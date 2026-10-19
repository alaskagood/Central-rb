--!strict
-- Inventario de lotes por "holder": "u:<UserId>" (lo que trae un jugador) o
-- "b:<número>" (una bodega). Todo cambio pasa por aquí; el cliente solo ve copias.
--
-- API para los demás servicios (H2 diablero, H4 jefe, H5 camionero, H6 revendedor):
--   InventoryService.add(holder, productId, units, freshness, owner, cost) --> Lot
--   InventoryService.take(holder, lotId, units) --> Lot? (sale del holder, nadie lo tiene)
--   InventoryService.put(holder, lot)                (mete un lote, se junta si se puede)
--   InventoryService.move(from, to, lotId, units) --> Lot?
--   InventoryService.hit(holder, lotId, impact)      (golpe 0 a 1: caída del diablo, frenazo)
--   InventoryService.list(holder) --> {Lot}         (no modificar la tabla regresada)
--   InventoryService.setStorage(holder, "sol" | "sombra" | "frio")

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Freshness = require(ReplicatedStorage.Shared.Freshness)
local Lots = require(ReplicatedStorage.Shared.Lots)
local Products = require(ReplicatedStorage.Shared.Config.Products)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

type Lot = Lots.Lot

local InventoryService = {}

local holders: { [string]: { Lot } } = {}
local storage: { [string]: Freshness.Storage } = {}
local listeners: { (holder: string) -> () } = {}

local function newId(): string
	return HttpService:GenerateGUID(false)
end

local function playerOf(holder: string): Player?
	-- En las pruebas multijugador de Studio los UserId son negativos (Player1 = -1).
	local userId = tonumber(string.match(holder, "^u:(%-?%d+)$"))
	return if userId then Players:GetPlayerByUserId(userId) else nil
end

-- Avisa al jugador dueño del holder qué trae ahora.
local function changed(holder: string)
	local player = playerOf(holder)
	if player then
		Remotes.get("Inventory"):FireClient(player, holders[holder] or {})
	end
	for _, fn in listeners do
		task.spawn(fn, holder)
	end
end

-- Para bodegas y otros holders: `fn(holder)` después de cada cambio.
function InventoryService.onChanged(fn: (holder: string) -> ())
	table.insert(listeners, fn)
end

local function find(holder: string, lotId: string): (Lot?, number)
	local list = holders[holder]
	if list then
		for i, lot in list do
			if lot.id == lotId then
				return lot, i
			end
		end
	end
	return nil, 0
end

function InventoryService.holderOf(player: Player): string
	return `u:{player.UserId}`
end

function InventoryService.list(holder: string): { Lot }
	return holders[holder] or {}
end

function InventoryService.setStorage(holder: string, kind: Freshness.Storage)
	storage[holder] = kind
end

function InventoryService.put(holder: string, lot: Lot)
	local list = holders[holder]
	if not list then
		list = {}
		holders[holder] = list
	end
	for _, other in list do
		if Lots.canMerge(other, lot) then
			Lots.merge(other, lot)
			changed(holder)
			return
		end
	end
	table.insert(list, lot)
	changed(holder)
end

function InventoryService.add(
	holder: string,
	productId: string,
	units: number,
	freshness: number,
	owner: number,
	cost: number
): Lot
	assert(Products[productId], "Producto desconocido: " .. productId)
	local lot = Lots.new(newId(), productId, units, freshness, owner, cost)
	InventoryService.put(holder, lot)
	return lot
end

function InventoryService.take(holder: string, lotId: string, units: number): Lot?
	local lot, index = find(holder, lotId)
	if not lot then
		return nil
	end
	local taken = Lots.take(lot, units, newId())
	if not taken then
		return nil
	end
	if lot.units == 0 then
		table.remove(holders[holder], index)
	end
	changed(holder)
	return taken
end

function InventoryService.move(from: string, to: string, lotId: string, units: number): Lot?
	local taken = InventoryService.take(from, lotId, units)
	if taken then
		InventoryService.put(to, taken)
	end
	return taken
end

function InventoryService.hit(holder: string, lotId: string, impact: number)
	local lot = find(holder, lotId)
	if lot then
		Lots.hit(lot, Products[lot.product].fragility, impact)
		changed(holder)
	end
end

-- DataService: carga lo guardado (ya validado) y lo suelta al salir.
function InventoryService.load(holder: string, saved: { unknown })
	local list = {}
	for _, raw in saved do
		local lot = Lots.validate(raw, Products)
		if lot then
			table.insert(list, lot)
		end
	end
	holders[holder] = list
	changed(holder)
end

function InventoryService.drop(holder: string)
	holders[holder] = nil
	storage[holder] = nil
end

-- Cada hora de juego todo se echa a perder un poco (según dónde esté guardado).
function InventoryService.start(clock: { onHour: (fn: (hour: number, day: number) -> ()) -> () })
	clock.onHour(function()
		for holder, list in holders do
			for _, lot in list do
				Lots.age(lot, 1, Products[lot.product].shelfLifeHours, storage[holder])
			end
			changed(holder)
		end
	end)
end

return InventoryService

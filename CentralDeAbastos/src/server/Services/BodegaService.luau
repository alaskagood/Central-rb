--!strict
-- H4 Jefe de bodega. Cada jefe recibe una bodega libre (su mercancía se guarda en su
-- perfil), compra cajas en la Subasta, pone precio por producto en su pizarrón y
-- cualquiera le compra por caja en la cortina. Todo se valida aquí.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryService = require(script.Parent.InventoryService)
local DataService = require(script.Parent.DataService)
local MarketService = require(script.Parent.MarketService)
local Products = require(ReplicatedStorage.Shared.Config.Products)
local Freshness = require(ReplicatedStorage.Shared.Freshness)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Scale = require(ReplicatedStorage.Shared.Config.Scale)

local BodegaService = {}

local MAX_UNITS = 100
local MAX_PRICE = 100000
local BUY_DISTANCE = Scale.m(15) -- desde el pizarrón
local DEFAULT_MARKUP = 1.15 -- precio de venta si el jefe no ha puesto uno

export type Offer = {
	id: string,
	product: string,
	units: number,
	freshness: number,
	price: number,
}

local bodegas: { [number]: Model } = {}

local function holder(n: number): string
	return `b:{n}`
end

local function isCount(n: unknown, max: number): boolean
	return type(n) == "number" and n == n and n >= 1 and n <= max and n % 1 == 0
end

local function cashOf(player: Player): number
	local c = player:GetAttribute("Cash")
	return if type(c) == "number" then c else 0
end

local function notify(player: Player, text: string)
	Remotes.get("Notify"):FireClient(player, text)
end

local function ownerOf(n: number): Player?
	local id = bodegas[n]:GetAttribute("OwnerUserId")
	return if type(id) == "number" and id ~= 0 then Players:GetPlayerByUserId(id) else nil
end

local function salePrice(n: number, productId: string): number
	local set = bodegas[n]:GetAttribute("Precio_" .. productId)
	if type(set) == "number" then
		return set
	end
	return math.floor(MarketService.price(productId) * DEFAULT_MARKUP / 5 + 0.5) * 5
end

local function offers(n: number): { Offer }
	local out = {}
	for _, lot in InventoryService.list(holder(n)) do
		if Freshness.grade(lot.freshness) ~= "basura" then
			table.insert(out, {
				id = lot.id,
				product = lot.product,
				units = lot.units,
				freshness = lot.freshness,
				price = salePrice(n, lot.product),
			})
		end
	end
	return out
end

-- Pizarrón de gis: un renglón por producto con cajas y precio.
local function refreshBoard(n: number)
	local label = bodegas[n]:FindFirstChild("Lista", true)
	if not (label and label:IsA("TextLabel")) then
		return
	end
	local units: { [string]: number } = {}
	for _, offer in offers(n) do
		units[offer.product] = (units[offer.product] or 0) + offer.units
	end
	local lines = {}
	for productId, u in units do
		table.insert(lines, `{Products[productId].name}  ${salePrice(n, productId)}  ({u})`)
	end
	table.sort(lines)
	local owner = ownerOf(n)
	local title = if owner then `BODEGA {n} · {owner.DisplayName}` else `BODEGA {n} · SE RENTA`
	label.Text = title .. "\n" .. (if #lines > 0 then table.concat(lines, "\n") else "Sin mercancía")
end

local function sendStock(n: number)
	local owner = ownerOf(n)
	if owner then
		Remotes.get("BodegaStock"):FireClient(owner, n, offers(n))
	end
	refreshBoard(n)
end

local function setSign(n: number, text: string)
	local sign = bodegas[n]:FindFirstChild("Texto", true)
	if sign and sign:IsA("TextLabel") then
		sign.Text = text
	end
end

local function claim(player: Player)
	if player:GetAttribute("Bodega") ~= nil then
		return
	end
	local free: number? = nil
	for n, model in bodegas do
		if model:GetAttribute("OwnerUserId") == 0 and (free == nil or n < free) then
			free = n
		end
	end
	if not free then
		notify(player, "No hay bodegas libres en este servidor.")
		return
	end
	local n = free :: number
	bodegas[n]:SetAttribute("OwnerUserId", player.UserId)
	player:SetAttribute("Bodega", n)
	setSign(n, `BODEGA {n} · {string.upper(player.DisplayName)}`)
	local data = DataService.getData(player)
	InventoryService.setStorage(holder(n), "sombra")
	InventoryService.load(holder(n), if data then data.bodegaLots else {})
	sendStock(n)
	Remotes.get("MarketPrices"):FireClient(player, MarketService.all())
	notify(player, `Tu bodega es la {n}. Compra en la Subasta y pon tus precios.`)
end

local function release(player: Player)
	local n = player:GetAttribute("Bodega")
	if type(n) ~= "number" or not bodegas[n] then
		return
	end
	InventoryService.drop(holder(n))
	for productId in Products do
		bodegas[n]:SetAttribute("Precio_" .. productId, nil)
	end
	bodegas[n]:SetAttribute("OwnerUserId", 0)
	setSign(n, `BODEGA {n}`)
	refreshBoard(n)
end

local function bodegaOf(player: Player): number?
	local n = player:GetAttribute("Bodega")
	return if type(n) == "number" and bodegas[n] then n else nil
end

local function near(player: Player, n: number): boolean
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local board = bodegas[n]:FindFirstChild("Tabla", true)
	local target = if board and board:IsA("BasePart") then board.Position else bodegas[n]:GetPivot().Position
	return root ~= nil and root:IsA("BasePart") and (root.Position - target).Magnitude <= BUY_DISTANCE
end

-- El jefe compra en la Subasta: entra a su bodega como lote fresco.
local function onMarketBuy(player: Player, productId: unknown, units: unknown)
	local n = bodegaOf(player)
	if not n or type(productId) ~= "string" or not Products[productId] or not isCount(units, MAX_UNITS) then
		return
	end
	local price = MarketService.price(productId)
	local total = price * (units :: number)
	if cashOf(player) < total then
		notify(player, "No te alcanza.")
		return
	end
	player:SetAttribute("Cash", cashOf(player) - total)
	InventoryService.add(holder(n), productId, units :: number, 100, player.UserId, price)
	notify(player, `Compraste {units} de {Products[productId].name} por ${total}.`)
end

local function onSetPrice(player: Player, productId: unknown, price: unknown)
	local n = bodegaOf(player)
	if not n or type(productId) ~= "string" or not Products[productId] or not isCount(price, MAX_PRICE) then
		return
	end
	bodegas[n]:SetAttribute("Precio_" .. productId, price)
	sendStock(n)
end

-- Cualquiera (menos el dueño) compra cajas en la cortina. El dinero va al jefe.
local function onBodegaBuy(player: Player, n: unknown, lotId: unknown, units: unknown)
	if type(n) ~= "number" or not bodegas[n] or type(lotId) ~= "string" or not isCount(units, MAX_UNITS) then
		return
	end
	local owner = ownerOf(n)
	if not owner or owner == player or not near(player, n) then
		return
	end
	local offer: Offer? = nil
	for _, o in offers(n) do
		if o.id == lotId then
			offer = o
		end
	end
	if not offer or offer.units < (units :: number) then
		notify(player, "Ya no hay tantas cajas.")
		return
	end
	local total = offer.price * (units :: number)
	if cashOf(player) < total then
		notify(player, "No te alcanza.")
		return
	end
	local lot = InventoryService.take(holder(n), lotId, units :: number)
	if not lot then
		return
	end
	lot.owner = player.UserId
	lot.cost = offer.price
	player:SetAttribute("Cash", cashOf(player) - total)
	owner:SetAttribute("Cash", cashOf(owner) + total)
	InventoryService.put(InventoryService.holderOf(player), lot)
	notify(player, `Compraste {units} de {Products[offer.product].name} por ${total}.`)
	notify(owner, `{player.DisplayName} te compró {units} de {Products[offer.product].name}: +${total}`)
	Remotes.get("BodegaOpen"):FireClient(player, n, offers(n), owner.DisplayName, false)
end

function BodegaService.start()
	local ceda = workspace:WaitForChild("CEDA")
	for _, d in ceda:GetDescendants() do
		local n = d:GetAttribute("Number")
		if d:IsA("Model") and type(n) == "number" then
			bodegas[n] = d
			d:SetAttribute("OwnerUserId", 0)
			local board = d:FindFirstChild("Tabla", true)
			if board then
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Ver precios"
				prompt.ObjectText = `Bodega {n}`
				prompt.HoldDuration = 0
				prompt.MaxActivationDistance = 12
				prompt.RequiresLineOfSight = false
				prompt.Parent = board
				prompt.Triggered:Connect(function(player: Player)
					local owner = ownerOf(n)
					Remotes.get("BodegaOpen"):FireClient(
						player,
						n,
						offers(n),
						if owner then owner.DisplayName else "",
						owner == player
					)
				end)
			end
			refreshBoard(n)
		end
	end

	InventoryService.onChanged(function(h: string)
		local n = tonumber(string.match(h, "^b:(%d+)$"))
		if n and bodegas[n] then
			sendStock(n)
		end
	end)

	local function watch(player: Player)
		local function check()
			if player:GetAttribute("Role") == "Jefe" and player:GetAttribute("DataLoaded") then
				claim(player)
			end
		end
		player:GetAttributeChangedSignal("Role"):Connect(check)
		check()
	end
	for _, p in Players:GetPlayers() do
		watch(p)
	end
	Players.PlayerAdded:Connect(watch)
	-- Diferido: DataService guarda la bodega en el perfil antes de soltarla.
	Players.PlayerRemoving:Connect(function(player: Player)
		task.defer(release, player)
	end)

	Remotes.get("MarketBuy").OnServerEvent:Connect(onMarketBuy)
	Remotes.get("SetPrice").OnServerEvent:Connect(onSetPrice)
	Remotes.get("BodegaBuy").OnServerEvent:Connect(onBodegaBuy)
end

return BodegaService

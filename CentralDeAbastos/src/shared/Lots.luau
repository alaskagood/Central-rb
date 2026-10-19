--!strict
-- Lotes: N unidades comerciales (cajas, arpillas, costales) del mismo producto,
-- con la misma frescura y el mismo dueño. Lógica pura (se prueba con lune).

local Freshness = if script then require(script.Parent.Freshness) else require("./Freshness")

export type Lot = {
	id: string,
	product: string, -- id de Config/Products
	units: number, -- entero >= 1
	freshness: number, -- 0 a 100
	owner: number, -- UserId del dueño (0 = mercado / NPC)
	cost: number, -- lo que se pagó por unidad, para saber si hubo ganancia
}

local Lots = {}

-- Dos lotes se juntan si son el mismo producto y dueño y su frescura es casi igual
-- (así un lote de primera no "rescata" uno de rezaga).
local MERGE_FRESHNESS_GAP = 5

local function isCount(n: unknown): boolean
	return type(n) == "number" and n == n and n >= 1 and n % 1 == 0 and n < 1e6
end

function Lots.new(id: string, product: string, units: number, freshness: number, owner: number, cost: number): Lot
	assert(isCount(units), "units debe ser entero >= 1")
	return {
		id = id,
		product = product,
		units = units,
		freshness = math.clamp(freshness, 0, 100),
		owner = owner,
		cost = math.max(cost, 0),
	}
end

-- Saca `units` del lote y regresa el lote nuevo con id `newId`.
-- Si se saca todo, el original queda en 0 y quien llama debe quitarlo.
function Lots.take(lot: Lot, units: number, newId: string): Lot?
	if not isCount(units) or units > lot.units then
		return nil
	end
	lot.units -= units
	return Lots.new(newId, lot.product, units, lot.freshness, lot.owner, lot.cost)
end

function Lots.canMerge(a: Lot, b: Lot): boolean
	return a.product == b.product
		and a.owner == b.owner
		and math.abs(a.freshness - b.freshness) <= MERGE_FRESHNESS_GAP
end

-- Junta `from` dentro de `into` (promedio ponderado de frescura y costo).
function Lots.merge(into: Lot, from: Lot)
	local total = into.units + from.units
	into.freshness = (into.freshness * into.units + from.freshness * from.units) / total
	into.cost = (into.cost * into.units + from.cost * from.units) / total
	into.units = total
end

function Lots.age(lot: Lot, hours: number, shelfLifeHours: number, storage: Freshness.Storage?)
	lot.freshness = Freshness.decay(lot.freshness, shelfLifeHours, hours, storage)
end

function Lots.hit(lot: Lot, fragility: number, impact: number)
	lot.freshness = Freshness.hit(lot.freshness, fragility, impact)
end

function Lots.grade(lot: Lot): Freshness.Grade
	return Freshness.grade(lot.freshness)
end

-- Lo que viene del DataStore no se confía: regresa un Lot limpio o nil.
function Lots.validate(t: unknown, products: { [string]: any }): Lot?
	if type(t) ~= "table" then
		return nil
	end
	local r = t :: any
	if type(r.id) ~= "string" or type(r.product) ~= "string" or products[r.product] == nil then
		return nil
	end
	if not isCount(r.units) or type(r.freshness) ~= "number" or r.freshness ~= r.freshness then
		return nil
	end
	if type(r.owner) ~= "number" or type(r.cost) ~= "number" or r.cost ~= r.cost then
		return nil
	end
	return Lots.new(r.id, r.product, r.units, r.freshness, r.owner, r.cost)
end

return Lots

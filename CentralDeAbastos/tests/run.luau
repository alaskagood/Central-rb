--!strict
-- Pruebas de la lógica pura. Correr desde CentralDeAbastos/:  lune run tests/run
-- Los módulos Config usan Color3/Enum, así que aquí se cargan solo los puros
-- y una copia mínima de un producto.

local Pricing = require("../src/shared/Pricing")
local Freshness = require("../src/shared/Freshness")

local failures = 0
local total = 0

local function check(name: string, ok: boolean)
	total += 1
	if ok then
		print("OK   " .. name)
	else
		failures += 1
		print("FALLA " .. name)
	end
end

local function near(a: number, b: number, eps: number?): boolean
	return math.abs(a - b) <= (eps or 1e-6)
end

local jitomate = {
	pricePerKg = 25.83,
	unitKg = 13,
	volatility = 0.12,
	season = { 0.9, 0.85, 1.6, 1.3, 1.1, 1.15, 1, 1, 1, 1, 1.05, 1.1 },
}

local base = { month = 10, hour = 4, demand = 100, supply = 100 }

-- Precio
check("precio base en octubre a las 4:00 = SNIIM", near(Pricing.pricePerKg(jitomate, base), 25.83))
check("caja de jitomate ≈ $335", Pricing.pricePerUnit(jitomate, base) == 335)
check(
	"marzo (heladas) más caro que febrero",
	Pricing.pricePerKg(jitomate, { month = 3, hour = 4, demand = 1, supply = 1 })
		> Pricing.pricePerKg(jitomate, { month = 2, hour = 4, demand = 1, supply = 1 })
)
check(
	"más demanda que oferta sube el precio",
	Pricing.pricePerKg(jitomate, { month = 10, hour = 4, demand = 200, supply = 100 }) > 25.83
)
check(
	"después de las 11:00 baja a 0.75",
	near(Pricing.pricePerKg(jitomate, { month = 10, hour = 12, demand = 1, supply = 1 }), 25.83 * 0.75)
)
check("hora 10:00 a medio camino", near(Pricing.hourFactor(10), 0.875))
check("hora 23:00 = 1", Pricing.hourFactor(23) == 1)
check(
	"segunda vale 75%",
	near(
		Pricing.pricePerKg(jitomate, { month = 10, hour = 4, demand = 1, supply = 1, quality = "segunda" }),
		25.83 * 0.75
	)
)
check(
	"oferta 0 no truena",
	Pricing.pricePerKg(jitomate, { month = 10, hour = 4, demand = 10, supply = 0 }) > 0
)

local seq = { 0.5, 0.25 }
local i = 0
local fakeRng = {
	NextNumber = function(_self: any): number
		i += 1
		return seq[(i - 1) % #seq + 1]
	end,
}
local g = Pricing.gaussian(fakeRng)
check("gaussiana finita", g == g and math.abs(g) < 10)

-- Merma
check("grado primera", Freshness.grade(85) == "primera")
check("grado segunda", Freshness.grade(55) == "segunda")
check("grado rezaga", Freshness.grade(20) == "rezaga")
check("grado basura", Freshness.grade(5) == "basura")
check("vida útil completa = 0", near(Freshness.decay(100, 144, 144), 0))
check(
	"cámara fría merma menos",
	Freshness.decay(100, 144, 24, "frio") > Freshness.decay(100, 144, 24, "sol")
)
check("golpe a jitomate pega más que a papa", Freshness.hit(100, 0.9, 1) < Freshness.hit(100, 0.15, 1))
check("frescura no baja de 0", Freshness.decay(5, 10, 100) == 0)

-- Lotes
local Lots = require("../src/shared/Lots")
local a = Lots.new("a", "jitomate_saladette", 10, 90, 1, 300)
local cut = Lots.take(a, 4, "b")
check("sacar 4 de 10 deja 6", a.units == 6 and cut ~= nil and cut.units == 4)
check("no se saca más de lo que hay", Lots.take(a, 7, "c") == nil and a.units == 6)
check("no se sacan fracciones ni negativos", Lots.take(a, 1.5, "c") == nil and Lots.take(a, -1, "c") == nil)
local b = Lots.new("d", "jitomate_saladette", 10, 80, 1, 200)
check("frescura 90 vs 80 no se junta", not Lots.canMerge(a, b))
local c2 = Lots.new("e", "jitomate_saladette", 2, 88, 1, 360)
check("frescura parecida sí se junta", Lots.canMerge(a, c2))
Lots.merge(a, c2)
check("merge suma unidades", a.units == 8)
check("merge pondera costo", near(a.cost, (6 * 300 + 2 * 360) / 8))
check("otro dueño no se junta", not Lots.canMerge(a, Lots.new("f", "jitomate_saladette", 1, 90, 2, 300)))
Lots.age(a, 144, 144)
check("envejecer toda la vida útil = basura", Lots.grade(a) == "basura")
local catalog = { jitomate_saladette = jitomate }
check("validate acepta lote bueno", Lots.validate({ id = "x", product = "jitomate_saladette", units = 3, freshness = 50, owner = 1, cost = 10 }, catalog) ~= nil)
check("validate rechaza producto inventado", Lots.validate({ id = "x", product = "oro", units = 3, freshness = 50, owner = 1, cost = 10 }, catalog) == nil)
check("validate rechaza unidades raras", Lots.validate({ id = "x", product = "jitomate_saladette", units = 0, freshness = 50, owner = 1, cost = 10 }, catalog) == nil)
check("validate rechaza NaN", Lots.validate({ id = "x", product = "jitomate_saladette", units = 1, freshness = 0 / 0, owner = 1, cost = 10 }, catalog) == nil)

-- Regateo
local Haggle = require("../src/shared/Haggle")
local h = Haggle.new(400, 1, 0.5, 0)
check("tope = 400 · 1.2 = 480", h.maxPay == 480)
check("abre 30% abajo del tope", h.offer == 335)
local r1, p1 = Haggle.ask(h, 450)
check("pedir abajo del tope se vende a lo pedido", r1 == "accept" and p1 == 450)
local h2 = Haggle.new(400, 1, 0.5, 0, 2)
local r2, p2 = Haggle.ask(h2, 600)
check("pedir de más: contraoferta más alta", r2 == "counter" and p2 > 335 and p2 <= 480)
local r3 = Haggle.ask(h2, 600)
check("sin paciencia se va", r3 == "leave")
check("rezaga paga menos", Haggle.new(400, 0.4, 0.5, 0).maxPay < Haggle.new(400, 1, 0.5, 0).maxPay)
local r4, p4 = Haggle.ask(Haggle.new(400, 1, 0.5, 0), 0 / 0)
check("pedir NaN no vende", r4 == "counter" and p4 == 335)

print(`\n{total - failures}/{total} pruebas OK`)
if failures > 0 then
	error(`{failures} pruebas fallaron`)
end

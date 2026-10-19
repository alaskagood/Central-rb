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

print(`\n{total - failures}/{total} pruebas OK`)
if failures > 0 then
	error(`{failures} pruebas fallaron`)
end

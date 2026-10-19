--!strict
-- Modelo de precio diario (doc original, sección 7):
-- P = base · S(mes) · (D/O)^e · E · H(hora) · Q · (1 + σ·N(0,1))
-- Lógica pura: sin APIs de Roblox, se prueba con lune.

local Pricing = {}

export type Quality = "primera" | "segunda" | "rezaga"

export type Inputs = {
	month: number, -- 1 a 12
	hour: number, -- 0 a 23.99
	demand: number,
	supply: number,
	event: number?, -- helada 1.5, bloqueo 1.3, sobreproducción 0.6
	quality: Quality?,
	elasticity: number?, -- 0.3 a 0.8
	noise: number?, -- muestra de N(0,1); 0 = sin ruido
}

local QUALITY: { [Quality]: number } = {
	primera = 1,
	segunda = 0.75,
	rezaga = 0.4,
}

-- 1.0 en la madrugada; los perecederos bajan hasta 0.75 después de las 11:00.
function Pricing.hourFactor(hour: number): number
	if hour >= 22 or hour < 9 then
		return 1
	elseif hour < 11 then
		return 1 - 0.125 * (hour - 9) -- 9:00 → 1.0, 11:00 → 0.75
	elseif hour < 22 then
		return 0.75
	end
	return 1
end

-- Muestra de N(0,1) con Box-Muller. `rng` es un Random de Roblox o cualquier
-- objeto con :NextNumber().
function Pricing.gaussian(rng: { NextNumber: (any) -> number }): number
	local u1 = math.max(rng:NextNumber(), 1e-9)
	local u2 = rng:NextNumber()
	return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
end

-- Precio por kg. `product` es una entrada de Config/Products.
function Pricing.pricePerKg(product: any, inputs: Inputs): number
	local season = product.season[inputs.month] or 1
	local supply = math.max(inputs.supply, 1)
	local ratio = math.clamp(inputs.demand / supply, 0.25, 4)
	local market = ratio ^ (inputs.elasticity or 0.5)
	local event = inputs.event or 1
	local quality = QUALITY[inputs.quality or "primera"]
	local noise = 1 + product.volatility * math.clamp(inputs.noise or 0, -3, 3)
	local price = product.pricePerKg
		* season
		* market
		* event
		* Pricing.hourFactor(inputs.hour)
		* quality
		* noise
	return math.max(price, 0.5)
end

-- Precio por unidad comercial (caja, arpilla, costal), redondeado a $5.
function Pricing.pricePerUnit(product: any, inputs: Inputs): number
	local raw = Pricing.pricePerKg(product, inputs) * product.unitKg
	return math.max(5, math.floor(raw / 5 + 0.5) * 5)
end

return Pricing

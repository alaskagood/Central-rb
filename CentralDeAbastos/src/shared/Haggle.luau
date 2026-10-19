--!strict
-- Regateo por turnos con un comprador NPC del tianguis. Lógica pura.
-- El NPC trae un tope secreto (maxPay) y abre ofreciendo menos. El vendedor acepta o pide
-- más; si pide arriba del tope, el NPC se acerca un poco y pierde paciencia.

export type Haggle = {
	offer: number, -- lo que ofrece ahora por unidad
	maxPay: number, -- lo más que pagaría (el vendedor no lo ve)
	patience: number, -- contraofertas que aguanta antes de irse
}

export type Result = "accept" | "counter" | "leave"

local Haggle = {}

local function round5(n: number): number
	return math.max(5, math.floor(n / 5 + 0.5) * 5)
end

-- `retail`: precio justo por unidad al menudeo. `quality`: 1 primera, 0.75 segunda, 0.4 rezaga.
-- `rollMax` y `rollOpen` son números de 0 a 1 (azar del servidor).
function Haggle.new(retail: number, quality: number, rollMax: number, rollOpen: number, patience: number?): Haggle
	local maxPay = round5(retail * quality * (1.05 + 0.3 * math.clamp(rollMax, 0, 1)))
	local offer = round5(maxPay * (0.7 + 0.15 * math.clamp(rollOpen, 0, 1)))
	return { offer = math.min(offer, maxPay), maxPay = maxPay, patience = patience or 3 }
end

-- El vendedor pide `ask` por unidad. Regresa el resultado y el precio:
-- "accept" + precio de venta, "counter" + nueva oferta del NPC, o "leave" + 0.
function Haggle.ask(h: Haggle, ask: number): (Result, number)
	if ask ~= ask or ask <= 0 then
		return "counter", h.offer
	end
	if ask <= h.maxPay then
		return "accept", math.max(round5(ask), h.offer)
	end
	h.patience -= 1
	if h.patience <= 0 then
		return "leave", 0
	end
	h.offer = math.min(round5((h.offer + h.maxPay) / 2), h.maxPay)
	return "counter", h.offer
end

return Haggle

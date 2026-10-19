--!strict
-- Merma: cada lote tiene frescura de 100 a 0. Lógica pura.

local Freshness = {}

export type Grade = "primera" | "segunda" | "rezaga" | "basura"

export type Storage = "sol" | "sombra" | "frio"

-- El sol acelera la merma; la cámara fría la reduce de 60 a 80% (usamos 70%).
local STORAGE_RATE: { [Storage]: number } = {
	sol = 1.5,
	sombra = 1,
	frio = 0.3,
}

function Freshness.grade(freshness: number): Grade
	if freshness >= 70 then
		return "primera"
	elseif freshness >= 40 then
		return "segunda"
	elseif freshness >= 10 then
		return "rezaga"
	end
	return "basura"
end

-- Frescura después de `hours` horas de juego.
function Freshness.decay(freshness: number, shelfLifeHours: number, hours: number, storage: Storage?): number
	local perHour = 100 / math.max(shelfLifeHours, 1)
	local rate = STORAGE_RATE[storage or "sombra"]
	return math.clamp(freshness - perHour * rate * hours, 0, 100)
end

-- Golpe (frenazo, caída del diablo, bache). `impact` de 0 a 1.
function Freshness.hit(freshness: number, fragility: number, impact: number): number
	local loss = 25 * math.clamp(fragility, 0, 1) * math.clamp(impact, 0, 1)
	return math.clamp(freshness - loss, 0, 100)
end

return Freshness

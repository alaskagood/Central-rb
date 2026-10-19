--!strict
-- Escala del mundo. Convención común de Roblox: 1 stud ≈ 0.28 m.

local Scale = {}

Scale.STUDS_PER_METER = 3.57

function Scale.m(meters: number): number
	return meters * Scale.STUDS_PER_METER
end

return Scale

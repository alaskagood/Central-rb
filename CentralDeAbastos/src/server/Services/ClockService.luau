--!strict
-- Reloj del juego. La madrugada (22:00 a 10:00) corre lenta porque ahí pasa todo.
-- Publica la hora en ReplicatedStorage:GetAttribute("GameHour") y mueve Lighting.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClockService = {}

local SECONDS_PER_HOUR_NIGHT = 90
local SECONDS_PER_HOUR_DAY = 30
local START_HOUR = 22

local hour = START_HOUR
local day = 1

local listeners: { (hour: number, day: number) -> () } = {}

local function isNight(h: number): boolean
	return h >= 22 or h < 10
end

-- Llama a `fn` cada vez que cambia la hora entera.
function ClockService.onHour(fn: (hour: number, day: number) -> ())
	table.insert(listeners, fn)
end

function ClockService.getHour(): number
	return hour
end

function ClockService.start()
	local lastWhole = math.floor(hour)
	RunService.Heartbeat:Connect(function(dt: number)
		local secondsPerHour = if isNight(hour) then SECONDS_PER_HOUR_NIGHT else SECONDS_PER_HOUR_DAY
		hour += dt / secondsPerHour
		if hour >= 24 then
			hour -= 24
			day += 1
		end
		Lighting.ClockTime = hour
		ReplicatedStorage:SetAttribute("GameHour", hour)
		ReplicatedStorage:SetAttribute("GameDay", day)

		local whole = math.floor(hour)
		if whole ~= lastWhole then
			lastWhole = whole
			for _, fn in listeners do
				task.spawn(fn, whole, day)
			end
		end
	end)
end

return ClockService

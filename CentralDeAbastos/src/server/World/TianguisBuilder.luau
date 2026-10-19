--!strict
-- Tianguis del vertical slice: 6 puestos con lona rosa en hilera, frente a una explanada
-- por donde llegan los compradores NPC. Medidas en metros.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = require(script.Parent.Parent.Assets)
local Scale = require(ReplicatedStorage.Shared.Config.Scale)

local m = Scale.m

local TianguisBuilder = {}

local PUESTOS = 6
local SEPARACION = 5.5 -- metros entre centros de puesto

function TianguisBuilder.build(parent: Instance, origin: CFrame): Folder
	local tianguis = Instance.new("Folder")
	tianguis.Name = "Tianguis"
	tianguis.Parent = parent

	local explanada = Instance.new("Part")
	explanada.Name = "Explanada"
	explanada.Anchored = true
	explanada.Size = Vector3.new(m(SEPARACION * PUESTOS + 6), 0.2, m(16))
	explanada.CFrame = origin * CFrame.new(0, 0.1, m(5))
	explanada.Color = Color3.fromRGB(150, 140, 125)
	explanada.Material = Enum.Material.Pavement
	explanada.Parent = tianguis

	for i = 1, PUESTOS do
		local x = (i - (PUESTOS + 1) / 2) * m(SEPARACION)
		-- El mostrador del modelo está en su −Z: girado 180° queda viendo a la explanada.
		local puesto = Assets.place("PuestoTianguis", origin * CFrame.new(x, 0, 0) * CFrame.Angles(0, math.pi, 0), tianguis)
		puesto.Name = `Puesto_{i}`
		puesto:SetAttribute("Puesto", i)
		puesto:SetAttribute("OwnerUserId", 0)
	end
	return tianguis
end

return TianguisBuilder

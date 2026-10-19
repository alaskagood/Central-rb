--!strict
-- Blockout del vertical slice: 1 nave con 2 hileras de bodegas frente a frente.
-- Al centro el pasillo peatonal; detrás de cada hilera, el andén de carga.
-- Las medidas están en metros (Scale.m) para respetar la CEDA real.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = require(script.Parent.Parent.Assets)
local Scale = require(ReplicatedStorage.Shared.Config.Scale)

local m = Scale.m

local NaveBuilder = {}

local BODEGAS_PER_ROW = 4
local BODEGA_FRONT = 5
local BODEGA_DEPTH = 20
local PASILLO_WIDTH = 8
local ANDEN_WIDTH = 6

local function slab(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = Enum.Material.Concrete
	p.TopSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
end

function NaveBuilder.build(parent: Instance, origin: CFrame): Folder
	local nave = Instance.new("Folder")
	nave.Name = "Nave_IJ"
	nave.Parent = parent

	local rowLength = m(BODEGA_FRONT * BODEGAS_PER_ROW)
	local index = 0

	-- Pasillo peatonal al centro (diableros y compradores).
	slab(
		"Pasillo",
		Vector3.new(m(PASILLO_WIDTH), 0.2, rowLength),
		origin * CFrame.new(0, 0.1, 0),
		Color3.fromRGB(120, 118, 112),
		nave
	)

	-- side = -1 hilera poniente, +1 hilera oriente. Cada bodega abre al pasillo
	-- y por detrás tiene el andén donde los camiones se meten en reversa.
	for _, side in { -1, 1 } do
		local rowX = side * m(PASILLO_WIDTH / 2 + BODEGA_DEPTH / 2)
		for i = 0, BODEGAS_PER_ROW - 1 do
			index += 1
			local z = -rowLength / 2 + m(BODEGA_FRONT) * (i + 0.5)
			local cf = origin * CFrame.new(rowX, 0, z)
			local bodega = Assets.place("Bodega", cf * CFrame.Angles(0, math.rad(90), 0), nave)
			bodega.Name = `Bodega_{index}`
			bodega:SetAttribute("Number", 100 + index)
			bodega:SetAttribute("OwnerUserId", 0)
		end

		slab(
			`Anden_{if side < 0 then "Poniente" else "Oriente"}`,
			Vector3.new(m(ANDEN_WIDTH), 0.2, rowLength),
			origin * CFrame.new(side * m(PASILLO_WIDTH / 2 + BODEGA_DEPTH + ANDEN_WIDTH / 2), 0.1, 0),
			Color3.fromRGB(80, 80, 80),
			nave
		)
	end

	Assets.place("Caseta", origin * CFrame.new(0, 0, rowLength / 2 + m(25)), nave)
	return nave
end

return NaveBuilder

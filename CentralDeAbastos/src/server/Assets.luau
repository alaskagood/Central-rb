--!strict
-- Assets.get(clave) → copia del modelo de ServerStorage/Assets/<clave> si existe
-- (traído de la Tienda de creadores), o un bloque del tamaño real si no.

local ServerStorage = game:GetService("ServerStorage")

local AssetCatalog = require(script.Parent.AssetCatalog)
local Scale = require(game:GetService("ReplicatedStorage").Shared.Config.Scale)

local Assets = {}

local warned: { [string]: boolean } = {}

local function placeholder(key: string, entry: AssetCatalog.Entry): Model
	local model = Instance.new("Model")
	model.Name = key
	local part = Instance.new("Part")
	part.Name = "Placeholder"
	part.Anchored = true
	part.Size = entry.size * Scale.STUDS_PER_METER
	part.Color = entry.color
	part.Material = entry.material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	model.PrimaryPart = part
	model:SetAttribute("Placeholder", true)
	return model
end

function Assets.get(key: string): Model
	local entry = AssetCatalog[key]
	assert(entry, "Asset sin entrada en AssetCatalog: " .. key)

	local folder = ServerStorage:FindFirstChild("Assets")
	local source = folder and folder:FindFirstChild(key)
	if source and source:IsA("Model") then
		return source:Clone()
	end

	if not warned[key] then
		warned[key] = true
		local terms = table.concat(entry.buscar, " / ")
		warn(`[Assets] "{key}" sin modelo: usando placeholder. Buscar en la Tienda: {terms}`)
	end
	return placeholder(key, entry)
end

-- Coloca el modelo con su base apoyada en `cframe` (el piso).
function Assets.place(key: string, cframe: CFrame, parent: Instance): Model
	local model = Assets.get(key)
	local _, size = model:GetBoundingBox()
	model:PivotTo(cframe * CFrame.new(0, size.Y / 2, 0))
	model.Parent = parent
	return model
end

return Assets

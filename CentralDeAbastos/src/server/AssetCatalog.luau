--!strict
-- Lista de assets del juego. REGLA: antes de modelar algo, buscarlo en la
-- Tienda de creadores con los términos de `buscar` (docs/02_CREATOR_STORE.md).
-- Si se encuentra uno bueno, se mete a ServerStorage/Assets/<clave>.
-- Si no, Assets.luau construye un bloque del tamaño real (en metros).

export type Entry = {
	buscar: { string },
	size: Vector3, -- metros (ancho, alto, largo)
	color: Color3,
	material: Enum.Material?,
}

local C = Color3.fromRGB

local AssetCatalog: { [string]: Entry } = {
	-- Arquitectura
	Bodega = {
		buscar = { "warehouse shop roll up door", "market stall garage", "bodega" },
		size = Vector3.new(5, 6, 20),
		color = C(170, 165, 150),
		material = Enum.Material.Concrete,
	},
	Caseta = {
		buscar = { "toll booth", "parking gate barrier", "security booth" },
		size = Vector3.new(3, 3, 3),
		color = C(230, 230, 230),
	},
	PuestoTianguis = {
		buscar = { "market stall", "mexican market stand", "tianguis" },
		size = Vector3.new(3, 2.5, 2),
		color = C(240, 90, 160),
		material = Enum.Material.Fabric,
	},
	-- Equipo de patio
	Diablito = {
		buscar = { "hand truck", "dolly cart", "sack truck" },
		size = Vector3.new(0.6, 1.3, 0.5),
		color = C(200, 40, 40),
		material = Enum.Material.Metal,
	},
	DiabloPlataforma = {
		buscar = { "platform cart", "flatbed trolley", "wagon cart" },
		size = Vector3.new(1, 0.6, 1.8),
		color = C(130, 90, 50),
		material = Enum.Material.Wood,
	},
	Bascula = {
		buscar = { "platform scale", "industrial scale" },
		size = Vector3.new(1, 0.9, 1),
		color = C(90, 90, 100),
		material = Enum.Material.Metal,
	},
	-- Envases
	CajaMadera = {
		buscar = { "wooden crate", "produce crate", "fruit crate" },
		size = Vector3.new(0.5, 0.3, 0.35),
		color = C(190, 150, 100),
		material = Enum.Material.Wood,
	},
	Arpilla = {
		buscar = { "mesh sack", "onion sack", "potato sack" },
		size = Vector3.new(0.5, 0.7, 0.35),
		color = C(200, 80, 40),
		material = Enum.Material.Fabric,
	},
	Costal = {
		buscar = { "burlap sack", "grain sack" },
		size = Vector3.new(0.5, 0.8, 0.35),
		color = C(220, 210, 180),
		material = Enum.Material.Fabric,
	},
	-- Vehículos (preferir chasis A-Chassis o similares bien mantenidos)
	PickUp = {
		buscar = { "pickup truck A-Chassis", "pickup truck drivable" },
		size = Vector3.new(1.9, 1.8, 5.2),
		color = C(230, 230, 230),
	},
	TresYMedia = {
		buscar = { "box truck drivable", "stake bed truck", "flatbed truck A-Chassis" },
		size = Vector3.new(2.2, 2.6, 6.5),
		color = C(240, 200, 60),
	},
	Torton = {
		buscar = { "dump truck drivable", "cargo truck A-Chassis", "10 wheeler truck" },
		size = Vector3.new(2.5, 3.5, 11),
		color = C(40, 90, 170),
	},
}

return AssetCatalog

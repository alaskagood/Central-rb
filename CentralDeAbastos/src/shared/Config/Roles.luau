--!strict
-- Los 4 oficios jugables. El servidor valida contra esta tabla.

export type RoleId = "Diablero" | "Camionero" | "Jefe" | "Revendedor"

export type Role = {
	id: RoleId,
	name: string,
	description: string,
	color: Color3,
	maxPerServer: number?, -- nil = sin límite
	startingCash: number,
}

local Roles: { [RoleId]: Role } = {
	Diablero = {
		id = "Diablero",
		name = "Diablero",
		description = "Mueve la carga con tu diablo por los pasillos. Cobras por caja.",
		color = Color3.fromRGB(230, 150, 40),
		maxPerServer = nil,
		startingCash = 200,
	},
	Camionero = {
		id = "Camionero",
		name = "Camionero",
		description = "Trae la mercancía, paga la caseta y métete en reversa al andén.",
		color = Color3.fromRGB(60, 120, 220),
		maxPerServer = nil,
		startingCash = 500,
	},
	Jefe = {
		id = "Jefe",
		name = "Jefe de bodega",
		description = "Compra camiones de producto, pon precios y contrata diableros.",
		color = Color3.fromRGB(200, 50, 50),
		maxPerServer = 8, -- una bodega por jefe en el vertical slice
		startingCash = 20000,
	},
	Revendedor = {
		id = "Revendedor",
		name = "Revendedor",
		description = "Compra al mayoreo y revende en tu puesto antes de que se eche a perder.",
		color = Color3.fromRGB(60, 170, 80),
		maxPerServer = nil,
		startingCash = 3000,
	},
}

return Roles

--!strict
-- 10 productos del vertical slice. Precios base: SNIIM, CEDA, 12 a 16 oct 2026
-- (ver docs/referencia/DocumentoDiseno_Original.md, sección 6).

export type Product = {
	id: string,
	name: string,
	origin: string,
	pricePerKg: number, -- precio frecuente de referencia
	unit: string, -- presentación comercial
	unitKg: number,
	shelfLifeHours: number, -- de frescura 100 a 0 a temperatura ambiente
	volatility: number, -- sigma diaria
	fragility: number, -- 0 a 1: cuánto le pegan los golpes
	-- multiplicador por mes (1 = enero)
	season: { number },
}

local FLAT = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }

local Products: { [string]: Product } = {
	jitomate_saladette = {
		id = "jitomate_saladette",
		name = "Jitomate saladette",
		origin = "Puebla",
		pricePerKg = 25.83,
		unit = "Caja de madera",
		unitKg = 13,
		shelfLifeHours = 144,
		volatility = 0.12,
		fragility = 0.9,
		season = { 0.9, 0.85, 1.6, 1.3, 1.1, 1.15, 1, 1, 1, 1, 1.05, 1.1 },
	},
	aguacate_hass = {
		id = "aguacate_hass",
		name = "Aguacate Hass",
		origin = "Michoacán",
		pricePerKg = 36.67,
		unit = "Caja",
		unitKg = 10,
		shelfLifeHours = 144,
		volatility = 0.08,
		fragility = 0.6,
		season = FLAT,
	},
	limon_semilla = {
		id = "limon_semilla",
		name = "Limón con semilla #5",
		origin = "Michoacán",
		pricePerKg = 16.5,
		unit = "Caja",
		unitKg = 19,
		shelfLifeHours = 288,
		volatility = 0.15,
		fragility = 0.3,
		season = { 1.1, 1.2, 1.4, 1.5, 1.2, 0.9, 0.8, 0.8, 0.9, 1, 1, 1 },
	},
	cebolla_bola = {
		id = "cebolla_bola",
		name = "Cebolla bola",
		origin = "Chihuahua",
		pricePerKg = 42,
		unit = "Arpilla",
		unitKg = 25,
		shelfLifeHours = 600,
		volatility = 0.04,
		fragility = 0.2,
		season = FLAT,
	},
	papa_alpha = {
		id = "papa_alpha",
		name = "Papa alpha",
		origin = "Edomex",
		pricePerKg = 14,
		unit = "Arpilla",
		unitKg = 50,
		shelfLifeHours = 600,
		volatility = 0.04,
		fragility = 0.15,
		season = FLAT,
	},
	naranja_valencia = {
		id = "naranja_valencia",
		name = "Naranja Valencia",
		origin = "Veracruz",
		pricePerKg = 12.3,
		unit = "Costal",
		unitKg = 25,
		shelfLifeHours = 300,
		volatility = 0.06,
		fragility = 0.3,
		season = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.15, 1.1, 1.2 },
	},
	platano_tabasco = {
		id = "platano_tabasco",
		name = "Plátano Tabasco",
		origin = "Tabasco",
		pricePerKg = 6.11,
		unit = "Caja",
		unitKg = 18,
		shelfLifeHours = 120,
		volatility = 0.06,
		fragility = 0.7,
		season = FLAT,
	},
	chile_serrano = {
		id = "chile_serrano",
		name = "Chile serrano",
		origin = "San Luis Potosí",
		pricePerKg = 21,
		unit = "Arpilla",
		unitKg = 10,
		shelfLifeHours = 200,
		volatility = 0.1,
		fragility = 0.4,
		season = FLAT,
	},
	chile_poblano = {
		id = "chile_poblano",
		name = "Chile poblano",
		origin = "Baja California",
		pricePerKg = 22,
		unit = "Caja",
		unitKg = 10,
		shelfLifeHours = 200,
		volatility = 0.1,
		fragility = 0.5,
		season = { 1, 1, 1, 1, 1, 1, 1, 1.2, 1.4, 1, 1, 1 }, -- Fiestas Patrias
	},
	chile_guajillo = {
		id = "chile_guajillo",
		name = "Chile guajillo (seco)",
		origin = "Zacatecas",
		pricePerKg = 125,
		unit = "Costal (por kg)",
		unitKg = 1,
		shelfLifeHours = 4000,
		volatility = 0.03,
		fragility = 0.1,
		season = FLAT,
	},
}

return Products

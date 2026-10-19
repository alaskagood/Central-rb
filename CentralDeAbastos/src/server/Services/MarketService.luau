--!strict
-- Precio de referencia de la Subasta (por unidad comercial). Cambia cada día de juego
-- (ruido por producto) y con la hora. H7 lo amplía con demanda/oferta y eventos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pricing = require(ReplicatedStorage.Shared.Pricing)
local Products = require(ReplicatedStorage.Shared.Config.Products)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local MarketService = {}

local noise: { [string]: number } = {}
local noiseDay = -1

local function roll(day: number)
	noiseDay = day
	local rng = Random.new(day * 7919)
	local ids = {}
	for id in Products do
		table.insert(ids, id)
	end
	table.sort(ids) -- orden fijo para que el mismo día dé los mismos precios
	for _, id in ids do
		noise[id] = Pricing.gaussian(rng)
	end
end

function MarketService.price(productId: string): number
	local product = Products[productId]
	assert(product, "Producto desconocido: " .. productId)
	local day = ReplicatedStorage:GetAttribute("GameDay")
	day = if type(day) == "number" then day else 1
	if day ~= noiseDay then
		roll(day)
	end
	local hour = ReplicatedStorage:GetAttribute("GameHour")
	return Pricing.pricePerUnit(product, {
		month = (os.date("*t") :: any).month,
		hour = if type(hour) == "number" then hour else 4,
		demand = 1,
		supply = 1,
		noise = noise[productId],
	})
end

function MarketService.all(): { [string]: number }
	local prices = {}
	for id in Products do
		prices[id] = MarketService.price(id)
	end
	return prices
end

-- Cada hora de juego se manda la tabla de la Subasta a todos.
function MarketService.start(clock: { onHour: (fn: (hour: number, day: number) -> ()) -> () })
	clock.onHour(function()
		Remotes.get("MarketPrices"):FireAllClients(MarketService.all())
	end)
	Players.PlayerAdded:Connect(function(player: Player)
		Remotes.get("MarketPrices"):FireClient(player, MarketService.all())
	end)
end

return MarketService

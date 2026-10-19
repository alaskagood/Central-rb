--!strict
-- Ventanas de bodega:
--  · MI BODEGA (solo el jefe): precio de la Subasta, cajas en bodega, su precio de venta
--    y botones para comprar en la Subasta.
--  · Ver precios (cualquiera, desde el pizarrón): comprar cajas por unidad.
-- Solo pide cosas; el servidor (BodegaService) valida y cobra.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Freshness = require(Shared.Freshness)
local Products = require(Shared.Config.Products)
local Remotes = require(Shared.Remotes)
local Ui = require(script.Parent.Parent.Ui)

local player = Players.LocalPlayer

local marketPrices: { [string]: number } = {}
local myStock: { any } = {}

local gui = Instance.new("ScreenGui")
gui.Name = "Bodega"
gui.ResetOnSpawn = false

local function sortedProducts(): { string }
	local ids = {}
	for id in Products do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b)
		return Products[a].name < Products[b].name
	end)
	return ids
end

---------------------------------------------------------------- MI BODEGA (jefe)
local mine, mineList, mineTitle = Ui.window(gui, "MI BODEGA", 760)

local function unitsInStock(productId: string): number
	local n = 0
	for _, o in myStock do
		if o.product == productId then
			n += o.units
		end
	end
	return n
end

local function myPrice(productId: string): number?
	for _, o in myStock do
		if o.product == productId then
			return o.price
		end
	end
	return nil
end

local function renderMine()
	Ui.clear(mineList)
	local header = Ui.row(mineList, 0)
	header.BackgroundTransparency = 1
	Ui.text(header, "Producto", 230, Ui.GRAY, 14)
	Ui.text(header, "Subasta", 80, Ui.GRAY, 14)
	Ui.text(header, "En bodega", 80, Ui.GRAY, 14)
	Ui.text(header, "Tu precio", 100, Ui.GRAY, 14)
	Ui.text(header, "Comprar en Subasta", 160, Ui.GRAY, 14)
	for i, id in sortedProducts() do
		local p = Products[id]
		local r = Ui.row(mineList, i)
		Ui.text(r, `{p.name} ({p.unit})`, 230)
		Ui.text(r, if marketPrices[id] then `${marketPrices[id]}` else "—", 80, Ui.MONEY)
		Ui.text(r, tostring(unitsInStock(id)), 80)
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 100, 1, -8)
		box.BackgroundColor3 = Color3.fromRGB(55, 60, 72)
		box.Font = Enum.Font.GothamBold
		box.TextSize = 16
		box.TextColor3 = Color3.new(1, 1, 1)
		box.PlaceholderText = "$ precio"
		box.Text = if myPrice(id) then tostring(myPrice(id)) else ""
		box.ClearTextOnFocus = false
		box.LayoutOrder = #r:GetChildren()
		box.Parent = r
		Ui.corner(box, 6)
		box.FocusLost:Connect(function()
			local value = tonumber((box.Text:gsub("[^%d]", "")))
			if value and value >= 1 then
				Remotes.get("SetPrice"):FireServer(id, math.floor(value))
			end
		end)
		Ui.button(r, "+1", 44, Ui.GREEN, function()
			Remotes.get("MarketBuy"):FireServer(id, 1)
		end)
		Ui.button(r, "+10", 52, Ui.GREEN, function()
			Remotes.get("MarketBuy"):FireServer(id, 10)
		end)
	end
end

local openMine = Ui.topButton(gui, "MI BODEGA", Color3.fromRGB(200, 50, 50), function()
	mine.Visible = not mine.Visible
	if mine.Visible then
		renderMine()
	end
end)

local function refreshBodegaButton()
	local n = player:GetAttribute("Bodega")
	openMine.Visible = type(n) == "number"
	if type(n) == "number" then
		mineTitle.Text = `MI BODEGA {n}`
	end
end
player:GetAttributeChangedSignal("Bodega"):Connect(refreshBodegaButton)
refreshBodegaButton()

Remotes.get("MarketPrices").OnClientEvent:Connect(function(prices: { [string]: number })
	marketPrices = prices
	if mine.Visible then
		renderMine()
	end
end)

Remotes.get("BodegaStock").OnClientEvent:Connect(function(_n: number, stock: { any })
	myStock = stock
	if mine.Visible then
		renderMine()
	end
end)

---------------------------------------------------------------- Comprar en una bodega
local shop, shopList, shopTitle = Ui.window(gui, "BODEGA", 640)

Remotes.get("BodegaOpen").OnClientEvent:Connect(function(n: number, offers: { any }, ownerName: string, isOwner: boolean)
	shopTitle.Text = if ownerName ~= "" then `BODEGA {n} · {ownerName}` else `BODEGA {n} · SE RENTA`
	Ui.clear(shopList)
	if isOwner then
		Ui.text(Ui.row(shopList, 0), "Es tu bodega: usa el botón MI BODEGA.", 560, Ui.YELLOW)
	elseif #offers == 0 then
		Ui.text(Ui.row(shopList, 0), "Sin mercancía por ahora.", 560, Ui.GRAY)
	end
	for i, o in offers do
		local p = Products[o.product]
		local grade = Freshness.grade(o.freshness)
		local r = Ui.row(shopList, i)
		Ui.text(r, `{o.units} × {p.name}`, 230)
		Ui.text(r, `{grade} {math.floor(o.freshness)}%`, 110, Ui.GRADE_COLOR[grade])
		Ui.text(r, `${o.price} c/u`, 100, Ui.MONEY)
		if not isOwner then
			Ui.button(r, "1", 44, Ui.GREEN, function()
				Remotes.get("BodegaBuy"):FireServer(n, o.id, 1)
			end)
			if o.units >= 5 then
				Ui.button(r, "5", 44, Ui.GREEN, function()
					Remotes.get("BodegaBuy"):FireServer(n, o.id, 5)
				end)
			end
		end
	end
	shop.Visible = true
end)

gui.Parent = player:WaitForChild("PlayerGui")

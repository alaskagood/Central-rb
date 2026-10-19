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

local player = Players.LocalPlayer

local BG = Color3.fromRGB(24, 26, 32)
local ROW = Color3.fromRGB(36, 39, 48)
local GREEN = Color3.fromRGB(60, 170, 80)
local GRADE_COLOR = {
	primera = Color3.fromRGB(80, 200, 90),
	segunda = Color3.fromRGB(240, 190, 40),
	rezaga = Color3.fromRGB(235, 110, 40),
	basura = Color3.fromRGB(150, 70, 60),
}

local marketPrices: { [string]: number } = {}
local myStock: { any } = {}

local gui = Instance.new("ScreenGui")
gui.Name = "Bodega"
gui.ResetOnSpawn = false

local function corner(parent: Instance, r: number)
	Instance.new("UICorner", parent).CornerRadius = UDim.new(0, r)
end

local function text(parent: Instance, s: string, w: number, color: Color3?, size: number?): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(0, w, 1, 0)
	l.Font = Enum.Font.GothamBold
	l.TextSize = size or 16
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Text = s
	l.LayoutOrder = #parent:GetChildren() -- en un renglón, en el orden en que se crean
	l.Parent = parent
	return l
end

local function button(parent: Instance, s: string, w: number, color: Color3, onClick: () -> ()): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, w, 1, -6)
	b.BackgroundColor3 = color
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 16
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = s
	b.LayoutOrder = #parent:GetChildren()
	b.Parent = parent
	corner(b, 6)
	b.Activated:Connect(onClick)
	return b
end

-- Ventana con título, X para cerrar y lista con scroll.
local function window(title: string, width: number): (Frame, ScrollingFrame, TextLabel)
	local w = Instance.new("Frame")
	w.AnchorPoint = Vector2.new(0.5, 0.5)
	w.Position = UDim2.fromScale(0.5, 0.5)
	w.Size = UDim2.fromOffset(width, 440)
	w.BackgroundColor3 = BG
	w.Visible = false
	w.Parent = gui
	corner(w, 12)
	local t = text(w, title, width - 60, Color3.fromRGB(250, 205, 40), 24)
	t.Size = UDim2.new(0, width - 60, 0, 44)
	t.Position = UDim2.fromOffset(16, 4)
	local close = button(w, "X", 36, Color3.fromRGB(190, 50, 50), function()
		w.Visible = false
	end)
	close.Size = UDim2.fromOffset(36, 36)
	close.Position = UDim2.new(1, -44, 0, 8)
	local list = Instance.new("ScrollingFrame")
	list.Position = UDim2.fromOffset(12, 56)
	list.Size = UDim2.new(1, -24, 1, -68)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = w
	local layout = Instance.new("UIListLayout", list)
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	return w, list, t
end

local function row(list: ScrollingFrame, order: number): Frame
	local r = Instance.new("Frame")
	r.Size = UDim2.new(1, -8, 0, 40)
	r.BackgroundColor3 = ROW
	r.LayoutOrder = order
	r.Parent = list
	corner(r, 8)
	local pad = Instance.new("UIPadding", r)
	pad.PaddingLeft, pad.PaddingTop = UDim.new(0, 10), UDim.new(0, 3)
	local layout = Instance.new("UIListLayout", r)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	return r
end

local function clear(list: ScrollingFrame)
	for _, c in list:GetChildren() do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
end

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
local mine, mineList, mineTitle = window("MI BODEGA", 760)

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
	clear(mineList)
	local header = row(mineList, 0)
	header.BackgroundTransparency = 1
	text(header, "Producto", 230, Color3.fromRGB(170, 170, 170), 14)
	text(header, "Subasta", 80, Color3.fromRGB(170, 170, 170), 14)
	text(header, "En bodega", 80, Color3.fromRGB(170, 170, 170), 14)
	text(header, "Tu precio", 100, Color3.fromRGB(170, 170, 170), 14)
	text(header, "Comprar en Subasta", 160, Color3.fromRGB(170, 170, 170), 14)
	for i, id in sortedProducts() do
		local p = Products[id]
		local r = row(mineList, i)
		text(r, `{p.name} ({p.unit})`, 230)
		text(r, if marketPrices[id] then `${marketPrices[id]}` else "—", 80, Color3.fromRGB(120, 230, 120))
		text(r, tostring(unitsInStock(id)), 80)
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
		corner(box, 6)
		box.FocusLost:Connect(function()
			local value = tonumber((box.Text:gsub("[^%d]", "")))
			if value and value >= 1 then
				Remotes.get("SetPrice"):FireServer(id, math.floor(value))
			end
		end)
		button(r, "+1", 44, GREEN, function()
			Remotes.get("MarketBuy"):FireServer(id, 1)
		end)
		button(r, "+10", 52, GREEN, function()
			Remotes.get("MarketBuy"):FireServer(id, 10)
		end)
	end
end

local openMine = Instance.new("TextButton")
openMine.AnchorPoint = Vector2.new(1, 0)
openMine.Position = UDim2.new(1, -16, 0, 16)
openMine.Size = UDim2.fromOffset(170, 48)
openMine.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
openMine.Font = Enum.Font.GothamBlack
openMine.TextSize = 20
openMine.TextColor3 = Color3.new(1, 1, 1)
openMine.Text = "MI BODEGA"
openMine.Visible = false
openMine.Parent = gui
corner(openMine, 10)
openMine.Activated:Connect(function()
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
local shop, shopList, shopTitle = window("BODEGA", 640)

Remotes.get("BodegaOpen").OnClientEvent:Connect(function(n: number, offers: { any }, ownerName: string, isOwner: boolean)
	shopTitle.Text = if ownerName ~= "" then `BODEGA {n} · {ownerName}` else `BODEGA {n} · SE RENTA`
	clear(shopList)
	if isOwner then
		local r = row(shopList, 0)
		text(r, "Es tu bodega: usa el botón MI BODEGA.", 560, Color3.fromRGB(250, 205, 40))
	elseif #offers == 0 then
		local r = row(shopList, 0)
		text(r, "Sin mercancía por ahora.", 560, Color3.fromRGB(170, 170, 170))
	end
	for i, o in offers do
		local p = Products[o.product]
		local grade = Freshness.grade(o.freshness)
		local r = row(shopList, i)
		text(r, `{o.units} × {p.name}`, 230)
		text(r, `{grade} {math.floor(o.freshness)}%`, 110, GRADE_COLOR[grade])
		text(r, `${o.price} c/u`, 100, Color3.fromRGB(120, 230, 120))
		if not isOwner then
			button(r, "1", 44, GREEN, function()
				Remotes.get("BodegaBuy"):FireServer(n, o.id, 1)
			end)
			if o.units >= 5 then
				button(r, "5", 44, GREEN, function()
					Remotes.get("BodegaBuy"):FireServer(n, o.id, 5)
				end)
			end
		end
	end
	shop.Visible = true
end)

gui.Parent = player:WaitForChild("PlayerGui")

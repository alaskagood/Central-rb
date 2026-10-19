--!strict
-- Revendedor: ventana MAYOREO (surtirse del mayoreo NPC) y tarjeta de regateo cuando
-- llega un comprador a su puesto. Solo pide; StallService valida y cobra.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Freshness = require(Shared.Freshness)
local Products = require(Shared.Config.Products)
local Remotes = require(Shared.Remotes)
local Ui = require(script.Parent.Parent.Ui)

local player = Players.LocalPlayer
local MAYOREO_MARKUP = 1.2 -- solo para mostrar; el servidor cobra lo suyo

local marketPrices: { [string]: number } = {}

local gui = Instance.new("ScreenGui")
gui.Name = "Puesto"
gui.ResetOnSpawn = false

local function round5(n: number): number
	return math.max(5, math.floor(n / 5 + 0.5) * 5)
end

---------------------------------------------------------------- MAYOREO
local shop, list = Ui.window(gui, "MAYOREO · surte tu puesto", 560)

local function render()
	Ui.clear(list)
	local ids = {}
	for id in Products do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b)
		return Products[a].name < Products[b].name
	end)
	for i, id in ids do
		local p = Products[id]
		local r = Ui.row(list, i)
		Ui.text(r, `{p.name} ({p.unit})`, 250)
		local base = marketPrices[id]
		Ui.text(r, if base then `${round5(base * MAYOREO_MARKUP)}` else "—", 80, Ui.MONEY)
		Ui.button(r, "+1", 44, Ui.GREEN, function()
			Remotes.get("WholesaleBuy"):FireServer(id, 1)
		end)
		Ui.button(r, "+5", 44, Ui.GREEN, function()
			Remotes.get("WholesaleBuy"):FireServer(id, 5)
		end)
	end
end

local open = Ui.topButton(gui, "MAYOREO", Color3.fromRGB(60, 170, 80), function()
	shop.Visible = not shop.Visible
	if shop.Visible then
		render()
	end
end)

local function refresh()
	open.Visible = type(player:GetAttribute("Puesto")) == "number"
end
player:GetAttributeChangedSignal("Puesto"):Connect(refresh)
refresh()

Remotes.get("MarketPrices").OnClientEvent:Connect(function(prices: { [string]: number })
	marketPrices = prices
	if shop.Visible then
		render()
	end
end)

---------------------------------------------------------------- Regateo
local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 1)
card.Position = UDim2.new(0.5, 0, 1, -90)
card.Size = UDim2.fromOffset(620, 128)
card.BackgroundColor3 = Ui.BG
card.Visible = false
card.Parent = gui
Ui.corner(card, 12)

local title = Ui.text(card, "", 590, Ui.YELLOW, 20)
title.Size = UDim2.fromOffset(590, 30)
title.Position = UDim2.fromOffset(16, 8)
local detail = Ui.text(card, "", 590, Color3.new(1, 1, 1), 16)
detail.Size = UDim2.fromOffset(590, 24)
detail.Position = UDim2.fromOffset(16, 38)

local buttons = Instance.new("Frame")
buttons.BackgroundTransparency = 1
buttons.Position = UDim2.fromOffset(16, 70)
buttons.Size = UDim2.fromOffset(590, 46)
buttons.Parent = card
local layout = Instance.new("UIListLayout", buttons)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

local function reply(action: string)
	Remotes.get("HaggleReply"):FireServer(action)
end
local accept = Ui.button(buttons, "", 140, Ui.GREEN, function()
	reply("accept")
end)
local up10 = Ui.button(buttons, "", 140, Color3.fromRGB(230, 140, 30), function()
	reply("up10")
end)
local up25 = Ui.button(buttons, "", 140, Color3.fromRGB(210, 90, 30), function()
	reply("up25")
end)
Ui.button(buttons, "No hay trato", 140, Ui.RED, function()
	reply("no")
end)

Remotes.get("Haggle").OnClientEvent:Connect(function(v: any)
	if v == nil then
		card.Visible = false
		return
	end
	local p = Products[v.product]
	local grade = Freshness.grade(v.freshness)
	title.Text = `{v.name} quiere {v.units} × {p.name}`
	detail.Text = `{grade} {math.floor(v.freshness)}% · Te ofrece ${v.offer} c/u · Paciencia: {string.rep("♥", v.patience)}`
	accept.Text = `Va, ${v.offer}`
	up10.Text = `Pide ${round5(v.offer * 1.1)}`
	up25.Text = `Pide ${round5(v.offer * 1.25)}`
	card.Visible = true
end)

gui.Parent = player:WaitForChild("PlayerGui")

--!strict
-- Panel "Tu carga": dinero y lotes que trae el jugador, con su frescura.
-- Solo muestra; todo lo decide el servidor (InventoryService).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Freshness = require(Shared.Freshness)
local Products = require(Shared.Config.Products)
local Remotes = require(Shared.Remotes)

local player = Players.LocalPlayer

local GRADE_COLOR = {
	primera = Color3.fromRGB(80, 200, 90),
	segunda = Color3.fromRGB(240, 190, 40),
	rezaga = Color3.fromRGB(235, 110, 40),
	basura = Color3.fromRGB(150, 70, 60),
}

local gui = Instance.new("ScreenGui")
gui.Name = "Inventario"
gui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0, 1)
panel.Position = UDim2.new(0, 16, 1, -16)
panel.Size = UDim2.fromOffset(300, 0)
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
panel.BackgroundTransparency = 0.2
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local pad = Instance.new("UIPadding", panel)
pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8)
pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
local layout = Instance.new("UIListLayout", panel)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)

local function label(text: string, size: number, color: Color3, order: number): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, size)
	l.Font = Enum.Font.GothamBold
	l.TextSize = size - 4
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = color
	l.Text = text
	l.LayoutOrder = order
	l.Parent = panel
	return l
end

local cashLabel = label("$0", 28, Color3.fromRGB(120, 230, 120), 0)
label("TU CARGA", 18, Color3.fromRGB(200, 200, 200), 1)
local rows: { Instance } = {}

local function money(n: number): string
	local s = tostring(math.floor(n))
	return "$" .. s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function refreshCash()
	local cash = player:GetAttribute("Cash")
	cashLabel.Text = if type(cash) == "number" then money(cash) else "$0"
end

local function render(lots: { any })
	for _, r in rows do
		r:Destroy()
	end
	table.clear(rows)
	if #lots == 0 then
		table.insert(rows, label("Vacío", 18, Color3.fromRGB(140, 140, 140), 2))
		return
	end
	for i, lot in lots do
		local product = Products[lot.product]
		local grade = Freshness.grade(lot.freshness)
		local name = if product then product.name else lot.product
		local unit = if product then product.unit else ""
		local row = label(
			`{lot.units} × {name} ({unit}) · {grade} {math.floor(lot.freshness)}%`,
			20,
			GRADE_COLOR[grade],
			1 + i
		)
		row.TextWrapped = true
		row.AutomaticSize = Enum.AutomaticSize.Y
		table.insert(rows, row)
	end
end

-- Avisos del servidor (Notify): aparecen arriba al centro y se van solos.
local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 70)
toast.Size = UDim2.fromOffset(0, 40)
toast.AutomaticSize = Enum.AutomaticSize.X
toast.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
toast.BackgroundTransparency = 0.15
toast.Font = Enum.Font.GothamBold
toast.TextSize = 20
toast.TextColor3 = Color3.new(1, 1, 1)
toast.Visible = false
toast.Parent = gui
Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
local tpad = Instance.new("UIPadding", toast)
tpad.PaddingLeft, tpad.PaddingRight = UDim.new(0, 14), UDim.new(0, 14)
local toastId = 0
Remotes.get("Notify").OnClientEvent:Connect(function(text: string)
	toastId += 1
	local mine = toastId
	toast.Text = text
	toast.Visible = true
	task.delay(4, function()
		if toastId == mine then
			toast.Visible = false
		end
	end)
end)

player:GetAttributeChangedSignal("Cash"):Connect(refreshCash)
Remotes.get("Inventory").OnClientEvent:Connect(render)
refreshCash()
render({})
gui.Parent = player:WaitForChild("PlayerGui")

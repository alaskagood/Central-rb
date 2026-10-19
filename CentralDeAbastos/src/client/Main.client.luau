--!strict
-- Pantalla de elegir oficio. Solo manda la petición; el servidor decide.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roles = require(ReplicatedStorage:WaitForChild("Shared").Config.Roles)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer

local ORDER = { "Diablero", "Camionero", "Jefe", "Revendedor" }

local gui = Instance.new("ScreenGui")
gui.Name = "RolePicker"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
bg.BackgroundTransparency = 0.15
bg.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 80)
title.Position = UDim2.fromOffset(0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "CENTRAL DE ABASTOS — ¿De qué vas a chambear?"
title.Parent = bg

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 1, -60)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.TextColor3 = Color3.fromRGB(255, 200, 80)
status.Text = ""
status.Parent = bg

local grid = Instance.new("Frame")
grid.Size = UDim2.fromScale(0.9, 0.6)
grid.Position = UDim2.fromScale(0.05, 0.22)
grid.BackgroundTransparency = 1
grid.Parent = bg

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromScale(0.23, 0.9)
layout.CellPadding = UDim2.fromScale(0.02, 0)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

for i, id in ORDER do
	local role = Roles[id :: Roles.RoleId]
	local button = Instance.new("TextButton")
	button.LayoutOrder = i
	button.BackgroundColor3 = role.color
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextWrapped = true
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = `{role.name}\n\n{role.description}`
	button.Parent = grid

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = button

	button.Activated:Connect(function()
		status.Text = "Pidiendo chamba..."
		Remotes.get("PickRole"):FireServer(role.id)
	end)
end

Remotes.get("RoleAssigned").OnClientEvent:Connect(function(roleId: string)
	gui.Enabled = false
	print("[CEDA] Oficio:", roleId)
end)

Remotes.get("RoleRejected").OnClientEvent:Connect(function(reason: string)
	status.Text = reason
end)

gui.Parent = player:WaitForChild("PlayerGui")

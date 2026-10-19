--!strict
-- El cliente solo solicita acciones; cajas, cobros y velocidad los decide el servidor.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "DiableroPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -12, 0, 60)
panel.Size = UDim2.new(0.85, 0, 0, 155)
panel.BackgroundColor3 = Color3.fromRGB(35, 42, 35)
panel.Parent = gui
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(340, 155)
constraint.Parent = panel
local text = Instance.new("TextLabel")
text.Position = UDim2.fromOffset(10, 8)
text.Size = UDim2.new(1, -20, 0, 98)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(255, 232, 180)
text.TextSize = 16
text.TextWrapped = true
text.Parent = panel
for index, action in { "Correr", "Soltar" } do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.5, -15, 0, 34)
	button.Position = UDim2.new((index - 1) * 0.5, 10, 1, -42)
	button.Text = if action == "Correr" then "Correr / Caminar" else "Soltar una caja"
	button.TextSize = 14
	button.Parent = panel
	button.Activated:Connect(function()
		local remote = ReplicatedStorage:FindFirstChild("DiableroAction")
		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer(action)
		end
	end)
end
local function update()
	gui.Enabled = player:GetAttribute("Role") == "Diablero"
	text.Text = `DIABLERO · {player:GetAttribute("DiableroBoxes") or 0}/5 cajas\n{player:GetAttribute(
		"DiableroMessage"
	) or "Equipa el diablito y busca Encargos en las esquinas del pasillo."}`
end
for _, attribute in { "Role", "DiableroBoxes", "DiableroMessage" } do
	player:GetAttributeChangedSignal(attribute):Connect(update)
end
update()

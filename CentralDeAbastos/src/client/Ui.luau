--!strict
-- Piezas de interfaz compartidas por las ventanas del juego (bodega, puesto...).

local Ui = {}

Ui.BG = Color3.fromRGB(24, 26, 32)
Ui.ROW = Color3.fromRGB(36, 39, 48)
Ui.GREEN = Color3.fromRGB(60, 170, 80)
Ui.RED = Color3.fromRGB(190, 50, 50)
Ui.YELLOW = Color3.fromRGB(250, 205, 40)
Ui.MONEY = Color3.fromRGB(120, 230, 120)
Ui.GRAY = Color3.fromRGB(170, 170, 170)
Ui.GRADE_COLOR = {
	primera = Color3.fromRGB(80, 200, 90),
	segunda = Color3.fromRGB(240, 190, 40),
	rezaga = Color3.fromRGB(235, 110, 40),
	basura = Color3.fromRGB(150, 70, 60),
}

function Ui.corner(parent: Instance, r: number)
	Instance.new("UICorner", parent).CornerRadius = UDim.new(0, r)
end

-- En un renglón con UIListLayout, LayoutOrder = orden de creación.
function Ui.text(parent: Instance, s: string, w: number, color: Color3?, size: number?): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(0, w, 1, 0)
	l.Font = Enum.Font.GothamBold
	l.TextSize = size or 16
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Text = s
	l.LayoutOrder = #parent:GetChildren()
	l.Parent = parent
	return l
end

function Ui.button(parent: Instance, s: string, w: number, color: Color3, onClick: () -> ()): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, w, 1, -6)
	b.BackgroundColor3 = color
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 16
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = s
	b.LayoutOrder = #parent:GetChildren()
	b.Parent = parent
	Ui.corner(b, 6)
	b.Activated:Connect(onClick)
	return b
end

-- Ventana centrada con título, X para cerrar y lista con scroll.
function Ui.window(gui: ScreenGui, title: string, width: number): (Frame, ScrollingFrame, TextLabel)
	local w = Instance.new("Frame")
	w.AnchorPoint = Vector2.new(0.5, 0.5)
	w.Position = UDim2.fromScale(0.5, 0.5)
	w.Size = UDim2.fromOffset(width, 440)
	w.BackgroundColor3 = Ui.BG
	w.Visible = false
	w.Parent = gui
	Ui.corner(w, 12)
	local t = Ui.text(w, title, width - 60, Ui.YELLOW, 24)
	t.Size = UDim2.new(0, width - 60, 0, 44)
	t.Position = UDim2.fromOffset(16, 4)
	local close = Ui.button(w, "X", 36, Ui.RED, function()
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

function Ui.row(list: Instance, order: number): Frame
	local r = Instance.new("Frame")
	r.Size = UDim2.new(1, -8, 0, 40)
	r.BackgroundColor3 = Ui.ROW
	r.LayoutOrder = order
	r.Parent = list
	Ui.corner(r, 8)
	local pad = Instance.new("UIPadding", r)
	pad.PaddingLeft, pad.PaddingTop = UDim.new(0, 10), UDim.new(0, 3)
	local layout = Instance.new("UIListLayout", r)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	return r
end

function Ui.clear(list: Instance)
	for _, c in list:GetChildren() do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
end

-- Botón grande arriba a la derecha (MI BODEGA, MAYOREO...).
function Ui.topButton(gui: ScreenGui, s: string, color: Color3, onClick: () -> ()): TextButton
	local b = Instance.new("TextButton")
	b.AnchorPoint = Vector2.new(1, 0)
	b.Position = UDim2.new(1, -16, 0, 16)
	b.Size = UDim2.fromOffset(170, 48)
	b.BackgroundColor3 = color
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 20
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = s
	b.Visible = false
	b.Parent = gui
	Ui.corner(b, 10)
	b.Activated:Connect(onClick)
	return b
end

return Ui

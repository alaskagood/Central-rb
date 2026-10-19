--!strict
-- H2. start() después de NaveBuilder.build; no crea mercancía ni modifica sus dueños.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(script.Parent.Parent.Assets)
local Inventory = require(script.Parent.InventoryService)

local Service = {}
local SOURCE = "b:101"
local CAPACITY = 5
type State = {
	tool: Tool?,
	visual: Model?,
	destination: BasePart?,
	remaining: number,
	loaded: number,
	rate: number,
	ground: { [string]: Model },
	lastAction: number,
	lastFall: number,
	previous: Vector3?,
	speed: number,
	running: boolean,
	walkSpeed: number?,
}
local states: { [Player]: State } = {}
local started = false
local world: Folder
local pickup: BasePart
local remote: RemoteEvent
local serial = 0

local function holder(player: Player): string
	return `d:{player.UserId}`
end

local function root(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local part = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and part and part:IsA("BasePart") then
		return part
	end
	return nil
end

local function eligible(player: Player): boolean
	return player:GetAttribute("Role") == "Diablero" and player:GetAttribute("DataLoaded") == true
end

local function near(player: Player, position: Vector3): boolean
	local part = root(player)
	return part ~= nil and (part.Position - position).Magnitude <= 12
end

local function say(player: Player, message: string)
	player:SetAttribute("DiableroMessage", message)
end

local function count(player: Player): number
	local total = 0
	for _, lot in Inventory.list(holder(player)) do
		total += lot.units
	end
	return total
end

-- Alinea por bounding box: los pivotes de la Tienda no siempre están centrados.
local function place(model: Model, base: CFrame)
	local box, size = model:GetBoundingBox()
	local offset = model:GetPivot():ToObjectSpace(box)
	model:PivotTo(base * CFrame.new(0, size.Y / 2, 0) * offset:Inverse())
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") then
			item.Anchored = true
			item.CanCollide = false
			item.CanTouch = false
			item.CanQuery = false
		end
	end
end

local function render(player: Player, state: State)
	if state.visual then
		state.visual:Destroy()
		state.visual = nil
	end
	local total = count(player)
	player:SetAttribute("DiableroBoxes", total)
	player:SetAttribute("DiableroRemaining", state.remaining)
	player:SetAttribute("DiableroRate", state.rate)
	if not state.tool or state.tool.Parent ~= player.Character then
		return
	end
	local cart = Assets.get("Diablito")
	cart.Name = `Diablo_{player.UserId}`
	place(cart, CFrame.identity)
	for i = 1, total do
		local box = Assets.get("CajaMadera")
		place(box, CFrame.new(0, 0.4 + math.floor((i - 1) / 2) * 1.25, -0.5 + ((i - 1) % 2) * 1.5))
		box.Parent = cart
	end
	-- Fija el origen de montaje después de colocar los assets: PivotTo conserva
	-- así la base del diablo aunque el asset tenga PrimaryPart o pivote desplazado.
	cart.PrimaryPart = nil
	cart.WorldPivot = CFrame.identity
	local part = root(player)
	if part then
		cart:PivotTo(part.CFrame * CFrame.new(0, -3, -3))
	end
	cart.Parent = world
	state.visual = cart
end

local function prompt(part: BasePart, label: string, action: (Player) -> ())
	local p = Instance.new("ProximityPrompt")
	p.ActionText = label
	p.ObjectText = part.Name
	p.MaxActivationDistance = 10
	p.HoldDuration = 0.3
	p.RequiresLineOfSight = false
	p.Parent = part
	p.Triggered:Connect(function(player)
		local state = states[player]
		if not state or not eligible(player) or not near(player, part.Position) then
			return
		end
		if os.clock() - state.lastAction < 0.35 then
			return
		end
		state.lastAction = os.clock()
		action(player)
	end)
end

local function spill(player: Player, state: State, impact: number)
	local part = root(player)
	local lot = Inventory.list(holder(player))[1]
	if not part or not lot then
		return
	end
	serial += 1
	local groundHolder = `g:diablero:{player.UserId}:{serial}`
	local moved = Inventory.move(holder(player), groundHolder, lot.id, 1)
	if not moved then
		return
	end
	Inventory.hit(groundHolder, moved.id, impact)
	Inventory.setStorage(groundHolder, "sol")
	local model = Assets.get("CajaMadera")
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character :: Model, world }
	local location = part.Position + part.CFrame.RightVector * 3
	local floor = workspace:Raycast(location, Vector3.new(0, -20, 0), params)
	place(model, CFrame.new(if floor then floor.Position else location - Vector3.new(0, 3, 0)))
	model.Name = "Caja caída"
	model.Parent = world
	state.ground[groundHolder] = model
	local anchor = model:FindFirstChildWhichIsA("BasePart", true)
	if anchor then
		prompt(anchor, "Recoger caja", function(who)
			if who ~= player or states[player] ~= state or count(player) >= CAPACITY then
				return
			end
			if not state.tool or state.tool.Parent ~= player.Character then
				return
			end
			local fallen = Inventory.list(groundHolder)[1]
			if fallen and Inventory.move(groundHolder, holder(player), fallen.id, 1) then
				Inventory.drop(groundHolder)
				state.ground[groundHolder] = nil
				model:Destroy()
				render(player, state)
				say(player, "¡Ya quedó! Aguas con la carga.")
			end
		end)
	end
	render(player, state)
	say(player, "¡Se cayó una caja! Recógela con E; ya perdió frescura.")
end

local function restore(player: Player, state: State)
	local function returnLots(from: string)
		for _, lot in table.clone(Inventory.list(from)) do
			Inventory.move(from, SOURCE, lot.id, lot.units)
		end
		Inventory.drop(from)
	end
	returnLots(holder(player))
	for key, model in state.ground do
		returnLots(key)
		model:Destroy()
	end
	state.ground = {}
	state.destination = nil
	state.remaining = 0
	state.loaded = 0
	state.previous = nil
	state.running = false
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and state.walkSpeed then
		humanoid.WalkSpeed = state.walkSpeed
	end
	state.walkSpeed = nil
	if state.tool then
		state.tool:Destroy()
		state.tool = nil
	end
	render(player, state)
end

local function giveTool(player: Player, state: State)
	if not eligible(player) or not root(player) or state.tool then
		return
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "Diablito"
	tool.ToolTip = "Equipa para cargar. Corre con el botón del panel."
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	state.tool = tool
	tool.Equipped:Connect(function()
		render(player, state)
	end)
	tool.Unequipped:Connect(function()
		state.running = false
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and state.walkSpeed then
			humanoid.WalkSpeed = state.walkSpeed
		end
		state.walkSpeed = nil
		render(player, state)
	end)
	tool.Parent = backpack
end

local function marker(name: string, position: Vector3, color: Color3): BasePart
	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.new(3, 0.2, 3)
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	part.Position = position
	part.Parent = world
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(200, 45)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 100
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.2
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = name
	label.TextSize = 16
	label.Parent = gui
	return part
end

function Service.start()
	if started then
		return
	end
	local nave = workspace:WaitForChild("CEDA"):WaitForChild("Nave_IJ")
	local aisle = nave:WaitForChild("Pasillo") :: BasePart
	local bodega: Model? = nil
	for _, item in nave:GetChildren() do
		if item:IsA("Model") and item:GetAttribute("Number") == 101 then
			bodega = item
		end
	end
	assert(bodega, "H2 necesita la bodega 101")
	started = true
	world = Instance.new("Folder")
	world.Name = "DiableroH2"
	world.Parent = workspace
	remote = Instance.new("RemoteEvent")
	remote.Name = "DiableroAction"
	remote.Parent = ReplicatedStorage
	local localBodega = aisle.CFrame:PointToObjectSpace(bodega:GetPivot().Position)
	pickup = marker(
		"Carga · Bodega 101",
		aisle.CFrame:PointToWorldSpace(Vector3.new(-aisle.Size.X / 2 + 2, 0.2, localBodega.Z)),
		Color3.fromRGB(240, 180, 40)
	)
	for index, side in { -1, 1 } do
		local corner = marker(
			`Encargos · Esquina {index}`,
			aisle.CFrame:PointToWorldSpace(Vector3.new(0, 0.2, side * (aisle.Size.Z / 2 + 5))),
			Color3.fromRGB(50, 180, 100)
		)
		prompt(corner, "Encargo / Entregar", function(player)
			local state = states[player]
			if not state.destination then
				state.destination = corner
				state.remaining = CAPACITY
				state.loaded = 0
				state.rate = math.clamp(math.floor((pickup.Position - corner.Position).Magnitude / 5), 5, 15)
				say(
					player,
					`¡Hay chamba! Lleva 5 cajas de la 101 a Esquina {index}. ${state.rate} por caja.`
				)
			elseif state.destination == corner then
				if not state.tool or state.tool.Parent ~= player.Character then
					say(player, "Equipa tu diablito para entregar.")
					return
				end
				local cash = player:GetAttribute("Cash")
				if typeof(cash) ~= "number" or cash ~= cash or math.abs(cash) == math.huge or cash < 0 then
					return
				end
				local delivered = 0
				for _, lot in table.clone(Inventory.list(holder(player))) do
					local units = math.min(lot.units, state.remaining)
					if
						units > 0 and Inventory.move(holder(player), `npc:diablero:{index}`, lot.id, units)
					then
						delivered += units
						state.remaining -= units
					end
				end
				player:SetAttribute("Cash", cash + delivered * state.rate)
				say(
					player,
					if delivered > 0
						then `¡Cámara! Entregaste {delivered} y cobraste ${delivered * state.rate}. Faltan {state.remaining}.`
						else "Trae las cajas de la 101, carnal."
				)
				if state.remaining == 0 then
					state.destination = nil
					state.loaded = 0
				end
			else
				say(player, "Tu cliente está en la otra esquina.")
			end
			render(player, state)
		end)
	end
	prompt(pickup, "Cargar una caja", function(player)
		local state = states[player]
		if not state.destination then
			say(player, "Primero busca chamba en una esquina.")
			return
		end
		if not state.tool or state.tool.Parent ~= player.Character then
			say(player, "Equipa tu diablito primero.")
			return
		end
		if count(player) >= CAPACITY or state.loaded >= CAPACITY then
			say(player, "Ya cargaste el encargo; recoge las que se cayeron.")
			return
		end
		-- Solo mercancía NPC: no tomar existencias de un jefe sin una oferta autorizada.
		for _, lot in Inventory.list(SOURCE) do
			if lot.owner == 0 and lot.units >= 1 and lot.freshness >= 10 then
				if Inventory.move(SOURCE, holder(player), lot.id, 1) then
					state.loaded += 1
					render(player, state)
					say(player, "¡Una más! Con calma en las bajadas.")
				end
				return
			end
		end
		say(player, "La 101 no tiene cajas disponibles para este encargo.")
	end)
	remote.OnServerEvent:Connect(function(player: Player, action: unknown)
		local state = states[player]
		if not state or not eligible(player) or not root(player) then
			return
		end
		if os.clock() - state.lastAction < 0.35 then
			return
		end
		state.lastAction = os.clock()
		if not state.tool or state.tool.Parent ~= player.Character then
			return
		end
		if action == "Soltar" then
			spill(player, state, 0.15)
		elseif action == "Correr" then
			local humanoid = (player.Character :: Model):FindFirstChildOfClass("Humanoid")
			if humanoid then
				state.running = not state.running
				if state.running then
					state.walkSpeed = humanoid.WalkSpeed
					humanoid.WalkSpeed = 24
				else
					humanoid.WalkSpeed = state.walkSpeed or 16
					state.walkSpeed = nil
				end
				say(
					player,
					if state.running then "¡Vas recio! Aguas con las bajadas." else "Paso tranquilo, carnal."
				)
			end
		end
	end)
	local function added(player: Player)
		local state: State = {
			tool = nil,
			visual = nil,
			destination = nil,
			remaining = 0,
			loaded = 0,
			rate = 0,
			ground = {},
			lastAction = 0,
			lastFall = 0,
			previous = nil,
			speed = 0,
			running = false,
			walkSpeed = nil,
		}
		states[player] = state
		player.CharacterRemoving:Connect(function()
			restore(player, state)
		end)
		player:GetAttributeChangedSignal("Role"):Connect(function()
			if not eligible(player) then
				restore(player, state)
			end
		end)
	end
	Players.PlayerAdded:Connect(added)
	for _, player in Players:GetPlayers() do
		added(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		local state = states[player]
		if state then
			restore(player, state)
			states[player] = nil
		end
	end)
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.1 then
			return
		end
		local interval = elapsed
		elapsed = 0
		for player, state in states do
			local part = root(player)
			if not part or not eligible(player) then
				continue
			end
			giveTool(player, state)
			local previous = state.previous
			local delta = if previous then part.Position - previous else Vector3.zero
			local speed = Vector3.new(delta.X, 0, delta.Z).Magnitude / interval
			local equipped = state.tool ~= nil and state.tool.Parent == player.Character
			if equipped and state.visual then
				state.visual:PivotTo(part.CFrame * CFrame.new(0, -3, -3))
			end
			-- Guardar la herramienta no protege la mercancía de los golpes.
			if count(player) > 0 and os.clock() - state.lastFall > 1.5 then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = { player.Character :: Model, world }
				local direction = if delta.Magnitude > 0.01 then delta.Unit else part.CFrame.LookVector
				local obstacle = workspace:Raycast(part.Position, direction * 4, params)
				local floor = workspace:Raycast(part.Position, Vector3.new(0, -5, 0), params)
				local downhill = floor ~= nil
					and floor.Normal.Y < 0.98
					and floor.Normal.Y > 0.3
					and delta.Y / interval < -2
					and speed > 18
				local collision = obstacle ~= nil
					and obstacle.Instance.CanCollide
					and state.speed > 12
					and speed < state.speed * 0.65
				if downhill or collision then
					state.lastFall = os.clock()
					spill(player, state, 0.65)
				end
			end
			state.previous = part.Position
			state.speed = speed
		end
	end)
end

return Service

--!strict
-- H6 Revendedor. Cada revendedor recibe un puesto del tianguis y vende lo que trae en su
-- carga ("u:<id>") a compradores NPC que llegan caminando y regatean por turnos (Haggle).
-- Si no hay jefes con mercancía, se surte del mayoreo NPC (Subasta + 20%).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryService = require(script.Parent.InventoryService)
local MarketService = require(script.Parent.MarketService)
local Products = require(ReplicatedStorage.Shared.Config.Products)
local Freshness = require(ReplicatedStorage.Shared.Freshness)
local Haggle = require(ReplicatedStorage.Shared.Haggle)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Scale = require(ReplicatedStorage.Shared.Config.Scale)

local StallService = {}

local MAYOREO_MARKUP = 1.2
local RETAIL_MARKUP = 1.3 -- precio justo al menudeo sobre la Subasta
local MAX_CARRY = 40 -- cajas que puede traer un revendedor
local MAX_BUY = 10
local NEAR_STALL = Scale.m(10)
local ANSWER_TIMEOUT = 25
local QUALITY = { primera = 1, segunda = 0.75, rezaga = 0.4 }

local NAMES = { "Doña Lupe", "Don Chucho", "La Güera", "Don Beto", "Seño Mari", "Don Pancho", "Doña Toña", "El Profe" }
local OPENERS = { "¿A cómo la caja, joven?", "Écheme precio, marchante.", "¿Qué tal está eso?", "¿Me lo da baratito?" }
local SKIN = { Color3.fromRGB(234, 184, 146), Color3.fromRGB(204, 142, 105), Color3.fromRGB(160, 105, 70), Color3.fromRGB(124, 80, 52) }
local SHIRT = { Color3.fromRGB(200, 60, 60), Color3.fromRGB(60, 110, 200), Color3.fromRGB(240, 200, 60), Color3.fromRGB(80, 160, 90), Color3.fromRGB(230, 120, 180) }
local PANTS = { Color3.fromRGB(40, 50, 80), Color3.fromRGB(70, 60, 50), Color3.fromRGB(30, 30, 30) }

type Customer = {
	npc: Model?,
	name: string,
	product: string,
	lotId: string,
	units: number,
	haggle: Haggle.Haggle,
	ready: boolean,
	deadline: number,
}

local stalls: { [number]: Model } = {}
local customers: { [Player]: Customer } = {}
local nextVisit: { [Player]: number } = {}
local npcFolder: Folder

local function round5(n: number): number
	return math.max(5, math.floor(n / 5 + 0.5) * 5)
end

local function isCount(n: unknown, max: number): boolean
	return type(n) == "number" and n == n and n >= 1 and n <= max and n % 1 == 0
end

local function cashOf(player: Player): number
	local c = player:GetAttribute("Cash")
	return if type(c) == "number" then c else 0
end

local function notify(player: Player, text: string)
	Remotes.get("Notify"):FireClient(player, text)
end

local function stallOf(player: Player): Model?
	local n = player:GetAttribute("Puesto")
	return if type(n) == "number" then stalls[n] else nil
end

local function carried(player: Player): number
	local n = 0
	for _, lot in InventoryService.list(InventoryService.holderOf(player)) do
		n += lot.units
	end
	return n
end

local function pick<T>(list: { T }): T
	return list[math.random(#list)]
end

-- Globo de texto arriba de la cabeza del NPC.
local function say(npc: Model?, text: string)
	local head = npc and npc:FindFirstChild("Head")
	if not head then
		return
	end
	local gui = head:FindFirstChild("Globo") :: BillboardGui?
	if not gui then
		local g = Instance.new("BillboardGui")
		g.Name = "Globo"
		g.Size = UDim2.fromOffset(240, 60)
		g.StudsOffset = Vector3.new(0, 3, 0)
		g.MaxDistance = 60
		local label = Instance.new("TextLabel")
		label.Name = "Texto"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.new(1, 1, 1)
		label.TextColor3 = Color3.fromRGB(20, 20, 20)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.TextWrapped = true
		label.Parent = g
		Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)
		g.Parent = head
		gui = g
	end
	((gui :: BillboardGui):FindFirstChild("Texto") :: TextLabel).Text = text
end

local function spawnNpc(name: string, at: CFrame): Model?
	local desc = Instance.new("HumanoidDescription")
	local skin, shirt, pants = pick(SKIN), pick(SHIRT), pick(PANTS)
	desc.HeadColor, desc.LeftArmColor, desc.RightArmColor = skin, skin, skin
	desc.TorsoColor = shirt
	desc.LeftLegColor, desc.RightLegColor = pants, pants
	local ok, npc = pcall(function()
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	if not ok or not npc then
		return nil
	end
	npc.Name = name
	npc:PivotTo(at)
	npc.Parent = npcFolder
	return npc
end

local function walk(npc: Model, target: Vector3)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	humanoid:MoveTo(target)
	local done = false
	local conn = humanoid.MoveToFinished:Connect(function()
		done = true
	end)
	local t = 0
	while not done and t < 10 and npc.Parent do
		t += task.wait(0.2)
	end
	conn:Disconnect()
end

-- Lo que ve el revendedor en su tarjeta de regateo (sin el tope secreto).
local function view(player: Player, c: Customer): { [string]: any }
	local freshness = 0
	for _, lot in InventoryService.list(InventoryService.holderOf(player)) do
		if lot.id == c.lotId then
			freshness = lot.freshness
		end
	end
	return {
		name = c.name,
		product = c.product,
		units = c.units,
		freshness = freshness,
		offer = c.haggle.offer,
		patience = c.haggle.patience,
	}
end

-- El NPC se va (con o sin compra) y desaparece.
local function leave(player: Player, line: string)
	local c = customers[player]
	customers[player] = nil
	Remotes.get("Haggle"):FireClient(player, nil)
	if not c or not c.npc then
		return
	end
	local npc = c.npc :: Model
	say(npc, line)
	task.spawn(function()
		task.wait(1.5)
		walk(npc, npc:GetPivot().Position + npc:GetPivot().LookVector * -30)
		npc:Destroy()
	end)
end

local function serve(player: Player, stall: Model)
	local holder = InventoryService.holderOf(player)
	local sellable = {}
	for _, lot in InventoryService.list(holder) do
		if Freshness.grade(lot.freshness) ~= "basura" then
			table.insert(sellable, lot)
		end
	end
	if #sellable == 0 then
		return
	end
	local lot = pick(sellable)
	local grade = Freshness.grade(lot.freshness)
	local retail = MarketService.price(lot.product) * RETAIL_MARKUP
	local c: Customer = {
		npc = nil,
		name = pick(NAMES),
		product = lot.product,
		lotId = lot.id,
		units = math.random(1, math.min(3, lot.units)),
		haggle = Haggle.new(retail, QUALITY[grade], math.random(), math.random()),
		ready = false,
		deadline = math.huge,
	}
	customers[player] = c

	local front = stall:GetPivot() * CFrame.new(0, 3, -Scale.m(2.8)) -- −Z local = frente del puesto
	local from = stall:GetPivot() * CFrame.new(math.random(-12, 12), 3, -Scale.m(14))
	local npc = spawnNpc(c.name, CFrame.lookAt(from.Position, front.Position))
	if customers[player] ~= c then
		if npc then
			npc:Destroy()
		end
		return
	end
	if not npc then
		customers[player] = nil
		return
	end
	c.npc = npc
	walk(npc, front.Position)
	if customers[player] ~= c then
		npc:Destroy()
		return
	end
	local here = npc:GetPivot().Position
	local stallPos = stall:GetPivot().Position
	npc:PivotTo(CFrame.lookAt(here, Vector3.new(stallPos.X, here.Y, stallPos.Z)))
	c.ready = true
	c.deadline = os.clock() + ANSWER_TIMEOUT
	say(npc, `{pick(OPENERS)} Le doy ${c.haggle.offer} por caja.`)
	Remotes.get("Haggle"):FireClient(player, view(player, c))
end

local function onReply(player: Player, action: unknown)
	local c = customers[player]
	if not c or not c.ready then
		return
	end
	local ask: number
	if action == "accept" then
		ask = c.haggle.offer
	elseif action == "up10" then
		ask = round5(c.haggle.offer * 1.1)
	elseif action == "up25" then
		ask = round5(c.haggle.offer * 1.25)
	elseif action == "no" then
		leave(player, "Ni modo, al rato vuelvo.")
		return
	else
		return
	end
	local result, price = Haggle.ask(c.haggle, ask)
	if result == "accept" then
		local lot = InventoryService.take(InventoryService.holderOf(player), c.lotId, c.units)
		if not lot then
			leave(player, "¿Ya no hay? Ni modo.")
			return
		end
		local total = price * c.units
		player:SetAttribute("Cash", cashOf(player) + total)
		notify(player, `Vendiste {c.units} de {Products[c.product].name} a {c.name}: +${total}`)
		leave(player, "¡Gracias, marchante!")
	elseif result == "counter" then
		c.deadline = os.clock() + ANSWER_TIMEOUT
		say(c.npc, `¡Uy, no! Ándele, le doy ${price}.`)
		Remotes.get("Haggle"):FireClient(player, view(player, c))
	else
		leave(player, "¡Está carísimo! Mejor me voy.")
	end
end

local function onWholesale(player: Player, productId: unknown, units: unknown)
	if player:GetAttribute("Role") ~= "Revendedor" or not stallOf(player) then
		return
	end
	if type(productId) ~= "string" or not Products[productId] or not isCount(units, MAX_BUY) then
		return
	end
	if carried(player) + (units :: number) > MAX_CARRY then
		notify(player, `Ya no te cabe más: máximo {MAX_CARRY} cajas.`)
		return
	end
	local price = round5(MarketService.price(productId) * MAYOREO_MARKUP)
	local total = price * (units :: number)
	if cashOf(player) < total then
		notify(player, "No te alcanza.")
		return
	end
	player:SetAttribute("Cash", cashOf(player) - total)
	InventoryService.add(InventoryService.holderOf(player), productId, units :: number, 90, player.UserId, price)
	notify(player, `Te surtiste {units} de {Products[productId].name} por ${total}.`)
end

local function setLabel(stall: Model, text: string?)
	local gui = stall:FindFirstChild("Letrero") :: BillboardGui?
	if not text then
		if gui then
			gui:Destroy()
		end
		return
	end
	if not gui then
		local g = Instance.new("BillboardGui")
		g.Name = "Letrero"
		g.Size = UDim2.fromOffset(220, 40)
		g.StudsOffset = Vector3.new(0, 9, 0)
		g.MaxDistance = 120
		g.Adornee = stall.PrimaryPart
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.GothamBlack
		label.TextScaled = true
		label.Parent = g
		g.Parent = stall
		gui = g
	end
	((gui :: BillboardGui):FindFirstChildOfClass("TextLabel") :: TextLabel).Text = text :: string
end

local function claim(player: Player)
	if player:GetAttribute("Puesto") ~= nil then
		return
	end
	for n = 1, #stalls do
		if stalls[n]:GetAttribute("OwnerUserId") == 0 then
			stalls[n]:SetAttribute("OwnerUserId", player.UserId)
			player:SetAttribute("Puesto", n)
			setLabel(stalls[n], `PUESTO DE {string.upper(player.DisplayName)}`)
			nextVisit[player] = os.clock() + 5
			notify(player, `Tu puesto es el {n} del tianguis. Surte en MAYOREO y espera a tus clientes.`)
			return
		end
	end
	notify(player, "No hay puestos libres en este servidor.")
end

local function release(player: Player)
	local stall = stallOf(player)
	if customers[player] then
		leave(player, "Ya se fue el marchante...")
	end
	nextVisit[player] = nil
	if stall then
		stall:SetAttribute("OwnerUserId", 0)
		setLabel(stall, nil)
	end
end

function StallService.start()
	local tianguis = workspace:WaitForChild("CEDA"):WaitForChild("Tianguis")
	for _, d in tianguis:GetChildren() do
		local n = d:GetAttribute("Puesto")
		if d:IsA("Model") and type(n) == "number" then
			stalls[n] = d
			d:SetAttribute("OwnerUserId", 0)
		end
	end
	npcFolder = Instance.new("Folder")
	npcFolder.Name = "Compradores"
	npcFolder.Parent = workspace

	local function watch(player: Player)
		local function check()
			if player:GetAttribute("Role") == "Revendedor" and player:GetAttribute("DataLoaded") then
				claim(player)
			end
		end
		player:GetAttributeChangedSignal("Role"):Connect(check)
		check()
	end
	for _, p in Players:GetPlayers() do
		watch(p)
	end
	Players.PlayerAdded:Connect(watch)
	Players.PlayerRemoving:Connect(release)

	Remotes.get("HaggleReply").OnServerEvent:Connect(onReply)
	Remotes.get("WholesaleBuy").OnServerEvent:Connect(onWholesale)

	-- Llegan compradores a los puestos atendidos (dueño cerca y con mercancía).
	task.spawn(function()
		while true do
			task.wait(1)
			for player, at in nextVisit do
				local c = customers[player]
				if c then
					if c.ready and os.clock() > c.deadline then
						leave(player, "¡Ay, qué lento! Me voy.")
						nextVisit[player] = os.clock() + math.random(6, 10)
					end
				elseif os.clock() >= at then
					local stall = stallOf(player)
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if
						stall
						and root
						and root:IsA("BasePart")
						and (root.Position - stall:GetPivot().Position).Magnitude <= NEAR_STALL
					then
						nextVisit[player] = os.clock() + math.random(8, 14)
						task.spawn(serve, player, stall)
					end
				end
			end
		end
	end)
end

return StallService

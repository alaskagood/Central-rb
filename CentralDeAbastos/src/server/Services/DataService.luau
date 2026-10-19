--!strict
-- Guardado con ProfileStore (loleris, Tienda de creadores 109379033046155):
-- bloqueo de sesión, guardado periódico y al salir. Si la carga falla se saca
-- al jugador y NO se guarda nada (no se borra su progreso).

local Players = game:GetService("Players")

local ProfileStore = require(script.Parent.Parent.Lib.ProfileStore)
local InventoryService = require(script.Parent.InventoryService)

local TEMPLATE = {
	cash = -1, -- -1 = nunca ha elegido oficio; RoleService le da el dinero inicial
	lots = {},
}

local DataService = {}

local store = ProfileStore.New("Jugadores_v1", TEMPLATE)
local profiles: { [Player]: any } = {}

-- Copia el estado vivo (atributo Cash e inventario) a Profile.Data.
local function snapshot(player: Player, profile: any)
	local cash = player:GetAttribute("Cash")
	if type(cash) == "number" and cash == cash then
		profile.Data.cash = math.floor(cash)
	end
	local lots = {}
	for _, lot in InventoryService.list(InventoryService.holderOf(player)) do
		table.insert(lots, table.clone(lot))
	end
	profile.Data.lots = lots
end

local function onPlayerAdded(player: Player)
	local profile = store:StartSessionAsync(`u_{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	if profile == nil then
		player:Kick("No pudimos cargar tus datos. Vuelve a entrar en un momento.")
		return
	end
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Tus datos se abrieron en otro servidor. Vuelve a entrar.")
		end
	end)
	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	profiles[player] = profile
	InventoryService.load(InventoryService.holderOf(player), profile.Data.lots)
	if profile.Data.cash >= 0 then
		player:SetAttribute("Cash", profile.Data.cash)
	end
	profile.OnSave:Connect(function()
		snapshot(player, profile)
	end)
	player:SetAttribute("DataLoaded", true)
end

function DataService.start()
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player: Player)
		local profile = profiles[player]
		if profile then
			snapshot(player, profile)
			profile:EndSession()
		end
		InventoryService.drop(InventoryService.holderOf(player))
	end)
end

return DataService

--!strict
-- Elección de oficio. El cliente pide un rol; el servidor valida cupo y lo asigna
-- con un Team (se ve en la tabla de jugadores) y el atributo "Role".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RoleService = {}

local teams: { [string]: Team } = {}

local function countInRole(roleId: string): number
	local n = 0
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("Role") == roleId then
			n += 1
		end
	end
	return n
end

local function assign(player: Player, roleId: string)
	local role = Roles[roleId :: Roles.RoleId]
	player:SetAttribute("Role", role.id)
	player.Team = teams[role.id]
	if player:GetAttribute("Cash") == nil then
		player:SetAttribute("Cash", role.startingCash)
	end
	Remotes.get("RoleAssigned"):FireClient(player, role.id)
	player:LoadCharacter()
end

function RoleService.start()
	for id, role in Roles do
		local team = Instance.new("Team")
		team.Name = role.name
		team.TeamColor = BrickColor.new(role.color)
		team.AutoAssignable = false
		team.Parent = Teams
		teams[id] = team
	end

	Remotes.get("PickRole").OnServerEvent:Connect(function(player: Player, roleId: unknown)
		if typeof(roleId) ~= "string" or Roles[roleId :: Roles.RoleId] == nil then
			return -- dato inválido del cliente: se ignora
		end
		if player:GetAttribute("Role") ~= nil then
			Remotes.get("RoleRejected")
				:FireClient(player, "Ya tienes oficio. Cámbialo en el kiosco de la entrada.")
			return
		end
		local role = Roles[roleId :: Roles.RoleId]
		if role.maxPerServer and countInRole(role.id) >= role.maxPerServer then
			Remotes.get("RoleRejected"):FireClient(player, "Ya no hay bodegas libres en este servidor.")
			return
		end
		assign(player, role.id)
	end)
end

return RoleService

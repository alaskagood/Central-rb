--!strict
-- Un solo lugar para los RemoteEvents. El servidor los crea; el cliente los espera.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NAMES = {
	"PickRole", -- cliente → servidor: (roleId)
	"RoleAssigned", -- servidor → cliente: (roleId)
	"RoleRejected", -- servidor → cliente: (reason)
	"Notify", -- servidor → cliente: (text)
	"Inventory", -- servidor → cliente: ({Lot}) lo que trae el jugador
}

local Remotes = {}

local function folder(): Folder
	if RunService:IsServer() then
		local existing = ReplicatedStorage:FindFirstChild("Remotes")
		if existing then
			return existing :: Folder
		end
		local f = Instance.new("Folder")
		f.Name = "Remotes"
		for _, name in NAMES do
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = f
		end
		f.Parent = ReplicatedStorage
		return f
	end
	return ReplicatedStorage:WaitForChild("Remotes") :: Folder
end

function Remotes.get(name: string): RemoteEvent
	assert(table.find(NAMES, name), "Remote desconocido: " .. name)
	return folder():WaitForChild(name) :: RemoteEvent
end

return Remotes

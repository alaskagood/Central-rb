--!strict
-- Punto de entrada del servidor: arranca servicios y arma el mundo.

local Players = game:GetService("Players")

local Services = script.Parent.Services
local RoleService = require(Services.RoleService)
local ClockService = require(Services.ClockService)
local InventoryService = require(Services.InventoryService)
local DataService = require(Services.DataService)
local NaveBuilder = require(script.Parent.World.NaveBuilder)

-- Nadie aparece hasta elegir oficio.
Players.CharacterAutoLoads = false

RoleService.start()
ClockService.start()
InventoryService.start(ClockService)
DataService.start()

-- Solo en Studio: el MCP corre en otra VM y su require da otra copia de los servicios.
-- ServerStorage.Prueba:Invoke("add", holder, ...) llega al InventoryService real.
if game:GetService("RunService"):IsStudio() then
	local prueba = Instance.new("BindableFunction")
	prueba.Name = "Prueba"
	prueba.OnInvoke = function(fn: string, ...: any): any
		return (InventoryService :: any)[fn](...)
	end
	prueba.Parent = game:GetService("ServerStorage")
end

local world = Instance.new("Folder")
world.Name = "CEDA"
world.Parent = workspace
NaveBuilder.build(world, CFrame.new(0, 0, 0))

print("[CEDA] Servidor listo")

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
require(Services.MarketService).start(ClockService)

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

-- El mapa ya viene construido en el lugar (para verlo y acomodarlo en el editor).
-- Solo si no existe se arma desde cero; lo que el usuario mueva en Studio manda.
if not workspace:FindFirstChild("CEDA") then
	local world = Instance.new("Folder")
	world.Name = "CEDA"
	world.Parent = workspace
	NaveBuilder.build(world, CFrame.new(0, 0, 0))
end
local ceda = workspace:FindFirstChild("CEDA") :: Folder
if not ceda:FindFirstChild("Tianguis") then
	require(script.Parent.World.TianguisBuilder).build(ceda, CFrame.new(0, 0, -110))
end
-- Estos buscan bodegas y puestos: van después del mapa.
require(Services.BodegaService).start()
require(Services.DiableroService).start()
require(Services.StallService).start()

print("[CEDA] Servidor listo")

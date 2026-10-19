--!strict
-- Punto de entrada del servidor: arranca servicios y arma el mundo.

local Players = game:GetService("Players")

local Services = script.Parent.Services
local RoleService = require(Services.RoleService)
local ClockService = require(Services.ClockService)
local NaveBuilder = require(script.Parent.World.NaveBuilder)

-- Nadie aparece hasta elegir oficio.
Players.CharacterAutoLoads = false

RoleService.start()
ClockService.start()

local world = Instance.new("Folder")
world.Name = "CEDA"
world.Parent = workspace
NaveBuilder.build(world, CFrame.new(0, 0, 0))

print("[CEDA] Servidor listo")

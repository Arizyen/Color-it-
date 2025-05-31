-- Services
-- local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
-- local BaseModules = ServerStorage.Source.BaseModules
-- local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
-- local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Knit = require(Packages.Knit)

-- KnitServices
local AlertService = Knit.CreateService({
	Name = "Alert",
	Client = { AddAlert = Knit.CreateSignal() },
})

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function AlertService:KnitInit() end

function AlertService:KnitStart() end
-- COMPONENT FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
function AlertService:AddAlert(player, windowName)
	self.Client.AddAlert:Fire(player, windowName)
end
-- CLIENT FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------

return AlertService

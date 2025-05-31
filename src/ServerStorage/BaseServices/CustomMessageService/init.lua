-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Knit = require(Packages.Knit)

-- KnitServices
local CustomMessageService = Knit.CreateService({
	Name = "CustomMessage",
	Client = { ShowCustomMessage = Knit.CreateSignal() },
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
function CustomMessageService:KnitInit() end

function CustomMessageService:KnitStart() end
-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------
-- properties can include the keys: message, icon, title, customSize, customPosition
function CustomMessageService:ShowCustomMessage(player, properties)
	self.Client.ShowCustomMessage:Fire(player, properties)
end
-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------------

return CustomMessageService

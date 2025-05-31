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
local CameraShakeService = Knit.CreateService({
	Name = "CameraShake",
	Client = { StartCameraShake = Knit.CreateSignal(), StopCameraShake = Knit.CreateSignal() },
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
-- Require Knit Services in KnitInit(). KnitStart() is called after all KnitInit() have been completed.
function CameraShakeService:KnitInit() end

-- KnitStart() fires after all KnitInit() have been completed.
function CameraShakeService:KnitStart() end
-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------
function CameraShakeService:StartCameraShake(player, presetName, sustain, factor)
	self.Client.StartCameraShake:Fire(player, presetName, sustain, factor)
end

function CameraShakeService:StopCameraShake(player, fadeOutTime)
	self.Client.StopCameraShake:Fire(player, fadeOutTime)
end
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

return CameraShakeService

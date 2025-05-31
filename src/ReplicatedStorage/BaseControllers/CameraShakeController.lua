-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
local CameraManager = require(ReplicatedBaseModules:WaitForChild("CameraManager"))

-- KnitControllers
local CameraShakeController = Knit.CreateController({
	Name = "CameraShake",
})

-- Instances

-- Configs

-- Variables

-- Tables
local knitServices = {}

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- Require Knit Services in KnitInit(). KnitStart() is called after all KnitInit() have been completed.
function CameraShakeController:KnitInit()
	knitServices["CameraShake"] = Knit.GetService("CameraShake")
end

-- KnitStart() fires after all KnitInit() have been completed.
function CameraShakeController:KnitStart()
	knitServices["CameraShake"].StartCameraShake:Connect(function(presetName, sustain, factor)
		CameraManager.StartCameraShake(presetName, sustain, factor)
	end)

	knitServices["CameraShake"].StopCameraShake:Connect(function(fadeOutTime)
		CameraManager.StopCameraShake(fadeOutTime)
	end)
end
-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT - SERVER FUNCTIONS ------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

return CameraShakeController

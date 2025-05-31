local SettingsObserver = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Configs = Source:WaitForChild("Configs")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local ReplicatedGameModules = Source:WaitForChild("GameModules")
local BaseControllers = Source:WaitForChild("BaseControllers")
local GameControllers = Source:WaitForChild("GameControllers")

-- Modulescripts -------------------------------------------------------------------
local Utils = require(Source:WaitForChild("Utils"))

-- Knit Controllers ----------------------------------------------------------------
local PlayersDataController = require(BaseControllers:WaitForChild("PlayersDataController"))
-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
PlayersDataController:ObserveKey("musicVolume", function(newValue)
	if type(newValue) == "number" then
		Utils.Sound.UpdateTagVolume("Music", newValue / 100)
	end
end)

PlayersDataController:ObserveKey("soundEffectsVolume", function(newValue)
	if type(newValue) == "number" then
		Utils.Sound.UpdateTagVolume("SoundEffect", newValue / 100)
	end
end)
------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return SettingsObserver

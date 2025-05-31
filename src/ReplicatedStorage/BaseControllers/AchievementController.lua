-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
-- local Source = ReplicatedStorage:WaitForChild("Source")
--
--
-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
-- KnitControllers
local AchievementController = Knit.CreateController({
	Name = "Achievement",
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
function AchievementController:KnitInit()
	knitServices["Achievement"] = Knit.GetService("Achievement")
end

function AchievementController:KnitStart() end
-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------

-- CLIENT - SERVER FUNCTIONS ------------------------------------------------------------------------------------------------------------------------
function AchievementController:ClaimAchievement(achievementName)
	knitServices["Achievement"]:ClaimAchievement(achievementName)
end

return AchievementController

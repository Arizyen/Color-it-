-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")

local BaseControllers = Source:WaitForChild("BaseControllers")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))

-- KnitControllers
local RewardController = Knit.CreateController({
	Name = "Reward",
})
local MessageController = require(BaseControllers:WaitForChild("MessageController"))

-- Instances

-- Configs

-- Variables
-- local groupId = 12573638
-- Tables
local knitServices = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function RewardController:KnitInit()
	knitServices["Reward"] = Knit.GetService("Reward")
end

function RewardController:KnitStart() end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
function RewardController:AwardGroupReward()
	knitServices["Reward"]:AwardGroupReward()
end

function RewardController:AwardDailyReward(dayNumber)
	return knitServices["Reward"]:AwardDailyReward(dayNumber)
end

function RewardController:AwardPlayTimeReward(rewardNumber)
	knitServices["Reward"]:AwardPlayTimeReward(rewardNumber)
end

function RewardController:ResetPlayTimeReward()
	knitServices["Reward"]:ResetPlayTimeReward()
end

-- function RewardController:AwardPremiumReward()
-- 	knitServices["Reward"]:AwardPremiumReward()
-- end

return RewardController

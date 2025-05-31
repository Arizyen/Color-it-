-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedSource.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Knit = require(Packages.Knit)
local Signals = require(ReplicatedSource.Utils.Signals)
local Daily = require(script.Rewards.Daily)
local Group = require(script.Rewards.Group)
local PlayTime = require(script.Rewards.PlayTime)
local Premium = require(script.Rewards.Premium)

-- KnitServices
local RewardService = Knit.CreateService({
	Name = "Reward",
	Client = {},
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
function RewardService:KnitInit() end

function RewardService:KnitStart()
	Signals.Connect("PlayerAdded", function(player)
		Daily:CheckDailyStreak(player)
		PlayTime:CheckPlayTimeReward(player)
	end)

	Signals.Connect("PlayerRemoving", function(player)
		PlayTime:UpdatePlayTimeRewardTime(player)
	end)
end
-- COMPONENT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------

-- DAILY ----------------------------------------------------------------------------------------------------

-- PLAY TIME REWARDS -----------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
function RewardService.Client:AwardGroupReward(player)
	Group:Award(player)
end

function RewardService.Client:AwardDailyReward(player, dayNumber)
	Daily:Award(player, dayNumber)
end

function RewardService.Client:AwardPremiumReward(player)
	Premium:Award(player)
end

function RewardService.Client:AwardPlayTimeReward(player, playTimeIndex)
	PlayTime:Award(player, playTimeIndex)
end

function RewardService.Client:ResetPlayTimeReward(player)
	PlayTime:CheckPlayTimeReward(player)
end

return RewardService

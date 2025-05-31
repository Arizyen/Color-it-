-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances
local LocalPlayer = game.Players.LocalPlayer

-- Configs

-- Variables

-- Tables
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local Data = Rodux.createReducer({
	claimedAchievements = {},
	claimableAchievements = {},
	dailyRewardsTimeClaimed = {},
	dailyRewardsClaimed = {},
	playTimeRewardsClaimed = {},
	dayStreak = 0,
	gamepasses = {},
	xp = 0,
	maxXP = 1000,
}, {
	UpdateData = function(state, action)
		local newState = Utils.Table.Copy(state)

		for key, value in pairs(action.value) do
			if type(value) == "table" then
				newState[key] = Utils.Table.Copy(value)
			else
				newState[key] = value and value or nil
			end
		end

		return newState
	end,
})

return Data

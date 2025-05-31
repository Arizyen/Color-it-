-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

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
local LeadersboardsReducer = Rodux.createReducer({
	leaderboardWeekUpdateTime = 0,
	leaderboardUpdateTime = 0,
	leaderboardsData = {},
	currentLeaderboardsRankingShown = {},
	leaderboardParts = {},
}, {
	UpdateLeaderboardKeyData = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.leaderboardsData = Utils.Table.Copy(newState.leaderboardsData)
		newState.leaderboardsData[action.key] = action.data

		return newState
	end,

	SetLeaderboardWeekUpdateTime = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState["leaderboardWeekUpdateTime"] = action.value or 0

		return newState
	end,

	SetLeaderboardUpdateTime = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState["leaderboardUpdateTime"] = action.value or 0

		return newState
	end,

	SetCurrentLeaderboardRankingShown = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState["currentLeaderboardsRankingShown"] = Utils.Table.Copy(newState["currentLeaderboardsRankingShown"])
		newState["currentLeaderboardsRankingShown"][action.key] = action.value

		return newState
	end,

	SetLeaderboardParts = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState["leaderboardParts"] = Utils.Table.DeepCopy(newState["leaderboardParts"], action.value)

		return newState
	end,
})

return LeadersboardsReducer

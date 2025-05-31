-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
local PlayerData = Rodux.createReducer({}, {
	UpdatePlayerData = function(state, action)
		local newState = Utils.Table.Copy(state)

		if action.player then
			newState[action.player.UserId] = action.data and Utils.Table.DeepCopy(action.data) or nil
		end

		return newState
	end,

	UpdatePlayerDataKeyValue = function(state, action)
		local newState = Utils.Table.Copy(state)

		local playerKey = action.player and action.player.UserId
		if action.player then
			if not newState[playerKey] then
				newState[playerKey] = {}
			end

			if action.dataKey then
				newState[playerKey][action.dataKey] = action.dataValue
			end
		end

		return newState
	end,
})

return PlayerData

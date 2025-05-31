-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
-- local Llama = require(Packages:WaitForChild("Llama"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables

--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
local PlayerStatsReducer = Rodux.createReducer({
	hasDied = false,
}, {
	SetNewStat = function(state, action)
		local newState = Utils.Table.Copy(state, action.value)
		return newState
	end,
})

return PlayerStatsReducer

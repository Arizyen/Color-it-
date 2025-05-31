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
local StoreReducer = Rodux.createReducer({
	currentCategory = "passes",
}, {
	SetStoreCategory = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.currentCategory = action.value

		return newState
	end,
})

return StoreReducer

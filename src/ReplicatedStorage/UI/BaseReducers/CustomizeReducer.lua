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
local categories = {
	"Skins",
	"Trails",
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local CustomizeReducer = Rodux.createReducer({
	currentCustomizeCategory = "Skins",
}, {
	SetCustomizeCategory = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.currentCustomizeCategory = action.value

		return newState
	end,

	ShowNextCustomizeCategory = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.currentCustomizeCategory = categories[table.find(categories, state.currentCustomizeCategory) + (action.value and 1 or -1)]
			or categories[action.value and 1 or #categories]

		return newState
	end,
})

return CustomizeReducer

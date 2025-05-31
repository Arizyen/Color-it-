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
local PromptReducer = Rodux.createReducer({
	message = "",
	onClick = false,
	promptShown = false,
	customPosition = false,
	customSize = false,
}, {
	SetPromptMessage = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.message = type(action.value) == "string" and action.value or ""

		return newState
	end,

	SetPromptOnClick = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.onClick = action.value or false

		return newState
	end,

	SetPromptCustomPosition = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.customPosition = action.value or false

		return newState
	end,

	SetPromptCustomSize = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.customSize = action.value or false

		return newState
	end,

	UpdatePrompt = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.promptShown = action.value or false
		newState.message = type(action.message) == "string" and action.message or ""
		newState.onClick = action.onClick or false
		newState.customPosition = action.customPosition or false
		newState.customSize = action.customSize or false
		newState.yesButtonText = action.yesButtonText or "Yes"
		newState.noButtonText = action.noButtonText or "No"

		return newState
	end,
})

return PromptReducer

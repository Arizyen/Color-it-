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
local OverlayReducer = Rodux.createReducer({
	windowsOverlay = {},
	windowOverlayShown = false,
}, {
	SetWindowOverlayPosition = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.windowsOverlay[action.windowName] = action.position or nil

		if action.windowName then
			newState.windowOverlayShown = action.position and action.windowName or nil
		end

		return newState
	end,

	HideWindowsOverlay = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.windowsOverlay = {}
		newState.windowOverlayShown = nil

		return newState
	end,
})

return OverlayReducer

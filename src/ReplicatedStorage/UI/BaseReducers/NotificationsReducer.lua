-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local UI = Source:WaitForChild("UI")

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
local NotificationsReducer = Rodux.createReducer({
	totalNotifications = 0,
	allNotifications = {},
}, {
	UpdateNotification = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.allNotifications = Utils.Table.Copy(state.allNotifications)
		newState.allNotifications[action.id] = action.value

		local totalNotifications = 0
		for _, _ in pairs(newState.allNotifications) do
			totalNotifications += 1
		end
		newState.totalNotifications = totalNotifications

		return newState
	end,
})

return NotificationsReducer

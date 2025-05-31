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
local CustomMessageReducer = Rodux.createReducer({
	message = "",
	icon = nil,
	title = nil,
	customSize = UDim2.fromScale(0.5, 0.5),
	customPosition = UDim2.fromScale(0.5, 0.5),
	titleBackgroundColor = Color3.fromRGB(0, 170, 255),
}, {
	UpdateCustomMessage = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.message = action.message
		newState.icon = action.icon
		newState.title = action.title
		newState.customSize = action.customSize or UDim2.fromScale(0.5, 0.5)
		newState.customPosition = action.customPosition or UDim2.fromScale(0.5, 0.5)
		newState.titleBackgroundColor = action.titleBackgroundColor or Color3.fromRGB(0, 170, 255)

		return newState
	end,
})

return CustomMessageReducer

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(Source:WaitForChild("Utils"))
local CoreGuiManager = require(ReplicatedBaseModules:WaitForChild("CoreGuiManager"))

-- KnitControllers

-- Instances
-- local Mouse = game.Players.LocalPlayer:GetMouse()

-- Configs

-- Types
type DeviceType = "pc" | "mobile" | "console"

-- Variables
if not game.Workspace.CurrentCamera then
	repeat
		task.wait()
	until game.Workspace.CurrentCamera
end

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local GameStateReducer = Rodux.createReducer({
	gameLoading = true,
	appEnabled = false,

	deviceType = "pc",
	-- isProServer = GameConfigs._IS_PRO_SERVER,
}, {
	SetGameState = function(state, action)
		local newState = Utils.Table.Copy(state)
		for eachAction, eachValue in pairs(action.value) do
			newState[eachAction] = eachValue
		end

		if newState.gameLoading then
			Utils.Signals.Fire("gameLoading", true)
		else
			Utils.Signals.Fire("gameLoading", false)
		end

		CoreGuiManager.UpdateGameState(newState)
		return newState
	end,

	SetDeviceType = function(state, action)
		local newState = Utils.Table.Copy(state)

		newState.deviceType = action.value :: DeviceType

		return newState
	end,
})

return GameStateReducer

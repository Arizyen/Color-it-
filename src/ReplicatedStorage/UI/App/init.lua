-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local Utils = require(Source:WaitForChild("Utils"))
local CameraManager = require(ReplicatedBaseModules:WaitForChild("CameraManager"))

local Background = require(script:WaitForChild("Background"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function App(props)
	local dispatch = ReactRedux.useDispatch()

	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local appEnabled = ReactRedux.useSelector(function(state)
		return state.game.appEnabled
	end)

	-- MEMOIZE -----------------------------------------------------------------------------------------------------------------------------------

	-- EFFECTS -----------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		task.spawn(function()
			game.ReplicatedFirst:WaitForChild("GuisLoaded").Value = true
		end)

		-- Signals.Connect("PlayerHumanoidAdded", function(player, humanoid)
		-- 	if player == game.Players.LocalPlayer then
		-- 		dispatch({
		-- 			type = "CloseAllWindows",
		-- 		})
		-- 		CameraManager.ResetCamera()
		-- 	end
		-- end)
	end, {})

	React.useEffect(function()
		props.screenGUI.Enabled = appEnabled
	end, appEnabled)

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return {
		Background = e(Background),
	}
end

return App

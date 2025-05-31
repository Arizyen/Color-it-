local UI = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUIService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local ReplicatedGameModules = Source:WaitForChild("GameModules")
local BaseControllers = Source:WaitForChild("BaseControllers")
local GameControllers = Source:WaitForChild("GameControllers")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local App = require(script:WaitForChild("App"))
local Store = require(script:WaitForChild("Store"))
local AllContextProviders = require(script:WaitForChild("AllContextProviders"))
local Utils = require(Source:WaitForChild("Utils"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------
local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local store = Store.ReturnStore()
local e = React.createElement

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function CreateCameraViewportSizeConnection()
	local viewportSize

	game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		viewportSize = game.Workspace.CurrentCamera.ViewportSize
		local lastSize = viewportSize

		-- Update window size only after 1 second of the window no longer changing size
		task.wait(0.5)

		if lastSize == viewportSize then
			Utils.Signals.Fire("DispatchAction", {
				type = "UpdateThemeState",
				value = {
					guiInset = GUIService:GetGuiInset(),
					cameraViewportSize = viewportSize,
					totalScreenSize = viewportSize.X + viewportSize.Y,
					screenResolution = Mouse and Mouse.ViewSizeX and Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY),
				},
			})
		end
	end)

	viewportSize = game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdateThemeState",
		value = {
			guiInset = GUIService:GetGuiInset(),
			cameraViewportSize = viewportSize,
			totalScreenSize = viewportSize.X + viewportSize.Y,
			screenResolution = Mouse and Mouse.ViewSizeX and Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY),
		},
	})
end
------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function UI.MountApp()
	local screenGUI = Instance.new("ScreenGui")
	screenGUI.Name = "MainGui"
	screenGUI.Parent = PlayerGui
	screenGUI.IgnoreGuiInset = true
	screenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGUI.ResetOnSpawn = false

	local root = ReactRoblox.createRoot(screenGUI)

	root:render(e(
		ReactRedux.Provider,
		{
			store = store,
		},
		e(
			AllContextProviders,
			nil,
			e(App, {
				screenGUI = screenGUI,
			})
		)
	))

	Utils.Signals.Fire("DispatchAction", {
		type = "SetGameState",
		value = {
			gameLoading = false,
			appEnabled = true,
		},
	})

	Utils.Signals.Fire("AppMounted")
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
CreateCameraViewportSizeConnection()

return UI

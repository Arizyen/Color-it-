-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUIService = game:GetService("GuiService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances
local Mouse = game.Players.LocalPlayer:GetMouse()

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local ThemeReducer = Rodux.createReducer({
	defaultFont = Enum.Font.FredokaOne,
	secondaryFont = Enum.Font.FredokaOne,
	numbersFont = Enum.Font.FredokaOne,
	maxWindowSizeX = 0.58,
	maxWindowSizeY = 0.58,

	strokeColor = Color3.fromRGB(255, 255, 255),

	guiInset = GUIService:GetGuiInset(),
	cameraViewportSize = game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.ViewportSize
		or Vector2.new(1280, 720), -- ignores GUI inset
	totalScreenSize = 1300,
	screenResolution = Mouse and Mouse.ViewSizeX and Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY), -- Does not ignore GUI inset
}, {
	UpdateThemeState = function(state, action)
		local newState = Utils.Table.Copy(state)

		for eachKey, eachValue in pairs(action.value) do
			newState[eachKey] = eachValue
		end

		return newState
	end,

	SetCameraViewportSize = function(state, action)
		local newState = Utils.Table.Copy(state)

		if typeof(action.value) == "Vector2" then
			newState.cameraViewportSize = action.value
		else
			newState.cameraViewportSize = game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.ViewportSize
				or Vector2.new(1280, 720)
		end

		newState.totalScreenSize = newState.cameraViewportSize.X + newState.cameraViewportSize.Y
		newState.screenResolution = Mouse and Mouse.ViewSizeX and Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY)

		return newState
	end,
})

return ThemeReducer

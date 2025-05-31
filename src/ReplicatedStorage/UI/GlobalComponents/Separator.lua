-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Configs = Source:WaitForChild("Configs")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local ReplicatedGameModules = Source:WaitForChild("GameModules")
local BaseControllers = Source:WaitForChild("BaseControllers")
local GameControllers = Source:WaitForChild("GameControllers")

local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local BaseComponents = UI:WaitForChild("BaseComponents")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))
local Utils = require(Source:WaitForChild("Utils"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type props = {}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function Separator(props: props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------

	return e(
		"Frame",
		Utils.Table.Merge({
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.2, 0.1),
		}, props),
		{
			UIGradient = e("UIGradient", {
				Rotation = 0,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0.5),
					NumberSequenceKeypoint.new(0.5, 0.3),
					NumberSequenceKeypoint.new(0.8, 0.5),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(190, 190, 190)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 190)),
				}),
			}),
		}
	)
end

return Separator

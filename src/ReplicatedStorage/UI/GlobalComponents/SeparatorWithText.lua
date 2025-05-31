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
local TextLabel = require(BaseComponents:WaitForChild("TextLabel"))
local Separator = require(BaseComponents:WaitForChild("Separator"))
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type props = {
	text: string,
	textSize: UDim2?,
	textColor3: Color3?,
	textStrokeSize: number?,
	textStrokeColor3: Color3?,
	textStrokeTransparency: number?,
	textUIGradient: UIGradient?,
	separatorSize: UDim2?,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function SeparatorWithText(props: props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"Frame",
		Utils.Table.MergeProps(props, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.075),
		}),
		{
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Separator1 = e(Separator, {
				LayoutOrder = 1,
				Size = props.separatorSize,
			}),
			TextLabel = e(TextLabel, {
				LayoutOrder = 2,
				AnchorPoint = Vector2.new(0.5, 0),
				Size = props.textSize or UDim2.fromScale(0.325, 1),
				Text = props.text,
				TextColor3 = props.textColor3,
				TextStrokeTransparency = props.textStrokeTransparency or 1,
				RichText = true,
			}, {
				UIGradient = props.textUIGradient and e("UIGradient", {
					Color = props.textUIGradient,
					Rotation = 90,
				}),
				UIStroke = props.textStrokeSize and e(UIStroke, {
					Thickness = props.textStrokeSize,
					Color = props.textStrokeColor3,
					Transparency = props.textStrokeTransparency or 1,
				}),
			}),
			Separator2 = e(Separator, {
				LayoutOrder = 3,
				Size = props.separatorSize,
			}),
		}
	)
end

return SeparatorWithText

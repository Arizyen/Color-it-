-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Configs = Source:WaitForChild("Configs")
local Infos = Source:WaitForChild("Infos")
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
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents ----------------------------------------------------------------
local CustomButton = require(GlobalComponents:WaitForChild("CustomButton"))

-- LocalComponents -----------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type props = {
	currency: string,
	price: number,
	onClick: () -> nil,
	cornerRadius: UDim,
	colorSequence: ColorSequence,
	Size: UDim2,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function ButtonPurchase(props: props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		CustomButton,
		Utils.Table.MergeProps(props, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0,
			Text = "",
			onClick = props.onClick,
		}),
		{
			UICorner = e("UICorner", {
				CornerRadius = props.cornerRadius or UDim.new(0.1, 0),
			}),
			UIGradient = e("UIGradient", {
				Color = props.colorSequence or Utils.Color.colorSequences["green"],
				Rotation = 90,
			}),
			UIStroke = e(UIStroke, {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 3,
			}),
			Frame = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.75, 1),
			}, {
				UIListLayout = e("UIListLayout", {
					Padding = UDim.new(0.05, 0),
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				ImageLabel = e("ImageLabel", {
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(0.3, 0.8),
					Image = props.currency == "coins" and "rbxassetid://106276938262912"
						or "rbxassetid://106510006707859",
					ScaleType = Enum.ScaleType.Fit,
				}),
				TextLabelCost = e(TextLabel, {
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(0.6, 0.8),
					Text = props.price,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					TextStrokeTransparency = 0.8,
				}),
			}),
		},
		props.children
	)
end

return ButtonPurchase

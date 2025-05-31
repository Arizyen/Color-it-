-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))

local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents
local ButtonInvisible = require(GlobalComponents:WaitForChild("ButtonInvisible"))

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function OnOff(props)
	-- Requires: anchorPoint, position, size, isOn, onClick
	-- Optional:
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES --------------------------------------------------------------------------------------------------------------------

	-- EFFECTS ---------------------------------------------------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e(
		"Frame",
		Utils.Table.MergeProps(props, {
			AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0),
			Position = props.position or UDim2.fromScale(0.5, 0.915),
			Size = props.size or UDim2.fromScale(0.2, 0.09),
			BackgroundTransparency = 1,
		}),
		{
			Frame = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = props.isOn and Color3.fromRGB(85, 170, 0) or Color3.fromRGB(255, 0, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 0.85),
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				UIStroke = e("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(255, 255, 255),
					LineJoinMode = Enum.LineJoinMode.Round,
				}),
				UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
					AspectRatio = 2,
				}),
			}),

			TextButton = e(ButtonInvisible, {
				anchorPoint = Vector2.new(0.5, 0.5),
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(1, 1),
				cornerRadius = UDim.new(1, 0),
				onClick = props.onClick,
			}),

			ImageLabel = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = props.isOn and UDim2.fromScale(0.8, 0.525) or UDim2.fromScale(0.2, 0.525),
				Size = UDim2.fromScale(1.2, 1.2),
				Image = "rbxassetid://10487325925",
				ScaleType = Enum.ScaleType.Fit,
			}),
		}
	)
end

return OnOff

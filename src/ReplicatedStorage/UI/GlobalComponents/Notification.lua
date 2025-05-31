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
local CloseButton = require(GlobalComponents:WaitForChild("CloseButton"))
-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function Notification(props)
	-- Requires: content, onClose, timeShown, image, noCloseButton
	-- Optional:
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS ----------------------------------------------------------------------------------------------------------------------------

	-- EFFECTS/STATES ----------------------------------------------------------------------------------------------------------

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.65,
		LayoutOrder = props.timeShown,
	}, {
		UICorner = e("UICorner", { CornerRadius = UDim.new(0.3, 0) }),
		ImageLabelIcon = props.image and e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.055, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			Image = props.image,
			ScaleType = Enum.ScaleType.Fit,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", { AspectRatio = 1 }),
		}),

		CloseButton = not props.noCloseButton and e(CloseButton, {
			position = UDim2.fromScale(0.95, 0.5),
			size = UDim2.fromScale(0.2, 0.5),
			exactSize = true,
			onClose = props.onClose,
		}),

		FrameContent = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = props.image and UDim2.fromScale(0.095, 0.5) or UDim2.fromScale(0.015, 0.5),
			Size = props.image and UDim2.fromScale(0.82, 0.75)
				or (props.noCloseButton and UDim2.fromScale(0.97, 0.75) or UDim2.fromScale(0.885, 0.75)),
		}, props.content),
	})
end

return Notification

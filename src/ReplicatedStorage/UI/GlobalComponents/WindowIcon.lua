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
local Contexts = require(UI:WaitForChild("Contexts"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents
local UserThumbnail = require(GlobalComponents:WaitForChild("UserThumbnail"))

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function WindowIcon(props)
	-- Requires:
	-- Optional:
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local theme = React.useContext(Contexts.Theme)
	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES --------------------------------------------------------------------------------------------------------------------

	-- EFFECTS ---------------------------------------------------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("ImageLabel", {
		Visible = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(0.24, 0.24):Lerp(
			UDim2.fromScale(0.15, 0.15),
			math.clamp((props.size.Y.Scale - 0.25) / (theme.maxWindowSizeY - 0.25), 0, 1)
		),
		BackgroundTransparency = 1,
		Image = props.icon and "rbxassetid://9435990460" or "",
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 2,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		ImageLabelIcon = e(
			type(props.icon) == "string" and "ImageLabel"
				or (type(props.icon) == "userdata" and props.icon:IsA("Player") and UserThumbnail),
			{
				player = (type(props.icon) == "userdata" and props.icon:IsA("Player") and props.icon) or nil,
				Visible = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = props.icon or "",
				ScaleType = Enum.ScaleType.Fit,
			}
		),
	})
end

return WindowIcon

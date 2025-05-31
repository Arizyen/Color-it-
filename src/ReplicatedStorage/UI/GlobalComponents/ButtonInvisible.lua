-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
-- local Source = ReplicatedStorage:WaitForChild("Source")
-- local UI = Source:WaitForChild("UI")
-- local GlobalComponents = UI:WaitForChild("GlobalComponents")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
-- local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
--
-- local Flipper = require(Packages:WaitForChild("Flipper"))
-- local UIUtils.Flipper = require(ReplicatedModulescripts:WaitForChild("UIUtils.Flipper"))
-- local Utils = require(ReplicatedModulescripts:WaitForChild("Utils"))

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
local function ButtonInvisible(props)
	-- Requires: size, text
	--[[Optional:
        onClick, anchorPoint, position, size, backgroundColor3, backgroundTransparency, visible, layoutOrder
        cornerRadius,
        aspectRatio,
	]]
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOIZE -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES -----------------------------------------------------------------------------------------------------------------------------------
	local buttonRef = React.useRef()

	-- EFFECTS/BINDINGS -----------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if buttonRef.current then
			CollectionService:AddTag(buttonRef.current, "Button")
		end
	end, {})

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("TextButton", {
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
		Position = props.position or UDim2.fromScale(0.5, 0.5),
		Size = props.size or UDim2.fromScale(0.5, 0.5),
		Visible = props.visible or (props.visible == nil),
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = props.layoutOrder or 1,
		ref = buttonRef,

		[React.Event.Activated] = function()
			if props.onClick then
				props.onClick()
			end
		end,
	}, {
		UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
		UIAspectRatioConstraint = props.aspectRatio and e("UIAspectRatioConstraint", {
			AspectRatio = props.aspectRatio,
		}),
	})
end

return ButtonInvisible

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

local Utils = require(Source:WaitForChild("Utils"))
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents
local Button = require(GlobalComponents:WaitForChild("Button"))

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function Page(props)
	-- Requires: anchorPoint, position, size, visible, currentPage, totalPage, onLeftClick, onRightClick, gradientColors
	--[[
		Optional: 
		currentPage, totalPage, text, textSize, noButtonSizeAnimation, textColor3, textStrokeTransparency
		leftButtonSize, leftButtonPosition, rightButtonSize, rightButtonPosition

	]]
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local defaultFont = ReactRedux.useSelector(function(state)
		return state.theme.defaultFont
	end)
	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES --------------------------------------------------------------------------------------------------------------------

	-- EFFECTS ---------------------------------------------------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0),
		Position = props.position or UDim2.fromScale(0.5, 0.915),
		Size = props.size or UDim2.fromScale(0.25, 0.09),
		BackgroundTransparency = 1,
		Visible = props.visible or props.visible == nil,
	}, {
		TextLabelPage = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0),
			Size = props.textSize or UDim2.fromScale(0.45, 1),
			Font = defaultFont,
			TextColor3 = props.textColor3 or Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Text = props.currentPage and props.totalPage and (tostring(
				props.currentPage and props.currentPage > 0 and props.currentPage or 1
			) .. "/" .. tostring(props.totalPage and props.totalPage > 0 and props.totalPage or 1)) or props.text or "",
			TextStrokeTransparency = props.textStrokeTransparency or 0,
		}),

		TextButtonLeft = e(Button, {
			anchorPoint = Vector2.new(0.5, 0.5),
			position = props.leftButtonPosition or UDim2.fromScale(0.135, 0.5),
			size = props.leftButtonSize or UDim2.fromScale(0.275, 1),
			smallRatio = not props.noButtonSizeAnimation and 0.9 or 1,
			largeRatio = not props.noButtonSizeAnimation and 1.10 or 1,
			text = "<",
			font = Enum.Font.FredokaOne,
			aspectRatio = 1,
			cornerRadius = UDim.new(1, 0),
			gradientColors = props.gradientColors or Utils.Colors.gradientColors["green"],
			onClick = props.onLeftClick,
		}),

		TextButtonRight = e(Button, {
			anchorPoint = Vector2.new(0.5, 0.5),
			position = props.rightButtonPosition or UDim2.fromScale(0.86, 0.5),
			size = props.rightButtonSize or UDim2.fromScale(0.275, 1),
			smallRatio = not props.noButtonSizeAnimation and 0.9 or 1,
			largeRatio = not props.noButtonSizeAnimation and 1.10 or 1,
			text = ">",
			font = Enum.Font.FredokaOne,
			aspectRatio = 1,
			cornerRadius = UDim.new(1, 0),
			gradientColors = props.gradientColors or Utils.Colors.gradientColors["green"],
			onClick = props.onRightClick,
		}),
	})
end

return Page

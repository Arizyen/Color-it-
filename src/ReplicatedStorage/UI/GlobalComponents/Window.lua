-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")
local BaseComponents = UI:WaitForChild("BaseComponents")
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

-- BaseComponents
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents
local WindowIcon = require(GlobalComponents:WaitForChild("WindowIcon"))
local CloseButton = require(GlobalComponents:WaitForChild("CloseButton"))
local Title = require(GlobalComponents:WaitForChild("Title"))
-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

-- Selectors
local selector = UIUtils.Selector.Create("Window", {
	theme = { "maxWindowSizeX", "maxWindowSizeY", "totalScreenSize" },
	window = { "windowShown", "hideWindows" },
	prompt = { "promptShown" },
	game = { "gameLoading" },
})
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function Window(props)
	-- Requires: (maxX 0.58, maxY 0.58), windowName, size, color, title, icon, content
	-- Optional: exactSize (boolean), noCloseButton (boolean), anchorPoint (Vector2), onClose (function), customClose (function), visible (boolean), customFrameMainPosition (UDim2), customFrameMainSize (UDim2), clipsDescendants (boolean), titleColorSequence (ColorSequence)
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local storeState = ReactRedux.useSelector(selector)
	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------
	local windowSize = React.useMemo(function()
		return (
			props.exactSize
			or (
				props.size
				and props.size.X.Scale <= storeState.maxWindowSizeX
				and props.size.Y.Scale <= storeState.maxWindowSizeY
				and props.size
			)
		)
			or (
				props.size ~= nil and UDim2.fromScale(storeState.maxWindowSizeX, storeState.maxWindowSizeY)
				or UDim2.fromScale(0.5, 0.5)
			)
	end, { props.size, props.exactSize, storeState.maxWindowSizeX, storeState.maxWindowSizeY })

	local windowMotor, windowMotorBinding = React.useMemo(function()
		return UIUtils.Flipper.CreateMotor(1)
	end, {})

	-- REFS/BINDINGS/STATES --------------------------------------------------------------------------------------------------------------------
	local windowWasShown = React.useRef(false)
	-- EFFECTS ---------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if storeState.windowShown == props.windowName and not storeState.gameLoading then
			if not windowWasShown.current then
				windowMotor:setGoal(Flipper.Linear.new(0, { velocity = 1 / 0.15 }))
				windowWasShown.current = true
			end
		else
			if windowWasShown.current then
				windowMotor:setGoal(Flipper.Linear.new(1, { velocity = 1 / 0.15 }))
				windowWasShown.current = false

				if props.noCloseButton and props.onClose then
					props.onClose()
				end
			end
		end
	end, { storeState.windowShown, storeState.gameLoading })
	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------

	return e(
		"Frame",
		Utils.Table.MergeProps(props, {
			Visible = storeState.windowShown == props.windowName,
			Size = windowSize,
			AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.55),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Position = windowMotorBinding:map(function(value)
				if value <= 0.5 then
					return (props.position or UDim2.fromScale(0.5, 0.5)):lerp(
						UDim2.fromScale(
							(props.position or UDim2.fromScale(0.5, 0.5)).X.Scale,
							((props.position or UDim2.fromScale(0.5, 0.5)).Y.Scale - 0.01)
						),
						TweenService:GetValue(value * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					)
				else
					return UDim2.fromScale(
						(props.position or UDim2.fromScale(0.5, 0.5)).X.Scale,
						((props.position or UDim2.fromScale(0.5, 0.5)).Y.Scale - 0.01)
					):lerp(
						UDim2.fromScale(
							(props.position or UDim2.fromScale(0.5, 0.5)).X.Scale,
							((props.position or UDim2.fromScale(0.5, 0.5)).Y.Scale + 0.01)
						),
						TweenService:GetValue((-0.5 + value) * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					)
				end

				-- return (props.position or UDim2.fromScale(0.5, 0.5)):lerp(
				-- 	UDim2.fromScale(
				-- 		(props.position or UDim2.fromScale(0.5, 0.5)).X.Scale,
				-- 		(
				-- 			(props.position or UDim2.fromScale(0.5, 0.5)).Y.Scale
				-- 			- 0.5
				-- 			- windowSize.Y.Scale
				-- 		)
				-- 	),
				-- 	TweenService:GetValue(value, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				-- )
			end),
			ZIndex = 2,
		}),
		{
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = windowSize and ((windowSize.X.Scale * 1280) / (windowSize.Y.Scale * 720))
					or (0.5 * 1280) / (0.5 * 720),
			}),
			UIStroke = e(UIStroke, {
				Thickness = 5,
			}),
			FrameTitle = props.title and e(Title, {
				windowName = props.windowName,
				size = windowSize,
				title = props.title,
				titleColorSequence = props.titleColorSequence,
				color = props.color,
				icon = props.icon,
				noCloseButton = props.noCloseButton,
				onClose = props.onClose,
				customClose = props.customClose,
			}),
			CloseButton = not props.title and not props.noCloseButton and e(CloseButton, {
				onClose = props.onClose,
				customClose = props.customClose,
				windowSize = windowSize,
				windowName = props.windowName,
				uiStrokeEnabled = true,
			}),
			ImageLabelIcon = not props.title and props.icon and e(WindowIcon, {
				size = windowSize,
				icon = props.icon,
			}),
			FrameMain = e("Frame", {
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				Position = props.customFrameMainPosition or UDim2.fromScale(0, 0.3):Lerp(
					UDim2.fromScale(0, 0.155),
					math.clamp(((windowSize.Y.Scale - 0.25) / (storeState.maxWindowSizeY - 0.25)), 0, 1)
				),
				Size = props.customFrameMainSize or UDim2.fromScale(1, 0.65):Lerp(
					UDim2.fromScale(1, 0.82),
					math.clamp(((windowSize.Y.Scale - 0.25) / (storeState.maxWindowSizeY - 0.25)), 0, 1)
				),
				ClipsDescendants = props.clipsDescendants,
			}, props.content or {}),
		}
	)
end

return Window

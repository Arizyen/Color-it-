-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

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

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function CloseButton(props)
	-- Requires: size
	-- Optional:
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local dispatch = ReactRedux.useDispatch()

	-- MEMOIZE -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS ---------------------------------------------------------------------------------------------------------------------------------
	local clicked = React.useRef(false)
	local buttonRef = React.useRef()

	-- EFFECTS/BINDINGS/STATES/MEMOS -----------------------------------------------------------------------------------------------------------------------
	local backgroundColor, setBackgroundColor = React.useState(Color3.fromRGB(150, 0, 0))

	local closeMotor, closeMotorBinding = React.useMemo(function()
		return UIUtils.Flipper.CreateMotor(0.5)
	end, {})

	-- Unmount effect
	React.useEffect(function()
		if buttonRef.current then
			CollectionService:AddTag(buttonRef.current, "Button")
		end

		return function()
			closeMotor:destroy()
		end
	end, {})
	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("TextButton", {
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
		Position = props.position or UDim2.fromScale(1, 0),
		Size = closeMotorBinding:map(function(value)
			if value > 0.5 then
				return props.size:Lerp(
					UDim2.fromScale(
						props.size.X.Scale * (props.largeRatio or 1.1),
						props.size.Y.Scale * (props.largeRatio or 1.1)
					),
					TweenService:GetValue((value / 0.5) - 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				)
			elseif value < 0.5 then
				if clicked.current then
					return UDim2.fromScale(
						props.size.X.Scale * (props.smallRatio or 0.9),
						props.size.Y.Scale * (props.smallRatio or 0.9)
					):Lerp(
						props.size,
						TweenService:GetValue((value / 0.5), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					)
				else
					return UDim2.fromScale(
						props.size.X.Scale * (props.smallRatio or 0.9),
						props.size.Y.Scale * (props.smallRatio or 0.9)
					):Lerp(
						props.size,
						TweenService:GetValue((value / 0.5), Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
					)
				end
			else
				return props.size
			end
		end),
		Visible = props.visible or (props.visible == nil),
		BackgroundColor3 = backgroundColor,
		AutoButtonColor = false,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = "",
		ref = buttonRef,
		[React.Event.MouseEnter] = function()
			setBackgroundColor(Color3.fromRGB(125, 0, 0))
			closeMotor:setGoal(Flipper.Linear.new(1, { velocity = 1 / 0.25 }))
		end,
		[React.Event.MouseLeave] = function()
			setBackgroundColor(Color3.fromRGB(150, 0, 0))
			closeMotor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.25 }))
		end,
		[React.Event.MouseButton1Down] = function()
			setBackgroundColor(Color3.fromRGB(175, 0, 0))
			clicked.current = true
			closeMotor:setGoal(Flipper.Instant.new(0))
		end,
		[React.Event.Activated] = function()
			setBackgroundColor(Color3.fromRGB(150, 0, 0))
			clicked.current = false
			closeMotor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.4 }))

			if props.customClose then
				props.customClose()
			elseif props.windowName then
				dispatch({
					type = "CloseWindow",
					value = props.windowName,
				})
				dispatch({
					type = "SetWindowOverlayPosition",
					windowName = props.windowName,
					position = nil,
				})

				if props.onClose then
					props.onClose()
				end
			elseif props.onClose then
				props.onClose()
			end
		end,
		ZIndex = 2,
	}, {
		UICorner = e("UICorner", { CornerRadius = UDim.new(0.2, 0) }),
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		FrameRed = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromScale(0.88, 0.85),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, { UICorner = e("UICorner", { CornerRadius = UDim.new(0.2, 0) }) }),
		TextLabel = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.FredokaOne,
			Text = "X",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextStrokeTransparency = 0,
			ZIndex = 4,
		}),
	})
end

return CloseButton

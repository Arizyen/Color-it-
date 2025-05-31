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
local function ImageButton(props)
	-- Requires: size
	-- Optional:
	-- smallRatio, largeRatio, -- when hovering/clicking
	-- anchorPoint, position, size, visible, onClick, image, hoverImage, scaleType, aspectRatio, imageTransparency, rotation, zIndex, layoutOrder
	-- imageColor3, onHoverImageColor3, onClickImageColor3
	-- noButtonAnimation
	-- text, textAnchorPoint, textPosition, textSize, textColor3, textStrokeColor3, textStrokeTransparency

	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local defaultFont = ReactRedux.useSelector(function(state)
		return state.theme.defaultFont
	end)

	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------
	local motor, motorBinding = React.useMemo(function()
		return UIUtils.Flipper.CreateMotor(0.5)
	end, {})

	-- REFS/BINDINGS -----------------------------------------------------------------------------------------------------------------------------------
	local buttonRef = React.useRef()
	local clicked = React.useRef(false)

	local mouseIsHovering, setMouseIsHovering = React.useState(false)

	-- EFFECTS/STATES ----------------------------------------------------------------------------------------------------------
	-- Unmount effect
	React.useEffect(function()
		if buttonRef.current then
			CollectionService:AddTag(buttonRef.current, "Button")
		end

		return function()
			motor:destroy()
		end
	end, {})

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e(
		"ImageButton",
		{
			AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
			Position = props.position or UDim2.fromScale(0.5, 0.5),
			Size = props.size and motorBinding:map(function(value)
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
			BackgroundTransparency = 1,
			-- BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Rotation = props.rotation or 0,
			ZIndex = props.zIndex or 1,
			LayoutOrder = props.layoutOrder or 0,
			Image = props.image,
			HoverImage = props.hoverImage,
			ImageColor3 = props.imageColor3 or Color3.fromRGB(255, 255, 255),
			ImageTransparency = props.imageTransparency or 0,
			ScaleType = props.scaleType or Enum.ScaleType.Fit,
			ref = buttonRef,
			[React.Event.MouseEnter] = function()
				if not props.noButtonAnimation then
					motor:setGoal(Flipper.Linear.new(1, { velocity = 1 / 0.25 }))
				end

				if props.onHoverImageColor3 then
					buttonRef.current.ImageColor3 = props.onHoverImageColor3
				end

				setMouseIsHovering(true)
			end,
			[React.Event.MouseLeave] = function()
				if not props.noButtonAnimation then
					motor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.25 }))
				end

				buttonRef.current.ImageColor3 = props.imageColor3 or Color3.fromRGB(255, 255, 255)

				setMouseIsHovering(false)
			end,
			[React.Event.MouseButton1Down] = function()
				clicked.current = true

				if not props.noButtonAnimation then
					motor:setGoal(Flipper.Instant.new(0))
				end

				buttonRef.current.ImageColor3 = props.onClickImageColor3
					or props.onHoverImageColor3
					or props.imageColor3
					or Color3.fromRGB(255, 255, 255)
			end,
			[React.Event.Activated] = function()
				clicked.current = false

				if not props.noButtonAnimation then
					motor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.4 }))
				end

				buttonRef.current.ImageColor3 = props.imageColor3 or Color3.fromRGB(255, 255, 255)
				if props.onClick then
					props.onClick()
				end

				setMouseIsHovering(false)
			end,
		},
		Utils.Table.MergeProps(props, {
			UIAspectRatioConstraint = props.aspectRatio
				and e("UIAspectRatioConstraint", { AspectRatio = props.aspectRatio }),

			TextLabel = props.text and e("TextLabel", {
				Visible = not props.showTextOnHover or mouseIsHovering,
				AnchorPoint = props.textAnchorPoint or Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = props.textPosition or UDim2.fromScale(0.5, 0.5),
				Size = props.textSize or UDim2.fromScale(0.8, 0.8),
				Font = defaultFont,
				Text = props.text,
				TextScaled = true,
				TextColor3 = props.textColor3 or Color3.fromRGB(255, 255, 255),
				TextStrokeColor3 = props.textStrokeColor3 or 0,
				TextStrokeTransparency = props.textStrokeTransparency or 0,
			}),
		})
	)
end

return ImageButton

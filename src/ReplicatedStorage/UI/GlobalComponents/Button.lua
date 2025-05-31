-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))

local Utils = require(Source:WaitForChild("Utils"))
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))
local Contexts = require(UI:WaitForChild("Contexts"))
-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables
export type ButtonProps = {
	size: UDim2,
	text: string,
	visible: boolean?,
	smallRatio: number?,
	largeRatio: number?,
	onClick: (() -> ())?,
	onHold: (() -> ())?,
	onHoldEnd: (() -> ())?,
	anchorPoint: Vector2?,
	position: UDim2?,
	backgroundColor3: Color3?,
	backgroundTransparency: number?,
	borderSizePixel: number?,
	layoutOrder: number?,
	font: Enum.Font?,
	textAnchorPoint: Vector2?,
	textPosition: UDim2?,
	textSize: number?,
	textColor3: Color3?,
	textStrokeTransparency: number?,
	textStrokeColor3: Color3?,
	image: string?,
	imageAnchorPoint: Vector2?,
	imagePosition: UDim2?,
	imageSize: UDim2?,
	imageVisible: boolean?,
	imageColor3: Color3?,
	imageTransparency: number?,
	imageUIAspectRatio: number?,
	uiCorner: UICorner?,
	cornerRadius: UDim?,
	stroke: UIStroke?,
	strokeThickness: number?,
	strokeColor: Color3?,
	colorSequence: ColorSequence?,
	gradientColors: ColorSequence?,
	aspectRatio: number?,
	shineAnimation: boolean?,
	shineAnimationVelocity: number?,
	shineAnimationColor3: Color3?,
	buttonAnimation: boolean?,
	onHoverColorChange: Color3?,
	zIndex: number?,
	clipsDescendants: boolean?,
	richText: boolean?,
}
-- Selectors

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function Button(props: ButtonProps)
	-- Requires: size and text absolutely and visible if using shineAnimation
	--[[Optional:
        smallRatio, largeRatio, -- when hovering/clicking
		onClick, onHold, onHoldEnd
        anchorPoint, position, size, backgroundColor3, backgroundTransparency, borderSizePixel, visible, layoutOrder
		text, font, textAnchorPoint, textPosition, textSize, textColor3, textStrokeTransparency, textStrokeColor3
		image, imageAnchorPoint, imagePosition, imageSize, imageVisible, imageColor3, imageTransparency, imageUIAspectRatio,
        uiCorner, cornerRadius,
        stroke, strokeThickness, strokeColor,
        colorSequence, gradientColors
        aspectRatio,
		shineAnimation, shineAnimationVelocity, shineAnimationColor3
		buttonAnimation
		onHoverColorChange
		zIndex
		clipsDescendants
		richText
	]]
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local theme = React.useContext(Contexts.Theme)
	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------
	local motor, motorBinding = React.useMemo(function()
		return UIUtils.Flipper.CreateMotor(0.5)
	end, {})

	local shineAnimationMotorConfigs = React.useMemo(function()
		if props.shineAnimation then
			return UIUtils.Flipper.CreateLoopingMotor(props.shineAnimationVelocity or 0.8)
		end
	end, { props.shineAnimation })

	-- REFS/STATES --------------------------------------------------------------------------------------------------------------------
	local buttonRef = React.useRef()
	local clicked = React.useRef(false)
	local isHolding = React.useRef(false)

	-- EFFECTS/BINDINGS ---------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if buttonRef.current then
			CollectionService:AddTag(buttonRef.current, "Button")
		end

		return function()
			-- Cleanup tag from button
			if buttonRef.current then
				CollectionService:RemoveTag(buttonRef.current, "Button")
			end

			-- Cleanup for motors
			if motor then
				motor:destroy()
			end

			if shineAnimationMotorConfigs then
				shineAnimationMotorConfigs:Destroy()
			end
		end
	end, {})

	-- Update shineAnimationMotorConfigs
	React.useLayoutEffect(function()
		if not props.shineAnimation and shineAnimationMotorConfigs then
			shineAnimationMotorConfigs:Destroy()
		elseif props.shineAnimation and shineAnimationMotorConfigs then
			-- Update velocity
			if shineAnimationMotorConfigs.velocity ~= props.shineAnimationVelocity then
				shineAnimationMotorConfigs:UpdateVelocity(props.shineAnimationVelocity)
			end

			-- Update active state
			if (props.visible or props.visible == nil) and not shineAnimationMotorConfigs.active then
				shineAnimationMotorConfigs:Start(true)
			elseif props.visible == false and shineAnimationMotorConfigs.active then
				shineAnimationMotorConfigs:Start(false)
			end
		end
	end, { props.shineAnimation, props.shineAnimationVelocity, props.visible })
	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e(
		"TextButton",
		{
			AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
			Position = props.position or UDim2.fromScale(0.5, 0.5),
			Size = (props.buttonAnimation ~= nil and not props.buttonAnimation) and props.size
				or motorBinding:map(function(value)
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
			BackgroundColor3 = props.backgroundColor3 or Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = props.backgroundTransparency or 0,
			BorderSizePixel = props.borderSizePixel or 0,
			Text = "",
			LayoutOrder = props.layoutOrder or 1,
			ZIndex = props.zIndex or 1,
			ClipsDescendants = props.clipsDescendants or props.clipsDescendants == nil,
			ref = buttonRef,
			[React.Event.MouseEnter] = function()
				if props.buttonAnimation == nil or props.buttonAnimation then
					motor:setGoal(Flipper.Linear.new(1, { velocity = 1 / 0.25 }))
				end
			end,
			[React.Event.MouseLeave] = function()
				if props.buttonAnimation == nil or props.buttonAnimation then
					motor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.25 }))
				end

				if isHolding.current then
					isHolding.current = false

					if props.onHoldEnd then
						props.onHoldEnd()
					end
				end
			end,
			[React.Event.MouseButton1Down] = function()
				isHolding.current = true

				if props.buttonAnimation == nil or props.buttonAnimation then
					clicked.current = true
					motor:setGoal(Flipper.Instant.new(0))
				end

				if props.onHold then
					props.onHold()
				end
			end,
			[React.Event.Activated] = function()
				if props.buttonAnimation == nil or props.buttonAnimation then
					clicked.current = false
					motor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.4 }))
				end

				if props.onClick then
					props.onClick()
				end

				if props.onHoldEnd then
					props.onHoldEnd()
				end
			end,
		},
		Utils.Table.MergeProps(props, {
			UICorner = (props.cornerRadius or (props.uiCorner == nil) or props.uiCorner)
				and e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
			TextLabel = props.text and e("TextLabel", {
				TextColor3 = props.textColor3 or Color3.fromRGB(255, 255, 255),
				AnchorPoint = props.textAnchorPoint or Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = props.textPosition or UDim2.fromScale(0.5, 0.5),
				Size = props.textSize or UDim2.fromScale(0.8, 0.8),
				Font = props.font
					or (type(props.text) == "string" and select(2, string.gsub(props.text, "%d", "")) >= (string.len(
						props.text
					) / 2)) and theme.defaultFont
					or theme.secondaryFont,
				TextScaled = true,
				TextStrokeColor3 = props.textStrokeColor3 or Color3.fromRGB(0, 0, 0),
				TextStrokeTransparency = props.textStrokeTransparency or 0.8,
				Text = props.text or "",
				RichText = props.richText or false,
				ZIndex = 2,
			}),
			ImageLabel = props.image and e("ImageLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = props.imageAnchorPoint or Vector2.new(0.5, 0.5),
				Position = props.imagePosition or UDim2.fromScale(0.5, 0.5),
				Size = props.imageSize or UDim2.fromScale(1, 1),
				Image = props.image or "rbxassetid://9128622454",
				ImageColor3 = props.imageColor3 and props.imageColor3 or Color3.fromRGB(255, 255, 255),
				ImageTransparency = props.imageTransparency or 0,
				ScaleType = Enum.ScaleType.Fit,
				Visible = props.imageVisible or (props.imageVisible == nil),
			}, {
				UIAspectRatioConstraint = props.imageUIAspectRatio and e("UIAspectRatioConstraint", {
					AspectRatio = props.imageUIAspectRatio,
				}),
			}),
			UIStroke = (props.stroke or props.strokeColor) and e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				LineJoinMode = Enum.LineJoinMode.Round,
				Color = props.strokeColor or Color3.fromRGB(255, 255, 255),
				Thickness = (props.strokeThickness or 1.5) * (theme.totalScreenSize >= 1300 and 1 or 0.5),
			}),
			UIGradient = e("UIGradient", {
				Color = props.colorSequence and props.colorSequence or Utils.Color.ColorSequence(
					props.gradientColors or { Color3.fromRGB(50, 195, 100), Color3.fromRGB(50, 150, 100) }
				),
				Rotation = 90,
			}),
			UIAspectRatioConstraint = props.aspectRatio and e("UIAspectRatioConstraint", {
				AspectRatio = props.aspectRatio,
			}),
			FrameShine = props.shineAnimation and e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 0,
				Visible = props.shineAnimation or false,
			}, {
				UICorner = e("UICorner", { CornerRadius = props.cornerRadius or UDim.new(0.1, 0) }),
				UIGradient = e("UIGradient", {
					Color = Utils.Color.ColorSequence({
						props.shineAnimationColor3 or Color3.fromRGB(235, 235, 235),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.3, 1),
						NumberSequenceKeypoint.new(0.5, 0.7),
						NumberSequenceKeypoint.new(0.7, 1),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Offset = shineAnimationMotorConfigs.binding:map(function(value)
						return Vector2.new(Utils.Math.Lerp(-0.6, 0.6, value), 0)
					end),
				}),
			}),
		})
	)
end

return Button

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
-- local Flipper = require(Packages:WaitForChild("Flipper"))
-- local Utils = require(ReplicatedModulescripts:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))
-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents
local Button = require(GlobalComponents:WaitForChild("Button"))

-- LocalComponents

-- Configs
local CONTROLLER_DEADZONE = 0.15
-- Variables
local e = React.createElement
-- Tables
local Slider = React.Component:extend("Slider")
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--[[mapStateToProps, which accepts the store's state as the first argument, as well as the props passed to the component.
mapStateToProps is run whenever the Rodux store updates, as well as whenever the props passed to your component are updated.]]
local function MapStateToProps(state, props)
	return {
		totalScreenSize = state.game.totalScreenSize,
	}
end

--[[mapDispatchToProps, which accepts a function that dispatches actions to your store. It works just like Store:dispatch in Rodux!
mapDispatchToProps is only run once per component instance.]]
local function MapDispatchToProps(dispatch)
	return {
		DispatchAction = function(action)
			dispatch(action)
		end,
	}
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--[[init is called exactly once when a new instance of a component is created. It can be used to set up the initial state, as well as any non-render related values directly on the component.]]
function Slider:init()
	self:setState({
		isUpdating = false,
	})
	self.buttonRef = React.useRef()
	self.barRef = React.useRef()
end

--[[render describes what a component should display at the current instant in time.]]
function Slider:render()
	-- needs: currentNumber, minNumber, maxNumber, onUpdate, onRelease, onClick
	-- can take: anchorPoint, position, size, increment, minValueChange, pointDecimalText, sliderGradientColor1, backgroundColor, buttonGradientColors
	local theme = React.useContext(Contexts.Theme)

	return e("Frame", {
		AnchorPoint = self.props.anchorPoint or Vector2.new(0.5, 0.5),
		Position = self.props.position or UDim2.fromScale(0.5, 0.5),
		Size = self.props.size or UDim2.fromScale(0.35, 0.1),
		BackgroundTransparency = 1,
	}, {
		TextButtonBackground = e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.65, 0.5),
			Visible = true,
			BackgroundTransparency = 1,
			Text = "",
			[React.Ref] = self.ref,

			[React.Event.Activated] = function()
				if self.props.onClick then
					self.props.onClick()
				end
			end,

			[React.Event.InputBegan] = function(rbx, input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					self:setState({
						isUpdating = true,
					})
					self:UpdatePosition(input, true)
				end
			end,

			[React.Event.InputEnded] = function(rbx, input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					self:setState({
						isUpdating = false,
					})
					if self.onRelease then
						self.onRelease()
					end
				end
			end,

			[React.Event.SelectionGained] = function(rbx, input)
				self:setState({
					isUpdating = true,
				})
			end,

			[React.Event.SelectionLost] = function(rbx, input)
				self:setState({
					isUpdating = false,
				})
			end,

			[React.Event.InputChanged] = function(rbx, input)
				self:UpdatePosition(input)
			end,
		}, {
			UICorner = e("UICorner", { CornerRadius = UDim.new(0.1, 0) }),
		}),

		SliderFrame = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.6, 1),
			[React.Ref] = self.barRef,
		}, {
			ImageLabel = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale((self.props.currentNumber or 0) / (self.props.maxNumber or 100), 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
				Image = "rbxassetid://10487325925",
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 3,
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint", { AspectRatio = 1 }),
				UICorner = e("UICorner", { CornerRadius = UDim.new(1, 0) }),
				TextLabel = e("TextLabel", {
					Visible = self.state.isUpdating,
					AnchorPoint = Vector2.new(0, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0, -0.65),
					Size = UDim2.fromScale(1, 1),
					Font = theme.defaultFont,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0,
					Text = self.props.currentNumber and (self.props.pointDecimalText and Utils.Math.Round(
						self.props.currentNumber,
						self.props.pointDecimalText
					) or self.props.currentNumber) or 0,
					TextScaled = true,
				}),
			}),

			FrameLeft = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 0.5),
				ZIndex = 2,
			}, {
				UICorner = e("UICorner", { CornerRadius = UDim.new(1, 0) }),
				UIStroke = e("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(255, 255, 255),
					LineJoinMode = Enum.LineJoinMode.Round,
					Thickness = self.props.totalScreenSize >= 1300 and 1.5 or 1,
				}),
				UIGradient = e("UIGradient", {
					Color = self.props.sliderGradientColor1 or Utils.Color.colorSequences["green"],
					Transparency = Utils.NumberSequence.CooldownSequence(
						self.props.currentNumber / self.props.maxNumber or 100,
						0
					),
				}),
			}),

			FrameRight = e("Frame", {
				BackgroundColor3 = self.props.backgroundColor or Color3.fromRGB(0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 0.5),
				ZIndex = 1,
			}, {
				UICorner = e("UICorner", { CornerRadius = UDim.new(1, 0) }),
				UIStroke = e("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(255, 255, 255),
					LineJoinMode = Enum.LineJoinMode.Round,
					Thickness = self.props.totalScreenSize >= 1300 and 1.5 or 1,
				}),
			}),
		}),

		TextButtonMinus = e(Button, {
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.075, 0.5),
			size = UDim2.fromScale(0.15, 1),
			smallRatio = 0.95,
			largeRatio = 1.05,
			text = "<",
			font = Enum.Font.FredokaOne,
			aspectRatio = 1,
			cornerRadius = UDim.new(1, 0),
			gradientColors = self.props.buttonGradientColors or Utils.Color.gradientColors["green"],
			zIndex = 2,
			onClick = function()
				self:Increase(false)
			end,
		}),

		TextButtonPlus = e(Button, {
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.925, 0.5),
			size = UDim2.fromScale(0.15, 1),
			smallRatio = 0.95,
			largeRatio = 1.05,
			text = ">",
			font = Enum.Font.FredokaOne,
			aspectRatio = 1,
			cornerRadius = UDim.new(1, 0),
			gradientColors = self.props.buttonGradientColors or Utils.Color.gradientColors["green"],
			zIndex = 2,
			onClick = function()
				self:Increase(true)
			end,
		}),
	})
end

--[[didMount is fired after the component finishes its initial render. At this point, all associated Roblox Instances have been created, and all components have finished mounting.
didMount is a good place to start initial network communications, attach events to services, or modify the Roblox Instance hierarchy.]]
function Slider:didMount()
	local button = self.buttonRef:getValue()
	if button then
		CollectionService:AddTag(button, "Button")
	end
end

--[[shouldUpdate is fired before render. It returns a bool value to determine if the component should render. shouldUpdate provides a way to override Roact's rerendering heuristics.
By default, components are re-rendered any time a parent component updates, or when state is updated via setState.]]
function Slider:shouldUpdate() --> bool
	return true
end

--[[willUpdate is fired after an update is started but before a component's state and props are updated. Variables given by function: nextProps, nextState]]
function Slider:willUpdate() end

--[[didUpdate is fired after at the end of an update. At this point, Roact has updated the properties of any Roblox Instances and the component instance's props and state are up to date. Variables given by function: previousProps, previousState
didUpdate is a good place to send network requests or dispatch Rodux actions, but make sure to compare self.props and self.state with previousProps and previousState to avoid triggering too many updates.]]
function Slider:didUpdate() end

--[[willUnmount is fired right before Roact begins unmounting a component instance's children.
willUnmount acts like a component's destructor, and is a good place to disconnect any manually-connected events.]]
function Slider:willUnmount() end

-- COMPONENT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function Slider:Increase(state)
	local increment = self.props.increment or 1

	if self.props.onUpdate and type(self.props.currentNumber) == "number" then
		if state then
			if self.props.maxNumber and self.props.currentNumber + increment > self.props.maxNumber then
				self.props.onUpdate(self.props.maxNumber)
			else
				self.props.onUpdate(self.props.currentNumber + increment)
			end
		else
			if self.props.minNumber and self.props.currentNumber - increment < self.props.minNumber then
				self.props.onUpdate(self.props.minNumber)
			else
				self.props.onUpdate(self.props.currentNumber - increment)
			end
		end
	end

	if self.onRelease then
		self.onRelease()
	end
end

function Slider:UpdatePosition(input, ignoreIsUpdating)
	if (not self.state.isUpdating or not self.props.onUpdate) and not ignoreIsUpdating then
		return
	end

	local percent
	local bar = self.barRef:getValue()

	if bar then
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			local movement = input.Position.X
			if math.abs(movement) > CONTROLLER_DEADZONE then
				percent = ((self.props.currentNumber or 0) / (self.props.maxNumber or 100))
					+ (movement > 0 and 0.01 or -0.01)
			end
		elseif
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			local startPosition, endPosition = bar.AbsolutePosition, bar.AbsolutePosition + bar.AbsoluteSize
			local difference = input.Position.X - startPosition.X
			percent = difference / (endPosition.X - startPosition.X)
		end

		if percent then
			percent = math.clamp(percent, 0, 1)
			local newNumber = math.round((self.props.maxNumber or 100) * percent)

			if newNumber ~= self.props.currentNumber then
				if
					(type(self.props.minValueChange) == "number" and (newNumber % self.props.minValueChange) == 0)
					or (type(self.props.minValueChange) ~= "number")
				then
					self.props.onUpdate(newNumber)
				end
			end
		end
	end
end

-- return Slider
return ReactRedux.connect(MapStateToProps, MapDispatchToProps)(Slider)

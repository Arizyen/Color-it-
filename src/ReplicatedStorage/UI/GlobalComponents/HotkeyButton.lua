-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Configs = Source:WaitForChild("Configs")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local ReplicatedGameModules = Source:WaitForChild("GameModules")
local BaseControllers = Source:WaitForChild("BaseControllers")
local GameControllers = Source:WaitForChild("GameControllers")

local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local BaseComponents = UI:WaitForChild("BaseComponents")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))
local Utils = require(Source:WaitForChild("Utils"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type props = {
	active: boolean,
	keyCodes: { Enum.KeyCode },
	onClick: () -> (),
	Size: UDim2,
	customTag: string?,
	onHold: () -> ()?,
	onHoldEnd: () -> ()?,
	smallRatio: number?,
	largeRatio: number?,
}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function HotkeyButton(props: props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------
	local buttonRef = React.useRef()
	local clicked = React.useRef(false)
	local isHolding = React.useRef(false)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local motor, motorBinding = React.useMemo(function()
		return UIUtils.Flipper.CreateMotor(0.5)
	end, {})

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Add tag to button and cleanup
	React.useEffect(function()
		if buttonRef.current then
			CollectionService:AddTag(buttonRef.current, props.customTag or "Hotkey")
		end

		return function()
			-- Cleanup tag from button
			if buttonRef.current then
				CollectionService:RemoveTag(buttonRef.current, props.customTag or "Hotkey")
			end
		end
	end, { props.customTag })

	-- Cleanup for motor
	React.useEffect(function()
		return function()
			motor:destroy()
		end
	end, {})

	-- Input connections
	React.useEffect(function()
		if not props.active or not props.keyCodes then
			return
		end

		local inputBeganConnection
		inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if table.find(props.keyCodes, input.KeyCode) then
				if props.buttonAnimation == nil or props.buttonAnimation then
					Utils.Sound.PlaySound(Utils.Sound.Infos.MouseButton1Down)
					clicked.current = true
					motor:setGoal(Flipper.Instant.new(0))
				end
			end
		end)

		local inputEndedConnection
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed and not clicked.current then
				return
			end

			if table.find(props.keyCodes, input.KeyCode) then
				if props.buttonAnimation == nil or props.buttonAnimation then
					clicked.current = false
					motor:setGoal(Flipper.Linear.new(0.5, { velocity = 1 / 0.4 }))
				end

				if props.onClick then
					props.onClick() -- Add sound to onClick if needed
				end
			end
		end)

		return function()
			if inputBeganConnection then
				inputBeganConnection:Disconnect()
			end
			if inputEndedConnection then
				inputEndedConnection:Disconnect()
			end
		end
	end, { props.active, props.onClick, motor, props.keyCodes })

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"TextButton",
		Utils.Table.MergePropsOverwrite(props, {
			ref = buttonRef,
			Size = (props.buttonAnimation ~= nil and not props.buttonAnimation) and props.Size
				or motorBinding:map(function(value)
					if value > 0.5 then
						return props.Size:Lerp(
							UDim2.fromScale(
								props.Size.X.Scale * (props.largeRatio or 1.075),
								props.Size.Y.Scale * (props.largeRatio or 1.075)
							),
							TweenService:GetValue((value / 0.5) - 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
						)
					elseif value < 0.5 then
						if clicked.current then
							return UDim2.fromScale(
								props.Size.X.Scale * (props.smallRatio or 0.925),
								props.Size.Y.Scale * (props.smallRatio or 0.925)
							):Lerp(
								props.Size,
								TweenService:GetValue((value / 0.5), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
							)
						else
							return UDim2.fromScale(
								props.Size.X.Scale * (props.smallRatio or 0.925),
								props.Size.Y.Scale * (props.smallRatio or 0.925)
							):Lerp(
								props.Size,
								TweenService:GetValue((value / 0.5), Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
							)
						end
					else
						return props.Size
					end
				end),
			[React.Event.MouseEnter] = function()
				if not props.active then
					return
				end

				if props.buttonAnimation == nil or props.buttonAnimation then
					motor:setGoal(Flipper.Linear.new(1, { velocity = 1 / 0.25 }))
				end
			end,
			[React.Event.MouseLeave] = function()
				if not props.active then
					return
				end

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
				if not props.active then
					return
				end

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
				if not props.active then
					return
				end

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
		}),
		props.children
	)
end

return HotkeyButton

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")

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
local function AlertIcon(props)
	-- Requires: active, windowName
	-- Optional:

	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local alerts = ReactRedux.useSelector(function(state)
		return state.alerts
	end)

	-- MEMOIZE -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES -----------------------------------------------------------------------------------------------------------------------------------
	local motorConfigs = React.useRef(UIUtils.Flipper.CreateLoopingMotor(1.75))
	local isVisible, setVisible = React.useBinding(false)

	-- EFFECTS/BINDINGS -----------------------------------------------------------------------------------------------------------------------------------
	-- Update visibility and motor
	React.useEffect(function()
		local hasWindowAlert = false

		if type(props.windowName) == "string" then
			if alerts.windowAlerts[props.windowName] then
				hasWindowAlert = true
			end
		elseif type(props.windowName) == "table" then
			for _, eachWindowName in pairs(props.windowName) do
				if alerts.windowAlerts[eachWindowName] then
					hasWindowAlert = true
					break
				end
			end
		end

		-- Update visibility
		if hasWindowAlert then
			if not isVisible:getValue() then
				setVisible(true)
			end
		else
			if isVisible:getValue() then
				setVisible(false)
			end
		end

		-- Update motor
		if props.active and hasWindowAlert and not motorConfigs.current.active then
			motorConfigs.current:Start(true)
		elseif not props.active or not hasWindowAlert and motorConfigs.current.active then
			motorConfigs.current:Start(false)
		end
	end, { alerts.windowAlerts, props.windowName, props.active })

	-- Unmount connection
	React.useEffect(function()
		-- Return a cleanup function
		return function()
			motorConfigs.current:Destroy()
		end
	end, {})

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e(
		"ImageLabel",
		Utils.Table.MergeProps(props, {
			Visible = isVisible:map(function(value)
				return value
			end),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.9, 0.25),
			Size = UDim2.fromScale(0.75, 0.75),
			BackgroundTransparency = 1,
			Image = "rbxassetid://15071192710",
			ImageColor3 = Color3.fromRGB(255, 0, 0),
			-- ImageColor3 = self.motorConfigs.binding:map(function(value)
			-- 	return Color3.fromRGB(255, 70, 0):Lerp(
			-- 		Color3.fromRGB(255, 0, 0),
			-- 		TweenService:GetValue(value, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			-- 	)
			-- end),
			Rotation = motorConfigs.current.binding:map(function(value)
				return -10 + (value * 20)
			end),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 3,
		})
	)
end

return AlertIcon

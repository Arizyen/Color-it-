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

local Utils = require(Source:WaitForChild("Utils"))
local UIUtils = require(Source:WaitForChild("UIUtils"))

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
local function AnimatedUIGradient(props)
	-- Requires: colorSequenceName or colorSequence, active, animateRotation
	-- Optional:animationSpeed (1 the fastest), offsetSpeed, rotation, offset, enabled, transparency, animateOffsetX, animateOffsetY

	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOIZE -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES -----------------------------------------------------------------------------------------------------------------------------------
	local continuousMotorConfigs = React.useRef(UIUtils.Flipper.CreateLoopingMotor())

	-- EFFECTS/BINDINGS -----------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if continuousMotorConfigs.current.active ~= (props.active and (props.enabled == nil or props.enabled)) then
			continuousMotorConfigs.current:Start(props.active and (props.enabled == nil or props.enabled))
		end
	end, { props.active, props.enabled })

	-- Unmount effect
	React.useEffect(function()
		return function()
			continuousMotorConfigs.current:Destroy()
		end
	end, {})

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("UIGradient", {
		Color = props.colorSequenceName and Utils.Colors.colorSequences[props.colorSequenceName]
			or props.colorSequence
			or continuousMotorConfigs.current.binding:map(function()
				local alpha = (os.clock() % (props.animationSpeed or 1)) / (props.animationSpeed or 1) -- Divide by the total time to get a value between 0 and 1
				local colors = {}
				local z

				for i = 0, 6 do
					if alpha - (i / 6) < 0 then
						z = Color3.fromHSV((alpha - (i / 6)) + 1, 1, 1)
					else
						z = Color3.fromHSV(alpha - (i / 6), 1, 1) -- Subtract the current index divided by the total range to get a value between 0 and 1
					end

					local d = ColorSequenceKeypoint.new(i / 6, z)
					table.insert(colors, d)
				end

				return ColorSequence.new(colors)
			end),
		Enabled = props.enabled == nil or props.enabled,
		Offset = props.offset
			or (props.animateOffsetX or props.animateOffsetY)
				and continuousMotorConfigs.current.binding:map(function()
					local alpha = (os.clock() % (props.offsetSpeed or props.animationSpeed or 1))
						/ (props.offsetSpeed or props.animationSpeed or 1) -- Divide by the total time to get a value between 0 and 1
					local x = 0
					local y = 0

					if props.animateOffsetX then
						x = math.sin(alpha * math.pi * 2) * 0.2 -- Multiply by 2pi to get a value between 0 and 1
					end

					if props.animateOffsetY then
						y = math.cos(alpha * math.pi * 2) * 0.2
					end

					return Vector2.new(x, y)
				end)
			or Vector2.new(0, 0),
		Rotation = props.rotation or not props.animateRotation and 0 or continuousMotorConfigs.current.binding:map(
			function()
				return (os.clock() % (props.animationSpeed or 1)) / (props.animationSpeed or 1) * 360
			end
		),
		Transparency = props.transparency
			or NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) }),
	})
end

return AnimatedUIGradient

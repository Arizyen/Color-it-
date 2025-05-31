local FlipperUtil = {}
FlipperUtil.__index = function(instance, key)
	local originalMethod = FlipperUtil[key]

	if type(originalMethod) == "function" then
		return function(_, ...)
			if instance.destroyed then
				return
			end

			return originalMethod(instance, ...)
		end
	end

	return originalMethod
end

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Flipper = require(Packages:WaitForChild("Flipper"))
local React = require(Packages:WaitForChild("React"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables

--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
function FlipperUtil.new(initConfigs)
	-- can take: onStart, onEnd
	local self = setmetatable(initConfigs, FlipperUtil)
	self.destroyed = false

	return self
end

function FlipperUtil:UpdateConfigs(valueTable)
	if valueTable and type(valueTable) == "table" then
		Utils.Table.Merge(self, valueTable)
	end
end

function FlipperUtil:Destroy()
	self.destroyed = true
	if self.motor then
		self.motor:stop()
	end
	self.motor = nil
end

function FlipperUtil:Start(state)
	if (self.active ~= state) or (not state and self.motor:getValue() ~= self.startValue) then
		self.active = state
		if state then
			if self.motor and self.startValue and self.endValue then
				self:OnStart()

				if self.motor:getValue() ~= self.startValue then
					self.restarting = true
					self.motor:setGoal(Flipper.Instant.new(self.startValue))
				else
					self.motor:setGoal(Flipper.Linear.new(self.endValue, { velocity = self.velocity }))
				end
			end
		else
			if self.motor and self.startValue and self.endValue then
				if self.resetType == "instant" then
					self.motor:setGoal(Flipper.Instant.new(self.startValue))
				else
					self.motor:setGoal(Flipper.Linear.new(self.startValue, { velocity = self.velocity }))
				end
			end
		end
	end
end

function FlipperUtil:Restart(ignoreIsActive)
	if not ignoreIsActive and not self.active then
		return
	end

	if self.motor and self.startValue and self.endValue then
		-- Set it instantly back to start value and it'll reboot if restarting
		self.restarting = true
		self.active = true
		self:OnStart()

		if self.motor:getValue() == self.startValue then
			self.restarting = false
			self.motor:setGoal(Flipper.Linear.new(self.endValue, { velocity = self.velocity }))
		else
			self.motor:setGoal(Flipper.Instant.new(self.startValue))
		end
	end
end

function FlipperUtil:SetGoal(value, instant)
	self.active = true
	if self.motor and self.motor:getValue() ~= value then
		if instant then
			self:OnStart()
			self.motor:setGoal(Flipper.Instant.new(value))
		else
			self:OnStart()
			self.motor:setGoal(Flipper.Linear.new(value, { velocity = self.velocity }))
		end
	end
end

function FlipperUtil:UpdateVelocity(velocity)
	if self.motor and velocity and self.velocity ~= velocity then
		self.velocity = velocity

		if self.active then
			self.motor:setGoal(Flipper.Linear.new(self.motor:getValue(), { velocity = self.velocity }))
		end
	end
end

function FlipperUtil:GetValue()
	if self.motor then
		return self.motor:getValue()
	else
		warn("Flipper util GetValue: motor is nil")
		return 0
	end
end

-- EVENTS ----------------------------------------------------------------------------------------------------
function FlipperUtil:OnEnd()
	if type(self.onEnd) == "function" then
		self.onEnd()
	end

	self.hasReset = true
end

function FlipperUtil:OnReset()
	if not self.hasReset then
		return
	end

	self.hasReset = false
	if type(self.onReset) == "function" then
		self.onReset()
	end
end

function FlipperUtil:OnStart()
	if type(self.onStart) == "function" then
		self.onStart()
	end
end

function FlipperUtil:OnStep(value: number)
	if self.active and type(self.onStep) == "function" then
		self.onStep(value)
	end
end
-- FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function FlipperUtil.CreateMotor(startValue)
	startValue = startValue or 0

	local motor = Flipper.SingleMotor.new(startValue)
	local binding, setBindingValue = React.createBinding(motor:getValue())
	motor:onStep(setBindingValue)

	return motor, binding
end

-- Creates motor with motorConfig functions
-- props: onStart, onEnd
function FlipperUtil.CreateSimpleMotor(velocity, startValue, endValue, props)
	velocity = velocity or 1
	startValue = startValue or 0
	endValue = endValue or 1

	assert(startValue ~= endValue, "Flipper util: startValue cannot be the same as endValue")

	local motor = Flipper.SingleMotor.new(startValue)
	local binding, setBinding = React.createBinding(motor:getValue())

	local motorConfig = FlipperUtil.new(Utils.Table.Merge({
		motor = motor,
		binding = binding,
		velocity = velocity or 1,
		startValue = startValue,
		endValue = endValue,
		resetType = "instant",
		active = false,
		reachedEnd = false,
		hasReset = false,
		restarting = false,
		motorType = "simple",
		onStep = nil,
		onEnd = nil,
		onReset = nil,
		onStart = nil,
	}, props))

	motor:onStep(function(value)
		setBinding(value)
		motorConfig:OnStep(value)

		if motorConfig.startValue > motorConfig.endValue then
			if value <= motorConfig.endValue then
				motorConfig.active = false
				motorConfig.reachedEnd = true
			end
		else
			if value >= motorConfig.endValue then
				motorConfig.active = false
				motorConfig.reachedEnd = true
			end
		end

		if motorConfig.reachedEnd then
			motorConfig.reachedEnd = false
			motorConfig.active = motorConfig.restarting or false
			motorConfig:OnEnd()
		end

		if value == motorConfig.startValue then
			motorConfig:OnReset()

			if motorConfig.restarting then
				motorConfig.restarting = false
				motorConfig.motor:setGoal(Flipper.Linear.new(motorConfig.endValue, { velocity = motorConfig.velocity }))
			end
		end
	end)

	return motorConfig, motor, binding
end

--> Goes from startValue to endValue then returns to startValue (not instantly). No looping. velocity: the time it takes (lower than one being slower).
function FlipperUtil.CreateBounceMotor(velocity, startValue, endValue, props)
	velocity = velocity or 1
	startValue = startValue or 0
	endValue = endValue or 1

	assert(startValue ~= endValue, "Flipper util: startValue cannot be the same as endValue")

	local motor = Flipper.SingleMotor.new(startValue)
	local binding, setBinding = React.createBinding(motor:getValue())

	local motorConfig = FlipperUtil.new(Utils.Table.Merge({
		motor = motor,
		binding = binding,
		velocity = velocity or 1,
		startValue = startValue,
		endValue = endValue,
		resetType = "instant",
		active = false,
		reachedEnd = false,
		hasReset = false,
		restarting = false,
		motorType = "bounce",
		onStep = nil,
		onEnd = nil,
		onReset = nil,
		onStart = nil,
	}, props))

	motor:onStep(function(value)
		setBinding(value)
		motorConfig:OnStep(value)

		if motorConfig.startValue > motorConfig.endValue then
			if value <= motorConfig.endValue then
				motorConfig.reachedEnd = true
				motor:setGoal(Flipper.Linear.new(motorConfig.startValue, { velocity = motorConfig.velocity }))
			end
		else
			if value >= motorConfig.endValue then
				motorConfig.reachedEnd = true
				motor:setGoal(Flipper.Linear.new(motorConfig.startValue, { velocity = motorConfig.velocity }))
			end
		end

		if motorConfig.reachedEnd then
			motorConfig.reachedEnd = false
			motorConfig.active = motorConfig.restarting or false

			motorConfig:OnEnd()
		end

		if value == motorConfig.startValue then
			motorConfig:OnReset()

			if motorConfig.restarting then
				motorConfig.restarting = false
				motorConfig.motor:setGoal(Flipper.Linear.new(motorConfig.endValue, { velocity = motorConfig.velocity }))
			end
		end
	end)

	return motorConfig, motor, binding
end

--> Goes from startValue to endValue then resets instantly back to startValue (does not loop)
function FlipperUtil.CreateReturningMotor(velocity, startValue, endValue, props)
	startValue = startValue or 0
	endValue = endValue or 1

	assert(startValue ~= endValue, "Flipper util: startValue cannot be the same as endValue")
	local motor = Flipper.SingleMotor.new(startValue)
	local binding, setBinding = React.createBinding(motor:getValue())

	local motorConfig = FlipperUtil.new(Utils.Table.Merge({
		motor = motor,
		binding = binding,
		velocity = velocity or 1,
		startValue = startValue,
		endValue = endValue,
		resetType = "instant",
		active = false,
		reachedEnd = false,
		hasReset = false,
		restarting = false,
		motorType = "returning",
		onStep = nil,
		onEnd = nil,
		onReset = nil,
		onStart = nil,
	}, props))

	motor:onStep(function(value)
		setBinding(value)
		motorConfig:OnStep(value)

		if motorConfig.startValue > motorConfig.endValue then
			if value <= motorConfig.endValue then
				motorConfig.reachedEnd = true
				motor:setGoal(Flipper.Instant.new(motorConfig.startValue))
			end
		else
			if value >= motorConfig.endValue then
				motorConfig.reachedEnd = true
				motor:setGoal(Flipper.Instant.new(motorConfig.startValue))
			end
		end

		if motorConfig.reachedEnd then
			motorConfig.reachedEnd = false
			motorConfig.active = motorConfig.restarting or false

			motorConfig:OnEnd()
		end

		if value == motorConfig.startValue then
			motorConfig:OnReset()

			if motorConfig.restarting then
				motorConfig.restarting = false
				motorConfig.motor:setGoal(Flipper.Linear.new(motorConfig.endValue, { velocity = motorConfig.velocity }))
			end
		end
	end)

	return motorConfig, motor, binding
end

--> Goes from startValue to endValue then returns to startValue and repeats until stopped. velocity: the time it takes (lower than one being slower).
function FlipperUtil.CreateLoopingMotor(velocity, startValue, endValue, props)
	velocity = velocity or 1
	startValue = startValue or 0
	endValue = endValue or 1

	assert(startValue ~= endValue, "Flipper util: startValue cannot be the same as endValue")

	local motor = Flipper.SingleMotor.new(startValue)
	local binding, setBinding = React.createBinding(motor:getValue())

	local motorConfig = FlipperUtil.new(Utils.Table.Merge({
		motor = motor,
		binding = binding,
		velocity = velocity or 1,
		startValue = startValue,
		endValue = endValue,
		resetType = "instant",
		active = false,
		motorType = "looping",
		onStep = nil,
		onEnd = nil,
		onReset = nil,
		onStart = nil,
	}, props))

	motor:onStep(function(value)
		setBinding(value)
		motorConfig:OnStep(value)

		if motorConfig.active then
			if value == motorConfig.endValue then
				motorConfig:OnEnd()
				motor:setGoal(Flipper.Linear.new(motorConfig.startValue, { velocity = motorConfig.velocity }))
			elseif value == motorConfig.startValue then
				motorConfig:OnReset()
				motor:setGoal(Flipper.Linear.new(motorConfig.endValue, { velocity = motorConfig.velocity }))
			end
		end
	end)

	return motorConfig, motor, binding
end

-- Goes from startValue to endValue repeatedly until stopped
function FlipperUtil.CreateContinuingMotor(velocity, startValue, endValue, props)
	startValue = startValue or 0
	endValue = endValue or 1

	assert(startValue ~= endValue, "Flipper util: startValue cannot be the same as endValue")
	local motor = Flipper.SingleMotor.new(startValue)
	local binding, setBinding = React.createBinding(motor:getValue())

	local motorConfig = FlipperUtil.new(Utils.Table.Merge({
		motor = motor,
		binding = binding,
		velocity = velocity or 1,
		startValue = startValue,
		endValue = endValue,
		resetType = "instant",
		active = false,
		motorType = "continuing",
		onStep = nil,
		onEnd = nil,
		onReset = nil,
		onStart = nil,
	}, props))

	motor:onStep(function(value)
		setBinding(value)
		motorConfig:OnStep(value)

		if motorConfig.startValue > motorConfig.endValue then
			if value <= motorConfig.endValue then
				motorConfig:OnEnd()
				motor:setGoal(Flipper.Instant.new(motorConfig.startValue))
			elseif value == motorConfig.startValue and motorConfig.active then
				motorConfig:OnReset()
				motor:setGoal(Flipper.Linear.new(motorConfig.endValue, { velocity = motorConfig.velocity }))
			end
		else
			if value >= motorConfig.endValue then
				motorConfig:OnEnd()
				motor:setGoal(Flipper.Instant.new(motorConfig.startValue))
			elseif value == motorConfig.startValue and motorConfig.active then
				motorConfig:OnReset()
				motor:setGoal(Flipper.Linear.new(motorConfig.endValue, { velocity = motorConfig.velocity }))
			end
		end
	end)

	return motorConfig, motor, binding
end

function FlipperUtil.DisconnectMotors(motorConfigs: { typeof(FlipperUtil) })
	for _, eachMotorConfig in pairs(motorConfigs) do
		if eachMotorConfig["Destroy"] then
			eachMotorConfig:Destroy()
		end
	end
end

return FlipperUtil

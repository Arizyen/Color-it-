-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

-- Folders

-- Modulescripts
local ColorUtil = require(ReplicatedStorage.Source.Utils.Color)

-- Configs
local ANIMATIONS_MIN_WAIT = 5
local ANIMATIONS_MAX_WAIT = 15

-- Variables
local randomGenerator = Random.new()

-- Tables
local animations = {}
local TextAnimator = {}
TextAnimator.__index = TextAnimator
----------------------------------------------
-- LOCAL FUNCTIONS ---------------------------
----------------------------------------------
local function CreateUIGradient(textLabel)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Parent = textLabel

	return uiGradient
end

local function ReturnNewMetatable(textLabel)
	local self = setmetatable({}, TextAnimator)
	self.TextLabel = textLabel
	self.UIGradient = textLabel:FindFirstChild("UIGradient") or CreateUIGradient(textLabel)

	self.textLabelDefaultColor = textLabel.TextColor3
	self.destroying = false
	self.destroyingConnection = self.TextLabel.Destroying:Connect(function()
		animations[self.TextLabel] = nil
		self:Destroy(true)
	end)
	self.colorIndex = 0

	self.currentTween = nil
	self.running = false
	self.startedTime = nil

	self:TweenTextLabelColor(Color3.fromRGB(255, 255, 255), 0.5)
	animations[textLabel] = self
	return self
end

local function ReturnTextLabelMetatable(textLabel)
	for textLabelKey, eachMeta in pairs(animations) do
		if not textLabelKey then
			eachMeta:Destroy()
		elseif textLabelKey == textLabel then
			return eachMeta
		end
	end

	return ReturnNewMetatable(textLabel)
end
----------------------------------------------
-- GLOBAL FUNCTIONS --------------------------
----------------------------------------------
function TextAnimator.new(textLabel, animationId, colors)
	if not textLabel or not animationId then
		return
	end

	local self = ReturnTextLabelMetatable(textLabel)
	self:Cancel()

	self:Start(animationId, nil, colors)

	return self
end

function TextAnimator.ReturnTextLabelMetatable(textLabel)
	return ReturnTextLabelMetatable(textLabel)
end

function TextAnimator:ActivateRainbowNametag(state)
	if not self or not self.TextLabel then
		return
	end

	if state == true then
		self:Start("RandomAnimate", nil)
	else
		self:Cancel()
	end
end

function TextAnimator:Cancel()
	self.running = false

	if self.currentTween and self.currentTween:IsA("TweenBase") then
		self.currentTween:Cancel()
		self.currentTween = nil
	end

	if self.animationConnection then
		self.animationConnection:Disconnect()
		self.animationConnection = nil
	end

	if self.UIGradient then
		self.UIGradient.Enabled = false
		self.TextLabel.TextColor3 = self.textLabelDefaultColor
	end
end

function TextAnimator:Destroy(textLabelDestroying)
	self:Cancel()

	self.destroying = true

	if self.destroyingConnection then
		self.destroyingConnection:Disconnect()
		self.destroyingConnection = nil
	end

	if self.TextLabel and self.TextLabel.Parent ~= nil then -- If it's already destroying, don't destroy it again (parent property locked)
		animations[self.TextLabel] = nil
		if not textLabelDestroying then
			self.TextLabel:Destroy()
		end
		self.TextLabel = nil
	end
end

function TextAnimator:Start(animationId, speed, colors)
	if not self or not self.TextLabel then
		return
	end

	self:Cancel()

	if self.UIGradient then
		self:TweenTextLabelColor(Color3.fromRGB(255, 255, 255), 0.5)
		self.UIGradient.Enabled = true
	end

	self.colors = type(colors) == "table" and colors or ColorUtil.RainbowColors(randomGenerator:NextInteger(3, 6))

	if typeof(self.colors) == "table" then
		self.UIGradient.Color = ColorUtil.ColorSequence(self.colors)
	elseif typeof(self.colors) == "ColorSequence" then
		self.UIGradient.Color = self.colors
	else
		self.UIGradient.Color = ColorUtil.ColorSequence(ColorUtil.Random())
	end

	self.running = true
	if not speed then
		speed = math.random(3, 4) - (math.random(1, 100) / 200)
	end
	self.startedTime = os.clock()
	-- Execute the animation chosen
	self[animationId](self, speed, true)
end
-- UTILITY FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function TextAnimator:TweenTextLabelColor(color, speed)
	local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	local goals = {
		TextColor3 = color,
	}
	local tween = TweenService:Create(self.TextLabel, tweenInfo, goals)
	tween:Play()
end

function TextAnimator:EnableUIGradient(state, resetTextLabelColor)
	self.UIGradient.Enabled = state
	if resetTextLabelColor then
		self.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		-- self:TweenTextLabelColor(Color3.fromRGB(255, 255, 255), 0.5)
	end
end

function TextAnimator:ReturnNextColor()
	if type(self.colors) == "table" then
		self.colorIndex = (self.colorIndex + 1) < #self.colors and self.colorIndex + 1 or 1
		if self.colorIndex > #self.colors then
			return self.colors[1]
		else
			return self.colors[self.colorIndex]
		end
	else
		warn("COLORS NOT A TABLE", "TextAnimator:ReturnNextColor")
	end
end
-- ANIMATIONS -----------------------------------------------------------------------------------------------------------------------------------
function TextAnimator.Animation1(self, speed, resetTextLabelColor)
	self:EnableUIGradient(true, resetTextLabelColor)
	local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true, 0)
	--self.UIGradient.Rotation = 0
	self.UIGradient.Offset = Vector2.new(0, 0)

	local goals = {
		Rotation = 360,
	}
	-- Create and play the tween
	-- Since TweenInfo.repeatCount is negative, it will loop indefinitely
	self.currentTween = TweenService:Create(self.UIGradient, tweenInfo, goals)
	self.currentTween:Play()
end

function TextAnimator.Animation2(self, speed, resetTextLabelColor)
	self:EnableUIGradient(true, resetTextLabelColor)
	local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true, 0)
	self.UIGradient.Rotation = 0
	self.UIGradient.Offset = Vector2.new(-1, 0)

	local goals = {
		Offset = Vector2.new(1, 0),
	}
	-- Create and play the tween
	-- Since TweenInfo.repeatCount is negative, it will loop indefinitely
	self.currentTween = TweenService:Create(self.UIGradient, tweenInfo, goals)
	self.currentTween:Play()
end

function TextAnimator.RandomFades(self, speed)
	if not self or not self.TextLabel then
		return
	end

	self:EnableUIGradient(false)

	if self.TextLabel.TextColor3 == Color3.fromRGB(255, 255, 255) then
		self.TextLabel.TextColor3 = self:ReturnNextColor()
	end

	local tweenInfo
	local goals
	local startedTime = self.startedTime

	local function StartAnimation()
		if startedTime ~= self.startedTime or not self.running then
			return
		end

		tweenInfo = TweenInfo.new(speed / 1.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
		goals = {
			TextColor3 = self:ReturnNextColor(),
		}

		self.currentTween = TweenService:Create(self.TextLabel, tweenInfo, goals)
		self.animationConnection = self.currentTween
			and self.currentTween.Completed:Connect(function()
				StartAnimation()
			end)
		self.currentTween:Play()
	end

	StartAnimation()
end

function TextAnimator.RandomAnimate(self, speed)
	if not self or not self.TextLabel or not self.running then
		warn("ANIMATION NOT ACTIVE")
		return
	end

	local tweenAnimations = {
		"Animation1",
		"Animation2",
	}
	local textColorAnimations = {
		"RandomFades",
	}

	local choice = math.random(100)

	if self and self.TextLabel and self.running == true then
		if choice >= 35 then
			self:Start(tweenAnimations[math.random(#tweenAnimations)], speed)
			local startedTime = self.startedTime
			task.delay(math.random(ANIMATIONS_MIN_WAIT, ANIMATIONS_MAX_WAIT), function()
				if self and self.running and startedTime == self.startedTime then
					self:Start("RandomAnimate", nil)
				end
			end)
		else
			self:Start(textColorAnimations[math.random(#textColorAnimations)], speed)
			local startedTime = self.startedTime
			task.delay(math.random(ANIMATIONS_MIN_WAIT, ANIMATIONS_MAX_WAIT), function()
				if self and self.running and startedTime == self.startedTime then
					self:Start("RandomAnimate", nil)
				end
			end)
		end
	end
end

return TextAnimator

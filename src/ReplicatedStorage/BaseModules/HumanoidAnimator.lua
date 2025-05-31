local HumanoidAnimator = {}
HumanoidAnimator.__index = HumanoidAnimator
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
-- local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs
local _SPEED_TRESHOLD = 0.75
local _RUN_SCALE = 16
local _IDLE_WEIGHTS = {
	{ 10 },
	{ 8, 2 },
	{ 6, 2, 2 },
	{ 4, 2, 2, 2 },
	{ 3, 2, 2, 2, 1 },
	{ 2, 2, 2, 2, 1, 1 },
}

-- Variables
local smallButNotZero = 0.001

-- Tables
local coreAnimationsType = { "walk", "idle", "jump", "fall" }
HumanoidAnimator.charactersAnimator = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateAnimation(animationId, parent)
	local animation = Instance.new("Animation")

	animationId = string.find(animationId, "rbxassetid://") and animationId
		or ("rbxassetid://" .. string.match(animationId, "%d+"))
	animation.AnimationId = animationId
	animation.Parent = parent
	return animation
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function HumanoidAnimator.new(character, animationsInfo, customStateActivation)
	if HumanoidAnimator.charactersAnimator[character] then
		HumanoidAnimator.charactersAnimator[character]:Destroy()
		-- return HumanoidAnimator.charactersAnimator[character]
	end
	-- animationsInfo (key:type value:string or table of animations)
	local self = setmetatable({}, HumanoidAnimator)
	HumanoidAnimator.charactersAnimator[character] = self

	self.character = character
	self.humanoid = self.character:WaitForChild("Humanoid")
	self.primaryPart = self.character.PrimaryPart

	Utils.Connections.Add(
		self.character,
		"characterDestroyingHumanoidAnimator",
		self.character.Destroying:Connect(function()
			self:Destroy()
		end)
	)

	Utils.Connections.Add(
		self.character,
		"characterParentChangedAnimator",
		self.character:GetPropertyChangedSignal("Parent"):Connect(function()
			if not self.character or not self.character:IsDescendantOf(game.Workspace) then
				self:Destroy()
			end
		end)
	)

	self.animator = nil
	self.animations = {}
	self.animationsInfo = animationsInfo
	self.currentCoreAnimTrack = nil
	self.currentActionAnimTrack = nil
	self.runAnimTrack = nil
	self.currentState = nil
	self.actionAnimationRunning = false

	self.currentCoreAnimInstance = nil
	self.lastAnimsInstance = {}

	self.jumpedTime = nil

	self:LoadAnimations()
	self.activated = true
	self.destroying = false

	if not customStateActivation then
		self:ActivateOnRunning(true)
		self:ActivateOnJump(true)
		self:ActivateOnFreeFall(true)
	end

	return self
end

function HumanoidAnimator:Destroy()
	if self.destroying then
		return
	end
	self.destroying = true

	HumanoidAnimator.charactersAnimator[self.character] = nil
	Utils.Connections.DisconnectKeyConnections(self.character)

	self:DestroyAnimations()
	setmetatable(self, nil)
	table.clear(self)
	self = nil
end

function HumanoidAnimator:Died()
	self.activated = false
	if self.character and self.character.Humanoid then
		for _, eachPlayingTrack in pairs(self.character.Humanoid:GetPlayingAnimationTracks()) do
			eachPlayingTrack:Stop(0.15)
			eachPlayingTrack:Destroy()
		end
	end

	self:PlayAnimation("died", 0, function()
		for _, eachChild in pairs(self.character:GetChildren()) do
			if eachChild:IsA("BasePart") then
				eachChild.Anchored = true
			end
		end

		self:DestroyAnimations()

		setmetatable(self, nil)
		table.clear(self)
		self = nil
	end)
end
-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
function HumanoidAnimator:ActivateOnRunning(state)
	if state then
		if self.humanoid.MoveDirection.Magnitude > 0 then
			self:OnRunning(self.primaryPart.Velocity.Magnitude)
		else
			-- initialize to idle
			self:PlayAnimation("idle", 0.1)
		end

		Utils.Connections.Add(
			self.character,
			"onRunning",
			self.character.Humanoid.Running:Connect(function(speed)
				self:OnRunning(speed)
			end)
		)
	else
		if self.activated then
			Utils.Connections.DisconnectKeyConnection(self.character, "onRunning")

			self.currentCoreAnimInstance = nil
		end
	end
end

-- function HumanoidAnimator:ActivateOnDamage(state)
-- 	if state then
-- 		Utils.Connections.Add(
-- 			self.character,
-- 			"onDamage",
-- 			self.character:GetAttributeChangedSignal("hp"):Connect(function()
-- 				if not self.attacking then
-- 					self:PlayAnimation("onDamage", 0.15)
-- 				end
-- 			end)
-- 		)
-- 	else
-- 		if self.activated then
-- 			Utils.Connections.DisconnectKeyConnection(self.character, "onDamage")
-- 		end
-- 	end
-- end

function HumanoidAnimator:ActivateOnJump(state)
	if state then
		Utils.Connections.Add(
			self.character,
			"onJumping",
			self.character.Humanoid.Jumping:Connect(function()
				self.jumpedTime = os.clock()
				self:PlayAnimation("jump", 0.1)
			end)
		)
	else
		if self.activated then
			Utils.Connections.DisconnectKeyConnection(self.character, "onJumping")
		end
	end
end

function HumanoidAnimator:ActivateOnFreeFall(state)
	if state then
		Utils.Connections.Add(
			self.character,
			"onFreeFall",
			self.character.Humanoid.FreeFalling:Connect(function()
				if self.jumpedTime and os.clock() - self.jumpedTime >= 0.31 then
					self:PlayAnimation("fall", 0.2)
				end
			end)
		)
	else
		if self.activated then
			Utils.Connections.DisconnectKeyConnection(self.character, "onFreeFall")
		end
	end
end
-- CONFIGURING ANIMATIONS -----------------------------------------------------------------------------------------------------------------------------------
function HumanoidAnimator:LoadAnimations()
	self.animator = self.humanoid:FindFirstChild("Animator")
	if not self.animator then
		self.animator = Instance.new("Animator")
		self.animator.Parent = self.humanoid
	end

	-- Create animation instances and preload them
	for animType, animIds in pairs(self.animationsInfo) do
		if type(animIds) == "table" then
			self.animations[animType] = {}
			for index, eachAnimId in ipairs(animIds) do
				self.animations[animType][index] = CreateAnimation(eachAnimId, self.humanoid)
				self.animator:LoadAnimation(self.animations[animType][index])
			end
		elseif type(animIds) == "string" then
			self.animations[animType] = CreateAnimation(animIds, self.humanoid)
			self.animator:LoadAnimation(self.animations[animType])
		end
	end
end

function HumanoidAnimator:DestroyAnimations()
	-- Stop and destroy animation tracks
	if self.character and self.humanoid then
		for _, eachPlayingTrack in pairs(self.humanoid:GetPlayingAnimationTracks()) do
			eachPlayingTrack:Stop(0.15)
			eachPlayingTrack:Destroy()
		end
	end

	-- Destroy animation instances
	for animType, animIds in pairs(self.animationsInfo) do
		if type(animIds) == "table" then
			for index, _ in ipairs(animIds) do
				if self.animations[animType] and self.animations[animType][index] then
					self.animations[animType][index]:Destroy()
				end
			end
		elseif type(animIds) == "string" then
			if self.animations[animType] then
				self.animations[animType]:Destroy()
			end
		end
	end
end
-- PLAYING ANIMATIONS -----------------------------------------------------------------------------------------------------------------------------------
function HumanoidAnimator:SwitchToAnimation(animation, animType, transitionTime)
	if not animation then
		-- print("No animation received")
		return
	elseif not self.activated then
		-- print("HumanoidAnimator not activated")
		return
	end

	self.currentCoreAnimInstance = animation
	self.currentState = animType

	if self.currentCoreAnimTrack ~= nil then
		self.currentCoreAnimTrack:Stop(transitionTime)
		self.currentCoreAnimTrack:Destroy()
		self.currentCoreAnimTrack = nil
	end

	if self.runAnimTrack ~= nil then
		self.runAnimTrack:Stop(transitionTime)
		self.runAnimTrack:Destroy()
		self.runAnimTrack = nil
	end

	-- load it to the animator; get AnimationTrack
	self.currentCoreAnimTrack = self.animator:LoadAnimation(animation)
	self.currentCoreAnimTrack.TimePosition = 0
	self.currentCoreAnimTrack.Priority = Enum.AnimationPriority.Core

	-- play the animation
	self.currentCoreAnimTrack:Play(transitionTime)

	-- check to see if we need to blend a walk/run animation
	if animType == "walk" then
		self.currentCoreAnimTrack.Looped = true

		if self.animations["run"] then
			self.runAnimTrack = self.animator:LoadAnimation(self:RollAnimation("run"))
			self.runAnimTrack.TimePosition = 0
			self.runAnimTrack.Priority = Enum.AnimationPriority.Core

			self.runAnimTrack:Play(transitionTime)

			-- set both animation looped true
			self.runAnimTrack.Looped = true
		end
	elseif animType == "idle" then
		self.currentCoreAnimTrack.Looped = false
		-- create animation ended connection for when the idle animation ends
		if self.activated then
			Utils.Connections.Add(
				self.character,
				"coreAnimationEnded",
				self.currentCoreAnimTrack.Stopped:Connect(function()
					if self.currentState == "idle" and self.activated then
						self:PlayAnimation("idle", 0.15)
					end
				end)
			)
		end
	end
end

function HumanoidAnimator:RollAnimation(animType)
	if type(self.animations[animType]) == "table" and #self.animations[animType] > 0 then
		-- print(animType, #self.animations[animType])
		if animType == "idle" then
			if self.actionAnimationRunning or not self.activated or #self.animations[animType] == 1 then
				return self.animations[animType][1]
			else
				local roll = math.random(10)
				local index = 1
				while roll > _IDLE_WEIGHTS[#self.animations[animType]][index] do
					roll = roll - _IDLE_WEIGHTS[#self.animations[animType]][index]
					index = index + 1
				end
				return self.animations[animType][index]
			end
		else
			if #self.animations[animType] > 1 then
				local randomInt
				repeat
					randomInt = math.random(#self.animations[animType])
				until self.lastAnimsInstance[animType] ~= self.animations[animType][randomInt]
				self.lastAnimsInstance[animType] = self.animations[animType][randomInt]
				return self.animations[animType][randomInt]
			else
				return self.animations[animType][1]
			end
		end
	elseif type(self.animations[animType]) == "userdata" then
		return self.animations[animType]
	else
		-- print("Anim type not found", animType)
	end
end

function HumanoidAnimator:PlayAnimation(animType, transitionTime, andThen)
	-- if not self.activated then
	-- 	return
	-- end

	local animation = self:RollAnimation(animType)

	if table.find(coreAnimationsType, animType) then
		self:SwitchToAnimation(animation, animType, transitionTime)
	elseif self.activated then
		if animType == "hit" then
			self.attacking = true
		end

		if animation then
			-- destroy past actionAnimationTrack
			if self.currentActionAnimTrack ~= nil then
				self.currentActionAnimTrack:Stop(transitionTime)
				self.currentActionAnimTrack:Destroy()
			end

			-- load it to the humanoid; get AnimationTrack
			self.currentActionAnimTrack = self.animator:LoadAnimation(animation)
			self.currentActionAnimTrack.Priority = Enum.AnimationPriority.Action

			-- play the animation
			self.currentActionAnimTrack:Play(transitionTime)
			self.actionAnimationRunning = true
			self.currentActionAnimTrack.Stopped:Connect(function()
				self.actionAnimationRunning = false

				if animType == "hit" then
					self.attacking = false
				end

				if andThen then
					andThen()
				end
			end)
		end
	end
end

function HumanoidAnimator:SetRunAnimationSpeed(speed)
	if self.animations["run"] and self.runAnimTrack then
		local normalizedWalkSpeed = 0.5 -- established empirically using `913402848` walk animation
		local normalizedRunSpeed = 1
		local runSpeed = speed * 1.25

		local walkAnimationWeight = smallButNotZero
		local runAnimationWeight = smallButNotZero
		local walkAnimationTimewarp = runSpeed / normalizedWalkSpeed
		local runAnimationTimerwarp = runSpeed / normalizedRunSpeed

		if runSpeed <= normalizedWalkSpeed then
			walkAnimationWeight = 1
		elseif runSpeed < normalizedRunSpeed then
			local fadeInRun = (runSpeed - normalizedWalkSpeed) / (normalizedRunSpeed - normalizedWalkSpeed)
			walkAnimationWeight = 1 - fadeInRun
			runAnimationWeight = fadeInRun
			walkAnimationTimewarp = 1
			runAnimationTimerwarp = 1
		else
			runAnimationWeight = 1
		end

		if self.currentCoreAnimTrack then
			self.currentCoreAnimTrack:AdjustWeight(walkAnimationWeight)
			self.currentCoreAnimTrack:AdjustSpeed(walkAnimationTimewarp)
		end

		self.runAnimTrack:AdjustWeight(runAnimationWeight)
		self.runAnimTrack:AdjustSpeed(runAnimationTimerwarp)
	else
		if self.currentCoreAnimTrack then
			self.currentCoreAnimTrack:AdjustWeight(1)
			self.currentCoreAnimTrack:AdjustSpeed(speed)
		end
	end
end
-- ON RUNNING FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function HumanoidAnimator:OnRunning(speed)
	if self.activated then
		if speed > _SPEED_TRESHOLD then
			if self.currentState ~= "walk" then
				self:PlayAnimation("walk", 0.2)
			end
			self:SetRunAnimationSpeed(speed / _RUN_SCALE)
		else
			if self.currentState ~= "idle" then
				self:PlayAnimation("idle", 0.2)
			end
		end
	end
end

return HumanoidAnimator

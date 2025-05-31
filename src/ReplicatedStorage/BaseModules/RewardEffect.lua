local RewardEffect = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local Utils = Source:WaitForChild("Utils")
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local Models = ReplicatedStorage:WaitForChild("Models")

-- Modulescripts
local Number = require(Utils:WaitForChild("Number"))

-- KnitControllers

-- Instances
local LocalPlayer = game.Players.LocalPlayer
local FrameReward = Models:WaitForChild("FrameReward")

-- Configs
local ANIMATION_SPEED = 2.5
local SPEED_VARIATION_PERCENTAGE = 10
local SIZE_START = UDim2.fromScale(0.035, 0.08)
local SIZE_END = UDim2.fromScale(0.24, 0.13)

-- Variables
local effectHeartbeatConnection = nil
local lastFactor = -1

-- Tables
local frames = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function QuadBezier(alpha, p0, p1, p2)
	return (1 - alpha) ^ 2 * p0 + 2 * (1 - alpha) * alpha * p1 + alpha ^ 2 * p2
end

local function StartEffectAnimator()
	if effectHeartbeatConnection then
		return
	end

	local count = 0
	effectHeartbeatConnection = RunService.Heartbeat:Connect(function()
		count = 0

		for eachFrame, eachFrameInfo in pairs(frames) do
			count += 1

			local alpha = (os.clock() - eachFrameInfo["spawnTime"]) / eachFrameInfo["animationSpeed"]
			if alpha >= 1 then
				frames[eachFrame] = nil
				eachFrame:Destroy()
				eachFrame = nil
			else
				local lerpX = QuadBezier(
					alpha,
					eachFrameInfo["point1"].X.Scale,
					eachFrameInfo["point2"].X.Scale,
					eachFrameInfo["point3"].X.Scale
				)
				local lerpY = QuadBezier(
					alpha,
					eachFrameInfo["point1"].Y.Scale,
					eachFrameInfo["point2"].Y.Scale,
					eachFrameInfo["point3"].Y.Scale
				)
				eachFrame.Position = UDim2.fromScale(lerpX, lerpY)

				local lerpXSize = QuadBezier(alpha, SIZE_START.X.Scale, SIZE_END.Y.Scale, SIZE_START.X.Scale)
				eachFrame.Size = UDim2.fromScale(lerpXSize, eachFrame.Size.Y.Scale)
			end
		end

		if count == 0 then
			effectHeartbeatConnection:Disconnect()
			effectHeartbeatConnection = nil
		end
	end)
end

local function ReturnRewardFrame(imageID, value)
	local frameReward = FrameReward:Clone()

	frameReward.ImageLabel.Image = imageID
	frameReward.TextLabel.Text = tostring(Number(value))

	local xPosition
	if lastFactor < 0 then
		lastFactor = 1
		xPosition = math.random(500, 550) / 1000
	else
		lastFactor = -1
		xPosition = math.random(450, 500) / 1000
	end
	frameReward.Position = UDim2.fromScale(xPosition, 1 + frameReward.Size.Y.Scale / 2)

	return frameReward
end

local function ShowRewardEffect(imageID, value)
	if not LocalPlayer.PlayerGui:FindFirstChild("App") then
		return
	end

	local frameReward = ReturnRewardFrame(imageID, value)
	frames[frameReward] = {}
	frames[frameReward]["spawnTime"] = os.clock()
	frames[frameReward]["animationSpeed"] = ANIMATION_SPEED
		* (math.random(100 - SPEED_VARIATION_PERCENTAGE, 100 + SPEED_VARIATION_PERCENTAGE) / 100)
	frames[frameReward]["alpha"] = 0
	local factor = frameReward.Position.X.Scale >= 0.5 and 1 or -1
	frames[frameReward]["point1"] = frameReward.Position
	frames[frameReward]["point2"] = UDim2.fromScale(
		frameReward.Position.X.Scale + (math.random(1, 50) / 1000) * factor,
		math.random(230, 270) / 1000
	)
	frames[frameReward]["point3"] = UDim2.fromScale(
		(frames[frameReward]["point2"].X.Scale + (math.random(1, 150) / 1000) * factor),
		1 + frameReward.Size.Y.Scale / 2
	)

	frameReward.Parent = LocalPlayer.PlayerGui.App
	StartEffectAnimator()
end

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
RewardEffect.Show = ShowRewardEffect

return RewardEffect

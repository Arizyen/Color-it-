-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
-- Folders
-- Modulescripts
-- Events
-- Instances
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = game.Workspace.CurrentCamera
-- Configs
local SPEED = 2
-- Variables
local controlsConnection = nil
-- Tables
-- Functions ----------------------------------------------
local function ReturnPlayerMass()
	local mass = 0
	for _, eachDescendant in pairs(Character:GetDescendants()) do
		if eachDescendant:IsA("BasePart") then
			mass = mass + eachDescendant:GetMass()
		end
	end
	return mass
end
--------------------------------------------------------------
-- FUNCTIONS FOR ACTIVATING FLYING ---------------------------
--------------------------------------------------------------
local function CreateBodyPosition()
	if not Character or not Character.PrimaryPart then
		return
	end

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = Vector3.new(1, 1, 1) * math.huge
	bodyPosition.D = 50
	bodyPosition.P = 10000
	bodyPosition.Position = Character.PrimaryPart.Position
	bodyPosition.Parent = Character.PrimaryPart
	return bodyPosition
end

local function ReturnBodyPosition()
	if not Character or not Character.PrimaryPart then
		return
	end

	local bodyPosition = Character.PrimaryPart:FindFirstChild("BodyPosition")
	if bodyPosition then
		return bodyPosition
	else
		return CreateBodyPosition()
	end
end

local function CreateBodyGyro()
	if not Character or not Character.PrimaryPart then
		return
	end

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * math.huge
	bodyGyro.D = 400
	bodyGyro.P = 3000
	bodyGyro.CFrame = CFrame.new(Camera.CFrame.p, Character.HumanoidRootPart.Position)
	bodyGyro.Parent = Character.HumanoidRootPart
	return bodyGyro
end

local function ReturnBodyGyro()
	if not Character or not Character.PrimaryPart then
		return
	end

	local bodyGyro = Character.PrimaryPart:FindFirstChild("BodyGyro")
	if bodyGyro then
		return bodyGyro
	else
		return CreateBodyGyro()
	end
end

local function ActivateFlying()
	-- local mass = ReturnPlayerMass()
	local bodyPosition = ReturnBodyPosition()
	local bodyGyro = ReturnBodyGyro()
	Humanoid.PlatformStand = true
	controlsConnection = RunService.RenderStepped:Connect(function()
		if Humanoid.MoveDirection.Magnitude > 0 then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				bodyPosition.Position += Humanoid.MoveDirection.Unit + (
					Character.HumanoidRootPart.Position - Camera.CFrame.Position
				).Unit * SPEED
			else
				bodyPosition.Position += Humanoid.MoveDirection.Unit * SPEED
			end
		end
		bodyGyro.CFrame = CFrame.new(Camera.CFrame.p, Character.HumanoidRootPart.Position)
	end)
end
--------------------------------------------------------------
-- FUNCTIONS FOR DISACTIVATING FLYING ------------------------
--------------------------------------------------------------
local function DisconnectControlsConnection()
	if controlsConnection then
		controlsConnection:Disconnect()
	end
end

local function DestroyBodyPosition()
	if not Character or not Character.PrimaryPart then
		return
	end

	local bodyPosition = Character.PrimaryPart:FindFirstChild("BodyPosition")
	if bodyPosition then
		bodyPosition:Destroy()
	end
end

local function DestroyBodyGyro()
	if not Character or not Character.PrimaryPart then
		return
	end

	local bodyGyro = Character.PrimaryPart:FindFirstChild("BodyGyro")
	if bodyGyro then
		bodyGyro:Destroy()
	end
end

local function DisactivateFlying()
	DisconnectControlsConnection()
	DestroyBodyPosition()
	DestroyBodyGyro()
	Humanoid.PlatformStand = false
end
-- MANAGER FUNCTIONS -----------------------
local function UpdateFlyingState()
	if LocalPlayer:GetAttribute("Fly") then
		ActivateFlying()
	else
		DisactivateFlying()
		script.Disabled = true
		script:Destroy()
	end
end
-- Running Functions --------------------------------------
LocalPlayer:SetAttribute("Fly", true)
UpdateFlyingState()
-- Connections --------------------------------------------
LocalPlayer:GetAttributeChangedSignal("Fly"):Connect(UpdateFlyingState)

local LightingManager = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local RunService = game:GetService("RunService")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local DefaultLighting = ReplicatedStorage:WaitForChild("DefaultLighting")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs

-- Variables
local lastLightingFolder
local blurEnabled = false
local currentDeviceType = "pc"

-- Tables
local currentLightingEffects = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function UpdateLightingSettingsDependingOnDevice(newDeviceType)
	if currentDeviceType == newDeviceType then
		return
	end

	if newDeviceType == "mobile" then
	elseif newDeviceType == "console" or newDeviceType == "pc" then
	end

	currentDeviceType = newDeviceType
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- CHANGE GAME LIGHTING -----------------------------------------------------------------------------------------------------------------------------------
local function AddLightingEffects(lightingFolder)
	for _, eachChild in pairs(lightingFolder:GetChildren()) do
		if not eachChild:IsA("Folder") then
			eachChild:Clone().Parent = Lighting
		end
	end
end

local function SetLightingSettings(lightingFolder)
	local lightingSettings = lightingFolder:FindFirstChild("LightingSettings")
	if not lightingSettings then
		return
	end

	for _, eachChild in pairs(lightingSettings:GetChildren()) do
		if type(eachChild.Value) == "number" then
			Utils.Tween.Start(
				Lighting,
				0.3,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.Out,
				{ [eachChild.Name] = eachChild.Value }
			)
		end

		Lighting[eachChild.Name] = eachChild.Value
	end
end

local function GetCurrentLightingEffects()
	for _, eachChild in pairs(Lighting:GetChildren()) do
		table.insert(currentLightingEffects, eachChild)
	end
end

local function DeleteOldLightingEffects()
	for _, eachChild in pairs(currentLightingEffects) do
		eachChild:Destroy()
	end
end

local function SetLighting(lightingFolder)
	lastLightingFolder = lightingFolder

	GetCurrentLightingEffects()
	AddLightingEffects(lightingFolder)
	SetLightingSettings(lightingFolder)
	DeleteOldLightingEffects()
end

function LightingManager.ResetLighting()
	SetLighting(DefaultLighting)
end

function LightingManager.SetLighting(lightingFolder, ignoreLastLightingFolder)
	if not lightingFolder or ((lastLightingFolder == lightingFolder) and not ignoreLastLightingFolder) then
		return
	end

	SetLighting(lightingFolder)
end
-- BLUR -----------------------------------------------------------------------------------------------------------------------------------
local function ReturnBlur()
	local blur = Lighting:FindFirstChild("Blur")
	if blur then
		return blur
	end
end

local function CreateBlur()
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Enabled = false
	blur.Parent = Lighting

	return blur
end

local function ChangeBlurSize(blur, size, speed)
	size = size or 8
	speed = speed or 0.1

	return Utils.Tween.Start(blur, speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, { Size = size })
end

function LightingManager.EnableBlur(state, size, speed)
	local blur = ReturnBlur()
	blurEnabled = state
	size = size or 10

	if state then
		if blur then
			blur.Enabled = state
			ChangeBlurSize(blur, size, speed)
		else
			blur = CreateBlur()
			blur.Enabled = state
			ChangeBlurSize(blur, size, speed)
		end

		-- Create a connection for if the blur gets destroyed after having enabled it
		local connection
		connection = blur:GetPropertyChangedSignal("Parent"):Connect(function()
			if blur and blur.Parent ~= Lighting then
				if blurEnabled then
					LightingManager.EnableBlur(state, size, speed)
				end
				if connection then
					connection:Disconnect()
					connection = nil
				end
			elseif not blur then
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end
		end)
	else
		if blur then
			if speed then
				local tween = ChangeBlurSize(blur, size, speed)
				tween.Completed:Connect(function()
					if blur then
						blur:Destroy()
					end
				end)
			else
				blur:Destroy()
			end
		end
	end
end

-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- Utils.Signals.Connect("deviceType", function(value)
-- 	UpdateLightingSettingsDependingOnDevice(value)
-- end)

return LightingManager

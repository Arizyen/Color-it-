-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Events = ReplicatedStorage:WaitForChild("Events")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local ReplicatedGameModules = Source:WaitForChild("GameModules")
local BaseControllers = Source:WaitForChild("BaseControllers")
local GameControllers = Source:WaitForChild("GameControllers")

-- Modulescripts
require(ReplicatedBaseModules) -- Initialize all base modules
require(ReplicatedGameModules) -- Initialize all game modules
local UI = require(Source:WaitForChild("UI"))
local Knit = require(Packages:WaitForChild("Knit"))
local Utils = require(Source:WaitForChild("Utils"))

-- Knit Controllers
local PlayerController = require(BaseControllers:WaitForChild("PlayerController"))

-- Instances
local ResetBE = Events:WaitForChild("ResetBE")

-- Configs

-- Variables

-- Tables

-- Functions ------------------------------------------------------------------------------------------------------------------------------------
local function CoreCall(method, ...)
	local result = {}
	for retries = 1, 10 do
		result = { pcall(StarterGui[method], StarterGui, ...) }
		if result[1] then
			break
		end
		RunService.Stepped:Wait()
	end
	return unpack(result)
end

-- CREATING CONNECTIONS ----------------------------------------------------------------------------------------------------
ResetBE.Event:Connect(function()
	PlayerController:Reset()
end)

-- RUNNING FUNCTIONS -------------------------------------------------------------------------------------------------------
if not game.Workspace:GetAttribute("serverStarted") then
	repeat
		task.wait()
	until game.Workspace:GetAttribute("serverStarted")
end

Knit.AddControllers(BaseControllers)
Knit.AddControllers(GameControllers)
Knit.Start()
	:andThen(function()
		game.ReplicatedFirst:WaitForChild("KnitLoaded").Value = true
		game.Players.LocalPlayer:WaitForChild("DataLoaded")
		game.Players.LocalPlayer:WaitForChild("DataReceived")

		UI.MountApp()

		Utils.Signals.Fire("ClientStarted", true)

		print("Controllers loaded")
	end)
	:catch(warn)

task.delay(0.5, function()
	CoreCall("SetCore", "ResetButtonCallback", ResetBE)
end)

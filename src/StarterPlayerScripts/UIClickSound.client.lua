-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- Knit Controllers

-- Instances

-- Configs

-- Variables

-- Tables
-- Functions ---------------------------------------

-- Creating Connections ----------------------------

-- Running Functions -------------------------------
Utils.Collection("Button", function(button)
	button.MouseEnter:connect(function()
		Utils.Sound.PlaySound(Utils.Sound.Infos.MouseEnter)
	end)

	button.MouseButton1Down:connect(function()
		Utils.Sound.PlaySound(Utils.Sound.Infos.MouseButton1Down)
	end)

	button.MouseButton1Click:connect(function()
		Utils.Sound.PlaySound(Utils.Sound.Infos.MouseButton1Click)
	end)
end)

Utils.Collection("Hotkey", function(button)
	button.MouseEnter:connect(function()
		Utils.Sound.PlaySound(Utils.Sound.Infos.MouseEnter)
	end)

	button.MouseButton1Down:connect(function()
		Utils.Sound.PlaySound(Utils.Sound.Infos.MouseButton1Down)
	end)
end)

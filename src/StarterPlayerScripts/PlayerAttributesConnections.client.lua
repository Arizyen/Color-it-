-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local UI = Source:WaitForChild("UI")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))
local Store = require(UI:WaitForChild("Store")) -- Must require store so it creates the "DispatchAction" signal

-- Knit Controllers

-- Instances
local LocalPlayer = game.Players.LocalPlayer

-- Configs

-- Variables

-- Tables
local allStatAttributes = {
	"level",
	"hasDied",
	"isAlive",
}
local allStatsDefaultAttributes = {
	level = 1,
	hasDied = false,
}
-- Functions ---------------------------------------
local function UpdateAttribute(attributeName)
	Utils.Signals.Fire("DispatchAction", {
		type = "SetNewStat",
		value = {
			[attributeName] = LocalPlayer:GetAttribute(attributeName)
				or allStatsDefaultAttributes[attributeName]
				or false,
		},
	})
end

local function CreateConnections()
	for _, eachStatAttribute in pairs(allStatAttributes) do
		Utils.Connections.Add(
			LocalPlayer,
			eachStatAttribute,
			LocalPlayer:GetAttributeChangedSignal(eachStatAttribute):Connect(function()
				UpdateAttribute(eachStatAttribute)
			end)
		)

		UpdateAttribute(eachStatAttribute)
	end
end
-- Creating Utils.Connections ----------------------------

-- Running Functions -------------------------------
CreateConnections()

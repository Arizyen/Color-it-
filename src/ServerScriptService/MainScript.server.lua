-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModels = ReplicatedSource.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
local GameModules = ServerStorage.Source.GameModules
local BaseServices = ServerStorage.Source.BaseServices
local GameServices = ServerStorage.Source.GameServices

-- Modulescripts
require(BaseModules) -- Initialize all base modules
require(GameModules) -- Initialize all game modules
local DataStoreManager = require(BaseModules.DataStore.Manager)
local PlayerManager = require(BaseModules.PlayerManager)
local ServerUpdate = require(BaseModules.ServerUpdate)
local Utils = require(ReplicatedSource.Utils)
local Knit = require(ReplicatedStorage.Packages.Knit)

-- KnitServices

-- Events

-- Instances

-- Configs
local MAX_WAIT = 120
local KICK_MESSAGE = "There is a problem with this server. Roblox is having issues. Please retry joining the game."

-- Variables
local gameIsRunning = false

-- Tables

-- Functions -------------------------------------

-- SERVER FUNCTIONS -------------------------------------------
local function CheckGameIsRunning()
	task.delay(MAX_WAIT, function()
		if not gameIsRunning then
			PlayerManager.KickPlayers(Players:GetPlayers(), KICK_MESSAGE)
		end
	end)
end

local function ServerIsNotRunning(player)
	if not gameIsRunning then
		if player and player:IsA("Player") then
			print("Game did not start")
			player:Kick(KICK_MESSAGE)
		end
		return true
	else
		return false
	end
end
----------------------------------------------------
-- PLAYER FUNCTIONS --------------------------------
----------------------------------------------------
local function PlayerAdded(player)
	if not player or ServerIsNotRunning(player) then
		return
	end

	if player.Parent ~= game.Players then
		Utils.Connections.Add(
			player,
			"AncestryChanged",
			player.AncestryChanged:Connect(function()
				Utils.Connections.DisconnectKeyConnection(player, "AncestryChanged")
				PlayerAdded(player)
			end)
		)
		return
	end

	Utils.Signals.Fire("PlayerJoined", player)

	if DataStoreManager.PlayerAdded(player) then
		Utils.Signals.Fire("PlayerAdded", player)
	else
		Utils.Connections.DisconnectKeyConnections(player)

		if player and not player:GetAttribute("teleporting") then
			player:Kick("There was a problem loading your data. Please rejoin the game. Servers might be down.")
		end
	end
end

local function AddAllPlayers()
	for _, eachPlayer in pairs(game.Players:GetPlayers()) do
		task.spawn(function()
			PlayerAdded(eachPlayer)
		end)
	end
end

local function PlayerRemoving(player, ignoreTimer)
	player:SetAttribute("removing", true)
	Utils.Signals.Fire("PlayerRemoving", player)
	-- Everything connected to PlayerRemoving gets executed first before the next lines
	DataStoreManager.PlayerRemoving(player, ignoreTimer)
	Utils.Connections.DisconnectKeyConnections(player.Character)
	Utils.Connections.DisconnectKeyConnections(player)
end

-- RUNNING FUNCTIONS -----------------------------
CheckGameIsRunning()
Knit.AddServices(BaseServices)
Knit.AddServices(GameServices)
Knit.Start()
	:andThen(function()
		print("Server loading")
		gameIsRunning = true

		-- Players connections
		game.Players.PlayerRemoving:Connect(function(player)
			PlayerRemoving(player, true)
		end)

		-- Subscribe to server wide message system
		ServerUpdate.SubscribeServerUpdate()

		game.Workspace:SetAttribute("serverStarted", true)

		print("Server Started")
		Utils.Signals.Fire("ServerStarted")

		-- Add all players
		AddAllPlayers()
		game.Players.PlayerAdded:Connect(function(player)
			PlayerAdded(player)
		end)
	end)
	:catch(warn)

-- CONNECTIONS -----------------------------------
game:BindToClose(function()
	if RunService:IsStudio() then
		return
	end

	for _, eachPlayer in pairs(Players:GetPlayers()) do
		PlayerRemoving(eachPlayer, true)
	end
end)

-- RUNNING FUNCTIONS -----------------------------
print("Game place version is: " .. game.PlaceVersion)

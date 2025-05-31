local PlayerManager = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts

-- KnitServices

-- Instances

-- Configs

-- Variables

-- Tables
PlayerManager.Player = require(script.Player)
PlayerManager.Character = require(script.Character)
PlayerManager.Level = require(script.Level)
PlayerManager.Badges = require(script.Badges)
PlayerManager.DayStreak = require(script.DayStreak)
PlayerManager.NameTag = require(script.NameTag)
--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
-- MANAGING PLAYERS -----------------------------------------------------------------------------------------------------------------------------------
function PlayerManager.KickPlayers(players, reason)
	if not players or typeof(players) ~= "table" then
		return
	end
	for _, eachPlayer in pairs(players) do
		if eachPlayer and eachPlayer:IsA("Player") then
			eachPlayer:Kick(reason)
		end
	end
end

-- CHANGING PLAYER SPEED/JUMP -----------------------------------------------------------------------------------------------------------------------------------
function PlayerManager.SetSpeed(player: Player, speed: number)
	if not player or typeof(speed) ~= "number" then
		return
	end

	player:SetAttribute("walkSpeed", speed)
end

function PlayerManager.SetPlayersSpeed(players: { Player }, speed: number)
	for _, eachPlayer in pairs(players) do
		PlayerManager.SetSpeed(eachPlayer, speed)
	end
end

function PlayerManager.SetJumpPower(player: Player, jumpPower: number)
	if not player or typeof(jumpPower) ~= "number" then
		return
	end

	player:SetAttribute("jumpPower", jumpPower)
end

function PlayerManager.SetPlayersJumpPower(players: { Player }, jumpPower: number)
	for _, eachPlayer in pairs(players) do
		PlayerManager.SetJumpPower(eachPlayer, jumpPower)
	end
end

function PlayerManager.Freeze(player: Player, state: boolean?)
	if not player or not player:IsA("Player") then
		return
	end

	player:SetAttribute("frozen", state or false)
end

function PlayerManager.FreezePlayers(players: { Player }, state: boolean?)
	for _, eachPlayer in pairs(players) do
		PlayerManager.Freeze(eachPlayer, state)
	end
end

-- CREATING CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------

return PlayerManager

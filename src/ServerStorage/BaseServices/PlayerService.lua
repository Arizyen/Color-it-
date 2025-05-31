-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local Utils = ReplicatedStorage.Source.Utils
-- local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Knit = require(Packages.Knit)
local PlayerManager = require(BaseModules.PlayerManager)
local TeleportUtil = require(Utils.Teleport)

-- KnitServices
local PlayerService = Knit.CreateService({
	Name = "Player",
	Client = { Teleport = Knit.CreateSignal() },
})

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnPlayerCharacterAndHumanoid(player)
	if player.Character then
		return player.Character, player.Character:FindFirstChildOfClass("Humanoid")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayerService:KnitInit() end

function PlayerService:KnitStart() end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- SERVICE FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
function PlayerService:Teleport(player: Player, teleportParams: TeleportUtil.TeleportParams)
	local cframe = TeleportUtil.Player(player, teleportParams)
	if typeof(cframe) == "CFrame" then
		self.Client.Teleport:Fire(player, cframe)
	end
end

function PlayerService:TeleportPlayers(players: { Player }, teleportParams: TeleportUtil.TeleportParams)
	for _, player in pairs(players) do
		local cframe = TeleportUtil.Player(player, teleportParams)
		if typeof(cframe) == "CFrame" then
			self.Client.Teleport:Fire(player, cframe)
		end
	end
end

function PlayerService:TeleportToFloor(player)
	local cframe = TeleportUtil.ToFloor(player)
	if typeof(cframe) == "CFrame" then
		self.Client.Teleport:Fire(player, cframe)
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
function PlayerService.Client:Freeze(playerFired, state)
	playerFired:SetAttribute("frozen", state)
end

function PlayerService.Client:Spawn(playerFired)
	PlayerManager.SpawnPlayer(playerFired)
end

function PlayerService.Client:Reset(playerFired)
	PlayerManager.Player.Reset(playerFired)
end

function PlayerService.Client:KnitLoaded(playerFired)
	playerFired:SetAttribute("knitLoaded", true)
end

return PlayerService

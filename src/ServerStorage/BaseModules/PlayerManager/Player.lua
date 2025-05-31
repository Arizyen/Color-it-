local Player = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
local GameServices = ServerStorage.Source.GameServices

-- Modulescripts -------------------------------------------------------------------
local Signals = require(ReplicatedSource.Utils.Signals)
local Connections = require(ReplicatedSource.Utils.Connections)
local NameTag = require(BaseModules.PlayerManager.NameTag)
local Collisions = require(BaseModules.Collisions)
local Utils = require(ReplicatedSource.Utils)
-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local entitiesSpawning = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ActivateHealthChangedConnection(player, character, humanoid)
	Connections.Add(
		player,
		"health",
		player:GetAttributeChangedSignal("health"):Connect(function()
			local health = player:GetAttribute("health")
			if typeof(health) == "number" then
				if health <= 0 then
					Player.Died(player, character, humanoid)
				end
			end
		end)
	)
end

local function CreateCharacterConnections(player)
	Connections.Add(
		player,
		"CharacterAppearanceLoaded",
		player.CharacterAppearanceLoaded:Connect(function(character)
			character:WaitForChild("HumanoidRootPart")
			NameTag.GiveEntityNameTag(player, character)

			player:SetAttribute("isAlive", true)
		end)
	)

	Connections.Add(
		player,
		"characterAdded",
		player.CharacterAdded:Connect(function(character)
			player:SetAttribute("hasDied", false)
			player:SetAttribute("health", 100)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

			character:WaitForChild("HumanoidRootPart")
			Signals.Fire("PlayerCharacterAdded", player, character)

			Connections.CreateKeyConnectionsTable(character)
			ActivateHealthChangedConnection(player, character, humanoid)

			Connections.Add(
				player,
				"PlayerHumanoidRootPartParentChanged",
				character.HumanoidRootPart.Parent.Changed:Connect(function()
					if not character.PrimaryPart or character.PrimaryPart.Parent ~= character then
						Player.Died(player, character, humanoid)
						Connections.DisconnectKeyConnections(character)
					end
				end)
			)

			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

			humanoid:UnequipTools()

			-- Disable default nametags
			humanoid.HealthDisplayDistance = 0
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			humanoid.DisplayName = ""
			humanoid.NameDisplayDistance = 0

			humanoid.BreakJointsOnDeath = true
			humanoid.HealthChanged:Connect(function(health)
				if health <= 0 then
					Player.Died(player, character, humanoid)
				end
			end)

			-- Add collisions
			Collisions.SetPlayerCollisionGroup(player, "PlayersNoCollide")
		end)
	)

	Connections.Add(
		player,
		"characterRemoving",
		player.CharacterRemoving:Connect(function(character)
			Signals.Fire("PlayerCharacterRemoving", player, character)
			Connections.DisconnectKeyConnections(character)
		end)
	)
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Player.Spawn(player, spawnLocation: Instance)
	if not player or not player.Parent or not spawnLocation then
		return
	end
	player.RespawnLocation = spawnLocation

	if entitiesSpawning[player.UserId] or player.Character then
		return false
	end
	entitiesSpawning[player.UserId] = true

	player:LoadCharacter()

	if player.Character then
		Utils.Teleport.Dummy(player.Character, { part = spawnLocation, randomPosition = true })
	end

	entitiesSpawning[player.UserId] = nil

	return player.Character
end

function Player.Died(player, character, humanoid)
	if player:GetAttribute("hasDied") or player:GetAttribute("removing") then
		return
	end
	player:SetAttribute("hasDied", true)
	player:SetAttribute("isAlive", false)
	humanoid.Health = 0

	Signals.Fire("PlayerDied", player)
	task.wait(3)

	if character and character.Parent then
		player.Character = nil
		character:Destroy() -- Destroy first so other connections can be fired (character.Destroying)
	end

	Connections.DisconnectKeyConnections(character)
	character = nil

	if player.Parent and not player:GetAttribute("wasInGame") then
		player:LoadCharacter()
	end
end

function Player.Reset(player)
	if player and player.Character then
		Player.Died(player, player.Character, player.Character:FindFirstChildOfClass("Humanoid"))
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerJoined", function(player)
	CreateCharacterConnections(player)
end)

return Player

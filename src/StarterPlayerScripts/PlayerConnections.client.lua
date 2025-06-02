-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local BaseControllers = Source:WaitForChild("BaseControllers")

-- Modulescripts
local UserThumbnail = require(ReplicatedBaseModules:WaitForChild("UserThumbnail"))
local LocalLeaderstats = require(ReplicatedBaseModules:WaitForChild("LocalLeaderstats"))
local Utils = require(Source:WaitForChild("Utils"))

-- Knit Controllers
local PlayersDataController = require(BaseControllers:WaitForChild("PlayersDataController"))

-- Instances
-- local LocalPlayer = game.Players.LocalPlayer

-- Configs

-- Variables

-- Tables

-- Functions ------------------------------------------------------------------------------------------------------------------------------------
local function CreateHealthChangedConnection(player, humanoid)
	Utils.Connections.Add(
		player,
		"HumanoidHealthChanged",
		humanoid.HealthChanged:Connect(function()
			if humanoid.Health <= 0 then
				Utils.Signals.Fire("PlayerDied", player)

				if player == game.Players.LocalPlayer then
					Utils.Sound.Play(Utils.Sound.Infos.Drumroll2)
				end
			end
		end)
	)
end

local function CreateHumanoidRootPartChangedConnection(player, character)
	Utils.Connections.Add(
		player,
		"playerHumanoidRootPartParentChanged",
		character.HumanoidRootPart.Parent.Changed:Connect(function()
			if not character.PrimaryPart or character.PrimaryPart.Parent ~= character then
				Utils.Signals.Fire("PlayerDied", player)

				Utils.Connections.DisconnectKeyConnections(character)
			end
		end)
	)
end

local function CharacterAdded(player, character)
	Utils.Connections.CreateKeyConnectionsTable(character)

	-- Wait for PrimaryPart
	character:WaitForChild("HumanoidRootPart", 60)
	if not character.Parent or not character.PrimaryPart then
		return
	end
	CreateHumanoidRootPartChangedConnection(player, character)
	Utils.Signals.Fire("PlayerCharacterAdded", player, character)

	-- Wait for Humanoid
	character:WaitForChild("Humanoid", 60)
	if not character.Parent or not character.PrimaryPart or not character:FindFirstChild("Humanoid") then
		return
	end

	CreateHealthChangedConnection(player, character.Humanoid)
	Utils.Signals.Fire("PlayerHumanoidAdded", player, character.Humanoid)
end

local function PlayerAdded(player)
	Utils.Connections.CreateKeyConnectionsTable(player)

	if player.Character then
		CharacterAdded(player, player.Character)
	end

	Utils.Connections.Add(
		player,
		"PlayerCharacterAdded",
		player.CharacterAdded:Connect(function(character)
			CharacterAdded(player, character)
		end)
	)

	Utils.Connections.Add(
		player,
		"PlayerCharacterRemoving",
		player.CharacterRemoving:Connect(function(character)
			Utils.Signals.Fire("PlayerCharacterRemoving", player, character)
			Utils.Connections.DisconnectKeyConnections(character)
		end)
	)

	UserThumbnail.RetrieveUserThumbnail(player)
	LocalLeaderstats.AddPlayerLeaderstats(player)
end
-- Creating Utils.Connections -------------------------------------------------------------------------------------------------------------------------
game.Players.PlayerAdded:Connect(function(player)
	PlayerAdded(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
	Utils.Signals.Fire("PlayerRemoving", player)
	UserThumbnail.PlayerRemoving(player)
	Utils.Connections.DisconnectKeyConnections(player.Character)
	Utils.Connections.DisconnectKeyConnections(player)
	LocalLeaderstats.UpdateEntityLeaderstats(player) -- to remove player from leaderstats
	-- Remove player from store data

	Utils.Signals.Fire("DispatchAction", {
		type = "PlayerRemoving",
		value = player,
	})
end)

-- Utils.Signals.Connect("PlayerCharacterAdded", function(player, character)
-- 	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 60)
-- 	if humanoidRootPart then
-- 		local runningSound = humanoidRootPart:WaitForChild("Running")
-- 		if typeof(runningSound) == "Instance" and runningSound:IsA("Sound") then
-- 			runningSound.Volume = 0
-- 		end
-- 	end
-- end)
-- Running Functions ----------------------------------------------------------------------------------------------------------------------------
LocalLeaderstats.RetrieveAllPlayersLeaderstats()
for _, eachPlayer in pairs(game.Players:GetPlayers()) do
	PlayerAdded(eachPlayer)
end

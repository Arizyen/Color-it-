local HumanoidManager = {}
-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
local Models = ReplicatedStorage.Models

-- Modulescripts
local EntitiesData = require(BaseModules.EntitiesData)
local Utils = require(ReplicatedStorage.Source.Utils)

-- KnitServices
local MessageService = require(BaseServices.MessageService)
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances
local Dummy = Models.Dummy

-- Configs

-- Variables

-- Tables
local playersDefaultHumanoidDescription = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnHumanoidDescription(player, retries)
	local userId = (type(player) == "number" and player)
		or (type(player) == "userdata" and player.UserId)
		or (type(player) == "string" and string.match(player, "%d+") and tonumber(string.match(player, "%d+")))

	if not userId or type(userId) ~= "number" or userId <= 0 then
		return
	end

	local success, humanoidDescription = pcall(Players.GetHumanoidDescriptionFromUserId, Players, userId)
	if not success then
		retries = retries or 0
		retries += 1

		if retries < 3 then
			task.wait(1)
			return ReturnHumanoidDescription(player, retries)
		else
			return
		end
	end
	return humanoidDescription
end

local function ReturnPlayerHumanoidDescription(playerId)
	if type(playerId) ~= "number" or playerId < 1 then
		return
	end

	local success, humanoidDescription = pcall(Players.GetHumanoidDescriptionFromUserId, Players, playerId)
	if not success or not humanoidDescription then
		return playersDefaultHumanoidDescription[tostring(playerId)]
	else
		if playersDefaultHumanoidDescription[tostring(playerId)] then
			playersDefaultHumanoidDescription[tostring(playerId)]:Destroy()
			playersDefaultHumanoidDescription[tostring(playerId)] = nil
		end
		playersDefaultHumanoidDescription[tostring(playerId)] = humanoidDescription

		return humanoidDescription
	end
end

local function ReturnPlayerCharacterHumanoidDescription(player, character)
	if player and player.Character then
		character = character and character:FindFirstChild("Humanoid") and character
			or player.Character and player.Character:FindFirstChild("Humanoid") and player.Character
		if character then
			return character.Humanoid:FindFirstChild("HumanoidDescription"), character.Humanoid
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function HumanoidManager.PlayerRemoving(player)
	if playersDefaultHumanoidDescription[tostring(player.UserId)] then
		playersDefaultHumanoidDescription[tostring(player.UserId)]:Destroy()
		playersDefaultHumanoidDescription[tostring(player.UserId)] = nil
	end
end
-- LOADING PLAYERS -----------------------------------------------------------------------------------------------------------------------------------
function HumanoidManager.LoadPlayer(player)
	if type(player) ~= "userdata" or player.Parent ~= game.Players then
		return
	end

	local humanoidDescription = ReturnPlayerHumanoidDescription(player.UserId)

	if humanoidDescription then
		humanoidDescription = humanoidDescription:Clone()
		player:LoadCharacterWithHumanoidDescription(humanoidDescription)
	else
		player:LoadCharacter()
		player.CharacterAppearanceLoaded:Wait()

		humanoidDescription = ReturnPlayerCharacterHumanoidDescription(player)

		if humanoidDescription then
			PlayersDataService:FirePlayerKeyValue(player, "defaultHumanoidDescription", humanoidDescription)

			humanoidDescription = humanoidDescription:Clone()

			if playersDefaultHumanoidDescription[tostring(player.UserId)] then
				playersDefaultHumanoidDescription[tostring(player.UserId)]:Destroy()
				playersDefaultHumanoidDescription[tostring(player.UserId)] = nil
			end
			playersDefaultHumanoidDescription[tostring(player.UserId)] = humanoidDescription
		else
			MessageService:SendMessageToPlayer(
				player,
				"Roblox error. Was not able to load your character with custom accessories",
				"Error"
			)
		end
	end
end

-- player can be Player or UserId (number)
function HumanoidManager.ReturnPlayerDummy(player)
	if type(player) == "string" or type(player) == "number" then
		player = Players:GetPlayerByUserId(player) or string.match(player, "%d+")
	end

	if not player then
		return
	end

	local playerHumanoidDescription = ReturnHumanoidDescription(player)

	if not playerHumanoidDescription or not playerHumanoidDescription:IsA("HumanoidDescription") then
		return Dummy:Clone()
	else
		local dummy = Dummy:Clone()
		dummy.Name = type(player) == "userdata" and player.Name or Dummy.Name
		dummy.Parent = ReplicatedStorage
		dummy.Humanoid:ApplyDescription(playerHumanoidDescription)

		return dummy
	end
end

function HumanoidManager.RecalculateHipHeight(character)
	if not character or not character.PrimaryPart or not character:FindFirstChild("Humanoid") then
		return
	end

	local bottomOfHumanoidRootPart = character.HumanoidRootPart.Position.Y - (1 / 2 * character.HumanoidRootPart.Size.Y)
	local bottomOfFoot = character.LeftFoot.Position.Y - (1 / 2 * character.LeftFoot.Size.Y) -- Left or right. Chose left arbitrarily
	local newHipHeight = bottomOfHumanoidRootPart - bottomOfFoot

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.HipHeight = newHipHeight
end

function HumanoidManager.ChangeCharacterSize(character, factor)
	local humanoid = character:FindFirstChild("Humanoid")
	factor = type(factor) == "number" and factor or 1

	if humanoid then
		local HS = humanoid.HeadScale
		local BDS = humanoid.BodyDepthScale
		local BWS = humanoid.BodyWidthScale
		local BHS = humanoid.BodyHeightScale

		HS.Value = HS.Value * factor
		BDS.Value = BDS.Value * factor
		BWS.Value = BWS.Value * factor
		BHS.Value = BHS.Value * factor

		HumanoidManager.RecalculateHipHeight(character)
	end
end
-- CONNECTIONS ----------------------------------------------------------------------------------------------------
game.Players.PlayerRemoving:Connect(HumanoidManager.PlayerRemoving)

return HumanoidManager

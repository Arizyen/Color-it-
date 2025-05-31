local Admin = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")

-- Folders
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local Scripts = ServerStorage.Source.Scripts
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Utils = require(ReplicatedStorage.Source.Utils)
local Collisions = require(BaseModules.Collisions)
local NameTag = require(BaseModules.PlayerManager.NameTag)
local ServerUpdate = require(BaseModules.ServerUpdate)
local Moderation = require(BaseModules.Moderation)

-- KnitServices
local MessageService = require(BaseServices.MessageService)

-- KnitServices

-- Instances
local flyScript = Scripts.Fly

-- Configs

-- Variables

-- Tables
local adminPlayers = {
	1858692567,
}
local adminPlayersRank = {
	["1858692567"] = 255,
}
local commands = {
	"Kick",
	"Ban",
	"Fly",
	"NoClip",
	-- "HideGuis",
	"Invisibility",
	-- "UpdateServers",
	"SendMessage",
}
local commandsNeedingPlayer = {
	"Kick",
	"Ban",
}

local adminFunctions = {}
-- Functions --------------------------------------------
local function HasRank(player, tier)
	if not adminPlayersRank[tostring(player.UserId)] then
		return
	end
	if adminPlayersRank[tostring(player.UserId)] < tier then
		return
	end
	return true
end
----------------------------------------------------
-- ADMIN CONTROLS ----------------------------------
----------------------------------------------------
local function ReturnPlayerFromCommand(message)
	local strings = message:split(" ")
	if strings[2] then
		if Players:FindFirstChild(strings[2]) then
			return Players:FindFirstChild(strings[2])
		end
	end
end
-- Kick player
function adminFunctions.Kick(player)
	if not player then
		warn("Admin commands: Player cannot be found")
	else
		Moderation.PlayerIsExploiting(player)
	end
end
-- Ban player
function adminFunctions.Ban(player, adminPlayer)
	if not player then
		warn("Admin commands: Player cannot be found")
	else
		Moderation.PlayerIsExploiting(player, "BANNED", true)
		Moderation.AdminBannedPlayer(adminPlayer, player)
	end
end
-- Functions for flying -------------------------------
function adminFunctions.Fly(player)
	if not player or not player:IsA("Player") or not player.Character then
		return
	end
	if not HasRank(player, 255) then
		return
	end

	if player:GetAttribute("Fly") then
		player:SetAttribute("Fly", false)
		player:SetAttribute("Admin", false)
		adminFunctions.NoClip(player, false)
	else
		player:SetAttribute("Fly", true)
		player:SetAttribute("Admin", true)
		adminFunctions.NoClip(player, true)
		flyScript:Clone().Parent = player.Character
	end
end

function adminFunctions.NoClip(player, state)
	if not player or not player:IsA("Player") then
		return
	end
	if not HasRank(player, 255) then
		return
	end

	local function ActivateNoClip()
		-- Give no clip collision group
		player:SetAttribute("NoClip", true)
		player:SetAttribute("Admin", true)
		Collisions.SetPlayerCollisionGroup(player, "NoClip")
	end

	local function DeactivateNoClip()
		-- Give back default collision group
		player:SetAttribute("NoClip", false)
		player:SetAttribute("Admin", false)
		Collisions.SetPlayerCollisionGroup(player, "PlayersCollide")
	end

	if state then
		return ActivateNoClip()
	elseif state == false then
		return DeactivateNoClip()
	else
		if player:GetAttribute("NoClip") then
			DeactivateNoClip()
		else
			ActivateNoClip()
		end
	end
end
-- Functions for showing guis --------------------------
local function ReturnPlayerGuisFolder(player)
	local guisFolder = player:FindFirstChild("HiddenGuis")
	if not guisFolder then
		guisFolder = Instance.new("Folder")
		guisFolder.Name = "HiddenGuis"
		guisFolder.Parent = player

		return guisFolder
	else
		return guisFolder
	end
end

local function HideGuis(player, state)
	local guisFolder = ReturnPlayerGuisFolder(player)
	if state then
		for _, eachChild in pairs(player.PlayerGui:GetChildren()) do
			if eachChild:IsA("ScreenGui") then
				eachChild.Parent = guisFolder
			end
		end
		player:SetAttribute("GuisHidden", true)
	else
		for _, eachChild in pairs(guisFolder:GetChildren()) do
			if eachChild:IsA("ScreenGui") then
				eachChild.Parent = player.PlayerGui
			end
		end
		player:SetAttribute("GuisHidden", false)
	end
end

function adminFunctions.HideGuis(player)
	if not player or not player:IsA("Player") then
		return
	end
	if player:GetAttribute("GuisHidden") then
		HideGuis(player, false)
	else
		HideGuis(player, true)
	end
end
-- Functions for invisibility ------------------------
local function MakePlayerInvisible(player, state)
	if state then
		Utils.Model.Hide(player.Character, true)
		NameTag.EnableEntityNameTag(player, false)
		player:SetAttribute("IsInvisible", true)
	else
		Utils.Model.Hide(player.Character, false)
		NameTag.EnableEntityNameTag(player, true)
		player:SetAttribute("IsInvisible", false)
	end
end

function adminFunctions.Invisibility(player)
	if not player or not player:IsA("Player") then
		return
	end
	if not HasRank(player, 255) then
		return
	end

	if player:GetAttribute("IsInvisible") then
		MakePlayerInvisible(player, false)
	else
		MakePlayerInvisible(player, true)
	end
end
-- Server update ------------------------------------
--function adminFunctions.UpdateServers(player)
--	if not player or not player:IsA("Player") then return end

--	local publishSuccess, publishResult = pcall(function()
--		MessagingService:PublishAsync(ServerUpdate.MessageTopics["SERVER_UPDATE"], "true")
--	end)
--	if not publishSuccess then
--		print(publishResult)
--	else
--		print("Fired all server to update successfully.")
--	end
--end
-- Server message -----------------------------------
function adminFunctions.SendMessage(playerFiring, message)
	if not playerFiring or not message or typeof(message) ~= "string" then
		return
	end
	if not HasRank(playerFiring, 255) then
		return
	end

	local strings = message:split(" ")
	message = string.gsub(message, strings[1], "")

	if message then
		local filteredMessage = MessageService:FilterMessage(playerFiring, message)
		if not filteredMessage or filteredMessage == "" then
			print("Filtered message is nil or empty")
			return
		end
		if string.find(filteredMessage, "#") then
			print("Message not sent: " .. filteredMessage)
			return
		end
		if message ~= filteredMessage then
			print("Message got filtered: " .. filteredMessage)
			return
		end

		local publishSuccess, publishResult = pcall(function()
			MessagingService:PublishAsync(ServerUpdate.MessageTopics["SERVER_MESSAGE"], filteredMessage)
		end)
		if not publishSuccess then
			print(publishResult)
		else
			print("Sent message to servers successfully: " .. filteredMessage)
		end
	end
end
--
------------------------------------------------------------------------------------------------------------------------------
local function ReturnRequestedFunction(message)
	for _, eachCommand in pairs(commands) do
		if string.find(string.lower(message), string.lower(eachCommand)) then
			return eachCommand
		end
	end
end
----------------------------------------------------
-- GLOBAL FUNCTIONS --------------------------------
----------------------------------------------------
function Admin.AddAdminControls(player)
	if not player or not player:IsA("Player") or not table.find(adminPlayers, player.UserId) then
		return
	end

	player:SetAttribute("IsAdmin", true)
	Utils.Connections.Add(
		player,
		"Chatted",
		player.Chatted:Connect(function(message)
			if message and string.len(message) > 0 and string.sub(message, 1, 1) == ";" then
				local request = ReturnRequestedFunction(message)
				if request then
					if adminFunctions[request] then
						local playerFromCommand = ReturnPlayerFromCommand(message)
						if playerFromCommand then
							adminFunctions[request](playerFromCommand, player)
						elseif not playerFromCommand then
							if not table.find(commandsNeedingPlayer, request) then
								adminFunctions[request](player, message)
							else
								print("Player not found for request: " .. request)
							end
						end
					else
						print("Function requested not found.")
					end
				end
			end
		end)
	)

	Utils.Connections.Add(
		player,
		"CharacterAddedAdmin",
		player.CharacterAdded:Connect(function(character)
			player:SetAttribute("Fly", false)
			player:SetAttribute("NoClip", false)
		end)
	)
end

-- CONNECTIONS ----------------------------------------------------------------------------------------------------
Utils.Signals.Connect("PlayerAdded", function(player)
	Admin.AddAdminControls(player)
end)

return Admin

local Moderation = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
local GameServices = ServerStorage.Source.GameServices

-- Modulescripts -------------------------------------------------------------------
local EntitiesData = require(BaseModules.EntitiesData)

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local MAX_EXPLOITING_CHANCES = 2
local _ANTI_CHEAT_VERSION = 1
local _BANNED_DAYS = 3
-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Moderation.IsPlayerBanned(player)
	if not player or not player:IsA("Player") or (RunService:IsStudio()) then
		return
	end

	if EntitiesData.data[player.UserId]["permanentBan"] then
		print("Permanent banned user tried to join: " .. player.Name)
		player:Kick("[BANNED] You are banned from this game for exploiting.")

		return true
	elseif EntitiesData.data[player.UserId]["bannedV" .. _ANTI_CHEAT_VERSION] then
		if
			os.time() - EntitiesData.data[player.UserId]["bannedV" .. _ANTI_CHEAT_VERSION]
			> _BANNED_DAYS * 24 * 60 * 60
		then
			EntitiesData.data[player.UserId]["bannedV" .. _ANTI_CHEAT_VERSION] = nil
			EntitiesData.data[player.UserId]["exploitingIntV" .. _ANTI_CHEAT_VERSION] = nil
		else
			print(
				string.format(
					"Banned user tried to join: %s. Ban time left: %s",
					player.Name,
					os.time() - EntitiesData.data[player.UserId]["bannedV" .. _ANTI_CHEAT_VERSION] / 24 / 60 / 60
				)
			)

			player:Kick(
				string.format(
					"[BANNED] You are banned from this game for exploiting. You can join in %s days.",
					os.time() - EntitiesData.data[player.UserId]["bannedV" .. _ANTI_CHEAT_VERSION] / 24 / 60 / 60
				)
			)
			return true
		end
	end
end

-- BANNING/KICKING PLAYER -----------------------------------------------------------------------------------------------------------------------------------
function Moderation.PlayerIsExploiting(player, reason, permanentBan)
	if
		not player
		or not player:IsA("Player")
		or player:GetAttribute("Kicked")
		or not EntitiesData.data[player.UserId]
	then
		return
	end
	player:SetAttribute("Kicked", true)

	if not EntitiesData.data[player.UserId]["exploitingIntV" .. _ANTI_CHEAT_VERSION] then
		EntitiesData.data[player.UserId]["exploitingIntV" .. _ANTI_CHEAT_VERSION] = 0
	end

	if not reason then
		reason = "KICKED"
	end
	if type(EntitiesData.data[player.UserId]["kickedReasons"]) ~= "table" then
		EntitiesData.data[player.UserId]["kickedReasons"] = {}
	end
	table.insert(EntitiesData.data[player.UserId]["kickedReasons"], reason)

	if permanentBan then
		EntitiesData.data[player.UserId]["permanentBan"] = true
		EntitiesData.data[player.UserId]["bannedV" .. _ANTI_CHEAT_VERSION] = os.time()
	end

	local hasBeenBanned = false

	EntitiesData.data[player.UserId]["exploitingIntV" .. _ANTI_CHEAT_VERSION] += 1 -- Commented for now, as we confirm the anti hacks reliability, will uncomment.
	if EntitiesData.data[player.UserId]["exploitingIntV" .. _ANTI_CHEAT_VERSION] >= MAX_EXPLOITING_CHANCES then
		EntitiesData.data[player.UserId]["bannedV" .. _ANTI_CHEAT_VERSION] = os.time()
		hasBeenBanned = true
	end

	print("Kicking player " .. player.Name .. " for: " .. reason)

	player:Kick(
		(hasBeenBanned or permanentBan) and "You have been banned from this experience for exploiting"
			or "You have been kicked for exploiting. Another exploit attempt will result in a ban."
	)
end

function Moderation.AdminBannedPlayer(adminPlayer, bannedPlayer)
	if
		not adminPlayer
		or not adminPlayer:IsA("Player")
		or not bannedPlayer
		or not bannedPlayer:IsA("Player")
		or not EntitiesData.data[adminPlayer.UserId]
	then
		return
	end

	if
		not EntitiesData.data[adminPlayer.UserId]["PlayersBanned"]
		or typeof(EntitiesData.data[adminPlayer.UserId]["PlayersBanned"]) ~= "table"
	then
		EntitiesData.data[adminPlayer.UserId]["PlayersBanned"] = {}
	end

	table.insert(EntitiesData.data[adminPlayer.UserId]["PlayersBanned"], bannedPlayer.UserId)
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Moderation

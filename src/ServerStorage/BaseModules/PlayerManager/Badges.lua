local Badges = {}
-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")
local Promise = require(ReplicatedStorage.Packages.Promise)

-- Folders
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModules = ReplicatedSource.BaseModules
local Infos = ReplicatedSource.Infos
-- local Packages = ReplicatedStorage.Packages
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local BadgesInfos = require(Infos.Badge)
local Signals = require(ReplicatedSource.Utils.Signals)

-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances

-- Configs
local MAX_TRIES = 3

-- Variables

-- Tables
local creatorsId = {
	1858692567,
}
local creatorsInGame = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function MakeBadgeAchievementClaimable(player, badgeName)
	-- Add badge to claimable achievements
	if
		not PlayersDataService:GetKeyValue(player, "claimedAchievements", badgeName)
		and not PlayersDataService:GetKeyValue(player, "claimableAchievements", badgeName)
	then
		PlayersDataService:SetKeyIndexValue(player, "claimableAchievements", badgeName, true, true)
		if player:GetAttribute("isNPC") then
			player:ClaimAchievement(badgeName)
		end
	end
end

local function PlayerBadgesAreLoaded(player)
	return type(PlayersDataService:GetKeyValue(player, "badges")) == "table"
end

local function BadgeIsValid(badgeId)
	-- Fetch badge information
	local success, badgeInfo = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)

	if success then
		if badgeInfo.IsEnabled then
			return true
		else
			return false
		end
	else
		return false
	end
end

local function AwardPlayerBadge(player, badgeId, checkBadgeIsValid)
	return Promise.new(function(resolve)
		if checkBadgeIsValid then
			if not BadgeIsValid(badgeId) then
				print("Badge is not valid", badgeId)
				resolve(false)
				return
			end
		end

		-- Award badge
		local success, result = pcall(function()
			return BadgeService:AwardBadge(player.UserId, badgeId)
		end)

		if not success then
			warn("Error while awarding badge:", result)
			resolve(false)
		elseif not result then
			success, result = pcall(function()
				return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
			end)

			if success and result then
				resolve(true)
			else
				resolve(false)
			end
		else
			resolve(true)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- AWARDING BADGES --------------------------------------------------------------------------------------------------------------------------------
-- Awards player the badge. YIELDING FUNCTION
function Badges.Award(player, badgeName, badgeType, skipSafeCheck, tries)
	if
		not badgeName
		or not BadgesInfos[badgeType]
		or not BadgesInfos[badgeType].infos[badgeName]
		or (not skipSafeCheck and not PlayerBadgesAreLoaded(player))
	then
		-- warn("Invalid badge name or badge type", "Badge name:", badgeName, "Badge type:", badgeType)
		return
	end

	if PlayersDataService:GetKeyValue(player, "badges", badgeName) then
		return
	end

	MakeBadgeAchievementClaimable(player, badgeName)

	-- Verify it's a player and not an npc
	if not player:IsA("Player") then
		return
	end

	local badges = BadgesInfos[badgeType]
	local badgeId = badges.infos[badgeName].badgeId
	AwardPlayerBadge(player, badgeId):andThen(function(value)
		if value then
			PlayersDataService:SetKeyIndexValue(player, "badges", badgeName, true, true)
		else
			if not tries then
				tries = 1
			else
				tries += 1
			end
			if tries > MAX_TRIES then
				-- print("Max tries reached for awarding badge", badgeName, "to player", player.Name, player.UserId)
				return
			end
			task.wait(3)
			return Badges.Award(player, badgeName, badgeType, false, tries)
		end
	end)
end

function Badges.AwardPlayers(players, badgeName, badgeType)
	if not players or typeof(players) ~= "table" or not badgeName then
		return
	end

	for _, eachPlayer in pairs(players) do
		if eachPlayer and eachPlayer:IsA("Player") then
			Badges.Award(eachPlayer, badgeName, badgeType)
		end
	end
end

-- Verify player was given the badges they achieved
function Badges.VerifyPlayer(player)
	if not player then
		return
	end

	if not PlayerBadgesAreLoaded(player) then
		-- print("Player badges are not loaded for player", player.Name, player.UserId)
		return
	end

	-- Badges.VerifyPlayerBadgeType(player, "WinsEasy", "wins")
end

function Badges.VerifyPlayerBadgeType(player, badgeType, dataKey)
	local playerKeyValue = PlayersDataService:GetKeyValue(player, dataKey)
	if not BadgesInfos[badgeType] then
		warn("Badges.VerifyPlayerBadgeType: Invalid badge type", badgeType)
		return
	end
	if playerKeyValue then
		local keys = BadgesInfos[badgeType].keys
		local badgeInfos = BadgesInfos[badgeType].infos

		for _, eachBadgeKey in ipairs(keys or {}) do
			if badgeInfos[eachBadgeKey] and playerKeyValue >= badgeInfos[eachBadgeKey].value then
				Badges.Award(player, eachBadgeKey, badgeType)
			else
				break
			end
		end
	end
end
-- CREATOR BADGES -----------------------------------------------------------------------------------------------------------------------------------
function Badges.CheckCreatorJoined(player)
	if not player or not player:IsA("Player") then
		return
	end

	if table.find(creatorsId, player.UserId) then
		if not creatorsInGame[tostring(player.UserId)] then
			creatorsInGame[tostring(player.UserId)] = true
			-- Badges.AwardPlayers(Players:GetPlayers(), "MeetCreator", "Special")
		end
	end
end

function Badges.CheckCreatorLeft(player)
	if not player or not player:IsA("Player") then
		return
	end

	if creatorsInGame[tostring(player.UserId)] then
		creatorsInGame[tostring(player.UserId)] = nil
	end
end

function Badges.CheckCreatorIsInGame(player)
	for _, eachCreatorId in pairs(creatorsId) do
		if creatorsInGame[tostring(eachCreatorId)] then
			-- Badges.Award(player, "MeetCreator", "Special")
			break
		end
	end
end
-- CREATING CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerAdded", function(player)
	Badges.CheckCreatorJoined(player)
	Badges.CheckCreatorIsInGame(player)
end)

Signals.Connect("PlayerDataLoaded", function(player)
	-- Badges.Award(player, "Welcome", "Special")
	Badges.VerifyPlayer(player)
end)

Signals.Connect("PlayerRemoving", Badges.CheckCreatorLeft)

return Badges

-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local Infos = ReplicatedStorage.Source.Infos
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Knit = require(Packages.Knit)
local AchievementsInfo = require(Infos.Rewards.AchievementsInfo)
local Utils = require(ReplicatedStorage.Source.Utils)
local InventoryManager = require(BaseModules.InventoryManager)

-- KnitServices
local AchievementService = Knit.CreateService({
	Name = "Achievement",
	Client = {},
})
local PlayersDataService = require(BaseServices.PlayersDataService)
local MessageService = require(BaseServices.MessageService)

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function AwardPlayerAchievement(player, achievementName, achievementInfo)
	MessageService:SendMessageToPlayer(
		player,
		"You have claimed the achievement: " .. achievementInfo.displayName,
		"AchievementClaimed"
	)

	PlayersDataService:SetKeyIndexValue(player, "claimableAchievements", achievementName, nil)

	if
		PlayersDataService:SetKeyIndexValue(player, "claimedAchievements", achievementName, true)
		and InventoryManager.AddGems(player, achievementInfo.gemReward, true)
	then
		PlayersDataService:SetKeyIndexValue(player, "claimedAchievements", achievementName, true, true)
		return true
	else
		PlayersDataService:SetKeyIndexValue(player, "claimedAchievements", achievementName, false)
		PlayersDataService:SetKeyIndexValue(player, "claimableAchievements", achievementName, true, true)
		return false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function AchievementService:KnitInit() end

function AchievementService:KnitStart() end
-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------
function AchievementService:ClaimAchievement(playerFired, achievementName)
	if type(achievementName) ~= "string" then
		return
	end

	local achievementInfo = AchievementsInfo.infos[achievementName]
	if not achievementInfo then
		return
	end

	if PlayersDataService:GetKeyValue(playerFired, "claimedAchievements", achievementName) then
		PlayersDataService:SetKeyIndexValue(playerFired, "claimableAchievements", achievementName, nil)
		-- Player has already claimed achievement, send message to player
		MessageService:SendMessageToPlayer(playerFired, "You have already claimed this achievement!", "Error")
		return
	elseif
		not PlayersDataService:GetKeyValue(playerFired, "claimableAchievements", achievementName)
		and not PlayersDataService:GetKeyValue(playerFired, "badges", achievementName)
	then
		-- Player cannot claim achievement, send message to player
		if
			AchievementsInfo.infos[achievementName]
			and AchievementsInfo.infos[achievementName].dataKey
			and AchievementsInfo.infos[achievementName].dataValue
			and PlayersDataService:GetKeyValue(playerFired, AchievementsInfo.infos[achievementName].dataKey)
		then
			local playerAchievementDataValue =
				PlayersDataService:GetKeyValue(playerFired, AchievementsInfo.infos[achievementName].dataKey)

			if AchievementsInfo.infos[achievementName].isTimeValue then
				local gameStartTime = PlayersDataService:GetKeyValue(playerFired, "gameStartTime")
				local totalPlayTimeOnStart = PlayersDataService:GetKeyValue(playerFired, "totalPlayTimeOnStart")

				if gameStartTime and totalPlayTimeOnStart then
					playerAchievementDataValue = achievementInfo.dataValue
						- (os.time() - gameStartTime + totalPlayTimeOnStart)
				end
			end

			MessageService:SendMessageToPlayer(
				playerFired,
				string.format(
					"You need %s more to claim this achievement!",
					AchievementsInfo.infos[achievementName].isTimeValue
							and Utils.Time.FormatTime(achievementInfo.dataValue - playerAchievementDataValue)
						or (Utils.Number.Spaced(achievementInfo.dataValue - playerAchievementDataValue, 10000))
				),
				"Error"
			)
		else
			MessageService:SendMessageToPlayer(playerFired, "You cannot claim this achievement yet!", "Error")
		end

		return
	end

	return AwardPlayerAchievement(playerFired, achievementName, achievementInfo)
end
-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------------
function AchievementService.Client:ClaimAchievement(playerFired, achievementName)
	return self.Server:ClaimAchievement(playerFired, achievementName)
end

return AchievementService

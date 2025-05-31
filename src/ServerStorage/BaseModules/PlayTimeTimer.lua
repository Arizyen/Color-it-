local PlayTimeTimer = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Folders -------------------------------------------------------------------------
local ReplicatedSource = ReplicatedStorage.Source
local Infos = ReplicatedSource.Infos
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts -------------------------------------------------------------------
local DayStreak = require(BaseModules.PlayerManager.DayStreak)
local PlayTimeBadges = require(Infos.Badge.PlayTime)
local Signals = require(ReplicatedSource.Utils.Signals)

-- KnitServices --------------------------------------------------------------------
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function PlayTimeTimer.Start()
	local badgeName, newTotalPlayTime
	task.spawn(function()
		while true do
			task.wait(60)
			for _, eachPlayer in pairs(Players:GetPlayers()) do
				local eachPlayerValues = PlayersDataService:GetKeysValue(
					eachPlayer,
					{ "gameStartTime", "totalPlayTime", "totalPlayTimeOnStart" }
				)

				if eachPlayerValues then
					newTotalPlayTime = eachPlayerValues.totalPlayTime
						+ (os.time() - eachPlayerValues.gameStartTime)
						- (eachPlayerValues.totalPlayTime - eachPlayerValues.totalPlayTimeOnStart)

					PlayersDataService:SetKeyValue(eachPlayer, "totalPlayTime", newTotalPlayTime)

					badgeName = string.format("Play%sSeconds", newTotalPlayTime - (newTotalPlayTime % 60))
					if PlayTimeBadges.infos[badgeName] then
						-- task.spawn(PlayerManager.Badges.Award, eachPlayer, badgeName, "PlayTime")
					end
				end

				DayStreak.UpdateStreak(eachPlayer)
			end
		end
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Signals.Connect("ServerStarted", PlayTimeTimer.Start)

return PlayTimeTimer

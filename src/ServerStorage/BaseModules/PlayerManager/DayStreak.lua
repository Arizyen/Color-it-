local DayStreak = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModules = ReplicatedSource.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Badges = require(BaseModules.PlayerManager.Badges)
local Signals = require(ReplicatedSource.Utils.Signals)
-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function DayStreak.UpdateStreak(player, playerJustJoined)
	local dayLoggedInTimes = PlayersDataService:GetKeyValue(player, "dayLoggedInTimes")
	if type(dayLoggedInTimes) ~= "table" then
		return
	end

	if playerJustJoined then
		-- Update dayLoggedInTimes
		for i = #dayLoggedInTimes, 1, -1 do
			if dayLoggedInTimes[i] < os.time() - ((24 * 60 * 60) * i) then
				table.remove(dayLoggedInTimes, i)
			else
				break
			end
		end

		-- Add current time to dayLoggedInTimes if 16 hours have passed since the last time
		if #dayLoggedInTimes == 0 or (#dayLoggedInTimes > 0 and dayLoggedInTimes[1] <= os.time() - (16 * 60 * 60)) then
			table.insert(dayLoggedInTimes, 1, os.time())
		end

		-- Update dayLoggedInStreak
		PlayersDataService:SetKeyValue(player, "dayLoggedInStreak", #dayLoggedInTimes)
	else
		-- Add current time to dayLoggedInTimes if 16 hours have passed since the last time
		if #dayLoggedInTimes == 0 or (#dayLoggedInTimes > 0 and dayLoggedInTimes[1] <= os.time() - (16 * 60 * 60)) then
			table.insert(dayLoggedInTimes, 1, os.time())
		end

		-- Update dayLoggedInStreak
		PlayersDataService:SetKeyValue(player, "dayLoggedInStreak", #dayLoggedInTimes)
	end

	if #dayLoggedInTimes >= 7 then
		-- Badges.Award(player, "Play7DaysInARow", "Special")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerDataLoaded", function(player)
	DayStreak.UpdateStreak(player, true)
end)

return DayStreak

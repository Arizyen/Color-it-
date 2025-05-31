local Level = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local ReplicatedSource = ReplicatedStorage.Source
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules

-- local Packages = ReplicatedStorage.Packages
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Signals = require(ReplicatedSource.Utils.Signals)
local Badges = require(BaseModules.PlayerManager.Badges)

-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances

-- Configs
Level.STARTING_XP = 1000
Level.PLAYER_XP_LVL_RATIO = 1.05
-- Variables

-- Tables
Level.levelsXP = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- XP-LVL FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function Level.ReturnLevelXP(level: number)
	if Level.levelsXP["level" .. level] then
		return Level.levelsXP["level" .. level]
	else
		Level.levelsXP["level" .. level] = math.round(Level.STARTING_XP * Level.PLAYER_XP_LVL_RATIO ^ level)
		return Level.levelsXP["level" .. level]
	end
end

function Level.LoadPlayerXP(player)
	local playerLvl = PlayersDataService:GetKeyValue(player, "level")
	if playerLvl then
		-- local playerXP = PlayersDataService:GetKeyValue(player, "xp")

		player:SetAttribute("level", playerLvl)
		-- player:SetAttribute("maxXP", Level.ReturnLevelXP(playerLvl))
		-- player:SetAttribute("xp", math.round(playerXP))
	end
end
-- RUNNING FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------

-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerAdded", function(player)
	Level.LoadPlayerXP(player)
end)

return Level

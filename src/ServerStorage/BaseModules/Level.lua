local Level = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local ReplicatedSource = ReplicatedStorage.Source
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Signals = require(ReplicatedSource.Utils.Signals)

-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)
-- Instances

-- Configs
Level.STARTING_XP = 1000

Level.PLAYER_XP_LVL_RATIO = 1.05
Level.MOB_XP_LVL_RATIO = 1.035
-- Variables

-- Tables
Level.playerLevelsXP = {}
Level.mobLevelsXP = {}

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function LoadPlayerXP(player)
	local playerLvl = PlayersDataService:GetKeyValue(player, "level")
	if playerLvl then
		local playerXP = PlayersDataService:GetKeyValue(player, "xp")

		Level.LoadPlayerLevelXP(playerLvl)
		PlayersDataService:SetKeyValue(player, "maxXP", Level.playerLevelsXP["level" .. playerLvl])
		PlayersDataService:SetKeyValue(player, "xp", math.round(playerXP))
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- XP-LVL FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function Level.InitializeLevelsXPTable()
	-- Initialize players and mobs xp levels table
	for i = 1, 120 do
		Level.playerLevelsXP["level" .. i] = math.round(Level.STARTING_XP * Level.PLAYER_XP_LVL_RATIO ^ i)
		Level.mobLevelsXP["level" .. i] = math.round(Level.STARTING_XP * Level.MOB_XP_LVL_RATIO ^ i)
	end
end

function Level.LoadPlayerLevelXP(level): number
	if not Level.playerLevelsXP["level" .. level] then
		Level.playerLevelsXP["level" .. level] = math.round(Level.STARTING_XP * Level.PLAYER_XP_LVL_RATIO ^ level)
	end

	return Level.playerLevelsXP["level" .. level]
end

function Level.LoadMobLevelXP(level): number
	if not Level.mobLevelsXP["level" .. level] then
		Level.mobLevelsXP["level" .. level] = math.round(Level.STARTING_XP * Level.MOB_XP_LVL_RATIO ^ level)
	end

	return Level.mobLevelsXP["level" .. level]
end

-- RUNNING FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
Level.InitializeLevelsXPTable()

-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerDataLoaded", LoadPlayerXP)

return Level

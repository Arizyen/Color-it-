local GameConfigs = {}
-- Services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
-- local Source = ReplicatedStorage:WaitForChild("Source")
--
--
-- Modulescripts

-- KnitControllers

-- Instances

-- Configs
GameConfigs._SERVERS_DIFFICULTY = {
	[123010376283547] = 1, -- Starting place (Easy)
	[95173589806067] = 2, -- Intermediate
	[94685198502054] = 3, -- Pro
}

GameConfigs._DIFFICULTY_BONUS_FACTOR = 0.25 -- 1 + ((difficulty-1) * factor), at difficulty 1 the factor is 1 (no bonus) and at difficulty 3 the factor is 0.5
GameConfigs._ARENA_CHANGE_COOLDOWN = 5 -- Seconds
GameConfigs._WRONG_ANSWER_COOLDOWN = 3 -- Seconds
GameConfigs._NEXT_EQUATION_COOLDOWN = 0.35 -- Seconds

GameConfigs._LAVA_STARTING_SPEED = 0.1 -- Studs per second
GameConfigs._LAVA_SPEED_INCREASE_INCREMENT = 0.05 -- Studs per second
GameConfigs._LAVA_SPEED_INCREASE_INTERVAL = 10 -- Seconds (time to increase speed), gives a total of 60 speed increases for a total time of 5 minutes (speed is 3 after 5 minutes)
GameConfigs._EQUATIONS_BAG_SIZE = 10
GameConfigs._MATCH_DURATION = 300 -- Seconds (5 minutes)
GameConfigs._INCREASE_COMBO_STREAK_INTERVAL = 5 -- Increase combo after 5 streaks
GameConfigs._TILE_SIZE = Vector3.new(5, 1, 5)
GameConfigs._TILE_ADDED_ANIMATION_TIME = 0.1 -- Seconds
GameConfigs._TILE_REMOVED_ANIMATION_TIME = 0.4 -- Seconds
-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function GameConfigs.GetDifficultyServerPlaceId(difficulty: number)
	for placeId, eachDifficulty in pairs(GameConfigs._SERVERS_DIFFICULTY) do
		if eachDifficulty == difficulty then
			return placeId
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

return GameConfigs

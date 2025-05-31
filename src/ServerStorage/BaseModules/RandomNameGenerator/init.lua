local RandomNameGenerator = {}
-- Services

-- Folders

-- Modulescripts
local RandomNamesList = require(script.RandomNamesList)
-- KnitServices

-- Instances

-- Configs

-- Variables
local randomGenerator = Random.new()
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function RandomNameGenerator.AddNameBack(name)
	table.insert(RandomNamesList, name)
end

function RandomNameGenerator.GenerateName(): string
	if #RandomNamesList == 0 then
		return "AI" .. randomGenerator:NextInteger(1, 9999)
	end

	local randomIndex, randomName
	local triesLeft = #RandomNamesList * 2

	repeat
		randomIndex = randomGenerator:NextInteger(1, #RandomNamesList)
		randomName = RandomNamesList[randomIndex]
		triesLeft -= 1
	until not game.Players:FindFirstChild(randomName) or triesLeft <= 0

	if triesLeft <= 0 or game.Players:FindFirstChild(randomName) then
		return "AI" .. randomGenerator:NextInteger(1, 9999)
	end

	return randomName
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

return RandomNameGenerator

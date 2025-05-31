local AnimatedArrowManager = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Signals = require(Source:WaitForChild("Utils")).Signals
-- KnitServices

-- Instances

-- Configs

-- Variables

-- Tables
local animatedArrowState = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function AnimatedArrowManager.SetAnimatedArrowState(key, state)
	if animatedArrowState[key] ~= state then
		animatedArrowState[key] = state

		Signals.Fire("DispatchAction", {
			type = "SetActiveAnimatedArrows",
			value = { [key] = state },
		})
	end
end

function AnimatedArrowManager.SetAnimatedArrowsState(state: table)
	if type(state) ~= "table" then
		return
	end

	local newUpdate = false
	for eachKey, eachState in pairs(state) do
		if not newUpdate and animatedArrowState[eachKey] ~= eachState then
			newUpdate = true
		end

		animatedArrowState[eachKey] = eachState
	end

	if newUpdate then
		Signals.Fire("DispatchAction", {
			type = "SetActiveAnimatedArrows",
			value = state,
		})
	end
end

return AnimatedArrowManager

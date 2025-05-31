local Selector = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
-- local Source = ReplicatedStorage:WaitForChild("Source")
-- local Configs = Source:WaitForChild("Configs")
-- local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
-- local ReplicatedGameModules = Source:WaitForChild("GameModules")
-- local BaseControllers = Source:WaitForChild("BaseControllers")
-- local GameControllers = Source:WaitForChild("GameControllers")

-- Modulescripts -------------------------------------------------------------------
local RoSelect = require(Packages:WaitForChild("RoSelect"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local dynamicSelectorsCache = {}
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Creates a selector that maps state to props for a component. It requires a table that maps reducer names to keys. The result is a table that maps keys to values.
function Selector.Create(componentName, reducerKeyMap: table)
	if dynamicSelectorsCache[componentName] then
		return dynamicSelectorsCache[componentName]
	end

	-- Create individual input selectors for each reducer/keys combination
	local inputSelectors = {}
	local keyOrder = {}
	for reducer, keys in pairs(reducerKeyMap) do
		for _, key in ipairs(keys) do
			table.insert(inputSelectors, function(state)
				if state[reducer] then
					return state[reducer][key] or false
				else
					warn("Reducer '" .. reducer .. "' not found in state.")
					return nil
				end
			end)
			table.insert(keyOrder, key)
		end
	end

	-- Combine all input selectors into a single selector
	local selector = RoSelect.createSelector(inputSelectors, function(...)
		local result = {}
		for i, eachKey in ipairs(keyOrder) do
			result[eachKey] = select(i, ...) -- Get the index i from the args without ignoring nil values
		end

		return result
	end)

	dynamicSelectorsCache[componentName] = selector

	return selector
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Selector

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs

-- Variables
local sortByKey = "Score"
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function PlayerStatIsNotInOrder(state, player)
	if not state[player][sortByKey] then
		return true
	end

	local playerIndex = table.find(state.sortedPlayers, player)
	if not playerIndex then
		return true
	end

	local previousPlayer = state.sortedPlayers[playerIndex - 1]
	if
		previousPlayer
		and state[previousPlayer][sortByKey]
		and state[previousPlayer][sortByKey] < state[player][sortByKey]
	then
		return true
	end

	local nextPlayer = state.sortedPlayers[playerIndex + 1]
	if nextPlayer and state[nextPlayer][sortByKey] and state[nextPlayer][sortByKey] > state[player][sortByKey] then
		return true
	end

	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local LeaderstatsReducer = Rodux.createReducer({
	sortedPlayers = {},
}, {
	UpdateEntityLeaderstats = function(state, action)
		if not action.player then
			return state
		end

		local newPlayer = false
		local newState = Utils.Table.Copy(state)
		if action.player and not newState[action.player] then
			newState[action.player] = {}
			-- Add player to sortedPlayers
			newState.sortedPlayers = Utils.Table.Copy(state.sortedPlayers)
			Utils.Table.AddUniqueItem(newState.sortedPlayers, action.player)

			newPlayer = true
		end

		if action.leaderstats then
			newState[action.player] = Utils.Table.Copy(newState[action.player])
			for eachValueName, eachValue in pairs(action.leaderstats) do
				newState[action.player][eachValueName] = eachValue
			end

			if
				-- newPlayer
				-- or newState[action.player][sortByKey] ~= state[action.player][sortByKey]
				-- or PlayerStatIsNotInOrder(newState, action.player)
				newPlayer or PlayerStatIsNotInOrder(newState, action.player)
			then
				if newState[action.player][sortByKey] then
					-- Sort sortedPlayers depending on sortByKey
					if not newPlayer then
						newState.sortedPlayers = Utils.Table.Copy(state.sortedPlayers)
					end

					table.sort(newState.sortedPlayers, function(a, b)
						if not newState[a][sortByKey] then
							return false
						end
						if not newState[b][sortByKey] then
							return true
						end
						if newState[a][sortByKey] == newState[b][sortByKey] then
							return a.Name:upper() < b.Name:upper()
						end

						return newState[a][sortByKey] > newState[b][sortByKey]
					end)
				end
			end
		else
			newState[action.player] = nil
			-- Remove player to sortedPlayers
			newState.sortedPlayers = Utils.Table.Copy(state.sortedPlayers)
			Utils.Table.RemoveItem(newState.sortedPlayers, action.player)
		end

		newPlayer = nil

		return newState
	end,
})

return LeaderstatsReducer

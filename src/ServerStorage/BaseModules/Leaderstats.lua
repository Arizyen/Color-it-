local Leaderstats = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Connections = require(ReplicatedSource.Utils.Connections)
local Signals = require(ReplicatedSource.Utils.Signals)
local Utils = require(ReplicatedSource.Utils)

-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)
-- Instances

-- Configs
local _GET_TOP1_PLAYER = true
local _SORT_BY_KEY = "rank"

-- Variables
local previousTop1Entity

-- Tables
local valueTypeInstances = {
	number = "IntValue",
	string = "StringValue",
}

local leaderstatNames = { "level" }

local sortedEntities = {}
local entitiesValues = {}
---------------------------------------------
-- LOCAL FUNCTIONS -------------------------
---------------------------------------------
local function CreateLeaderstatsValue(valueName, leaderstatsFolder, value)
	local valueInstance = Instance.new(valueTypeInstances[type(value)])
	valueInstance.Name = valueName
	valueInstance.Value = value
	valueInstance.Parent = leaderstatsFolder

	return valueInstance
end

local function ReturnLeaderstatsValueInstance(valueName, leaderstatsFolder, value)
	local valueInstance = leaderstatsFolder:FindFirstChild(valueName)

	return valueInstance or CreateLeaderstatsValue(valueName, leaderstatsFolder, value)
end

local function SortChanged()
	if previousTop1Entity ~= sortedEntities[1] then
		previousTop1Entity = sortedEntities[1]
		Signals.Fire("Top1EntityChanged", sortedEntities[1])
	end
end

local function SortIsNotInOrder(player)
	if not entitiesValues[player][_SORT_BY_KEY] then
		return true
	end

	local playerIndex = table.find(sortedEntities, player)
	if not playerIndex then
		return true
	end

	local previousPlayer = sortedEntities[playerIndex - 1]
	if
		previousPlayer
		and entitiesValues[previousPlayer][_SORT_BY_KEY]
		and entitiesValues[previousPlayer][_SORT_BY_KEY] < entitiesValues[player][_SORT_BY_KEY]
	then
		return true
	end

	local nextPlayer = sortedEntities[playerIndex + 1]
	if
		nextPlayer
		and entitiesValues[nextPlayer][_SORT_BY_KEY]
		and entitiesValues[nextPlayer][_SORT_BY_KEY] > entitiesValues[player][_SORT_BY_KEY]
	then
		return true
	end

	return false
end

local function UpdateSort(player)
	if not player then
		return
	end

	if SortIsNotInOrder(player) then
		if entitiesValues[player][_SORT_BY_KEY] then
			table.sort(sortedEntities, function(a, b)
				if not entitiesValues[a][_SORT_BY_KEY] then
					return false
				end
				if not entitiesValues[b][_SORT_BY_KEY] then
					return true
				end
				if entitiesValues[a][_SORT_BY_KEY] == entitiesValues[b][_SORT_BY_KEY] then
					return a.Name:upper() < b.Name:upper()
				end

				return entitiesValues[a][_SORT_BY_KEY] > entitiesValues[b][_SORT_BY_KEY]
			end)

			SortChanged()
		end
	end
end

local function EntityLeaderstatValueChanged(player, leaderstatName, newValue)
	if not entitiesValues[player] then
		return
	end

	entitiesValues[player][leaderstatName] = newValue

	if _GET_TOP1_PLAYER and entitiesValues[player] then
		entitiesValues[player][leaderstatName] = player:GetAttribute(leaderstatName) or 0

		if leaderstatName == _SORT_BY_KEY then
			UpdateSort(player)
		end
	end
end
---------------------------------------------
-- GLOBAL FUNCTIONS -------------------------
---------------------------------------------
function Leaderstats.CreateLeaderstatsForPlayer(player)
	if not entitiesValues[player] then
		entitiesValues[player] = {}
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	if #sortedEntities == 0 then
		Signals.Fire("Top1EntityChanged", player)
	end

	table.insert(sortedEntities, player)

	for _, eachLeaderstatName in pairs(leaderstatNames) do
		local value = PlayersDataService:GetKeyValue(player, eachLeaderstatName)

		local valueInstance = ReturnLeaderstatsValueInstance(
			string.upper(string.sub(eachLeaderstatName, 1, 1)) .. string.sub(eachLeaderstatName, 2),
			leaderstats,
			value
		)

		Leaderstats.UpdateEntityLeaderstat(player, eachLeaderstatName, value)

		Connections.Add(
			player,
			eachLeaderstatName .. "LeaderstatObserver",
			PlayersDataService:ObservePlayerKey(player, eachLeaderstatName, function(newValue)
				if valueInstance then
					valueInstance.Value = newValue
					EntityLeaderstatValueChanged(player, eachLeaderstatName, valueInstance.Value)
				else
					valueInstance = Leaderstats.UpdateEntityLeaderstat(player, eachLeaderstatName, newValue)
				end
			end)
		)
	end
end

function Leaderstats.CreateLeaderstatsForAI(ai)
	if not entitiesValues[ai] then
		entitiesValues[ai] = {}
	end

	if #sortedEntities == 0 then
		Signals.Fire("Top1EntityChanged", ai)
	end

	table.insert(sortedEntities, ai)

	for _, eachLeaderstatName in pairs(leaderstatNames) do
		local valueInstance = ReturnLeaderstatsValueInstance(
			string.upper(string.sub(eachLeaderstatName, 1, 1)) .. string.sub(eachLeaderstatName, 2),
			ai.leaderstats,
			ai:GetAttribute(eachLeaderstatName)
		)

		Leaderstats.UpdateEntityLeaderstat(ai, eachLeaderstatName, ai:GetAttribute(eachLeaderstatName))

		Connections.Add(
			ai.UserId,
			eachLeaderstatName .. "ValueUpdated",
			ai:GetAttributeChangedSignal(eachLeaderstatName):Connect(function()
				if valueInstance then
					valueInstance.Value = ai:GetAttribute(eachLeaderstatName)
					EntityLeaderstatValueChanged(ai, eachLeaderstatName, valueInstance.Value)
				else
					valueInstance =
						Leaderstats.UpdateEntityLeaderstat(ai, eachLeaderstatName, ai:GetAttribute(eachLeaderstatName))
				end
			end)
		)
	end
end

function Leaderstats.UpdateEntityLeaderstat(player, leaderstatName, value)
	local valueInstance = ReturnLeaderstatsValueInstance(
		string.upper(string.sub(leaderstatName, 1, 1)) .. string.sub(leaderstatName, 2),
		player.leaderstats,
		value
	)
	valueInstance.Value = value

	EntityLeaderstatValueChanged(player, leaderstatName, value)

	return valueInstance
end
-- MISCELLANEOUS FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function Leaderstats.GetEntityAtRank(rank)
	return sortedEntities[rank]
end

function Leaderstats.EntityIsTop1(entity)
	return sortedEntities[1] == entity
end

function Leaderstats.ReturnLeaderstatsCount()
	return #sortedEntities
end
-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerAdded", function(player)
	Leaderstats.CreateLeaderstatsForPlayer(player)
end)

Signals.Connect("PlayerRemoving", function(player)
	Utils.Table.RemoveItem(sortedEntities, player)
	entitiesValues[player] = nil
	SortChanged()
end)

Signals.Connect("AIRemoving", function(ai)
	Utils.Table.RemoveItem(sortedEntities, ai)
	entitiesValues[ai] = nil
	SortChanged()
end)

return Leaderstats

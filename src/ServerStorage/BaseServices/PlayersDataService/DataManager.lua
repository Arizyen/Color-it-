local DataManager = {}
DataManager.__index = DataManager
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local Configs = ReplicatedStorage.Source.Configs
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
local GameServices = ServerStorage.Source.GameServices

-- Modulescripts -------------------------------------------------------------------
local DataObserver = require(ReplicatedBaseModules.DataObserver)
local EntitiesData = require(BaseModules.EntitiesData)
local Utils = require(ReplicatedStorage.Source.Utils)
-- KnitServices --------------------------------------------------------------------

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
function DataManager.new(playersDataService)
	local self = setmetatable({}, DataManager)
	self.PlayersDataService = playersDataService

	return self
end

-- GET ----------------------------------------------------------------------------------------------------
function DataManager:GetPlayerData(playerUserId: number): table?
	return EntitiesData.data[playerUserId]
end

function DataManager:GetKeyValue(playerUserId: number, key, index)
	if key and EntitiesData.data[playerUserId] then
		if not index then
			return EntitiesData.data[playerUserId][key]
		else
			if EntitiesData.data[playerUserId][key] then
				return EntitiesData.data[playerUserId][key][index]
			end
		end
	end

	return nil
end

function DataManager:GetKeysValue(playerUserId: number, keys): table
	if type(keys) == "table" and EntitiesData.data[playerUserId] then
		local values = {}
		for _, eachKey in pairs(keys) do
			values[eachKey] = EntitiesData.data[playerUserId][eachKey]
		end
		return values
	end

	return nil
end

function DataManager:FindKeyValueIndex(playerUserId: number, key, value)
	if playerUserId and key and value then
		local playerKeyValue = self:GetKeyValue(playerUserId, key)
		if playerKeyValue then
			if #playerKeyValue > 0 then
				return table.find(playerKeyValue, value)
			else
				for index, eachValue in pairs(playerKeyValue) do
					if eachValue == value then
						return index
					end
				end
			end
		end
	end

	return nil
end

-- SET ----------------------------------------------------------------------------------------------------
function DataManager:SetKeyValue(player, key, value, index, noUpdateToPlayer): boolean
	if not player or not key or not EntitiesData.data[player.UserId] then
		return false
	end

	local playerUserId = player.UserId

	local oldValue = EntitiesData.data[playerUserId][key]
	if DataObserver.IsObservingKey(key) and type(oldValue) == "table" then
		oldValue = Utils.DeepCopy(oldValue)
	end

	if not index then
		EntitiesData.data[playerUserId][key] = value
		self.PlayersDataService:PlayerKeyValueUpdated(player, key, value, nil, nil, noUpdateToPlayer)

		DataObserver.Notify(player, key, value, oldValue)

		return true
	else
		if not EntitiesData.data[playerUserId][key] then
			EntitiesData.data[playerUserId][key] = {}
		end
		local playerKeyValue = EntitiesData.data[playerUserId][key]

		if type(index) == "number" then
			if value then
				table.insert(playerKeyValue, index, value)
				self.PlayersDataService:PlayerKeyValueUpdated(player, key, value, index, "add", noUpdateToPlayer)
				DataObserver.Notify(player, key, playerKeyValue, oldValue, "add", index)
			else
				table.remove(playerKeyValue, index)
				self.PlayersDataService:PlayerKeyValueUpdated(player, key, value, index, "remove", noUpdateToPlayer)
				DataObserver.Notify(player, key, playerKeyValue, oldValue, "remove", index)
			end
		elseif type(index) == "string" then
			playerKeyValue[index] = value
			self.PlayersDataService:PlayerKeyValueUpdated(player, key, value, index, "update", noUpdateToPlayer)
			DataObserver.Notify(player, key, playerKeyValue, oldValue, "update", index)
		elseif value then
			table.insert(playerKeyValue, value)
			self.PlayersDataService:PlayerKeyValueUpdated(player, key, value, nil, "add", noUpdateToPlayer)
			DataObserver.Notify(player, key, playerKeyValue, oldValue, "add")
		end

		return true
	end
end

function DataManager:IncrementKeyValue(player, key, index, increment): boolean
	if
		not player
		or not key
		or not EntitiesData.data[player.UserId]
		or not EntitiesData.data[player.UserId][key]
		or increment == 0
	then
		return false
	end

	local playerUserId = player.UserId

	increment = increment or 1

	if not index then
		if type(EntitiesData.data[playerUserId][key]) ~= "number" then
			EntitiesData.data[playerUserId][key] = 0
		end

		if EntitiesData.data[playerUserId][key] + increment < 0 then
			return false
		end

		local oldValue = EntitiesData.data[playerUserId][key]

		EntitiesData.data[playerUserId][key] += increment
		self.PlayersDataService:PlayerKeyValueUpdated(player, key, EntitiesData.data[playerUserId][key])

		DataObserver.Notify(player, key, EntitiesData.data[playerUserId][key], oldValue)

		return true
	else
		if type(EntitiesData.data[playerUserId][key]) ~= "table" then
			return false
		end

		if type(EntitiesData.data[playerUserId][key][index]) ~= "number" then
			EntitiesData.data[playerUserId][key][index] = 0
		end

		if EntitiesData.data[playerUserId][key][index] + increment < 0 then
			return false
		end

		local oldValue = EntitiesData.data[playerUserId][key][index]

		EntitiesData.data[playerUserId][key][index] += increment
		self.PlayersDataService:PlayerKeyValueUpdated(
			player,
			key,
			EntitiesData.data[playerUserId][key][index],
			index,
			"update"
		)

		DataObserver.Notify(player, key, EntitiesData.data[playerUserId][key][index], oldValue, "update", index)

		return true
	end
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return DataManager

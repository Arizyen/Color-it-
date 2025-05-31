local DataStore = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Folders
local ReplicatedSource = ReplicatedStorage.Source
local BaseModules = ServerStorage.Source.BaseModules

-- Modulescripts
local EntitiesData = require(BaseModules.EntitiesData)
local Signals = require(ReplicatedSource.Utils.Signals)

-- KnitServices

-- Instances

-- Configs
local _MAX_RETRIES = 3
local _DATA_INTERVAL_WAIT = 3
local _DATA_STORE_VERSION = "DataV1"

-- Variables
DataStore.playersData = DataStoreService:GetDataStore(_DATA_STORE_VERSION)

-- Tables
DataStore.dataStores = {
	DataStore.playersData,
}
DataStore.dataStoresDataLocation = {
	[_DATA_STORE_VERSION] = EntitiesData.data,
}
------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
-- SAVING DATA -----------------------------------------------------------------------------------------------------------------------------------
local function ReturnDataRequested(dataStore, playerUserId)
	if dataStore and DataStore.dataStoresDataLocation[dataStore.Name] ~= nil then
		return DataStore.dataStoresDataLocation[dataStore.Name][playerUserId]
			or (
				type(playerUserId) == "userdata"
				and DataStore.dataStoresDataLocation[dataStore.Name][playerUserId.UserId]
			)
	else
		print("Datastore not found")
	end
end

function DataStore.Save(dataStore, data, userId, maxRetries, currentRetries)
	if not data then
		data = ReturnDataRequested(dataStore, userId)
	end
	if not data then
		-- print("Data received is nil: " .. dataStore.Name)
		if userId and dataStore and dataStore.Name then
			Signals.Fire(userId .. dataStore.Name, false)
		end

		return false
	end

	local success, err = pcall(function()
		dataStore:SetAsync(userId, data)
	end)
	if success then
		Signals.Fire(userId .. dataStore.Name, true)
		return true
	else
		-- print("DATA DID NOT SAVE", dataStore.Name, err, data)
		currentRetries = currentRetries or 0
		if currentRetries < (maxRetries or _MAX_RETRIES) then
			currentRetries += 1
			task.wait(_DATA_INTERVAL_WAIT)
			return DataStore.Save(dataStore, nil, userId, maxRetries, currentRetries)
		else
			Signals.Fire(userId .. dataStore.Name, false)
			return false
		end
	end
end

-- LOADING DATA -----------------------------------------------------------------------------------------------------------------------------------
local function GetPlayerData(dataStore, player)
	local data
	local success, err = pcall(function()
		data = dataStore:GetAsync(player.UserId)
	end)

	if success then
		return data
	else
		return nil, err
	end
end
-- YIELDING FUNCTION / LOADING REQUESTED PLAYER DATA
function DataStore.Load(player, dataStore, retries) -- returns success, data
	if not player or not dataStore then
		print("DataStore.Load ERROR: Player or dataStore is nil")
		return false
	end

	local data, err = GetPlayerData(dataStore, player)

	if not EntitiesData.playersDataLoaded[player.UserId] then
		EntitiesData.playersDataLoaded[player.UserId] = {}
	end

	retries = retries or 0

	if err then
		EntitiesData.playersDataLoaded[player.UserId][dataStore.Name] = false
		print("Data: " .. dataStore.Name .. " loading error. Error code: " .. tostring(err))

		if player and retries < _MAX_RETRIES then
			retries += 1
			task.wait(_DATA_INTERVAL_WAIT)
			return DataStore.Load(player, dataStore, retries)
		else
			warn("DATA OF PLAYER " .. player.Name .. " WAS NOT LOADED SUCCESSFULLY. KICKING PLAYER.")
			player:Kick("[ERROR] Your data did not load properly. Roblox is having issues. Please join again.")
			return false
		end
	end
	-- print("Data loaded: ", dataStore.Name)
	EntitiesData.playersDataLoaded[player.UserId][dataStore.Name] = true

	return true, data
end

-- Simply gets data and returns it, no saving
function DataStore.ReturnData(player, dataStore, maxRetries, currentRetries) -- returns success, data
	local data, err = GetPlayerData(dataStore, player)

	currentRetries = currentRetries or 0

	if err then
		if not string.find(string.sub(err, 1, 10), "404") or not string.find(string.sub(err, 1, 10), "503") then
			print("Data: " .. dataStore.Name .. " loading error. Error code: " .. tostring(err))

			if player and maxRetries and currentRetries < _MAX_RETRIES then
				currentRetries += 1
				task.wait(_DATA_INTERVAL_WAIT)
				return DataStore.ReturnData(player, dataStore, maxRetries, currentRetries)
			else
				return false
			end
		end
	end

	return true, data
end

-- UTIL FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function DataStore.CreateOrderedDataStore(dataStoreName, dataLocation)
	local orderedDataStore = DataStoreService:GetOrderedDataStore(dataStoreName)
	table.insert(DataStore.dataStores, orderedDataStore)
	DataStore.dataStoresDataLocation[dataStoreName] = dataLocation or EntitiesData.data

	return orderedDataStore
end

function DataStore.RemoveDataStore(dataStore)
	if table.find(DataStore.dataStores, dataStore) then
		table.remove(DataStore.dataStores, table.find(DataStore.dataStores, dataStore))

		if DataStore.dataStoresDataLocation[dataStore.Name] then
			DataStore.dataStoresDataLocation[dataStore.Name] = nil
		end

		-- Destroy signals for all players
		for _, player in pairs(game.Players:GetPlayers()) do
			Signals.Destroy(player.UserId .. dataStore.Name)
		end
	end
end

return DataStore

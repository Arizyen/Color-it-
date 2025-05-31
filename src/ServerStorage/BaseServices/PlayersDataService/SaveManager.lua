local SaveManager = {}
SaveManager.__index = SaveManager
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local BaseModules = ServerStorage.Source.BaseModules

-- Modulescripts -------------------------------------------------------------------
local Promise = require(Packages.Promise)
local DataStore = require(BaseModules.DataStore)
local EntitiesData = require(BaseModules.EntitiesData)
local Signals = require(ReplicatedSource.Utils.Signals)
-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local SAVE_WAIT = 8

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local dataStoreTimerTable = {}
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function SaveManager.new(playersDataService)
	local self = setmetatable({}, SaveManager)
	self.PlayersDataService = playersDataService
	self:StartDataStoreTimer()

	return self
end

function SaveManager:ReturnSaveWaitTime(playerUserId, dataStore, customSaveDelay)
	customSaveDelay = customSaveDelay or SAVE_WAIT

	if dataStoreTimerTable[dataStore.Name .. "," .. playerUserId] then
		return customSaveDelay
	else
		local lastSavedTimes =
			self.PlayersDataService:GetKeyValue(Players:GetPlayerByUserId(playerUserId), "lastSavedTimes")
		if lastSavedTimes and type(lastSavedTimes[dataStore.Name]) == "number" then
			if os.time() - lastSavedTimes[dataStore.Name] > customSaveDelay then
				return 0
			else
				return customSaveDelay - (os.time() - lastSavedTimes[dataStore.Name])
			end
		else
			return customSaveDelay
		end
	end
end

function SaveManager:SaveRequestExecuted(playerUserId, dataStore)
	dataStoreTimerTable[dataStore.Name .. "," .. playerUserId] = nil

	playerUserId = tonumber(playerUserId)
	if playerUserId then
		self.PlayersDataService:SetKeyIndexValue(
			Players:GetPlayerByUserId(playerUserId),
			"lastSavedTimes",
			dataStore.Name,
			os.time()
		)
	end
end

function SaveManager:HasNoDataStoreSaveRequest(playerUserId, dataStore)
	return dataStoreTimerTable[dataStore.Name .. "," .. playerUserId] == nil
end

function SaveManager:ExecuteSaveRequest(dataStoreName, playerUserId)
	for _, eachDataStore in pairs(DataStore.dataStores) do
		if eachDataStore.Name == dataStoreName then
			if self:CanSave(playerUserId, eachDataStore) then
				self:SaveRequestExecuted(playerUserId, eachDataStore)
				DataStore.Save(eachDataStore, nil, playerUserId, 3)
			else
				self:AddPlayerSaveRequest(
					playerUserId,
					eachDataStore,
					self:ReturnSaveWaitTime(playerUserId, eachDataStore) or SAVE_WAIT
				)
			end

			break
		end
	end
end

function SaveManager:CanSave(playerUserId, dataStore, customSaveDelay)
	customSaveDelay = customSaveDelay or SAVE_WAIT

	local lastSavedTimes =
		self.PlayersDataService:GetKeyValue(Players:GetPlayerByUserId(playerUserId), "lastSavedTimes")
	if lastSavedTimes then
		if type(lastSavedTimes[dataStore.Name]) == "number" then
			if os.time() - lastSavedTimes[dataStore.Name] >= customSaveDelay then
				return true
			else
				return false
			end
		else
			return true
		end
	else
		if dataStoreTimerTable[dataStore.Name .. "," .. playerUserId] then
			return false
		else
			return true
		end
	end
end

function SaveManager:SavePlayerData(player, dataStore, data, ignoreTimer, maxRetries, customSaveDelay) --> Returns a promise with a boolean success value
	return Promise.new(function(resolve)
		if
			not dataStore
			or not player
			or not EntitiesData.playersDataLoaded[player.UserId]
			or not EntitiesData.playersDataLoaded[player.UserId][dataStore.Name]
			or (EntitiesData.data[player.UserId] and EntitiesData.data[player.UserId].isNPC)
		then
			-- print("Could not save", dataStore, EntitiesData.playersDataLoaded[player.UserId][dataStore.Name], player)
			return resolve(false)
		end

		if
			ignoreTimer
			or (
				self:HasNoDataStoreSaveRequest(player.UserId, dataStore)
				and self:CanSave(player.UserId, dataStore, customSaveDelay)
			)
		then
			self:SaveRequestExecuted(player.UserId, dataStore)
			local success = DataStore.Save(dataStore, data, player.UserId, maxRetries)

			return resolve(success)
		else
			self:AddPlayerSaveRequest(
				player.UserId,
				dataStore,
				self:ReturnSaveWaitTime(player.UserId, dataStore, customSaveDelay)
			)
			local success = Signals.Wait(player.UserId .. dataStore.Name) -- No need to retry since DataStore.Save does it and fires only after it's done

			return resolve(success)
		end
	end):catch(function(err)
		warn(tostring(err))
		return false
	end)
end

function SaveManager:AddPlayerSaveRequest(playerUserId, dataStore, customSaveDelay)
	if
		not playerUserId
		or not dataStore
		or not EntitiesData.playersDataLoaded[playerUserId]
		or not EntitiesData.playersDataLoaded[playerUserId][dataStore.Name]
	then
		return
	end

	if not self:HasNoDataStoreSaveRequest(playerUserId, dataStore) then
		return
	end

	customSaveDelay = self:ReturnSaveWaitTime(playerUserId, dataStore, customSaveDelay) or SAVE_WAIT

	if
		not dataStoreTimerTable[dataStore.Name .. "," .. playerUserId]
		or dataStoreTimerTable[dataStore.Name .. "," .. playerUserId] > customSaveDelay
	then
		dataStoreTimerTable[dataStore.Name .. "," .. playerUserId] = customSaveDelay
	end
end

function SaveManager:StartDataStoreTimer()
	local strings
	task.spawn(function()
		while true do
			task.wait(1)
			for key, value in pairs(dataStoreTimerTable) do
				if dataStoreTimerTable[key] <= 0 then
					dataStoreTimerTable[key] = nil
					strings = string.split(key)
					if strings[1] and strings[2] then
						self:ExecuteSaveRequest(strings[1], tonumber(strings[2]))
					end
				else
					dataStoreTimerTable[key] = value - 1
				end
			end
		end
	end)
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return SaveManager

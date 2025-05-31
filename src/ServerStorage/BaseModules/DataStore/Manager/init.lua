local Manager = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Folders
local ReplicatedSource = ReplicatedStorage.Source
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedSource.BaseModules
local Keys = ReplicatedSource.Keys
local BaseServices = ServerStorage.Source.BaseServices
local GameServices = ServerStorage.Source.GameServices

-- Modulescripts
local DataStore = require(BaseModules.DataStore)
local EntitiesData = require(BaseModules.EntitiesData)
local Signals = require(ReplicatedSource.Utils.Signals)
local Moderation = require(BaseModules.Moderation)
local LeaderboardKeys = require(Keys.LeaderboardKeys)

-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)
local LeaderboardService = require(BaseServices.LeaderboardService)

-- Instances

-- Configs

-- Variables

-- Tables
Manager.Gamepass = require(script.Gamepass)

local playersRemoving = {} -- tostring(userId) == value
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

-- INITIALIZING PLAYER DATA -----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Manager.PlayerAdded(player)
	if playersRemoving[tostring(player.UserId)] then
		repeat
			task.wait()
		until not playersRemoving[tostring(player.UserId)]

		if not player or player.Parent ~= Players then
			return
		end
	end

	-- Load player data
	if not Manager.LoadPlayerData(player) then
		return false
	end

	-- Load player ordered data
	if not Manager.LoadOrderedDataStores(player) then
		return false
	end

	if player.Parent ~= Players then
		return false
	end

	PlayersDataService:PlayerDataLoaded(player)

	if PlayersDataService:GetKeyValue(player, "newPlayer") then
		PlayersDataService:SavePlayerData(player, DataStore.playersData)
	end

	-- Create a signal for each data store for the player
	for _, eachDataStore in pairs(DataStore.dataStores) do
		Signals.Add(player.UserId .. eachDataStore.Name)
	end

	return true
end

function Manager.PlayerRemoving(player, ignoreTimer)
	-- Save all their data
	if not player or not player:IsA("Player") or playersRemoving[tostring(player.UserId)] then
		return
	end

	playersRemoving[tostring(player.UserId)] = true

	local dataSavesInfos = {
		{ player, DataStore.playersData, nil, ignoreTimer },
	}
	-- Add sorted data stores
	for _, eachLeaderboardKey in pairs(LeaderboardKeys) do
		table.insert(dataSavesInfos, {
			player,
			LeaderboardService.dataStores[eachLeaderboardKey].allTime,
			EntitiesData.sortedData[eachLeaderboardKey].allTime[player.UserId],
			ignoreTimer,
		})
		table.insert(dataSavesInfos, {
			player,
			LeaderboardService.dataStores[eachLeaderboardKey].weekly,
			EntitiesData.sortedData[eachLeaderboardKey].weekly[player.UserId],
			ignoreTimer,
		})
	end

	local count = 0
	for _, eachDataSaveInfo in ipairs(dataSavesInfos) do
		PlayersDataService:SavePlayerData(table.unpack(eachDataSaveInfo)):andThen(function()
			count += 1
		end)
	end

	if ignoreTimer then
		-- Disconnect player datastore Signals
		for _, eachDataStore in pairs(DataStore.dataStores) do
			Signals.Destroy(player.UserId .. eachDataStore.Name)
		end

		PlayersDataService:PlayerRemoving(player)
		playersRemoving[tostring(player.UserId)] = nil
	else
		task.spawn(function()
			local startTime = os.clock()
			repeat
				task.wait(0.5)
			until count >= #dataSavesInfos or (os.clock() - startTime) > 8 + (#dataSavesInfos * 3)
			-- print(count, "total time spent: ", os.clock() - startTime)
			-- Disconnect player datastore Signals
			for _, eachDataStore in pairs(DataStore.dataStores) do
				Signals.Destroy(player.UserId .. eachDataStore.Name)
			end

			PlayersDataService:PlayerRemoving(player)
			playersRemoving[tostring(player.UserId)] = nil
		end)
	end
end
-- SAVE PLAYER DATA -----------------------------------------------------------------------------------------------------------------------------------
function Manager.SavePlayerData(player, dataStore, data, ignoreTimer, maxRetries)
	return PlayersDataService:SavePlayerData(player, dataStore, data, ignoreTimer, maxRetries)
end

-- LOAD PLAYER DATA -----------------------------------------------------------------------------------------------------------------------------------
function Manager.GetPlayerData(player)
	local _, data = DataStore.ReturnData(player, DataStore.playersData, 1)
	return data
end

function Manager.LoadPlayerData(player)
	local success, data = DataStore.Load(player, DataStore.playersData)

	if not success or not player or player.Parent ~= game.Players then
		return false
	end

	local returningPlayer = false
	if type(data) == "table" then
		returningPlayer = true
	end

	data = PlayersDataService:InitializePlayerData(player, data)

	if Moderation.IsPlayerBanned(player) then
		return false
	end

	Manager.Gamepass.Verify(player)

	PlayersDataService:FirePlayerData(player)

	PlayersDataService:SetKeyIndexValue(player, "lastSavedTimes", DataStore.playersData.Name, os.time())
	PlayersDataService:SetKeyValue(player, "serverJoinTime", os.time())

	if returningPlayer then
		-- PlayerManager.Badges.Award(player, "ReturningPlayer", "Special", true)
	end

	Signals.Fire("PlayerDataLoaded", player)

	return true
end

function Manager.LoadOrderedDataStores(player): boolean
	for _, eachLeaderboardKey in pairs(LeaderboardKeys) do
		-- Load total
		local success, data = DataStore.Load(player, LeaderboardService.dataStores[eachLeaderboardKey].allTime)
		if not success then
			print("ERROR: Manager.LoadOrderedDataStores: Failed to load total data", eachLeaderboardKey)
			return false
		end

		if data ~= nil then
			EntitiesData.sortedData[eachLeaderboardKey].allTime[player.UserId] = data
		else
			EntitiesData.sortedData[eachLeaderboardKey].allTime[player.UserId] = 0
		end

		-- Load weekly
		success, data = DataStore.Load(player, LeaderboardService.dataStores[eachLeaderboardKey].weekly)
		if not success then
			print("ERROR: Manager.LoadOrderedDataStores: Failed to load weekly data", eachLeaderboardKey)
			return false
		end

		if data ~= nil then
			EntitiesData.sortedData[eachLeaderboardKey].weekly[player.UserId] = data
		else
			EntitiesData.sortedData[eachLeaderboardKey].weekly[player.UserId] = 0
		end
	end

	-- Update weekly data based on ordered data stores
	Manager.UpdateWeeklyDataValues(player)

	return true
end
-- UPDATE WEEKLY DATA -----------------------------------------------------------------------------------------------------------------------------------
function Manager.UpdateWeeklyDataValues(player)
	for _, eachLeaderboardKey in pairs(LeaderboardKeys) do
		PlayersDataService:SetKeyValue(
			player,
			"weekly" .. eachLeaderboardKey,
			EntitiesData.sortedData[eachLeaderboardKey].weekly[player.UserId]
		)
	end
end

return Manager

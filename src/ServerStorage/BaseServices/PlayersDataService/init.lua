-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Folders
local Packages = ReplicatedStorage.Packages
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
local Keys = ReplicatedStorage.Source.Keys

-- Modulescripts
local Knit = require(Packages.Knit)
local EntitiesData = require(BaseModules.EntitiesData)
local DataStore = require(BaseModules.DataStore)
local Utils = require(ReplicatedStorage.Source.Utils)
local DataManager = require(script.DataManager)
local SaveManager = require(script.SaveManager)
local LeaderboardKeys = require(Keys.LeaderboardKeys)
local DataKeys = require(script.DataKeys)
local ClientKeys = require(Keys.ClientDataKeys) -- Must update whenever a new key is added
local DataObserver = require(ReplicatedBaseModules.DataObserver)
local Observer = require(ReplicatedBaseModules.DataObserver.Observer)

-- KnitServices
local PlayersDataService = Knit.CreateService({
	Name = "PlayersData",
	Client = {
		DataLoaded = Knit.CreateSignal(), -- Fires when a player's data is loaded
		UpdateData = Knit.CreateSignal(), -- Fires all of a player's data to them
		UpdatePlayerData = Knit.CreateSignal(), -- Fire all of a player's data to all other players
		UpdatePlayerKeyValue = Knit.CreateSignal(), -- Fires all players a player's data key value
		UpdateKeyValue = Knit.CreateSignal(), -- Fires player a key/value
		ReturnClientKeys = Knit.CreateSignal(), -- Fires player all client keys
	},
})

-- Instances

-- Configs
local _GROUP_ID = 123

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function InitializeData(data)
	if typeof(data) ~= "table" then
		data = {}
	end

	-- Keys to reset on load
	for _, eachKeyToReset in pairs(DataKeys.keysToResetOnLoad) do
		data[eachKeyToReset] = nil
	end

	-- Set default values first
	for eachKey, eachValue in pairs(DataKeys.defaultValues) do
		if data[eachKey] == nil then
			if type(eachValue) == "table" then
				data[eachKey] = Utils.Table.DeepCopy(eachValue)
			elseif type(eachValue) == "function" then
				data[eachKey] = eachValue(data)
			else
				data[eachKey] = eachValue
			end
		end
	end

	-- Keys.booleans
	for _, eachBoolValue in pairs(DataKeys.booleans) do
		if type(data[eachBoolValue]) ~= "boolean" then
			data[eachBoolValue] = false
		end
	end

	-- Keys.numbers
	for _, eachValue in pairs(DataKeys.numbers) do
		if not data[eachValue] then
			data[eachValue] = 0
		end
	end

	-- Keys.tables
	for _, eachTableValue in pairs(DataKeys.tables) do
		if typeof(data[eachTableValue]) ~= "table" then
			data[eachTableValue] = {}
		end
	end

	return data
end

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayersDataService:KnitInit()
	self.saveManager = SaveManager.new(PlayersDataService)
	self.dataManager = DataManager.new(PlayersDataService)
end

function PlayersDataService:KnitStart() end
-- MODULE FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------

-- PLAYER JOINING/LEAVING -----------------------------------------------------------------------------------------------------------------------------
function PlayersDataService:InitializePlayerData(player, data)
	EntitiesData.data[player.UserId] = InitializeData(data)
	for _, eachLeaderboardKey in pairs(LeaderboardKeys) do
		EntitiesData.sortedData[eachLeaderboardKey].allTime[player.UserId] = 0
		EntitiesData.sortedData[eachLeaderboardKey].weekly[player.UserId] = 0
	end

	return EntitiesData.data[player.UserId]
end

function PlayersDataService:PlayerRemoving(player)
	EntitiesData.data[player.UserId] = nil

	for _, eachLeaderboardKey in pairs(LeaderboardKeys) do
		EntitiesData.sortedData[eachLeaderboardKey].allTime[player.UserId] = nil
		EntitiesData.sortedData[eachLeaderboardKey].weekly[player.UserId] = nil
	end

	EntitiesData.playersDataLoaded[player.UserId] = nil
end

function PlayersDataService:InitializeNPCData(npc, data)
	EntitiesData.data[npc.UserId] = InitializeData(data)
	EntitiesData.data[npc.UserId].isNPC = true
end

function PlayersDataService:NPCRemoving(npc)
	EntitiesData.data[npc.UserId] = nil
end

-- SAVE PLAYER DATA -----------------------------------------------------------------------------------------------------------------------------------
function PlayersDataService:SavePlayerData(player, dataStore, data, ignoreTimer, maxRetries)
	return self.saveManager:SavePlayerData(player, dataStore, data, ignoreTimer, maxRetries)
end

function PlayersDataService:SavePlayerDefaultData(saveData, player, ignoreTimer, maxRetries)
	if saveData and not EntitiesData.data[player.UserId].isNPC then
		return self.saveManager:SavePlayerData(
			player,
			DataStore.playersData,
			EntitiesData.data[player.UserId],
			ignoreTimer,
			maxRetries
		)
	end

	return true
end

-- DATA REPLICATION FUNCTIONS --------------------------------------------------------------------------------------------------------------------------
-- Fire a player's data to them
function PlayersDataService:FirePlayerData(player)
	if not EntitiesData.data[player.UserId] then
		return
	end

	local playerData = {}
	for eachDataKey, eachDataValue in pairs(EntitiesData.data[player.UserId]) do
		if not DataKeys.keysNotToReplicate[eachDataKey] then
			playerData[eachDataKey] = eachDataValue
		end
	end
	self.Client.UpdateData:Fire(player, playerData)
end

-- Let player know their data is loaded and replicate it to others
function PlayersDataService:PlayerDataLoaded(player)
	if type(player) == "userdata" and type(EntitiesData.data[player.UserId]) == "table" then
		-- Fire to player that their data is loaded
		self.Client.DataLoaded:Fire(player)

		-- Replicate player's data to all other players
		local playerData = {}
		for eachKey, _ in pairs(DataKeys.keysToShareWithOthers) do
			playerData[eachKey] = EntitiesData.data[player.UserId][eachKey]
		end
		self.Client.UpdatePlayerData:FireExcept(player, player, playerData)
	end
end

-- Fire to newly added player all other players data
function PlayersDataService:GetAllPlayersReplicatableData(player)
	if type(player) == "userdata" then
		return
	end

	local allPlayersData = {}
	for eachPlayer, eachPlayerData in pairs(EntitiesData.data) do
		if eachPlayer ~= player then
			local playerData = {}
			for eachKey, _ in pairs(DataKeys.keysToShareWithOthers) do
				playerData[eachKey] = eachPlayerData[eachKey]
			end
			table.insert(allPlayersData, playerData)
		end
	end
	return allPlayersData
end

-- Fire the player's key value to them
function PlayersDataService:FirePlayerKey(player, key)
	if player and key and EntitiesData.data[player.UserId] and not player:GetAttribute("isNPC") then
		self:FirePlayerKeyValue(player, key, EntitiesData.data[player.UserId][key])
	end
end

function PlayersDataService:FirePlayerKeyValue(player, key, value, updateType, index)
	if key and not DataKeys.keysNotToReplicate[key] then
		self.Client.UpdateKeyValue:Fire(player, key, value, updateType, index)
	end
end

-- Replicate key data value of a player to all players (if the key is replicatable or else to only the player itself)
function PlayersDataService:FirePlayersKeyValue(player, key, value, updateType, index, noUpdateToPlayer)
	if not DataKeys.keysNotToReplicate[key] and not player:GetAttribute("isNPC") then
		if not noUpdateToPlayer then
			self.Client.UpdatePlayerKeyValue:FireAll(player, key, value, updateType, index)
		else
			self.Client.UpdatePlayerKeyValue:FireExcept(player, player, key, value, updateType, index)
		end
	end
end

function PlayersDataService:PlayerKeyValueUpdated(player, key, value, index, updateType, noUpdateToPlayer)
	if not player or player:GetAttribute("isNPC") or DataKeys.keysNotToReplicate[key] then
		return
	end

	if DataKeys.keysToShareWithOthers[key] then
		self:FirePlayersKeyValue(player, key, value, updateType, index, noUpdateToPlayer)
	else
		self:FirePlayerKeyValue(player, key, value, updateType, index)
	end
end
-- SET FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayersDataService:SetKeyValue(player, key, value, saveData, ignoreTimer, maxRetries)
	if self.dataManager:SetKeyValue(player, key, value, nil) then
		return self:SavePlayerDefaultData(saveData, player, ignoreTimer, maxRetries)
	end

	return false
end

function PlayersDataService:SetKeyIndexValue(player, key, index, value, saveData, ignoreTimer, maxRetries)
	if self.dataManager:SetKeyValue(player, key, value, index or {}) then
		return self:SavePlayerDefaultData(saveData, player, ignoreTimer, maxRetries)
	end

	return false
end

function PlayersDataService:IncrementKeyValue(player, key, increment, saveData, ignoreTimer, maxRetries)
	if self.dataManager:IncrementKeyValue(player, key, nil, increment) then
		return self:SavePlayerDefaultData(saveData, player, ignoreTimer, maxRetries)
	end

	return false
end

function PlayersDataService:IncrementKeyIndexValue(player, key, index, increment, saveData, ignoreTimer, maxRetries)
	if self.dataManager:IncrementKeyValue(player, key, index, increment) then
		return self:SavePlayerDefaultData(saveData, player, ignoreTimer, maxRetries)
	end

	return false
end
-- GET FUNCTIONS ----------------------------------------------------------------------------------------------------
function PlayersDataService:GetPlayerData(player: Player)
	return self.dataManager:GetPlayerData(player.UserId)
end

function PlayersDataService:GetKeyValue(player: Player, key: string, index: number | string?)
	return self.dataManager:GetKeyValue(player.UserId, key, index)
end

function PlayersDataService:GetKeysValue(player: Player, keys): table
	return self.dataManager:GetKeysValue(player.UserId, keys)
end

-- Will return the index at which the value is found
function PlayersDataService:FindKeyValueIndex(player: Player, key, value)
	return self.dataManager:FindKeyValueIndex(player.UserId, key, value)
end

-- CONNECTIONS ----------------------------------------------------------------------------------------------------
function PlayersDataService:ObservePlayerKey(
	player: Player,
	key: any,
	callback: DataObserver.Callback
): DataObserver.Observer
	if not player or not key or not callback then
		return
	end

	return DataObserver.Observe(player, key, callback)
end

-- GAMEPASS -----------------------------------------------------------------------------------------------------------------------------------
function PlayersDataService:OwnsGamepass(player, gamepassKey)
	local gamepasses = PlayersDataService:GetKeyValue(player, "gamepasses")
	if gamepasses and gamepasses[gamepassKey] then
		return true
	else
		return false
	end
end
-- MISC FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------
function PlayersDataService:PlayerIsInGroup(player, tries)
	if not player or not player:IsA("Player") then
		return
	end

	local success, playerIsInGroup = pcall(function()
		return player:IsInGroup(_GROUP_ID)
	end)

	if not success then
		if not tries then
			tries = 0
		end
		tries += 1
		if tries >= 3 then
			return
		end
		task.wait(3)
		return self:PlayerIsInGroup(player, tries)
	else
		return playerIsInGroup
	end
end

function PlayersDataService:GetRoleOfPlayerInGroup(player, tries)
	if not player or not player:IsA("Player") then
		return
	end

	local success, playerRoleInGroup = pcall(function()
		return player:GetRoleInGroup(_GROUP_ID)
	end)

	if not success then
		if not tries then
			tries = 0
		end
		tries += 1
		if tries >= 3 then
			return
		end
		task.wait(3)
		return self:GetRoleOfPlayerInGroup(player, tries)
	else
		return playerRoleInGroup
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
function PlayersDataService.Client:GetPlayerData(_, player)
	local playerData = {}
	if EntitiesData.data[player.UserId] then
		for eachKey, _ in pairs(DataKeys.keysToShareWithOthers) do
			playerData[eachKey] = EntitiesData.data[player.UserId][eachKey]
		end
	end
	return playerData
end

function PlayersDataService.Client:SetKeyValue(playerFired, key, value)
	if not playerFired or not ClientKeys.keys[key] or (type(value) ~= ClientKeys.keys[key] and value ~= nil) then
		return
	end

	return self.Server.dataManager:SetKeyValue(playerFired, key, value)
end

function PlayersDataService.Client:SetKeyIndexValue(playerFired, key, index, value, noUpdateToPlayer)
	if
		not playerFired
		or not ClientKeys.tableKeys[key]
		or (type(value) ~= ClientKeys.tableKeys[key][index] and value ~= nil)
	then
		print("Invalid data", playerFired, key, index, value)
		return
	end

	return self.Server.dataManager:SetKeyValue(playerFired, key, value, index, noUpdateToPlayer)
end

-- OTHER MISCELLANEOUS CLIENT FUNCTIONS -----------------------------------------------------------------------------------------------------
function PlayersDataService.Client:GetAllPlayersReplicatableData()
	return self.Server:GetAllPlayersReplicatableData()
end

return PlayersDataService

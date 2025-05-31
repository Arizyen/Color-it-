local PlayerData = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local BaseControllers = Source:WaitForChild("BaseControllers")

-- Modulescripts
local Local = require(script.Parent:WaitForChild("Local"))
local DataObserver = require(ReplicatedBaseModules:WaitForChild("DataObserver"))
local Utils = require(Source:WaitForChild("Utils"))
local DataHandler = require(script.Parent:WaitForChild("DataHandler"))

-- KnitControllers

-- Instances
local LocalPlayer = game.Players.LocalPlayer
-- Configs

-- Variables

-- Tables
PlayerData.data = {}
-------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS ------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -----------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
function PlayerData.Update(player, data)
	if not player then
		return
	end

	if not PlayerData.data[player] and game.Players:GetPlayerByUserId(player.UserId) then
		PlayerData.data[player] = data
	elseif PlayerData.data[player] then
		Utils.Table.Merge(PlayerData.data[player], data)
	end

	for eachKey, _ in pairs(data) do
		DataObserver.Notify(player, eachKey, PlayerData.data[player][eachKey], data[eachKey])
	end

	Utils.Signals.Fire("DispatchAction", {
		type = "UpdatePlayerData",
		player = player,
		data = data,
	})
end

function PlayerData.Removing(player)
	PlayerData.data[player] = nil
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdatePlayerData",
		player = player,
		data = nil,
	})
end

function PlayerData.GetKeyValue(player, key, index)
	if player == LocalPlayer then
		return Local.GetKeyValue(key, index)
	else
		if PlayerData.data[player] then
			if index then
				if PlayerData.data[player][key] then
					return PlayerData.data[player][key][index]
				end
			else
				return PlayerData.data[player][key]
			end
		end
	end
end

function PlayerData.SetKeyValue(player, key, value, updateType, index)
	if player == LocalPlayer then
		Local.SetKeyValue(key, value, updateType, index)
	else
		if not PlayerData.data[player] then
			PlayerData.data[player] = {}
		end

		local oldValue = PlayerData.data[player][key]
		if DataObserver.IsObservingKey(player, key) and type(oldValue) == "table" then
			oldValue = Utils.Table.DeepCopy(oldValue)
		end

		if not updateType then
			PlayerData.data[player][key] = value
		else
			if updateType == "add" then
				DataHandler.InsertDataValue(PlayerData.data[player][key], value, index)
			elseif updateType == "remove" then
				DataHandler.RemoveDataValue(PlayerData.data[player][key], index)
			elseif updateType == "update" then
				DataHandler.UpdateDataValue(PlayerData.data[player][key], value, index)
			end
		end

		DataObserver.Notify(player, key, PlayerData.data[player][key], oldValue, updateType, index)

		Utils.Signals.Fire("DispatchAction", {
			type = "UpdatePlayerDataKeyValue",
			player = player,
			dataKey = key,
			dataValue = PlayerData.data[player][key] and PlayerData.data[player][key] or false,
		})
	end
end

return PlayerData

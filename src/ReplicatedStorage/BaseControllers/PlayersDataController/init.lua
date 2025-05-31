-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Configs = Source:WaitForChild("Configs")
local Keys = Source:WaitForChild("Keys")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
local Utils = require(Source:WaitForChild("Utils"))
local DataManagers = require(script:WaitForChild("Managers"))
local ClientDataKeys = require(Keys:WaitForChild("ClientDataKeys"))
local DataObserver = require(ReplicatedBaseModules:WaitForChild("DataObserver"))

-- KnitControllers
local PlayersDataController = Knit.CreateController({
	Name = "PlayersData",
})

-- Instances
local LocalPlayer = game.Players.LocalPlayer

-- Configs

-- Variables

-- Tables
local knitServices = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayersDataController:KnitInit()
	knitServices["PlayersData"] = Knit.GetService("PlayersData")
end

function PlayersDataController:KnitStart()
	knitServices["PlayersData"].DataLoaded:Connect(function()
		-- Insert bool value locally inside player for dataLoaded
		if not LocalPlayer:FindFirstChild("DataLoaded") then
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "DataLoaded"
			boolValue.Value = true
			boolValue.Parent = LocalPlayer
		end
	end)

	Utils.Signals.Connect("PlayerRemoving", function(player)
		DataManagers.Others.Removing(player)
	end)

	-- Updates local data
	knitServices["PlayersData"].UpdateData:Connect(function(data)
		DataManagers.Local.Update(data)
	end)

	-- Updates other player data
	knitServices["PlayersData"].UpdatePlayerData:Connect(function(player, data)
		DataManagers.Others.Update(player, data)
	end)

	-- Updates local player data key value
	knitServices["PlayersData"].UpdateKeyValue:Connect(function(key, value, updateType, index)
		DataManagers.Local.SetKeyValue(key, value, updateType, index)
	end)

	-- Updates other player data key value
	knitServices["PlayersData"].UpdatePlayerKeyValue:Connect(function(player, key, value, updateType, index)
		DataManagers.Others.SetKeyValue(player, key, value, updateType, index)
	end)
end
-- FETCH FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayersDataController:ReturnAllPlayersWithKeyValue(key, value)
	local players = {}
	for eachPlayer, eachData in pairs(DataManagers.Others.data) do
		if eachPlayer ~= LocalPlayer and type(eachPlayer) == "userdata" and eachPlayer:IsA("Player") then
			if eachData[key] == value then
				table.insert(players, eachPlayer)
			end
		end
	end
	return players
end

function PlayersDataController:GetKeyValue(key, index)
	return DataManagers.Local.GetKeyValue(key, index)
end

function PlayersDataController:GetPlayerKeyValue(player, key, index)
	if player == LocalPlayer then
		return DataManagers.Local.GetKeyValue(key, index)
	else
		return DataManagers.Others.GetKeyValue(player, key, index)
	end
end

-- CONNECTIONS ----------------------------------------------------------------------------------------------------
function PlayersDataController:ObservePlayerKey(
	player: Player,
	key: any,
	callback: DataObserver.Callback
): DataObserver.Observer
	if not player or not key or not callback then
		return
	end

	return DataObserver.Observe(player, key, callback)
end

function PlayersDataController:ObserveKey(key: any, callback: DataObserver.Callback): DataObserver.Observer
	if not key or not callback then
		return
	end

	return DataObserver.Observe(LocalPlayer, key, callback)
end

-- MISC FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------

-- CLIENT TO SERVER FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayersDataController:LoadPlayerData(player)
	if player == LocalPlayer then
		return
	end

	knitServices["PlayersData"]:GetPlayerData(player):andThen(function(data)
		if data then
			DataManagers.Others.Update(player, data)
		end
	end)
end

function PlayersDataController:SetKeyValue(key, value, index)
	if key then
		DataManagers.Local.SetKeyValue(key, value, nil, index)
		if not index then
			if ClientDataKeys.keys[key] and (type(value) == ClientDataKeys.keys[key] or value == nil) then
				return knitServices["PlayersData"]:SetKeyValue(key, value)
			end
		else
			if
				key
				and ClientDataKeys.tableKeys[key]
				and (
					type(value) == ClientDataKeys.tableKeys[key][index]
					or (value == nil and ClientDataKeys.tableKeys[key][index])
				)
			then
				return knitServices["PlayersData"]:SetKeyIndexValue(key, index, value)
			end
		end
	end
end

-- CREATING CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------

return PlayersDataController

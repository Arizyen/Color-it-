local DataObserver = {}
-- Services
local Players = game:GetService("Players")

-- Folders

-- Modulescripts
local PlayerKeysObserved = require(script.PlayersKeysObserved)
local Observer = require(script.Observer)

-- KnitService

-- Instances

-- Configs

-- Types
export type Observer = Observer.Observer
export type Callback = Observer.Callback
export type UpdateType = Observer.UpdateType

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function DataObserver.IsObservingKey(player: Player, key: string): boolean
	return PlayerKeysObserved[player.UserId]
		and PlayerKeysObserved[player.UserId][key]
		and next(PlayerKeysObserved[player.UserId][key]) ~= nil
end

-- Notifies all observers of a change for a specific player's key.
-- @param player: The player whose key's observers are notified.
-- @param key: The key associated with the data being updated.
-- @param newValue: The new value for the key.
-- @param oldValue: The old value for the key.
-- @param updateType: The type of update (e.g., "add", "remove", "update").
-- @param index: The specific index in the key's data being updated (optional).
function DataObserver.Notify(
	player: Player,
	key: string,
	newValue: any,
	oldValue: any,
	updateType: Observer.UpdateType,
	index: any
)
	local observers = PlayerKeysObserved[player.UserId] and PlayerKeysObserved[player.UserId][key]
	if not observers or next(observers) == nil then
		return
	end

	for _, observer in pairs(observers) do
		observer:Fire(newValue, oldValue, updateType, index)
	end
end

function DataObserver.Observe(player: Player, key: string, callback: Observer.Callback): typeof(Observer)
	return Observer.new(player, key, callback)
end

-- CREATING CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	if PlayerKeysObserved[player.UserId] then
		for _, observers in pairs(PlayerKeysObserved[player.UserId]) do
			for _, observer in pairs(observers) do
				observer:Destroy(true)
			end
		end
		PlayerKeysObserved[player.UserId] = nil
	end
end)

-- RUNNING FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------

return DataObserver

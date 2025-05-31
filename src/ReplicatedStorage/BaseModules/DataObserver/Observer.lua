local Observer = {}
Observer.__index = Observer
-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------
local PlayersKeysObserved = require(script.Parent.PlayersKeysObserved)
-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local _DEBUG = false

-- Types ---------------------------------------------------------------------------
export type Observer = typeof(setmetatable({}, Observer))
export type UpdateType = "add" | "remove" | "update"
export type Callback = (newValue: any, oldValue: any, updateType: UpdateType, index: number | string) -> ()

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function DebugPrint(...)
	if _DEBUG then
		print(...)
	end
end
------------------------------------------------------------------------------------------------------------------------
-- GLOBAL METHODS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Observer.new(
	player: Player,
	key: string,
	callback: (newValue: any, oldValue: any, updateType: UpdateType, index: any) -> ()
): Observer
	-- Validate parameters
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		error("Observer.new: 'player' must be a valid Player instance")
	end

	if typeof(key) ~= "string" then
		error("Observer.new: 'key' must be a string")
	end

	if typeof(callback) ~= "function" then
		error("Observer.new: 'callback' must be a function")
	end

	local self = setmetatable({}, Observer)

	self.active = true
	self.player = player
	self.key = key
	self.callback = callback

	self:Init()

	return self
end

function Observer:Init()
	PlayersKeysObserved[self.player.UserId] = PlayersKeysObserved[self.player.UserId] or {}
	PlayersKeysObserved[self.player.UserId][self.key] = PlayersKeysObserved[self.player.UserId][self.key] or {}

	PlayersKeysObserved[self.player.UserId][self.key][self] = self
	DebugPrint("Observer initialized for player:", self.player.Name, "key:", self.key)
end

function Observer:Destroy(noCleanup: boolean?)
	if not self.active then
		return
	end
	self.active = false

	local observers = PlayersKeysObserved[self.player.UserId] and PlayersKeysObserved[self.player.UserId][self.key]
	if not observers then
		return
	end

	if observers then
		observers[self] = nil

		if not noCleanup and next(observers) == nil then
			-- Cleanup if no more observers
			PlayersKeysObserved[self.player.UserId][self.key] = nil

			if not next(PlayersKeysObserved[self.player.UserId]) then
				PlayersKeysObserved[self.player.UserId] = nil
			end
		end
	end
end

Observer.Disconnect = Observer.Destroy

function Observer:Fire(newValue: any, oldValue: any, updateType: UpdateType?, index: number | string)
	updateType = updateType or "update"
	if self.active then
		self.callback(newValue, oldValue, updateType, index)
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Observer

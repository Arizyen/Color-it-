local Signals = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Signal = require(Packages.Signal)

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables
local signals = {}

local localSignals = {
	"ClientStarted", -- Fired at the end of the MainScript after all the services are initialized

	"PlayerCharacterAdded", -- player, character
	"PlayerHumanoidAdded", -- player, humanoid
	"PlayerCharacterRemoving", -- player, character
	"PlayerDied", -- player
	"PlayerRemoving", -- player

	"DispatchAction", -- table with keys --> it dispatches it to the store
	"AppMounted", -- Fired when the app is mounted
}

local serverSignals = {
	"ServerStarted", -- Fired at the end of the MainScript after all the services are initialized

	"PlayerCharacterAdded", -- player, character
	"PlayerCharacterRemoving", -- player, character
	"PlayerJoined", -- player
	"PlayerAdded", -- player
	"PlayerDataLoaded", -- player
	"PlayerDied", -- player
	"PlayerRemoving", -- player
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Signals.Initialize()
	if game:GetService("RunService"):IsServer() then
		Signals.Add(serverSignals)
	else
		Signals.Add(localSignals)
	end
end

function Signals.Create()
	return Signal.new()
end

function Signals.Add(signalName)
	if type(signalName) == "string" then
		if not signals[signalName] then
			signals[signalName] = Signal.new()
			return signals[signalName]
		else
			return signals[signalName]
		end
	elseif type(signalName) == "table" then
		for _, eachSignalName in pairs(signalName) do
			if not signals[eachSignalName] then
				signals[eachSignalName] = Signal.new()
			end
		end
	end
end

-- Returns the connection
function Signals.Connect(signalName, callback)
	if type(signalName) ~= "string" or type(callback) ~= "function" then
		print("Could not connect to signal: " .. tostring(signalName))
		return
	end

	if not signals[signalName] then
		signals[signalName] = Signal.new()
	end

	return signals[signalName]:Connect(callback)
end

function Signals.Wait(signalName)
	if signals[signalName] then
		return signals[signalName]:Wait()
	end
end

-- Fires signal with given variables
function Signals.Fire(signalName, ...)
	if signals[signalName] then
		signals[signalName]:Fire(...)
	end
end

-- Same as `Fire`, but uses `task.defer` internally & doesn't take advantage of thread reuse.
function Signals.FireDeferred(signalName, ...)
	if signals[signalName] then
		signals[signalName]:FireDeferred(...)
	end
end

-- Disconnects all connections and destroys signal from memory
function Signals.Destroy(signalName)
	if signals[signalName] then
		signals[signalName]:DisconnectAll()
		signals[signalName]:Destroy()
		signals[signalName] = nil
	end
end

-- RUNNING FUNCTIONS ----------------------------------------------------------------------------------------------------
Signals.Initialize()

return Signals

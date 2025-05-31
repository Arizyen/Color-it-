local Local = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts -------------------------------------------------------------------
local Utils = require(Source:WaitForChild("Utils"))
local DataObserver = require(ReplicatedBaseModules:WaitForChild("DataObserver"))
local DataHandler = require(script.Parent:WaitForChild("DataHandler"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------
local LocalPlayer = game.Players.LocalPlayer

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
Local.data = {}
local keysToNotAddInStore = {}
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Local.Update(data)
	if type(data) ~= "table" then
		return
	end

	Utils.Table.Merge(Local.data, data)
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdateData",
		value = data,
	})

	for eachKey, _ in pairs(data) do
		DataObserver.Notify(LocalPlayer, eachKey, Local.data[eachKey], data[eachKey])
	end

	Utils.Instance.Create("BoolValue", game.Players.LocalPlayer, "DataReceived")
end

function Local.GetKeyValue(key, index)
	if index then
		if Local.data[key] then
			return Local.data[key][index]
		end
	else
		return Local.data[key]
	end
end

function Local.SetKeyValue(key, value, updateType, index)
	local oldValue = Local.data[key]
	local updateStore = not table.find(keysToNotAddInStore, key)

	if DataObserver.IsObservingKey(LocalPlayer, key) and type(oldValue) == "table" then
		oldValue = Utils.Table.DeepCopy(oldValue)
	end

	if not updateType then
		Local.data[key] = value
	else
		if updateType == "add" then
			DataHandler.InsertDataValue(Local.data[key], value, index)
		elseif updateType == "remove" then
			DataHandler.RemoveDataValue(Local.data[key], index)
		elseif updateType == "update" then
			DataHandler.UpdateDataValue(Local.data[key], value, index)
		end
	end

	DataObserver.Notify(LocalPlayer, key, Local.data[key], oldValue, updateType, index)

	if updateStore then
		Utils.Signals.Fire("DispatchAction", {
			type = "UpdateData",
			value = { [key] = Local.data[key] and Local.data[key] or false },
		})
	end
end

-- MISCELLANEOUS -------------------------------------------------------------------------------------------------------
function Local.OwnsGamepass(gamepassName)
	local gamepasses = Local.GetKeyValue("gamepasses")
	if gamepasses and gamepasses[gamepassName] then
		return true
	else
		return false
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Local

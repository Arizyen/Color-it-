local BaseTypes = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
-- Modulescripts -------------------------------------------------------------------
local t = require(Packages.t)

------------------------------------------------------------------------------------------------------------------------
-- TYPES ---------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Lists
export type AnyList = { any }
export type PartList = { Part }
export type NumberList = { number }
export type StringList = { string }
export type PlayerList = { Player }
export type InstanceList = { Instance }
export type Vector3List = { Vector3 }
export type CFrameList = { CFrame }
export type Color3List = { Color3 }

-- Dictionaries
export type PlayerDictionary = { [number]: Player }
export type ObjectDictionary = { [string]: any }
export type NumberDictionary = { [string]: number }
export type StringDictionary = { [string]: string }
export type InstanceDictionary = { [string]: Instance }
export type PartDictionary = { [string]: Part }

-- Event and Signal Handlers
export type Callback = (...any) -> ()

-- Utility BaseTypes
export type Optional<T> = T?
export type Map<K, V> = { [K]: V }
------------------------------------------------------------------------------------------------------------------------
-- VALIDATORS ----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

BaseTypes.Validators = {
	-- Lists
	AnyList = t.array(t.any),
	PartList = t.array(t.instanceOf("Part")),
	NumberList = t.array(t.number),
	StringList = t.array(t.string),
	PlayerList = t.array(t.instanceOf("Player")),
	InstanceList = t.array(t.instanceOf("Instance")),
	Vector3List = t.array(t.Vector3),
	CFrameList = t.array(t.CFrame),
	Color3List = t.array(t.Color3),

	-- Dictionaries
	PlayerDictionary = t.map(t.number, t.instanceOf("Player")),
	ObjectDictionary = t.map(t.string, t.any),
	NumberDictionary = t.map(t.string, t.number),
	StringDictionary = t.map(t.string, t.string),
	InstanceDictionary = t.map(t.string, t.instanceOf("Instance")),
	PartDictionary = t.map(t.string, t.instanceOf("Part")),

	-- Event and Signal Handlers
	Callback = t.callback,

	-- Utility
	Optional = function(typeValidator)
		return t.optional(typeValidator)
	end,
	Map = function(keyValidator, valueValidator)
		return t.map(keyValidator, valueValidator)
	end,
}

return BaseTypes

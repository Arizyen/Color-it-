local Loader = {}

-- Services ------------------------------------------------------------------------
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- Folders -------------------------------------------------------------------------
local AllSoundsFolder = ReplicatedStorage:FindFirstChild("AllSounds")

-- Modulescripts -------------------------------------------------------------------

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Infos ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
export type Info = { tag: string?, preloadServer: boolean?, preloadLocal: boolean? } & { [string]: any }

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local _DEFAULT_PROPERTIES = {
	Volume = 1,
	Looped = false,
	PlaybackSpeed = 1,
}
local cache = {}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function GetAllSoundsFolder()
	if RunService:IsServer() then
		if not AllSoundsFolder then
			local folder = Instance.new("Folder")
			folder.Name = "AllSounds"
			folder.Parent = ReplicatedStorage
			AllSoundsFolder = folder
		end
	else
		if not AllSoundsFolder then
			AllSoundsFolder = ReplicatedStorage:WaitForChild("AllSounds")
		end
	end
end

local function GetId(asset: number | string | table | Instance): string
	if type(asset) == "number" then
		return tostring(asset)
	elseif type(asset) == "string" then
		return asset:match("%d+")
	elseif typeof(asset) == "Instance" and asset:IsA("Sound") then
		return asset.SoundId:match("%d+")
	elseif type(asset) == "table" and asset.Id then
		return tostring(asset.Id)
	else
		error("Invalid asset type: " .. tostring(asset))
	end
end

local function ApplyInfo(sound: Instance, info: Info)
	for property, value in pairs(info) do
		if property == "SoundId" then
			continue -- Skip SoundId as it is set separately
		end

		if string.sub(property, 1, 1) == string.upper(string.sub(property, 1, 1)) then
			if type(value) == "function" then
				sound[property] = value()
			else
				sound[property] = value
			end
		else
			-- Handle attributes
			if property == "tag" then
				CollectionService:AddTag(sound, value)
			end
		end
	end

	-- Save default volume
	sound:SetAttribute("defaultVolume", sound.Volume)
end

local function Create(info: Info)
	local id = GetId(info.SoundId)
	assert(id, "Invalid SoundId provided: " .. tostring(info.SoundId))

	local sound = Instance.new("Sound")
	sound.Name = info.Name or ("Sound_" .. id)

	ApplyInfo(sound, _DEFAULT_PROPERTIES)
	ApplyInfo(sound, info)

	sound.SoundId = "rbxassetid://" .. id -- Ensure the SoundId is set correctly
	sound.Parent = AllSoundsFolder -- So sounds get loaded by the clients too (if loaded on the server)

	return sound
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Loader.Preload(infoList: { Info })
	for _, info in pairs(infoList) do
		local id = GetId(info.SoundId)
		if not cache[id] then
			local sound

			local ok, error = pcall(function()
				sound = Create(info)
				ContentProvider:PreloadAsync({ sound })
				cache[id] = sound
			end)
			if not ok then
				if sound and sound.Parent then
					sound:Destroy()
				end
				cache[id] = nil

				warn("Failed to preload sound with ID " .. id .. ": " .. tostring(error))
			end
		end
	end
end

function Loader.Get(info: Info): Instance
	local id = GetId(info.SoundId)
	if not cache[id] then
		cache[id] = Create(info)
	end

	local soundClone = cache[id]:Clone()
	ApplyInfo(soundClone, info)

	return soundClone
end

function Loader.Unload(idOrInfo: number | string | table | Instance)
	local id = GetId(idOrInfo)
	if cache[id] then
		cache[id]:Destroy()
		cache[id] = nil
	end
end

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
GetAllSoundsFolder()

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Loader

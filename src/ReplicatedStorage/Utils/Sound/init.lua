local Sound = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local Configs = ReplicatedSource:WaitForChild("Configs")
local Infos = ReplicatedSource:WaitForChild("Infos")
local Types = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseModules = ReplicatedSource:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local BaseControllers = ReplicatedSource:WaitForChild("BaseControllers")
local GameControllers = ReplicatedSource:WaitForChild("GameControllers")

-- Modulescripts -------------------------------------------------------------------
local Reduce = require(script.Parent:WaitForChild("Reduce"))
local Collection = require(script.Parent:WaitForChild("Collection"))
local Loader = require(script:WaitForChild("Loader"))
local Playback = require(script:WaitForChild("Playback"))
local Playlist = require(script:WaitForChild("Playlist"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Infos ---------------------------------------------------------------------------
Sound.Infos = require(Infos:WaitForChild("SoundInfos"))

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function PreloadSounds()
	task.spawn(function()
		if RunService:IsServer() then
			Loader.Preload(Reduce(Sound.Infos, function(accumulator, eachSoundInfo)
				if eachSoundInfo.preloadServer then
					table.insert(accumulator, eachSoundInfo)
				end
				return accumulator
			end, {}))
		else
			Loader.Preload(Reduce(Sound.Infos, function(accumulator, eachSoundInfo)
				if eachSoundInfo.preloadLocal then
					table.insert(accumulator, eachSoundInfo)
				end
				return accumulator
			end, {}))
		end
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- LOADER ----------------------------------------------------------------------------------------------------
Sound.Preload = Loader.Preload
Sound.Unload = Loader.Unload

-- PLAYBACK ----------------------------------------------------------------------------------------------------
Sound.Play = Playback.Play
Sound.Stop = Playback.Stop
Sound.StopSoundsWithTag = Playback.StopSoundsWithTag

-- PLAYLIST ----------------------------------------------------------------------------------------------------
function Sound.Loop(soundInfos: { Loader.Info }, parent: Instance?)
	if type(soundInfos) ~= "table" then
		warn("Invalid sound infos provided to Sound.Loop")
		return nil
	end

	local playlist = Playlist.new(soundInfos, parent)
	playlist:Start()

	return playlist
end

-- TAG ----------------------------------------------------------------------------------------------------
function Sound.SetTagVolume(tagName, volumeFactor) -- volumeFactor is a number between 0 and 1
	Collection(tagName, function(sound)
		if sound.Parent and sound:IsA("Sound") then
			sound.Volume = (sound:GetAttribute("defaultVolume") or 1) * volumeFactor
		end
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
PreloadSounds()

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Sound

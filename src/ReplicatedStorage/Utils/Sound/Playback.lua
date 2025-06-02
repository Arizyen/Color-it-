local Playback = {}
-- Services ------------------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- Folders -------------------------------------------------------------------------
local LocalSoundsFolder = game.Workspace:FindFirstChild("LocalSounds")
local ServerSoundsFolder = game.Workspace:FindFirstChild("ServerSounds")

-- Modulescripts -------------------------------------------------------------------
local Loader = require(script.Parent:WaitForChild("Loader"))
local InstanceUtil = require(script.Parent.Parent:WaitForChild("InstanceUtil"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Infos ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
export type Tag = "SoundEffect" | "Music" | "Voice"

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function TweenVolume(sound: Instance, targetVolume: number, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(sound, tweenInfo, { Volume = targetVolume })

	tween:Play()

	return tween
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Playback.Play(info: Loader.Info, parent: Instance?, unload: boolean?)
	if type(info) ~= "table" then
		warn("Invalid sound info provided to Playback.Play")
		return nil
	end

	local sound = Loader.Get(info)
	sound.Parent = parent or RunService:IsServer() and ServerSoundsFolder or LocalSoundsFolder

	if not sound.Looped then
		sound.Ended:Once(function()
			if sound.Parent then
				sound:Destroy()
			end
		end)
	end

	if unload then
		sound.Destroying:Once(function()
			Loader.Unload(info)
		end)
	end

	sound:Play()

	return sound
end

-- Stops a sound instance and destroys it after a fade-out effect.
function Playback.Stop(sound: Instance, time: number?)
	if typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
		warn("Invalid sound instance provided to Playback.Stop")
		return
	end

	TweenVolume(sound, 0, time or 0.25).Completed:Once(function()
		if sound.Parent then
			sound:Stop()
			sound:Destroy()
		end
	end)
end

function Playback.StopSoundsWithTag(tagName: Tag, time: number?)
	if type(tagName) ~= "string" then
		warn("Invalid tag name provided to Playback.StopSoundsWithTag")
		return
	end

	for _, sound in ipairs(CollectionService:GetTagged(tagName)) do
		if sound:IsA("Sound") then
			Playback.Stop(sound, time)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
LocalSoundsFolder = InstanceUtil.Create("Folder", game.Workspace, "LocalSounds")
ServerSoundsFolder = not RunService:IsServer() and game.Workspace:WaitForChild("ServerSounds")
	or InstanceUtil.Create("Folder", game.Workspace, "ServerSounds")

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Playback

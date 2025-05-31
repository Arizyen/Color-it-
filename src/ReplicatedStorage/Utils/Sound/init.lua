local SoundManager = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local SoundsFolder
local SoundsLoaded
local DebrisFolder = game.Workspace:WaitForChild("Debris")

-- Modulescripts
local Connections = require(script.Parent:WaitForChild("Connections"))
local InstanceUtil = require(script.Parent:WaitForChild("InstanceUtil"))
local TableUtil = require(script.Parent:WaitForChild("Table"))
local Reduce = require(script.Parent:WaitForChild("Reduce"))
local Collection = require(script.Parent:WaitForChild("Collection"))
SoundManager.Infos = require(script:WaitForChild("Infos"))
-- Configs

-- Variables
local isServer = game:GetService("RunService"):IsServer()
local soundFromLoop

-- Tables
local allSounds = {}
local validSounds = {}
local defaultProperties = {
	Volume = 1,
	Looped = false,
	PlaybackSpeed = 1,
}
local soundTagVolumeFactor = {}

SoundManager.serverSoundsToPreload = {}

SoundManager.localSoundsToPreload = {
	"MouseEnter",
	"MouseButton1Down",
	"MouseButton1Click",
	"Notification1",
	"Notification2",
	"Notification3",
	"Error1",
	"Success1",
	"PurchaseSuccessful",
	"LevelUp",
	"GemPurchase",
	"RewardClaimed",
	"AchievementClaimed",
	"Pop",
	"WrongAnswer",
	"Drumroll2",
	"Gong",
}

--[[ XP Effect sounds
9119690113
9119689944
]]
-- FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- BASIC FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
local function TweenFunction(
	object,
	speedInt,
	easingStyle,
	easingDirection,
	repeatTimes,
	reversesTrueFalse,
	delayStartInt,
	properties
)
	if object ~= nil then
		local tweenInfo = TweenInfo.new(
			speedInt, -- The amount of time it takes for the tween to complete.
			easingStyle, -- The style in which the tween executes.
			easingDirection, -- The direction in which the EasingStyle executes.
			repeatTimes, -- Repeat count. Must be set to -1 to play indefinitely.
			reversesTrueFalse, -- If the tween reverses once it reaches it's goal.
			delayStartInt
		) -- The amount of delay before the tween starts

		local newTween = TweenService:Create(object, tweenInfo, properties)
		newTween:Play()
		return newTween
		--newTween.Completed:Wait()
	end
end

local function ReturnSoundIdFromString(soundId)
	return soundId ~= nil and tostring(soundId) and string.match(soundId, "%d+") or nil
end

local function AddSoundsFolder()
	if isServer then
		SoundsFolder = InstanceUtil.Create("Folder", game.Workspace, "ServerSounds")
	else
		SoundsFolder = InstanceUtil.Create("Folder", game.Workspace, "ClientSounds")
	end
end

local function ReturnSoundName(soundId, tries)
	if not soundId then
		return
	end

	if typeof(soundId) == "string" then
		if ReturnSoundIdFromString(soundId) then
			soundId = tonumber(ReturnSoundIdFromString(soundId))
		else
			return
		end
	end

	local productInfo = nil
	local success, err = pcall(function()
		productInfo = MarketplaceService:GetProductInfo(soundId)
	end)

	if not success then
		if not tries then
			tries = 0
		end
		tries += 1
		if tries >= 3 then
			return "Sound not retrievable"
		end
		task.wait(3)
		return ReturnSoundName(soundId, tries)
	else
		return productInfo.Name
	end
end

local function ReturnSoundInfo(soundInfo)
	if typeof(soundInfo) ~= "table" and typeof(soundInfo) ~= "Instance" then
		if type(soundInfo) == "string" or type(soundInfo) == "number" then
			if SoundManager.soundInfos[soundInfo] then
				return SoundManager.soundInfos[soundInfo]
			else
				soundInfo = { SoundId = soundInfo }
			end
			return soundInfo
		else
			print("Did not receive a sound info", type(soundInfo))
			return
		end
	else
		-- Execute all functions in the soundInfo table
		local newSoundInfo = {}
		for eachKey, eachValue in pairs(soundInfo) do
			newSoundInfo[eachKey] = type(eachValue) == "function" and eachValue() or eachValue
		end

		return newSoundInfo
	end
end
-- DESTROYING SOUNDS -----------------------------------------------------------------------------------------------------------------------------------
local function FateOutAndDestroy(sound, speed)
	if sound and sound:IsA("Sound") and sound.Parent then
		local tween = TweenFunction(
			sound,
			speed or 1,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false,
			0,
			{ Volume = 0 }
		)
		tween.Completed:Connect(function()
			sound:Destroy()
			sound = nil
		end)
	end
end

local function StopLastSounds(state)
	if state then
		for _, eachChild in pairs(SoundsFolder:GetChildren()) do
			FateOutAndDestroy(eachChild)
		end
		-- elseif not state then
		-- 	for _, eachChild in pairs(SoundsFolder:GetChildren()) do
		-- 		if eachChild:IsA("Sound") then
		-- 			if eachChild.TimePosition == eachChild.TimeLength then
		-- 				eachChild:Destroy()
		-- 			end
		-- 		end
		-- 	end
	end
end

local function StopSound(soundId)
	if type(soundId) == "userdata" then
		FateOutAndDestroy(soundId)
	else
		soundId = ReturnSoundIdFromString(soundId)
		if soundId then
			for _, eachChild in pairs(SoundsFolder:GetChildren()) do
				if string.find(eachChild.SoundId, soundId) then
					FateOutAndDestroy(eachChild)
				end
			end
		end
	end
end

local function UnloadSound(soundId)
	soundId = ReturnSoundIdFromString(soundId)
	if soundId then
		if allSounds[soundId] then
			allSounds[soundId]:Destroy()
			allSounds[soundId] = nil
		end
	end
end
-- PRELOADING SOUNDS -----------------------------------------------------------------------------------------------------------------------------------
local function PreloadSound(soundInfo, noSoundIdCheck)
	if not soundInfo or type(soundInfo) ~= "table" then
		print("No sound info was provided")
		return
	end

	if not noSoundIdCheck then
		soundInfo.SoundId = ReturnSoundIdFromString(soundInfo.SoundId)
		if not soundInfo.SoundId then
			print("No sound id", soundInfo.SoundId, soundInfo)
			return
		end
	end

	if allSounds[tostring(soundInfo.SoundId)] then
		return allSounds[tostring(soundInfo.SoundId)]
	end

	local propertiesChanged = {}
	local newSound = Instance.new("Sound")
	--newSound.Name = ReturnSoundName(tonumber(soundInfo.SoundId))

	for eachProperty, value in pairs(soundInfo) do
		if eachProperty == "Volume" then
			newSound:SetAttribute("defaultVolume", value)
		elseif eachProperty ~= "Tag" then
			newSound[eachProperty] = type(value) == "function" and value() or value
			table.insert(propertiesChanged, eachProperty)
		end
	end

	for eachProperty, defaultValue in pairs(defaultProperties) do
		if not table.find(propertiesChanged, eachProperty) then
			newSound[eachProperty] = defaultValue
		end
	end

	-- Set tag after getting all sound properties
	if soundInfo["Tag"] then
		CollectionService:AddTag(newSound, soundInfo["Tag"])
	end

	newSound.SoundId = "rbxassetid://" .. soundInfo.SoundId

	local success, assets = pcall(function()
		ContentProvider:PreloadAsync({ newSound })
	end)

	table.clear(propertiesChanged)
	propertiesChanged = nil

	if success then
		allSounds[tostring(soundInfo.SoundId)] = newSound
		newSound.Parent = SoundsLoaded
		return newSound
	else
		print("ContentProvider: Sound was not loaded. Line 235 SoundManager", soundInfo.SoundId)
		newSound:Destroy()
		return false
	end
end

local function IsValidSound(soundId)
	if not soundId then
		return
	end
	if validSounds[tostring(soundId)] then
		return true
	end

	if typeof(soundId) == "string" then
		soundId = tonumber(ReturnSoundIdFromString(soundId))
		if not soundId then
			return
		end
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(soundId)
	end)

	if success and result and result.AssetTypeId == 3 then
		validSounds[tostring(soundId)] = true
		return true
	else
		return false
	end
end

local function ReturnSound(soundInfo, tries, isValidSound)
	if type(soundInfo) ~= "table" then
		-- if type(soundInfo) == "userdata" and soundInfo:IsA("Sound") then
		-- 	return soundInfo
		-- else
		-- 	print("No sound info was provided")
		-- 	return
		-- end

		print("No sound info was provided")
		return
	end

	soundInfo.SoundId = ReturnSoundIdFromString(soundInfo.SoundId)
	if not soundInfo.SoundId then
		print("No sound id", soundInfo.SoundId, soundInfo)
		return
	end

	if allSounds[tostring(soundInfo.SoundId)] then
		return allSounds[tostring(soundInfo.SoundId)]:Clone()
	else
		--if not isValidSound then
		--	if not IsValidSound(tonumber(soundInfo.SoundId)) then return end
		--	isValidSound = true
		--end
		local sound = PreloadSound(soundInfo, true)
		if not sound then
			print("Sound not received")
			if not tries then
				tries = 0
			end

			tries += 1
			if tries >= 3 then
				return
			end
			task.wait()
			return ReturnSound(soundInfo, tries, isValidSound)
		else
			return sound:Clone()
		end
	end
end

-- update the sound volume depending on the tag volumeFactor
local function UpdateSoundVolume(sound)
	local tags = CollectionService:GetTags(sound)
	local defaultVolume = sound:GetAttribute("defaultVolume")

	for _, eachTag in pairs(tags) do
		if soundTagVolumeFactor[eachTag] then
			sound.Volume = (defaultVolume or 1) * soundTagVolumeFactor[eachTag]
		end
	end
end

local function UpdateSound(sound, soundInfo)
	-- Update the sound properties to make sure it has the props we need. The function ReturnSound returns the saved instance.
	for eachProperty, value in pairs(soundInfo) do
		if eachProperty == "Volume" then
			sound[eachProperty] = value
			sound:SetAttribute("defaultVolume", value)
		elseif eachProperty ~= "SoundId" and eachProperty ~= "Tag" then
			sound[eachProperty] = value
		end
	end

	-- Add tag at the end (after setting default volume)
	if soundInfo["Tag"] then
		CollectionService:AddTag(sound, soundInfo["Tag"])
	end

	-- UpdateSoundVolume(sound)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
function SoundManager.PreloadSoundsFromFolder(folder)
	if not folder then
		return
	end
	local allSoundsInfo = {}

	for _, eachChild in pairs(folder:GetChildren()) do
		if not eachChild:IsA("Sound") then
			continue
		end

		local soundInfo = {}
		soundInfo.SoundId = eachChild.SoundId
		table.insert(allSoundsInfo, soundInfo)
	end

	if #allSoundsInfo > 0 then
		SoundManager.PreloadSounds(allSoundsInfo)
	end
end

function SoundManager.PreloadSound(soundInfo)
	if type(soundInfo) == "table" then
		return PreloadSound(soundInfo)
	elseif type(soundInfo) == "number" or type(soundInfo) == "string" then
		soundInfo = {
			SoundId = soundInfo,
		}
		return PreloadSound(soundInfo)
	end
end

function SoundManager.PreloadSounds(soundsTable)
	for _, eachSoundInfo in pairs(soundsTable) do
		SoundManager.PreloadSound(eachSoundInfo)
	end
end

function SoundManager.ReturnSound(soundInfo)
	return ReturnSound(soundInfo)
end
-- PLAY SOUNDS -----------------------------------------------------------------------------------------------------------------------------------
function SoundManager.PlaySound(soundInfo, stopLastSounds, unloadSoundAtEnd)
	if not soundInfo then
		print("No sound info returned")
		return
	end

	soundInfo = ReturnSoundInfo(soundInfo)

	if soundInfo then
		if not soundInfo.SoundId then
			print("SoundId is nil", soundInfo)
			return
		end

		StopLastSounds(stopLastSounds)

		local sound = ReturnSound(soundInfo)
		if not sound then
			print("No sound received")
			return
		end

		UpdateSound(sound, soundInfo)
		sound.Parent = SoundsFolder
		sound:Play()

		sound.Ended:Connect(function()
			sound:Destroy()

			if unloadSoundAtEnd then
				SoundManager.UnloadSound(soundInfo)
			end
		end)
		return sound
	end
end

function SoundManager.PlaySoundOnPart(soundInfo, part, unloadSoundAtEnd)
	if not soundInfo or typeof(soundInfo) ~= "table" then
		return warn("Did not receive a sound info")
	end
	if not soundInfo.SoundId or not part then
		return
	end

	local sound = ReturnSound(soundInfo)
	if sound and part then
		UpdateSound(sound, soundInfo)

		sound.Parent = part
		sound:Play()

		sound.Ended:Connect(function()
			sound:Destroy()

			if unloadSoundAtEnd then
				SoundManager.UnloadSound(soundInfo)
			end
		end)
		return sound
	end
end

function SoundManager.PlaySoundAtPosition(soundInfo, position, unloadSoundAtEnd)
	if not soundInfo or typeof(soundInfo) ~= "table" then
		return warn("Did not receive a sound info")
	end
	if not soundInfo.SoundId or not position then
		return
	end

	local sound = ReturnSound(soundInfo)
	if sound and position then
		UpdateSound(sound, soundInfo)

		local soundPart = Instance.new("Part")
		soundPart.Name = "SoundPart"
		soundPart.Transparency = 1
		soundPart.Anchored = true
		soundPart.CanCollide = false
		soundPart.CanTouch = false
		soundPart.CanQuery = false
		soundPart.Position = position
		soundPart.Parent = DebrisFolder

		sound.Parent = soundPart
		sound:Play()

		sound.Ended:Connect(function()
			sound:Destroy()

			if unloadSoundAtEnd then
				SoundManager.UnloadSound(soundInfo)
			end
		end)
		return sound
	end
end
-- DESTROYING/STOPPING SOUNDS -----------------------------------------------------------------------------------------------------------------------------------
function SoundManager.StopAllSounds()
	StopLastSounds(true)
end

function SoundManager.FadeSoundOut(sound, speed)
	if not sound or not sound:IsA("Sound") then
		return
	end

	FateOutAndDestroy(sound, speed)
end

function SoundManager.StopSound(soundInfo)
	if type(soundInfo) == "table" then
		StopSound(soundInfo.SoundId)
	elseif
		(type(soundInfo) == "number" or type(soundInfo) == "string")
		or (type(soundInfo) == "userdata" and soundInfo:IsA("Sound"))
	then
		StopSound(soundInfo)
	end
end

function SoundManager.StopSounds(soundInfos)
	for _, eachSoundInfo in pairs(soundInfos) do
		SoundManager.StopSound(eachSoundInfo)
	end
end

function SoundManager.UnloadSound(soundInfo)
	if type(soundInfo) == "table" then
		UnloadSound(soundInfo.SoundId)
	elseif
		(type(soundInfo) == "number" or type(soundInfo) == "string")
		or (type(soundInfo) == "userdata" and soundInfo:IsA("Sound"))
	then
		UnloadSound(soundInfo)
	end
end

function SoundManager.UnloadSounds(soundInfos)
	if type(soundInfos) == "table" then
		for _, eachSoundInfo in pairs(soundInfos) do
			SoundManager.UnloadSound(eachSoundInfo)
		end
	end
end
-- LOOP SOUNDS -----------------------------------------------------------------------------------------------------------------------------------
function SoundManager.LoopThroughSounds(soundInfos, properties, lastSoundId) -- soundInfos must be an array not a dictionary
	if type(soundInfos) ~= "table" or #soundInfos == 0 then
		return
	end

	lastSoundId = ReturnSoundIdFromString(lastSoundId)

	local chosenSoundInfo

	if #soundInfos == 1 then
		chosenSoundInfo = soundInfos[1]
	elseif #soundInfos <= 100 then
		-- Copy soundInfos and remove lastSoundId from it
		local soundInfosCopy = TableUtil.Copy(soundInfos)
		if lastSoundId then
			for eachKey, eachValue in pairs(soundInfos) do
				if
					(type(eachValue) == "number" and eachValue == tonumber(lastSoundId))
					or (type(eachValue) == "table" and string.match(eachValue.SoundId, "%d+") == lastSoundId)
				then
					table.remove(soundInfosCopy, eachKey)
				end
			end
		end

		if #soundInfosCopy > 0 then
			chosenSoundInfo = soundInfosCopy[math.random(#soundInfosCopy)]
		end
	else
		-- Repeat random number until new sound
		if #soundInfos > 1 and type(lastSoundId) == "string" then
			repeat
				chosenSoundInfo = soundInfos[math.random(#soundInfos)]
				-- print(chosenSoundInfo)

				if type(chosenSoundInfo) == "table" and not chosenSoundInfo.SoundId then
					print("L482 SoundManager. Invalid sound received. Removing from table.")
					table.remove(soundInfos, table.find(soundInfos, chosenSoundInfo))
				end
			until (
					#soundInfos <= 1
					or (type(chosenSoundInfo) == "string" or type(chosenSoundInfo) == "number")
						and not string.find(chosenSoundInfo, lastSoundId)
				)
				or (
					type(chosenSoundInfo) == "table"
					and chosenSoundInfo.SoundId
					and not string.find(chosenSoundInfo.SoundId, lastSoundId)
				)
		elseif #soundInfos > 0 then
			chosenSoundInfo = soundInfos[math.random(#soundInfos)]
		else
			return
		end
	end

	chosenSoundInfo = ReturnSoundInfo(chosenSoundInfo)
	if chosenSoundInfo then
		if type(properties) == "table" then
			for eachProperty, eachValue in pairs(properties) do
				chosenSoundInfo[eachProperty] = eachValue
			end
		end

		soundFromLoop = SoundManager.PlaySound(chosenSoundInfo)
		if soundFromLoop then
			Connections.Add(
				script,
				"soundFromLoopDestroying",
				soundFromLoop.Destroying:Connect(function()
					return SoundManager.LoopThroughSounds(soundInfos, properties, soundFromLoop.SoundId)
				end)
			)
		else
			print("Got no sound from loop", chosenSoundInfo)
			task.wait(1)
			return SoundManager.LoopThroughSounds(soundInfos, properties, lastSoundId)
		end
	else
		print("ERROR: SoundInfo not received")
		task.wait(1)
		return SoundManager.LoopThroughSounds(soundInfos, properties, lastSoundId)
	end
end

function SoundManager.StopLoopingSounds()
	Connections.DisconnectKeyConnection(script, "soundFromLoopDestroying")
	StopSound(soundFromLoop)
end

-- SOUND TAG SYSTEM ----------------------------------------------------------------------------------------------------------------------------------
function SoundManager.UpdateTagVolume(tagName, volumeFactor) -- volumeFactor is a number between 0 and 1
	if not soundTagVolumeFactor[tagName] then
		soundTagVolumeFactor[tagName] = volumeFactor
		Collection(tagName, function(sound)
			if sound and sound:IsA("Sound") then
				sound.Volume = (sound:GetAttribute("defaultVolume") or 1) * soundTagVolumeFactor[tagName]
			end
		end)
	else
		soundTagVolumeFactor[tagName] = volumeFactor
	end

	local tags = CollectionService:GetTagged(tagName)
	for _, eachInstance in pairs(tags) do
		if eachInstance:IsA("Sound") then
			eachInstance.Volume = (eachInstance:GetAttribute("defaultVolume") or 1) * volumeFactor
		end
	end
end

-- Running Functions ---------------------------------------------------------------------------------------------------------------------------------
SoundsLoaded = InstanceUtil.Create("Folder", ReplicatedStorage, "SoundsLoaded")
AddSoundsFolder()
if RunService:IsServer() then
	SoundManager.PreloadSounds(Reduce(SoundManager.serverSoundsToPreload, function(accumulator, eachSoundInfoId)
		table.insert(accumulator, SoundManager.Infos[eachSoundInfoId])
		return accumulator
	end, {}))
else
	SoundManager.PreloadSounds(Reduce(SoundManager.localSoundsToPreload, function(accumulator, eachSoundInfoId)
		table.insert(accumulator, SoundManager.Infos[eachSoundInfoId])
		return accumulator
	end, {}))
end

-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------

return SoundManager

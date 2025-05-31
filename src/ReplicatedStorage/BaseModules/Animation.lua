local Animation = {}
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local PlayersCharacter

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs
local _IDLE_WEIGHTS = {
	{ 8, 2 },
	{ 6, 2, 2 },
}

-- Variables

-- Tables
local animationTracks = {}
local charactersAnimating = {} -- character, value
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateAnimation(data)
	local obj = Instance.new("Animation")
	for k, v in pairs(data) do
		if type(k) == "number" then
			v.Parent = obj
		else
			obj[k] = v
		end
	end
	return obj
end

local function ReturnAnimation(humanoid, animationId, animationName)
	if not humanoid or (not animationId and not animationName) then
		return
	end

	animationId = string.match(animationId, "%d+") and tonumber(string.match(animationId, "%d+")) or nil
	if not animationId then
		print("Animation L49. Did not get animation Id")
		return
	end
	-- for _, eachChild in pairs(humanoid:GetChildren()) do
	-- 	if eachChild:IsA("Animation") then
	-- 		if string.find(eachChild.AnimationId, tostring(animationId)) then
	-- 			return eachChild
	-- 		end
	-- 	end
	-- end

	if
		(animationId and humanoid:FindFirstChild(tostring(animationId)))
		or (animationName and humanoid:FindFirstChild(animationName))
	then
		return humanoid:FindFirstChild(tostring(animationId)) or humanoid:FindFirstChild(animationName)
	else
		return CreateAnimation({
			Name = animationName or animationId,
			AnimationId = "rbxassetid://" .. animationId,
			Parent = humanoid,
		})
	end
end

local function UpdateAnimationTrackDetails(animationTrack, animationTrackDetails)
	if animationTrack and animationTrackDetails then
		for eachProperty, eachValue in pairs(animationTrackDetails) do
			animationTrack[eachProperty] = eachValue
		end
	end
end

local function CreateAnimationTrack(humanoid, animationId)
	local animationTrack = animationTracks[humanoid][animationId]

	if animationTrack then
		animationTrack:Stop(0.1)
		animationTrack:Destroy()
	end

	local animator = humanoid:WaitForChild("Animator")
	local animation = ReturnAnimation(humanoid, animationId)

	if animation then
		animationTrack = animator:LoadAnimation(animation)
		animationTracks[humanoid][animationId] = animationTrack

		return animationTrack
	end
end

local function ReturnAnimationTrack(character, animationId, animationTrackDetails)
	if
		type(character) ~= "userdata"
		or not character:IsA("Model")
		or not character:FindFirstChild("Humanoid")
		or not animationId
	then
		print("Animation L102. Wrong data received")
		return
	end

	local humanoid = character.Humanoid

	if not animationTracks[humanoid] then
		animationTracks[humanoid] = {}

		Utils.Connections.Add(
			character,
			"Animation_CharacterRemoving",
			character.Destroying:Connect(function()
				animationTracks[humanoid] = nil
				charactersAnimating[character] = nil
				Utils.Connections.DisconnectKeyConnection(character, "Animation_CharacterRemoving")
			end)
		)

		-- Create an Animator if it's not a player's character
		if not Players:GetPlayerFromCharacter(character) and not humanoid:FindFirstChild("Animator") then
			local animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
	end

	animationId = string.match(tostring(animationId), "%d+")
	local animationTrack = CreateAnimationTrack(humanoid, animationId)
	if animationTrack then
		UpdateAnimationTrackDetails(animationTrack, animationTrackDetails)
		return animationTrack
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Animation.CharacterDestroyed(character)
	if character then
		charactersAnimating[character] = nil
		animationTracks[character.Humanoid] = nil
	end
end

function Animation.PrepareAnimationOnCharacter(character, animationId, animationTrackDetails)
	return ReturnAnimationTrack(character, animationId, animationTrackDetails)
end

function Animation.PrepareAnimationsOnCharacter(character, animationIds: table, animationTrackDetails)
	for _, eachAnimationId in pairs(animationIds) do
		ReturnAnimationTrack(character, eachAnimationId, animationTrackDetails)
	end
end

function Animation.PrepareAnimationsOnPlayers(players, animationIds, animationTrackDetails)
	if type(players) ~= "table" or type(animationIds) ~= "table" then
		return
	end

	for _, eachPlayer in pairs(players) do
		if eachPlayer then
			if not eachPlayer.Character then
				Utils.Connections.Add(
					eachPlayer,
					"Animation_CharacterAdded",
					eachPlayer.CharacterAdded:Connect(function(character)
						Utils.Connections.DisconnectKeyConnection(eachPlayer, "Animation_CharacterAdded")
						character:WaitForChild("Humanoid")
						for _, eachAnimationId in pairs(animationIds) do
							ReturnAnimationTrack(character, eachAnimationId, animationTrackDetails)
						end
					end)
				)
			else
				for _, eachAnimationId in pairs(animationIds) do
					ReturnAnimationTrack(eachPlayer.Character, eachAnimationId, animationTrackDetails)
				end
			end
		end
	end
end

function Animation.PlayAnimation(character, animationId, animationTrackDetails, andThen)
	if type(character) ~= "userdata" or not animationId then
		return
	end

	if character:IsA("Player") then
		character = character.Character or nil
	elseif not character:IsA("Model") then
		return
	end

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local animationTrack = ReturnAnimationTrack(character, animationId, animationTrackDetails)
			if animationTrack then
				animationTrack:Play(0)

				if andThen then
					animationTrack.Stopped:Connect(andThen)
				end
				return animationTrack
			end
		end
	end
end

function Animation.StopAnimations(player)
	if type(player) ~= "userdata" then
		return
	end

	local character
	if player:IsA("Model") and player:FindFirstChild("Humanoid") then
		character = player
	elseif player:IsA("Player") then
		character = player.Character
	end

	if character then
		charactersAnimating[character] = nil

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local animator = humanoid:FindFirstChild("Animator") or humanoid:WaitForChild("Animator", 10)
			if animator then
				local playingAnimationTracks = animator:GetPlayingAnimationTracks()
				for _, eachTrack in pairs(playingAnimationTracks) do
					eachTrack:Stop(0.1)
				end
			end
		end
	end
end

function Animation.ReturnPlayerCoreAnimations(player, animationState)
	if type(player) ~= "userdata" or not animationState then
		return
	end

	local character
	if player:IsA("Player") then
		character = player.Character
	elseif player:IsA("Model") and player:FindFirstChild("Humanoid") then
		character = player
	end

	if not character or not character:FindFirstChild("Animate") then
		character = PlayersCharacter:FindFirstChild(player.Name)

		-- If the character or Animate script is not found, then use LocalHumanoidManager.ReturnPlayerHumanoidDescription(playerUserId, retries)
	end

	if character then
		local animateScript = character:FindFirstChild("Animate")
		if animateScript then
			local animationStateFolder = animateScript:FindFirstChild(animationState)
			if animationStateFolder then
				local animations = {}
				for _, eachAnimation in pairs(animationStateFolder:GetChildren()) do
					if eachAnimation:IsA("Animation") then
						animations[eachAnimation.Name] = eachAnimation
					end
				end
				return animations
			else
				print("Animation state folder not found: ", animationState)
			end
		end
	end
end

function Animation.AnimateIdle(model, playerAnimationsToCopy, customAnimationIds)
	if
		type(model) ~= "userdata"
		or (type(playerAnimationsToCopy) ~= "userdata" and type(customAnimationIds) ~= "table")
	then
		return
	end

	local character
	if model:IsA("Model") and model:FindFirstChild("Humanoid") then
		character = model
	end

	if character then
		local idleAnimations = Animation.ReturnPlayerCoreAnimations(playerAnimationsToCopy, "idle") -- returns nil if no player
		if
			(not idleAnimations or (not idleAnimations["Animation1"] and not idleAnimations["Animation2"]))
			and type(customAnimationIds) == "table"
		then
			idleAnimations = {}
			for i, eachAnimationId in pairs(customAnimationIds) do
				idleAnimations["Animation" .. i] = ReturnAnimation(character.Humanoid, eachAnimationId)
			end
		end

		if idleAnimations and idleAnimations["Animation1"] then
			for _, eachAnimation in pairs(idleAnimations) do
				ReturnAnimationTrack(
					character,
					eachAnimation.AnimationId,
					{ Looped = false, Priority = Enum.AnimationPriority.Core }
				)
			end

			charactersAnimating[character] = true

			local function AnimateNext()
				if character and charactersAnimating[character] then
					if idleAnimations["Animation1"] and idleAnimations["Animation2"] then
						-- Get total animations
						local totalAnimations = Utils.Table.Length(idleAnimations)
						local idleWeights = _IDLE_WEIGHTS[totalAnimations - 1]
						local rollAmount = 10

						if not idleWeights then
							idleWeights = {}
							for i = 1, totalAnimations do
								table.insert(idleWeights, 1)
							end
							rollAmount = #idleWeights
						end

						local roll = math.random(rollAmount)
						local index = 1
						while roll > idleWeights[index] do
							roll = roll - idleWeights[index]
							index = index + 1
						end

						Animation.PlayAnimation(
							character,
							idleAnimations["Animation" .. index].AnimationId,
							{ Looped = false, Priority = Enum.AnimationPriority.Core },
							AnimateNext
						)
					else
						Animation.PlayAnimation(
							character,
							idleAnimations["Animation1"].AnimationId,
							{ Looped = true, Priority = Enum.AnimationPriority.Core },
							AnimateNext
						)
					end
				end
			end

			AnimateNext()
		end
	end
end

-- RUNNING FUNCTIONS ----------------------------------------------------------------------------------------------------
PlayersCharacter = Utils.Instance.Create("Folder", ReplicatedStorage, "PlayersCharacter")

return Animation

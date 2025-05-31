local UserThumbnail = {}
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Promise = require(Packages.Promise)
local Signals = require(Source:WaitForChild("Utils")).Signals

-- KnitServices

-- Instances
-- Configs
local RETRY_TIME = 1
local MAX_RETRIES = 5
-- Variables

-- Tables
local userThumbnails = {}
--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------
local function RemoveInvalidThumbnails()
	for eachUserId, _ in pairs(userThumbnails) do
		if not Players:GetPlayerByUserId(eachUserId) then
			userThumbnails[eachUserId] = nil
		end
	end
end

local function ReturnUserId(player)
	if not player then
		return
	end

	if type(player) == "userdata" and player:IsA("Player") then
		return player.UserId
	elseif typeof(player) == "number" then
		return player
	end
end

-- userid must be a number
local function RetrieveAvatar(userId)
	local tries = 0

	if userId < 0 then
		return nil
	end

	while true do
		local content, isReady =
			Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)

		if isReady then
			userThumbnails[userId] = content
			return content
		end

		tries += 1
		if tries >= 5 then
			return
		end
		task.wait(RETRY_TIME)
	end
end

-- player can be a Player or number
local function ReturnUserThumbnail(player)
	local userId = ReturnUserId(player)

	if not userId then
		return
	end

	return userThumbnails[userId]
end

-- player can be a Player or number
local function RetrieveUserThumbnail(player)
	local userId = type(player) == "userdata" and ReturnUserId(player) or type(player) == "number" and player

	return Promise.new(function(resolve)
		if not userId then
			return resolve(nil)
		end

		if userThumbnails[userId] then
			return resolve(userThumbnails[userId])
		else
			return resolve(RetrieveAvatar(userId))
		end
	end)
end
--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
UserThumbnail.ReturnUserThumbnail = ReturnUserThumbnail
UserThumbnail.RetrieveUserThumbnail = RetrieveUserThumbnail
UserThumbnail.RemoveInvalidThumbnails = RemoveInvalidThumbnails

function UserThumbnail.PlayerRemoving(player)
	local userId = ReturnUserId(player)

	userThumbnails[userId] = nil
	RemoveInvalidThumbnails()
end

-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerRemoving", function(player)
	UserThumbnail.PlayerRemoving(player)
end)

return UserThumbnail

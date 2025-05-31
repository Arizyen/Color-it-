local ServerUpdate = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")

-- Folders
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
-- local Events = ReplicatedStorage.Events
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local MessageService = require(BaseServices.MessageService)
local Connections = require(ReplicatedSource.Utils.Connections)

-- Events
-- TeleportRE = Events.Teleport

-- Instances

-- Configs

-- Variables
ServerUpdate.newUpdate = false
ServerUpdate.teleportedPlayers = false

-- Tables
ServerUpdate.MessageTopics = {
	SERVER_UPDATE = "NewUpdate",
	SERVER_MESSAGE = "NewMessage",
}

-----------------------------------------------
-- GLOBAL FUNCTIONS ---------------------------
-----------------------------------------------
function ServerUpdate.SubscribeServerUpdate(retries)
	for _, eachMessageTopic in pairs(ServerUpdate.MessageTopics) do
		-- Subscribe to the topic
		local subscribeSuccess, subscribeConnection = pcall(function()
			return MessagingService:SubscribeAsync(eachMessageTopic, function(message)
				if ServerUpdate[eachMessageTopic] then
					ServerUpdate[eachMessageTopic](message.Data)
				end
			end)
		end)

		Connections.Add("ServerUpdate", eachMessageTopic, subscribeConnection)

		if not subscribeSuccess then
			if not retries then
				retries = 1
			end
			if retries >= 3 then
				return
			end
			if retries == 1 then
				return coroutine.wrap(function()
					task.wait(5)
					ServerUpdate.SubscribeServerUpdate(retries + 1)
				end)()
			else
				task.wait(5)
				ServerUpdate.SubscribeServerUpdate(retries + 1)
			end
		end
	end
end

function ServerUpdate.NewMessage(message)
	if not message or typeof(message) ~= "string" then
		return
	end

	MessageService:SendMessage(message)
	MessageService:SendMessageToPlayers(game.Players:GetPlayers(), message, "Error", {
		duration = 10,
	})
	print("New message received: " .. message)
end

return ServerUpdate

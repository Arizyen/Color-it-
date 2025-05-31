-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local Chat = game:GetService("Chat")

-- Folders
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local Infos = ReplicatedStorage.Source.Infos
local Packages = ReplicatedStorage.Packages
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Knit = require(Packages.Knit)
local Utils = require(ReplicatedStorage.Source.Utils)
local MessagesInfo = require(Infos.MessagesInfo)

-- KnitServices
local MessageService = Knit.CreateService({
	Name = "Message",
	Client = {
		NewMessage = Knit.CreateSignal(),
	},
})

-- Instances
local Filter = Chat.FilterStringForBroadcast

-- Configs
local NAME_COLOR = Color3.fromRGB(255, 0, 0)
local CHAT_COLOR = Color3.fromRGB(227, 255, 44)

-- Variables
local serverSpeaker = nil

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function SetExtraData()
	serverSpeaker:SetExtraData("NameColor", NAME_COLOR)
	serverSpeaker:SetExtraData("ChatColor", CHAT_COLOR)
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------------
function MessageService:KnitInit() end

function MessageService:KnitStart() end
-- SEND MESSAGES ----------------------------------------------------------------------------------------------------------------------------------
function MessageService:SaveSpeaker(speaker)
	serverSpeaker = speaker
	SetExtraData()
end

function MessageService:SendMessage(message)
	if message and serverSpeaker then
		serverSpeaker:SayMessage(message, "ALL")
	end
end

-- duration, Text, TextColor3, any other text properties
function MessageService:SendMessageToPlayer(player, message: string, messageType: string, messageProperties)
	if not player or typeof(player) == "string" or not player:IsA("Player") then
		return
	end

	self.Client.NewMessage:Fire(player, message, messageType, messageProperties)
end

function MessageService:SendMessageToPlayers(players, message: string, type: string, messageProperties)
	for _, eachPlayer in pairs(players) do
		MessageService:SendMessageToPlayer(eachPlayer, message, type, messageProperties)
	end
end

function MessageService:FilterMessage(playerFiring, message)
	local filteredString = Chat:FilterStringForBroadcast(message, playerFiring)
	return filteredString
end

function MessageService:SendMessageCrossServers(message, playerFrom)
	if not message or type(message) ~= "string" then
		return
	end

	local success, filteredMessage = pcall(Filter, Chat, message, playerFrom) --We filter the message so that you don't get banned
	if success then
		MessagingService:PublishAsync("NewMessage", filteredMessage)
	else
		print("Sending message to all server not successful")
	end
end

return MessageService

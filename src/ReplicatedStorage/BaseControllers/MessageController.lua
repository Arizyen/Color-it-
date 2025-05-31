local Players = game:GetService("Players")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Infos = Source:WaitForChild("Infos")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
local Utils = require(Source:WaitForChild("Utils"))
local MessagesInfo = require(Infos:WaitForChild("MessagesInfo"))

-- KnitControllers
local MessageController = Knit.CreateController({
	Name = "Message",
})

-- Instances
local LocalPlayer = Players.LocalPlayer
local MessageGui = Instance.new("ScreenGui")
MessageGui.Name = "ScreenGuiMessage"
MessageGui.DisplayOrder = 2
MessageGui.ResetOnSpawn = false
MessageGui.Parent = LocalPlayer.PlayerGui

-- Configs
local _DEFAULT_FRAME_PROPERTIES = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 1.05),
	Size = UDim2.fromScale(0.7, 0.05),
	ZIndex = 15,
}

-- Variables
MessageController.changedFrameProperties = false
local endPosition

-- Tables
local knitServices = {}
local frameProperties = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 1.05),
	Size = UDim2.fromScale(0.7, 0.05),
	ZIndex = 15,
}
local textLabelProperties = {
	TextScaled = true,
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	TextWrapped = true,
	Size = UDim2.fromScale(1, 1),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextStrokeTransparency = 0.2,
	TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
	Font = Enum.Font.FredokaOne,
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ChangeInstanceProperties(instance, properties)
	for eachProperty, eachValue in pairs(properties) do
		instance[eachProperty] = eachValue
	end
end

local function CreateMessageFrame(messageProperties)
	-- Create the frame
	local frame = Instance.new("Frame")
	frame.Name = "MessageFrame"
	ChangeInstanceProperties(frame, frameProperties)

	-- Create the textLabel
	local textLabel = Instance.new("TextLabel")
	ChangeInstanceProperties(textLabel, Utils.Table.MergeProps(messageProperties, textLabelProperties))
	textLabel.Parent = frame

	frame.Parent = MessageGui
	return frame
end

local function ReturnMessageFrame(messageProperties)
	local frame = MessageGui:FindFirstChild("MessageFrame")

	if frame then
		frame:Destroy()
		frame = nil
	end

	return CreateMessageFrame(messageProperties)
end

local function PlaySound(soundId)
	if not soundId then
		return
	end

	if Utils.Sound.Infos[soundId] then
		Utils.Sound.PlaySound(Utils.Sound.Infos[soundId])
	else
		Utils.Sound.PlaySound({ SoundId = soundId, Tag = "SoundEffect" })
	end
end

local function ShowMessage(message, messageType, messageProperties)
	messageProperties = messageProperties or {}
	messageProperties.Text = message

	if messageType and MessagesInfo[messageType] then
		messageProperties = Utils.Table.Copy(MessagesInfo[messageType], messageProperties)
	end

	if type(messageProperties) ~= "table" or not messageProperties.Text then
		print(
			"Cannot show message. Did not receive proper message properties",
			type(messageProperties),
			messageProperties.Text
		)
		return
	end

	local messageFrame = ReturnMessageFrame(messageProperties)
	if messageFrame and messageFrame:FindFirstChild("TextLabel") then
		PlaySound(messageProperties["soundId"])

		Utils.Tween.Start(messageFrame, 1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
			Position = UDim2.fromScale(
				endPosition and endPosition.X.Scale or frameProperties.Position.X.Scale,
				endPosition and endPosition.Y.Scale or 0.8
			),
		})

		task.wait(messageProperties["duration"] or 3)

		if messageFrame and messageFrame:FindFirstChild("TextLabel") then
			messageFrame.TextLabel.TextStrokeTransparency = 1
			local newTween = Utils.Tween.Start(
				messageFrame.TextLabel,
				0.5,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out,
				{ TextTransparency = 1 }
			)
			newTween.Completed:Connect(function()
				if messageFrame then
					messageFrame:Destroy()
					messageFrame = nil
				end
			end)
		else
			-- print("Message frame could not be found")
		end
	else
		-- print("No message frame")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function MessageController:KnitInit()
	knitServices["MessageController"] = Knit.GetService("Message")
end

function MessageController:KnitStart()
	knitServices["MessageController"].NewMessage:Connect(function(message, messageType, messageProperties)
		self:ShowMessage(message, messageType, messageProperties, true)
	end)
end
-- SHOWING MESSAGES -----------------------------------------------------------------------------------------------------------------------------------
function MessageController:ShowMessage(message: string, messageType: string, messageProperties, noCoroutine)
	if noCoroutine then
		ShowMessage(message, messageType, messageProperties)
	else
		task.spawn(ShowMessage, message, messageType, messageProperties)
	end
end
-- UPDATING DEFAULT MESSAGE PROPERTIES -----------------------------------------------------------------------------------------------------------------------------------
function MessageController:UpdateDefaultMessageProperties(properties)
	if not properties and MessageController.changedFrameProperties then
		MessageController.changedFrameProperties = false
		for eachDefaultProperty, eachValue in pairs(_DEFAULT_FRAME_PROPERTIES) do
			frameProperties[eachDefaultProperty] = eachValue
		end
	elseif type(properties) == "table" then
		MessageController.changedFrameProperties = true
		for eachProperty, eachValue in pairs(properties) do
			frameProperties[eachProperty] = eachValue
		end
	end
end

function MessageController:UpdateMessageEndPosition(position)
	if typeof(position) == "UDim2" then
		endPosition = position
	else
		endPosition = nil
	end
end

return MessageController

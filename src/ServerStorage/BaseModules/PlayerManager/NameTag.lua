local NameTag = {}
-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedSource = ReplicatedStorage.Source
local ReplicatedBaseModules = ReplicatedSource.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
local Models = ServerStorage.Models

-- Modulescripts
local TextAnimator = require(ReplicatedSource.Utils.TextAnimator)
local Utils = require(ReplicatedSource.Utils)

-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances
local BillboardGuiNameTag = Models.BillboardGuiNameTag
local DummyBillboardGuiNameTag = Models.DummyBillboardGuiNameTag

-- Configs

-- Variables

-- Tables

-- Functions -------------------------------------
local function ReturnNameTag(character, nameTag)
	local head = "Head"
	if not character:FindFirstChild(head) then
		return
	end

	local tag = character[head]:FindFirstChild(nameTag.Name)
	if not tag then
		tag = nameTag:Clone()
	end

	tag.Adornee = character[head]
	tag.Parent = character[head]

	return tag
end

local function UpdateName(entity, gui)
	if not entity or not gui or not gui:FindFirstChild("TextLabelName") then
		return
	end

	if entity and entity:IsA("Player") then
		gui.TextLabelName.Text = entity.DisplayName
	elseif entity:IsA("Model") then
		gui.TextLabelName.Text = entity.Name
	end
end

local function UpdateLevelNameTag(gui, level)
	gui.TextLabelLevel.Text = level
end

local function UpdateStudsOffsetWorldSpace(character, nameTag)
	nameTag.StudsOffsetWorldSpace = Vector3.new(0, (character.Head.Size.Y / 2) * 3, 0)
end
--------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------
--------------------------------------------------
function NameTag.GiveEntityNameTag(entity, character)
	if not entity or not entity.Parent or not character or not character.Parent then
		return
	end

	local nameTag = ReturnNameTag(character, BillboardGuiNameTag)

	if
		PlayersDataService:OwnsGamepass(entity, "vip")
			and PlayersDataService:GetKeyValue(entity, "rainbowNametagEnabled")
		or (not entity:IsA("Player") and entity:IsA("AI") and entity.gamepasses.vip)
	then
		TextAnimator.new(nameTag.TextLabelName, "RandomAnimate")
	end

	UpdateStudsOffsetWorldSpace(character, nameTag)
	UpdateLevelNameTag(nameTag, PlayersDataService:GetKeyValue(entity, "level"))
	UpdateName(entity, nameTag)

	Utils.Connections.Add(
		entity,
		"NameTagLevelUpdated",
		PlayersDataService:ObservePlayerKey(entity, "level", function(newValue)
			UpdateLevelNameTag(nameTag, newValue)
		end)
	)

	Utils.Connections.Add(
		entity,
		"NameTagRainbowEnabled",
		PlayersDataService:ObservePlayerKey(entity, "rainbowNametagEnabled", function(newValue)
			NameTag.ActivateRainbowNametag(entity, newValue)
		end)
	)
end

function NameTag.GiveDummyNameTag(dummy, name, color)
	if not dummy then
		return
	end

	local nameTag = ReturnNameTag(dummy, DummyBillboardGuiNameTag)
	-- UpdateStudsOffsetWorldSpace(dummy, nameTag)

	-- Update name
	nameTag.TextLabelName.Text = name
	nameTag.TextLabelName.TextColor3 = color
end

function NameTag.EnableEntityNameTag(entity, state)
	if not entity or not entity.Character then
		return
	end

	local entityNameTag = ReturnNameTag(entity.Character, BillboardGuiNameTag)
	if entityNameTag then
		entityNameTag.Visible = state
	end
end

function NameTag.UpdateStudsOffsetWorldSpace(character)
	if not character then
		return
	end

	local nameTag = ReturnNameTag(character, BillboardGuiNameTag)
	if nameTag then
		UpdateStudsOffsetWorldSpace(character, nameTag)
	end
end

function NameTag.ActivateRainbowNametag(entity, state)
	if not entity or not entity.Character then
		return
	end

	local character = entity.Character
	local nameTag = ReturnNameTag(character, BillboardGuiNameTag)
	if nameTag then
		local textAnimator = TextAnimator.ReturnTextLabelMetatable(nameTag.TextLabelName)

		if textAnimator then
			textAnimator:ActivateRainbowNametag(state)
		end
	end
end
------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return NameTag

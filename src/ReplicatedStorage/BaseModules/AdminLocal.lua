local AdminLocal = {}
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")

-- Modulescripts
local Utils = require(ReplicatedSource:WaitForChild("Utils"))

-- KnitControllers

-- Instances
local LocalPlayer = Players.LocalPlayer

-- Configs

-- Variables
local nameTagsHidden = false

-- Tables
local adminPlayers = {
	1858692567,
}
local commands = {
	"HideNameTags",
}
local adminFunctions = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnRequestedFunction(message)
	for _, eachCommand in pairs(commands) do
		if string.find(string.lower(message), string.lower(eachCommand)) then
			return eachCommand
		end
	end
end

local function HideCharacterNameTag(character)
	if character and character:IsA("Model") then
		local playerHead = character:WaitForChild("Head", 10)
		if playerHead then
			for _, eachChild in pairs(playerHead:GetChildren()) do
				if eachChild:IsA("BillboardGui") then
					if not nameTagsHidden then
						eachChild:SetAttribute("nameTagEnabledDefaultState", eachChild.Enabled)
					end

					eachChild.Enabled = (nameTagsHidden and eachChild:GetAttribute("nameTagEnabledDefaultState"))
						or false

					if nameTagsHidden then
						eachChild:SetAttribute("nameTagEnabledDefaultState", nil)
					end
				end
			end
		end
	end
end
-- ADMIN FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function adminFunctions.HideNameTags()
	Utils.Connections.DisconnectKeyConnection("AdminLocal", "HideNameTags")

	if not nameTagsHidden then
		Utils.Connections.Add(
			"AdminLocal",
			"PlayerCharacterAddedNameTag",
			Utils.Signals.Connect("PlayerCharacterAdded", function(player, character)
				if player and player:IsA("Player") and character and character:IsA("Model") then
					HideCharacterNameTag(character)
				end
			end)
		)
	end

	for _, eachPlayer in pairs(Players:GetPlayers()) do
		HideCharacterNameTag(eachPlayer.Character)
	end

	nameTagsHidden = not nameTagsHidden
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function AdminLocal.Enable()
	if not table.find(adminPlayers, LocalPlayer.UserId) then
		return
	end

	Utils.Connections.Add(
		"AdminLocal",
		"LocalPlayerChatted",
		LocalPlayer.Chatted:Connect(function(message)
			if message and string.len(message) > 0 and string.sub(message, 1, 1) == ";" then
				local request = ReturnRequestedFunction(string.gsub(message, ";", ""))
				if request then
					adminFunctions[request]()
				end
			end
		end)
	)
end

return AdminLocal

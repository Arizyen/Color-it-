local NameTagManager = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs

-- Variables
local nameTagsEnabled = true

-- Tables
local nameTagsToHide = {
	"BillboardGuiMobNameTag",
	"BillboardGuiNameTag",
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function UpdateNameTagEnabled(player, character)
	if not character then
		return
	end

	if character:FindFirstChild("Head") then
		for _, eachNameTag in pairs(nameTagsToHide) do
			if character.Head:FindFirstChild(eachNameTag) then
				character.Head[eachNameTag].Enabled = nameTagsEnabled
			end
		end

		if not nameTagsEnabled then
			Utils.Connections.Add(
				"NameTagManager",
				"characterHeadChildAdded" .. player.UserId,
				character.Head.ChildAdded:Connect(function(child)
					if child:IsA("BillboardGui") and table.find(nameTagsToHide, child.Name) then
						child.Enabled = nameTagsEnabled
					end
				end)
			)
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function NameTagManager.ShowPlayersNameTags(state)
	nameTagsEnabled = state

	for _, eachPlayer in pairs(game.Players:GetPlayers()) do
		if eachPlayer.Character then
			UpdateNameTagEnabled(eachPlayer, eachPlayer.Character)
		end
	end

	if state then
		Utils.Connections.Add(
			"NameTagManager",
			"PlayerAdded",
			game.Players.PlayerAdded:Connect(function(player)
				Utils.Connections.Add(
					"NameTagManager",
					"characterAdded" .. player.UserId,
					player.CharacterAppearanceLoaded:Connect(function(character)
						UpdateNameTagEnabled(player, character)
					end)
				)
			end)
		)
	else
		Utils.Connections.DisconnectKeyConnections("NameTagManager")
	end
end

return NameTagManager

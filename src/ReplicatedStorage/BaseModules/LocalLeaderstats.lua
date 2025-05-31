local LocalLeaderstats = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables
local leaderstatValueTypes = {
	"IntValue",
	"NumberValue",
	"StringValue",
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER LEADERSTATS -----------------------------------------------------------------------------------------------------------------------------------
local function ConnectEntityLeaderstat(entity, instance)
	if table.find(leaderstatValueTypes, instance.ClassName) then
		LocalLeaderstats.UpdateEntityLeaderstats(entity, instance)
		Utils.Connections.Add(
			entity,
			"leaderstatUpdated" .. instance.Name,
			instance:GetPropertyChangedSignal("Value"):Connect(function()
				LocalLeaderstats.UpdateEntityLeaderstats(entity, instance)
			end)
		)
	end
end

local function CreateLeaderstatConnections(entity, leaderstatsFolder)
	for _, eachChild in pairs(leaderstatsFolder:GetChildren()) do
		ConnectEntityLeaderstat(entity, eachChild)
	end

	Utils.Connections.Add(
		entity,
		"leaderstatsAdded",
		leaderstatsFolder.ChildAdded:Connect(function(child)
			ConnectEntityLeaderstat(entity, child)
		end)
	)
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function LocalLeaderstats.RetrieveAllPlayersLeaderstats()
	for _, eachPlayer in pairs(game.Players:GetPlayers()) do
		LocalLeaderstats.AddPlayerLeaderstats(eachPlayer)
	end
end

function LocalLeaderstats.AddPlayerLeaderstats(player)
	local leaderstatsFolder = player:FindFirstChild("leaderstats")

	if not leaderstatsFolder then
		Utils.Connections.Add(
			player,
			"leaderstatsLoaded",
			player.ChildAdded:Connect(function(child)
				if child:IsA("Folder") and child.Name == "leaderstats" then
					Utils.Connections.DisconnectKeyConnection(player, "leaderstatsLoaded")
					CreateLeaderstatConnections(player, child)
				end
			end)
		)
	else
		CreateLeaderstatConnections(player, leaderstatsFolder)
	end
end

function LocalLeaderstats.AddAILeaderstats(ai)
	if not ai.leaderstats then
		print("Local AI Leaderstats folder is nil")
		return
	end

	CreateLeaderstatConnections(ai, ai.leaderstats)
end

function LocalLeaderstats.UpdateEntityLeaderstats(entity, valueInstance)
	-- if valueInstance is nil, then the leaderstat will be removed
	Utils.Signals.Fire("DispatchAction", {
		type = "UpdateEntityLeaderstats",
		player = entity,
		leaderstats = valueInstance and { [valueInstance.Name] = valueInstance.Value } or nil,
	})
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

return LocalLeaderstats

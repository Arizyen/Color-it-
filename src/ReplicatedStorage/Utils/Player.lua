local Player = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Connections = require(script.Parent:WaitForChild("Connections"))
local WeldUtil = require(script.Parent:WaitForChild("Weld"))

-- FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function Player.GetCharacter(player: Player | Model)
	if player:IsA("Player") then
		return player.Character
	elseif player:IsA("Model") and game.Players:GetPlayerFromCharacter(player) then
		return player -- It's already a character
	end
end

function Player.GetHumanoid(player: Player | Model)
	local character = Player.GetCharacter(player)
	if character then
		return character:FindFirstChildOfClass("Humanoid")
	end
end

function Player.GetRootPart(player: Player | Model)
	if player and player:IsA("Player") then
		if player.Character and player.Character.PrimaryPart then
			return player.Character.PrimaryPart
		end
	elseif player:IsA("Model") and player.PrimaryPart then
		return player.PrimaryPart
	end
end

function Player.Sit(player: Player | Model, seatPart: BasePart)
	local character
	if player:IsA("Player") and player.Character and player.PrimaryPart then
		character = player.Character
	elseif player:IsA("Model") and player.PrimaryPart then
		character = player
	end

	if not character:FindFirstChild("RightUpperLeg") then
		return
	end

	WeldUtil.DestroyWelds(character.PrimaryPart)
	local weld = WeldUtil.Weld(
		character.PrimaryPart,
		seatPart,
		"WeldConstraint",
		CFrame.new(0, ((character.RightUpperLeg.Size.Y / 2) + (character.PrimaryPart.Size.Y / 2)), 0)
		-- CFrame.new(0, (dummy.PrimaryPart.Size.Y / 2) + (seatPart.Size.Y), 0)
	)
	weld.Name = "CustomSeatWeld"
	weld.Parent = seatPart
end

function Player.GetFriendsOnline(player): table
	local success, result = pcall(player.GetFriendsOnline, player)

	if success then
		return result
	else
		-- warn("Failed to get friends online for player:", player.Name, "Error:", result)
		return {}
	end
end

function Player.HasFriendsInServer(player): boolean
	local friendsOnline = Player.GetFriendsOnline(player)
	if not friendsOnline or #friendsOnline == 0 then
		return false
	end

	-- Get friends online in the current game
	local currentJobId = game.JobId
	local friendsInGame = {} :: { [number]: boolean }
	for _, friend in ipairs(friendsOnline) do
		if friend.IsOnline and friend.PlaceId == game.PlaceId and friend.GameId == currentJobId then
			friendsInGame[friend.VisitorId] = true
		end
	end

	for _, eachPlayer in ipairs(game.Players:GetPlayers()) do
		if friendsInGame[eachPlayer.UserId] then
			return true -- Found a friend in the server
		end
	end

	return false
end

function Player.GetPlayerDetails(playerUserId: number)
	local success, result = pcall(function()
		local url = "https://players.roblox.com/v1/users/" .. playerUserId
		local response = HttpService:GetAsync(url)
		return HttpService:JSONDecode(response)
	end)

	if success then
		return result
	else
		warn("Failed to get player details: " .. tostring(result))
		return nil
	end
end

return Player

local Humanoid = {}
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Models = ReplicatedStorage:WaitForChild("Models")

-- Modulescripts

-- Models
local Dummy = Models:WaitForChild("Dummy")

-- Tables
local playersDefaultHumanoidDescription = {}

-- FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
function Humanoid.GetHalfHeight(humanoid)
	if not humanoid or not humanoid.Parent then
		return
	end

	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		return (humanoid.RootPart.Size.Y * 0.5) + humanoid.HipHeight
	elseif humanoid.RigType == Enum.HumanoidRigType.R6 and humanoid.Parent:FindFirstChild("Left Leg") then
		return (humanoid.RootPart.Size.Y * 0.5) + humanoid.Parent["Left Leg"].Size.Y + humanoid.HipHeight
	else
		-- calculate rootPartYHalfSize from model
		return (humanoid.RootPart.Position.Y - (humanoid.RootPart.Size.Y / 2))
			- (humanoid.Parent:GetBoundingBox().Position - humanoid.Parent:GetExtentsSize() / 2).Y
	end
end

function Humanoid.GetPlayerHumanoidDescription(playerUserId: number, saveHumanoidDescription: boolean?, retries)
	if playersDefaultHumanoidDescription[playerUserId] then
		return playersDefaultHumanoidDescription[playerUserId]
	end

	local success, humanoidDescription = pcall(Players.GetHumanoidDescriptionFromUserId, Players, playerUserId)

	if not success or not humanoidDescription then
		retries = retries or 0

		if retries >= 3 then
			return
		else
			task.wait(1)
			return Humanoid.GetPlayerHumanoidDescription(playerUserId, saveHumanoidDescription, retries + 1)
		end
	else
		if saveHumanoidDescription then
			playersDefaultHumanoidDescription[playerUserId] = humanoidDescription
		end
		return humanoidDescription
	end
end

function Humanoid.GetPlayerDummy(playerUserId, saveHumanoidDescription)
	local dummy = Dummy:Clone()

	local humanoidDescription = Humanoid.GetPlayerHumanoidDescription(playerUserId, saveHumanoidDescription)

	if humanoidDescription then
		dummy.Parent = game.Workspace
		dummy.Humanoid:ApplyDescription(humanoidDescription)
	end

	dummy.Parent = ReplicatedStorage

	return dummy
end

-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	if playersDefaultHumanoidDescription[player.UserId] then
		playersDefaultHumanoidDescription[player.UserId]:Destroy()
		playersDefaultHumanoidDescription[player.UserId] = nil
	end
end)

return Humanoid

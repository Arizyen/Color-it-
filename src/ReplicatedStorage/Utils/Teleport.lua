local Teleport = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local Utils = Source:WaitForChild("Utils")

-- Modulescripts
local Raycaster = require(Utils:WaitForChild("Raycaster"))
local HumanoidUtil = require(Utils:WaitForChild("Humanoid"))
local WeldUtil = require(Utils:WaitForChild("Weld"))
local PlayerUtil = require(Utils:WaitForChild("Player"))

-- KnitServices

-- Instances

-- Configs

-- Variables
local isServer = game:GetService("RunService"):IsServer()

-- Tables
local plusAndMinus = { 1, -1 }

export type TeleportParams = {
	position: Vector3?,
	lookAtPosition: Vector3?,
	part: BasePart?, -- this or position is required
	randomPosition: boolean?,
	freeze: boolean?,
	unFreeze: boolean?,
}

type DummyTeleportParams = {
	position: Vector3,
	lookAtPosition: number?,
	part: BasePart?,
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnRandomCFrameOnPart(part)
	return part.CFrame
		* CFrame.new(
			(part.Size.X / 2) * math.random() * plusAndMinus[math.random(2)],
			part.Size.Y / 2,
			(part.Size.Z / 2) * math.random() * plusAndMinus[math.random(2)]
		)
end

local function SetAlignPosition(alignPosition, vector3)
	if alignPosition then
		alignPosition.Position = vector3
		alignPosition.Enabled = true
	end
end

local function SetCharacterAlignOrientation(character, cframe)
	local alignOrientation = character:FindFirstChildWhichIsA("AlignOrientation", true)

	if alignOrientation then
		alignOrientation.CFrame = cframe
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Requires params.part or params.position
function Teleport.Player(player: Player, params: TeleportParams)
	if not player or not params or (not params.part and not params.position) then
		print("Teleport.Player: Invalid parameters")
		warn(debug.traceback(1))
		return
	end

	-- Check if character has primaryPart and is not already being teleported
	if not player.Character or not player.Character.PrimaryPart or player:GetAttribute("teleported") then
		print("Teleport.Player - Player has no character or primaryPart or is already being teleported")
		return
	end

	-- Get humanoid
	local character = player.Character
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not humanoid.RootPart then
		print("Teleport.Player: Invalid humanoid")
		return
	end

	-- Unsit humanoid and destroy welds
	WeldUtil.DestroyWelds(character.PrimaryPart)
	if humanoid.Sit then
		WeldUtil.DestroyWelds(humanoid.SeatPart)
		humanoid.Sit = false

		task.delay(0.25, function()
			Teleport.Player(player, params)
		end)
		return
	end

	-- Set teleported attribute
	player:SetAttribute("teleported", true)

	-- Freeze character during teleport if requested
	if params.freeze then
		player:SetAttribute("Freeze", true)
	end

	-- Calculate height of root part from character base
	local halfHeight = HumanoidUtil.GetHalfHeight(humanoid)

	-- Teleport player and request content around location if applicable
	local cframe

	if params.part and params.part:IsA("Seat") then
		params.part:Sit(humanoid)
	else
		if params.part then
			if params.randomPosition then
				cframe = ReturnRandomCFrameOnPart(params.part)
			else
				cframe = params.part.CFrame + Vector3.new(0, halfHeight + (params.part.Size.Y / 2) + 0.1, 0)
			end
		elseif params.position then
			cframe = CFrame.new(params.position + Vector3.new(0, halfHeight + 0.1, 0))
		end

		if params.lookAtPosition then
			cframe = CFrame.new(
				cframe.Position,
				Vector3.new(params.lookAtPosition.X, cframe.Position.Y, params.lookAtPosition.Z)
			)
		end

		local rawLookVector = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)
		local lookVector = rawLookVector.Magnitude > 1e-4 and rawLookVector.Unit or Vector3.new(0, 0, 1)
		cframe = CFrame.lookAt(cframe.Position, cframe.Position + lookVector)

		local alignPosition = character:FindFirstChildWhichIsA("AlignPosition", true)
		if alignPosition then
			alignPosition.Enabled = false
		end

		character:PivotTo(cframe)

		SetAlignPosition(alignPosition, cframe.Position)
		SetCharacterAlignOrientation(character, cframe)

		if workspace.StreamingEnabled and isServer then
			if player then
				player:RequestStreamAroundAsync(params.position or params.part.Position)
			end
		end
	end

	-- Unfreeze character
	if params.unFreeze then
		player:SetAttribute("Freeze", false)
	end

	player:SetAttribute("teleported", nil)

	return cframe
end

function Teleport.Players(players: { Player }, params: TeleportParams)
	if not players or typeof(players) ~= "table" then
		return
	end

	for _, eachPlayer in pairs(players) do
		if eachPlayer and eachPlayer:IsA("Player") then
			Teleport.Player(eachPlayer, params)
		end
	end
end

function Teleport.Dummy(character, params: DummyTeleportParams)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	-- Calculate height of root part from character base
	local halfHeight = HumanoidUtil.GetHalfHeight(humanoid)
	-- Teleport player and request content around location if applicable
	local cframe
	if params.part then
		if params.randomPosition then
			cframe = ReturnRandomCFrameOnPart(params.part) + Vector3.new(0, halfHeight + 0.1, 0)
		else
			cframe = params.part.CFrame + Vector3.new(0, halfHeight + (params.part.Size.Y / 2) + 0.1, 0)
		end
	elseif params.position then
		cframe = CFrame.lookAlong(
			params.position + Vector3.new(0, halfHeight + 0.1, 0),
			character.PrimaryPart.CFrame.LookVector
		)
	end

	if params.lookAtPosition then
		cframe = CFrame.new(
			cframe.Position,
			Vector3.new(params.lookAtPosition.X, cframe.Position.Y, params.lookAtPosition.Z)
		)
	end

	character:PivotTo(cframe)
end

function Teleport.ToFloor(player)
	if
		not player
		or not player.Character
		or not player.Character.PrimaryPart
		or not player.Character:FindFirstChild("Humanoid")
	then
		return
	end

	local character = player.Character
	local ignoreTable = { character }
	local raycastResult
	local teleportCFrame
	local lookVector = character.PrimaryPart.CFrame.LookVector * 100

	local retries = 0
	local startPosition = character.PrimaryPart.Position

	repeat
		raycastResult = Raycaster.Raycast(startPosition, startPosition - Vector3.new(0, 20, 0), ignoreTable, "Default")

		if raycastResult.Instance and raycastResult.Instance:IsA("BasePart") then
			if raycastResult.Instance.Parent and raycastResult.Instance.CanCollide then
				if not raycastResult.Instance.Parent:FindFirstChild("Humanoid") then
					local hipHeight = HumanoidUtil.GetHipHeight(character:FindFirstChild("Humanoid"))
					if not hipHeight then
						return print("No root part half size")
					end

					teleportCFrame = CFrame.new(
						Vector3.new(
							character.PrimaryPart.Position.X,
							(raycastResult.Position.Y + hipHeight),
							character.PrimaryPart.Position.Z
						),
						character.PrimaryPart.Position + lookVector
					)
					player:SetAttribute("teleported", true)
					character:PivotTo(teleportCFrame)
				else
					table.insert(ignoreTable, raycastResult.Instance.Parent)
				end
			else
				table.insert(ignoreTable, raycastResult.Instance)
			end
		else
			if retries >= 10 then
				return
			else
				retries += 1
			end

			startPosition = startPosition - Vector3.new(0, 20, 0)
		end
	until teleportCFrame or retries >= 10

	player:SetAttribute("teleported", nil)

	return teleportCFrame
end

return Teleport

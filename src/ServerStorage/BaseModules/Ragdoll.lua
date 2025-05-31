local Ragdoll = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
-- local ServerSource = ServerStorage.Source
-- local ReplicatedBaseModules = ReplicatedSource.BaseModules
-- local Configs = ReplicatedSource.Configs
-- local BaseModules = ServerSource.BaseModules
-- local GameModules = ServerSource.GameModules
-- local BaseServices = ServerSource.BaseServices
-- local GameServices = ServerSource.GameServices

-- Modulescripts -------------------------------------------------------------------
local Signals = require(ReplicatedSource.Utils.Signals)

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local _DEFAULT_UNRAGDOLL_WAIT_TIME = 3
local _RAGDOLL_JOINTS_FOLDER_NAME = "_RagdollJoints"
-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local charactersCanCollideStates = {}

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function UnCanCollideCharacter(character)
	for _, eachChild in pairs(character:GetChildren()) do
		if eachChild:IsA("BasePart") then
			if charactersCanCollideStates[character] then
				if charactersCanCollideStates[character][eachChild] ~= nil then
					eachChild.CanCollide = charactersCanCollideStates[character][eachChild]
				end
			else
				eachChild.CanCollide = false
			end
		end
	end
end

local function CanCollideCharacter(character)
	charactersCanCollideStates[character] = {}

	for _, eachChild in pairs(character:GetChildren()) do
		if eachChild:IsA("BasePart") then
			charactersCanCollideStates[character][eachChild] = eachChild.CanCollide
			if eachChild ~= character.PrimaryPart then
				eachChild.CanCollide = true
			end
		end
	end
end

local function UnRagdollCharacter(character: Model, humanoid: Humanoid)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

	local sockets = {}
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("Motor6D") then
			v.Enabled = true
		elseif v.Name == "RagdollSocket" then
			table.insert(sockets, v)
		elseif v.Parent.Name == _RAGDOLL_JOINTS_FOLDER_NAME then
			v.Enabled = false
		end
	end

	for _, v in pairs(sockets) do
		v:Destroy()
	end

	character.PrimaryPart.Anchored = false
	character.PrimaryPart.Massless = false
	humanoid:BuildRigFromAttachments()
	UnCanCollideCharacter(character)

	return true
end

local function RagdollCharacter(character: Model, humanoid: Humanoid)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	CanCollideCharacter(character)

	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if v.Name ~= "Root" and v.Name ~= "RootJoint" then
				local att0 = Instance.new("Attachment")
				att0.Name = "RagdollSocket"
				att0.CFrame = v.C0
				att0.Parent = v.Part0
				local att1 = Instance.new("Attachment")
				att1.Name = "RagdollSocket"
				att1.CFrame = v.C1
				att1.Parent = v.Part1

				local socket = character[_RAGDOLL_JOINTS_FOLDER_NAME]:FindFirstChild(v.Name)
				socket.Attachment0 = att0
				socket.Attachment1 = att1
				socket.Enabled = true

				v.Enabled = false
			end
		end
	end

	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end

	character.PrimaryPart.CanCollide = false
	character.PrimaryPart.Massless = true
	character.PrimaryPart.Anchored = false
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Ragdoll.Tag(player: Player, timeToRagdoll: number | string)
	if
		player:GetAttribute("isRagdolled")
		or not player.Character
		or not player.Character.Parent
		or not player.Character.PrimaryPart
		or not player.Character:FindFirstChild(_RAGDOLL_JOINTS_FOLDER_NAME)
	then
		return
	end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	player:SetAttribute("isRagdolled", os.clock())
	RagdollCharacter(player.Character, humanoid)

	-- UnRagdoll after given time
	if timeToRagdoll then
		local delay = typeof(timeToRagdoll) == "string" and tonumber(string.match(timeToRagdoll, "%d+"))
			or typeof(timeToRagdoll) == "number" and timeToRagdoll
			or _DEFAULT_UNRAGDOLL_WAIT_TIME

		task.delay(delay, function()
			Ragdoll.Untag(player)
		end)
	end

	return true
end

function Ragdoll.Untag(player: Player)
	if
		not player:GetAttribute("isRagdolled")
		or not player.Character
		or not player.Character.Parent
		or not player.Character.PrimaryPart
	then
		return
	end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	UnRagdollCharacter(player.Character, humanoid)
	player:SetAttribute("isRagdolled", nil)

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
Signals.Connect("PlayerDied", function(player)
	Ragdoll.Tag(player)
end)

Signals.Connect("PlayerCharacterAdded", function(player)
	player:SetAttribute("isRagdolled", nil)
end)
------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Ragdoll

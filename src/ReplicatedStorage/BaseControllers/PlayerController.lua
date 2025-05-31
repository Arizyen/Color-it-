-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))

-- KnitControllers
local PlayerController = Knit.CreateController({
	Name = "Player",
})

-- Instances
local LocalPlayer = game.Players.LocalPlayer

-- Configs

-- Variables

-- Tables
local knitServices = {}
local plusAndMinus = { 1, -1 }
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnPlayerCharacterAndHumanoid(player)
	if player and player.Character then
		return player.Character, player.Character:FindFirstChildOfClass("Humanoid")
	end
end

local function ReturnRandomPartCFrame(primaryPart)
	return primaryPart.CFrame
		* CFrame.new(
			(primaryPart.Size.X / 2) * (math.random(100) / 100) * plusAndMinus[math.random(2)],
			0,
			(primaryPart.Size.Z / 2) * (math.random(100) / 100) * plusAndMinus[math.random(2)]
		)
end

local function Teleport(cframe)
	if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
		LocalPlayer.Character:PivotTo(cframe)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayerController:KnitInit()
	knitServices["Player"] = Knit.GetService("Player")
end

function PlayerController:KnitStart()
	knitServices["Player"]:KnitLoaded()
	knitServices["Player"].Teleport:Connect(Teleport)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROLLER FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- MANAGING SPEED -----------------------------------------------------------------------------------------------------------------------------------
function PlayerController:Freeze(state)
	knitServices["Player"]:Freeze(state)

	if state then
		local _, humanoid = ReturnPlayerCharacterAndHumanoid(LocalPlayer)
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end
	end

	-- print("Freezing player", state)
end
-- MISCELLANEOUS FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function PlayerController:ShowNameTag(state)
	local character = ReturnPlayerCharacterAndHumanoid(LocalPlayer)
	if character and character:FindFirstChild("Head") then
		local nameTag = character.Head:FindFirstChild("BillboardGuiNameTag")
		if nameTag then
			nameTag.Enabled = state
		end
	end
end

function PlayerController:Spawn()
	knitServices["Player"]:Spawn()
end

function PlayerController:Reset()
	knitServices["Player"]:Reset()
end

return PlayerController

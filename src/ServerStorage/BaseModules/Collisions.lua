local Collisions = {}
-- Services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
-- local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules

-- Modulescripts

-- Tables
Collisions.playersCollisions = {}

-- Services
local PhysicsService = game:GetService("PhysicsService")
-- LOCAL FUNCTIONS -----------------------------------------------------------
local function SetCollisionGroup(part, group)
	if not part then
		return
	end
	if part:IsA("BasePart") then
		if not part:GetAttribute("lockedCollisionGroup") then
			if group then
				part.CollisionGroup = group
			end
		else
			part.CollisionGroup = part:GetAttribute("lockedCollisionGroup")
		end
	end
end

local function SetCollisionGroupCollidable(collisionGroup, collisionGroupsCollidable)
	collisionGroupsCollidable = collisionGroupsCollidable or {}
	for _, eachCollisionGroupInfo in pairs(PhysicsService:GetRegisteredCollisionGroups()) do
		if not table.find(collisionGroupsCollidable, eachCollisionGroupInfo.name) then
			PhysicsService:CollisionGroupSetCollidable(collisionGroup, eachCollisionGroupInfo.name, false)
		else
			PhysicsService:CollisionGroupSetCollidable(collisionGroup, eachCollisionGroupInfo.name, true)
		end
	end
end
-- GLOBAL FUNCTIONS ----------------------------------------------------------
function Collisions.CreateCollisionGroups()
	-- Creating collision groups
	PhysicsService:RegisterCollisionGroup("PlayersCollide")
	PhysicsService:RegisterCollisionGroup("PlayersNoCollide")
	PhysicsService:RegisterCollisionGroup("PlayersNoCollideRaycast")
	PhysicsService:RegisterCollisionGroup("NPCNoCollide")
	PhysicsService:RegisterCollisionGroup("CollideOnlyWithPlayers")
	PhysicsService:RegisterCollisionGroup("ObjectsNoCollideWithAll")

	PhysicsService:RegisterCollisionGroup("Tower")
	PhysicsService:RegisterCollisionGroup("TowerRaycast")

	-- Setting collision group rules
	SetCollisionGroupCollidable("PlayersCollide", { "Default", "PlayersCollide" })
	SetCollisionGroupCollidable("PlayersNoCollide", { "Default" })
	SetCollisionGroupCollidable("PlayersNoCollideRaycast", { "PlayersNoCollide" })
	SetCollisionGroupCollidable("NPCNoCollide", { "Default" })
	SetCollisionGroupCollidable("CollideOnlyWithPlayers", { "PlayersCollide", "PlayersNoCollide" })
	SetCollisionGroupCollidable("ObjectsNoCollideWithAll", {})

	SetCollisionGroupCollidable("Tower", { "Default", "PlayersNoCollide", "PlayersCollide" })
	SetCollisionGroupCollidable("TowerRaycast", { "Tower" })
end

Collisions.SetCollisionGroup = SetCollisionGroup

function Collisions.SetCollisionGroup(object, group)
	if not object then
		return
	end
	SetCollisionGroup(object, group)

	for _, eachChild in pairs(object:GetChildren()) do
		Collisions.SetCollisionGroup(eachChild, group)
	end
end

function Collisions.SetModelCollisionGroup(model, group)
	for _, eachDescendant in pairs(model:GetDescendants()) do
		if eachDescendant:IsA("BasePart") then
			eachDescendant:SetAttribute("collisionGroup", group)
			SetCollisionGroup(eachDescendant, group)
		end
	end
end

function Collisions.SetPlayerCollisionGroup(player, collisionGroup)
	if not player or not player.Character then
		return
	end

	local char = player.Character
	-- if no collision groups was given, set it to Players default collision group.
	if not collisionGroup then
		if not Collisions.playersCollisions[player] then
			collisionGroup = "PlayersNoCollide"
			Collisions.playersCollisions[player] = collisionGroup
			Collisions.SetCollisionGroup(char, collisionGroup)
			return
		end
	else
		Collisions.playersCollisions[player] = collisionGroup
		Collisions.SetCollisionGroup(char, collisionGroup)
	end

	char.DescendantAdded:Connect(function(descendant)
		if descendant:GetAttribute("collisionGroup") then
			Collisions.SetCollisionGroup(descendant, descendant:GetAttribute("collisionGroup"))
		else
			Collisions.SetCollisionGroup(descendant, Collisions.playersCollisions[player])
		end
	end)
end

-- RUNNING FUNCTIONS ----------------------------------------------------------------------------------------------------
Collisions.CreateCollisionGroups()

-- CREATING CONNECTIONS -------------------------------------------------------------------------------------------------
game.Players.PlayerRemoving:Connect(function(player)
	Collisions.playersCollisions[player] = nil
end)

return Collisions

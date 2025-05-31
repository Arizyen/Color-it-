local MovementManager = {}
-- Services ------------------------------------------------------------------------
-- local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
-- local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
-- local ServerSource = ServerStorage.Source
local Configs = ReplicatedSource.Configs
-- local BaseModules = ServerSource.BaseModules
-- local GameModules = ServerSource.GameModules
-- local BaseServices = ServerSource.BaseServices
-- local GameServices = ServerSource.GameServices

-- Modulescripts -------------------------------------------------------------------
local Utils = require(ReplicatedSource.Utils)
local MovementConfigs = require(Configs.MovementConfigs)

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function MovementManager.Activate(entity, character, humanoid)
	humanoid.WalkSpeed = MovementConfigs._WALK_SPEED
	humanoid.JumpPower = MovementConfigs._JUMP_POWER

	entity:SetAttribute("walkSpeed", MovementConfigs._WALK_SPEED)
	entity:SetAttribute("maxWalkSpeed", MovementConfigs._MAX_WALK_SPEED)

	entity:SetAttribute("jumpPower", MovementConfigs._JUMP_POWER)
	entity:SetAttribute("maxJumpPower", MovementConfigs._MAX_JUMP_POWER)

	-- Reset all attributes
	entity:SetAttribute("SetWalkSpeed", nil)
	entity:SetAttribute("SetJumpPower", nil)
	entity:SetAttribute("SetMaxWalkSpeed", nil)
	entity:SetAttribute("SetMaxJumpPower", nil)
	entity:SetAttribute("Freeze", nil)

	-- Connections
	Utils.Connections.Add(
		entity,
		"SetMaxWalkSpeed",
		entity:GetAttributeChangedSignal("SetMaxWalkSpeed"):Connect(function()
			local maxWalkSpeed = entity:GetAttribute("SetMaxWalkSpeed")
			if type(maxWalkSpeed) == "number" then
				entity:SetAttribute("maxWalkSpeed", maxWalkSpeed)
				if humanoid and humanoid.WalkSpeed > maxWalkSpeed then
					entity:SetAttribute("walkSpeed", maxWalkSpeed)
				end

				entity:SetAttribute("SetMaxWalkSpeed", nil)
			end
		end)
	)

	Utils.Connections.Add(
		entity,
		"SetMaxJumpPower",
		entity:GetAttributeChangedSignal("SetMaxJumpPower"):Connect(function()
			local maxJumpPower = entity:GetAttribute("SetMaxJumpPower")
			if typeof(maxJumpPower) == "number" then
				entity:SetAttribute("maxJumpPower", maxJumpPower)
				if humanoid and humanoid.JumpPower > maxJumpPower then
					entity:SetAttribute("jumpPower", maxJumpPower)
				end

				entity:SetAttribute("SetMaxJumpPower", nil)
			end
		end)
	)

	Utils.Connections.Add(
		entity,
		"SetWalkSpeed",
		entity:GetAttributeChangedSignal("SetWalkSpeed"):Connect(function()
			local walkSpeed = entity:GetAttribute("SetWalkSpeed")
			if typeof(walkSpeed) == "number" then
				local newWalkSpeed = walkSpeed <= entity:GetAttribute("maxWalkSpeed") and walkSpeed
					or entity:GetAttribute("maxWalkSpeed")

				if not entity:GetAttribute("frozen") and humanoid then
					humanoid.WalkSpeed = newWalkSpeed
				end

				entity:SetAttribute("walkSpeed", newWalkSpeed)
				entity:SetAttribute("SetWalkSpeed", nil)
			end
		end)
	)

	Utils.Connections.Add(
		entity,
		"SetJumpPower",
		entity:GetAttributeChangedSignal("SetJumpPower"):Connect(function()
			local jumpPower = entity:GetAttribute("SetJumpPower")

			if typeof(jumpPower) == "number" then
				local newJumpPower = jumpPower <= entity:GetAttribute("maxJumpPower") and jumpPower
					or entity:GetAttribute("maxJumpPower")

				if not entity:GetAttribute("frozen") and humanoid then
					humanoid.JumpPower = newJumpPower
				end

				entity:SetAttribute("jumpPower", newJumpPower)
				entity:SetAttribute("SetJumpPower", nil)
			end
		end)
	)

	Utils.Connections.Add(
		entity,
		"Freeze",
		entity:GetAttributeChangedSignal("Freeze"):Connect(function()
			if character and character.PrimaryPart then
				local freeze = entity:GetAttribute("Freeze")
				if freeze == nil then
					return
				end
				-- character.PrimaryPart.Anchored = freeze

				entity:SetAttribute("frozen", freeze)

				if freeze then
					humanoid.WalkSpeed = 0
					humanoid.JumpPower = 0
					character.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
					character.PrimaryPart.AssemblyAngularVelocity = Vector3.new()
				else
					entity:SetAttribute(
						"SetWalkSpeed",
						entity:GetAttribute("maxWalkSpeed") or MovementConfigs._WALK_SPEED
					)
					entity:SetAttribute(
						"SetJumpPower",
						entity:GetAttribute("maxJumpPower") or MovementConfigs._JUMP_POWER
					)
				end

				entity:SetAttribute("Freeze", nil)
			end
		end)
	)
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return MovementManager

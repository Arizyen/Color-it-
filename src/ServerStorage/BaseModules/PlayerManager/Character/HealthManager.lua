local HealthManager = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedBaseModules = ReplicatedSource.BaseModules
local Configs = ReplicatedSource.Configs
local BaseModules = ServerSource.BaseModules
local GameModules = ServerSource.GameModules
local BaseServices = ServerSource.BaseServices
local GameServices = ServerSource.GameServices

-- Modulescripts -------------------------------------------------------------------
local Utils = require(ReplicatedSource.Utils)

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local playersCurrentHP = {} :: { [Player]: number }
local playersMaxHP = {} :: { [Player]: number }

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function HealthManager.Activate(player: Player, humanoid: Humanoid)
	playersCurrentHP[player] = player:GetAttribute("hp")
	playersMaxHP[player] = player:GetAttribute("maxHP")

	Utils.Connections.Add(
		player,
		"maxHP",
		player:GetAttributeChangedSignal("maxHP"):Connect(function()
			local maxHP = player:GetAttribute("maxHP")
			if typeof(maxHP) == "number" then
				playersMaxHP[player] = maxHP
			end
		end)
	)
	Utils.Connections.Add(
		player,
		"hp",
		player:GetAttributeChangedSignal("hp"):Connect(function()
			local hp = player:GetAttribute("hp")
			if typeof(hp) == "number" then
				if hp <= 0 then
					hp = 0
					humanoid.Health = 0
				end

				playersCurrentHP[player] = hp
			end
		end)
	)
	Utils.Connections.Add(
		player,
		"AddHP",
		player:GetAttributeChangedSignal("AddHP"):Connect(function()
			local addHP = player:GetAttribute("AddHP")
			if typeof(addHP) == "number" and not player:GetAttribute("isDead") then
				local hp = playersCurrentHP[player]
				local maxHP = playersMaxHP[player]
				if typeof(hp) == "number" and typeof(maxHP) == "number" then
					player:SetAttribute("hp", math.min(maxHP, hp + addHP))
				end
			end
			player:SetAttribute("AddHP", nil)
		end)
	)
	Utils.Connections.Add(
		player,
		"RemoveHP",
		player:GetAttributeChangedSignal("RemoveHP"):Connect(function()
			local removeHP = player:GetAttribute("RemoveHP")
			if typeof(removeHP) == "number" then
				local hp = playersCurrentHP[player]
				if typeof(hp) == "number" then
					player:SetAttribute("hp", math.max(0, hp - removeHP))
				end
			end
			player:SetAttribute("RemoveHP", nil)
		end)
	)
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
game.Players.PlayerRemoving:Connect(function(player)
	playersCurrentHP[player] = nil
	playersMaxHP[player] = nil
end)

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return HealthManager

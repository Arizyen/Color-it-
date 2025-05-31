local Group = {}
local Rewards = require(script.Parent)
setmetatable(Group, { __index = Rewards })
-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local _GROUP_REWARD_GEMS = 300

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL METHODS ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Group:Award(player)
	if not self.PlayersDataService:GetPlayerData(player) then
		self.MessageService:SendMessageToPlayer(
			player,
			"Error claiming group rewards: Data did not load. Please try again later.",
			"Error"
		)
		return false
	end

	if self.PlayersDataService:PlayerIsInGroup(player) then
		if self.PlayersDataService:GetKeyValue(player, "groupRewardAwarded") then
			self.MessageService:SendMessageToPlayer(player, "You have already claimed the group reward!", "Error")
			return false
		end

		self.PlayersDataService:SetKeyValue(player, "groupRewardAwarded", true)
		if self.InventoryManager.AddGems(player, _GROUP_REWARD_GEMS) then
			self.MessageService:SendMessageToPlayer(player, "You have claimed the group reward!", "RewardClaimed")
			return true
		else
			self.PlayersDataService:SetKeyValue(player, "groupRewardAwarded", false)
			self.MessageService:SendMessageToPlayer(
				player,
				"Error claiming group rewards: Data did not save. Please try again later.",
				"Error"
			)
			return false
		end
	else
		self.MessageService:SendMessageToPlayer(
			player,
			"You must have joined our group Triangular to claim this reward!",
			"Error"
		)
	end
end
------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Group

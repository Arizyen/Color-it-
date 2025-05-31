local Premium = {}
local Rewards = require(script.Parent)
setmetatable(Premium, { __index = Rewards })
-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local _PREMIUM_REWARD_GEMS = 300
-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL METHODS ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Premium:Award(player)
	if self.PlayersDataService:GetKeyValue(player, "premiumRewardAwarded") then
		self.MessageService:SendMessageToPlayer(player, "You have already claimed the premium reward!", "Error")
		return false
	elseif player.MembershipType ~= Enum.MembershipType.Premium then
		self.MessageService:SendMessageToPlayer(player, "You must be a premium user to claim this reward!", "Error")
		self.StoreService:PurchasePremium(player)
	end

	if not self.PlayersDataService:GetPlayerData(player) then
		self.MessageService:SendMessageToPlayer(
			player,
			"Error claiming premium rewards: Data did not save. Please try again later.",
			"Error"
		)
		return
	end

	if
		player.MembershipType == Enum.MembershipType.Premium
		and self.PlayersDataService:SetKeyValue(player, "premiumRewardAwarded", true)
	then
		if self.InventoryManager.AddGems(player, _PREMIUM_REWARD_GEMS, true) then
			self.MessageService:SendMessageToPlayer(player, "You have claimed the premium reward!", "RewardClaimed")
		else
			self.PlayersDataService:SetKeyValue(player, "premiumRewardAwarded", false)
			self.MessageService:SendMessageToPlayer(
				player,
				"Error claiming premium rewards: Data did not save. Please try again later.",
				"Error"
			)
		end
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

return Premium

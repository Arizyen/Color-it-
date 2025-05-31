local Donations = {}
local Store = require(script.Parent)
setmetatable(Donations, { __index = Store })

-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Donations:ProcessReceipt(receiptInfo)
	if not self.DonationsInfo.infos[self.DonationsStore[receiptInfo.ProductId]] then
		return
	end

	local player = self:GetPlayerFromReceiptInfo(receiptInfo)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Add the donation to the player and save it in data store
	local success = self.InventoryManager.AddSponsorsToPlayer(player, receiptInfo.CurrencySpent)
	if not success then
		self.MessageService:SendMessageToPlayer(player, "The purchase was not successful. Please try again.", "Error")
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
		self.MessageService:SendMessage(
			player.DisplayName .. " has sponsored the game with " .. tostring(receiptInfo.CurrencySpent) .. " Robux!"
		)

		self.MessageService:SendMessageToPlayer(
			player,
			string.format(
				"Thank you for your sponsor of %s Robux. Your sponsors keep the game alive!",
				tostring(receiptInfo.CurrencySpent)
			),
			"Success"
		)

		self:PlayerSpentRobux(player, receiptInfo.CurrencySpent)

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end
------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Donations:IsValid(assetId)
	return self.DonationsStore[assetId] ~= nil and self.DonationsInfo.infos[self.DonationsStore[assetId]] ~= nil
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Donations

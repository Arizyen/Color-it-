local Coins = {}
local Store = require(script.Parent)
setmetatable(Coins, { __index = Store })
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
function Coins:ProcessReceipt(receiptInfo)
	local player = self:GetPlayerFromReceiptInfo(receiptInfo)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local coinsAmount = self.CoinsInfo.infos[self.CoinsStore[receiptInfo.ProductId]].amount

	if self.InventoryManager.AddCoins(player, coinsAmount, true) then
		self.MessageService:SendMessageToPlayer(
			player,
			string.format("You have purchased %s coins!", self.Utils.Number.Spaced(coinsAmount, 1000)),
			"PurchaseSuccessful"
		)
		self:PlayerSpentRobux(player, receiptInfo.CurrencySpent)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		self.MessageService:SendMessageToPlayer(
			player,
			string.format(
				"Your coins purchase of %s cannot currently be processed.",
				self.Utils.Number.Spaced(coinsAmount, 1000)
			),
			"Error"
		)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end
------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Coins:IsValid(assetId)
	return self.CoinsStore[assetId] ~= nil and self.CoinsInfo.infos[self.CoinsStore[assetId]] ~= nil
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Coins

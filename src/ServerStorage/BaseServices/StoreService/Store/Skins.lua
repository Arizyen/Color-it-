local Skins = {}
local Store = require(script.Parent)
setmetatable(Skins, { __index = Store })
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
function Skins:ProcessReceipt(receiptInfo)
	local player = self:GetPlayerFromReceiptInfo(receiptInfo)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local skinName = self.SkinsStore[receiptInfo.ProductId]
	local success = false

	self.PlayersDataService
		:SetKeyIndexValue(player, "skins", skinName, true, true)
		:andThen(function(value)
			success = value
		end)
		:catch(function()
			success = false
		end)
		:await()

	if not success then
		self.PlayersDataService:SetKeyIndexValue(player, "skins", skinName, false, true)

		self.MessageService:SendMessageToPlayer(
			player,
			"Your purchase of " .. skinName .. " could not be processed. Please try again.",
			"Error"
		)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		-- Equip skin

		self:PlayerSpentRobux(player, receiptInfo.CurrencySpent)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end
------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Skins:IsValid(assetId)
	return self.SkinsStore[assetId] ~= nil and self.TilesInfo.infos[self.SkinsStore[assetId]] ~= nil
end

function Skins:CanPurchase(player, assetId)
	if not self.SkinsStore[assetId] or not self.TilesInfo.infos[self.SkinsStore[assetId]] then
		return false
	end

	if self.PlayersDataService:GetKeyValue(player, "skins", self.SkinsStore[assetId]) then
		self.MessageService:SendMessageToPlayer(
			player,
			"You already own the skin: " .. self.SkinsStore[assetId],
			"Error"
		)
		return false
	end

	return false
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Skins

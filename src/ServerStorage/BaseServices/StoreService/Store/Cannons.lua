local Cannons = {}
local Store = require(script.Parent)
setmetatable(Cannons, { __index = Store })
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
function Cannons:ProcessReceipt(receiptInfo)
	local player = self:GetPlayerFromReceiptInfo(receiptInfo)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local canonName = self.CannonsStore[receiptInfo.ProductId]
	local success = false

	self.PlayersDataService
		:SetKeyIndexValue(player, "canons", canonName, true, true)
		:andThen(function(value)
			if value then
				success = true
				self.MessageService:SendMessageToPlayer(
					player,
					"You have purchased the cannon: " .. canonName,
					"Success"
				)
			else
				self.MessageService:SendMessageToPlayer(
					player,
					"Your cannon purchase of " .. canonName .. " cannot currently be processed.",
					"Success"
				)
			end
		end)
		:catch(function()
			success = false
		end)
		:await()

	if success then
		self:PlayerSpentRobux(player, receiptInfo.CurrencySpent)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		self.PlayersDataService:SetKeyIndexValue(player, "canons", canonName, false, true)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end
------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Cannons:IsValid(assetId)
	return self.CannonsStore[assetId] ~= nil and self.CanonsInfo.infos[self.CannonsStore[assetId]] ~= nil
end

function Cannons:CanPurchase(player, assetId)
	if not self.CannonsStore[assetId] or not self.CanonsInfo.infos[self.CannonsStore[assetId]] then
		return false
	end

	if self.PlayersDataService:GetKeyValue(player, "canons", self.CannonsStore[assetId]) then
		self.MessageService:SendMessageToPlayer(
			player,
			"You already own the cannon: " .. self.CanonsInfo.infos[self.CannonsStore[assetId]].name,
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

return Cannons

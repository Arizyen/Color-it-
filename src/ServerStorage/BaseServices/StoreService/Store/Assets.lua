local Assets = {}
local Store = require(script.Parent)
setmetatable(Assets, { __index = Store })
-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local totalAssetsBought = 0
local totalAssetsEarning = 0
-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Assets:PlayerBoughtAsset(player, assetId, isPurchased)
	if not isPurchased then
		self.MessageService:SendMessageToPlayer(player, "The purchase was not successful. Please try again.", "Error")
		return
	end

	if not self.PlayersDataService:GetKeyValue(player, "assetsOwned", tostring(assetId)) then
		self.PlayersDataService:SetKeyIndexValue(player, "assetsOwnedList", nil, tostring(assetId))
	end

	self.PlayersDataService:SetKeyIndexValue(player, "assetsOwned", tostring(assetId), true)
	self.PlayersDataService:SetKeyIndexValue(player, "assetsOwnedRobux", tostring(assetId), true, true)

	self.MessageService:SendMessageToPlayer(
		player,
		"The purchase was successful. You now have the item in your inventory!",
		"Success"
	)

	-- Functions for stats
	local price = (self:GetProductPrice(assetId) * 0.4)
	self:PlayerSpentRobux(player, price)

	totalAssetsBought += 1
	totalAssetsEarning += price
	print(
		"Player "
			.. player.Name
			.. " bought an asset with robux. AssetId: "
			.. tostring(assetId)
			.. ". Price: "
			.. tostring(price)
	)
	print("Total asset bought in server: " .. tostring(totalAssetsBought))
	print("Total estimated commission earnings from asset: " .. tostring(totalAssetsEarning))
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

return Assets

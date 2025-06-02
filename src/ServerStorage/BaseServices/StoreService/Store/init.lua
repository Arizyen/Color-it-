local Store = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local Infos = ReplicatedSource.Infos
local ReplicatedBaseModules = ReplicatedSource.BaseModules
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
local GameServices = ServerStorage.Source.GameServices

-- Modulescripts -------------------------------------------------------------------
local DataStore = require(BaseModules.DataStore)
local EntitiesData = require(BaseModules.EntitiesData)
Store.InventoryManager = require(BaseModules.InventoryManager)
Store.NameTag = require(BaseModules.PlayerManager.NameTag)
Store.Utils = require(ReplicatedSource.Utils)

Store.GamepassesInfo = require(Infos.Store.GamepassesInfo)
Store.GemsInfo = require(Infos.Store.GemsInfo)
Store.CoinsInfo = require(Infos.Store.CoinsInfo)

-- KnitServices --------------------------------------------------------------------
Store.PlayersDataService = require(BaseServices.PlayersDataService)
Store.LeaderboardService = require(BaseServices.LeaderboardService)
Store.MessageService = require(BaseServices.MessageService)

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL METHODS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Store:PlayerSpentRobux(player, amount)
	if amount <= 0 or not EntitiesData.sortedData["Robux"] then
		return
	end

	if EntitiesData.sortedData["Robux"].allTime[player.UserId] then
		EntitiesData.sortedData["Robux"].allTime[player.UserId] += amount
		self.PlayersDataService:SavePlayerData(player, self.LeaderboardService.dataStores["Robux"].allTime)
		self.PlayersDataService:SetKeyValue(player, "robux", EntitiesData.sortedData["Robux"].allTime[player.UserId])
	end

	if EntitiesData.sortedData["Robux"].weekly[player.UserId] then
		EntitiesData.sortedData["Robux"].weekly[player.UserId] += amount
		self.PlayersDataService:SavePlayerData(player, self.LeaderboardService.dataStores["Robux"].weekly)
		self.PlayersDataService:SetKeyValue(
			player,
			"weeklyRobux",
			EntitiesData.sortedData["Robux"].weekly[player.UserId]
		)
	end
end

function Store:GetPlayerFromReceiptInfo(receiptInfo)
	return Players:GetPlayerByUserId(receiptInfo.PlayerId)
end
-- PRODUCTS ----------------------------------------------------------------------------------------------------
function Store:GetProductInfo(productId, infoType: Enum.InfoType)
	local success, productInfo = pcall(function()
		return self.MarketplaceService:GetProductInfo(productId, infoType)
	end)
	if success then
		return productInfo
	end
end

function Store:GetProductPrice(productId, infoType: Enum.InfoType)
	local productInfo = self:GetProductInfo(tonumber(productId), infoType)
	return productInfo and productInfo["PriceInRobux"] or 0
end
------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Store:IsValid(assetId)
	return false
end

function Store:CanPurchase(player, assetId)
	return true
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Store

-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Folders
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local Configs = ReplicatedStorage.Source.Configs
local Packages = ReplicatedStorage.Packages
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Knit = require(Packages.Knit)
local Assets = require(script.Store.Assets)
local Coins = require(script.Store.Coins)
local Gems = require(script.Store.Gems)
local Gamepasses = require(script.Store.Gamepasses)

-- KnitServices
local StoreService = Knit.CreateService({
	Name = "Store",
})
local MessageService = require(BaseServices.MessageService)
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances

-- Configs

-- Variables

-- Tables
local allDevProductPurchaseModules = {
	Coins = Coins,
	Gems = Gems,
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function DetermineDevProductPurchase(receiptInfo)
	for _, eachPurchaseModule in pairs(allDevProductPurchaseModules) do
		if eachPurchaseModule:IsValid(receiptInfo.ProductId) then
			return eachPurchaseModule:ProcessReceipt(receiptInfo)
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function CanPurchase(player, assetId)
	if not player or type(assetId) ~= "number" then
		return false
	end

	for _, eachPurchaseModule in pairs(allDevProductPurchaseModules) do
		if eachPurchaseModule:IsValid(assetId) and eachPurchaseModule:CanPurchase(player, assetId) then
			return true
		end
	end

	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function StoreService:KnitInit() end

function StoreService:KnitStart()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(...)
		Gamepasses:PlayerPurchasedGamePass(...)
	end)
	MarketplaceService.PromptPurchaseFinished:Connect(function(...)
		Assets:PlayerBoughtAsset(...)
	end)
	MarketplaceService.ProcessReceipt = DetermineDevProductPurchase
end

-- PURCHASE GAMEPASS -----------------------------------------------------------------------------------------------------------------------------------
function StoreService:PurchaseGamepass(player, gamepassKey)
	-- Fire prompt to player
	if
		type(gamepassKey) == "string"
		and Gamepasses:IsValid(gamepassKey)
		and Gamepasses:CanPurchase(player, gamepassKey)
	then
		MarketplaceService:PromptGamePassPurchase(player, Gamepasses:GetGamepassId(gamepassKey))
	end
end

-- Checks if player owns gamepass and if not fires purchase prompt for the player
function StoreService:OwnsGamepass(player, gamepassKey)
	if not PlayersDataService:OwnsGamepass(player, gamepassKey) then
		-- Send player gamepass purchase prompt
		MarketplaceService:PromptGamePassPurchase(player, Gamepasses:GetGamepassId(gamepassKey))
		return false
	else
		return true
	end
end
-- PURCHASE ASSET -----------------------------------------------------------------------------------------------------------------------------------
function StoreService:PurchaseAsset(player, assetId)
	MarketplaceService:PromptPurchase(player, tonumber(assetId))
end

function StoreService:PurchaseDevProduct(player, assetId)
	if not CanPurchase(player, assetId) then
		return false
	end

	MarketplaceService:PromptProductPurchase(player, assetId)
end

function StoreService:PurchasePremium(player)
	MarketplaceService:PromptPremiumPurchase(player)
end
-- CLIENT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function StoreService.Client:PurchaseGamepass(player, gamepassKey)
	self.Server:PurchaseGamepass(player, gamepassKey)
end

function StoreService.Client:PurchaseAsset(player, assetId)
	self.Server:PurchaseAsset(player, assetId)
end

function StoreService.Client:PurchaseDevProduct(player, assetId)
	self.Server:PurchaseDevProduct(player, assetId)
end

return StoreService

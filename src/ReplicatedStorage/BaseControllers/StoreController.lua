-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local BaseControllers = Source:WaitForChild("BaseControllers")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))

-- KnitControllers
local StoreController = Knit.CreateController({
	Name = "Store",
})
local PlayersDataController = require(BaseControllers:WaitForChild("PlayersDataController"))
-- Instances

-- Configs

-- Variables

-- Tables
local knitServices = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function StoreController:KnitInit()
	knitServices["Store"] = Knit.GetService("Store")
end

function StoreController:KnitStart() end

function StoreController:PurchaseGamepass(gamepassName)
	knitServices["Store"]:PurchaseGamepass(gamepassName)
end

function StoreController:PurchaseDevProduct(assetId)
	knitServices["Store"]:PurchaseDevProduct(assetId)
end

function StoreController:Revive()
	return knitServices["Store"]:Revive()
end

-- Checks if player owns gamepass and if not fires the server to make the purchase
function StoreController:OwnsGamepass(gamepassName)
	if not PlayersDataController:GetKeyValue("gamepasses", gamepassName) then
		-- Fire server to purchase gamepass
		self:PurchaseGamepass(gamepassName)
		return false
	else
		return true
	end
end

return StoreController

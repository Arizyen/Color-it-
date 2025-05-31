local Gamepass = {}
-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local Infos = ReplicatedStorage.Source.Infos
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts -------------------------------------------------------------------
local Gamepasses = require(Infos.Store.GamepassesInfo)
local EntitiesData = require(BaseModules.EntitiesData)

-- KnitServices --------------------------------------------------------------------
local PlayersDataService = require(BaseServices.PlayersDataService)
-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local _MAX_RETRIES = 3
-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Gamepass.Owned(player, gamePassId, retries)
	local success, result =
		pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, gamePassId)
	if not success then
		if not retries then
			retries = 0
		end
		retries += 1

		if retries >= _MAX_RETRIES then
			print("Cannot check if user owns gamepass. Server issue.", success, result)
			return false
		end

		task.wait(3)
		return Gamepass.Owned(player, gamePassId, retries)
	end
	return result
end

function Gamepass.Verify(player)
	if not EntitiesData.data[player.UserId] or not EntitiesData.data[player.UserId]["gamepasses"] then
		return
	end

	for eachGamepassName, eachGamepassInfo in pairs(Gamepasses.infos) do
		if Gamepass.Owned(player, eachGamepassInfo.passId) then
			-- print("Player owns gamepass: " .. eachGamePassName)
			if player and EntitiesData.data[player.UserId] and EntitiesData.data[player.UserId]["gamepasses"] then
				PlayersDataService:SetKeyIndexValue(player, "gamepasses", eachGamepassName, true, true)
			end
		else
			-- print("Player doesn't own gamepass: " .. eachGamePassName)
			-- if
			-- 	player
			-- 	and EntitiesData.data[player.UserId]
			-- 	and EntitiesData.data[player.UserId]["gamepasses"]
			-- then
			-- 	PlayersDataService:SetKeyIndexValue(player, "gamepasses", eachGamePassName, false, true)
			-- end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Gamepass

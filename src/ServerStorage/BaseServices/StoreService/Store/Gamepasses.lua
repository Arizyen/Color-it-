local Gamepasses = {}
local Store = require(script.Parent)
setmetatable(Gamepasses, { __index = Store })

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
local function GetGamepassKeyFromId(gamePassId)
	for key, gamepassInfo in pairs(Gamepasses.GamepassesInfo.infos) do
		if gamepassInfo.id == gamePassId then
			return key
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Gamepasses:PlayerPurchasedGamePass(player, gamePassId, success)
	local gamepassKey = GetGamepassKeyFromId(gamePassId)

	if success and gamepassKey then
		print(player.Name .. " purchased the game pass " .. gamepassKey .. " with ID " .. gamePassId .. ".")

		self.PlayersDataService:SetKeyIndexValue(player, "gamepasses", gamepassKey, true, true)

		if gamepassKey == "vip" then
			self.PlayersDataService:SetKeyValue(player, "rainbowNametagEnabled", true)
			self.NameTag.GiveEntityNameTag(player, player.Character)
		end

		gamepassKey = string.upper(string.sub(gamepassKey, 1, 1)) .. string.sub(gamepassKey, 2)
		self.MessageService:SendMessage(player.DisplayName .. " has purchased the " .. gamepassKey .. " game pass!")
		self.MessageService:SendMessageToPlayer(player, "You have purchased the game pass: " .. gamepassKey, "Success")

		local gamepassInfo = self:GetProductInfo(gamePassId, Enum.InfoType.GamePass)
		local priceInRobux = gamepassInfo and gamepassInfo["PriceInRobux"] or 0
		self:PlayerSpentRobux(player, priceInRobux)
	else
		-- Fire the client to show frame saying not enough robux
		self.MessageService:SendMessageToPlayer(
			player,
			"The game pass purchase was not successful. Please try again.",
			"Error"
		)
	end
end

function Gamepasses:GetGamepassId(gamepassKey)
	return self.GamepassesInfo.infos[gamepassKey] and self.GamepassesInfo.infos[gamepassKey].id or nil
end

------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Store:IsValid(gamepassKey)
	return self.GamepassesInfo.infos[gamepassKey] ~= nil
end

function Store:CanPurchase(player, gamepassKey)
	if self.PlayersDataService:OwnsGamepass(player, gamepassKey) then
		self.MessageService:SendMessageToPlayer(
			player,
			string.format("You already own the %s gamepass", self.GamepassesInfo.infos[gamepassKey].name),
			"Error"
		)
		return false
	end

	return true
end

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Gamepasses

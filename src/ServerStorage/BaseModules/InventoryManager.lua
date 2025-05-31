local InventoryManager = {}
-- Services
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local EntitiesData = require(BaseModules.EntitiesData)
local DataStore = require(BaseModules.DataStore)
local Level = require(BaseModules.Level)
local Badges = require(BaseModules.PlayerManager.Badges)
local NumberUtil = require(ReplicatedStorage.Source.Utils.Number)

-- KnitServices
local PlayersDataService = require(BaseServices.PlayersDataService)
local MessageService = require(BaseServices.MessageService)
local LeaderboardService = require(BaseServices.LeaderboardService)

-- Instances

-- Configs

-- Variables
local randomGenerator = Random.new()
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- PURCHASING STUFF WITH CURRENCY ----------------------------------------------------------------------------------------------------------------------
function InventoryManager.CanPurchase(player, productCost, currencyType, playerCurrencyCount: number?)
	playerCurrencyCount = playerCurrencyCount or PlayersDataService:GetKeyValue(player, currencyType)
	if playerCurrencyCount and playerCurrencyCount < productCost then
		MessageService:SendMessageToPlayer(
			player,
			string.format(
				"You do not have enough %s. You need %s more %s!",
				currencyType,
				NumberUtil.ToEnglish(productCost - playerCurrencyCount),
				currencyType
			),
			"Error"
		)
	end

	return playerCurrencyCount and playerCurrencyCount >= productCost
end

function InventoryManager.Purchase(player, productCost, noSave)
	local playerCoins = PlayersDataService:GetKeyValue(player, "coins")

	if InventoryManager.CanPurchase(player, productCost, "coins", playerCoins) then
		-- Make the purchase and reduce the money of the player
		playerCoins -= productCost
		PlayersDataService:SetKeyValue(player, "coins", playerCoins, not noSave)
		return true
	end

	return false
end

function InventoryManager.PurchaseWithGems(player, productCost, ignoreTimer, returnPromise)
	local playerTickets = PlayersDataService:GetKeyValue(player, "tickets")

	if InventoryManager.CanPurchase(player, productCost, "tickets", playerTickets) then
		-- Make the purchase and reduce the currency of the player
		playerTickets -= productCost
		local success = PlayersDataService:SetKeyValue(player, "tickets", playerTickets, true, ignoreTimer)
		-- Check if it's a promise and if so return its result
		if returnPromise and success and type(success) ~= "boolean" then
			success
				:andThen(function(value)
					success = value
				end)
				:await()
		end
		return success
	end

	return false
end

-- UPDATING PLAYER DATA --------------------------------------------------------------------------------------------------------------------------------
function InventoryManager.AddSponsorsToPlayer(player, sponsorAmount)
	if
		not player
		or not player:IsA("Player")
		or not EntitiesData.data[player.UserId]
		or not EntitiesData.playersDataLoaded[player.UserId]["PlayersTotalSponsors"]
		or not sponsorAmount
	then
		return
	end
	-- playersDonations[Player] is set to 0 by default. We need this check to make sure it was actually loaded.
	if
		type(EntitiesData.sortedData["Sponsors"].allTime[player.UserId]) ~= "number"
		or type(EntitiesData.sortedData["Sponsors"].weekly[player.UserId]) ~= "number"
	then
		return false
	end

	local success = true

	EntitiesData.sortedData["Sponsors"].allTime[player.UserId] += sponsorAmount
	PlayersDataService:SavePlayerData(player, LeaderboardService.dataStores["Sponsors"].allTime)
		:andThen(function(value)
			if not value then
				success = false
				EntitiesData.sortedData["Sponsors"].allTime[player.UserId] -= sponsorAmount
			end
		end)
		:await()

	if success then
		EntitiesData.sortedData["Sponsors"].weekly[player.UserId] += sponsorAmount
		PlayersDataService:SavePlayerData(player, LeaderboardService.dataStores["Sponsors"].weekly)
			:andThen(function(value)
				if not value then
					success = false
					EntitiesData.sortedData["Sponsors"].weekly[player.UserId] -= sponsorAmount
					if EntitiesData.sortedData["Sponsors"].allTime[player.UserId] then
						EntitiesData.sortedData["Sponsors"].allTime[player.UserId] -= sponsorAmount
					end
				end
			end)
			:await()
	end

	if success then
		PlayersDataService:SetKeyValue(
			player,
			"sponsors",
			EntitiesData.sortedData["Sponsors"].allTime[player.UserId],
			true
		)
		PlayersDataService:SetKeyValue(
			player,
			"weeklySponsors",
			EntitiesData.sortedData["Sponsors"].weekly[player.UserId],
			true
		)
	end

	return success
end

function InventoryManager.AddGems(player, amount, makeSave, ignoreTimer)
	local playerTickets = PlayersDataService:GetKeyValue(player, "tickets")
	if type(playerTickets) ~= "number" then
		return
	end
	playerTickets += math.round(amount)

	PlayersDataService:IncrementKeyValue(player, "totalTickets", math.round(amount))

	if makeSave then
		local promise = PlayersDataService:SetKeyValue(player, "tickets", playerTickets, makeSave, ignoreTimer, 3)
		local success = false

		if type(promise) == "table" then
			promise
				:andThen(function(value)
					success = value
				end)
				:await()
		elseif type(promise) == "boolean" then
			success = promise
		end

		if not success then
			-- Remove/Add back the tickets to default value
			PlayersDataService:SetKeyValue(player, "tickets", playerTickets - math.round(amount), makeSave, ignoreTimer)
			PlayersDataService:IncrementKeyValue(player, "totalTickets", -math.round(amount))
		end

		return success
	else
		PlayersDataService:SetKeyValue(player, "tickets", playerTickets)
		return true
	end
end

function InventoryManager.GiveGemsOverTime(player, amount, intervals, totalTimeInterval)
	if type(amount) ~= "number" then
		return
	end

	intervals = (type(intervals) == "number" and math.clamp(intervals, intervals, amount))
		or 5 < amount and 5
		or math.round(amount / 2)
	totalTimeInterval = type(totalTimeInterval) == "number" and totalTimeInterval or 1

	-- Add random amounts that equals to amount over intervals
	local randomAmounts = {}
	local totalRandomAmount = 0
	for i = 1, intervals do
		local randomAmount = randomGenerator:NextInteger(1, math.round(amount / intervals))
		table.insert(randomAmounts, randomAmount)
		totalRandomAmount += randomAmount
	end

	-- Add the remaining amount to the last interval
	randomAmounts[#randomAmounts] += amount - totalRandomAmount

	local interval, count = 0, 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		interval += dt
		if interval >= totalTimeInterval / intervals then
			interval -= totalTimeInterval / intervals
			count += 1

			PlayersDataService:IncrementKeyValue(player, "tickets", randomAmounts[count])
			PlayersDataService:IncrementKeyValue(player, "totalTickets", randomAmounts[count])

			if count >= intervals then
				connection:Disconnect()

				if player and player.Parent and not player:IsA("Player") and player:IsA("AI") then
					player:ReceivedGems()
				end
			end
		end
	end)
end

function InventoryManager.AddCoins(player, amount, makeSave, ignoreTimer)
	local playerCoins = PlayersDataService:GetKeyValue(player, "coins")
	if type(playerCoins) ~= "number" then
		print("Player coins is not a number")
		return
	end
	playerCoins += math.round(amount)

	PlayersDataService:IncrementKeyValue(player, "totalCoins", math.round(amount))

	if makeSave then
		local promise = PlayersDataService:SetKeyValue(player, "coins", playerCoins, makeSave, ignoreTimer)
		local success = false

		if type(promise) == "table" then
			promise
				:andThen(function(value)
					success = value
				end)
				:await()
		elseif type(promise) == "boolean" then
			success = promise
		end

		if not success then
			print("Failed to save coins")
			-- Remove/Add back the coins to default value
			PlayersDataService:SetKeyValue(player, "coins", playerCoins - math.round(amount), makeSave, ignoreTimer)
			PlayersDataService:IncrementKeyValue(player, "totalCoins", -math.round(amount))
		end

		return success
	else
		PlayersDataService:SetKeyValue(player, "coins", playerCoins)
		return true
	end
end

function InventoryManager.AddXP(player, xp, makeSave)
	local playerLvl = PlayersDataService:GetKeyValue(player, "level")
	local playerXP = PlayersDataService:GetKeyValue(player, "xp")

	if playerLvl and playerXP then
		Level.LoadPlayerLevelXP(playerLvl)
		playerXP += xp

		if playerXP >= Level.playerLevelsXP["level" .. playerLvl] then
			repeat
				playerXP -= Level.playerLevelsXP["level" .. playerLvl]
				playerLvl += 1

				Level.LoadPlayerLevelXP(playerLvl)
			-- Player has leveled up
			until playerXP < Level.playerLevelsXP["level" .. playerLvl]

			PlayersDataService:SetKeyValue(player, "level", playerLvl, true)
			PlayersDataService:SetKeyValue(player, "xp", playerXP, true)
			PlayersDataService:SetKeyValue(player, "maxXP", Level.playerLevelsXP["level" .. playerLvl], true)

			MessageService:SendMessageToPlayer(
				player,
				string.format("You have leveled up to level %s!", playerLvl),
				"LevelUp"
			)

			player:SetAttribute("level", playerLvl)
		else
			playerXP = math.min(math.round(playerXP), Level.playerLevelsXP["level" .. playerLvl])
		end

		PlayersDataService:SetKeyValue(player, "xp", math.round(playerXP))

		-- Set and save ordered data stores
		PlayersDataService:IncrementKeyValue(player, "xpAllTime", math.round(xp))
		PlayersDataService:IncrementKeyValue(player, "weeklyXP", math.round(xp), makeSave) -- Save at last to avoid saving multiple times
		LeaderboardService:IncrementPlayerLeaderboard(player, "XP", math.round(xp))
	end
end

function InventoryManager.AddWins(player, wins, makeSave)
	PlayersDataService:IncrementKeyValue(player, "wins", wins)
	PlayersDataService:IncrementKeyValue(player, "weeklyWins", wins, makeSave) -- Save at last to avoid saving multiple times
	LeaderboardService:IncrementPlayerLeaderboard(player, "Wins", wins)
end

return InventoryManager

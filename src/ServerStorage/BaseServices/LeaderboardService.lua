-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
local ReplicatedLeaderboardFolder = ReplicatedStorage:FindFirstChild("Leaderboards")
local Keys = ReplicatedStorage.Source.Keys

-- Modulescripts
local Knit = require(Packages.Knit)
local EntitiesData = require(BaseModules.EntitiesData)
local DataStore = require(BaseModules.DataStore)
local HumanoidManager = require(BaseModules.HumanoidManager)
local Collisions = require(BaseModules.Collisions)
local Badges = require(BaseModules.PlayerManager.Badges)
local NameTag = require(BaseModules.PlayerManager.NameTag)
local LeaderboardKeys = require(Keys.LeaderboardKeys)

-- KnitServices
local LeaderboardService = Knit.CreateService({
	Name = "Leaderboard",
	Client = {
		UpdateLeaderboardKeyData = Knit.CreateSignal(),
		SetLeaderboardWeekUpdateTime = Knit.CreateSignal(),
		SetLeaderboardUpdateTime = Knit.CreateSignal(),
	},
})
local PlayersDataService = require(BaseServices.PlayersDataService)

-- Instances

-- Configs
local _INITIAL_SUNDAY_TIME = 1691884800
local _UPDATE_INTERVAL = 60
local PAGE_AMOUNT = 1 -- Each page is 100 record
local DEFAULT_COLOR = Color3.fromRGB(255, 255, 127)

-- Variables
LeaderboardService.weekResetTime = 0
LeaderboardService.currentWeekNumber = 0
local timer = 7 -- Wait 7 seconds before loading leaderboards for the first time
local lastWeekNumber

-- Tables
LeaderboardService.dataStores = {} -- {Name = {allTime = OrderedDataStore, weekly = OrderedDataStore}}
local dataStoreNamesKeyCreated = {}

local leaderboardsDummies = {}

local cacheUsernames = {}

local topColors = { Color3.fromRGB(255, 215, 0), Color3.fromRGB(192, 192, 192), Color3.fromRGB(205, 127, 50) }
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- DATASTORE UTILITY FUNCTIONS ------------------------------------------------------------------------------------------------------------------------
local function CreateLeaderboardFolder(name)
	if not ReplicatedLeaderboardFolder then
		ReplicatedLeaderboardFolder = Instance.new("Folder")
		ReplicatedLeaderboardFolder.Name = "Leaderboards"
		ReplicatedLeaderboardFolder.Parent = ReplicatedStorage
	end

	local leaderboardFolder = Instance.new("Folder")
	leaderboardFolder.Name = name
	leaderboardFolder.Parent = ReplicatedLeaderboardFolder
end

local function GetCurrentWeekNumber()
	local currentTime = os.time()
	local remainingTime = currentTime - _INITIAL_SUNDAY_TIME
	local weekNumber = math.floor(remainingTime / 604800) -- 604800 == 1 week time

	if weekNumber > 0 then
		remainingTime = 604800 - (remainingTime % 604800)
	else
		remainingTime = 604800 - remainingTime
	end

	LeaderboardService.weekResetTime = os.time() + remainingTime
	LeaderboardService.currentWeekNumber = weekNumber

	return weekNumber
end

local function RemoveLastWeekDataStores()
	if lastWeekNumber and GetCurrentWeekNumber() ~= lastWeekNumber then
		for eachLeaderboardKey, eachDataStores in pairs(LeaderboardService.dataStores) do
			if dataStoreNamesKeyCreated[eachLeaderboardKey .. tostring(lastWeekNumber)] then
				-- Remove last week's datastores
				DataStore.RemoveDataStore(eachDataStores.weekly)

				-- Reset all players weekly data to 0
				if
					EntitiesData.sortedData[eachLeaderboardKey] and EntitiesData.sortedData[eachLeaderboardKey].weekly
				then
					for _, eachPlayer in pairs(Players:GetPlayers()) do
						if EntitiesData.sortedData[eachLeaderboardKey].weekly[eachPlayer.UserId] then
							EntitiesData.sortedData[eachLeaderboardKey].weekly[eachPlayer.UserId] = 0
						end
						PlayersDataService:SetKeyValue(eachPlayer, "weekly" .. eachLeaderboardKey, 0)
					end
				end
			end
		end
	end
end
-- LEADERBOARD UPDATING FUNCTIONS ---------------------------------------------------------------------------------------------------------------------
local function HasBudget()
	local budget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetSortedAsync)
	if budget >= 1 then
		return true
	end
end

local function ReturnPositionColor(index)
	local color = DEFAULT_COLOR --Default color
	if index == 1 then
		color = Color3.fromRGB(212, 175, 55) --1st place color
	elseif index == 2 then
		color = Color3.fromRGB(192, 192, 192) --2nd place color
	elseif index == 3 then
		color = Color3.fromRGB(159, 122, 52) --3rd place color
	end
	return color
end

function GetUsernameFromUserId(userId)
	-- First, check if the cache contains the name
	if cacheUsernames[userId] then
		return cacheUsernames[userId]
	end
	-- Second, check if the user is already connected to the server
	local player = Players:GetPlayerByUserId(userId)
	if player then
		cacheUsernames[userId] = player.Name
		return player.Name
	end
	-- If all else fails, send a request
	local name
	pcall(function()
		name = Players:GetNameFromUserIdAsync(userId)
	end)
	cacheUsernames[userId] = name
	return name
end

local function UpdateLeaderboardDummies(dataStoreType, topRecords, isAllTimeData)
	local leaderboardKey = isAllTimeData and dataStoreType or dataStoreType .. "Weekly"
	if type(leaderboardsDummies[leaderboardKey]) ~= "table" then
		leaderboardsDummies[leaderboardKey] = {}
	end

	for i = 1, 3 do
		if topRecords[i] then
			if
				(
					leaderboardsDummies[leaderboardKey][i]
					and leaderboardsDummies[leaderboardKey][i].Name ~= topRecords[i]["Name"]
				) or not leaderboardsDummies[leaderboardKey][i]
			then
				if leaderboardsDummies[leaderboardKey][i] then
					leaderboardsDummies[leaderboardKey][i]:Destroy()
				end

				local playerDummy, playerData = HumanoidManager.ReturnPlayerDummy(topRecords[i]["UserId"])
				if playerDummy then
					-- print("Dummy for: " .. topRecords[i]["Name"] .. " created")
					playerDummy.Parent = game.Workspace
					-- HumanoidManager.ChangeCharacterSize(playerDummy, 1.15)
					playerDummy:ScaleTo(1.05)
					Collisions.SetCollisionGroup(playerDummy, "ObjectsNoCollideWithAll")
					playerDummy.PrimaryPart.Anchored = true
					playerDummy.Name = topRecords[i]["Name"]
					playerDummy:SetAttribute("leaderboardName", dataStoreType)
					playerDummy:SetAttribute("allTimeRanking", isAllTimeData)
					playerDummy:SetAttribute("rank", i)
					playerDummy.Parent = ReplicatedLeaderboardFolder[dataStoreType]
					leaderboardsDummies[leaderboardKey][i] = playerDummy

					if type(playerData) == "table" then
						NameTag.GiveDummyNameTag(
							playerDummy,
							topRecords[i]["Name"],
							topColors[i] or Color3.fromRGB(255, 255, 255)
						)
					end
				else
					-- print("No dummy for: " .. topRecords[i]["Name"])
				end
			end
		end
	end
end

local function ReturnTopRecordsTable(dataStore)
	--print("Returning top 10")
	local topRecords = {}
	local isAscending = false
	local pageSize = 100
	local pages
	pcall(function()
		pages = dataStore:GetSortedAsync(isAscending, pageSize)
	end)
	if not pages then
		-- print("No pages")
		return
	end
	-- For each item, 'data.key' is the key in the OrderedDataStore and 'data.value' is the value

	for i = 1, PAGE_AMOUNT do
		local topScores = pages:GetCurrentPage()
		for rank, data in ipairs(topScores) do
			local userId = data.key
			if tonumber(userId) >= 0 then
				local value
				value = data.value
				if value and value > 0 then
					local name = GetUsernameFromUserId(userId)

					local newRecord = {
						["UserId"] = tonumber(userId),
						["Value"] = value,
						["Name"] = name,
					}
					if value ~= nil and name ~= nil then
						table.insert(topRecords, newRecord)
						--print(newRecord["name"])
					end
					--print("User: "..data.key.." has a score of: "..tostring(data.value))
				end
			end
		end

		if pages.IsFinished then
			break
		end
		if PAGE_AMOUNT > 1 then
			-- Load the next page.
			pages:AdvanceToNextPageAsync()
		end
	end

	if #topRecords >= 1 then
		return topRecords
	end
end

local function UpdateLeaderboard(dataStoreType: string, dataStore, isAllTimeData)
	if not HasBudget() then
		-- print("No budget")
		return
	end

	local topRecords = ReturnTopRecordsTable(dataStore)
	if not topRecords then
		return
	end
	UpdateLeaderboardDummies(dataStoreType, topRecords, isAllTimeData)

	local leaderboardKey = string.format("%s%s", dataStoreType, isAllTimeData and "AllTime" or "Weekly")
	EntitiesData.topRecords[leaderboardKey] = topRecords

	LeaderboardService.Client.UpdateLeaderboardKeyData:FireAll(leaderboardKey, topRecords)

	EntitiesData.top100Names[leaderboardKey] = EntitiesData.top100Names[leaderboardKey] or {}
	table.clear(EntitiesData.top100Names[leaderboardKey])

	local player
	for i = 1, #topRecords do
		if topRecords[i]["Name"] then
			EntitiesData.top100Names[leaderboardKey][topRecords[i]["Name"]] = true
		end

		player = Players:GetPlayerByUserId(topRecords[i]["UserId"])
		if player then
			-- Badges.Award(player, leaderboardKey, "Leaderboard", false)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function LeaderboardService:KnitInit() end

function LeaderboardService:KnitStart()
	LeaderboardService:Start(LeaderboardKeys)
end
-- MODULE FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- UTILITY FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function LeaderboardService:Start(names) -- name = leaderboard folder
	if type(names) == "table" then
		for _, eachName in pairs(names) do
			LeaderboardService.dataStores[eachName] = {
				allTime = DataStoreService:GetOrderedDataStore("allTime" .. eachName),
				weekly = nil,
			}
			EntitiesData.sortedData[eachName] = {
				allTime = {},
				weekly = {},
			}
			CreateLeaderboardFolder(eachName)
		end
	end

	self:AddCurrentWeekDataStores()

	task.spawn(function()
		while true do
			-- verify if timeLeftUntilNextWeek <= 0 and if so, update the data stores
			if LeaderboardService.weekResetTime - os.time() <= 0 then
				self:AddCurrentWeekDataStores()
				self:UpdateLeaderboards()
			end

			-- update the leaderboard every 60 seconds
			if timer <= 0 then
				timer = _UPDATE_INTERVAL
				self:UpdateLeaderboards()
			else
				timer -= 1
			end

			task.wait(1)
		end
	end)
end

function LeaderboardService:AddCurrentWeekDataStores()
	RemoveLastWeekDataStores()
	local currentWeekNumber = GetCurrentWeekNumber()
	lastWeekNumber = currentWeekNumber

	self.Client.SetLeaderboardWeekUpdateTime:FireAll(LeaderboardService.weekResetTime)

	for eachLeaderboardKey, eachDataStores in pairs(LeaderboardService.dataStores) do
		if not dataStoreNamesKeyCreated[eachLeaderboardKey .. tostring(currentWeekNumber)] then
			dataStoreNamesKeyCreated[eachLeaderboardKey .. tostring(currentWeekNumber)] = true

			-- Get this week's datastores
			eachDataStores.weekly = DataStore.CreateOrderedDataStore(
				eachLeaderboardKey .. tostring(currentWeekNumber),
				EntitiesData.sortedData[eachLeaderboardKey].weekly
			)

			-- Reload all players weekly data stores so that EntitiesData.playersDataLoaded[player][dataStore.Name] is true
			for _, eachPlayer in pairs(Players:GetPlayers()) do
				DataStore.Load(eachPlayer, eachDataStores.weekly)
			end
		end
	end
end

-- UPDATING LEADERBOARDS --------------------------------------------------------------------------------------------------------------------------
-- WIll update the leaderboard gui as well as update the top3 players' dummy model
function LeaderboardService:UpdateLeaderboards()
	for i = 1, 2 do
		for eachLeaderboardKey, eachDataStores in pairs(LeaderboardService.dataStores) do
			UpdateLeaderboard(eachLeaderboardKey, i == 1 and eachDataStores.allTime or eachDataStores.weekly, i == 1)
		end
	end

	self.Client.SetLeaderboardUpdateTime:FireAll(game.Workspace:GetServerTimeNow() + timer)
end

function LeaderboardService:IncrementPlayerLeaderboard(player, leaderboardType, increment)
	if not LeaderboardService.dataStores[leaderboardType] then
		print("Leaderboard type not found", leaderboardType)
		return
	end

	local newLeaderboardValues = {
		allTime = EntitiesData.sortedData[leaderboardType].allTime[player.UserId] + increment,
		weekly = EntitiesData.sortedData[leaderboardType].weekly[player.UserId] + increment,
	}

	-- Update the player's data
	for eachOrderedTimeFrame, eachValue in pairs(newLeaderboardValues) do
		if eachValue > 0 then
			EntitiesData.sortedData[leaderboardType][eachOrderedTimeFrame][player.UserId] = eachValue
			PlayersDataService:SavePlayerData(
				player,
				LeaderboardService.dataStores[leaderboardType][eachOrderedTimeFrame],
				eachValue
			)
		end
	end
end
-- CLIENT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function LeaderboardService.Client:ReturnLeaderboardsData()
	return EntitiesData.topRecords
end

function LeaderboardService.Client:ReturnWeekUpdateTime()
	return LeaderboardService.weekResetTime
end

function LeaderboardService.Client:ReturnUpdateTime()
	return os.time() + timer
end

return LeaderboardService

local Store = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local BaseReducers = script.Parent:WaitForChild("BaseReducers")
local GameReducers = script.Parent:WaitForChild("GameReducers")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Reducers
local PlayerStatsReducer = require(BaseReducers:WaitForChild("PlayerStatsReducer"))
local ThemeReducer = require(BaseReducers:WaitForChild("ThemeReducer"))
local GameStateReducer = require(BaseReducers:WaitForChild("GameStateReducer"))
local WindowStateReducer = require(BaseReducers:WaitForChild("WindowStateReducer"))
local DataReducer = require(BaseReducers:WaitForChild("DataReducer"))
local PlayersDataReducer = require(BaseReducers:WaitForChild("PlayersDataReducer"))
local LeaderstatsReducer = require(BaseReducers:WaitForChild("LeaderstatsReducer"))
local NotificationsReducer = require(BaseReducers:WaitForChild("NotificationsReducer"))
local AlertReducer = require(BaseReducers:WaitForChild("AlertReducer"))
local PromptReducer = require(BaseReducers:WaitForChild("PromptReducer"))
local StoreReducer = require(BaseReducers:WaitForChild("StoreReducer"))
local AnimatedArrowsReducer = require(BaseReducers:WaitForChild("AnimatedArrowsReducer"))
local LeaderboardReducer = require(BaseReducers:WaitForChild("LeaderboardsReducer"))
local OverlayReducer = require(BaseReducers:WaitForChild("OverlayReducer"))
local CustomMessageReducer = require(BaseReducers:WaitForChild("CustomMessageReducer"))

-- Instances

-- Configs
local ENABLE_DEBUGGING = false

-- Variables
local store = nil

-- Tables

--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------
local function ReturnLoggerMiddleWare()
	if RunService:IsStudio() and ENABLE_DEBUGGING then
		return Rodux.loggerMiddleware
	end
end

local function ReturnReducers()
	return Rodux.combineReducers({
		playerStats = PlayerStatsReducer,
		data = DataReducer,
		game = GameStateReducer,
		theme = ThemeReducer,
		window = WindowStateReducer,
		alerts = AlertReducer,
		playersData = PlayersDataReducer,
		leaderstats = LeaderstatsReducer,
		notifications = NotificationsReducer,
		prompt = PromptReducer,
		store = StoreReducer,
		animatedArrows = AnimatedArrowsReducer,
		leaderboard = LeaderboardReducer,
		overlay = OverlayReducer,
		customMessage = CustomMessageReducer,
	})
end
--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
function Store.ReturnStore()
	if store then
		return store
	else
		store = Rodux.Store.new(ReturnReducers(), nil, { ReturnLoggerMiddleWare() })
		return store
	end
end

function Store.GetState(stateName, key)
	if store then
		return store:getState()[stateName][key]
	end
end

-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Connect("DispatchAction", function(data)
	Store.ReturnStore()
	if store and type(data) == "table" then
		store:dispatch(data)
	end
end)

return Store

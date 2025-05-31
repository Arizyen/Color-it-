local AdManager = {}
-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local BaseControllers = Source:WaitForChild("BaseControllers")

-- Modulescripts -------------------------------------------------------------------
local Signals = require(Source:WaitForChild("Utils")).Signals

-- KnitControllers -----------------------------------------------------------------
local PlayersDataController = require(BaseControllers:WaitForChild("PlayersDataController"))

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------
local _MAX_SHOW_TIMES_PER_AD = 2 -- User has to click or close the ad twice to stop showing it
local _MIN_WAIT_TIME_AD_SHOW = 60 * 5 -- 5 minutes
local _MAX_WAIT_TIME_AD_SHOW = 60 * 7 -- 8 minutes

-- local _MIN_WAIT_TIME_AD_SHOW = 10 -- 5 minutes
-- local _MAX_WAIT_TIME_AD_SHOW = 15 -- 8 minutes

-- Variables -----------------------------------------------------------------------
local currentWaitTime = 0
local running = false

-- Tables --------------------------------------------------------------------------
local notificationIds = {
	"vip",
}
local notificationIdsComponentName = {
	vip = "NotificationVIP",
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function CanShowAd()
	local adShownTimes = PlayersDataController:GetKeyValue("adShownTimes")
	if type(adShownTimes) ~= "table" then
		return false
	end

	-- Remove ads that have reached max show times
	for i = #notificationIds, 1, -1 do
		if
			type(adShownTimes[notificationIds[i]]) == "number"
			and adShownTimes[notificationIds[i]] >= _MAX_SHOW_TIMES_PER_AD
		then
			table.remove(notificationIds, i)
		end
	end

	-- Remove ads if gamepass is already owned
	local gamepasses = PlayersDataController:GetKeyValue("gamepasses")
	if type(gamepasses) == "table" then
		for i = #notificationIds, 1, -1 do
			if gamepasses[notificationIds[i]] then
				table.remove(notificationIds, i)
			end
		end
	end

	if #notificationIds == 0 then
		return false
	else
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function AdManager.Start()
	if running then
		return
	end
	running = true

	task.spawn(function()
		-- Only start ad manager if there are ads to show
		if #notificationIds == 0 or not CanShowAd() then
			return
		end

		local nextWaitTime
		repeat
			currentWaitTime = 0
			nextWaitTime = math.random(_MIN_WAIT_TIME_AD_SHOW, _MAX_WAIT_TIME_AD_SHOW)
			repeat
				task.wait(1)

				if game.Players.LocalPlayer:GetAttribute("isAlive") then
					currentWaitTime += 1
				end
			until currentWaitTime >= nextWaitTime or #notificationIds == 0

			if #notificationIds == 0 then
				return
			end
			-- Pick a random ad and show it
			local randomAd = notificationIds[math.random(#notificationIds)]

			Signals.Fire("ShowNotification", notificationIdsComponentName[randomAd], nil, 10, false, true)
		until #notificationIds == 0

		running = false
	end)
end

function AdManager.IncrementAdShownTimes(key)
	local adShownTimes = PlayersDataController:GetKeyValue("adShownTimes")
	if type(adShownTimes) ~= "table" then
		return
	end

	if adShownTimes[key] then
		PlayersDataController:SetKeyValue("adShownTimes", adShownTimes[key] + 1, key)
	else
		PlayersDataController:SetKeyValue("adShownTimes", 1, key)
	end
end

function AdManager.UpdateCanShowAd()
	if CanShowAd() then
		AdManager.Start()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

return AdManager

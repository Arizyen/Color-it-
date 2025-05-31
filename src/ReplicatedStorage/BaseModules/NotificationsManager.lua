local NotificationsManager = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local UI = Source:WaitForChild("UI")
local Notifications = UI:WaitForChild("Notifications")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs
local _MAX_SHOW_TIME = 10
local _MAX_ID_COUNT = 10000

-- Variables
local timerStarted = false
local currentId = 0

-- Tables
local notificationsTimer = {}
local allNotificationIds = {}
local allNotificationIdsComponentName = {}
local componentsNotificationCount = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnUniqueId()
	-- Reset to 0 if no notificationIds
	if #allNotificationIds == 0 then
		currentId = 0
	end

	currentId += 1

	-- Reset currentId to 1 if higher than _MAX_ID_COUNT
	-- if currentId > _MAX_ID_COUNT then
	-- 	if notificationsTimer["notification1"] then
	-- 		repeat
	-- 			currentId += 1
	-- 		until not notificationsTimer["notification" .. currentId]
	-- 	else
	-- 		currentId = 1
	-- 	end
	-- end

	-- Return unique currentId not taken
	if not notificationsTimer[currentId] then
		table.insert(allNotificationIds, currentId)
		return "notification" .. currentId
	else
		repeat
			currentId += 1
		until not notificationsTimer[currentId]

		table.insert(allNotificationIds, currentId)
		return "notification" .. currentId
	end
end

local function AddComponentNotificationCount(componentName, state)
	if not componentName then
		return
	end

	if not componentsNotificationCount[componentName] then
		componentsNotificationCount[componentName] = 0
	end

	if state then
		componentsNotificationCount[componentName] += 1
	else
		componentsNotificationCount[componentName] -= componentsNotificationCount[componentName] - 1 >= 0 and 1 or 0
	end
end

local function DeleteId(id)
	if notificationsTimer[id] then
		notificationsTimer[id] = nil
		AddComponentNotificationCount(allNotificationIdsComponentName[id], false)
		allNotificationIdsComponentName[id] = nil

		if table.find(allNotificationIds, id) then
			table.remove(allNotificationIds, table.find(allNotificationIds, id))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function NotificationsManager.Start()
	if timerStarted then
		return
	end
	timerStarted = true
	-- Create the connections
	Utils.Signals.Connect("ShowNotification", NotificationsManager.ShowNotification)
	Utils.Signals.Connect("HideNotification", NotificationsManager.HideNotification)
	-- Start the timer
	task.spawn(function()
		while true do
			for eachNotificationId, timeToHide in pairs(notificationsTimer) do
				if os.time() > timeToHide then
					Utils.Signals.Fire("DispatchAction", {
						type = "UpdateNotification",
						id = eachNotificationId,
						value = nil,
					})
					DeleteId(eachNotificationId)
				end
			end
			task.wait(1)
		end
	end)
end

function NotificationsManager.ShowNotification(
	componentName,
	props,
	maxShowTime,
	noNotificationSound,
	noDuplicateNotification
) -- Props is table of key,value needed for the component used. Reserved Keys: id
	if
		noDuplicateNotification
		and componentsNotificationCount[componentName]
		and componentsNotificationCount[componentName] > 0
	then
		return
	end

	props = type(props) == "table" and props or {}
	if type(componentName) ~= "string" or not Notifications:FindFirstChild(componentName) then
		print("Component not found", componentName)
		return
	end

	-- Fire the store the notification with its unique id
	props["id"] = ReturnUniqueId()
	props["timeShown"] = os.time()
	props["layoutOrder"] = tonumber(string.match(props["id"], "%d+"))
	notificationsTimer[props["id"]] = maxShowTime and os.time() + maxShowTime or os.time() + _MAX_SHOW_TIME
	allNotificationIdsComponentName[props["id"]] = componentName
	AddComponentNotificationCount(componentName, true)

	if not noNotificationSound then
		Utils.Sound.PlaySound({ SoundId = "rbxassetid://11646730151", Tag = "SoundEffect" })
	end

	Utils.Signals.Fire("DispatchAction", {
		type = "UpdateNotification",
		id = props["id"],
		value = { componentName = componentName, props = props },
	})

	return props["id"]
end

function NotificationsManager.HideNotification(notificationId)
	if notificationsTimer[notificationId] then
		Utils.Signals.Fire("DispatchAction", {
			type = "UpdateNotification",
			id = notificationId,
			value = nil,
		})
		DeleteId(notificationId)
	end
end
-- RUNNING FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
NotificationsManager.Start()

return NotificationsManager

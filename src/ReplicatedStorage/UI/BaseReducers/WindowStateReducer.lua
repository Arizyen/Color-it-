-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local BaseControllers = Source:WaitForChild("BaseControllers")

-- Modulescripts
local Rodux = require(Packages:WaitForChild("Rodux"))
local Utils = require(Source:WaitForChild("Utils"))
local LightingManager = require(ReplicatedBaseModules:WaitForChild("LightingManager"))
local CoreGuiManager = require(ReplicatedBaseModules:WaitForChild("CoreGuiManager"))
local Waypoint = require(ReplicatedBaseModules:WaitForChild("Waypoint"))

-- KnitControllers
local MessageController = require(BaseControllers:WaitForChild("MessageController"))

-- Instances
local LocalPlayer = game.Players.LocalPlayer

-- Configs

-- Variables
local blurEnabled = false

-- Tables
local config = {
	menuWindowNames = {
		"Inventory",
		"Rewards",
		"Settings",
		"Store",
		"GroupReward",
	},
	shopWindows = {},
	inventoryWindows = {},
	windowsRequiringBlur = {
		"Tutorial",
		"Difficulty",
		"Teleport",
	},
	windowsBlurSize = {
		Tutorial = 10,
	},
	windowsHidingSideGuis = {
		"StartScreen",
		"DiedScreen",
		"GlobalLeaderboard",
		"Difficulty",
		"Teleport",
	},
	windowsCustomMessagePosition = {
		Customize = {
			Position = UDim2.fromScale(0.71, 1.05),
			Size = UDim2.fromScale(0.4, 0.1),
		},
	},
	windowsCustomMessageEndPosition = {
		DiedScreen = UDim2.fromScale(0.5, 0.875),
	},
	inGameWindowsCustomMessageEndPosition = {
		Achievements = UDim2.fromScale(0.5, 0.8),
		Statistics = UDim2.fromScale(0.5, 0.8),
		Store = UDim2.fromScale(0.5, 0.8),
		Skills = UDim2.fromScale(0.5, 0.8),
		DailyReward = UDim2.fromScale(0.5, 0.8),
		Settings = UDim2.fromScale(0.5, 0.8),
		GroupReward = UDim2.fromScale(0.5, 0.8),
	},
	notInGameWindowsCustomMessageEndPosition = {
		Achievements = UDim2.fromScale(0.5, 0.85),
		Statistics = UDim2.fromScale(0.5, 0.85),
		Store = UDim2.fromScale(0.5, 0.85),
		Skills = UDim2.fromScale(0.5, 0.85),
		DailyReward = UDim2.fromScale(0.5, 0.85),
		Settings = UDim2.fromScale(0.5, 0.85),
		GroupReward = UDim2.fromScale(0.5, 0.85),
	},
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function UpdateBlur(state)
	if state.windowShown and table.find(config.windowsRequiringBlur, state.windowShown) then
		if not blurEnabled then
			blurEnabled = true
			LightingManager.EnableBlur(true, config.windowsBlurSize[state.windowShown])
		end
	elseif blurEnabled then
		blurEnabled = false
		LightingManager.EnableBlur(false)
	end
end

local function UpdateMessageProperties(state)
	if state.windowShown then
		MessageController:UpdateDefaultMessageProperties(config.windowsCustomMessagePosition[state.windowShown])
		MessageController:UpdateMessageEndPosition(
			config.windowsCustomMessageEndPosition[state.windowShown]
				or (
					LocalPlayer:GetAttribute("isAlive")
						and config.inGameWindowsCustomMessageEndPosition[state.windowShown]
					or config.notInGameWindowsCustomMessageEndPosition[state.windowShown]
				)
		)
		Waypoint.Deactivate(state.windowShown)
	else
		MessageController:UpdateDefaultMessageProperties()
		MessageController:UpdateMessageEndPosition()
	end
end

local function UpdateSideGuiVisibility(state)
	if state.windowShown and table.find(config.windowsHidingSideGuis, state.windowShown) then
		state.hideSideGuis = state.windowShown
		state.hideNotifications = true
		UserInputService.ModalEnabled = true
	else
		state.hideSideGuis = nil
		state.hideNotifications = false
		UserInputService.ModalEnabled = false
	end
end

local function UpdateCoreGui(state)
	CoreGuiManager.UpdateGameState({
		hideSideGuis = state.hideSideGuis or false,
		hideWindows = state.hideWindows or false,
		windowShown = state.windowShown or false,
	})
end

local function UpdateWindowShown(state)
	if state.hideWindows then
		state.windowShown = nil
		UserInputService.ModalEnabled = true
	else
		state.windowShown = state.windowsShown[1]
		UserInputService.ModalEnabled = false
		UpdateSideGuiVisibility(state)
	end

	UpdateBlur(state)
	UpdateCoreGui(state)
	UpdateMessageProperties(state)

	Utils.Signals.FireDeferred("windowShown", state.windowShown)
end

local function CloseWindow(newState, windowName)
	Utils.Table.RemoveItem(newState.windowsShown, windowName)

	if newState.hideSideGuis == windowName then
		newState.hideSideGuis = nil
	end

	newState.windowsPinned[windowName] = nil
end

local function CloseWindows(newState, windows)
	if type(windows) ~= "table" then
		return
	end

	newState.windowsShown = Utils.Table.Copy(newState.windowsShown)
	newState.windowsPinned = Utils.Table.Copy(newState.windowsPinned)

	for _, windowName in pairs(windows) do
		CloseWindow(newState, windowName)
	end

	UpdateWindowShown(newState)
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local WindowStateReducer = Rodux.createReducer({
	windowsShown = {},
	windowsPinned = {},
	sideGuisHidden = {},

	windowShown = nil,
	windowPinned = nil,

	hideWindows = false,
	hideSideGuis = false,
	hideNotifications = false,
}, {
	ShowWindow = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.windowsShown = Utils.Table.Copy(newState.windowsShown)

		Utils.Table.RemoveItem(newState.windowsShown, action.value)
		table.insert(
			newState.windowsShown,
			Utils.Table.Length(newState.windowsPinned) > 0 and (action.ignoreLock and 1 or 2) or 1,
			action.value
		)

		if action.hideSideGuis == false then
			action.hideSideGuis = nil
		elseif action.hideSideGuis == true then
			action.hideSideGuis = action.value
		end

		if action.pinned then
			newState.windowsPinned = Utils.Table.Copy(newState.windowsPinned)
			newState.windowsPinned[action.value] = action.pinned
		end

		UpdateWindowShown(newState)
		return newState
	end,

	CloseWindow = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.windowsShown = Utils.Table.Copy(newState.windowsShown)

		Utils.Table.RemoveItem(newState.windowsShown, action.value)

		if newState.hideSideGuis == action.value then
			newState.hideSideGuis = nil
		end

		if newState.windowsPinned[action.value] then
			newState.windowsPinned = Utils.Table.Copy(newState.windowsPinned)
			newState.windowsPinned[action.value] = nil
		end

		UpdateWindowShown(newState)
		return newState
	end,

	CloseWindows = function(state, action)
		local newState = Utils.Table.Copy(state)
		CloseWindows(newState, action.value)

		return newState
	end,

	-- close all windows
	CloseAllWindows = function(state)
		local newState = Utils.Table.Copy(state)
		newState.windowsShown = {}
		newState.windowsPinned = {}

		newState.hideSideGuis = nil
		newState.windowShown = nil

		UpdateWindowShown(newState)
		return newState
	end,

	-- Close shop windows when getting out of shop
	CloseShopWindows = function(state)
		local newState = Utils.Table.Copy(state)
		CloseWindows(newState, config.shopWindows)

		return newState
	end,

	CloseInventoryWindows = function(state)
		local newState = Utils.Table.Copy(state)
		CloseWindows(newState, config.inventoryWindows)

		return newState
	end,

	-- Must recall this function to show windows anew
	SetHideWindows = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.hideWindows = action.value or nil

		UpdateWindowShown(newState)
		return newState
	end,

	-- hideSideGuis must be named after the window name requesting to hide (When closing the window it resets it to nil)
	SetHideSideGuis = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.hideSideGuis = action.hideSideGuis or nil

		return newState
	end,

	SetHideNotifications = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.hideNotifications = action.value or nil
		return newState
	end,

	-- Must recall this function to show all anew
	SetHideAll = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.hideWindows = action.value or nil
		newState.hideSideGuis = action.value or nil
		newState.hideNotifications = action.value or nil

		UpdateWindowShown(newState)
		return newState
	end,

	-- For hiding a gui by user's command (menuButtons, team stats side gui)
	SetSideGuisHidden = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.sideGuisHidden = Utils.Table.Copy(newState.sideGuisHidden)
		Utils.Table.Merge(newState.sideGuisHidden, action.value)

		return newState
	end,

	-- For showing/hiding menu windows when clicking the same button
	ToggleMenuWindow = function(state, action)
		local newState = Utils.Table.Copy(state)
		newState.windowsShown = Utils.Table.Copy(newState.windowsShown)
		newState.windowsPinned = Utils.Table.Copy(newState.windowsPinned)

		-- Hide other menu windows if shown
		for _, eachMenuWindow in pairs(config.menuWindowNames) do
			if eachMenuWindow ~= action.value then
				CloseWindow(newState, eachMenuWindow)
			end
		end

		-- Show menu window if not shown or else hide
		local index = table.find(newState.windowsShown, action.value)
		if index then
			if index ~= 1 then
				-- Window was not the first one shown, show the window
				table.remove(newState.windowsShown, index)
				table.insert(newState.windowsShown, 1, action.value)
			else
				-- Window was shown, hide it
				table.remove(newState.windowsShown, 1)
			end
		else
			-- Window is not shown, show it
			table.insert(newState.windowsShown, 1, action.value)
		end

		UpdateWindowShown(newState)

		return newState
	end,
})

return WindowStateReducer

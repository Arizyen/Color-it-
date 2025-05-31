local DeviceTypeUpdater = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Folders
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local UI = Source:WaitForChild("UI")
-- local GlobalComponents = UI:WaitForChild("GlobalComponents")

-- Modulescripts
local Signals = require(Source:WaitForChild("Utils")).Signals

-- KnitControllers

-- Instances

-- Components

-- Configs

-- Variables
local lastInputType
local lastDeviceType

DeviceTypeUpdater.currentDeviceType = nil

-- Tables
local mouseInputs = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseButton2,
	Enum.UserInputType.MouseButton3,
	Enum.UserInputType.MouseMovement,
	Enum.UserInputType.MouseWheel,
}

local gamePadInputs = {
	Enum.UserInputType.Gamepad1,
	Enum.UserInputType.Gamepad2,
	Enum.UserInputType.Gamepad3,
	Enum.UserInputType.Gamepad4,
	Enum.UserInputType.Gamepad5,
	Enum.UserInputType.Gamepad6,
	Enum.UserInputType.Gamepad7,
	Enum.UserInputType.Gamepad8,
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function DeviceTypeChanged(newDeviceType)
	if lastDeviceType == newDeviceType then
		return
	else
		lastDeviceType = newDeviceType
	end

	DeviceTypeUpdater.currentDeviceType = newDeviceType

	Signals.Fire("DispatchAction", {
		type = "SetDeviceType",
		value = newDeviceType,
	})
	Signals.Fire("deviceType", newDeviceType)
end

local function UpdateDeviceType(newInputType)
	if
		newInputType == "touch"
		or ((UserInputService.TouchEnabled and not UserInputService.MouseEnabled) or newInputType == "touch")
			and not GuiService:IsTenFootInterface()
	then
		DeviceTypeChanged("mobile")
	elseif
		newInputType == "gamepad"
		and (
			GuiService:IsTenFootInterface()
			or (
				UserInputService.GamepadEnabled
				or (UserInputService.GamepadConnected and UserInputService.GamepadEnabled)
				or newInputType == "gamepad"
			)
		)
	then
		DeviceTypeChanged("console")
	-- elseif
	-- 	UserInputService.KeyboardEnabled and UserInputService.MouseEnabled and not GuiService:IsTenFootInterface()
	-- 	or (newInputType == "keyboard" or newInputType == "mouse")
	-- then
	-- 	DeviceTypeChanged("pc")
	else
		DeviceTypeChanged("pc")
	end
end

local function InputTypeChanged(inputType)
	if lastInputType == inputType then
		return
	else
		lastInputType = inputType
	end

	if inputType == Enum.UserInputType.Keyboard and DeviceTypeUpdater.deviceType ~= "pc" then
		UpdateDeviceType("keyboard")
		return
	end

	if table.find(mouseInputs, inputType) and DeviceTypeUpdater.deviceType ~= "pc" then
		UpdateDeviceType("mouse")
		return
	end

	if inputType == Enum.UserInputType.Touch and DeviceTypeUpdater.deviceType ~= "mobile" then
		UpdateDeviceType("touch")
		return
	end

	if table.find(gamePadInputs, inputType) and DeviceTypeUpdater.deviceType ~= "console" then
		UpdateDeviceType("gamepad")
		return
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function DeviceTypeUpdater.Activate()
	-- Detect user device type
	UserInputService.LastInputTypeChanged:Connect(function(inputType)
		InputTypeChanged(inputType)
	end)
	InputTypeChanged(UserInputService:GetLastInputType())
end

return DeviceTypeUpdater

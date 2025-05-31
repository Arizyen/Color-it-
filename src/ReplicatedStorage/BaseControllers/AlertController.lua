-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UIFolder = Source:WaitForChild("UI")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
local Utils = require(Source:WaitForChild("Utils"))
local Store = require(UIFolder:WaitForChild("Store"))

-- KnitControllers
local AlertController = Knit.CreateController({
	Name = "Alert",
})

-- Instances

-- Configs

-- Variables

-- Tables
local knitServices = {}
local windowAlertsActive = {}

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function AlertController:KnitInit()
	knitServices["Alert"] = Knit.GetService("Alert")
end

function AlertController:KnitStart()
	knitServices["Alert"].AddAlert:Connect(function(windowName)
		self:Add(windowName)
	end)

	Utils.Signals.Connect("windowShown", function(windowName)
		self:Remove(windowName)
	end)
end
-- COMPONENT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- Remove alerts depending on windowShown
function AlertController:Remove(windowName)
	if type(windowName) ~= "string" then
		return
	end

	-- Remove the alert if there's an active alert
	if windowAlertsActive[windowName] then
		windowAlertsActive[windowName] = nil

		Utils.Signals.Fire("DispatchAction", {
			type = "SetWindowAlert",
			window = windowName,
			value = false,
		})
	end
end

-- Add alerts depending on windowShown
function AlertController:Add(windowName, dataNotLoaded)
	if type(windowName) ~= "string" or dataNotLoaded then
		return
	end

	if not windowAlertsActive[windowName] and Store.GetState("window", "windowShown") ~= windowName then
		windowAlertsActive[windowName] = true

		Utils.Signals.Fire("DispatchAction", {
			type = "SetWindowAlert",
			window = windowName,
			value = true,
		})
	end
end
-- CLIENT - SERVER FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------

return AlertController

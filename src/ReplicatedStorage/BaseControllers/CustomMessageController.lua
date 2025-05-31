-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers
local CustomMessageController = Knit.CreateController({
	Name = "CustomMessage",
})

-- Instances

-- Configs

-- Variables

-- Tables
local knitServices = {}

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function CustomMessageController:KnitInit()
	knitServices["CustomMessage"] = Knit.GetService("CustomMessage")
end

function CustomMessageController:KnitStart()
	knitServices["CustomMessage"].ShowCustomMessage:Connect(function(properties)
		Utils.Signals.Fire(
			"DispatchAction",
			Utils.Table.Merge(properties, {
				type = "UpdateCustomMessage",
			})
		)
		Utils.Signals.Fire("DispatchAction", {
			type = "ShowWindow",
			value = "CustomMessage",
		})

		Utils.Sound.PlaySound(Utils.Sound.soundInfos.notification1, true)
	end)
end
-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------

-- CLIENT - SERVER FUNCTIONS ------------------------------------------------------------------------------------------------------------------------

return CustomMessageController

local Prompt = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Prompt.Show(properties)
	if type(properties) ~= "table" then
		return
	end

	Utils.Signals.Fire(
		"DispatchAction",
		Utils.Table.Merge({
			type = "UpdatePrompt",
			value = true,
		}, properties)
	)

	Utils.Signals.Fire("DispatchAction", {
		type = "ShowWindow",
		value = "Prompt",
	})
end

return Prompt

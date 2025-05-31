-- Services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Folders
-- local Source = ReplicatedStorage:WaitForChild("Source")

-- Modulescripts

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables

--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
return function(name, callback)
	for _, thing in pairs(CollectionService:GetTagged(name)) do
		task.spawn(function()
			callback(thing)
		end)
	end

	CollectionService:GetInstanceAddedSignal(name):Connect(callback)
end

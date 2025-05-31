local Cloner = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
-- local Source = ReplicatedStorage:WaitForChild("Source")
local ClonesFolder = ReplicatedStorage:FindFirstChild("Clones") :: Folder or nil

-- Modulescripts
local TableUtils = require(script.Parent:WaitForChild("Table"))

-- Modulescripts requiring to start

-- KnitControllers

-- Instances

-- Configs
local _DEFAULT_CLONE_LIMIT = 10 -- Default limit for clones per defaultInstance

-- Variables
local timerRunning = false

-- Tables
local clones = {} -- {defaultInstance = {clone1, clone2}}
local clonesTimeLimit = {} :: { [Instance]: { defaultInstance: Instance, destroyTime: number } } -- key is clone
local connections = {}

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateClonesFolder()
	if not ClonesFolder then
		ClonesFolder = Instance.new("Folder")
		ClonesFolder.Name = "Clones"
		ClonesFolder.Parent = ReplicatedStorage
	end
end

local function CloneRemoved(defaultInstance: Instance)
	if #clones[defaultInstance] == 0 then
		clones[defaultInstance] = nil
		if connections[defaultInstance] then
			connections[defaultInstance]:Disconnect()
			connections[defaultInstance] = nil
		end
	end
end

local function DestroyClone(defaultInstance: Instance, clone: Instance)
	if clones[defaultInstance] then
		local index = table.find(clones[defaultInstance], clone)
		if index then
			table.remove(clones[defaultInstance], index)
			CloneRemoved(defaultInstance)
		end
	end

	if clone.Parent then
		clone:Destroy()
	end
	clonesTimeLimit[clone] = nil
end

local function RunTimer()
	if timerRunning then
		return
	end
	timerRunning = true

	task.spawn(function()
		local currentTime

		while timerRunning do
			if not next(clonesTimeLimit) then
				timerRunning = false
				return
			end

			currentTime = os.clock()
			for clone, data in pairs(clonesTimeLimit) do
				if currentTime >= data.destroyTime then
					DestroyClone(data.defaultInstance, clone)
				end
			end

			task.wait(1)
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Cloner.GetClone(defaultInstance): Instance
	if clones[defaultInstance] and #clones[defaultInstance] > 0 then
		local clone = table.remove(clones[defaultInstance], 1)
		clonesTimeLimit[clone] = nil
		CloneRemoved(defaultInstance)

		if not clone.Parent or clone.Parent ~= ClonesFolder then
			return Cloner.GetClone(defaultInstance)
		end

		return clone
	else
		return defaultInstance:Clone()
	end
end

function Cloner.StoreClone(defaultInstance: Instance, clone: Instance, cloneLimit: number?, timeLimit: number?)
	if typeof(defaultInstance) ~= "Instance" then
		if typeof(clone) == "Instance" and clone.Parent then
			clone:Destroy()
		end
		return
	elseif typeof(clone) ~= "Instance" then
		return
	elseif not clone.Parent then
		-- warn("Cloner.StoreClone: Clone is not parented to anything", defaultInstance.Name, clone.Name)
		return
	end

	if not clones[defaultInstance] then
		clones[defaultInstance] = {}

		-- Add AncestryChanged connection to remove clones when defaultInstance is destroyed
		connections[defaultInstance] = defaultInstance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				Cloner.DestroyClones(defaultInstance)
			end
		end)
	elseif #clones[defaultInstance] >= (cloneLimit or _DEFAULT_CLONE_LIMIT) then
		if table.find(clones[defaultInstance], clone) then
			DestroyClone(defaultInstance, clone)
		else
			clone:Destroy()
		end
		return
	end

	-- Store clone
	if not table.find(clones[defaultInstance], clone) then
		clone.Parent = ClonesFolder
		table.insert(clones[defaultInstance], clone)
	end

	if timeLimit then
		clonesTimeLimit[clone] = { defaultInstance = defaultInstance, destroyTime = os.clock() + timeLimit }
		RunTimer()
	end
end

function Cloner.DestroyClones(defaultInstance: Instance)
	if clones[defaultInstance] then
		for _, clone in ipairs(TableUtils.Copy(clones[defaultInstance])) do
			if clone.Parent == ClonesFolder then
				DestroyClone(defaultInstance, clone)
			end
		end
		clones[defaultInstance] = nil
	end

	if connections[defaultInstance] then
		connections[defaultInstance]:Disconnect()
		connections[defaultInstance] = nil
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
CreateClonesFolder()

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS -------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

return Cloner

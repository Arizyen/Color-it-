local DynamicLoader = {}
-- Services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
-- local Source = ReplicatedStorage:WaitForChild("Source")
--
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
--
-- Modulescripts

-- KnitControllers

-- Instances

-- Configs
local DEFAULT_MAX_RECURSION = 5
-- Variables

-- Tables
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function Load(folder, destination, speed, maxRecursion, currentRecursion, items)
	if not folder or not destination or folder:GetAttribute("loading") then
		return
	end
	folder:SetAttribute("loading", true)

	currentRecursion = currentRecursion or 0
	items = { count = 0 } or items

	if currentRecursion <= maxRecursion then
		-- Get the PrimaryPart if it is a model
		local primaryPart
		if folder:IsA("Model") and folder.PrimaryPart then
			primaryPart = folder.PrimaryPart
		end

		-- Unparent all children (Only Folders, BaseParts and Models)
		local childrensUnparented = {}
		for _, eachChild in pairs(folder:GetChildren()) do
			if eachChild:IsA("BasePart") or eachChild:IsA("Model") or eachChild:IsA("Folder") then
				table.insert(childrensUnparented, eachChild)
				eachChild.Parent = nil

				items.count += 1
				if items.count % speed == 0 then
					task.wait()
				end
			end
		end

		-- Move folder to destination
		folder.Parent = destination
		currentRecursion += 1
		-- Parent all children back to destination
		for _, eachChild in pairs(childrensUnparented) do
			items.count += 1
			if items.count % speed == 0 then
				task.wait()
			end

			Load(eachChild, folder, speed, maxRecursion, currentRecursion, items)
		end

		-- Set back the PrimaryPart
		if primaryPart then
			folder.PrimaryPart = primaryPart
		end
	else
		-- Move folder to destination
		folder.Parent = destination
	end

	folder:SetAttribute("loading", nil)
	return true
end

local function ReturnHumanoids(folder)
	local humanoids = {}
	for _, eachDescendant in pairs(folder:GetDescendants()) do
		if eachDescendant:IsA("Model") and eachDescendant:FindFirstChild("Humanoid") then
			humanoids[eachDescendant] = eachDescendant.Parent
			eachDescendant.Parent = nil
		end
	end
	return humanoids
end

local function ReturnScripts(folder)
	local scripts = {}
	for _, eachDescendant in pairs(folder:GetDescendants()) do
		if eachDescendant:IsA("Script") or eachDescendant:IsA("LocalScript") then
			scripts[eachDescendant] = eachDescendant.Parent
			eachDescendant.Parent = nil
		end
	end
	return scripts
end

local function ParentItemsBack(items)
	if not items or type(items) ~= "table" then
		return
	end

	for eachItem, parentFolder in pairs(items) do
		eachItem.Parent = parentFolder
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function DynamicLoader.Load(folder, destination, speed, maxRecursion, checkForHumanoids, checkForScripts)
	-- speed: closer to 1 = slower
	if folder.Parent == destination then
		return true
	end

	if folder:GetAttribute("loading") then
		repeat
			task.wait()
		until not folder:GetAttribute("loading")
		DynamicLoader.Load(folder, destination, speed, maxRecursion, checkForHumanoids, checkForScripts)
	end

	local humanoids = checkForHumanoids and ReturnHumanoids(folder) or nil
	local scripts = checkForScripts and ReturnScripts(folder) or nil

	-- The closer the speed is to 1, the more time it takes
	speed = (speed and speed >= 1) and math.round(speed) or 50
	maxRecursion = maxRecursion or DEFAULT_MAX_RECURSION
	-- print("LOADING: "..folder.Name, "SPEED: "..tostring(speed))
	if Load(folder, destination, speed, maxRecursion) then
		ParentItemsBack(humanoids)
		ParentItemsBack(scripts)
		task.wait()
		return true
	else
		return false
	end
end

function DynamicLoader.LoadObjects(objects, destination, speed, checkForHumanoids, checkForScripts) end

return DynamicLoader

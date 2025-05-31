local InstanceUtil = {}
-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function InstanceUtil.Create(instanceType: string, parent: Instance, instanceName: string, ignoreIfExists: boolean)
	-- Find instance
	local instance
	if not ignoreIfExists and instanceName then
		instance = parent:FindFirstChild(instanceName)
		if instance and not instance:IsA(instanceType) then
			instance = nil
			for _, eachChild in pairs(parent:GetChildren()) do
				if eachChild.Name == instanceName and eachChild:IsA(instanceType) then
					instance = eachChild
					break
				end
			end
		end
	end

	-- Create or return instance
	if not instance or (instance and ignoreIfExists) then
		instance = Instance.new(instanceType)
		instance.Name = instanceName or instance.Name
		instance.Parent = parent

		return instance
	else
		return instance
	end
end

function InstanceUtil.GetFolder(parent: Instance, ...)
	local args = { ... }
	local currentParent = parent
	local folderName

	for _, eachFolderName in ipairs(args) do
		folderName = tostring(eachFolderName)

		if folderName then
			currentParent = InstanceUtil.Create("Folder", currentParent, eachFolderName)
		end
	end

	return currentParent
end

function InstanceUtil.WaitForChild(parent: Instance, timeout: number, ...)
	local args = { ... }
	local currentParent = parent
	local childName

	for _, eachChildName in ipairs(args) do
		childName = tostring(eachChildName)

		if childName then
			currentParent = currentParent:WaitForChild(childName, timeout)
			if not currentParent then
				return
			end
		end
	end

	return currentParent
end

function InstanceUtil.FindFirstChild(parent: Instance, ...)
	local args = { ... }
	local currentParent = parent
	local childName

	for _, eachChildName in ipairs(args) do
		childName = tostring(eachChildName)

		if childName then
			currentParent = currentParent:FindFirstChild(childName)
			if not currentParent then
				return
			end
		end
	end

	return currentParent
end

function InstanceUtil.RemoveChildrenOfType(parent: Instance, instanceType: string)
	for _, eachChild in pairs(parent:GetChildren()) do
		if eachChild:IsA(instanceType) then
			eachChild:Destroy()
		end
	end
end

function InstanceUtil.RemoveDescendantsOfType(parent: Instance, instanceType: string)
	for _, eachDescendant in pairs(parent:GetDescendants()) do
		if eachDescendant:IsA(instanceType) then
			eachDescendant:Destroy()
		end
	end
end

function InstanceUtil.Destroy(instance)
	if instance and instance.Parent then
		instance:Destroy()
	end
end
------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return InstanceUtil

local Raycaster = {}
-- Services

-- Folders

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
function Raycaster.Raycast(
	startPosition: Vector3,
	endPosition: Vector3,
	ignoreList: table?,
	collisionGroup: string?,
	ignoreListFilterType: Enum.RaycastFilterType?
): RaycastResult?
	ignoreList = ignoreList or {}
	local distance = (startPosition - endPosition).Magnitude

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.FilterType = ignoreListFilterType or Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	raycastParams.CollisionGroup = collisionGroup or "Default"

	return workspace:Raycast(startPosition, (endPosition - startPosition).Unit * distance, raycastParams)
end

function Raycaster.RaycastUnderModel(
	model: Model,
	maxDistance: number?,
	ignoreHumanoids: boolean?,
	collisionGroup: string?,
	ignoreListFilterType: Enum.RaycastFilterType?
): RaycastResult?
	if not model or not model.PrimaryPart then
		return
	end

	local ignoreList = { model }
	local raycastResult

	repeat
		raycastResult = Raycaster.Raycast(
			model.PrimaryPart.Position,
			model.PrimaryPart.Position - Vector3.new(0, maxDistance or 100, 0),
			ignoreList,
			collisionGroup,
			ignoreListFilterType
		)
		if
			raycastResult
			and (
				not raycastResult.Instance:IsA("BasePart")
				or not raycastResult.Instance.CanCollide
				or raycastResult.Instance:IsDescendantOf(model)
				or ignoreHumanoids and raycastResult.Instance.Parent:FindFirstChildOfClass("Humanoid")
			)
		then
			table.insert(ignoreList, raycastResult.Instance)
		end
	until not raycastResult
		or not raycastResult.Instance
		or (
			raycastResult.Instance:IsA("BasePart")
			and (not ignoreHumanoids or not raycastResult.Instance.Parent:FindFirstChildOfClass("Humanoid"))
			and raycastResult.Instance.CanCollide
		)

	return raycastResult
end

function Raycaster.GetCollidable(
	startPosition: Vector3,
	endPosition: Vector3,
	ignoreList: table?,
	collisionGroup: string?,
	ignoreListFilterType: Enum.RaycastFilterType?
): RaycastResult?
	local raycastResult
	ignoreList = ignoreList or {}

	repeat
		raycastResult = Raycaster.Raycast(startPosition, endPosition, ignoreList, collisionGroup, ignoreListFilterType)
		if raycastResult and (not raycastResult.Instance:IsA("BasePart") or not raycastResult.Instance.CanCollide) then
			table.insert(ignoreList, raycastResult.Instance)
		end
	until not raycastResult
		or not raycastResult.Instance
		or (raycastResult.Instance:IsA("BasePart") and raycastResult.Instance.CanCollide)

	return raycastResult
end

return Raycaster

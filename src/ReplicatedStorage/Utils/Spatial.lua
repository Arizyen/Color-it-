local Spatial = {}

local plusAndMinus = { -1, 1 }
local randomGenerator = Random.new()

-- DISTANCE CHECKS -----------------------------------------------------------------------------------------------------------------------------------
function Spatial.IsWithinPart(part, partToCheck, isACylinder, exactY)
	if not part or not partToCheck then
		return false
	end

	local function getCorners()
		local corners = {}
		local halfSize = part.Size / 2
		-- Calculate corners in world space
		corners[1] = part.CFrame * Vector3.new(-halfSize.X, 0, halfSize.Z) -- Top-right
		corners[2] = part.CFrame * Vector3.new(-halfSize.X, 0, -halfSize.Z) --  Bottom-right
		corners[3] = part.CFrame * Vector3.new(halfSize.X, 0, -halfSize.Z) -- Bottom-left
		corners[4] = part.CFrame * Vector3.new(halfSize.X, 0, halfSize.Z) -- Top-left

		return corners
	end

	local function pointInRectangle(point, corners)
		-- Check if the point is inside the rectangle using cross products
		local function crossProduct(v1, v2)
			return v1.X * v2.Z - v1.Z * v2.X
		end

		for i = 1, 4 do
			local nextIndex = (i % 4) + 1
			local edge = corners[nextIndex] - corners[i]
			local toPoint = point - corners[i]
			if crossProduct(edge, toPoint) < 0 then
				return false -- Point is outside this edge
			end
		end
		return true
	end

	if not isACylinder then
		local corners = getCorners()
		local point = partToCheck.Position

		-- Check Y-axis bounds if required
		if exactY then
			if math.abs(point.Y - part.Position.Y) > part.Size.Y / 2 then
				return false
			end
		end

		-- Check if the 2D projection of the point is within the rectangle
		local projectedPoint = Vector3.new(point.X, 0, point.Z)
		return pointInRectangle(projectedPoint, corners)
	else
		-- Handle cylinder case
		local horizontalDist = (Vector3.new(partToCheck.Position.X, 0, partToCheck.Position.Z) - Vector3.new(
			part.Position.X,
			0,
			part.Position.Z
		)).Magnitude
		local withinCylinder = horizontalDist <= part.Size.Z / 2

		if exactY then
			local verticalDist = math.abs(partToCheck.Position.Y - part.Position.Y)
			return withinCylinder and verticalDist <= part.Size.Y / 2
		end

		return withinCylinder
	end
end

function Spatial.GetPartBoundsInBox(cframe, vector3, ignoreList, collisionGroup)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = ignoreList
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	if collisionGroup then
		overlapParams.CollisionGroup = collisionGroup
	end

	return workspace:GetPartBoundsInBox(cframe, vector3, overlapParams)
end

function Spatial.PlayersAreWithinDistance(player1, player2, distance)
	if type(distance) ~= "number" then
		return false
	end

	if player1.Character and player1.Character.PrimaryPart and player2.Character and player2.Character.PrimaryPart then
		return (player1.Character.PrimaryPart.Position - player2.Character.PrimaryPart.Position).Magnitude <= distance
	end
end

-- RANDOM POSITION WITHIN -----------------------------------------------------------------------------------------------------------------------------------
function Spatial.GetRandomCFrameWithinPart(primaryPart)
	return primaryPart.CFrame
		* CFrame.new(
			(primaryPart.Size.X / 2) * randomGenerator:NextNumber() * plusAndMinus[math.random(2)],
			0,
			(primaryPart.Size.Z / 2) * randomGenerator:NextNumber() * plusAndMinus[math.random(2)]
		)
end

function Spatial.GetRandomPositionWithinPart(primaryPart)
	return (primaryPart.CFrame * CFrame.new(
		(primaryPart.Size.X / 2) * randomGenerator:NextNumber() * plusAndMinus[math.random(2)],
		0,
		(primaryPart.Size.Z / 2) * randomGenerator:NextNumber() * plusAndMinus[math.random(2)]
	)).Position
end

return Spatial

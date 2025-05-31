local Math = {}

local rng = Random.new()

-- NUMBERS ----------------------------------------------------------------------------------------------------------------------------------
function Math.Round(number, decimalPlaces)
	local multiplier = 10 ^ (decimalPlaces or 0)
	if number >= 0 then
		return (math.round(number * multiplier) / multiplier)
	else
		return (math.round(math.abs(number) * multiplier) / multiplier) * -1
	end
end

-- GEOMETRY ---------------------------------------------------------------------------------------------------------------------------------
function Math.GetYAxisAngleDifference(fromPosition, toPosition)
	local direction = (toPosition - fromPosition)
	return math.atan2(direction.X, direction.Z) -- Y-axis angle in radians
end

function Math.ShortestAngleDifference(fromAngle, toAngle)
	local difference = toAngle - fromAngle
	difference = (difference + math.pi) % (2 * math.pi) - math.pi
	return difference
end

function Math.LerpAngle(a, b, t)
	-- shortest angle difference
	local diff = (b - a + math.pi) % (2 * math.pi) - math.pi
	return a + diff * t
end

function Math.GetLookVectorFromAngle(angle: number)
	angle = math.rad(angle % 360)
	return Vector3.new(math.sin(angle), 0, math.cos(angle)).Unit
end

function Math.GetAngleFromLookVector(lookVector: Vector3)
	local angle = math.atan2(lookVector.X, lookVector.Z)
	return math.deg(angle) % 360
end

function Math.GetPositionFromAngle(position: Vector3, angle: number, distance: number)
	return position + Math.GetLookVectorFromAngle(angle) * distance
end

function Math.GetSquaredDistance(position1, position2)
	local offset = position1 - position2
	return offset.X ^ 2 + offset.Y ^ 2 + offset.Z ^ 2
end

function Math.IsWithinDistance(position1, position2, distance)
	return Math.GetSquaredDistance(position1, position2) <= distance ^ 2
end

-- BEZIER -----------------------------------------------------------------------------------------------------------------------------------
function Math.Lerp(a, b, alpha)
	return a + (b - a) * alpha
end

-- InverseLerp returns alpha between 0 and 1 based on the input value
function Math.InverseLerp(a, b, value)
	return (value - a) / (b - a)
end

function Math.QuadBezier(alpha, p0, p1, p2)
	return (1 - alpha) ^ 2 * p0 + 2 * (1 - alpha) * alpha * p1 + alpha ^ 2 * p2
end

function Math.CubicBezier(alpha, p0, p1, p2, p3)
	return (1 - alpha) ^ 3 * p0 + 3 * (1 - alpha) ^ 2 * alpha * p1 + 3 * (1 - alpha) * alpha ^ 2 * p2 + alpha ^ 3 * p3
end

-- ROLLING ----------------------------------------------------------------------------------------------------
function Math.Roll(weights: { number }, totalWeight: number): number?
	if #weights == 0 then
		print("Math.Roll received an empty weights table.")
		return nil
	end

	-- Calculate the total weight if not provided
	if not totalWeight then
		totalWeight = 0
		for _, odd in ipairs(weights) do
			totalWeight += odd
		end
	end

	if totalWeight <= 0 then
		print("Math.Roll: Total weight is zero or negative.")
		return nil
	end

	-- Perform weighted random selection
	local cumulativeWeight = 0
	local roll = rng:NextNumber(0, totalWeight)
	for index, weight in ipairs(weights) do
		cumulativeWeight += weight
		if roll <= cumulativeWeight then
			return index
		end
	end

	return #weights
end

function Math.RedistributeWeights(rarityTable, boostPercentage)
	assert(boostPercentage < 1, "boostPercentage must be less than 1")
	local n = #rarityTable
	local newTable = table.clone(rarityTable)

	-- 1: Find bounds of non-zero values
	local firstIndex, lastIndex
	for i = 1, n do
		if rarityTable[i] > 0 then
			firstIndex = i
			break
		end
	end
	for i = n, 1, -1 do
		if rarityTable[i] > 0 then
			lastIndex = i
			break
		end
	end

	-- Nothing to redistribute
	if not firstIndex or not lastIndex or firstIndex == lastIndex then
		return newTable
	end

	-- 2: Extract working sub-table
	local working = {}
	for i = firstIndex, lastIndex do
		table.insert(working, rarityTable[i])
	end

	local workingLen = #working
	local midpoint = math.floor(workingLen / 2)

	-- 3: Deduct from lower half
	local lowerTotal = 0
	for i = 1, midpoint do
		lowerTotal += working[i]
	end

	local actualStolen = 0
	if lowerTotal > 0 then
		for i = 1, midpoint do
			if working[i] > 0 then
				local ratio = working[i] / lowerTotal
				local deduction = boostPercentage * ratio
				working[i] -= deduction
				actualStolen += deduction
			end
		end
	else
		return newTable
	end

	-- 4: Redistribute only to non-zero entries
	local weights = {}
	local weightSum = 0
	for i = 1, workingLen do
		if working[i] > 0 then
			local bias = math.exp(-((i - workingLen * 0.5) ^ 2) / (workingLen * 0.8)) -- Gaussian-like curve
			weights[i] = bias
			weightSum += bias
		else
			weights[i] = 0
		end
	end

	for i = 1, workingLen do
		if weights[i] > 0 then
			local portion = weights[i] / weightSum
			working[i] += actualStolen * portion
		end
	end

	-- 5: Reinsert into full table
	for i = 1, workingLen do
		newTable[firstIndex + i - 1] = working[i]
	end

	return newTable
end

return Math

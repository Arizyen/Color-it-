local Bezier = {}

local bezierFunctionNames = {
	"Lerp",
	"Quad",
	"Cubic",
}
local bezierFunctions = {}
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnBezierValue(alpha, points)
	local n = #points
	local result = { unpack(points) }

	for i = 1, n - 1 do
		for j = 1, n - i do
			result[j] = result[j] + alpha * (result[j + 1] - result[j])
		end
	end

	return result[1]
end

local function GetLength(numberOfPoints, bezierFunction, ...)
	local sum, ranges, sums = 0, {}, {}
	for i = 0, numberOfPoints - 1 do
		local p1, p2 = bezierFunction(i / numberOfPoints, ...), bezierFunction((i + 1) / numberOfPoints, ...)
		local dist = (p2 - p1).magnitude
		ranges[sum] = { dist, p1, p2 }
		table.insert(sums, sum)
		sum = sum + dist
	end
	return sum, ranges, sums
end

function bezierFunctions.Lerp(alpha, a, b)
	return a + (b - a) * alpha
end

function bezierFunctions.Quad(alpha, p0, p1, p2)
	return (1 - alpha) ^ 2 * p0 + 2 * (1 - alpha) * alpha * p1 + alpha ^ 2 * p2
end

function bezierFunctions.Cubic(t, p0, p1, p2, p3)
	return (1 - t) ^ 3 * p0 + 3 * (1 - t) ^ 2 * t * p1 + 3 * (1 - t) * t ^ 2 * p2 + t ^ 3 * p3
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- points : table of points {part1, part2, part3} {vector3,vector3,vector3}
-- numberOfPoints: number of points to save, higher = more precise
-- points cannot be more than 4 and less than 2
function Bezier.new(points: table, numberOfPoints: number)
	local self = setmetatable({}, { __index = Bezier })
	self.bezierFunction = bezierFunctions[bezierFunctionNames[#points - 1]]

	self.points = { table.unpack(points) } -- create a new table in case table received gets changed
	self.numberOfPoints = numberOfPoints or (#points * 2)

	local sum, ranges, sums = GetLength(self.numberOfPoints, self.bezierFunction, table.unpack(self.points))
	self.length = sum
	self.ranges = ranges
	self.sums = sums

	return self
end

function Bezier:Destroy()
	setmetatable(self, nil)
	self = nil
end

function Bezier:SetPoints(points: table)
	-- only update the length when the control points are changed
	self.points = { table.unpack(points) }
	self.numberOfPoints = #self.points

	local sum, ranges, sums = GetLength(self.numberOfPoints, self.bezierFunction, table.unpack(self.points))
	self.length = sum
	self.ranges = ranges
	self.sums = sums
end

function Bezier:Calculate(alpha)
	-- if you don't need alpha to be a percentage of distance (actual distance of a complete length)
	return self.bezierFunction(alpha, table.unpack(self.points))
end

function Bezier:CalculateFixed(alpha)
	local maxLength, nearPoint = alpha * self.length, 0
	for _, eachPoint in next, self.sums do
		if (maxLength - eachPoint) < 0 then
			break
		end
		nearPoint = eachPoint
	end
	local set = self.ranges[nearPoint]
	local percent = (maxLength - nearPoint) / set[1]
	return set[2], set[3], percent
end

return Bezier

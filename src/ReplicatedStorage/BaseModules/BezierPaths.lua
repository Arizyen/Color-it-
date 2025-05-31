local BezierPaths = {}
BezierPaths.__index = BezierPaths
-- Services
-- local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
-- local Packages = ReplicatedStorage.Packages
local Source = ReplicatedStorage:WaitForChild("Source")
-- local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
-- local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts
local Bezier = require(ReplicatedBaseModules:WaitForChild("Bezier"))

-- KnitServices

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function ReturnBeziers(points, bezierPoints)
	local beziers = {}

	local int = 0
	local selectedPoints = {}
	for _, eachPoint in ipairs(points) do
		int += 1
		table.insert(selectedPoints, eachPoint)

		if int >= bezierPoints then
			int = 0
			table.insert(beziers, Bezier.new(selectedPoints))
			table.clear(selectedPoints)
		end
	end

	return beziers
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- points must be ordered
function BezierPaths.new(points: table)
	if #points < 2 then
		return
	end

	local self = setmetatable({}, BezierPaths)

	-- each next bezier must have the last point of the last bezier

	local sets = {}
	local pointsAmount = #points
	repeat
		if (pointsAmount - 4) == 0 or (pointsAmount - 4) > 2 then
			pointsAmount -= 3
			table.insert(sets, 4)
		elseif (pointsAmount - 3) == 0 or (pointsAmount - 3) >= 2 then
			pointsAmount -= 2
			table.insert(sets, 3)
		else
			pointsAmount -= 1
			table.insert(sets, 2)
		end
	until pointsAmount <= 1

	self.beziers = {}
	local int = 0
	local index = 0
	local lastPoint
	local selectedPoints = {}
	for _, eachSet in ipairs(sets) do
		int = eachSet
		repeat
			if int == eachSet and lastPoint then
				int -= 1
				table.insert(selectedPoints, lastPoint)
			end

			int -= 1
			index += 1

			table.insert(selectedPoints, points[index])
			if int <= 0 then
				table.insert(self.beziers, Bezier.new(selectedPoints))
				table.clear(selectedPoints)
				lastPoint = points[index]
			end
		until int == 0
	end

	return self
end

function BezierPaths:Destroy()
	for _, eachBezier in pairs(self.beziers) do
		eachBezier:Destroy()
	end
	setmetatable(self, nil)
	self = nil
end

-- Returns value relative to total distance
function BezierPaths:GetValue(alpha, notFixDistance)
	local totalLength, sums = 0, {}
	-- get total length of all curves, also order sums for sorting
	for _, bezier in next, self.beziers do
		table.insert(sums, totalLength)
		totalLength = totalLength + bezier.length
	end
	-- get percentage of total distance and find the bezier curve we're on
	local maxLength, nearPoint, bezier, pathNumber = alpha * totalLength, 0, self.beziers[1], 1
	for i, eachSum in ipairs(sums) do
		if (maxLength - eachSum) < 0 then
			break
		end
		nearPoint, bezier, pathNumber = eachSum, self.beziers[i], i
	end
	-- get relative percentage traveled on given bezier curve
	local percent = (maxLength - nearPoint) / bezier.length
	-- lerp across curve by percentage

	if notFixDistance then
		return bezier:Calculate(percent), pathNumber, percent
	else
		local a, b, c = bezier:CalculateFixed(percent)
		return a + (b - a) * c, pathNumber, percent
	end
end

-- Will not return a value relative to total distance but rather relative to the bezier we're on depending on alpha
function BezierPaths:GetValue2(alpha, notFixDistance)
	-- get total bezier and determine which bezier we're on depending on alpha
	local bezierIndex = math.floor((#self.beziers * alpha)) + 1
	bezierIndex = bezierIndex <= #self.beziers and bezierIndex or #self.beziers

	local bezier = self.beziers[bezierIndex]
	-- get relative percentage traveled on given bezier curve based on alpha, bezierIndex and #self.beziers
	local percent = 1 - (bezierIndex - (#self.beziers * alpha))
	-- lerp across curve by percentage
	if notFixDistance then
		return bezier:Calculate(percent), bezierIndex, percent
	else
		local a, b, c = bezier:CalculateFixed(percent)
		return a + (b - a) * c, bezierIndex, percent
	end
end

-- If the bezier index is already known
function BezierPaths:GetValueOfPath(pathNumber, alpha, notFixDistance)
	if self.beziers[pathNumber] and alpha then
		if notFixDistance then
			return self.beziers[pathNumber]:Calculate(alpha)
		else
			local a, b, c = self.beziers[pathNumber]:CalculateFixed(alpha)
			return a + (b - a) * c
		end
	end
end

return BezierPaths

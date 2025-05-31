local Color = {}

local colorsTable = {
	Color3.fromRGB(35, 60, 170),
	Color3.fromRGB(5, 100, 180),
	Color3.fromRGB(0, 145, 195),
	Color3.fromRGB(1, 157, 74),
	Color3.fromRGB(115, 200, 75),
	Color3.fromRGB(250, 230, 0),
	Color3.fromRGB(250, 165, 25),
	Color3.fromRGB(239, 123, 33),
	Color3.fromRGB(255, 75, 100),
	Color3.fromRGB(240, 25, 40),
	Color3.fromRGB(160, 35, 145),
	Color3.fromRGB(90, 50, 150),
}
local chosenColors = {
	Color3.fromRGB(115, 200, 75),
	Color3.fromRGB(250, 230, 0),
	Color3.fromRGB(250, 165, 25),
	Color3.fromRGB(239, 123, 33),
	Color3.fromRGB(255, 75, 100),
	Color3.fromRGB(240, 25, 40),
}

Color.gradientColors = {
	white = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(235, 235, 235) },
	black = { Color3.fromRGB(80, 80, 80), Color3.fromRGB(35, 35, 35) },
	blue = { Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 125, 235) },
	blue2 = { Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 125, 255) },
	blue3 = { Color3.fromRGB(24, 171, 225), Color3.fromRGB(14, 105, 135) },
	blueDark = { Color3.fromRGB(21, 143, 195), Color3.fromRGB(38, 68, 150) },
	blueSimply = { Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 170, 255) },
	blueRed = { Color3.fromRGB(85, 85, 255), Color3.fromRGB(204, 34, 64) },

	ceruleanBlue = { Color3.fromRGB(0, 123, 167), Color3.fromRGB(0, 70, 98) },

	crimson = { Color3.fromRGB(220, 20, 60), Color3.fromRGB(139, 0, 0) },

	gray = { Color3.fromRGB(200, 200, 200), Color3.fromRGB(149, 149, 149) },
	gray2 = { Color3.fromRGB(170, 170, 170), Color3.fromRGB(130, 130, 130) },
	grayMedium = { Color3.fromRGB(100, 100, 100), Color3.fromRGB(50, 50, 50) },
	grayDark = { Color3.fromRGB(65, 65, 65), Color3.fromRGB(40, 40, 40) },

	gold = { Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 170, 0) },

	green = { Color3.fromRGB(56, 221, 111), Color3.fromRGB(50, 150, 100) },
	green2 = { Color3.fromRGB(85, 170, 0), Color3.fromRGB(85, 170, 0) },

	-- orange = { Color3.fromRGB(247, 179, 18), Color3.fromRGB(185, 106, 37) },
	orange = { Color3.fromRGB(255, 85, 0), Color3.fromRGB(175, 58, 0) },
	orange2 = { Color3.fromRGB(255, 170, 0), Color3.fromRGB(211, 137, 0) },
	orange3 = { Color3.fromRGB(255, 199, 58), Color3.fromRGB(255, 37, 21) },
	orange4 = { Color3.fromRGB(255, 85, 0), Color3.fromRGB(255, 140, 0) },

	pinkRed = { Color3.fromRGB(255, 0, 60), Color3.fromRGB(204, 33, 64) },
	pinkRed2 = { Color3.fromRGB(250, 35, 90), Color3.fromRGB(223, 31, 88) },
	pinkRed2Blue = { Color3.fromRGB(250, 35, 90), Color3.fromRGB(0, 123, 255) },
	pink = { Color3.fromRGB(255, 85, 127), Color3.fromRGB(180, 46, 75) },
	pinkDeep = { Color3.fromRGB(255, 20, 147), Color3.fromRGB(139, 10, 80) },

	purple = { Color3.fromRGB(119, 44, 225), Color3.fromRGB(81, 81, 225) },
	purple2 = { Color3.fromRGB(136, 40, 255), Color3.fromRGB(136, 0, 255) },
	purple3 = { Color3.fromRGB(132, 112, 255), Color3.fromRGB(72, 61, 139) },

	royalPurple = { Color3.fromRGB(85, 85, 235), Color3.fromRGB(85, 50, 255) },
	royalPurple2 = { Color3.fromRGB(85, 85, 235), Color3.fromRGB(136, 50, 255) },

	rainbow = {
		Color3.fromRGB(255, 0, 4),
		Color3.fromRGB(255, 170, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(85, 255, 0),
		Color3.fromRGB(0, 170, 255),
		Color3.fromRGB(170, 85, 255),
	},
	rainbow2 = {
		Color3.fromRGB(244, 67, 54),
		Color3.fromRGB(233, 30, 99),
		Color3.fromRGB(156, 39, 176),
		Color3.fromRGB(33, 150, 243),
		Color3.fromRGB(0, 200, 83),
		Color3.fromRGB(255, 235, 59),
		Color3.fromRGB(255, 109, 0),
	},

	red = { Color3.fromRGB(255, 20, 24), Color3.fromRGB(175, 26, 29) },
	red2 = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(230, 0, 0) },

	teal = { Color3.fromRGB(0, 192, 176), Color3.fromRGB(0, 128, 128) },

	totalBlack = { Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0) },

	yellowGold = { Color3.fromRGB(235, 235, 0), Color3.fromRGB(255, 170, 0) },
	yellowGold2 = { Color3.fromRGB(235, 215, 0), Color3.fromRGB(255, 170, 0) },
	yellowGold3 = { Color3.fromRGB(235, 215, 0), Color3.fromRGB(255, 128, 0) },
	yellow = { Color3.fromRGB(247, 179, 18), Color3.fromRGB(211, 118, 42) },
	yellow2 = { Color3.fromRGB(235, 220, 0), Color3.fromRGB(255, 170, 0) },
	yellow3 = { Color3.fromRGB(255, 210, 0), Color3.fromRGB(200, 163, 0) },
	yellowPure = { Color3.fromRGB(255, 238, 0), Color3.fromRGB(234, 183, 17) },
}

Color.colorSequences = {} -- { colorName = ColorSequence } initialized in InitializeColorSequences()
-- FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function Color.GenerateColor()
	return Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))
end

function Color.AddDarkness(color3, percentage) -- any color3 and percentage out of 1
	local h, s, v = color3:ToHSV()

	return Color3.fromHSV(h, s, v * (1 - percentage))
end

-- COLOR SEQUENCE -----------------------------------------------------------------------------------------------------------------------------------
local function InitializeColorSequences()
	for eachColorName, eachColorsTable in pairs(Color.gradientColors) do
		Color.colorSequences[eachColorName] = Color.ColorSequence(eachColorsTable)
	end
end

function Color.ColorSequence(colors: table | Color3)
	if type(colors) == "table" then
		local colorSequence = {}
		for i, eachColor in pairs(colors) do
			if i == 1 then
				table.insert(colorSequence, ColorSequenceKeypoint.new(0, eachColor))
			elseif i == #colors then
				table.insert(colorSequence, ColorSequenceKeypoint.new(1, eachColor))
			else
				table.insert(colorSequence, ColorSequenceKeypoint.new((i / #colors), eachColor))
			end
		end

		if #colors == 1 then
			table.insert(colorSequence, ColorSequenceKeypoint.new(1, colors[1]))
		end

		colorSequence = ColorSequence.new(colorSequence)
		return colorSequence
	elseif typeof(colors) == "Color3" then
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, colors),
			ColorSequenceKeypoint.new(1, colors),
		})
	end
end

function Color.GetColorSequenceTable(colorSequence)
	local keyPoints = {}
	local keyPointsColors = {}

	for _, eachKeypoint in pairs(colorSequence.Keypoints) do
		--print(tostring(eachKeypoint.Time).." has a color of "..tostring(eachKeypoint.Value))
		table.insert(keyPoints, eachKeypoint.Time)
		local color = eachKeypoint.Value
		local keyPointColor = { color.R, color.G, color.B }
		table.insert(keyPointsColors, keyPointColor)
	end

	local colorSequenceTable = { keyPoints, keyPointsColors }
	--print(colorSequenceTable)
	return colorSequenceTable
end

function Color.GetColorSequenceFromTable(colorSequenceTable)
	local colorSequences = {}
	if not colorSequenceTable then
		return
	end
	for i, eachKeyPoint in ipairs(colorSequenceTable[1]) do
		local rgb = colorSequenceTable[2][i]
		local color = Color3.new(rgb[1], rgb[2], rgb[3])
		table.insert(colorSequences, ColorSequenceKeypoint.new(eachKeyPoint, color))
	end
	local colorSequence = ColorSequence.new(colorSequences)
	return colorSequence
end

-- RAINBOW -----------------------------------------------------------------------------------------------------------------------------------
function Color.Random()
	return colorsTable[math.random(#colorsTable)]
end

function Color.RainbowColors(colorsCount: number)
	local colors = {}
	local availableColors = { unpack(colorsTable) }

	colorsCount = colorsCount or #availableColors
	if colorsCount > #colorsTable then
		colorsCount = #colorsTable
	end

	for i = 1, colorsCount do
		local randomIndex = math.random(#availableColors)
		table.insert(colors, table.remove(availableColors, randomIndex))
	end

	return colors
end

function Color.GetRainbowColorSequence(colorsCount: number)
	local colors = Color.RainbowColors(colorsCount)
	return Color.ColorSequence(colors)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
InitializeColorSequences()

return Color

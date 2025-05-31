local Number = {}

function Number.Spaced(number, minimumLimit)
	number = tonumber(number) or 0
	minimumLimit = minimumLimit or 1000

	if number < minimumLimit then
		return number
	end

	local numberString = tostring(number)
	local reversedString = string.reverse(numberString)
	local result = ""

	for i = 1, #reversedString do
		result = result .. string.sub(reversedString, i, i)

		if i % 3 == 0 and i ~= #reversedString then
			result = result .. " "
		end
	end

	return string.reverse(result)
end

function Number.WithCommas(number)
	number = tonumber(number) or 0

	local numberString = tostring(number)
	local reversedString = string.reverse(numberString)
	local result = ""

	for i = 1, #reversedString do
		result = result .. string.sub(reversedString, i, i)

		if i % 3 == 0 and i ~= #reversedString then
			result = result .. ","
		end
	end

	return string.reverse(result)
end

function Number.ToEnglish(number, roundNumber): string
	local units = { "K", "M", "B", "T", "Q" }

	if not number then
		return "0"
	elseif type(number) ~= "number" then
		if type(number) == "string" and tonumber(number) then
			number = tonumber(number)
		else
			return "0"
		end
	end

	local negative = number < 0
	number = math.abs(math.floor(number))

	for index = #units, 1, -1 do
		local unit = units[index]
		local size = 10 ^ (index * 3)

		if size <= number then
			if not roundNumber then
				number = (number * 10 / size) / 10
			else
				number = math.floor((number * 10 / size) + 0.5) / 10
			end

			local result = ("%.3f"):format(number)
			if string.sub(result, string.len(result) - 1, string.len(result) - 1) ~= "0" then
				number = string.sub(result, 1, string.len(result) - 1) .. unit
			elseif string.sub(result, string.len(result) - 2, string.len(result) - 2) ~= "0" then
				number = string.sub(result, 1, string.len(result) - 2) .. unit
			else
				number = ("%.0f"):format(number) .. unit
			end

			break
		end
	end

	if negative then
		return "-" .. number
	else
		return tostring(number)
	end
end

-- TESTS -----------------------------------------------------------------------------------------------------------------------------------
-- local TEST_CASES = {
-- 	[9] = "9",
-- 	[99] = "99",
-- 	[999] = "999",
-- 	[1000] = "1K",
-- 	[1040] = "1.04K",
-- 	[1050] = "1.05K",
-- 	[1100] = "1.1K",
-- 	[2400] = "2.4K",
-- 	[9999] = "9.99K",
-- 	[10000] = "10K",
-- 	[10500] = "10.5K",
-- 	[11000] = "11K",
-- 	[11009] = "11K",
-- 	[11099] = "11.09K",
-- 	[99999] = "99.99K",
-- 	[100000] = "100K",
-- 	[100500] = "100.5K",
-- 	[123456] = "123.45K",
-- 	[1000000] = "1M",
-- 	[1234567] = "1.23M",
-- 	[1234567890] = "1.23B",
-- 	[1234567890000] = "1.23T",
-- 	-- [1234567890000000] = "1234.6T",
-- 	[1234567890000000] = "1.23Q",
-- 	[-1000] = "-1K",
-- }

-- for number, expected in pairs(TEST_CASES) do
-- 	local result = Number.ToEnglish(number)
-- 	if result ~= expected then
-- 		warn("EnglishNumbers test fail: " .. number .. " was " .. result .. ", not " .. expected)
-- 	end
-- end

return Number

local Time = {}

function Time.Format(timeValue: number): string
	if not timeValue or type(timeValue) ~= "number" then
		return
	end
	if math.floor(timeValue / 60) < 10 then
		return string.format("%1d:%02d", math.floor(timeValue / 60), timeValue % 60) -- minute:second
	elseif timeValue < 3599 then -- less than 1 hour
		return string.format("%02d:%02d", math.floor(timeValue / 60), timeValue % 60) -- minute:second
	elseif timeValue < 86399 then
		return string.format(
			"%02d:%02d:%02d",
			math.floor(timeValue / 3600),
			math.floor((timeValue % 3600) / 60),
			timeValue % 60
		) -- hour:minute:second
	else
		-- more than 24 hours
		return string.format(
			math.floor(timeValue / 86400) < 10 and "%2d %s and %02d:%02d:%02d" or "%02d %s and %02d:%02d:%02d",
			math.floor(timeValue / 86400),
			math.floor(timeValue / 86400) == 1 and "Day" or "Days",
			math.floor((timeValue % 86400) / 3600),
			math.floor((timeValue % 3600) / 60),
			timeValue % 60
		) -- D hour:minute:second
	end
end

-- Time value is in seconds
function Time.ToString(timeValue: number): string
	-- Returns time in this format: 1 day, 2 hours 3 minutes and 4 seconds, doesn't show 0 values
	local minutes = math.floor(timeValue / 60)
	local hours = math.floor(minutes / 60)
	local days = math.floor(hours / 24)

	local str = ""

	if days > 0 then
		str = days .. " day" .. (days > 1 and "s" or "")
		hours = hours % 24
		if hours > 0 or minutes > 0 or timeValue > 0 then
			str = str .. ", "
		end
	end

	if hours > 0 then
		str = str .. hours .. " hour" .. (hours > 1 and "s" or "")
		minutes = minutes % 60
		if minutes > 0 or timeValue > 0 then
			str = str .. " and "
		end
	end

	if minutes > 0 then
		str = str .. minutes .. " minute" .. (minutes > 1 and "s" or "")
		timeValue = timeValue % 60
		if timeValue > 0 then
			str = str .. " and "
		end
	end

	if timeValue > 0 or str == "" then
		str = str .. timeValue .. " second" .. (timeValue > 1 and "s" or "")
	end

	return str

	-- if not timeValue or type(timeValue) ~= "number" then
	-- 	return
	-- end
	-- if timeValue < 60 then
	-- 	return string.format("%02d seconds", timeValue)
	-- elseif timeValue < 3600 then
	-- 	return string.format("%02d minutes and %02d seconds", math.floor(timeValue / 60), timeValue % 60)
	-- elseif timeValue < 86400 then
	-- 	return string.format(
	-- 		"%02d hours, %02d minutes and %02d seconds",
	-- 		math.floor(timeValue / 3600),
	-- 		math.floor((timeValue % 3600) / 60),
	-- 		timeValue % 60
	-- 	)
	-- else
	-- 	return string.format(
	-- 		"%02d days, %02d hours, %02d minutes and %02d seconds",
	-- 		math.floor(timeValue / 86400),
	-- 		math.floor((timeValue % 86400) / 3600),
	-- 		math.floor((timeValue % 3600) / 60),
	-- 		timeValue % 60
	-- 	)
	-- end
end

return Time

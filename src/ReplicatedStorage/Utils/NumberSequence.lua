local NumberSequenceUtil = {}

function NumberSequenceUtil.CooldownSequence(timeValue, transparency, inverted)
	timeValue = typeof(timeValue) == "number" and timeValue or 0
	transparency = typeof(transparency) == "number" and transparency or 0

	if timeValue >= 1 then
		timeValue = 1
	elseif timeValue <= 0 then
		timeValue = 0
	end

	if transparency >= 1 then
		transparency = 1
	elseif transparency <= 0 then
		transparency = 0
	end

	local sequenceKeypoints = {}
	local timeValue1 = (timeValue - 0.001 >= 0) and timeValue - 0.001 or 0

	if timeValue1 == 0 then
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(0, inverted and transparency or 1))
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(1, inverted and transparency or 1))
	elseif timeValue == 1 then
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(0, inverted and 1 or transparency))
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(1, inverted and 1 or transparency))
	else
		for i = 1, 4 do
			if i == 1 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(0, inverted and 1 or transparency))
			elseif i == 2 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(timeValue1, inverted and 1 or transparency))
			elseif i == 3 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(timeValue, inverted and transparency or 1))
			elseif i == 4 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(1, inverted and transparency or 1))
			end
		end
	end

	return NumberSequence.new(sequenceKeypoints)
end

function NumberSequenceUtil.new(keyValues: { [number]: number }) -- Index must start at 0 and finish at 1
	local sequenceKeypoints = {}

	for eachIndex, eachTransparency in pairs(keyValues) do
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(eachIndex, eachTransparency))
	end

	table.sort(sequenceKeypoints, function(a, b)
		return a.Time < b.Time
	end)

	return NumberSequence.new(sequenceKeypoints)
end

-- SCALING/MODIFYING -----------------------------------------------------------------------------------------------------------------------------------
function NumberSequenceUtil.Scale(numberSequence, scaleFactor)
	local numberSequenceKeypoints = {}

	-- Loop through keypoints in the input sequence
	for _, keypoint in ipairs(numberSequence.Keypoints) do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scaleFactor, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

return NumberSequenceUtil

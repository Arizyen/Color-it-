local LoadingModule = {}
-- Services
local TweenService = game:GetService("TweenService")
-- Folders

-- Modulescripts

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function LoadingModule.Tween(
	object,
	speedInt,
	easingStyle,
	easingDirection,
	repeatTimes,
	reversesTrueFalse,
	delayStartInt,
	properties
)
	if object ~= nil then
		local tweenInfo = TweenInfo.new(
			speedInt, -- The amount of time it takes for the tween to complete.
			easingStyle, -- The style in which the tween executes.
			easingDirection, -- The direction in which the EasingStyle executes.
			repeatTimes, -- Repeat count. Must be set to -1 to play indefinitely.
			reversesTrueFalse, -- If the tween reverses once it reaches it's goal.
			delayStartInt
		) -- The amount of delay before the tween starts

		local newTween = TweenService:Create(object, tweenInfo, properties)
		newTween:Play()
		return newTween
		--newTween.Completed:Wait()
	end
end

function LoadingModule.ReturnCooldownSequence(timeValue, transparency)
	if not timeValue or typeof(timeValue) ~= "number" then
		return
	end
	if timeValue >= 1 then
		timeValue = 1
	elseif timeValue <= 0 then
		timeValue = 0
	end

	if not transparency or typeof(transparency) ~= "number" then
		return
	end
	if transparency >= 1 then
		transparency = 1
	elseif transparency <= 0 then
		transparency = 0
	end

	local sequenceKeypoints = {}
	local timeValue1 = (timeValue - 0.0001 >= 0) and timeValue - 0.0001 or 0

	if timeValue1 == 0 then
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(0, 1))
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
	elseif timeValue == 1 then
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(0, transparency))
		table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(1, transparency))
	else
		for i = 1, 4 do
			if i == 1 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(0, transparency))
			elseif i == 2 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(timeValue1, transparency))
			elseif i == 3 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(timeValue, 1))
			elseif i == 4 then
				table.insert(sequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
			end
		end
	end

	return NumberSequence.new(sequenceKeypoints)
end

return LoadingModule

local NumberRange = {}

function NumberRange.Scale(numberRange, scaleFactor)
	return NumberRange.new(numberRange.Min * scaleFactor, numberRange.Max * scaleFactor)
end

return NumberRange

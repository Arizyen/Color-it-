local function Reduce(tbl, callback, initialValue)
	local value = initialValue or tbl[1]

	for i, v in pairs(tbl) do
		value = callback(value, v, i)
	end

	return value
end

return Reduce

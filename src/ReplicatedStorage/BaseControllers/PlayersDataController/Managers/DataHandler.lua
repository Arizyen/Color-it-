local DataHandler = {}

function DataHandler.UpdateDataValue(data, value, index)
	if type(data) == "table" then
		data[index] = value
		-- else
		-- print("Not a table: UpdateDataValue")
	end
end

function DataHandler.InsertDataValue(data, value, index)
	if type(data) == "table" then
		if type(index) == "number" and value then
			table.insert(data, index, value)
		elseif type(index) == "string" then
			data[index] = value
		elseif value then
			table.insert(data, value)
		end
		-- else
		-- print("Not a table: InsertDataValue")
	end
end

function DataHandler.RemoveDataValue(data, index)
	if type(data) == "table" then
		if type(index) == "number" then
			table.remove(data, index)
		elseif type(index) == "string" then
			data[index] = nil
		end
		-- else
		-- print("Not a table")
	end
end

return DataHandler

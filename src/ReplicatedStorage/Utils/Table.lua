local Table = {}
-- Services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
-- local Source = ReplicatedStorage:WaitForChild("Source")
--
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
--
-- Modulescripts

-- KnitControllers

-- Instances

-- Configs

-- Variables
local none = newproxy(true)
local randomGenerator = Random.new()
-- Tables

--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------
local function MergeProps(overWrite: boolean?)
	return function(...)
		local new = {}

		for dictionaryIndex = 1, select("#", ...) do
			local dictionary = select(dictionaryIndex, ...)

			if dictionary ~= nil then
				if typeof(dictionary) ~= "table" then
					continue
				end

				for key, value in pairs(dictionary) do
					if value == none then
						new[key] = nil
					elseif not overWrite and new[key] then
						continue
					elseif
						typeof(key) == "string"
						and key ~= "ref"
						and string.sub(key, 1, 1) == string.lower(string.sub(key, 1, 1))
					then
						continue
					else
						new[key] = value
					end
				end
			end
		end

		return new
	end
end

--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
-- DICTIONARIES -----------------------------------------------------------------------------------------------------------------------------------
-- Merge react properties together in a new table. Second table does not overwrite first table. Functions are not passed.
function Table.MergeProps(...)
	return MergeProps(false)(...)
end

-- Merge react properties together in a new table. Second table overwrites first table. Functions are not passed.
function Table.MergePropsOverwrite(...)
	return MergeProps(true)(...)
end

-- Merge tables to the mainTable. Does not create a new table but modifies the mainTable. Second table overwrites keys.
function Table.Merge(mainTable, ...)
	for dictionaryIndex = 1, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		if type(dictionary) == "table" then
			for key, value in pairs(dictionary) do
				if value == none then
					mainTable[key] = nil
				else
					mainTable[key] = value
				end
			end
		end
	end

	return mainTable
end

function Table.DeepMerge(tables, convertToNumber)
	local new = {}

	for _, eachDictionary in pairs(tables) do
		if type(eachDictionary) == "table" then
			for key, value in pairs(eachDictionary) do
				key = (convertToNumber and tonumber(key)) and tonumber(key) or key

				if type(value) == "table" then
					if new[key] == nil or type(new[key]) ~= "table" then
						new[key] = Table.DeepCopy(value)
					else
						new[key] = Table.DeepMerge({ new[key], value }, convertToNumber)
					end
				else
					new[key] = value
				end
			end
		end
	end

	return new
end

-- Returns a new copy of tables passed (Overwrites duplicate keys)
function Table.Copy(...)
	local new = {}

	for dictionaryIndex = 1, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		if type(dictionary) == "table" then
			for key, value in pairs(dictionary) do
				new[key] = value
			end
		end
	end

	return new
end

-- Returns a whole new copy of all tables passed (Overwrites duplicate keys)
function Table.DeepCopy(...)
	local new = {}

	for dictionaryIndex = 1, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		if type(dictionary) == "table" then
			for key, value in pairs(dictionary) do
				if type(value) == "table" then
					new[key] = Table.DeepCopy(value)
				else
					new[key] = value
				end
			end
		end
	end

	return new
end

function Table.DeepCopyWithWait(tableToDeepCopy, speed)
	local new = {}

	local int = 0

	for key, value in pairs(tableToDeepCopy) do
		if type(value) == "table" then
			new[key] = Table.DeepCopyWithWait(value, speed)
		else
			int += 1
			new[key] = value

			if int % speed == 0 then
				task.wait()
				int = 0
			end
		end
	end

	return new
end

function Table.TableContainsKeys(myTable: table, keys: table): boolean
	if type(myTable) ~= "table" or type(keys) ~= "table" then
		return false
	end

	for _, eachKey in pairs(keys) do
		if myTable[eachKey] == nil then
			return false
		end
	end

	return true
end

function Table.Map<T, U>(array: { T }, mapper: (value: T, index: number, array: { T }) -> U?): { U }
	local mapped = {}

	for index, value in ipairs(array) do
		local mappedValue = mapper(value, index, array)

		if mappedValue ~= nil then
			table.insert(mapped, mappedValue)
		end
	end

	return mapped
end

-- ARRAY LISTS -----------------------------------------------------------------------------------------------------------------------------------
-- Remove duplicates of an array list. Returns an array list without duplicates
function Table.RemoveDuplicates(array)
	if type(array) ~= "table" then
		return {}
	end

	local newTable = {}
	for _, eachItem in pairs(array) do
		if not table.find(newTable, eachItem) then
			table.insert(newTable, eachItem)
		end
	end

	return newTable
end

-- will merge array lists in a new table without ignoring duplicates
function Table.CopyLists(...)
	local newTable = {}

	for dictionaryIndex = 1, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		if dictionary ~= nil then
			if typeof(dictionary) ~= "table" then
				continue
			end

			for _, value in pairs(dictionary) do
				table.insert(newTable, value)
			end
		end
	end

	return newTable
end

-- will merge array lists in a new table while ignoring duplicates
function Table.MergeLists(...)
	local newTable = {}

	for dictionaryIndex = 1, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		if typeof(dictionary) == "table" then
			for _, value in pairs(dictionary) do
				if not table.find(newTable, value) then
					table.insert(newTable, value)
				end
			end
		end
	end

	return newTable
end

-- Will add items in tableToAddTo while not ignoring duplicates
function Table.AddItems(tableToAddTo: table, items: table): ()
	if type(tableToAddTo) ~= "table" or type(items) ~= "table" then
		return
	end

	for _, eachValue in pairs(items) do
		table.insert(tableToAddTo, eachValue)
	end
end

-- Will add items from tableToAddFrom in tableToAddTo while ignoring duplicates
function Table.AddUniqueItems(tableToAddTo: table, tableToAddFrom: table): ()
	if type(tableToAddTo) ~= "table" or type(tableToAddFrom) ~= "table" then
		return
	end

	for _, eachValue in pairs(tableToAddFrom) do
		if not table.find(tableToAddTo, eachValue) then
			table.insert(tableToAddTo, eachValue)
		end
	end
end

-- Will add item in tableToAddTo if it is not a duplicate
function Table.AddUniqueItem(tableToAddTo: table, item: any): ()
	if type(tableToAddTo) ~= "table" or not item then
		return
	end

	if not table.find(tableToAddTo, item) then
		table.insert(tableToAddTo, item)
	end
end

-- Will remove items from the list tableToRemoveFrom if found
function Table.RemoveItems(tableToRemoveFrom: table, items: table): ()
	if type(tableToRemoveFrom) ~= "table" or type(items) ~= "table" then
		return
	end

	local index
	for _, eachItem in pairs(items) do
		index = table.find(tableToRemoveFrom, eachItem)
		if index then
			table.remove(tableToRemoveFrom, index)
		end
	end
end

-- Will remove item from the list tableToRemoveFrom if found
function Table.RemoveItem(tableToRemoveFrom: table, item: any): ()
	if type(tableToRemoveFrom) ~= "table" or not item then
		return
	end

	local index = table.find(tableToRemoveFrom, item)
	if index then
		table.remove(tableToRemoveFrom, index)
	end
end

-- SORTING TABLES -----------------------------------------------------------------------------------------------------------------------------------
local function spairs(t: { [any]: any }, order: (table, any, any) -> boolean)
	-- It collets the keys of the dictionary then sorts the keys depending on the order function given then returns an iterator function with sorted key,value
	-- collect the keys
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a, b)
			return order(t, a, b)
		end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function Table.GetOrderedDictionary(dictionary: { [string]: any }, orderFunction: (table, any, any) -> boolean): table
	-- Return an ordered table of the keys in order depending on sort option. The key has the object, v has the value to compare.
	local orderedTable = {}

	--[[ Order function example (low to high):
		function(t, a, b)
			return t[a] < t[b]
		end
	--]]

	for k, v in spairs(dictionary, orderFunction) do
		table.insert(orderedTable, v)
	end

	return orderedTable
end

function Table.GetOrderedDictionaryByKey(dictionary: { [string]: any }, lowToHigh: boolean?): table
	-- Return an ordered table of the keys in order depending on sort option. The key has the object, v has the value to compare.
	local orderedKeysTable = {}

	if lowToHigh then
		for k, v in
			spairs(dictionary, function(t, a, b)
				return t[a] < t[b]
			end)
		do
			table.insert(orderedKeysTable, k)
		end
	else
		for k, v in
			spairs(dictionary, function(t, a, b)
				return t[a] > t[b]
			end)
		do
			table.insert(orderedKeysTable, k)
		end
	end

	return orderedKeysTable
end

function Table.SortLowHigh(tbl: table, state: boolean?): table
	if #tbl <= 1 then
		return tbl
	end

	if state then
		table.sort(tbl, function(a, b)
			return a < b
		end)
	else
		table.sort(tbl, function(a, b)
			return a > b
		end)
	end
	return tbl
end

function Table.ShuffleList(list: table, returnNewList: boolean?): table
	math.randomseed(os.time())
	if returnNewList then
		-- Returns a new shuffled table (Does not modify table given)
		local shuffled = {}
		for i, v in ipairs(list) do
			local pos = randomGenerator:NextInteger(1, #shuffled + 1)
			table.insert(shuffled, pos, v)
		end
		return shuffled
	else
		-- Shuffles the table given
		for i = #list, 2, -1 do
			local j = randomGenerator:NextInteger(1, i)
			list[i], list[j] = list[j], list[i]
		end
		return list
	end
end

-- TABLE SEPARATION -----------------------------------------------------------------------------------------------------------------------------------
function Table.ReturnSeparateTables(mainTable: table, maxTableSize: number?, twoLevelRecursion: boolean?): { table }
	if type(mainTable) ~= "table" then
		return {}
	end

	maxTableSize = maxTableSize or 5000
	local tables = {}
	local newTable = {}
	local count = 0

	for eachKey, eachValue in pairs(mainTable) do
		if type(eachValue) == "table" and twoLevelRecursion then
			newTable[eachKey] = {}

			for eachSecondKey, eachSecondValue in pairs(eachValue) do
				count += 1
				newTable[eachKey][eachSecondKey] = eachSecondValue

				if count >= maxTableSize then
					count = 0
					table.insert(tables, newTable)
					newTable = {}
					newTable[eachKey] = {}
				end
			end
		else
			count += 1
			newTable[eachKey] = eachValue

			if count >= maxTableSize then
				count = 0
				table.insert(tables, newTable)
				newTable = {}
			end
		end
	end

	if Table.HasValue(newTable) then
		table.insert(tables, newTable)
	end

	return tables
end

-- MISCELLANEOUS FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- Returns true if the table has at least one key with a non-empty value
function Table.HasValue(myTable: table): boolean
	if type(myTable) ~= "table" then
		return false
	end

	for _, eachValue in pairs(myTable) do
		if type(eachValue) == "table" then
			if Table.HasValue(eachValue) then
				return true
			end
		elseif eachValue and eachValue ~= "" then
			return true
		end
	end

	return false
end

-- Return the key with the max values. If multiple keys have the same max value, return a random one of them
function Table.GetMaxValueKey(myTable: table): any
	if type(myTable) ~= "table" then
		return nil
	end

	local maxKey
	local maxValue = -math.huge

	for eachKey, eachValue in pairs(myTable) do
		if eachValue > maxValue then
			maxKey = eachKey
			maxValue = eachValue
		elseif eachValue == maxValue then
			if randomGenerator:NextNumber() > 0.5 then
				maxKey = eachKey
			end
		end
	end

	return maxKey
end

-- Returns the length of a table. If countTablesLength is true, it will count the length of tables inside the table as well
function Table.Length(t: table, countTablesLength: boolean, customMaxLevel: number?, currentLevel: number)
	if #t > 0 then
		return #t
	else
		local count = 0

		for _, eachValue in pairs(t) do
			if type(eachValue) == "table" then
				if not countTablesLength then
					count += 1
				else
					if currentLevel and customMaxLevel and currentLevel >= customMaxLevel then
						count += 1
					else
						if not customMaxLevel then
							count += Table.Length(eachValue, countTablesLength)
						else
							count += Table.Length(
								eachValue,
								countTablesLength,
								customMaxLevel,
								currentLevel and currentLevel + 1 or 1
							)
						end
					end
				end
			elseif type(eachValue) ~= none then
				count += 1
			end
		end

		return count
	end
end

-- Returns the keys of a table
function Table.Keys(t: table)
	local keys = {}
	for eachKey, _ in pairs(t) do
		table.insert(keys, eachKey)
	end
	return keys
end

-- Returns the values of a dictionary
function Table.Values(t: table)
	local values = {}
	for _, eachValue in pairs(t) do
		table.insert(values, eachValue)
	end
	return values
end

return Table

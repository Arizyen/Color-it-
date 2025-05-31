local Contexts = {}

local privateStorage = {
	Theme = require(script:WaitForChild("Theme")),
}

local function resolveContext(key)
	local module = privateStorage[key]
	if module and module.Context then
		rawset(Contexts, key, module.Context) -- Cache in Contexts
		return module.Context
	else
		local availableKeys = {}
		for k in pairs(privateStorage) do
			table.insert(availableKeys, k)
		end
		error(
			("%q is not a valid member of Contexts. Available keys: %s"):format(
				tostring(key),
				table.concat(availableKeys, ", ")
			),
			2
		)
	end
end

-- Return the Context automatically for the key accessed
setmetatable(Contexts, {
	__index = function(_, key)
		return resolveContext(key)
	end,
	__call = function(_, key)
		return resolveContext(key)
	end,
})

return Contexts

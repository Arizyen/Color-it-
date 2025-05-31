local Selectors = {}

-- Selectors.Selector = require(script.Selector)

function Selectors.GetValueFromStore(state, store: string, key)
	if state[store] then
		return state[store][key]
	end
end

return Selectors

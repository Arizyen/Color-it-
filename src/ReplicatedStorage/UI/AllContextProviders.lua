-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Contexts = script.Parent:WaitForChild("Contexts")
-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))

local Theme = require(Contexts:WaitForChild("Theme"))
-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- MainComponents ------------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Types ---------------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------
local contextProviders = {
	Theme.Provider,
}
------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function AllProviders(props)
	local wrapped = props.children

	for _, provider in ipairs(contextProviders) do
		wrapped = e(provider, nil, wrapped)
	end

	return wrapped
end

return AllProviders

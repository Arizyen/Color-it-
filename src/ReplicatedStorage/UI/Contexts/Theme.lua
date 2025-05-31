-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))

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

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local ThemeContext = React.createContext()

local function ThemeProvider(props)
	local theme = ReactRedux.useSelector(function(state)
		return state.theme
	end)

	return e(ThemeContext.Provider, {
		value = theme,
		children = props.children,
	})
end

return {
	Provider = ThemeProvider,
	Context = ThemeContext,
}

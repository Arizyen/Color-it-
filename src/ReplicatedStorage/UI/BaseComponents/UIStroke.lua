-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local Utils = require(Source:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- MainComponents ------------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Types ---------------------------------------------------------------------------
type props = {
	ApplyStrokeMode: Enum.ApplyStrokeMode?,
	Thickness: number?,
	Color: Color3?,
}
-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function UIStroke(props)
	-- SELECTORS -----------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES/CONTEXTS ------------------------------------------------------------------------------------------------
	local theme = React.useContext(Contexts.Theme)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local thickness = React.useMemo(function()
		return (props.Thickness or 2) * (theme.totalScreenSize >= 1300 and 1 or 0.5) -- Half thickness on mobile
	end, { props.Thickness, theme.totalScreenSize })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("UIStroke", {
		ApplyStrokeMode = props.ApplyStrokeMode or Enum.ApplyStrokeMode.Contextual,
		Color = props.Color or theme.strokeColor,
		Thickness = thickness,
	}, props.children)
end

return UIStroke

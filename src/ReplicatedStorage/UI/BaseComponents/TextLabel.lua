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
	[string]: any,
	secondaryFont: boolean?,
}
-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function TextLabel(props: props)
	-- SELECTORS -----------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES/CONTEXTS ------------------------------------------------------------------------------------------------
	local theme = React.useContext(Contexts.Theme)

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"TextLabel",
		Utils.Table.Merge(props, {
			BackgroundTransparency = 1,
			Font = props.secondaryFont and theme.secondaryFont or theme.defaultFont,
			TextColor3 = props.TextColor3 or theme.textColor3,
			TextScaled = true,
		}),
		props.children
	)
end

return TextLabel

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local Utils = require(Source:WaitForChild("Utils"))
local UIUtils = require(Source:WaitForChild("UIUtils"))
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
	active: boolean, -- Must add active if using colorSequence, otherwise it won't work
	colorSequence: ColorSequence,
	velocity: number?,
	ApplyStrokeMode: Enum.ApplyStrokeMode?,
	Thickness: number?,
	Color: Color3?,
}
-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function UIStrokeAnimated(props)
	-- SELECTORS -----------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES/CONTEXTS ------------------------------------------------------------------------------------------------
	local theme = React.useContext(Contexts.Theme)

	local animationMotorConfigs = React.useRef(UIUtils.Flipper.CreateContinuingMotor(props.velocity or 1 / 2))

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------
	local thickness = React.useMemo(function()
		return (props.Thickness or 2) * (theme.totalScreenSize >= 1300 and 1 or 0.5) -- Half thickness on mobile
	end, { props.Thickness, theme.totalScreenSize })

	-- EFFECTS -------------------------------------------------------------------------------------------------------------
	-- Animation
	React.useEffect(function()
		animationMotorConfigs.current:Start(props.colorSequence ~= nil and props.active)
	end, { props.colorSequence, props.active })

	-- Speed
	React.useEffect(function()
		animationMotorConfigs.current.velocity = props.velocity
	end, { props.velocity })

	-- Cleanup
	React.useEffect(function()
		return function()
			animationMotorConfigs.current:Destroy()
		end
	end, {})

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e(
		"UIStroke",
		{
			ApplyStrokeMode = props.ApplyStrokeMode or Enum.ApplyStrokeMode.Contextual,
			Color = props.Color or props.colorSequence and Color3.fromRGB(255, 255, 255) or theme.strokeColor,
			Thickness = thickness,
		},
		Utils.Table.Merge(props.children or {}, {
			UIGradient = props.colorSequence and e("UIGradient", {
				Color = props.colorSequence,
				Rotation = animationMotorConfigs.current.binding:map(function(value)
					return value * 360
				end),
			}),
		})
	)
end

return UIStrokeAnimated

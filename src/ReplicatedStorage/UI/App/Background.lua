-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")
local Configs = ReplicatedSource:WaitForChild("Configs")
local Infos = ReplicatedSource:WaitForChild("Infos")
local Types = ReplicatedSource:WaitForChild("Types")
local ReplicatedBaseModules = ReplicatedSource:WaitForChild("BaseModules")
local ReplicatedGameModules = ReplicatedSource:WaitForChild("GameModules")
local BaseControllers = ReplicatedSource:WaitForChild("BaseControllers")
local GameControllers = ReplicatedSource:WaitForChild("GameControllers")

local UI = ReplicatedSource:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local BaseComponents = UI:WaitForChild("BaseComponents")
local AppComponents = UI:WaitForChild("AppComponents")

-- Modulescripts -------------------------------------------------------------------
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(ReplicatedSource:WaitForChild("UIUtils"))
local Utils = require(ReplicatedSource:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))

-- Knit Controllers ----------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- BaseComponents ----------------------------------------------------------------

-- GlobalComponents ----------------------------------------------------------------

-- LocalComponents -----------------------------------------------------------------

-- AppComponents -------------------------------------------------------------------

-- Infos ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------
type Props = {}

-- Variables -----------------------------------------------------------------------
local e = React.createElement

-- Tables --------------------------------------------------------------------------

-- Selectors --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function Background(props: Props)
	-- SELECTORS/CONTEXTS -----------------------------------------------------------------------------------------------------------

	-- STATES/REFS/BINDINGS ---------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------

	-- MEMOS ---------------------------------------------------------------------------------------------------------------

	-- EFFECTS -------------------------------------------------------------------------------------------------------------

	-- COMPONENT -----------------------------------------------------------------------------------------------------------
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = -1,
	}, {
		UIGradient = e("UIGradient", {
			Color = Utils.Color.colorSequences["blue2"],
			Rotation = 90,
		}),
	})
end

return Background

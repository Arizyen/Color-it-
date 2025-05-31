-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))

local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function TextButton(props)
	-- Requires:
	-- Optional:
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES --------------------------------------------------------------------------------------------------------------------
	local buttonRef = React.useRef()
	-- EFFECTS ---------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if buttonRef.current then
			CollectionService:AddTag(buttonRef.current, "Button")
		end
	end, {})
	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e(
		"TextButton",
		Utils.Table.MergeProps(props, {
			ref = buttonRef,
			[React.Event.Activated] = function()
				if props.onClick then
					props.onClick()
				end
			end,
		})
	)
end

return TextButton

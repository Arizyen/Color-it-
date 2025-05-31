-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local UserThumbnailModule = require(ReplicatedBaseModules:WaitForChild("UserThumbnail"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents

-- LocalComponents

-- Configs

-- Types
type props = {
	player: Player,
}

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function UserThumbnail(props: props)
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------

	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES --------------------------------------------------------------------------------------------------------------------
	local userImage, setUserImage = React.useBinding(nil)
	-- EFFECTS ---------------------------------------------------------------------------------------------------------------------------------
	React.useEffect(function()
		if props.player then
			if UserThumbnailModule.ReturnUserThumbnail(props.player) then
				setUserImage(UserThumbnailModule.ReturnUserThumbnail(props.player))
			else
				UserThumbnailModule.RetrieveUserThumbnail(props.player):andThen(function(image)
					setUserImage(image)
				end)
			end
		else
			setUserImage(nil)
		end
	end, { props.player })
	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e(
		"ImageLabel",
		Utils.Table.MergeProps(props, {
			Image = userImage:map(function(value)
				return value or ""
			end),
			ScaleType = Enum.ScaleType.Fit,
		}, props[React.Children])
	)
end

return UserThumbnail

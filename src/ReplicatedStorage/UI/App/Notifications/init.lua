-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local TweenService = game:GetService("TweenService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")
-- local GlobalComponents = UI:WaitForChild("GlobalComponents")
local NotificationsFolder = UI:WaitForChild("Notifications")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))
-- local Flipper = require(Packages:WaitForChild("Flipper"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents
-- local BaseComponents = require(ReplicatedModulescripts:WaitForChild("BaseComponents"))
-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables
local Notifications = React.Component:extend("Notifications")
local components = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--[[mapStateToProps, which accepts the store's state as the first argument, as well as the props passed to the component.
mapStateToProps is run whenever the Rodux store updates, as well as whenever the props passed to your component are updated.]]
local function MapStateToProps(state, props)
	return {
		notifications = state.notifications,
		hideSideGuis = state.window.hideSideGuis,
		hideNotifications = state.window.hideNotifications,
		mapLoading = state.game.mapLoading,
	}
end

--[[mapDispatchToProps, which accepts a function that dispatches actions to your store. It works just like Store:dispatch in Rodux!
mapDispatchToProps is only run once per component instance.]]
local function MapDispatchToProps(dispatch)
	return {
		DispatchAction = function(action)
			dispatch(action)
		end,
	}
end

local function ReturnComponent(componentName)
	if components[componentName] then
		return components[componentName]
	else
		if NotificationsFolder:FindFirstChild(componentName) then
			components[componentName] = require(NotificationsFolder[componentName])
			return components[componentName]
		end
	end
end

-- local function Lerp(a, b, alpha)
-- 	return a + (b - a) * alpha
-- end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--[[init is called exactly once when a new instance of a component is created. It can be used to set up the initial state, as well as any non-render related values directly on the component.]]
function Notifications:init()
	self.scrollingFrameRef = React.createRef()
end

--[[render describes what a component should display at the current instant in time.]]
function Notifications:render()
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.09),
		Size = UDim2.fromScale(0.37, 0.175),
		Visible = not self.props.hideNotifications and not self.props.hideSideGuis and not self.props.mapLoading,
	}, {
		ScrollingFrame = e(
			"ScrollingFrame",
			{
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 1),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				CanvasSize = UDim2.fromScale(0, 2),
				ScrollBarImageTransparency = 1,
				ScrollBarThickness = 0,
				ScrollingEnabled = true,
				[React.Ref] = self.scrollingFrameRef,
			},
			Utils.Table.Merge({
				UIGridLayout = e("UIGridLayout", {
					CellPadding = UDim2.fromScale(0, 0.015),
					CellSize = UDim2.fromScale(1, 0.49),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					StartCorner = Enum.StartCorner.BottomLeft,
				}),
			}, self:ReturnNotifications())
		),
	})
end

--[[didMount is fired after the component finishes its initial render. At this point, all associated Roblox Instances have been created, and all components have finished mounting.
didMount is a good place to start initial network communications, attach events to services, or modify the Roblox Instance hierarchy.]]
function Notifications:didMount() end

--[[willUnmount is fired right before Roact begins unmounting a component instance's children.
willUnmount acts like a component's destructor, and is a good place to disconnect any manually-connected events.]]
function Notifications:willUnmount() end

--[[willUpdate is fired after an update is started but before a component's state and props are updated. Variables given by function: nextProps, nextState]]
function Notifications:willUpdate() end

--[[didUpdate is fired after at the end of an update. At this point, Roact has updated the properties of any Roblox Instances and the component instance's props and state are up to date. Variables given by function: previousProps, previousState
didUpdate is a good place to send network requests or dispatch Rodux actions, but make sure to compare self.props and self.state with previousProps and previousState to avoid triggering too many updates.]]
function Notifications:didUpdate(lastProps)
	if self.props.notifications.totalNotifications ~= lastProps.notifications.totalNotifications then
		self.scrollingFrameRef:getValue().CanvasPosition = Vector2.new()
	end
end

function Notifications:ReturnNotifications()
	local notifications = {}
	local notificationComponent

	for eachId, eachNotification in pairs(self.props.notifications.allNotifications) do
		notificationComponent = ReturnComponent(eachNotification["componentName"])
		if notificationComponent then
			notifications[eachId] = e(notificationComponent, eachNotification["props"])
		end
	end

	return notifications
end

return ReactRedux.connect(MapStateToProps, MapDispatchToProps)(Notifications)

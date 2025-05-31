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
local NotificationsManager = require(ReplicatedBaseModules:WaitForChild("NotificationsManager"))
-- local Flipper = require(Packages:WaitForChild("Flipper"))
-- local Utils = require(Source:WaitForChild("Utils"))
local Gamepasses = require(ReplicatedBaseModules:WaitForChild("Gamepasses"))
local AdManager = require(ReplicatedBaseModules:WaitForChild("AdManager"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents
local BaseComponents = require(ReplicatedBaseModules:WaitForChild("BaseComponents"))
local Notification = require(GlobalComponents:WaitForChild("Notification"))
local Button = require(GlobalComponents:WaitForChild("Button"))

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement

-- Tables
local NotificationVIP = React.Component:extend("NotificationVIP")
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--[[mapStateToProps, which accepts the store's state as the first argument, as well as the props passed to the component.
mapStateToProps is run whenever the Rodux store updates, as well as whenever the props passed to your component are updated.]]
local function MapStateToProps(state, props)
	return {
		-- data = state.data,
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
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--[[init is called exactly once when a new instance of a component is created. It can be used to set up the initial state, as well as any non-render related values directly on the component.]]
function NotificationVIP:init() end

--[[render describes what a component should display at the current instant in time.]]
function NotificationVIP:render()
	-- needs: id, timeShown
	return e(Notification, {
		onClose = function()
			NotificationsManager.HideNotification(self.props.id)
			AdManager.IncrementAdShownTimes("vip")
		end,
		timeShown = self.props.timeShown,
		layoutOrder = self.props.layoutOrder,
		content = {
			ImageLabelGamepass = e("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(0.125, 1),
				Image = Gamepasses["vip"].image,
				ScaleType = Enum.ScaleType.Fit,
			}),

			TextLabel = e("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.14, 0.5),
				Size = UDim2.fromScale(0.57, 1),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.2,
				Font = BaseComponents.DEFAULT_FONT,
				Text = "VIP Content",
				TextScaled = true,
			}, {
				UIGradient = e("UIGradient", {
					Color = BaseComponents.colorSequences["yellow2"],
					Rotation = 90,
				}),
			}),

			Button = e(Button, {
				position = UDim2.fromScale(0.86, 0.5),
				size = UDim2.fromScale(0.25, 0.9),
				text = "Open",
				smallRatio = 0.95,
				largeRatio = 1.05,
				onClick = function()
					NotificationsManager.HideNotification(self.props.id)
					self.props.DispatchAction({
						type = "SetStoreCategory",
						value = "passes",
					})
					self.props.DispatchAction({
						type = "ShowWindow",
						value = "Store",
					})
					AdManager.IncrementAdShownTimes("vip")
				end,
			}),
		},
	})
end

--[[didMount is fired after the component finishes its initial render. At this point, all associated Roblox Instances have been created, and all components have finished mounting.
didMount is a good place to start initial network communications, attach events to services, or modify the Roblox Instance hierarchy.]]
function NotificationVIP:didMount() end

--[[willUnmount is fired right before Roact begins unmounting a component instance's children.
willUnmount acts like a component's destructor, and is a good place to disconnect any manually-connected events.]]
function NotificationVIP:willUnmount() end

--[[willUpdate is fired after an update is started but before a component's state and props are updated. Variables given by function: nextProps, nextState]]
function NotificationVIP:willUpdate() end

--[[didUpdate is fired after at the end of an update. At this point, Roact has updated the properties of any Roblox Instances and the component instance's props and state are up to date. Variables given by function: previousProps, previousState
didUpdate is a good place to send network requests or dispatch Rodux actions, but make sure to compare self.props and self.state with previousProps and previousState to avoid triggering too many updates.]]
function NotificationVIP:didUpdate() end

return ReactRedux.connect(MapStateToProps, MapDispatchToProps)(NotificationVIP)

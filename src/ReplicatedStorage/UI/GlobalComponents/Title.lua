-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")
local BaseComponents = UI:WaitForChild("BaseComponents")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))

local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))
local Utils = require(Source:WaitForChild("Utils"))
local Contexts = require(UI:WaitForChild("Contexts"))
-- KnitControllers

-- Instances

-- BaseComponents
local UIStroke = require(BaseComponents:WaitForChild("UIStroke"))

-- GlobalComponents
local CloseButton = require(GlobalComponents:WaitForChild("CloseButton"))

-- LocalComponents

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function Title(props)
	-- Requires: windowName, title, icon, color, size
	-- Optional: titleColorSequence, noCloseButton, onClose, customClose
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local theme = React.useContext(Contexts.Theme)
	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES --------------------------------------------------------------------------------------------------------------------

	-- EFFECTS ---------------------------------------------------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------

	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 0.25):Lerp(
			UDim2.fromScale(1, 0.12),
			math.clamp(
				(((props.size and props.size.Y.Scale or theme.maxWindowSizeY) - 0.25) / (theme.maxWindowSizeY - 0.25)),
				0,
				1
			)
		),
		ZIndex = 2,
	}, {
		UIGradient = e("UIGradient", {
			Color = props.titleColorSequence or ColorSequence.new({
				ColorSequenceKeypoint.new(0, props.color or Color3.fromRGB(0, 170, 255)),
				ColorSequenceKeypoint.new(
					1,
					props.color
							and Color3.fromHSV(
								math.clamp(
									({ props.color:ToHSV() })[1] + ({ props.color:ToHSV() })[1] < 0.6 and 0.05 or -0.05,
									0,
									1
								),
								({ props.color:ToHSV() })[2],
								({ props.color:ToHSV() })[3]
							)
						or Color3.fromRGB(0, 125, 235)
				),
			}),
			Offset = Vector2.new(0, 0),
			Rotation = 90,
		}),

		UIStroke = e("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 5,
		}),

		TextLabelTitle = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			-- Size = UDim2.fromScale(0.98, 0.88):Lerp(
			-- 	UDim2.fromScale(0.98, 0.87),
			-- 	(((props.size and props.size.Y.Scale or 0.5) - 0.25) / (0.57 - 0.25))
			-- ),
			Size = UDim2.fromScale(0.5, 0.9),
			Font = theme.defaultFont,
			Text = props.title or "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextStrokeTransparency = 1,
		}, {
			UIStroke = e(UIStroke, {
				Color = Color3.fromRGB(0, 0, 0),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Thickness = 1.5,
			}),
		}),

		ImageLabelIcon = e("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.005, 0.5),
			Size = UDim2.fromScale(0.1, 1.35),
			BackgroundTransparency = 1,
			Image = props.icon and "rbxassetid://9435990460" or "",
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 2,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			ImageLabelIcon = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
				BackgroundTransparency = 1,
				Image = props.icon or "",
				ScaleType = Enum.ScaleType.Fit,
			}),
		}),

		CloseButton = not props.noCloseButton and e(CloseButton, {
			windowName = props.windowName,
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.99, 0.5),
			size = UDim2.fromScale(0.25, 1.235),
			uiStrokeEnabled = true,
			onClose = props.onClose,
			customClose = props.customClose,
		}),
	})
end

return Title

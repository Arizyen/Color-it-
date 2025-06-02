-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local UI = Source:WaitForChild("UI")
local GlobalComponents = UI:WaitForChild("GlobalComponents")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local React = require(Packages:WaitForChild("React"))
local ReactRedux = require(Packages:WaitForChild("ReactRedux"))

local Utils = require(Source:WaitForChild("Utils"))
local Flipper = require(Packages:WaitForChild("Flipper"))
local UIUtils = require(Source:WaitForChild("UIUtils"))

-- KnitControllers

-- Instances

-- MainComponents

-- GlobalComponents

-- LocalComponents
local Button = require(GlobalComponents:WaitForChild("Button"))

-- Configs

-- Variables
local e = React.createElement
-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function NumericUpDown(props)
	-- Requires: anchorPoint, position, size, minNumber, maxNumber, increment, onUpdate()
	-- Optional: totalScreenSize
	-- SELECTORS -----------------------------------------------------------------------------------------------------------------------------------
	local defaultFont = ReactRedux.useSelector(function(state)
		return state.theme.defaultFont
	end)
	-- MEMOS -----------------------------------------------------------------------------------------------------------------------------------

	-- REFS/BINDINGS/STATES ----------------------------------------------------------------------------------------------------------------------------
	local currentNumber, setCurrentNumber = React.useState(props.startNumber or props.minNumber or 1)
	local startHoldTime = React.useRef(nil)
	-- EFFECTS ----------------------------------------------------------------------------------------------------------

	-- CALLBACKS -----------------------------------------------------------------------------------------------------------------------------------
	local Increase = React.useCallback(function(increase)
		local increment = props.increment or 1

		if props.onUpdate and type(currentNumber) == "number" then
			if increase then
				if props.maxNumber and currentNumber + increment > props.maxNumber then
					props.onUpdate(props.maxNumber)
					setCurrentNumber(props.maxNumber)
				else
					props.onUpdate(currentNumber + increment)
					setCurrentNumber(currentNumber + increment)
				end
			else
				if props.minNumber and currentNumber - increment < props.minNumber then
					props.onUpdate(props.minNumber)
					setCurrentNumber(props.minNumber)
				else
					props.onUpdate(currentNumber - increment)
					setCurrentNumber(currentNumber - increment)
				end
			end
		end
	end)

	local ButtonIsHeld = React.useCallback(function(state, value)
		if state then
			startHoldTime.current = os.clock()

			local intervalIncreaseCount = 0
			local intervalIncrease = 0.25
			local intervalDecreaseCount = 0
			local intervalDecrease = 0.15
			Utils.Connections.Add(
				"NumericUpDown",
				"buttonHeld",
				RunService.Heartbeat:Connect(function(dt)
					intervalIncreaseCount += dt
					if intervalIncreaseCount >= intervalIncrease then
						intervalIncreaseCount -= intervalIncrease
						Increase(value > 0)
						Utils.Sound.Play({
							SoundId = 14930937370,
							Volume = 1,
							Tag = "SoundEffect",
						})
					end

					if intervalIncrease > 0.125 then
						intervalDecreaseCount += dt
						if intervalDecreaseCount >= intervalDecrease then
							intervalDecreaseCount -= intervalDecrease
							intervalIncrease -= 0.025
						end
					end
				end)
			)
		else
			startHoldTime.current = nil
			Utils.Connections.DisconnectKeyConnection("NumericUpDown", "buttonHeld")
		end
	end)
	-- COMPONENT ----------------------------------------------------------------------------------------------------------------------------------
	return e("Frame", {
		AnchorPoint = props.anchorPoint or Vector2.new(0, 0.5),
		Position = props.position or UDim2.fromScale(0.008, 0.5),
		Size = props.size or UDim2.fromScale(0.4, 0.725),
		BackgroundTransparency = 1,
	}, {
		FrameTextBox = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.625, 1),
		}, {
			UIStroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(255, 255, 255),
				LineJoinMode = Enum.LineJoinMode.Round,
				Transparency = 0,
				Thickness = props.totalScreenSize and props.totalScreenSize >= 1300 and 2 or 1,
			}),
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.3, 0),
			}),
			TextBoxNumber = e("TextBox", {
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 1),
				Font = defaultFont,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextStrokeTransparency = 1,
				Text = currentNumber,
				[React.Change.Text] = function(rbx)
					if rbx.Text == "" or nil then
						rbx.Text = currentNumber
					else
						if not tonumber(rbx.Text) or tonumber(rbx.Text) == currentNumber then
							return
						end

						if props.minNumber and tonumber(rbx.Text) < props.minNumber then
							if props.onUpdate then
								props.onUpdate(props.minNumber)
							end
							setCurrentNumber(props.minNumber)
							-- rbx.Text = tostring(props.minNumber)
						elseif props.maxNumber and tonumber(rbx.Text) > props.maxNumber then
							if props.onUpdate then
								props.onUpdate(props.maxNumber)
							end
							setCurrentNumber(props.maxNumber)
							-- rbx.Text = tostring(props.maxNumber)
						else
							if props.onUpdate then
								props.onUpdate(tonumber(rbx.Text))
							end
							setCurrentNumber(tonumber(rbx.Text))
						end
					end
				end,
			}),
		}),

		FrameButtons = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.695, 0),
			Size = UDim2.fromScale(0.265, 1),
		}, {
			TextButtonMinus = e(Button, {
				anchorPoint = Vector2.new(0.5, 0.5),
				position = UDim2.fromScale(0.5, 0.75),
				size = UDim2.fromScale(1, 0.45),
				smallRatio = 0.95,
				largeRatio = 1.05,
				text = "",
				-- font = Enum.Font.FredokaOne,
				aspectRatio = 1,
				cornerRadius = UDim.new(1, 0),
				gradientColors = Utils.Colors.gradientColors["red"],
				onClick = function()
					if startHoldTime.current then
						if os.clock() - startHoldTime.current < 0.25 then
							Increase(false)
						end
					else
						Increase(false)
					end
				end,
				onHold = function()
					ButtonIsHeld(true, -1)
				end,
				onHoldEnd = function()
					ButtonIsHeld(false)
				end,
				image = "rbxassetid://14536800151",
				imageSize = UDim2.fromScale(0.75, 0.75),
			}),

			TextButtonPlus = e(Button, {
				anchorPoint = Vector2.new(0.5, 0.5),
				position = UDim2.fromScale(0.5, 0.25),
				size = UDim2.fromScale(1, 0.45),
				smallRatio = 0.95,
				largeRatio = 1.05,
				text = "",
				-- font = Enum.Font.FredokaOne,
				aspectRatio = 1,
				cornerRadius = UDim.new(1, 0),
				gradientColors = Utils.Colors.gradientColors["green"],
				onClick = function()
					if startHoldTime.current then
						if os.clock() - startHoldTime.current < 0.25 then
							Increase(true)
						end
					else
						Increase(true)
					end
				end,
				onHold = function()
					ButtonIsHeld(true, 1)
				end,
				onHoldEnd = function()
					ButtonIsHeld(false)
				end,
				image = "rbxassetid://14536793526",
				imageSize = UDim2.fromScale(0.75, 0.75),
			}),
		}),
	})
end

return NumericUpDown

-- Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterGui = game:GetService("StarterGui")
-- Folders

-- Modulescripts
local LoadingModule = require(script.Parent:WaitForChild("LoadingModule"))
-- Knit Controllers

-- Instances
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGuiLoading = ReplicatedFirst:WaitForChild("ScreenGuiLoading")

local LoadingScreen = ScreenGuiLoading:WaitForChild("LoadingScreen")

local FrameLoading = LoadingScreen:WaitForChild("FrameLoading")
local FrameProgress = FrameLoading:WaitForChild("FrameProgress")
local UIGradientFrameProgress = FrameProgress:WaitForChild("UIGradient")

local TextLabelProgress = FrameLoading:WaitForChild("TextLabelProgress")
local TextLabelLoading = LoadingScreen:WaitForChild("TextLabelLoading")

local ImageLabelLogo = LoadingScreen:WaitForChild("ImageLabelLogo")

-- local ImageLabelTile = LoadingScreen:WaitForChild("ImageLabelTile")

local KnitLoaded = ReplicatedFirst:WaitForChild("KnitLoaded")
local GuisLoaded = ReplicatedFirst:WaitForChild("GuisLoaded")
-- Configs
local FRAME_ICONS_ANIMATION_SPEED = 40
-- Variables
local currentProgress = 0
local loadingComplete = false
-- Tables
local progressValues = {
	serverLoaded = 25,
	knitLoaded = 25,
	dataLoaded = 25,
	-- mapsLoaded = 35,
	guisLoaded = 25,
}
-- Functions ------------------------------------------------------------------------------------------------------------------------------------
local function LoadingComplete()
	if loadingComplete then
		task.wait(0.5)
		ScreenGuiLoading:Destroy()
		script:Destroy()
	end
end

local function AnimateLoadingTextLabel()
	while not loadingComplete do
		TextLabelLoading.Text = not string.find(TextLabelLoading.Text, "%.%.%.") and TextLabelLoading.Text .. "."
			or string.gsub(TextLabelLoading.Text, "%.%.%.", "")
		task.wait(0.3)
	end
end

local function AnimateLogo()
	-- Rotate left and right
	-- LoadingModule.Tween(ImageLabelLogo, 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 0, {
	-- 	Rotation = 3,
	-- })

	-- Size up and down
	LoadingModule.Tween(ImageLabelLogo, 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true, 0, {
		Size = UDim2.fromScale(0.7, 0.6),
	})
end

-- local function AnimateBackground()
-- 	local totalScreenSize
-- 	if cameraViewportSize then
-- 		totalScreenSize = cameraViewportSize.X + cameraViewportSize.Y
-- 		if totalScreenSize <= 1300 then
-- 			ImageLabelTile.TileSize = UDim2.fromOffset(64, 64)
-- 		end
-- 	end

-- 	TweenService:Create(ImageLabelTile, TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
-- 		Position = UDim2.new(
-- 			-1,
-- 			totalScreenSize and totalScreenSize <= 1300 and 256 or 512,
-- 			0,
-- 			totalScreenSize and totalScreenSize <= 1300 and -256 or -512
-- 		),
-- 	}):Play()
-- end
-- UPDATING LOADING PROGRESS -----------------------------------------------------------------------------------------------------------------------------------
local function UpdateProgress(text, progress)
	TextLabelLoading.Text = not string.find(TextLabelLoading.Text, text) and text or TextLabelLoading.Text
	TextLabelProgress.Text = math.round(progress) .. "%"

	UIGradientFrameProgress.Transparency = LoadingModule.ReturnCooldownSequence(math.round(progress) / 100, 0)
end

local function StartLoading()
	-- Wait for the server to start ----------------------------------------------------------------------
	UpdateProgress("Waiting for server to load", currentProgress)
	repeat
		task.wait()
	until game.Workspace:GetAttribute("serverStarted")
	currentProgress += progressValues["serverLoaded"]
	UpdateProgress("Waiting for server to load", currentProgress)

	-- Waiting for knit to load ------------------------------------------------------------------------
	UpdateProgress("Loading scripts", currentProgress)
	repeat
		task.wait()
	until KnitLoaded.Value == true
	currentProgress += progressValues["knitLoaded"]
	UpdateProgress("Loading scripts", currentProgress)

	-- Wait for client data to load ---------------------------------------------------------------------
	UpdateProgress("Loading client data", currentProgress)
	local dataLoadedBoolValue = LocalPlayer:WaitForChild("DataLoaded")
	repeat
		task.wait()
	until dataLoadedBoolValue.Value

	currentProgress += progressValues["dataLoaded"]
	UpdateProgress("Loading client data", currentProgress)

	-- Waiting for guis to load ------------------------------------------------------------------------
	UpdateProgress("Loading GUIs", currentProgress)
	repeat
		task.wait()
	until GuisLoaded.Value == true
	currentProgress += progressValues["guisLoaded"]
	UpdateProgress("Loading Complete", currentProgress)

	loadingComplete = true
	LoadingComplete()
end
-- Running Functions ----------------------------------------------------------------------------------------------------------------------------

ScreenGuiLoading.Parent = PlayerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()
UIGradientFrameProgress.Transparency = LoadingModule.ReturnCooldownSequence(0, 0)

-- StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
-- Creating Connections -------------------------------------------------------------------------------------------------------------------------

-- Running Functions ----------------------------------------------------------------------------------------------------------------------------
task.spawn(AnimateLoadingTextLabel)
AnimateLogo()
StartLoading()

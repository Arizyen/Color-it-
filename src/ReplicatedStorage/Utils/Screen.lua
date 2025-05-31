local Screen = {}
-- Services
local RunService = game:GetService("RunService")
-- Folders

-- Modulescripts
local Math = require(script.Parent:WaitForChild("Math"))

-- KnitServices

-- Instances
local Mouse

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function GetMouse()
	if RunService:IsClient() then
		Mouse = game.Players.LocalPlayer:GetMouse()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Screen.GetScreenSize()
	if
		Screen.screenResolution and Screen.screenResolution.X ~= Mouse.ViewSizeX
		or Screen.screenResolution.Y ~= Mouse.ViewSizeY
	then
		Screen.screenResolution = Mouse and Mouse.ViewSizeX and Vector2.new(Mouse.ViewSizeX, Mouse.ViewSizeY)
			or Vector2.new(1280, 720)
	end

	return Screen.screenResolution
end

function Screen.GetCameraViewportSize()
	Screen.cameraViewportSize = game.Workspace.Camera and game.Workspace.Camera.ViewportSize or Vector2.new(1280, 720)

	return Screen.cameraViewportSize
end

function Screen.GetHardwareSafeAreaInsets()
	local playerGui = game.Players.LocalPlayer.PlayerGui
	assert(playerGui, "PlayerGui not found")

	local fullscreenGui = playerGui:FindFirstChild("_FullscreenTestGui")
	if not fullscreenGui then
		fullscreenGui = Instance.new("ScreenGui")
		fullscreenGui.Name = "_FullscreenTestGui"
		fullscreenGui.Parent = playerGui
		fullscreenGui.ScreenInsets = Enum.ScreenInsets.None
	end

	local deviceGui = playerGui:FindFirstChild("_DeviceTestGui")
	if not deviceGui then
		deviceGui = Instance.new("ScreenGui")
		deviceGui.Name = "_DeviceTestGui"
		deviceGui.Parent = playerGui
		deviceGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	end

	local tlInset = deviceGui.AbsolutePosition - fullscreenGui.AbsolutePosition
	local brInset = fullscreenGui.AbsolutePosition
		+ fullscreenGui.AbsoluteSize
		- (deviceGui.AbsolutePosition + deviceGui.AbsoluteSize)

	return { left = tlInset.X, top = tlInset.Y, right = brInset.X, bottom = brInset.Y }
end

function Screen.GetFrameAbsoluteSize(scaleX, scaleY, aspectRatio, cameraViewportSize): Vector2
	cameraViewportSize = cameraViewportSize or Screen.GetCameraViewportSize()

	aspectRatio = aspectRatio or 1

	local frameSize = Vector2.new(cameraViewportSize.X * scaleX, cameraViewportSize.Y * scaleY)
	local frameAspectRatio = frameSize.X / frameSize.Y

	if frameAspectRatio > aspectRatio then
		frameSize = Vector2.new(frameSize.Y * aspectRatio, frameSize.Y)
	elseif frameAspectRatio < aspectRatio then
		frameSize = Vector2.new(frameSize.X, frameSize.X / aspectRatio)
	end

	return frameSize
end

-- Returns frame size depending on screen size to account for the scroll bar size changing the smaller the resolution
function Screen.GetDynamicScrollingFrameSize(size)
	if Screen.cameraViewportSize.X >= 1280 then
		return size
	elseif Screen.cameraViewportSize.X <= 480 then
		return UDim2.fromScale(size.X.Scale * 0.94043, size.Y.Scale)
	else
		return UDim2.fromScale(
			Math.Lerp(size.X.Scale * 0.94043, size.X.Scale, Screen.cameraViewportSize.X / 1280),
			size.Y.Scale
		) -- 6% difference from large screen to small screen
	end
end

function Screen.GetMousePositionOnFrame(frame, x, y)
	local gui_X = frame.AbsolutePosition.X
	local gui_Y = frame.AbsolutePosition.Y
	local guiAbsoluteSizeX = frame.AbsoluteSize.X
	local guiAbsoluteSizeY = frame.AbsoluteSize.Y

	--print("MouseX: "..X.." | FrameAbsolutionXPosition: "..gui_X)
	local offset = Vector2.new(math.abs(x - gui_X), math.abs(y - gui_Y - 36))
	local offsetScalar = Vector2.new(offset.X / guiAbsoluteSizeX, offset.Y / guiAbsoluteSizeY)
	return UDim2.new(offsetScalar.X, 0, offsetScalar.Y, 0)
end

function Screen.GetMinimumViewportModelDistance(model, camera)
	local modelCF, modelSize

	if model:IsA("Model") then
		modelCF, modelSize = model:GetBoundingBox()
	elseif model:IsA("BasePart") then
		modelCF, modelSize = model.CFrame, model.Size
	else
		return 10
	end

	local rotInv = (modelCF - modelCF.p):inverse()
	modelCF = modelCF * rotInv
	modelSize = rotInv * modelSize
	modelSize = Vector3.new(math.abs(modelSize.X), math.abs(modelSize.Y), math.abs(modelSize.Z))

	local diagonal = 0
	local maxExtent = math.max(modelSize.X, modelSize.Y, modelSize.Z)
	local tan = math.tan(math.rad(camera.FieldOfView / 2))

	if maxExtent == modelSize.X then
		diagonal = math.sqrt(modelSize.Y * modelSize.Y + modelSize.Z * modelSize.Z) / 2
	elseif maxExtent == modelSize.Y then
		diagonal = math.sqrt(modelSize.X * modelSize.X + modelSize.Z * modelSize.Z) / 2
	else
		diagonal = math.sqrt(modelSize.X * modelSize.X + modelSize.Y * modelSize.Y) / 2
	end

	return (maxExtent / 2) / tan + diagonal
end
------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
GetMouse()

return Screen

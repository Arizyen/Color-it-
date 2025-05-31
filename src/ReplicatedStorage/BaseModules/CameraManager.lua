local CameraManager = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Folders
local Source = ReplicatedStorage:WaitForChild("Source")
local BaseKnitControllers = Source:WaitForChild("BaseControllers")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))
local CameraShaker = require(ReplicatedBaseModules:WaitForChild("CameraShaker"))
local BezierPaths = require(ReplicatedBaseModules:WaitForChild("BezierPaths"))

-- KnitControllers
local PlayerController = require(BaseKnitControllers:WaitForChild("PlayerController"))

-- Instances
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

-- Configs
local _CAMERA_DEFAULT_FIELD_OF_VIEW = 70
local CAMERA_OFFSET = CFrame.new(0, 1.2, -7.75)
local CAMERA_DEFAULT_OFFSET = CFrame.new(0, 3.5, 12.5)

local DEFAULT_CINEMATIC_SPEED = 3
local DEFAULT_EASING_STYLE = Enum.EasingStyle.Linear
local DEFAULT_EASING_DIRECTION = Enum.EasingDirection.Out

-- local START_CAMERA_CFRAME = CFrame.new(Vector3.new(-1188, 94, -1124), Vector3.new(-1302, 95, -1060))
local START_CAMERA_CFRAME = CFrame.new(Vector3.new(-1188, 89, -1136), Vector3.new(-1276, 81, -1089))

-- Variables
local cinematicEnabled = false
local cameraShaker

-- Tables
-- Functions ------------------------------------
local function Lerp(alpha, a, b)
	return a + (b - a) * alpha
end

local function ChangeCameraToScriptable(state, character)
	if state then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CameraSubject = nil
	else
		Camera.CameraType = Enum.CameraType.Track
		if character then
			Camera.CameraSubject = character:WaitForChild("Humanoid")
		else
			character = game.Players.LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					Camera.CameraSubject = humanoid
				end
			end
		end
	end
end

local function DisconnectAutoRotate()
	Utils.Connections.DisconnectKeyConnection(script, "autoRotateConnection")
end

local function DisconnectRenderStep()
	Utils.Connections.DisconnectKeyConnection(script, "renderSteppedConnection")
end

local function DisconnectCinematic()
	cinematicEnabled = false
	Utils.Connections.DisconnectKeyConnection(script, "cinematicConnection")
end

local function DisconnectConnections()
	Utils.Connections.DisconnectKeyConnections(script)
	DisconnectCinematic()
end

local function ResetCamera(speed, unfreeze)
	DisconnectConnections()

	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	character:WaitForChild("Humanoid", 10)

	if not character or not character:FindFirstChild("Humanoid") then
		return
	end

	Camera.FieldOfView = _CAMERA_DEFAULT_FIELD_OF_VIEW
	local primaryPart = character.PrimaryPart

	if type(speed) == "number" and speed > 0 then
		if primaryPart then
			ChangeCameraToScriptable(true)
			local startCFrame = game.Workspace.CurrentCamera.CFrame
			local startTime = os.clock()

			Utils.Connections.Add(
				"CameraManager",
				"cameraTween",
				RunService.Heartbeat:Connect(function(dt)
					if primaryPart then
						if (os.clock() - startTime) / speed > 1 then
							Utils.Connections.DisconnectKeyConnection("CameraManager", "cameraTween")
							ResetCamera(nil, unfreeze)
						end

						game.Workspace.CurrentCamera.CFrame = startCFrame:Lerp(
							CFrame.new(
								(primaryPart.CFrame:ToWorldSpace(CAMERA_DEFAULT_OFFSET)).Position,
								primaryPart.Position
							),
							TweenService:GetValue(
								(os.clock() - startTime) / speed,
								Enum.EasingStyle.Quad,
								Enum.EasingDirection.Out
							)
						)
					else
						Utils.Connections.DisconnectKeyConnection("CameraManager", "cameraTween")
						ResetCamera(nil, unfreeze)
					end
				end)
			)
		else
			ResetCamera(nil, unfreeze)
		end
	else
		ChangeCameraToScriptable(false, character)

		if character then
			local humRootPart = character:FindFirstChild("HumanoidRootPart")
			if humRootPart then
				local playerPosition = humRootPart.Position
				-- make the Camera follow the player
				Camera.CFrame = CFrame.new(
					(character.HumanoidRootPart.CFrame:ToWorldSpace(CAMERA_DEFAULT_OFFSET)).Position,
					playerPosition
				)
			end

			if unfreeze then
				PlayerController:Freeze(false)
			end
		end
	end
end

local function TweenCamera(cframe, speed)
	ChangeCameraToScriptable(true)
	Utils.Connections.Add(
		script,
		"cameraTween",
		Utils.Tween.Start(Camera, speed or 2, DEFAULT_EASING_STYLE, DEFAULT_EASING_DIRECTION, { CFrame = cframe })
	)
end
-------------------------------------------------
-- GLOBAL FUNCTIONS -----------------------------
-------------------------------------------------
CameraManager.ResetCamera = ResetCamera
CameraManager.ChangeCameraToScriptable = ChangeCameraToScriptable
CameraManager.DisconnectConnections = DisconnectConnections

function CameraManager.ChangeCameraToPlayer(player)
	if not player then
		return
	end
	CameraManager.DisconnectConnections()

	local character = player.Character or player.CharacterAdded:Wait()
	ChangeCameraToScriptable(false, character)
	local cameraCFrame = CFrame.new(
		(character.HumanoidRootPart.CFrame:ToWorldSpace(CAMERA_DEFAULT_OFFSET)).Position,
		character.Head.Position
	)
	Utils.Tween.Start(Camera, 1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { CFrame = cameraCFrame })
end

function CameraManager.ChangeCameraCFrame(cframe)
	if cframe and typeof(cframe) == "CFrame" then
		ChangeCameraToScriptable(true)
		Camera.CFrame = cframe
	else
		ChangeCameraToScriptable(false)
	end
end

function CameraManager.UpdateCameraFieldOfView(newFieldOfView)
	if newFieldOfView and type(newFieldOfView) == "number" then
		Camera.FieldOfView = newFieldOfView
	end
end

function CameraManager.ShowStartCamera(state, speed, unfreeze)
	if state then
		if speed then
			TweenCamera(START_CAMERA_CFRAME, speed)
		else
			ChangeCameraToScriptable(true)
			Camera.CFrame = START_CAMERA_CFRAME
		end
	else
		ResetCamera(speed, unfreeze)
	end
end

function CameraManager.ChangeCameraToObject(partToFocus, offSet, initialAngle)
	CameraManager.DisconnectConnections()

	ChangeCameraToScriptable(true)
	Camera.FieldOfView = _CAMERA_DEFAULT_FIELD_OF_VIEW

	Camera.CFrame = partToFocus.CFrame
		* CFrame.Angles(0, math.rad(180), 0)
		* CFrame.Angles(0, math.rad(initialAngle), 0)
		* offSet
end

-- Rotate camera around CFrame or model (must have primary part), speed is the time it takes to rotate 360 degrees
function CameraManager.RotateCamera(
	part: Part,
	offSet: number,
	offsetAngles: CFrame?,
	rotationsPerSecond: number?,
	rotationTimes: number?
)
	if (typeof(part) ~= "Instance" or not part:IsA("Part")) or (offsetAngles and typeof(offsetAngles) ~= "CFrame") then
		return
	end
	CameraManager.DisconnectConnections()

	offSet = offSet or 10
	offsetAngles = offsetAngles or CFrame.Angles(0, 0, 0)
	rotationsPerSecond = rotationsPerSecond or 0.25

	local startAngles = CFrame.Angles(part.CFrame:ToEulerAnglesXYZ())
	local angleDelta
	local currentAngle = 0
	local totalAngle = 0

	ChangeCameraToScriptable(true)
	Camera.FieldOfView = _CAMERA_DEFAULT_FIELD_OF_VIEW

	Utils.Connections.Add(
		script,
		"autoRotateConnection",
		RunService.Heartbeat:Connect(function(step)
			if not part.Parent then
				Utils.Connections.DisconnectKeyConnection(script, "autoRotateConnection")
				return
			end
			angleDelta = (360 * rotationsPerSecond * step)
			currentAngle += angleDelta

			if rotationTimes then
				totalAngle += angleDelta

				if totalAngle >= 360 * rotationTimes then
					Utils.Connections.DisconnectKeyConnection(script, "autoRotateConnection")
				end
			end

			Camera.CFrame = CFrame.new(part.Position.X, part.Position.Y, part.Position.Z)
				* startAngles
				* CFrame.Angles(0, math.rad(currentAngle + 180), 0)
				* offsetAngles
				* CFrame.new(0, 0, offSet)
		end)
	)
end

function CameraManager.FocusOnPart(partToFocus: Part, offSet: number, angle: number)
	if not partToFocus then
		return
	end
	CameraManager.DisconnectConnections()

	local centerCFrame = partToFocus.CFrame

	ChangeCameraToScriptable(true)
	Camera.FieldOfView = _CAMERA_DEFAULT_FIELD_OF_VIEW

	Camera.CFrame = centerCFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, -offSet)
end

function CameraManager.ChangeCameraSubject(cameraSubject)
	if not cameraSubject then
		return false
	end
	CameraManager.DisconnectConnections()
	Camera.CameraType = Enum.CameraType.Track
	Camera.CameraSubject = cameraSubject
end

function CameraManager.FixCameraOnCharacter(cameraOffset)
	if not cameraOffset then
		return
	end
	CameraManager.DisconnectConnections()

	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = nil
	local playerPosition = nil
	local cameraPosition = nil

	ChangeCameraToScriptable(true)

	Utils.Connections.Add(
		script,
		"renderSteppedConnection",
		RunService.RenderStepped:Connect(function()
			if character and character.PrimaryPart then
				humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					playerPosition = character.PrimaryPart.Position
					cameraPosition = playerPosition + cameraOffset

					-- make the Camera follow the player
					Camera.CFrame = CFrame.new(cameraPosition, playerPosition)
				end
			else
				CameraManager.ResetCamera()
			end
		end)
	)

	return true
end

function CameraManager.BlurCamera(state, speed)
	if state then
		if not Camera:FindFirstChild("BlurEffect") then
			local blur = Instance.new("BlurEffect")
			blur.Name = "BlurEffect"
			blur.Size = 0
			blur.Parent = Camera
		end
		Utils.Tween.Start(
			Camera:FindFirstChild("BlurEffect"),
			speed or 1,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			{ Size = 10 }
		)
	else
		if Camera:FindFirstChild("BlurEffect") then
			if speed then
				Utils.Tween.Start(
					Camera:FindFirstChild("BlurEffect"),
					speed or 1,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					{ Size = 0 }
				)
			else
				Camera:FindFirstChild("BlurEffect"):Destroy()
			end
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAMERA SHAKER FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
function CameraManager.ReturnCameraShakeInstance(
	magnitude: number,
	roughness: number,
	fadeInTime: number,
	fadeOutTime: number,
	positionInfluence: Vector3,
	rotationInfluence: Vector3
)
	local cameraShakeInstance = CameraShaker.CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)

	cameraShakeInstance.PositionInfluence = positionInfluence or Vector3.new(0.15, 0.15, 0.15)
	cameraShakeInstance.RotationInfluence = rotationInfluence or Vector3.new(1, 1, 1)

	return cameraShakeInstance
end

function CameraManager.StartCameraShake(presetName, sustain, cameraShakeInstance)
	if cameraShaker then
		cameraShaker:Stop()
	end

	cameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)
	cameraShaker:Start()

	if type(cameraShakeInstance) == "number" and presetName then
		print("Creating new camera shake instance")
		local factor = cameraShakeInstance
		cameraShakeInstance = CameraShaker.Presets[presetName] or CameraShaker.Presets["Explosion"]

		if type(cameraShakeInstance) == "table" then
			cameraShakeInstance = CameraManager.ReturnCameraShakeInstance(
				cameraShakeInstance.Magnitude * factor,
				cameraShakeInstance.Roughness * factor,
				cameraShakeInstance.FadeInTime * factor,
				cameraShakeInstance.FadeOutTime * factor,
				cameraShakeInstance.PositionInfluence * factor,
				cameraShakeInstance.RotationInfluence * factor
			)
		end
	end

	if sustain then
		if presetName then
			cameraShaker:ShakeSustain(CameraShaker.Presets[presetName] or CameraShaker.Presets["HandheldCamera"])
		elseif cameraShakeInstance then
			cameraShaker:ShakeSustain(cameraShakeInstance)
		end
	else
		if presetName then
			cameraShaker:Shake(CameraShaker.Presets[presetName] or CameraShaker.Presets["Explosion"])
		else
			cameraShaker:Shake(cameraShakeInstance)
		end
	end
end

function CameraManager.StopCameraShake(fadeOutTime)
	if not cameraShaker then
		return
	end

	if type(fadeOutTime) == "number" and fadeOutTime > 0 then
		cameraShaker:StopSustained(fadeOutTime)
	else
		cameraShaker:Stop()
	end
end
--------------------------------------------------------------
-- FUNCTIONS FOR CINEMATIC ----------------------------------
--------------------------------------------------------------
CameraManager.DisconnectCinematic = DisconnectCinematic

function CameraManager.StartCinematic(cinematicInfo, isLooped, totalTime)
	if not cinematicInfo or typeof(cinematicInfo) ~= "table" then
		return
	end
	if #cinematicInfo < 1 then
		return
	end

	ChangeCameraToScriptable(true)

	cinematicEnabled = true -- Changing this variable and disconnecting the connection would stop cinematics

	task.spawn(function()
		repeat
			if #cinematicInfo == 1 then
				-- Use tween
				for _, eachCinematicInfo in ipairs(cinematicInfo) do
					if not cinematicEnabled then
						return
					end
					if not eachCinematicInfo.CFrame then
						continue
					end

					local tween = Utils.Connections.Add(
						script,
						"cinematicConnection",
						Utils.Tween.Start(
							Camera,
							eachCinematicInfo.Speed or DEFAULT_CINEMATIC_SPEED,
							eachCinematicInfo.EasingStyle or DEFAULT_EASING_STYLE,
							eachCinematicInfo.EasingDirection or DEFAULT_EASING_DIRECTION,
							{ CFrame = eachCinematicInfo.CFrame }
						)
					)
					tween.Completed:Wait()
				end

				Utils.Connections.DisconnectKeyConnection(script, "cinematicConnection")
			else
				-- Interpolate between the CFrames
				local positions, lookVectors = {}, {}
				for _, eachCinematicInfo in ipairs(cinematicInfo) do
					table.insert(positions, eachCinematicInfo.CFrame.Position)
					table.insert(lookVectors, eachCinematicInfo.CFrame.LookVector)
				end

				local positionsBezierPath = BezierPaths.new(positions)
				local lookVectorsBezierPath = BezierPaths.new(lookVectors)

				local cinematicDone = false
				local startTime = os.clock()
				local alpha, piAlpha, positionLerp, pathNumber, percent, lookVectorLerp
				Utils.Connections.Add(
					script,
					"cinematicConnection",
					RunService.Heartbeat:Connect(function()
						alpha = (os.clock() - startTime) / totalTime
						piAlpha = isLooped and alpha or (1 + math.sin(Lerp(alpha, -math.pi / 2, math.pi / 2))) / 2 -- Get alpha of -pi/2 to pi/2, then get the sin value which returns from -1,1 and calculate its distance between -1,1 to get an lpha based on sinus

						alpha = alpha <= 1 and alpha or 1

						positionLerp, pathNumber, percent = positionsBezierPath:GetValue(piAlpha, true)
						lookVectorLerp = lookVectorsBezierPath:GetValueOfPath(pathNumber, percent)

						Camera.CFrame = CFrame.new(positionLerp, positionLerp + lookVectorLerp)

						if alpha >= 1 then
							cinematicDone = true
							Utils.Connections.DisconnectKeyConnection(script, "cinematicConnection")
						end
					end)
				)

				repeat
					task.wait()
				until cinematicDone
			end
		until not cinematicEnabled or not isLooped
	end)
end

function CameraManager.PartsCinematic(partsFolder, isLooped, easingStyle, easingDirection, totalTime, randomIndexStart)
	if not partsFolder then
		return
	end
	local cinematicInfo = {}

	local allParts = partsFolder:GetChildren()
	if #allParts < 1 then
		return
	end

	local speed = totalTime ~= nil and totalTime / #allParts or DEFAULT_CINEMATIC_SPEED
	easingStyle = easingStyle or DEFAULT_EASING_STYLE
	easingDirection = easingDirection or DEFAULT_EASING_DIRECTION

	if randomIndexStart then
		local randomIndex = math.random(1, #allParts)

		repeat
			local part = partsFolder:FindFirstChild(randomIndex)
			if not part or not part:IsA("BasePart") then
				continue
			end

			if not part.Parent then
				CameraManager.DisconnectCinematic()
				return
			end

			local newCinematic = {
				["CFrame"] = part.CFrame,
				EasingStyle = easingStyle,
				EasingDirection = easingDirection,
				Speed = speed,
			}

			table.insert(cinematicInfo, newCinematic)

			randomIndex += 1
			if randomIndex > #allParts then
				randomIndex = 1
			end
		until #cinematicInfo == #allParts
	else
		for i = 1, #allParts do
			local part = partsFolder:FindFirstChild(i)
			if not part or not part:IsA("BasePart") then
				continue
			end

			if not part.Parent then
				CameraManager.DisconnectCinematic()
				return
			end

			local newCinematic = {
				["CFrame"] = part.CFrame,
				EasingStyle = easingStyle,
				EasingDirection = easingDirection,
				Speed = speed,
			}

			table.insert(cinematicInfo, newCinematic)
		end
	end

	if #cinematicInfo > 0 then
		if isLooped then
			table.insert(cinematicInfo, cinematicInfo[1])
		end

		CameraManager.StartCinematic(cinematicInfo, isLooped, totalTime)
	end
end

return CameraManager

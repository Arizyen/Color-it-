local Waypoint = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
-- local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
-- local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers

-- Instances
local LocalPlayer = game.Players.LocalPlayer

-- Configs
local _BEAM_PROPERTIES = {
	Brightness = 1,
	Color = Color3.fromRGB(255, 215, 0),
	LightEmission = 0.5,
	LightInfluence = 0.5,
	-- Texture = "rbxassetid://7985456681",
	Texture = "rbxassetid://11774607913",
	TextureLength = 1,
	TextureMode = Enum.TextureMode.Static,
	TextureSpeed = 1.5,
	Transparency = 0,
	FaceCamera = true,
	Segments = 1,
	Width0 = 3,
	Width1 = 1,
}

-- Variables
local beam
local currentWaypointKey
local currentWaypointPart
local distanceCheckConnection

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function StartDistanceCheck()
	if not currentWaypointPart or not currentWaypointKey or distanceCheckConnection then
		return
	end

	local character = LocalPlayer.Character
	local int = 0
	distanceCheckConnection = game:GetService("RunService").Heartbeat:Connect(function()
		int += 1
		if int % 5 == 0 then
			int = 0

			if not character or not character.PrimaryPart or not currentWaypointPart then
				Waypoint.Deactivate(currentWaypointKey)
				return
			end

			if (currentWaypointPart.Position - character.PrimaryPart.Position).Magnitude <= 15 then
				Waypoint.Deactivate(currentWaypointKey)
				-- Utils.Signals.Fire("waypointReached", currentWaypointKey)
			end
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
function Waypoint.Activate(waypointPart, key, beamProperties)
	Waypoint.Deactivate(currentWaypointKey)

	currentWaypointPart = waypointPart
	currentWaypointKey = key

	local character = game.Players.LocalPlayer.Character
	if not currentWaypointPart or not character or not character.PrimaryPart then
		return
	end

	beam = Utils.Beam.Create(
		character.PrimaryPart,
		currentWaypointPart,
		type(beamProperties) == "table" and Utils.Table.Merge(beamProperties, _BEAM_PROPERTIES) or _BEAM_PROPERTIES
	)

	StartDistanceCheck()
end

function Waypoint.Deactivate(key, ignoreKey)
	-- Disconnect connection and destroy beam
	if not beam or (not ignoreKey and currentWaypointKey ~= key) then
		return
	end

	-- Disconnect connection
	if distanceCheckConnection then
		distanceCheckConnection:Disconnect()
		distanceCheckConnection = nil
	end

	local attachments = { "Attachment0", "Attachment1" }

	-- Destroy attachments
	for _, eachAttachment in pairs(attachments) do
		if beam[eachAttachment] then
			beam[eachAttachment]:Destroy()
		end
	end

	-- Destroy beam
	beam:Destroy()
	beam = nil

	currentWaypointPart = nil
	currentWaypointKey = nil
end
-- CONNECTIONS -----------------------------------------------------------------------------------------------------------------------------------
Utils.Signals.Connect("characterAppearanceLoaded", function()
	if not currentWaypointPart or not currentWaypointKey then
		return
	end

	Waypoint.Activate(currentWaypointPart, currentWaypointKey)
end)

return Waypoint

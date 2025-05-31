local Tween = {}

local TweenService = game:GetService("TweenService")
local tweens = {} :: { [Instance]: Tween }
local instanceConnections = {} :: { [Instance]: RBXScriptConnection }
-- FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
local function DisconnectInstanceConnection(object)
	if instanceConnections[object] then
		instanceConnections[object]:Disconnect()
		instanceConnections[object] = nil
	end
end

local function CancelTween(object)
	if tweens[object] then
		if tweens[object].PlaybackState ~= Enum.PlaybackState.Completed then
			tweens[object]:Cancel()
		end
		tweens[object] = nil
	end
end
-- GLOBAL FUNCTIONS ----------------------------------------------------------------------------------------------------
function Tween.Start(
	object: Instance,
	speed: number,
	easingStyle: Enum,
	easingDirection: Enum,
	properties: table,
	repeatCount: number?,
	reverses: boolean?,
	delay: number?
)
	if not object or typeof(object) ~= "Instance" then
		warn("Invalid object provided to Tween.Start")
		return
	end

	-- Create the tween
	local info = TweenInfo.new(speed, easingStyle, easingDirection, repeatCount or 0, reverses or false, delay or 0)
	local tween = TweenService:Create(object, info, properties)
	tweens[object] = tween

	-- Create a connection to remove the tween when the object is destroyed
	instanceConnections[object] = object.AncestryChanged:Connect(function()
		if not object.Parent then
			Tween.Cancel(object)
		end
	end)

	-- Remove the tween from the table when it's done
	tween.Completed:Connect(function()
		-- Cancelling a tween will re-trigger the Completed event (the Completed event is fired before the state is set to Completed)
		tweens[object] = nil
		DisconnectInstanceConnection(object)
	end)

	tween:Play()
	return tween
end

function Tween.Cancel(object)
	CancelTween(object)
	DisconnectInstanceConnection(object)
end

function Tween.IsTweening(object)
	return tweens[object] ~= nil
end

return Tween

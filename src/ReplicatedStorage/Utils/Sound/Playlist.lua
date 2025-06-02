local Playlist = {}
Playlist.__index = Playlist

-- Services ------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local ReplicatedSource = ReplicatedStorage:WaitForChild("Source")

-- Modulescripts -------------------------------------------------------------------
local TableUtils = require(ReplicatedSource:WaitForChild("Utils"):WaitForChild("Table"))
local Connections = require(ReplicatedSource:WaitForChild("Utils"):WaitForChild("Connections"))
local Playback = require(script.Parent:WaitForChild("Playback"))

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Infos ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CORE METHODS --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Playlist.new(soundInfos: { { [string]: any } }, parent: string): typeof(Playlist)
	assert(typeof(soundInfos) == "table", "Playlist requires an array of soundInfos")

	local self = setmetatable({}, Playlist)

	-- Booleans
	self._destroyed = false
	self._playing = false

	-- Numbers
	self._currentIndex = 0

	-- Tables
	self._soundInfos = table.clone(soundInfos)

	-- Instances
	self._currentSound = nil
	self._parent = parent

	self:_Init()

	return self
end

function Playlist:_Init()
	TableUtils.ShuffleList(self._soundInfos)
	self:Update()
end

function Playlist:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	Connections.DisconnectKeyConnections(self)
end

function Playlist:Update() end

------------------------------------------------------------------------------------------------------------------------
-- CLASS METHODS -------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Playlist:_PlayNext()
	if self._destroyed or not self._playing or #self._soundInfos == 0 then
		return
	end

	-- Increment the index and wrap around if necessary
	self._currentIndex = (self._currentIndex % #self._soundInfos) + 1
	local soundInfo = self._soundInfos[self._currentIndex]

	self._currentSound = Playback.Play(soundInfo, self._parent)

	-- Chain to the next sound when the current one ends
	if self._currentSound then
		Connections.Add(
			self,
			"SoundEnded",
			self._currentSound.Ended:Once(function()
				self._currentSound = nil
				self:_PlayNext()
			end)
		)
	end
end

function Playlist:Start()
	if self._destroyed or self._playing then
		return
	end

	self._playing = true
	self:_PlayNext()
end

function Playlist:Stop()
	if self._destroyed or not self._playing then
		return
	end

	self._playing = false
	Connections.DisconnectKeyConnection(self, "SoundEnded")

	if self._currentSound then
		Playback.Stop(self._currentSound)
		self._currentSound = nil
	end
end

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Playlist

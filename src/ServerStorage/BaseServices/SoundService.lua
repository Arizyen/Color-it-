-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local Packages = ReplicatedStorage.Packages
local BaseModules = ServerStorage.Source.BaseModules
local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
local BaseServices = ServerStorage.Source.BaseServices
-- Modulescripts
local Knit = require(Packages.Knit)
-- KnitServices
local SoundService = Knit.CreateService({
	Name = "Sound",
	Client = { PlaySound = Knit.CreateSignal(), PlaySoundOnPart = Knit.CreateSignal() },
})
-- Instances

-- Configs

-- Variables

-- Tables

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function SoundService:KnitInit() end

function SoundService:KnitStart() end
-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------
function SoundService:PlaySound(player, soundInfo, stopLastSounds, unloadSoundAtEnd)
	if type(player) == "userdata" and player:IsA("Player") then
		self.Client.PlaySound:Fire(player, soundInfo, stopLastSounds, unloadSoundAtEnd)
	elseif type(player) == "table" then
		self.Client.PlaySound:FireFor(player, soundInfo, stopLastSounds, unloadSoundAtEnd)
	end
end

function SoundService:PlaySoundOnPart(player, soundInfo, part, stopLastSounds, unloadSoundAtEnd)
	if type(player) == "userdata" and player:IsA("Player") then
		self.Client.PlaySoundOnPart:Fire(player, soundInfo, part, stopLastSounds, unloadSoundAtEnd)
	elseif type(player) == "table" then
		self.Client.PlaySoundOnPart:FireFor(player, soundInfo, part, stopLastSounds, unloadSoundAtEnd)
	end
end
-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------------

return SoundService

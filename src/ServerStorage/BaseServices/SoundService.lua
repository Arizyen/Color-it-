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
	Client = { Play = Knit.CreateSignal(), PlayOnPart = Knit.CreateSignal() },
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
function SoundService:Play(player, soundInfo, parent, unload)
	if type(player) == "userdata" and player:IsA("Player") then
		self.Client.Play:Fire(player, soundInfo, parent, unload)
	elseif type(player) == "table" then
		self.Client.Play:FireFor(player, soundInfo, parent, unload)
	end
end

-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------------

return SoundService

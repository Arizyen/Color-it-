-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local ReplicatedBaseModules = Source:WaitForChild("BaseModules")

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
local Utils = require(Source:WaitForChild("Utils"))

-- KnitControllers
local SoundController = Knit.CreateController({
	Name = "Sound",
})

-- Instances

-- Configs

-- Variables

-- Tables
local knitServices = {}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function SoundController:KnitInit()
	knitServices["Sound"] = Knit.GetService("Sound")
end

function SoundController:KnitStart()
	knitServices["Sound"].Play:Connect(Utils.Sound.Play)
end

-- COMPONENT FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------

-- CLIENT - SERVER FUNCTIONS ------------------------------------------------------------------------------------------------------------------------

return SoundController

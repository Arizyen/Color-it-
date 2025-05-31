local CoreGuiManager = {}
-- Services
-- local ServerStorage = game:GetService("ServerStorage")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Folders
-- local BaseModules = ServerStorage.Source.BaseModules
-- local ReplicatedBaseModules = ReplicatedStorage.Source.BaseModules
-- local Packages = ReplicatedStorage.Packages
-- local BaseServices = ServerStorage.Source.BaseServices

-- Modulescripts

-- KnitServices

-- Instances

-- Configs

-- Variables

-- Tables
local gameStatus = {
	mapLoading = nil,
	gameLoading = true,
	appEnabled = nil,
	hideWindows = nil,
	hideSideGuis = nil,
	windowShown = nil,
}

local coreGuisCurrentState = {
	Chat = nil,
	PlayerList = nil,
} -- states set by the game
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Prevents a core gui to enable if it was disable in the first place (Without using this function)
function CoreGuiManager.SetCoreGuiEnabled(coreGuiType: string, state: boolean)
	if coreGuisCurrentState[coreGuiType] == state then
		return
	end
	coreGuisCurrentState[coreGuiType] = state

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[coreGuiType], state)
end

function CoreGuiManager.UpdateGameState(stateTable)
	for eachProperty, eachState in pairs(stateTable) do
		gameStatus[eachProperty] = eachState
	end

	if gameStatus.hideWindows then
		-- CoreGuiManager.SetCoreGuiEnabled("PlayerList", false)
	elseif gameStatus.gameLoading or not gameStatus.appEnabled then
		-- CoreGuiManager.SetCoreGuiEnabled("PlayerList", false)
		CoreGuiManager.SetCoreGuiEnabled("Chat", false)
	else
		-- Only show if windowShown is nil (when a window is shown, it will hide the player list if size.X.Scale is higher than 0.5)
		CoreGuiManager.SetCoreGuiEnabled("Chat", true)

		-- if not gameStatus.windowShown then
		-- CoreGuiManager.SetCoreGuiEnabled("PlayerList", true)
		-- 	CoreGuiManager.SetCoreGuiEnabled("Chat", true)
		-- end
	end
end

return CoreGuiManager

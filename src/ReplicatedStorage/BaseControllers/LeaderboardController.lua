-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicatedBaseModules = Source:WaitForChild("BaseModules")
local ReplicatedLeaderboards = ReplicatedStorage:WaitForChild("Leaderboards")
local LeaderboardDisplay

-- Modulescripts
local Knit = require(Packages:WaitForChild("Knit"))
local Utils = require(Source:WaitForChild("Utils"))
local Animation = require(ReplicatedBaseModules:WaitForChild("Animation"))

-- KnitControllers
local LeaderboardController = Knit.CreateController({
	Name = "Leaderboard",
})

-- Instances

-- Configs

-- Variables
local leaderboardShown = false
local animationIndex = 0

-- Tables
local knitServices = {}
local currentLeaderboardsRankings = {}
local leaderboardsModels = {}
local changingLeaderboard = {}
local danceAnimationIds = {
	"rbxassetid://14476807912",
	"rbxassetid://14476824842",
	"rbxassetid://14476828423",
	"rbxassetid://14476834836",
	"rbxassetid://14476837438",
	"rbxassetid://14476840235",
	"rbxassetid://14476842965",
	"rbxassetid://14476846403",
	"rbxassetid://14476849457",
	"rbxassetid://14476853474",
	"rbxassetid://14476856728",
	"rbxassetid://14476862700",
	"rbxassetid://14476866974",
	"rbxassetid://14476870161",
	"rbxassetid://14476873057",
	"rbxassetid://14476876218",
	"rbxassetid://14476879937",
	"rbxassetid://14476883564",
	"rbxassetid://14476887453",
	"rbxassetid://14476891513",
	"rbxassetid://14476895352",
	"rbxassetid://14476903508",
	"rbxassetid://14476907467",
	"rbxassetid://14476910792",
	"rbxassetid://14476917008",
	"rbxassetid://14476921718",
	"rbxassetid://14476926112",
	"rbxassetid://14476930167",
	"rbxassetid://14476934441",
	"rbxassetid://14476938157",
	"rbxassetid://14476942829",
	"rbxassetid://14476946935",
	"rbxassetid://14476962206",
	"rbxassetid://14476966745",
	"rbxassetid://14476971402",
	"rbxassetid://14476982069",
	"rbxassetid://14476986989",
	"rbxassetid://14476993389",
}
---------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
local function PlaceDummyOnStand(model, leaderboard, rank)
	if not model or not model.Parent or not leaderboard or not rank then
		return
	end

	local stand = leaderboard:WaitForChild("Podium"):WaitForChild(rank)
	Utils.Teleport.Dummy(model, {
		part = stand.PrimaryPart,
	})
	model.Parent = stand

	return true
end

local function ReturnRandomAnimationId()
	animationIndex += 1

	if #danceAnimationIds >= animationIndex then
		return danceAnimationIds[animationIndex]
	else
		animationIndex = 1
		return danceAnimationIds[animationIndex]
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS -------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- KNIT FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
function LeaderboardController:KnitInit()
	knitServices["Leaderboard"] = Knit.GetService("Leaderboard")
end

function LeaderboardController:KnitStart()
	-- Create connections
	knitServices["Leaderboard"].UpdateLeaderboardKeyData:Connect(function(key, data)
		Utils.Signals.Fire("DispatchAction", {
			type = "UpdateLeaderboardKeyData",
			key = key,
			data = data,
		})
	end)
	knitServices["Leaderboard"].SetLeaderboardWeekUpdateTime:Connect(function(newTime)
		Utils.Signals.Fire("DispatchAction", {
			type = "SetLeaderboardWeekUpdateTime",
			value = newTime,
		})
	end)
	knitServices["Leaderboard"].SetLeaderboardUpdateTime:Connect(function(newTime)
		Utils.Signals.Fire("DispatchAction", {
			type = "SetLeaderboardUpdateTime",
			value = newTime,
		})
	end)

	-- Initialize values
	knitServices["Leaderboard"]:ReturnLeaderboardsData():andThen(function(data)
		for eachKey, eachData in pairs(data) do
			Utils.Signals.Fire("DispatchAction", {
				type = "UpdateLeaderboardKeyData",
				key = eachKey,
				data = eachData,
			})
		end
	end)
	knitServices["Leaderboard"]:ReturnWeekUpdateTime():andThen(function(newTime)
		Utils.Signals.Fire("DispatchAction", {
			type = "SetLeaderboardWeekUpdateTime",
			value = newTime,
		})
	end)
	knitServices["Leaderboard"]:ReturnUpdateTime():andThen(function(newTime)
		Utils.Signals.Fire("DispatchAction", {
			type = "SetLeaderboardUpdateTime",
			value = newTime,
		})
	end)
end
-- MODULE FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- Disconnect all connections and destroy all animators then parent LeaderboardDisplay in ReplicatedStorage
function LeaderboardController:HideLeaderboard()
	if not leaderboardShown then
		return
	end
	leaderboardShown = false

	Utils.Connections.DisconnectKeyConnections("LeaderboardController")

	-- Stop animations and place the dummy back in its respective location
	task.spawn(function()
		for _, eachLeaderboardName in pairs(leaderboardsModels) do
			for _, eachRanking in pairs(eachLeaderboardName) do
				for _, eachModel in pairs(eachRanking) do
					Animation.StopAnimations(eachModel)

					if
						eachModel.Parent
						and eachModel:GetAttribute("leaderboardName")
						and ReplicatedLeaderboards:FindFirstChild(eachModel:GetAttribute("leaderboardName"))
					then
						eachModel.Parent =
							ReplicatedLeaderboards:FindFirstChild(eachModel:GetAttribute("leaderboardName"))
					end
				end
			end
		end
	end)
end

-- Create connections and parent LeaderboardDisplay in game.Workspace
function LeaderboardController:ShowLeaderboard(leaderboardFolder, leaderboardName, ranking)
	if not leaderboardFolder then
		return
	end

	if leaderboardShown then
		self:HideLeaderboard()
	end
	leaderboardShown = true

	LeaderboardDisplay = leaderboardFolder

	-- DynamicLoader.Load(LeaderboardDisplay, game.Workspace, 35, 4)

	task.spawn(function()
		-- Show allTime rankings by default
		self:UpdateLeaderboard(leaderboardName, ranking or "allTime")

		-- Get leaderboards dummies
		if ReplicatedLeaderboards:FindFirstChild(leaderboardName) then
			-- Add dummies in respective leaderboards
			for _, eachChild in pairs(ReplicatedLeaderboards[leaderboardName]:GetChildren()) do
				self:UpdateLeaderboardModel(leaderboardName, eachChild)
			end
			-- Create dummy added connection for leaderboards
			Utils.Connections.Add(
				"LeaderboardController",
				leaderboardName .. "Updated",
				ReplicatedLeaderboards[leaderboardName].ChildAdded:Connect(function(child)
					if not child:IsA("Model") then
						return
					end

					task.wait() -- Changing the parent of the child instantly will cause a bug
					self:UpdateLeaderboardModel(leaderboardName, child)
				end)
			)
		end
	end)
end

function LeaderboardController:UpdateLeaderboardModel(leaderboardName, model)
	if not leaderboardName or not model then
		return
	end

	local ranking = model:GetAttribute("allTimeRanking") and "allTime" or "weekly"
	local rank = model:GetAttribute("rank")

	if not leaderboardsModels[leaderboardName] then
		leaderboardsModels[leaderboardName] = {}
	end

	if not leaderboardsModels[leaderboardName][ranking] then
		leaderboardsModels[leaderboardName][ranking] = {}
	end

	-- Delete saved model if the name is not the same or it's a descendant of LeaderboardDisplay
	if
		leaderboardsModels[leaderboardName][ranking][rank]
		and (
			leaderboardsModels[leaderboardName][ranking][rank].Name ~= model.Name
			or leaderboardsModels[leaderboardName][ranking][rank]:IsDescendantOf(LeaderboardDisplay)
		)
	then
		Animation.StopAnimations(leaderboardsModels[leaderboardName][ranking][rank])
		leaderboardsModels[leaderboardName][ranking][rank]:Destroy()
	end

	leaderboardsModels[leaderboardName][ranking][rank] = model

	-- If leaderboard is shown then place the dummy on the stand and animate it
	if leaderboardShown and currentLeaderboardsRankings[leaderboardName] == ranking then
		if PlaceDummyOnStand(model, LeaderboardDisplay, rank) then
			-- Random animate model
			Animation.PlayAnimation(
				model,
				ReturnRandomAnimationId(),
				{ Looped = true, Priority = Enum.AnimationPriority.Action }
			)
		end
	end
end

-- Will show leaderboard with desired ranking
function LeaderboardController:UpdateLeaderboard(leaderboardName, ranking)
	if changingLeaderboard[leaderboardName] or not LeaderboardDisplay then
		-- print("Cannot update leaderboard", leaderboardName, changingLeaderboard[leaderboardName])
		return
	end

	currentLeaderboardsRankings[leaderboardName] = ranking
	changingLeaderboard[leaderboardName] = true

	-- Hide the models of opposite ranking if present
	if
		leaderboardsModels[leaderboardName]
		and leaderboardsModels[leaderboardName][ranking == "allTime" and "weekly" or "allTime"]
	then
		for i = 1, 3 do
			if
				leaderboardsModels[leaderboardName][ranking == "allTime" and "weekly" or "allTime"][i]
				and leaderboardsModels[leaderboardName][ranking == "allTime" and "weekly" or "allTime"][i].Parent
			then
				Animation.StopAnimations(
					leaderboardsModels[leaderboardName][ranking == "allTime" and "weekly" or "allTime"][i]
				)
				leaderboardsModels[leaderboardName][ranking == "allTime" and "weekly" or "allTime"][i].Parent =
					ReplicatedStorage
			end
		end
	end
	-- Show the models of ranking
	if leaderboardsModels[leaderboardName] and leaderboardsModels[leaderboardName][ranking] then
		for i = 1, 3 do
			if
				leaderboardsModels[leaderboardName][ranking][i]
				and not leaderboardsModels[leaderboardName][ranking][i]:IsDescendantOf(LeaderboardDisplay)
			then
				if PlaceDummyOnStand(leaderboardsModels[leaderboardName][ranking][i], LeaderboardDisplay, i) then
					-- Random animate model
					Animation.PlayAnimation(
						leaderboardsModels[leaderboardName][ranking][i],
						ReturnRandomAnimationId(),
						{ Looped = true, Priority = Enum.AnimationPriority.Action }
					)
				end
			end
		end
	end

	Utils.Signals.Fire("DispatchAction", {
		type = "SetCurrentLeaderboardRankingShown",
		key = leaderboardName,
		value = ranking,
	})

	changingLeaderboard[leaderboardName] = false
end

return LeaderboardController

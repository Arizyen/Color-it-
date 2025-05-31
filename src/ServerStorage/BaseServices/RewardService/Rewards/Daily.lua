local Daily = {}
local Rewards = require(script.Parent)
setmetatable(Daily, { __index = Rewards })

-- Services ------------------------------------------------------------------------

-- Folders -------------------------------------------------------------------------

-- Modulescripts -------------------------------------------------------------------

-- KnitServices --------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- GLOBAL METHODS ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Daily:Award(player, dayNumber)
	if type(player) ~= "userdata" or type(dayNumber) ~= "number" or dayNumber > 7 then
		return false
	end

	local dayStreak = self.PlayersDataService:GetKeyValue(player, "dayStreak")
	local dailyRewardsTimeClaimed = self.PlayersDataService:GetKeyValue(player, "dailyRewardsTimeClaimed")

	-- Check if player already claimed the daily reward
	if dayNumber <= dayStreak or dailyRewardsTimeClaimed["day" .. dayNumber] then
		self.MessageService:SendMessageToPlayer(player, "You have already claimed this reward!", "Error")
		return false
	end

	-- Check if player is claiming invalid daily reward (dayNumber must be dayStreak + 1)
	if dayNumber > dayStreak + 1 then
		if dailyRewardsTimeClaimed["day" .. dayNumber - 1] then
			self.MessageService:SendMessageToPlayer(
				player,
				string.format(
					"You must wait %s before claiming this reward!",
					self.Utils.Time.Format(
						self.DailyRewardsConfigs._MIN_WAIT_TIME
							- (os.time() - dailyRewardsTimeClaimed["day" .. dayNumber - 1])
					)
				),
				"Error"
			)
		else
			self.MessageService:SendMessageToPlayer(player, "You cannot claim this reward yet!", "Error")
		end

		return false
	end

	-- Claim daily reward if within time frame
	if
		not dailyRewardsTimeClaimed["day" .. dayNumber - 1]
		or (
			os.time() - dailyRewardsTimeClaimed["day" .. dayNumber - 1] >= self.DailyRewardsConfigs._MIN_WAIT_TIME
			and os.time() - dailyRewardsTimeClaimed["day" .. dayNumber - 1]
				<= self.DailyRewardsConfigs._MAX_WAIT_TIME
		)
	then
		if self:GivePlayerDayReward(player, dayNumber) then
			if dayNumber < 7 then
				self.PlayersDataService:SetKeyValue(player, "dayStreak", dayNumber)
				self.PlayersDataService:SetKeyIndexValue(
					player,
					"dailyRewardsTimeClaimed",
					"day" .. dayNumber,
					os.time(),
					true
				)

				self.MessageService:SendMessageToPlayer(
					player,
					string.format(
						"You have claimed your day %s reward! Come back tomorrow to claim your next reward!",
						tostring(dayNumber)
					),
					"RewardClaimed"
				)
			else
				self.PlayersDataService:SetKeyValue(player, "dayStreak", 0)
				self.PlayersDataService:SetKeyValue(player, "dailyRewardsTimeClaimed", { day0 = os.time() })
			end

			return true
		else
			self.MessageService:SendMessageToPlayer(
				player,
				"Error claiming daily reward: could not save data. Please try again later.",
				"Error"
			)

			return false
		end
	else
		if dailyRewardsTimeClaimed["day" .. dayNumber - 1] then
			self.MessageService:SendMessageToPlayer(
				player,
				string.format(
					"You must wait %s before claiming this reward!",
					self.Utils.Time.Format(
						self.DailyRewardsConfigs._MIN_WAIT_TIME
							- (os.time() - dailyRewardsTimeClaimed["day" .. dayNumber - 1])
					)
				),
				"Error"
			)
		end

		return false
	end
end

function Daily:GivePlayerDayReward(player, dayNumber): boolean
	if not self.DailyRewardsInfos[dayNumber] or not self.PlayersDataService:GetPlayerData(player) then
		return false
	end

	self.InventoryManager.AddGems(player, self.DailyRewardsInfos[dayNumber].tickets)

	return true
end

function Daily:CheckDailyStreak(player)
	local dayStreak = self.PlayersDataService:GetKeyValue(player, "dayStreak")
	local dailyRewardsTimeClaimed = self.PlayersDataService:GetKeyValue(player, "dailyRewardsTimeClaimed")

	if type(dayStreak) ~= "number" or type(dailyRewardsTimeClaimed) ~= "table" then
		print("Error checking daily streak failed: Data did not load.")
		return
	end

	-- Reset dayStreak if more than 40 hours (16h + 24h) have passed since last time claimed
	if type(dailyRewardsTimeClaimed["day" .. dayStreak]) == "number" then
		if os.time() - dailyRewardsTimeClaimed["day" .. dayStreak] >= self.DailyRewardsConfigs._MAX_WAIT_TIME then
			self.PlayersDataService:SetKeyValue(player, "dayStreak", 0)
			self.PlayersDataService:SetKeyValue(player, "dailyRewardsTimeClaimed", {})
			self.AlertService:AddAlert(player, "DailyRewards")
		elseif os.time() - dailyRewardsTimeClaimed["day" .. dayStreak] >= self.DailyRewardsConfigs._MIN_WAIT_TIME then
			self.AlertService:AddAlert(player, "DailyRewards")
		end
	else
		self.PlayersDataService:SetKeyValue(player, "dayStreak", 0)
		self.PlayersDataService:SetKeyValue(player, "dailyRewardsTimeClaimed", {})
		self.AlertService:AddAlert(player, "DailyRewards")
	end
end

------------------------------------------------------------------------------------------------------------------------
-- VIRTUAL METHODS IMPLEMENTATION --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RUNNING FUNCTIONS ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

return Daily

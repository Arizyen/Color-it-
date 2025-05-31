local PlayTime = {}
local Rewards = require(script.Parent)
setmetatable(PlayTime, { __index = Rewards })
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
-- UPDATING PLAY TIME REWARD TIME ----------------------------------------------------------------------------------------------------
function PlayTime:CheckPlayTimeReward(player)
	local playTimeRewardTimeStarted = self.PlayersDataService:GetKeyValue(player, "playTimeRewardTimeStarted")
	local playTimeRewardTimeRestarting = self.PlayersDataService:GetKeyValue(player, "playTimeRewardTimeRestarting")
	local playTimeRewardsClaimed = self.PlayersDataService:GetKeyValue(player, "playTimeRewardsClaimed")

	if
		type(playTimeRewardTimeStarted) ~= "number"
		or type(playTimeRewardTimeRestarting) ~= "number"
		or type(playTimeRewardsClaimed) ~= "table"
	then
		return
	end

	if
		(playTimeRewardsClaimed[12] and os.time() >= playTimeRewardTimeRestarting)
		or (
			not playTimeRewardsClaimed[12]
			and (os.time() - playTimeRewardTimeStarted >= 57600) -- if the 12th reward is not claimed, then give 16 hours
			and (not playTimeRewardsClaimed[11] or playTimeRewardTimeStarted >= 86400) -- if the 11th reward is claimed, then give 24 hours
		)
	then -- 16 hours, 24 hours if 11th reward is claimed
		self.PlayersDataService:SetKeyValue(player, "playTimeRewardTime", 0)
		self.PlayersDataService:SetKeyValue(player, "playTimeRewardTimeStarted", os.time())
		self.PlayersDataService:SetKeyValue(player, "playTimeRewardTimeRestarting", 0)
		self.PlayersDataService:SetKeyValue(player, "playTimeRewardLastClaimTime", 0)
		self.PlayersDataService:SetKeyValue(player, "playTimeRewardsClaimed", {})

		playTimeRewardsClaimed = {}
	end

	-- Update playTimeRewardTime if it's less than the play time of the last claimed reward
	if self.Utils.Table.Length(playTimeRewardsClaimed) > 0 then
		local playTimeRewardTime = self.PlayersDataService:GetKeyValue(player, "playTimeRewardTime")
		if type(playTimeRewardTime) ~= "number" then
			return
		end

		if
			self.PlayTimeRewardsInfo[self.Utils.Table.Length(playTimeRewardsClaimed)]
			and playTimeRewardTime
				< self.PlayTimeRewardsInfo[self.Utils.Table.Length(playTimeRewardsClaimed)].playTime
		then
			self.PlayersDataService:SetKeyValue(
				player,
				"playTimeRewardTime",
				self.PlayTimeRewardsInfo[self.Utils.Table.Length(playTimeRewardsClaimed)].playTime + playTimeRewardTime
			)
		end
	end
end

function PlayTime:GetPlayerPlayTimeRewardTime(player)
	local playTimeRewardTime = self.PlayersDataService:GetKeyValue(player, "playTimeRewardTime")
	local playTimeRewardTimeStarted = self.PlayersDataService:GetKeyValue(player, "playTimeRewardTimeStarted")
	local playTimeRewardLastClaimTime = self.PlayersDataService:GetKeyValue(player, "playTimeRewardLastClaimTime")
	local gameStartTime = self.PlayersDataService:GetKeyValue(player, "gameStartTime")

	if
		type(playTimeRewardTime) ~= "number"
		or type(playTimeRewardTimeStarted) ~= "number"
		or type(playTimeRewardLastClaimTime) ~= "number"
		or type(gameStartTime) ~= "number"
	then
		return
	end

	-- Calculate playTimeRewardTime depending on gameStartTime and playTimeRewardTimeStarted and playTimeRewardLastClaimTime
	return playTimeRewardTime
		+ (
			os.time()
			- (
				gameStartTime >= playTimeRewardTimeStarted
					and (playTimeRewardLastClaimTime > gameStartTime and playTimeRewardLastClaimTime or gameStartTime)
				or (
					playTimeRewardLastClaimTime > playTimeRewardTimeStarted and playTimeRewardLastClaimTime
					or playTimeRewardTimeStarted
				)
			)
		)
end

function PlayTime:UpdatePlayTimeRewardTime(player)
	local playTimeRewardTime = self:GetPlayerPlayTimeRewardTime(player)

	if not playTimeRewardTime then
		return
	else
		self.PlayersDataService:SetKeyValue(player, "playTimeRewardTime", playTimeRewardTime)
	end
end
-- AWARDING ----------------------------------------------------------------------------------------------------
function PlayTime:Award(player, playTimeIndex)
	local playTimeRewardTimeStarted = self.PlayersDataService:GetKeyValue(player, "playTimeRewardTimeStarted")
	local playTimeRewardTimeRestarting = self.PlayersDataService:GetKeyValue(player, "playTimeRewardTimeRestarting")
	local gameStartTime = self.PlayersDataService:GetKeyValue(player, "gameStartTime")
	local playTimeRewardsClaimed = self.PlayersDataService:GetKeyValue(player, "playTimeRewardsClaimed")

	if
		type(playTimeRewardTimeStarted) ~= "number"
		or type(playTimeRewardTimeRestarting) ~= "number"
		or type(gameStartTime) ~= "number"
		or type(playTimeRewardsClaimed) ~= "table"
	then
		self.MessageService:SendMessageToPlayer(
			player,
			"Error claiming reward! Please try again later or rejoin the game.",
			"Error"
		)
		return
	end

	-- Check if player is claiming invalid play time reward (playTimeIndex must be 1 more than last claimed)
	if playTimeIndex > #self.PlayTimeRewardsInfo then
		self.MessageService:SendMessageToPlayer(player, "Invalid reward!", "Error")
		return
	end

	-- Check if player is claiming award before playTimeRewardTimeRestarting
	if
		playTimeRewardTimeRestarting > os.time()
		and self.Utils.Table.Length(playTimeRewardsClaimed) >= #self.PlayTimeRewardsInfo
	then
		self.MessageService:SendMessageToPlayer(
			player,
			string.format(
				"You can claim play time rewards again in %s!",
				self.Utils.Time.Format(playTimeRewardTimeRestarting - os.time())
			),
			"Error"
		)
		return
	end

	-- Check if player is claiming awarded play time reward
	if playTimeRewardsClaimed[playTimeIndex] then
		self.MessageService:SendMessageToPlayer(player, "You have already claimed this reward!", "Error")
		return
	end

	local playTimeRewardTime = self:GetPlayerPlayTimeRewardTime(player)
	if type(playTimeRewardTime) ~= "number" then
		self.MessageService:SendMessageToPlayer(
			player,
			"Error claiming reward! Please try again later or rejoin the game.",
			"Error"
		)
		return
	end

	if playTimeRewardTime >= self.PlayTimeRewardsInfo[playTimeIndex].playTime then
		-- Check if play time reward has skins reward and if player already has all skins
		if
			self.PlayTimeRewardsInfo[playTimeIndex].skins
			and not self:PlayerHasAllSkins(player, self.PlayTimeRewardsInfo[playTimeIndex].skins)
		then
			local skins = self.PlayersDataService:GetKeyValue(player, "skins")
			if not skins then
				return false
			end

			local skinsMissing = {}
			for _, eachSkin in pairs(self.PlayTimeRewardsInfo[playTimeIndex].skins) do
				if not skins[eachSkin] then
					table.insert(skinsMissing, eachSkin)
				end
			end

			if #skinsMissing > 0 then
				-- Give player a skin randomly based on its rarity
				local totalRarity = 0
				for _, eachSkin in pairs(skinsMissing) do
					totalRarity += self.TilesInfo.infos[eachSkin].rarity
				end

				local randomRarity = self.rng:NextNumber(0, totalRarity)

				self.Utils.Table.ShuffleList(skinsMissing)

				local currentRarity = 0
				for _, eachSkin in ipairs(skinsMissing) do
					currentRarity += self.TilesInfo.infos[eachSkin].rarity
					if randomRarity <= currentRarity then
						-- Make player wait 16 hours before restarting play time reward
						if playTimeIndex == 12 then
							self.PlayersDataService:SetKeyValue(
								player,
								"playTimeRewardTimeRestarting",
								os.time() + 57600
							)
						end

						-- Give player skin
						self.PlayersDataService:SetKeyIndexValue(player, "playTimeRewardsClaimed", playTimeIndex, true)
						self.PlayersDataService:SetKeyValue(player, "playTimeRewardLastClaimTime", os.time())
						self.PlayersDataService:SetKeyValue(player, "playTimeRewardTime", playTimeRewardTime)
						self.PlayersDataService:SetKeyIndexValue(player, "skins", eachSkin, true, true)

						self.MessageService:SendMessageToPlayer(
							player,
							string.format(
								"You have been rewarded the skin: %s (%s) !",
								eachSkin,
								(self.TilesInfo.infos[eachSkin].rarity * 100) .. "%"
							),
							"RewardClaimed"
						)

						return true
					end
				end
			end
		else
			if self.InventoryManager.AddGems(player, self.PlayTimeRewardsInfo[playTimeIndex].gems) then
				-- Make player wait 16 hours before restarting play time reward
				if playTimeIndex == 12 then
					self.PlayersDataService:SetKeyValue(player, "playTimeRewardTimeRestarting", os.time() + 57600)
				end

				self.PlayersDataService:SetKeyIndexValue(player, "playTimeRewardsClaimed", playTimeIndex, true)
				self.PlayersDataService:SetKeyValue(player, "playTimeRewardLastClaimTime", os.time())
				self.PlayersDataService:SetKeyValue(player, "playTimeRewardTime", playTimeRewardTime, true)

				self.MessageService:SendMessageToPlayer(
					player,
					string.format(
						"You have been rewarded %s gems for playing %s!",
						self.PlayTimeRewardsInfo[playTimeIndex].gems,
						self.PlayTimeRewardsInfo[playTimeIndex].playTime / 60 < 60
								and string.format(
									"%s minutes",
									math.round(self.PlayTimeRewardsInfo[playTimeIndex].playTime / 60)
								)
							or self.Utils.Time.Format(self.PlayTimeRewardsInfo[playTimeIndex].playTime)
					),
					"RewardClaimed"
				)

				return true
			else
				self.MessageService:SendMessageToPlayer(
					player,
					"Error claiming play time reward: Data did not save. Please try again later.",
					"Error"
				)
			end
		end
	else
		self.MessageService:SendMessageToPlayer(
			player,
			string.format(
				"You must play %s more to claim this reward!",
				self.Utils.Time.Format(self.PlayTimeRewardsInfo[playTimeIndex].playTime - playTimeRewardTime)
			),
			"Error"
		)
	end
end

function PlayTime:PlayerHasAllSkins(player, skins)
	local playerSkins = self.PlayersDataService:GetKeyValue(player, "skins")
	if not playerSkins then
		return true
	end

	for _, eachSkin in pairs(skins) do
		if not playerSkins[eachSkin] then
			return false
		end
	end

	return true
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

return PlayTime

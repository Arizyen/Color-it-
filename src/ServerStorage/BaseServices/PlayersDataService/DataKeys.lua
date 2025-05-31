local Keys = {
	-- VALUES ----------------------------------
	numbers = {
		"gameStartTime",
		"firstPlayedTime",
		"totalPlayTime",
		"totalPlayTimeOnStart",

		"dayStreak",
		"dayLoggedInStreak",
		"playTimeRewardTime",
		"playTimeRewardTimeStarted",
		"playTimeRewardTimeRestarting",
		"playTimeRewardLastClaimTime",

		"musicVolume",
		"soundEffectsVolume",

		"level",
		"xp",
		"coins",
		"gems",
		"totalCoins",
		"totalGems",

		"xpAllTime",
		"weeklyXP",
		"wins",
		"weeklyWins",

		"robux",
		"weeklyRobux",
		"robuxSpent",
	},
	booleans = {
		"newPlayer",
		"groupRewardAwarded",
	},
	strings = {},
	tables = {
		"lastSavedTimes",
		"gamepasses",
		"badges",

		"claimedAchievements",
		"claimableAchievements",

		"dailyRewardsTimeClaimed",

		"dayLoggedInTimes",

		"adShownTimes",

		"playTimeRewardsClaimed",
		"kickedReasons",
	},
	-- CONFIGS ----------------------------------
	defaultValues = {
		firstPlayedTime = function()
			return os.time()
		end,
		gameStartTime = function()
			return os.time()
		end,
		totalPlayTimeOnStart = function(data)
			return data.totalPlayTime or 0
		end,
		newPlayer = true,
		musicVolume = 60,
		soundEffectsVolume = 100,
	},
	keysToResetOnLoad = { "gameStartTime", "totalPlayTimeOnStart" },
	keysNotToReplicate = {},
	keysToShareWithOthers = {
		level = true,
		coins = true,
		gems = true,
		xp = true,

		firstPlayedTime = true,
		totalPlayTime = true,
		totalCoins = true,
		totalGems = true,

		gamepasses = true,
	},
}

return Keys

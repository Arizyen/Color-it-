return {
	-- Interface sounds
	MouseEnter = {
		SoundId = 101795256683715,
		PlaybackSpeed = math.random(90, 110) / 100,
		Volume = 0.85,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	MouseButton1Down = {
		SoundId = 9118134279,
		PlaybackSpeed = math.random(90, 110) / 100,
		Volume = 0.85,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	MouseButton1Click = {
		SoundId = 9117841338,
		PlaybackSpeed = math.random(100, 120) / 100,
		Volume = 0.85,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	Notification1 = {
		SoundId = 122397610725397,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	Notification2 = {
		SoundId = 122397610725397,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	Notification3 = {
		SoundId = 127573162596493,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	Error1 = {
		SoundId = 14910185858,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	Success1 = {
		SoundId = 14910184097,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	PurchaseSuccessful = {
		SoundId = 14910184097,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	LevelUp = {
		SoundId = 14910179366,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	GemPurchase = {
		SoundId = 14910260338,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	RewardClaimed = {
		SoundId = 14910260338,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	AchievementClaimed = {
		SoundId = 14910179366,
		Volume = 1,
		tag = "SoundEffect",
		preloadLocal = true,
	},

	-- In-Game sounds
	Pop = {
		SoundId = 119100882120159,
		PlaybackSpeed = function()
			return math.random(90, 110) / 100
		end,
		Volume = 0.85,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	WrongAnswer = {
		SoundId = 115124740518615,
		Volume = 0.85,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	Gong = {
		SoundId = 84666372572856,
		PlaybackSpeed = 1,
		Volume = 0.85,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	Drumroll2 = {
		SoundId = 133329258794504,
		Volume = 0.85,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	CountdownTick = {
		SoundId = 94952134949700,
		tag = "SoundEffect",
		preloadLocal = true,
	},
	CountdownEnd = {
		SoundId = 127776688836567,
		tag = "SoundEffect",
		preloadLocal = true,
	},
}

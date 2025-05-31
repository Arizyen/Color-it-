return {
	-- Interface sounds
	MouseEnter = {
		SoundId = 101795256683715,
		PlaybackSpeed = math.random(90, 110) / 100,
		Volume = 0.85,
		Tag = "SoundEffect",
	},
	MouseButton1Down = {
		SoundId = 9118134279,
		PlaybackSpeed = math.random(90, 110) / 100,
		Volume = 0.85,
		Tag = "SoundEffect",
	},
	MouseButton1Click = {
		SoundId = 9117841338,
		PlaybackSpeed = math.random(100, 120) / 100,
		Volume = 0.85,
		Tag = "SoundEffect",
	},
	Notification1 = {
		SoundId = 122397610725397,
		Volume = 1,
		Tag = "SoundEffect",
	},
	Notification2 = {
		SoundId = 122397610725397,
		Volume = 1,
		Tag = "SoundEffect",
	},
	Notification3 = {
		SoundId = 127573162596493,
		Volume = 1,
		Tag = "SoundEffect",
	},
	Error1 = {
		SoundId = 14910185858,
		Volume = 1,
		Tag = "SoundEffect",
	},
	Success1 = {
		SoundId = 14910184097,
		Volume = 1,
		Tag = "SoundEffect",
	},
	PurchaseSuccessful = {
		SoundId = 14910184097,
		Volume = 1,
		Tag = "SoundEffect",
	},
	LevelUp = {
		SoundId = 14910179366,
		Volume = 1,
		Tag = "SoundEffect",
	},
	GemPurchase = {
		SoundId = 14910260338,
		Volume = 1,
		Tag = "SoundEffect",
	},
	RewardClaimed = {
		SoundId = 14910260338,
		Volume = 1,
		Tag = "SoundEffect",
	},
	AchievementClaimed = {
		SoundId = 14910179366,
		Volume = 1,
		Tag = "SoundEffect",
	},

	-- In-Game sounds
	Pop = {
		SoundId = 119100882120159,
		PlaybackSpeed = function()
			return math.random(90, 110) / 100
		end,
		Volume = 0.85,
		Tag = "SoundEffect",
	},
	WrongAnswer = {
		SoundId = 115124740518615,
		Volume = 0.85,
		Tag = "SoundEffect",
	},
	Gong = {
		SoundId = 84666372572856,
		PlaybackSpeed = 1,
		Volume = 0.85,
		Tag = "SoundEffect",
	},
	Drumroll2 = {
		SoundId = 133329258794504,
		Volume = 0.85,
		Tag = "SoundEffect",
	},
}

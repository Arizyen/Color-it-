return {
	keys = { -- Keys that are modifiable by the client (MUST NOT BE A TABLE)
		newPlayer = "boolean",
		musicVolume = "number",
		soundEffectsVolume = "number",
	},
	tableKeys = { -- Table keys modifiable by the client
		adShownTimes = {
			vip = "number",
			doubleGems = "number",
			doubleCoins = "number",
			doubleXP = "number",
			triplePetsEquip = "number",
			tripleOpen = "number",
			fastOpen = "number",
			autoOpen = "number",
			lucky = "number",
			superLucky = "number",
			autoFuse = "number",
		},
	},
}

local DataStoreService = game:GetService("DataStoreService")
local PlayersTotalScore = DataStoreService:GetOrderedDataStore("PlayersTotalScore")

local usersNewScore = {
	[2877729182] = 5400000,
}

for userId, score in pairs(usersNewScore) do
	local success, err = pcall(function()
		PlayersTotalScore:SetAsync(userId, score)
	end)
	if success then
		print("SetAsync success for userId: " .. userId)
	else
		print("SetAsync failed for userId: " .. userId .. " with error: " .. err)
	end
end

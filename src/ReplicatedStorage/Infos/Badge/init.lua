local Badges = {}

for _, eachModule in pairs(script:GetChildren()) do
	Badges[eachModule.Name] = require(eachModule)
end

return Badges

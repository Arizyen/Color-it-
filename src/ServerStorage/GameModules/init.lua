local Modules = {}

for _, eachModule in pairs(script:GetChildren()) do
	Modules[eachModule.Name] = require(eachModule)
end

return Modules

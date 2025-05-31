local Assets = {}

local ContentProvider = game:GetService("ContentProvider")

-- LOADING -----------------------------------------------------------------------------------------------------------------------------------
function Assets.Preload(assetIds, callBackFunction)
	task.spawn(function()
		ContentProvider:PreloadAsync(assetIds, callBackFunction)
	end)
end

function Assets.ImageLinkFromId(assetId, height)
	if not assetId then
		return
	end
	if not height then
		height = 420
	end
	return "https://www.roblox.com/asset-thumbnail/image?assetId="
		.. tostring(assetId)
		.. "&width="
		.. height
		.. "&height="
		.. height
		.. "&format=png"
end

-- function Assets.ImageLinkFromId(assetId)
-- 	return "rbxthumb://type=Asset&id=" .. assetId .. "&w=150&h=150"
-- end

return Assets

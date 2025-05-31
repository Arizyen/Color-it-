local Model = {}

local RunService = game:GetService("RunService")
local Connections = require(script.Parent.Connections)
local Tween = require(script.Parent.Tween)

function Model.SetDescendantPartProperty(model, property, value)
	if not model then
		return
	end
	if model:IsA("BasePart") then
		model[property] = value
	end
	for _, eachDescendant in pairs(model:GetDescendants()) do
		if eachDescendant:IsA("BasePart") then
			eachDescendant[property] = value
		end
	end
end

function Model.SetDescendantPartProperties(model, propertiesKeyValues)
	if not model then
		return
	end
	if model:IsA("BasePart") then
		for eachProperty, eachValue in pairs(propertiesKeyValues) do
			model[eachProperty] = eachValue
		end
	end
	for _, eachDescendant in pairs(model:GetDescendants()) do
		if eachDescendant:IsA("BasePart") then
			for eachProperty, eachValue in pairs(propertiesKeyValues) do
				eachDescendant[eachProperty] = eachValue
			end
		end
	end
end

function Model.Show(model: Model, state: boolean?)
	if not model then
		return
	end

	for _, eachDescendant in pairs(model:GetDescendants()) do
		if eachDescendant:IsA("BasePart") or eachDescendant:IsA("Decal") then
			eachDescendant.Transparency = state == true and 1 or 0
		elseif eachDescendant:IsA("BillboardGui") or eachDescendant:IsA("SurfaceGui") then
			if state then
				eachDescendant.Enabled = false
			else
				eachDescendant.Enabled = true
			end
		end
	end
end

function Model.AveragePosition(model: Model | Folder)
	if not model then
		return
	end

	local modelChildren = model:GetChildren()
	if modelChildren and #modelChildren > 0 then
		local totalVector3, count, modelPosition = Vector3.new(), 0, nil
		for _, eachChild in pairs(modelChildren) do
			if eachChild:IsA("BasePart") then
				totalVector3 += eachChild.Position
				count += 1
			elseif eachChild:IsA("Model") then
				modelPosition = Model.AveragePosition(eachChild)
				if modelPosition then
					totalVector3 += modelPosition
					count += 1
				end
			end
		end

		if count >= 1 then
			return totalVector3 / count
		end
	end

	return Vector3.new()
end

-- Return precise extents size of model
function Model.GetExtentsSize(model): Vector3
	local modelCFrame = model:GetBoundingBox()

	local minBounds = Vector3.new(math.huge, math.huge, math.huge)
	local maxBounds = Vector3.new(-math.huge, -math.huge, -math.huge)

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local relativeCFrame = modelCFrame:ToObjectSpace(part.CFrame)
			local size = part.Size / 2

			-- Calculate the local corners
			local corners = {
				relativeCFrame * Vector3.new(-size.X, -size.Y, -size.Z),
				relativeCFrame * Vector3.new(size.X, -size.Y, -size.Z),
				relativeCFrame * Vector3.new(-size.X, size.Y, -size.Z),
				relativeCFrame * Vector3.new(size.X, size.Y, -size.Z),
				relativeCFrame * Vector3.new(-size.X, -size.Y, size.Z),
				relativeCFrame * Vector3.new(size.X, -size.Y, size.Z),
				relativeCFrame * Vector3.new(-size.X, size.Y, size.Z),
				relativeCFrame * Vector3.new(size.X, size.Y, size.Z),
			}

			-- Update bounds in local space
			for _, corner in ipairs(corners) do
				minBounds = Vector3.new(
					math.min(minBounds.X, corner.X),
					math.min(minBounds.Y, corner.Y),
					math.min(minBounds.Z, corner.Z)
				)
				maxBounds = Vector3.new(
					math.max(maxBounds.X, corner.X),
					math.max(maxBounds.Y, corner.Y),
					math.max(maxBounds.Z, corner.Z)
				)
			end
		end
	end

	local boundingBox = maxBounds - minBounds

	return Vector3.new(
		math.round(boundingBox.X * 1e4) / 1e4,
		math.round(boundingBox.Y * 1e4) / 1e4,
		math.round(boundingBox.Z * 1e4) / 1e4
	)
end

function Model.SetPartsSizeFactor(model: Model | Folder)
	-- Get highest size value
	local highestSize = Vector3.new()

	for _, eachDescendant in pairs(model:GetDescendants()) do
		if eachDescendant:IsA("BasePart") and eachDescendant.Size.Magnitude > highestSize.Magnitude then
			highestSize = eachDescendant.Size
		end
	end

	-- Set size factor
	for _, eachDescendant in pairs(model:GetDescendants()) do
		if eachDescendant:IsA("BasePart") then
			eachDescendant:SetAttribute("sizeFactor", eachDescendant.Size.Magnitude / highestSize.Magnitude)
		end
	end

	model:SetAttribute("sizeFactorsSet", true)
end

function Model.Scale(model: Model | Folder, factor: number)
	for _, eachDescendant in pairs(model:GetDescendants()) do
		if eachDescendant:IsA("BasePart") then
			eachDescendant.Size *= (factor * (eachDescendant:GetAttribute("sizeFactor") or 1))
		end
	end
end

function Model.ScaleToSize(model: Model, targetSize: Vector3)
	local modelCFrame, modelSize = model:GetBoundingBox()
	local scaleFactor = targetSize / modelSize

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local localOffset = modelCFrame:PointToObjectSpace(part.Position)
			local scaledOffset = localOffset * scaleFactor
			local newPosition = modelCFrame:PointToWorldSpace(scaledOffset)
			local originalRotation = part.CFrame - part.CFrame.Position

			part.Size = part.Size * scaleFactor
			part.CFrame = CFrame.new(newPosition) * originalRotation
		end
	end
end

function Model.TweenSize(model, targetSize, duration)
	local currentSize = Model.GetExtentsSize(model)
	local scaleFactor = targetSize / currentSize

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local localOffset = model.PrimaryPart.CFrame:PointToObjectSpace(part.Position)
			local newSize = part.Size * scaleFactor
			local targetCFrame = model.PrimaryPart.CFrame * CFrame.new(localOffset * scaleFactor)

			Tween.Start(part, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {
				Size = newSize,
				CFrame = targetCFrame,
			})
		end
	end
end

function Model.TweenSizeAndPosition(model, targetSize, targetPosition, duration)
	local currentSize = Model.GetExtentsSize(model)
	local scaleFactor = targetSize / currentSize

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local localOffset = model.PrimaryPart.CFrame:PointToObjectSpace(part.Position)
			local newSize = part.Size * scaleFactor
			local newCFrame = CFrame.new(targetPosition) * CFrame.new(localOffset * scaleFactor)

			Tween.Start(part, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {
				Size = newSize,
				CFrame = newCFrame,
			})
		end
	end
end

function Model.CancelTween(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			Tween.Cancel(part)
		end
	end
end

-- RunService manipulations
function Model.FocusOnPart(model: Model, focusPart: BasePart)
	if not model or not model.PrimaryPart or not focusPart or not focusPart.Parent then
		return
	end

	local targetCFrame
	return Connections.Add(
		model,
		"focusOnPart",
		RunService.RenderStepped:Connect(function()
			if not model or not model.PrimaryPart or not focusPart or not focusPart.Parent then
				Connections.DisconnectKeyConnection(model, "focusOnPart")
				return
			end

			targetCFrame = CFrame.new(model.PrimaryPart.Position, focusPart.Position)
			model.PrimaryPart.CFrame = CFrame.new(
				model.PrimaryPart.Position,
				model.PrimaryPart.Position + Vector3.new(targetCFrame.LookVector.X, 0, targetCFrame.LookVector.Z)
			)
		end)
	)
end

return Model

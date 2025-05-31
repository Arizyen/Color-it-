local Beam = {}

function Beam.Create(mainPart: BasePart, secondPart: BasePart, properties: table?)
	if not mainPart or not secondPart then
		return
	end

	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = mainPart

	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = secondPart

	local beam = Instance.new("Beam")
	beam.Parent = mainPart

	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.FaceCamera = true

	if typeof(properties) == "table" then
		for eachProperty, eachValue in pairs(properties) do
			beam[eachProperty] = eachValue
		end
	end

	beam.Parent = mainPart
	return beam
end

function Beam.Remove(beam)
	if not beam or not beam.Parent then
		return
	end

	-- Destroy attachments
	for _, eachAttachment in pairs({ "Attachment0", "Attachment1" }) do
		if beam[eachAttachment] then
			beam[eachAttachment]:Destroy()
		end
	end

	-- Destroy beam
	beam:Destroy()
end

return Beam

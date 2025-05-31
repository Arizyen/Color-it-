local Weld = {}

function Weld.Weld(mainPart, partToWeldTo, weldType, offset, keepRelativePosition) -- Create a weld while keeping relative position or not. mainPart --> Part to weld.
	if not mainPart or not partToWeldTo then
		return
	end

	local weld = Instance.new(weldType or "WeldConstraint")
	offset = offset or CFrame.new()

	if weld:IsA("Weld") then
		if keepRelativePosition then
			weld.C0 = mainPart.CFrame:Inverse() * partToWeldTo.CFrame * offset
		else
			-- weld.C0 = partToWeldTo.CFrame * offset
			-- weld.C1 = partToWeldTo.CFrame
			weld.C0 = offset
		end
	elseif weld:IsA("WeldConstraint") then
		if not keepRelativePosition then
			mainPart.CFrame = partToWeldTo.CFrame:ToWorldSpace(offset)
		end
	end

	weld.Part0 = mainPart
	weld.Part1 = partToWeldTo
	weld.Parent = mainPart

	return weld
end

function Weld.DestroyActiveWelds(mainPart, partToWeldTo)
	local parts = { mainPart, partToWeldTo }
	for _, eachPart in pairs(parts) do
		if eachPart and eachPart:IsA("BasePart") then
			for _, eachChild in pairs(eachPart:GetChildren()) do
				if eachChild:IsA("Weld") or eachChild:IsA("WeldConstraint") then
					if
						(eachChild.Part0 == mainPart and eachChild.Part1 == partToWeldTo)
						or (eachChild.Part0 == partToWeldTo and eachChild.Part1 == mainPart)
					then
						eachChild:Destroy()
					end
				end
			end
		end
	end
end

function Weld.DestroyWelds(parentFolder)
	if not parentFolder then
		return
	end
	for _, eachChild in pairs(parentFolder:GetChildren()) do
		if eachChild:IsA("Weld") or eachChild:IsA("WeldConstraint") then
			eachChild:Destroy()
		end
	end
end

return Weld

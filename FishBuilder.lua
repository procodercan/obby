-- PASTE INTO: ReplicatedStorage > Modules > FishBuilder (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FishData"))

local FishBuilder = {}

local function style(part, fd)
	if fd.pattern == "Iridescent" or fd.pattern == "Rainbow" then
		part.Color = fd.primaryColor
		part.Material = Enum.Material.Neon
	else
		part.Color = fd.primaryColor
		part.Material = Enum.Material.SmoothPlastic
	end
end

function FishBuilder.createFishModel(fd)
	local scale = fd.size or 1
	local model = Instance.new("Model")
	model.Name = fd.name
	
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2*scale, 0.8*scale, 1.2*scale)
	body.Shape = Enum.PartType.Ball
	body.Anchored = false
	body.CanCollide = true
	style(body, fd)
	body.Parent = model
	
	local tail = Instance.new("Part")
	tail.Name = "Tail"
	tail.Size = Vector3.new(0.3*scale, 1*scale, 1.5*scale)
	tail.Anchored = false
	tail.Color = fd.secondaryColor
	tail.Material = Enum.Material.Neon
	tail.Parent = model
	local tw = Instance.new("WeldConstraint")
	tw.Part0 = body
	tw.Part1 = tail
	tw.Parent = tail
	tail.CFrame = body.CFrame * CFrame.new(0,0,-1.2)
	
	local fin = Instance.new("Part")
	fin.Name = "Fin"
	fin.Size = Vector3.new(0.2*scale, 1.2*scale, 0.3*scale)
	fin.Anchored = false
	fin.Color = fd.secondaryColor
	fin.Material = Enum.Material.Neon
	fin.Transparency = 0.4
	fin.CanCollide = false
	fin.Parent = model
	local fw = Instance.new("WeldConstraint")
	fw.Part0 = body
	fw.Part1 = fin
	fw.Parent = fin
	fin.CFrame = body.CFrame * CFrame.new(0, 0.5, 0.5)
	
	model.PrimaryPart = body
	return model
end

return FishBuilder

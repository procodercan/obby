--[[
	FISH BUILDER - Creates beautiful 3D fish models from FishData
	Works in both Workspace and when cloning for players
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FishData"))

local FishBuilder = {}

-- Apply pattern to fish part (decal, gradient, etc)
local function applyPattern(part, fishData)
	if fishData.pattern == "Striped" then
		part.Color = fishData.primaryColor
		part.Material = Enum.Material.SmoothPlastic
		-- Tail gets secondary for stripe contrast
	elseif fishData.pattern == "Spotted" or fishData.pattern == "Speckled" then
		part.Color = fishData.primaryColor
		part.Transparency = 0.1
	elseif fishData.pattern == "Iridescent" or fishData.pattern == "Rainbow" then
		part.Color = fishData.primaryColor
		part.Material = Enum.Material.Neon
	else
		part.Color = fishData.primaryColor
		part.Material = Enum.Material.SmoothPlastic
	end
end

function FishBuilder.createFishModel(fishData)
	local model = Instance.new("Model")
	model.Name = fishData.name
	
	local scale = fishData.size or 1
	local bodyLength = 2 * scale
	local bodyHeight = 0.8 * scale
	local bodyWidth = 1.2 * scale
	
	-- Main body (ellipsoid-like with Part)
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bodyLength, bodyHeight, bodyWidth)
	body.Shape = Enum.PartType.Ball
	body.Anchored = false
	body.CanCollide = true
	body.CanQuery = true
	body.CanTouch = true
	body.Massless = false
	body.Parent = model
	applyPattern(body, fishData)
	
	-- Tail fin
	local tail = Instance.new("Part")
	tail.Name = "Tail"
	tail.Size = Vector3.new(0.3 * scale, bodyHeight * 1.2, bodyWidth * 1.5)
	tail.Shape = Enum.PartType.Block
	tail.Anchored = false
	tail.CanCollide = true
	tail.Color = fishData.secondaryColor
	tail.Material = Enum.Material.SmoothPlastic
	tail.Parent = model
	
	local tailWeld = Instance.new("WeldConstraint")
	tailWeld.Part0 = body
	tailWeld.Part1 = tail
	tailWeld.Parent = tail
	tail.CFrame = body.CFrame * CFrame.new(0, 0, -bodyLength/2 - 0.15)
	
	-- Head/Dorsal fin
	local dorsal = Instance.new("Part")
	dorsal.Name = "DorsalFin"
	dorsal.Size = Vector3.new(0.2 * scale, bodyHeight * 1.5, 0.3 * scale)
	dorsal.Shape = Enum.PartType.Block
	dorsal.Anchored = false
	dorsal.CanCollide = false
	dorsal.Color = fishData.secondaryColor
	dorsal.Transparency = 0.3
	dorsal.Material = Enum.Material.SmoothPlastic
	dorsal.Parent = model
	
	local dorsalWeld = Instance.new("WeldConstraint")
	dorsalWeld.Part0 = body
	dorsalWeld.Part1 = dorsal
	dorsalWeld.Parent = dorsal
	dorsal.CFrame = body.CFrame * CFrame.new(0, bodyHeight/2 + 0.1, bodyLength/4)
	
	-- Set primary part
	model.PrimaryPart = body
	
	-- Add HumanoidDescription-like tag for identification
	local attr = Instance.new("StringValue")
	attr.Name = "FishId"
	attr.Value = tostring(fishData.id)
	attr.Parent = model
	
	return model
end

function FishBuilder.createFromId(fishId)
	local fishData = FishData.getFish(fishId)
	return FishBuilder.createFishModel(fishData)
end

function FishBuilder.createRandom()
	local fishData = FishData.getRandomFish()
	return FishBuilder.createFishModel(fishData)
end

return FishBuilder

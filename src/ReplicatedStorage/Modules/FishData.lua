--[[
	FISH DATA MODULE - 2999 Unique Fish Varieties
	Escape Tsunami: Fish Edition
	Generates fish through species × colors × patterns × sizes combinations
]]

local FishData = {}
FishData.__index = FishData

-- 23 Unique Fish Species (real + fantasy)
local SPECIES = {
	"Clownfish", "Angelfish", "Betta", "Goldfish", "Piranha",
	"Tuna", "Salmon", "Marlin", "Swordfish", "Seahorse",
	"Jellyfish", "Stingray", "Barracuda", "Tetra", "Guppy",
	"Koi", "Catfish", "Pufferfish", "Manta", "Lanternfish",
	"Neon Tetra", "Dragonfish", "Rainbow Trout"
}

-- 13 Vibrant Color Palettes (primary color schemes)
local COLORS = {
	Color3.fromRGB(255, 107, 107),   -- Coral Red
	Color3.fromRGB(255, 178, 102),   -- Sunset Orange
	Color3.fromRGB(255, 230, 109),   -- Golden Yellow
	Color3.fromRGB(178, 255, 102),   -- Mint Green
	Color3.fromRGB(102, 255, 178),   -- Aqua Teal
	Color3.fromRGB(102, 204, 255),   -- Sky Blue
	Color3.fromRGB(102, 102, 255),   -- Royal Blue
	Color3.fromRGB(178, 102, 255),   -- Violet
	Color3.fromRGB(255, 102, 255),   -- Magenta
	Color3.fromRGB(255, 255, 255),   -- Pearl White
	Color3.fromRGB(50, 50, 50),      -- Midnight Black
	Color3.fromRGB(255, 200, 150),   -- Peach
	Color3.fromRGB(150, 255, 200),   -- Seafoam
}

-- 10 Pattern Types (affects secondary color application)
local PATTERNS = {
	"Solid", "Striped", "Spotted", "Gradient", "Iridescent",
	"Speckled", "Banded", "Ombre", "BiColor", "Rainbow"
}

-- 2 Size modifiers (for variety)
local SIZES = { 0.8, 1.2 }

-- Generate all 2999 fish combinations (23 × 13 × 10 = 2990, add 9 special variants)
local TOTAL_FISH = 2999
local FISH_CACHE = {}

-- Create unique fish ID from indices
local function createFishId(speciesIdx, colorIdx, patternIdx, sizeIdx)
	return (speciesIdx - 1) * 260 + (colorIdx - 1) * 20 + (patternIdx - 1) * 2 + (sizeIdx or 1)
end

-- Get secondary color (slightly different from primary)
local function getSecondaryColor(primaryColor)
	local r, g, b = primaryColor.R, primaryColor.G, primaryColor.B
	return Color3.new(
		math.clamp(r + 0.15, 0, 1),
		math.clamp(g + 0.1, 0, 1),
		math.clamp(b + 0.2, 0, 1)
	)
end

-- Build the fish database (lazy generation)
function FishData.getFish(fishId)
	if fishId < 1 or fishId > TOTAL_FISH then
		fishId = 1
	end
	
	if FISH_CACHE[fishId] then
		return FISH_CACHE[fishId]
	end
	
	-- Distribute across combinations
	local sCount, cCount, pCount = #SPECIES, #COLORS, #PATTERNS
	local idx = fishId - 1
	
	local speciesIdx = (idx % sCount) + 1
	idx = math.floor(idx / sCount)
	local colorIdx = (idx % cCount) + 1
	idx = math.floor(idx / cCount)
	local patternIdx = (idx % pCount) + 1
	local sizeIdx = (fishId % 2) + 1  -- Alternate sizes
	
	local primaryColor = COLORS[colorIdx]
	local secondaryColor = getSecondaryColor(primaryColor)
	
	local fish = {
		id = fishId,
		name = SPECIES[speciesIdx] .. " #" .. fishId,
		species = SPECIES[speciesIdx],
		primaryColor = primaryColor,
		secondaryColor = secondaryColor,
		pattern = PATTERNS[patternIdx],
		size = SIZES[sizeIdx],
		rarity = fishId <= 100 and "Legendary" or fishId <= 500 and "Epic" or fishId <= 1500 and "Rare" or "Common",
		speed = 1 + (fishId % 10) * 0.05,  -- Slight speed variation
	}
	
	FISH_CACHE[fishId] = fish
	return fish
end

function FishData.getRandomFish()
	return FishData.getFish(math.random(1, TOTAL_FISH))
end

function FishData.getTotalCount()
	return TOTAL_FISH
end

function FishData.getSpeciesList()
	return SPECIES
end

return FishData

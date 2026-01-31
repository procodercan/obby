-- PASTE INTO: ReplicatedStorage > Modules > FishData (ModuleScript)

local FishData = {}
local SPECIES = {"Clownfish","Angelfish","Betta","Goldfish","Piranha","Tuna","Salmon","Marlin","Swordfish","Seahorse","Jellyfish","Stingray","Barracuda","Tetra","Guppy","Koi","Catfish","Pufferfish","Manta","Lanternfish","Neon Tetra","Dragonfish","Rainbow Trout"}
local COLORS = {
	Color3.fromRGB(255,71,87), Color3.fromRGB(255,127,80), Color3.fromRGB(255,215,0),
	Color3.fromRGB(50,205,50), Color3.fromRGB(0,255,255), Color3.fromRGB(30,144,255),
	Color3.fromRGB(138,43,226), Color3.fromRGB(255,0,255), Color3.fromRGB(255,192,203),
	Color3.fromRGB(255,255,255), Color3.fromRGB(25,25,25), Color3.fromRGB(255,165,0),
	Color3.fromRGB(124,252,0)
}
local PATTERNS = {"Solid","Striped","Spotted","Gradient","Iridescent","Speckled","Banded","Ombre","BiColor","Rainbow"}
local SIZES = {0.8, 1.2}
local TOTAL = 2999
local CACHE = {}

local function getSecondary(c)
	return Color3.new(math.clamp(c.R+0.2,0,1), math.clamp(c.G+0.1,0,1), math.clamp(c.B+0.2,0,1))
end

function FishData.getFish(id)
	id = math.clamp(id or 1, 1, TOTAL)
	if CACHE[id] then return CACHE[id] end
	local idx = id - 1
	local s = (idx % #SPECIES) + 1
	idx = math.floor(idx / #SPECIES)
	local c = (idx % #COLORS) + 1
	idx = math.floor(idx / #COLORS)
	local p = (idx % #PATTERNS) + 1
	local prim = COLORS[c]
	local fish = {
		id=id, name=SPECIES[s].." #"..id, species=SPECIES[s],
		primaryColor=prim, secondaryColor=getSecondary(prim), pattern=PATTERNS[p],
		size=SIZES[(id%2)+1],
		rarity = id<=50 and "LEGENDARY" or id<=200 and "EPIC" or id<=800 and "RARE" or "COMMON"
	}
	CACHE[id] = fish
	return fish
end

function FishData.getRandomFish()
	return FishData.getFish(math.random(1,TOTAL))
end

function FishData.getTotalCount()
	return TOTAL
end

return FishData

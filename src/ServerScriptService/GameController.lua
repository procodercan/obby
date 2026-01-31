--[[
	GAME CONTROLLER - Escape Tsunami: Fish Edition
	Server-side game logic: spawning, tsunami, scoring, game state
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FishData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FishData"))
local FishBuilder = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FishBuilder"))

-- Create RemoteEvents for client-server communication
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "GameRemotes"
remotesFolder.Parent = ReplicatedStorage

local startGame = Instance.new("RemoteEvent")
startGame.Name = "StartGame"
startGame.Parent = remotesFolder

local selectFish = Instance.new("RemoteEvent")
selectFish.Name = "SelectFish"
selectFish.Parent = remotesFolder

local gameState = Instance.new("RemoteEvent")
gameState.Name = "GameState"
gameState.Parent = remotesFolder

-- Game configuration
local CONFIG = {
	OCEAN_DEPTH = 50,
	OCEAN_WIDTH = 200,
	OCEAN_LENGTH = 500,
	TSUNAMI_SPEED = 25,
	PLAYER_SPEED = 35,
	OBSTACLE_SPAWN_RATE = 2,
	POWERUP_SPAWN_RATE = 5,
}

local gameActive = false
local tsunamiPosition = 0
local tsunamiModel = nil
local playerScores = {}
local playerFish = {}

-- Setup ocean environment
local function setupOcean()
	local ocean = Workspace:FindFirstChild("Ocean")
	if not ocean then
		ocean = Instance.new("Folder")
		ocean.Name = "Ocean"
		ocean.Parent = Workspace
	end
	
	-- Water plane (Roblox has built-in water)
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.WaterColor = Color3.fromRGB(0, 119, 190)
		terrain.WaterTransparency = 0.3
		terrain.WaterWaveSize = 0.5
	end
	
	-- Ocean floor
	local floor = Workspace:FindFirstChild("OceanFloor")
	if not floor then
		floor = Instance.new("Part")
		floor.Name = "OceanFloor"
		floor.Size = Vector3.new(CONFIG.OCEAN_WIDTH * 2, 2, CONFIG.OCEAN_LENGTH * 2)
		floor.Position = Vector3.new(0, -CONFIG.OCEAN_DEPTH, 0)
		floor.Anchored = true
		floor.Material = Enum.Material.Sand
		floor.Color = Color3.fromRGB(194, 178, 128)
		floor.Parent = Workspace
	end
	
	return ocean
end

-- Spawn tsunami wave
local function spawnTsunami()
	if tsunamiModel then tsunamiModel:Destroy() end
	
	tsunamiModel = Instance.new("Model")
	tsunamiModel.Name = "Tsunami"
	tsunamiModel.Parent = Workspace
	
	local wavePart = Instance.new("Part")
	wavePart.Name = "Wave"
	wavePart.Size = Vector3.new(CONFIG.OCEAN_WIDTH * 2, 80, 30)
	wavePart.Position = Vector3.new(0, 20, -CONFIG.OCEAN_LENGTH)
	wavePart.Anchored = true
	wavePart.Material = Enum.Material.ForceField
	wavePart.Color = Color3.fromRGB(30, 144, 255)
	wavePart.Transparency = 0.4
	wavePart.CanCollide = false
	wavePart.Parent = tsunamiModel
	
	-- Foam effect (offset from wave)
	local foam = Instance.new("Part")
	foam.Name = "Foam"
	foam.Size = Vector3.new(CONFIG.OCEAN_WIDTH * 2, 10, 5)
	foam.CFrame = wavePart.CFrame * CFrame.new(0, 40, 15)
	foam.Anchored = true
	foam.Material = Enum.Material.Neon
	foam.Color = Color3.fromRGB(255, 255, 255)
	foam.Transparency = 0.2
	foam.CanCollide = false
	foam.Parent = tsunamiModel
	
	tsunamiModel.PrimaryPart = wavePart
	return tsunamiModel
end

-- Spawn obstacle (rocks, debris)
local function spawnObstacle()
	local obstacle = Instance.new("Part")
	obstacle.Name = "Obstacle"
	obstacle.Shape = Enum.PartType.Ball
	obstacle.Size = Vector3.new(4, 4, 4) * math.random(80, 150) / 100
	obstacle.Position = Vector3.new(
		math.random(-CONFIG.OCEAN_WIDTH/2, CONFIG.OCEAN_WIDTH/2),
		math.random(-CONFIG.OCEAN_DEPTH + 10, 10),
		math.random(0, CONFIG.OCEAN_LENGTH)
	)
	obstacle.Anchored = true
	obstacle.Material = Enum.Material.Rock
	obstacle.Color = Color3.fromRGB(100, 100, 100)
	obstacle.Parent = Workspace
	game:GetService("Debris"):AddItem(obstacle, 15)
end

-- Select fish for player (can change until game starts)
selectFish.OnServerEvent:Connect(function(player, fishId)
	fishId = math.clamp(fishId or math.random(1, FishData.getTotalCount()), 1, FishData.getTotalCount())
	playerFish[player.UserId] = fishId
	selectFish:FireClient(player, fishId)
end)

-- Start game
startGame.OnServerEvent:Connect(function(player)
	if gameActive then return end
	
	gameActive = true
	playerScores[player.UserId] = 0
	tsunamiPosition = -CONFIG.OCEAN_LENGTH
	
	setupOcean()
	spawnTsunami()
	
	gameState:FireAllClients("GameStarted", {
		totalFish = FishData.getTotalCount(),
		playerFishId = playerFish[player.UserId] or 1,
	})
end)

-- Tsunami chase loop + obstacles (separate connection)
local obstacleTimer = 0
RunService.Heartbeat:Connect(function(dt)
	if not gameActive then return end
	
	tsunamiPosition = tsunamiPosition + CONFIG.TSUNAMI_SPEED * dt
	if tsunamiModel and tsunamiModel.Parent and tsunamiModel.PrimaryPart then
		tsunamiModel.PrimaryPart.CFrame = CFrame.new(0, 20, tsunamiPosition)
		local foam = tsunamiModel:FindFirstChild("Foam")
		if foam and foam:IsA("BasePart") then
			foam.CFrame = tsunamiModel.PrimaryPart.CFrame * CFrame.new(0, 40, 15)
		end
	end
	
	-- Spawn obstacles periodically
	obstacleTimer = obstacleTimer + dt
	if obstacleTimer >= CONFIG.OBSTACLE_SPAWN_RATE then
		obstacleTimer = 0
		spawnObstacle()
	end
end)

-- End game when player is caught
game.BindToRenderStep("CheckTsunamiCollision", Enum.RenderPriority.First.Value, function()
	if not gameActive then return end
	
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local root = character.HumanoidRootPart
			if root.Position.Z < tsunamiPosition + 20 then
				gameState:FireClient(player, "GameOver", { score = playerScores[player.UserId] or 0 })
				gameActive = false
			else
				playerScores[player.UserId] = (playerScores[player.UserId] or 0) + 1
			end
		end
	end
end)

print("[Escape Tsunami: Fish Edition] Game loaded! " .. FishData.getTotalCount() .. " fish varieties available.")

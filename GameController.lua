-- PASTE INTO: ServerScriptService > GameController (Script)

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local FishData = require(RS:WaitForChild("Modules"):WaitForChild("FishData"))
local FishBuilder = require(RS:WaitForChild("Modules"):WaitForChild("FishBuilder"))

local Remotes = Instance.new("Folder")
Remotes.Name = "GameRemotes"
Remotes.Parent = RS

local StartGame = Instance.new("RemoteEvent")
StartGame.Name = "StartGame"
StartGame.Parent = Remotes

local SelectFish = Instance.new("RemoteEvent")
SelectFish.Name = "SelectFish"
SelectFish.Parent = Remotes

local GameState = Instance.new("RemoteEvent")
GameState.Name = "GameState"
GameState.Parent = Remotes

local active = false
local tsunamiZ = -500
local tsunamiModel = nil
local scores = {}
local fishChoice = {}

SelectFish.OnServerEvent:Connect(function(p, id)
	id = math.clamp(id or math.random(1,2999), 1, 2999)
	fishChoice[p.UserId] = id
	SelectFish:FireClient(p, id)
end)

StartGame.OnServerEvent:Connect(function(p)
	if active then return end
	active = true
	scores[p.UserId] = 0
	tsunamiZ = -500
	
	-- Ocean floor
	local floor = WS:FindFirstChild("OceanFloor")
	if not floor then
		floor = Instance.new("Part")
		floor.Name = "OceanFloor"
		floor.Size = Vector3.new(400,4,1000)
		floor.Position = Vector3.new(0,-55,0)
		floor.Anchored = true
		floor.Material = Enum.Material.Sand
		floor.Color = Color3.fromRGB(194,178,128)
		floor.Parent = WS
	end
	
	-- Terrain water
	local terrain = WS:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.WaterColor = Color3.fromRGB(0,150,255)
		terrain.WaterTransparency = 0.2
	end
	
	-- Tsunami - BRAINROT MEGA WAVE
	if tsunamiModel then tsunamiModel:Destroy() end
	tsunamiModel = Instance.new("Model")
	tsunamiModel.Name = "Tsunami"
	tsunamiModel.Parent = WS
	
	local wave = Instance.new("Part")
	wave.Name = "Wave"
	wave.Size = Vector3.new(400, 120, 50)
	wave.Position = Vector3.new(0, 30, -500)
	wave.Anchored = true
	wave.Material = Enum.Material.ForceField
	wave.Color = Color3.fromRGB(0, 200, 255)
	wave.Transparency = 0.3
	wave.CanCollide = false
	wave.Parent = tsunamiModel
	
	local foam = Instance.new("Part")
	foam.Name = "Foam"
	foam.Size = Vector3.new(400, 20, 10)
	foam.CFrame = wave.CFrame * CFrame.new(0, 60, 25)
	foam.Anchored = true
	foam.Material = Enum.Material.Neon
	foam.Color = Color3.fromRGB(255,255,255)
	foam.Transparency = 0.1
	foam.CanCollide = false
	foam.Parent = tsunamiModel
	
	tsunamiModel.PrimaryPart = wave
	
	GameState:FireAllClients("GameStarted", {
		playerFishId = fishChoice[p.UserId] or 1
	})
end)

local obstTimer = 0
RunService.Heartbeat:Connect(function(dt)
	if not active then return end
	tsunamiZ = tsunamiZ + 28 * dt
	if tsunamiModel and tsunamiModel.Parent and tsunamiModel.PrimaryPart then
		tsunamiModel.PrimaryPart.CFrame = CFrame.new(0, 30, tsunamiZ)
		local foam = tsunamiModel:FindFirstChild("Foam")
		if foam and foam:IsA("BasePart") then
			foam.CFrame = tsunamiModel.PrimaryPart.CFrame * CFrame.new(0, 60, 25)
		end
	end
	obstTimer = obstTimer + dt
	if obstTimer >= 1.5 then
		obstTimer = 0
		local obs = Instance.new("Part")
		obs.Size = Vector3.new(6,6,6) * (0.8 + math.random()*0.7)
		obs.Position = Vector3.new(math.random(-100,100), math.random(-40,20), math.random(0,400))
		obs.Anchored = true
		obs.Material = Enum.Material.Neon
		obs.Color = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
		obs.Parent = WS
		game:GetService("Debris"):AddItem(obs, 12)
	end
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if not active then return end
	for _, p in Players:GetPlayers() do
		local char = p.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local root = char.HumanoidRootPart
			if root.Position.Z < tsunamiZ + 25 then
				GameState:FireClient(p, "GameOver", { score = scores[p.UserId] or 0 })
				active = false
			else
				scores[p.UserId] = (scores[p.UserId] or 0) + 1
			end
		end
	end
end)

print("FISH ESCAPE TSUNAMI BRAINROT - 2999 FISH LOADED W")

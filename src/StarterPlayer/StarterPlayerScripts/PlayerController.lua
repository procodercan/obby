--[[
	PLAYER CONTROLLER - Client-side fish swimming & controls
	Escape Tsunami: Fish Edition
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FishData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FishData"))
local FishBuilder = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FishBuilder"))

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("GameRemotes")
local startGame = remotes:WaitForChild("StartGame")
local selectFish = remotes:WaitForChild("SelectFish")
local gameState = remotes:WaitForChild("GameState")

local selectedFishId = 1
local swimmingSpeed = 35
local boostMultiplier = 1.5
local isBoosting = false
local gameStarted = false

-- Replace player character with fish model when game starts
local function replaceWithFish()
	local fishData = FishData.getFish(selectedFishId)
	local fishModel = FishBuilder.createFishModel(fishData)
	
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	local root = character.HumanoidRootPart
	
	-- Position fish at player
	fishModel:SetPrimaryPartCFrame(root.CFrame)
	fishModel.Parent = Workspace
	
	-- Make humanoid invisible, attach to fish
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = 1
			part.CanCollide = false
		end
	end
	
	-- Weld character to fish body
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = fishModel.PrimaryPart
	weld.Part1 = root
	weld.Parent = root
	
	-- Store reference for movement
	root:SetAttribute("FishModel", fishModel:GetDebugId())
end

-- Swimming movement (client predicts, server validates)
local moveDirection = Vector3.new(0, 0, 1)
local lastInput = tick()

RunService.RenderStepped:Connect(function(dt)
	if not gameStarted then return end
	
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	
	local root = character.HumanoidRootPart
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	-- Gather input
	local forward = Vector3.new(0, 0, 1)
	local right = Vector3.new(1, 0, 0)
	local up = Vector3.new(0, 1, 0)
	
	local inputVec = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then inputVec = inputVec + forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then inputVec = inputVec - forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then inputVec = inputVec - right end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then inputVec = inputVec + right end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then inputVec = inputVec + up end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then inputVec = inputVec - up end
	
	if inputVec.Magnitude > 0 then
		moveDirection = inputVec.Unit
	end
	
	-- Apply movement
	local speed = swimmingSpeed * (isBoosting and boostMultiplier or 1)
	local move = moveDirection * speed * dt
	root.CFrame = root.CFrame + move
	
	-- Face movement direction
	local lookTarget = root.Position + moveDirection
	root.CFrame = CFrame.lookAt(root.Position, lookTarget)
end)

-- Boost on shift (handled above)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then isBoosting = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then isBoosting = false end
end)

-- Listen for game state
gameState.OnClientEvent:Connect(function(state, data)
	if state == "GameStarted" then
		gameStarted = true
		selectedFishId = data.playerFishId or 1
		replaceWithFish()
	elseif state == "GameOver" then
		gameStarted = false
		-- Character will respawn normally
	end
end)

-- Request fish selection before starting
selectFish.OnClientEvent:Connect(function(fishId)
	selectedFishId = fishId
end)

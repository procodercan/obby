-- PASTE INTO: StarterGui > Client (LocalScript)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local FishData = require(RS:WaitForChild("Modules"):WaitForChild("FishData"))
local FishBuilder = require(RS:WaitForChild("Modules"):WaitForChild("FishBuilder"))

local remotes = RS:WaitForChild("GameRemotes")
local StartGame = remotes:WaitForChild("StartGame")
local SelectFish = remotes:WaitForChild("SelectFish")
local GameState = remotes:WaitForChild("GameState")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local selectedFish = 1
local speed = 38
local boost = 1.6
local boosting = false
local playing = false
local moveDir = Vector3.new(0,0,1)

-- BRAINROT UI
local gui = Instance.new("ScreenGui")
gui.Name = "FishTsunamiUI"
gui.ResetOnSpawn = false
gui.Parent = pg

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(10,10,25)
bg.BackgroundTransparency = 0.5
bg.BorderSizePixel = 0
bg.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.9,0,0.12,0)
title.Position = UDim2.new(0.05,0,0.02,0)
title.BackgroundTransparency = 1
title.Text = "🐟 FISH ESCAPE TSUNAMI 🐟"
title.TextColor3 = Color3.fromRGB(255,100,150)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.TextStrokeColor3 = Color3.fromRGB(255,0,100)
title.TextStrokeTransparency = 0
title.Parent = gui

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(0.7,0,0.05,0)
sub.Position = UDim2.new(0.15,0,0.14,0)
sub.BackgroundTransparency = 1
sub.Text = "2999 FISH • SWIM OR DIE • NO CAP"
sub.TextColor3 = Color3.fromRGB(0,255,255)
sub.TextScaled = true
sub.Font = Enum.Font.GothamBold
sub.Parent = gui

local box = Instance.new("Frame")
box.Size = UDim2.new(0.5,0,0.22,0)
box.Position = UDim2.new(0.25,0,0.24,0)
box.BackgroundColor3 = Color3.fromRGB(30,20,60)
box.BorderSizePixel = 0
box.Parent = gui
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", box)
stroke.Color = Color3.fromRGB(255,0,200)
stroke.Thickness = 3

local boxTitle = Instance.new("TextLabel")
boxTitle.Size = UDim2.new(1,0,0.35,0)
boxTitle.BackgroundTransparency = 1
boxTitle.Text = "PICK UR FISH (1-2999)"
boxTitle.TextColor3 = Color3.fromRGB(255,200,255)
boxTitle.TextScaled = true
boxTitle.Font = Enum.Font.GothamBold
boxTitle.Parent = box

local input = Instance.new("TextBox")
input.Name = "FishInput"
input.Size = UDim2.new(0.55,0,0.28,0)
input.Position = UDim2.new(0.05,0,0.4,0)
input.BackgroundColor3 = Color3.fromRGB(60,30,100)
input.BorderSizePixel = 0
input.Text = "1"
input.PlaceholderText = "1-2999"
input.TextColor3 = Color3.fromRGB(255,255,255)
input.PlaceholderColor3 = Color3.fromRGB(150,150,150)
input.TextScaled = true
input.Font = Enum.Font.GothamBold
input.ClearTextOnFocus = false
input.Parent = box
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 10)

local randBtn = Instance.new("TextButton")
randBtn.Size = UDim2.new(0.3,0,0.25,0)
randBtn.Position = UDim2.new(0.65,0,0.38,0)
randBtn.BackgroundColor3 = Color3.fromRGB(255,50,150)
randBtn.BorderSizePixel = 0
randBtn.Text = "🎲 RANDOM"
randBtn.TextColor3 = Color3.fromRGB(255,255,255)
randBtn.TextScaled = true
randBtn.Font = Enum.Font.GothamBlack
randBtn.Parent = box
Instance.new("UICorner", randBtn).CornerRadius = UDim.new(0, 12)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.5,0,0.1,0)
startBtn.Position = UDim2.new(0.25,0,0.52,0)
startBtn.BackgroundColor3 = Color3.fromRGB(0,255,100)
startBtn.BorderSizePixel = 0
startBtn.Text = "▶ SWIM TO SURVIVE"
startBtn.TextColor3 = Color3.fromRGB(0,0,0)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBlack
startBtn.Parent = gui
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 14)
local startStroke = Instance.new("UIStroke", startBtn)
startStroke.Color = Color3.fromRGB(255,255,0)
startStroke.Thickness = 4

local scoreLbl = Instance.new("TextLabel")
scoreLbl.Size = UDim2.new(0.4,0,0.06,0)
scoreLbl.Position = UDim2.new(0.3,0,0.02,0)
scoreLbl.BackgroundTransparency = 1
scoreLbl.Text = "SURVIVED: 0 sec"
scoreLbl.TextColor3 = Color3.fromRGB(255,255,0)
scoreLbl.TextScaled = true
scoreLbl.Font = Enum.Font.GothamBlack
scoreLbl.Visible = false
scoreLbl.Parent = gui

local ctrlLbl = Instance.new("TextLabel")
ctrlLbl.Size = UDim2.new(0.8,0,0.05,0)
ctrlLbl.Position = UDim2.new(0.1,0,0.92,0)
ctrlLbl.BackgroundTransparency = 1
ctrlLbl.Text = "WASD MOVE • SPACE UP • SHIFT DOWN • DONT GET COOKED"
ctrlLbl.TextColor3 = Color3.fromRGB(0,255,255)
ctrlLbl.TextScaled = true
ctrlLbl.Font = Enum.Font.GothamBold
ctrlLbl.Visible = false
ctrlLbl.Parent = gui

local gameOver = Instance.new("Frame")
gameOver.Size = UDim2.new(1,0,1,0)
gameOver.BackgroundColor3 = Color3.fromRGB(0,0,0)
gameOver.BackgroundTransparency = 0.3
gameOver.Visible = false
gameOver.Parent = gui

local ripLbl = Instance.new("TextLabel")
ripLbl.Size = UDim2.new(0.9,0,0.15,0)
ripLbl.Position = UDim2.new(0.05,0,0.35,0)
ripLbl.BackgroundTransparency = 1
ripLbl.Text = "🌊 RIP BOZO 🌊"
ripLbl.TextColor3 = Color3.fromRGB(255,50,50)
ripLbl.TextScaled = true
ripLbl.Font = Enum.Font.GothamBlack
ripLbl.TextStrokeColor3 = Color3.fromRGB(255,255,0)
ripLbl.TextStrokeTransparency = 0
ripLbl.Parent = gameOver

local skillLbl = Instance.new("TextLabel")
skillLbl.Size = UDim2.new(0.8,0,0.1,0)
skillLbl.Position = UDim2.new(0.1,0,0.5,0)
skillLbl.BackgroundTransparency = 1
skillLbl.Text = "WAVE GOT YOU • SKILL ISSUE"
skillLbl.TextColor3 = Color3.fromRGB(255,200,100)
skillLbl.TextScaled = true
skillLbl.Font = Enum.Font.GothamBold
skillLbl.Parent = gameOver

local finalScore = Instance.new("TextLabel")
finalScore.Size = UDim2.new(0.6,0,0.08,0)
finalScore.Position = UDim2.new(0.2,0,0.62,0)
finalScore.BackgroundTransparency = 1
finalScore.Text = "You lasted: 0 seconds"
finalScore.TextColor3 = Color3.fromRGB(0,255,255)
finalScore.TextScaled = true
finalScore.Font = Enum.Font.GothamBold
finalScore.Parent = gameOver

-- Fish transform
local function becomeFish()
	local fd = FishData.getFish(selectedFish)
	local fish = FishBuilder.createFishModel(fd)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	fish:SetPrimaryPartCFrame(root.CFrame)
	fish.Parent = workspace
	for _, p in char:GetDescendants() do
		if p:IsA("BasePart") then
			p.Transparency = 1
			p.CanCollide = false
		end
	end
	local w = Instance.new("WeldConstraint")
	w.Part0 = fish.PrimaryPart
	w.Part1 = root
	w.Parent = root
end

-- Movement
RunService.RenderStepped:Connect(function(dt)
	if not playing then return end
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	local h = char:FindFirstChild("Humanoid")
	if not h or h.Health <= 0 then return end
	
	local inp = Vector3.zero
	if UIS:IsKeyDown(Enum.KeyCode.W) then inp = inp + Vector3.new(0,0,1) end
	if UIS:IsKeyDown(Enum.KeyCode.S) then inp = inp - Vector3.new(0,0,1) end
	if UIS:IsKeyDown(Enum.KeyCode.A) then inp = inp - Vector3.new(1,0,0) end
	if UIS:IsKeyDown(Enum.KeyCode.D) then inp = inp + Vector3.new(1,0,0) end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then inp = inp + Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then inp = inp - Vector3.new(0,1,0) end
	if inp.Magnitude > 0 then moveDir = inp.Unit end
	
	local spd = speed * (boosting and boost or 1)
	root.CFrame = root.CFrame + moveDir * spd * dt
	root.CFrame = CFrame.lookAt(root.Position, root.Position + moveDir)
end)

UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.LeftShift then boosting = true end end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.LeftShift then boosting = false end end)

-- UI handlers
local function getFishId()
	local n = tonumber(input.Text)
	return (n and n >= 1 and n <= 2999) and math.floor(n) or math.random(1,2999)
end

randBtn.MouseButton1Click:Connect(function()
	local id = math.random(1, FishData.getTotalCount())
	input.Text = tostring(id)
	SelectFish:FireServer(id)
end)

input.FocusLost:Connect(function()
	local id = getFishId()
	input.Text = tostring(id)
	SelectFish:FireServer(id)
end)

startBtn.MouseButton1Click:Connect(function()
	SelectFish:FireServer(getFishId())
	StartGame:FireServer()
	title.Visible = false
	sub.Visible = false
	box.Visible = false
	startBtn.Visible = false
	bg.Visible = false
	scoreLbl.Visible = true
	ctrlLbl.Visible = true
end)

local score = 0
GameState.OnClientEvent:Connect(function(state, data)
	if state == "GameStarted" then
		playing = true
		selectedFish = data.playerFishId or 1
		score = 0
		gameOver.Visible = false
		task.defer(becomeFish)
	elseif state == "GameOver" then
		playing = false
		score = data.score or 0
		finalScore.Text = "You lasted: " .. score .. " seconds"
		gameOver.Visible = true
		task.delay(4, function()
			gameOver.Visible = false
			title.Visible = true
			sub.Visible = true
			box.Visible = true
			startBtn.Visible = true
			bg.Visible = true
			scoreLbl.Visible = false
			ctrlLbl.Visible = false
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		if scoreLbl.Visible then
			score = score + 1
			scoreLbl.Text = "SURVIVED: " .. score .. " sec"
		end
	end
end)

SelectFish.OnClientEvent:Connect(function(id) selectedFish = id end)

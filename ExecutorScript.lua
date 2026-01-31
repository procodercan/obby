

(function()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- FISH DATA (2999 types)
local SPECIES = {"Clownfish","Angelfish","Betta","Goldfish","Piranha","Tuna","Salmon","Marlin","Swordfish","Seahorse","Jellyfish","Stingray","Barracuda","Tetra","Guppy","Koi","Catfish","Pufferfish","Manta","Lanternfish","Neon Tetra","Dragonfish","Rainbow Trout"}
local COLORS = {Color3.fromRGB(255,71,87),Color3.fromRGB(255,127,80),Color3.fromRGB(255,215,0),Color3.fromRGB(50,205,50),Color3.fromRGB(0,255,255),Color3.fromRGB(30,144,255),Color3.fromRGB(138,43,226),Color3.fromRGB(255,0,255),Color3.fromRGB(255,192,203),Color3.fromRGB(255,255,255),Color3.fromRGB(25,25,25),Color3.fromRGB(255,165,0),Color3.fromRGB(124,252,0)}
local PATTERNS = {"Solid","Striped","Spotted","Iridescent","Rainbow","Neon","Speckled","Banded","Ombre","BiColor"}
local function getFish(id)
	id = math.clamp(id,1,2999)
	local idx,s,c,p = id-1,(id-1)%#SPECIES+1,math.floor((id-1)/#SPECIES)%#COLORS+1,math.floor((id-1)/(#SPECIES*#COLORS))%#PATTERNS+1
	local prim = COLORS[c]
	local sec = Color3.new(math.clamp(prim.R+0.2,0,1),math.clamp(prim.G+0.1,0,1),math.clamp(prim.B+0.2,0,1))
	return {id=id,name=SPECIES[s].." #"..id,primaryColor=prim,secondaryColor=sec,size=(id%2==0) and 1.2 or 0.8}
end

-- CREATE FISH MODEL
local function makeFish(fd)
	local s = fd.size or 1
	local model = Instance.new("Model")
	model.Name = fd.name
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2*s,0.8*s,1.2*s)
	body.Shape = Enum.PartType.Ball
	body.Anchored = false
	body.CanCollide = true
	body.Color = fd.primaryColor
	body.Material = Enum.Material.Neon
	body.Parent = model
	local tail = Instance.new("Part")
	tail.Size = Vector3.new(0.3*s,1*s,1.5*s)
	tail.Anchored = false
	tail.Color = fd.secondaryColor
	tail.Material = Enum.Material.Neon
	tail.Parent = model
	tail.CFrame = body.CFrame*CFrame.new(0,0,-1.2)
	local w = Instance.new("WeldConstraint",tail)
	w.Part0 = body
	w.Part1 = tail
	model.PrimaryPart = body
	return model
end

-- CLEANUP OLD
for _,v in Workspace:GetChildren() do
	if v.Name=="Tsunami" or v.Name:find("FishTsunami") then v:Destroy() end
end
for _,v in pg:GetChildren() do
	if v.Name=="FishTsunamiUI" then v:Destroy() end
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "FishTsunamiUI"
gui.ResetOnSpawn = false
gui.Parent = pg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.9,0,0.1,0)
title.Position = UDim2.new(0.05,0,0.02,0)
title.BackgroundTransparency = 1
title.Text = "FISH ESCAPE TSUNAMI - 2999 FISH"
title.TextColor3 = Color3.fromRGB(255,100,150)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = gui

local box = Instance.new("Frame")
box.Size = UDim2.new(0.4,0,0.18,0)
box.Position = UDim2.new(0.3,0,0.18,0)
box.BackgroundColor3 = Color3.fromRGB(30,20,60)
box.BorderSizePixel = 0
box.Parent = gui
Instance.new("UICorner",box).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke",box).Color = Color3.fromRGB(255,0,200)

local input = Instance.new("TextBox")
input.Size = UDim2.new(0.5,0,0.3,0)
input.Position = UDim2.new(0.1,0,0.35,0)
input.BackgroundColor3 = Color3.fromRGB(60,30,100)
input.BorderSizePixel = 0
input.Text = "1"
input.PlaceholderText = "1-2999"
input.TextColor3 = Color3.fromRGB(255,255,255)
input.TextScaled = true
input.Font = Enum.Font.GothamBold
input.ClearTextOnFocus = false
input.Parent = box
Instance.new("UICorner",input).CornerRadius = UDim.new(0,8)

local randBtn = Instance.new("TextButton")
randBtn.Size = UDim2.new(0.35,0,0.3,0)
randBtn.Position = UDim2.new(0.55,0,0.32,0)
randBtn.BackgroundColor3 = Color3.fromRGB(255,50,150)
randBtn.BorderSizePixel = 0
randBtn.Text = "RANDOM"
randBtn.TextColor3 = Color3.fromRGB(255,255,255)
randBtn.TextScaled = true
randBtn.Font = Enum.Font.GothamBlack
randBtn.Parent = box
Instance.new("UICorner",randBtn).CornerRadius = UDim.new(0,10)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.45,0,0.09,0)
startBtn.Position = UDim2.new(0.275,0,0.42,0)
startBtn.BackgroundColor3 = Color3.fromRGB(0,255,100)
startBtn.BorderSizePixel = 0
startBtn.Text = "SWIM TO SURVIVE"
startBtn.TextColor3 = Color3.fromRGB(0,0,0)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBlack
startBtn.Parent = gui
Instance.new("UICorner",startBtn).CornerRadius = UDim.new(0,12)

local scoreLbl = Instance.new("TextLabel")
scoreLbl.Size = UDim2.new(0.35,0,0.05,0)
scoreLbl.Position = UDim2.new(0.325,0,0.02,0)
scoreLbl.BackgroundTransparency = 1
scoreLbl.Text = "SURVIVED: 0"
scoreLbl.TextColor3 = Color3.fromRGB(255,255,0)
scoreLbl.TextScaled = true
scoreLbl.Font = Enum.Font.GothamBlack
scoreLbl.Visible = false
scoreLbl.Parent = gui

local gameOver = Instance.new("Frame")
gameOver.Size = UDim2.new(1,0,1,0)
gameOver.BackgroundColor3 = Color3.fromRGB(0,0,0)
gameOver.BackgroundTransparency = 0.4
gameOver.Visible = false
gameOver.Parent = gui

local ripLbl = Instance.new("TextLabel")
ripLbl.Size = UDim2.new(0.8,0,0.12,0)
ripLbl.Position = UDim2.new(0.1,0,0.4,0)
ripLbl.BackgroundTransparency = 1
ripLbl.Text = "RIP - WAVE GOT YOU"
ripLbl.TextColor3 = Color3.fromRGB(255,50,50)
ripLbl.TextScaled = true
ripLbl.Font = Enum.Font.GothamBlack
ripLbl.Parent = gameOver

local finalScore = Instance.new("TextLabel")
finalScore.Size = UDim2.new(0.6,0,0.06,0)
finalScore.Position = UDim2.new(0.2,0,0.54,0)
finalScore.BackgroundTransparency = 1
finalScore.Text = "Lasted: 0 sec"
finalScore.TextColor3 = Color3.fromRGB(0,255,255)
finalScore.TextScaled = true
finalScore.Font = Enum.Font.GothamBold
finalScore.Parent = gameOver

-- GAME STATE
local selectedFish = 1
local speed = 38
local boosting = false
local playing = false
local moveDir = Vector3.new(0,0,1)
local score = 0
local tsunamiZ = -200
local tsunamiModel = nil

-- BECOME FISH
local function becomeFish()
	local fd = getFish(selectedFish)
	local fish = makeFish(fd)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	fish:SetPrimaryPartCFrame(root.CFrame)
	fish.Parent = Workspace
	for _,p in char:GetDescendants() do
		if p:IsA("BasePart") then p.Transparency=1 p.CanCollide=false end
	end
	local w = Instance.new("WeldConstraint")
	w.Part0 = fish.PrimaryPart
	w.Part1 = root
	w.Parent = root
end

-- SPAWN TSUNAMI
local function spawnTsunami()
	if tsunamiModel then tsunamiModel:Destroy() end
	tsunamiModel = Instance.new("Model")
	tsunamiModel.Name = "Tsunami"
	tsunamiModel.Parent = Workspace
	local wave = Instance.new("Part")
	wave.Name = "Wave"
	wave.Size = Vector3.new(300,80,40)
	wave.Position = Vector3.new(0,25,tsunamiZ)
	wave.Anchored = true
	wave.Material = Enum.Material.ForceField
	wave.Color = Color3.fromRGB(0,180,255)
	wave.Transparency = 0.35
	wave.CanCollide = false
	wave.Parent = tsunamiModel
	local foam = Instance.new("Part")
	foam.Size = Vector3.new(300,15,8)
	foam.CFrame = wave.CFrame*CFrame.new(0,40,20)
	foam.Anchored = true
	foam.Material = Enum.Material.Neon
	foam.Color = Color3.fromRGB(255,255,255)
	foam.Transparency = 0.2
	foam.CanCollide = false
	foam.Name = "Foam"
	foam.Parent = tsunamiModel
	tsunamiModel.PrimaryPart = wave
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function(dt)
	if not playing then return end
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	
	-- Move tsunami
	tsunamiZ = tsunamiZ + 26*dt
	if tsunamiModel and tsunamiModel.Parent and tsunamiModel.PrimaryPart then
		tsunamiModel.PrimaryPart.CFrame = CFrame.new(0,25,tsunamiZ)
		local f = tsunamiModel:FindFirstChild("Foam")
		if f and f~=tsunamiModel.PrimaryPart and f:IsA("BasePart") then
			f.CFrame = tsunamiModel.PrimaryPart.CFrame*CFrame.new(0,40,20)
		end
	end
	
	-- Input
	local inp = Vector3.zero
	if UIS:IsKeyDown(Enum.KeyCode.W) then inp = inp + Vector3.new(0,0,1) end
	if UIS:IsKeyDown(Enum.KeyCode.S) then inp = inp - Vector3.new(0,0,1) end
	if UIS:IsKeyDown(Enum.KeyCode.A) then inp = inp - Vector3.new(1,0,0) end
	if UIS:IsKeyDown(Enum.KeyCode.D) then inp = inp + Vector3.new(1,0,0) end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then inp = inp + Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then inp = inp - Vector3.new(0,1,0) end
	if inp.Magnitude>0 then moveDir = inp.Unit end
	
	-- Move player
	local spd = speed * (boosting and 1.5 or 1)
	root.CFrame = root.CFrame + moveDir*spd*dt
	root.CFrame = CFrame.lookAt(root.Position, root.Position + moveDir)
	
	-- Caught?
	if root.Position.Z < tsunamiZ + 30 then
		playing = false
		finalScore.Text = "Lasted: "..score.." sec"
		gameOver.Visible = true
		task.delay(4, function()
			gameOver.Visible = false
			title.Visible = true
			box.Visible = true
			startBtn.Visible = true
			scoreLbl.Visible = false
		end)
	end
end)

UIS.InputBegan:Connect(function(i) if i.KeyCode==Enum.KeyCode.LeftShift then boosting=true end end)
UIS.InputEnded:Connect(function(i) if i.KeyCode==Enum.KeyCode.LeftShift then boosting=false end end)

-- UI
randBtn.MouseButton1Click:Connect(function()
	local id = math.random(1,2999)
	input.Text = tostring(id)
	selectedFish = id
end)

local function getFishId()
	local n = tonumber(input.Text)
	return (n and n>=1 and n<=2999) and math.floor(n) or math.random(1,2999)
end

input.FocusLost:Connect(function()
	selectedFish = getFishId()
	input.Text = tostring(selectedFish)
end)

startBtn.MouseButton1Click:Connect(function()
	selectedFish = getFishId()
	input.Text = tostring(selectedFish)
	tsunamiZ = -200
	score = 0
	spawnTsunami()
	playing = true
	title.Visible = false
	box.Visible = false
	startBtn.Visible = false
	scoreLbl.Visible = true
	gameOver.Visible = false
	task.defer(becomeFish)
end)

task.spawn(function()
	while true do
		task.wait(1)
		if playing and scoreLbl.Visible then
			score = score + 1
			scoreLbl.Text = "SURVIVED: "..score
		end
	end
end)

print("FISH ESCAPE TSUNAMI - Executor loaded. Pick fish, click SWIM.")
end)()
--[[
	MAIN UI - Escape Tsunami: Fish Edition
	Fish selector, start button, score, game over screen
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local FishData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FishData"))
local remotes = ReplicatedStorage:WaitForChild("GameRemotes")
local startGame = remotes:WaitForChild("StartGame")
local selectFish = remotes:WaitForChild("SelectFish")
local gameState = remotes:WaitForChild("GameState")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EscapeTsunamiUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0.6, 0, 0.15, 0)
title.Position = UDim2.new(0.2, 0, 0.02, 0)
title.BackgroundTransparency = 1
title.Text = "🐟 ESCAPE TSUNAMI 🐟"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextStrokeColor3 = Color3.fromRGB(0, 100, 180)
title.TextStrokeTransparency = 0.3
title.Parent = screenGui

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(0.5, 0, 0.05, 0)
subtitle.Position = UDim2.new(0.25, 0, 0.16, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "2,999 Fish • Swim to Survive"
subtitle.TextColor3 = Color3.fromRGB(200, 230, 255)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = screenGui

-- Fish selector frame
local selectorFrame = Instance.new("Frame")
selectorFrame.Name = "FishSelector"
selectorFrame.Size = UDim2.new(0.4, 0, 0.25, 0)
selectorFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
selectorFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
selectorFrame.BackgroundTransparency = 0.3
selectorFrame.BorderSizePixel = 0
selectorFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.12, 0)
corner.Parent = selectorFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = selectorFrame

local selectorTitle = Instance.new("TextLabel")
selectorTitle.Size = UDim2.new(1, 0, 0.3, 0)
selectorTitle.Position = UDim2.new(0, 0, 0, 0)
selectorTitle.BackgroundTransparency = 1
selectorTitle.Text = "Choose Your Fish"
selectorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
selectorTitle.TextScaled = true
selectorTitle.Font = Enum.Font.GothamBold
selectorTitle.Parent = selectorFrame

local fishIdInput = Instance.new("TextBox")
fishIdInput.Name = "FishIdInput"
fishIdInput.Size = UDim2.new(0.6, 0, 0.25, 0)
fishIdInput.Position = UDim2.new(0.2, 0, 0.35, 0)
fishIdInput.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
fishIdInput.BorderSizePixel = 0
fishIdInput.Text = "1"
fishIdInput.PlaceholderText = "1 - 2999"
fishIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
fishIdInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
fishIdInput.TextScaled = true
fishIdInput.Font = Enum.Font.Gotham
fishIdInput.ClearTextOnFocus = false
fishIdInput.Parent = selectorFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0.2, 0)
inputCorner.Parent = fishIdInput

local randomBtn = Instance.new("TextButton")
randomBtn.Name = "RandomBtn"
randomBtn.Size = UDim2.new(0.25, 0, 0.2, 0)
randomBtn.Position = UDim2.new(0.75, 0, 0.38, 0)
randomBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
randomBtn.BorderSizePixel = 0
randomBtn.Text = "🎲"
randomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
randomBtn.TextScaled = true
randomBtn.Font = Enum.Font.GothamBold
randomBtn.Parent = selectorFrame

local randomCorner = Instance.new("UICorner")
randomCorner.CornerRadius = UDim.new(0.3, 0)
randomCorner.Parent = randomBtn

-- Start button
local startBtn = Instance.new("TextButton")
startBtn.Name = "StartButton"
startBtn.Size = UDim2.new(0.35, 0, 0.12, 0)
startBtn.Position = UDim2.new(0.325, 0, 0.55, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
startBtn.BorderSizePixel = 0
startBtn.Text = "▶ SWIM TO SURVIVE"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBold
startBtn.Parent = screenGui

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0.15, 0)
startCorner.Parent = startBtn

local startStroke = Instance.new("UIStroke")
startStroke.Color = Color3.fromRGB(255, 200, 100)
startStroke.Thickness = 3
startStroke.Parent = startBtn

-- Score display (hidden initially)
local scoreLabel = Instance.new("TextLabel")
scoreLabel.Name = "Score"
scoreLabel.Size = UDim2.new(0.3, 0, 0.08, 0)
scoreLabel.Position = UDim2.new(0.35, 0, 0.02, 0)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "Survival: 0"
scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
scoreLabel.TextScaled = true
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.Visible = false
scoreLabel.Parent = screenGui

-- Controls hint
local controlsHint = Instance.new("TextLabel")
controlsHint.Size = UDim2.new(0.5, 0, 0.08, 0)
controlsHint.Position = UDim2.new(0.25, 0, 0.88, 0)
controlsHint.BackgroundTransparency = 1
controlsHint.Text = "WASD • Space=Up • Shift=Down • Swim away from the wave!"
controlsHint.TextColor3 = Color3.fromRGB(180, 220, 255)
controlsHint.TextScaled = true
controlsHint.Font = Enum.Font.Gotham
controlsHint.Visible = false
controlsHint.Parent = screenGui

-- Game over overlay
local gameOverFrame = Instance.new("Frame")
gameOverFrame.Name = "GameOver"
gameOverFrame.Size = UDim2.new(1, 0, 1, 0)
gameOverFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
gameOverFrame.BackgroundTransparency = 0.6
gameOverFrame.BorderSizePixel = 0
gameOverFrame.Visible = false
gameOverFrame.Parent = screenGui

local gameOverLabel = Instance.new("TextLabel")
gameOverLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
gameOverLabel.Position = UDim2.new(0.1, 0, 0.35, 0)
gameOverLabel.BackgroundTransparency = 1
gameOverLabel.Text = "🌊 CAUGHT BY THE TSUNAMI! 🌊"
gameOverLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gameOverLabel.TextScaled = true
gameOverLabel.Font = Enum.Font.GothamBold
gameOverLabel.Parent = gameOverFrame

local finalScoreLabel = Instance.new("TextLabel")
finalScoreLabel.Size = UDim2.new(0.6, 0, 0.15, 0)
finalScoreLabel.Position = UDim2.new(0.2, 0, 0.5, 0)
finalScoreLabel.BackgroundTransparency = 1
finalScoreLabel.Text = "You survived: 0 seconds"
finalScoreLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
finalScoreLabel.TextScaled = true
finalScoreLabel.Font = Enum.Font.Gotham
finalScoreLabel.Parent = gameOverFrame

-- Button click handlers
local function getFishId()
	local text = fishIdInput.Text
	local id = tonumber(text)
	if id and id >= 1 and id <= 2999 then
		return math.floor(id)
	end
	return math.random(1, 2999)
end

randomBtn.MouseButton1Click:Connect(function()
	local id = math.random(1, FishData.getTotalCount())
	fishIdInput.Text = tostring(id)
	selectFish:FireServer(id)
end)

fishIdInput.FocusLost:Connect(function()
	local id = getFishId()
	fishIdInput.Text = tostring(id)
	selectFish:FireServer(id)
end)

startBtn.MouseButton1Click:Connect(function()
	selectFish:FireServer(getFishId())
	startGame:FireServer()
	
	-- Hide menu, show in-game UI
	title.Visible = false
	subtitle.Visible = false
	selectorFrame.Visible = false
	startBtn.Visible = false
	scoreLabel.Visible = true
	controlsHint.Visible = true
end)

-- Game state handling
local score = 0
gameState.OnClientEvent:Connect(function(state, data)
	if state == "GameStarted" then
		score = 0
		gameOverFrame.Visible = false
	elseif state == "GameOver" then
		score = data.score or 0
		finalScoreLabel.Text = "You survived: " .. score .. " seconds!"
		gameOverFrame.Visible = true
		
		-- Show menu again after 3 seconds
		task.delay(3, function()
			title.Visible = true
			subtitle.Visible = true
			selectorFrame.Visible = true
			startBtn.Visible = true
			scoreLabel.Visible = false
			controlsHint.Visible = false
			gameOverFrame.Visible = false
		end)
	end
end)

-- Update score every second during gameplay
task.spawn(function()
	while true do
		task.wait(1)
		if scoreLabel.Visible then
			score = score + 1
			scoreLabel.Text = "Survival: " .. score
		end
	end
end)

-- Coin Rush HUD + coin animation (all client-side, purely visual).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local roundRemote = ReplicatedStorage:WaitForChild("RoundUpdate")

local gui = Instance.new("ScreenGui")
gui.Name = "CoinRushHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeLabel(name, size, position, textSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.35
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize
	label.TextScaled = false
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	return label
end

local statusLabel = makeLabel("Status", UDim2.fromOffset(420, 44), UDim2.new(0.5, 0, 0, 12), 22)
local timerLabel = makeLabel("Timer", UDim2.fromOffset(120, 40), UDim2.new(0.5, 0, 0, 62), 24)
local coinLabel = makeLabel("MyCoins", UDim2.fromOffset(180, 40), UDim2.new(0.5, 0, 1, -56), 22)
coinLabel.TextColor3 = Color3.fromRGB(255, 220, 60)
timerLabel.Visible = false

roundRemote.OnClientEvent:Connect(function(status, seconds)
	statusLabel.Text = status
	if seconds > 0 then
		timerLabel.Visible = true
		timerLabel.Text = string.format("%d:%02d", seconds // 60, seconds % 60)
	else
		timerLabel.Visible = false
	end
end)

-- Show the local player's coin count for the current round.
task.spawn(function()
	local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")
	local function update()
		coinLabel.Text = "Coins: " .. coins.Value
	end
	update()
	coins.Changed:Connect(update)
end)

-- Spin and bob every coin locally (the server keeps them still).
local tracked = {}
local function track(part)
	if part:IsA("BasePart") then
		tracked[part] = part.Position
	end
end
CollectionService:GetInstanceAddedSignal("Coin"):Connect(track)
CollectionService:GetInstanceRemovedSignal("Coin"):Connect(function(part)
	tracked[part] = nil
end)
for _, part in CollectionService:GetTagged("Coin") do
	track(part)
end

RunService.RenderStepped:Connect(function()
	local t = os.clock() * 2.5
	for part, origin in tracked do
		part.CFrame = CFrame.new(origin.X, origin.Y + math.sin(t + origin.X) * 0.4, origin.Z) * CFrame.Angles(0, t, 0)
	end
end)

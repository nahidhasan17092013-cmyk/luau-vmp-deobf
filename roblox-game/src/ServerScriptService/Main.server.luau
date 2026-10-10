-- Coin Rush: builds the arena at runtime and runs the round loop.
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local roundRemote = Instance.new("RemoteEvent")
roundRemote.Name = "RoundUpdate"
roundRemote.Parent = ReplicatedStorage

local winsStore = DataStoreService:GetDataStore("CoinRushWins_v1")

local half = Config.ARENA_SIZE / 2
local roundActive = false
local lastState = { "Waiting for players...", 0 }

----------------------------------------------------------------------
-- Arena
----------------------------------------------------------------------

Lighting.ClockTime = 14

local arena = Instance.new("Folder")
arena.Name = "Arena"
arena.Parent = workspace

local coinFolder = Instance.new("Folder")
coinFolder.Name = "Coins"
coinFolder.Parent = workspace

local function newPart(name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = arena
	return part
end

local function killOnTouch(part)
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)
end

-- Floor (top surface at y = 0)
newPart(
	"Floor",
	Vector3.new(Config.ARENA_SIZE, 2, Config.ARENA_SIZE),
	Vector3.new(0, -1, 0),
	Color3.fromRGB(88, 140, 80),
	Enum.Material.Grass
)

-- Kill plane in case anyone ends up below the map
local killPlane = newPart("KillPlane", Vector3.new(2000, 2, 2000), Vector3.new(0, -60, 0), Color3.new(0, 0, 0))
killPlane.Transparency = 1
killPlane.CanCollide = false
killOnTouch(killPlane)

-- Low translucent walls so nobody walks off the edge
for _, side in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
	local sx, sz = side[1], side[2]
	local wall = newPart(
		"Wall",
		Vector3.new(sx ~= 0 and 2 or Config.ARENA_SIZE, 24, sz ~= 0 and 2 or Config.ARENA_SIZE),
		Vector3.new(sx * (half + 1), 12, sz * (half + 1)),
		Color3.fromRGB(120, 180, 255),
		Enum.Material.Glass
	)
	wall.Transparency = 0.6
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Anchored = true
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 0.5, 0)
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Color3.fromRGB(255, 255, 255)
spawn.Parent = arena

-- Lava pools: { centerX, centerZ, width, depth }
local lavaPools = {
	{ 40, 40, 30, 30 },
	{ -45, 30, 24, 36 },
	{ 30, -50, 36, 20 },
	{ -40, -40, 28, 28 },
}
for _, pool in lavaPools do
	local lava = newPart(
		"Lava",
		Vector3.new(pool[3], 0.4, pool[4]),
		Vector3.new(pool[1], 0.2, pool[2]),
		Color3.fromRGB(255, 90, 20),
		Enum.Material.Neon
	)
	killOnTouch(lava)
end

-- Jump pads that launch players up to floating platforms.
-- Each platform sits 14 studs to the +X side of its pad (reachable with a bit of air steering).
local padCooldown = setmetatable({}, { __mode = "k" })
local platformTops = {} -- { center = Vector3, halfX = number, halfZ = number }
local towerSpots = {
	{ -80, 0 },
	{ -30, -70 },
	{ 20, 75 },
	{ 75, 10 },
	{ -75, 70 },
	{ 60, -75 },
}
local PLATFORM_Y = 15
for _, spot in towerSpots do
	local x, z = spot[1], spot[2]

	local pad = newPart(
		"JumpPad",
		Vector3.new(8, 0.6, 8),
		Vector3.new(x, 0.3, z),
		Color3.fromRGB(0, 255, 120),
		Enum.Material.Neon
	)
	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root or humanoid.Health <= 0 or padCooldown[character] then
			return
		end
		padCooldown[character] = true
		local v = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(v.X, Config.JUMP_PAD_VELOCITY, v.Z)
		task.delay(0.8, function()
			padCooldown[character] = nil
		end)
	end)

	local platform = newPart(
		"Platform",
		Vector3.new(14, 1.5, 14),
		Vector3.new(x + 14, PLATFORM_Y, z),
		Color3.fromRGB(255, 220, 90),
		Enum.Material.Metal
	)
	table.insert(platformTops, {
		center = Vector3.new(platform.Position.X, PLATFORM_Y + 0.75, platform.Position.Z),
		halfX = 5,
		halfZ = 5,
	})
end

----------------------------------------------------------------------
-- Coins
----------------------------------------------------------------------

local rng = Random.new()

local function insideLava(x, z)
	for _, pool in lavaPools do
		if math.abs(x - pool[1]) < pool[3] / 2 + 3 and math.abs(z - pool[2]) < pool[4] / 2 + 3 then
			return true
		end
	end
	return false
end

-- Returns position, isGolden
local function randomCoinSpot()
	if rng:NextNumber() < 0.3 then
		local top = platformTops[rng:NextInteger(1, #platformTops)]
		local offset = Vector3.new(
			rng:NextNumber(-top.halfX, top.halfX),
			3,
			rng:NextNumber(-top.halfZ, top.halfZ)
		)
		return top.center + offset, true
	end

	local limit = half - 8
	for _ = 1, 20 do
		local x = rng:NextNumber(-limit, limit)
		local z = rng:NextNumber(-limit, limit)
		if not insideLava(x, z) then
			return Vector3.new(x, 2.5, z), rng:NextNumber() < Config.GOLD_CHANCE
		end
	end
	return Vector3.new(0, 2.5, 15), false
end

local spawnRandomCoin

local function collectCoin(coin, hit)
	if not roundActive or coin:GetAttribute("Collected") then
		return
	end
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	local stats = player and player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	if not coins then
		return
	end

	coin:SetAttribute("Collected", true)
	coins.Value += coin:GetAttribute("Value")
	coin:Destroy()
	spawnRandomCoin()
end

function spawnRandomCoin()
	local position, golden = randomCoinSpot()

	local coin = Instance.new("Part")
	coin.Name = golden and "GoldCoin" or "Coin"
	coin.Shape = Enum.PartType.Cylinder -- axis along X, so the disc stands upright
	coin.Size = Vector3.new(0.5, 3, 3)
	coin.Anchored = true
	coin.CanCollide = false
	coin.Material = Enum.Material.Neon
	coin.Color = golden and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 235, 60)
	coin.Position = position
	coin:SetAttribute("Value", golden and Config.GOLD_VALUE or Config.COIN_VALUE)
	CollectionService:AddTag(coin, "Coin") -- clients spin and bob tagged coins locally
	coin.Touched:Connect(function(hit)
		collectCoin(coin, hit)
	end)
	coin.Parent = coinFolder
end

local function clearCoins()
	coinFolder:ClearAllChildren()
end

----------------------------------------------------------------------
-- Players / persistence
----------------------------------------------------------------------

local function setupPlayer(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = stats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Parent = stats
	stats.Parent = player

	local ok, saved = pcall(function()
		return winsStore:GetAsync(tostring(player.UserId))
	end)
	if ok and typeof(saved) == "number" then
		wins.Value = saved
	elseif not ok then
		warn("Could not load wins for " .. player.Name .. ": " .. tostring(saved))
	end

	roundRemote:FireClient(player, lastState[1], lastState[2])
end

local function savePlayer(player)
	local stats = player:FindFirstChild("leaderstats")
	local wins = stats and stats:FindFirstChild("Wins")
	if not wins then
		return
	end
	local ok, err = pcall(function()
		winsStore:SetAsync(tostring(player.UserId), wins.Value)
	end)
	if not ok then
		warn("Could not save wins for " .. player.Name .. ": " .. tostring(err))
	end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(savePlayer)
for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		savePlayer(player)
	end
end)

----------------------------------------------------------------------
-- Round loop
----------------------------------------------------------------------

local function broadcast(status, seconds)
	lastState = { status, seconds }
	roundRemote:FireAllClients(status, seconds)
end

local function startRound()
	for _, player in Players:GetPlayers() do
		local coins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = 0
		end
		task.spawn(function()
			player:LoadCharacter() -- fresh start at the spawn pad
		end)
	end
	roundActive = true
	for _ = 1, Config.COIN_COUNT do
		spawnRandomCoin()
	end
end

local function endRound()
	roundActive = false
	clearCoins()

	local best, winners = 0, {}
	for _, player in Players:GetPlayers() do
		local stats = player:FindFirstChild("leaderstats")
		local coins = stats and stats:FindFirstChild("Coins")
		if coins and coins.Value > best then
			best = coins.Value
			winners = { player }
		elseif coins and coins.Value == best and best > 0 then
			table.insert(winners, player)
		end
	end

	if #winners == 0 then
		broadcast("Nobody collected any coins!", 0)
		return
	end

	local names = {}
	for _, winner in winners do
		table.insert(names, winner.Name)
		winner.leaderstats.Wins.Value += 1
	end
	broadcast(table.concat(names, " & ") .. " won with " .. best .. " coins!", 0)
end

while true do
	while #Players:GetPlayers() < Config.MIN_PLAYERS do
		broadcast("Waiting for players...", 0)
		task.wait(1)
	end

	for t = Config.INTERMISSION, 1, -1 do
		broadcast("Next round in", t)
		task.wait(1)
	end

	startRound()
	for t = Config.ROUND_LENGTH, 1, -1 do
		broadcast("Collect the coins!", t)
		task.wait(1)
	end

	endRound()
	task.wait(Config.RESULT_TIME)
end

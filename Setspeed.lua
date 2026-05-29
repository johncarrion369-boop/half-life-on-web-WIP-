local allowedPlaceId = 79546208627805
if game.PlaceId ~= allowedPlaceId then
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local spawnRemote = ReplicatedStorage:FindFirstChild("SpawnRequest")
if not spawnRemote then
    spawnRemote = Instance.new("RemoteEvent")
    spawnRemote.Name = "SpawnRequest"
    spawnRemote.Parent = ReplicatedStorage
end

spawnRemote.OnServerEvent:Connect(function(player, itemName)
    if typeof(itemName) ~= "string" then
        return
    end

    local spawnPos
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        spawnPos = hrp.Position + Vector3.new(0, 5, 0)
    else
        spawnPos = Vector3.new(0, 5, 0)
    end

    local item = Instance.new("Part")
    item.Size = Vector3.new(4, 4, 4)
    item.Anchored = false
    item.Position = spawnPos
    item.Name = itemName
    item.BrickColor = BrickColor.random()
    item.Parent = workspace

    if itemName == "Ball" then
        item.Shape = Enum.PartType.Ball
    elseif itemName == "Plate" then
        item.Size = Vector3.new(6, 1, 6)
        item.Anchored = true
    elseif itemName == "Tower" then
        item.Size = Vector3.new(4, 16, 4)
    end
end)

local function createGuiForPlayer(player)
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpawnUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 320)
    frame.Position = UDim2.new(0, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = "Spawn Menu"
    title.Parent = frame

    local function addButton(name, text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -20, 0, 36)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 18
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text
        btn.Parent = frame
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    addButton("SpawnBlock", "Spawn Block", 50, function()
        spawnRemote:FireServer("Block")
    end)

    addButton("SpawnBall", "Spawn Ball", 100, function()
        spawnRemote:FireServer("Ball")
    end)

    addButton("SpawnTower", "Spawn Tower", 150, function()
        spawnRemote:FireServer("Tower")
    end)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 24)
    speedLabel.Position = UDim2.new(0, 10, 0, 210)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 16
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.Text = "Speed: 16"
    speedLabel.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -20, 0, 34)
    slider.Position = UDim2.new(0, 10, 0, 240)
    slider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    slider.BorderSizePixel = 0
    slider.Font = Enum.Font.Gotham
    slider.TextSize = 16
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.Text = "Increase Speed"
    slider.Parent = frame

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, -20, 0, 34)
    resetBtn.Position = UDim2.new(0, 10, 0, 280)
    resetBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    resetBtn.BorderSizePixel = 0
    resetBtn.Font = Enum.Font.Gotham
    resetBtn.TextSize = 16
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.Text = "Reset Speed"
    resetBtn.Parent = frame

    local localScript = Instance.new("LocalScript")
    localScript.Source = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("SpawnRequest")
local player = Players.LocalPlayer

local frame = script.Parent:FindFirstChildOfClass("Frame")
local speedLabel = frame and frame:FindFirstChild("TextLabel")
local increaseButton = frame and frame:FindFirstChild("Increase Speed")
local resetButton = frame and frame:FindFirstChild("Reset Speed")

for _, button in ipairs(frame:GetChildren()) do
    if button:IsA("TextButton") and button.Text == "Spawn Block" then
        button.MouseButton1Click:Connect(function()
            remote:FireServer("Block")
        end)
    elseif button:IsA("TextButton") and button.Text == "Spawn Ball" then
        button.MouseButton1Click:Connect(function()
            remote:FireServer("Ball")
        end)
    elseif button:IsA("TextButton") and button.Text == "Spawn Tower" then
        button.MouseButton1Click:Connect(function()
            remote:FireServer("Tower")
        end)
    end
end

local function updateSpeedLabel(value)
    if speedLabel then
        speedLabel.Text = "Speed: " .. tostring(value)
    end
end

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function setSpeed(amount)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = math.clamp(amount, 8, 100)
        updateSpeedLabel(humanoid.WalkSpeed)
    end
end

if frame then
    for _, btn in ipairs(frame:GetChildren()) do
        if btn:IsA("TextButton") and btn.Text == "Increase Speed" then
            btn.MouseButton1Click:Connect(function()
                local humanoid = getHumanoid()
                if humanoid then
                    setSpeed(humanoid.WalkSpeed + 4)
                end
            end)
        elseif btn:IsA("TextButton") and btn.Text == "Reset Speed" then
            btn.MouseButton1Click:Connect(function()
                setSpeed(16)
            end)
        end
    end
end
]]
    localScript.Parent = screenGui
end

Players.PlayerAdded:Connect(createGuiForPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    createGuiForPlayer(player)
end
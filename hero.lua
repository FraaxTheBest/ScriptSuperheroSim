local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local lPlayer = Players.LocalPlayer
local pGui = lPlayer:WaitForChild("PlayerGui") -- Spostato qui per garantire la massima compatibilità su Delta
local askCoinRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AskCoin")
local spawnersFolder = Workspace:WaitForChild("CoinSpawners")

_G.FarmingAttivo = false
local TARGET_LOOPS = 250
local SPAWNER_NAME = "50000000000000"

-- ==========================================
-- ROUTINE ANTI-AFK REALE (Bypass 20 Minuti)
-- ==========================================
local function InizializzaAntiAFK()
    local ok, err = pcall(function()
        local virtualUser = game:GetService("VirtualUser")
        lPlayer.Idled:Connect(function()
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new(0, 0))
            print("[ANTI-AFK] Input simulato con successo per prevenire il kick!")
        end)
    end)
    if ok then print("[ANTI-AFK] Sistema di prevenzione attivo.") else print("[ANTI-AFK] Errore:", err) end
end

-- ==========================================
-- LOGICA DI RACCOLTA MONETE
-- ==========================================
local spawnerInstances = {}
local children = spawnersFolder:GetChildren()
for i = 1, #children do
    local child = children[i]
    if child.Name == SPAWNER_NAME then
        table.insert(spawnerInstances, child)
    end
end

local function runRoutine(targetSpawner)
    local char = lPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    hrp.CFrame = targetSpawner.CFrame
    task.wait(0.15) 
    
    for i = 1, TARGET_LOOPS do
        if not _G.FarmingAttivo then break end
        askCoinRemote:FireServer(targetSpawner)
        RunService.Heartbeat:Wait()
    end
end

local function AvviaLoopFarming()
    task.spawn(function()
        print("[CORE] Loop farming attivato.")
        while _G.FarmingAttivo do
            for idx = 1, #spawnerInstances do
                local instance = spawnerInstances[idx]
                if not _G.FarmingAttivo then break end
                runRoutine(instance)
                task.wait(0.3)
            end
            task.wait(1.5) 
        end
        print("[CORE] Loop farming terminato.")
    end)
end

-- ==========================================
-- CREAZIONE INTERFACCIA GRAFICA (GUI)
-- ==========================================
local function CreaInterfaccia()
    local screenName = "SuperheroSim_50T_Gui"
    local vecchioScreen = pGui:FindFirstChild(screenName)
    if vecchioScreen then vecchioScreen:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = screenName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = pGui

    -- Frame Principale
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 220, 0, 160) -- <--- CORRETTO: Scritto UDim2.new (Rimosso UUDim2)
    MainFrame.Position = UDim2.new(0.5, -110, 0.4, -80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    -- Sistema di trascinamento touch nativo per Mobile (Rimpiazza .Draggable rotto)
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 10)
    FrameCorner.Parent = MainFrame

    -- Titolo GUI
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.Text = "TRIXADE 50T MANAGER"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    -- Pulsante START / STOP Farming
    local FarmButton = Instance.new("TextButton")
    FarmButton.Name = "FarmButton"
    FarmButton.Size = UDim2.new(0, 180, 0, 40)
    FarmButton.Position = UDim2.new(0.5, -90, 0, 50)
    FarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FarmButton.Text = "FARMING: DISATTIVATO"
    FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmButton.TextSize = 14
    FarmButton.Font = Enum.Font.SourceSansBold
    FarmButton.Parent = MainFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = FarmButton

    -- Stato dell'Anti-AFK
    local AfkStatus = Instance.new("TextLabel")
    AfkStatus.Name = "AfkStatus"
    AfkStatus.Size = UDim2.new(0, 180, 0, 30)
    AfkStatus.Position = UDim2.new(0.5, -90, 0, 105)
    AfkStatus.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    AfkStatus.Text = "🛡️ ANTI-AFK: ATTIVO PROTETTO"
    AfkStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    AfkStatus.TextSize = 12
    AfkStatus.Font = Enum.Font.SourceSans
    AfkStatus.Parent = MainFrame

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = AfkStatus

    FarmButton.MouseButton1Click:Connect(function()
        _G.FarmingAttivo = not _G.FarmingAttivo
        if _G.FarmingAttivo then
            FarmButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            FarmButton.Text = "FARMING: ATTIVO"
            AvviaLoopFarming()
        else
            FarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            FarmButton.Text = "FARMING: DISATTIVATO"
        end
    end)
end

-- ==========================================
-- ESECUZIONE COMPLESSIVA
-- ==========================================
if #spawnerInstances > 0 then
    InizializzaAntiAFK()
    CreaInterfaccia()
    print("[SYSTEM] GUI creata correttamente.")
else
    error("[SYSTEM] Nessuno spawner da 50T trovato in questa istanza.")
end

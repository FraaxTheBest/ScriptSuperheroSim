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


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI_NAME = "SuperheroSim_50T_Gui"

-- Rimuove soltanto una vecchia copia della stessa GUI
local oldGui = playerGui:FindFirstChild(GUI_NAME)
if oldGui then
    oldGui:Destroy()
end

--=========================================================
-- SCREEN GUI
--=========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

--=========================================================
-- MAIN FRAME
--=========================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0,10)
FrameCorner.Parent = MainFrame

--=========================================================
-- TITLE
--=========================================================

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1,0,0,36)
Title.BackgroundColor3 = Color3.fromRGB(40,40,45)
Title.BorderSizePixel = 0
Title.Text = "TRIXADE 50T MANAGER"
Title.TextColor3 = Color3.fromRGB(255,215,0)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Active = true
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0,10)
TitleCorner.Parent = Title

--=========================================================
-- DRAG MOUSE + TOUCH
--=========================================================

local dragging = false
local dragInput
local dragStart
local startPos

Title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

local dragConnection = UserInputService.InputChanged:Connect(function(input)

    if input == dragInput and dragging and MainFrame.Parent then

        local delta = input.Position - dragStart

        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--=========================================================
-- START / STOP SOLO GRAFICO
--=========================================================

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

--=========================================================
-- LABEL HELPER
--=========================================================

local function makeLabel(name, y, text)

    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = UDim2.new(0,210,0,28)
    label.Position = UDim2.new(0.5,-105,0,y)
    label.BackgroundColor3 = Color3.fromRGB(43,43,48)
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextSize = 12
    label.Font = Enum.Font.SourceSansBold
    label.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = label

    return label
end

local CurrentCash =
    makeLabel("CurrentCash", 100, "CASH: caricamento...")

local GainSecond =
    makeLabel("GainSecond", 134, "GUADAGNO / SEC: +0")

local GainMinute =
    makeLabel("GainMinute", 168, "ULTIMI 60 SEC: +0")

local GainSession =
    makeLabel("GainSession", 202, "SESSIONE: +0")

local InfoLabel =
    makeLabel("InfoLabel", 236, "GUI: ATTIVA")

--=========================================================
-- FORMATTA NUMERI
--=========================================================

local function formatNumber(n)

    n = tonumber(n) or 0

    local sign = ""

    if n < 0 then
        sign = "-"
        n = math.abs(n)
    end

    if n >= 1e21 then
        return sign .. string.format("%.2fSx", n / 1e21)

    elseif n >= 1e18 then
        return sign .. string.format("%.2fQi", n / 1e18)

    elseif n >= 1e15 then
        return sign .. string.format("%.2fQa", n / 1e15)

    elseif n >= 1e12 then
        return sign .. string.format("%.2fT", n / 1e12)

    elseif n >= 1e9 then
        return sign .. string.format("%.2fB", n / 1e9)

    elseif n >= 1e6 then
        return sign .. string.format("%.2fM", n / 1e6)

    elseif n >= 1e3 then
        return sign .. string.format("%.2fK", n / 1e3)

    else
        return sign .. tostring(math.floor(n))
    end
end

local function signedNumber(n)

    if n >= 0 then
        return "+" .. formatNumber(n)
    end

    return formatNumber(n)
end

--=========================================================
-- CASH TRACKER READ-ONLY
--=========================================================

local trackerRunning = true

task.spawn(function()

    local leaderstats = player:WaitForChild("leaderstats",10)

    if not leaderstats then
        CurrentCash.Text = "CASH: N/D"
        return
    end

    local cash = leaderstats:WaitForChild("Cash",10)

    if not cash then
        CurrentCash.Text = "CASH: N/D"
        return
    end

    local sessionStart = tonumber(cash.Value) or 0
    local previousCash = sessionStart

    local history = {
        {
            time = os.clock(),
            cash = sessionStart
        }
    }

    while trackerRunning and ScreenGui.Parent do

        task.wait(1)

        if not cash.Parent then
            break
        end

        local now = os.clock()
        local current = tonumber(cash.Value) or previousCash

        local secondDelta = current - previousCash
        previousCash = current

        table.insert(history,{
            time = now,
            cash = current
        })

        while #history > 1
        and now - history[1].time > 60 do
            table.remove(history,1)
        end

        local minuteDelta =
            current - history[1].cash

        local sessionDelta =
            current - sessionStart

        CurrentCash.Text =
            "CASH: " .. formatNumber(current)

        GainSecond.Text =
            "GUADAGNO / SEC: "
            .. signedNumber(secondDelta)

        GainMinute.Text =
            "ULTIMI 60 SEC: "
            .. signedNumber(minuteDelta)

        GainSession.Text =
            "SESSIONE: "
            .. signedNumber(sessionDelta)
    end
end)

--=========================================================
-- MINIMIZE
--=========================================================

local minimized = false

local MinButton = Instance.new("TextButton")
MinButton.Name = "MinButton"
MinButton.Size = UDim2.new(0,28,0,25)
MinButton.Position = UDim2.new(1,-64,0,5)
MinButton.BackgroundColor3 = Color3.fromRGB(75,75,80)
MinButton.Text = "—"
MinButton.TextColor3 = Color3.fromRGB(255,255,255)
MinButton.TextSize = 18
MinButton.Font = Enum.Font.SourceSansBold
MinButton.ZIndex = 10
MinButton.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,6)
MinCorner.Parent = MinButton

--=========================================================
-- CLOSE
--=========================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0,28,0,25)
CloseButton.Position = UDim2.new(1,-32,0,5)
CloseButton.BackgroundColor3 = Color3.fromRGB(190,50,50)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.ZIndex = 10
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,6)
CloseCorner.Parent = CloseButton

local content = {
    StartButton,
    CurrentCash,
    GainSecond,
    GainMinute,
    GainSession,
    InfoLabel
}

MinButton.MouseButton1Click:Connect(function()

    minimized = not minimized

    if minimized then

        MainFrame.Size = UDim2.new(0,250,0,36)

        for _,object in ipairs(content) do
            object.Visible = false
        end

        MinButton.Text = "+"

    else

        MainFrame.Size = UDim2.new(0,250,0,280)

        for _,object in ipairs(content) do
            object.Visible = true
        end

        MinButton.Text = "—"
    end
end)

--=========================================================
-- CLOSE CLEAN
--=========================================================

CloseButton.MouseButton1Click:Connect(function()

    trackerRunning = false
    dragging = false

    if dragConnection then
        dragConnection:Disconnect()
    end

    ScreenGui:Destroy()
end)

print("[GUI] TRIXADE 50T MANAGER caricata.")

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

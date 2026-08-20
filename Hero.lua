
--===================================================================================
-- CONFIGURAZIONE ENGINE, FARMING LOOP, ANTI-AFK E MOTORE ECONOMICO
--===================================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lPlayer = Players.LocalPlayer
local pGui = lPlayer:WaitForChild("PlayerGui")
local askCoinRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AskCoin")

_G.FarmingAttivo = false
local TARGET_LOOPS = 250
local SPAWNER_NAME = "50000000000000"

--===================================================================================
-- CARTELLA SPAWNER E LOGICA DI INDIVIDUAZIONE
--===================================================================================
local spawnersFolder = Workspace:WaitForChild("CoinSpawners")
local spawnerInstances = {}
local children = spawnersFolder:GetChildren()

for i = 1, #children do
    local child = children[i]
    if child.Name == SPAWNER_NAME and child:IsA("BasePart") then
        table.insert(spawnerInstances, child)
    end
end

print("[CORE] Spawner 50T agganciati nel server:", #spawnerInstances)

--===================================================================================
-- ROUTINE INTERNA E AUTOMAZIONE DEI CICLI DI RETE
--===================================================================================
local function runRoutine(targetSpawner)
    local char = lPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    hrp.CFrame = targetSpawner.CFrame
    task.wait(0.1)
    
    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AskCoin")
    
    for i = 1, TARGET_LOOPS do
        if not _G.FarmingAttivo then break end
        remote:FireServer(targetSpawner)
        
        if i % 25 == 0 then
            task.wait(0.01)
        end
    end
end

--===================================================================================
-- PROTEZIONE ANTI-AFK REALE (PREVENZIONE KICK 20 MINUTI)
--===================================================================================
local AntiAfkAttivo = true
local idleConnection = nil

local function InizializzaAntiAFK()
    local ok, err = pcall(function()
        local VirtualUser = game:GetService("VirtualUser")
        idleConnection = lPlayer.Idled:Connect(function()
            if not AntiAfkAttivo then return end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
            print("[ANTI-AFK] Simulazione input completata con successo.")
        end)
    end)

    if ok then
        print("[ANTI-AFK] Sistema di monitoraggio IDLE attivo.")
    else
        warn("[ANTI-AFK] Errore inizializzazione modulo:", err)
    end
end

--===================================================================================
-- SISTEMA DI FORMATTAZIONE NUMERICA ECONOMY COMPLETA (K, M, B, T, Qa, Qi, Sx, Sp, Oc)
--===================================================================================
local function formatNumber(n)
    n = tonumber(n) or 0
    local sign = ""
    if n < 0 then
        sign = "-"
        n = math.abs(n)
    end

    if n >= 1e27 then return sign .. string.format("%.2fOc", n / 1e27) -- Ottilioni
    elseif n >= 1e24 then return sign .. string.format("%.2fSp", n / 1e24) -- Settilioni
    elseif n >= 1e21 then return sign .. string.format("%.2fSx", n / 1e21) -- Sestilioni
    elseif n >= 1e18 then return sign .. string.format("%.2fQi", n / 1e18) -- Quintilioni
    elseif n >= 1e15 then return sign .. string.format("%.2fQa", n / 1e15) -- Quadrilioni
    elseif n >= 1e12 then return sign .. string.format("%.2fT", n / 1e12) -- Trilioni
    elseif n >= 1e9 then return sign .. string.format("%.2fB", n / 1e9) -- Miliardi
    elseif n >= 1e6 then return sign .. string.format("%.2fM", n / 1e6) -- Milioni
    elseif n >= 1e3 then return sign .. string.format("%.2fK", n / 1e3) -- Migliaia
    end
    return sign .. tostring(math.floor(n))
end

local function signedNumber(n)
    if n >= 0 then return "+" .. formatNumber(n) end
    return formatNumber(n)
end

local function CreaInterfaccia()
    local screenName = "SuperheroSim_50T_Gui"
    local vecchioScreen = pGui:FindFirstChild(screenName)
    if vecchioScreen then vecchioScreen:Destroy() end

    --=====================================================
    -- SCREEN GUI
    --=====================================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = screenName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = pGui

    --=====================================================
    -- FRAME PRINCIPALE
    --=====================================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 260, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -130, 0.4, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 10)
    FrameCorner.Parent = MainFrame

    --=====================================================
    -- BARRA DEL TITOLO TRASCINABILE
    --=====================================================
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 36)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.BorderSizePixel = 0
    Title.Text = "TRIXADE 50T MANAGER"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Oro
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    Title.Active = true
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    -- Sistema di drag nativo per schermi Mobile Delta Touch Fix
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local dragConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and MainFrame.Parent then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    --=====================================================
    -- PULSANTE START / STOP FARMING
    --=====================================================
    local FarmButton = Instance.new("TextButton")
    FarmButton.Name = "FarmButton"
    FarmButton.Size = UDim2.new(0, 220, 0, 42)
    FarmButton.Position = UDim2.new(0.5, -110, 0, 50)
    FarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FarmButton.Text = "FARMING: DISATTIVATO"
    FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmButton.TextSize = 14
    FarmButton.Font = Enum.Font.SourceSansBold
    FarmButton.Parent = MainFrame

    local FarmCorner = Instance.new("UICorner")
    FarmCorner.CornerRadius = UDim.new(0, 8)
    FarmCorner.Parent = FarmButton

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

    --=====================================================
    -- PULSANTE INTERATTIVO ANTI-AFK
    --=====================================================
    local AfkButton = Instance.new("TextButton")
    AfkButton.Name = "AfkButton"
    AfkButton.Size = UDim2.new(0, 220, 0, 30)
    AfkButton.Position = UDim2.new(0.5, -110, 0, 102)
    AfkButton.Text = "ANTI-AFK: ATTIVO"
    AfkButton.BackgroundColor3 = Color3.fromRGB(45, 110, 55)
    AfkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AfkButton.TextSize = 12
    AfkButton.Font = Enum.Font.SourceSansBold
    AfkButton.Parent = MainFrame

    local AfkCorner = Instance.new("UICorner")
    AfkCorner.CornerRadius = UDim.new(0, 7)
    AfkCorner.Parent = AfkButton

    AfkButton.MouseButton1Click:Connect(function()
        AntiAfkAttivo = not AntiAfkAttivo
        if AntiAfkAttivo then
            AfkButton.Text = "ANTI-AFK: ATTIVO"
            AfkButton.BackgroundColor3 = Color3.fromRGB(45, 110, 55)
        else
            AfkButton.Text = "ANTI-AFK: DISATTIVATO"
            AfkButton.BackgroundColor3 = Color3.fromRGB(130, 60, 60)
        end
    end)

    --=====================================================
    -- COSTRUTTORE MODULI INFORMATIVI (LABEL)
    --=====================================================
    local function makeLabel(name, y, text)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(0, 220, 0, 28)
        label.Position = UDim2.new(0.5, -110, 0, y)
        label.BackgroundColor3 = Color3.fromRGB(43, 43, 48)
        label.BorderSizePixel = 0
        label.Text = text
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSansBold
        label.Parent = MainFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = label
        return label
    end

    local CurrentCash = makeLabel("CurrentCash", 143, "CASH: caricamento...")
    local GainSecond  = makeLabel("GainSecond", 177, "GUADAGNO / SEC: +0")
    local GainMinute  = makeLabel("GainMinute", 211, "ULTIMI 60 SEC: +0")
    local GainSession = makeLabel("GainSession", 245, "SESSIONE: +0")
    local SpawnerInfo = makeLabel("SpawnerInfo", 279, "SPAWNER 50T: " .. tostring(#spawnerInstances))
    local LoopInfo    = makeLabel("LoopInfo", 313, "LOOPS CONFIG: " .. tostring(TARGET_LOOPS))

    --=====================================================
    -- MOTORE DI CALCOLO CASH TRACKER IN TEMPO REALE (FIXED)
    --=====================================================
    local trackerRunning = true

    task.spawn(function()
        local leaderstats = lPlayer:WaitForChild("leaderstats", 10)
        if not leaderstats then CurrentCash.Text = "CASH: N/D" return end
        local cash = leaderstats:WaitForChild("Cash", 10)
        if not cash then CurrentCash.Text = "CASH: N/D" return end

        -- Funzione di formattazione locale interna per evitare errori di tipo nil
        local function localFormat(val)
            local n = tonumber(val) or 0
            local sign = n < 0 and "-" or ""
            n = math.abs(n)
            if n >= 1e27 then return sign .. string.format("%.2fOc", n / 1e27)
            elseif n >= 1e24 then return sign .. string.format("%.2fSp", n / 1e24)
            elseif n >= 1e21 then return sign .. string.format("%.2fSx", n / 1e21)
            elseif n >= 1e18 then return sign .. string.format("%.2fQi", n / 1e18)
            elseif n >= 1e15 then return sign .. string.format("%.2fQa", n / 1e15)
            elseif n >= 1e12 then return sign .. string.format("%.2fT", n / 1e12)
            elseif n >= 1e9 then return sign .. string.format("%.2fB", n / 1e9)
            elseif n >= 1e6 then return sign .. string.format("%.2fM", n / 1e6)
            elseif n >= 1e3 then return sign .. string.format("%.2fK", n / 1e3)
            end
            return sign .. tostring(math.floor(n))
        end

        local function localSigned(val)
            return (tonumber(val) or 0) >= 0 and "+" .. localFormat(val) or localFormat(val)
        end

        local sessionStart = tonumber(cash.Value) or 0
        local previousCash = sessionStart
        local history = {{time = os.clock(), cash = sessionStart}}

        while trackerRunning and ScreenGui.Parent and cash.Parent do
            task.wait(1)
            local now = os.clock()
            local current = tonumber(cash.Value) or previousCash
            local secondDelta = current - previousCash
            previousCash = current

            table.insert(history, {time = now, cash = current})

            while #history > 1 and now - history[1].time > 60 do
                table.remove(history, 1)
            end

            local minuteDelta = current - history[1].cash
            local sessionDelta = current - sessionStart

            CurrentCash.Text = "CASH: " .. localFormat(current)
            GainSecond.Text = "GUADAGNO / SEC: " .. localSigned(secondDelta)
            GainMinute.Text = "ULTIMI 60 SEC: " .. localSigned(minuteDelta)
            GainSession.Text = "SESSIONE: " .. localSigned(sessionDelta)
        end
    end)

    --=====================================================
    -- GESTIONE BOTTONE MINIMIZZA (— / +)
    --=====================================================
    local minimized = false
    local MinButton = Instance.new("TextButton")
    MinButton.Name = "MinButton"
    MinButton.Size = UDim2.new(0, 28, 0, 25)
    MinButton.Position = UDim2.new(1, -64, 0, 5)
    MinButton.BackgroundColor3 = Color3.fromRGB(75, 75, 80)
    MinButton.Text = "—"
    MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinButton.TextSize = 18
    MinButton.Font = Enum.Font.SourceSansBold
    MinButton.ZIndex = 10
    MinButton.Parent = MainFrame

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinButton

    --=====================================================
    -- GESTIONE BOTTONE CHIUDI (×)
    --=====================================================
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 28, 0, 25)
    CloseButton.Position = UDim2.new(1, -32, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.ZIndex = 10
    CloseButton.Parent = MainFrame

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    --=====================================================
    -- CONFIGURAZIONE STRUTTURALE CONTENUTI GUI
    --=====================================================
    local content = {
        FarmButton, 
        AfkButton, 
        CurrentCash,
        GainSecond, 
        GainMinute, 
        GainSession,
        SpawnerInfo, 
        LoopInfo
    }

    -- Gestione interattiva pulsante riduci/espandi
    MinButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 260, 0, 36)
            for i = 1, #content do
                local object = content[i]
                if object then object.Visible = false end
            end
            MinButton.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 260, 0, 350)
            for i = 1, #content do
                local object = content[i]
                if object then object.Visible = true end
            end
            MinButton.Text = "—"
        end
    end)

    --=====================================================
    -- CHIUSURA PULITA E DISCONNESSIONE EVENTI
    --=====================================================
    CloseButton.MouseButton1Click:Connect(function()
        _G.FarmingAttivo = false
        trackerRunning = false
        
        -- Chiusura sicura senza crash da variabili nil
        pcall(function()
            if dragConnection then dragConnection:Disconnect() end
        end)
        pcall(function()
            if idleConnection then idleConnection:Disconnect() end
        end)
        
        ScreenGui:Destroy()
        print("[GUI] Manager rimosso con successo dal DataModel.")
    end)

    print("[GUI] Interfaccia caricata in PlayerGui.")
end

--===================================================================================
-- ESECUZIONE STRUTTURALE GLOBALE
--===================================================================================
if #spawnerInstances > 0 then
    InizializzaAntiAFK()
    CreaInterfaccia()
    print("[SYSTEM] TrixAde 50T fully operational.")
else
    warn("[SYSTEM] Spawner assenti. Caricamento interfaccia in modalità standby.")
    InizializzaAntiAFK()
    CreaInterfaccia()
end

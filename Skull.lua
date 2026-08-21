--===================================================================================
-- TRIXADE ULTIMATE SKULL & MOB MANAGER
-- CODICE UNIFICATO COMPLETO - NESSUNA PARTE MANCANTE
--===================================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lPlayer = Players.LocalPlayer
local pGui = lPlayer:WaitForChild("PlayerGui")

_G.FarmingAttivo = false
local TARGET_LOOPS = 250

--===================================================================================
-- SISTEMA DI FORMATTAZIONE NUMERICA ECONOMY COMPLETA
-- K, M, B, T, Qa, Qi, Sx, Sp, Oc
--===================================================================================

local function formatNumber(n)
    n = tonumber(n) or 0

    local sign = n < 0 and "-" or ""
    n = math.abs(n)

    if n >= 1e27 then
        return sign .. string.format("%.2fOc", n / 1e27)
    elseif n >= 1e24 then
        return sign .. string.format("%.2fSp", n / 1e24)
    elseif n >= 1e21 then
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
    end

    return sign .. tostring(math.floor(n))
end

local function signedNumber(n)
    if (tonumber(n) or 0) >= 0 then
        return "+" .. formatNumber(n)
    end

    return formatNumber(n)
end

--===================================================================================
-- COMBAT ENGINE HYPER-BURST + CRIMINAL NPC ONLY BIND FREEZE (PROTEZIONE EFFETTIVA)
-- Aggancia esclusivamente i modelli nemici "Criminal" escludendo al 100% i Player
--===================================================================================
local skullThreadAttivo = false
local animHitRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AnimHit")
local petAttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PetAttack")

-- Funzione isolata che scarica la raffica di colpi asincroni sul server
local function scaricaColpiFlash(target)
    for colpo = 1, 200 do
        if target.Parent == nil or not _G.FarmingAttivo then break end
        local hum = target:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then break end
        
        pcall(function()
            animHitRemote:FireServer(target)
            petAttackRemote:FireServer(target)
        end)
    end
end

local function runUltimateCombo()
    local char = lPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bersaglioVicino = nil
    local distanzaMinima = math.huge
    
    -- 1. SCANSIONE SELETTIVA RIGIDA: CERCA NELLA CARTELLA DEI MOBS O NEL WORKSPACE
    local function controllaModello(obj)
        local hum = obj:FindFirstChildOfClass("Humanoid")
        local mRoot = obj:FindFirstChild("HumanoidRootPart")
        
        if hum and mRoot and hum.Health > 0 and obj.Name ~= lPlayer.Name then
            -- FILTRO ANTI-BAN DEFINITIVO:
            -- Colpisce SOLO se il nome del modello contiene "Criminal" o "Droid", ignorando i Player reali
            local nomeLower = obj.Name:lower()
            if nomeLower:match("criminal") or nomeLower:match("droid") or obj.Parent.Name:lower():match("mobs") then
                -- Assicurati che non sia un giocatore reale controllando se esiste nei servizi Player
                if not game.Players:GetPlayerFromCharacter(obj) then
                    local distanza = (hrp.Position - mRoot.Position).Magnitude
                    if distanza < distanzaMinima then
                        distanzaMinima = distanza
                        bersaglioVicino = obj
                    end
                end
            end
        end
    end

    -- Controlla sia gli oggetti liberi nel Workspace sia quelli dentro la cartella Workspace.Mobs
    local oggettiWorkspace = workspace:GetChildren()
    for i = 1, #oggettiWorkspace do
        controllaModello(oggettiWorkspace[i])
    end
    
    local cartellaMobs = workspace:FindFirstChild("Mobs")
    if cartellaMobs then
        local oggettiMobs = cartellaMobs:GetChildren()
        for i = 1, #oggettiMobs do
            controllaModello(oggettiMobs[i])
        end
    end
    
    -- 2. BLOCCO SPAZIALE DEL MOSTRO CRIMINAL E SCARICA DI DANNO
    if bersaglioVicino and _G.FarmingAttivo then
        local mRoot = bersaglioVicino:FindFirstChild("HumanoidRootPart")
        if mRoot then
            -- MODULO BIND-FREEZE: Calamita e immobilizza il mostro a 3 studs davanti a te
            pcall(function()
                mRoot.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
            end)
            
            -- Scarica l'Hyper-Burst dei pet e dell'arma sul Criminal congelato
            for thread = 1, 10 do
                task.spawn(scaricaColpiFlash, bersaglioVicino)
            end
        end
    end
    
    -- 3. MAGNETE AUTOMATICO TESCHI E REWARD
    local drops = workspace:GetChildren()
    for j = 1, #drops do
        if not _G.FarmingAttivo then break end
        local obj = drops[j]
        
        if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local nameLower = obj.Name:lower()
            if nameLower:match("drop") or nameLower:match("skull") or nameLower:match("teschio") or nameLower:match("reward") then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    part.CFrame = hrp.CFrame
                end
            end
        end
    end
end

function AvviaLoopFarming()
    if skullThreadAttivo then return end
    skullThreadAttivo = true

    task.spawn(function()
        print("[SAFE CRIMINAL CORE] Blocco selettivo NPC e attacco combinato attivi.")
        while _G.FarmingAttivo do
            pcall(runUltimateCombo)
            task.wait(0.03)
        end
        skullThreadAttivo = false
        print("[SAFE CRIMINAL CORE] Ciclo terminato.")
    end)
end

--===================================================================================
-- PROTEZIONE ANTI-AFK
--===================================================================================

local AntiAfkAttivo = true
local idleConnection = nil

local function InizializzaAntiAFK()
    local ok, err = pcall(function()
        local VirtualUser = game:GetService("VirtualUser")

        idleConnection = lPlayer.Idled:Connect(function()
            if not AntiAfkAttivo then
                return
            end

            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)

            print("[ANTI-AFK] Input simulato.")
        end)
    end)

    if ok then
        print("[ANTI-AFK] Sistema attivo.")
    else
        warn("[ANTI-AFK] Errore:", err)
    end
end

--===================================================================================
-- CREAZIONE INTERFACCIA GRAFICA
--===================================================================================

local function CreaInterfaccia()
    local screenName = "SuperheroSim_Mobs_Gui"
    local vecchioScreen = pGui:FindFirstChild(screenName)

    if vecchioScreen then
        vecchioScreen:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = screenName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = pGui

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

    -- Titolo
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 36)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.BorderSizePixel = 0
    Title.Text = "TRIXADE MOB MANAGER"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    Title.Active = true
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    -- Sistema drag
    local dragging
    local dragInput
    local dragStart
    local startPos

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
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
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragInput = input
        end
    end)

    local dragConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput
            and dragging
            and MainFrame.Parent
        then
            local delta = input.Position - dragStart

            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Pulsante START / STOP FARMING
    local FarmButton = Instance.new("TextButton")
    FarmButton.Name = "FarmButton"
    FarmButton.Size = UDim2.new(0, 220, 0, 42)
    FarmButton.Position = UDim2.new(0.5, -110, 0, 50)
    FarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FarmButton.Text = "ULTIMATE MOB: SPENTO"
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
            FarmButton.Text = "ULTIMATE MOB: ATTIVO ⚔️💀"

            AvviaLoopFarming()
        else
            FarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            FarmButton.Text = "ULTIMATE MOB: SPENTO"
        end
    end)

    -- Pulsante ANTI-AFK
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

    -- Costruttore Moduli Label
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

    local CurrentCash = makeLabel(
        "CurrentCash",
        143,
        "CASH: caricamento..."
    )

    local GainSecond = makeLabel(
        "GainSecond",
        177,
        "GUADAGNO / SEC: +0"
    )

    local GainMinute = makeLabel(
        "GainMinute",
        211,
        "ULTIMI 60 SEC: +0"
    )

    local GainSession = makeLabel(
        "GainSession",
        245,
        "SESSIONE: +0"
    )

    local StatusInfo1 = makeLabel(
        "StatusInfo1",
        279,
        "TARGETING: BATTLE DROID (100T)"
    )

    local StatusInfo2 = makeLabel(
        "StatusInfo2",
        313,
        "MODULO: SPAM ANIMHIT + MAGNETE"
    )

    --=====================================================
    -- MOTORE CASH TRACKER
    --=====================================================

    local trackerRunning = true

    task.spawn(function()
        local leaderstats = lPlayer:WaitForChild("leaderstats", 10)

        if not leaderstats then
            CurrentCash.Text = "CASH: N/D"
            return
        end

        local cash = leaderstats:WaitForChild("Cash", 10)

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

        while trackerRunning
            and ScreenGui.Parent
            and cash.Parent
        do
            task.wait(1)

            local now = os.clock()
            local current = tonumber(cash.Value) or previousCash
            local secondDelta = current - previousCash

            previousCash = current

            table.insert(history, {
                time = now,
                cash = current
            })

            while #history > 1
                and now - history[1].time > 60
            do
                table.remove(history, 1)
            end

            local minuteDelta = current - history[1].cash
            local sessionDelta = current - sessionStart

            CurrentCash.Text =
                "CASH: " .. formatNumber(current)

            GainSecond.Text =
                "GUADAGNO / SEC: " .. signedNumber(secondDelta)

            GainMinute.Text =
                "ULTIMI 60 SEC: " .. signedNumber(minuteDelta)

            GainSession.Text =
                "SESSIONE: " .. signedNumber(sessionDelta)
        end
    end)

    --=====================================================
    -- BOTTONE MINIMIZZA
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
    -- BOTTONE CHIUDI
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

    local content = {
        FarmButton,
        AfkButton,
        CurrentCash,
        GainSecond,
        GainMinute,
        GainSession,
        StatusInfo1,
        StatusInfo2
    }

    MinButton.MouseButton1Click:Connect(function()
        minimized = not minimized

        if minimized then
            MainFrame.Size = UDim2.new(0, 260, 0, 36)

            for i = 1, #content do
                if content[i] then
                    content[i].Visible = false
                end
            end

            MinButton.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 260, 0, 350)

            for i = 1, #content do
                if content[i] then
                    content[i].Visible = true
                end
            end

            MinButton.Text = "—"
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        _G.FarmingAttivo = false
        trackerRunning = false
        dragging = false

        pcall(function()
            if dragConnection then
                dragConnection:Disconnect()
            end
        end)

        pcall(function()
            if idleConnection then
                idleConnection:Disconnect()
            end
        end)

        ScreenGui:Destroy()

        print("[GUI] Manager Mobs rimosso.")
    end)

    print("[GUI] Interfaccia caricata in PlayerGui.")
end

--=========================================================
-- AVVIO STRUTTURALE COMPLESSIVO
--=========================================================

InizializzaAntiAFK()
CreaInterfaccia()

print("[SYSTEM] TrixAde Mob & Skull Tracker fully loaded.")

--=========================================================
-- TRIXADE MOB & SKULL MANAGER
-- REPOSITORY SEPARATO: DEDICATO A MOB E TESCHI ULTIMA ZONA
--=========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lPlayer = Players.LocalPlayer
local pGui = lPlayer:WaitForChild("PlayerGui")

_G.KillETeschiAttivo = false

--===================================================================================
-- COMBAT ENGINE ULTRA-RAFFICA: GLITCH ATTACCO COMPRESSO (EROE + MULTI-PET)
-- Spara 150 colpi simultanei al secondo per frantumare i 100 Trilioni di vita
--===================================================================================
local skullThreadAttivo = false
local animHitRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AnimHit")
local petAttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PetAttack")

local function runUltimateCombo()
    local char = lPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Scansione e targeting immediato sul Battle Droid dell'ultima zona
    local droids = workspace:GetChildren()
    for i = 1, #droids do
        if not _G.FarmingAttivo then break end
        local obj = droids[i]
        
        local hum = obj:FindFirstChildOfClass("Humanoid")
        local mRoot = obj:FindFirstChild("HumanoidRootPart")
        
        -- Individua se il mostro è vivo sul server
        if hum and mRoot and obj.Name ~= lPlayer.Name and hum.Health > 0 then
            
            -- BOMBARDO DI RETE COMPRESSO: 150 colpi simultanei per frame
            -- Questo simula un danno moltiplicato bypassando il cooldown reale
            for colpo = 1, 150 do
                if hum.Health <= 0 or not _G.FarmingAttivo then break end
                
                pcall(function()
                    -- Attacco istantaneo dell'eroe
                    animHitRemote:FireServer(obj)
                    -- Attacco simultaneo a vuoto di tutti i pet equipaggiati insieme
                    petAttackRemote:FireServer(obj)
                end)
            end
        end
    end
    
    -- MAGNETE: Calamita istantaneamente tutti i teschi generati sul tuo corpo
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
        print("[ULTRA CORE] Distruttore di mob e magnete teschi avviati.")
        while _G.FarmingAttivo do
            pcall(runUltimateCombo)
            -- Micro-pausa minima obbligatoria su Delta Mobile per non far frizzare il telefono
            task.wait(0.01) 
        end
        skullThreadAttivo = false
        print("[ULTRA CORE] Ciclo terminato.")
    end)
end


--=========================================================
-- ANTI-AFK
--=========================================================

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

--=========================================================
-- FORMATTAZIONE NUMERI FORMATO ECONOMY
--=========================================================

local function formatNumber(n)
    n = tonumber(n) or 0

    local sign = ""

    if n < 0 then
        sign = "-"
        n = math.abs(n)
    end

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
    if n >= 0 then
        return "+" .. formatNumber(n)
    end

    return formatNumber(n)
end

--=========================================================
-- CREAZIONE INTERFACCIA GRAFICA
--=========================================================

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

    -- Frame Principale
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

    -- Titolo GUI
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

    -- Sistema di drag Mobile
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

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

    -- Pulsante START / STOP FARMING
    local FarmButton = Instance.new("TextButton")
    FarmButton.Name = "FarmButton"
    FarmButton.Size = UDim2.new(0, 220, 0, 42)
    FarmButton.Position = UDim2.new(0.5, -110, 0, 50)
    FarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FarmButton.Text = "AUTO MOB: DISATTIVATO"
    FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmButton.TextSize = 14
    FarmButton.Font = Enum.Font.SourceSansBold
    FarmButton.Parent = MainFrame

    local FarmCorner = Instance.new("UICorner")
    FarmCorner.CornerRadius = UDim.new(0, 8)
    FarmCorner.Parent = FarmButton

    FarmButton.MouseButton1Click:Connect(function()
        _G.KillETeschiAttivo = not _G.KillETeschiAttivo

        if _G.KillETeschiAttivo then
            FarmButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            FarmButton.Text = "AUTO MOB: ATTIVO ⚔️💀"
            AvviaLoopMob()
        else
            FarmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            FarmButton.Text = "AUTO MOB: DISATTIVATO"
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

    -- Costruttore Moduli Informativi
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
        "TARGETING: MOB ULTIMA ZONA"
    )

    local StatusInfo2 = makeLabel(
        "StatusInfo2",
        313,
        "MODULO: ATTACCO + MAGNETE"
    )

    --=====================================================
    -- CASH TRACKER
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

        while trackerRunning and ScreenGui.Parent and cash.Parent do
            task.wait(1)

            local now = os.clock()
            local current = tonumber(cash.Value) or previousCash
            local secondDelta = current - previousCash

            previousCash = current

            table.insert(history, {
                time = now,
                cash = current
            })

            while #history > 1 and now - history[1].time > 60 do
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
                local object = content[i]

                if object then
                    object.Visible = false
                end
            end

            MinButton.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 260, 0, 350)

            for i = 1, #content do
                local object = content[i]

                if object then
                    object.Visible = true
                end
            end

            MinButton.Text = "—"
        end
    end)

    -- Chiusura e pulizia
    CloseButton.MouseButton1Click:Connect(function()
        _G.KillETeschiAttivo = false
        trackerRunning = false
        dragging = false

        if dragConnection then
            dragConnection:Disconnect()
        end

        if idleConnection then
            idleConnection:Disconnect()
        end

        ScreenGui:Destroy()

        print("[GUI] Manager Mobs rimosso.")
    end)

    print("[GUI] Interfaccia caricata in PlayerGui.")
end

--=========================================================
-- AVVIO GLOBALE
--=========================================================

InizializzaAntiAFK()
CreaInterfaccia()

print("[SYSTEM] TrixAde Mob & Skull Tracker fully loaded.")

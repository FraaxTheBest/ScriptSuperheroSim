--===================================================================================
-- ENGINE AUTO-ATTACK PROTETTO (KILL AURA DISTANZIATO)
-- Identifica i nemici e simula l'impatto dell'arma senza esporre il player
--===================================================================================

_G.AutoKillMobs = false

local function AvviaAutoKill()
    task.spawn(function()
        print("[KILL ENGINE] Scansione nemici avviata.")
        while _G.AutoKillMobs do
            local char = lPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            local weaponPart = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true))
            
            -- Sfrutta il corpo del personaggio se l'arma non è equipaggiata
            local attackSource = weaponPart or (char and char:FindFirstChild("HumanoidRootPart"))
            
            if attackSource then
                -- Scansione lineare del Workspace per isolare i bersagli vivi
                for _, obj in ipairs(workspace:GetChildren()) do
                    if not _G.AutoKillMobs then break end
                    
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    
                    -- Verifica che sia un NPC nemico valido e che abbia vita sul server
                    if hum and root and obj.Name ~= lPlayer.Name and hum.Health > 0 then
                        -- Genera un ciclo rapido di 10 colpi simulati per frame sul bersaglio attuale
                        for colpo = 1, 10 do
                            if hum.Health <= 0 or not _G.AutoKillMobs then break end
                            pcall(function()
                                firetouchinterest(root, attackSource, 0) -- Avvia contatto fisico
                                firetouchinterest(root, attackSource, 1) -- Conclude contatto fisico
                            end)
                        end
                    end
                end
            end
            -- Pausa di 0.05 secondi per prevenire il congelamento dell'app Delta su mobile
            task.wait(0.05)
        end
        print("[KILL ENGINE] Scansione nemici interrotta.")
    end)
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
    -- FRAME PRINCIPALE (ALTEZZA AGGIORNATA A 390)
    --=====================================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 260, 0, 390) -- Aumentato per contenere Potato Mode
    MainFrame.Position = UDim2.new(0.5, -130, 0.4, -195)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 10)
    FrameCorner.Parent = MainFrame

    --=====================================================
    -- TITOLO GUI (BARRA DI TRASCINAMENTO)
    --=====================================================
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 36)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.BorderSizePixel = 0
    Title.Text = "TRIXADE 50T MANAGER"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    Title.Active = true
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    -- Sistema di drag nativo Mobile Delta Touch Fix
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
            
            -- Forza l'esecuzione sicura del loop senza blocchi globali
            pcall(function()
                AvviaLoopFarming()
            end)
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
    -- PULSANTE POTATO MODE (FPS BOOST INTERATTIVO)
    --=====================================================
    local PotatoButton = Instance.new("TextButton")
    PotatoButton.Name = "PotatoButton"
    PotatoButton.Size = UDim2.new(0, 220, 0, 30)
    PotatoButton.Position = UDim2.new(0.5, -110, 0, 137) -- Sotto l'Anti-AFK
    PotatoButton.Text = "POTATO MODE: SPENTO"
    PotatoButton.BackgroundColor3 = Color3.fromRGB(130, 60, 60)
    PotatoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PotatoButton.TextSize = 12
    PotatoButton.Font = Enum.Font.SourceSansBold
    PotatoButton.Parent = MainFrame

    local PotatoCorner = Instance.new("UICorner")
    PotatoCorner.CornerRadius = UDim.new(0, 7)
    PotatoCorner.Parent = PotatoButton

    local PotatoAttivo = false
    local originalMaterials = {}
    local descConnection = nil

    local function applicaPotato(obj)
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            if not originalMaterials[obj] then
                originalMaterials[obj] = {
                    Material = obj.Material,
                    Color = obj.Color,
                    CastShadow = obj.CastShadow
                }
            end
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.fromRGB(120, 120, 120)
            obj.CastShadow = false
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
        end
    end

    local function rimuoviPotato()
        for obj, data in pairs(originalMaterials) do
            if obj and obj.Parent then
                obj.Material = data.Material
                obj.Color = data.Color
                obj.CastShadow = data.CastShadow
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 0
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = true
            end
        end
        table.clear(originalMaterials)
    end

    PotatoButton.MouseButton1Click:Connect(function()
        if not MainFrame.Parent then return end
        PotatoAttivo = not PotatoAttivo
        if PotatoAttivo then
            PotatoButton.Text = "POTATO MODE: ATTIVO"
            PotatoButton.BackgroundColor3 = Color3.fromRGB(45, 110, 55)
            for _, child in ipairs(workspace:GetDescendants()) do
                applicaPotato(child)
            end
            descConnection = workspace.DescendantAdded:Connect(function(child)
                task.wait()
                if PotatoAttivo then applicaPotato(child) end
            end)
        else
            PotatoButton.Text = "POTATO MODE: SPENTO"
            PotatoButton.BackgroundColor3 = Color3.fromRGB(130, 60, 60)
            if descConnection then descConnection:Disconnect() end
            rimuoviPotato()
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

    --=====================================================
    -- CONTATORI (COORDINATE Y  DOWNSTREAM)
    --=====================================================
    local CurrentCash = makeLabel("CurrentCash", 178, "CASH: caricamento...")
    local GainSecond  = makeLabel("GainSecond", 212, "GUADAGNO / SEC: +0")
    local GainMinute  = makeLabel("GainMinute", 246, "ULTIMI 60 SEC: +0")
    local GainSession = makeLabel("GainSession", 280, "SESSIONE: +0")
    local SpawnerInfo = makeLabel("SpawnerInfo", 314, "SPAWNER 50T: " .. tostring(#spawnerInstances))
    local LoopInfo    = makeLabel("LoopInfo", 348, "LOOPS CONFIG: " .. tostring(TARGET_LOOPS))

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
    -- CONFIGURAZIONE STRUTTURALE CONTENUTI E INTERRUTTORI
    --=====================================================
    local content = {
        FarmButton, 
        AfkButton, 
        PotatoButton, -- Integrato nel modulo di contrazione visiva
        CurrentCash,
        GainSecond, 
        GainMinute, 
        GainSession,
        SpawnerInfo, 
        LoopInfo
    }

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
            MainFrame.Size = UDim2.new(0, 260, 0, 390) -- Espansione completa a 390
            for i = 1, #content do
                local object = content[i]
                if object then object.Visible = true end
            end
            MinButton.Text = "—"
        end
    end)

    --=====================================================
    -- CHIUSURA PULITA DI MEMORIA E EVENTI
    --=====================================================
    CloseButton.MouseButton1Click:Connect(function()
        _G.FarmingAttivo = false
        trackerRunning = false
        dragging = false
        
        pcall(function()
            if descConnection then descConnection:Disconnect() end
        end)
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

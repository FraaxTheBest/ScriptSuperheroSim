--=========================================================
-- TRIXADE 50T MANAGER
-- GUI + ANTI-AFK + CASH TRACKER
--=========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lPlayer = Players.LocalPlayer
local pGui = lPlayer:WaitForChild("PlayerGui")

_G.FarmingAttivo = false

local TARGET_LOOPS = 250
local SPAWNER_NAME = "50000000000000"

--=========================================================
-- LOGICA RACCOLTA MONETE
-- SOLO LETTURA
--=========================================================

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


--=========================================================
-- ANTI-AFK
--=========================================================

local AntiAfkAttivo = true
local idleConnection = nil

local function InizializzaAntiAFK()

    local ok, err = pcall(function()

        local VirtualUser =
            game:GetService("VirtualUser")

        idleConnection =
            lPlayer.Idled:Connect(function()

                if not AntiAfkAttivo then
                    return
                end

                pcall(function()

                    VirtualUser:CaptureController()

                    VirtualUser:ClickButton2(
                        Vector2.new(0, 0)
                    )

                end)

                print("[ANTI-AFK] Input simulato.")
            end)
    end)

    if ok then
        print("[ANTI-AFK] Sistema attivo.")
    else
        warn(
            "[ANTI-AFK] Errore:",
            err
        )
    end
end

--=========================================================
-- ROUTINE FARMING
--
-- QUI VA LA PARTE CHE ESEGUE UNA SINGOLA ROUTINE
--=========================================================

local function runRoutine(targetSpawner)

    if not targetSpawner then
        return
    end

    if not _G.FarmingAttivo then
        return
    end

    --=====================================================
    -- FARMING REALE: INSERIMENTO MANUALE
    --=====================================================
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

--=========================================================
-- LOOP FARMING
--=========================================================

local farmingThreadAttivo = false

local function AvviaLoopFarming()

    -- Evita di creare 20 thread premendo START più volte
    if farmingThreadAttivo then
        return
    end

    farmingThreadAttivo = true

    task.spawn(function()

        print("[CORE] Loop avviato.")

        while _G.FarmingAttivo do

            for index, instance
                in ipairs(spawnerInstances)
            do

                if not _G.FarmingAttivo then
                    break
                end

                print(
                    "[CORE] Target 50T #"
                    .. tostring(index)
                )

                runRoutine(instance)

                task.wait(0.3)
            end

            if _G.FarmingAttivo then
                task.wait(1.5)
            end
        end

        farmingThreadAttivo = false

        print("[CORE] Loop terminato.")
    end)
end

--=========================================================
-- FORMATTAZIONE NUMERI
--=========================================================

local function formatNumber(number)

    number = tonumber(number) or 0

    local sign = ""

    if number < 0 then
        sign = "-"
        number = math.abs(number)
    end

    if number >= 1e24 then
        return sign
            .. string.format(
                "%.2fSp",
                number / 1e24
            )

    elseif number >= 1e21 then
        return sign
            .. string.format(
                "%.2fSx",
                number / 1e21
            )

    elseif number >= 1e18 then
        return sign
            .. string.format(
                "%.2fQi",
                number / 1e18
            )

    elseif number >= 1e15 then
        return sign
            .. string.format(
                "%.2fQa",
                number / 1e15
            )

    elseif number >= 1e12 then
        return sign
            .. string.format(
                "%.2fT",
                number / 1e12
            )

    elseif number >= 1e9 then
        return sign
            .. string.format(
                "%.2fB",
                number / 1e9
            )

    elseif number >= 1e6 then
        return sign
            .. string.format(
                "%.2fM",
                number / 1e6
            )

    elseif number >= 1e3 then
        return sign
            .. string.format(
                "%.2fK",
                number / 1e3
            )
    end

    return sign
        .. tostring(
            math.floor(number)
        )
end

local function signedNumber(number)

    if number >= 0 then
        return "+"
            .. formatNumber(number)
    end

    return formatNumber(number)
end

--=========================================================
-- GUI
--=========================================================

local function CreaInterfaccia()

    local GUI_NAME =
        "SuperheroSim_50T_Gui"

    local oldGui =
        pGui:FindFirstChild(GUI_NAME)

    if oldGui then
        oldGui:Destroy()
    end

    --=====================================================
    -- SCREEN GUI
    --=====================================================

    local ScreenGui =
        Instance.new("ScreenGui")

    ScreenGui.Name = GUI_NAME
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = pGui

    --=====================================================
    -- MAIN FRAME
    --=====================================================

    local MainFrame =
        Instance.new("Frame")

    MainFrame.Name = "MainFrame"

    MainFrame.Size =
        UDim2.new(
            0, 260,
            0, 350
        )

    MainFrame.Position =
        UDim2.new(
            0.5, -130,
            0.4, -175
        )

    MainFrame.BackgroundColor3 =
        Color3.fromRGB(
            30, 30, 35
        )

    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local FrameCorner =
        Instance.new("UICorner")

    FrameCorner.CornerRadius =
        UDim.new(0, 10)

    FrameCorner.Parent =
        MainFrame

    --=====================================================
    -- TITLE BAR
    --=====================================================

    local Title =
        Instance.new("TextLabel")

    Title.Name = "Title"

    Title.Size =
        UDim2.new(
            1, 0,
            0, 36
        )

    Title.BackgroundColor3 =
        Color3.fromRGB(
            40, 40, 45
        )

    Title.BorderSizePixel = 0

    Title.Text =
        "TRIXADE 50T MANAGER"

    Title.TextColor3 =
        Color3.fromRGB(
            255, 215, 0
        )

    Title.TextSize = 14

    Title.Font =
        Enum.Font.SourceSansBold

    Title.Active = true
    Title.Parent = MainFrame

    local TitleCorner =
        Instance.new("UICorner")

    TitleCorner.CornerRadius =
        UDim.new(0, 10)

    TitleCorner.Parent = Title

    --=====================================================
    -- DRAG PC + TOUCH
    --=====================================================

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    Title.InputBegan:Connect(
        function(input)

            if
                input.UserInputType
                    == Enum.UserInputType.MouseButton1
                or
                input.UserInputType
                    == Enum.UserInputType.Touch
            then

                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position

                input.Changed:Connect(
                    function()

                        if
                            input.UserInputState
                            == Enum.UserInputState.End
                        then

                            dragging = false
                        end
                    end
                )
            end
        end
    )

    Title.InputChanged:Connect(
        function(input)

            if
                input.UserInputType
                    == Enum.UserInputType.MouseMovement
                or
                input.UserInputType
                    == Enum.UserInputType.Touch
            then

                dragInput = input
            end
        end
    )

    local dragConnection =
        UserInputService.InputChanged:Connect(
            function(input)

                if
                    input == dragInput
                    and dragging
                    and MainFrame.Parent
                then

                    local delta =
                        input.Position
                        - dragStart

                    MainFrame.Position =
                        UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset
                                + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset
                                + delta.Y
                        )
                end
            end
        )

    --=====================================================
    -- START / STOP FARMING
    --=====================================================

    local FarmButton =
        Instance.new("TextButton")

    FarmButton.Name =
        "FarmButton"

    FarmButton.Size =
        UDim2.new(
            0, 220,
            0, 42
        )

    FarmButton.Position =
        UDim2.new(
            0.5, -110,
            0, 50
        )

    FarmButton.BackgroundColor3 =
        Color3.fromRGB(
            200, 50, 50
        )

    FarmButton.Text =
        "FARMING: DISATTIVATO"

    FarmButton.TextColor3 =
        Color3.fromRGB(
            255, 255, 255
        )

    FarmButton.TextSize = 14

    FarmButton.Font =
        Enum.Font.SourceSansBold

    FarmButton.Parent =
        MainFrame

    local FarmCorner =
        Instance.new("UICorner")

    FarmCorner.CornerRadius =
        UDim.new(0, 8)

    FarmCorner.Parent =
        FarmButton

    --=====================================================
    -- QUESTO COLLEGA IL BOTTONE AL LOOP
    --=====================================================

    FarmButton.MouseButton1Click:Connect(
        function()

            _G.FarmingAttivo =
                not _G.FarmingAttivo

            if _G.FarmingAttivo then

                FarmButton.BackgroundColor3 =
                    Color3.fromRGB(
                        50, 180, 50
                    )

                FarmButton.Text =
                    "FARMING: ATTIVO"

                AvviaLoopFarming()

            else

                FarmButton.BackgroundColor3 =
                    Color3.fromRGB(
                        200, 50, 50
                    )

                FarmButton.Text =
                    "FARMING: DISATTIVATO"
            end
        end
    )

    --=====================================================
    -- ANTI AFK BUTTON
    --=====================================================

    local AfkButton =
        Instance.new("TextButton")

    AfkButton.Name =
        "AfkButton"

    AfkButton.Size =
        UDim2.new(
            0, 220,
            0, 30
        )

    AfkButton.Position =
        UDim2.new(
            0.5, -110,
            0, 102
        )

    AfkButton.Text =
        "ANTI-AFK: ATTIVO"

    AfkButton.BackgroundColor3 =
        Color3.fromRGB(
            45, 110, 55
        )

    AfkButton.TextColor3 =
        Color3.fromRGB(
            255, 255, 255
        )

    AfkButton.TextSize = 12

    AfkButton.Font =
        Enum.Font.SourceSansBold

    AfkButton.Parent =
        MainFrame

    local AfkCorner =
        Instance.new("UICorner")

    AfkCorner.CornerRadius =
        UDim.new(0, 7)

    AfkCorner.Parent =
        AfkButton

    AfkButton.MouseButton1Click:Connect(
        function()

            AntiAfkAttivo =
                not AntiAfkAttivo

            if AntiAfkAttivo then

                AfkButton.Text =
                    "ANTI-AFK: ATTIVO"

                AfkButton.BackgroundColor3 =
                    Color3.fromRGB(
                        45, 110, 55
                    )

            else

                AfkButton.Text =
                    "ANTI-AFK: DISATTIVATO"

                AfkButton.BackgroundColor3 =
                    Color3.fromRGB(
                        130, 60, 60
                    )
            end
        end
    )

    --=====================================================
    -- LABEL HELPER
    --=====================================================

    local function makeLabel(
        name,
        y,
        text
    )

        local label =
            Instance.new("TextLabel")

        label.Name = name

        label.Size =
            UDim2.new(
                0, 220,
                0, 28
            )

        label.Position =
            UDim2.new(
                0.5, -110,
                0, y
            )

        label.BackgroundColor3 =
            Color3.fromRGB(
                43, 43, 48
            )

        label.BorderSizePixel = 0

        label.Text = text

        label.TextColor3 =
            Color3.fromRGB(
                230, 230, 230
            )

        label.TextSize = 12

        label.Font =
            Enum.Font.SourceSansBold

        label.Parent =
            MainFrame

        local corner =
            Instance.new("UICorner")

        corner.CornerRadius =
            UDim.new(0, 6)

        corner.Parent =
            label

        return label
    end

    local CurrentCash =
        makeLabel(
            "CurrentCash",
            143,
            "CASH: caricamento..."
        )

    local GainSecond =
        makeLabel(
            "GainSecond",
            177,
            "GUADAGNO / SEC: +0"
        )

    local GainMinute =
        makeLabel(
            "GainMinute",
            211,
            "ULTIMI 60 SEC: +0"
        )

    local GainSession =
        makeLabel(
            "GainSession",
            245,
            "SESSIONE: +0"
        )

    local SpawnerInfo =
        makeLabel(
            "SpawnerInfo",
            279,
            "SPAWNER 50T: "
            .. tostring(
                #spawnerInstances
            )
        )

    local LoopInfo =
        makeLabel(
            "LoopInfo",
            313,
            "LOOPS CONFIG: "
            .. tostring(
                TARGET_LOOPS
            )
        )

    --=====================================================
    -- CASH TRACKER READ-ONLY
    --=====================================================

    local trackerRunning = true

    task.spawn(function()

        local leaderstats =
            lPlayer:WaitForChild(
                "leaderstats",
                10
            )

        if not leaderstats then

            CurrentCash.Text =
                "CASH: N/D"

            return
        end

        local cash =
            leaderstats:WaitForChild(
                "Cash",
                10
            )

        if not cash then

            CurrentCash.Text =
                "CASH: N/D"

            return
        end

        local sessionStart =
            tonumber(cash.Value)
            or 0

        local previousCash =
            sessionStart

        local history = {
            {
                time = os.clock(),
                cash = sessionStart
            }
        }

        while
            trackerRunning
            and ScreenGui.Parent
            and cash.Parent
        do

            task.wait(1)

            local now =
                os.clock()

            local current =
                tonumber(cash.Value)
                or previousCash

            local secondDelta =
                current
                - previousCash

            previousCash =
                current

            table.insert(
                history,
                {
                    time = now,
                    cash = current
                }
            )

            while
                #history > 1
                and
                now
                    - history[1].time
                    > 60
            do

                table.remove(
                    history,
                    1
                )
            end

            local minuteDelta =
                current
                - history[1].cash

            local sessionDelta =
                current
                - sessionStart

            CurrentCash.Text =
                "CASH: "
                .. formatNumber(
                    current
                )

            GainSecond.Text =
                "GUADAGNO / SEC: "
                .. signedNumber(
                    secondDelta
                )

            GainMinute.Text =
                "ULTIMI 60 SEC: "
                .. signedNumber(
                    minuteDelta
                )

            GainSession.Text =
                "SESSIONE: "
                .. signedNumber(
                    sessionDelta
                )
        end
    end)

    --=====================================================
    -- MINIMIZE
    --=====================================================

    local minimized = false

    local MinButton =
        Instance.new("TextButton")

    MinButton.Name =
        "MinButton"

    MinButton.Size =
        UDim2.new(
            0, 28,
            0, 25
        )

    MinButton.Position =
        UDim2.new(
            1, -64,
            0, 5
        )

    MinButton.BackgroundColor3 =
        Color3.fromRGB(
            75, 75, 80
        )

    MinButton.Text = "—"

    MinButton.TextColor3 =
        Color3.fromRGB(
            255, 255, 255
        )

    MinButton.TextSize = 18

    MinButton.Font =
        Enum.Font.SourceSansBold

    MinButton.ZIndex = 10
    MinButton.Parent = MainFrame

    local MinCorner =
        Instance.new("UICorner")

    MinCorner.CornerRadius =
        UDim.new(0, 6)

    MinCorner.Parent =
        MinButton

    --=====================================================
    -- CLOSE
    --=====================================================

    local CloseButton =
        Instance.new("TextButton")

    CloseButton.Name =
        "CloseButton"

    CloseButton.Size =
        UDim2.new(
            0, 28,
            0, 25
        )

    CloseButton.Position =
        UDim2.new(
            1, -32,
            0, 5
        )

    CloseButton.BackgroundColor3 =
        Color3.fromRGB(
            190, 50, 50
        )

    CloseButton.Text = "×"

    CloseButton.TextColor3 =
        Color3.fromRGB(
            255, 255, 255
        )

    CloseButton.TextSize = 18

    CloseButton.Font =
        Enum.Font.SourceSansBold

    CloseButton.ZIndex = 10
    CloseButton.Parent = MainFrame

    local CloseCorner =
        Instance.new("UICorner")

    CloseCorner.CornerRadius =
        UDim.new(0, 6)

    CloseCorner.Parent =
        CloseButton

    --=====================================================
    -- MINIMIZE CONTENT
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

    MinButton.MouseButton1Click:Connect(
        function()

            minimized =
                not minimized

            if minimized then

                MainFrame.Size =
                    UDim2.new(
                        0, 260,
                        0, 36
                    )

                for _, object
                    in ipairs(content)
                do

                    object.Visible =
                        false
                end

                MinButton.Text =
                    "+"

            else

                MainFrame.Size =
                    UDim2.new(
                        0, 260,
                        0, 350
                    )

                for _, object
                    in ipairs(content)
                do

                    object.Visible =
                        true
                end

                MinButton.Text =
                    "—"
            end
        end
    )

    --=====================================================
    -- CLOSE CLEAN
    --=====================================================

    CloseButton.MouseButton1Click:Connect(
        function()

            _G.FarmingAttivo = false

            trackerRunning = false
            dragging = false

            if dragConnection then
                dragConnection:Disconnect()
            end

            ScreenGui:Destroy()

            print("[GUI] Manager chiuso.")
        end
    )

    print(
        "[GUI] TRIXADE 50T MANAGER caricata."
    )
end

--=========================================================
-- AVVIO
--=========================================================

InizializzaAntiAFK()
CreaInterfaccia()

print("[SYSTEM] GUI creata correttamente.")

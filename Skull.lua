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


    --=====================================================
    -- INTERRUTTORE GRAFICO AUTOMAZIONE COMBATTIMENTO
    --=====================================================
    local KillButton = Instance.new("TextButton")
    KillButton.Name = "KillButton"
    KillButton.Size = UDim2.new(0, 220, 0, 30)
    KillButton.Position = UDim2.new(0.5, -110, 0, 172)
    KillButton.Text = "AUTO ATTACK: DISATTIVATO"
    KillButton.BackgroundColor3 = Color3.fromRGB(130, 60, 60)
    KillButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillButton.TextSize = 12
    KillButton.Font = Enum.Font.SourceSansBold
    KillButton.Parent = MainFrame

    local KillCorner = Instance.new("UICorner")
    KillCorner.CornerRadius = UDim.new(0, 7)
    KillCorner.Parent = KillButton

    KillButton.MouseButton1Click:Connect(function()
        if not MainFrame.Parent then return end
        _G.AutoKillMobs = not _G.AutoKillMobs
        if _G.AutoKillMobs then
            KillButton.Text = "AUTO ATTACK: ATTIVO ⚔️"
            KillButton.BackgroundColor3 = Color3.fromRGB(45, 110, 55)
            AvviaAutoKill()
        else
            KillButton.Text = "AUTO ATTACK: DISATTIVATO"
            KillButton.BackgroundColor3 = Color3.fromRGB(130, 60, 60)
        end
    end)

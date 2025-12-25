local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Velocidade padrão
local defaultSpeed = 60
local speed = defaultSpeed

-- Função para criar Tool + Tapete + UI
local function createToolAndTapete(char)
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    -- Tool
    local tool = Instance.new("Tool")
    tool.Name = "Tapete Mágico"
    tool.RequiresHandle = false
    tool.Parent = player.Backpack

    -- Tapete decorado
    local tapete = Instance.new("Part")
    tapete.Size = Vector3.new(12, 1, 12)
    tapete.Anchored = false
    tapete.CanCollide = false
    tapete.Transparency = 0.2
    tapete.Color = Color3.fromRGB(255, 0, 0)
    tapete.Material = Enum.Material.Neon
    tapete.Name = "Tapete"
    tapete.Parent = nil

    -- Efeitos visuais
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxassetid://241837157" -- estrelas
    particle.Rate = 20
    particle.Lifetime = NumberRange.new(1,2)
    particle.Speed = NumberRange.new(0,0)
    particle.Size = NumberSequence.new(0.5)
    particle.Parent = tapete

    -- Estado
    local flying = false
    local bv, bg, conn, spinConn

    -- Desliga colisões
    local function disableCollisions(model)
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Iniciar voo
    local function startFlying()
        if flying then return end
        flying = true

        tapete.Parent = workspace

        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = root

        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 1e4
        bg.CFrame = root.CFrame
        bg.Parent = root

        conn = RunService.RenderStepped:Connect(function()
            if not flying then return end

            local look = camera.CFrame.LookVector
            bv.Velocity = look.Unit * speed
            bg.CFrame = CFrame.new(root.Position, root.Position + look)

            tapete.Position = root.Position - Vector3.new(0, 3, 0)
            disableCollisions(char)
        end)

        -- 🔄 Giro contínuo do personagem enquanto voa
        spinConn = RunService.RenderStepped:Connect(function()
            if flying then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(2), 0) -- gira 2° por frame
            end
        end)
    end

    -- Parar voo
    local function stopFlying()
        if not flying then return end
        flying = false

        if conn then conn:Disconnect() conn = nil end
        if spinConn then spinConn:Disconnect() spinConn = nil end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end

        tapete.Parent = nil
    end

    tool.Equipped:Connect(startFlying)
    tool.Unequipped:Connect(stopFlying)

    -- Caixa de controle de velocidade
    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    screenGui.Name = "TapeteUI"

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 150, 0, 80)
    frame.Position = UDim2.new(0.8, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 2

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0.4,0)
    label.Text = "Velocidade: "..speed
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0.5,0,0.6,0)
    plus.Position = UDim2.new(0,0,0.4,0)
    plus.Text = "+"
    plus.TextScaled = true

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0.5,0,0.6,0)
    minus.Position = UDim2.new(0.5,0,0.4,0)
    minus.Text = "-"
    minus.TextScaled = true

    plus.MouseButton1Click:Connect(function()
        speed = speed + 20
        label.Text = "Velocidade: "..speed
    end)

    minus.MouseButton1Click:Connect(function()
        speed = math.max(20, speed - 20)
        label.Text = "Velocidade: "..speed
    end)
end

-- Criar Tool no personagem atual
createToolAndTapete(player.Character or player.CharacterAdded:Wait())

-- Garantir que a Tool reapareça e a velocidade volte ao normal quando o jogador renasce
player.CharacterAdded:Connect(function(char)
    speed = defaultSpeed
    createToolAndTapete(char)
end)

-- Mensagem inicial
StarterGui:SetCore("SendNotification", {
    Title = "Script executado!",
    Text = "Obrigado por usar este script 😎",
    Duration = 5
})


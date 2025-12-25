local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Função que cria a Tool e o Tapete
local function createToolAndTapete(char)
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    -- Tool
    local tool = Instance.new("Tool")
    tool.Name = "Tapete Mágico"
    tool.RequiresHandle = false
    tool.Parent = player.Backpack

    -- Tapete
    local tapete = Instance.new("Part")
    tapete.Size = Vector3.new(10, 1, 10)
    tapete.Anchored = false
    tapete.CanCollide = false
    tapete.Transparency = 1
    tapete.Color = Color3.fromRGB(255, 0, 0)
    tapete.Name = "Tapete"
    tapete.Parent = nil

    -- Estado
    local flying = false
    local speed = 60
    local bv, bg, conn

    -- Desliga colisões do personagem
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

        tapete.Transparency = 0.3
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
    end

    -- Parar voo
    local function stopFlying()
        if not flying then return end
        flying = false

        if conn then conn:Disconnect() conn = nil end
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end

        tapete.Transparency = 1
        tapete.Parent = nil
    end

    tool.Equipped:Connect(startFlying)
    tool.Unequipped:Connect(stopFlying)
end

-- Criar Tool no personagem atual
createToolAndTapete(player.Character or player.CharacterAdded:Wait())

-- Garantir que a Tool reapareça quando o jogador morrer/renascer
player.CharacterAdded:Connect(function(char)
    createToolAndTapete(char)
end)

-- Mensagem inicial
StarterGui:SetCore("SendNotification", {
    Title = "Script executado!",
    Text = "Obrigado por usar este script 😎",
    Duration = 5
})

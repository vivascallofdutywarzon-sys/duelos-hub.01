-- [[ Mi Script Personalizado de Duelos (con Toggle en la letra K) ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Evitar duplicados
if CoreGui:FindFirstChild("DuelosGui") then
    CoreGui.DuelosGui:Destroy()
end

-- 1. Crear la Interfaz Gráfica (ScreenGui)
local DuelosGui = Instance.new("ScreenGui")
DuelosGui.Name = "DuelosGui"
DuelosGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 265)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -132)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = DuelosGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "DUELOS HUB v2.2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local function CreateButton(text, positionY, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.85, 0, 0, 35)
    Button.Position = UDim2.new(0.075, 0, 0, positionY)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Font = Enum.Font.SourceSansMed
    Button.TextSize = 14
    Button.Parent = MainFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- 2. Lógica del Autoapuntado (Aimbot)
local aimbotEnabled = false
local aiming = false

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Detectar teclas y clics del mouse
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Clic derecho para aimbot
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end

    -- Tecla K para ocultar / mostrar el menú
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Actualización continua de la cámara al apuntar
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled and aiming then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- 3. Botones del Menú

-- Opción 1: Activar/Desactivar Autoapuntado
CreateButton("Autoapuntado: APAGADO", 50, function(btn)
    aimbotEnabled = not aimbotEnabled
    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Position.Y.Offset == 50 then
            child.Text = aimbotEnabled and "Autoapuntado: ENCENDIDO" or "Autoapuntado: APAGADO"
            child.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
        end
    end
end)

-- Opción 2: ESP (Ver a través de paredes)
local espEnabled = false
CreateButton("Activar / Desactivar ESP", 95, function()
    espEnabled = not espEnabled
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- Opción 3: Velocidad Rápida
CreateButton("Velocidad Rápida (WalkSpeed)", 140, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 24
    end
end)

-- Opción 4: Restaurar Velocidad Normal
CreateButton("Restaurar Velocidad (Normal)", 185, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

print("¡Duelos Hub v2.2 cargado! Presiona la letra 'K' para ocultar/mostrar el menú.")

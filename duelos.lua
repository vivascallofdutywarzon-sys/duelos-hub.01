-- Versión segura / limpia
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Evita duplicados
if CoreGui:FindFirstChild("DuelosGui") then
    CoreGui.DuelosGui:Destroy()
end

local DuelosGui = Instance.new("ScreenGui")
DuelosGui.Name = "DuelosGui"
DuelosGui.ResetOnSpawn = false
DuelosGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 525)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -262)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = DuelosGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "DUELOS HUB (LIMPIO)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Parent = MainFrame

local function CreateButton(text, positionY, callback)
    local Button = Instance.new("TextButton")
    Button.Name = text
    Button.Size = UDim2.new(0.85, 0, 0, 35)
    Button.Position = UDim2.new(0.075, 0, 0, positionY)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Font = Enum.Font.SourceSansMed
    Button.TextSize = 13
    Button.Parent = MainFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        callback(Button)
    end)

    return Button
end

-- Estado
local espEnabled = false
local espColor = Color3.fromRGB(0, 255, 255)
local autoFireEnabled = false
local aiming = false
local targetObject = nil

local espButtonRef = nil
local autoFireButtonRef = nil

-- ESP tipo contorno/transparente (sin relleno sólido)
local function UpdateESPVisuals()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Outline")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Outline"
                    highlight.Parent = player.Character
                end

                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 0.2
                highlight.OutlineColor = espColor
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = player.Character
            else
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

local function ToggleESP()
    espEnabled = not espEnabled
    if espButtonRef then
        espButtonRef.Text = "ESP [R]: " .. (espEnabled and "ON" or "APAGADO")
        espButtonRef.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
    end
    UpdateESPVisuals()
end

local function ToggleAutoFire()
    autoFireEnabled = not autoFireEnabled
    if autoFireButtonRef then
        autoFireButtonRef.Text = autoFireEnabled and "AutoDisparo [C]: ENCENDIDO" or "AutoDisparo [C]: APAGADO"
        autoFireButtonRef.BackgroundColor3 = autoFireEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
    end
end

-- Cámara suave (sin salto brusco)
local function SmoothLookAt(targetPosition, dt)
    local currentCFrame = Camera.CFrame
    local desiredCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    local smoothFactor = 1 - math.exp(-dt * 12)
    Camera.CFrame = currentCFrame:Lerp(desiredCFrame, smoothFactor)
end

-- Buscador de objetivo válido (solo si tu sistema de juego lo permite)
local function GetTarget()
    local bestTarget = nil
    local bestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            if humanoidRoot and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < bestDistance then
                        bestDistance = distance
                        bestTarget = player
                    end
                end
            end
        end
    end

    return bestTarget
end

-- Control de teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end

    if input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end

    if input.KeyCode == Enum.KeyCode.R then
        ToggleESP()
    end

    if input.KeyCode == Enum.KeyCode.C then
        -- Esto solo es correcto si tu juego tiene un sistema de disparo propio.
        ToggleAutoFire()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Lógica de cámara suave
RunService.RenderStepped:Connect(function(dt)
    local targetPlayer = GetTarget()
    if aiming and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local headPos = targetPlayer.Character.Head.Position
        SmoothLookAt(headPos, dt)
    end

    -- Modo de disparo continuo SOLO si tu arma del juego lo soporta.
    if autoFireEnabled then
        -- Ejemplo:
        -- if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        --     local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        --     if tool.Fire then
        --         tool:Fire()
        --     end
        -- end
    end
end)

-- Botones del menú
espButtonRef = CreateButton("ESP [R]: APAGADO", 50, function()
    ToggleESP()
end)

autoFireButtonRef = CreateButton("AutoDisparo [C]: APAGADO", 95, function()
    ToggleAutoFire()
end)

CreateButton("Color ESP: Celeste", 140, function(btn)
    espColor = Color3.fromRGB(0, 255, 255)
    btn.Text = "Color ESP: Celeste"
    UpdateESPVisuals()
end)

CreateButton("Modo Cámara: Suave", 185, function()
    -- Aquí solo se usa el comportamiento puro de cámara; no modificas cuerpos.
end)

print("DUELOS HUB (versión segura) cargado.")

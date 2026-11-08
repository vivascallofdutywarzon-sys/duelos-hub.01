-- [[ Mi Script Personalizado de Duelos (v2.8 con Autoshoot en la letra C) ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Evitar duplicados
if CoreGui:FindFirstChild("DuelosGui") then
    CoreGui.DuelosGui:Destroy()
end

-- 1. Crear la Interfaz Gráfica (ScreenGui)
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
Title.Text = "DUELOS HUB v2.8"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.ZIndex = 2
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Función para crear botones
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
    Button.Visible = true
    Button.ZIndex = 3
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        callback(Button)
    end)
    
    Button.Parent = MainFrame
    return Button
end

-- Variables de Estado
local aimbotEnabled = false
local aiming = false
local autoshootEnabled = false
local fovSize = 100

local hitboxEnabled = false
local hitboxSize = 4
local hitboxColorIndex = 1
local hitboxColors = {
    {name = "Rojo", color = Color3.fromRGB(255, 0, 0)},
    {name = "Verde", color = Color3.fromRGB(0, 255, 0)},
    {name = "Azul", color = Color3.fromRGB(0, 0, 255)},
    {name = "Amarillo", color = Color3.fromRGB(255, 255, 0)},
    {name = "Celeste", color = Color3.fromRGB(0, 255, 255)}
}

local espEnabled = false
local espColorIndex = 1
local espColors = {
    {name = "Rojo", color = Color3.fromRGB(255, 0, 0)},
    {name = "Verde", color = Color3.fromRGB(0, 255, 0)},
    {name = "Blanco", color = Color3.fromRGB(255, 255, 255)},
    {name = "Azul", color = Color3.fromRGB(0, 100, 255)},
    {name = "Morado", color = Color3.fromRGB(150, 0, 255)}
}

local aimbotButtonRef = nil
local espButtonRef = nil
local autoshootButtonRef = nil

-- Círculo FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = fovSize
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = fovSize
    FOVCircle.Visible = aimbotEnabled
end)

local function GetClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = fovSize
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

-- Actualizar ESP
local function UpdateESPVisuals()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.Parent = player.Character
                end
                highlight.FillColor = espColors[espColorIndex].color
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

local function ToggleESP()
    espEnabled = not espEnabled
    if espButtonRef then
        espButtonRef.Text = "ESP [R]: " .. (espEnabled and "ON (" .. espColors[espColorIndex].name .. ")" or "APAGADO")
        espButtonRef.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
    end
    UpdateESPVisuals()
end

local function ToggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotButtonRef then
        aimbotButtonRef.Text = aimbotEnabled and "Autoapuntado [X]: ENCENDIDO" or "Autoapuntado [X]: APAGADO"
        aimbotButtonRef.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
    end
end

local function ToggleAutoshoot()
    autoshootEnabled = not autoshootEnabled
    if autoshootButtonRef then
        autoshootButtonRef.Text = autoshootEnabled and "Autoshoot [C]: ENCENDIDO" or "Autoshoot [C]: APAGADO"
        autoshootButtonRef.BackgroundColor3 = autoshootEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
    end
end

-- Hitbox Gigante
RunService.RenderStepped:Connect(function()
    if hitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    rootPart.Transparency = 0.6
                    rootPart.Color = hitboxColors[hitboxColorIndex].color
                    rootPart.Material = Enum.Material.Neon
                    rootPart.CanCollide = false
                end
            end
        end
    end
end)

-- Teclas y Clics
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            aiming = true
        end

        if input.KeyCode == Enum.KeyCode.K then
            MainFrame.Visible = not MainFrame.Visible
            FOVCircle.Visible = MainFrame.Visible and aimbotEnabled
        end

        if input.KeyCode == Enum.KeyCode.R then
            ToggleESP()
        end

        if input.KeyCode == Enum.KeyCode.X then
            ToggleAimbot()
        end

        if input.KeyCode == Enum.KeyCode.C then
            ToggleAutoshoot()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Lógica de Aimbot + Autoshoot
RunService.RenderStepped:Connect(function()
    local target = GetClosestPlayerInFOV()
    
    if aimbotEnabled and aiming and target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end

    if autoshootEnabled and target and target.Character and target.Character:FindFirstChild("Head") then
        VirtualUser:Button1Down(Vector2.new(0,0))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(0,0))
    end
end)

-- 4. Botones del Menú
aimbotButtonRef = CreateButton("Autoapuntado [X]: APAGADO", 50, function()
    ToggleAimbot()
end)

autoshootButtonRef = CreateButton("Autoshoot [C]: APAGADO", 95, function()
    ToggleAutoshoot()
end)

CreateButton("Radio FOV: 100 (Max 500)", 140, function(btn)
    fovSize = fovSize + 50
    if fovSize > 500 then fovSize = 50 end
    btn.Text = "Radio FOV: " .. fovSize .. " (Max 500)"
end)

local hitboxBtnRef = CreateButton("Hitbox Gigante: APAGADO", 185, function(btn)
    hitboxEnabled = not hitboxEnabled
    btn.Text = hitboxEnabled and "Hitbox: ON (" .. hitboxSize .. ")" or "Hitbox Gigante: APAGADO"
    btn.BackgroundColor3 = hitboxEnabled and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
end)

CreateButton("Tamaño Hitbox: 4 -> 500", 230, function(btn)
    hitboxSize = hitboxSize + 25
    if hitboxSize > 500 then hitboxSize = 4 end
    btn.Text = "Tamaño Hitbox: " .. hitboxSize
    if hitboxEnabled then
        hitboxBtnRef.Text = "Hitbox: ON (" .. hitboxSize .. ")"
    end
end)

CreateButton("Color Hitbox: Rojo", 275, function(btn)
    hitboxColorIndex = hitboxColorIndex + 1
    if hitboxColorIndex > #hitboxColors then hitboxColorIndex = 1 end
    btn.Text = "Color Hitbox: " .. hitboxColors[hitboxColorIndex].name
end)

espButtonRef = CreateButton("ESP [R]: APAGADO", 320, function()
    ToggleESP()
end)

CreateButton("Color ESP: Rojo", 365, function(btn)
    espColorIndex = espColorIndex + 1
    if espColorIndex > #espColors then espColorIndex = 1 end
    btn.Text = "Color ESP: " .. espColors[espColorIndex].name
    UpdateESPVisuals()
end)

CreateButton("Velocidad Rápida (WalkSpeed)", 410, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 24
    end
end)

CreateButton("Restaurar Velocidad (Normal)", 455, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

print("¡Duelos Hub v2.8 cargado con éxito!")

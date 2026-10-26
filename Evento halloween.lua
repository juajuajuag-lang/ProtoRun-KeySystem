-- Pumpkin ESP - Panel Compacto
-- ----
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ---- Limpiar versiones anteriores
local previous = PG:FindFirstChild("PumpkinESP_Debug")
if previous then previous:Destroy() end

local oldFolder = Workspace:FindFirstChild("PumpkinESP_Test")
if oldFolder then oldFolder:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "PumpkinESP_Test"
folder.Parent = Workspace

-- ---- Configuracion
local espEnabled = true
local nameEnabled = true
local minimized = false
local found = {}
local total = 0
local running = true

-- ---- Crear interfaz
local gui = Instance.new("ScreenGui")
gui.Name = "PumpkinESP_Debug"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = PG

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.fromOffset(220, 112)
panel.Position = UDim2.new(0, 15, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 7)
panelCorner.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Active = true
header.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 7)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -68, 1, 0)
title.Position = UDim2.fromOffset(8, 0)
title.BackgroundTransparency = 1
title.Text = "Pumpkin ESP"
title.TextColor3 = Color3.fromRGB(255, 160, 45)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local function makeButton(parent, text, size, position)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 67)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    return button
end

local minimizeButton = makeButton(
    header, "—", UDim2.fromOffset(23, 22),
    UDim2.new(1, -50, 0, 4)
)

local closeButton = makeButton(
    header, "X", UDim2.fromOffset(23, 22),
    UDim2.new(1, -25, 0, 4)
)

-- ---- Crear opciones compactas
local function makeToggle(text, y)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 27)
    row.Position = UDim2.fromOffset(8, y)
    row.BackgroundTransparency = 1
    row.Parent = panel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -58, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 235, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local button = makeButton(
        row, "ON", UDim2.fromOffset(48, 22),
        UDim2.new(1, -48, 0.5, -11)
    )

    return button, row
end

local espButton, espRow = makeToggle("Pumpkin ESP", 34)
local nameButton, nameRow = makeToggle("Nametag", 63)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 14)
status.Position = UDim2.fromOffset(8, 94)
status.BackgroundTransparency = 1
status.Text = "Coincidencias: 0"
status.TextColor3 = Color3.fromRGB(180, 180, 190)
status.Font = Enum.Font.Gotham
status.TextSize = 9
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

-- ---- Arrastrar panel
local dragging = false
local dragInput
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- ---- Buscar pieza principal
local function getPart(obj)
    if obj:IsA("BasePart") then
        return obj
    end

    if obj:IsA("Model") then
        return obj.PrimaryPart
            or obj:FindFirstChildWhichIsA("BasePart", true)
    end

    return nil
end

-- ---- Reconocer nombres de calabazas
local function isPumpkinName(name)
    name = string.lower(name)

    return string.find(name, "pump", 1, true) ~= nil
        or string.find(name, "gourd", 1, true) ~= nil
        or string.find(name, "squash", 1, true) ~= nil
end

-- ---- Actualizar objetos encontrados
local function updateObject(data)
    if data.highlight and data.highlight.Parent then
        data.highlight.Enabled = espEnabled
    end

    if data.tag and data.tag.Parent then
        data.tag.Enabled = nameEnabled
    end
end

-- ---- Crear ESP y Nametag
local function addESP(obj)
    if found[obj] then return end

    local part = getPart(obj)
    if not part then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PumpkinHighlight"
    highlight.Adornee = obj
    highlight.FillColor = Color3.fromRGB(255, 130, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.45
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = espEnabled
    highlight.Parent = folder

    local tag = Instance.new("BillboardGui")
    tag.Name = "PumpkinNametag"
    tag.Adornee = part
    tag.Size = UDim2.fromOffset(150, 25)
    tag.StudsOffset = Vector3.new(0, 2.5, 0)
    tag.AlwaysOnTop = true
    tag.Enabled = nameEnabled
    tag.Parent = folder

    local text = Instance.new("TextLabel")
    text.Name = "Label"
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 170, 50)
    text.TextStrokeTransparency = 0.2
    text.TextScaled = false
    text.TextSize = 12
    text.Font = Enum.Font.GothamBold
    text.Text = obj.Name
    text.Parent = tag

    found[obj] = {
        highlight = highlight,
        tag = tag
    }

    total += 1
end

-- ---- Escanear objetos del mapa
local function scan()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart"))
            and isPumpkinName(obj.Name) then
            addESP(obj)
        end
    end

    status.Text = "Coincidencias: " .. total
end

-- ---- Interruptor Pumpkin ESP
espButton.Activated:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ON" or "OFF"
    espButton.BackgroundColor3 = espEnabled
        and Color3.fromRGB(45, 125, 70)
        or Color3.fromRGB(130, 50, 50)

    for _, data in pairs(found) do
        updateObject(data)
    end
end)

-- ---- Interruptor Nametag
nameButton.Activated:Connect(function()
    nameEnabled = not nameEnabled
    nameButton.Text = nameEnabled and "ON" or "OFF"
    nameButton.BackgroundColor3 = nameEnabled
        and Color3.fromRGB(45, 125, 70)
        or Color3.fromRGB(130, 50, 50)

    for _, data in pairs(found) do
        updateObject(data)
    end
end)

-- ---- Minimizar y restaurar
minimizeButton.Activated:Connect(function()
    minimized = not minimized

    panel.Size = minimized
        and UDim2.fromOffset(220, 30)
        or UDim2.fromOffset(220, 112)

    espRow.Visible = not minimized
    nameRow.Visible = not minimized
    status.Visible = not minimized
    minimizeButton.Text = minimized and "+" or "—"
end)

-- ---- Cerrar y limpiar
closeButton.Activated:Connect(function()
    running = false
    gui:Destroy()
    folder:Destroy()
end)

-- ---- Colores iniciales
espButton.BackgroundColor3 = Color3.fromRGB(45, 125, 70)
nameButton.BackgroundColor3 = Color3.fromRGB(45, 125, 70)

-- ---- Escaneo inicial y continuo
scan()

task.spawn(function()
    while running and gui.Parent and folder.Parent do
        task.wait(1)
        scan()

        for obj, data in pairs(found) do
            if not obj:IsDescendantOf(Workspace) then
                if data.highlight then
                    data.highlight:Destroy()
                end

                if data.tag then
                    data.tag:Destroy()
                end

                found[obj] = nil
                total = math.max(0, total - 1)
            end
        end

        status.Text = "Coincidencias: " .. total
    end
end)
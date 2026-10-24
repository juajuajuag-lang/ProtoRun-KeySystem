
-- ProtoRun Lite - World ESP Optimizado
-- PARTE 1/2: Configuracion, deteccion y objetos visuales
-- ----
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ---- Configuracion
local Config = {
    Master = true,
    Generator = true,
    Hook = true,
    Gate = true,
    Window = true,
    Pallet = true,
    SCPZombie = true,
    Nametags = true,
    Distance = true,
    GeneratorPercent = true,
    MaxDistance = 2500,
    ScanInterval = 8,
    UpdateInterval = 0.3,
    WindowColorIndex = 6
}

local Palette = {
    Color3.fromRGB(255, 65, 65),
    Color3.fromRGB(255, 130, 50),
    Color3.fromRGB(255, 210, 55),
    Color3.fromRGB(170, 255, 65),
    Color3.fromRGB(65, 255, 100),
    Color3.fromRGB(50, 255, 190),
    Color3.fromRGB(50, 220, 255),
    Color3.fromRGB(65, 145, 255),
    Color3.fromRGB(100, 90, 255),
    Color3.fromRGB(165, 75, 255),
    Color3.fromRGB(220, 70, 255),
    Color3.fromRGB(255, 75, 190),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(210, 210, 210),
    Color3.fromRGB(150, 150, 150),
    Color3.fromRGB(90, 90, 90),
    Color3.fromRGB(255, 100, 100),
    Color3.fromRGB(255, 175, 100),
    Color3.fromRGB(255, 240, 120),
    Color3.fromRGB(180, 255, 140),
    Color3.fromRGB(120, 255, 180),
    Color3.fromRGB(120, 255, 230),
    Color3.fromRGB(120, 220, 255),
    Color3.fromRGB(130, 180, 255),
    Color3.fromRGB(155, 145, 255),
    Color3.fromRGB(195, 140, 255),
    Color3.fromRGB(235, 140, 255),
    Color3.fromRGB(255, 140, 220),
    Color3.fromRGB(255, 190, 190),
    Color3.fromRGB(190, 255, 190),
    Color3.fromRGB(190, 220, 255)
}

local CategoryInfo = {
    Generator = {Label = "Generator", Color = Color3.fromRGB(65, 255, 100)},
    Hook = {Label = "Hook", Color = Color3.fromRGB(255, 65, 65)},
    Gate = {Label = "Gate", Color = Color3.fromRGB(255, 210, 55)},
    Window = {Label = "Window", Color = Palette[6]},
    Pallet = {Label = "Pallet", Color = Color3.fromRGB(50, 220, 255)},
    SCPZombie = {Label = "SCP / Zombie", Color = Color3.fromRGB(220, 70, 255)}
}

local Registry = {
    Generator = {},
    Hook = {},
    Gate = {},
    Window = {},
    Pallet = {},
    SCPZombie = {}
}

local Connections = {}
local Running = true
local ScreenGui
local MainFrame
local StatusLabel
local ToggleButtons = {}
local ScanAccumulator = 0
local UpdateAccumulator = 0
local PendingInstances = {}

-- ---- Nombres aceptados por categoria
local NameRules = {
    Generator = {
        "generator", "gen_machine", "genmachine",
        "genspawn", "repairmachine"
    },
    -- Solo nombres concretos para evitar falsos positivos.
    -- Agrega aqui el nombre real del gancho si es diferente.
    Hook = {
        "hook", "meathook", "sacrificehook",
        "survivorhook", "hanginghook"
    },
    Gate = {
        "gate", "exitgate", "exit_gate",
        "escape_gate", "exitdoor"
    },
    Window = {
        "window", "vault", "windowframe",
        "window_frame", "vaultpoint"
    },
    Pallet = {
        "pallet", "woodenpallet", "wood_pallet",
        "palletspawn", "pallet_spawn"
    },
    SCPZombie = {
        "scp", "zombie", "infected",
        "monster", "killer", "creature"
    }
}

local HookExactNames = {}
for _, name in ipairs(NameRules.Hook) do
    HookExactNames[name] = true
end

-- ---- Utilidades basicas
local function SafeName(instance)
    if not instance then
        return ""
    end
    local ok, name = pcall(function()
        return instance.Name
    end)
    if not ok then
        return ""
    end
    return string.lower(tostring(name)):gsub("[%s_%-]", "")
end

local function IsAlive(instance)
    return instance ~= nil
        and instance.Parent ~= nil
        and instance:IsDescendantOf(Workspace)
end

local function GetRootPart(instance)
    if not instance then
        return nil
    end
    if instance:IsA("BasePart") then
        return instance
    end
    if instance:IsA("Model") then
        if instance.PrimaryPart then
            return instance.PrimaryPart
        end
        return instance:FindFirstChildWhichIsA("BasePart", true)
    end
    return instance:FindFirstChildWhichIsA("BasePart", true)
end

local function GetPosition(instance)
    local part = GetRootPart(instance)
    return part and part.Position or nil
end

local function GetDistance(instance)
    local position = GetPosition(instance)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not position or not root then
        return nil
    end
    return (position - root.Position).Magnitude
end

local function GetColor(category)
    if category == "Window" then
        local index = math.clamp(Config.WindowColorIndex, 1, #Palette)
        return Palette[index]
    end
    return CategoryInfo[category].Color
end

local function IsEnabled(category)
    return Config.Master and Config[category] == true
end

local function GetDisplayName(instance)
    return instance.Name:gsub("_", " "):gsub("(%l)(%u)", "%1 %2")
end

-- ---- Deteccion de nombres
local function NameMatches(name, category)
    if category == "Hook" then
        return HookExactNames[name] == true
    end

    for _, pattern in ipairs(NameRules[category]) do
        if string.find(name, pattern, 1, true) then
            return true
        end
    end
    return false
end

local function DetectCategory(instance)
    if not instance then
        return nil
    end

    local name = SafeName(instance)
    if name == "" then
        return nil
    end

    local priority = {
        "Generator", "Hook", "Gate",
        "Window", "Pallet", "SCPZombie"
    }

    for _, category in ipairs(priority) do
        if NameMatches(name, category) then
            return category
        end
    end
    return nil
end

local function GetCandidate(instance)
    local current = instance
    local steps = 0

    while current and current ~= Workspace and steps < 5 do
        if current:IsA("Model") or current:IsA("Folder") then
            local category = DetectCategory(current)
            if category then
                return current, category
            end
        end
        current = current.Parent
        steps += 1
    end

    local category = DetectCategory(instance)
    if category then
        return instance, category
    end
    return nil, nil
end

-- ---- Limpieza visual
local function DestroyVisuals(entry)
    if not entry then
        return
    end
    if entry.Highlight then
        pcall(function()
            entry.Highlight:Destroy()
        end)
        entry.Highlight = nil
    end
    if entry.Billboard then
        pcall(function()
            entry.Billboard:Destroy()
        end)
        entry.Billboard = nil
    end
end

local function UnregisterObject(instance, category)
    local objects = Registry[category]
    if not objects then
        return
    end
    local entry = objects[instance]
    if entry then
        DestroyVisuals(entry)
        objects[instance] = nil
    end
end

-- ---- Crear Highlight
local function CreateHighlight(instance, category)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ProtoRunWorldESP"
    highlight.Adornee = instance
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = GetColor(category)
    highlight.OutlineColor = GetColor(category)
    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0.12
    highlight.Enabled = IsEnabled(category)
    highlight.Parent = instance
    return highlight
end

-- ---- Crear etiqueta
local function CreateBillboard(instance, category)
    local part = GetRootPart(instance)
    if not part then
        return nil
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ProtoRunWorldTag"
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(170, 38)
    billboard.StudsOffset = Vector3.new(0, 2.3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = IsEnabled(category) and Config.Nametags
    billboard.MaxDistance = Config.MaxDistance
    billboard.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextColor3 = GetColor(category)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.TextWrapped = true
    label.Text = CategoryInfo[category].Label
    label.Parent = billboard
    return billboard
end

-- ---- Registrar objetos una sola vez
local function RegisterObject(instance, category)
    if not instance or not category or not Registry[category] then
        return
    end
    if not IsAlive(instance) or Registry[category][instance] then
        return
    end
    if not GetRootPart(instance) then
        return
    end

    local entry = {
        Instance = instance,
        Category = category,
        Highlight = nil,
        Billboard = nil
    }

    local okHighlight, highlight = pcall(CreateHighlight, instance, category)
    if okHighlight then
        entry.Highlight = highlight
    end

    local okBillboard, billboard = pcall(CreateBillboard, instance, category)
    if okBillboard then
        entry.Billboard = billboard
    end

    Registry[category][instance] = entry
end

-- ---- Escaneo limitado al mapa
local function GetMapRoots()
    local roots = {}
    local map = Workspace:FindFirstChild("Map")
    local map1 = Workspace:FindFirstChild("Map1")

    if map then
        table.insert(roots, map)
    end
    if map1 and map1 ~= map then
        table.insert(roots, map1)
    end
    if #roots == 0 then
        table.insert(roots, Workspace)
    end
    return roots
end

local function ScanInstance(instance)
    if not instance or not IsAlive(instance) then
        return
    end
    if not (instance:IsA("Model") or instance:IsA("Folder")
        or instance:IsA("BasePart")) then
        return
    end

    local candidate, category = GetCandidate(instance)
    if candidate and category then
        RegisterObject(candidate, category)
    end
end

local function ScanWorld()
    if not Running then
        return
    end

    for _, root in ipairs(GetMapRoots()) do
        ScanInstance(root)
        for _, descendant in ipairs(root:GetDescendants()) do
            if not Running then
                return
            end
            ScanInstance(descendant)
        end
    end
end

-- ---- CONTINUA EN LA PARTE 2


-- ProtoRun Lite - World ESP Optimizado
-- PARTE 2/2: Actualizacion, interfaz y conexiones
-- ----

-- ---- Leer porcentaje del generador
local function GetGeneratorPercent(instance)
    local names = {
        "RepairProgress", "GeneratorProgress",
        "Progress", "RepairPercentage", "Percent"
    }

    for _, name in ipairs(names) do
        local value = instance:GetAttribute(name)
        if typeof(value) == "number" then
            if value >= 0 and value <= 1 then
                value *= 100
            end
            return math.clamp(math.floor(value + 0.5), 0, 100)
        end
    end

    for _, child in ipairs(instance:GetDescendants()) do
        local name = SafeName(child)

        if child:IsA("NumberValue") or child:IsA("IntValue") then
            if string.find(name, "progress", 1, true)
                or string.find(name, "repair", 1, true)
                or string.find(name, "percent", 1, true) then
                local value = child.Value
                if value >= 0 and value <= 1 then
                    value *= 100
                end
                return math.clamp(math.floor(value + 0.5), 0, 100)
            end
        end

        for _, attributeName in ipairs(names) do
            local value = child:GetAttribute(attributeName)
            if typeof(value) == "number" then
                if value >= 0 and value <= 1 then
                    value *= 100
                end
                return math.clamp(math.floor(value + 0.5), 0, 100)
            end
        end
    end

    return nil
end

-- ---- Actualizar elementos existentes sin recrearlos
local function UpdateEntry(entry)
    local instance = entry.Instance
    local category = entry.Category

    if not IsAlive(instance) then
        return false
    end

    local distance = GetDistance(instance)
    local inRange = distance == nil or distance <= Config.MaxDistance
    local enabled = IsEnabled(category) and inRange
    local color = GetColor(category)

    if entry.Highlight then
        entry.Highlight.Enabled = enabled
        entry.Highlight.FillColor = color
        entry.Highlight.OutlineColor = color
    end

    if entry.Billboard then
        entry.Billboard.Enabled = enabled and Config.Nametags
        entry.Billboard.MaxDistance = Config.MaxDistance

        local label = entry.Billboard:FindFirstChild("Label")
        if label then
            label.TextColor3 = color

            local text = GetDisplayName(instance)
            if category == "Generator" and Config.GeneratorPercent then
                local percent = GetGeneratorPercent(instance)
                if percent ~= nil then
                    text ..= "\nRepair: " .. tostring(percent) .. "%"
                end
            end

            if Config.Distance and distance then
                text ..= "\n" .. tostring(math.floor(distance + 0.5)) .. " studs"
            end
            label.Text = text
        end
    end

    return true
end

local function UpdateAll()
    local total = 0
    local active = 0

    for category, objects in pairs(Registry) do
        for instance, entry in pairs(objects) do
            local success, result = pcall(UpdateEntry, entry)
            if not success or result == false then
                UnregisterObject(instance, category)
            else
                total += 1
                if IsEnabled(category) then
                    active += 1
                end
            end
        end
    end

    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = string.format(
            "Objetos: %d | Activos: %d",
            total,
            active
        )
    end
end

-- ---- Controles visuales
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 5)
    corner.Parent = parent
end

local function CreateButton(parent, text, height)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, height or 29)
    button.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Parent = parent
    CreateCorner(button, 5)
    return button
end

local function CreateLabel(parent, text, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, height or 22)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(225, 225, 235)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function RefreshToggle(category)
    local button = ToggleButtons[category]
    if not button then
        return
    end

    local enabled = Config[category]
    button.Text = CategoryInfo[category].Label
        .. ": " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(35, 115, 75)
        or Color3.fromRGB(95, 50, 55)
end

-- ---- Cierre y limpieza
local function Shutdown()
    if not Running then
        return
    end
    Running = false

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Connections)
    table.clear(PendingInstances)

    for category, objects in pairs(Registry) do
        for instance, entry in pairs(objects) do
            DestroyVisuals(entry)
            objects[instance] = nil
        end
    end

    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
end

-- ---- Crear menu
local function CreateTestUI()
    local old = PlayerGui:FindFirstChild("ProtoRunWorldESP")
    if old then
        old:Destroy()
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ProtoRunWorldESP"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.fromOffset(230, 420)
    MainFrame.Position = UDim2.new(0, 18, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    CreateCorner(MainFrame, 8)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Color3.fromRGB(38, 44, 57)
    header.BorderSizePixel = 0
    header.Parent = MainFrame
    CreateCorner(header, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.fromOffset(9, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "PROTO RUN | WORLD ESP"
    title.TextSize = 11
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.fromOffset(27, 25)
    minimize.Position = UDim2.new(1, -59, 0, 5)
    minimize.Text = "-"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 15
    minimize.TextColor3 = Color3.new(1, 1, 1)
    minimize.BackgroundColor3 = Color3.fromRGB(65, 75, 95)
    minimize.Parent = header
    CreateCorner(minimize, 4)

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(27, 25)
    close.Position = UDim2.new(1, -30, 0, 5)
    close.Text = "X"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 12
    close.TextColor3 = Color3.new(1, 1, 1)
    close.BackgroundColor3 = Color3.fromRGB(145, 50, 58)
    close.Parent = header
    CreateCorner(close, 4)

    local content = Instance.new("ScrollingFrame")
    content.Position = UDim2.fromOffset(9, 43)
    content.Size = UDim2.new(1, -18, 1, -52)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.Parent = MainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    CreateLabel(content, "CONTROL GENERAL", 20)

    local master = CreateButton(content, "MASTER ESP: ON", 30)
    master.Activated:Connect(function()
        Config.Master = not Config.Master
        master.Text = "MASTER ESP: " .. (Config.Master and "ON" or "OFF")
        master.BackgroundColor3 = Config.Master
            and Color3.fromRGB(35, 115, 75)
            or Color3.fromRGB(95, 50, 55)
    end)

    CreateLabel(content, "CATEGORIAS", 20)

    local categories = {
        "Generator", "Hook", "Gate",
        "Window", "Pallet", "SCPZombie"
    }

    for _, category in ipairs(categories) do
        local button = CreateButton(content, category, 29)
        ToggleButtons[category] = button
        RefreshToggle(category)

        button.Activated:Connect(function()
            Config[category] = not Config[category]
            RefreshToggle(category)
        end)
    end

    CreateLabel(content, "OPCIONES", 20)

    local tags = CreateButton(content, "Etiquetas: ON", 29)
    tags.Activated:Connect(function()
        Config.Nametags = not Config.Nametags
        tags.Text = "Etiquetas: " .. (Config.Nametags and "ON" or "OFF")
    end)

    local distance = CreateButton(content, "Distancia: ON", 29)
    distance.Activated:Connect(function()
        Config.Distance = not Config.Distance
        distance.Text = "Distancia: " .. (Config.Distance and "ON" or "OFF")
    end)

    local percent = CreateButton(content, "Porcentaje generador: ON", 29)
    percent.Activated:Connect(function()
        Config.GeneratorPercent = not Config.GeneratorPercent
        percent.Text = "Porcentaje generador: "
            .. (Config.GeneratorPercent and "ON" or "OFF")
    end)

    local color = CreateButton(content, "Color ventana: 6/31", 29)
    color.Activated:Connect(function()
        Config.WindowColorIndex = Config.WindowColorIndex % #Palette + 1
        color.Text = string.format(
            "Color ventana: %d/31",
            Config.WindowColorIndex
        )
    end)

    local range = CreateButton(content, "Rango: 2500 studs", 29)
    range.Activated:Connect(function()
        local ranges = {500, 1000, 1500, 2500}
        local index = 1
        for i, value in ipairs(ranges) do
            if value == Config.MaxDistance then
                index = i
                break
            end
        end
        index = index % #ranges + 1
        Config.MaxDistance = ranges[index]
        range.Text = "Rango: " .. Config.MaxDistance .. " studs"
    end)

    StatusLabel = CreateLabel(content, "Objetos: 0 | Activos: 0", 22)

    local minimized = false
    minimize.Activated:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        MainFrame.Size = minimized
            and UDim2.fromOffset(230, 36)
            or UDim2.fromOffset(230, 420)
        minimize.Text = minimized and "+" or "-"
    end)

    close.Activated:Connect(Shutdown)

    -- Arrastre de la ventana
    local dragging = false
    local dragStart
    local startPosition

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position

            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if endConnection then
                        endConnection:Disconnect()
                    end
                end
            end)
        end
    end)

    table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))
end

-- ---- Procesar objetos nuevos sin escanear todo el mapa
table.insert(Connections, Workspace.DescendantAdded:Connect(function(instance)
    if not Running or PendingInstances[instance] then
        return
    end

    PendingInstances[instance] = true
    task.delay(0.15, function()
        PendingInstances[instance] = nil
        if Running and IsAlive(instance) then
            pcall(ScanInstance, instance)
        end
    end)
end))

table.insert(Connections, Workspace.DescendantRemoving:Connect(function(instance)
    for category, objects in pairs(Registry) do
        for registered in pairs(objects) do
            if registered == instance then
                UnregisterObject(registered, category)
            else
                local ok, descendant = pcall(function()
                    return registered:IsDescendantOf(instance)
                end)
                if ok and descendant then
                    UnregisterObject(registered, category)
                end
            end
        end
    end
end))

-- ---- Ciclo controlado de actualizacion
table.insert(Connections, RunService.Heartbeat:Connect(function(deltaTime)
    if not Running then
        return
    end

    ScanAccumulator += deltaTime
    UpdateAccumulator += deltaTime

    if ScanAccumulator >= Config.ScanInterval then
        ScanAccumulator = 0
        task.spawn(function()
            if Running then
                pcall(ScanWorld)
            end
        end)
    end

    if UpdateAccumulator >= Config.UpdateInterval then
        UpdateAccumulator = 0
        pcall(UpdateAll)
    end
end))

-- ---- Iniciar
CreateTestUI()
ScanWorld()
UpdateAll()

print("[ProtoRun Lite] World ESP optimizado iniciado.")

--[=[
UI modular de Roblox (LocalScript) - base visual / estados locales.
Coloca este archivo como LocalScript en StarterPlayer > StarterPlayerScripts.
Las opciones se guardan como estado de UI; no ejecutan acciones de juego por sí solas.
]=]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local IMAGE_IDS = {
    Background = "rbxassetid://106827487721783",
    Button = "rbxassetid://97723259169310",
}

local SECTION_DATA = {{"Dashboard", "76923384537622", {{"info", "Proyecto", "Interfaz modular · Android · UI local"}, {"info", "Estado", "Los controles cambian estados locales; la lógica del juego se integra por separado."}, {"info", "Changelog", "v0.1 · Base visual, navegación, escalado y configuración local"}}}, {"Visual", "128369431495583", {{"group", "ESP", "128369431495583", {{"group", "Highlight ESP Settings", nil, {{"slider", "Transparencia del relleno ESP", 0, 1, 0.35}, {"slider", "Transparencia del contorno ESP", 0, 1, 0}, {"slider", "Tamaño del texto ESP", 8, 24, 14}}}, {"group", "Player Highlight ESP", nil, {{"toggle", "Activar ESP de jugadores", false}, {"multi", "Seleccionar ESP de jugadores", {"Killer", "Survivor", "Spectator"}, {}}, {"toggle", "Nametags de jugadores", false}, {"toggle", "Distancia ESP de jugadores", false}, {"toggle", "Advertencia Killer en Survivor", false}}}, {"group", "Colores players", nil, {{"color", "Color Survivor Rainbow", "#39d98a"}, {"color", "Color Survivor Normal", "#39d98a"}, {"color", "Color Survivor Herido", "#ffbd59"}, {"color", "Color Survivor derribado", "#ff5252"}, {"color", "Color Killer Rainbow", "#ff4f64"}, {"color", "Color Killer", "#ff4f64"}, {"color", "Color Spectator Rainbow", "#b58cff"}, {"color", "Color Spectator", "#b58cff"}}}, {"group", "World Highlight ESP", nil, {{"toggle", "Activar ESP del mundo", false}, {"multi", "Seleccionar objetos del mundo", {"Generators", "Hooks", "Gates", "Windows", "Pallets", "SCP/Zombie"}, {}}, {"toggle", "Nametags del mundo", false}, {"toggle", "Distancia ESP del mundo", false}, {"toggle", "Porcentaje del generator", false}, {"color", "Color Generator", "#4ea1ff"}, {"color", "Color Hook", "#ff6b6b"}, {"color", "Color Gate", "#f7c65b"}, {"color", "Color Window", "#6ee7b7"}, {"color", "Color Pallet", "#b58cff"}, {"color", "Color SCP / Zombie", "#ff8c42"}}}}}, {"group", "Camera", "79839886609854", {{"toggle", "Activar override de FOV de cámara", false}, {"slider", "FOV de cámara", 40, 120, 70}, {"toggle", "Tercera persona (solo Killer)", false}, {"toggle", "Shift Lock (mirar hacia la cámara)", false}, {"toggle", "Zoom infinito hacia afuera", false}}}, {"group", "Lighting", "122076438981661", {{"toggle", "Sin cutscene", false}, {"toggle", "Sin niebla", false}, {"toggle", "Fullbright", false}, {"select", "Tema de clima y cielo", {"Default", "Clear", "Cloudy", "Sunset", "Night"}, "Default"}, {"toggle", "Game Info Panel", false}, {"toggle", "Display Kyst Killer", false}, {"toggle", "Contador de espectadores", false}, {"toggle", "Mostrar perks del Killer", false}, {"toggle", "Predecir mapa", false}, {"toggle", "Ocultar icono de Survivor", false}, {"toggle", "Mostrar Ping y FPS", false}, {"toggle", "Mostrar contador de hooks", false}}}}}, {"Survivor", "116226775614038", {{"group", "Automation", "100548873375720", {{"toggle", "Auto Skillcheck", false}, {"toggle", "Ocultar UI de skillcheck", false}, {"select", "Modo de skillcheck", {"Normal", "Perfect", "Instant"}, "Normal"}, {"toggle", "Boost Gen Bypass", false}}}, {"group", "Fake Perks", "104806511010721", {{"slider", "Cooldown (todas las perks)", 0, 120, 30}, {"toggle", "Flowstate", false}, {"toggle", "Quick Recovery", false}, {"toggle", "Perfect Landing", false}, {"toggle", "Adrenaline Rush", false}}}, {"group", "Survivor Ayuda", "120447678741132", {{"toggle", "Swift Vault", false}, {"toggle", "Swift Vault V2", false}, {"slider", "Velocidad de vault", 1, 3, 1}, {"toggle", "Pallet Reflex", false}, {"slider", "Rango de disparo de pallet (studs)", 1, 30, 8}, {"toggle", "Anti Knock", false}, {"toggle", "Aura Heal (Self)", false}, {"toggle", "Auto Dodge Spear (Veil)", false}, {"toggle", "Aura Heal All", false}, {"toggle", "Cámara en primera persona (Survivor)", false}, {"toggle", "Auto Parry", false}, {"toggle", "Auto Parry Agresif", false}, {"slider", "Distancia de trigger del parry", 1, 30, 8}, {"toggle", "Mostrar círculo de rango de parry", false}, {"toggle", "Fake Parry (tecla V)", false}, {"select", "Animación de Fake Parry", {"Default", "Quick", "Extended"}, "Default"}, {"toggle", "Botón no arrastrable (Fake Parry)", false}, {"toggle", "Fake Generator (tecla B)", false}, {"toggle", "Botón no arrastrable (Fake Gen)", false}}}, {"group", "Escape", "98668024380623", {{"toggle", "Bypass Gate", false}, {"toggle", "Beat Survivor (auto exit)", false}, {"toggle", "Flee Killer", false}, {"slider", "Distancia de huida", 5, 100, 25}}}}}, {"Aim Survivor", "131216405316082", {{"group", "Aimbot", "129000867872009", {{"toggle", "Activar Aimbot", false}, {"toggle", "Usar RMB para apuntar", false}, {"toggle", "Mostrar círculo FOV", false}, {"toggle", "Visibility Check", false}, {"toggle", "Prediction", false}, {"slider", "Tamaño FOV (radio en pantalla)", 10, 500, 100}, {"slider", "Suavidad (Speed Aim)", 1, 20, 5}}}, {"group", "Advanced Crosshair", "97809427353730", {{"toggle", "Activar crosshair", false}, {"select", "Estilo de crosshair", {"Cross", "Dot", "Circle", "Plus"}, "Cross"}, {"color", "Color de crosshair", "#4ea1ff"}, {"slider", "Tamaño de crosshair", 2, 40, 12}, {"slider", "Grosor de crosshair", 1, 8, 2}, {"slider", "Gap de crosshair", 0, 20, 4}, {"slider", "Offset posición X", -100, 100, 0}, {"slider", "Offset posición Y", -100, 100, 0}}}, {"group", "Silent Aim Twist Of Fate", "131216405316082", {{"toggle", "Silent Aim Twist Of Fate", false}, {"toggle", "ToF Laser", false}, {"toggle", "ToF Wall Check", false}, {"toggle", "ToF Block When Knocked", false}, {"select", "Modo de objetivo ToF", {"Killer", "Survivors", "Zombie"}, "Killer"}, {"select", "Tecla Silent Aim", {"None", "Q", "E", "R", "F", "V", "X", "C"}, "None"}}}, {"group", "Silent Aim Flashlight", "131216405316082", {{"toggle", "Silent Aim Flashlight", false}, {"toggle", "Flashlight Laser", false}, {"slider", "Rango Flashlight", 1, 100, 25}, {"slider", "Suavidad Flashlight", 1, 20, 5}, {"select", "Parte objetivo Flashlight", {"Head", "Torso", "Root"}, "Torso"}}}}}, {"Killer", "82556507969698", {{"group", "Killer Ataque", "72284651806372", {{"toggle", "Auto Attack", false}, {"slider", "Rango de ataque", 1, 30, 8}, {"toggle", "Hitbox Expand", false}, {"slider", "Tamaño de hitbox", 1, 15, 3}, {"toggle", "Infinite Lunge (ataque básico)", false}}}, {"group", "Killer Ability", "90409197187623", {{"toggle", "Infinite Abyssal Burst (Abyss)", false}, {"toggle", "Infinite Skill (Hidden)", false}, {"toggle", "Infinite Frenzy (Jeff)", false}, {"toggle", "Infinite Lake Mist (Jason)", false}, {"toggle", "Infinite Pursuit (Jason)", false}, {"toggle", "Infinite Grab (Myers)", false}, {"toggle", "Fake Attack (Counter Parry)", false}, {"toggle", "Botón no arrastrable (Inf Grab)", false}}}, {"group", "Utilidad killer", "71690311330962", {{"toggle", "Auto Hook", false}, {"toggle", "Destroy Pallets", false}, {"toggle", "Auto Kick Generator", false}, {"toggle", "Block All Vaults", false}, {"toggle", "Auto Drop All Pallets", false}, {"toggle", "Break All Pallet", false}, {"toggle", "Anti Blind (Flashlight)", false}, {"toggle", "Remove Palletwrong (All)", false}, {"toggle", "No Slowdown", false}, {"toggle", "Beat Killer (auto kill)", false}, {"toggle", "Target Lock.", false}, {"slider", "Distancia máxima Target Lock", 1, 100, 25}, {"toggle", "Bloquear botón Target Lock", false}}}}}, {"Killer Aim", "140146718588465", {{"group", "Aimbot Spear (Veil)", "108474847929998", {{"toggle", "Spear Aimbot", false}, {"toggle", "Keybind de toggle (PC)", false}, {"toggle", "Silent Aim Spear (Veil)", false}, {"toggle", "Mostrar círculo FOV", false}, {"toggle", "Mostrar láser al objetivo", false}, {"slider", "Radio FOV", 10, 500, 100}, {"toggle", "Auto Predict", false}, {"slider", "Velocidad de lanza", 1, 300, 100}, {"slider", "Gravedad", 0, 200, 50}, {"slider", "Vector horizontal", -100, 100, 0}, {"select", "Parte objetivo", {"Torso", "Head", "Root"}, "Torso"}}}, {"group", "Silent Aim Flask (Cure)", "87415718393828", {{"toggle", "Silent Aim Flask (Cure)", false}, {"toggle", "Flask Laser (Cure)", false}}}}}, {"Mapping", "136230310763744", {{"group", "Teleport", "106629339497075", {{"button", "Actualizar lista de jugadores"}, {"select", "Seleccionar jugador para teletransporte", {"(sin seleccionar)"}, "(sin seleccionar)"}, {"button", "Teleport al jugador"}, {"toggle", "TP a Gen", false}, {"toggle", "TP a Gate", false}, {"toggle", "TP a Hook", false}}}, {"group", "Radar", "121934977788749", {{"info", "Radar Configuration", "Configuración visual local del radar."}, {"toggle", "Radar activado", false}, {"toggle", "Modo círculo del radar", true}, {"slider", "Tamaño del radar", 100, 400, 180}, {"slider", "Rango del radar", 25, 500, 150}, {"slider", "Transparencia del radar", 0, 1, 0.25}}}, {"group", "Radar Filters", "71708933906334", {{"toggle", "Mostrar Killer", true}, {"toggle", "Mostrar Survivor", true}, {"toggle", "Mostrar Generator", true}, {"toggle", "Mostrar Pallet", true}, {"toggle", "Mostrar Hook", true}, {"toggle", "Mostrar Gate", true}, {"toggle", "Mostrar Window", true}, {"toggle", "Mostrar Zombie", true}}}}}, {"Player", "88408405954370", {{"group", "Movement", "98668024380623", {{"toggle", "Auto Crouch BETA", false}, {"toggle", "Speed Hack", false}, {"slider", "Valor de velocidad", 1, 100, 16}, {"toggle", "Jump Hack", false}, {"slider", "Jump Power", 1, 150, 50}, {"toggle", "Infinite Jump", false}, {"toggle", "Anti Fall Damage", false}, {"toggle", "Noclip", false}, {"toggle", "Moonwalk", false}, {"slider", "Velocidad zigzag Moonwalk", 1, 30, 8}, {"slider", "Potencia boost Moonwalk", 0, 100, 20}, {"toggle", "Bloquear botón Moonwalk", false}, {"toggle", "Invisible Not Visual", false}, {"slider", "Velocidad Invisible", 1, 30, 8}, {"toggle", "Anti AFK", false}}}, {"group", "Fling", "140146718588465", {{"toggle", "Activar Fling", false}, {"slider", "Fuerza de Fling", 1, 500, 100}, {"toggle", "Fling al más cercano", false}, {"toggle", "Fling a todos", false}}}, {"group", "Emote [BETA]", "108329282586807", {{"toggle", "Activar Emote", false}, {"select", "Seleccionar Emote", {"Default", "Wave", "Dance", "Cheer", "Point"}, "Default"}}}, {"group", "Fun", "99927158255777", {{"info", "Spoof Stats [Visual Only]", "Solo valores mostrados en esta interfaz."}, {"input", "Set Level", "100"}, {"input", "Set Gears", "0"}, {"input", "Set Screws", "0"}, {"button", "Apply Spoof Data"}}}, {"group", "Streamer Mode", "92090688433136", {{"toggle", "Hide Name", false}}}}}, {"Config / Ajustes", "87830132220340", {{"info", "Configuración", "Los perfiles se guardan en memoria durante esta sesión. Para persistencia real, integra almacenamiento autorizado."}, {"input", "Nombre de config", "Default"}, {"button", "Guardar configuración"}, {"button", "Cargar configuración"}, {"button", "Borrar configuración"}, {"select", "Tema / opciones de la propia UI", {"Dark Blue", "Dark Gray", "Black"}, "Dark Blue"}}}}

local COLORS = {
    Background = Color3.fromRGB(10, 12, 17),
    Panel = Color3.fromRGB(17, 20, 28),
    Panel2 = Color3.fromRGB(23, 27, 37),
    Border = Color3.fromRGB(43, 51, 66),
    Text = Color3.fromRGB(232, 237, 246),
    Muted = Color3.fromRGB(142, 153, 173),
    Accent = Color3.fromRGB(55, 139, 255),
    AccentSoft = Color3.fromRGB(27, 62, 111),
    Off = Color3.fromRGB(61, 68, 82),
    Danger = Color3.fromRGB(255, 95, 109),
}

local state = {}
local savedConfigs = {}
local selectedTab = "Dashboard"
local expandedGroups = {}
local selectedMulti = {}
local guiScale = 1
local isDraggingMenu = false
local isDraggingButton = false
local buttonMoved = false
local dragStart, startPosition, dragInput
local buttonDragStart, buttonStartPosition, buttonDragInput
local currentTheme = "Dark Blue"

local function keyFor(section, group, option)
    return table.concat({section or "", group or "", option or ""}, "::")
end

local function setState(key, value)
    state[key] = value
end

local function getState(key, default)
    local value = state[key]
    if value == nil then return default end
    return value
end

local function make(className, props, parent)
    local object = Instance.new(className)
    for property, value in pairs(props or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local screenGui = make("ScreenGui", {
    Name = "ModularControlUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local rootScale = make("UIScale", {Scale = guiScale}, screenGui)

local menu = make("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.new(0.08, 0, 0.12, 0),
    Size = UDim2.fromOffset(760, 510),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, screenGui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, menu)
make("UIStroke", {Color = COLORS.Border, Thickness = 1}, menu)

local header = make("Frame", {
    Name = "Header", Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0,
}, menu)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, header)
make("Frame", {Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0}, header)
local title = make("TextLabel", {
    Name = "Title", Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -130, 1, 0),
    BackgroundTransparency = 1, Text = "NIGHTSHIFT  /  CONTROL CENTER", TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
}, header)
local statusLabel = make("TextLabel", {
    Position = UDim2.new(1, -105, 0, 0), Size = UDim2.fromOffset(90, 54), BackgroundTransparency = 1,
    Text = "UI LOCAL", TextColor3 = COLORS.Accent, Font = Enum.Font.GothamBold, TextSize = 10,
}, header)

local nav = make("ScrollingFrame", {
    Name = "Navigation", Position = UDim2.fromOffset(10, 64), Size = UDim2.new(0, 178, 1, -76),
    BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, menu)
make("UICorner", {CornerRadius = UDim.new(0, 9)}, nav)
make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7)}, nav)
make("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, nav)

local content = make("ScrollingFrame", {
    Name = "Content", Position = UDim2.new(0, 198, 0, 64), Size = UDim2.new(1, -210, 1, -76),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLORS.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, menu)
make("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 7)}, content)
make("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, content)

local floatingButton = make("ImageButton", {
    Name = "OpenButton", Position = UDim2.new(0, 18, 0.55, 0), Size = UDim2.fromOffset(54, 54),
    BackgroundColor3 = COLORS.Panel2, Image = IMAGE_IDS.Button, ImageColor3 = COLORS.Text,
    AutoButtonColor = true, ZIndex = 20,
}, screenGui)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, floatingButton)
make("UIStroke", {Color = COLORS.Accent, Thickness = 2}, floatingButton)

local scaleHandle = make("TextButton", {
    Name = "ScaleHandle", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -7, 1, -7),
    Size = UDim2.fromOffset(28, 28), BackgroundColor3 = COLORS.Accent, Text = "↘",
    TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 17,
    AutoButtonColor = true, ZIndex = 30,
}, menu)
make("UICorner", {CornerRadius = UDim.new(0, 7)}, scaleHandle)

local function applyTheme(themeName)
    currentTheme = themeName or currentTheme
    if currentTheme == "Dark Gray" then
        COLORS.Background = Color3.fromRGB(18, 19, 22)
        COLORS.Panel = Color3.fromRGB(28, 29, 34)
        COLORS.Panel2 = Color3.fromRGB(38, 40, 47)
        COLORS.Accent = Color3.fromRGB(140, 155, 180)
    elseif currentTheme == "Black" then
        COLORS.Background = Color3.fromRGB(4, 5, 7)
        COLORS.Panel = Color3.fromRGB(11, 12, 15)
        COLORS.Panel2 = Color3.fromRGB(18, 20, 25)
        COLORS.Accent = Color3.fromRGB(55, 139, 255)
    else
        COLORS.Background = Color3.fromRGB(10, 12, 17)
        COLORS.Panel = Color3.fromRGB(17, 20, 28)
        COLORS.Panel2 = Color3.fromRGB(23, 27, 37)
        COLORS.Accent = Color3.fromRGB(55, 139, 255)
    end
    menu.BackgroundColor3 = COLORS.Background
    header.BackgroundColor3 = COLORS.Panel
    nav.BackgroundColor3 = COLORS.Panel
    title.TextColor3 = COLORS.Text
    statusLabel.TextColor3 = COLORS.Accent
    floatingButton.UIStroke.Color = COLORS.Accent
    scaleHandle.BackgroundColor3 = COLORS.Accent
end

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
    end
end

local function sectionHeader(text, imageId)
    local row = make("Frame", {Size = UDim2.new(1, -4, 0, 48), BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0}, content)
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, row)
    make("Frame", {Size = UDim2.new(0, 3, 1, -12), Position = UDim2.fromOffset(0, 6), BackgroundColor3 = COLORS.Accent, BorderSizePixel = 0}, row)
    local label = make("TextLabel", {Position = UDim2.fromOffset(13, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, row)
    if imageId then
        local icon = make("ImageLabel", {Position = UDim2.new(1, -36, 0.5, -12), Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, Image = "rbxassetid://" .. tostring(imageId), ScaleType = Enum.ScaleType.Fit}, row)
        label.Size = UDim2.new(1, -55, 1, 0)
    end
end

local function makeLabel(parent, text, size, color)
    return make("TextLabel", {Size = size or UDim2.new(1, -12, 0, 30), BackgroundTransparency = 1, Text = text, TextColor3 = color or COLORS.Text, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left}, parent)
end

local function controlRow(parent, height)
    local row = make("Frame", {Size = UDim2.new(1, 0, 0, height or 42), BackgroundColor3 = COLORS.Panel2, BorderSizePixel = 0}, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, row)
    make("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 9)}, row)
    return row
end

local function makeToggle(parent, section, groupName, optionName, defaultValue)
    local key = keyFor(section, groupName, optionName)
    local row = controlRow(parent, 40)
    local label = makeLabel(row, optionName, UDim2.new(1, -70, 1, 0))
    local button = make("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(54, 25), BackgroundColor3 = COLORS.Off, Text = "OFF", TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 10}, row)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, button)
    local function refresh()
        local value = getState(key, defaultValue)
        button.Text = value and "ON" or "OFF"
        button.BackgroundColor3 = value and COLORS.Accent or COLORS.Off
        label.TextColor3 = value and COLORS.Text or COLORS.Muted
    end
    button.Activated:Connect(function() setState(key, not getState(key, defaultValue)); refresh() end)
    refresh()
end

local function makeSlider(parent, section, groupName, optionName, minValue, maxValue, defaultValue)
    local key = keyFor(section, groupName, optionName)
    local row = controlRow(parent, 57)
    local label = makeLabel(row, optionName, UDim2.new(1, -58, 0, 25))
    local valueLabel = make("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 2), Size = UDim2.fromOffset(48, 22), BackgroundTransparency = 1, TextColor3 = COLORS.Accent, Font = Enum.Font.GothamBold, TextSize = 11, Text = tostring(defaultValue)}, row)
    local track = make("Frame", {Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 5), BackgroundColor3 = COLORS.Off, BorderSizePixel = 0}, row)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
    local fill = make("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = COLORS.Accent, BorderSizePixel = 0}, track)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
    local knob = make("TextButton", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(15, 15), BackgroundColor3 = COLORS.Text, Text = "", AutoButtonColor = false}, track)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)
    local dragging = false
    local function setFromX(x)
        local width = math.max(track.AbsoluteSize.X, 1)
        local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        local value = math.floor((minValue + (maxValue - minValue) * alpha) * 100 + 0.5) / 100
        setState(key, value)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
    end
    local function refresh()
        local value = getState(key, defaultValue)
        local alpha = math.clamp((value - minValue) / math.max(maxValue - minValue, 0.001), 0, 1)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setFromX(input.Position.X) end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setFromX(input.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFromX(input.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    refresh()
end

local function makeSelect(parent, section, groupName, optionName, options, defaultValue)
    local key = keyFor(section, groupName, optionName)
    local row = controlRow(parent, 42)
    local label = makeLabel(row, optionName, UDim2.new(0.48, -4, 1, 0))
    local button = make("TextButton", {Position = UDim2.new(0.48, 0, 0.5, -13), Size = UDim2.new(0.52, 0, 0, 26), BackgroundColor3 = COLORS.Background, Text = tostring(getState(key, defaultValue)), TextColor3 = COLORS.Text, Font = Enum.Font.Gotham, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd}, row)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, button)
    local popup
    local index = 1
    for i, option in ipairs(options) do if option == getState(key, defaultValue) then index = i end end
    button.Activated:Connect(function()
        if popup then popup:Destroy(); popup = nil; return end
        popup = make("Frame", {Position = UDim2.new(0.48, 0, 1, 3), Size = UDim2.new(0.52, 0, 0, math.min(#options * 30, 150)), BackgroundColor3 = COLORS.Background, BorderSizePixel = 0, ZIndex = 15}, row)
        make("UICorner", {CornerRadius = UDim.new(0, 6)}, popup)
        make("UIStroke", {Color = COLORS.Border, Thickness = 1}, popup)
        local list = make("ScrollingFrame", {Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 16}, popup)
        make("UIListLayout", {Padding = UDim.new(0,2), SortOrder = Enum.SortOrder.LayoutOrder}, list)
        for _, option in ipairs(options) do
            local choice = make("TextButton", {Size = UDim2.new(1, -4, 0, 28), BackgroundColor3 = option == getState(key, defaultValue) and COLORS.AccentSoft or COLORS.Panel, Text = tostring(option), TextColor3 = option == getState(key, defaultValue) and COLORS.Text or COLORS.Muted, Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 17}, list)
            choice.Activated:Connect(function()
                setState(key, option); button.Text = tostring(option); popup:Destroy(); popup = nil
            end)
        end
    end)
end

local function makeMulti(parent, section, groupName, optionName, options, defaults)
    local key = keyFor(section, groupName, optionName)
    selectedMulti[key] = selectedMulti[key] or {}
    for _, value in ipairs(defaults or {}) do selectedMulti[key][value] = true end
    local outer = make("Frame", {Size = UDim2.new(1,0,0,44 + #options * 30), BackgroundColor3 = COLORS.Panel2, BorderSizePixel = 0}, parent)
    make("UICorner", {CornerRadius = UDim.new(0,7)}, outer)
    makeLabel(outer, optionName, UDim2.new(1,-16,0,38)).Position = UDim2.fromOffset(10,0)
    local list = make("Frame", {Position = UDim2.fromOffset(8,39), Size = UDim2.new(1,-16,0,#options*30), BackgroundTransparency = 1}, outer)
    make("UIListLayout", {Padding = UDim.new(0,2), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    for _, option in ipairs(options) do
        local button = make("TextButton", {Size = UDim2.new(1,0,0,28), BackgroundColor3 = selectedMulti[key][option] and COLORS.AccentSoft or COLORS.Background, Text = (selectedMulti[key][option] and "●  " or "○  ") .. option, TextColor3 = selectedMulti[key][option] and COLORS.Text or COLORS.Muted, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, list)
        make("UIPadding", {PaddingLeft = UDim.new(0,8)}, button)
        button.Activated:Connect(function()
            selectedMulti[key][option] = not selectedMulti[key][option]
            local active = selectedMulti[key][option]
            button.Text = (active and "●  " or "○  ") .. option
            button.TextColor3 = active and COLORS.Text or COLORS.Muted
            button.BackgroundColor3 = active and COLORS.AccentSoft or COLORS.Background
            state[key] = selectedMulti[key]
        end)
    end
    state[key] = selectedMulti[key]
end

local function makeColor(parent, section, groupName, optionName, defaultValue)
    local key = keyFor(section, groupName, optionName)
    local row = controlRow(parent, 42)
    makeLabel(row, optionName, UDim2.new(1,-110,1,0))
    local input = make("TextBox", {AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,0,0.5,0), Size = UDim2.fromOffset(100,26), BackgroundColor3 = COLORS.Background, Text = tostring(getState(key,defaultValue)), PlaceholderText = "#RRGGBB", TextColor3 = COLORS.Text, Font = Enum.Font.Code, TextSize = 11, ClearTextOnFocus = false}, row)
    make("UICorner", {CornerRadius = UDim.new(0,5)}, input)
    input.FocusLost:Connect(function() setState(key,input.Text) end)
end

local function makeInput(parent, section, groupName, optionName, defaultValue)
    local key = keyFor(section, groupName, optionName)
    local row = controlRow(parent, 42)
    makeLabel(row, optionName, UDim2.new(0.48,-4,1,0))
    local input = make("TextBox", {Position = UDim2.new(0.48,0,0.5,-13), Size = UDim2.new(0.52,0,0,26), BackgroundColor3 = COLORS.Background, Text = tostring(getState(key,defaultValue)), PlaceholderText = "Escribir...", TextColor3 = COLORS.Text, Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false}, row)
    make("UICorner", {CornerRadius = UDim.new(0,5)}, input)
    input.FocusLost:Connect(function() setState(key,input.Text) end)
end

local function makeButton(parent, section, groupName, optionName)
    local row = controlRow(parent, 42)
    local button = make("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = optionName, TextColor3 = COLORS.Accent, Font = Enum.Font.GothamBold, TextSize = 12}, row)
    button.Activated:Connect(function()
        if optionName == "Actualizar lista de jugadores" then
            local key = keyFor(section, groupName, "Seleccionar jugador para teletransporte")
            local list = {"(sin seleccionar)"}
            for _, other in ipairs(Players:GetPlayers()) do if other ~= player then table.insert(list, other.Name) end end
            state[key .. "::options"] = list
            statusLabel.Text = "LISTA ACTUALIZADA"
            task.delay(2, function() if statusLabel.Parent then statusLabel.Text = "UI LOCAL" end end)
        elseif optionName == "Guardar configuración" then
            local name = getState(keyFor(section, groupName, "Nombre de config"), "Default")
            savedConfigs[tostring(name)] = {state = table.clone(state), selectedMulti = table.clone(selectedMulti), theme = currentTheme}
            statusLabel.Text = "GUARDADO"
            task.delay(2, function() if statusLabel.Parent then statusLabel.Text = "UI LOCAL" end end)
        elseif optionName == "Cargar configuración" then
            local name = getState(keyFor(section, groupName, "Nombre de config"), "Default")
            local config = savedConfigs[tostring(name)]
            if config then
                state = table.clone(config.state or {})
                selectedMulti = table.clone(config.selectedMulti or {})
                applyTheme(config.theme)
                statusLabel.Text = "CARGADO; CAMBIA DE PESTAÑA"
            else statusLabel.Text = "CONFIG NO EXISTE" end
            task.delay(2, function() if statusLabel.Parent then statusLabel.Text = "UI LOCAL" end end)
        elseif optionName == "Borrar configuración" then
            local name = getState(keyFor(section, groupName, "Nombre de config"), "Default")
            savedConfigs[tostring(name)] = nil
            statusLabel.Text = "BORRADO"
            task.delay(2, function() if statusLabel.Parent then statusLabel.Text = "UI LOCAL" end end)
        elseif optionName == "Apply Spoof Data" then
            statusLabel.Text = "SOLO VISUAL"
            task.delay(2, function() if statusLabel.Parent then statusLabel.Text = "UI LOCAL" end end)
        else
            -- Punto de integración: conecta aquí una acción autorizada del proyecto.
            statusLabel.Text = "SIN LÓGICA ASIGNADA"
            task.delay(2, function() if statusLabel.Parent then statusLabel.Text = "UI LOCAL" end end)
        end
    end)
end

local renderSection
renderSection = function(section)
    clearContent()
    sectionHeader(section[1], section[2])
    if section[1] == "Dashboard" then
        for _, item in ipairs(section[3]) do
            local card = make("Frame", {Size = UDim2.new(1,-4,0,72), BackgroundColor3 = COLORS.Panel2, BorderSizePixel = 0}, content)
            make("UICorner", {CornerRadius = UDim.new(0,8)}, card)
            local titleLabel = makeLabel(card, item[2], UDim2.new(1,-20,0,25), COLORS.Accent)
            titleLabel.Position = UDim2.fromOffset(10,7)
            local body = makeLabel(card, item[3], UDim2.new(1,-20,0,34), COLORS.Muted)
            body.Position = UDim2.fromOffset(10,32)
        end
        return
    end
    local renderControls
    renderControls = function(parent, currentSection, groupName, controls)
        for _, control in ipairs(controls or {}) do
            local kind, name = control[1], control[2]
            if kind == "group" then
                local nestedName, nestedImage, nestedControls = control[2], control[3], control[4]
                local nestedKey = keyFor(currentSection, nestedName, "expanded")
                local nestedOpen = expandedGroups[nestedKey] == true
                local nestedFrame = make("Frame", {Size = UDim2.new(1,0,0,42), BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0, ClipsDescendants = true}, parent)
                make("UICorner", {CornerRadius = UDim.new(0,7)}, nestedFrame)
                local nestedButton = make("TextButton", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Text = (nestedOpen and "▲  " or "▼  ") .. nestedName, TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, nestedFrame)
                make("UIPadding", {PaddingLeft = UDim.new(0,10)}, nestedButton)
                local nestedBody = make("Frame", {Position = UDim2.fromOffset(6,43), Size = UDim2.new(1,-12,0,0), BackgroundTransparency = 1, Visible = nestedOpen, AutomaticSize = Enum.AutomaticSize.Y}, nestedFrame)
                make("UIListLayout", {Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder}, nestedBody)
                renderControls(nestedBody, currentSection, nestedName, nestedControls)
                local function toggleNested()
                    nestedOpen = not nestedOpen
                    expandedGroups[nestedKey] = nestedOpen
                    nestedButton.Text = (nestedOpen and "▲  " or "▼  ") .. nestedName
                    nestedBody.Visible = nestedOpen
                    nestedFrame.Size = nestedOpen and UDim2.new(1,0,0,nestedBody.AbsoluteSize.Y + 49) or UDim2.new(1,0,0,42)
                end
                nestedButton.Activated:Connect(toggleNested)
                if nestedOpen then task.defer(function() if nestedFrame.Parent then nestedFrame.Size = UDim2.new(1,0,0,nestedBody.AbsoluteSize.Y + 49) end end) end
            elseif kind == "toggle" then makeToggle(parent,currentSection,groupName,name,control[3])
            elseif kind == "slider" then makeSlider(parent,currentSection,groupName,name,control[3],control[4],control[5])
            elseif kind == "select" then
                local options = control[3]
                local dynamic = state[keyFor(currentSection,groupName,name) .. "::options"]
                makeSelect(parent,currentSection,groupName,name,dynamic or options,control[4])
            elseif kind == "multi" then makeMulti(parent,currentSection,groupName,name,control[3],control[4])
            elseif kind == "color" then makeColor(parent,currentSection,groupName,name,control[3])
            elseif kind == "input" then makeInput(parent,currentSection,groupName,name,control[3])
            elseif kind == "button" then makeButton(parent,currentSection,groupName,name)
            elseif kind == "info" then
                local card = controlRow(parent, 48)
                local label = makeLabel(card, name .. "  —  " .. tostring(control[3] or ""), UDim2.new(1,0,1,0), COLORS.Muted)
            end
        end
    end
    for _, entry in ipairs(section[3] or {}) do
        if entry[1] == "group" then
            local groupName, imageId, controls = entry[2], entry[3], entry[4]
            local groupKey = keyFor(section[1], groupName, "expanded")
            local opened = expandedGroups[groupKey] == true
            local groupFrame = make("Frame", {Size = UDim2.new(1,-4,0,42), BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0, ClipsDescendants = true}, content)
            make("UICorner", {CornerRadius = UDim.new(0,8)}, groupFrame)
            local groupButton = make("TextButton", {Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1, Text = (opened and "▲  " or "▼  ") .. groupName, TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, groupFrame)
            make("UIPadding", {PaddingLeft = UDim.new(0,12)}, groupButton)
            if imageId then
                local icon = make("ImageLabel", {AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-10,0,21), Size = UDim2.fromOffset(20,20), BackgroundTransparency = 1, Image = "rbxassetid://" .. tostring(imageId)}, groupFrame)
            end
            local body = make("Frame", {Position = UDim2.fromOffset(8,45), Size = UDim2.new(1,-16,0,0), BackgroundTransparency = 1, Visible = opened, AutomaticSize = Enum.AutomaticSize.Y}, groupFrame)
            make("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, body)
            renderControls(body, section[1], groupName, controls)
            local function updateGroup()
                opened = not opened
                expandedGroups[groupKey] = opened
                groupButton.Text = (opened and "▲  " or "▼  ") .. groupName
                body.Visible = opened
                groupFrame.Size = opened and UDim2.new(1,-4,0,body.AbsoluteSize.Y + 53) or UDim2.new(1,-4,0,42)
            end
            groupButton.Activated:Connect(updateGroup)
            if opened then task.defer(function() if groupFrame.Parent then groupFrame.Size = UDim2.new(1,-4,0,body.AbsoluteSize.Y + 53) end end) end
        else
            renderControls(content, section[1], section[1], {entry})
        end
    end
end

local function selectTab(section)
    selectedTab = section[1]
    for _, child in ipairs(nav:GetChildren()) do
        if child:IsA("TextButton") then
            local active = child.Name == "Nav_" .. selectedTab
            child.BackgroundColor3 = active and COLORS.AccentSoft or COLORS.Panel
            child.TextColor3 = active and COLORS.Text or COLORS.Muted
        end
    end
    renderSection(section)
end

for index, section in ipairs(SECTION_DATA) do
    local navButton = make("TextButton", {Name = "Nav_" .. section[1], LayoutOrder = index, Size = UDim2.new(1,0,0,39), BackgroundColor3 = COLORS.Panel, Text = section[1], TextColor3 = COLORS.Muted, Font = Enum.Font.GothamSemibold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, nav)
    make("UICorner", {CornerRadius = UDim.new(0,7)}, navButton)
    make("UIPadding", {PaddingLeft = UDim.new(0,10)}, navButton)
    navButton.Activated:Connect(function() selectTab(section) end)
end

-- Arrastre limitado a la cabecera: el input no se usa para mover la cámara.
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingMenu = true
        dragStart = input.Position
        startPosition = menu.Position
        dragInput = input
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingMenu and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        menu.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
    if isDraggingButton and (input == buttonDragInput or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - buttonDragStart
        if math.abs(delta.X) + math.abs(delta.Y) > 8 then buttonMoved = true end
        floatingButton.Position = UDim2.new(buttonStartPosition.X.Scale, buttonStartPosition.X.Offset + delta.X, buttonStartPosition.Y.Scale, buttonStartPosition.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingMenu = false
        isDraggingButton = false
    end
end)

floatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingButton = true
        buttonMoved = false
        buttonDragStart = input.Position
        buttonStartPosition = floatingButton.Position
        buttonDragInput = input
    end
end)
floatingButton.Activated:Connect(function()
    if not buttonMoved then menu.Visible = not menu.Visible end
end)

-- Escalado integral: UIScale afecta panel, controles y textos conjuntamente.
local scaleDragging = false
local scaleStartY, scaleStartValue
scaleHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        scaleDragging = true
        scaleStartY = input.Position.Y
        scaleStartValue = guiScale
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if scaleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        guiScale = math.clamp(scaleStartValue + (scaleStartY - input.Position.Y) / 320, 0.65, 1.35)
        rootScale.Scale = guiScale
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then scaleDragging = false end
end)

-- Protección de visibilidad de la UI: no modifica ni cancela la cámara/cutscene del juego.
-- ResetOnSpawn=false conserva la interfaz al reaparecer; si otro script la deshabilita,
-- se vuelve a habilitar mientras esta instancia exista.
local visibilityConnection = RunService.Heartbeat:Connect(function()
    if screenGui.Parent ~= playerGui then screenGui.Parent = playerGui end
    if not screenGui.Enabled then screenGui.Enabled = true end
end)
screenGui.Destroying:Connect(function()
    if visibilityConnection then visibilityConnection:Disconnect() end
end)

-- Inicio en Dashboard. La configuración es local a esta sesión; no se escribe en DataStore.
for _, section in ipairs(SECTION_DATA) do
    if section[1] == "Dashboard" then selectTab(section); break end
end

print("[ModularControlUI] UI cargada. Las opciones son estados locales hasta integrar lógica autorizada.")

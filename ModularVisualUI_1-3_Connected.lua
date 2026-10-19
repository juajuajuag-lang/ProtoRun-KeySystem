
-- PARTE 1: BASE UI + DASHBOARD
-- Plataforma: Roblox Studio / Android
-- La logica de Visual se conectara en partes posteriores.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local OLD = PlayerGui:FindFirstChild("ModularVisualUI")
if OLD then
    OLD:Destroy()
end

local Theme = {
    Background = Color3.fromRGB(13, 15, 20),
    Panel = Color3.fromRGB(21, 24, 31),
    Panel2 = Color3.fromRGB(29, 33, 42),
    Border = Color3.fromRGB(49, 57, 70),
    Accent = Color3.fromRGB(45, 125, 235),
    Text = Color3.fromRGB(240, 243, 248),
    Muted = Color3.fromRGB(145, 154, 169),
    Red = Color3.fromRGB(220, 60, 65),
    White = Color3.fromRGB(255, 255, 255),
}

local State = {
    CurrentTab = "Dashboard",
    MenuVisible = true,
    Destroyed = false,
    Sections = {},
    Controls = {},
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModularVisualUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 50
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local function Create(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function Stroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function Label(parent, text, size, color, font)
    return Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = color or Theme.Text,
        TextSize = size or 14,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, 22),
    }, parent)
end

local function Button(parent, text, size)
    local button = Create("TextButton", {
        AutoButtonColor = false,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        BackgroundColor3 = Theme.Panel2,
        Size = size or UDim2.new(1, 0, 0, 36),
        BorderSizePixel = 0,
    }, parent)
    Corner(button, 7)
    Stroke(button)
    button.MouseEnter:Connect(function()
        if not State.Destroyed then
            TweenService:Create(button, TweenInfo.new(0.12), {
                BackgroundColor3 = Theme.Border
            }):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if not State.Destroyed then
            TweenService:Create(button, TweenInfo.new(0.12), {
                BackgroundColor3 = Theme.Panel2
            }):Play()
        end
    end)
    return button
end

local function MakeDraggable(target, handle)
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    handle = handle or target

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position
            dragInput = input

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then
            return
        end

        local delta = input.Position - dragStart
        target.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

-- BOTON FLOTANTE
local OpenButton = Button(ScreenGui, "M", UDim2.fromOffset(48, 48))
OpenButton.Name = "OpenMenuButton"
OpenButton.Position = UDim2.new(0, 18, 0.45, 0)
OpenButton.BackgroundColor3 = Theme.Accent
OpenButton.TextSize = 20
OpenButton.ZIndex = 10
Corner(OpenButton, 14)

-- VENTANA PRINCIPAL
local Main = Create("Frame", {
    Name = "MainWindow",
    Size = UDim2.new(0, 560, 0, 390),
    Position = UDim2.new(0.5, -280, 0.5, -195),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, ScreenGui)
Corner(Main, 12)
Stroke(Main, Theme.Border, 1)

local MainScale = Create("UIScale", {
    Scale = 1
}, Main)

local function UpdateScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local scale = math.min(
        1,
        viewport.X / 590,
        viewport.Y / 430
    )
    MainScale.Scale = math.max(0.68, scale)
end

UpdateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(UpdateScale)
end

-- CABECERA
local Header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, Main)

local HeaderTitle = Label(Header, "MODULAR VISUAL", 15, Theme.Text,
    Enum.Font.GothamBold)
HeaderTitle.Position = UDim2.new(0, 15, 0, 2)
HeaderTitle.Size = UDim2.new(1, -110, 1, -4)

local Minimize = Button(Header, "—", UDim2.fromOffset(34, 30))
Minimize.Position = UDim2.new(1, -78, 0, 9)
Minimize.TextSize = 19

local Close = Button(Header, "X", UDim2.fromOffset(34, 30))
Close.Position = UDim2.new(1, -39, 0, 9)
Close.BackgroundColor3 = Theme.Red
Close.TextColor3 = Theme.White

MakeDraggable(Main, Header)
MakeDraggable(OpenButton)

-- BARRA LATERAL
local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Position = UDim2.new(0, 0, 0, 48),
    Size = UDim2.new(0, 145, 1, -48),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, Main)

local SidePadding = Create("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 9),
    PaddingRight = UDim.new(0, 9),
}, Sidebar)

local SideLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Sidebar)

local Content = Create("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.new(0, 145, 0, 48),
    Size = UDim2.new(1, -145, 1, -48),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Theme.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Main)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 14),
    PaddingLeft = UDim.new(0, 14),
    PaddingRight = UDim.new(0, 14),
    PaddingBottom = UDim.new(0, 14),
}, Content)

local ContentLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Content)

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
    local page = Create("Frame", {
        Name = name .. "Page",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, Content)

    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    Pages[name] = page
    return page
end

local function CreateTab(name, symbol)
    local button = Button(
        Sidebar,
        symbol .. "  " .. name,
        UDim2.new(1, 0, 0, 38)
    )
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 12
    button.LayoutOrder = #TabButtons + 1

    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
    }, button)

    TabButtons[name] = button

    button.Activated:Connect(function()
        if State.Destroyed then
            return
        end

        State.CurrentTab = name

        for tabName, page in pairs(Pages) do
            page.Visible = tabName == name
        end

        for tabName, tabButton in pairs(TabButtons) do
            tabButton.BackgroundColor3 =
                tabName == name and Theme.Accent or Theme.Panel2
        end
    end)

    return button
end

local function ShowTab(name)
    State.CurrentTab = name

    for tabName, page in pairs(Pages) do
        page.Visible = tabName == name
    end

    for tabName, tabButton in pairs(TabButtons) do
        tabButton.BackgroundColor3 =
            tabName == name and Theme.Accent or Theme.Panel2
    end
end

CreateTab("Dashboard", "⌂")
CreateTab("Visual", "◈")

-- COMPONENTES DE PAGINA
local function Section(parent, title, subtitle)
    local section = Create("Frame", {
        Name = title:gsub("%W", "") .. "Section",
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, parent)
    Corner(section, 9)
    Stroke(section)

    local padding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 11),
        PaddingRight = UDim.new(0, 11),
    }, section)

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, section)

    Label(section, title, 14, Theme.Text,
        Enum.Font.GothamBold).LayoutOrder = 1

    if subtitle and subtitle ~= "" then
        local description = Label(section, subtitle, 11, Theme.Muted)
        description.Size = UDim2.new(1, 0, 0, 30)
        description.TextWrapped = true
        description.LayoutOrder = 2
    end

    State.Sections[title] = section
    return section
end

local function InfoRow(parent, title, value)
    local row = Create("Frame", {
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
    }, parent)
    Corner(row, 6)

    local left = Label(row, title, 12, Theme.Muted)
    left.Position = UDim2.new(0, 9, 0, 0)
    left.Size = UDim2.new(0.56, -9, 1, 0)

    local right = Label(row, value, 12, Theme.Text,
        Enum.Font.GothamMedium)
    right.Position = UDim2.new(0.56, 0, 0, 0)
    right.Size = UDim2.new(0.44, -9, 1, 0)
    right.TextXAlignment = Enum.TextXAlignment.Right

    return row
end

local function AddPlaceholder(parent, title, description)
    local row = Create("Frame", {
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
    }, parent)
    Corner(row, 7)

    local label = Label(row, title, 12, Theme.Text,
        Enum.Font.GothamMedium)
    label.Position = UDim2.new(0, 9, 0, 3)
    label.Size = UDim2.new(1, -18, 0, 20)

    local detail = Label(row, description or "Pendiente de integrar", 10,
        Theme.Muted)
    detail.Position = UDim2.new(0, 9, 0, 23)
    detail.Size = UDim2.new(1, -18, 0, 18)

    return row
end

-- DASHBOARD
local Dashboard = CreatePage("Dashboard")

local Welcome = Section(
    Dashboard,
    "Dashboard",
    "Panel principal del sistema modular."
)

local WelcomeTitle = Label(
    Welcome,
    "Bienvenido",
    22,
    Theme.Text,
    Enum.Font.GothamBold
)
WelcomeTitle.LayoutOrder = 3
WelcomeTitle.Size = UDim2.new(1, 0, 0, 32)

local WelcomeText = Label(
    Welcome,
    "Configura las opciones desde las secciones disponibles.",
    12,
    Theme.Muted
)
WelcomeText.LayoutOrder = 4
WelcomeText.Size = UDim2.new(1, 0, 0, 38)
WelcomeText.TextWrapped = true

local StatusSection = Section(
    Dashboard,
    "Estado del menú",
    "Información de esta interfaz local."
)

InfoRow(StatusSection, "Interfaz", "Inicializada").LayoutOrder = 3
InfoRow(StatusSection, "Plataforma", "Adaptable").LayoutOrder = 4
InfoRow(StatusSection, "Visual ESP", "Pendiente").LayoutOrder = 5

local ChangeSection = Section(
    Dashboard,
    "Changelog",
    "Cambios previstos para esta versión."
)

AddPlaceholder(
    ChangeSection,
    "Base modular",
    "Ventana movible y navegación inicial."
).LayoutOrder = 3

AddPlaceholder(
    ChangeSection,
    "Visual",
    "Controles y lógica por integrar."
).LayoutOrder = 4

-- VISUAL: ESQUELETO PARA LAS SIGUIENTES PARTES
local Visual = CreatePage("Visual")

local VisualIntro = Section(
    Visual,
    "Visual",
    "Los ajustes se mostrarán aquí. Los elementos del juego se dibujarán fuera del menú."
)

AddPlaceholder(
    VisualIntro,
    "Highlight ESP Settings",
    "Transparencia y tamaño del texto."
).LayoutOrder = 3

AddPlaceholder(
    VisualIntro,
    "Player Highlight ESP",
    "Roles, estados, objetos y Name Tags."
).LayoutOrder = 4

AddPlaceholder(
    VisualIntro,
    "World Highlight ESP",
    "Generadores, porcentaje y otros objetos."
).LayoutOrder = 5

AddPlaceholder(
    VisualIntro,
    "Lighting",
    "Ajustes visuales e información."
).LayoutOrder = 6

AddPlaceholder(
    VisualIntro,
    "Camera",
    "Opciones de cámara."
).LayoutOrder = 7

-- CONTROLES DE VENTANA
Minimize.Activated:Connect(function()
    if State.Destroyed then
        return
    end

    State.MenuVisible = false
    Main.Visible = false
    OpenButton.Visible = true
end)

OpenButton.Activated:Connect(function()
    if State.Destroyed then
        return
    end

    State.MenuVisible = true
    Main.Visible = true
end)

Close.Activated:Connect(function()
    if State.Destroyed then
        return
    end

    State.Destroyed = true
    ScreenGui:Destroy()
end)

ShowTab("Dashboard")

print("[ModularVisualUI] Parte 1 cargada.")


-- PARTE 2: CONTROLES INTERACTIVOS DE VISUAL
-- Pegar debajo de la Parte 1, en el mismo LocalScript.

-- Ocultar el esquema provisional de Visual
VisualIntro.Visible = false

local ControlOrder = {}

local function NextOrder(parent)
    ControlOrder[parent] = (ControlOrder[parent] or 2) + 1
    return ControlOrder[parent]
end

local function SaveControl(name, value)
    State.Controls[name] = value
end

-- PALETA NUMERADA DEL 1 AL 31
-- Basada en los primeros 31 colores de la lista proporcionada.
local ColorPalette = {
    {name = "Blanco", color = Color3.fromRGB(255, 255, 255)},
    {name = "Rojo Carmín", color = Color3.fromRGB(150, 0, 35)},
    {name = "Azul Cielo", color = Color3.fromRGB(100, 190, 255)},
    {name = "Amarillo Limón", color = Color3.fromRGB(240, 255, 0)},
    {name = "Verde Esmeralda", color = Color3.fromRGB(0, 190, 110)},
    {name = "Negro", color = Color3.fromRGB(15, 15, 15)},
    {name = "Naranja Butano", color = Color3.fromRGB(255, 125, 20)},
    {name = "Morado Oscuro", color = Color3.fromRGB(75, 25, 110)},
    {name = "Plata", color = Color3.fromRGB(192, 192, 200)},
    {name = "Verde Lima", color = Color3.fromRGB(130, 255, 0)},
    {name = "Blanco", color = Color3.fromRGB(255, 255, 255)},
    {name = "Azul Marino", color = Color3.fromRGB(15, 35, 100)},
    {name = "Rosa Pastel", color = Color3.fromRGB(255, 180, 200)},
    {name = "Marrón Chocolate", color = Color3.fromRGB(100, 55, 35)},
    {name = "Cian", color = Color3.fromRGB(0, 230, 230)},
    {name = "Mostaza", color = Color3.fromRGB(210, 170, 35)},
    {name = "Magenta", color = Color3.fromRGB(255, 0, 180)},
    {name = "Verde Oliva", color = Color3.fromRGB(105, 115, 35)},
    {name = "Coral", color = Color3.fromRGB(255, 115, 100)},
    {name = "Lavanda", color = Color3.fromRGB(190, 160, 235)},
    {name = "Oro", color = Color3.fromRGB(255, 195, 40)},
    {name = "Gris Carbón", color = Color3.fromRGB(50, 53, 60)},
    {name = "Azul Turquesa", color = Color3.fromRGB(30, 210, 200)},
    {name = "Terracota", color = Color3.fromRGB(190, 90, 65)},
    {name = "Fucsia", color = Color3.fromRGB(245, 0, 150)},
    {name = "Verde Menta", color = Color3.fromRGB(145, 245, 195)},
    {name = "Burdeos", color = Color3.fromRGB(115, 20, 45)},
    {name = "Beige", color = Color3.fromRGB(225, 210, 175)},
    {name = "Violeta", color = Color3.fromRGB(140, 50, 220)},
    {name = "Acua", color = Color3.fromRGB(100, 255, 220)},
    {name = "Salmón", color = Color3.fromRGB(250, 145, 125)},
}

State.ColorPalette = ColorPalette

local function MakeToggle(parent, name, defaultValue, callback)
    local value = defaultValue == true

    local row = Create("Frame", {
        Name = name:gsub("%W", "") .. "Toggle",
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = NextOrder(parent),
    }, parent)
    Corner(row, 7)

    local title = Label(row, name, 12, Theme.Text)
    title.Position = UDim2.new(0, 9, 0, 0)
    title.Size = UDim2.new(1, -65, 1, 0)

    local toggle = Create("TextButton", {
        Name = "ToggleButton",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = value and Theme.Accent or Theme.Border,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(42, 22),
        Position = UDim2.new(1, -50, 0.5, -11),
    }, row)
    Corner(toggle, 11)

    local knob = Create("Frame", {
        Name = "Knob",
        BackgroundColor3 = Theme.White,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(16, 16),
        Position = value and UDim2.new(1, -19, 0.5, -8)
            or UDim2.new(0, 3, 0.5, -8),
    }, toggle)
    Corner(knob, 8)

    local function Update(newValue)
        value = newValue
        SaveControl(name, value)

        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = value and Theme.Accent or Theme.Border,
        }):Play()

        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = value and UDim2.new(1, -19, 0.5, -8)
                or UDim2.new(0, 3, 0.5, -8),
        }):Play()

        if callback then
            callback(value)
        end
    end

    toggle.Activated:Connect(function()
        Update(not value)
    end)

    SaveControl(name, value)

    return {
        Row = row,
        Get = function()
            return value
        end,
        Set = Update,
    }
end

local function MakeSlider(parent, name, minimum, maximum, defaultValue, suffix, callback)
    local value = math.clamp(defaultValue, minimum, maximum)
    local range = maximum - minimum

    local row = Create("Frame", {
        Name = name:gsub("%W", "") .. "Slider",
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 62),
        LayoutOrder = NextOrder(parent),
    }, parent)
    Corner(row, 7)

    local title = Label(row, name, 12, Theme.Text)
    title.Position = UDim2.new(0, 9, 0, 4)
    title.Size = UDim2.new(1, -90, 0, 20)

    local valueLabel = Label(row, tostring(value) .. (suffix or ""), 12, Theme.Text)
    valueLabel.Position = UDim2.new(1, -82, 0, 4)
    valueLabel.Size = UDim2.new(0, 72, 0, 20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 39),
        Size = UDim2.new(1, -20, 0, 5),
    }, row)
    Corner(track, 3)

    local fraction = range == 0 and 0 or (value - minimum) / range

    local fill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(fraction, 0, 1, 0),
    }, track)
    Corner(fill, 3)

    -- Circulo visible que indica la posicion actual
    local knob = Create("TextButton", {
        Name = "SliderKnob",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.White,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(fraction, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = 3,
    }, track)
    Corner(knob, 8)
    Stroke(knob, Theme.Accent, 2)

    local dragging = false

    local function UpdateFromX(screenX)
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return
        end

        local relativeX = math.clamp(
            screenX - track.AbsolutePosition.X,
            0,
            width
        )

        local alpha = relativeX / width
        value = math.floor(minimum + range * alpha + 0.5)
        fraction = range == 0 and 0 or (value - minimum) / range

        fill.Size = UDim2.new(fraction, 0, 1, 0)
        knob.Position = UDim2.new(fraction, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. (suffix or "")

        SaveControl(name, value)

        if callback then
            callback(value)
        end
    end

    local function BeginDrag(input)
        dragging = true
        UpdateFromX(input.Position.X)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            BeginDrag(input)
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            BeginDrag(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            UpdateFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    SaveControl(name, value)

    return {
        Row = row,
        Get = function()
            return value
        end,
        Set = function(newValue)
            newValue = math.clamp(newValue, minimum, maximum)
            local alpha = range == 0 and 0 or (newValue - minimum) / range
            value = newValue
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            valueLabel.Text = tostring(value) .. (suffix or "")
            SaveControl(name, value)
            if callback then
                callback(value)
            end
        end,
    }
end

-- Corrección de MakeDropdown
-- Reemplaza la función anterior completa por esta.

local function MakeDropdown(parent, name, description)
    local container = Instance.new("Frame")
    container.Name = name .. "Container"
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = false
    container.LayoutOrder = NextOrder(parent)

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Name = "DropdownLayout"
    containerLayout.Parent = container
    containerLayout.FillDirection = Enum.FillDirection.Vertical
    containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 5)

    local header = Instance.new("TextButton")
    header.Name = "DropdownHeader"
    header.Parent = container
    header.LayoutOrder = 1
    header.Size = UDim2.new(1, 0, 0, 38)
    header.BackgroundColor3 = Color3.fromRGB(35, 39, 48)
    header.BorderSizePixel = 0
    header.AutoButtonColor = true
    header.Font = Enum.Font.GothamSemibold
    header.TextSize = 13
    header.TextColor3 = Color3.fromRGB(235, 240, 250)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = "  " .. name .. "  ▼"

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 7)
    headerCorner.Parent = header

    local headerPadding = Instance.new("UIPadding")
    headerPadding.PaddingLeft = UDim.new(0, 8)
    headerPadding.PaddingRight = UDim.new(0, 8)
    headerPadding.Parent = header

    local body = Instance.new("Frame")
    body.Name = "DropdownContent"
    body.Parent = container
    body.LayoutOrder = 2
    body.Size = UDim2.new(1, 0, 0, 0)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
    body.BackgroundTransparency = 0.12
    body.BorderSizePixel = 0
    body.ClipsDescendants = false
    body.Visible = false

    local bodyCorner = Instance.new("UICorner")
    bodyCorner.CornerRadius = UDim.new(0, 7)
    bodyCorner.Parent = body

    local bodyPadding = Instance.new("UIPadding")
    bodyPadding.PaddingTop = UDim.new(0, 7)
    bodyPadding.PaddingBottom = UDim.new(0, 7)
    bodyPadding.PaddingLeft = UDim.new(0, 7)
    bodyPadding.PaddingRight = UDim.new(0, 7)
    bodyPadding.Parent = body

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Name = "ContentLayout"
    bodyLayout.Parent = body
    bodyLayout.FillDirection = Enum.FillDirection.Vertical
    bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bodyLayout.Padding = UDim.new(0, 6)

    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Name = "DropdownDescription"
    descriptionLabel.Parent = body
    descriptionLabel.LayoutOrder = 0
    descriptionLabel.Size = UDim2.new(1, 0, 0, 0)
    descriptionLabel.AutomaticSize = Enum.AutomaticSize.Y
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Font = Enum.Font.Gotham
    descriptionLabel.TextSize = 11
    descriptionLabel.TextColor3 = Color3.fromRGB(155, 165, 180)
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextWrapped = true
    descriptionLabel.Text = description or ""

    local isOpen = false
    local function RefreshScrollCanvas()
        local current = container.Parent
        while current and current ~= game do
            if current:IsA("ScrollingFrame") then
                current.AutomaticCanvasSize = Enum.AutomaticSize.Y
                current.CanvasSize = UDim2.new(0, 0, 0, 0)
            end
            current = current.Parent
        end
    end

    local function RefreshLayout()
        task.defer(function()
            if not container.Parent then
                return
            end
            RefreshScrollCanvas()
        end)
    end

    header.Activated:Connect(function()
        isOpen = not isOpen
        body.Visible = isOpen
        header.Text = "  " .. name .. (isOpen and "  ▲" or "  ▼")
        RefreshLayout()
    end)

    bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshLayout)
    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshLayout)

    RefreshLayout()
    return body, container
end

local function MakeColorSlider(parent, name, defaultIndex)
    local preview = Create("Frame", {
        Name = "ColorPreview",
        BackgroundColor3 = ColorPalette[defaultIndex].color,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(18, 18),
        LayoutOrder = NextOrder(parent),
    }, parent)
    Corner(preview, 9)
    Stroke(preview, Theme.White, 1)

    local slider = MakeSlider(
        parent,
        name .. " (Color 1-31)",
        1,
        31,
        defaultIndex,
        "",
        function(index)
            preview.BackgroundColor3 = ColorPalette[index].color
            SaveControl(name .. "Name", ColorPalette[index].name)
            SaveControl(name .. "Color", ColorPalette[index].color)
        end
    )

    SaveControl(name .. "Name", ColorPalette[defaultIndex].name)
    SaveControl(name .. "Color", ColorPalette[defaultIndex].color)

    return slider
end

-- HIGHLIGHT ESP SETTINGS
local SettingsSection = Section(
    Visual,
    "Highlight ESP Settings",
    "Ajustes comunes de los elementos visuales."
)

local SettingsDropdown = MakeDropdown(
    SettingsSection,
    "Highlight ESP Settings",
    "Controla la transparencia y el tamaño de las etiquetas."
)

MakeSlider(
    SettingsDropdown,
    "Transparencia del relleno ESP",
    0, 100, 50, "%",
    function(value)
        SaveControl("FillTransparency", value / 100)
    end
)

MakeSlider(
    SettingsDropdown,
    "Transparencia del contorno ESP",
    0, 100, 0, "%",
    function(value)
        SaveControl("OutlineTransparency", value / 100)
    end
)

MakeSlider(
    SettingsDropdown,
    "Tamaño del texto ESP",
    8, 30, 14, " px"
)

-- PLAYER HIGHLIGHT ESP
local PlayerSection = Section(
    Visual,
    "Player Highlight ESP",
    "Opciones de jugador. Los marcadores se dibujarán fuera del menú."
)

MakeToggle(PlayerSection, "Player Highlight ESP", false)
MakeToggle(PlayerSection, "Survivor ESP", false)
MakeToggle(PlayerSection, "Survivor Items ESP", false)
MakeToggle(PlayerSection, "Killer ESP", false)
MakeToggle(PlayerSection, "Spectator ESP", false)
MakeToggle(PlayerSection, "Player Name Tags", false)
MakeToggle(PlayerSection, "Killer Warning", false)

local PlayerSettings = MakeDropdown(
    PlayerSection,
    "Player Name Tags Settings",
    "El estado y el rol se mostrarán junto al nombre del jugador."
)

MakeToggle(PlayerSettings, "Mostrar nombre del jugador", true)
MakeToggle(PlayerSettings, "Mostrar rol del jugador", true)
MakeToggle(PlayerSettings, "Mostrar estado herido", true)
MakeToggle(PlayerSettings, "Mostrar estado derribado", true)
MakeToggle(PlayerSettings, "Mostrar objeto del Survivor", true)

MakeSlider(
    PlayerSettings,
    "Distancia máxima de jugadores",
    50, 2000, 500, " studs"
)

local RoleColors = MakeDropdown(
    PlayerSection,
    "Player ESP Colors",
    "Elige un color por rol mediante el slider numerado."
)

MakeColorSlider(RoleColors, "Survivor Color", 3)
MakeColorSlider(RoleColors, "Killer Color", 2)
MakeColorSlider(RoleColors, "Spectator Color", 9)

MakeToggle(RoleColors, "Rainbow Survivor", false)
MakeToggle(RoleColors, "Rainbow Killer", false)
MakeToggle(RoleColors, "Rainbow Spectator", false)

-- WORLD HIGHLIGHT ESP: CONTROLES INICIALES
local WorldSection = Section(
    Visual,
    "World Highlight ESP",
    "Opciones de objetos del mundo y generadores."
)

MakeToggle(WorldSection, "World Highlight ESP", false)
MakeToggle(WorldSection, "Generator ESP", false)
MakeToggle(WorldSection, "Hook ESP", false)
MakeToggle(WorldSection, "Gate ESP", false)
MakeToggle(WorldSection, "Window ESP", false)
MakeToggle(WorldSection, "Pallet ESP", false)
MakeToggle(WorldSection, "World Name Tags", false)

local GeneratorSettings = MakeDropdown(
    WorldSection,
    "Generator Settings",
    "El porcentaje real depende de la información que exponga el juego."
)

MakeToggle(GeneratorSettings, "Mostrar porcentaje del generador", true)
MakeToggle(GeneratorSettings, "Mostrar barra horizontal", true)
MakeSlider(
    GeneratorSettings,
    "Distancia máxima de objetos",
    50, 2000, 500, " studs"
)

local GeneratorColors = MakeDropdown(
    WorldSection,
    "Generator Colors",
    "Rangos previstos: rojo 0-15, naranja 16-75 y verde/azul 76-100."
)

MakeColorSlider(GeneratorColors, "Generator Low Color", 2)
MakeColorSlider(GeneratorColors, "Generator Medium Color", 7)
MakeColorSlider(GeneratorColors, "Generator High Color", 5)

-- INFORMACION DE ESTADO PARA FUTURAS CONEXIONES
State.VisualReady = true

print("[ModularVisualUI] Parte 2: controles interactivos cargados.")


-- =========================================================
-- PARTE 3: LIGHTING, CAMARA Y GAME INFO PANEL
-- Requiere las partes 1 y 2 en el mismo LocalScript
-- =========================================================
local LightingService = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local InfoPanels = {}
local PanelPositions = {}
local PanelCounter = 0

State.Lighting = State.Lighting or {}
State.Camera = State.Camera or {}
State.ShowHookCounter = State.ShowHookCounter or false

-- =========================================================
-- GAME INFO PANEL: CREACION INDEPENDIENTE
-- =========================================================
local function CreateInfoPanel(panelKey, titleText)
    if InfoPanels[panelKey] and InfoPanels[panelKey].Root then
        local existing = InfoPanels[panelKey].Root
        if existing.Parent then
            existing.Visible = true
            return InfoPanels[panelKey]
        end
    end

    PanelCounter = PanelCounter + 1

    local root = Create("Frame", {
        Name = "GameInfo_" .. panelKey,
        Size = UDim2.fromOffset(270, 150),
        Position = PanelPositions[panelKey]
            or UDim2.new(0, 24 + ((PanelCounter - 1) % 3) * 28,
                0, 100 + ((PanelCounter - 1) % 4) * 28),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 20,
    }, ScreenGui)

    Corner(root, 9)
    Stroke(root, Theme.Border, 1)

    local header = Create("Frame", {
        Name = "PanelHeader",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 21,
    }, root)

    local title = Label(header, titleText, 12, Theme.Text)
    title.Position = UDim2.fromOffset(10, 0)
    title.Size = UDim2.new(1, -78, 1, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 22

    local minimize = Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -66, 0, 3),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Text = "—",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 18,
        ZIndex = 22,
    }, header)

    local remove = Create("TextButton", {
        Name = "Remove",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -34, 0, 3),
        BackgroundColor3 = Color3.fromRGB(160, 45, 50),
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 13,
        ZIndex = 22,
    }, header)

    Corner(minimize, 6)
    Corner(remove, 6)

    local content = Create("Frame", {
        Name = "Information",
        Position = UDim2.fromOffset(8, 42),
        Size = UDim2.new(1, -16, 1, -50),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 21,
    }, root)

    Corner(content, 7)

    local info = Label(content, "Información\nEsperando datos del juego...", 12, Theme.Text)
    info.Position = UDim2.fromOffset(10, 8)
    info.Size = UDim2.new(1, -20, 1, -16)
    info.TextWrapped = true
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.ZIndex = 22

    local minimized = false
    local dragging = false
    local dragStart
    local startPosition

    minimize.Activated:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        root.Size = minimized
            and UDim2.fromOffset(270, 36)
            or UDim2.fromOffset(270, 150)
        minimize.Text = minimized and "+" or "—"
    end)

    remove.Activated:Connect(function()
        PanelPositions[panelKey] = root.Position
        InfoPanels[panelKey] = nil
        root:Destroy()
    end)

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = root.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
            PanelPositions[panelKey] = root.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local panel = {
        Root = root,
        Content = content,
        Label = info,
        SetText = function(text)
            if info and info.Parent then
                info.Text = tostring(text)
            end
        end,
    }

    InfoPanels[panelKey] = panel
    return panel
end

-- =========================================================
-- CONTROL DE PANELES INFORMATIVOS
-- =========================================================
local function SetInfoPanel(key, title, enabled)
    if not enabled then
        local panel = InfoPanels[key]
        if panel and panel.Root and panel.Root.Parent then
            panel.Root.Visible = false
        end
        return
    end

    local panel = CreateInfoPanel(key, title)
    panel.Root.Visible = true
end

local function SetLightingOption(key, enabled)
    State.Lighting[key] = enabled
    SaveControl(key, enabled)
end

-- =========================================================
-- LIGHTING (VISUAL + PANEL INFO)
-- =========================================================
local LightingSection = Section(
    Visual,
    "Lighting (Visual + Panel info)",
    "Efectos visuales y paneles independientes"
)

local LightingDropdown = MakeDropdown(
    LightingSection,
    "Lighting (Visual + Panel info)",
    "Los paneles informativos aparecen fuera del menú."
)

MakeToggle(LightingDropdown, "Sin cutscene", false, function(v)
    SetLightingOption("Sin cutscene", v)
end)

MakeToggle(LightingDropdown, "Sin niebla", false, function(v)
    SetLightingOption("Sin niebla", v)
end)

MakeToggle(LightingDropdown, "Fullbright", false, function(v)
    SetLightingOption("Fullbright", v)
end)

MakeToggle(LightingDropdown, "Display Kyst Killer", false, function(v)
    SetLightingOption("Display Kyst Killer", v)
    SetInfoPanel("KystKiller", "Display Kyst Killer", v)
end)

MakeToggle(LightingDropdown, "Contador de espectadores", false, function(v)
    SetLightingOption("Contador de espectadores", v)
    SetInfoPanel("Spectators", "Contador de espectadores", v)
end)

MakeToggle(LightingDropdown, "Perks del Killer", false, function(v)
    SetLightingOption("Perks del Killer", v)
    SetInfoPanel("KillerPerks", "Perks del Killer", v)
end)

MakeToggle(LightingDropdown, "Predicción del mapa", false, function(v)
    SetLightingOption("Predicción del mapa", v)
    SetInfoPanel("MapPrediction", "Predicción del mapa", v)
end)

MakeToggle(LightingDropdown, "Ocultar icono del Survivor", false, function(v)
    SetLightingOption("Ocultar icono del Survivor", v)
end)

MakeToggle(LightingDropdown, "Mostrar ping/FPS", false, function(v)
    SetLightingOption("Mostrar ping/FPS", v)
    SetInfoPanel("PingFPS", "Ping / FPS", v)
end)

-- =========================================================
-- CAMARA
-- =========================================================
local CameraSection = Section(
    Visual,
    "Cámara",
    "Opciones de cámara"
)

local CameraDropdown = MakeDropdown(
    CameraSection,
    "Cámara",
    "Los cambios se guardan para conectarlos a la lógica."
)

MakeToggle(CameraDropdown, "FOV Override", false, function(v)
    State.Camera.FOVOverride = v
    SaveControl("FOV Override", v)
end)

MakeSlider(
    CameraDropdown,
    "FOV",
    50, 120, 70, "°",
    function(v)
        State.Camera.FOV = v
        SaveControl("FOV", v)
    end
)

MakeToggle(CameraDropdown, "Third Person (solo Killer)", false, function(v)
    State.Camera.ThirdPersonKiller = v
    SaveControl("Third Person (solo Killer)", v)
end)

MakeToggle(CameraDropdown, "Shift Lock", false, function(v)
    State.Camera.ShiftLock = v
    SaveControl("Shift Lock", v)
end)

MakeToggle(CameraDropdown, "Infinite Zoom", false, function(v)
    State.Camera.InfiniteZoom = v
    SaveControl("Infinite Zoom", v)
end)

-- =========================================================
-- CONTADOR DE CUELGUES EN NAME TAG
-- No crea un panel informativo separado.
-- =========================================================
local function SetHookCounterEnabled(enabled)
    State.ShowHookCounter = enabled == true
    SaveControl("Mostrar contador de cuelgues", State.ShowHookCounter)
end

MakeToggle(
    PlayerSettings,
    "Mostrar contador de cuelgues",
    false,
    SetHookCounterEnabled
)

-- El código de Name Tags deberá consultar:
-- State.ShowHookCounter
-- y añadir " | Cuelgues: N" al final del texto del Survivor.
-- N debe proceder del contador real disponible en el juego.

-- =========================================================
-- ESTADO FINAL
-- =========================================================
State.InfoPanels = InfoPanels
State.PanelPositions = PanelPositions
State.LightingReady = true
State.CameraReady = true

print("[ModularVisualUI] Parte 3 cargada")

-- =========================================================
-- PARTE 4: LOGICA CONECTADA DE CONTROLES VISUALES
-- Se conserva la interfaz de las Partes 1-3.
-- Efectos locales; no modifica datos del servidor.
-- =========================================================
local Runtime = {
    PlayerVisuals = {},
    WorldVisuals = {},
    HiddenGuiState = {},
    Connections = {},
    OriginalLighting = nil,
    OriginalCamera = nil,
    LastWorldScan = 0,
    LastInfoRefresh = 0,
    Stopped = false,
    FPS = 0,
}

local KillerWarningLabel = Instance.new("TextLabel")
KillerWarningLabel.Name = "KillerWarningLocal"
KillerWarningLabel.AnchorPoint = Vector2.new(0.5, 0)
KillerWarningLabel.Position = UDim2.new(0.5, 0, 0, 18)
KillerWarningLabel.Size = UDim2.new(0.8, 0, 0, 38)
KillerWarningLabel.BackgroundColor3 = Color3.fromRGB(145, 25, 35)
KillerWarningLabel.BackgroundTransparency = 0.12
KillerWarningLabel.BorderSizePixel = 0
KillerWarningLabel.Font = Enum.Font.GothamBold
KillerWarningLabel.TextSize = 15
KillerWarningLabel.TextColor3 = Color3.new(1, 1, 1)
KillerWarningLabel.TextStrokeTransparency = 0.6
KillerWarningLabel.Text = "KILLER CERCANO"
KillerWarningLabel.Visible = false
KillerWarningLabel.ZIndex = 100
KillerWarningLabel.Parent = ScreenGui
local KillerWarningCorner = Instance.new("UICorner")
KillerWarningCorner.CornerRadius = UDim.new(0, 8)
KillerWarningCorner.Parent = KillerWarningLabel

local function ControlOn(name)
    return State.Controls[name] == true
end

local function ControlNumber(name, fallback)
    local value = State.Controls[name]
    return type(value) == "number" and value or fallback
end

local function ControlColor(name, fallback)
    local value = State.Controls[name .. "Color"]
    return typeof(value) == "Color3" and value or fallback
end

local function CharacterOf(player)
    return player and player.Character
end

local function RootOf(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChildWhichIsA("BasePart")
end

local function RoleOf(player)
    if not player then return "Unknown" end
    local values = {}
    if player.Team then table.insert(values, player.Team.Name) end
    for key, value in pairs(player:GetAttributes()) do
        if string.find(string.lower(key), "role", 1, true)
            or string.find(string.lower(key), "team", 1, true) then
            table.insert(values, tostring(value))
        end
    end
    local character = player.Character
    if character then
        for key, value in pairs(character:GetAttributes()) do
            if string.find(string.lower(key), "role", 1, true)
                or string.find(string.lower(key), "team", 1, true) then
                table.insert(values, tostring(value))
            end
        end
    end
    for _, value in ipairs(values) do
        local normalized = string.lower(value)
        if string.find(normalized, "killer", 1, true)
            or string.find(normalized, "murder", 1, true) then
            return "Killer"
        elseif string.find(normalized, "survivor", 1, true)
            or string.find(normalized, "victim", 1, true) then
            return "Survivor"
        elseif string.find(normalized, "spectat", 1, true)
            or string.find(normalized, "observer", 1, true) then
            return "Spectator"
        end
    end
    return "Unknown"
end

local function DistanceToPlayer(player)
    local a = RootOf(CharacterOf(Player))
    local b = RootOf(CharacterOf(player))
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

local function WithinPlayerDistance(player)
    return DistanceToPlayer(player) <= ControlNumber("Distancia máxima de jugadores", 500)
end

local function RoleColor(role, elapsed)
    if role == "Survivor" then
        if ControlOn("Rainbow Survivor") then
            return Color3.fromHSV((elapsed * 0.15) % 1, 0.9, 1)
        end
        return ControlColor("Survivor Color", Color3.fromRGB(100, 190, 255))
    elseif role == "Killer" then
        if ControlOn("Rainbow Killer") then
            return Color3.fromHSV((elapsed * 0.15 + 0.33) % 1, 0.9, 1)
        end
        return ControlColor("Killer Color", Color3.fromRGB(150, 0, 35))
    elseif role == "Spectator" then
        if ControlOn("Rainbow Spectator") then
            return Color3.fromHSV((elapsed * 0.15 + 0.66) % 1, 0.9, 1)
        end
        return ControlColor("Spectator Color", Color3.fromRGB(192, 192, 200))
    end
    return Theme.Accent
end

local function HealthText(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    return tostring(math.floor(humanoid.Health + 0.5)) .. "/"
        .. tostring(math.floor(humanoid.MaxHealth + 0.5))
end

local function FindCounter(player)
    local tokens = {"hook", "cuelgue", "hookstage", "hookcount"}
    local function matches(name)
        local lower = string.lower(name)
        for _, token in ipairs(tokens) do
            if string.find(lower, token, 1, true) then return true end
        end
        return false
    end
    for key, value in pairs(player:GetAttributes()) do
        if matches(key) and type(value) == "number" then return value end
    end
    for _, item in ipairs(player:GetDescendants()) do
        if matches(item.Name)
            and (item:IsA("IntValue") or item:IsA("NumberValue")) then
            return item.Value
        end
    end
    return nil
end

local function MakeLocalBillboard(name, adornee)
    local gui = Instance.new("BillboardGui")
    gui.Name = name
    gui.Adornee = adornee
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.Size = UDim2.fromOffset(220, 46)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 2.7, 0)
    gui.MaxDistance = ControlNumber("Distancia máxima de jugadores", 500)
    gui.Parent = PlayerGui
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = ControlNumber("Tamaño del texto ESP", 14)
    label.TextColor3 = Theme.White
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.TextWrapped = true
    label.Parent = gui
    return gui, label
end

local function RemovePlayerVisual(player)
    local record = Runtime.PlayerVisuals[player]
    if not record then return end
    if record.Highlight then record.Highlight:Destroy() end
    if record.Billboard then record.Billboard:Destroy() end
    Runtime.PlayerVisuals[player] = nil
end

local function PlayerESPEnabled(player, role)
    local master = ControlOn("Player Highlight ESP")
    local byRole = (role == "Survivor" and ControlOn("Survivor ESP"))
        or (role == "Killer" and ControlOn("Killer ESP"))
        or (role == "Spectator" and ControlOn("Spectator ESP"))
    return (master or byRole) and WithinPlayerDistance(player)
end

local function UpdatePlayerESP(player, elapsed)
    if player == Player then RemovePlayerVisual(player) return end
    local character = CharacterOf(player)
    local root = RootOf(character)
    if not character or not root then RemovePlayerVisual(player) return end
    local role = RoleOf(player)
    local highlightOn = PlayerESPEnabled(player, role)
    local tagsOn = ControlOn("Player Name Tags") and WithinPlayerDistance(player)
    if not highlightOn and not tagsOn then RemovePlayerVisual(player) return end

    local record = Runtime.PlayerVisuals[player] or {}
    Runtime.PlayerVisuals[player] = record
    local color = RoleColor(role, elapsed)
    if highlightOn then
        if not record.Highlight or not record.Highlight.Parent then
            record.Highlight = Instance.new("Highlight")
            record.Highlight.Name = "ModularVisual_PlayerHighlight"
            record.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            record.Highlight.Parent = character
        end
        record.Highlight.Adornee = character
        record.Highlight.FillColor = color
        record.Highlight.OutlineColor = color
        record.Highlight.FillTransparency = math.clamp(
            ControlNumber("FillTransparency", 0.5), 0, 1)
        record.Highlight.OutlineTransparency = math.clamp(
            ControlNumber("OutlineTransparency", 0), 0, 1)
    elseif record.Highlight then
        record.Highlight:Destroy()
        record.Highlight = nil
    end

    if tagsOn then
        local head = character:FindFirstChild("Head") or root
        if not record.Billboard or not record.Billboard.Parent then
            record.Billboard, record.Label = MakeLocalBillboard(
                "ModularVisual_PlayerTag", head)
        end
        record.Billboard.Adornee = head
        record.Billboard.MaxDistance = ControlNumber("Distancia máxima de jugadores", 500)
        record.Label.TextSize = ControlNumber("Tamaño del texto ESP", 14)
        record.Label.TextColor3 = color
        local parts = {}
        if ControlOn("Mostrar nombre del jugador") then
            table.insert(parts, player.DisplayName ~= "" and player.DisplayName or player.Name)
        end
        if ControlOn("Mostrar rol del jugador") and role ~= "Unknown" then
            table.insert(parts, "[" .. role .. "]")
        end
        if ControlOn("Mostrar estado herido") then
            local health = HealthText(character)
            if health then table.insert(parts, "HP " .. health) end
        end
        if ControlOn("Mostrar estado derribado") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                table.insert(parts, "Derribado")
            end
        end
        if ControlOn("Mostrar objeto del Survivor") and role == "Survivor" then
            local heldTool
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Tool") then
                    heldTool = child.Name
                    break
                end
            end
            if heldTool then table.insert(parts, "Objeto: " .. heldTool) end
        end
        if ControlOn("Mostrar contador de cuelgues") and role == "Survivor" then
            local count = FindCounter(player)
            if count ~= nil then table.insert(parts, "Cuelgues: " .. tostring(count)) end
        end
        local distance = DistanceToPlayer(player)
        if distance < math.huge then
            table.insert(parts, tostring(math.floor(distance + 0.5)) .. " studs")
        end
        record.Label.Text = table.concat(parts, "\n")
    elseif record.Billboard then
        record.Billboard:Destroy()
        record.Billboard = nil
        record.Label = nil
    end
end

local function ClassifyWorld(instance)
    local name = string.lower(instance.Name)
    if string.find(name, "generator", 1, true)
        or string.find(name, "generador", 1, true) then return "Generator" end
    if string.find(name, "hook", 1, true)
        or string.find(name, "gancho", 1, true) then return "Hook" end
    if string.find(name, "gate", 1, true)
        or string.find(name, "exit", 1, true)
        or string.find(name, "puerta", 1, true) then return "Gate" end
    if string.find(name, "window", 1, true)
        or string.find(name, "ventana", 1, true) then return "Window" end
    if string.find(name, "pallet", 1, true)
        or string.find(name, "palet", 1, true) then return "Pallet" end
    if string.find(name, "flashlight", 1, true)
        or string.find(name, "medkit", 1, true)
        or string.find(name, "toolbox", 1, true)
        or string.find(name, "item", 1, true) then return "Item" end
    return nil
end

local function WorldAdornee(instance)
    if instance:IsA("BasePart") then return instance end
    if instance:IsA("Model") then
        return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function WorldDistance(instance)
    local a = RootOf(CharacterOf(Player))
    local b = WorldAdornee(instance)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

local function WorldColor(kind, instance, elapsed)
    if kind == "Generator" then
        local progress
        for _, key in ipairs({"Progress", "progress", "Percent", "Percentage", "Completion"}) do
            local value = instance:GetAttribute(key)
            if type(value) == "number" then
                progress = value <= 1 and value * 100 or value
                break
            end
        end
        if progress and progress <= 15 then
            return ControlColor("Generator Low Color", Color3.fromRGB(150, 0, 35))
        elseif progress and progress <= 75 then
            return ControlColor("Generator Medium Color", Color3.fromRGB(255, 125, 20))
        elseif progress then
            return ControlColor("Generator High Color", Color3.fromRGB(0, 190, 110))
        end
        return ControlColor("Generator Medium Color", Color3.fromRGB(255, 125, 20))
    elseif kind == "Hook" then return Color3.fromRGB(225, 65, 75)
    elseif kind == "Gate" then return Color3.fromRGB(70, 220, 130)
    elseif kind == "Window" then return Color3.fromRGB(90, 190, 255)
    elseif kind == "Pallet" then return Color3.fromRGB(195, 145, 255)
    elseif kind == "Item" then return Color3.fromRGB(255, 225, 90) end
    return Color3.fromHSV((elapsed * 0.1) % 1, 0.8, 1)
end

local function WorldWanted(kind)
    return ControlOn("World Highlight ESP")
        or (kind == "Generator" and (ControlOn("Generator ESP") or ControlOn("Survivor Items ESP")))
        or (kind == "Hook" and ControlOn("Hook ESP"))
        or (kind == "Gate" and ControlOn("Gate ESP"))
        or (kind == "Window" and ControlOn("Window ESP"))
        or (kind == "Pallet" and ControlOn("Pallet ESP"))
        or (kind == "Item" and ControlOn("Survivor Items ESP"))
end

local function RemoveWorldVisual(instance)
    local record = Runtime.WorldVisuals[instance]
    if not record then return end
    if record.Highlight then record.Highlight:Destroy() end
    if record.Billboard then record.Billboard:Destroy() end
    Runtime.WorldVisuals[instance] = nil
end

local function UpdateWorldESP(instance, elapsed)
    if not instance or not instance.Parent then RemoveWorldVisual(instance) return end
    local kind = ClassifyWorld(instance)
    local adornee = WorldAdornee(instance)
    local distance = WorldDistance(instance)
    local within = distance <= ControlNumber("Distancia máxima de objetos", 500)
    local highlightOn = kind and WorldWanted(kind) and within
    local tagsOn = kind and ControlOn("World Name Tags") and within
    if not kind or not adornee or (not highlightOn and not tagsOn) then
        RemoveWorldVisual(instance)
        return
    end
    local record = Runtime.WorldVisuals[instance] or {}
    Runtime.WorldVisuals[instance] = record
    local color = WorldColor(kind, instance, elapsed)
    if highlightOn then
        if not record.Highlight or not record.Highlight.Parent then
            record.Highlight = Instance.new("Highlight")
            record.Highlight.Name = "ModularVisual_WorldHighlight"
            record.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            record.Highlight.Parent = instance
        end
        record.Highlight.Adornee = instance
        record.Highlight.FillColor = color
        record.Highlight.OutlineColor = color
        record.Highlight.FillTransparency = math.clamp(ControlNumber("FillTransparency", 0.5), 0, 1)
        record.Highlight.OutlineTransparency = math.clamp(ControlNumber("OutlineTransparency", 0), 0, 1)
    elseif record.Highlight then
        record.Highlight:Destroy()
        record.Highlight = nil
    end
    if tagsOn then
        if not record.Billboard or not record.Billboard.Parent then
            record.Billboard, record.Label = MakeLocalBillboard("ModularVisual_WorldTag", adornee)
        end
        record.Billboard.Adornee = adornee
        record.Billboard.MaxDistance = ControlNumber("Distancia máxima de objetos", 500)
        record.Label.TextSize = ControlNumber("Tamaño del texto ESP", 14)
        record.Label.TextColor3 = color
        local labelText = instance.Name
        if kind == "Generator" and ControlOn("Mostrar porcentaje del generador") then
            local progress
            for _, key in ipairs({"Progress", "progress", "Percent", "Percentage", "Completion"}) do
                local value = instance:GetAttribute(key)
                if type(value) == "number" then
                    progress = math.floor(math.clamp(value <= 1 and value * 100 or value, 0, 100) + 0.5)
                    break
                end
            end
            labelText = labelText .. (progress and (" - " .. progress .. "%") or " - progreso N/D")
        end
        record.Label.Text = labelText
    elseif record.Billboard then
        record.Billboard:Destroy()
        record.Billboard = nil
        record.Label = nil
    end
end

local function ScanWorldESP()
    local seen = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") or item:IsA("BasePart") then
            if ClassifyWorld(item) then
                seen[item] = true
                UpdateWorldESP(item, os.clock())
            end
        end
    end
    for item in pairs(Runtime.WorldVisuals) do
        if not seen[item] or not item.Parent then RemoveWorldVisual(item) end
    end
end

local function CaptureLighting()
    if Runtime.OriginalLighting then return end
    Runtime.OriginalLighting = {
        Brightness = LightingService.Brightness,
        ClockTime = LightingService.ClockTime,
        GlobalShadows = LightingService.GlobalShadows,
        Ambient = LightingService.Ambient,
        OutdoorAmbient = LightingService.OutdoorAmbient,
        FogStart = LightingService.FogStart,
        FogEnd = LightingService.FogEnd,
        FogColor = LightingService.FogColor,
    }
end

local function ApplyLightingOptions()
    CaptureLighting()
    local old = Runtime.OriginalLighting
    if ControlOn("Fullbright") then
        LightingService.Brightness = 3
        LightingService.ClockTime = 14
        LightingService.GlobalShadows = false
        LightingService.Ambient = Color3.fromRGB(190, 190, 190)
        LightingService.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
    else
        LightingService.Brightness = old.Brightness
        LightingService.ClockTime = old.ClockTime
        LightingService.GlobalShadows = old.GlobalShadows
        LightingService.Ambient = old.Ambient
        LightingService.OutdoorAmbient = old.OutdoorAmbient
    end
    if ControlOn("Sin niebla") then
        LightingService.FogStart = 0
        LightingService.FogEnd = 1000000
    else
        LightingService.FogStart = old.FogStart
        LightingService.FogEnd = old.FogEnd
        LightingService.FogColor = old.FogColor
    end
end

local function CaptureCamera()
    if Runtime.OriginalCamera then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    Runtime.OriginalCamera = {
        FOV = camera.FieldOfView,
        MinZoom = Player.CameraMinZoomDistance,
        MaxZoom = Player.CameraMaxZoomDistance,
        CameraMode = Player.CameraMode,
    }
end

local function ApplyCameraOptions()
    local camera = workspace.CurrentCamera
    if not camera then return end
    CaptureCamera()
    local old = Runtime.OriginalCamera
    if not old then return end
    camera.FieldOfView = ControlOn("FOV Override") and ControlNumber("FOV", 70) or old.FOV
    if ControlOn("Infinite Zoom") then
        Player.CameraMaxZoomDistance = 1000
    else
        Player.CameraMaxZoomDistance = old.MaxZoom
    end
    if ControlOn("Third Person (solo Killer)") and RoleOf(Player) == "Killer" then
        Player.CameraMode = Enum.CameraMode.Classic
        Player.CameraMinZoomDistance = 8
        Player.CameraMaxZoomDistance = math.max(Player.CameraMaxZoomDistance, 12)
    else
        Player.CameraMode = old.CameraMode
        Player.CameraMinZoomDistance = old.MinZoom
    end
    if not UserInputService.TouchEnabled then
        if ControlOn("Shift Lock") then
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter end)
        elseif UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
        end
    end
end

local function UpdateKillerWarning()
    if not ControlOn("Killer Warning") then
        KillerWarningLabel.Visible = false
        return
    end
    local nearest, nearestDistance
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and RoleOf(otherPlayer) == "Killer" then
            local distance = DistanceToPlayer(otherPlayer)
            if distance < (nearestDistance or math.huge) then
                nearest, nearestDistance = otherPlayer, distance
            end
        end
    end
    if nearest and nearestDistance and nearestDistance <= 100 then
        KillerWarningLabel.Text = "KILLER CERCANO  •  " .. nearest.Name
            .. "  •  " .. tostring(math.floor(nearestDistance + 0.5)) .. " studs"
        KillerWarningLabel.Visible = true
    else
        KillerWarningLabel.Visible = false
    end
end

local function GetMapText()
    for _, key in ipairs({"MapName", "CurrentMap", "Map"}) do
        local value = workspace:GetAttribute(key)
        if type(value) == "string" and value ~= "" then return value end
    end
    local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("CurrentMap")
    return map and map.Name or "No expuesto por el juego"
end

local function GetPingText()
    local ok, value = pcall(function()
        local stats = game:GetService("Stats")
        local network = stats:FindFirstChild("Network")
        local server = network and network:FindFirstChild("ServerStatsItem")
        local ping = server and server:FindFirstChild("Data Ping")
        return ping and ping:GetValueString() or nil
    end)
    return ok and value or nil
end

local function RefreshInfoPanels()
    local killer
    local spectators = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local role = RoleOf(player)
        if role == "Killer" then killer = player end
        if role == "Spectator" then spectators = spectators + 1 end
    end

    local panel = InfoPanels.KystKiller
    if panel and panel.Root and panel.Root.Parent then
        if killer then
            local health = HealthText(CharacterOf(killer)) or "N/D"
            local distance = DistanceToPlayer(killer)
            panel.SetText("Killer: " .. killer.Name
                .. "\nDistancia: " .. (distance < math.huge and math.floor(distance + 0.5) .. " studs" or "N/D")
                .. "\nSalud: " .. health)
        else
            panel.SetText("Killer no identificado. El juego no expone un rol reconocible.")
        end
    end
    panel = InfoPanels.Spectators
    if panel and panel.Root and panel.Root.Parent then
        panel.SetText("Espectadores detectados: " .. tostring(spectators)
            .. "\nJugadores totales: " .. tostring(#Players:GetPlayers()))
    end
    panel = InfoPanels.KillerPerks
    if panel and panel.Root and panel.Root.Parent then
        local lines = {}
        if killer then
            for _, item in ipairs(killer:GetDescendants()) do
                if string.find(string.lower(item.Name), "perk", 1, true)
                    and (item:IsA("StringValue") or item:IsA("BoolValue")
                        or item:IsA("IntValue") or item:IsA("NumberValue")) then
                    table.insert(lines, item.Name .. ": " .. tostring(item.Value))
                end
            end
        end
        panel.SetText(#lines > 0 and table.concat(lines, "\n")
            or "Perks no expuestas por el juego.")
    end
    panel = InfoPanels.MapPrediction
    if panel and panel.Root and panel.Root.Parent then
        panel.SetText("Mapa detectado: " .. GetMapText()
            .. "\nPredicción: no disponible sin datos del juego.")
    end
    panel = InfoPanels.PingFPS
    if panel and panel.Root and panel.Root.Parent then
        panel.SetText("FPS aproximados: " .. tostring(Runtime.FPS)
            .. "\nPing: " .. (GetPingText() or "No disponible"))
    end
end

local function ApplyNamedGuiOptions()
    local hideCutscene = ControlOn("Sin cutscene")
    local hideSurvivor = ControlOn("Ocultar icono del Survivor")
    for _, item in ipairs(PlayerGui:GetDescendants()) do
        if item:IsA("ScreenGui") or item:IsA("GuiObject") then
            local name = string.lower(item.Name)
            local shouldHide = (hideCutscene and string.find(name, "cutscene", 1, true))
                or (hideSurvivor and string.find(name, "survivor", 1, true)
                    and string.find(name, "icon", 1, true))
            if shouldHide then
                if Runtime.HiddenGuiState[item] == nil then
                    Runtime.HiddenGuiState[item] = item.Visible
                end
                item.Visible = false
            elseif Runtime.HiddenGuiState[item] ~= nil then
                item.Visible = Runtime.HiddenGuiState[item]
                Runtime.HiddenGuiState[item] = nil
            end
        end
    end
end

local function CleanupRuntime()
    if Runtime.Stopped then return end
    Runtime.Stopped = true
    for player in pairs(Runtime.PlayerVisuals) do RemovePlayerVisual(player) end
    for item in pairs(Runtime.WorldVisuals) do RemoveWorldVisual(item) end
    for item, visible in pairs(Runtime.HiddenGuiState) do
        if item and item.Parent then pcall(function() item.Visible = visible end) end
    end
    if Runtime.OriginalLighting then
        local old = Runtime.OriginalLighting
        pcall(function()
            LightingService.Brightness = old.Brightness
            LightingService.ClockTime = old.ClockTime
            LightingService.GlobalShadows = old.GlobalShadows
            LightingService.Ambient = old.Ambient
            LightingService.OutdoorAmbient = old.OutdoorAmbient
            LightingService.FogStart = old.FogStart
            LightingService.FogEnd = old.FogEnd
            LightingService.FogColor = old.FogColor
        end)
    end
    if Runtime.OriginalCamera then
        local old = Runtime.OriginalCamera
        pcall(function()
            local camera = workspace.CurrentCamera
            if camera then camera.FieldOfView = old.FOV end
            Player.CameraMinZoomDistance = old.MinZoom
            Player.CameraMaxZoomDistance = old.MaxZoom
            Player.CameraMode = old.CameraMode
        end)
    end
    pcall(function()
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)
end

Runtime.Connections.Render = RunService.RenderStepped:Connect(function(deltaTime)
    if Runtime.Stopped or State.Destroyed or not ScreenGui.Parent then return end
    Runtime.FPS = deltaTime > 0 and math.floor(1 / deltaTime + 0.5) or Runtime.FPS
    local now = os.clock()
    for _, player in ipairs(Players:GetPlayers()) do
        UpdatePlayerESP(player, now)
    end
    ApplyLightingOptions()
    ApplyCameraOptions()
    ApplyNamedGuiOptions()
    UpdateKillerWarning()
    if now - Runtime.LastWorldScan >= 1.25 then
        Runtime.LastWorldScan = now
        ScanWorldESP()
    end
    if now - Runtime.LastInfoRefresh >= 1 then
        Runtime.LastInfoRefresh = now
        RefreshInfoPanels()
    end
end)

Runtime.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(RemovePlayerVisual)
Runtime.Connections.Destroying = ScreenGui.Destroying:Connect(CleanupRuntime)
State.Runtime = Runtime
State.GetRole = RoleOf
State.GetPlayerDistance = DistanceToPlayer
State.GetControl = function(name) return State.Controls[name] end

print("[ModularVisualUI] Logica conectada; controles locales activos.")


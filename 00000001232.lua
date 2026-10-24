-- ProtoRun Lite - Parte 1: Estructura Base con Layout Sidebar
-- Sistema de UI con protección contra cinemáticas

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)

if not player or not playerGui then
    warn("[ProtoRun Lite] Error: Jugador o PlayerGui no encontrado")
    return
end

-- Variables globales del menú
local ProtoRunLite = {}
ProtoRunLite.Menu = nil
ProtoRunLite.MenuButton = nil
ProtoRunLite.IsVisible = true
ProtoRunLite.CurrentTab = "Dashboard"
ProtoRunLite.MenuSize = UDim2.new(0, 320, 0, 390)
ProtoRunLite.MinSize = UDim2.new(0, 260, 0, 260)
ProtoRunLite.MaxSize = UDim2.new(0, 520, 0, 620)

-- Colores del tema (negro, plateado, dorado)
local Colors = {
    Background = Color3.fromRGB(15, 15, 15),
    Panel = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(192, 192, 192),
    Accent = Color3.fromRGB(255, 215, 0),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 160),
    Button = Color3.fromRGB(40, 40, 40),
    ButtonHover = Color3.fromRGB(60, 60, 60),
    ButtonActive = Color3.fromRGB(50, 50, 50),
    Success = Color3.fromRGB(0, 255, 100),
    Danger = Color3.fromRGB(255, 50, 50),
    Slider = Color3.fromRGB(50, 50, 50),
    SliderFill = Color3.fromRGB(255, 215, 0),
    HologramGreen = Color3.fromRGB(0, 255, 150),
    HologramBlue = Color3.fromRGB(0, 200, 255)
}

-- Crear ScreenGui principal con protección contra cinemáticas
local function CreateScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProtoRunLite_UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 9999
    
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if screenGui and screenGui.Parent then
                screenGui.IgnoreGuiInset = true
                screenGui.DisplayOrder = 9999
                screenGui.Enabled = true
            end
        end)
    end)
    
    screenGui.Parent = playerGui
    return screenGui
end

-- Crear botón del menú (toggle) con arrastre
local function CreateMenuButton(screenGui)
    local menuButton = Instance.new("TextButton")
    menuButton.Name = "ProtoRunLite_Button"
    menuButton.Size = UDim2.new(0, 60, 0, 60)
    menuButton.Position = UDim2.new(0, 20, 0.5, -30)
    menuButton.BackgroundColor3 = Colors.Background
    menuButton.BorderSizePixel = 0
    menuButton.Text = "PR"
    menuButton.TextColor3 = Colors.Accent
    menuButton.TextSize = 20
    menuButton.Font = Enum.Font.GothamBold
    menuButton.ZIndex = 100
    menuButton.Active = true
    
    local border = Instance.new("UICorner")
    border.CornerRadius = UDim.new(1, 0)
    border.Parent = menuButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Accent
    stroke.Thickness = 2
    stroke.Parent = menuButton
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    menuButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = menuButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    menuButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            menuButton.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    menuButton.MouseButton1Click:Connect(function()
        if not dragging then
            ProtoRunLite.IsVisible = not ProtoRunLite.IsVisible
            if ProtoRunLite.Menu then
                ProtoRunLite.Menu.Visible = ProtoRunLite.IsVisible
            end
        end
    end)
    
    menuButton.Parent = screenGui
    return menuButton
end

-- Crear ventana principal del menú
local function CreateMainWindow(screenGui)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "ProtoRunLite_Main"
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(720, 1280)
    local initialWidth = math.clamp(viewport.X * 0.88, 260, 520)
    local initialHeight = math.clamp(viewport.Y * 0.68, 280, 620)
    mainFrame.Size = UDim2.fromOffset(initialWidth, initialHeight)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    mainFrame.ZIndex = 50
    mainFrame.Active = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    mainFrame.Parent = screenGui
    return mainFrame
end

-- Crear barra de título con botones y arrastre
local function CreateTitleBar(mainFrame)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Colors.Panel
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 51
    titleBar.Active = true
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ProtoRun Lite"
    titleLabel.TextColor3 = Colors.Accent
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 52
    titleLabel.Parent = titleBar
    
    local hideButton = Instance.new("TextButton")
    hideButton.Name = "HideButton"
    hideButton.Size = UDim2.new(0, 30, 0, 30)
    hideButton.Position = UDim2.new(1, -70, 0, 5)
    hideButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hideButton.BorderSizePixel = 0
    hideButton.Text = "—"
    hideButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    hideButton.TextSize = 20
    hideButton.Font = Enum.Font.GothamBold
    hideButton.ZIndex = 52
    hideButton.Parent = titleBar
    
    local hideCorner = Instance.new("UICorner")
    hideCorner.CornerRadius = UDim.new(0, 4)
    hideCorner.Parent = hideButton
    
    hideButton.MouseButton1Click:Connect(function()
        ProtoRunLite.IsVisible = false
        mainFrame.Visible = false
    end)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.ZIndex = 52
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        if ProtoRunLite.Menu then ProtoRunLite.Menu:Destroy() end
        if ProtoRunLite.MenuButton then ProtoRunLite.MenuButton:Destroy() end
        if ProtoRunLite.ScreenGui then ProtoRunLite.ScreenGui:Destroy() end
    end)
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return titleBar
end

-- Crear SIDEBAR (lista de ventanas a la izquierda)
local function CreateSidebar(mainFrame)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0.25, 0, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Colors.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 51
    sidebar.Parent = mainFrame
    
    local rightBorder = Instance.new("Frame")
    rightBorder.Name = "RightBorder"
    rightBorder.Size = UDim2.new(0, 1, 1, 0)
    rightBorder.Position = UDim2.new(1, 0, 0, 0)
    rightBorder.BackgroundColor3 = Colors.Border
    rightBorder.BackgroundTransparency = 0.5
    rightBorder.BorderSizePixel = 0
    rightBorder.ZIndex = 52
    rightBorder.Parent = sidebar
    
    local header = Instance.new("Frame")
    header.Name = "SidebarHeader"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Colors.Panel
    header.BorderSizePixel = 0
    header.ZIndex = 52
    header.Parent = sidebar
    
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, -20, 1, 0)
    headerLabel.Position = UDim2.new(0, 10, 0, 0)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = "VENTANAS"
    headerLabel.TextColor3 = Colors.Accent
    headerLabel.TextSize = 12
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.ZIndex = 53
    headerLabel.Parent = header
    
    local buttonsContainer = Instance.new("ScrollingFrame")
    buttonsContainer.Name = "ButtonsContainer"
    buttonsContainer.Size = UDim2.new(1, -10, 1, -60)
    buttonsContainer.Position = UDim2.new(0, 5, 0, 55)
    buttonsContainer.BackgroundTransparency = 1
    buttonsContainer.BorderSizePixel = 0
    buttonsContainer.ScrollBarThickness = 3
    buttonsContainer.ScrollBarImageColor3 = Colors.Accent
    buttonsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    buttonsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    buttonsContainer.ZIndex = 52
    buttonsContainer.Parent = sidebar
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = buttonsContainer
    
    local windows = {
        {Name = "Dashboard", Icon = "⌂", Order = 1},
        {Name = "Visual", Icon = "◉", Order = 2}
    }
    
    local tabButtons = {}
    
    for _, win in ipairs(windows) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = win.Name .. "_Tab"
        tabButton.Size = UDim2.new(1, -5, 0, 40)
        tabButton.BackgroundColor3 = Colors.Button
        tabButton.BorderSizePixel = 0
        tabButton.Text = "  " .. win.Icon .. "  " .. win.Name
        tabButton.TextColor3 = Colors.TextDim
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.ZIndex = 53
        tabButton.LayoutOrder = win.Order
        tabButton.Parent = buttonsContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = tabButton
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Colors.Border
        btnStroke.Transparency = 0.7
        btnStroke.Thickness = 1
        btnStroke.Parent = tabButton
        
        tabButtons[win.Name] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            ProtoRunLite.CurrentTab = win.Name
            for name, btn in pairs(tabButtons) do
                if name == win.Name then
                    btn.BackgroundColor3 = Colors.ButtonActive
                    btn.TextColor3 = Colors.Accent
                    btnStroke.Color = Colors.Accent
                    btnStroke.Transparency = 0
                else
                    btn.BackgroundColor3 = Colors.Button
                    btn.TextColor3 = Colors.TextDim
                    local otherStroke = btn:FindFirstChildOfClass("UIStroke")
                    if otherStroke then
                        otherStroke.Color = Colors.Border
                        otherStroke.Transparency = 0.7
                    end
                end
            end
            if ProtoRunLite.SwitchTab then
                ProtoRunLite.SwitchTab(win.Name)
            end
        end)
        
        if win.Name == "Dashboard" then
            tabButton.BackgroundColor3 = Colors.ButtonActive
            tabButton.TextColor3 = Colors.Accent
            btnStroke.Color = Colors.Accent
            btnStroke.Transparency = 0
        end
    end
    
    return sidebar, tabButtons
end

-- Crear área de contenido (derecha)
local function CreateContentArea(mainFrame)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentArea"
    contentFrame.Size = UDim2.new(0.75, -10, 1, -50)
    contentFrame.Position = UDim2.new(0.25, 5, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.ZIndex = 51
    contentFrame.Parent = mainFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ContentScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Colors.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ZIndex = 52
    scrollFrame.Parent = contentFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = scrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = scrollFrame
    
    return contentFrame, scrollFrame
end

-- Crear control de redimensionamiento
local function CreateResizeHandle(mainFrame)
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -25, 1, -25)
    resizeHandle.BackgroundColor3 = Colors.Accent
    resizeHandle.BackgroundTransparency = 0.3
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Text = "⤡"
    resizeHandle.TextColor3 = Colors.Background
    resizeHandle.TextSize = 14
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.ZIndex = 80
    
    local resizeCorner = Instance.new("UICorner")
    resizeCorner.CornerRadius = UDim.new(0, 4)
    resizeCorner.Parent = resizeHandle
    
    local resizing = false
    local dragInput, dragStart, startSize
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            dragStart = input.Position
            startSize = mainFrame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    resizeHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and resizing then
            local delta = input.Position - dragStart
            local newSize = UDim2.new(
                startSize.X.Scale,
                math.clamp(startSize.X.Offset + delta.X, ProtoRunLite.MinSize.X.Offset, ProtoRunLite.MaxSize.X.Offset),
                startSize.Y.Scale,
                math.clamp(startSize.Y.Offset + delta.Y, ProtoRunLite.MinSize.Y.Offset, ProtoRunLite.MaxSize.Y.Offset)
            )
            mainFrame.Size = newSize
            ProtoRunLite.MenuSize = newSize
        end
    end)
    
    resizeHandle.Parent = mainFrame
    return resizeHandle
end

-- Inicializar el menú completo
function ProtoRunLite:Initialize()
    print("[ProtoRun Lite] Iniciando...")
    
    local screenGui = CreateScreenGui()
    ProtoRunLite.ScreenGui = screenGui
    
    ProtoRunLite.MenuButton = CreateMenuButton(screenGui)
    
    local mainFrame = CreateMainWindow(screenGui)
    ProtoRunLite.Menu = mainFrame
    
    CreateTitleBar(mainFrame)
    local sidebar, tabButtons = CreateSidebar(mainFrame)
    local contentArea, scrollFrame = CreateContentArea(mainFrame)
    CreateResizeHandle(mainFrame)
    
    ProtoRunLite.ContentArea = contentArea
    ProtoRunLite.ContentScroll = scrollFrame
    ProtoRunLite.TabButtons = tabButtons
    ProtoRunLite.Sidebar = sidebar
    ProtoRunLite.Colors = Colors
    
    ProtoRunLite.SwitchTab = function(tabName)
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = (child.Name == tabName .. "_Content")
            end
        end
    end
    
    -- IMPORTANTE: Guardar en getgenv para que otras partes puedan acceder
    if getgenv then
        getgenv().ProtoRunLite = ProtoRunLite
    end
    
    print("[ProtoRun Lite] ✓ Menú inicializado correctamente")
    return ProtoRunLite
end

-- Iniciar el menú
ProtoRunLite:Initialize()
print("[ProtoRun Lite] Sistema listo - Esperando Parte 2...")

-- ProtoRun Lite - Parte 2: Dashboard Completo
-- Estado de conexión, Avatar holográfico, ID de Red, Lista de jugadores

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Esperar a que ProtoRunLite esté disponible
local ProtoRunLite
for i = 1, 50 do
    if getgenv and getgenv().ProtoRunLite then
        ProtoRunLite = getgenv().ProtoRunLite
        break
    end
    task.wait(0.1)
end

if not ProtoRunLite or not ProtoRunLite.ContentScroll then
    warn("[ProtoRun Lite] Error: Menú principal no encontrado")
    return
end

local Colors = {
    Background = Color3.fromRGB(15, 15, 15),
    Panel = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(192, 192, 192),
    Accent = Color3.fromRGB(255, 215, 0),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 160),
    Button = Color3.fromRGB(40, 40, 40),
    HologramGreen = Color3.fromRGB(0, 255, 150),
    HologramBlue = Color3.fromRGB(0, 200, 255),
    Scanline = Color3.fromRGB(0, 0, 0)
}

-- Crear contenedor principal del Dashboard
local function CreateDashboardContainer(scrollFrame)
    local dashboard = Instance.new("Frame")
    dashboard.Name = "Dashboard_Content"
    dashboard.Size = UDim2.new(1, -10, 0, 0)
    dashboard.BackgroundTransparency = 1
    dashboard.BorderSizePixel = 0
    dashboard.AutomaticSize = Enum.AutomaticSize.Y
    dashboard.Visible = true
    dashboard.Parent = scrollFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = dashboard
    
    return dashboard
end

-- 1. ESTADO DE CONEXIÓN (Indicador parpadeante)
local function CreateConnectionStatus(dashboard)
    local statusPanel = Instance.new("Frame")
    statusPanel.Name = "ConnectionStatus"
    statusPanel.Size = UDim2.new(1, 0, 0, 70)
    statusPanel.BackgroundColor3 = Colors.Panel
    statusPanel.BorderSizePixel = 0
    statusPanel.LayoutOrder = 1
    statusPanel.Parent = dashboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = statusPanel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = statusPanel
    
    -- Título del panel
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ESTADO DEL SISTEMA"
    titleLabel.TextColor3 = Colors.Accent
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = statusPanel
    
    -- Contenedor del indicador
    local indicatorContainer = Instance.new("Frame")
    indicatorContainer.Size = UDim2.new(1, -20, 0, 35)
    indicatorContainer.Position = UDim2.new(0, 10, 0, 28)
    indicatorContainer.BackgroundTransparency = 1
    indicatorContainer.Parent = statusPanel
    
    -- Punto parpadeante
    local dot = Instance.new("Frame")
    dot.Name = "StatusDot"
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 0, 0.5, -6)
    dot.BackgroundColor3 = Colors.HologramGreen
    dot.BorderSizePixel = 0
    dot.Parent = indicatorContainer
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    -- Efecto de brillo alrededor del punto
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = Colors.HologramGreen
    glow.ImageTransparency = 0.5
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    glow.ZIndex = 0
    glow.Parent = dot
    
    -- Texto del estado
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -25, 1, 0)
    statusText.Position = UDim2.new(0, 25, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "SISTEMA: ONLINE"
    statusText.TextColor3 = Colors.HologramGreen
    statusText.TextSize = 14
    statusText.Font = Enum.Font.Code
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = indicatorContainer
    
    -- Animación de parpadeo
    local blinkTween = TweenService:Create(dot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.7
    })
    blinkTween:Play()
    
    local glowTween = TweenService:Create(glow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        ImageTransparency = 0.9
    })
    glowTween:Play()
    
    -- Actualizar estado cada cierto tiempo
    task.spawn(function()
        while statusPanel.Parent do
            task.wait(5)
            if math.random() > 0.5 then
                statusText.Text = "SISTEMA: ONLINE"
                statusText.TextColor3 = Colors.HologramGreen
                dot.BackgroundColor3 = Colors.HologramGreen
                glow.ImageColor3 = Colors.HologramGreen
            else
                statusText.Text = "USUARIO VINCULADO"
                statusText.TextColor3 = Colors.HologramBlue
                dot.BackgroundColor3 = Colors.HologramBlue
                glow.ImageColor3 = Colors.HologramBlue
            end
        end
    end)
    
    return statusPanel
end

-- 2. VISUALIZADOR DE SUJETO (Avatar holográfico con scanlines) - VERSIÓN FINAL
local function CreateSubjectViewer(dashboard)
    local viewerPanel = Instance.new("Frame")
    viewerPanel.Name = "SubjectViewer"
    viewerPanel.Size = UDim2.new(1, 0, 0, 220)
    viewerPanel.BackgroundColor3 = Colors.Panel
    viewerPanel.BorderSizePixel = 0
    viewerPanel.LayoutOrder = 2
    viewerPanel.Parent = dashboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = viewerPanel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = viewerPanel
    
    -- Título del panel
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "VISUALIZADOR DE SUJETO"
    titleLabel.TextColor3 = Colors.Accent
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = viewerPanel
    
    -- ViewportFrame para el avatar
    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "AvatarViewport"
    viewport.Size = UDim2.new(1, -20, 1, -35)
    viewport.Position = UDim2.new(0, 10, 0, 28)
    viewport.BackgroundColor3 = Color3.fromRGB(10, 20, 15)
    viewport.BackgroundTransparency = 0.2
    viewport.BorderSizePixel = 0
    viewport.LightColor = Color3.fromRGB(255, 255, 255)
    viewport.LightDirection = Vector3.new(1, -1, 1)
    viewport.Ambient = Color3.fromRGB(150, 150, 150)
    viewport.Parent = viewerPanel
    
    local viewportCorner = Instance.new("UICorner")
    viewportCorner.CornerRadius = UDim.new(0, 4)
    viewportCorner.Parent = viewport
    
    -- Crear el avatar 3D conservando los accesorios del personaje original
    task.spawn(function()
        if not viewport.Parent then
            return
        end

        local avatar = nil
        local character = player.Character

        -- Esperar al personaje si todavía está cargando
        if not character then
            local characterSuccess, loadedCharacter = pcall(function()
                return player.CharacterAdded:Wait()
            end)
            if characterSuccess then
                character = loadedCharacter
            end
        end

        -- Clonar el personaje actual para conservar cabello, accesorios y uniones
        if character then
            local previousArchivable = character.Archivable
            character.Archivable = true
            local cloneSuccess, characterClone = pcall(function()
                return character:Clone()
            end)
            character.Archivable = previousArchivable

            if cloneSuccess and characterClone then
                avatar = characterClone
            end
        end

        -- Alternativa si el personaje no se pudo clonar
        if not avatar then
            local descriptionSuccess, description = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(player.UserId)
            end)

            if descriptionSuccess and description then
                local modelSuccess, model = pcall(function()
                    return Players:CreateHumanoidModelFromDescription(
                        description,
                        Enum.HumanoidRigType.R15
                    )
                end)

                if modelSuccess and model then
                    avatar = model
                else
                    warn("[ProtoRun Lite] No se pudo crear el avatar desde la descripción:", model)
                end
            else
                warn("[ProtoRun Lite] No se pudo obtener la descripción del avatar:", description)
            end
        end

        if not avatar then
            warn("[ProtoRun Lite] No se pudo cargar el personaje en el visor")
            return
        end

        -- Quitar scripts y componentes que no son necesarios dentro del visor
        for _, object in ipairs(avatar:GetDescendants()) do
            if object:IsA("Script") or object:IsA("LocalScript") then
                object:Destroy()
            elseif object:IsA("BasePart") then
                object.CanCollide = false
                object.CastShadow = false
                object.Anchored = true
            end
        end

        local humanoid = avatar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                animator:Destroy()
            end
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end

        -- El WorldModel conserva correctamente los accesorios y sus uniones
        local worldModel = Instance.new("WorldModel")
        worldModel.Name = "AvatarWorld"
        worldModel.Parent = viewport

        avatar.Name = "AvatarClone"
        avatar.Parent = worldModel
        avatar:PivotTo(CFrame.new(0, 0, 0))

        -- Calcular el encuadre después de posicionar el modelo
        local boundingCFrame, boundingSize = avatar:GetBoundingBox()
        local center = boundingCFrame.Position
        local focusPoint = center + Vector3.new(0, boundingSize.Y * 0.02, 0)

        -- Cámara fija, frontal y ajustada al tamaño del avatar
        local cameraDistance = math.max(boundingSize.Y * 1.35, 4)
        local camera = Instance.new("Camera")
        camera.Name = "AvatarCamera"
        camera.FieldOfView = 35
        camera.CFrame = CFrame.lookAt(
            focusPoint + Vector3.new(0, 0, -cameraDistance),
            focusPoint
        )
        camera.Parent = viewport
        viewport.CurrentCamera = camera
    end)
    
    -- EFECTO DE SCANLINES (líneas horizontales)
    local scanlines = Instance.new("Frame")
    scanlines.Name = "Scanlines"
    scanlines.Size = UDim2.new(1, 0, 1, 0)
    scanlines.Position = UDim2.new(0, 0, 0, 0)
    scanlines.BackgroundTransparency = 1
    scanlines.BorderSizePixel = 0
    scanlines.ClipsDescendants = true
    scanlines.ZIndex = 10
    scanlines.Parent = viewport
    
    -- Crear líneas horizontales
    for i = 1, 60 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0, i * 3)
        line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
        line.ZIndex = 10
        line.Parent = scanlines
    end
    
    -- Overlay de color holográfico (MUY transparente)
    local holoOverlay = Instance.new("Frame")
    holoOverlay.Name = "HoloOverlay"
    holoOverlay.Size = UDim2.new(1, 0, 1, 0)
    holoOverlay.Position = UDim2.new(0, 0, 0, 0)
    holoOverlay.BackgroundColor3 = Colors.HologramGreen
    holoOverlay.BackgroundTransparency = 0.95
    holoOverlay.BorderSizePixel = 0
    holoOverlay.ZIndex = 11
    holoOverlay.Parent = viewport
    
    -- Efecto de parpadeo holográfico sutil
    task.spawn(function()
        while viewerPanel.Parent do
            task.wait(0.15)
            local flicker = math.random(93, 97) / 100
            holoOverlay.BackgroundTransparency = flicker
        end
    end)
    
    -- Etiqueta "LIVE" en esquina
    local liveLabel = Instance.new("TextLabel")
    liveLabel.Size = UDim2.new(0, 50, 0, 18)
    liveLabel.Position = UDim2.new(0, 15, 0, 33)
    liveLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    liveLabel.BackgroundTransparency = 0.2
    liveLabel.BorderSizePixel = 0
    liveLabel.Text = "● LIVE"
    liveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    liveLabel.TextSize = 10
    liveLabel.Font = Enum.Font.GothamBold
    liveLabel.ZIndex = 15
    liveLabel.Parent = viewerPanel
    
    local liveCorner = Instance.new("UICorner")
    liveCorner.CornerRadius = UDim.new(0, 3)
    liveCorner.Parent = liveLabel
    
    return viewerPanel
end

-- 3. ID DE RED DIRECTA (Username + Número de Serie)
local function CreateNetworkID(dashboard)
    local idPanel = Instance.new("Frame")
    idPanel.Name = "NetworkID"
    idPanel.Size = UDim2.new(1, 0, 0, 80)
    idPanel.BackgroundColor3 = Colors.Panel
    idPanel.BorderSizePixel = 0
    idPanel.LayoutOrder = 3
    idPanel.Parent = dashboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = idPanel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = idPanel
    
    -- Título del panel
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ID DE RED DIRECTA"
    titleLabel.TextColor3 = Colors.Accent
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = idPanel
    
    -- Username
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, -20, 0, 25)
    usernameLabel.Position = UDim2.new(0, 10, 0, 28)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@ " .. player.Name
    usernameLabel.TextColor3 = Colors.HologramGreen
    usernameLabel.TextSize = 16
    usernameLabel.Font = Enum.Font.Code
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = idPanel
    
    -- Número de serie
    local serialNumber = "SN-" .. tostring(player.UserId)
    local serialLabel = Instance.new("TextLabel")
    serialLabel.Size = UDim2.new(1, -20, 0, 20)
    serialLabel.Position = UDim2.new(0, 10, 0, 55)
    serialLabel.BackgroundTransparency = 1
    serialLabel.Text = serialNumber
    serialLabel.TextColor3 = Colors.TextDim
    serialLabel.TextSize = 12
    serialLabel.Font = Enum.Font.Code
    serialLabel.TextXAlignment = Enum.TextXAlignment.Left
    serialLabel.Parent = idPanel
    
    -- Línea decorativa
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 52)
    divider.BackgroundColor3 = Colors.Border
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = idPanel
    
    return idPanel
end

-- 4. LISTA DE JUGADORES CONECTADOS
local function CreatePlayerList(dashboard)
    local listPanel = Instance.new("Frame")
    listPanel.Name = "PlayerList"
    listPanel.Size = UDim2.new(1, 0, 0, 250)
    listPanel.BackgroundColor3 = Colors.Panel
    listPanel.BorderSizePixel = 0
    listPanel.LayoutOrder = 4
    listPanel.Parent = dashboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = listPanel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = listPanel
    
    -- Título del panel con contador
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "ListTitle"
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "JUGADORES CONECTADOS [0]"
    titleLabel.TextColor3 = Colors.Accent
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = listPanel
    
    -- ScrollFrame para la lista
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayersScroll"
    scrollFrame.Size = UDim2.new(1, -20, 1, -35)
    scrollFrame.Position = UDim2.new(0, 10, 0, 28)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Colors.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = listPanel
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    -- Función para crear un item de jugador
    local function CreatePlayerItem(playerName, userId, layoutOrder)
        local item = Instance.new("Frame")
        item.Name = "Player_" .. userId
        item.Size = UDim2.new(1, -5, 0, 30)
        item.BackgroundColor3 = Colors.Button
        item.BorderSizePixel = 0
        item.LayoutOrder = layoutOrder
        item.Parent = scrollFrame
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 3)
        itemCorner.Parent = item
        
        local itemStroke = Instance.new("UIStroke")
        itemStroke.Color = Colors.Border
        itemStroke.Transparency = 0.7
        itemStroke.Thickness = 1
        itemStroke.Parent = item
        
        -- Indicador de estado (punto verde)
        local statusDot = Instance.new("Frame")
        statusDot.Size = UDim2.new(0, 8, 0, 8)
        statusDot.Position = UDim2.new(0, 8, 0.5, -4)
        statusDot.BackgroundColor3 = Colors.HologramGreen
        statusDot.BorderSizePixel = 0
        statusDot.Parent = item
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = statusDot
        
        -- Nombre del jugador
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, -20, 1, 0)
        nameLabel.Position = UDim2.new(0, 22, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = playerName
        nameLabel.TextColor3 = Colors.Text
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = item
        
        -- ID del jugador
        local idLabel = Instance.new("TextLabel")
        idLabel.Size = UDim2.new(0.4, -10, 1, 0)
        idLabel.Position = UDim2.new(0.6, 0, 0, 0)
        idLabel.BackgroundTransparency = 1
        idLabel.Text = "ID:" .. tostring(userId)
        idLabel.TextColor3 = Colors.TextDim
        idLabel.TextSize = 11
        idLabel.Font = Enum.Font.Code
        idLabel.TextXAlignment = Enum.TextXAlignment.Right
        idLabel.Parent = item
        
        return item
    end
    
    -- Función para actualizar la lista
    local function UpdatePlayerList()
        -- Limpiar items existentes
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Agregar jugadores actuales
        local order = 1
        for _, p in ipairs(Players:GetPlayers()) do
            CreatePlayerItem(p.Name, p.UserId, order)
            order = order + 1
        end
        
        -- Actualizar contador en el título
        titleLabel.Text = "JUGADORES CONECTADOS [" .. #Players:GetPlayers() .. "]"
    end
    
    -- Actualizar inicialmente
    UpdatePlayerList()
    
    -- Escuchar cambios en la lista de jugadores
    Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        UpdatePlayerList()
    end)
    
    Players.PlayerRemoving:Connect(function()
        task.wait(0.2)
        UpdatePlayerList()
    end)
    
    return listPanel
end

-- Crear el Dashboard completo
local function CreateDashboard()
    local scrollFrame = ProtoRunLite.ContentScroll
    local dashboard = CreateDashboardContainer(scrollFrame)
    
    CreateConnectionStatus(dashboard)
    CreateSubjectViewer(dashboard)
    CreateNetworkID(dashboard)
    CreatePlayerList(dashboard)
    
    print("[ProtoRun Lite] ✓ Dashboard creado correctamente")
    return dashboard
end

-- Ejecutar la creación del Dashboard
CreateDashboard()

-- =====================================================
-- INTEGRACION PLAYER HIGHLIGHT ESP + LINEA KILLER
-- La lógica original de detección y etiquetas se conserva.
-- =====================================================

-- ProtoRun Lite - Player Highlight ESP
-- PARTE 1/3: Configuracion, roles, estados e imagenes
-- ----
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local ESP_CONFIG = {
    MasterESP = false,
    SurvivorESP = false,
    KillerESP = false,
    SpectatorESP = false,
    ItemsESP = false,
    Nametags = false,
    Distance = false,
    WarnKiller = false,
    KillerLine = false,
    WorldESP = false, WorldGenerators = true, WorldHooks = true, WorldGates = true,
    WorldWindows = true, WorldPallets = true, WorldSCPZombie = true,
    WorldNames = true, WorldDistance = false, WorldGeneratorPercent = true,
    WorldGeneratorColorIndex = 21,
    WorldHookColorIndex = 2,
    WorldGateColorIndex = 15,
    WorldWindowColorIndex = 5,
    WorldPalletColorIndex = 10,
    WorldSCPZombieColorIndex = 7,
    SurvivorRainbow = false,
    KillerRainbow = false,
    SpectatorRainbow = false,
    SurvivorColorIndex = 5,
    KillerColorIndex = 2,
    SpectatorColorIndex = 1,
    FillTransparency = 0.95,
    OutlineTransparency = 0.3,
    TextSize = 12,
    SurvivorColor = Color3.fromRGB(0, 255, 0),
    KillerColor = Color3.fromRGB(255, 0, 0),
    SpectatorColor = Color3.fromRGB(255, 255, 255),
    UpdateRate = 0.25
}
local KNOWN_ITEMS = {
    ["Motion Tracker"] = true,
    ["Gate"] = true,
    ["Flashlight"] = true,
    ["Bandage"] = true,
    ["Parrying Dagger"] = true,
    ["Adrenaline Shot"] = true,
    ["Twist of Fate"] = true,
    ["Shadow Clone"] = true,
    ["Holy Water"] = true,
    ["Wax Bound Candle"] = true,
    ["Riot Shield"] = true,
    ["Emperor"] = true,
    ["AWP"] = true
}
local WARN_ICONS = {
    Yellow = "rbxassetid://120753562298647",
    Red = "rbxassetid://99499680507460"
}
local ESPFolder
local PlayerConns = {}
local GlobalConns = {}
local WarningBillboards = {}
local ESPDead = false
local PlayerLoopThread
local ToggleRefresh
local ESPTestGui
local KillerLineFolder
local KillerLineParts = {}
local function PlayerKey(player)
    return tostring(player and player.UserId or 0)
end
local function GetESPFolder()
    if ESPDead then
        return nil
    end
    if ESPFolder and ESPFolder.Parent then
        return ESPFolder
    end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local parent = playerGui or workspace
    local old = parent:FindFirstChild("PRL_TestESP")
    if old then
        old:Destroy()
    end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "PRL_TestESP"
    ESPFolder.Parent = parent
    return ESPFolder
end
local function DestroyChild(name)
    local folder = ESPFolder
    if not folder or not folder.Parent then
        return
    end
    local child = folder:FindFirstChild(name)
    if child then
        child:Destroy()
    end
end
-- ----
-- DETECCION DEL ROL
-- ----
local function GetRole(player)
    if not player then
        return "Unknown"
    end
    local roleValues = {
        player:GetAttribute("Role"),
        player:GetAttribute("Team"),
        player:GetAttribute("PlayerRole")
    }
    for _, value in ipairs(roleValues) do
        if type(value) == "string" then
            local role = value:lower()
            if role:find("killer", 1, true) then
                return "Killer"
            elseif role:find("survivor", 1, true) then
                return "Survivor"
            elseif role:find("spect", 1, true) then
                return "Spectator"
            end
        end
    end
    local teamName = player.Team and player.Team.Name
    if teamName then
        teamName = teamName:lower()
        if teamName:find("killer", 1, true) then
            return "Killer"
        elseif teamName:find("survivor", 1, true) then
            return "Survivor"
        elseif teamName:find("spect", 1, true) then
            return "Spectator"
        end
    end
    return "Unknown"
end
local function IsKiller(player)
    return GetRole(player) == "Killer"
end
local function IsSurvivor(player)
    return GetRole(player) == "Survivor"
end
-- ----
-- NORMALIZAR ESTADOS
-- ----
local function NormalizeState(value)
    if value == nil then
        return nil
    end
    local state = tostring(value):lower()
    if state:find("downed", 1, true)
        or state:find("knocked", 1, true)
        or state:find("incapacitated", 1, true)
        or state:find("down", 1, true)
        or state == "dead" then
        return "Derribado"
    end
    if state:find("injured", 1, true)
        or state:find("wounded", 1, true)
        or state:find("hurt", 1, true)
        or state:find("injury", 1, true) then
        return "Herido"
    end
    return nil
end
-- ----
-- DETECTAR ESTADO DEL JUGADOR
-- ----
local function GetPlayerState(player)
    if not player or not player.Character then
        return nil
    end
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local containers = {player, character}
    if humanoid then
        table.insert(containers, humanoid)
    end
    local downedKeys = {
        "IsDowned", "Downed", "Knocked",
        "IsKnocked", "Incapacitated", "IsIncapacitated"
    }
    local injuredKeys = {
        "IsInjured", "Injured", "Wounded",
        "IsWounded", "Hurt", "IsHurt"
    }
    local stateKeys = {
        "State", "PlayerState", "SurvivorState",
        "Condition", "Status", "HealthState"
    }
    local function IsTrue(value)
        return value == true or value == 1
            or (type(value) == "string" and value:lower() == "true")
    end
    local function ReadContainer(container)
        for _, key in ipairs(stateKeys) do
            local value = container:GetAttribute(key)
            if value ~= nil then
                local state = NormalizeState(value)
                if state then
                    return state
                end
            end
        end
        for _, key in ipairs(downedKeys) do
            if IsTrue(container:GetAttribute(key)) then
                return "Derribado"
            end
            local value = container:FindFirstChild(key)
            if value and value:IsA("BoolValue") and value.Value then
                return "Derribado"
            end
        end
        for _, key in ipairs(injuredKeys) do
            if IsTrue(container:GetAttribute(key)) then
                return "Herido"
            end
            local value = container:FindFirstChild(key)
            if value and value:IsA("BoolValue") and value.Value then
                return "Herido"
            end
        end
        return nil
    end
    for _, container in ipairs(containers) do
        if ReadContainer(container) == "Derribado" then
            return "Derribado"
        end
    end
    for _, container in ipairs(containers) do
        if ReadContainer(container) == "Herido" then
            return "Herido"
        end
    end
    for _, container in ipairs(containers) do
        for _, object in ipairs(container:GetDescendants()) do
            if object:IsA("StringValue") then
                local name = object.Name:lower()
                if table.find(stateKeys, object.Name)
                    or name:find("state")
                    or name:find("condition")
                    or name:find("status") then
                    local state = NormalizeState(object.Value)
                    if state then
                        return state
                    end
                end
            elseif object:IsA("BoolValue") and object.Value then
                local name = object.Name:lower()
                if name:find("down") or name:find("knock")
                    or name:find("incapacitat") then
                    return "Derribado"
                elseif name:find("injur") or name:find("wound")
                    or name:find("hurt") then
                    return "Herido"
                end
            end
        end
    end
    if humanoid then
        if humanoid.Health <= 0 then
            return "Derribado"
        elseif humanoid.MaxHealth > 0
            and humanoid.Health < humanoid.MaxHealth then
            return "Herido"
        end
    end
    return nil
end
-- ----
-- DETECCION DEL OBJETO DEL SURVIVOR
-- ----
local function GetSurvivorItem(player)
    local character = player and player.Character
    if not character then
        return nil
    end
    for _, object in ipairs(character:GetDescendants()) do
        if (object:IsA("Tool") or object:IsA("Accessory")
            or object:IsA("Model")) and KNOWN_ITEMS[object.Name] then
            return object.Name
        end
    end
    return nil
end
-- ----
-- OBTENER IMAGEN REAL DESDE REPLICATEDSTORAGE
-- ----
local function NormalizeImageId(value)
    if type(value) == "number" and value > 0 then
        return "rbxassetid://" .. tostring(value)
    end
    if type(value) ~= "string" or value == "" then
        return nil
    end
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end
    if value:match("^rbxassetid://") or value:match("^https?://") then
        return value
    end
    return nil
end
local function GetItemImageId(itemName, player)
    if not itemName then
        return nil
    end
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    local itemObject = itemsFolder and itemsFolder:FindFirstChild(itemName)
    if itemObject then
        if itemObject:IsA("Decal") or itemObject:IsA("Texture") then
            if itemObject.Texture ~= "" then
                return itemObject.Texture
            end
        end
        local texture = itemObject:FindFirstChildWhichIsA("Decal", true)
            or itemObject:FindFirstChildWhichIsA("Texture", true)
        if texture and texture.Texture ~= "" then
            return texture.Texture
        end
        for _, attribute in ipairs({"ImageId", "TextureId", "Icon", "Image"}) do
            local imageId = NormalizeImageId(itemObject:GetAttribute(attribute))
            if imageId then
                return imageId
            end
        end
    end
    local character = player and player.Character
    local object = character and character:FindFirstChild(itemName, true)
    if object then
        if object:IsA("Tool") and object.TextureId ~= "" then
            return object.TextureId
        end
        for _, attribute in ipairs({"ImageId", "TextureId", "Icon", "Image"}) do
            local imageId = NormalizeImageId(object:GetAttribute(attribute))
            if imageId then
                return imageId
            end
        end
        local decal = object:FindFirstChildWhichIsA("Decal", true)
        if decal and decal.Texture ~= "" then
            return decal.Texture
        end
        local texture = object:FindFirstChildWhichIsA("Texture", true)
        if texture and texture.Texture ~= "" then
            return texture.Texture
        end
        local image = object:FindFirstChildWhichIsA("ImageLabel", true)
            or object:FindFirstChildWhichIsA("ImageButton", true)
        if image and image.Image ~= "" then
            return image.Image
        end
    end
    return nil
end
-- ----
-- HIGHLIGHT DE LOS PERSONAJES
-- ----
local function EnsureHighlight(name, adornee, color, isPlayer)
    local folder = GetESPFolder()
    if not folder or not adornee then
        return nil
    end
    local highlight = folder:FindFirstChild(name)
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = name
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = folder
    end
    highlight.Adornee = adornee
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = isPlayer and ESP_CONFIG.FillTransparency or 0.98
    highlight.OutlineTransparency = isPlayer and ESP_CONFIG.OutlineTransparency or 0.5
    highlight.Enabled = true
    return highlight
end
local function ClearPlayerESP(player)
    if not player or player == LocalPlayer then
        return
    end
    local key = PlayerKey(player)
    DestroyChild("PRL_HL_" .. key)
    DestroyChild("PRL_Tag_" .. key)
    DestroyChild("PRL_Item_" .. key)
    DestroyChild("PRL_Warn_" .. key)
end

-- ProtoRun Lite - Player Highlight ESP
-- PARTE 2/3: Etiquetas y actualizacion
-- ----
local function CreateTagText(parent, name, order)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.new(0, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = ESP_CONFIG.TextSize
    label.TextStrokeTransparency = 0.4
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = false
    label.LayoutOrder = order
    label.Visible = false
    label.Parent = parent
    return label
end
local function CreatePlayerTag(player, head)
    local folder = GetESPFolder()
    if not folder or not player or not head then
        return nil
    end
    local tagName = "PRL_Tag_" .. PlayerKey(player)
    local tag = folder:FindFirstChild(tagName)
    if tag then
        tag.Adornee = head
        return tag
    end
    tag = Instance.new("BillboardGui")
    tag.Name = tagName
    tag.AlwaysOnTop = true
    tag.LightInfluence = 0
    tag.MaxDistance = 0
    tag.Size = UDim2.fromOffset(300, 28)
    tag.StudsOffset = Vector3.new(0, 2.65, 0)
    tag.Adornee = head
    tag.Enabled = true
    tag.Parent = folder
    local frame = Instance.new("Frame")
    frame.Name = "Content"
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.fromScale(1, 1)
    frame.Parent = tag
    local layout = Instance.new("UIListLayout")
    layout.Name = "HorizontalLayout"
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = frame
    local image = Instance.new("ImageLabel")
    image.Name = "ItemImage"
    image.BackgroundTransparency = 1
    image.BorderSizePixel = 0
    image.Size = UDim2.fromOffset(15, 15)
    image.LayoutOrder = 1
    image.ScaleType = Enum.ScaleType.Fit
    image.Visible = false
    image.Parent = frame
    CreateTagText(frame, "ItemSeparator", 2)
    CreateTagText(frame, "MainText", 3)
    CreateTagText(frame, "StateSeparator", 4)
    CreateTagText(frame, "StateText", 5)
    CreateTagText(frame, "DistanceSeparator", 6)
    CreateTagText(frame, "DistanceText", 7)
    return tag
end
local function UpdatePlayerTag(player, character, head, color)
    local tagName = "PRL_Tag_" .. PlayerKey(player)
    if not head or not head.Parent then
        DestroyChild(tagName)
        return
    end
    local role = GetRole(player)
    local itemName
    local imageId
    if role == "Survivor" and ESP_CONFIG.ItemsESP then
        itemName = GetSurvivorItem(player)
        imageId = GetItemImageId(itemName, player)
    end
    local state = role == "Survivor" and GetPlayerState(player) or nil
    local mainText = ESP_CONFIG.Nametags and player.Name or ""
    local stateText = state == "Herido" and "Herido" or (state == "Derribado" and "Derribado" or "")
    local stateColor = state == "Herido" and Color3.fromRGB(255, 165, 0)
        or (state == "Derribado" and Color3.fromRGB(255, 50, 50) or color)
    local distanceText = ""
    if ESP_CONFIG.Distance then
        local localCharacter = LocalPlayer.Character
        local root = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        local targetRoot = character:FindFirstChild("HumanoidRootPart")
        if root and targetRoot then
            distanceText = tostring(math.floor((root.Position - targetRoot.Position).Magnitude)) .. " m"
        end
    end
    local showItemImage = role == "Survivor"
        and ESP_CONFIG.ItemsESP and itemName ~= nil and imageId ~= nil
    local fallbackItemText = ""
    if role == "Survivor" and ESP_CONFIG.ItemsESP and itemName and not imageId then
        fallbackItemText = "[" .. itemName .. "]"
    end
    local showMainText = mainText ~= ""
    local showStateText = stateText ~= "" and showMainText
    local showFallback = fallbackItemText ~= ""
    local showDistance = distanceText ~= ""
    if not showItemImage and not showMainText and not showFallback and not showDistance then
        DestroyChild(tagName)
        return
    end
    local tag = CreatePlayerTag(player, head)
    if not tag then
        return
    end
    local frame = tag:FindFirstChild("Content")
    if not frame then
        DestroyChild(tagName)
        return
    end
    local image = frame:FindFirstChild("ItemImage")
    local itemSeparator = frame:FindFirstChild("ItemSeparator")
    local mainLabel = frame:FindFirstChild("MainText")
    local stateSeparator = frame:FindFirstChild("StateSeparator")
    local stateLabel = frame:FindFirstChild("StateText")
    local distanceSeparator = frame:FindFirstChild("DistanceSeparator")
    local distanceLabel = frame:FindFirstChild("DistanceText")
    if not image or not itemSeparator or not mainLabel or not stateSeparator or not stateLabel
        or not distanceSeparator or not distanceLabel then
        DestroyChild(tagName)
        return
    end
    image.Visible = showItemImage
    image.Image = showItemImage and imageId or ""
    itemSeparator.Visible = showItemImage and (showMainText or showFallback)
    itemSeparator.Text = " | "
    itemSeparator.TextColor3 = color
    itemSeparator.TextSize = ESP_CONFIG.TextSize
    mainLabel.Text = showFallback and fallbackItemText or mainText
    mainLabel.Visible = showMainText or showFallback
    mainLabel.TextColor3 = color
    mainLabel.TextSize = ESP_CONFIG.TextSize
    stateSeparator.Visible = showStateText
    stateSeparator.Text = " • "
    stateSeparator.TextColor3 = stateColor
    stateSeparator.TextSize = ESP_CONFIG.TextSize
    stateLabel.Text = stateText
    stateLabel.Visible = showStateText
    stateLabel.TextColor3 = stateColor
    stateLabel.TextSize = ESP_CONFIG.TextSize
    distanceSeparator.Visible = showDistance and (showItemImage or showMainText or showFallback or showStateText)
    distanceSeparator.Text = " | "
    distanceSeparator.TextColor3 = color
    distanceSeparator.TextSize = ESP_CONFIG.TextSize
    distanceLabel.Text = distanceText
    distanceLabel.Visible = showDistance
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextSize = ESP_CONFIG.TextSize
    tag.Adornee = head
    tag.Enabled = true
    tag.StudsOffset = Vector3.new(0, 2.65, 0)
    task.defer(function()
        if not tag.Parent or not frame.Parent then
            return
        end
        local width = 0
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextLabel") and child.Visible then
                width += child.TextBounds.X + 4
            end
        end
        if image.Visible then
            width += image.Size.X.Offset + 4
        end
        tag.Size = UDim2.fromOffset(math.clamp(width + 8, 30, 500), 28)
    end)
end
local function ResolveRoleColor(role)
    if role == "Survivor" and ESP_CONFIG.SurvivorRainbow then
        return Color3.fromHSV((tick() * 0.15) % 1, 1, 1)
    elseif role == "Killer" and ESP_CONFIG.KillerRainbow then
        return Color3.fromHSV((tick() * 0.15) % 1, 1, 1)
    elseif role == "Spectator" and ESP_CONFIG.SpectatorRainbow then
        return Color3.fromHSV((tick() * 0.15) % 1, 1, 1)
    end
    if role == "Killer" then return ESP_CONFIG.KillerColor end
    if role == "Spectator" then return ESP_CONFIG.SpectatorColor end
    return ESP_CONFIG.SurvivorColor
end

local function ApplyPlayerESP(player)
    if ESPDead or not player or player == LocalPlayer then
        return
    end
    local character = player.Character
    if not character or not character.Parent then
        ClearPlayerESP(player)
        return
    end
    local role = GetRole(player)
    local enabled = ESP_CONFIG.MasterESP
    if role == "Killer" then
        enabled = enabled and ESP_CONFIG.KillerESP
    elseif role == "Spectator" then
        enabled = enabled and ESP_CONFIG.SpectatorESP
    elseif role == "Survivor" then
        enabled = enabled and ESP_CONFIG.SurvivorESP
    else
        enabled = false
    end
    if not enabled then
        ClearPlayerESP(player)
        return
    end
    local color = ResolveRoleColor(role)
    local head = character:FindFirstChild("Head")
    EnsureHighlight("PRL_HL_" .. PlayerKey(player), character, color, true)
    UpdatePlayerTag(player, character, head, color)
    DestroyChild("PRL_Item_" .. PlayerKey(player))
end
local function RefreshAllPlayers()
    if ESPDead then
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local ok, err = pcall(ApplyPlayerESP, player)
            if not ok then
                warn("[ProtoRun Lite] Error ESP:", player.Name, err)
            end
        end
    end
end
local function StartPlayerLoop()
    if ESPDead or PlayerLoopThread then
        return
    end
    PlayerLoopThread = task.spawn(function()
        while not ESPDead and ESP_CONFIG.MasterESP do
            RefreshAllPlayers()
            task.wait(math.max(0.1, ESP_CONFIG.UpdateRate))
        end
        PlayerLoopThread = nil
    end)
end

-- ProtoRun Lite - Player Highlight ESP
-- parte 3/3: Killer Warning, menu y conexiones
-- ----
local function RemoveKillerWarning(player)
    local warning = WarningBillboards[player]
    if warning then
        pcall(function()
            warning:Destroy()
        end)
        WarningBillboards[player] = nil
    end
end
local function CreateKillerWarning(player, root, isClose)
    if not player or not root or not root:IsA("BasePart") then
        if player then
            RemoveKillerWarning(player)
        end
        return
    end
    local warning = WarningBillboards[player]
    if warning and (not warning.Parent or warning.Adornee ~= root) then
        RemoveKillerWarning(player)
        warning = nil
    end
    if not warning then
        warning = Instance.new("BillboardGui")
        warning.Name = "ProtoRunKillerWarning"
        warning.Size = UDim2.fromOffset(42, 42)
        warning.StudsOffset = Vector3.new(0, 4.5, 0)
        warning.AlwaysOnTop = true
        warning.LightInfluence = 0
        warning.MaxDistance = 0
        warning.Adornee = root
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Size = UDim2.fromScale(1, 1)
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = warning
        WarningBillboards[player] = warning
    end
    local icon = warning:FindFirstChild("Icon")
    if icon then
        icon.Image = isClose and WARN_ICONS.Red or WARN_ICONS.Yellow
        icon.ImageColor3 = Color3.new(1, 1, 1)
        icon.Visible = true
    end
    warning.Adornee = root
    warning.Parent = root
    warning.Enabled = true
end
-- ----
-- OBTENER POSICIONES DE LOS KILLERS
-- ----
local function GetKillerRoots()
    local roots = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if IsKiller(player) then
            local character = player.Character
            local root = character and (
                character:FindFirstChild("HumanoidRootPart")
                or character:FindFirstChild("UpperTorso")
                or character:FindFirstChild("Torso")
            )
            if root and root:IsA("BasePart") then
                table.insert(roots, {Player = player, Root = root})
            end
        end
    end
    return roots
end
-- ----
-- ACTUALIZAR KILLER WARNING
-- ----
local function UpdateKillerWarnings()
    if ESPDead then
        return
    end
    if not ESP_CONFIG.MasterESP or not ESP_CONFIG.WarnKiller then
        for player in pairs(WarningBillboards) do
            RemoveKillerWarning(player)
        end
        return
    end
    local killerRoots = GetKillerRoots()
    local activeWarnings = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if IsSurvivor(player) then
            local character = player.Character
            local root = character and (
                character:FindFirstChild("HumanoidRootPart")
                or character:FindFirstChild("UpperTorso")
                or character:FindFirstChild("Torso")
            )
            if root and root:IsA("BasePart") then
                local nearestDistance = math.huge
                for _, killerData in ipairs(killerRoots) do
                    if killerData.Player ~= player
                        and killerData.Root and killerData.Root.Parent then
                        local distance = (
                            root.Position - killerData.Root.Position
                        ).Magnitude
                        if distance < nearestDistance then
                            nearestDistance = distance
                        end
                    end
                end
                if nearestDistance <= 60 then
                    activeWarnings[player] = true
                    CreateKillerWarning(player, root, nearestDistance <= 40)
                else
                    RemoveKillerWarning(player)
                end
            else
                RemoveKillerWarning(player)
            end
        else
            RemoveKillerWarning(player)
        end
    end
    for player in pairs(WarningBillboards) do
        if not activeWarnings[player] then
            RemoveKillerWarning(player)
        end
    end
end
-- ----
local function DisconnectPlayer(player)
    local connections = PlayerConns[player]
    if connections then
        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        PlayerConns[player] = nil
    end
    RemoveKillerWarning(player)
    ClearPlayerESP(player)
end
local function WatchPlayer(player)
    if not player or player == LocalPlayer or ESPDead then
        return
    end
    DisconnectPlayer(player)
    local connections = {}
    PlayerConns[player] = connections
    local function AddConnection(connection)
        table.insert(connections, connection)
    end
    AddConnection(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not ESPDead and player.Parent == Players then
            ApplyPlayerESP(player)
            UpdateKillerWarnings()
        end
    end))
    AddConnection(player.CharacterRemoving:Connect(function()
        ClearPlayerESP(player)
        RemoveKillerWarning(player)
    end))
    AddConnection(player:GetPropertyChangedSignal("Team"):Connect(function()
        task.wait(0.1)
        if not ESPDead then
            ApplyPlayerESP(player)
            UpdateKillerWarnings()
        end
    end))
    AddConnection(player:GetAttributeChangedSignal("Role"):Connect(function()
        if not ESPDead then
            ApplyPlayerESP(player)
            UpdateKillerWarnings()
        end
    end))
    AddConnection(player:GetAttributeChangedSignal("Team"):Connect(function()
        if not ESPDead then
            ApplyPlayerESP(player)
            UpdateKillerWarnings()
        end
    end))
    if player.Character then
        task.defer(function()
            if not ESPDead and player.Parent == Players then
                ApplyPlayerESP(player)
                UpdateKillerWarnings()
            end
        end)
    end
end
-- ----
local function RefreshAfterToggle()
    if ESPDead then
        return
    end
    if ESP_CONFIG.MasterESP then
        RefreshAllPlayers()
        StartPlayerLoop()
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ClearPlayerESP(player)
            end
        end
    end
    UpdateKillerWarnings()
end
ToggleRefresh = RefreshAfterToggle
local function ShutdownESP()
    if ESPDead then
        return
    end
    ESPDead = true
    ESP_CONFIG.MasterESP = false
    for player in pairs(WarningBillboards) do
        RemoveKillerWarning(player)
    end
    for player in pairs(PlayerConns) do
        DisconnectPlayer(player)
    end
    for _, connection in ipairs(GlobalConns) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(GlobalConns)
    if ESPFolder then
        pcall(function()
            ESPFolder:Destroy()
        end)
        ESPFolder = nil
    end
    if ESPTestGui then
        pcall(function()
            ESPTestGui:Destroy()
        end)
        ESPTestGui = nil
    end
    if KillerLineFolder then
        pcall(function() KillerLineFolder:Destroy() end)
        KillerLineFolder = nil
    end
    table.clear(KillerLineParts)
end
-- ----

-- ----
-- PESTAÑA VISUAL INTEGRADA EN PROTORUN LITE
-- ----
local WORLD_COLORS = {
    Generator=Color3.fromRGB(255,215,0),
    Hook=Color3.fromRGB(255,70,70),
    Gate=Color3.fromRGB(70,220,255),
    Window=Color3.fromRGB(80,255,130),
    Pallet=Color3.fromRGB(190,120,255),
    SCPZombie=Color3.fromRGB(255,130,35)
}
local function CreateVisualTab()
    local scrollFrame = ProtoRunLite.ContentScroll
    if not scrollFrame then return end
    local old = scrollFrame:FindFirstChild("Visual_Content")
    if old then old:Destroy() end
    local visual = Instance.new("Frame")
    visual.Name = "Visual_Content"
    visual.Size = UDim2.new(1, -10, 0, 0)
    visual.BackgroundTransparency = 1
    visual.BorderSizePixel = 0
    visual.AutomaticSize = Enum.AutomaticSize.Y
    visual.Visible = false
    visual.Parent = scrollFrame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = visual
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 3)
    padding.PaddingRight = UDim.new(0, 3)
    padding.Parent = visual
    local palette = {
        {Name="Blanco", Color=Color3.fromRGB(255,255,255)},
        {Name="Rojo Carmín", Color=Color3.fromRGB(220,20,60)},
        {Name="Azul Cielo", Color=Color3.fromRGB(135,206,235)},
        {Name="Amarillo Limón", Color=Color3.fromRGB(255,247,0)},
        {Name="Verde Esmeralda", Color=Color3.fromRGB(80,200,120)},
        {Name="Negro", Color=Color3.fromRGB(10,10,10)},
        {Name="Naranja Butano", Color=Color3.fromRGB(255,120,20)},
        {Name="Morado Oscuro", Color=Color3.fromRGB(75,0,130)},
        {Name="Plata", Color=Color3.fromRGB(192,192,192)},
        {Name="Verde Lima", Color=Color3.fromRGB(50,205,50)},
        {Name="Blanco", Color=Color3.fromRGB(245,245,245)},
        {Name="Azul Marino", Color=Color3.fromRGB(0,0,128)},
        {Name="Rosa Pastel", Color=Color3.fromRGB(255,209,220)},
        {Name="Marrón Chocolate", Color=Color3.fromRGB(123,63,0)},
        {Name="Cian", Color=Color3.fromRGB(0,255,255)},
        {Name="Mostaza", Color=Color3.fromRGB(204,153,0)},
        {Name="Magenta", Color=Color3.fromRGB(255,0,255)},
        {Name="Verde Oliva", Color=Color3.fromRGB(128,128,0)},
        {Name="Coral", Color=Color3.fromRGB(255,127,80)},
        {Name="Lavanda", Color=Color3.fromRGB(230,230,250)},
        {Name="Oro", Color=Color3.fromRGB(255,215,0)},
        {Name="Gris Carbón", Color=Color3.fromRGB(54,69,79)},
        {Name="Azul Turquesa", Color=Color3.fromRGB(64,224,208)},
        {Name="Terracota", Color=Color3.fromRGB(226,114,91)},
        {Name="Fucsia", Color=Color3.fromRGB(255,0,128)},
        {Name="Verde Menta", Color=Color3.fromRGB(152,255,152)},
        {Name="Burdeos", Color=Color3.fromRGB(128,0,32)},
        {Name="Beige", Color=Color3.fromRGB(245,245,220)},
        {Name="Violeta", Color=Color3.fromRGB(143,0,255)},
        {Name="Acua", Color=Color3.fromRGB(127,255,212)},
        {Name="Salmón", Color=Color3.fromRGB(250,128,114)},
        {Name="Rojo Ladrillo", Color=Color3.fromRGB(178,34,34)},
        {Name="Azul Eléctrico", Color=Color3.fromRGB(125,249,255)},
        {Name="Verde Militar", Color=Color3.fromRGB(75,83,32)},
        {Name="Amarillo Neón", Color=Color3.fromRGB(255,255,51)},
        {Name="Gris Perla", Color=Color3.fromRGB(234,234,234)},
        {Name="Púrpura", Color=Color3.fromRGB(160,32,240)},
        {Name="Marrón Café", Color=Color3.fromRGB(111,78,55)},
        {Name="Verde Manzana", Color=Color3.fromRGB(141,182,0)},
        {Name="Azul Cobalto", Color=Color3.fromRGB(0,71,171)},
        {Name="Naranja Neón", Color=Color3.fromRGB(255,95,31)},
        {Name="Lila", Color=Color3.fromRGB(200,162,200)},
        {Name="Bronce", Color=Color3.fromRGB(205,127,50)},
        {Name="Crema", Color=Color3.fromRGB(255,253,208)},
        {Name="Verde Azulado", Color=Color3.fromRGB(0,128,128)},
        {Name="Granate", Color=Color3.fromRGB(128,0,0)},
        {Name="Celeste", Color=Color3.fromRGB(135,206,250)},
        {Name="Caqui", Color=Color3.fromRGB(195,176,145)},
        {Name="Rosa Chicle", Color=Color3.fromRGB(255,105,180)},
        {Name="Gris Pizarra", Color=Color3.fromRGB(112,128,144)},
        {Name="Amarillo Huevo", Color=Color3.fromRGB(255,225,53)},
        {Name="Carioca", Color=Color3.fromRGB(0,200,83)},
        {Name="Verde Pino", Color=Color3.fromRGB(1,121,111)},
        {Name="Ocre", Color=Color3.fromRGB(204,119,34)},
        {Name="Azul Índigo", Color=Color3.fromRGB(75,0,130)},
        {Name="Melocotón", Color=Color3.fromRGB(255,218,185)},
        {Name="Verde Jade", Color=Color3.fromRGB(0,168,107)},
        {Name="Marrón Madera", Color=Color3.fromRGB(139,69,19)},
        {Name="Malva", Color=Color3.fromRGB(224,176,255)},
        {Name="Azul Zafiro", Color=Color3.fromRGB(15,82,186)},
        {Name="Rojo Coral", Color=Color3.fromRGB(255,64,64)}
    }
    local function round(object, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 6)
        c.Parent = object
    end
    local function makeLabel(parent, text, height, size)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 0, height or 22)
        label.Font = Enum.Font.GothamSemibold
        label.Text = text
        label.TextSize = size or 11
        label.TextColor3 = Color3.fromRGB(235,235,235)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        return label
    end
    local function makeSection(titleText, order)
        local section = Instance.new("Frame")
        section.Name = titleText:gsub("%W", "") .. "Section"
        section.Size = UDim2.new(1, 0, 0, 0)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.BackgroundColor3 = Color3.fromRGB(22,22,22)
        section.BorderSizePixel = 0
        section.LayoutOrder = order
        section.Parent = visual
        round(section, 7)
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Padding = UDim.new(0, 5)
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Parent = section
        local sectionPadding = Instance.new("UIPadding")
        sectionPadding.PaddingTop = UDim.new(0, 6)
        sectionPadding.PaddingBottom = UDim.new(0, 7)
        sectionPadding.PaddingLeft = UDim.new(0, 7)
        sectionPadding.PaddingRight = UDim.new(0, 7)
        sectionPadding.Parent = section
        local header = Instance.new("TextButton")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundColor3 = Color3.fromRGB(38,38,38)
        header.BorderSizePixel = 0
        header.Font = Enum.Font.GothamBold
        header.Text = titleText .. " (▼)"
        header.TextColor3 = Color3.fromRGB(255,215,0)
        header.TextSize = 11
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = section
        round(header, 5)
        local body = Instance.new("Frame")
        body.Name = "Body"
        body.Size = UDim2.new(1, 0, 0, 0)
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.BackgroundTransparency = 1
        body.Visible = false
        body.Parent = section
        local bodyLayout = Instance.new("UIListLayout")
        bodyLayout.Padding = UDim.new(0, 5)
        bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
        bodyLayout.Parent = body
        header.Activated:Connect(function()
            body.Visible = not body.Visible
            header.Text = titleText .. (body.Visible and " (▲)" or " (▼)")
        end)
        return body
    end
    local function makeToggle(parent, titleText, key, onChanged)
        local button = Instance.new("TextButton")
        button.Name = key .. "Toggle"
        button.Size = UDim2.new(1, 0, 0, 29)
        button.BackgroundColor3 = Color3.fromRGB(39,43,52)
        button.BorderSizePixel = 0
        button.Font = Enum.Font.Gotham
        button.TextSize = 11
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = parent
        round(button, 5)
        local function refresh()
            local value = ESP_CONFIG[key] == true
            button.Text = "  " .. titleText .. ": " .. (value and "ON" or "OFF")
            button.TextColor3 = value and Color3.fromRGB(105,225,145) or Color3.fromRGB(195,195,195)
            button.BackgroundColor3 = value and Color3.fromRGB(35,57,46) or Color3.fromRGB(39,43,52)
        end
        button.Activated:Connect(function()
            ESP_CONFIG[key] = not ESP_CONFIG[key]
            refresh()
            if ToggleRefresh then ToggleRefresh() end
            if onChanged then onChanged(ESP_CONFIG[key]) end
        end)
        refresh()
        return button
    end
    local activeSlider
    local function makeSlider(parent, titleText, minValue, maxValue, initial, suffix, callback)
        local row = Instance.new("Frame")
        row.Name = titleText:gsub("%W", "") .. "Slider"
        row.Size = UDim2.new(1, 0, 0, 47)
        row.BackgroundTransparency = 1
        row.Parent = parent
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(0,0)
        label.Size = UDim2.new(1,0,0,19)
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.TextColor3 = Color3.fromRGB(230,230,230)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row
        local track = Instance.new("TextButton")
        track.Name = "Track"
        track.Position = UDim2.new(0, 1, 0, 27)
        track.Size = UDim2.new(1, -2, 0, 7)
        track.BackgroundColor3 = Color3.fromRGB(76,76,76)
        track.BorderSizePixel = 0
        track.Text = ""
        track.AutoButtonColor = false
        track.Parent = row
        round(track, 4)
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.Size = UDim2.fromOffset(15,15)
        knob.AnchorPoint = Vector2.new(0.5,0.5)
        knob.Position = UDim2.new(0,0,0.5,0)
        knob.BackgroundColor3 = Color3.fromRGB(255,215,0)
        knob.BorderSizePixel = 0
        knob.ZIndex = 3
        knob.Parent = track
        round(knob, 99)
        local current = math.clamp(initial, minValue, maxValue)
        local function setValue(value)
            current = math.clamp(math.floor(value + 0.5), minValue, maxValue)
            local alpha = (current - minValue) / math.max(1, maxValue - minValue)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            label.Text = titleText .. ": " .. tostring(current) .. (suffix or "")
            if callback then callback(current) end
        end
        local function setFromInput(input)
            local x = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local alpha = track.AbsoluteSize.X > 0 and x / track.AbsoluteSize.X or 0
            setValue(minValue + alpha * (maxValue - minValue))
        end
        local function begin(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                activeSlider = track
                setFromInput(input)
            end
        end
        track.InputBegan:Connect(begin)
        knob.InputBegan:Connect(begin)
        local moveConn = UserInputService.InputChanged:Connect(function(input)
            if activeSlider == track and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromInput(input)
            end
        end)
        local endConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if activeSlider == track then activeSlider = nil end
            end
        end)
        setValue(current)
        return row
    end
    local function makeColorPicker(parent, roleName, configColor, rainbowKey, indexKey)
        local colorRow = Instance.new("Frame")
        colorRow.Size = UDim2.new(1,0,0,0)
        colorRow.AutomaticSize = Enum.AutomaticSize.Y
        colorRow.BackgroundTransparency = 1
        colorRow.Parent = parent
        local rowLayout = Instance.new("UIListLayout")
        rowLayout.Padding = UDim.new(0,5)
        rowLayout.Parent = colorRow
        makeToggle(colorRow, roleName .. " Rainbow", rainbowKey, function() end)
        local colorHeader = Instance.new("Frame")
        colorHeader.Name = roleName .. "ColorHeader"
        colorHeader.Size = UDim2.new(1,0,0,30)
        colorHeader.BackgroundTransparency = 1
        colorHeader.Parent = colorRow
        local colorLabel = Instance.new("TextLabel")
        colorLabel.Size = UDim2.new(1,-42,1,0)
        colorLabel.BackgroundTransparency = 1
        colorLabel.Text = "Color " .. roleName
        colorLabel.TextColor3 = Color3.fromRGB(240,240,240)
        colorLabel.TextSize = 11
        colorLabel.Font = Enum.Font.GothamSemibold
        colorLabel.TextXAlignment = Enum.TextXAlignment.Left
        colorLabel.Parent = colorHeader
        local selected = Instance.new("TextButton")
        selected.Name = roleName .. "ColorSelect"
        selected.Size = UDim2.fromOffset(24,24)
        selected.Position = UDim2.new(1,-27,0,3)
        selected.BackgroundColor3 = ESP_CONFIG[configColor]
        selected.BorderSizePixel = 0
        selected.Text = ""
        selected.Parent = colorHeader
        round(selected,12)
        local swatchStroke = Instance.new("UIStroke")
        swatchStroke.Color = Color3.fromRGB(235,235,235)
        swatchStroke.Thickness = 1
        swatchStroke.Parent = selected
        local paletteFrame = Instance.new("Frame")
        paletteFrame.Size = UDim2.new(1,0,0,0)
        paletteFrame.AutomaticSize = Enum.AutomaticSize.Y
        paletteFrame.BackgroundColor3 = Color3.fromRGB(29,29,29)
        paletteFrame.Visible = false
        paletteFrame.Parent = colorRow
        round(paletteFrame,5)
        local paletteLayout = Instance.new("UIListLayout")
        paletteLayout.Padding = UDim.new(0,2)
        paletteLayout.Parent = paletteFrame
        local palettePadding = Instance.new("UIPadding")
        palettePadding.PaddingTop = UDim.new(0,4)
        palettePadding.PaddingBottom = UDim.new(0,4)
        palettePadding.PaddingLeft = UDim.new(0,4)
        palettePadding.PaddingRight = UDim.new(0,4)
        palettePadding.Parent = paletteFrame
        local function refreshSelected()
            local color = ESP_CONFIG[configColor]
            local idx = ESP_CONFIG[indexKey] or 1
            local name = palette[idx] and palette[idx].Name or "Personalizado"
            selected.BackgroundColor3 = color
            selected:SetAttribute("SelectedColorName", name)
            selected:SetAttribute("SelectedColorIndex", idx)
        end
        for index, item in ipairs(palette) do
            local option = Instance.new("TextButton")
            option.Name = "ColorOption" .. index
            option.Size = UDim2.new(1,0,0,25)
            option.BackgroundColor3 = item.Color
            option.BorderSizePixel = 0
            option.Font = Enum.Font.Gotham
            option.TextSize = 10
            option.Text = string.format("%02d. %s", index, item.Name)
            option.TextColor3 = (item.Color.R + item.Color.G + item.Color.B) / 3 > 0.62 and Color3.new(0,0,0) or Color3.new(1,1,1)
            option.Parent = paletteFrame
            round(option,4)
            option.Activated:Connect(function()
                ESP_CONFIG[configColor] = item.Color
                ESP_CONFIG[indexKey] = index
                paletteFrame.Visible = false
                refreshSelected()
                if ToggleRefresh then ToggleRefresh() end
            end)
        end
        selected.Activated:Connect(function()
            paletteFrame.Visible = not paletteFrame.Visible
        end)
        makeSlider(colorRow, roleName .. " color (1–31)", 1, 31, ESP_CONFIG[indexKey] or 1, "", function(value)
            ESP_CONFIG[indexKey] = value
            ESP_CONFIG[configColor] = palette[value].Color
            refreshSelected()
            if ToggleRefresh then ToggleRefresh() end
        end)
        refreshSelected()
    end
    local settings = makeSection("Highlight ESP Settings", 1)
    makeSlider(settings, "ESP fill transparency", 0, 100, math.floor(ESP_CONFIG.FillTransparency * 100 + 0.5), "%", function(value)
        ESP_CONFIG.FillTransparency = value / 100
        if ToggleRefresh then ToggleRefresh() end
    end)
    makeSlider(settings, "ESP outline transparency", 0, 100, math.floor(ESP_CONFIG.OutlineTransparency * 100 + 0.5), "%", function(value)
        ESP_CONFIG.OutlineTransparency = value / 100
        if ToggleRefresh then ToggleRefresh() end
    end)
    makeSlider(settings, "ESP text size", 8, 24, ESP_CONFIG.TextSize, "", function(value)
        ESP_CONFIG.TextSize = value
        if ToggleRefresh then ToggleRefresh() end
    end)
    local playerSettings = makeSection("Player Highlight ESP", 2)
    makeToggle(playerSettings, "Activate player ESP", "MasterESP")
    makeToggle(playerSettings, "ESP SURVIVOR", "SurvivorESP")
    makeToggle(playerSettings, "ESP KILLER", "KillerESP")
    makeToggle(playerSettings, "ESP ITEM SURVIVOR", "ItemsESP")
    makeToggle(playerSettings, "ESP ESPECTATOR", "SpectatorESP")
    makeToggle(playerSettings, "Nametags", "Nametags")
    makeToggle(playerSettings, "Distance ESP", "Distance")
    makeToggle(playerSettings, "Killer warning in Survivor", "WarnKiller")
    makeToggle(playerSettings, "Línea Killer", "KillerLine", function() end)
    local worldSettings = makeSection("World Highlight", 3)
    makeToggle(worldSettings, "Activar World Highlight", "WorldESP")
    makeToggle(worldSettings, "Generators", "WorldGenerators")
    makeToggle(worldSettings, "Hooks", "WorldHooks")
    makeToggle(worldSettings, "Gates", "WorldGates")
    makeToggle(worldSettings, "Windows", "WorldWindows")
    makeToggle(worldSettings, "Pallets", "WorldPallets")
    makeToggle(worldSettings, "SCP / Zombie", "WorldSCPZombie")
    makeToggle(worldSettings, "Nombres de objetos", "WorldNames")
    makeToggle(worldSettings, "Distancia de objetos", "WorldDistance")
    makeToggle(worldSettings, "Porcentaje de generador", "WorldGeneratorPercent")
    local worldColorsSection = makeSection("Colors World", 4)
    local worldColorControls = {
        {Label="Generator", Key="Generator", Index="WorldGeneratorColorIndex"},
        {Label="Hook", Key="Hook", Index="WorldHookColorIndex"},
        {Label="Gate", Key="Gate", Index="WorldGateColorIndex"},
        {Label="Window", Key="Window", Index="WorldWindowColorIndex"},
        {Label="Pallet", Key="Pallet", Index="WorldPalletColorIndex"},
        {Label="SCP / Zombie", Key="SCPZombie", Index="WorldSCPZombieColorIndex"}
    }
    for _, item in ipairs(worldColorControls) do
        makeSlider(worldColorsSection, item.Label .. " color", 1, #palette,
            ESP_CONFIG[item.Index], "", function(value)
                ESP_CONFIG[item.Index] = value
                WORLD_COLORS[item.Key] = palette[value].Color
                if ToggleRefresh then ToggleRefresh() end
            end)
    end
    local colorsSection = makeSection("ESP Colors", 5)
    makeColorPicker(colorsSection, "Survivor", "SurvivorColor", "SurvivorRainbow", "SurvivorColorIndex")
    makeColorPicker(colorsSection, "Killer", "KillerColor", "KillerRainbow", "KillerColorIndex")
    makeColorPicker(colorsSection, "Spectator", "SpectatorColor", "SpectatorRainbow", "SpectatorColorIndex")
    local refreshPlayers = Instance.new("TextButton")
    refreshPlayers.Name = "RefreshPlayerList"
    refreshPlayers.Size = UDim2.new(1,0,0,28)
    refreshPlayers.BackgroundColor3 = Color3.fromRGB(55,48,28)
    refreshPlayers.BorderSizePixel = 0
    refreshPlayers.Font = Enum.Font.GothamSemibold
    refreshPlayers.Text = "Actualizar lista de jugadores"
    refreshPlayers.TextColor3 = Color3.fromRGB(255,225,150)
    refreshPlayers.TextSize = 10
    refreshPlayers.LayoutOrder = 6
    refreshPlayers.Parent = visual
    round(refreshPlayers,5)
    refreshPlayers.Activated:Connect(function()
        if ToggleRefresh then ToggleRefresh() end
    end)
    print("[ProtoRun Lite] Pestaña Visual creada correctamente.")
end

-- ----
-- WORLD HIGHLIGHT ESP: OBJETOS DEL MAPA
-- ----
local WorldESPFolder, WorldESPObjects, WorldESPScanClock = nil, {}, 0
local function WorldFolder()
    if WorldESPFolder and WorldESPFolder.Parent then return WorldESPFolder end
    WorldESPFolder = workspace:FindFirstChild("PRL_WorldESP") or Instance.new("Folder")
    WorldESPFolder.Name = "PRL_WorldESP"; WorldESPFolder.Parent = workspace
    return WorldESPFolder
end
local function WorldCategory(obj)
    local n = string.lower(obj.Name)
    if n:find("generator",1,true) or n:match("^gen%d") then return "Generator" end
    if n:find("hook",1,true) or n:find("gancho",1,true) then return "Hook" end
    if n:find("gate",1,true) or n:find("exitdoor",1,true) or n:find("exit_door",1,true) then return "Gate" end
    if n:find("window",1,true) or n:find("vault",1,true) then return "Window" end
    if n:find("pallet",1,true) then return "Pallet" end
    if n:find("scp",1,true) or n:find("zombie",1,true) then return "SCPZombie" end
end
local function WorldEnabled(c)
    return (c=="Generator" and ESP_CONFIG.WorldGenerators) or (c=="Hook" and ESP_CONFIG.WorldHooks) or (c=="Gate" and ESP_CONFIG.WorldGates) or (c=="Window" and ESP_CONFIG.WorldWindows) or (c=="Pallet" and ESP_CONFIG.WorldPallets) or (c=="SCPZombie" and ESP_CONFIG.WorldSCPZombie)
end
local function WorldPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true) end
    return obj:FindFirstChildWhichIsA("BasePart",true)
end
local function WorldPercent(obj)
    for _,v in ipairs(obj:GetDescendants()) do
        local val=v:GetAttribute("Progress") or v:GetAttribute("Percent") or v:GetAttribute("RepairProgress")
        if typeof(val)=="number" then if val<=1 then val*=100 end; return math.clamp(math.floor(val+0.5),0,100) end
        if (v:IsA("NumberValue") or v:IsA("IntValue")) and (string.lower(v.Name):find("progress",1,true) or string.lower(v.Name):find("percent",1,true) or string.lower(v.Name):find("repair",1,true)) then
            val=v.Value; if val<=1 then val*=100 end; return math.clamp(math.floor(val+0.5),0,100)
        end
    end
end
local function RemoveWorld(obj)
    local r=WorldESPObjects[obj]; if not r then return end
    if r.h then pcall(function() r.h:Destroy() end) end
    if r.b then pcall(function() r.b:Destroy() end) end
    if r.p then pcall(function() r.p:Destroy() end) end
    WorldESPObjects[obj]=nil
end
local function CreateWorldLabel(name,offset,height)
    local billboard=Instance.new("BillboardGui")
    billboard.Name=name
    billboard.AlwaysOnTop=true
    billboard.Size=UDim2.fromOffset(180,height or 30)
    billboard.StudsOffset=Vector3.new(0,offset,0)
    billboard.Parent=WorldFolder()
    local label=Instance.new("TextLabel")
    label.Name="Label"
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.Font=Enum.Font.GothamBold
    label.TextSize=12
    label.TextStrokeTransparency=0.25
    label.TextWrapped=true
    label.Parent=billboard
    return billboard
end
local function ApplyWorld(obj,c)
    local part=WorldPart(obj); if not part then return end
    local r=WorldESPObjects[obj] or {}; WorldESPObjects[obj]=r
    local color=WORLD_COLORS[c]
    if not r.h or not r.h.Parent then
        r.h=Instance.new("Highlight")
        r.h.Name="PRL_WorldHighlight"
        r.h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        r.h.Parent=WorldFolder()
    end
    r.h.Adornee=obj
    r.h.FillColor=color
    r.h.OutlineColor=color
    r.h.FillTransparency=0.78
    r.h.OutlineTransparency=0.05
    -- Nametag y distancia: independientes del porcentaje del generador.
    if ESP_CONFIG.WorldNames or ESP_CONFIG.WorldDistance then
        if not r.b or not r.b.Parent then
            r.b=CreateWorldLabel("PRL_WorldLabel",2.5,36)
        end
        r.b.Adornee=part
        local label=r.b:FindFirstChild("Label")
        if label then
            local parts={}
            if ESP_CONFIG.WorldNames then table.insert(parts,obj.Name) end
            if ESP_CONFIG.WorldDistance then
                local ch=LocalPlayer.Character
                local root=ch and ch:FindFirstChild("HumanoidRootPart")
                if root then
                    table.insert(parts,tostring(math.floor((root.Position-part.Position).Magnitude)).." studs")
                end
            end
            label.Text=table.concat(parts," | ")
            label.TextColor3=color
        end
    elseif r.b then
        pcall(function() r.b:Destroy() end)
        r.b=nil
    end
    -- Porcentaje: Billboard propio, no depende de WorldNames ni WorldDistance.
    if c=="Generator" and ESP_CONFIG.WorldGeneratorPercent then
        if not r.p or not r.p.Parent then
            r.p=CreateWorldLabel("PRL_GeneratorPercent",1.35,24)
        end
        r.p.Adornee=part
        local label=r.p:FindFirstChild("Label")
        if label then
            local pct=WorldPercent(obj)
            label.Text=pct and ("Repair: "..tostring(pct).."%") or "Repair: --%"
            label.TextColor3=color
        end
    elseif r.p then
        pcall(function() r.p:Destroy() end)
        r.p=nil
    end
end
local function UpdateWorldESP(dt)
    if not ESP_CONFIG.WorldESP then for obj in pairs(WorldESPObjects) do RemoveWorld(obj) end; if WorldESPFolder then WorldESPFolder:ClearAllChildren() end; return end
    WorldESPScanClock+=dt or 0; if WorldESPScanClock<0.75 then return end; WorldESPScanClock=0
    local seen={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if not (WorldESPFolder and (obj==WorldESPFolder or obj:IsDescendantOf(WorldESPFolder))) then
            local c=WorldCategory(obj)
            if c and WorldEnabled(c) and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Folder")) and WorldPart(obj) then seen[obj]=true; ApplyWorld(obj,c) end
        end
    end
    for obj in pairs(WorldESPObjects) do if not seen[obj] or not obj.Parent then RemoveWorld(obj) end end
end

-- ----
-- LINEA KILLER: CONTORNO DE CONO REDONDEADO
-- ----
local KILLER_LINE_ANGLE = 50
local KILLER_LINE_RANGE = 20
local KILLER_LINE_SEGMENTS = 24
local KILLER_LINE_THICKNESS = 0.10
local function GetKillerLineFolder()
    if KillerLineFolder and KillerLineFolder.Parent then return KillerLineFolder end
    KillerLineFolder = workspace:FindFirstChild("PRL_KillerLine")
    if not KillerLineFolder then
        KillerLineFolder = Instance.new("Folder")
        KillerLineFolder.Name = "PRL_KillerLine"
        KillerLineFolder.Parent = workspace
    end
    return KillerLineFolder
end
local function GetLinePart(index)
    local folder = GetKillerLineFolder()
    local part = KillerLineParts[index]
    if not part or not part.Parent then
        part = Instance.new("Part")
        part.Name = "LineSegment" .. index
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255,215,0)
        part.Transparency = 0.12
        part.Size = Vector3.new(KILLER_LINE_THICKNESS, KILLER_LINE_THICKNESS, 1)
        part.Parent = folder
        KillerLineParts[index] = part
    end
    return part
end
local function PositionLinePart(index, p1, p2)
    local part = GetLinePart(index)
    local delta = p2 - p1
    local length = delta.Magnitude
    part.Size = Vector3.new(KILLER_LINE_THICKNESS, KILLER_LINE_THICKNESS, math.max(length, 0.05))
    part.CFrame = CFrame.lookAt((p1 + p2) / 2, p2)
    part.Transparency = 0.12
end
local function FindKillerRoot()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and IsKiller(target) then
            local character = target.Character
            local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))
            if root and root:IsA("BasePart") then return root, character end
        end
    end
    return nil, nil
end
local function GroundPoint(root, character)
    local origin = root.Position + Vector3.new(0, 2, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local hit = workspace:Raycast(origin, Vector3.new(0, -14, 0), params)
    if hit then return hit.Position + Vector3.new(0, 0.12, 0) end
    return root.Position - Vector3.new(0, 2.5, 0)
end
local function UpdateKillerLine()
    if ESPDead then return end
    if not ESP_CONFIG.KillerLine then
        if KillerLineFolder then KillerLineFolder:ClearAllChildren() end
        table.clear(KillerLineParts)
        return
    end
    local root, character = FindKillerRoot()
    if not root then
        if KillerLineFolder then KillerLineFolder:ClearAllChildren() end
        table.clear(KillerLineParts)
        return
    end
    local origin = GroundPoint(root, character)
    local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
    if look.Magnitude < 0.001 then return end
    look = look.Unit
    local right = Vector3.new(-look.Z, 0, look.X)
    local points = {}
    local halfAngle = math.rad(KILLER_LINE_ANGLE / 2)
    for i = 0, KILLER_LINE_SEGMENTS do
        local alpha = -halfAngle + (2 * halfAngle * i / KILLER_LINE_SEGMENTS)
        local direction = (look * math.cos(alpha) + right * math.sin(alpha)).Unit
        table.insert(points, origin + direction * KILLER_LINE_RANGE)
    end
    local count = 0
    for i = 1, #points - 1 do
        count += 1
        PositionLinePart(count, points[i], points[i + 1])
    end
    count += 1
    PositionLinePart(count, origin, points[1])
    count += 1
    PositionLinePart(count, origin, points[#points])
    for index = count + 1, #KillerLineParts do
        local part = KillerLineParts[index]
        if part then part:Destroy() end
        KillerLineParts[index] = nil
    end
end

-- INICIALIZACION Y EVENTOS GLOBALES
-- ----
for _, player in ipairs(Players:GetPlayers()) do
    WatchPlayer(player)
end
table.insert(GlobalConns, Players.PlayerAdded:Connect(function(player)
    WatchPlayer(player)
    task.delay(0.6, function()
        if not ESPDead and player.Parent == Players then
            ApplyPlayerESP(player)
            UpdateKillerWarnings()
        end
    end)
end))
table.insert(GlobalConns, Players.PlayerRemoving:Connect(function(player)
    DisconnectPlayer(player)
end))
table.insert(GlobalConns, RunService.Heartbeat:Connect(function(deltaTime)
    if not ESPDead then
        local worldOk, worldErr = pcall(UpdateWorldESP, deltaTime)
        if not worldOk then warn("[ProtoRun Lite] Error World Highlight:", worldErr) end
        local lineOk, lineErr = pcall(UpdateKillerLine)
        if not lineOk then
            warn("[ProtoRun Lite] Error Línea Killer:", lineErr)
        end
    end
    if not ESPDead and ESP_CONFIG.MasterESP and ESP_CONFIG.WarnKiller then
        local ok, err = pcall(UpdateKillerWarnings)
        if not ok then
            warn("[ProtoRun Lite] Error Killer Warning:", err)
        end
    end
end))
CreateVisualTab()
if ESP_CONFIG.MasterESP then
    RefreshAllPlayers()
    StartPlayerLoop()
end
print("[ProtoRun Lite ESP] Sistema iniciado correctamente.")
print("[ProtoRun Lite ESP] Usa el menu para activar o desactivar las funciones.")

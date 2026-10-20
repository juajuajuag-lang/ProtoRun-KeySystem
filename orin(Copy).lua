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
ProtoRunLite.MenuSize = UDim2.new(0, 320, 0, 380)
ProtoRunLite.MinSize = UDim2.new(0, 220, 0, 200)
ProtoRunLite.MaxSize = UDim2.new(0, 700, 0, 760)

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
    screenGui.DisplayOrder = 999
    
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if screenGui and screenGui.Parent then
                screenGui.IgnoreGuiInset = true
                screenGui.DisplayOrder = 999
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
    mainFrame.Size = ProtoRunLite.MenuSize
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
    resizeHandle.ZIndex = 52
    
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

-- ProtoRun Lite - Parte 3: Ventana Visual (ESP)
-- Lógica adaptada de KysHub a nuestro menú nativo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

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

local Colors = ProtoRunLite.Colors

-- ============================================================
-- PALETA DE 31 COLORES (orden fijo)
-- ============================================================
local ColorPalette = {
    [1]  = Color3.fromRGB(255, 255, 255),   -- 1. Blanco
    [2]  = Color3.fromRGB(150, 10, 10),     -- 2. Rojo Carmín
    [3]  = Color3.fromRGB(135, 206, 235),   -- 3. Azul Cielo
    [4]  = Color3.fromRGB(230, 255, 0),     -- 4. Amarillo Limón
    [5]  = Color3.fromRGB(80, 200, 120),    -- 5. Verde Esmeralda
    [6]  = Color3.fromRGB(0, 0, 0),         -- 6. Negro
    [7]  = Color3.fromRGB(255, 140, 0),     -- 7. Naranja Butano
    [8]  = Color3.fromRGB(75, 0, 130),      -- 8. Morado Oscuro
    [9]  = Color3.fromRGB(192, 192, 192),   -- 9. Plata
    [10] = Color3.fromRGB(180, 255, 0),     -- 10. Verde Lima
    [11] = Color3.fromRGB(255, 255, 255),   -- 11. Blanco
    [12] = Color3.fromRGB(0, 0, 128),       -- 12. Azul Marino
    [13] = Color3.fromRGB(255, 182, 193),   -- 13. Rosa Pastel
    [14] = Color3.fromRGB(101, 67, 33),     -- 14. Marrón Chocolate
    [15] = Color3.fromRGB(0, 255, 255),     -- 15. Cian
    [16] = Color3.fromRGB(225, 175, 0),     -- 16. Mostaza
    [17] = Color3.fromRGB(255, 0, 255),     -- 17. Magenta
    [18] = Color3.fromRGB(107, 142, 35),    -- 18. Verde Oliva
    [19] = Color3.fromRGB(255, 127, 80),    -- 19. Coral
    [20] = Color3.fromRGB(230, 230, 250),   -- 20. Lavanda
    [21] = Color3.fromRGB(255, 215, 0),     -- 21. Oro
    [22] = Color3.fromRGB(50, 50, 50),      -- 22. Gris Carbón
    [23] = Color3.fromRGB(64, 224, 208),    -- 23. Azul Turquesa
    [24] = Color3.fromRGB(204, 102, 0),     -- 24. Terracota
    [25] = Color3.fromRGB(255, 0, 180),     -- 25. Fucsia
    [26] = Color3.fromRGB(152, 255, 152),   -- 26. Verde Menta
    [27] = Color3.fromRGB(128, 0, 32),      -- 27. Burdeos
    [28] = Color3.fromRGB(245, 222, 179),   -- 28. Beige
    [29] = Color3.fromRGB(148, 0, 211),     -- 29. Violeta
    [30] = Color3.fromRGB(0, 204, 204),     -- 30. Acua
    [31] = Color3.fromRGB(250, 128, 114)    -- 31. Salmón
}

-- ============================================================
-- ESTADO ESP (adaptado de KYS_ESPState)
-- ============================================================
local ESPState = {
    PlayerMasterESP = false,
    WorldMasterESP = false,
    ESPFillTransparency = 0.95,
    ESPOutlineTransparency = 0.3,
    ESPTextSize = 12,
    SurvivorESP = false,
    KillerESP = false,
    SpectatorESP = false,
    SurvivorItemsESP = false,
    Nametags = false,
    DistanceESP = false,
    WarnKiller = false,
    SurvivorColor = ColorPalette[5],
    SurvivorWoundedColor = ColorPalette[2],
    SurvivorDownedColor = ColorPalette[6],
    KillerColor = ColorPalette[2],
    SpectatorColor = ColorPalette[1],
    SurvivorRainbow = false,
    KillerRainbow = false,
    SpectatorRainbow = false,
    SurvivorColorIndex = 5,
    SurvivorWoundedIndex = 2,
    SurvivorDownedIndex = 6,
    KillerColorIndex = 2,
    SpectatorColorIndex = 1,
    GeneratorESP = false,
    HookESP = false,
    GateESP = false,
    WindowESP = false,
    PalletESP = false,
    SCPZombieESP = false,
    WorldNametags = false,
    WorldDistanceESP = false,
    GeneratorPercent = false,
    GeneratorColor = ColorPalette[3],
    HookColor = ColorPalette[2],
    GateColor = ColorPalette[21],
    WindowColor = ColorPalette[1],
    PalletColor = ColorPalette[7],
    SCPZombieColor = ColorPalette[8],
    GeneratorColorIndex = 3,
    HookColorIndex = 2,
    GateColorIndex = 21,
    WindowColorIndex = 1,
    PalletColorIndex = 7,
    SCPZombieColorIndex = 8
}

-- ============================================================
-- REGISTRO DE OBJETOS DEL MUNDO
-- ============================================================
local WorldReg = {
    Generator = {}, Hook = {}, Gate = {},
    Window = {}, Pallet = {}, SCPZombie = {}
}
local ESPFolder = nil
local PlayerConns = {}
local MapConns = {}
local ESPDead = false

local function GetESPFolder()
    if ESPFolder and ESPFolder.Parent then return ESPFolder end
    local parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or Workspace
    local old = parent:FindFirstChild("ProtoRunLite_ESP")
    if old then old:Destroy() end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ProtoRunLite_ESP"
    ESPFolder.Parent = parent
    return ESPFolder
end

local function DestroyChild(name)
    local folder = GetESPFolder()
    local child = folder:FindFirstChild(name)
    if child then child:Destroy() end
end

local function PlayerKey(player)
    return tostring(player and player.UserId or 0)
end

local function GetRole(player)
    local teamName = player.Team and player.Team.Name and player.Team.Name:lower() or ""
    if teamName:find("killer") then return "Killer" end
    if teamName:find("survivor") then return "Survivor" end
    if teamName:find("spect") then return "Spectator" end
    return "Survivor"
end

local function GetPlayerColor(player)
    local role = GetRole(player)
    if role == "Killer" then
        return ESPState.KillerRainbow and Color3.fromHSV(tick() % 1, 1, 1) or ESPState.KillerColor
    end
    if role == "Spectator" then
        return ESPState.SpectatorRainbow and Color3.fromHSV(tick() % 1, 1, 1) or ESPState.SpectatorColor
    end
    return ESPState.SurvivorRainbow and Color3.fromHSV(tick() % 1, 1, 1) or ESPState.SurvivorColor
end

-- ============================================================
-- HIGHLIGHT ESP
-- ============================================================
local function EnsureHighlight(name, adornee, color, isPlayer)
    if not adornee then return nil end
    local folder = GetESPFolder()
    local hl = folder:FindFirstChild(name)
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = name
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = folder
    end
    hl.Adornee = adornee
    hl.FillColor = color
    hl.OutlineColor = color
    if isPlayer then
        hl.FillTransparency = ESPState.ESPFillTransparency
        hl.OutlineTransparency = ESPState.ESPOutlineTransparency
    else
        hl.FillTransparency = 0.98
        hl.OutlineTransparency = 0.5
    end
    hl.Enabled = true
    return hl
end

local function ClearPlayerESP(player)
    if not player or player == LocalPlayer then return end
    local key = PlayerKey(player)
    DestroyChild("PRL_PlayerHL_" .. key)
    DestroyChild("PRL_PlayerTag_" .. key)
end

local function UpdatePlayerTag(player, character, head, color)
    local key = PlayerKey(player)
    local tagName = "PRL_PlayerTag_" .. key
    if not head or not head.Parent then
        DestroyChild(tagName)
        return
    end
    local lines = {}
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
    local distanceText = ""
    if ESPState.DistanceESP and root and targetRoot then
        distanceText = "[" .. tostring(math.floor((root.Position - targetRoot.Position).Magnitude)) .. "m]"
    end
    local nameText = ESPState.Nametags and player.Name or ""
    local mainLine = ""
    if nameText ~= "" and distanceText ~= "" then
        mainLine = nameText .. " " .. distanceText
    elseif nameText ~= "" then
        mainLine = nameText
    elseif distanceText ~= "" then
        mainLine = distanceText
    end
    if mainLine == "" then
        DestroyChild(tagName)
        return
    end
    table.insert(lines, { Text = mainLine, Color = color })
    local folder = GetESPFolder()
    local tag = folder:FindFirstChild(tagName)
    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = tagName
        tag.AlwaysOnTop = true
        tag.LightInfluence = 0
        tag.MaxDistance = 0
        tag.Parent = folder
    end
    tag.Adornee = head
    tag.Enabled = true
    tag.Size = UDim2.new(0, 220, 0, #lines * 20)
    tag.StudsOffset = Vector3.new(0, 2.65, 0)
    for i, data in ipairs(lines) do
        local label = tag:FindFirstChild("Line" .. i)
        if not label then
            label = Instance.new("TextLabel")
            label.Name = "Line" .. i
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 0
            label.Font = Enum.Font.Gotham
            label.TextStrokeTransparency = 0.65
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.Parent = tag
        end
        label.Size = UDim2.new(1, 0, 1 / #lines, 0)
        label.Position = UDim2.new(0, 0, (i - 1) / #lines, 0)
        label.TextSize = ESPState.ESPTextSize
        label.TextColor3 = data.Color
        label.Text = data.Text
    end
end

local function ApplyPlayerESP(player)
    if ESPDead or not player or player == LocalPlayer then return end
    local character = player.Character
    if not character or not character.Parent then
        ClearPlayerESP(player)
        return
    end
    local key = PlayerKey(player)
    local role = GetRole(player)
    local enabled = ESPState.PlayerMasterESP
    if role == "Killer" then enabled = enabled and ESPState.KillerESP end
    if role == "Spectator" then enabled = enabled and ESPState.SpectatorESP end
    if role == "Survivor" then enabled = enabled and ESPState.SurvivorESP end
    if not enabled then
        ClearPlayerESP(player)
        return
    end
    local color = GetPlayerColor(player)
    local head = character:FindFirstChild("Head")
    EnsureHighlight("PRL_PlayerHL_" .. key, character, color, true)
    UpdatePlayerTag(player, character, head, color)
end

local function RefreshAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(ApplyPlayerESP, player)
        end
    end
end

local PlayerLoopThread = nil
local function StartPlayerLoop()
    if PlayerLoopThread then return end
    PlayerLoopThread = task.spawn(function()
        while not ESPDead and ESPState.PlayerMasterESP do
            RefreshAllPlayers()
            task.wait(0.25)
        end
        PlayerLoopThread = nil
    end)
end

local function WatchPlayer(player)
    if player == LocalPlayer then return end
    if PlayerConns[player] then
        for _, conn in ipairs(PlayerConns[player]) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
    end
    PlayerConns[player] = {}
    table.insert(PlayerConns[player], player.CharacterAdded:Connect(function()
        ClearPlayerESP(player)
        task.delay(0.15, function()
            if not ESPDead then pcall(ApplyPlayerESP, player) end
        end)
    end))
    table.insert(PlayerConns[player], player.CharacterRemoving:Connect(function()
        ClearPlayerESP(player)
    end))
    table.insert(PlayerConns[player], player:GetPropertyChangedSignal("Team"):Connect(function()
        ClearPlayerESP(player)
        pcall(ApplyPlayerESP, player)
    end))
    if player.Character then pcall(ApplyPlayerESP, player) end
end

local function UnwatchPlayer(player)
    ClearPlayerESP(player)
    if PlayerConns[player] then
        for _, conn in ipairs(PlayerConns[player]) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
    end
    PlayerConns[player] = nil
end

-- ============================================================
-- ESP DEL MUNDO
-- ============================================================
local function WorldKey(cat, model)
    return "PRL_World_" .. cat .. "_" .. tostring(model)
end

local function ClearWorldVisual(cat, model)
    if not model then return end
    DestroyChild(WorldKey(cat, model) .. "_HL")
    DestroyChild(WorldKey(cat, model) .. "_Tag")
    DestroyChild(WorldKey(cat, model) .. "_HL")
    DestroyChild(WorldKey(cat, model) .. "_Tag")
end

local function RemoveWorldEntry(cat, model)
    if not WorldReg[cat] or not WorldReg[cat][model] then return end
    ClearWorldVisual(cat, model)
    WorldReg[cat][model] = nil
end

local function PickWorldPart(model, cat)
    if not model or not model.Parent then return nil end
    if cat == "Generator" then
        local hitbox = model:FindFirstChild("HitBox", true) or model:FindFirstChild("GeneratorPoint", true)
        if hitbox and hitbox:IsA("BasePart") then return hitbox end
    elseif cat == "Pallet" then
        local candidates = {
            model:FindFirstChild("HumanoidRootPart", true),
            model:FindFirstChild("PalletPoint", true),
            model:FindFirstChild("PalletPointSlide", true)
        }
        for _, part in ipairs(candidates) do
            if part and part:IsA("BasePart") then return part end
        end
    elseif cat == "Window" then
        local vault = model:FindFirstChild("VaultPoint", true) or model:FindFirstChild("VaultTrigger", true)
        if vault and vault:IsA("BasePart") then return vault end
    elseif cat == "SCPZombie" then
        local root = model:FindFirstChild("HumanoidRootPart", true)
        if root and root:IsA("BasePart") then return root end
    end
    local part = model:FindFirstChildWhichIsA("BasePart", true)
    if part then return part end
    return nil
end

local function GeneratorLabel(model)
    local pct = tonumber(model:GetAttribute("RepairProgress")) or 0
    if pct >= 0 and pct <= 1.001 then pct = pct * 100 end
    pct = math.clamp(pct, 0, 100)
    local repairers = tonumber(model:GetAttribute("PlayersRepairingCount")) or 0
    local parts = { "Gen " .. tostring(math.floor(pct + 0.5)) .. "%" }
    if repairers > 0 then table.insert(parts, "(" .. repairers .. "p)") end
    return table.concat(parts, " ")
end

local function UpdateWorldTag(cat, model, part, color)
    local key = WorldKey(cat, model)
    local tagName = key .. "_Tag"
    if not part or not part.Parent then
        DestroyChild(tagName)
        return
    end
    local lines = {}
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distanceText = ""
    if ESPState.WorldDistanceESP and root then
        distanceText = "[" .. tostring(math.floor((root.Position - part.Position).Magnitude)) .. "m]"
    end
    local nameText = ""
    if ESPState.WorldNametags then
        if cat == "Generator" then
            nameText = ESPState.GeneratorPercent and GeneratorLabel(model) or "Generator"
        elseif cat == "Pallet" then
            nameText = "Pallet"
        elseif cat == "Window" then
            nameText = "Window"
        elseif cat == "SCPZombie" then
            nameText = model.Name
        else
            nameText = cat
        end
    end
    local mainLine = ""
    if nameText ~= "" and distanceText ~= "" then
        mainLine = nameText .. " " .. distanceText
    elseif nameText ~= "" then
        mainLine = nameText
    elseif distanceText ~= "" then
        mainLine = distanceText
    end
    if mainLine == "" then
        DestroyChild(tagName)
        return
    end
    table.insert(lines, { Text = mainLine, Color = color })
    local folder = GetESPFolder()
    local tag = folder:FindFirstChild(tagName)
    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = tagName
        tag.AlwaysOnTop = true
        tag.LightInfluence = 0
        tag.MaxDistance = 0
        tag.Parent = folder
    end
    tag.Adornee = part
    tag.Enabled = true
    tag.Size = UDim2.new(0, 220, 0, #lines * 20)
    tag.StudsOffset = Vector3.new(0, 2.5, 0)
    for i, data in ipairs(lines) do
        local label = tag:FindFirstChild("Line" .. i)
        if not label then
            label = Instance.new("TextLabel")
            label.Name = "Line" .. i
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 0
            label.Font = Enum.Font.Gotham
            label.TextStrokeTransparency = 0.65
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.Parent = tag
        end
        label.Size = UDim2.new(1, 0, 1 / #lines, 0)
        label.Position = UDim2.new(0, 0, (i - 1) / #lines, 0)
        label.TextSize = ESPState.ESPTextSize
        label.TextColor3 = data.Color
        label.Text = data.Text
    end
end

local function RegisterWorldDescendant(obj)
    if not obj or not obj.Parent then return end
    local validCats = { Generator = true, Hook = true, Gate = true, Window = true, Pallet = true }
    if obj:IsA("Model") then
        if validCats[obj.Name] then
            if not WorldReg[obj.Name][obj] then
                local part = PickWorldPart(obj, obj.Name)
                if part then WorldReg[obj.Name][obj] = { part = part } end
            end
            return
        end
        local lower = obj.Name:lower()
        if lower:find("scp") or lower:find("zombie") then
            if not WorldReg.SCPZombie[obj] then
                local part = PickWorldPart(obj, "SCPZombie")
                if part then WorldReg.SCPZombie[obj] = { part = part } end
            end
        end
    end
end

local function UnregisterWorldDescendant(obj)
    if not obj then return end
    local validCats = { Generator = true, Hook = true, Gate = true, Window = true, Pallet = true }
    if obj:IsA("Model") then
        if validCats[obj.Name] then RemoveWorldEntry(obj.Name, obj) end
        local lower = obj.Name:lower()
        if lower:find("scp") or lower:find("zombie") then RemoveWorldEntry("SCPZombie", obj) end
    end
end

local function AttachESPRoot(root)
    if not root or MapConns[root] then return end
    MapConns[root] = {
        root.DescendantAdded:Connect(RegisterWorldDescendant),
        root.DescendantRemoving:Connect(UnregisterWorldDescendant)
    }
    for _, descendant in ipairs(root:GetDescendants()) do
        RegisterWorldDescendant(descendant)
    end
end

local function RefreshESPRoots()
    for _, conns in pairs(MapConns) do
        for _, conn in ipairs(conns) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
    end
    MapConns = {}
    for cat, models in pairs(WorldReg) do
        for model in pairs(models) do
            ClearWorldVisual(cat, model)
        end
        WorldReg[cat] = {}
    end
    local map = Workspace:FindFirstChild("Map")
    local map1 = Workspace:FindFirstChild("Map1")
    if map then AttachESPRoot(map) end
    if map1 then AttachESPRoot(map1) end
end

local WorldLoopThread = nil
local function AnyWorldEnabled()
    return ESPState.WorldMasterESP and (
        ESPState.GeneratorESP or ESPState.HookESP or ESPState.GateESP or
        ESPState.WindowESP or ESPState.PalletESP or ESPState.SCPZombieESP
    )
end

local function StartWorldLoop()
    if WorldLoopThread then return end
    WorldLoopThread = task.spawn(function()
        while not ESPDead and AnyWorldEnabled() do
            for cat, models in pairs(WorldReg) do
                local enabled = ESPState.WorldMasterESP
                if cat == "Generator" then enabled = enabled and ESPState.GeneratorESP end
                if cat == "Hook" then enabled = enabled and ESPState.HookESP end
                if cat == "Gate" then enabled = enabled and ESPState.GateESP end
                if cat == "Window" then enabled = enabled and ESPState.WindowESP end
                if cat == "Pallet" then enabled = enabled and ESPState.PalletESP end
                if cat == "SCPZombie" then enabled = enabled and ESPState.SCPZombieESP end
                local color
                if cat == "Generator" then color = ESPState.GeneratorColor
                elseif cat == "Hook" then color = ESPState.HookColor
                elseif cat == "Gate" then color = ESPState.GateColor
                elseif cat == "Window" then color = ESPState.WindowColor
                elseif cat == "Pallet" then color = ESPState.PalletColor
                elseif cat == "SCPZombie" then color = ESPState.SCPZombieColor
                else color = Color3.new(1, 1, 1) end
                if enabled then
                    for model, entry in pairs(models) do
                        if model and model.Parent then
                            local part = entry.part
                            if not part or not part.Parent or not part:IsDescendantOf(model) then
                                entry.part = PickWorldPart(model, cat)
                                part = entry.part
                            end
                            if part and part.Parent then
                                EnsureHighlight(WorldKey(cat, model) .. "_HL", model, color, false)
                                UpdateWorldTag(cat, model, part, color)
                            else
                                RemoveWorldEntry(cat, model)
                            end
                        else
                            RemoveWorldEntry(cat, model)
                        end
                    end
                else
                    for model in pairs(models) do
                        ClearWorldVisual(cat, model)
                    end
                end
            end
            task.wait(0.25)
        end
        WorldLoopThread = nil
    end)
end

local function ClearAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then ClearPlayerESP(player) end
    end
    for cat, models in pairs(WorldReg) do
        for model in pairs(models) do
            ClearWorldVisual(cat, model)
        end
    end
end

-- ============================================================
-- UI HELPERS: Desplegables, Toggles, Sliders con círculo
-- ============================================================
local VisualContent = nil
local ActiveSlider = nil

local function CreateToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 30)
    frame.BackgroundColor3 = Colors.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.75, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Colors.Text
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 22)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Colors.Accent or Colors.Button
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = default and Colors.Background or Colors.TextDim
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local state = { Value = default }
    toggleBtn.MouseButton1Click:Connect(function()
        state.Value = not state.Value
        toggleBtn.BackgroundColor3 = state.Value and Colors.Accent or Colors.Button
        toggleBtn.Text = state.Value and "ON" or "OFF"
        toggleBtn.TextColor3 = state.Value and Colors.Background or Colors.TextDim
        if callback then callback(state.Value) end
    end)
    return state
end

local function CreateSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 50)
    frame.BackgroundColor3 = Colors.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 3)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Colors.Text
    label.TextSize = 11
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 25)
    track.BackgroundColor3 = Colors.Slider
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Colors.Accent
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = { Value = default }
    local dragging = false

    local function update(input)
        local trackAbs = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local relative = (input.Position.X - trackAbs) / trackSize
        relative = math.clamp(relative, 0, 1)
        local value = math.floor(min + relative * (max - min) + 0.5)
        value = math.clamp(value, min, max)
        state.Value = value
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        knob.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
        label.Text = name .. ": " .. tostring(value)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            ActiveSlider = state
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if ActiveSlider == state and dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                update(input)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            if ActiveSlider == state then
                dragging = false
                ActiveSlider = nil
            end
        end
    end)

    return state
end

local function CreateDropdown(parent, name, items, defaultOpen)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -5, 0, defaultOpen and 0 or 30)
    container.BackgroundColor3 = Colors.Panel
    container.BorderSizePixel = 0
    container.AutomaticSize = defaultOpen and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Colors.Button
    header.BorderSizePixel = 0
    header.Text = (defaultOpen and "▲ " or "▼ ") .. name
    header.TextColor3 = Colors.Accent
    header.TextSize = 13
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = container
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -10, 0, 0)
    content.Position = UDim2.new(0, 5, 0, 32)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Visible = defaultOpen or false
    content.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = content

    local state = { Open = defaultOpen or false }

    header.MouseButton1Click:Connect(function()
        state.Open = not state.Open
        header.Text = (state.Open and "▲ " or "▼ ") .. name
        content.Visible = state.Open
        container.AutomaticSize = state.Open and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
    end)

    return content
end

-- ============================================================
-- CREAR CONTENIDO DE LA PESTAÑA VISUAL
-- ============================================================
local function CreateVisualContent()
    local scrollFrame = ProtoRunLite.ContentScroll
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

    -- 1. HIGHLIGHT ESP SETTINGS
    local settingsDrop = CreateDropdown(visual, "Highlight ESP Settings", {}, false)
    CreateSlider(settingsDrop, "Transparencia Relleno ESP", 0, 100, 95, function(v)
        ESPState.ESPFillTransparency = v / 100
        RefreshAllPlayers()
    end)
    CreateSlider(settingsDrop, "Transparencia Contorno ESP", 0, 100, 30, function(v)
        ESPState.ESPOutlineTransparency = v / 100
        RefreshAllPlayers()
    end)
    CreateSlider(settingsDrop, "Tamaño Texto ESP", 8, 22, 12, function(v)
        ESPState.ESPTextSize = v
        RefreshAllPlayers()
    end)

    -- 2. PLAYER HIGHLIGHT ESP
    local playerDrop = CreateDropdown(visual, "Player Highlight ESP", {}, false)
    CreateToggle(playerDrop, "Activar ESP de jugadores", false, function(v)
        ESPState.PlayerMasterESP = v
        if v then
            StartPlayerLoop()
            RefreshAllPlayers()
        else
            ClearAllESP()
        end
    end)
    CreateToggle(playerDrop, "ESP SURVIVOR", false, function(v)
        ESPState.SurvivorESP = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateToggle(playerDrop, "ESP KILLER", false, function(v)
        ESPState.KillerESP = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateToggle(playerDrop, "ESP ITEM SURVIVOR", false, function(v)
        ESPState.SurvivorItemsESP = v
    end)
    CreateToggle(playerDrop, "ESP ESPECTATOR", false, function(v)
        ESPState.SpectatorESP = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateToggle(playerDrop, "Nametags de jugadores", false, function(v)
        ESPState.Nametags = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateToggle(playerDrop, "Distancia ESP de jugadores", false, function(v)
        ESPState.DistanceESP = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateToggle(playerDrop, "Advertencia Killer en Survivor (!)", false, function(v)
        ESPState.WarnKiller = v
    end)

    -- 3. COLORES PLAYERS
    local colorsDrop = CreateDropdown(visual, "Colores players", {}, false)
    CreateToggle(colorsDrop, "Color Survivor Rainbow", false, function(v)
        ESPState.SurvivorRainbow = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateSlider(colorsDrop, "Slider Survivor Color Normal", 1, 31, 5, function(v)
        ESPState.SurvivorColorIndex = v
        ESPState.SurvivorColor = ColorPalette[v]
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateSlider(colorsDrop, "Slider Survivor Color Herido", 1, 31, 2, function(v)
        ESPState.SurvivorWoundedIndex = v
        ESPState.SurvivorWoundedColor = ColorPalette[v]
    end)
    CreateSlider(colorsDrop, "Slider Survivor Color Derribado", 1, 31, 6, function(v)
        ESPState.SurvivorDownedIndex = v
        ESPState.SurvivorDownedColor = ColorPalette[v]
    end)
    CreateToggle(colorsDrop, "Color Killer Rainbow", false, function(v)
        ESPState.KillerRainbow = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateSlider(colorsDrop, "Slider Color Killer", 1, 31, 2, function(v)
        ESPState.KillerColorIndex = v
        ESPState.KillerColor = ColorPalette[v]
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateToggle(colorsDrop, "Color Spectator Rainbow", false, function(v)
        ESPState.SpectatorRainbow = v
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)
    CreateSlider(colorsDrop, "Slider Color Spectator", 1, 31, 1, function(v)
        ESPState.SpectatorColorIndex = v
        ESPState.SpectatorColor = ColorPalette[v]
        if ESPState.PlayerMasterESP then RefreshAllPlayers() end
    end)

    -- 4. WORLD HIGHLIGHT ESP
    local worldDrop = CreateDropdown(visual, "World Highlight ESP", {}, false)
    CreateToggle(worldDrop, "Activar ESP del mundo", false, function(v)
        ESPState.WorldMasterESP = v
        if v then
            RefreshESPRoots()
            if AnyWorldEnabled() then StartWorldLoop() end
        else
            ClearAllESP()
        end
    end)
    CreateToggle(worldDrop, "Generators", false, function(v)
        ESPState.GeneratorESP = v
        if ESPState.WorldMasterESP and AnyWorldEnabled() then StartWorldLoop() else ClearAllESP() end
    end)
    CreateToggle(worldDrop, "Hooks", false, function(v)
        ESPState.HookESP = v
        if ESPState.WorldMasterESP and AnyWorldEnabled() then StartWorldLoop() else ClearAllESP() end
    end)
    CreateToggle(worldDrop, "Gates", false, function(v)
        ESPState.GateESP = v
        if ESPState.WorldMasterESP and AnyWorldEnabled() then StartWorldLoop() else ClearAllESP() end
    end)
    CreateToggle(worldDrop, "Windows", false, function(v)
        ESPState.WindowESP = v
        if ESPState.WorldMasterESP and AnyWorldEnabled() then StartWorldLoop() else ClearAllESP() end
    end)
    CreateToggle(worldDrop, "Pallets", false, function(v)
        ESPState.PalletESP = v
        if ESPState.WorldMasterESP and AnyWorldEnabled() then StartWorldLoop() else ClearAllESP() end
    end)
    CreateToggle(worldDrop, "SCP/Zombie", false, function(v)
        ESPState.SCPZombieESP = v
        if ESPState.WorldMasterESP and AnyWorldEnabled() then StartWorldLoop() else ClearAllESP() end
    end)
    CreateToggle(worldDrop, "Nametags del mundo", false, function(v)
        ESPState.WorldNametags = v
    end)
    CreateToggle(worldDrop, "Distancia ESP del mundo", false, function(v)
        ESPState.WorldDistanceESP = v
    end)
    CreateToggle(worldDrop, "Porcentaje del generator", false, function(v)
        ESPState.GeneratorPercent = v
    end)

    -- 5. COLORES MUNDO
    local worldColorsDrop = CreateDropdown(visual, "Colores World ESP", {}, false)
    CreateSlider(worldColorsDrop, "Slider Color Generator", 1, 31, 3, function(v)
        ESPState.GeneratorColorIndex = v
        ESPState.GeneratorColor = ColorPalette[v]
    end)
    CreateSlider(worldColorsDrop, "Slider Color Hook", 1, 31, 2, function(v)
        ESPState.HookColorIndex = v
        ESPState.HookColor = ColorPalette[v]
    end)
    CreateSlider(worldColorsDrop, "Slider Color Gate", 1, 31, 21, function(v)
        ESPState.GateColorIndex = v
        ESPState.GateColor = ColorPalette[v]
    end)
    CreateSlider(worldColorsDrop, "Slider Color Window", 1, 31, 1, function(v)
        ESPState.WindowColorIndex = v
        ESPState.WindowColor = ColorPalette[v]
    end)
    CreateSlider(worldColorsDrop, "Slider Color Pallet", 1, 31, 7, function(v)
        ESPState.PalletColorIndex = v
        ESPState.PalletColor = ColorPalette[v]
    end)
    CreateSlider(worldColorsDrop, "Slider Color SCP/Zombie", 1, 31, 8, function(v)
        ESPState.SCPZombieColorIndex = v
        ESPState.SCPZombieColor = ColorPalette[v]
    end)

    return visual
end

-- ============================================================
-- INICIALIZAR Y CONECTAR EVENTOS
-- ============================================================
local function InitializeVisual()
    local visualContent = CreateVisualContent()
    ProtoRunLite.VisualContent = visualContent

    -- Conectar jugadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        WatchPlayer(player)
    end

    table.insert(ProtoRunLite.Connections or {}, Players.PlayerAdded:Connect(WatchPlayer))
    table.insert(ProtoRunLite.Connections or {}, Players.PlayerRemoving:Connect(UnwatchPlayer))
    table.insert(ProtoRunLite.Connections or {}, Workspace.ChildAdded:Connect(function(child)
        if child.Name == "Map" or child.Name == "Map1" then
            AttachESPRoot(child)
            if ESPState.WorldMasterESP and AnyWorldEnabled() then StartWorldLoop() end
        end
    end))
    table.insert(ProtoRunLite.Connections or {}, Workspace.ChildRemoved:Connect(function(child)
        if child.Name == "Map" or child.Name == "Map1" then
            RefreshESPRoots()
        end
    end))

    RefreshESPRoots()

    -- Cleanup al destruir
    ProtoRunLite.CleanupESP = function()
        ESPDead = true
        ClearAllESP()
        if ESPFolder and ESPFolder.Parent then ESPFolder:Destroy() end
    end

    print("[ProtoRun Lite] ✓ Ventana Visual ESP creada")
    return visualContent
end

-- Ejecutar
if ProtoRunLite.ContentScroll then
    InitializeVisual()
end
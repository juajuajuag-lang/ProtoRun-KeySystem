-- ProtoRun Lite - World ESP Optimizado
-- PARTE 1/3: Configuracion y visuales
-- ----
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
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
    ScanInterval = math.huge,
    UpdateInterval = 0.5,
    WindowColorIndex = 6
}
local Palette = {
    Color3.fromRGB(255,65,65), Color3.fromRGB(255,130,50),
    Color3.fromRGB(255,210,55), Color3.fromRGB(170,255,65),
    Color3.fromRGB(65,255,100), Color3.fromRGB(50,255,190),
    Color3.fromRGB(50,220,255), Color3.fromRGB(65,145,255),
    Color3.fromRGB(100,90,255), Color3.fromRGB(165,75,255),
    Color3.fromRGB(220,70,255), Color3.fromRGB(255,75,190),
    Color3.fromRGB(255,255,255), Color3.fromRGB(210,210,210),
    Color3.fromRGB(150,150,150), Color3.fromRGB(90,90,90),
    Color3.fromRGB(255,100,100), Color3.fromRGB(255,175,100),
    Color3.fromRGB(255,240,120), Color3.fromRGB(180,255,140),
    Color3.fromRGB(120,255,180), Color3.fromRGB(120,255,230),
    Color3.fromRGB(120,220,255), Color3.fromRGB(130,180,255),
    Color3.fromRGB(155,145,255), Color3.fromRGB(195,140,255),
    Color3.fromRGB(235,140,255), Color3.fromRGB(255,140,220),
    Color3.fromRGB(255,190,190), Color3.fromRGB(190,255,190),
    Color3.fromRGB(190,220,255)
}
local CategoryInfo = {
    Generator = {Label="Generator",Color=Color3.fromRGB(65,255,100)},
    Hook = {Label="Hook",Color=Color3.fromRGB(255,65,65)},
    Gate = {Label="Gate",Color=Color3.fromRGB(255,210,55)},
    Window = {Label="Window",Color=Palette[6]},
    Pallet = {Label="Pallet",Color=Color3.fromRGB(50,220,255)},
    SCPZombie = {Label="SCP / Zombie",Color=Color3.fromRGB(220,70,255)}
}
local Registry = {
    Generator={}, Hook={}, Gate={}, Window={}, Pallet={}, SCPZombie={}
}
local Connections = {}
local Running = true
local ScreenGui
local MainFrame
local StatusLabel
local ToggleButtons = {}
local UpdateAccumulator = 0
local PendingInstances = {}
local WindowVisualFolder
local NameRules = {
    Generator={"generator","genmachine","genspawn","repairmachine"},
    Hook={"hook","meathook","sacrificehook","survivorhook","hanginghook"},
    Gate={"gate","exitgate","escapegate","exitdoor"},
    Window={},
    Pallet={"pallet","woodenpallet","woodpallet","palletspawn"},
    SCPZombie={"scp","zombie","infected","monster","killer","creature"}
}
local HookExactNames = {}
for _, name in ipairs(NameRules.Hook) do
    HookExactNames[name] = true
end
-- ---- Utilidades
local function SafeName(instance)
    if not instance then return "" end
    local ok, name = pcall(function() return instance.Name end)
    if not ok then return "" end
    return string.lower(tostring(name)):gsub("[%s_%-]","")
end
local function IsAlive(instance)
    return instance ~= nil and instance.Parent ~= nil
        and instance:IsDescendantOf(Workspace)
end
-- ---- Obtener una parte representativa de Window
-- Evitar VaultPoint y VaultTrigger: pueden estar desplazados
-- y no representar el marco visible de la ventana.
local function GetWindowPart(model)
    if not model or not model:IsA("Model") then return nil end
    local primary = model.PrimaryPart
    if primary and primary:IsA("BasePart") then
        local name = SafeName(primary)
        if name ~= "vaultpoint" and name ~= "vaulttrigger" then
            return primary
        end
    end
    local descendants = model:GetDescendants()
    local preferred = {
        "windowframe","frame","windowpart","window",
        "vaultframe","framepart"
    }
    for _, preferredName in ipairs(preferred) do
        for _, item in ipairs(descendants) do
            if item:IsA("BasePart")
                and SafeName(item) == preferredName then
                return item
            end
        end
    end
    for _, item in ipairs(descendants) do
        if item:IsA("BasePart") then
            local name = SafeName(item)
            if name ~= "vaultpoint"
                and name ~= "vaulttrigger" then
                return item
            end
        end
    end
    return primary
end
local function GetRootPart(instance)
    if not instance then return nil end
    if instance:IsA("Model") and instance.Name == "Window" then
        return GetWindowPart(instance)
    end
    if instance:IsA("BasePart") then return instance end
    if instance:IsA("Model") then
        return instance.PrimaryPart
            or instance:FindFirstChildWhichIsA("BasePart",true)
    end
    return instance:FindFirstChildWhichIsA("BasePart",true)
end
local function GetPosition(instance)
    local part = GetRootPart(instance)
    return part and part.Position or nil
end
local function GetDistance(instance)
    local position = GetPosition(instance)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not position or not root then return nil end
    return (position-root.Position).Magnitude
end
local function GetColor(category)
    if category == "Window" then
        return Palette[math.clamp(Config.WindowColorIndex,1,#Palette)]
    end
    return CategoryInfo[category].Color
end
local function IsEnabled(category)
    return Config.Master and Config[category] == true
end
local function GetDisplayName(instance)
    return instance.Name:gsub("_"," "):gsub("(%l)(%u)","%1 %2")
end
-- ---- Deteccion
local function NameMatches(name,category)
    if category == "Hook" then return HookExactNames[name] == true end
    if category == "Window" then return false end
    for _, pattern in ipairs(NameRules[category]) do
        if string.find(name,pattern,1,true) then return true end
    end
    return false
end
local function DetectCategory(instance)
    if not instance then return nil end
    if instance:IsA("Model") and instance.Name == "Window" then
        return "Window"
    end
    local name = SafeName(instance)
    if name == "" then return nil end
    for _, category in ipairs({
        "Generator","Hook","Gate","Pallet","SCPZombie"
    }) do
        if NameMatches(name,category) then return category end
    end
    return nil
end
local function GetCandidate(instance)
    local current = instance
    local steps = 0
    while current and current ~= Workspace and steps < 8 do
        if current:IsA("Model") or current:IsA("Folder") then
            local category = DetectCategory(current)
            if category then return current,category end
        end
        current = current.Parent
        steps += 1
    end
    local category = DetectCategory(instance)
    if category then return instance,category end
    return nil,nil
end
-- ---- Carpeta de adornos locales
local function GetWindowVisualFolder()
    if WindowVisualFolder and WindowVisualFolder.Parent then
        return WindowVisualFolder
    end
    local parent
    pcall(function()
        if gethui then parent = gethui() end
    end)
    if not parent then parent = PlayerGui end
    local old = parent:FindFirstChild("ProtoRunWindowVisuals")
    if old then old:Destroy() end
    WindowVisualFolder = Instance.new("Folder")
    WindowVisualFolder.Name = "ProtoRunWindowVisuals"
    WindowVisualFolder.Parent = parent
    return WindowVisualFolder
end
local function DestroyAdornment(adornment)
    if adornment then pcall(function() adornment:Destroy() end) end
end
-- ---- Caja inferior de Window
local function ensureBox(entry,part,color)
    if not entry or not part or not part:IsA("BasePart") then return end
    local box = entry.WindowBox
    if not box or not box.Parent then
        box = Instance.new("BoxHandleAdornment")
        box.Name = "ProtoRunWindowBottom"
        box.Adornee = part
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.18
        box.Parent = GetWindowVisualFolder()
        entry.WindowBox = box
    end
    box.Adornee = part
    box.Color3 = color
    box.Size = Vector3.new(
        math.max(part.Size.X,0.05),
        math.max(part.Size.Y*0.32,0.05),
        math.max(part.Size.Z,0.05)
    )
    box.CFrame = CFrame.new(0,-part.Size.Y*0.34,0)
    box.Visible = true
end
-- ---- Bordes inferiores de Window
local function ensureWire(entry,part,color)
    if not entry or not part or not part:IsA("BasePart") then return end
    entry.WindowEdges = entry.WindowEdges or {}
    local sx = math.max(part.Size.X,0.05)
    local sy = math.max(part.Size.Y*0.32,0.05)
    local sz = math.max(part.Size.Z,0.05)
    local y = -part.Size.Y*0.34
    local tx = math.max(sx*0.018,0.025)
    local ty = math.max(sy*0.018,0.025)
    local tz = math.max(sz*0.018,0.025)
    local specs = {
        {Vector3.new(sx,ty,tz),Vector3.new(0,y-sy/2,-sz/2)},
        {Vector3.new(sx,ty,tz),Vector3.new(0,y-sy/2,sz/2)},
        {Vector3.new(sx,ty,tz),Vector3.new(0,y+sy/2,-sz/2)},
        {Vector3.new(sx,ty,tz),Vector3.new(0,y+sy/2,sz/2)},
        {Vector3.new(tx,sy,tz),Vector3.new(-sx/2,y,-sz/2)},
        {Vector3.new(tx,sy,tz),Vector3.new(sx/2,y,-sz/2)},
        {Vector3.new(tx,sy,tz),Vector3.new(-sx/2,y,sz/2)},
        {Vector3.new(tx,sy,tz),Vector3.new(sx/2,y,sz/2)},
        {Vector3.new(tx,ty,sz),Vector3.new(-sx/2,y-sy/2,0)},
        {Vector3.new(tx,ty,sz),Vector3.new(sx/2,y-sy/2,0)},
        {Vector3.new(tx,ty,sz),Vector3.new(-sx/2,y+sy/2,0)},
        {Vector3.new(tx,ty,sz),Vector3.new(sx/2,y+sy/2,0)}
    }
    local folder = GetWindowVisualFolder()
    for index,spec in ipairs(specs) do
        local edge = entry.WindowEdges[index]
        if not edge or not edge.Parent then
            edge = Instance.new("BoxHandleAdornment")
            edge.Name = "ProtoRunWindowEdge"..index
            edge.Adornee = part
            edge.AlwaysOnTop = true
            edge.ZIndex = 6
            edge.Transparency = 0
            edge.Parent = folder
            entry.WindowEdges[index] = edge
        end
        edge.Adornee = part
        edge.Color3 = color
        edge.Size = spec[1]
        edge.CFrame = CFrame.new(spec[2])
        edge.Visible = true
    end
end
local function HideWindowVisuals(entry)
    if entry.WindowBox then entry.WindowBox.Visible = false end
    for _, edge in ipairs(entry.WindowEdges or {}) do
        if edge then edge.Visible = false end
    end
end
local function DestroyVisuals(entry)
    if not entry then return end
    if entry.Highlight then
        pcall(function() entry.Highlight:Destroy() end)
        entry.Highlight = nil
    end
    if entry.Billboard then
        pcall(function() entry.Billboard:Destroy() end)
        entry.Billboard = nil
    end
    DestroyAdornment(entry.WindowBox)
    entry.WindowBox = nil
    for _, edge in ipairs(entry.WindowEdges or {}) do
        DestroyAdornment(edge)
    end
    entry.WindowEdges = {}
end
local function UnregisterObject(instance,category)
    local objects = Registry[category]
    if not objects then return end
    local entry = objects[instance]
    if entry then
        DestroyVisuals(entry)
        objects[instance] = nil
    end
end

-- ProtoRun Lite - World ESP Optimizado
-- PARTE 2/3: Registro y actualizacion
-- ----
local function CreateHighlight(instance,category)
    if category == "Window" then return nil end
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
local function CreateBillboard(instance,category)
    local part = GetRootPart(instance)
    if not part then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ProtoRunWorldTag"
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(170,38)
    billboard.StudsOffset = Vector3.new(0,2.3,0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = IsEnabled(category) and Config.Nametags
    billboard.MaxDistance = Config.MaxDistance
    billboard.Parent = PlayerGui
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextColor3 = GetColor(category)
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextStrokeTransparency = 0.2
    label.TextWrapped = true
    label.Text = CategoryInfo[category].Label
    label.Parent = billboard
    return billboard
end
-- ---- Registrar objetos una sola vez
local function RegisterObject(instance,category)
    if not instance or not category or not Registry[category] then return end
    if not IsAlive(instance) or Registry[category][instance] then return end
    if category == "Window" then
        if not instance:IsA("Model") or instance.Name ~= "Window" then
            return
        end
        if not GetWindowPart(instance) then return end
    elseif not GetRootPart(instance) then
        return
    end
    local entry = {
        Instance=instance, Category=category,
        Highlight=nil, Billboard=nil, WindowBox=nil,
        WindowEdges={}, CachedWindowPart=nil,
        CachedWindowSize=nil, CachedWindowColor=nil,
        CachedLabelText=nil, CachedPercent=nil,
        PercentRefresh=0
    }
    local okHighlight,highlight = pcall(CreateHighlight,instance,category)
    if okHighlight then entry.Highlight = highlight end
    local okBillboard,billboard = pcall(CreateBillboard,instance,category)
    if okBillboard then entry.Billboard = billboard end
    Registry[category][instance] = entry
end
-- ---- Raices del mapa
local function GetMapRoots()
    local roots = {}
    local map = Workspace:FindFirstChild("Map")
    local map1 = Workspace:FindFirstChild("Map1")
    if map then table.insert(roots,map) end
    if map1 and map1 ~= map then table.insert(roots,map1) end
    if #roots == 0 then table.insert(roots,Workspace) end
    return roots
end
-- ---- Escaneo inicial de ventanas
local function scanWindows()
    if not Running then return end
    local found = {}
    local roots = {}
    local map = Workspace:FindFirstChild("Map")
    local map1 = Workspace:FindFirstChild("Map1")
    if map then table.insert(roots,map) end
    if map1 and map1 ~= map then table.insert(roots,map1) end
    local function inspect(root)
        if not root then return end
        if root:IsA("Model") and root.Name == "Window" then
            found[root] = true
            RegisterObject(root,"Window")
        end
        for _, item in ipairs(root:GetDescendants()) do
            if not Running then return end
            if item:IsA("Model") and item.Name == "Window" then
                found[item] = true
                RegisterObject(item,"Window")
            end
        end
    end
    for _, root in ipairs(roots) do inspect(root) end
    if #roots == 0 then inspect(Workspace) end
    for instance in pairs(Registry.Window) do
        if not found[instance] or not IsAlive(instance) then
            UnregisterObject(instance,"Window")
        end
    end
end
local function ScanInstance(instance)
    if not instance or not IsAlive(instance) then return end
    if not (instance:IsA("Model") or instance:IsA("Folder")
        or instance:IsA("BasePart")) then return end
    local candidate,category = GetCandidate(instance)
    if candidate and category then RegisterObject(candidate,category) end
end
local function ScanWorld()
    if not Running then return end
    for _, root in ipairs(GetMapRoots()) do
        ScanInstance(root)
        for _, item in ipairs(root:GetDescendants()) do
            if not Running then return end
            ScanInstance(item)
        end
    end
    scanWindows()
end
-- ---- Porcentaje del generador
local function GetGeneratorPercent(instance)
    local names = {
        "RepairProgress","GeneratorProgress","Progress",
        "RepairPercentage","Percent"
    }
    for _, name in ipairs(names) do
        local value = instance:GetAttribute(name)
        if typeof(value) == "number" then
            if value >= 0 and value <= 1 then value *= 100 end
            return math.clamp(math.floor(value+0.5),0,100)
        end
    end
    for _, child in ipairs(instance:GetDescendants()) do
        local name = SafeName(child)
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            if string.find(name,"progress",1,true)
                or string.find(name,"repair",1,true)
                or string.find(name,"percent",1,true) then
                local value = child.Value
                if value >= 0 and value <= 1 then value *= 100 end
                return math.clamp(math.floor(value+0.5),0,100)
            end
        end
        for _, attributeName in ipairs(names) do
            local value = child:GetAttribute(attributeName)
            if typeof(value) == "number" then
                if value >= 0 and value <= 1 then value *= 100 end
                return math.clamp(math.floor(value+0.5),0,100)
            end
        end
    end
    return nil
end
-- ---- Actualizacion optimizada de Window
local function updateSafe(entry)
    local instance = entry.Instance
    if not IsAlive(instance) or not instance:IsA("Model")
        or instance.Name ~= "Window" then return false end
    local part = GetWindowPart(instance)
    if not part then
        HideWindowVisuals(entry)
        return true
    end
    local distance = GetDistance(instance)
    local inRange = distance == nil or distance <= Config.MaxDistance
    local enabled = IsEnabled("Window") and inRange
    local color = GetColor("Window")
    if not enabled then
        HideWindowVisuals(entry)
    else
        local size = part.Size
        local changed = entry.CachedWindowPart ~= part
            or entry.CachedWindowSize ~= size
            or entry.CachedWindowColor ~= color
        if changed then
            ensureBox(entry,part,color)
            ensureWire(entry,part,color)
            entry.CachedWindowPart = part
            entry.CachedWindowSize = size
            entry.CachedWindowColor = color
        else
            if entry.WindowBox then entry.WindowBox.Visible = true end
            for _, edge in ipairs(entry.WindowEdges or {}) do
                if edge then edge.Visible = true end
            end
        end
    end
    if entry.Billboard then
        entry.Billboard.Adornee = part
        entry.Billboard.Enabled = enabled and Config.Nametags
        entry.Billboard.MaxDistance = Config.MaxDistance
        local label = entry.Billboard:FindFirstChild("Label")
        if label then
            label.TextColor3 = color
            local text = "Window"
            if Config.Distance and distance then
                text ..= "\n"..tostring(math.floor(distance+0.5))
                    .." studs"
            end
            if label.Text ~= text then label.Text = text end
        end
    end
    return true
end
-- ---- Actualizar un objeto
local function UpdateEntry(entry)
    local instance = entry.Instance
    local category = entry.Category
    if not IsAlive(instance) then return false end
    if category == "Window" then return updateSafe(entry) end
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
                local now = os.clock()
                if now >= entry.PercentRefresh then
                    entry.CachedPercent = GetGeneratorPercent(instance)
                    entry.PercentRefresh = now+2
                end
                if entry.CachedPercent ~= nil then
                    text ..= "\nRepair: "..tostring(entry.CachedPercent).."%"
                end
            end
            if Config.Distance and distance then
                text ..= "\n"..tostring(math.floor(distance+0.5))
                    .." studs"
            end
            if label.Text ~= text then label.Text = text end
        end
    end
    return true
end
local function UpdateAll()
    local total,active = 0,0
    for category,objects in pairs(Registry) do
        for instance,entry in pairs(objects) do
            local success,result = pcall(UpdateEntry,entry)
            if not success or result == false then
                UnregisterObject(instance,category)
            else
                total += 1
                if IsEnabled(category) then active += 1 end
            end
        end
    end
    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = string.format(
            "Objetos: %d | Activos: %d",total,active)
    end
end

-- ProtoRun Lite - World ESP Optimizado
-- PARTE 3/3: Menu, conexiones e inicio
-- ----
local function CreateCorner(parent,radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,radius or 5)
    corner.Parent = parent
end
local function CreateButton(parent,text,height)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,height or 29)
    button.BackgroundColor3 = Color3.fromRGB(45,48,60)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Color3.new(1,1,1)
    button.TextSize = 12
    button.Parent = parent
    CreateCorner(button,5)
    return button
end
local function CreateLabel(parent,text,height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,height or 22)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(225,225,235)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end
local function RefreshToggle(category)
    local button = ToggleButtons[category]
    if not button then return end
    local enabled = Config[category]
    button.Text = CategoryInfo[category].Label..": "
        ..(enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(35,115,75)
        or Color3.fromRGB(95,50,55)
end
-- ---- Cierre y limpieza
local function Shutdown()
    if not Running then return end
    Running = false
    for _, connection in ipairs(Connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(Connections)
    table.clear(PendingInstances)
    for category,objects in pairs(Registry) do
        for instance,entry in pairs(objects) do
            DestroyVisuals(entry)
            objects[instance] = nil
        end
    end
    if WindowVisualFolder then
        pcall(function() WindowVisualFolder:Destroy() end)
        WindowVisualFolder = nil
    end
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
end
-- ---- Menu ProtoRun Lite
local function CreateTestUI()
    local old = PlayerGui:FindFirstChild("ProtoRunWorldESP")
    if old then old:Destroy() end
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ProtoRunWorldESP"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.fromOffset(230,420)
    MainFrame.Position = UDim2.new(0,18,0.5,-210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24,26,33)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    CreateCorner(MainFrame,8)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,36)
    header.BackgroundColor3 = Color3.fromRGB(38,44,57)
    header.BorderSizePixel = 0
    header.Parent = MainFrame
    CreateCorner(header,8)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-70,1,0)
    title.Position = UDim2.fromOffset(9,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "PROTO RUN | WORLD ESP"
    title.TextSize = 11
    title.TextColor3 = Color3.new(1,1,1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.fromOffset(27,25)
    minimize.Position = UDim2.new(1,-59,0,5)
    minimize.Text = "-"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 15
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.BackgroundColor3 = Color3.fromRGB(65,75,95)
    minimize.Parent = header
    CreateCorner(minimize,4)
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(27,25)
    close.Position = UDim2.new(1,-30,0,5)
    close.Text = "X"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 12
    close.TextColor3 = Color3.new(1,1,1)
    close.BackgroundColor3 = Color3.fromRGB(145,50,58)
    close.Parent = header
    CreateCorner(close,4)
    local content = Instance.new("ScrollingFrame")
    content.Position = UDim2.fromOffset(9,43)
    content.Size = UDim2.new(1,-18,1,-52)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.Parent = MainFrame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    CreateLabel(content,"CONTROL GENERAL",20)
    local master = CreateButton(content,"MASTER ESP: ON",30)
    master.Activated:Connect(function()
        Config.Master = not Config.Master
        master.Text = "MASTER ESP: "
            ..(Config.Master and "ON" or "OFF")
        master.BackgroundColor3 = Config.Master
            and Color3.fromRGB(35,115,75)
            or Color3.fromRGB(95,50,55)
    end)
    CreateLabel(content,"CATEGORIAS",20)
    for _,category in ipairs({
        "Generator","Hook","Gate","Window","Pallet","SCPZombie"
    }) do
        local button = CreateButton(content,category,29)
        ToggleButtons[category] = button
        RefreshToggle(category)
        button.Activated:Connect(function()
            Config[category] = not Config[category]
            RefreshToggle(category)
        end)
    end
    CreateLabel(content,"OPCIONES",20)
    local tags = CreateButton(content,"Etiquetas: ON",29)
    tags.Activated:Connect(function()
        Config.Nametags = not Config.Nametags
        tags.Text = "Etiquetas: "
            ..(Config.Nametags and "ON" or "OFF")
    end)
    local distance = CreateButton(content,"Distancia: ON",29)
    distance.Activated:Connect(function()
        Config.Distance = not Config.Distance
        distance.Text = "Distancia: "
            ..(Config.Distance and "ON" or "OFF")
    end)
    local percent = CreateButton(content,"Porcentaje generador: ON",29)
    percent.Activated:Connect(function()
        Config.GeneratorPercent = not Config.GeneratorPercent
        percent.Text = "Porcentaje generador: "
            ..(Config.GeneratorPercent and "ON" or "OFF")
    end)
    local color = CreateButton(content,"Color ventana: 6/31",29)
    color.Activated:Connect(function()
        Config.WindowColorIndex = Config.WindowColorIndex%#Palette+1
        color.Text = string.format(
            "Color ventana: %d/31",Config.WindowColorIndex)
    end)
    local range = CreateButton(content,"Rango: 2500 studs",29)
    range.Activated:Connect(function()
        local ranges = {500,1000,1500,2500}
        local index = 1
        for i,value in ipairs(ranges) do
            if value == Config.MaxDistance then
                index = i
                break
            end
        end
        index = index%#ranges+1
        Config.MaxDistance = ranges[index]
        range.Text = "Rango: "..Config.MaxDistance.." studs"
    end)
    StatusLabel = CreateLabel(content,"Objetos: 0 | Activos: 0",22)
    local minimized = false
    minimize.Activated:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        MainFrame.Size = minimized
            and UDim2.fromOffset(230,36)
            or UDim2.fromOffset(230,420)
        minimize.Text = minimized and "+" or "-"
    end)
    close.Activated:Connect(Shutdown)
    -- Arrastre con raton o pantalla tactil
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
                    if endConnection then endConnection:Disconnect() end
                end
            end)
        end
    end)
    table.insert(Connections,UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position-dragStart
            MainFrame.Position = UDim2.new(
                startPosition.X.Scale,startPosition.X.Offset+delta.X,
                startPosition.Y.Scale,startPosition.Y.Offset+delta.Y
            )
        end
    end))
end
-- ---- Registrar objetos agregados al mapa sin reescanearlo completo
table.insert(Connections,Workspace.DescendantAdded:Connect(function(instance)
    if not Running or PendingInstances[instance] then return end
    PendingInstances[instance] = true
    task.delay(0.15,function()
        PendingInstances[instance] = nil
        if not Running or not IsAlive(instance) then return end
        local current = instance
        while current and current ~= Workspace do
            if current:IsA("Model") and current.Name == "Window" then
                pcall(RegisterObject,current,"Window")
                return
            end
            current = current.Parent
        end
        pcall(ScanInstance,instance)
    end)
end))
-- ---- Retirar registros eliminados
table.insert(Connections,Workspace.DescendantRemoving:Connect(function(instance)
    for category,objects in pairs(Registry) do
        for registered in pairs(objects) do
            if registered == instance then
                UnregisterObject(registered,category)
            else
                local ok,descendant = pcall(function()
                    return registered:IsDescendantOf(instance)
                end)
                if ok and descendant then
                    UnregisterObject(registered,category)
                end
            end
        end
    end
end))
-- ---- Ciclo visual sin escaneo repetido
table.insert(Connections,RunService.Heartbeat:Connect(function(deltaTime)
    if not Running then return end
    UpdateAccumulator += deltaTime
    if UpdateAccumulator >= Config.UpdateInterval then
        UpdateAccumulator = 0
        pcall(UpdateAll)
    end
end))
-- ---- Inicio
CreateTestUI()
ScanWorld()
UpdateAll()
print("[ProtoRun Lite] World ESP optimizado iniciado.")
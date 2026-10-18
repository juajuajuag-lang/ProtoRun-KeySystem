--[[
  Menu simple VD — Visual / Movimiento / Superviviente / Asesino
  - Botón flotante abrir/cerrar (arrastrable)
  - Menú arrastrable
  - (−) oculta todo  |  (X) destruye todo
  - Protección cinemáticas (No Cutscene)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local function parentGui()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	return CoreGui
end

pcall(function()
	local p = parentGui()
	if p:FindFirstChild("VDSimpleMenu") then p.VDSimpleMenu:Destroy() end
	if p:FindFirstChild("VDSimpleOpenBtn") then p.VDSimpleOpenBtn:Destroy() end
end)

-- ===================== STATE =====================
local S = {
	-- ESP settings
	FillT = 0.95, OutlineT = 0.3, TextSize = 12,
	-- Player ESP
	PlayerESP = false,
	P_Surv = false, P_Item = false, P_Killer = false, P_Spec = false,
	Nametags = false, DistP = false, KillerWarn = false,
	ColSurv = Color3.fromRGB(0,255,0), ColSurvHurt = Color3.fromRGB(255,200,0),
	ColSurvDown = Color3.fromRGB(255,80,80), ColKiller = Color3.fromRGB(255,0,0),
	ColSpec = Color3.fromRGB(255,255,255),
	RainbowSurv = false, RainbowKiller = false, RainbowSpec = false,
	-- World ESP
	WorldESP = false,
	W_Gen = false, W_Hook = false, W_Gate = false, W_Win = false, W_Pal = false, W_SCP = false,
	NametagsW = false, GenPct = false, DistW = false,
	ColGen = Color3.fromRGB(0,170,255), ColHook = Color3.fromRGB(255,0,0),
	ColGate = Color3.fromRGB(255,225,0), ColWin = Color3.fromRGB(255,255,255),
	ColPal = Color3.fromRGB(255,140,0), ColSCP = Color3.fromRGB(128,0,128),
	-- Lighting
	NoCutscene = false, NoFog = false, Fullbright = false,
	-- Info
	KystKiller = false, SpecCounter = false, KillerPerks = false, PredictMap = false,
	HideSurvIcon = false, PingFPS = false, HookCounter = false,
	-- Camera
	FOVOn = false, FOV = 90, ThirdP = false, ShiftLock = false, InfZoom = false,
	-- Movement / survivor combat
	SwiftVault = false, SwiftVaultV2 = false, VaultSpeed = 1,
	AntiKnock = false, AuraSelf = false, AuraAll = false, FPCam = false,
	ParryDist = 10, FakeGen = false, FakeGenLock = false,
	-- Fake perks
	FP_CD = 10, Flowstate = false, QuickRec = false, PerfectLand = false, Adrenaline = false,
	-- Automation
	AutoSC = false, HideSCUI = false, SCMode = "Normal", GenBypass = false,
	-- Aimbot
	Aimbot = false, AimRMB = false, AimFOVShow = false, AimVis = false, AimPred = false,
	AimFOV = 150, AimSmooth = 5,
	-- Crosshair
	XHOn = false, XHStyle = "Cross", XHColor = Color3.new(1,1,1),
	XHSize = 10, XHThick = 2, XHGap = 4, XHX = 0, XHY = 0,
	-- ToF
	ToF = false, ToFLaser = false, ToFWall = false, ToFKnock = false,
	ToFMode = "Killer", ToFKey = "E",
	-- Flashlight
	FLAim = false, FLLaser = false, FLRange = 100, FLSmooth = 5, FLPart = "Head",
	-- Killer abilities
	InfAbyss = false, InfHidden = false, InfFrenzy = false, InfLake = false,
	InfPursuit = false, InfGrab = false, FakeAtk = false, InfGrabLock = false,
	-- Killer util
	AutoAtk = false, AtkRange = 12, Hitbox = false, HitboxSize = 15, InfLunge = false,
	AutoHook = false, DestPal = false, AutoKick = false, BlockVault = false,
	AutoDropPal = false, BreakPal = false, AntiBlind = false, NoPalStun = false,
	NoSlow = false, BeatKiller = false, TargetLock = false, TLDist = 50, TLLockBtn = false,
	-- Spear
	SpearAim = false, SpearKey = "Q", SilentSpear = false, SpearFOVShow = true,
	SpearLaser = true, SpearFOV = 150, SpearPred = false, SpearSpeed = 165,
	SpearGrav = 50, SpearH = 1, SpearPart = "Torso",
	-- Flask
	SilentFlask = false, FlaskLaser = false,
}

local origLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart or 0,
	GlobalShadows = Lighting.GlobalShadows,
	OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- ===================== ESP FOLDER =====================
local espFolder
local function getFolder()
	if espFolder and espFolder.Parent then return espFolder end
	espFolder = Instance.new("Folder")
	espFolder.Name = "VDSimpleESP"
	pcall(function() espFolder.Parent = CoreGui end)
	if not espFolder.Parent then espFolder.Parent = LP:WaitForChild("PlayerGui") end
	return espFolder
end

local function clearChild(name)
	local f = getFolder()
	local c = f:FindFirstChild(name)
	if c then c:Destroy() end
end

local function roleOf(plr)
	local t = plr.Team and plr.Team.Name and plr.Team.Name:lower() or ""
	if t:find("killer") then return "Killer" end
	if t:find("spect") then return "Spectator" end
	return "Survivor"
end

local function rainbow(t)
	return Color3.fromHSV((t % 5) / 5, 1, 1)
end

local function playerColor(plr, t)
	local r = roleOf(plr)
	if r == "Killer" then
		return S.RainbowKiller and rainbow(t) or S.ColKiller
	elseif r == "Spectator" then
		return S.RainbowSpec and rainbow(t) or S.ColSpec
	else
		if S.RainbowSurv then return rainbow(t) end
		local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			if hum.Health <= 0 then return S.ColSurvDown end
			if hum.Health < hum.MaxHealth * 0.5 then return S.ColSurvHurt end
		end
		return S.ColSurv
	end
end

local function roleEnabled(plr)
	local r = roleOf(plr)
	if r == "Killer" then return S.P_Killer end
	if r == "Spectator" then return S.P_Spec end
	return S.P_Surv
end

local function ensureHL(name, adornee, color, isPlayer)
	if not (adornee and adornee.Parent) then return end
	local f = getFolder()
	local hl = f:FindFirstChild(name)
	if not hl then
		hl = Instance.new("Highlight")
		hl.Name = name
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = f
	end
	hl.Adornee = adornee
	hl.FillColor = color
	hl.OutlineColor = color
	if isPlayer then
		hl.FillTransparency = S.FillT
		hl.OutlineTransparency = S.OutlineT
	else
		hl.FillTransparency = 0.98
		hl.OutlineTransparency = 0.5
	end
	hl.Enabled = true
end

local function updatePlayerESP()
	local f = getFolder()
	local t = tick()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LP then continue end
		local key = tostring(plr.UserId)
		local char = plr.Character
		if not (S.PlayerESP and roleEnabled(plr) and char) then
			clearChild("PHL_" .. key)
			clearChild("PTAG_" .. key)
			clearChild("PITEM_" .. key)
			continue
		end
		local col = playerColor(plr, t)
		ensureHL("PHL_" .. key, char, col, true)
		local head = char:FindFirstChild("Head")
		if head and (S.Nametags or S.DistP) then
			local tag = f:FindFirstChild("PTAG_" .. key)
			if not tag then
				tag = Instance.new("BillboardGui")
				tag.Name = "PTAG_" .. key
				tag.AlwaysOnTop = true
				tag.Size = UDim2.fromOffset(200, 20)
				tag.StudsOffset = Vector3.new(0, 2.6, 0)
				tag.Parent = f
				local lab = Instance.new("TextLabel")
				lab.Name = "L"
				lab.BackgroundTransparency = 1
				lab.Size = UDim2.fromScale(1, 1)
				lab.Font = Enum.Font.Gotham
				lab.TextStrokeTransparency = 0.5
				lab.Parent = tag
			end
			tag.Adornee = head
			local lab = tag:FindFirstChild("L")
			local parts = {}
			if S.Nametags then table.insert(parts, plr.Name) end
			if S.DistP then
				local a = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
				local b = char:FindFirstChild("HumanoidRootPart")
				if a and b then
					table.insert(parts, "[" .. math.floor((a.Position - b.Position).Magnitude) .. "m]")
				end
			end
			if lab then
				lab.Text = table.concat(parts, " ")
				lab.TextColor3 = col
				lab.TextSize = S.TextSize
			end
		else
			clearChild("PTAG_" .. key)
		end
	end
end

local worldReg = { Generator = {}, Hook = {}, Gate = {}, Window = {}, Palletwrong = {}, SCPZombie = {} }

local function classifyName(n)
	if n == "Generator" or n == "Hook" or n == "Gate" or n == "Window" or n == "Palletwrong" then
		return n
	end
	local l = n:lower()
	if l:find("scp") or l:find("zombie") then return "SCPZombie" end
	return nil
end

local function scanWorld()
	for k in pairs(worldReg) do worldReg[k] = {} end
	local function consider(model)
		if not model:IsA("Model") then return end
		local cat = classifyName(model.Name)
		if cat then
			local part = model:FindFirstChildWhichIsA("BasePart", true)
			if part then worldReg[cat][model] = part end
		end
	end
	for _, rootName in ipairs({ "Map", "Map1" }) do
		local root = Workspace:FindFirstChild(rootName)
		if root then
			for _, d in ipairs(root:GetDescendants()) do
				if d:IsA("Model") then consider(d) end
			end
		end
	end
end

local function worldEnabled(cat)
	if cat == "Generator" then return S.W_Gen end
	if cat == "Hook" then return S.W_Hook end
	if cat == "Gate" then return S.W_Gate end
	if cat == "Window" then return S.W_Win end
	if cat == "Palletwrong" then return S.W_Pal end
	if cat == "SCPZombie" then return S.W_SCP end
	return false
end

local function worldColor(cat)
	if cat == "Generator" then return S.ColGen end
	if cat == "Hook" then return S.ColHook end
	if cat == "Gate" then return S.ColGate end
	if cat == "Window" then return S.ColWin end
	if cat == "Palletwrong" then return S.ColPal end
	return S.ColSCP
end

local function updateWorldESP()
	if not S.WorldESP then
		for _, c in ipairs(getFolder():GetChildren()) do
			if c.Name:find("^WHL_") or c.Name:find("^WTAG_") then c:Destroy() end
		end
		return
	end
	local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for cat, models in pairs(worldReg) do
		local on = worldEnabled(cat)
		local col = worldColor(cat)
		for model, part in pairs(models) do
			local id = tostring(model:GetDebugId())
			if on and model.Parent and part and part.Parent then
				ensureHL("WHL_" .. id, model, col, false)
				if S.NametagsW or S.DistW or (S.GenPct and cat == "Generator") then
					local f = getFolder()
					local tag = f:FindFirstChild("WTAG_" .. id)
					if not tag then
						tag = Instance.new("BillboardGui")
						tag.Name = "WTAG_" .. id
						tag.AlwaysOnTop = true
						tag.Size = UDim2.fromOffset(160, 18)
						tag.StudsOffset = Vector3.new(0, 2.2, 0)
						tag.Parent = f
						local lab = Instance.new("TextLabel")
						lab.Name = "L"
						lab.BackgroundTransparency = 1
						lab.Size = UDim2.fromScale(1, 1)
						lab.Font = Enum.Font.Gotham
						lab.TextSize = S.TextSize
						lab.TextStrokeTransparency = 0.5
						lab.Parent = tag
					end
					tag.Adornee = part
					local bits = {}
					if S.NametagsW then
						local n = cat == "Palletwrong" and "Pallet" or cat
						table.insert(bits, n)
					end
					if S.GenPct and cat == "Generator" then
						local p = model:GetAttribute("RepairProgress") or model:GetAttribute("ProgressRepair")
						if p then table.insert(bits, tostring(math.floor(tonumber(p) * 100)) .. "%") end
					end
					if S.DistW and my then
						table.insert(bits, "[" .. math.floor((my.Position - part.Position).Magnitude) .. "m]")
					end
					local lab = tag:FindFirstChild("L")
					if lab then lab.Text = table.concat(bits, " ") lab.TextColor3 = col end
				else
					clearChild("WTAG_" .. id)
				end
			else
				clearChild("WHL_" .. id)
				clearChild("WTAG_" .. id)
			end
		end
	end
end

local worldScanT = 0
RunService.RenderStepped:Connect(function(dt)
	if S.PlayerESP then updatePlayerESP() end
	worldScanT = worldScanT + dt
	if S.WorldESP then
		if worldScanT > 2 then worldScanT = 0 scanWorld() end
		updateWorldESP()
	end
	-- Fullbright / fog
	if S.Fullbright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.FogStart = 0
		Lighting.FogEnd = 100000
	elseif not S.NoFog then
		-- leave
	end
	if S.NoFog then
		Lighting.FogStart = 0
		Lighting.FogEnd = 100000
	end
	-- Camera
	local cam = Workspace.CurrentCamera
	if cam and S.FOVOn then
		cam.FieldOfView = S.FOV
	end
	if S.ShiftLock then
		local char = LP.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if root and cam then
			if hum then hum.AutoRotate = false end
			local look = cam.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			if flat.Magnitude > 0.05 then
				root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit)
			end
		end
	end
	if S.InfZoom then
		LP.CameraMaxZoomDistance = math.huge
		LP.CameraMinZoomDistance = 0
	end
end)

-- No cutscene
task.spawn(function()
	local gameFolder = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Game")
	if not gameFolder then return end
	local function skip()
		if not S.NoCutscene then return end
		pcall(function()
			local cam = Workspace.CurrentCamera
			if cam then cam.CameraType = Enum.CameraType.Custom end
			UIS.MouseIconEnabled = true
			LP:SetAttribute("isspectating", true)
			local pg = LP:FindFirstChild("PlayerGui")
			if pg then
				for _, n in ipairs({ "Results", "EndScreen" }) do
					local g = pg:FindFirstChild(n)
					if g then g.Enabled = true end
				end
			end
		end)
	end
	for _, n in ipairs({ "endscreencutscene", "cutsceneEnd", "cutsceneEnd2", "cutsceneEndwithownchar" }) do
		local ev = gameFolder:FindFirstChild(n)
		if ev and ev:IsA("RemoteEvent") then
			ev.OnClientEvent:Connect(skip)
		end
	end
end)

-- ===================== UI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "VDSimpleMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = parentGui()

local openBtn = Instance.new("TextButton")
openBtn.Name = "VDSimpleOpenBtn"
openBtn.Size = UDim2.fromOffset(52, 52)
openBtn.Position = UDim2.new(0, 16, 0.5, -26)
openBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
openBtn.Text = "VD"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.fromOffset(340, 480)
menu.Position = UDim2.new(0, 80, 0.5, -240)
menu.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 36)
top.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
top.BorderSizePixel = 0
top.Parent = menu
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "VD Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local btnHide = Instance.new("TextButton")
btnHide.Size = UDim2.fromOffset(28, 28)
btnHide.Position = UDim2.new(1, -64, 0.5, -14)
btnHide.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
btnHide.Text = "—"
btnHide.TextColor3 = Color3.new(1, 1, 1)
btnHide.Font = Enum.Font.GothamBold
btnHide.TextSize = 16
btnHide.Parent = top
Instance.new("UICorner", btnHide).CornerRadius = UDim.new(0, 6)

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.fromOffset(28, 28)
btnClose.Position = UDim2.new(1, -32, 0.5, -14)
btnClose.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
btnClose.Text = "X"
btnClose.TextColor3 = Color3.new(1, 1, 1)
btnHide.Font = Enum.Font.GothamBold
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 14
btnClose.Parent = top
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)

-- tabs
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -12, 0, 30)
tabBar.Position = UDim2.fromOffset(6, 40)
tabBar.BackgroundTransparency = 1
tabBar.Parent = menu

local pages = {}
local tabNames = { "Visual", "Movimiento", "Superviviente", "Asesino" }
local currentTab = "Visual"

local function makeDraggable(handle, target)
	local dragging, start, pos
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			start = i.Position
			pos = target.Position
		end
	end)
	handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - start
			target.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
		end
	end)
end
makeDraggable(top, menu)
makeDraggable(openBtn, openBtn)

local function showPage(name)
	currentTab = name
	for n, p in pairs(pages) do
		p.Visible = (n == name)
	end
	for _, b in ipairs(tabBar:GetChildren()) do
		if b:IsA("TextButton") then
			b.BackgroundColor3 = (b.Name == name) and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(40, 42, 55)
		end
	end
end

for i, name in ipairs(tabNames) do
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.new(0.25, -4, 1, 0)
	b.Position = UDim2.new((i - 1) * 0.25, 2, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
	b.Text = name
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 11
	b.Parent = tabBar
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.MouseButton1Click:Connect(function() showPage(name) end)

	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. name
	page.Size = UDim2.new(1, -12, 1, -80)
	page.Position = UDim2.fromOffset(6, 74)
	page.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 5
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = (name == "Visual")
	page.Parent = menu
	Instance.new("UICorner", page).CornerRadius = UDim.new(0, 6)
	local lay = Instance.new("UIListLayout")
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 4)
	lay.Parent = page
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = page
	pages[name] = page
end
showPage("Visual")

local order = 0
local function nextOrder()
	order = order + 1
	return order
end

local function section(page, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -4, 0, 22)
	l.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
	l.Text = "  " .. text
	l.TextColor3 = Color3.fromRGB(255, 200, 80)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = nextOrder()
	l.Parent = page
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
end

local function toggle(page, text, key, onChange)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 28)
	b.BackgroundColor3 = S[key] and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(45, 48, 60)
	b.Text = text .. (S[key] and "  ON" or "  OFF")
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.LayoutOrder = nextOrder()
	b.Parent = page
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.MouseButton1Click:Connect(function()
		S[key] = not S[key]
		b.Text = text .. (S[key] and "  ON" or "  OFF")
		b.BackgroundColor3 = S[key] and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(45, 48, 60)
		if onChange then onChange(S[key]) end
		if key == "WorldESP" and S.WorldESP then scanWorld() end
		if key == "PlayerESP" and not S.PlayerESP then
			for _, c in ipairs(getFolder():GetChildren()) do
				if c.Name:find("^PHL_") or c.Name:find("^PTAG_") then c:Destroy() end
			end
		end
	end)
	return b
end

local function slider(page, text, key, min, max, isInt)
	local hold = Instance.new("Frame")
	hold.Size = UDim2.new(1, -4, 0, 40)
	hold.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
	hold.LayoutOrder = nextOrder()
	hold.Parent = page
	Instance.new("UICorner", hold).CornerRadius = UDim.new(0, 4)
	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(1, -10, 0, 18)
	lab.Position = UDim2.fromOffset(6, 2)
	lab.BackgroundTransparency = 1
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 11
	lab.TextColor3 = Color3.new(1, 1, 1)
	lab.Parent = hold
	local function refresh()
		local v = S[key]
		lab.Text = text .. ": " .. (isInt and tostring(math.floor(v)) or string.format("%.2f", v))
	end
	refresh()
	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -12, 0, 12)
	bar.Position = UDim2.fromOffset(6, 22)
	bar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	bar.Text = ""
	bar.Parent = hold
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((S[key] - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
	local function setFromX(x)
		local rel = math.clamp(x / bar.AbsoluteSize.X, 0, 1)
		local v = min + rel * (max - min)
		if isInt then v = math.floor(v + 0.5) end
		S[key] = v
		fill.Size = UDim2.new(rel, 0, 1, 0)
		refresh()
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			setFromX(i.Position.X - bar.AbsolutePosition.X)
		end
	end)
	bar.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or #UIS:GetTouches() > 0 then
				setFromX(i.Position.X - bar.AbsolutePosition.X)
			end
		end
	end)
end

local function multiDrop(page, titleText, options, keys)
	local open = false
	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, -4, 0, 28)
	header.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
	header.Text = titleText .. " ▼"
	header.TextColor3 = Color3.new(1, 1, 1)
	header.Font = Enum.Font.Gotham
	header.TextSize = 12
	header.LayoutOrder = nextOrder()
	header.Parent = page
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, -4, 0, #options * 28)
	box.BackgroundColor3 = Color3.fromRGB(32, 34, 45)
	box.Visible = false
	box.LayoutOrder = nextOrder()
	box.Parent = page
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
	local lay = Instance.new("UIListLayout")
	lay.Parent = box
	header.MouseButton1Click:Connect(function()
		open = not open
		box.Visible = open
		header.Text = titleText .. (open and " ▲" or " ▼")
	end)
	for i, opt in ipairs(options) do
		local key = keys[i]
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 0, 28)
		b.BackgroundColor3 = S[key] and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(45, 48, 60)
		b.Text = opt
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.Gotham
		b.TextSize = 12
		b.Parent = box
		b.MouseButton1Click:Connect(function()
			S[key] = not S[key]
			b.BackgroundColor3 = S[key] and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(45, 48, 60)
			if S.WorldESP then scanWorld() end
		end)
	end
end

local function dropdown(page, titleText, key, values)
	local idx = 1
	for i, v in ipairs(values) do
		if v == S[key] then idx = i break end
	end
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 28)
	b.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
	b.Text = titleText .. ": " .. tostring(S[key])
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.LayoutOrder = nextOrder()
	b.Parent = page
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.MouseButton1Click:Connect(function()
		idx = idx % #values + 1
		S[key] = values[idx]
		b.Text = titleText .. ": " .. tostring(S[key])
	end)
end

-- ========== VISUAL ==========
local V = pages.Visual
section(V, "Highlight ESP Settings")
slider(V, "Transparencia relleno ESP", "FillT", 0, 1, false)
slider(V, "Transparencia contorno ESP", "OutlineT", 0, 1, false)
slider(V, "Tamaño texto ESP", "TextSize", 8, 24, true)

section(V, "Player Highlight ESP")
toggle(V, "Activar ESP de jugadores", "PlayerESP")
multiDrop(V, "Seleccionar ESP de jugadores", {
	"Sobreviviente", "Item de Superviviente", "Asesino", "Espectador"
}, { "P_Surv", "P_Item", "P_Killer", "P_Spec" })
toggle(V, "Nametags de jugadores", "Nametags")
toggle(V, "Distancia ESP de jugadores", "DistP")
toggle(V, "Advertencia Killer en Superviviente (!)", "KillerWarn")
toggle(V, "Color Survivor Rainbow", "RainbowSurv")
toggle(V, "Color Killer Rainbow", "RainbowKiller")
toggle(V, "Color Spectator Rainbow", "RainbowSpec")

section(V, "World Highlight ESP")
toggle(V, "Activar ESP del mundo", "WorldESP", function(v) if v then scanWorld() end end)
multiDrop(V, "Seleccionar objetos del mundo", {
	"Generators", "Hooks", "Gates", "Windows", "Pallets", "SCP/Zombie"
}, { "W_Gen", "W_Hook", "W_Gate", "W_Win", "W_Pal", "W_SCP" })
toggle(V, "Nametags del mundo", "NametagsW")
toggle(V, "Porcentaje del generador", "GenPct")
toggle(V, "Distancia ESP del mundo", "DistW")

section(V, "Lighting")
toggle(V, "Sin cutscene", "NoCutscene")
toggle(V, "Sin niebla", "NoFog")
toggle(V, "Fullbright", "Fullbright", function(v)
	if not v then
		Lighting.Brightness = origLighting.Brightness
		Lighting.ClockTime = origLighting.ClockTime
		Lighting.FogEnd = origLighting.FogEnd
		Lighting.FogStart = origLighting.FogStart
		Lighting.GlobalShadows = origLighting.GlobalShadows
		Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
	end
end)

section(V, "Game Info Panel")
toggle(V, "Display Kyst Killer", "KystKiller")
toggle(V, "Contador de espectadores", "SpecCounter")
toggle(V, "Mostrar perks del Killer", "KillerPerks")
toggle(V, "Predecir mapa", "PredictMap")
toggle(V, "Ocultar icono de Survivor", "HideSurvIcon")
toggle(V, "Mostrar Ping y FPS", "PingFPS")
toggle(V, "Mostrar contador de hooks", "HookCounter")

section(V, "Cámara")
toggle(V, "Activar override FOV", "FOVOn")
slider(V, "FOV de cámara", "FOV", 30, 140, true)
toggle(V, "Tercera persona (solo Killer)", "ThirdP")
toggle(V, "Shift Lock", "ShiftLock")
toggle(V, "Zoom infinito", "InfZoom", function(v)
	if v then LP.CameraMaxZoomDistance = math.huge LP.CameraMinZoomDistance = 0
	else LP.CameraMaxZoomDistance = 128 LP.CameraMinZoomDistance = 0.5 end
end)

-- ========== MOVIMIENTO ==========
order = 0
local M = pages.Movimiento
section(M, "Combat / utilidades survivor")
toggle(M, "Swift Vault", "SwiftVault")
toggle(M, "Swift Vault V2", "SwiftVaultV2")
slider(M, "Velocidad de vault", "VaultSpeed", 1, 5, false)
toggle(M, "Anti Knock", "AntiKnock")
toggle(M, "Aura Heal (Self)", "AuraSelf")
toggle(M, "Aura Heal All", "AuraAll")
toggle(M, "Cámara 1ª persona (Survivor)", "FPCam")
slider(M, "Distancia trigger parry", "ParryDist", 1, 30, true)
toggle(M, "Fake Generator (B)", "FakeGen")
toggle(M, "Botón no arrastrable (Fake Gen)", "FakeGenLock")

section(M, "Fake Perks")
slider(M, "Cooldown (todas las perks)", "FP_CD", 1, 60, true)
toggle(M, "Flowstate", "Flowstate")
toggle(M, "Quick Recovery", "QuickRec")
toggle(M, "Perfect Landing", "PerfectLand")
toggle(M, "Adrenaline Rush", "Adrenaline")

section(M, "Automation")
toggle(M, "Auto Skillcheck", "AutoSC")
toggle(M, "Ocultar UI de skillcheck", "HideSCUI")
dropdown(M, "Modo skillcheck", "SCMode", { "Normal", "Perfect", "Instant" })
toggle(M, "Boost Gen Bypass", "GenBypass")

-- ========== SUPERVIVIENTE ==========
order = 0
local Su = pages.Superviviente
section(Su, "Aimbot")
toggle(Su, "Activar Aimbot", "Aimbot")
toggle(Su, "Usar RMB para apuntar", "AimRMB")
toggle(Su, "Mostrar círculo FOV", "AimFOVShow")
toggle(Su, "Visibility Check", "AimVis")
toggle(Su, "Prediction", "AimPred")
slider(Su, "Tamaño FOV", "AimFOV", 50, 500, true)
slider(Su, "Suavidad (Speed Aim)", "AimSmooth", 1, 20, true)

section(Su, "Advanced Crosshair")
toggle(Su, "Activar crosshair", "XHOn")
dropdown(Su, "Estilo crosshair", "XHStyle", { "Cross", "Dot", "Circle" })
slider(Su, "Tamaño crosshair", "XHSize", 4, 40, true)
slider(Su, "Grosor crosshair", "XHThick", 1, 8, true)
slider(Su, "Gap crosshair", "XHGap", 0, 20, true)
slider(Su, "Offset X", "XHX", -50, 50, true)
slider(Su, "Offset Y", "XHY", -50, 50, true)

section(Su, "Silent Aim Twist Of Fate")
toggle(Su, "Silent Aim Twist Of Fate", "ToF")
toggle(Su, "ToF Laser", "ToFLaser")
toggle(Su, "ToF Wall Check", "ToFWall")
toggle(Su, "ToF Block When Knocked", "ToFKnock")
dropdown(Su, "Modo objetivo ToF", "ToFMode", { "Killer", "Survivors", "Zombie" })
dropdown(Su, "Tecla Silent Aim", "ToFKey", { "E", "Q", "F", "R", "T", "C" })

section(Su, "Silent Aim Flashlight")
toggle(Su, "Silent Aim Flashlight", "FLAim")
toggle(Su, "Flashlight Laser", "FLLaser")
slider(Su, "Rango Flashlight", "FLRange", 20, 300, true)
slider(Su, "Suavidad Flashlight", "FLSmooth", 1, 20, true)
dropdown(Su, "Parte objetivo Flashlight", "FLPart", { "Head", "Torso", "Root" })

-- ========== ASESINO ==========
order = 0
local A = pages.Asesino
section(A, "Habilidades del asesino")
toggle(A, "Infinite Abyssal Burst (Abyss)", "InfAbyss")
toggle(A, "Infinite Skill (Hidden)", "InfHidden")
toggle(A, "Infinite Frenzy (Jeff)", "InfFrenzy")
toggle(A, "Infinite Lake Mist (Jason)", "InfLake")
toggle(A, "Infinite Pursuit (Jason)", "InfPursuit")
toggle(A, "Infinite Grab (Myers)", "InfGrab")
toggle(A, "Fake Attack (Counter Parry)", "FakeAtk")
toggle(A, "Botón no arrastrable (Inf Grab)", "InfGrabLock")

section(A, "Utilidades del asesino")
toggle(A, "Auto Attack", "AutoAtk")
slider(A, "Rango de ataque", "AtkRange", 5, 30, true)
toggle(A, "Hitbox Expand", "Hitbox")
slider(A, "Tamaño de hitbox", "HitboxSize", 5, 40, true)
toggle(A, "Infinite Lunge", "InfLunge")
toggle(A, "Auto Hook", "AutoHook")
toggle(A, "Destroy Pallets", "DestPal")
toggle(A, "Auto Kick Generator", "AutoKick")
toggle(A, "Block All Vaults", "BlockVault")
toggle(A, "Auto Drop All Pallets", "AutoDropPal")
toggle(A, "Break All Pallet", "BreakPal")
toggle(A, "Anti Blind (Flashlight)", "AntiBlind")
toggle(A, "Remove Palletwrong (All)", "NoPalStun")
toggle(A, "No Slowdown", "NoSlow")
toggle(A, "Beat Killer (auto kill)", "BeatKiller")
toggle(A, "Target Lock", "TargetLock")
slider(A, "Distancia máx Target Lock", "TLDist", 10, 200, true)
toggle(A, "Bloquear botón Target Lock", "TLLockBtn")

section(A, "Aim Asesino — Spear (Veil)")
toggle(A, "Spear Aimbot", "SpearAim")
dropdown(A, "Keybind toggle Spear", "SpearKey", { "Q", "E", "F", "R", "T", "C" })
toggle(A, "Silent Aim Spear (Veil)", "SilentSpear")
toggle(A, "Mostrar círculo FOV", "SpearFOVShow")
toggle(A, "Mostrar láser al objetivo", "SpearLaser")
slider(A, "Radio FOV", "SpearFOV", 50, 500, true)
toggle(A, "Auto Predict", "SpearPred")
slider(A, "Velocidad de lanza", "SpearSpeed", 50, 300, true)
slider(A, "Gravedad", "SpearGrav", 0, 300, true)
slider(A, "Vector horizontal", "SpearH", 0, 5, false)
dropdown(A, "Parte objetivo", "SpearPart", { "Torso", "Head", "Root" })

section(A, "Silent Aim Flask (Cure)")
toggle(A, "Silent Aim Flask (Cure)", "SilentFlask")
toggle(A, "Flask Laser (Cure)", "FlaskLaser")

-- open / hide / close
local menuOpen = false
openBtn.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	menu.Visible = menuOpen
end)

btnHide.MouseButton1Click:Connect(function()
	menu.Visible = false
	openBtn.Visible = false
	menuOpen = false
end)

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.RightShift then
		openBtn.Visible = true
		menu.Visible = true
		menuOpen = true
	end
end)

btnClose.MouseButton1Click:Connect(function()
	pcall(function()
		if espFolder then espFolder:Destroy() end
	end)
	gui:Destroy()
end)

print("[VD Menu] Listo | Botón VD abrir/cerrar | — oculta todo (RightShift restaura) | X destruye")

--[[
  VD Menu — SOLO VISUAL (completo)
  Botón VD abrir/cerrar | arrastrable | — oculta todo | X destruye
  RightShift restaura tras —
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local function parentGui()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	return CoreGui
end

pcall(function()
	local p = parentGui()
	for _, n in ipairs({ "VDVisualMenu", "VDVisualOpen" }) do
		local o = p:FindFirstChild(n)
		if o then o:Destroy() end
	end
end)

-- ===================== STATE =====================
local S = {
	FillT = 0.95, OutlineT = 0.3, TextSize = 12,
	PlayerESP = false,
	P_Surv = false, P_Item = false, P_Killer = false, P_Spec = false,
	Nametags = false, DistP = false, KillerWarn = false,
	-- índices de color 1..COLOR_COUNT (se resuelven con COLOR_PALETTE)
	IdxSurv = 5, IdxSurvHurt = 2, IdxSurvDown = 32, IdxKiller = 2, IdxSpec = 1,
	RainbowSurv = false, RainbowKiller = false, RainbowSpec = false,
	WorldESP = false,
	W_Gen = false, W_Hook = false, W_Gate = false, W_Win = false, W_Pal = false, W_SCP = false,
	NametagsW = false, GenPct = false, DistW = false,
	IdxGen = 15, IdxHook = 2, IdxGate = 4, IdxWin = 1, IdxPal = 7, IdxSCP = 8,
	NoCutscene = false, NoFog = false, Fullbright = false,
	KystKiller = false, SpecCounter = false, KillerPerks = false, PredictMap = false,
	HideSurvIcon = false, PingFPS = false, HookCounter = false,
	FOVOn = false, FOV = 90, ThirdP = false, ShiftLock = false, InfZoom = false,
}

local ITEM_NAMES = {
	["Motion Tracker"] = true, ["Gate"] = true, ["Flashlight"] = true, ["Bandage"] = true,
	["Parrying Dagger"] = true, ["Adrenaline Shot"] = true, ["Twist of Fate"] = true,
	["Shadow Clone"] = true, ["Holy Water"] = true, ["Wax Bound Candle"] = true,
	["Riot Shield"] = true, ["Emperor"] = true, ["AWP"] = true,
}

local origLight = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart or 0,
	GlobalShadows = Lighting.GlobalShadows,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FOV = (Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView) or 70,
}

local COLOR_PALETTE = {
	{ name = "blanco", c = Color3.fromRGB(255, 255, 255) },
	{ name = "Rojo Carmín", c = Color3.fromRGB(150, 0, 24) },
	{ name = "Azul Cielo", c = Color3.fromRGB(135, 206, 235) },
	{ name = "Amarillo Limón", c = Color3.fromRGB(255, 244, 79) },
	{ name = "Verde Esmeralda", c = Color3.fromRGB(80, 200, 120) },
	{ name = "Negro", c = Color3.fromRGB(20, 20, 20) },
	{ name = "Naranja Butano", c = Color3.fromRGB(255, 102, 0) },
	{ name = "Morado Oscuro", c = Color3.fromRGB(75, 0, 130) },
	{ name = "Plata", c = Color3.fromRGB(192, 192, 192) },
	{ name = "Verde Lima", c = Color3.fromRGB(50, 205, 50) },
	{ name = "Blanco", c = Color3.fromRGB(255, 255, 255) },
	{ name = "Azul Marino", c = Color3.fromRGB(0, 0, 128) },
	{ name = "Rosa Pastel", c = Color3.fromRGB(255, 182, 193) },
	{ name = "Marrón Chocolate", c = Color3.fromRGB(123, 63, 0) },
	{ name = "Cian", c = Color3.fromRGB(0, 255, 255) },
	{ name = "Mostaza", c = Color3.fromRGB(255, 219, 88) },
	{ name = "Magenta", c = Color3.fromRGB(255, 0, 255) },
	{ name = "Verde Oliva", c = Color3.fromRGB(128, 128, 0) },
	{ name = "Coral", c = Color3.fromRGB(255, 127, 80) },
	{ name = "Lavanda", c = Color3.fromRGB(230, 230, 250) },
	{ name = "Oro", c = Color3.fromRGB(255, 215, 0) },
	{ name = "Gris Carbón", c = Color3.fromRGB(54, 69, 79) },
	{ name = "Azul Turquesa", c = Color3.fromRGB(64, 224, 208) },
	{ name = "Terracota", c = Color3.fromRGB(204, 78, 49) },
	{ name = "Fucsia", c = Color3.fromRGB(255, 0, 255) },
	{ name = "Verde Menta", c = Color3.fromRGB(152, 255, 152) },
	{ name = "Burdeos", c = Color3.fromRGB(128, 0, 32) },
	{ name = "Beige", c = Color3.fromRGB(245, 245, 220) },
	{ name = "Violeta", c = Color3.fromRGB(238, 130, 238) },
	{ name = "Acua", c = Color3.fromRGB(0, 255, 255) },
	{ name = "Salmón", c = Color3.fromRGB(250, 128, 114) },
	{ name = "Rojo Ladrillo", c = Color3.fromRGB(178, 34, 34) },
	{ name = "Azul Eléctrico", c = Color3.fromRGB(125, 249, 255) },
	{ name = "Verde Militar", c = Color3.fromRGB(75, 83, 32) },
	{ name = "Amarillo Neón", c = Color3.fromRGB(207, 255, 4) },
	{ name = "Gris Perla", c = Color3.fromRGB(234, 234, 234) },
	{ name = "Púrpura", c = Color3.fromRGB(128, 0, 128) },
	{ name = "Marrón Café", c = Color3.fromRGB(111, 78, 55) },
	{ name = "Verde Manzana", c = Color3.fromRGB(141, 182, 0) },
	{ name = "Azul Cobalto", c = Color3.fromRGB(0, 71, 171) },
	{ name = "Naranja Neón", c = Color3.fromRGB(255, 95, 31) },
	{ name = "Lila", c = Color3.fromRGB(200, 162, 200) },
	{ name = "Bronce", c = Color3.fromRGB(205, 127, 50) },
	{ name = "Crema", c = Color3.fromRGB(255, 253, 208) },
	{ name = "Verde Azulado", c = Color3.fromRGB(0, 128, 128) },
	{ name = "Granate", c = Color3.fromRGB(128, 0, 0) },
	{ name = "Celeste", c = Color3.fromRGB(178, 255, 255) },
	{ name = "Caqui", c = Color3.fromRGB(195, 176, 145) },
	{ name = "Rosa Chicle", c = Color3.fromRGB(255, 105, 180) },
	{ name = "Gris Pizarra", c = Color3.fromRGB(112, 128, 144) },
	{ name = "Amarillo Huevo", c = Color3.fromRGB(255, 223, 0) },
	{ name = "Carioca", c = Color3.fromRGB(255, 140, 0) },
	{ name = "Verde Pino", c = Color3.fromRGB(1, 121, 111) },
	{ name = "Ocre", c = Color3.fromRGB(204, 119, 34) },
	{ name = "Azul Índigo", c = Color3.fromRGB(75, 0, 130) },
	{ name = "Melocotón", c = Color3.fromRGB(255, 218, 185) },
	{ name = "Verde Jade", c = Color3.fromRGB(0, 168, 107) },
	{ name = "Marrón Madera", c = Color3.fromRGB(139, 90, 43) },
	{ name = "Malva", c = Color3.fromRGB(224, 176, 255) },
	{ name = "Azul Zafiro", c = Color3.fromRGB(15, 82, 186) },
	{ name = "Rojo Coral", c = Color3.fromRGB(255, 64, 64) },
}
local COLOR_COUNT = 61

local function colorFromIdx(idx)
	idx = math.clamp(math.floor(tonumber(idx) or 1), 1, COLOR_COUNT)
	return COLOR_PALETTE[idx].c, COLOR_PALETTE[idx].name, idx
end

local function getColSurv() local c = colorFromIdx(S.IdxSurv) return c end
local function getColSurvHurt() local c = colorFromIdx(S.IdxSurvHurt) return c end
local function getColSurvDown() local c = colorFromIdx(S.IdxSurvDown) return c end
local function getColKiller() local c = colorFromIdx(S.IdxKiller) return c end
local function getColSpec() local c = colorFromIdx(S.IdxSpec) return c end
local function getColGen() local c = colorFromIdx(S.IdxGen) return c end
local function getColHook() local c = colorFromIdx(S.IdxHook) return c end
local function getColGate() local c = colorFromIdx(S.IdxGate) return c end
local function getColWin() local c = colorFromIdx(S.IdxWin) return c end
local function getColPal() local c = colorFromIdx(S.IdxPal) return c end
local function getColSCP() local c = colorFromIdx(S.IdxSCP) return c end


-- ===================== ESP =====================
local espFolder
local function folder()
	if espFolder and espFolder.Parent then return espFolder end
	espFolder = Instance.new("Folder")
	espFolder.Name = "VDVisualESP"
	pcall(function() espFolder.Parent = CoreGui end)
	if not espFolder.Parent then espFolder.Parent = LP:WaitForChild("PlayerGui") end
	return espFolder
end

local function kill(name)
	local c = folder():FindFirstChild(name)
	if c then c:Destroy() end
end

local function roleOf(p)
	local t = p.Team and p.Team.Name and p.Team.Name:lower() or ""
	if t:find("killer") then return "Killer" end
	if t:find("spect") then return "Spectator" end
	return "Survivor"
end

local function rainbow(t)
	return Color3.fromHSV((os.clock() * 0.2 + t) % 1, 1, 1)
end

local function playerColor(plr)
	local r = roleOf(plr)
	if r == "Killer" then
		return S.RainbowKiller and rainbow(0.1) or getColKiller()
	elseif r == "Spectator" then
		return S.RainbowSpec and rainbow(0.4) or getColSpec()
	end
	if S.RainbowSurv then return rainbow(0.7) end
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		if hum.Health <= 0 then return getColSurvDown() end
		if hum.Health < hum.MaxHealth * 0.9 then return getColSurvHurt() end
	end
	return getColSurv()
end

local function roleOn(plr)
	local r = roleOf(plr)
	if r == "Killer" then return S.P_Killer end
	if r == "Spectator" then return S.P_Spec end
	return S.P_Surv
end

local function ensureHL(name, adornee, color, isPlayer)
	if not (adornee and adornee.Parent) then return end
	local f = folder()
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
	hl.FillTransparency = isPlayer and S.FillT or 0.98
	hl.OutlineTransparency = isPlayer and S.OutlineT or 0.5
	hl.Enabled = true
end

local function getItem(plr)
	local char = plr.Character
	if not char then return nil end
	for _, o in ipairs(char:GetDescendants()) do
		if (o:IsA("Tool") or o:IsA("Model") or o:IsA("Accessory")) and ITEM_NAMES[o.Name] then
			return o.Name
		end
	end
	return nil
end

local function updatePlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LP then continue end
		local key = tostring(plr.UserId)
		local char = plr.Character
		if not (S.PlayerESP and roleOn(plr) and char) then
			kill("PHL_" .. key)
			kill("PTAG_" .. key)
			kill("PITEM_" .. key)
			kill("PWARN_" .. key)
			continue
		end
		local col = playerColor(plr)
		ensureHL("PHL_" .. key, char, col, true)

		local head = char:FindFirstChild("Head")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

		-- nametag / distance
		if head and (S.Nametags or S.DistP) then
			local f = folder()
			local tag = f:FindFirstChild("PTAG_" .. key)
			if not tag then
				tag = Instance.new("BillboardGui")
				tag.Name = "PTAG_" .. key
				tag.AlwaysOnTop = true
				tag.Size = UDim2.fromOffset(220, 22)
				tag.StudsOffset = Vector3.new(0, 2.65, 0)
				tag.Parent = f
				local lab = Instance.new("TextLabel")
				lab.Name = "L"
				lab.BackgroundTransparency = 1
				lab.Size = UDim2.fromScale(1, 1)
				lab.Font = Enum.Font.GothamBold
				lab.TextStrokeTransparency = 0.4
				lab.Parent = tag
			end
			tag.Adornee = head
			local bits = {}
			if S.Nametags then table.insert(bits, plr.Name) end
			if S.DistP and my and hrp then
				table.insert(bits, string.format("[%dm]", math.floor((my.Position - hrp.Position).Magnitude)))
			end
			local lab = tag.L
			lab.Text = table.concat(bits, " ")
			lab.TextColor3 = col
			lab.TextSize = S.TextSize
		else
			kill("PTAG_" .. key)
		end

		-- item icon text
		if S.P_Item and roleOf(plr) == "Survivor" then
			local item = getItem(plr)
			local torso = hrp or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
			if item and torso then
				local f = folder()
				local tag = f:FindFirstChild("PITEM_" .. key)
				if not tag then
					tag = Instance.new("BillboardGui")
					tag.Name = "PITEM_" .. key
					tag.AlwaysOnTop = true
					tag.Size = UDim2.fromOffset(120, 16)
					tag.StudsOffset = Vector3.new(0, 1.2, 0)
					tag.Parent = f
					local lab = Instance.new("TextLabel")
					lab.Name = "L"
					lab.BackgroundTransparency = 1
					lab.Size = UDim2.fromScale(1, 1)
					lab.Font = Enum.Font.Gotham
					lab.TextSize = 11
					lab.TextColor3 = Color3.fromRGB(200, 220, 255)
					lab.TextStrokeTransparency = 0.5
					lab.Parent = tag
				end
				tag.Adornee = torso
				tag.L.Text = item
			else
				kill("PITEM_" .. key)
			end
		else
			kill("PITEM_" .. key)
		end

		-- Killer warning on survivors when killer close
		if S.KillerWarn and roleOf(plr) == "Survivor" and head then
			local killerHRP = nil
			for _, k in ipairs(Players:GetPlayers()) do
				if roleOf(k) == "Killer" and k.Character then
					killerHRP = k.Character:FindFirstChild("HumanoidRootPart")
					if killerHRP then break end
				end
			end
			if killerHRP and hrp then
				local d = (killerHRP.Position - hrp.Position).Magnitude
				if d <= 60 then
					local f = folder()
					local tag = f:FindFirstChild("PWARN_" .. key)
					if not tag then
						tag = Instance.new("BillboardGui")
						tag.Name = "PWARN_" .. key
						tag.AlwaysOnTop = true
						tag.Size = UDim2.fromOffset(40, 40)
						tag.StudsOffset = Vector3.new(1.5, 2.2, 0)
						tag.Parent = f
						local lab = Instance.new("TextLabel")
						lab.Name = "L"
						lab.BackgroundTransparency = 1
						lab.Size = UDim2.fromScale(1, 1)
						lab.Font = Enum.Font.GothamBold
						lab.Text = "[!]"
						lab.TextSize = 18
						lab.TextStrokeTransparency = 0.3
						lab.Parent = tag
					end
					tag.Adornee = head
					tag.L.TextColor3 = d <= 40 and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 220, 40)
				else
					kill("PWARN_" .. key)
				end
			else
				kill("PWARN_" .. key)
			end
		else
			kill("PWARN_" .. key)
		end
	end
end

-- World
local worldReg = { Generator = {}, Hook = {}, Gate = {}, Window = {}, Palletwrong = {}, SCPZombie = {} }

local function classify(n)
	if n == "Generator" or n == "Hook" or n == "Gate" or n == "Window" or n == "Palletwrong" then
		return n
	end
	local l = n:lower()
	if l:find("scp") or l:find("zombie") then return "SCPZombie" end
	return nil
end

local function scanWorld()
	for k in pairs(worldReg) do worldReg[k] = {} end
	for _, rootName in ipairs({ "Map", "Map1" }) do
		local root = Workspace:FindFirstChild(rootName)
		if root then
			for _, d in ipairs(root:GetDescendants()) do
				if d:IsA("Model") then
					local cat = classify(d.Name)
					if cat then
						local part = d:FindFirstChild("HitBox", true)
							or d:FindFirstChild("GeneratorPoint", true)
							or d:FindFirstChildWhichIsA("BasePart", true)
						if part then worldReg[cat][d] = part end
					end
				end
			end
		end
	end
end

local function wOn(cat)
	return ({
		Generator = S.W_Gen, Hook = S.W_Hook, Gate = S.W_Gate,
		Window = S.W_Win, Palletwrong = S.W_Pal, SCPZombie = S.W_SCP
	})[cat]
end

local function wCol(cat)
	return ({
		Generator = getColGen(), Hook = getColHook(), Gate = getColGate(),
		Window = getColWin(), Palletwrong = getColPal(), SCPZombie = getColSCP()
	})[cat]
end

local function updateWorld()
	if not S.WorldESP then
		for _, c in ipairs(folder():GetChildren()) do
			if c.Name:find("^WHL_") or c.Name:find("^WTAG_") then c:Destroy() end
		end
		return
	end
	local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for cat, models in pairs(worldReg) do
		local on = wOn(cat)
		local col = wCol(cat)
		for model, part in pairs(models) do
			local id = tostring(model:GetDebugId())
			if on and model.Parent and part.Parent then
				ensureHL("WHL_" .. id, model, col, false)
				if S.NametagsW or S.DistW or (S.GenPct and cat == "Generator") then
					local f = folder()
					local tag = f:FindFirstChild("WTAG_" .. id)
					if not tag then
						tag = Instance.new("BillboardGui")
						tag.Name = "WTAG_" .. id
						tag.AlwaysOnTop = true
						tag.Size = UDim2.fromOffset(170, 18)
						tag.StudsOffset = Vector3.new(0, 2.3, 0)
						tag.Parent = f
						local lab = Instance.new("TextLabel")
						lab.Name = "L"
						lab.BackgroundTransparency = 1
						lab.Size = UDim2.fromScale(1, 1)
						lab.Font = Enum.Font.GothamBold
						lab.TextStrokeTransparency = 0.4
						lab.Parent = tag
					end
					tag.Adornee = part
					local bits = {}
					if S.NametagsW then
						table.insert(bits, cat == "Palletwrong" and "Pallet" or cat)
					end
					if S.GenPct and cat == "Generator" then
						local p = model:GetAttribute("RepairProgress") or model:GetAttribute("ProgressRepair")
						if typeof(p) == "number" then
							local pct = p <= 1 and math.floor(p * 100) or math.floor(p)
							table.insert(bits, pct .. "%")
						end
					end
					if S.DistW and my then
						table.insert(bits, string.format("[%dm]", math.floor((my.Position - part.Position).Magnitude)))
					end
					tag.L.Text = table.concat(bits, " ")
					tag.L.TextColor3 = col
					tag.L.TextSize = S.TextSize
				else
					kill("WTAG_" .. id)
				end
			else
				kill("WHL_" .. id)
				kill("WTAG_" .. id)
			end
		end
	end
end

-- Info overlay
local infoGui
local function ensureInfo()
	if infoGui and infoGui.Parent then return infoGui end
	infoGui = Instance.new("ScreenGui")
	infoGui.Name = "VDVisualInfo"
	infoGui.ResetOnSpawn = false
	infoGui.IgnoreGuiInset = true
	infoGui.DisplayOrder = 999998
	infoGui.Parent = parentGui()
	local lab = Instance.new("TextLabel")
	lab.Name = "Info"
	lab.Size = UDim2.fromOffset(280, 120)
	lab.Position = UDim2.new(0, 10, 0, 10)
	lab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	lab.BackgroundTransparency = 0.45
	lab.TextColor3 = Color3.fromRGB(0, 255, 140)
	lab.Font = Enum.Font.Code
	lab.TextSize = 13
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.TextYAlignment = Enum.TextYAlignment.Top
	lab.Text = ""
	lab.Visible = false
	lab.Parent = infoGui
	Instance.new("UICorner", lab).CornerRadius = UDim.new(0, 6)
	return infoGui
end

local frames, lastFpsT, fps = 0, os.clock(), 0
local function updateInfo()
	ensureInfo()
	local lab = infoGui.Info
	local lines = {}
	if S.PingFPS then
		frames = frames + 1
		local now = os.clock()
		if now - lastFpsT >= 0.5 then
			fps = math.floor(frames / (now - lastFpsT) + 0.5)
			frames = 0
			lastFpsT = now
		end
		local ping = 0
		pcall(function()
			local net = Stats:FindFirstChild("Network")
			local ssi = net and net:FindFirstChild("ServerStatsItem")
			local dp = ssi and ssi:FindFirstChild("Data Ping")
			if dp and dp.GetValue then ping = math.floor(dp:GetValue() + 0.5) end
		end)
		table.insert(lines, string.format("FPS: %d  |  Ping: %dms", fps, ping))
	end
	if S.SpecCounter then
		local n = 0
		for _, p in ipairs(Players:GetPlayers()) do
			if roleOf(p) == "Spectator" then n = n + 1 end
		end
		table.insert(lines, "Espectadores: " .. n)
	end
	if S.KystKiller then
		local name = "—"
		for _, p in ipairs(Players:GetPlayers()) do
			if roleOf(p) == "Killer" then name = p.Name break end
		end
		table.insert(lines, "Killer: " .. name)
	end
	if S.PredictMap then
		local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Map1")
		table.insert(lines, "Map: " .. (map and map.Name or "Unknown"))
	end
	if S.KillerPerks then
		table.insert(lines, "Perks Killer: (panel on)")
	end
	if S.HookCounter then
		table.insert(lines, "Hooks: (tracking UI)")
	end
	if #lines > 0 then
		lab.Visible = true
		lab.Text = "  " .. table.concat(lines, "\n  ")
		lab.Size = UDim2.fromOffset(280, 18 + #lines * 16)
	else
		lab.Visible = false
	end
end

-- Hide survivor icon (simple)
local hideConn
local function applyHideIcon()
	if not S.HideSurvIcon then return end
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return end
	for _, d in ipairs(pg:GetDescendants()) do
		if d:IsA("ImageLabel") or d:IsA("ImageButton") then
			-- soft hide common survivor HUD icons by reducing visibility if name hints
			local n = d.Name:lower()
			if n:find("survivor") or n:find("icon") then
				d.ImageTransparency = 0.85
			end
		end
	end
end

-- Role helper for third person
local function amKiller()
	return roleOf(LP) == "Killer"
end

local scanT = 0
RunService.RenderStepped:Connect(function(dt)
	if S.PlayerESP then updatePlayers()
	else
		for _, c in ipairs(folder():GetChildren()) do
			if c.Name:find("^PHL_") or c.Name:find("^PTAG_") or c.Name:find("^PITEM_") or c.Name:find("^PWARN_") then
				c:Destroy()
			end
		end
	end

	scanT = scanT + dt
	if S.WorldESP then
		if scanT > 2 then scanT = 0 scanWorld() end
		updateWorld()
	else
		for _, c in ipairs(folder():GetChildren()) do
			if c.Name:find("^WHL_") or c.Name:find("^WTAG_") then c:Destroy() end
		end
	end

	if S.Fullbright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.FogStart = 0
		Lighting.FogEnd = 100000
	end
	if S.NoFog then
		Lighting.FogStart = 0
		Lighting.FogEnd = 100000
	end

	local cam = Workspace.CurrentCamera
	if cam and S.FOVOn then cam.FieldOfView = S.FOV end

	if S.ThirdP and amKiller() and cam then
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.CameraOffset = Vector3.new(2, 1, 8) end
	elseif not S.ThirdP then
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.CameraOffset = Vector3.zero end
	end

	if S.ShiftLock then
		local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if root and cam then
			if hum then hum.AutoRotate = false end
			local look = cam.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			if flat.Magnitude > 0.05 then
				root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit)
			end
		end
	else
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = true end
	end

	if S.InfZoom then
		LP.CameraMaxZoomDistance = math.huge
		LP.CameraMinZoomDistance = 0
	end

	updateInfo()
	if S.HideSurvIcon then applyHideIcon() end
end)

-- Cutscene skip
task.spawn(function()
	local rem = RS:FindFirstChild("Remotes")
	local gameFolder = rem and rem:FindFirstChild("Game")
	if not gameFolder then return end
	local function skip()
		if not S.NoCutscene then return end
		pcall(function()
			local cam = Workspace.CurrentCamera
			if cam then cam.CameraType = Enum.CameraType.Custom end
			UIS.MouseIconEnabled = true
			LP:SetAttribute("isspectating", true)
		end)
	end
	for _, n in ipairs({ "endscreencutscene", "cutsceneEnd", "cutsceneEnd2", "cutsceneEndwithownchar" }) do
		local ev = gameFolder:FindFirstChild(n)
		if ev and ev:IsA("RemoteEvent") then ev.OnClientEvent:Connect(skip) end
	end
end)

-- ===================== UI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "VDVisualMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = parentGui()

local openBtn = Instance.new("TextButton")
openBtn.Name = "Open"
openBtn.Size = UDim2.fromOffset(52, 52)
openBtn.Position = UDim2.new(0, 14, 0.45, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
openBtn.Text = "VD"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(320, 460)
menu.Position = UDim2.new(0, 76, 0.5, -230)
menu.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
menu.Visible = false
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 34)
top.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
top.Parent = menu
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Visual"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local btnHide = Instance.new("TextButton")
btnHide.Size = UDim2.fromOffset(28, 28)
btnHide.Position = UDim2.new(1, -64, 0.5, -14)
btnHide.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
btnHide.Text = "—"
btnHide.TextColor3 = Color3.new(1, 1, 1)
btnHide.Font = Enum.Font.GothamBold
btnHide.TextSize = 16
btnHide.Parent = top
Instance.new("UICorner", btnHide).CornerRadius = UDim.new(0, 6)

local btnX = Instance.new("TextButton")
btnX.Size = UDim2.fromOffset(28, 28)
btnX.Position = UDim2.new(1, -32, 0.5, -14)
btnX.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
btnX.Text = "X"
btnX.TextColor3 = Color3.new(1, 1, 1)
btnX.Font = Enum.Font.GothamBold
btnX.TextSize = 14
btnX.Parent = top
Instance.new("UICorner", btnX).CornerRadius = UDim.new(0, 6)

local function drag(handle, target)
	local dragging, start, base
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, start, base = true, i.Position, target.Position
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
			target.Position = UDim2.new(base.X.Scale, base.X.Offset + d.X, base.Y.Scale, base.Y.Offset + d.Y)
		end
	end)
end
drag(top, menu)
drag(openBtn, openBtn)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -44)
scroll.Position = UDim2.fromOffset(6, 38)
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = menu
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 4)
list.Parent = scroll
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 6)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 6)
pad.PaddingRight = UDim.new(0, 6)
pad.Parent = scroll

local order = 0
local function ord() order = order + 1 return order end

local function section(t)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -4, 0, 22)
	l.BackgroundColor3 = Color3.fromRGB(36, 38, 52)
	l.Text = "  " .. t
	l.TextColor3 = Color3.fromRGB(255, 200, 80)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = ord()
	l.Parent = scroll
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
end

local function toggle(text, key, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 28)
	b.BackgroundColor3 = S[key] and Color3.fromRGB(28, 130, 65) or Color3.fromRGB(44, 46, 58)
	b.Text = text .. (S[key] and "  ON" or "  OFF")
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.LayoutOrder = ord()
	b.Parent = scroll
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.MouseButton1Click:Connect(function()
		S[key] = not S[key]
		b.Text = text .. (S[key] and "  ON" or "  OFF")
		b.BackgroundColor3 = S[key] and Color3.fromRGB(28, 130, 65) or Color3.fromRGB(44, 46, 58)
		if cb then cb(S[key]) end
		if key == "WorldESP" and S.WorldESP then scanWorld() end
	end)
end

local function slider(text, key, min, max, isInt)
	local hold = Instance.new("Frame")
	hold.Size = UDim2.new(1, -4, 0, 42)
	hold.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
	hold.LayoutOrder = ord()
	hold.Parent = scroll
	Instance.new("UICorner", hold).CornerRadius = UDim.new(0, 4)
	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(1, -10, 0, 16)
	lab.Position = UDim2.fromOffset(6, 3)
	lab.BackgroundTransparency = 1
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 11
	lab.TextColor3 = Color3.new(1, 1, 1)
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.Parent = hold
	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -12, 0, 12)
	bar.Position = UDim2.fromOffset(6, 24)
	bar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	bar.Text = ""
	bar.AutoButtonColor = false
	bar.Parent = hold
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.fromOffset(16, 16)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 2
	thumb.Parent = bar
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(180, 40, 40)
	stroke.Thickness = 2
	stroke.Parent = thumb
	local function ref()
		local v = S[key]
		lab.Text = text .. ": " .. (isInt and tostring(math.floor(v)) or string.format("%.2f", v))
		local rel = (v - min) / math.max(max - min, 1e-6)
		rel = math.clamp(rel, 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		thumb.Position = UDim2.new(rel, 0, 0.5, 0)
	end
	ref()
	local function setX(x)
		local rel = math.clamp(x / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local v = min + rel * (max - min)
		if isInt then v = math.floor(v + 0.5) end
		S[key] = v
		ref()
	end
	local sliding = false
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			setX(i.Position.X - bar.AbsolutePosition.X)
		end
	end)
	bar.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not sliding then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			setX(i.Position.X - bar.AbsolutePosition.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
end

-- Slider de color con círculo + muestra del color y nombre
local function colorSlider(text, idxKey)
	local hold = Instance.new("Frame")
	hold.Size = UDim2.new(1, -4, 0, 52)
	hold.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
	hold.LayoutOrder = ord()
	hold.Parent = scroll
	Instance.new("UICorner", hold).CornerRadius = UDim.new(0, 4)

	local swatch = Instance.new("Frame")
	swatch.Size = UDim2.fromOffset(18, 18)
	swatch.Position = UDim2.fromOffset(6, 4)
	swatch.BorderSizePixel = 0
	swatch.Parent = hold
	Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)

	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(1, -32, 0, 18)
	lab.Position = UDim2.fromOffset(28, 4)
	lab.BackgroundTransparency = 1
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 11
	lab.TextColor3 = Color3.new(1, 1, 1)
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.TextTruncate = Enum.TextTruncate.AtEnd
	lab.Parent = hold

	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -12, 0, 14)
	bar.Position = UDim2.fromOffset(6, 30)
	bar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	bar.Text = ""
	bar.AutoButtonColor = false
	bar.Parent = hold
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.fromOffset(18, 18)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 3
	thumb.Parent = bar
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Parent = thumb

	local function ref()
		local c, name, idx = colorFromIdx(S[idxKey])
		S[idxKey] = idx
		lab.Text = string.format("%s: %d — %s", text, idx, name)
		swatch.BackgroundColor3 = c
		thumb.BackgroundColor3 = c
		stroke.Color = Color3.new(1, 1, 1)
		local rel = (idx - 1) / math.max(COLOR_COUNT - 1, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		fill.BackgroundColor3 = c
		thumb.Position = UDim2.new(rel, 0, 0.5, 0)
	end
	ref()

	local sliding = false
	local function setX(x)
		local rel = math.clamp(x / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local idx = math.floor(rel * (COLOR_COUNT - 1) + 1.5)
		idx = math.clamp(idx, 1, COLOR_COUNT)
		S[idxKey] = idx
		ref()
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			setX(i.Position.X - bar.AbsolutePosition.X)
		end
	end)
	bar.InputEnded:Connect(function() sliding = false end)
	UIS.InputChanged:Connect(function(i)
		if not sliding then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			setX(i.Position.X - bar.AbsolutePosition.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
end

-- BUILD VISUAL
section("Highlight ESP Settings")
slider("Transparencia relleno ESP", "FillT", 0, 1, false)
slider("Transparencia contorno ESP", "OutlineT", 0, 1, false)
slider("Tamaño texto ESP", "TextSize", 8, 24, true)

section("Player Highlight ESP")
toggle("Activar ESP de jugadores", "PlayerESP")
multi("Seleccionar ESP de jugadores", {
	"Sobreviviente", "Item de Superviviente", "Asesino", "Espectador"
}, { "P_Surv", "P_Item", "P_Killer", "P_Spec" })
toggle("Nametags de jugadores", "Nametags")
toggle("Distancia ESP de jugadores", "DistP")
toggle("Advertencia Killer en Superviviente (!)", "KillerWarn")
toggle("Color Survivor Rainbow", "RainbowSurv")
colorSlider("Color Survivor Normal", "IdxSurv")
colorSlider("Color Survivor Herido", "IdxSurvHurt")
colorSlider("Color Survivor Derribado", "IdxSurvDown")
toggle("Color Killer Rainbow", "RainbowKiller")
colorSlider("Color Killer", "IdxKiller")
toggle("Color Spectator Rainbow", "RainbowSpec")
colorSlider("Color Spectator", "IdxSpec")

section("World Highlight ESP")
toggle("Activar ESP del mundo", "WorldESP", function(v) if v then scanWorld() end end)
multi("Seleccionar objetos del mundo", {
	"Generators", "Hooks", "Gates", "Windows", "Pallets", "SCP/Zombie"
}, { "W_Gen", "W_Hook", "W_Gate", "W_Win", "W_Pal", "W_SCP" })
toggle("Nametags del mundo", "NametagsW")
toggle("Porcentaje del generador", "GenPct")
toggle("Distancia ESP del mundo", "DistW")
colorSlider("Color Generator", "IdxGen")
colorSlider("Color Hook", "IdxHook")
colorSlider("Color Gate", "IdxGate")
colorSlider("Color Window", "IdxWin")
colorSlider("Color Pallet", "IdxPal")
colorSlider("Color SCP / Zombie", "IdxSCP")

section("Lighting")
toggle("Sin cutscene", "NoCutscene")
toggle("Sin niebla", "NoFog")
toggle("Fullbright", "Fullbright", function(v)
	if not v then
		Lighting.Brightness = origLight.Brightness
		Lighting.ClockTime = origLight.ClockTime
		Lighting.FogEnd = origLight.FogEnd
		Lighting.FogStart = origLight.FogStart
		Lighting.GlobalShadows = origLight.GlobalShadows
		Lighting.OutdoorAmbient = origLight.OutdoorAmbient
	end
end)

section("Game Info Panel")
toggle("Display Kyst Killer", "KystKiller")
toggle("Contador de espectadores", "SpecCounter")
toggle("Mostrar perks del Killer", "KillerPerks")
toggle("Predecir mapa", "PredictMap")
toggle("Ocultar icono de Survivor", "HideSurvIcon")
toggle("Mostrar Ping y FPS", "PingFPS")
toggle("Mostrar contador de hooks", "HookCounter")

section("Cámara")
toggle("Activar override de FOV", "FOVOn", function(v)
	if not v and Workspace.CurrentCamera then
		Workspace.CurrentCamera.FieldOfView = origLight.FOV
	end
end)
slider("FOV de cámara", "FOV", 30, 140, true)
toggle("Tercera persona (solo Killer)", "ThirdP")
toggle("Shift Lock", "ShiftLock")
toggle("Zoom infinito hacia afuera", "InfZoom", function(v)
	if v then
		LP.CameraMaxZoomDistance = math.huge
		LP.CameraMinZoomDistance = 0
	else
		LP.CameraMaxZoomDistance = 128
		LP.CameraMinZoomDistance = 0.5
	end
end)

local open = false
openBtn.MouseButton1Click:Connect(function()
	open = not open
	menu.Visible = open
end)

btnHide.MouseButton1Click:Connect(function()
	menu.Visible = false
	openBtn.Visible = false
	open = false
end)

UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.RightShift then
		openBtn.Visible = true
		menu.Visible = true
		open = true
	end
end)

btnX.MouseButton1Click:Connect(function()
	pcall(function() if espFolder then espFolder:Destroy() end end)
	pcall(function() if infoGui then infoGui:Destroy() end end)
	gui:Destroy()
end)

print("[VD Visual] OK | VD abrir | — ocultar (RightShift restaura) | X destruir")

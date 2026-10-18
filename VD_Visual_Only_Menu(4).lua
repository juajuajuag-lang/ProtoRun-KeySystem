--[[
  VD Visual Menu — completo y estable
  Botón VD: toque = abrir/cerrar | arrastrar si mueves
  — oculta todo | RightShift restaura | X destruye
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
	local ok, h = pcall(function()
		return gethui and gethui()
	end)
	if ok and h then return h end
	local ok2, cg = pcall(function() return CoreGui end)
	if ok2 then return cg end
	return LP:WaitForChild("PlayerGui")
end

pcall(function()
	local p = parentGui()
	for _, n in ipairs({ "VDVisualMenu", "VDVisualInfo" }) do
		local o = p:FindFirstChild(n)
		if o then o:Destroy() end
	end
end)

-- ===================== COLOR PALETTE =====================
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
local COLOR_COUNT = #COLOR_PALETTE

local function colorFromIdx(idx)
	idx = math.clamp(math.floor(tonumber(idx) or 1), 1, COLOR_COUNT)
	return COLOR_PALETTE[idx].c, COLOR_PALETTE[idx].name, idx
end

-- ===================== STATE =====================
local S = {
	FillT = 0.95, OutlineT = 0.3, TextSize = 12,
	PlayerESP = false,
	P_Surv = false, P_Item = false, P_Killer = false, P_Spec = false,
	Nametags = false, DistP = false, KillerWarn = false,
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

local function getCol(key)
	local c = colorFromIdx(S[key])
	return c
end

local function rainbow()
	return Color3.fromHSV((os.clock() * 0.25) % 1, 1, 1)
end

local function roleOf(p)
	local t = p.Team and p.Team.Name and p.Team.Name:lower() or ""
	if string.find(t, "killer") then return "Killer" end
	if string.find(t, "spect") then return "Spectator" end
	return "Survivor"
end

local function roleOn(plr)
	local r = roleOf(plr)
	if r == "Killer" then return S.P_Killer end
	if r == "Spectator" then return S.P_Spec end
	return S.P_Surv
end

local function playerColor(plr)
	local r = roleOf(plr)
	if r == "Killer" then
		if S.RainbowKiller then return rainbow() end
		return getCol("IdxKiller")
	elseif r == "Spectator" then
		if S.RainbowSpec then return rainbow() end
		return getCol("IdxSpec")
	end
	if S.RainbowSurv then return rainbow() end
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		if hum.Health <= 0 then return getCol("IdxSurvDown") end
		if hum.Health < hum.MaxHealth * 0.9 then return getCol("IdxSurvHurt") end
	end
	return getCol("IdxSurv")
end

-- ===================== ESP =====================
local espFolder
local function folder()
	if espFolder and espFolder.Parent then return espFolder end
	espFolder = Instance.new("Folder")
	espFolder.Name = "VDVisualESP"
	pcall(function() espFolder.Parent = CoreGui end)
	if not espFolder.Parent then
		espFolder.Parent = LP:WaitForChild("PlayerGui")
	end
	return espFolder
end

local function kill(name)
	local c = folder():FindFirstChild(name)
	if c then c:Destroy() end
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
		if plr ~= LP then
			local key = tostring(plr.UserId)
			local char = plr.Character
			if not (S.PlayerESP and roleOn(plr) and char) then
				kill("PHL_" .. key)
				kill("PTAG_" .. key)
				kill("PITEM_" .. key)
				kill("PWARN_" .. key)
			else
				local col = playerColor(plr)
				ensureHL("PHL_" .. key, char, col, true)
				local head = char:FindFirstChild("Head")
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

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
					tag.L.Text = table.concat(bits, " ")
					tag.L.TextColor3 = col
					tag.L.TextSize = S.TextSize
				else
					kill("PTAG_" .. key)
				end

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

				if S.KillerWarn and roleOf(plr) == "Survivor" and head and hrp then
					local killerHRP = nil
					for _, k in ipairs(Players:GetPlayers()) do
						if roleOf(k) == "Killer" and k.Character then
							killerHRP = k.Character:FindFirstChild("HumanoidRootPart")
							if killerHRP then break end
						end
					end
					if killerHRP then
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
							tag.L.TextColor3 = (d <= 40) and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 220, 40)
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
	end
end

local worldReg = { Generator = {}, Hook = {}, Gate = {}, Window = {}, Palletwrong = {}, SCPZombie = {} }

local function classify(n)
	if n == "Generator" or n == "Hook" or n == "Gate" or n == "Window" or n == "Palletwrong" then
		return n
	end
	local l = string.lower(n)
	if string.find(l, "scp") or string.find(l, "zombie") then return "SCPZombie" end
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
	local m = {
		Generator = S.W_Gen, Hook = S.W_Hook, Gate = S.W_Gate,
		Window = S.W_Win, Palletwrong = S.W_Pal, SCPZombie = S.W_SCP,
	}
	return m[cat]
end

local function wCol(cat)
	local m = {
		Generator = "IdxGen", Hook = "IdxHook", Gate = "IdxGate",
		Window = "IdxWin", Palletwrong = "IdxPal", SCPZombie = "IdxSCP",
	}
	return getCol(m[cat])
end

local function updateWorld()
	if not S.WorldESP then
		for _, c in ipairs(folder():GetChildren()) do
			if string.find(c.Name, "^WHL_") or string.find(c.Name, "^WTAG_") then
				c:Destroy()
			end
		end
		return
	end
	local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for cat, models in pairs(worldReg) do
		local on = wOn(cat)
		local col = wCol(cat)
		for model, part in pairs(models) do
			local id = tostring(model:GetDebugId())
			if on and model.Parent and part and part.Parent then
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
						table.insert(bits, (cat == "Palletwrong") and "Pallet" or cat)
					end
					if S.GenPct and cat == "Generator" then
						local p = model:GetAttribute("RepairProgress") or model:GetAttribute("ProgressRepair")
						if typeof(p) == "number" then
							local pct = (p <= 1) and math.floor(p * 100) or math.floor(p)
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
	lab.Size = UDim2.fromOffset(280, 80)
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
	if #lines > 0 then
		lab.Visible = true
		lab.Text = "  " .. table.concat(lines, "\n  ")
		lab.Size = UDim2.fromOffset(280, 18 + #lines * 16)
	else
		lab.Visible = false
	end
end

local scanT = 0
RunService.RenderStepped:Connect(function(dt)
	if S.PlayerESP then
		updatePlayers()
	else
		for _, c in ipairs(folder():GetChildren()) do
			if string.find(c.Name, "^PHL_") or string.find(c.Name, "^PTAG_")
				or string.find(c.Name, "^PITEM_") or string.find(c.Name, "^PWARN_") then
				c:Destroy()
			end
		end
	end

	scanT = scanT + dt
	if S.WorldESP then
		if scanT > 2 then
			scanT = 0
			scanWorld()
		end
		updateWorld()
	else
		for _, c in ipairs(folder():GetChildren()) do
			if string.find(c.Name, "^WHL_") or string.find(c.Name, "^WTAG_") then
				c:Destroy()
			end
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
	if cam and S.FOVOn then
		cam.FieldOfView = S.FOV
	end

	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if S.ThirdP and roleOf(LP) == "Killer" then
		if hum then hum.CameraOffset = Vector3.new(2, 1, 8) end
	else
		if hum then hum.CameraOffset = Vector3.zero end
	end

	if S.ShiftLock then
		local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if root and cam then
			if hum then hum.AutoRotate = false end
			local look = cam.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			if flat.Magnitude > 0.05 then
				root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit)
			end
		end
	else
		if hum then hum.AutoRotate = true end
	end

	if S.InfZoom then
		LP.CameraMaxZoomDistance = math.huge
		LP.CameraMinZoomDistance = 0
	end

	updateInfo()
end)

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
--[[
  Ventana Visual
  Sub-pestañas desplegables (acordeón):
    ▼ Highlight ESP Settings
    ▼ Player Highlight ESP
    ▼ World Highlight ESP
    ▼ Lighting
    ▼ Cámara
]]

local gui = Instance.new("ScreenGui")
gui.Name = "VDVisualMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = parentGui()

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.fromOffset(56, 56)
openBtn.Position = UDim2.new(0, 14, 0.42, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
openBtn.Text = "VD"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18
openBtn.AutoButtonColor = true
openBtn.Active = true
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.fromOffset(340, 500)
menu.Position = UDim2.new(0, 80, 0.5, -250)
menu.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
menu.Visible = false
menu.Active = true
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 12)

local top = Instance.new("Frame")
top.Name = "Top"
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
top.Active = true
top.Parent = menu
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "Visual"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local btnHide = Instance.new("TextButton")
btnHide.Size = UDim2.fromOffset(30, 30)
btnHide.Position = UDim2.new(1, -70, 0.5, -15)
btnHide.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
btnHide.Text = "—"
btnHide.TextColor3 = Color3.new(1, 1, 1)
btnHide.Font = Enum.Font.GothamBold
btnHide.TextSize = 16
btnHide.Parent = top
Instance.new("UICorner", btnHide).CornerRadius = UDim.new(0, 6)

local btnX = Instance.new("TextButton")
btnX.Size = UDim2.fromOffset(30, 30)
btnX.Position = UDim2.new(1, -34, 0.5, -15)
btnX.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
btnX.Text = "X"
btnX.TextColor3 = Color3.new(1, 1, 1)
btnX.Font = Enum.Font.GothamBold
btnX.TextSize = 14
btnX.Parent = top
Instance.new("UICorner", btnX).CornerRadius = UDim.new(0, 6)

local menuOpen = false
local function setMenuOpen(v)
	menuOpen = v and true or false
	menu.Visible = menuOpen
end
local function toggleMenu()
	setMenuOpen(not menuOpen)
end

local function makeDrag(handle, target, onTap)
	local dragging, moved, startPos, base
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, false
			startPos, base = input.Position, target.Position
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if dragging and not moved and onTap then onTap() end
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - startPos
			if d.Magnitude > 12 then
				moved = true
				target.Position = UDim2.new(
					base.X.Scale, base.X.Offset + d.X,
					base.Y.Scale, base.Y.Offset + d.Y
				)
			end
		end
	end)
end

makeDrag(top, menu, nil)
makeDrag(openBtn, openBtn, toggleMenu)
openBtn.MouseButton1Click:Connect(toggleMenu)
pcall(function() openBtn.Activated:Connect(toggleMenu) end)

-- Scroll principal con sub-pestañas desplegables
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "MainScroll"
scroll.Size = UDim2.new(1, -12, 1, -50)
scroll.Position = UDim2.fromOffset(6, 44)
scroll.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = menu
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

local mainList = Instance.new("UIListLayout")
mainList.Padding = UDim.new(0, 6)
mainList.Parent = scroll

local mainPad = Instance.new("UIPadding")
mainPad.PaddingTop = UDim.new(0, 6)
mainPad.PaddingBottom = UDim.new(0, 10)
mainPad.PaddingLeft = UDim.new(0, 6)
mainPad.PaddingRight = UDim.new(0, 6)
mainPad.Parent = scroll

-- Solo 1 slider a la vez
local activeSlider, activeSetX = nil, nil

UIS.InputChanged:Connect(function(i)
	if not activeSlider or not activeSetX then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch then
		activeSetX(i.Position.X - activeSlider.AbsolutePosition.X)
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
		activeSlider = nil
		activeSetX = nil
	end
end)

local function bindSlider(bar, setX)
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			if activeSlider and activeSlider ~= bar then return end
			activeSlider = bar
			activeSetX = setX
			setX(i.Position.X - bar.AbsolutePosition.X)
		end
	end)
end

-- Crea una sub-pestaña desplegable. Devuelve el contenedor interno (body).
local function makeAccordion(titleText, defaultOpen)
	local wrap = Instance.new("Frame")
	wrap.Name = "Acc_" .. titleText
	wrap.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	wrap.BorderSizePixel = 0
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.Size = UDim2.new(1, 0, 0, 0)
	wrap.Parent = scroll
	Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)

	local wrapList = Instance.new("UIListLayout")
	wrapList.SortOrder = Enum.SortOrder.LayoutOrder
	wrapList.Parent = wrap

	local header = Instance.new("TextButton")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundColor3 = Color3.fromRGB(36, 38, 52)
	header.Text = (defaultOpen and "▼  " or "▶  ") .. titleText
	header.TextColor3 = Color3.fromRGB(255, 200, 80)
	header.Font = Enum.Font.GothamBold
	header.TextSize = 13
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = wrap
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	body.BorderSizePixel = 0
	body.Visible = defaultOpen and true or false
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.Size = UDim2.new(1, 0, 0, 0)
	body.Parent = wrap
	Instance.new("UICorner", body).CornerRadius = UDim.new(0, 6)

	local bodyList = Instance.new("UIListLayout")
	bodyList.Padding = UDim.new(0, 5)
	bodyList.Parent = body

	local bodyPad = Instance.new("UIPadding")
	bodyPad.PaddingTop = UDim.new(0, 6)
	bodyPad.PaddingBottom = UDim.new(0, 8)
	bodyPad.PaddingLeft = UDim.new(0, 6)
	bodyPad.PaddingRight = UDim.new(0, 6)
	bodyPad.Parent = body

	local open = defaultOpen and true or false
	header.MouseButton1Click:Connect(function()
		open = not open
		body.Visible = open
		header.Text = (open and "▼  " or "▶  ") .. titleText
		header.BackgroundColor3 = open and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(36, 38, 52)
		header.TextColor3 = open and Color3.new(1, 1, 1) or Color3.fromRGB(255, 200, 80)
	end)

	if defaultOpen then
		header.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
		header.TextColor3 = Color3.new(1, 1, 1)
	end

	return body
end

local function subHeader(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -2, 0, 20)
	l.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
	l.Text = "  › " .. text
	l.TextColor3 = Color3.fromRGB(170, 180, 210)
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
end

local function toggle(parent, text, key, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -2, 0, 30)
	b.BackgroundColor3 = S[key] and Color3.fromRGB(28, 130, 65) or Color3.fromRGB(42, 44, 56)
	b.Text = "  " .. text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

	local badge = Instance.new("TextLabel")
	badge.Size = UDim2.fromOffset(40, 20)
	badge.Position = UDim2.new(1, -46, 0.5, -10)
	badge.BackgroundColor3 = S[key] and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(60, 60, 70)
	badge.Text = S[key] and "ON" or "OFF"
	badge.TextColor3 = Color3.new(1, 1, 1)
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 10
	badge.Parent = b
	Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)

	b.MouseButton1Click:Connect(function()
		S[key] = not S[key]
		badge.Text = S[key] and "ON" or "OFF"
		badge.BackgroundColor3 = S[key] and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(60, 60, 70)
		b.BackgroundColor3 = S[key] and Color3.fromRGB(28, 130, 65) or Color3.fromRGB(42, 44, 56)
		if cb then cb(S[key]) end
		if key == "WorldESP" and S.WorldESP then scanWorld() end
	end)
end

local function slider(parent, text, key, min, max, isInt)
	local hold = Instance.new("Frame")
	hold.Size = UDim2.new(1, -2, 0, 46)
	hold.BackgroundColor3 = Color3.fromRGB(36, 38, 50)
	hold.Parent = parent
	Instance.new("UICorner", hold).CornerRadius = UDim.new(0, 5)

	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(1, -10, 0, 16)
	lab.Position = UDim2.fromOffset(8, 4)
	lab.BackgroundTransparency = 1
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 11
	lab.TextColor3 = Color3.fromRGB(230, 230, 240)
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.Parent = hold

	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -16, 0, 14)
	bar.Position = UDim2.fromOffset(8, 26)
	bar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
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
	thumb.Size = UDim2.fromOffset(16, 16)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 3
	thumb.Parent = bar
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(180, 40, 40)
	st.Thickness = 2
	st.Parent = thumb

	local function ref()
		local v = S[key]
		lab.Text = text .. ": " .. (isInt and tostring(math.floor(v)) or string.format("%.2f", v))
		local rel = math.clamp((v - min) / math.max(max - min, 1e-6), 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		thumb.Position = UDim2.new(rel, 0, 0.5, 0)
	end
	ref()

	bindSlider(bar, function(x)
		local rel = math.clamp(x / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local v = min + rel * (max - min)
		if isInt then v = math.floor(v + 0.5) end
		S[key] = v
		ref()
	end)
end

local function colorSlider(parent, text, idxKey)
	local hold = Instance.new("Frame")
	hold.Size = UDim2.new(1, -2, 0, 54)
	hold.BackgroundColor3 = Color3.fromRGB(36, 38, 50)
	hold.Parent = parent
	Instance.new("UICorner", hold).CornerRadius = UDim.new(0, 5)

	local swatch = Instance.new("Frame")
	swatch.Size = UDim2.fromOffset(16, 16)
	swatch.Position = UDim2.fromOffset(8, 6)
	swatch.BorderSizePixel = 0
	swatch.Parent = hold
	Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 3)

	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(1, -30, 0, 16)
	lab.Position = UDim2.fromOffset(28, 6)
	lab.BackgroundTransparency = 1
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 11
	lab.TextColor3 = Color3.fromRGB(230, 230, 240)
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.Parent = hold

	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -16, 0, 14)
	bar.Position = UDim2.fromOffset(8, 32)
	bar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	bar.Text = ""
	bar.AutoButtonColor = false
	bar.Parent = hold
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.fromOffset(18, 18)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 3
	thumb.Parent = bar
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Parent = thumb

	local function ref()
		local c, name, idx = colorFromIdx(S[idxKey])
		S[idxKey] = idx
		lab.Text = string.format("%s  %d — %s", text, idx, name)
		swatch.BackgroundColor3 = c
		thumb.BackgroundColor3 = c
		fill.BackgroundColor3 = c
		local rel = (idx - 1) / math.max(COLOR_COUNT - 1, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		thumb.Position = UDim2.new(rel, 0, 0.5, 0)
	end
	ref()

	bindSlider(bar, function(x)
		local rel = math.clamp(x / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local idx = math.floor(rel * (COLOR_COUNT - 1) + 1.5)
		S[idxKey] = math.clamp(idx, 1, COLOR_COUNT)
		ref()
	end)
end

local function multi(parent, title, labels, keys)
	local open = false
	local headerBtn = Instance.new("TextButton")
	headerBtn.Size = UDim2.new(1, -2, 0, 30)
	headerBtn.BackgroundColor3 = Color3.fromRGB(48, 50, 64)
	headerBtn.Text = "  " .. title .. "  ▼"
	headerBtn.TextColor3 = Color3.new(1, 1, 1)
	headerBtn.Font = Enum.Font.Gotham
	headerBtn.TextSize = 12
	headerBtn.TextXAlignment = Enum.TextXAlignment.Left
	headerBtn.Parent = parent
	Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, 5)

	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, -2, 0, #labels * 28)
	box.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
	box.Visible = false
	box.Parent = parent
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
	Instance.new("UIListLayout", box)

	headerBtn.MouseButton1Click:Connect(function()
		open = not open
		box.Visible = open
		headerBtn.Text = "  " .. title .. (open and "  ▲" or "  ▼")
	end)

	for i, labText in ipairs(labels) do
		local key = keys[i]
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 0, 28)
		b.BackgroundColor3 = S[key] and Color3.fromRGB(28, 130, 65) or Color3.fromRGB(42, 44, 56)
		b.Text = "  " .. labText
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.Gotham
		b.TextSize = 12
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Parent = box
		b.MouseButton1Click:Connect(function()
			S[key] = not S[key]
			b.BackgroundColor3 = S[key] and Color3.fromRGB(28, 130, 65) or Color3.fromRGB(42, 44, 56)
			if S.WorldESP then scanWorld() end
		end)
	end
end

-- ========== SUB-PESTAÑAS DESPLEGABLES ==========

-- 1) Highlight ESP Settings (abierta por defecto)
do
	local p = makeAccordion("Highlight ESP Settings", true)
	slider(p, "Transparencia del relleno ESP", "FillT", 0, 1, false)
	slider(p, "Transparencia del contorno ESP", "OutlineT", 0, 1, false)
	slider(p, "Tamaño del texto ESP", "TextSize", 8, 24, true)
end

-- 2) Player Highlight ESP
do
	local p = makeAccordion("Player Highlight ESP", false)
	toggle(p, "Activar ESP de jugadores", "PlayerESP")
	multi(p, "Seleccionar ESP de jugadores", {
		"Sobreviviente",
		"Item de Superviviente",
		"Asesino",
		"Espectador",
	}, { "P_Surv", "P_Item", "P_Killer", "P_Spec" })

	subHeader(p, "Extras")
	toggle(p, "Nametags de jugadores", "Nametags")
	toggle(p, "Distancia ESP de jugadores", "DistP")
	toggle(p, "Advertencia Killer en Superviviente (!)", "KillerWarn")

	subHeader(p, "Colores Survivor")
	toggle(p, "Color Survivor Rainbow", "RainbowSurv")
	colorSlider(p, "Survivor Normal", "IdxSurv")
	colorSlider(p, "Survivor Herido", "IdxSurvHurt")
	colorSlider(p, "Survivor Derribado", "IdxSurvDown")

	subHeader(p, "Colores Killer / Spectator")
	toggle(p, "Color Killer Rainbow", "RainbowKiller")
	colorSlider(p, "Color Killer", "IdxKiller")
	toggle(p, "Color Spectator Rainbow", "RainbowSpec")
	colorSlider(p, "Color Spectator", "IdxSpec")
end

-- 3) World Highlight ESP
do
	local p = makeAccordion("World Highlight ESP", false)
	toggle(p, "Activar ESP del mundo", "WorldESP", function(v)
		if v then scanWorld() end
	end)
	multi(p, "Seleccionar objetos del mundo", {
		"Generators", "Hooks", "Gates", "Windows", "Pallets", "SCP/Zombie",
	}, { "W_Gen", "W_Hook", "W_Gate", "W_Win", "W_Pal", "W_SCP" })

	subHeader(p, "Extras")
	toggle(p, "Nametags del mundo", "NametagsW")
	toggle(p, "Porcentaje del generador", "GenPct")
	toggle(p, "Distancia ESP del mundo", "DistW")

	subHeader(p, "Colores del mundo")
	colorSlider(p, "Color Generator", "IdxGen")
	colorSlider(p, "Color Hook", "IdxHook")
	colorSlider(p, "Color Gate", "IdxGate")
	colorSlider(p, "Color Window", "IdxWin")
	colorSlider(p, "Color Pallet", "IdxPal")
	colorSlider(p, "Color SCP / Zombie", "IdxSCP")
end

-- 4) Lighting
do
	local p = makeAccordion("Lighting", false)
	subHeader(p, "Iluminación")
	toggle(p, "Sin cutscene", "NoCutscene")
	toggle(p, "Sin niebla", "NoFog")
	toggle(p, "Fullbright", "Fullbright", function(v)
		if not v then
			Lighting.Brightness = origLight.Brightness
			Lighting.ClockTime = origLight.ClockTime
			Lighting.FogEnd = origLight.FogEnd
			Lighting.FogStart = origLight.FogStart
			Lighting.GlobalShadows = origLight.GlobalShadows
			Lighting.OutdoorAmbient = origLight.OutdoorAmbient
		end
	end)

	subHeader(p, "Game Info Panel")
	toggle(p, "Display Kyst Killer", "KystKiller")
	toggle(p, "Contador de espectadores", "SpecCounter")
	toggle(p, "Mostrar perks del Killer", "KillerPerks")
	toggle(p, "Predecir mapa", "PredictMap")
	toggle(p, "Ocultar icono de Survivor", "HideSurvIcon")
	toggle(p, "Mostrar Ping y FPS", "PingFPS")
	toggle(p, "Mostrar contador de hooks", "HookCounter")
end

-- 5) Cámara
do
	local p = makeAccordion("Cámara", false)
	toggle(p, "Activar override de FOV", "FOVOn", function(v)
		if not v and Workspace.CurrentCamera then
			Workspace.CurrentCamera.FieldOfView = origLight.FOV
		end
	end)
	slider(p, "FOV de cámara", "FOV", 30, 140, true)
	toggle(p, "Tercera persona (solo Killer)", "ThirdP")
	toggle(p, "Shift Lock", "ShiftLock")
	toggle(p, "Zoom infinito hacia afuera", "InfZoom", function(v)
		if v then
			LP.CameraMaxZoomDistance = math.huge
			LP.CameraMinZoomDistance = 0
		else
			LP.CameraMaxZoomDistance = 128
			LP.CameraMinZoomDistance = 0.5
		end
	end)
end

btnHide.MouseButton1Click:Connect(function()
	setMenuOpen(false)
	openBtn.Visible = false
end)

UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.RightShift then
		openBtn.Visible = true
		setMenuOpen(true)
	end
end)

btnX.MouseButton1Click:Connect(function()
	pcall(function() if espFolder then espFolder:Destroy() end end)
	pcall(function() if infoGui then infoGui:Destroy() end end)
	gui:Destroy()
end)

warn("[VD Visual] sub-pestañas desplegables (acordeón)")

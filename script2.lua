print("[NanoHub] AimLock v1.32 === START ===")

--// SERVICES
local P   = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local TS  = game:GetService("TweenService")
local HS  = game:GetService("HttpService")
local LG  = game:GetService("Lighting")
local ST  = game:GetService("Stats")
local VU  = game:GetService("VirtualUser")
local LP  = P.LocalPlayer
local M   = LP:GetMouse()

--// HELPERS
local function rndName(b) return (b or "A") .. tostring(math.random(10000, 99999)) end
local function ni(c, p) local o = Instance.new(c) if p then for k, v in pairs(p) do o[k] = v end end return o end
local function clamp(x, a, b) if x < a then return a end if x > b then return b end return x end

--// RELOAD-SAFE CLEANUP
_G.NanoAim = _G.NanoAim or {}
local hub = _G.NanoAim

local function removeDraws(t)
	if not t then return end
	for _, d in pairs(t) do
		pcall(function()
			if type(d) == "table" then
				if d.dot then d.dot:Remove() end
				if d.lbl then d.lbl:Remove() end
				if d.Remove then d:Remove() end
			elseif d and d.Remove then
				d:Remove()
			end
		end)
	end
end

local function cleanupAll()
	if hub.conns then
		for _, c in ipairs(hub.conns) do
			pcall(function() if c and c.Connected then c:Disconnect() end end)
		end
		table.clear(hub.conns)
	end
	for _, k in ipairs({ "draws", "distLbls", "wpDraws", "cardDraws" }) do
		removeDraws(hub[k]); hub[k] = nil
	end
	if hub.hbCache then
		for part, size in pairs(hub.hbCache) do
			pcall(function() if part and part.Parent then part.Size = size end end)
		end
		hub.hbCache = nil
	end
	if hub.xrayCache then
		for part in pairs(hub.xrayCache) do
			pcall(function() if part and part.Parent then part.LocalTransparencyModifier = 0 end end)
		end
		hub.xrayCache = nil
	end
	if hub.noclipCache then
		for part, cc in pairs(hub.noclipCache) do
			pcall(function() if part and part.Parent then part.CanCollide = cc end end)
		end
		hub.noclipCache = nil
	end
	if hub.espCache then
		for _, e in pairs(hub.espCache) do
			pcall(function()
				if e.box then e.box:Remove() end
				if e.name then e.name:Remove() end
				if e.tracer then e.tracer:Remove() end
				if e.hpBg then e.hpBg:Remove() end
				if e.hpF then e.hpF:Remove() end
				if e.hl then e.hl:Destroy() end
				if e.skel then for i = 1, #e.skel do if e.skel[i] then e.skel[i]:Remove() end end end
			end)
		end
		hub.espCache = nil
	end
	pcall(function()
		for _, n in ipairs({ "NanoCC", "NanoBloom", "NanoSun" }) do
			local e = LG:FindFirstChild(n)
			if e then e:Destroy() end
		end
		local o = hub.origLight
		if o then
			LG.Brightness = o.Brightness
			LG.ClockTime = o.ClockTime
			LG.FogEnd = o.FogEnd
			LG.FogStart = o.FogStart
			LG.GlobalShadows = o.GlobalShadows
			LG.Ambient = o.Ambient
			LG.OutdoorAmbient = o.OutdoorAmbient
		end
		local cam = workspace.CurrentCamera
		if cam and hub.origZoom then cam.MaxZoomDistance = hub.origZoom end
	end)
	pcall(function()
		local c = LP.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if hrp then
			for _, n in ipairs({ "NHFlyBV", "NHFlyBG" }) do
				local e = hrp:FindFirstChild(n)
				if e then e:Destroy() end
			end
		end
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
			hum.JumpPower = 50
			hum.AutoRotate = true
		end
	end)
	if hub.ui then pcall(function() hub.ui:Destroy() end) hub.ui = nil end
end
cleanupAll()
hub.conns = {}
local function track(c) table.insert(hub.conns, c) return c end

--// COLORS
local ACC  = Color3.fromRGB(150, 100, 255)
local CYAN = Color3.fromRGB(90, 200, 255)
local BG0  = Color3.fromRGB(8, 9, 14)
local BG1  = Color3.fromRGB(13, 15, 23)
local BG2  = Color3.fromRGB(20, 23, 34)
local BG3  = Color3.fromRGB(30, 34, 50)
local BG4  = Color3.fromRGB(42, 48, 70)
local TXT  = Color3.fromRGB(240, 242, 252)
local SUB  = Color3.fromRGB(150, 158, 182)
local RED  = Color3.fromRGB(255, 84, 92)
local GRN  = Color3.fromRGB(96, 226, 138)
local COLR = Color3.fromRGB(255, 90, 120)

--// THEMES
local themeAcc, gradRepaints = {}, {}
local rainbowToken = 0
local function repaint()
	for _, r in ipairs(themeAcc) do pcall(function() r[1][r[2]] = ACC end) end
	for _, fn in ipairs(gradRepaints) do pcall(fn, ACC) end
end
local THEMES = {
	{ name = "Purple", acc = Color3.fromRGB(150, 100, 255), cyan = Color3.fromRGB(90, 200, 255) },
	{ name = "Blue",   acc = Color3.fromRGB(70, 150, 255),  cyan = Color3.fromRGB(120, 220, 255) },
	{ name = "Red",    acc = Color3.fromRGB(255, 90, 90),   cyan = Color3.fromRGB(255, 160, 120) },
	{ name = "Green",  acc = Color3.fromRGB(80, 220, 140),  cyan = Color3.fromRGB(150, 255, 200) },
	{ name = "Orange", acc = Color3.fromRGB(255, 150, 60),  cyan = Color3.fromRGB(255, 210, 120) },
	{ name = "Pink",   acc = Color3.fromRGB(255, 100, 180), cyan = Color3.fromRGB(255, 170, 220) },
	{ name = "Rainbow",acc = Color3.fromRGB(150, 100, 255), cyan = Color3.fromRGB(90, 200, 255) },
}
local THEME_NAMES = { "Purple", "Blue", "Red", "Green", "Orange", "Pink", "Rainbow" }
local function setThemeVars(i)
	i = clamp(i, 1, #THEMES)
	local t = THEMES[i]
	ACC, CYAN = t.acc, t.cyan
	rainbowToken = rainbowToken + 1
	if i == 7 then
		local my = rainbowToken
		task.spawn(function()
			while my == rainbowToken do
				ACC = Color3.fromHSV((tick() % 6) / 6, 0.65, 1)
				repaint()
				task.wait(0.1)
			end
		end)
	else
		repaint()
	end
end

--// SETTINGS
local S = {
	on = false, keyEnabled = true, keyIdx = 1, hitIdx = 1, aimIdx = 1,
	fovR = 200, range = 1000, smooth = 0.35, teamCheck = false, wallCheck = false,
	trigOn = false, trigDelay = 0.05,
	auraOn = false, auraRange = 14, auraCD = 0.5,
	silentOn = false, hbOn = false, hbSize = 8, tLockOn = false, tLockIdx = 1,
	colIdx = 1, showFov = true, showSnap = true, showDot = true, showDist = true,
	crossOn = false, crossSize = 10, crossGap = 4, crossThick = 2,
	espOn = false, espBox = true, espHP = true, hpSide = 1, espTeamCol = false,
	chamsOn = false, chamsFill = 0.6, espName = true, espSkel = false, espTracer = false, espMaxD = 1500,
	cardEspOn = false, cardMaxD = 2000,
	filterOn = false, filterIdx = 1, fContrast = 0.1, fSat = 0, fBright = 0.02, fTintIdx = 1, fBloom = 0, fSun = 0,
	flyOn = false, flySpeed = 60, noclipOn = false, infJumpOn = false, clickTpOn = false, ragdollOn = false,
	wsEnabled = false, wsValue = 16, jpEnabled = false, jpValue = 50,
	fbOn = false, fogOn = false, xrayOn = false, xrayT = 0.55, arrowsOn = false,
	zoomOn = false, zoomVal = 200,
	themeIdx = 1, guiKeyIdx = 1, uiScale = 1, profileIdx = 1,
	fastStart = false, autoSaveAll = true, antiAfkOn = true, panicIdx = 1,
	hkEsp = 1, hkChams = 1, hkFly = 1, hkNoclip = 1, hkInfJump = 1, hkClickTp = 1, hkTrig = 1,
	fpsBoost = false,
}

--// CONFIG
local CFG_DIR = "NanoAim"
local canFS = (type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function")
local NO_SAVE = {
	on = true, flyOn = true, noclipOn = true, infJumpOn = true, clickTpOn = true,
	trigOn = true, auraOn = true, silentOn = true, hbOn = true, tLockOn = true,
	crossOn = true, arrowsOn = true, fbOn = true, fogOn = true, xrayOn = true,
	zoomOn = true, filterOn = true, ragdollOn = true,
}
local CFG_CLAMPS = {
	fovR = { 60, 600 }, range = { 100, 2000 }, smooth = { 0.05, 1 },
	espMaxD = { 100, 5000 }, cardMaxD = { 100, 5000 }, hpSide = { 1, 2 }, chamsFill = { 0, 1 },
	keyIdx = { 1, 8 }, hitIdx = { 1, 4 }, aimIdx = { 1, 2 }, colIdx = { 1, 6 }, tLockIdx = { 1, 8 },
	themeIdx = { 1, 7 }, guiKeyIdx = { 1, 4 }, profileIdx = { 1, 3 }, panicIdx = { 1, 5 },
	filterIdx = { 1, 5 }, fTintIdx = { 1, 6 }, fContrast = { -1, 1 }, fSat = { -1, 1 }, fBright = { -0.5, 0.5 },
	fBloom = { 0, 3 }, fSun = { 0, 1 },
	flySpeed = { 10, 300 }, wsValue = { 8, 200 }, jpValue = { 20, 300 },
	hbSize = { 4, 20 }, crossSize = { 4, 30 }, crossGap = { 0, 15 }, crossThick = { 1, 5 },
	xrayT = { 0.2, 0.9 }, zoomVal = { 50, 400 }, auraRange = { 6, 40 }, auraCD = { 0.1, 2 },
	trigDelay = { 0, 0.5 }, uiScale = { 0.8, 1.5 },
	hkEsp = { 1, 11 }, hkChams = { 1, 11 }, hkFly = { 1, 11 }, hkNoclip = { 1, 11 },
	hkInfJump = { 1, 11 }, hkClickTp = { 1, 11 }, hkTrig = { 1, 11 },
}
local function cfgPath() return CFG_DIR .. "/profile" .. S.profileIdx .. ".json" end
local function applyConfig(d)
	if type(d) ~= "table" then return false end
	for k, v in pairs(d) do
		if k ~= "__version" and not NO_SAVE[k] and S[k] ~= nil and type(v) == type(S[k]) then
			local c = CFG_CLAMPS[k]
			if c then S[k] = clamp(v, c[1], c[2]) else S[k] = v end
		end
	end
	return true
end
local function saveConfigNow()
	if not canFS then return false end
	return pcall(function()
		if makefolder and isfolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
		writefile(cfgPath(), HS:JSONEncode(S))
	end)
end
local pendingSave = false
local function queueSave()
	if not S.autoSaveAll or not canFS then return end
	if pendingSave then return end
	pendingSave = true
	task.delay(0.7, function()
		pendingSave = false
		if S.autoSaveAll then saveConfigNow() end
	end)
end
if canFS then
	pcall(function()
		if isfile(cfgPath()) then
			local ok, data = pcall(function() return HS:JSONDecode(readfile(cfgPath())) end)
			if ok and type(data) == "table" then applyConfig(data) end
		end
	end)
end
setThemeVars(S.themeIdx)

--// CONSTANTS
local KEYNAMES = { "E", "Q", "F", "X", "V", "C", "T", "Y" }
local KEYCODES = { Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.F, Enum.KeyCode.X, Enum.KeyCode.V, Enum.KeyCode.C, Enum.KeyCode.T, Enum.KeyCode.Y }
local HITS = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
local AIMMODES = { "Rage", "Smooth" }
local COLNAMES = { "Red", "Purple", "Cyan", "Green", "White", "Rainbow" }
local HP_SIDES = { "Links", "Rechts" }
local HK_NAMES = { "-", "E", "Q", "F", "X", "V", "C", "T", "G", "H", "J" }
local HK_CODES = { nil, Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.F, Enum.KeyCode.X, Enum.KeyCode.V, Enum.KeyCode.C, Enum.KeyCode.T, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.J }
local PANIC_NAMES = { "B", "N", "M", "K", "-" }
local PANIC_CODES = { Enum.KeyCode.B, Enum.KeyCode.N, Enum.KeyCode.M, Enum.KeyCode.K, nil }
local GUIKEYS = { "RightAlt", "RightCtrl", "F2", "F3" }
local GUIKEY_CODES = { Enum.KeyCode.RightAlt, Enum.KeyCode.RightCtrl, Enum.KeyCode.F2, Enum.KeyCode.F3 }
local TINT_NAMES = { "Aus", "Rot", "Blau", "Grün", "Orange", "Violett" }
local TINT_COLS = { nil, Color3.fromRGB(255, 120, 120), Color3.fromRGB(120, 170, 255), Color3.fromRGB(120, 255, 150), Color3.fromRGB(255, 200, 120), Color3.fromRGB(200, 140, 255) }
local FILTER_NAMES = { "Realistic", "Cinematic", "Vibrant", "Cold", "Warm" }
local FILTER_PRESETS = {
	Realistic = { fContrast = 0.15, fSat = -0.15, fBright = 0.02, fTintIdx = 1, fBloom = 0.15, fSun = 0.15 },
	Cinematic = { fContrast = 0.25, fSat = -0.3, fBright = 0, fTintIdx = 5, fBloom = 0.2, fSun = 0.1 },
	Vibrant = { fContrast = 0.1, fSat = 0.35, fBright = 0.03, fTintIdx = 1, fBloom = 0.25, fSun = 0.05 },
	Cold = { fContrast = 0.1, fSat = -0.1, fBright = 0.03, fTintIdx = 3, fBloom = 0.1, fSun = 0 },
	Warm = { fContrast = 0.1, fSat = 0.05, fBright = 0.04, fTintIdx = 5, fBloom = 0.15, fSun = 0.2 },
}
local CARD_KEYS = { "card", "pack", "booster", "crate", "egg" }
local RAR = {
	{ "secret", RED }, { "mythic", Color3.fromRGB(255, 80, 200) }, { "legend", Color3.fromRGB(255, 150, 50) },
	{ "epic", Color3.fromRGB(170, 80, 255) }, { "rare", Color3.fromRGB(70, 150, 255) }, { "common", Color3.fromRGB(200, 200, 200) },
}

--// CHAR HELPERS
local function getHum() local c = LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c = LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function isAlly(pl)
	if pl == LP then return true end
	if not S.teamCheck then return false end
	return LP.Team ~= nil and pl.Team ~= nil and LP.Team == pl.Team
end
local function drawColor()
	local nm = COLNAMES[S.colIdx]
	if nm == "Rainbow" then return Color3.fromHSV((tick() % 5) / 5, 0.75, 1)
	elseif nm == "Purple" then return ACC
	elseif nm == "Cyan" then return CYAN
	elseif nm == "Green" then return Color3.fromRGB(90, 255, 120)
	elseif nm == "White" then return Color3.fromRGB(240, 240, 240) end
	return COLR
end
local function worldFromMouse()
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local ray = cam:ScreenPointToRay(M.X, M.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ex = {}
	if LP.Character then table.insert(ex, LP.Character) end
	params.FilterDescendantsInstances = ex
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	if hit then return hit.Position end
	return ray.Origin + ray.Direction * 300
end

--// TP-HISTORY
hub.tpHistory = hub.tpHistory or {}
local function recordTP(name, cf)
	if not cf then return end
	for i, e in ipairs(hub.tpHistory) do
		if e.name == name then table.remove(hub.tpHistory, i) break end
	end
	table.insert(hub.tpHistory, 1, { name = name, cf = cf })
	if #hub.tpHistory > 5 then table.remove(hub.tpHistory) end
	if hub.refreshTPHist then pcall(hub.refreshTPHist) end
end
local function tpTo(pl)
	local c = pl.Character
	local hrp = c and c:FindFirstChild("HumanoidRootPart")
	local my = getHRP()
	if hrp and my then
		recordTP(pl.Name, my.CFrame)
		my.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
	end
end

--// SPECTATE
local spectating = nil
local function stopSpectate()
	local myHum = getHum()
	local cam = workspace.CurrentCamera
	if cam and myHum then cam.CameraSubject = myHum end
	spectating = nil
end
local function toggleSpectate(pl)
	if spectating == pl then stopSpectate() return false end
	spectating = pl
	local c = pl.Character
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	local cam = workspace.CurrentCamera
	if cam and hum then cam.CameraSubject = hum end
	return true
end
track(RS.Heartbeat:Connect(function()
	if spectating then
		local c = spectating.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		local cam = workspace.CurrentCamera
		if cam and hum and hum.Health > 0 and cam.CameraSubject ~= hum then
			cam.CameraSubject = hum
		end
	end
end))

--// DRAWING
local canDraw = false
pcall(function() local t = Drawing.new("Line") t:Remove() canDraw = true end)
local canFire = (type(mouse1press) == "function")
hub.draws = {}
local fovC, snapL, headD
if canDraw then
	fovC = Drawing.new("Circle")
	fovC.Thickness = 1; fovC.NumSides = 64; fovC.Filled = false; fovC.Visible = false
	snapL = Drawing.new("Line")
	snapL.Thickness = 1; snapL.Visible = false
	headD = Drawing.new("Circle")
	headD.Thickness = 1; headD.NumSides = 24; headD.Filled = false; headD.Visible = false
	table.insert(hub.draws, fovC); table.insert(hub.draws, snapL); table.insert(hub.draws, headD)
end
local crossDot, crossLines
if canDraw then
	crossDot = Drawing.new("Circle")
	crossDot.Thickness = 1; crossDot.NumSides = 16; crossDot.Filled = true; crossDot.Visible = false
	table.insert(hub.draws, crossDot)
	crossLines = {}
	for i = 1, 4 do
		local ln = Drawing.new("Line")
		ln.Thickness = 2; ln.Visible = false
		crossLines[i] = ln
		table.insert(hub.draws, ln)
	end
end
hub.arrowPool = {}
if canDraw then
	for i = 1, 8 do
		local t = Drawing.new("Triangle")
		t.Thickness = 2; t.Filled = true; t.Visible = false
		hub.arrowPool[i] = t
		table.insert(hub.draws, t)
	end
end
hub.distLbls = {}

--// ESP CACHE
local R6_BONES = {
	{ "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" }, { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}
local R15_BONES = {
	{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}
local function bonePos(c, nm)
	local p = c:FindFirstChild(nm)
	if p and p:IsA("BasePart") then return p.Position end
	return nil
end
hub.espCache = {}
local function espClearOne(pl)
	local e = hub.espCache[pl]
	if not e then return end
	pcall(function()
		if e.box then e.box:Remove() end
		if e.name then e.name:Remove() end
		if e.tracer then e.tracer:Remove() end
		if e.hpBg then e.hpBg:Remove() end
		if e.hpF then e.hpF:Remove() end
		if e.hl then e.hl:Destroy() end
		if e.skel then for i = 1, #e.skel do if e.skel[i] then e.skel[i]:Remove() end end end
	end)
	hub.espCache[pl] = nil
end
local function espClearAll() for pl in pairs(hub.espCache) do espClearOne(pl) end end

--// TARGETING
local function isVisible(part)
	local cam = workspace.CurrentCamera
	if not cam then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ex = {}
	if LP.Character then table.insert(ex, LP.Character) end
	if part.Parent then table.insert(ex, part.Parent) end
	params.FilterDescendantsInstances = ex
	local hit = workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, params)
	return hit == nil
end
local function findTarget()
	local cam = workspace.CurrentCamera
	if not cam then return nil, nil, nil end
	local myHrp = getHRP()
	local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local best, bestPart, bestSp = nil, nil, nil
	local bestD = math.huge
	for _, pl in ipairs(P:GetPlayers()) do
		if pl ~= LP and not isAlly(pl) then
			local c = pl.Character
			if c then
				local hum = c:FindFirstChildOfClass("Humanoid")
				local part = c:FindFirstChild(HITS[S.hitIdx])
				if hum and hum.Health > 0 and part then
					local sp, on = cam:WorldToViewportPoint(part.Position)
					if on then
						local sp2 = Vector2.new(sp.X, sp.Y)
						local d = (sp2 - center).Magnitude
						if d <= S.fovR and d < bestD then
							local okRange = true
							if myHrp then okRange = (part.Position - myHrp.Position).Magnitude <= S.range end
							if okRange and (not S.wallCheck or isVisible(part)) then
								bestD = d
								best, bestPart, bestSp = pl, part, sp2
							end
						end
					end
				end
			end
		end
	end
	return best, bestPart, bestSp
end

--// UI ROOT
local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
local ui = ni("ScreenGui", {
	Name = rndName("NH"), ResetOnSpawn = false, IgnoreGuiInset = true,
	DisplayOrder = 50, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = pg,
})
hub.ui = ui

local curToast = nil
local toastGen = 0
local function toast(msg, col)
	toastGen = toastGen + 1
	local myGen = toastGen
	if curToast then pcall(function() curToast:Destroy() end) curToast = nil end
	local f = ni("Frame", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -40),
		Size = UDim2.new(0, 190, 0, 34), BackgroundColor3 = BG2, BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 50, Parent = ui,
	})
	curToast = f
	ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = f })
	local st = ni("UIStroke", { Color = col, Thickness = 1, Transparency = 1, Parent = f })
	local lb = ni("TextLabel", {
		Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
		Text = msg, TextColor3 = col, TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 51, Parent = f,
	})
	TS:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 1, -70) }):Play()
	TS:Create(st, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.5 }):Play()
	TS:Create(lb, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
	task.delay(1.4, function()
		if myGen ~= toastGen then return end
		pcall(function()
			TS:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 1, -40) }):Play()
			TS:Create(st, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
			TS:Create(lb, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
		end)
		task.wait(0.35)
		if curToast == f then curToast = nil end
		pcall(function() f:Destroy() end)
	end)
end

--// WINDOW
local WIN_W, WIN_H = 470, 470
local HEAD, SB_W = 46, 120
local win = ni("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, WIN_W, 0, WIN_H), BackgroundColor3 = BG1,
	BorderSizePixel = 0, Visible = false, Parent = ui,
})
ni("UICorner", { CornerRadius = UDim.new(0, 14), Parent = win })
local winStroke = ni("UIStroke", { Color = ACC, Transparency = 0.4, Thickness = 1.4, Parent = win })
table.insert(themeAcc, { winStroke, "Color" })
ni("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(198, 203, 224)),
	}),
	Rotation = 100, Parent = win,
})
local uiScaleObj = ni("UIScale", { Scale = S.uiScale, Parent = win })

local header = ni("Frame", { Size = UDim2.new(1, 0, 0, HEAD), BackgroundColor3 = BG0, BorderSizePixel = 0, Parent = win })
ni("UICorner", { CornerRadius = UDim.new(0, 14), Parent = header })
local title = ni("TextLabel", {
	Position = UDim2.new(0, 14, 0, 5), Size = UDim2.new(0, 150, 0, 24), BackgroundTransparency = 1,
	Text = "NanoHub", TextColor3 = ACC, TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold, TextSize = 17, Parent = header,
})
table.insert(themeAcc, { title, "TextColor3" })
ni("TextLabel", {
	Position = UDim2.new(0, 14, 0, 26), Size = UDim2.new(0, 240, 0, 14), BackgroundTransparency = 1,
	Text = "AimLock v1.32  •  " .. LP.DisplayName, TextColor3 = SUB,
	TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 11, Parent = header,
})
local accBar = ni("Frame", { Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = ACC, BorderSizePixel = 0, Parent = header })
table.insert(themeAcc, { accBar, "BackgroundColor3" })
local accBarGrad = ni("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, ACC),
		ColorSequenceKeypoint.new(1, CYAN),
	}),
	Parent = accBar,
})
table.insert(gradRepaints, function(col)
	pcall(function()
		accBarGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, col),
			ColorSequenceKeypoint.new(1, CYAN),
		})
	end)
end)
local wkDot = ni("Frame", { Position = UDim2.new(0.5, -34, 0.5, -4), Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = GRN, BorderSizePixel = 0, Parent = header })
ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = wkDot })
ni("TextLabel", {
	Position = UDim2.new(0.5, -20, 0, 0), Size = UDim2.new(0, 70, 1, 0), BackgroundTransparency = 1,
	Text = "working", TextColor3 = GRN, Font = Enum.Font.GothamBold, TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
})
task.spawn(function()
	while win.Parent do
		pcall(function() TS:Create(wkDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.6 }):Play() end)
		task.wait(0.6)
		pcall(function() TS:Create(wkDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }):Play() end)
		task.wait(0.6)
	end
end)

local closeBtn = ni("TextButton", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 10), Size = UDim2.new(0, 26, 0, 26),
	BackgroundColor3 = BG3, BorderSizePixel = 0, Text = "X", TextColor3 = RED,
	Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, Parent = header,
})
ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeBtn })
local hideBtn = ni("TextButton", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -40, 0, 10), Size = UDim2.new(0, 26, 0, 26),
	BackgroundColor3 = BG3, BorderSizePixel = 0, Text = "—", TextColor3 = SUB,
	Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, Parent = header,
})
ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = hideBtn })
local miniBtn = ni("TextButton", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -72, 0, 10), Size = UDim2.new(0, 26, 0, 26),
	BackgroundColor3 = BG3, BorderSizePixel = 0, Text = "▣", TextColor3 = SUB,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = header,
})
ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = miniBtn })

local miniBadge = ni("TextButton", {
	AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 20, 1, -20), Size = UDim2.new(0, 42, 0, 42),
	BackgroundColor3 = ACC, BorderSizePixel = 0, Text = "NH", TextColor3 = Color3.fromRGB(15, 15, 20),
	Font = Enum.Font.GothamBold, TextSize = 14, Visible = false, AutoButtonColor = false, Parent = ui,
})
ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = miniBadge })
miniBtn.MouseButton1Click:Connect(function()
	win.Visible = false
	miniBadge.Visible = true
end)
miniBadge.MouseButton1Click:Connect(function()
	miniBadge.Visible = false
	win.Visible = true
end)
hideBtn.MouseButton1Click:Connect(function()
	win.Visible = false
end)
closeBtn.MouseButton1Click:Connect(function()
	rainbowToken = rainbowToken + 1
	cleanupAll()
end)

--// CONTENT + TABS
local content = ni("Frame", { Position = UDim2.new(0, SB_W, 0, HEAD), Size = UDim2.new(1, -SB_W, 1, -HEAD), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = win })
local pages = {}
for i = 1, 9 do
	local pf = ni("ScrollingFrame", {
		Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = ACC, CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = content,
	})
	ni("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = pf })
	pages[i] = pf
end
local homePage, aimPage, visPage, espPage, filterPage, movePage, plrPage, wpPage, setPage = pages[1], pages[2], pages[3], pages[4], pages[5], pages[6], pages[7], pages[8], pages[9]

local function showTab(i)
	for j = 1, #pages do
		pages[j].Visible = (j == i)
		tabBtnsSet(j, j == i)
	end
end
local tabBtns, tabAcc = {}, {}
function tabBtnsSet(j, sel)
	tabBtns[j].BackgroundColor3 = sel and BG4 or BG2
	tabBtns[j].TextColor3 = sel and TXT or SUB
	pcall(function() TS:Create(tabAcc[j], TweenInfo.new(0.18), { BackgroundTransparency = sel and 0 or 1 }):Play() end)
end
local sidebar = ni("Frame", {
	Position = UDim2.new(0, 0, 0, HEAD), Size = UDim2.new(0, SB_W, 1, -HEAD),
	BackgroundColor3 = BG0, BackgroundTransparency = 0.25, BorderSizePixel = 0, Parent = win,
})
local TABS = {
	{ "🏠", "Home" }, { "🎯", "AimLock" }, { "👁️", "Visuals" }, { "🃏", "ESP" },
	{ "🎞️", "Filter" }, { "🏃", "Movement" }, { "👥", "Players" },
	{ "📍", "Waypoints" }, { "⚙️", "Settings" },
}
for i, t in ipairs(TABS) do
	local b = ni("TextButton", {
		Position = UDim2.new(0, 8, 0, 8 + (i - 1) * 44), Size = UDim2.new(1, -16, 0, 36),
		BackgroundColor3 = BG2, BorderSizePixel = 0, Text = "  " .. t[1] .. " " .. t[2],
		TextColor3 = SUB, Font = Enum.Font.GothamMedium, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = sidebar,
	})
	ni("UICorner", { CornerRadius = UDim.new(0, 9), Parent = b })
	local acc = ni("Frame", {
		Position = UDim2.new(0, 0, 0.5, -9), Size = UDim2.new(0, 3, 0, 18),
		BackgroundColor3 = ACC, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = b,
	})
	table.insert(themeAcc, { acc, "BackgroundColor3" })
	tabBtns[i] = b
	tabAcc[i] = acc
	b.MouseButton1Click:Connect(function() showTab(i) end)
end
ni("TextLabel", {
	Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1,
	Text = "E = AimLock  •  GUI-Taste = GUI  •  v1.32", TextColor3 = SUB, Font = Enum.Font.Gotham,
	TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 22), Parent = win,
})

--// DRAGGING
local dragging = false
local dragStart, startPos
header.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = inp.Position
		startPos = win.Position
	end
end)
track(UIS.InputChanged:Connect(function(inp)
	if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
		local delta = inp.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end))
track(UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end))

--// ROW HELPERS
local APPLY = {}
local CTRLS = {}
local function mkRow(page)
	local row = ni("TextButton", {
		Size = UDim2.new(1, -16, 0, 32), BackgroundColor3 = BG2, BorderSizePixel = 0,
		Text = "", AutoButtonColor = false, Parent = page,
	})
	ni("UICorner", { CornerRadius = UDim.new(0, 9), Parent = row })
	local hs = ni("UIStroke", { Color = BG4, Thickness = 1, Transparency = 1, Parent = row })
	row.MouseEnter:Connect(function()
		TS:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = BG3 }):Play()
		TS:Create(hs, TweenInfo.new(0.12), { Transparency = 0.4 }):Play()
	end)
	row.MouseLeave:Connect(function()
		TS:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = BG2 }):Play()
		TS:Create(hs, TweenInfo.new(0.12), { Transparency = 1 }):Play()
	end)
	return row
end
local function addHeader(page, text)
	local h = ni("Frame", { Size = UDim2.new(1, -16, 0, 22), BackgroundTransparency = 1, Parent = page })
	local bar = ni("Frame", { Position = UDim2.new(0, 2, 0, 5), Size = UDim2.new(0, 3, 0, 12), BackgroundColor3 = ACC, BorderSizePixel = 0, Parent = h })
	table.insert(themeAcc, { bar, "BackgroundColor3" })
	ni("TextLabel", {
		Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1,
		Text = string.upper(text), TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = h,
	})
	return h
end
local function addToggle(page, titleTxt, key, doToast)
	local row = mkRow(page)
	ni("TextLabel", {
		Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1,
		Text = titleTxt, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	local dot = ni("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -50, 0.5, 0),
		Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = RED, BorderSizePixel = 0, Parent = row,
	})
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
	local sw = ni("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 34, 0, 18), BackgroundColor3 = RED, BorderSizePixel = 0, Parent = row,
	})
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
	local knob = ni("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Color3.fromRGB(240, 242, 252), BorderSizePixel = 0, Parent = sw,
	})
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	local val = S[key]
	local inited = false
	local function setOn(v, silent)
		local changed = (v ~= val)
		val = v
		S[key] = v
		local c = v and GRN or RED
		dot.BackgroundColor3 = c
		pcall(function()
			TS:Create(sw, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = c }):Play()
			TS:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = v and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }):Play()
		end)
		if APPLY[key] then pcall(APPLY[key], v) end
		if doToast and inited and changed and not silent then
			toast(titleTxt .. (v and "  AN" or "  AUS"), v and GRN or RED)
		end
		if changed then queueSave() end
	end
	row.MouseButton1Click:Connect(function() setOn(not val) end)
	setOn(val, true)
	inited = true
	CTRLS[key] = { set = function(v, silent) setOn(v, silent) end }
	return CTRLS[key]
end
local function addCycle(page, titleTxt, key, items, onSet)
	local row = mkRow(page)
	ni("TextLabel", {
		Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -130, 1, 0), BackgroundTransparency = 1,
		Text = titleTxt, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	local pill = ni("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 104, 0, 20), BackgroundColor3 = BG0, BorderSizePixel = 0, Parent = row,
	})
	ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = pill })
	local val = ni("TextLabel", {
		Position = UDim2.new(0, 5, 0, 0), Size = UDim2.new(1, -10, 1, 0), BackgroundTransparency = 1,
		Text = items[S[key]] or "?", TextColor3 = ACC, Font = Enum.Font.GothamBold, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Parent = pill,
	})
	table.insert(themeAcc, { val, "TextColor3" })
	row.MouseButton1Click:Connect(function()
		S[key] = (S[key] % #items) + 1
		val.Text = items[S[key]]
		if onSet then pcall(onSet, S[key]) end
		queueSave()
	end)
	CTRLS[key] = { set = function(v)
		v = clamp(v, 1, #items)
		S[key] = v
		val.Text = items[v]
		if onSet then pcall(onSet, v) end
	end }
	return CTRLS[key]
end
local function addSlider(page, titleTxt, key, mn, mx, step, fmt)
	local row = mkRow(page)
	row.Size = UDim2.new(1, -16, 0, 46)
	ni("TextLabel", {
		Position = UDim2.new(0, 10, 0, 7), Size = UDim2.new(1, -110, 0, 16), BackgroundTransparency = 1,
		Text = titleTxt, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	local pill = ni("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 6), Size = UDim2.new(0, 78, 0, 18),
		BackgroundColor3 = BG0, BorderSizePixel = 0, Parent = row,
	})
	ni("UICorner", { CornerRadius = UDim.new(0, 9), Parent = pill })
	local val = ni("TextLabel", {
		Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -8, 1, 0), BackgroundTransparency = 1,
		Text = "", TextColor3 = ACC, Font = Enum.Font.GothamBold, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right, Parent = pill,
	})
	table.insert(themeAcc, { val, "TextColor3" })
	local bar = ni("Frame", { Position = UDim2.new(0, 12, 1, -16), Size = UDim2.new(1, -24, 0, 5), BackgroundColor3 = BG4, BorderSizePixel = 0, Parent = row })
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
	local fill = ni("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = ACC, BorderSizePixel = 0, Parent = bar })
	table.insert(themeAcc, { fill, "BackgroundColor3" })
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
	local knob = ni("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Color3.fromRGB(240, 242, 252), BorderSizePixel = 0, Parent = bar,
	})
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	local function paint()
		local ratio = clamp((S[key] - mn) / (mx - mn), 0, 1)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		knob.Position = UDim2.new(ratio, 0, 0.5, 0)
		val.Text = fmt and fmt(S[key]) or tostring(S[key])
	end
	local function setFromX(x)
		local span = bar.AbsoluteSize.X
		if span <= 0 then return end
		local ratio = clamp((x - bar.AbsolutePosition.X) / span, 0, 1)
		local raw = mn + ratio * (mx - mn)
		local snapped = mn + math.floor((raw - mn) / step + 0.5) * step
		local nv = clamp(snapped, mn, mx)
		if nv ~= S[key] then
			S[key] = nv
			paint()
			if APPLY[key] then pcall(APPLY[key], nv) end
			queueSave()
		end
	end
	local draggingS = false
	row.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			draggingS = true
			setFromX(inp.Position.X)
		end
	end)
	track(UIS.InputChanged:Connect(function(inp)
		if draggingS and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			setFromX(inp.Position.X)
		end
	end))
	track(UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			draggingS = false
		end
	end))
	CTRLS[key] = { set = function(v) S[key] = clamp(v, mn, mx) paint() end }
	paint()
end
local function addButton(page, titleTxt, cb)
	local row = mkRow(page)
	ni("TextLabel", {
		Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1,
		Text = titleTxt, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	row.MouseButton1Click:Connect(function()
		pcall(function()
			TS:Create(row, TweenInfo.new(0.08), { Size = UDim2.new(1, -26, 0, 29) }):Play()
		end)
		task.delay(0.1, function()
			pcall(function() TS:Create(row, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(1, -16, 0, 32) }):Play() end)
		end)
		pcall(cb)
	end)
end
local function addInput(page, titleTxt, placeholder, onEnter)
	local row = ni("Frame", { Size = UDim2.new(1, -16, 0, 32), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = page })
	ni("UICorner", { CornerRadius = UDim.new(0, 9), Parent = row })
	ni("TextLabel", {
		Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -180, 1, 0), BackgroundTransparency = 1,
		Text = titleTxt, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	local tb = ni("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 160, 0, 22),
		BackgroundColor3 = BG0, BorderSizePixel = 0, Text = "", PlaceholderText = placeholder,
		PlaceholderColor3 = SUB, TextColor3 = TXT, Font = Enum.Font.Gotham, TextSize = 12,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	ni("UICorner", { CornerRadius = UDim.new(0, 7), Parent = tb })
	tb.FocusLost:Connect(function(enter)
		if enter and tb.Text ~= "" then
			local txt = tb.Text
			tb.Text = ""
			pcall(onEnter, txt)
		end
	end)
	return tb
end
local function syncUI()
	for key, ctrl in pairs(CTRLS) do
		pcall(function()
			if ctrl and ctrl.set then ctrl.set(S[key], true) end
		end)
	end
end

--// APPLY: WORLD / FILTER / FLY / NOCLIP
APPLY.fbOn = function(v)
	pcall(function()
		if not hub.origLight then
			hub.origLight = {
				Brightness = LG.Brightness, ClockTime = LG.ClockTime, FogEnd = LG.FogEnd, FogStart = LG.FogStart,
				GlobalShadows = LG.GlobalShadows, Ambient = LG.Ambient, OutdoorAmbient = LG.OutdoorAmbient,
			}
		end
		if v then
			LG.Brightness = 3
			LG.ClockTime = 14
			LG.GlobalShadows = false
			LG.Ambient = Color3.fromRGB(200, 200, 200)
			LG.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		else
			local o = hub.origLight
			if o then
				LG.Brightness = o.Brightness
				LG.ClockTime = o.ClockTime
				LG.GlobalShadows = o.GlobalShadows
				LG.Ambient = o.Ambient
				LG.OutdoorAmbient = o.OutdoorAmbient
			end
		end
	end)
end
APPLY.fogOn = function(v)
	pcall(function()
		if not hub.origLight then
			hub.origLight = {
				Brightness = LG.Brightness, ClockTime = LG.ClockTime, FogEnd = LG.FogEnd, FogStart = LG.FogStart,
				GlobalShadows = LG.GlobalShadows, Ambient = LG.Ambient, OutdoorAmbient = LG.OutdoorAmbient,
			}
		end
		if v then
			LG.FogEnd = 100000
			LG.FogStart = 0
		else
			local o = hub.origLight
			if o then
				LG.FogEnd = o.FogEnd
				LG.FogStart = o.FogStart
			end
		end
	end)
end
APPLY.zoomOn = function(v)
	pcall(function()
		local cam = workspace.CurrentCamera
		if not cam then return end
		if not hub.origZoom then hub.origZoom = cam.MaxZoomDistance end
		if v then
			cam.MaxZoomDistance = S.zoomVal
		else
			cam.MaxZoomDistance = hub.origZoom
		end
	end)
end
APPLY.zoomVal = function(v)
	pcall(function()
		if S.zoomOn and workspace.CurrentCamera then workspace.CurrentCamera.MaxZoomDistance = v end
	end)
end
local function xrayScan()
	if not hub.xrayCache then hub.xrayCache = {} end
	local n = 0
	for _, d in ipairs(workspace:GetDescendants()) do
		if n > 400 then break end
		if d:IsA("BasePart") and d.Transparency < 0.95 and not d:IsDescendantOf(LP.Character) then
			local skip = d.Parent and d.Parent:FindFirstChildOfClass("Humanoid") ~= nil
			if not skip then
				pcall(function() d.LocalTransparencyModifier = S.xrayT end)
				if not hub.xrayCache[d] then
					hub.xrayCache[d] = true
					n = n + 1
				end
			end
		end
	end
end
APPLY.xrayOn = function(v)
	if v then
		xrayScan()
	elseif hub.xrayCache then
		for part in pairs(hub.xrayCache) do
			pcall(function() if part and part.Parent then part.LocalTransparencyModifier = 0 end end)
		end
		hub.xrayCache = nil
	end
end
APPLY.xrayT = function(v)
	if S.xrayOn and hub.xrayCache then
		for part in pairs(hub.xrayCache) do
			pcall(function() if part and part.Parent then part.LocalTransparencyModifier = v end end)
		end
	end
end
local function ensureFX()
	local cc = LG:FindFirstChild("NanoCC")
	if not cc then cc = ni("ColorCorrectionEffect", { Name = "NanoCC", Parent = LG }) end
	local bl = LG:FindFirstChild("NanoBloom")
	if not bl then bl = ni("BloomEffect", { Name = "NanoBloom", Parent = LG }) end
	local sr = LG:FindFirstChild("NanoSun")
	if not sr then sr = ni("SunRaysEffect", { Name = "NanoSun", Parent = LG }) end
	return cc, bl, sr
end
local function applyFilter()
	pcall(function()
		if not S.filterOn then
			for _, n in ipairs({ "NanoCC", "NanoBloom", "NanoSun" }) do
				local e = LG:FindFirstChild(n)
				if e then e.Enabled = false end
			end
			return
		end
		local cc, bl, sr = ensureFX()
		cc.Enabled = true
		cc.Contrast = S.fContrast
		cc.Saturation = S.fSat
		cc.Brightness = S.fBright
		cc.TintColor = TINT_COLS[S.fTintIdx] or Color3.new(1, 1, 1)
		bl.Enabled = S.fBloom > 0.01
		bl.Intensity = S.fBloom
		bl.Size = 24
		bl.Threshold = 0.95
		sr.Enabled = S.fSun > 0.01
		sr.Intensity = S.fSun
	end)
end
for _, k in ipairs({ "fContrast", "fSat", "fBright", "fTintIdx", "fBloom", "fSun" }) do
	APPLY[k] = function() applyFilter() end
end
local function applyFilterPreset()
	local p = FILTER_PRESETS[FILTER_NAMES[S.filterIdx]]
	if p then
		for k, v in pairs(p) do S[k] = v end
		syncUI()
	end
	applyFilter()
end
APPLY.filterOn = function(v) applyFilter() end
local flyBV, flyBG = nil, nil
APPLY.flyOn = function(v)
	pcall(function()
		local hrp = getHRP()
		if v and hrp then
			flyBV = ni("BodyVelocity", { Name = "NHFlyBV", MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero, Parent = hrp })
			flyBG = ni("BodyGyro", { Name = "NHFlyBG", MaxTorque = Vector3.new(1e9, 1e9, 1e9), P = 100000, D = 500, Parent = hrp })
		else
			if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
			if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
			local hum = getHum()
			if hum then hum.AutoRotate = true end
		end
	end)
end
hub.noclipCache = {}
APPLY.noclipOn = function(v)
	if not v then
		for part, cc in pairs(hub.noclipCache) do
			pcall(function() if part and part.Parent then part.CanCollide = cc end end)
		end
		hub.noclipCache = {}
	end
end
APPLY.fpsBoost = function(v)
	pcall(function()
		if v then
			LG.GlobalShadows = false
			pcall(function() workspace.Terrain.Decoration = false end)
			pcall(function() settings().Rendering.QualityLevel = 1 end)
		else
			pcall(function() workspace.Terrain.Decoration = true end)
		end
	end)
end

--// ============ HOME TAB ============
do
	local card = ni("Frame", { Size = UDim2.new(1, -16, 0, 84), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = homePage })
	ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
	local ava = ni("ImageButton", {
		Position = UDim2.new(0, 10, 0.5, -32), Size = UDim2.new(0, 64, 0, 64),
		BackgroundColor3 = BG3, BorderSizePixel = 0, AutoButtonColor = false, Parent = card,
	})
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ava })
	local avaStroke = ni("UIStroke", { Color = ACC, Thickness = 2, Transparency = 0.25, Parent = ava })
	table.insert(themeAcc, { avaStroke, "Color" })
	task.spawn(function()
		local ok, c = pcall(function()
			return P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.AvatarHeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if ok and c and ava.Parent then ava.Image = c end
	end)
	task.spawn(function()
		while ava and ava.Parent do
			pcall(function() TS:Create(avaStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 3.5, Transparency = 0 }):Play() end)
			task.wait(0.9)
			pcall(function() TS:Create(avaStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 2, Transparency = 0.25 }):Play() end)
			task.wait(0.9)
		end
	end)
	ava.MouseButton1Click:Connect(function()
		S.themeIdx = (S.themeIdx % #THEMES) + 1
		setThemeVars(S.themeIdx)
		if CTRLS.themeIdx then CTRLS.themeIdx.set(S.themeIdx) end
		toast("Theme: " .. THEME_NAMES[S.themeIdx], ACC)
		pcall(function()
			TS:Create(ava, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 70, 0, 70) }):Play()
			task.delay(0.12, function()
				TS:Create(ava, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 64, 0, 64) }):Play()
			end)
		end)
		queueSave()
	end)
	ni("TextLabel", {
		Position = UDim2.new(0, 86, 0, 14), Size = UDim2.new(1, -96, 0, 24), BackgroundTransparency = 1,
		Text = LP.DisplayName, TextColor3 = TXT, TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold, TextSize = 17, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	ni("TextLabel", {
		Position = UDim2.new(0, 86, 0, 40), Size = UDim2.new(1, -96, 0, 16), BackgroundTransparency = 1,
		Text = "@" .. LP.Name, TextColor3 = SUB, TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	ni("TextLabel", {
		Position = UDim2.new(0, 86, 0, 58), Size = UDim2.new(1, -96, 0, 14), BackgroundTransparency = 1,
		Text = "ID: " .. tostring(LP.UserId), TextColor3 = SUB, TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham, TextSize = 11, Parent = card,
	})

	local banner = ni("Frame", { Size = UDim2.new(1, -16, 0, 44), BackgroundColor3 = ACC, BorderSizePixel = 0, Parent = homePage })
	banner.ClipsDescendants = true
	ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = banner })
	table.insert(themeAcc, { banner, "BackgroundColor3" })
	local shimmer = ni("Frame", {
		Position = UDim2.new(0, -40, 0, -10), Size = UDim2.new(0, 34, 1, 20),
		BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.55, BorderSizePixel = 0,
		Rotation = 18, ZIndex = 2, Parent = banner,
	})
	task.spawn(function()
		while banner and banner.Parent do
			shimmer.Position = UDim2.new(0, -40, 0, -10)
			pcall(function() TS:Create(shimmer, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(1, 10, 0, -10) }):Play() end)
			task.wait(3.6)
		end
	end)
	ni("TextLabel", {
		Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1,
		Text = "Willkommen, " .. LP.DisplayName .. "! 🚀", TextColor3 = Color3.fromRGB(15, 15, 20),
		Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = banner,
	})

	local statHdr = addHeader(homePage, "Status (LIVE)")
	local liveDot = ni("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = GRN, BorderSizePixel = 0, Parent = statHdr,
	})
	ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = liveDot })
	task.spawn(function()
		while liveDot and liveDot.Parent do
			pcall(function() TS:Create(liveDot, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 0.4 }):Play() end)
			task.wait(0.7)
			pcall(function() TS:Create(liveDot, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 0 }):Play() end)
			task.wait(0.7)
		end
	end)
	local statsFrame = ni("Frame", { Size = UDim2.new(1, -16, 0, 116), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = homePage })
	ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = statsFrame })
	local function mkStat(px, py, pw, cap)
		ni("TextLabel", {
			Position = UDim2.new(0, px, 0, py), Size = UDim2.new(0, pw, 0, 12), BackgroundTransparency = 1,
			Text = cap, TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = statsFrame,
		})
		return ni("TextLabel", {
			Position = UDim2.new(0, px, 0, py + 12), Size = UDim2.new(0, pw, 0, 16), BackgroundTransparency = 1,
			Text = "...", TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = statsFrame,
		})
	end
	local lbFps = mkStat(12, 8, 140, "FPS")
	local lbPing = mkStat(160, 8, 150, "Ping")
	local lbPlr = mkStat(12, 38, 140, "Spieler")
	local lbExec = mkStat(160, 38, 150, "Executor")
	local lbGame = mkStat(12, 68, 300, "Spiel")
	local lbPos = mkStat(12, 96, 300, "Position")
	task.spawn(function()
		local gameName = game.Name
		task.spawn(function()
			pcall(function()
				local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
				if info and info.Name then gameName = info.Name end
			end)
		end)
		while statsFrame and statsFrame.Parent do
			pcall(function()
				lbFps.Text = tostring(hub.fpsVal or 0)
				local ping = "?"
				pcall(function() ping = ST.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
				lbPing.Text = tostring(ping)
				lbPlr.Text = tostring(#P:GetPlayers())
				local ex = "Unbekannt"
				pcall(function() if type(identifyexecutor) == "function" then ex = tostring(identifyexecutor()) end end)
				if ex == "Unbekannt" then
					pcall(function() if type(getexecutorname) == "function" then ex = tostring(getexecutorname()) end end)
				end
				lbExec.Text = ex
				lbGame.Text = gameName
				local hrp = getHRP()
				if hrp then
					lbPos.Text = string.format("X: %.0f  Y: %.0f  Z: %.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
				else
					lbPos.Text = "-"
				end
			end)
			task.wait(1)
		end
	end)

	local badges = { { "🎯", "AimLock" }, { "🔫", "Trigger" }, { "👁️", "ESP" }, { "🎞️", "Filter" }, { "🏃", "Fly" }, { "🚨", "Panic" } }
	local grid = ni("Frame", { Size = UDim2.new(1, -16, 0, 64), BackgroundTransparency = 1, Parent = homePage })
	for i, b in ipairs(badges) do
		local col = (i - 1) % 3
		local rowI = math.floor((i - 1) / 3)
		local cell = ni("Frame", { Position = UDim2.new(0, col * 104, 0, rowI * 32), Size = UDim2.new(0, 98, 0, 28), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = grid })
		ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = cell })
		ni("TextLabel", {
			Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(1, -10, 1, 0), BackgroundTransparency = 1,
			Text = b[1] .. " " .. b[2], TextColor3 = SUB, Font = Enum.Font.GothamMedium, TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = cell,
		})
	end

	addHeader(homePage, "Teleport-Historie")
	local tphFrame = ni("Frame", { Size = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Parent = homePage })
	ni("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tphFrame })
	hub.refreshTPHist = function()
		for _, c in ipairs(tphFrame:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for _, e in ipairs(hub.tpHistory) do
			local b = ni("TextButton", {
				Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = BG2, BorderSizePixel = 0,
				Text = "⏮ " .. e.name, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 12,
				AutoButtonColor = false, Parent = tphFrame,
			})
			ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = b })
			b.MouseButton1Click:Connect(function()
				local hrp = getHRP()
				if hrp then
					recordTP("Zurück", hrp.CFrame)
					hrp.CFrame = e.cf
					toast("Zurück: " .. e.name, GRN)
				end
			end)
		end
	end
	hub.refreshTPHist()

	ni("TextLabel", {
		Size = UDim2.new(1, -16, 0, 18), BackgroundTransparency = 1,
		Text = "ℹ️ NanoHub v1.32  •  Avatar-Klick = Theme  •  🚨 = Panic", TextColor3 = SUB,
		Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = homePage,
	})
end

--// ============ AIMLOCK TAB ============
addHeader(aimPage, "AimLock")
addToggle(aimPage, "AimLock", "on", true)
addToggle(aimPage, "Taste aktiv", "keyEnabled", true)
addCycle(aimPage, "Taste", "keyIdx", KEYNAMES)
addCycle(aimPage, "Ziel-Part", "hitIdx", HITS)
addCycle(aimPage, "Modus", "aimIdx", AIMMODES)
addSlider(aimPage, "Smoothing", "smooth", 0.05, 1, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(aimPage, "Range", "range", 100, 2000, 50)
addSlider(aimPage, "FOV Radius", "fovR", 60, 600, 10)
addHeader(aimPage, "Checks")
addToggle(aimPage, "Team Check", "teamCheck", true)
addToggle(aimPage, "Wall Check", "wallCheck", true)
addHeader(aimPage, "Triggerbot")
addToggle(aimPage, "Triggerbot", "trigOn", true)
addSlider(aimPage, "Trigger Delay", "trigDelay", 0, 0.5, 0.05, function(x) return string.format("%.2fs", x) end)
addHeader(aimPage, "Kill Aura")
addToggle(aimPage, "Kill Aura", "auraOn", true)
addSlider(aimPage, "Aura Radius", "auraRange", 6, 40, 1)
addSlider(aimPage, "Aura Cooldown", "auraCD", 0.1, 2, 0.1, function(x) return string.format("%.1fs", x) end)
addHeader(aimPage, "Extras")
addToggle(aimPage, "Silent Aim (Click-Snap)", "silentOn", true)
addToggle(aimPage, "Hitbox Expander", "hbOn", true)
addSlider(aimPage, "Hitbox Größe", "hbSize", 4, 20, 1)
addToggle(aimPage, "Target Lock", "tLockOn", true)
addCycle(aimPage, "Lock-Taste (halten)", "tLockIdx", KEYNAMES)

--// ============ VISUALS TAB ============
addHeader(visPage, "Aim Drawing")
addCycle(visPage, "Farbe", "colIdx", COLNAMES)
addToggle(visPage, "FOV Circle", "showFov", true)
addToggle(visPage, "Snap Line", "showSnap", true)
addToggle(visPage, "Head Dot", "showDot", true)
addToggle(visPage, "Distance Labels", "showDist", true)
addToggle(visPage, "Custom Crosshair", "crossOn", true)
addSlider(visPage, "Crosshair Größe", "crossSize", 4, 30, 1)
addSlider(visPage, "Crosshair Gap", "crossGap", 0, 15, 1)
addSlider(visPage, "Crosshair Dicke", "crossThick", 1, 5, 1)
addHeader(visPage, "World")
addToggle(visPage, "Fullbright", "fbOn", true)
addToggle(visPage, "No Fog", "fogOn", true)
addToggle(visPage, "X-Ray", "xrayOn", true)
addSlider(visPage, "X-Ray Transparenz", "xrayT", 0.2, 0.9, 0.05, function(x) return string.format("%.2f", x) end)
addToggle(visPage, "Off-Screen Pfeile", "arrowsOn", true)
addHeader(visPage, "Camera")
addToggle(visPage, "Zoom Hack", "zoomOn", true)
addSlider(visPage, "Max Zoom", "zoomVal", 50, 400, 10)

--// ============ ESP TAB ============
addHeader(espPage, "Player ESP")
addToggle(espPage, "ESP Master", "espOn", true)
addToggle(espPage, "Box", "espBox", true)
addToggle(espPage, "HP Bar", "espHP", true)
addCycle(espPage, "HP Position", "hpSide", HP_SIDES)
addToggle(espPage, "Team Farben", "espTeamCol", true)
addToggle(espPage, "Name + Distance", "espName", true)
addToggle(espPage, "Skeleton", "espSkel", true)
addToggle(espPage, "Tracer", "espTracer", true)
addSlider(espPage, "Max Distance", "espMaxD", 100, 5000, 50)
addHeader(espPage, "Chams")
addToggle(espPage, "Chams", "chamsOn", true)
addSlider(espPage, "Chams Transparenz", "chamsFill", 0, 1, 0.1, function(x) return string.format("%.1f", x) end)
addHeader(espPage, "Item / Card ESP")
addToggle(espPage, "Card/Pack ESP", "cardEspOn", true)
addSlider(espPage, "Card Max Distance", "cardMaxD", 100, 5000, 50)

--// ============ FILTER TAB ============
addHeader(filterPage, "Filter")
addToggle(filterPage, "Filter AN", "filterOn", true)
addCycle(filterPage, "Preset", "filterIdx", FILTER_NAMES, function() applyFilterPreset() end)
addHeader(filterPage, "Manuell")
addSlider(filterPage, "Contrast", "fContrast", -1, 1, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(filterPage, "Sättigung", "fSat", -1, 1, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(filterPage, "Helligkeit", "fBright", -0.5, 0.5, 0.01, function(x) return string.format("%.2f", x) end)
addCycle(filterPage, "Tint", "fTintIdx", TINT_NAMES)
addSlider(filterPage, "Bloom", "fBloom", 0, 3, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(filterPage, "Sun Rays", "fSun", 0, 1, 0.05, function(x) return string.format("%.2f", x) end)
addButton(filterPage, "🔄 Filter Reset", function()
	if CTRLS.filterOn then CTRLS.filterOn.set(false) end
end)

--// ============ MOVEMENT TAB ============
local hub_savedCF = nil
addHeader(movePage, "Bewegung")
addToggle(movePage, "Fly (WASD+Space)", "flyOn", true)
addSlider(movePage, "Fly Speed", "flySpeed", 10, 300, 5)
addToggle(movePage, "Noclip", "noclipOn", true)
addToggle(movePage, "Infinite Jump", "infJumpOn", true)
addToggle(movePage, "Click-TP", "clickTpOn", true)
addToggle(movePage, "Anti-Ragdoll", "ragdollOn", true)
addHeader(movePage, "Speed / Jump")
addToggle(movePage, "WalkSpeed AN", "wsEnabled", true)
addSlider(movePage, "WalkSpeed", "wsValue", 8, 200, 1)
addToggle(movePage, "JumpPower AN", "jpEnabled", true)
addSlider(movePage, "JumpPower", "jpValue", 20, 300, 5)
addHeader(movePage, "Position")
addButton(movePage, "💾 Position speichern", function()
	local hrp = getHRP()
	if hrp then
		hub_savedCF = hrp.CFrame
		toast("Position gespeichert", GRN)
	end
end)
addButton(movePage, "↩️ Position laden", function()
	local hrp = getHRP()
	if hrp and hub_savedCF then
		recordTP("Save-Pos", hrp.CFrame)
		hrp.CFrame = hub_savedCF
		toast("Position geladen", GRN)
	else
		toast("Keine Position", RED)
	end
end)

--// ============ PLAYERS TAB ============
addHeader(plrPage, "Join Spieler")
addInput(plrPage, "TP zu Username", "Username...", function(txt)
	txt = txt:lower()
	for _, pl in ipairs(P:GetPlayers()) do
		if pl.Name:lower():sub(1, #txt) == txt or pl.DisplayName:lower():sub(1, #txt) == txt then
			tpTo(pl)
			toast("TP -> " .. pl.Name, GRN)
			return
		end
	end
	toast("Nicht gefunden", RED)
end)
addHeader(plrPage, "Spieler Liste")
local plrListFrame = ni("Frame", { Size = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Parent = plrPage })
ni("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = plrListFrame })
local playerRows = {}
local function buildPlayerList()
	for _, row in pairs(playerRows) do
		pcall(function() if row and row.Destroy then row:Destroy() end end)
	end
	table.clear(playerRows)
	for _, pl in ipairs(P:GetPlayers()) do
		if pl ~= LP then
			local row = mkRow(plrListFrame)
			ni("TextLabel", {
				Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
				Text = pl.DisplayName .. " (@" .. pl.Name .. ")", TextColor3 = TXT, Font = Enum.Font.GothamMedium,
				TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
			})
			local spBtn = ni("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 34, 0, 22),
				BackgroundColor3 = BG3, BorderSizePixel = 0, Text = "👁", TextColor3 = ACC,
				Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = row,
			})
			ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = spBtn })
			row.MouseButton1Click:Connect(function()
				tpTo(pl)
				toast("TP -> " .. pl.Name, GRN)
			end)
			spBtn.MouseButton1Click:Connect(function()
				local on = toggleSpectate(pl)
				if on then
					spBtn.Text = "⏹"
					toast("Spectate -> " .. pl.Name, GRN)
				else
					spBtn.Text = "👁"
					toast("Spectate Stop", RED)
				end
			end)
			playerRows[pl] = row
		end
	end
end
buildPlayerList()

--// ============ WAYPOINTS TAB ============
hub.waypoints = hub.waypoints or {}
if canFS then
	pcall(function()
		if isfile(CFG_DIR .. "/waypoints.json") then
			local ok, d = pcall(function() return HS:JSONDecode(readfile(CFG_DIR .. "/waypoints.json")) end)
			if ok and type(d) == "table" then hub.waypoints = d end
		end
	end)
end
local function saveWaypoints()
	if not canFS then return end
	pcall(function()
		if makefolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
		writefile(CFG_DIR .. "/waypoints.json", HS:JSONEncode(hub.waypoints))
	end)
end
addHeader(wpPage, "Neuer Wegpunkt")
addInput(wpPage, "Name", "z.B. Mid...", function(txt)
	local hrp = getHRP()
	if hrp then
		table.insert(hub.waypoints, { name = txt, pos = { hrp.Position.X, hrp.Position.Y, hrp.Position.Z } })
		saveWaypoints()
		rebuildWpList()
		toast("Waypoint: " .. txt, GRN)
	end
end)
addHeader(wpPage, "Waypoints")
local wpListFrame = ni("Frame", { Size = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Parent = wpPage })
ni("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = wpListFrame })
hub.wpDraws = {}
function rebuildWpList()
	for _, c in ipairs(wpListFrame:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for _, d in pairs(hub.wpDraws) do
		pcall(function()
			if d.dot then d.dot:Remove() end
			if d.lbl then d.lbl:Remove() end
		end)
	end
	hub.wpDraws = {}
	for i, wp in ipairs(hub.waypoints) do
		local row = ni("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = wpListFrame })
		ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = row })
		ni("TextLabel", {
			Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1,
			Text = wp.name, TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
		})
		local tpB = ni("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.new(0, 40, 0, 20),
			BackgroundColor3 = BG3, BorderSizePixel = 0, Text = "TP", TextColor3 = ACC,
			Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, Parent = row,
		})
		ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tpB })
		table.insert(themeAcc, { tpB, "TextColor3" })
		local delB = ni("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 24, 0, 20),
			BackgroundColor3 = BG3, BorderSizePixel = 0, Text = "🗑", TextColor3 = RED,
			Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, Parent = row,
		})
		ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = delB })
		tpB.MouseButton1Click:Connect(function()
			local hrp = getHRP()
			if hrp then
				recordTP("WP:" .. wp.name, hrp.CFrame)
				hrp.CFrame = CFrame.new(wp.pos[1], wp.pos[2], wp.pos[3]) + Vector3.new(0, 3, 0)
				toast("WP: " .. wp.name, GRN)
			end
		end)
		delB.MouseButton1Click:Connect(function()
			table.remove(hub.waypoints, i)
			saveWaypoints()
			rebuildWpList()
			toast("Gelöscht", RED)
		end)
		if canDraw then
			local dot = Drawing.new("Circle")
			dot.Thickness = 2; dot.NumSides = 16; dot.Filled = false; dot.Radius = 6; dot.Visible = false
			local lbl = Drawing.new("Text")
			lbl.Size = 13; lbl.Center = true; lbl.Outline = true; lbl.Visible = false
			table.insert(hub.draws, dot)
			table.insert(hub.draws, lbl)
			hub.wpDraws[i] = { dot = dot, lbl = lbl, pos = Vector3.new(wp.pos[1], wp.pos[2], wp.pos[3]), name = wp.name }
		end
	end
end
rebuildWpList()

--// ============ SETTINGS TAB ============
addHeader(setPage, "Config")
addButton(setPage, "💾 Config speichern", function()
	if not canFS then toast("Kein FileSystem", RED) return end
	if saveConfigNow() then toast("Config gespeichert", GRN) else toast("Config Fehler", RED) end
end)
addButton(setPage, "📂 Config laden", function()
	if not canFS then toast("Kein FileSystem", RED) return end
	local ok, data = pcall(function() return HS:JSONDecode(readfile(cfgPath())) end)
	if ok and type(data) == "table" then
		applyConfig(data)
		syncUI()
		setThemeVars(S.themeIdx)
		toast("Config geladen", GRN)
	else
		toast("Keine Config", RED)
	end
end)
addCycle(setPage, "Profil", "profileIdx", { "1", "2", "3" })
addToggle(setPage, "Auto-Save", "autoSaveAll", false)
addToggle(setPage, "Fast Start", "fastStart", false)
addHeader(setPage, "UI")
addCycle(setPage, "Theme", "themeIdx", THEME_NAMES, function() setThemeVars(S.themeIdx) end)
addCycle(setPage, "GUI Taste", "guiKeyIdx", GUIKEYS)
addButton(setPage, "➖ GUI kleiner", function()
	S.uiScale = clamp(S.uiScale - 0.1, 0.8, 1.5)
	uiScaleObj.Scale = S.uiScale
	queueSave()
end)
addButton(setPage, "➕ GUI größer", function()
	S.uiScale = clamp(S.uiScale + 0.1, 0.8, 1.5)
	uiScaleObj.Scale = S.uiScale
	queueSave()
end)
local frMouse = false
local function toggleFreeMouse()
	frMouse = not frMouse
	toast("Maus frei: " .. (frMouse and "AN" or "AUS"), frMouse and GRN or RED)
end
addButton(setPage, "🖱️ Maus frei (Toggle)", toggleFreeMouse)
track(RS.RenderStepped:Connect(function()
	if frMouse then
		pcall(function()
			UIS.MouseBehavior = Enum.MouseBehavior.Default
			UIS.MouseIconEnabled = true
		end)
	end
end))
addHeader(setPage, "Feature Hotkeys")
addCycle(setPage, "ESP", "hkEsp", HK_NAMES)
addCycle(setPage, "Chams", "hkChams", HK_NAMES)
addCycle(setPage, "Fly", "hkFly", HK_NAMES)
addCycle(setPage, "Noclip", "hkNoclip", HK_NAMES)
addCycle(setPage, "Infinite Jump", "hkInfJump", HK_NAMES)
addCycle(setPage, "Click-TP", "hkClickTp", HK_NAMES)
addCycle(setPage, "Triggerbot", "hkTrig", HK_NAMES)
addHeader(setPage, "Sicherheit")
addCycle(setPage, "🚨 Panic-Taste", "panicIdx", PANIC_NAMES)
addToggle(setPage, "Anti-AFK", "antiAfkOn", false)
addToggle(setPage, "⚡ FPS Boost", "fpsBoost", true)

local function panic()
	local keys = { "on", "trigOn", "auraOn", "silentOn", "hbOn", "tLockOn", "espOn", "chamsOn", "cardEspOn",
		"crossOn", "arrowsOn", "xrayOn", "fbOn", "fogOn", "zoomOn", "flyOn", "noclipOn", "infJumpOn",
		"clickTpOn", "ragdollOn", "filterOn" }
	for _, k in ipairs(keys) do
		if S[k] then
			S[k] = false
			local c = CTRLS[k]
			if c and c.set then pcall(function() c.set(false, true) end) end
		end
	end
	toast("🚨 PANIC — alles AUS", RED)
	queueSave()
end

--// ============ SPLASH ============
if not S.fastStart then
	local splash = ni("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = BG0, BorderSizePixel = 0, ZIndex = 90, Parent = ui })
	local spTitle = ni("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.16, 0), Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1, Text = "", TextColor3 = ACC, Font = Enum.Font.GothamBold, TextSize = 38, ZIndex = 91, Parent = splash,
	})
	table.insert(themeAcc, { spTitle, "TextColor3" })
	ni("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.16, 50), Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1, Text = "Universal AimLock", TextColor3 = SUB, Font = Enum.Font.Gotham,
		TextSize = 13, ZIndex = 91, Parent = splash,
	})
	local spAva = ni("ImageLabel", {
		Anchor

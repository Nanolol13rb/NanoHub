print("[NanoHub] AimLock v1.29 === START ===")

local P = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LP = P.LocalPlayer
local M = LP:GetMouse()

local function rndName(b)
    return (b or "A") .. tostring(math.random(10000, 99999))
end

local function ni(c, p)
    local o = Instance.new(c)
    if p then
        for k, v in pairs(p) do
            o[k] = v
        end
    end
    return o
end

local function clamp(x, a, b)
    if x < a then
        return a
    end
    if x > b then
        return b
    end
    return x
end

_G.NanoAim = _G.NanoAim or {}
local hub = _G.NanoAim

if hub.conns then
    for i = 1, #hub.conns do
        local c = hub.conns[i]
        pcall(function()
            if c and c.Connected then
                c:Disconnect()
            end
        end)
    end
end
hub.conns = {}

local function removeDraws(tbl)
    if not tbl then
        return
    end
    for _, d in pairs(tbl) do
        pcall(function()
            if d and d.Remove then
                d:Remove()
            end
        end)
    end
end

removeDraws(hub.draws)
removeDraws(hub.distLbls)
hub.draws = {}
hub.distLbls = nil

if hub.wpDraws then
    for _, d in pairs(hub.wpDraws) do
        pcall(function()
            if d then
                if d.dot then d.dot:Remove() end
                if d.lbl then d.lbl:Remove() end
            end
        end)
    end
end
hub.wpDraws = nil

if hub.cardDraws then
    for _, d in pairs(hub.cardDraws) do
        pcall(function()
            if d then
                if d.dot then d.dot:Remove() end
                if d.lbl then d.lbl:Remove() end
            end
        end)
    end
end
hub.cardDraws = nil

if hub.espCache then
    for _, e in pairs(hub.espCache) do
        pcall(function()
            if e.box then e.box:Remove() end
            if e.name then e.name:Remove() end
            if e.tracer then e.tracer:Remove() end
            if e.hpBg then e.hpBg:Remove() end
            if e.hpF then e.hpF:Remove() end
            if e.hl then
                e.hl:Destroy()
            end
            if e.skel then
                for i = 1, #e.skel do
                    if e.skel[i] then
                        e.skel[i]:Remove()
                    end
                end
            end
        end)
    end
end
hub.espCache = nil

for _, n in ipairs({ "NanoCC", "NanoBloom", "NanoSun" }) do
    local e = Lighting:FindFirstChild(n)
    if e then
        pcall(function() e:Destroy() end)
    end
end

do
    local c0 = LP.Character
    local hrp0 = c0 and c0:FindFirstChild("HumanoidRootPart")
    if hrp0 then
        for _, n in ipairs({ "NanoHubFlyBV", "NanoHubFlyBG" }) do
            local e = hrp0:FindFirstChild(n)
            if e then
                pcall(function() e:Destroy() end)
            end
        end
    end
end

if hub.ui then
    pcall(function() hub.ui:Destroy() end)
    hub.ui = nil
end

local function track(c)
    table.insert(hub.conns, c)
    return c
end

local pg = LP:FindFirstChild("PlayerGui")
if not pg then
    pg = LP:WaitForChild("PlayerGui")
end

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

local S = {
    on = false,
    keyEnabled = true,
    keyIdx = 1,
    hitIdx = 1,
    aimIdx = 1,
    colIdx = 1,
    themeIdx = 1,
    fovR = 200,
    range = 1000,
    smooth = 0.35,
    teamCheck = false,
    wallCheck = false,
    showFov = true,
    showSnap = true,
    showDot = true,
    showDist = true,
    espOn = false,
    espBox = true,
    espHP = true,
    hpSide = 1,
    espTeamCol = false,
    chamsOn = false,
    chamsFill = 0.6,
    espName = true,
    espSkel = false,
    espTracer = false,
    espMaxD = 1500,
    trigOn = false,
    trigDelay = 0.1,
    trigTeam = true,
    trigRange = 400,
    trigFov = 20,
    guiKeyIdx = 1,
    freeMouseIdx = 1,
    freeMouseOn = false,
    fastStart = false,
    wpMarkers = true,
    filterOn = false,
    filterPresetIdx = 1,
    filterTintIdx = 1,
    fContrast = 0.12,
    fSat = -0.08,
    fBright = 0.01,
    fBloom = 0.25,
    fSunRays = 0.08,
    flyOn = false,
    flySpeed = 60,
    noclipOn = false,
    infJumpOn = false,
    clickTpOn = false,
    wsEnabled = false,
    wsValue = 16,
    jpEnabled = false,
    jpValue = 50,
    antiAfkOn = true,
    autoRejoinOn = false,
    cardEspOn = false,
    cardMaxD = 2000,
}

-- ============ THEMES ============
local THEMES = {
    { name = "Purple", acc = Color3.fromRGB(150, 100, 255), cyan = Color3.fromRGB(90, 200, 255) },
    { name = "Blue",   acc = Color3.fromRGB(70, 150, 255),  cyan = Color3.fromRGB(120, 220, 255) },
    { name = "Red",    acc = Color3.fromRGB(255, 90, 90),   cyan = Color3.fromRGB(255, 160, 120) },
    { name = "Green",  acc = Color3.fromRGB(80, 220, 140),  cyan = Color3.fromRGB(150, 255, 200) },
    { name = "Orange", acc = Color3.fromRGB(255, 150, 60),  cyan = Color3.fromRGB(255, 210, 120) },
    { name = "Pink",   acc = Color3.fromRGB(255, 100, 180), cyan = Color3.fromRGB(255, 170, 220) },
}
local THEME_NAMES = { "Purple", "Blue", "Red", "Green", "Orange", "Pink" }

local themeAcc = {}
local gradRepaints = {}
local function setThemeVars(i)
    local t = THEMES[clamp(i, 1, #THEMES)]
    if not t then
        return
    end
    ACC = t.acc
    CYAN = t.cyan
    for _, r in ipairs(themeAcc) do
        pcall(function()
            r[1][r[2]] = ACC
        end)
    end
    for _, fn in ipairs(gradRepaints) do
        pcall(fn, ACC)
    end
end

-- ============ CONFIG ============
local CFG_DIR = "NanoAim"
local CFG_PATH = CFG_DIR .. "/config.json"
local canFS = (type(writefile) == "function" and type(readfile) == "function")

local CFG_CLAMPS = {
    fovR = { 60, 600 },
    range = { 100, 2000 },
    smooth = { 0.05, 1 },
    espMaxD = { 100, 5000 },
    hpSide = { 1, 2 },
    chamsFill = { 0, 1 },
    keyIdx = { 1, 8 },
    hitIdx = { 1, 4 },
    aimIdx = { 1, 2 },
    colIdx = { 1, 6 },
    themeIdx = { 1, 6 },
    trigDelay = { 0, 0.5 },
    trigRange = { 50, 1000 },
    trigFov = { 5, 120 },
    guiKeyIdx = { 1, 5 },
    freeMouseIdx = { 1, 5 },
    filterPresetIdx = { 1, 6 },
    filterTintIdx = { 1, 6 },
    fContrast = { -0.5, 1 },
    fSat = { -1, 1 },
    fBright = { -0.5, 0.5 },
    fBloom = { 0, 2 },
    fSunRays = { 0, 0.5 },
    flySpeed = { 10, 300 },
    wsValue = { 8, 200 },
    jpValue = { 20, 300 },
    cardMaxD = { 100, 5000 },
}

local function applyConfig(d)
    if type(d) ~= "table" then
        return false
    end
    for k, v in pairs(d) do
        if k ~= "on" and k ~= "flyOn" and k ~= "noclipOn" and k ~= "clickTpOn"
            and k ~= "infJumpOn" and k ~= "wsEnabled" and k ~= "jpEnabled"
            and S[k] ~= nil and type(v) == type(S[k]) then
            local c = CFG_CLAMPS[k]
            if c then
                S[k] = clamp(v, c[1], c[2])
            else
                S[k] = v
            end
        end
    end
    return true
end

if canFS then
    pcall(function()
        if isfile and isfile(CFG_PATH) then
            local ok, data = pcall(function()
                return HS:JSONDecode(readfile(CFG_PATH))
            end)
            if ok and type(data) == "table" then
                applyConfig(data)
            end
        end
    end)
end
setThemeVars(S.themeIdx)

local function saveSilent()
    if not canFS then
        return
    end
    pcall(function()
        if makefolder and isfolder and not isfolder(CFG_DIR) then
            makefolder(CFG_DIR)
        end
        writefile(CFG_PATH, HS:JSONEncode(S))
    end)
end

-- ============ KEYS / COLORS ============
local KEYNAMES = { "E", "Q", "F", "X", "V", "C", "T", "Y" }
local KEYCODES = {
    Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.F, Enum.KeyCode.X,
    Enum.KeyCode.V, Enum.KeyCode.C, Enum.KeyCode.T, Enum.KeyCode.Y,
}
local GUIKEY_NAMES = { "RightAlt", "RightCtrl", "F2", "F3", "O" }
local GUIKEY_CODES = {
    Enum.KeyCode.RightAlt, Enum.KeyCode.RightControl, Enum.KeyCode.F2,
    Enum.KeyCode.F3, Enum.KeyCode.O,
}
local FREEMOUSE_NAMES = { "RightCtrl", "RightAlt", "F4", "M", "K" }
local FREEMOUSE_CODES = {
    Enum.KeyCode.RightControl, Enum.KeyCode.RightAlt, Enum.KeyCode.F4,
    Enum.KeyCode.M, Enum.KeyCode.K,
}
local HITS = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
local AIMMODES = { "Rage", "Smooth" }
local COLNAMES = { "Red", "Purple", "Cyan", "Green", "White", "Rainbow" }
local HP_SIDES = { "Links", "Rechts" }

local function curKey()
    return KEYCODES[S.keyIdx]
end

local function drawColor()
    local nm = COLNAMES[S.colIdx]
    if nm == "Rainbow" then
        return Color3.fromHSV((tick() % 5) / 5, 0.75, 1)
    elseif nm == "Purple" then
        return ACC
    elseif nm == "Cyan" then
        return CYAN
    elseif nm == "Green" then
        return Color3.fromRGB(90, 255, 120)
    elseif nm == "White" then
        return Color3.fromRGB(240, 240, 240)
    end
    return COLR
end

-- ============ TELEPORT HELPER ============
local function tpTo(pl)
    local c = pl.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local myC = LP.Character
    local my = myC and myC:FindFirstChild("HumanoidRootPart")
    if hrp and my then
        my.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ============ SPECTATE MODULE ============
local spectating = nil

local function specAttach()
    if not spectating then
        return
    end
    local c = spectating.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if cam and hum and hum.Health > 0 then
        cam.CameraSubject = hum
    end
end

local function stopSpectate()
    local myC = LP.Character
    local myHum = myC and myC:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if cam and myHum then
        cam.CameraSubject = myHum
    end
    spectating = nil
end

local function startSpectate(pl)
    spectating = pl
    specAttach()
end

local function toggleSpectate(pl)
    if spectating == pl then
        stopSpectate()
        return false
    end
    startSpectate(pl)
    return true
end

track(RS.Heartbeat:Connect(function()
    if spectating then
        local c = spectating.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if cam and (not hum or hum.Health <= 0 or cam.CameraSubject ~= hum) then
            if not hum or hum.Health <= 0 then
            else
                cam.CameraSubject = hum
            end
        end
    end
end))

-- ============ DRAWING SETUP ============
local canDraw = false
pcall(function()
    local t = Drawing.new("Line")
    t:Remove()
    canDraw = true
end)

local fovC, snapL, headD
hub.draws = {}
if canDraw then
    fovC = Drawing.new("Circle")
    fovC.Thickness = 1
    fovC.NumSides = 64
    fovC.Filled = false
    fovC.Visible = false
    snapL = Drawing.new("Line")
    snapL.Thickness = 1
    snapL.Visible = false
    headD = Drawing.new("Circle")
    headD.Thickness = 1
    headD.NumSides = 24
    headD.Filled = false
    headD.Visible = false
    table.insert(hub.draws, fovC)
    table.insert(hub.draws, snapL)
    table.insert(hub.draws, headD)
end

local distLbls = {}
hub.distLbls = distLbls

-- ============ ESP CACHE ============
local espCache = {}
hub.espCache = espCache

local R6_BONES = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}
local R15_BONES = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
}

local function bonePos(c, nm)
    local p = c:FindFirstChild(nm)
    if p and p:IsA("BasePart") then
        return p.Position
    end
    return nil
end

local function espClearOne(pl)
    local e = espCache[pl]
    if not e then
        return
    end
    pcall(function()
        if e.box then e.box:Remove() end
        if e.name then e.name:Remove() end
        if e.tracer then e.tracer:Remove() end
        if e.hpBg then e.hpBg:Remove() end
        if e.hpF then e.hpF:Remove() end
        if e.hl then
            e.hl:Destroy()
        end
        if e.skel then
            for i = 1, #e.skel do
                if e.skel[i] then
                    e.skel[i]:Remove()
                end
            end
        end
    end)
    espCache[pl] = nil
end

local function espClearAll()
    for pl in pairs(espCache) do
        espClearOne(pl)
    end
end

-- ============ TARGETING ============
local function isVisible(part)
    local v = workspace.CurrentCamera
    if not v then
        return false
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {}
    if LP.Character then
        table.insert(exclude, LP.Character)
    end
    if part.Parent then
        table.insert(exclude, part.Parent)
    end
    params.FilterDescendantsInstances = exclude
    local hit = workspace:Raycast(v.CFrame.Position, part.Position - v.CFrame.Position, params)
    return hit == nil
end

local function findTarget()
    local v = workspace.CurrentCamera
    if not v then
        return nil, nil, nil
    end
    local myC = LP.Character
    local myHrp = myC and myC:FindFirstChild("HumanoidRootPart") or nil
    local center = Vector2.new(v.ViewportSize.X / 2, v.ViewportSize.Y / 2)
    local best, bestPart, bestSp = nil, nil, nil
    local bestD = math.huge
    for _, pl in ipairs(P:GetPlayers()) do
        if pl ~= LP then
            if not (S.teamCheck and pl.Team ~= nil and pl.Team == LP.Team) then
                local c = pl.Character
                if c then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    local part = c:FindFirstChild(HITS[S.hitIdx])
                    if hum and hum.Health > 0 and part then
                        local sp, on = v:WorldToViewportPoint(part.Position)
                        if on then
                            local sp2 = Vector2.new(sp.X, sp.Y)
                            local d = (sp2 - center).Magnitude
                            if d <= S.fovR and d < bestD then
                                local okRange = true
                                if myHrp then
                                    okRange = (part.Position - myHrp.Position).Magnitude <= S.range
                                end
                                if okRange then
                                    if not S.wallCheck or isVisible(part) then
                                        bestD = d
                                        best = pl
                                        bestPart = part
                                        bestSp = sp2
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart, bestSp
end

-- ============ UI ROOT ============
local ui = ni("ScreenGui", {
    Name = rndName("NH"),
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 50,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = pg,
})
hub.ui = ui

-- ============ TOAST SYSTEM ============
local curToast = nil
local toastGen = 0
local function toast(msg, col)
    toastGen = toastGen + 1
    local myGen = toastGen
    if curToast then
        pcall(function() curToast:Destroy() end)
        curToast = nil
    end
    local f = ni("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -40),
        Size = UDim2.new(0, 170, 0, 34),
        BackgroundColor3 = BG2,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 50,
        Parent = ui,
    })
    curToast = f
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = f })
    local st = ni("UIStroke", { Color = col, Thickness = 1, Transparency = 1, Parent = f })
    local lb = ni("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = col,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 51,
        Parent = f,
    })
    TS:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 1, -70) }):Play()
    TS:Create(st, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.5 }):Play()
    TS:Create(lb, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
    task.delay(1.4, function()
        if myGen ~= toastGen then
            return
        end
        pcall(function()
            TS:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 1, -40) }):Play()
            TS:Create(st, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
            TS:Create(lb, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
        end)
        task.wait(0.35)
        if curToast == f then
            curToast = nil
        end
        pcall(function() f:Destroy() end)
    end)
end

-- ============ WINDOW ============
local WIN_W, WIN_H = 470, 470
local HEAD, SB_W = 46, 120

local win = ni("Frame", {
    Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    BackgroundColor3 = BG1,
    BorderSizePixel = 0,
    Visible = false,
    Parent = ui,
})
ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = win })
local winStroke = ni("UIStroke", { Color = ACC, Transparency = 0.45, Thickness = 1.2, Parent = win })
table.insert(themeAcc, { winStroke, "Color" })
ni("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 180, 205)),
    }),
    Rotation = 115,
    Parent = win,
})

local header = ni("Frame", {
    Size = UDim2.new(1, 0, 0, HEAD),
    BackgroundColor3 = BG0,
    BorderSizePixel = 0,
    Parent = win,
})
ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = header })

local title = ni("TextLabel", {
    Position = UDim2.new(0, 14, 0, 6),
    Size = UDim2.new(0, 150, 0, 22),
    BackgroundTransparency = 1,
    Text = "NanoHub",
    TextColor3 = ACC,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Parent = header,
})
table.insert(themeAcc, { title, "TextColor3" })

local sub = ni("TextLabel", {
    Position = UDim2.new(0, 14, 0, 25),
    Size = UDim2.new(0, 220, 0, 14),
    BackgroundTransparency = 1,
    Text = "AimLock v1.29  •  " .. LP.DisplayName,
    TextColor3 = SUB,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    Parent = header,
})

local accBar = ni("Frame", {
    Position = UDim2.new(0, 0, 1, -2),
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = ACC,
    BorderSizePixel = 0,
    Parent = header,
})
table.insert(themeAcc, { accBar, "BackgroundColor3" })

local wkDot = ni("Frame", {
    Position = UDim2.new(0.5, -32, 0.5, -4),
    Size = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = GRN,
    BorderSizePixel = 0,
    Parent = header,
})
ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = wkDot })
local wkLbl = ni("TextLabel", {
    Position = UDim2.new(0.5, -18, 0, 0),
    Size = UDim2.new(0, 60, 1, 0),
    BackgroundTransparency = 1,
    Text = "working",
    TextColor3 = GRN,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header,
})
task.spawn(function()
    while win.Parent do
        pcall(function()
            TS:Create(wkDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.6 }):Play()
        end)
        task.wait(0.6)
        pcall(function()
            TS:Create(wkDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }):Play()
        end)
        task.wait(0.6)
    end
end)

local closeBtn = ni("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 10),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = BG3,
    BorderSizePixel = 0,
    Text = "X",
    TextColor3 = RED,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false,
    Parent = header,
})
ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeBtn })

local hideBtn = ni("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -40, 0, 10),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = BG3,
    BorderSizePixel = 0,
    Text = "—",
    TextColor3 = SUB,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false,
    Parent = header,
})
ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = hideBtn })
hideBtn.MouseButton1Click:Connect(function()
    win.Visible = false
end)

-- Sidebar + Tabs
local sidebar = ni("Frame", {
    Position = UDim2.new(0, 0, 0, HEAD),
    Size = UDim2.new(0, SB_W, 1, -HEAD),
    BackgroundColor3 = BG0,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Parent = win,
})

local TAB_NAMES = { "Home", "AimLock", "Visuals", "ESP", "Filter", "Movement", "Players", "Waypoints", "Settings" }
local tabBtns = {}
local tabAcc = {}
for i = 1, #TAB_NAMES do
    local b = ni("TextButton", {
        Position = UDim2.new(0, 8, 0, 10 + (i - 1) * 42),
        Size = UDim2.new(1, -16, 0, 34),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        Text = TAB_NAMES[i],
        TextColor3 = SUB,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = sidebar,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = b })
    local acc = ni("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = ACC,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = b,
    })
    table.insert(themeAcc, { acc, "BackgroundColor3" })
    tabBtns[i] = b
    tabAcc[i] = acc
end

local content = ni("Frame", {
    Position = UDim2.new(0, SB_W, 0, HEAD),
    Size = UDim2.new(1, -SB_W, 1, -HEAD),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = win,
})
local pages = {}
for i = 1, #TAB_NAMES do
    local pf = ni("ScrollingFrame", {
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = ACC,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = content,
    })
    ni("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = pf })
    pages[i] = pf
end
local homePage    = pages[1]
local aimPage     = pages[2]
local visPage     = pages[3]
local espPage     = pages[4]
local filterPage  = pages[5]
local movePage    = pages[6]
local plrPage     = pages[7]
local wpPage      = pages[8]
local setPage     = pages[9]

local function showTab(name)
    local idx = 1
    for i, n in ipairs(TAB_NAMES) do
        if n == name then
            idx = i
        end
    end
    for i = 1, #pages do
        pages[i].Visible = (i == idx)
        tabBtns[i].BackgroundColor3 = (i == idx) and BG4 or BG2
        tabBtns[i].TextColor3 = (i == idx) and TXT or SUB
        tabAcc[i].BackgroundTransparency = (i == idx) and 0 or 1
    end
end

for i = 1, #TAB_NAMES do
    local nm = TAB_NAMES[i]
    tabBtns[i].MouseButton1Click:Connect(function()
        showTab(nm)
    end)
end

local footer = ni("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundColor3 = BG0,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = win,
})
ni("TextLabel", {
    Position = UDim2.new(0, 10, 0, 0),
    Size = UDim2.new(1, -20, 1, 0),
    BackgroundTransparency = 1,
    Text = "Hotkeys: Settings-Tab  •  v1.29",
    TextColor3 = SUB,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = footer,
})

-- Dragging (Fenster)
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

-- ============ ROW HELPERS ============
local CTRLS = {}

local function mkRow(page)
    local row = ni("TextButton", {
        Size = UDim2.new(1, -16, 0, 30),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = page,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = row })
    row.MouseEnter:Connect(function()
        TS:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = BG3 }):Play()
    end)
    row.MouseLeave:Connect(function()
        TS:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = BG2 }):Play()
    end)
    return row
end

local function addHeader(page, text)
    local l = ni("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        BackgroundTransparency = 1,
        Text = string.upper(text),
        TextColor3 = ACC,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = page,
    })
    table.insert(themeAcc, { l, "TextColor3" })
end

local function addToggle(page, titleTxt, key, doToast, onSet)
    local row = mkRow(page)
    ni("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = titleTxt,
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local dot = ni("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = RED,
        BorderSizePixel = 0,
        Parent = row,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
    local val = S[key]
    local inited = false
    local function setOn(v, silent)
        local changed = (v ~= val)
        val = v
        S[key] = v
        dot.BackgroundColor3 = v and GRN or RED
        if onSet then
            pcall(onSet, v, silent)
        end
        if doToast and inited and changed and not silent then
            if v then
                toast(titleTxt .. "  AN", GRN)
            else
                toast(titleTxt .. "  AUS", RED)
            end
        end
    end
    row.MouseButton1Click:Connect(function()
        setOn(not val)
    end)
    setOn(val, true)
    inited = true
    local ctrl = { set = setOn }
    if key then
        CTRLS[key] = ctrl
    end
    return ctrl
end

local function addCycle(page, titleTxt, key, items, onSet)
    local row = mkRow(page)
    ni("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = titleTxt,
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local val = ni("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 90, 1, 0),
        BackgroundTransparency = 1,
        Text = items[S[key]] or "?",
        TextColor3 = ACC,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    table.insert(themeAcc, { val, "TextColor3" })
    row.MouseButton1Click:Connect(function()
        S[key] = (S[key] % #items) + 1
        val.Text = items[S[key]]
        if onSet then
            pcall(onSet, S[key])
        end
    end)
    local ctrl = { set = function(v)
        S[key] = clamp(v, 1, #items)
        val.Text = items[S[key]]
        if onSet then
            pcall(onSet, S[key])
        end
    end }
    CTRLS[key] = ctrl
    return ctrl
end

-- ============ DRAG-SLIDER ============
local function addSlider(page, titleTxt, key, mn, mx, step, fmt)
    local row = mkRow(page)
    row.Size = UDim2.new(1, -16, 0, 40)
    local ttl = ni("TextLabel", {
        Position = UDim2.new(0, 10, 0, 6),
        Size = UDim2.new(1, -100, 0, 16),
        BackgroundTransparency = 1,
        Text = titleTxt,
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local val = ni("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 6),
        Size = UDim2.new(0, 90, 0, 16),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = ACC,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    table.insert(themeAcc, { val, "TextColor3" })
    local bar = ni("Frame", {
        Position = UDim2.new(0, 12, 1, -14),
        Size = UDim2.new(1, -24, 0, 5),
        BackgroundColor3 = BG4,
        BorderSizePixel = 0,
        Parent = row,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
    local fill = ni("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ACC,
        BorderSizePixel = 0,
        Parent = bar,
    })
    table.insert(themeAcc, { fill, "BackgroundColor3" })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    local knob = ni("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = TXT,
        BorderSizePixel = 0,
        Parent = bar,
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
        if span <= 0 then
            return
        end
        local ratio = clamp((x - bar.AbsolutePosition.X) / span, 0, 1)
        local raw = mn + ratio * (mx - mn)
        local snapped = mn + math.floor((raw - mn) / step + 0.5) * step
        S[key] = clamp(snapped, mn, mx)
        paint()
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
    CTRLS[key] = { set = function(v)
        S[key] = clamp(v, mn, mx)
        paint()
    end }
    paint()
end

local function addButton(page, titleTxt, cb)
    local row = mkRow(page)
    ni("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text = titleTxt,
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    row.MouseButton1Click:Connect(function()
        pcall(cb)
    end)
end

local function syncUI()
    for key, ctrl in pairs(CTRLS) do
        local c = ctrl
        pcall(function()
            if c and c.set then
                c.set(S[key], true)
            end
        end)
    end
end

-- ============ FILTER MODULE (Realistic) ============
local FILTER_TINTS = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 220, 180),
    Color3.fromRGB(190, 215, 255),
    Color3.fromRGB(255, 190, 150),
    Color3.fromRGB(200, 255, 200),
    Color3.fromRGB(230, 210, 255),
}
local FILTER_TINT_NAMES = { "Neutral", "Warm", "Cold", "Sunset", "Forest", "Purple" }
local FILTER_PRESET_NAMES = { "Realistic", "Cinematic", "Vibrant", "Cold", "Warm", "Custom" }
local FILTER_PRESETS = {
    { 0.12, -0.08, 0.01, 0.25, 0.08, 1 },
    { 0.25, -0.15, 0.00, 0.50, 0.12, 2 },
    { 0.15,  0.30, 0.02, 0.60, 0.05, 1 },
    { 0.10, -0.05, 0.00, 0.20, 0.10, 3 },
    { 0.10,  0.05, 0.02, 0.30, 0.15, 2 },
    { 0.12, -0.08, 0.01, 0.25, 0.08, 1 },
}

local function applyFilter()
    if not S.filterOn then
        for _, n in ipairs({ "NanoCC", "NanoBloom", "NanoSun" }) do
            local e = Lighting:FindFirstChild(n)
            if e then
                pcall(function() e:Destroy() end)
            end
        end
        return
    end
    local cc = Lighting:FindFirstChild("NanoCC")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "NanoCC"
        cc.Parent = Lighting
    end
    cc.Enabled = true
    cc.Contrast = S.fContrast
    cc.Saturation = S.fSat
    cc.Brightness = S.fBright
    cc.TintColor = FILTER_TINTS[S.filterTintIdx] or Color3.new(1, 1, 1)
    local bl = Lighting:FindFirstChild("NanoBloom")
    if S.fBloom > 0 then
        if not bl then
            bl = Instance.new("BloomEffect")
            bl.Name = "NanoBloom"
            bl.Parent = Lighting
        end
        bl.Enabled = true
        bl.Intensity = S.fBloom
        bl.Size = 24
        bl.Threshold = 0.95
    elseif bl then
        bl.Enabled = false
    end
    local sr = Lighting:FindFirstChild("NanoSun")
    if S.fSunRays > 0 then
        if not sr then
            sr = Instance.new("SunRaysEffect")
            sr.Name = "NanoSun"
            sr.Parent = Lighting
        end
        sr.Enabled = true
        sr.Intensity = S.fSunRays
    elseif sr then
        sr.Enabled = false
    end
end

local function applyFilterPreset(idx)
    local p = FILTER_PRESETS[clamp(idx, 1, #FILTER_PRESETS)]
    if not p then
        return
    end
    if idx ~= 6 then
        S.fContrast = p[1]
        S.fSat = p[2]
        S.fBright = p[3]
        S.fBloom = p[4]
        S.fSunRays = p[5]
        S.filterTintIdx = p[6]
    end
    if CTRLS["fContrast"] then CTRLS["fContrast"].set(S.fContrast) end
    if CTRLS["fSat"] then CTRLS["fSat"].set(S.fSat) end
    if CTRLS["fBright"] then CTRLS["fBright"].set(S.fBright) end
    if CTRLS["fBloom"] then CTRLS["fBloom"].set(S.fBloom) end
    if CTRLS["fSunRays"] then CTRLS["fSunRays"].set(S.fSunRays) end
    if CTRLS["filterTintIdx"] then CTRLS["filterTintIdx"].set(S.filterTintIdx) end
    applyFilter()
end

if S.filterOn then
    applyFilter()
end

-- ============ MOVEMENT + SERVER MODULE ============
local flyBV, flyBG = nil, nil
local noclipCache = {}
local lastNoclipChar = nil

local function noclipRestore()
    for part, v in pairs(noclipCache) do
        pcall(function()
            if part and part.Parent then
                part.CanCollide = v
            end
        end)
    end
    table.clear(noclipCache)
    lastNoclipChar = nil
end

local function flyCleanup()
    pcall(function() if flyBV then flyBV:Destroy() end end)
    pcall(function() if flyBG then flyBG:Destroy() end end)
    flyBV = nil
    flyBG = nil
end

track(RS.Heartbeat:Connect(function()
    local c = LP.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if S.flyOn and hrp and hum and hum.Health > 0 then
        if not flyBV or flyBV.Parent ~= hrp then
            flyCleanup()
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "NanoHubFlyBV"
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.Name = "NanoHubFlyBG"
            flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBG.P = 9e4
            flyBG.D = 500
            flyBG.Parent = hrp
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.new(0, 0, 0)
        if cam then
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0.01 then
            move = move.Unit
        end
        flyBV.Velocity = move * S.flySpeed
        if cam then
            flyBG.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + cam.CFrame.LookVector)
        end
    elseif flyBV then
        flyCleanup()
    end
    if S.noclipOn and c then
        if lastNoclipChar ~= c then
            table.clear(noclipCache)
            lastNoclipChar = c
        end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                if noclipCache[p] == nil then
                    noclipCache[p] = p.CanCollide
                end
                p.CanCollide = false
            end
        end
    end
    if hum then
        if S.wsEnabled and hum.WalkSpeed ~= S.wsValue then
            hum.WalkSpeed = S.wsValue
        end
        if S.jpEnabled then
            if not hum.UseJumpPower then
                hum.UseJumpPower = true
            end
            if hum.JumpPower ~= S.jpValue then
                hum.JumpPower = S.jpValue
            end
        end
    end
end))

track(UIS.JumpRequest:Connect(function()
    if S.infJumpOn then
        local c = LP.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end
end))

-- Anti-AFK
local VU = game:GetService("VirtualUser")
track(LP.Idled:Connect(function()
    if S.antiAfkOn then
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new(0, 0))
        end)
    end
end))

-- Auto-Rejoin
local function rejoinServer()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end)
end
task.spawn(function()
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local rpg = coreGui:FindFirstChild("RobloxPromptGui")
        local overlay = rpg and rpg:FindFirstChild("promptOverlay")
        if overlay then
            overlay.ChildAdded:Connect(function(child)
                if S.autoRejoinOn and child.Name == "ErrorPrompt" then
                    task.delay(3, function()
                        rejoinServer()
                    end)
                end
            end)
        end
    end)
end)
track(LP.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed and S.autoRejoinOn then
        task.delay(1, function()
            rejoinServer()
        end)
    end
end))

-- Server Hop
local function serverHop()
    toast("Server Hop ...", CYAN)
    task.spawn(function()
        local reqFn = nil
        pcall(function()
            if type(http_request) == "function" then
                reqFn = http_request
            elseif type(http) == "table" and type(http.request) == "function" then
                reqFn = http.request
            elseif type(syn) == "table" and type(syn.request) == "function" then
                reqFn = syn.request
            elseif type(request) == "function" then
                reqFn = request
            end
        end)
        if not reqFn then
            toast("Kein request verfügbar", RED)
            return
        end
        local ok, resp = pcall(function()
            return reqFn({
                Url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?limit=100",
                Method = "GET",
            })
        end)
        if not ok then
            toast("Hop fehlgeschlagen", RED)
            return
        end
        local body = (type(resp) == "table" and resp.Body) or resp
        local ok2, data = pcall(function()
            return HS:JSONDecode(body)
        end)
        if not ok2 or type(data) ~= "table" or type(data.data) ~= "table" then
            toast("Hop fehlgeschlagen", RED)
            return
        end
        local candidates = {}
        for _, sv in ipairs(data.data) do
            if type(sv) == "table" and sv.id and sv.id ~= game.JobId then
                if (tonumber(sv.playing) or 0) < (tonumber(sv.maxPlayers) or 50) then
                    table.insert(candidates, sv.id)
                end
            end
        end
        if #candidates == 0 then
            toast("Kein Server gefunden", RED)
            return
        end
        local pick = candidates[math.random(1, #candidates)]
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, pick, LP)
        end)
    end)
end
-- ============ /MOVEMENT + SERVER MODULE ============

-- ============ CONFIG BUTTONS ============
local function saveConfigFull()
    if not canFS then
        toast("Config: kein FS", RED)
        return
    end
    local ok = pcall(function()
        if makefolder and isfolder and not isfolder(CFG_DIR) then
            makefolder(CFG_DIR)
        end
        writefile(CFG_PATH, HS:JSONEncode(S))
    end)
    if ok then
        toast("Config gespeichert", GRN)
    else
        toast("Config Fehler", RED)
    end
end

local function loadConfigFull()
    if not canFS then
        toast("Config: kein FS", RED)
        return
    end
    local ok, data = pcall(function()
        return HS:JSONDecode(readfile(CFG_PATH))
    end)
    if ok and type(data) == "table" then
        applyConfig(data)
        syncUI()
        setThemeVars(S.themeIdx)
        applyFilter()
        toast("Config geladen", GRN)
    else
        toast("Keine Config", RED)
    end
end

-- ============ PLAYER LIST ============
local playerRows = {}
local function clearPlayerRows()
    for _, row in pairs(playerRows) do
        pcall(function()
            if row and row.Destroy then
                row:Destroy()
            end
        end)
    end
    table.clear(playerRows)
end

local function buildPlayerList()
    if not plrPage then
        return
    end
    clearPlayerRows()
    for _, pl in ipairs(P:GetPlayers()) do
        if pl ~= LP then
            local row = mkRow(plrPage)
            ni("TextLabel", {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -140, 1, 0),
                BackgroundTransparency = 1,
                Text = pl.DisplayName .. " (@" .. pl.Name .. ")",
                TextColor3 = TXT,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })
            local tpLbl = ni("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -54, 0.5, 0),
                Size = UDim2.new(0, 40, 1, 0),
                BackgroundTransparency = 1,
                Text = "TP",
                TextColor3 = ACC,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })
            table.insert(themeAcc, { tpLbl, "TextColor3" })
            local spBtn = ni("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -8, 0, 4),
                Size = UDim2.new(0, 34, 0, 22),
                BackgroundColor3 = BG3,
                BorderSizePixel = 0,
                Text = "👁",
                TextColor3 = ACC,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false,
                Parent = row,
            })
            ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = spBtn })
            row.MouseButton1Click:Connect(function()
                pcall(function()
                    tpTo(pl)
                end)
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

-- ============ WAYPOINTS MODULE ============
local WPTS = {}
local wpDraws = {}
hub.wpDraws = wpDraws
local WP_FILE = CFG_DIR .. "/waypoints.json"

local function saveWpts()
    if not canFS then
        return
    end
    pcall(function()
        if makefolder and isfolder and not isfolder(CFG_DIR) then
            makefolder(CFG_DIR)
        end
        local arr = {}
        for i, w in ipairs(WPTS) do
            arr[i] = { name = w.name, x = w.pos.X, y = w.pos.Y, z = w.pos.Z }
        end
        writefile(WP_FILE, HS:JSONEncode(arr))
    end)
end

local function loadWpts()
    if not canFS then
        return
    end
    pcall(function()
        if isfile and isfile(WP_FILE) then
            local ok, arr = pcall(function()
                return HS:JSONDecode(readfile(WP_FILE))
            end)
            if ok and type(arr) == "table" then
                WPTS = {}
                for _, w in ipairs(arr) do
                    if type(w) == "table" and tonumber(w.x) and tonumber(w.y) and tonumber(w.z) then
                        table.insert(WPTS, {
                            name = tostring(w.name or "WP"),
                            pos = Vector3.new(tonumber(w.x), tonumber(w.y), tonumber(w.z)),
                        })
                    end
                end
            end
        end
    end)
end
loadWpts()

local wpRows = {}
local function clearWpRows()
    for _, r in pairs(wpRows) do
        pcall(function()
            if r and r.Destroy then
                r:Destroy()
            end
        end)
    end
    table.clear(wpRows)
end

local function wpRenamePrompt(idx)
    local box = ni("TextBox", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 200, 0, 34),
        BackgroundColor3 = BG2,
        TextColor3 = TXT,
        Text = WPTS[idx].name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ClearTextOnFocus = false,
        ZIndex = 60,
        Parent = ui,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = box })
    box:CaptureFocus()
    box.FocusLost:Connect(function(enter)
        local t = box.Text
        pcall(function() box:Destroy() end)
        if enter and t ~= "" and WPTS[idx] then
            WPTS[idx].name = t
            saveWpts()
            buildWpList()
            toast("WP umbenannt", GRN)
        end
    end)
end

local function buildWpList()
    if not wpPage then
        return
    end
    clearWpRows()
    for i, w in ipairs(WPTS) do
        local row = mkRow(wpPage)
        ni("TextLabel", {
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -130, 1, 0),
            BackgroundTransparency = 1,
            Text = w.name,
            TextColor3 = TXT,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        local tpL = ni("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -100, 0.5, 0),
            Size = UDim2.new(0, 30, 1, 0),
            BackgroundTransparency = 1,
            Text = "TP",
            TextColor3 = ACC,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Parent = row,
        })
        table.insert(themeAcc, { tpL, "TextColor3" })
        local renBtn = ni("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -46, 0, 4),
            Size = UDim2.new(0, 30, 0, 22),
            BackgroundColor3 = BG3,
            BorderSizePixel = 0,
            Text = "✎",
            TextColor3 = ACC,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = row,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = renBtn })
        local delBtn = ni("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -8, 0, 4),
            Size = UDim2.new(0, 30, 0, 22),
            BackgroundColor3 = BG3,
            BorderSizePixel = 0,
            Text = "🗑",
            TextColor3 = RED,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AutoButtonColor = false,
            Parent = row,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = delBtn })
        row.MouseButton1Click:Connect(function()
            local myC = LP.Character
            local my = myC and myC:FindFirstChild("HumanoidRootPart")
            if my then
                my.CFrame = CFrame.new(w.pos + Vector3.new(0, 3, 0))
                toast("WP -> " .. w.name, GRN)
            end
        end)
        renBtn.MouseButton1Click:Connect(function()
            wpRenamePrompt(i)
        end)
        delBtn.MouseButton1Click:Connect(function()
            table.remove(WPTS, i)
            saveWpts()
            buildWpList()
            toast("WP gelöscht", RED)
        end)
        wpRows[i] = row
    end
end

-- ============ CARD ESP MODULE ============
local CARD_KEYWORDS = { "card", "pack", "booster", "crate", "egg" }
local CARD_RARITY = {
    { "secret", Color3.fromRGB(255, 60, 60) },
    { "mythic", Color3.fromRGB(255, 80, 200) },
    { "godly",  Color3.fromRGB(170, 170, 185) },
    { "legend", Color3.fromRGB(255, 160, 60) },
    { "epic",   Color3.fromRGB(170, 80, 255) },
    { "rare",   Color3.fromRGB(60, 140, 255) },
    { "shiny",  Color3.fromRGB(60, 255, 220) },
    { "common", Color3.fromRGB(150, 150, 150) },
}
local cardEntries = {}
local cardDraws = {}
hub.cardDraws = cardDraws
local cardScanAcc = 0

local function cardColorFor(name)
    local low = string.lower(name)
    for _, r in ipairs(CARD_RARITY) do
        if string.find(low, r[1], 1, true) then
            return r[2]
        end
    end
    return nil
end

local function cardScan()
    local nxt = {}
    local count = 0
    for _, inst in ipairs(workspace:GetDescendants()) do
        if count >= 40 then
            break
        end
        if inst:IsA("BasePart") or inst:IsA("Model") then
            local low = string.lower(inst.Name)
            local matched = false
            for _, k in ipairs(CARD_KEYWORDS) do
                if string.find(low, k, 1, true) then
                    matched = true
                    break
                end
            end
            if matched and not string.find(low, "backpack", 1, true) then
                local part
                if inst:IsA("BasePart") then
                    part = inst
                else
                    part = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
                end
                if part then
                    count = count + 1
                    nxt[count] = { part = part, name = inst.Name, col = cardColorFor(inst.Name) or ACC }
                end
            end
        end
    end
    cardEntries = nxt
end

track(RS.Heartbeat:Connect(function(dt)
    if S.cardEspOn then
        cardScanAcc = cardScanAcc + dt
        if cardScanAcc >= 0.5 then
            cardScanAcc = 0
            cardScan()
        end
    elseif #cardEntries > 0 then
        cardEntries = {}
    end
end))

track(RS.RenderStepped:Connect(function()
    local v = workspace.CurrentCamera
    if not (S.cardEspOn and canDraw and v) then
        for i = 1, 40 do
            local d = cardDraws[i]
            if d then
                pcall(function()
                    d.dot.Visible = false
                    d.lbl.Visible = false
                end)
            end
        end
        return
    end
    local myC = LP.Character
    local myHrp = myC and myC:FindFirstChild("HumanoidRootPart")
    for i = 1, 40 do
        local e = cardEntries[i]
        local d = cardDraws[i]
        if not d then
            d = { dot = Drawing.new("Circle"), lbl = Drawing.new("Text") }
            d.dot.Thickness = 1
            d.dot.NumSides = 10
            d.dot.Filled = true
            d.dot.Radius = 4
            d.lbl.Size = 13
            d.lbl.Center = true
            d.lbl.Outline = true
            cardDraws[i] = d
        end
        local drawn = false
        if e and e.part and e.part.Parent then
            local dist = myHrp and (e.part.Position - myHrp.Position).Magnitude or 0
            if dist <= S.cardMaxD then
                local sp, onS = v:WorldToViewportPoint(e.part.Position)
                if onS and sp.Z > 0 then
                    drawn = true
                    d.dot.Color = e.col
                    d.dot.Position = Vector2.new(sp.X, sp.Y)
                    d.dot.Visible = true
                    d.lbl.Color = e.col
                    d.lbl.Text = e.name .. " (" .. string.format("%.0f", dist) .. "m)"
                    d.lbl.Position = Vector2.new(sp.X, sp.Y - 14)
                    d.lbl.Visible = true
                end
            end
        end
        if not drawn then
            d.dot.Visible = false
            d.lbl.Visible = false
        end
    end
end))
-- ============ /CARD ESP MODULE ============

-- ============ TABS ============
addHeader(aimPage, "Core")
local aimSet = nil
aimSet = addToggle(aimPage, "AimLock", "on", true)
addToggle(aimPage, "Taste aktiv", "keyEnabled", true)
addCycle(aimPage, "Taste", "keyIdx", KEYNAMES)
addCycle(aimPage, "Ziel-Part", "hitIdx", HITS)
addCycle(aimPage, "Modus", "aimIdx", AIMMODES)
addSlider(aimPage, "Smoothing", "smooth", 0.05, 1, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(aimPage, "Range", "range", 100, 2000, 100)
addSlider(aimPage, "FOV Radius", "fovR", 60, 600, 20)
addHeader(aimPage, "Triggerbot")
addToggle(aimPage, "Triggerbot", "trigOn", true)
addSlider(aimPage, "Trigger Delay", "trigDelay", 0, 0.5, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(aimPage, "Trigger FOV", "trigFov", 5, 120, 5)
addSlider(aimPage, "Trigger Range", "trigRange", 50, 1000, 50)
addToggle(aimPage, "Trigger Team Check", "trigTeam", true)
addHeader(aimPage, "Checks")
addToggle(aimPage, "Team Check", "teamCheck", true)
addToggle(aimPage, "Wall Check", "wallCheck", true)

addHeader(visPage, "Draw")
addCycle(visPage, "Draw Color", "colIdx", COLNAMES)
addToggle(visPage, "FOV Circle", "showFov", true)
addToggle(visPage, "Snap Line", "showSnap", true)
addToggle(visPage, "Head Dot", "showDot", true)
addToggle(visPage, "Distance Labels", "showDist", true)

addHeader(espPage, "Player ESP")
addToggle(espPage, "ESP Master", "espOn", true)
addToggle(espPage, "Box", "espBox", true)
addToggle(espPage, "HP Bar", "espHP", true)
addCycle(espPage, "HP Position", "hpSide", HP_SIDES)
addToggle(espPage, "Team Farben", "espTeamCol", true)
addToggle(espPage, "Chams", "chamsOn", true)
addSlider(espPage, "Chams Transp", "chamsFill", 0, 1, 0.1, function(x) return string.format("%.1f", x) end)
addToggle(espPage, "Name + Distance", "espName", true)
addToggle(espPage, "Skeleton", "espSkel", true)
addToggle(espPage, "Tracer", "espTracer", true)
addSlider(espPage, "Max Distance", "espMaxD", 100, 5000, 100)
addHeader(espPage, "Card ESP")
addToggle(espPage, "Card / Pack ESP", "cardEspOn", true)
addSlider(espPage, "Card Max Distance", "cardMaxD", 100, 5000, 100)

addHeader(filterPage, "Realistic Filter")
addToggle(filterPage, "Filter AN", "filterOn", true, function() applyFilter() end)
addCycle(filterPage, "Preset", "filterPresetIdx", FILTER_PRESET_NAMES, function() applyFilterPreset(S.filterPresetIdx) end)
addSlider(filterPage, "Contrast", "fContrast", -0.5, 1, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(filterPage, "Sättigung", "fSat", -1, 1, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(filterPage, "Helligkeit", "fBright", -0.5, 0.5, 0.05, function(x) return string.format("%.2f", x) end)
addCycle(filterPage, "Farb-Tint", "filterTintIdx", FILTER_TINT_NAMES, function() applyFilter() end)
addHeader(filterPage, "Extra")
addSlider(filterPage, "Bloom", "fBloom", 0, 2, 0.1, function(x) return string.format("%.1f", x) end)
addSlider(filterPage, "Sun Rays", "fSunRays", 0, 0.5, 0.05, function(x) return string.format("%.2f", x) end)
addButton(filterPage, "Filter komplett AUS", function()
    if CTRLS["filterOn"] then
        CTRLS["filterOn"].set(false)
    end
    applyFilter()
    toast("Filter aus", RED)
end)

addHeader(movePage, "Fly")
addToggle(movePage, "Fly (WASD + Space)", "flyOn", true, function(v)
    if not v then
        pcall(function() flyCleanup() end)
    end
end)
addSlider(movePage, "Fly Speed", "flySpeed", 10, 300, 10)
addHeader(movePage, "Movement")
addToggle(movePage, "Noclip", "noclipOn", true, function(v)
    if not v then
        pcall(function() noclipRestore() end)
    end
end)
addToggle(movePage, "Infinite Jump", "infJumpOn", true)
addToggle(movePage, "Click-TP", "clickTpOn", true)
addHeader(movePage, "Speed / Jump")
addToggle(movePage, "WalkSpeed aktiv", "wsEnabled", true, function(v)
    if not v then
        pcall(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.WalkSpeed = 16
            end
        end)
    end
end)
addSlider(movePage, "WalkSpeed", "wsValue", 8, 200, 1)
addToggle(movePage, "JumpPower aktiv", "jpEnabled", true, function(v)
    if not v then
        pcall(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.UseJumpPower = true
                h.JumpPower = 50
            end
        end)
    end
end)
addSlider(movePage, "JumpPower", "jpValue", 20, 300, 5)

addHeader(plrPage, "Spieler Liste")
buildPlayerList()

addHeader(wpPage, "Waypoints")
addToggle(wpPage, "Marker anzeigen", "wpMarkers", true)
addButton(wpPage, "+ Waypoint hier speichern", function()
    local myC = LP.Character
    local my = myC and myC:FindFirstChild("HumanoidRootPart")
    if my then
        table.insert(WPTS, { name = "WP #" .. tostring(#WPTS + 1), pos = my.Position })
        saveWpts()
        buildWpList()
        toast("Waypoint gespeichert", GRN)
    end
end)
buildWpList()

addHeader(setPage, "Config")
addButton(setPage, "Config speichern", saveConfigFull)
addButton(setPage, "Config laden", loadConfigFull)
addHeader(setPage, "UI")
addCycle(setPage, "Theme", "themeIdx", THEME_NAMES, function() setThemeVars(S.themeIdx) end)
addHeader(setPage, "Hotkeys")
addCycle(setPage, "GUI Taste", "guiKeyIdx", GUIKEY_NAMES)
addCycle(setPage, "Free-Mouse Taste", "freeMouseIdx", FREEMOUSE_NAMES)
addToggle(setPage, "Free Mouse (Maus lösen)", "freeMouseOn", true)
addHeader(setPage, "Server")
addToggle(setPage, "Anti-AFK", "antiAfkOn", false)
addToggle(setPage, "Auto-Rejoin bei Kick", "autoRejoinOn", true)
addButton(setPage, "Server Hop (neuer Server)", serverHop)
addHeader(setPage, "Start")
addToggle(setPage, "Fast Start (Splash überspringen)", "fastStart", true, function(v, silent)
    if not silent then
        saveSilent()
    end
end)

-- ============ HOME TAB (animated) ============
do
    local homeAvatarCard = ni("Frame", {
        Size = UDim2.new(1, -16, 0, 84),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        Parent = homePage,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = homeAvatarCard })

    local homeAvatar = ni("ImageButton", {
        Position = UDim2.new(0, 10, 0.5, -32),
        Size = UDim2.new(0, 64, 0, 64),
        BackgroundColor3 = BG3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = homeAvatarCard,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = homeAvatar })
    local homeAvatarStroke = ni("UIStroke", {
        Color = ACC, Thickness = 2, Transparency = 0.25, Parent = homeAvatar,
    })
    table.insert(themeAcc, { homeAvatarStroke, "Color" })

    task.spawn(function()
        local ok, content = pcall(function()
            return P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.AvatarHeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and content and homeAvatar.Parent then
            homeAvatar.Image = content
        end
    end)

    homeAvatar.MouseButton1Click:Connect(function()
        S.themeIdx = (S.themeIdx % #THEMES) + 1
        if CTRLS["themeIdx"] then
            CTRLS["themeIdx"].set(S.themeIdx)
        else
            setThemeVars(S.themeIdx)
        end
        toast("Theme: " .. THEME_NAMES[S.themeIdx], ACC)
        pcall(function()
            TS:Create(homeAvatar, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 70, 0, 70) }):Play()
            task.delay(0.12, function()
                TS:Create(homeAvatar, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 64, 0, 64) }):Play()
            end)
        end)
        saveSilent()
    end)

    ni("TextLabel", {
        Position = UDim2.new(0, 86, 0, 14),
        Size = UDim2.new(1, -96, 0, 24),
        BackgroundTransparency = 1,
        Text = LP.DisplayName,
        TextColor3 = TXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = homeAvatarCard,
    })
    ni("TextLabel", {
        Position = UDim2.new(0, 86, 0, 40),
        Size = UDim2.new(1, -96, 0, 16),
        BackgroundTransparency = 1,
        Text = "@" .. LP.Name,
        TextColor3 = SUB,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = homeAvatarCard,
    })
    ni("TextLabel", {
        Position = UDim2.new(0, 86, 0, 58),
        Size = UDim2.new(1, -96, 0, 14),
        BackgroundTransparency = 1,
        Text = "ID: " .. tostring(LP.UserId),
        TextColor3 = SUB,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Parent = homeAvatarCard,
    })

    task.spawn(function()
        while homeAvatar and homeAvatar.Parent do
            pcall(function()
                TS:Create(homeAvatarStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 3.5, Transparency = 0 }):Play()
            end)
            task.wait(0.9)
            if not (homeAvatar and homeAvatar.Parent) then break end
            pcall(function()
                TS:Create(homeAvatarStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 1.5, Transparency = 0.5 }):Play()
            end)
            task.wait(0.9)
        end
    end)

    local homeBanner = ni("Frame", {
        Size = UDim2.new(1, -16, 0, 44),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = homePage,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = homeBanner })
    local homeBannerGrad = ni("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, ACC),
            ColorSequenceKeypoint.new(1, CYAN),
        }),
        Rotation = 10,
        Parent = homeBanner,
    })
    table.insert(gradRepaints, function(col)
        pcall(function()
            homeBannerGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, col),
                ColorSequenceKeypoint.new(1, CYAN),
            })
        end)
    end)
    ni("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = "Willkommen, " .. LP.DisplayName .. "!  🚀",
        TextColor3 = Color3.fromRGB(15, 15, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2,
        Parent = homeBanner,
    })
    local homeShine = ni("Frame", {
        Position = UDim2.new(0, -90, -0.5, 0),
        Size = UDim2.new(0, 55, 2, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        Rotation = 20,
        ZIndex = 3,
        Parent = homeBanner,
    })

    task.spawn(function()
        while homeBanner and homeBanner.Parent do
            pcall(function()
                TS:Create(homeBannerGrad, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(0.35, 0) }):Play()
            end)
            task.wait(2.6)
            if not (homeBanner and homeBanner.Parent) then break end
            pcall(function()
                TS:Create(homeBannerGrad, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(-0.35, 0) }):Play()
            end)
            task.wait(2.6)
        end
    end)

    task.spawn(function()
        task.wait(1.3)
        while homeBanner and homeBanner.Parent do
            pcall(function()
                homeShine.Position = UDim2.new(0, -90, -0.5, 0)
                TS:Create(homeShine, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(1, 40, -0.5, 0) }):Play()
            end)
            task.wait(4.2)
        end
    end)

    local homeStatHead = ni("Frame", {
        Size = UDim2.new(1, -16, 0, 20),
        BackgroundTransparency = 1,
        Parent = homePage,
    })
    local homeStatLbl = ni("TextLabel", {
        Position = UDim2.new(0, 2, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = "STATUS",
        TextColor3 = ACC,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = homeStatHead,
    })
    table.insert(themeAcc, { homeStatLbl, "TextColor3" })
    ni("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -22, 0.5, 0),
        Size = UDim2.new(0, 40, 1, 0),
        BackgroundTransparency = 1,
        Text = "LIVE",
        TextColor3 = GRN,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = homeStatHead,
    })
    local homeLiveDot = ni("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = GRN,
        BorderSizePixel = 0,
        Parent = homeStatHead,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = homeLiveDot })

    task.spawn(function()
        while homeLiveDot and homeLiveDot.Parent do
            pcall(function()
                TS:Create(homeLiveDot, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.7, Size = UDim2.new(0, 11, 0, 11) }):Play()
            end)
            task.wait(0.7)
            if not (homeLiveDot and homeLiveDot.Parent) then break end
            pcall(function()
                TS:Create(homeLiveDot, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0, Size = UDim2.new(0, 8, 0, 8) }):Play()
            end)
            task.wait(0.7)
        end
    end)

    local homeStats = {}
    local function homeStatRow(label)
        local row = ni("Frame", {
            Size = UDim2.new(1, -16, 0, 26),
            BackgroundColor3 = BG2,
            BorderSizePixel = 0,
            Parent = homePage,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = row })
        ni("TextLabel", {
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = SUB,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
        local v = ni("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0.5, -12, 1, 0),
            BackgroundTransparency = 1,
            Text = "...",
            TextColor3 = TXT,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        homeStats[label] = v
    end
    homeStatRow("FPS")
    homeStatRow("Ping")
    homeStatRow("Spieler")
    homeStatRow("Spiel")
    homeStatRow("Executor")

    local homeFeatHead = ni("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        BackgroundTransparency = 1,
        Text = "FEATURES",
        TextColor3 = ACC,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = homePage,
    })
    table.insert(themeAcc, { homeFeatHead, "TextColor3" })

    local homeGrid = ni("Frame", {
        Size = UDim2.new(1, -16, 0, 130),
        BackgroundTransparency = 1,
        Parent = homePage,
    })
    ni("UIGridLayout", {
        CellSize = UDim2.new(0.5, -7, 0, 28),
        CellPadding = UDim2.new(0, 8, 0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = homeGrid,
    })
    local homeFeats = { "🎯 AimLock", "🔫 Triggerbot", "👁️ ESP", "🧊 Chams", "📍 Waypoints", "🎞️ Filter", "🚀 Movement", "🃏 Card ESP" }
    for _, f in ipairs(homeFeats) do
        local b = ni("Frame", {
            BackgroundColor3 = BG2,
            BorderSizePixel = 0,
            Parent = homeGrid,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = b })
        local bar = ni("Frame", {
            Size = UDim2.new(0, 3, 1, -12),
            Position = UDim2.new(0, 0, 0, 6),
            BackgroundColor3 = ACC,
            BorderSizePixel = 0,
            Parent = b,
        })
        table.insert(themeAcc, { bar, "BackgroundColor3" })
        ni("TextLabel", {
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -18, 1, 0),
            BackgroundTransparency = 1,
            Text = f,
            TextColor3 = TXT,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = b,
        })
    end

    ni("TextLabel", {
        Size = UDim2.new(1, -16, 0, 40),
        BackgroundTransparency = 1,
        Text = "NanoHub v1.29  •  Avatar-Klick = Theme\nHotkeys & Einstellungen: Settings-Tab",
        TextColor3 = SUB,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = homePage,
    })

    local StatsSvc = game:GetService("Stats")
    task.spawn(function()
        local homeFrames = 0
        local homeFpsConn = RS.RenderStepped:Connect(function()
            homeFrames = homeFrames + 1
        end)
        while homePage and homePage.Parent do
            task.wait(1)
            if not (homePage and homePage.Parent) then break end
            if homeStats["FPS"] then
                homeStats["FPS"].Text = tostring(homeFrames) .. " FPS"
            end
            homeFrames = 0
            if homeStats["Ping"] then
                local okP, ping = pcall(function()
                    return StatsSvc.Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                homeStats["Ping"].Text = okP and string.format("%.0f ms", ping) or "?"
            end
            if homeStats["Spieler"] then
                homeStats["Spieler"].Text = tostring(#P:GetPlayers()) .. " / " .. tostring(P.MaxPlayers)
            end
            if homeStats["Spiel"] then
                homeStats["Spiel"].Text = tostring(game.Name)
            end
            if homeStats["Executor"] then
                local ex = "Unbekannt"
                pcall(function()
                    if type(identifyexecutor) == "function" then
                        ex = tostring(identifyexecutor())
                    elseif type(getexecutorname) == "function" then
                        ex = tostring(getexecutorname())
                    end
                end)
                homeStats["Executor"].Text = ex
            end
        end
        pcall(function() homeFpsConn:Disconnect() end)
    end)
end
-- ============ /HOME TAB ============

-- ============ FREE MOUSE LOOP ============
track(RS.RenderStepped:Connect(function()
    if S.freeMouseOn then
        pcall(function()
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end)
    end
end))

-- ============ SPLASH ============
if S.fastStart then
    win.Visible = true
else
    local splash = ni("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = BG0,
        BorderSizePixel = 0,
        ZIndex = 90,
        Parent = ui,
    })
    local spTitle = ni("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.22, 0),
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = ACC,
        Font = Enum.Font.GothamBold,
        TextSize = 38,
        ZIndex = 91,
        Parent = splash,
    })
    table.insert(themeAcc, { spTitle, "TextColor3" })
    local spSub = ni("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.22, 50),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "Universal Rage Aim",
        TextColor3 = SUB,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 91,
        Parent = splash,
    })
    local spAvatar = ni("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.22, 74),
        Size = UDim2.new(0, 100, 0, 100),
        BackgroundTransparency = 1,
        ZIndex = 91,
        Parent = splash,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spAvatar })
    local spAvStroke = ni("UIStroke", { Color = ACC, Thickness = 1, Transparency = 0.3, Parent = spAvatar })
    table.insert(themeAcc, { spAvStroke, "Color" })
    task.spawn(function()
        local ok, content = pcall(function()
            return P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
        end)
        if ok and content and spAvatar.Parent then
            spAvatar.Image = content
        end
    end)
    local spLine = ni("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.58, 0),
        Size = UDim2.new(0, 260, 0, 6),
        BackgroundColor3 = BG3,
        BorderSizePixel = 0,
        ZIndex = 91,
        Parent = splash,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spLine })
    local spFill = ni("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ACC,
        BorderSizePixel = 0,
        ZIndex = 92,
        Parent = spLine,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spFill })
    local spGrad = ni("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, ACC),
            ColorSequenceKeypoint.new(1, CYAN),
        }),
        Parent = spFill,
    })
    table.insert(gradRepaints, function(col)
        pcall(function()
            spGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, col),
                ColorSequenceKeypoint.new(1, CYAN),
            })
        end)
    end)
    local spPct = ni("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.58, 14),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = TXT,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        ZIndex = 91,
        Parent = splash,
    })
    local spWelcome = ni("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.64, 0),
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        ZIndex = 91,
        Parent = splash,
    })
    local spBtn = ni("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.71, 0),
        Size = UDim2.new(0, 150, 0, 36),
        BackgroundColor3 = ACC,
        BorderSizePixel = 0,
        Text = "Starten",
        TextColor3 = Color3.fromRGB(15, 15, 20),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Visible = false,
        AutoButtonColor = false,
        ZIndex = 91,
        Parent = splash,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = spBtn })

    task.spawn(function()
        local full = "NanoHub"
        for i = 1, #full do
            spTitle.Text = string.sub(full, 1, i)
            task.wait(0.06)
        end
    end)
    task.spawn(function()
        local i = 0
        while i < 100 do
            i = i + 2
            if i > 100 then
                i = 100
            end
            spFill.Size = UDim2.new(i / 100, 0, 1, 0)
            spPct.Text = tostring(i) .. "%"
            if i < 100 then
                task.wait(0.04)
            end
        end
        spWelcome.Text = "Willkommen, " .. LP.DisplayName .. "!"
        spBtn.Visible = true
        TS:Create(spBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 170, 0, 40) }):Play()
    end)
    spBtn.MouseButton1Click:Connect(function()
        spBtn.Visible = false
        win.Visible = true
        TS:Create(splash, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
        task.delay(0.4, function()
            pcall(function()
                splash:Destroy()
            end)
        end)
    end)
end

-- ============ CLOSE BUTTON ============
closeBtn.MouseButton1Click:Connect(function()
    for i = 1, #hub.conns do
        local c = hub.conns[i]
        pcall(function()
            if c and c.Connected then
                c:Disconnect()
            end
        end)
    end
    table.clear(hub.conns)
    removeDraws(hub.draws)
    hub.draws = nil
    removeDraws(hub.distLbls)
    hub.distLbls = nil
    for _, d in pairs(hub.wpDraws or {}) do
        pcall(function()
            if d then
                if d.dot then d.dot:Remove() end
                if d.lbl then d.lbl:Remove() end
            end
        end)
    end
    hub.wpDraws = nil
    espClearAll()
    pcall(function() flyCleanup() end)
    pcall(function() noclipRestore() end)
    pcall(function()
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = 16
            h.UseJumpPower = true
            h.JumpPower = 50
        end
    end)
    for i = 1, 40 do
        local d = cardDraws[i]
        if d then
            pcall(function()
                d.dot:Remove()
                d.lbl:Remove()
            end)
        end
    end
    for _, n in ipairs({ "NanoCC", "NanoBloom", "NanoSun" }) do
        local e = Lighting:FindFirstChild(n)
        if e then
            pcall(function() e:Destroy() end)
        end
    end
    pcall(function()
        hub.ui:Destroy()
    end)
    hub.ui = nil
end)

-- ============ KEYBINDS ============
local trigNext = 0
local trigHeld = false
track(UIS.InputBegan:Connect(function(inp, g)
    if g then
        return
    end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and S.clickTpOn and not trigHeld then
        local cam = workspace.CurrentCamera
        local myC = LP.Character
        local myHrp = myC and myC:FindFirstChild("HumanoidRootPart")
        if cam and myHrp then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            local ex = {}
            if myC then
                table.insert(ex, myC)
            end
            if ui then
                table.insert(ex, ui)
            end
            params.FilterDescendantsInstances = ex
            local ray = cam:ScreenPointToRay(M.X, M.Y)
            local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            local pos = hit and hit.Position or (ray.Origin + ray.Direction * 200)
            myHrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            toast("Click-TP", GRN)
        end
        return
    end
    if inp.KeyCode == GUIKEY_CODES[S.guiKeyIdx] then
        win.Visible = not win.Visible
    elseif inp.KeyCode == FREEMOUSE_CODES[S.freeMouseIdx] then
        S.freeMouseOn = not S.freeMouseOn
        if CTRLS["freeMouseOn"] then
            CTRLS["freeMouseOn"].set(S.freeMouseOn, true)
        end
        if S.freeMouseOn then
            toast("Free Mouse AN", GRN)
        else
            toast("Free Mouse AUS", RED)
        end
    elseif inp.KeyCode == curKey() and S.keyEnabled then
        if aimSet then
            aimSet.set(not S.on)
        end
    end
end))

-- ============ MAIN LOOP (AIMBOT) ============
track(RS.RenderStepped:Connect(function()
    local v = workspace.CurrentCamera
    local myC = LP.Character
    local myHrp = myC and myC:FindFirstChild("HumanoidRootPart") or nil
    if canDraw and fovC then
        if S.on and S.showFov and v then
            fovC.Color = drawColor()
            fovC.Radius = S.fovR
            fovC.Position = Vector2.new(v.ViewportSize.X / 2, v.ViewportSize.Y / 2)
            fovC.Visible = true
        else
            fovC.Visible = false
        end
    end
    local best, bestPart, bestSp = nil, nil, nil
    if S.on and v then
        best, bestPart, bestSp = findTarget()
    end
    if canDraw and snapL then
        if best and bestSp and S.showSnap and v then
            snapL.Color = drawColor()
            snapL.From = Vector2.new(v.ViewportSize.X / 2, v.ViewportSize.Y / 2)
            snapL.To = bestSp
            snapL.Visible = true
        else
            snapL.Visible = false
        end
    end
    if canDraw and headD then
        if best and bestSp and S.showDot and v then
            headD.Color = drawColor()
            headD.Radius = 4
            headD.Position = bestSp
            headD.Visible = true
        else
            headD.Visible = false
        end
    end
    if canDraw then
        if S.showDist and S.on and v then
            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= LP and pl.Character and pl.Character:FindFirstChild("Head") then
                    local h = pl.Character.Head
                    local sp, on = v:WorldToViewportPoint(h.Position)
                    if on then
                        if not distLbls[pl] then
                            local t = Drawing.new("Text")
                            t.Size = 13
                            t.Center = true
                            t.Outline = true
                            t.Visible = false
                            distLbls[pl] = t
                        end
                        local d3 = myHrp and (h.Position - myHrp.Position).Magnitude or 0
                        distLbls[pl].Position = Vector2.new(sp.X, sp.Y - 26)
                        distLbls[pl].Text = string.format("%.0f", d3) .. " studs"
                        distLbls[pl].Color = Color3.fromRGB(220, 220, 230)
                        distLbls[pl].Visible = true
                    elseif distLbls[pl] then
                        distLbls[pl].Visible = false
                    end
                end
            end
        else
            for _, lb in pairs(distLbls) do
                pcall(function()
                    lb.Visible = false
                end)
            end
        end
    end
    if best and bestPart and v then
        local alpha = 1
        if S.aimIdx == 2 then
            alpha = clamp(1 - S.smooth, 0.05, 1)
        end
        local targetCFrame = CFrame.new(v.CFrame.Position, bestPart.Position)
        v.CFrame = v.CFrame:Lerp(targetCFrame, alpha)
    end
    -- Triggerbot
    if S.trigOn and v then
        local center2 = Vector2.new(v.ViewportSize.X / 2, v.ViewportSize.Y / 2)
        local tHit = false
        for _, pl in ipairs(P:GetPlayers()) do
            if not tHit and pl ~= LP then
                if not (S.trigTeam and pl.Team ~= nil and pl.Team == LP.Team) then
                    local c = pl.Character
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    local part = c and c:FindFirstChild(HITS[S.hitIdx])
                    if hum and hum.Health > 0 and part then
                        local sp, onS = v:WorldToViewportPoint(part.Position)
                        if onS then
                            local d2 = (Vector2.new(sp.X, sp.Y) - center2).Magnitude
                            if d2 <= S.trigFov then
                                local okR = true
                                if myHrp then
                                    okR = (part.Position - myHrp.Position).Magnitude <= S.trigRange
                                end
                                if okR and (not S.wallCheck or isVisible(part)) then
                                    tHit = true
                                end
                            end
                        end
                    end
                end
            end
        end
        local now = os.clock()
        if tHit and not trigHeld and now >= trigNext then
            trigHeld = true
            pcall(function()
                if type(mouse1press) == "function" then
                    mouse1press()
                else
                    local VU2 = game:GetService("VirtualUser")
                    VU2:CaptureController()
                    VU2:Button1Down(Vector2.new(0, 0))
                end
            end)
            task.delay(0.1, function()
                pcall(function()
                    if type(mouse1release) == "function" then
                        mouse1release()
                    else
                        local VU2 = game:GetService("VirtualUser")
                        VU2:Button1Up(Vector2.new(0, 0))
                    end
                end)
                trigHeld = false
                trigNext = os.clock() + S.trigDelay
            end)
        end
    end
end))

-- ============ ESP + CHAMS LOOP ============
track(RS.RenderStepped:Connect(function()
    if not S.espOn and not S.chamsOn then
        for _, e in pairs(espCache) do
            pcall(function()
                if e.box then e.box.Visible = false end
                if e.name then e.name.Visible = false end
                if e.tracer then e.tracer.Visible = false end
                if e.hpBg then e.hpBg.Visible = false end
                if e.hpF then e.hpF.Visible = false end
                if e.skel then
                    for i = 1, #e.skel do
                        if e.skel[i] then
                            e.skel[i].Visible = false
                        end
                    end
                end
            end)
            pcall(function()
                if e.hl then
                    e.hl:Destroy()
                    e.hl = nil
                end
            end)
        end
        return
    end
    local v = workspace.CurrentCamera
    if not v then
        return
    end
    local myC = LP.Character
    local myHrp = myC and myC:FindFirstChild("HumanoidRootPart") or nil
    local vp = v.ViewportSize
    for pl, e in pairs(espCache) do
        local seen = false
        pcall(function()
            local c = pl.Character
            if c and S.espOn and canDraw then
                local head = c:FindFirstChild("Head")
                local hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
                local hum = c:FindFirstChildOfClass("Humanoid")
                if head and hrp and hum and hum.Health > 0 then
                    if not (S.teamCheck and pl.Team ~= nil and pl.Team == LP.Team) then
                        local dist = myHrp and (head.Position - myHrp.Position).Magnitude or 0
                        if dist <= S.espMaxD then
                            local spT = v:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
                            local spB = v:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
                            if spT.Z > 0 and spB.Z > 0 then
                                seen = true
                                local ec = drawColor()
                                if S.espTeamCol and pl.Team then
                                    ec = pl.Team.TeamColor.Color
                                end
                                local yTop = spT.Y
                                local yBot = spB.Y
                                local bh = yBot - yTop
                                local bw = bh * 0.46
                                local cx = spT.X
                                if S.espBox then
                                    if not e.box then
                                        e.box = Drawing.new("Square")
                                        e.box.Thickness = 1
                                        e.box.Filled = false
                                    end
                                    e.box.Color = ec
                                    e.box.Position = Vector2.new(cx - bw / 2, yTop)
                                    e.box.Size = Vector2.new(bw, bh)
                                    e.box.Visible = true
                                elseif e.box then
                                    e.box.Visible = false
                                end
                                if S.espHP then
                                    if not e.hpBg then
                                        e.hpBg = Drawing.new("Square")
                                        e.hpBg.Filled = true
                                        e.hpBg.Color = Color3.fromRGB(12, 12, 16)
                                        e.hpBg.Thickness = 1
                                    end
                                    if not e.hpF then
                                        e.hpF = Drawing.new("Square")
                                        e.hpF.Filled = true
                                    end
                                    local ratio = clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                    local fh = math.floor(bh * ratio + 0.5)
                                    if fh < 1 then
                                        fh = 1
                                    end
                                    local barX
                                    if S.hpSide == 2 then
                                        barX = cx + bw / 2 + 3
                                    else
                                        barX = cx - bw / 2 - 6
                                    end
                                    e.hpBg.Transparency = 0.35
                                    e.hpBg.Position = Vector2.new(barX, yTop)
                                    e.hpBg.Size = Vector2.new(3, bh)
                                    e.hpBg.Visible = true
                                    e.hpF.Color = RED:Lerp(GRN, ratio)
                                    e.hpF.Position = Vector2.new(barX, yBot - fh)
                                    e.hpF.Size = Vector2.new(3, fh)
                                    e.hpF.Visible = true
                                else
                                    if e.hpBg then
                                        e.hpBg.Visible = false
                                    end
                                    if e.hpF then
                                        e.hpF.Visible = false
                                    end
                                end
                                if S.espName then
                                    if not e.name then
                                        e.name = Drawing.new("Text")
                                        e.name.Size = 14
                                        e.name.Center = true
                                        e.name.Outline = true
                                    end
                                    e.name.Color = ec
                                    e.name.Text = pl.Name .. " (" .. string.format("%.0f", dist) .. "m)"
                                    e.name.Position = Vector2.new(cx, yTop - 20)
                                    e.name.Visible = true
                                elseif e.name then
                                    e.name.Visible = false
                                end
                                if S.espSkel then
                                    if not e.skel then
                                        e.skel = {}
                                    end
                                    local bones = R15_BONES
                                    if c:FindFirstChild("Torso") then
                                        bones = R6_BONES
                                    end
                                    for i = #e.skel + 1, 15 do
                                        local ln = Drawing.new("Line")
                                        ln.Thickness = 1
                                        ln.Visible = false
                                        e.skel[i] = ln
                                    end
                                    for i = 1, #bones do
                                        local a = bonePos(c, bones[i][1])
                                        local b = bonePos(c, bones[i][2])
                                        local ln = e.skel[i]
                                        if a and b then
                                            local pa = v:WorldToViewportPoint(a)
                                            local pb = v:WorldToViewportPoint(b)
                                            if pa.Z > 0 and pb.Z > 0 then
                                                ln.Color = ec
                                                ln.From = Vector2.new(pa.X, pa.Y)
                                                ln.To = Vector2.new(pb.X, pb.Y)
                                                ln.Visible = true
                                            else
                                                ln.Visible = false
                                            end
                                        else
                                            ln.Visible = false
                                        end
                                    end
                                    for i = #bones + 1, #e.skel do
                                        if e.skel[i] then
                                            e.skel[i].Visible = false
                                        end
                                    end
                                elseif e.skel then
                                    for i = 1, #e.skel do
                                        if e.skel[i] then
                                            e.skel[i].Visible = false
                                        end
                                    end
                                end
                                if S.espTracer then
                                    if not e.tracer then
                                        e.tracer = Drawing.new("Line")
                                        e.tracer.Thickness = 1
                                    end
                                    e.tracer.Color = ec
                                    e.tracer.From = Vector2.new(vp.X / 2, vp.Y)
                                    e.tracer.To = Vector2.new(cx, yBot)
                                    e.tracer.Visible = true
                                elseif e.tracer then
                                    e.tracer.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end)
        if not seen then
            pcall(function()
                if e.box then e.box.Visible = false end
                if e.name then e.name.Visible = false end
                if e.tracer then e.tracer.Visible = false end
                if e.hpBg then e.hpBg.Visible = false end
                if e.hpF then e.hpF.Visible = false end
                if e.skel then
                    for i = 1, #e.skel do
                        if e.skel[i] then
                            e.skel[i].Visible = false
                        end
                    end
                end
            end)
        end
        local chamsApplied = false
        if S.chamsOn then
            if not (S.teamCheck and pl.Team ~= nil and pl.Team == LP.Team) then
                pcall(function()
                    local c = pl.Character
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    if c and hum and hum.Health > 0 then
                        if not e.hl or not e.hl.Parent then
                            e.hl = Instance.new("Highlight")
                            e.hl.Name = rndName("CH")
                            e.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            e.hl.Parent = c
                        end
                        local hlCol = drawColor()
                        if S.espTeamCol and pl.Team then
                            hlCol = pl.Team.TeamColor.Color
                        end
                        e.hl.FillColor = hlCol
                        e.hl.OutlineColor = hlCol
                        e.hl.FillTransparency = S.chamsFill
                        e.hl.OutlineTransparency = 0.5
                        chamsApplied = true
                    end
                end)
            end
        end
        if not chamsApplied and e.hl then
            pcall(function()
                e.hl:Destroy()
            end)
            e.hl = nil
        end
    end
end))

-- ============ WAYPOINT MARKER LOOP ============
track(RS.RenderStepped:Connect(function()
    local v = workspace.CurrentCamera
    if not (canDraw and S.wpMarkers and v) then
        for i = 1, #wpDraws do
            local d = wpDraws[i]
            if d then
                pcall(function()
                    d.dot.Visible = false
                    d.lbl.Visible = false
                end)
            end
        end
        return
    end
    local myC = LP.Character
    local myHrp = myC and myC:FindFirstChild("HumanoidRootPart")
    for i = 1, #WPTS do
        local w = WPTS[i]
        local d = wpDraws[i]
        if not d then
            d = { dot = Drawing.new("Circle"), lbl = Drawing.new("Text") }
            d.dot.Thickness = 1
            d.dot.NumSides = 12
            d.dot.Filled = true
            d.dot.Radius = 4
            d.lbl.Size = 13
            d.lbl.Center = true
            d.lbl.Outline = true
            wpDraws[i] = d
        end
        local sp, onS = v:WorldToViewportPoint(w.pos)
        if onS and sp.Z > 0 then
            d.dot.Color = ACC
            d.dot.Position = Vector2.new(sp.X, sp.Y)
            d.dot.Visible = true
            local dist = myHrp and (w.pos - myHrp.Position).Magnitude or 0
            d.lbl.Color = ACC
            d.lbl.Text = w.name .. " (" .. string.format("%.0f", dist) .. "m)"
            d.lbl.Position = Vector2.new(sp.X, sp.Y - 14)
            d.lbl.Visible = true
        else
            d.dot.Visible = false
            d.lbl.Visible = false
        end
    end
    for i = #WPTS + 1, #wpDraws do
        local d = wpDraws[i]
        if d then
            pcall(function()
                d.dot:Remove()
                d.lbl:Remove()
            end)
        end
        wpDraws[i] = nil
    end
end))

-- ============ PLAYER WIRING ============
local function wirePlayer(pl)
    if pl == LP then
        return
    end
    if not espCache[pl] then
        espCache[pl] = {}
    end
end
for _, pl in ipairs(P:GetPlayers()) do
    wirePlayer(pl)
end
track(P.PlayerAdded:Connect(function(pl)
    wirePlayer(pl)
    buildPlayerList()
end))
track(P.PlayerRemoving:Connect(function(pl)
    if spectating == pl then
        stopSpectate()
    end
    espClearOne(pl)
    buildPlayerList()
    local lb = distLbls[pl]
    if lb then
        pcall(function()
            lb:Remove()
        end)
        distLbls[pl] = nil
    end
end))

showTab("Home")
print("[NanoHub] AimLock v1.29 ready  -  Home + AimLock + Triggerbot + ESP + Card-ESP + Filter + Movement (Fly/Noclip/InfJump/ClickTP/WS/JP) + Anti-AFK + Auto-Rejoin + Server Hop + Player-List + Waypoints + Hotkeys + FreeMouse + Fast Start + Themes + Config")

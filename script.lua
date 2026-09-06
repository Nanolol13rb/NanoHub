print("[NanoHub] AimLock v1.21 === START ===")

local P = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
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
    wpMarkers = true,
    fmOn = false,
    fmKeyIdx = 14,
    guiKeyIdx = 16,
    fastStart = false,
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
    keyIdx = { 1, 19 },
    fmKeyIdx = { 1, 19 },
    guiKeyIdx = { 1, 19 },
    hitIdx = { 1, 4 },
    aimIdx = { 1, 2 },
    colIdx = { 1, 6 },
    themeIdx = { 1, 6 },
}

local function applyConfig(d)
    if type(d) ~= "table" then
        return false
    end
    for k, v in pairs(d) do
        if k ~= "on" and k ~= "fmOn" and S[k] ~= nil and type(v) == type(S[k]) then
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

-- ============ KEYS / COLORS ============
local KEYNAMES = { "E", "Q", "F", "X", "V", "C", "T", "Y", "B", "Z", "G", "H", "R", "RightCtrl", "RightShift", "RightAlt", "LeftCtrl", "LeftShift", "LeftAlt" }
local KEYCODES = {
    Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.F, Enum.KeyCode.X,
    Enum.KeyCode.V, Enum.KeyCode.C, Enum.KeyCode.T, Enum.KeyCode.Y,
    Enum.KeyCode.B, Enum.KeyCode.Z, Enum.KeyCode.G, Enum.KeyCode.H,
    Enum.KeyCode.R, Enum.KeyCode.RightControl, Enum.KeyCode.RightShift,
    Enum.KeyCode.RightAlt, Enum.KeyCode.LeftControl, Enum.KeyCode.LeftShift,
    Enum.KeyCode.LeftAlt,
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
                -- Ziel tot: Kamera bleibt auf letzter Position, Re-Attach nach Respawn
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
    Text = "AimLock v1.21  •  " .. LP.DisplayName,
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

local TAB_NAMES = { "AimLock", "Visuals", "ESP", "Players", "Waypoints", "Settings" }
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
local aimPage  = pages[1]
local visPage  = pages[2]
local espPage  = pages[3]
local plrPage  = pages[4]
local wpPage   = pages[5]
local setPage  = pages[6]

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
    Text = "Hotkeys: Settings-Tab  •  v1.21",
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

local function addToggle(page, titleTxt, key, doToast)
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
    setOn(val)
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
        toast("Config geladen", GRN)
    else
        toast("Keine Config", RED)
    end
end

-- ============ WAYPOINTS MODULE ============
local wpList = {}
local WP_MAX = 50
local WP_FILE = CFG_DIR .. "/waypoints.json"

local function wpSave()
    if not canFS then
        return
    end
    pcall(function()
        if makefolder and isfolder and not isfolder(CFG_DIR) then
            makefolder(CFG_DIR)
        end
        local d = {}
        for i, w in ipairs(wpList) do
            d[i] = { name = w.name, x = w.x, y = w.y, z = w.z }
        end
        writefile(WP_FILE, HS:JSONEncode(d))
    end)
end

local function wpLoad()
    if not canFS or not isfile then
        return
    end
    pcall(function()
        if not isfile(WP_FILE) then
            return
        end
        local ok, d = pcall(function()
            return HS:JSONDecode(readfile(WP_FILE))
        end)
        if ok and type(d) == "table" then
            table.clear(wpList)
            for _, w in ipairs(d) do
                if type(w) == "table" and type(w.x) == "number" and type(w.y) == "number" and type(w.z) == "number" then
                    table.insert(wpList, {
                        name = tostring(w.name or "WP"),
                        x = w.x, y = w.y, z = w.z,
                    })
                end
            end
        end
    end)
end
wpLoad()

local function getMyHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function wpAddHere()
    local hrp = getMyHRP()
    if not hrp then
        toast("Kein Character", RED)
        return
    end
    if #wpList >= WP_MAX then
        toast("Max " .. WP_MAX .. " Waypoints", RED)
        return
    end
    local p = hrp.Position
    table.insert(wpList, {
        name = "WP " .. tostring(#wpList + 1),
        x = p.X, y = p.Y, z = p.Z,
    })
    wpSave()
    toast("Waypoint gespeichert", GRN)
end

local function wpTeleport(w)
    local hrp = getMyHRP()
    if hrp and w then
        hrp.CFrame = CFrame.new(w.x, w.y, w.z)
        toast("TP -> " .. w.name, GRN)
    end
end

local function wpDelete(i)
    table.remove(wpList, i)
    wpSave()
end

local wpMarkers = {}
track(RS.RenderStepped:Connect(function()
    local v = workspace.CurrentCamera
    if not v then
        return
    end
    if not (S.wpMarkers and canDraw) then
        for _, m in pairs(wpMarkers) do
            pcall(function()
                if m.dot then m.dot.Visible = false end
                if m.name then m.name.Visible = false end
                if m.dist then m.dist.Visible = false end
            end)
        end
        return
    end
    local myHrp = getMyHRP()
    for i = 1, #wpList do
        local w = wpList[i]
        local m = wpMarkers[i]
        if not m then
            m = {}
            m.dot = Drawing.new("Circle")
            m.dot.Thickness = 1
            m.dot.NumSides = 16
            m.dot.Filled = true
            m.dot.Visible = false
            m.name = Drawing.new("Text")
            m.name.Size = 13
            m.name.Center = true
            m.name.Outline = true
            m.name.Visible = false
            m.dist = Drawing.new("Text")
            m.dist.Size = 12
            m.dist.Center = true
            m.dist.Outline = true
            m.dist.Visible = false
            table.insert(hub.draws, m.dot)
            table.insert(hub.draws, m.name)
            table.insert(hub.draws, m.dist)
            wpMarkers[i] = m
        end
        local wp3 = Vector3.new(w.x, w.y, w.z)
        local sp, on = v:WorldToViewportPoint(wp3)
        if on and sp.Z > 0 then
            local col = drawColor()
            local d3 = myHrp and (wp3 - myHrp.Position).Magnitude or 0
            m.dot.Color = col
            m.dot.Position = Vector2.new(sp.X, sp.Y)
            m.dot.Radius = 4
            m.dot.Visible = true
            m.name.Color = col
            m.name.Text = w.name
            m.name.Position = Vector2.new(sp.X, sp.Y - 18)
            m.name.Visible = true
            m.dist.Color = Color3.fromRGB(220, 220, 230)
            m.dist.Text = string.format("%.0f", d3) .. " m"
            m.dist.Position = Vector2.new(sp.X, sp.Y + 8)
            m.dist.Visible = true
        else
            m.dot.Visible = false
            m.name.Visible = false
            m.dist.Visible = false
        end
    end
    for i = #wpList + 1, #wpMarkers do
        local m = wpMarkers[i]
        if m then
            pcall(function()
                if m.dot then m.dot.Visible = false end
                if m.name then m.name.Visible = false end
                if m.dist then m.dist.Visible = false end
            end)
        end
    end
end))

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

-- ============ TABS ============
addHeader(aimPage, "Core")
local aimSet = nil
aimSet = addToggle(aimPage, "AimLock", "on", true)
addToggle(aimPage, "Hotkey aktiv", "keyEnabled", true)
addCycle(aimPage, "Ziel-Part", "hitIdx", HITS)
addCycle(aimPage, "Modus", "aimIdx", AIMMODES)
addSlider(aimPage, "Smoothing", "smooth", 0.05, 1, 0.05, function(x) return string.format("%.2f", x) end)
addSlider(aimPage, "Range", "range", 100, 2000, 100)
addSlider(aimPage, "FOV Radius", "fovR", 60, 600, 20)
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

addHeader(plrPage, "Spieler Liste")
buildPlayerList()

-- ============ WAYPOINTS TAB ============
addHeader(wpPage, "Waypoints")

local wpRows = {}
local function clearWpRows()
    for _, row in pairs(wpRows) do
        pcall(function()
            if row and row.Destroy then
                row:Destroy()
            end
        end)
    end
    table.clear(wpRows)
end

local renameModal = nil
local function openRename(i, w, nameLbl)
    if not w then
        return
    end
    if renameModal then
        pcall(function() renameModal:Destroy() end)
        renameModal = nil
    end
    local overlay = ni("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = BG0,
        BackgroundTransparency = 0.35,
        Active = true,
        BorderSizePixel = 0,
        ZIndex = 95,
        Parent = ui,
    })
    renameModal = overlay
    local box = ni("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 250, 0, 130),
        BackgroundColor3 = BG1,
        BorderSizePixel = 0,
        ZIndex = 96,
        Parent = overlay,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = box })
    local mStroke = ni("UIStroke", { Color = ACC, Thickness = 1, Transparency = 0.45, Parent = box })
    table.insert(themeAcc, { mStroke, "Color" })
    ni("TextLabel", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Text = "Waypoint umbenennen",
        TextColor3 = TXT,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 97,
        Parent = box,
    })
    local tb = ni("TextBox", {
        Position = UDim2.new(0, 12, 0, 32),
        Size = UDim2.new(1, -24, 0, 30),
        BackgroundColor3 = BG2,
        Text = w.name,
        PlaceholderText = "Neuer Name",
        PlaceholderColor3 = SUB,
        TextColor3 = TXT,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 97,
        Parent = box,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tb })
    ni("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = tb })

    local modalOpen = true
    local function closeModal()
        if not modalOpen then
            return
        end
        modalOpen = false
        pcall(function() overlay:Destroy() end)
        if renameModal == overlay then
            renameModal = nil
        end
    end
    local function saveName()
        local t = tostring(tb.Text or "")
        t = t:gsub("[\r\n]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if #t == 0 then
            toast("Name zu kurz", RED)
            return
        end
        if #t > 20 then
            t = string.sub(t, 1, 20)
        end
        w.name = t
        nameLbl.Text = t
        wpSave()
        closeModal()
        toast("Umbenannt -> " .. t, GRN)
    end
    tb.FocusLost:Connect(function(enter)
        if enter then
            saveName()
        end
    end)
    local saveB = ni("TextButton", {
        Position = UDim2.new(0, 12, 0, 72),
        Size = UDim2.new(0.5, -18, 0, 28),
        BackgroundColor3 = ACC,
        BorderSizePixel = 0,
        Text = "Speichern",
        TextColor3 = Color3.fromRGB(15, 15, 20),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        AutoButtonColor = false,
        ZIndex = 97,
        Parent = box,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = saveB })
    saveB.MouseButton1Click:Connect(saveName)
    local cancelB = ni("TextButton", {
        Position = UDim2.new(0.5, 6, 0, 72),
        Size = UDim2.new(0.5, -18, 0, 28),
        BackgroundColor3 = BG3,
        BorderSizePixel = 0,
        Text = "Abbrechen",
        TextColor3 = SUB,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        AutoButtonColor = false,
        ZIndex = 97,
        Parent = box,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = cancelB })
    cancelB.MouseButton1Click:Connect(closeModal)
    pcall(function() tb:CaptureFocus() end)
end

local function buildWaypointList()
    clearWpRows()
    for i, w in ipairs(wpList) do
        local row = mkRow(wpPage)
        local nameLbl = ni("TextLabel", {
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -160, 1, 0),
            BackgroundTransparency = 1,
            Text = w.name,
            TextColor3 = TXT,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        local tpLbl = ni("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -86, 0.5, 0),
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
        local renBtn = ni("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -58, 0, 4),
            Size = UDim2.new(0, 34, 0, 22),
            BackgroundColor3 = BG3,
            BorderSizePixel = 0,
            Text = "✏",
            TextColor3 = ACC,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = row,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = renBtn })
        local delBtn = ni("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -18, 0, 4),
            Size = UDim2.new(0, 34, 0, 22),
            BackgroundColor3 = BG3,
            BorderSizePixel = 0,
            Text = "X",
            TextColor3 = RED,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = row,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = delBtn })
        row.MouseButton1Click:Connect(function()
            pcall(function()
                wpTeleport(w)
            end)
        end)
        renBtn.MouseButton1Click:Connect(function()
            openRename(i, w, nameLbl)
        end)
        delBtn.MouseButton1Click:Connect(function()
            wpDelete(i)
            buildWaypointList()
        end)
        wpRows[i] = row
    end
end

addButton(wpPage, "＋ Position speichern", function()
    wpAddHere()
    buildWaypointList()
end)
addToggle(wpPage, "Welt-Marker", "wpMarkers", true)
buildWaypointList()

addHeader(setPage, "Config")
addButton(setPage, "Config speichern", saveConfigFull)
addButton(setPage, "Config laden", loadConfigFull)
addHeader(setPage, "Hotkeys")
addCycle(setPage, "AimLock-Taste", "keyIdx", KEYNAMES)
addCycle(setPage, "GUI-Taste", "guiKeyIdx", KEYNAMES)
addCycle(setPage, "FreeMouse-Taste", "fmKeyIdx", KEYNAMES)
addToggle(setPage, "Maus freigeben (FreeMouse)", "fmOn", true)
addHeader(setPage, "UI")
addCycle(setPage, "Theme", "themeIdx", THEME_NAMES, function() setThemeVars(S.themeIdx) end)
addToggle(setPage, "Fast Start (Splash überspringen)", "fastStart", true)

-- ============ FREE MOUSE ============
local fmBtn = ni("TextButton", {
    Name = "NanoHub_FreeMouse",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 8, 1, -8),
    Size = UDim2.new(0, 130, 0, 30),
    BackgroundColor3 = BG2,
    BorderSizePixel = 0,
    Text = "MAUS: LOCK",
    TextColor3 = SUB,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    Parent = ui,
})
ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = fmBtn })
local fmStroke = ni("UIStroke", { Color = ACC, Thickness = 1, Transparency = 0.5, Parent = fmBtn })

local function setFm(v, silent)
    S.fmOn = v
    if CTRLS.fmOn then
        pcall(function()
            CTRLS.fmOn.set(v, true)
        end)
    end
    if not silent then
        if v then
            toast("FreeMouse AN — Maus frei", GRN)
        else
            toast("FreeMouse AUS — Maus gelockt", RED)
        end
    end
end

fmBtn.MouseButton1Click:Connect(function()
    setFm(not S.fmOn)
end)

local fmLast = nil
track(RS.RenderStepped:Connect(function()
    if S.fmOn ~= fmLast then
        fmLast = S.fmOn
        fmBtn.Text = fmLast and "MAUS: FREI" or "MAUS: LOCK"
        fmBtn.TextColor3 = fmLast and GRN or SUB
        fmStroke.Color = fmLast and GRN or ACC
    end
    if S.fmOn then
        pcall(function()
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end)
    end
end))

-- ============ SPLASH / FAST START ============
if S.fastStart then
    -- Kein Splash: GUI öffnet direkt
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
        Position = UDim2.new(0.5, 0, 0.3, 0),
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
        Position = UDim2.new(0.5, 0, 0.3, 50),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "Universal AimLock",
        TextColor3 = SUB,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 91,
        Parent = splash,
    })
    local spLine = ni("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.55, 0),
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
        spGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, col),
            ColorSequenceKeypoint.new(1, CYAN),
        })
    end)
    local spPct = ni("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.55, 14),
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
        Position = UDim2.new(0.5, 0, 0.66, 0),
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
        Position = UDim2.new(0.5, 0, 0.73, 0),
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
            task.wait(0.09)
        end
    end)
    task.spawn(function()
        local i = 0
        while i < 100 do
            i = i + 1
            spFill.Size = UDim2.new(i / 100, 0, 1, 0)
            spPct.Text = tostring(i) .. "%"
            if i < 100 then
                task.wait(0.05)
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
    espClearAll()
    pcall(function()
        hub.ui:Destroy()
    end)
    hub.ui = nil
end)

-- ============ KEYBINDS ============
track(UIS.InputBegan:Connect(function(inp, g)
    if g then
        return
    end
    if inp.KeyCode == KEYCODES[S.guiKeyIdx] then
        pcall(function()
            win.Visible = not win.Visible
        end)
    elseif inp.KeyCode == KEYCODES[S.fmKeyIdx] then
        setFm(not S.fmOn)
    elseif inp.KeyCode == KEYCODES[S.keyIdx] and S.keyEnabled then
        if aimSet then
            aimSet.set(not S.on)
        end
    end
end))

-- ============ MAIN LOOP (AIMLOCK) ============
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

showTab("AimLock")
print("[NanoHub] AimLock v1.21 ready  -  AimLock + ESP + Chams + Player-List + Waypoints (Rename) + Hotkeys + FreeMouse + Fast Start (Direct-Open) + Themes + Config")

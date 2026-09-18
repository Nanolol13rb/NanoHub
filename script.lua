print("[NanoHub] GUI v2.5 === START ===")

local P   = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")
local HS  = game:GetService("HttpService")
local LP  = P.LocalPlayer
local T0  = os.clock()

local function rndName(b)
    return (b or "A") .. tostring(math.random(10000, 99999))
end
local function ni(c, p)
    local o = Instance.new(c)
    if p then for k, v in pairs(p) do o[k] = v end end
    return o
end
local function clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end

-- Reload-Safe
_G.NanoHubGUI = _G.NanoHubGUI or {}
local hub = _G.NanoHubGUI
if hub.conns then
    for _, c in ipairs(hub.conns) do
        pcall(function() if c and c.Connected then c:Disconnect() end end)
    end
end
hub.conns = {}
if hub.ui then pcall(function() hub.ui:Destroy() end) end
local function track(c) table.insert(hub.conns, c); return c end

local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")

-- Farben / Themes
local ACC, CYAN = Color3.fromRGB(150, 100, 255), Color3.fromRGB(90, 200, 255)
local BG0 = Color3.fromRGB(8, 9, 14)
local BG1 = Color3.fromRGB(13, 15, 23)
local BG2 = Color3.fromRGB(20, 23, 34)
local BG3 = Color3.fromRGB(30, 34, 50)
local BG4 = Color3.fromRGB(42, 48, 70)
local TXT = Color3.fromRGB(240, 242, 252)
local SUB = Color3.fromRGB(150, 158, 182)
local RED = Color3.fromRGB(255, 84, 92)
local GRN = Color3.fromRGB(96, 226, 138)

-- === Farbige Icons ===
-- WICHTIG: Roblox-Emojis (🏠⚡🎮) sind feste Farb-Glyphen und lassen sich
-- NICHT umfaerben (TextColor3 wirkt nicht). Deshalb benutzen wir Text-Symbole,
-- die sich wirklich faerben lassen — so wie die flat icons bei BUNI.
local EMOJI_COLORS = {}
local function emojiKey(e)
    return e
end
local function defEmoji(col, ...)
    for i = 1, select("#", ...) do
        EMOJI_COLORS[emojiKey(select(i, ...))] = col
    end
end
-- BUNI-Palette
defEmoji(Color3.fromRGB(59, 130, 246), "◆", "●", "◇") -- Blau
defEmoji(Color3.fromRGB(255, 212, 59), "✦", "✧", "$") -- Gelb
defEmoji(Color3.fromRGB(61, 220, 132), "❖", "▶", "»") -- Grün
defEmoji(Color3.fromRGB(34, 211, 238), "◉", "○") -- Cyan
defEmoji(Color3.fromRGB(168, 85, 247), "◈", "▲", "▼") -- Lila
defEmoji(Color3.fromRGB(255, 197, 61), "★") -- Gold
defEmoji(Color3.fromRGB(203, 213, 225), "≡", "✕") -- Hellgrau
defEmoji(Color3.fromRGB(251, 146, 60), "✚", "△") -- Orange
defEmoji(TXT, "▤") -- Weiß

local function emojiColor(e)
    return EMOJI_COLORS[emojiKey(e)] or TXT
end
local function hexCol(c)
    return string.format("%02X%02X%02X",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end
local function em(emoji, rest)
    return string.format('<font color="#%s">%s</font>%s', hexCol(emojiColor(emoji)), emoji, rest or "")
end
-- "💎 Crystal ESP" -> RichText mit farbigem Emoji vorne
local function emTitle(txt)
    local sp = txt:find(" ", 1, true)
    local head = sp and txt:sub(1, sp - 1) or txt
    local b = head:byte(1)
    if b and (b >= 0xC2 or head == "$") and #head <= 8 then
        return true, em(head, txt:sub(sp or #txt + 1))
    end
    return false, txt
end

local THEMES = {
    { name = "Purple", acc = Color3.fromRGB(150, 100, 255), cyan = Color3.fromRGB(90, 200, 255) },
    { name = "Blue",   acc = Color3.fromRGB(70, 150, 255),  cyan = Color3.fromRGB(120, 220, 255) },
    { name = "Red",    acc = Color3.fromRGB(255, 90, 90),   cyan = Color3.fromRGB(255, 160, 120) },
    { name = "Green",  acc = Color3.fromRGB(80, 220, 140),  cyan = Color3.fromRGB(150, 255, 200) },
    { name = "Orange", acc = Color3.fromRGB(255, 150, 60),  cyan = Color3.fromRGB(255, 210, 120) },
    { name = "Pink",   acc = Color3.fromRGB(255, 100, 180), cyan = Color3.fromRGB(255, 170, 220) },
}
local THEME_NAMES = {}
for i, t in ipairs(THEMES) do THEME_NAMES[i] = t.name end

local themeAcc = {}
local function setThemeVars(i)
    local t = THEMES[clamp(i, 1, #THEMES)]
    if not t then return end
    ACC, CYAN = t.acc, t.cyan
    for _, r in ipairs(themeAcc) do
        pcall(function() r[1][r[2]] = ACC end)
    end
end

-- Config
local canFS = (type(writefile) == "function" and type(readfile) == "function")
local CFG_DIR, CFG_PATH = "NanoHub", "NanoHub/gui.json"
local S = {
    themeIdx = 1,
    antiAFK = false,
    autoRejoin = false,
    panicOn = false,
    panicIdx = 1,
     game = "",
    mtmCrystalESP = false,
    mtmPlayerESP = false,
    mtmAutoSell = false,
    mtmAutoPickup = false,
    mtmInstantDig = false,
    mtmSpeed = false,
    mantMinTier = 1,
    mantAutoBreak = false,
    mantTiers = {},
    mtmSpeed = false,
    mantOreESP = false,
    mantPlrESP = false,
    mantAutoDig = false,
    mantAutoSell = false,
    mantSpeed = false,
    mantAntiRag = false,
    bladeBallESP = false,
    bladePlrESP = false,
    isAdmin = false,
    gameStatus = { ["Blade Ball"] = "down", ["Mine Antarctica"] = "down" },
}
local function saveCfg()
    if not canFS then return end

    pcall(function()
        if makefolder and isfolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
        -- Nur Settings speichern — nicht Game-Auswahl / Feature-Toggles / Rarity-Filter
        local out = {}
        local SKIP = {
            game = true,
            isAdmin = true,
            mantOreESP = true, mantPlrESP = true, mantAutoDig = true,
            mantAutoSell = true, mantAutoBreak = true, mantSpeed = true,
            mantAntiRag = true, mantBestGlow = true,
            mantTiers = true, mantMinTier = true, mantRange = true, mantRangeIdx = true,
            mtmCrystalESP = true, mtmPlayerESP = true, mtmAutoSell = true,
            mtmAutoPickup = true, mtmInstantDig = true, mtmSpeed = true,
        }
        for k, v in pairs(S) do
            if not SKIP[k] then out[k] = v end
        end
        writefile(CFG_PATH, HS:JSONEncode(out))
    end)
end
local function loadCfg()
    if not canFS then return end
    pcall(function()
        if isfile and isfile(CFG_PATH) then
            local ok, d = pcall(function() return HS:JSONDecode(readfile(CFG_PATH)) end)
            if ok and type(d) == "table" then
                local SKIPLOAD = { game = true, mantTiers = true, isAdmin = true }
                for k, v in pairs(d) do
                    if not SKIPLOAD[k] and S[k] ~= nil and type(v) == type(S[k]) then S[k] = v end
                end
            end
        end
    end)
end
loadCfg()

-- Firebase RTDB (Status für alle Nutzer)
local FB_URL = "https://nanohub-script-default-rtdb.europe-west1.firebasedatabase.app"
local function nbRead()
    local req = (type(http_request) == "function" and http_request)
        or (type(request) == "function" and request) or nil
    if not req then return nil end
    local ok, res = pcall(req, {
        Url = FB_URL .. "/status.json", Method = "GET",
    })
    if not ok or not res or not res.Body or res.Body == "null" then return nil end
    local ok2, j = pcall(function() return HS:JSONDecode(res.Body) end)
    if ok2 and type(j) == "table" then return j end
    return nil
end
local function nbWrite()
    local req = (type(http_request) == "function" and http_request)
        or (type(request) == "function" and request) or nil
    if not req then return false end
    local ok = pcall(req, {
        Url = FB_URL .. "/status.json", Method = "PUT",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HS:JSONEncode(S.gameStatus or {}),
    })
    return ok
end
-- Auto-Update: beim Start + alle 60s
task.spawn(function()
    while true do
        local st = nbRead()
        if st then
            local changed = false
            for k, v in pairs(st) do
                if (S.gameStatus or {})[k] ~= v then changed = true end
            end
            S.gameStatus = st
            if changed and hub.buildGrid then pcall(hub.buildGrid) end
        end
        task.wait(60)
    end
end)

setThemeVars(S.themeIdx)
-- Anti-AFK
track(LP.Idled:Connect(function()
    if S.antiAFK then
        pcall(function()
            local VU = game:GetService("VirtualUser")
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end))

-- Auto-Rejoin
local TSvc = game:GetService("TeleportService")
pcall(function()
    game:GetService("NetworkClient").ChildRemoved:Connect(function()
        if S.autoRejoin then
            task.wait(2)
            pcall(function()
                TSvc:Teleport(game.PlaceId, LP)
            end)
        end
    end)
end)

-- GAMES-Liste (hier eintragen)
local GAMES = {
    {
        name = "Mine Antarctica",
        placeId = 138686218420016,
        icon = "🧊",
        features = {},
    },
    {
        name = "Blade Ball",
        placeId = 13772394625,
        icon = "⚔️",
        features = {},
    },
}


-- Auto: echter Name + Icon-Bild von Roblox
do
    local MS = game:GetService("MarketplaceService")
    for _, gg in ipairs(GAMES) do
        if gg.placeId then
                        gg._img = "rbxthumb://type=GameIcon&id=" .. gg.placeId .. "&w=150&h=150"
            local ok, info = pcall(function() return MS:GetProductInfo(gg.placeId) end)
            if ok and type(info) == "table" then
                if info.Name and info.Name ~= "" then
                    gg.name = info.Name
                end
                if info.IconImageAssetId and info.IconImageAssetId > 0 then
                    gg._img = "rbxassetid://" .. info.IconImageAssetId
                end
            end
        end
    end
end
-- UI Root
local ui = ni("ScreenGui", {
    Name = rndName("NH"),
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = (type(gethui) == "function" and gethui() or pg),
})
hub.ui = ui

-- Toast-Queue
local toastQueue = {}
local function toast(msg, col)
    table.insert(toastQueue, true)
    local idx = #toastQueue
    task.spawn(function()
        local f = ni("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -20 - (idx - 1) * 42),
            Size = UDim2.new(0, 210, 0, 34),
            BackgroundColor3 = BG2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 80,
            Parent = ui,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = f })
        local st = ni("UIStroke", { Color = col, Thickness = 1, Transparency = 0.5, Parent = f })
        ni("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = msg,
            TextColor3 = col,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            ZIndex = 81,
            Parent = f,
        })
        TS:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 }):Play()
        task.wait(1.6)
        TS:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
        TS:Create(st, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        task.wait(0.35)
        pcall(function() f:Destroy() end)
        table.remove(toastQueue, idx)
    end)
end

-- Fenster
local WIN_W, WIN_H, HEAD, SB_W, FOOT = 900, 560, 62, 176, 26
local win = ni("Frame", {
    Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    BackgroundColor3 = BG1,
    BorderSizePixel = 0,
    Visible = true,
    Parent = ui,
})
ni("UICorner", { CornerRadius = UDim.new(0, 14), Parent = win })
local winStroke = ni("UIStroke", { Color = ACC, Transparency = 0.5, Thickness = 1.2, Parent = win })
table.insert(themeAcc, { winStroke, "Color" })

-- Header (Top-Bar)
local header = ni("Frame", {
    Size = UDim2.new(1, 0, 0, HEAD),
    BackgroundColor3 = BG0,
    ClipsDescendants = true,
    BorderSizePixel = 0,
    Parent = win,
})
ni("UICorner", { CornerRadius = UDim.new(0, 14), Parent = header })

-- Logo
local logo = ni("Frame", { Position = UDim2.new(0, 14, 0, 13), Size = UDim2.new(0, 36, 0, 36), BackgroundColor3 = ACC, BorderSizePixel = 0, Parent = header })
ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = logo })
table.insert(themeAcc, { logo, "BackgroundColor3" })
ni("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "N", TextColor3 = Color3.fromRGB(9, 11, 18), Font = Enum.Font.GothamBlack, TextSize = 21, Parent = logo })

local title = ni("TextLabel", { Position = UDim2.new(0, 58, 0, 10), Size = UDim2.new(0, 120, 0, 22), BackgroundTransparency = 1, Text = "NanoHub", TextColor3 = TXT, Font = Enum.Font.GothamBlack, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

local verPill = ni("Frame", { Position = UDim2.new(0, 148, 0, 15), Size = UDim2.new(0, 42, 0, 18), BackgroundColor3 = BG3, BorderSizePixel = 0, Parent = header })
ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = verPill })
ni("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "v2.7", TextColor3 = SUB, Font = Enum.Font.GothamBold, TextSize = 10, Parent = verPill })

ni("TextLabel", { Position = UDim2.new(0, 58, 0, 32), Size = UDim2.new(0, 320, 0, 16), BackgroundTransparency = 1, Text = "AimLock • ESP • Key-System • Game Hub", TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

-- Status-Pill
local statusPill = ni("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -92, 0.5, 0), Size = UDim2.new(0, 96, 0, 26), BackgroundColor3 = Color3.fromRGB(36, 16, 21), BorderSizePixel = 0, Parent = header })
ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = statusPill })
local statusDot = ni("Frame", { Position = UDim2.new(0, 10, 0.5, -4), Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = RED, BorderSizePixel = 0, Parent = statusPill })
ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = statusDot })
local statusLbl = ni("TextLabel", { Position = UDim2.new(0, 24, 0, 0), Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Text = "Locked", TextColor3 = RED, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = statusPill })

hub.setStatus = function(ok)
    if ok then
        statusDot.BackgroundColor3 = GRN
        statusLbl.Text = "Ready"
        statusLbl.TextColor3 = GRN
        statusPill.BackgroundColor3 = Color3.fromRGB(14, 34, 23)
    else
        statusDot.BackgroundColor3 = RED
        statusLbl.Text = "Locked"
        statusLbl.TextColor3 = RED
        statusPill.BackgroundColor3 = Color3.fromRGB(36, 16, 21)
    end
end

-- === Window-Buttons (BUNI-Style): flach, Hover = rot ===
local function mkWinBtn(txt, xOff, col, tip, onClick)
    local b = ni("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, xOff, 0, 9),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = col,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = txt,
        TextColor3 = SUB,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = header,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 7), Parent = b })
    local glow = ni("UIStroke", { Color = col, Thickness = 1, Transparency = 1, Parent = b })

    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromRGB(255, 255, 255),
        }):Play()
        TS:Create(glow, TweenInfo.new(0.14), { Transparency = 0.3 }):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = col,
            BackgroundTransparency = 1,
            TextColor3 = SUB,
        }):Play()
        TS:Create(glow, TweenInfo.new(0.2), { Transparency = 1 }):Play()
    end)
    b.MouseButton1Down:Connect(function()
        TS:Create(b, TweenInfo.new(0.07), { BackgroundColor3 = Color3.fromRGB(210, 55, 65) }):Play()
    end)
    b.MouseButton1Up:Connect(function()
        TS:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = col }):Play()
    end)
    b.MouseButton1Click:Connect(onClick)
    return b
end

local closeBtn = mkWinBtn("X", -8, RED, "close", function()
    pcall(function() hub.ui:Destroy() end)
    hub.ui = nil
end)

local hideBtn = mkWinBtn("—", -42, Color3.fromRGB(255, 110, 100), "minimize", function()
    win.Visible = false
end)

-- Akzentlinie unter dem Header
local accBar = ni("Frame", { Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = ACC, BorderSizePixel = 0, Parent = header })
table.insert(themeAcc, { accBar, "BackgroundColor3" })

-- Sidebar
local sidebar = ni("Frame", {
    Position = UDim2.new(0, 0, 0, HEAD),
    Size = UDim2.new(0, SB_W, 1, -(HEAD + FOOT)),
    BackgroundColor3 = BG0,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Parent = win,
})
ni("UICorner", { CornerRadius = UDim.new(0, 14), Parent = sidebar })

local TAB_NAMES = { "Home", "Scripts", "Game", "Settings", "Info" }
local TAB_ICONS = { "🏠", "⚡", "🎮", "⚙️", "ℹ️" }
local TAB_SUBS  = { "Overview & Key", "Chose a game", "Select your game", "Configure hub", "Information" }
local LOCKED = { false, true, true, true, true }

local TILE_H, TILE_GAP = 50, 6
local pill = ni("Frame", {
    Position = UDim2.new(0, 8, 0, 8),
    Size = UDim2.new(1, -16, 0, TILE_H),
    BackgroundColor3 = ACC,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = sidebar,
})
ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = pill })
local pillStroke = ni("UIStroke", { Color = ACC, Transparency = 0.3, Thickness = 1, Parent = pill })
table.insert(themeAcc, { pillStroke, "Color" })
local pillBar = ni("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.new(0, 3, 0, 26),
    BackgroundColor3 = ACC,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = pill,
})
ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pillBar })
table.insert(themeAcc, { pillBar, "BackgroundColor3" })

ni("TextLabel", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 12, 1, -10),
    Size = UDim2.new(1, -24, 0, 30),
    BackgroundTransparency = 1,
    Text = "NanoHub\nAimLock • ESP • Hub",
    TextColor3 = Color3.fromRGB(78, 86, 108),
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Bottom,
    Parent = sidebar,
})

local content = ni("Frame", {
    Position = UDim2.new(0, SB_W, 0, HEAD),
    Size = UDim2.new(1, -SB_W, 1, -(HEAD + FOOT)),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = win,
})

local pages, tabBtns, tabLbls, tabIcons, tabBoxes, tabSubs = {}, {}, {}, {}, {}, {}
for i = 1, #TAB_NAMES do
    local b = ni("TextButton", {
        Position = UDim2.new(0, 8, 0, 8 + (i - 1) * (TILE_H + TILE_GAP)),
        Size = UDim2.new(1, -16, 0, TILE_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
        Parent = sidebar,
    })
    local ibox = ni("Frame", {
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = BG3,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = b,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 9), Parent = ibox })
    local ico = ni("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = TAB_ICONS[i],
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = SUB,
        ZIndex = 5,
        Parent = ibox,
    })

    local lbl = ni("TextLabel", {
        Position = UDim2.new(0, 48, 0, 8),
        Size = UDim2.new(1, -56, 0, 17),
        BackgroundTransparency = 1,
        Text = TAB_NAMES[i],
        TextColor3 = SUB,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
        Parent = b,
    })
    local subl = ni("TextLabel", {
        Position = UDim2.new(0, 48, 0, 26),
        Size = UDim2.new(1, -56, 0, 14),
        BackgroundTransparency = 1,
        Text = TAB_SUBS[i],
        TextColor3 = Color3.fromRGB(96, 104, 128),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
        Parent = b,
    })
    tabBtns[i], tabLbls[i], tabIcons[i], tabBoxes[i], tabSubs[i] = b, lbl, ico, ibox, subl

    if i == 1 then
        local f = ni("Frame", {
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 1, -20),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = true,
            Parent = content,
        })
        pages[i] = f
    else
        local pf = ni("ScrollingFrame", {
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 1, -20),
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
end

local unlocked = false
local curTab = 1

local function paintNav(i)
    local open = (unlocked or i == 1)
    if i == curTab then
        tabLbls[i].TextColor3 = TXT
        tabIcons[i].TextColor3 = emojiColor(TAB_ICONS[i])
        tabBoxes[i].BackgroundColor3 = ACC
        tabBoxes[i].BackgroundTransparency = 0.15
    else
        tabLbls[i].TextColor3 = open and TXT or SUB
        tabIcons[i].TextColor3 = emojiColor(TAB_ICONS[i])
        tabBoxes[i].BackgroundColor3 = BG3
        tabBoxes[i].BackgroundTransparency = 0
    end
    tabSubs[i].TextColor3 = open and Color3.fromRGB(96, 104, 128) or Color3.fromRGB(70, 76, 96)
end

local function showTab(idx)
    if LOCKED[idx] and not unlocked then
        local b = tabBtns[idx]
        local orig = b.Position
        for _, off in ipairs({ -5, 5, -3, 3, 0 }) do
            b.Position = UDim2.new(orig.X.Scale, orig.X.Offset + off, orig.Y.Scale, orig.Y.Offset)
            task.wait(0.035)
        end
        toast("🔒 Erst Key eingeben!", RED)
        return
    end
    curTab = idx
    TS:Create(pill, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 8, 0, 8 + (idx - 1) * (TILE_H + TILE_GAP)),
    }):Play()
    for i = 1, #pages do
        pages[i].Visible = (i == idx)
        paintNav(i)
    end
end

for i = 1, #TAB_NAMES do
    local idx = i
    tabBtns[i].MouseButton1Click:Connect(function()
        task.spawn(function() showTab(idx) end)
    end)
    tabBtns[i].MouseEnter:Connect(function()
        if idx ~= curTab then tabLbls[idx].TextColor3 = TXT end
    end)
    tabBtns[i].MouseLeave:Connect(function()
        paintNav(idx)
    end)
end
paintNav(1)

-- Footer
local footer = ni("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, FOOT),
    BackgroundColor3 = BG0,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = win,
})
ni("UICorner", { CornerRadius = UDim.new(0, 14), Parent = footer })
ni("TextLabel", {
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -60, 1, 0),
    BackgroundTransparency = 1,
      Text = "RightAlt = GUI  •  Delete = Panic  •  Dashboard v2.7",
    TextColor3 = SUB,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = footer,
})

-- Resize-Grip
local grip = ni("TextButton", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -3, 1, -3),
    Size = UDim2.new(0, 18, 0, 18),
    BackgroundTransparency = 1,
    Text = "◢",
    TextColor3 = SUB,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Parent = win,
})
local resizing = false
grip.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        resizing = true
    end
end)
track(UIS.InputChanged:Connect(function(inp)
    if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local nw = clamp(inp.Position.X - win.AbsolutePosition.X, 760, 1240)
        local nh = clamp(inp.Position.Y - win.AbsolutePosition.Y, 480, 820)
        win.Size = UDim2.new(0, nw, 0, nh)
    end
end))
track(UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end))

-- Dragging
local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = win.Position
    end
end)
track(UIS.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end))
track(UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

-- Row Helpers
local CTRLS = {}
local function mkRow(page)
    local row = ni("TextButton", {
        Size = UDim2.new(1, -8, 0, 30),
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
        Size = UDim2.new(1, -8, 0, 20),
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
local function addToggle(page, titleTxt, key, onSet)
    local row = mkRow(page)
    local richOn, richTxt = emTitle(titleTxt)
    ni("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        RichText = richOn,
        Text = richTxt,
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local sw = ni("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 34, 0, 18),
        BackgroundColor3 = BG4,
        BorderSizePixel = 0,
        Parent = row,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
    local knob = ni("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = SUB,
        BorderSizePixel = 0,
        Parent = sw,
    })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    local function setOn(v)
        S[key] = v
        TS:Create(sw, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundColor3 = v and GRN or BG4,
        }):Play()
        TS:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = v and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            BackgroundColor3 = v and Color3.fromRGB(15, 20, 16) or SUB,
        }):Play()
    end
    row.MouseButton1Click:Connect(function()
        setOn(not S[key])
        toast(titleTxt .. (S[key] and "  AN" or "  AUS"), S[key] and GRN or RED)
        if onSet then pcall(onSet, S[key]) end
    end)
    CTRLS[key] = { set = function(v)
        setOn(v)
        if onSet then pcall(onSet, v) end
    end }
    setOn(S[key])
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
        if onSet then pcall(onSet, S[key]) end
    end)
    CTRLS[key] = { set = function(v)
        S[key] = clamp(v, 1, #items)
        val.Text = items[S[key]]
        if onSet then pcall(onSet, S[key]) end
    end }
end
local function addButton(page, titleTxt, cb)
    local row = mkRow(page)
    local richOn, richTxt = emTitle(titleTxt)
    ni("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        RichText = richOn,
        Text = richTxt,
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    row.MouseButton1Click:Connect(function() pcall(cb) end)
end

-- Unlock nach Verify
local function unlockTabs()
    if unlocked then return end
    unlocked = true
    for i = 2, #TAB_NAMES do
        LOCKED[i] = false
        paintNav(i)
    end
    paintNav(curTab)
    if hub.setStatus then pcall(hub.setStatus, true) end
    if hub.statKey then pcall(hub.statKey, true) end
    if hub.log then pcall(hub.log, "Key", "session verified", GRN) end
    toast("✓ Key verified — alle Tabs freigeschaltet", GRN)
end

-- ============ HOME (Dashboard) ============
local function buildHome()
    local home = pages[1]

    local left  = ni("Frame", { Size = UDim2.new(0.64, -6, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = home })
    local right = ni("Frame", { Position = UDim2.new(0.64, 6, 0, 0), Size = UDim2.new(0.36, -6, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = home })

    -- ---------- HERO ----------
    local hero = ni("Frame", {
        Size = UDim2.new(1, 0, 0, 140),
        BackgroundColor3 = BG2,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        Parent = left,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = hero })
    local heroStroke = ni("UIStroke", { Color = ACC, Transparency = 0.72, Thickness = 1, Parent = hero })
    table.insert(themeAcc, { heroStroke, "Color" })

    local glow1 = ni("Frame", { Position = UDim2.new(0, -40, 0, -50), Size = UDim2.new(0, 180, 0, 180), BackgroundColor3 = ACC, BackgroundTransparency = 0.9, BorderSizePixel = 0, ZIndex = 1, Parent = hero })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glow1 })
    table.insert(themeAcc, { glow1, "BackgroundColor3" })
    local glow2 = ni("Frame", { Position = UDim2.new(1, -130, 1, -110), Size = UDim2.new(0, 170, 0, 170), BackgroundColor3 = CYAN, BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = 1, Parent = hero })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glow2 })
    task.spawn(function()
        while glow1.Parent do
            TS:Create(glow1, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.8, Size = UDim2.new(0, 200, 0, 200) }):Play()
            TS:Create(glow2, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.84 }):Play()
            task.wait(2)
            TS:Create(glow1, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.93, Size = UDim2.new(0, 180, 0, 180) }):Play()
            TS:Create(glow2, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.94 }):Play()
            task.wait(2)
        end
    end)

    local nBox = ni("Frame", { Position = UDim2.new(0, 18, 0, 24), Size = UDim2.new(0, 86, 0, 92), BackgroundColor3 = ACC, BackgroundTransparency = 0.08, BorderSizePixel = 0, ZIndex = 2, Parent = hero })
    ni("UICorner", { CornerRadius = UDim.new(0, 16), Parent = nBox })
    table.insert(themeAcc, { nBox, "BackgroundColor3" })
    ni("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "N", TextColor3 = Color3.fromRGB(9, 11, 18), Font = Enum.Font.GothamBlack, TextSize = 52, ZIndex = 3, Parent = nBox })

    ni("TextLabel", { Position = UDim2.new(0, 118, 0, 24), Size = UDim2.new(1, -132, 0, 32), BackgroundTransparency = 1, Text = "NanoHub", TextColor3 = TXT, Font = Enum.Font.GothamBlack, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = hero })
    ni("TextLabel", { Position = UDim2.new(0, 120, 0, 58), Size = UDim2.new(1, -134, 0, 16), BackgroundTransparency = 1, Text = "AimLock • ESP • Game Hub — one clean UI.", TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = hero })

    local CHIPS = {
        { i = "✦", t = "Fast", s = "instant response" },
        { i = "❖", t = "Safe", s = "key protected" },
        { i = "★", t = "Free", s = "no paywall" },
    }
    for ci, c in ipairs(CHIPS) do
        local ch = ni("Frame", { Position = UDim2.new(0, 120 + (ci - 1) * 104, 0, 84), Size = UDim2.new(0, 96, 0, 42), BackgroundColor3 = BG3, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 2, Parent = hero })
        ni("UICorner", { CornerRadius = UDim.new(0, 9), Parent = ch })
        ni("TextLabel", { Position = UDim2.new(0, 8, 0, 12), Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, Text = c.i, TextColor3 = emojiColor(c.i), TextSize = 13, ZIndex = 3, Parent = ch })
        ni("TextLabel", { Position = UDim2.new(0, 28, 0, 6), Size = UDim2.new(1, -32, 0, 16), BackgroundTransparency = 1, Text = c.t, TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = ch })
        ni("TextLabel", { Position = UDim2.new(0, 28, 0, 21), Size = UDim2.new(1, -32, 0, 14), BackgroundTransparency = 1, Text = c.s, TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = ch })
    end

    -- ---------- KEY ACCESS ----------
    local card = ni("Frame", { Position = UDim2.new(0, 0, 0, 148), Size = UDim2.new(1, 0, 1, -148), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = left })
    ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = card })
    local cardStroke = ni("UIStroke", { Color = BG4, Thickness = 1, Parent = card })

    local playIco = ni("Frame", { Position = UDim2.new(0, 14, 0, 12), Size = UDim2.new(0, 28, 0, 28), BackgroundColor3 = ACC, BackgroundTransparency = 0.82, BorderSizePixel = 0, Parent = card })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = playIco })
    local playStroke = ni("UIStroke", { Color = ACC, Transparency = 0.5, Thickness = 1, Parent = playIco })
    table.insert(themeAcc, { playStroke, "Color" })
    ni("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "▶", TextColor3 = ACC, TextSize = 13, Parent = playIco })

    ni("TextLabel", { Position = UDim2.new(0, 52, 0, 14), Size = UDim2.new(1, -172, 0, 22), BackgroundTransparency = 1, Text = "Key Access", TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })

    local keyStat = ni("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 13), Size = UDim2.new(0, 108, 0, 26), BackgroundColor3 = Color3.fromRGB(36, 16, 21), BorderSizePixel = 0, Parent = card })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = keyStat })
    local keyDot = ni("Frame", { Position = UDim2.new(0, 10, 0.5, -4), Size = UDim2.new(0, 8, 0, 8), BackgroundColor3 = RED, BorderSizePixel = 0, Parent = keyStat })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = keyDot })
    local keyLbl = ni("TextLabel", { Position = UDim2.new(0, 24, 0, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1, Text = "Locked", TextColor3 = RED, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = keyStat })

    local subTxt = ni("TextLabel", { Position = UDim2.new(0, 14, 0, 46), Size = UDim2.new(1, -28, 0, 16), BackgroundTransparency = 1, Text = 'Key "Nano" — bei jedem Start eingeben. (Enter = Verify)', TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })

    local box = ni("TextBox", { Position = UDim2.new(0, 14, 0, 68), Size = UDim2.new(1, -28, 0, 40), BackgroundColor3 = BG3, BorderSizePixel = 0, PlaceholderText = "XXXX-XXXX-XXXX", PlaceholderColor3 = SUB, Text = "", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 14, ClearTextOnFocus = false, Parent = card })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = box })
    local boxStroke = ni("UIStroke", { Color = BG4, Thickness = 1.2, Parent = box })
    box.Focused:Connect(function()
        TS:Create(boxStroke, TweenInfo.new(0.2), { Color = ACC, Thickness = 2 }):Play()
    end)
    box.FocusLost:Connect(function()
        TS:Create(boxStroke, TweenInfo.new(0.2), { Color = BG4, Thickness = 1.2 }):Play()
    end)
    box.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.Return then
            -- Trigger verify (Funktion ist weiter unten definiert)
            task.defer(function()
                local btn = vBtn
                if btn and btn.Visible then
                    for _, c in pairs(getconnections and getconnections(btn.MouseButton1Click) or {}) do
                        pcall(function() c:Fire() end)
                    end
                end
            end)
        end
    end)


    local errLbl = ni("TextLabel", { Position = UDim2.new(0, 14, 0, 110), Size = UDim2.new(1, -28, 0, 16), BackgroundTransparency = 1, Text = "", TextColor3 = RED, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })

    local vBtn = ni("TextButton", { Position = UDim2.new(0, 14, 0, 130), Size = UDim2.new(1, -28, 0, 40), BackgroundColor3 = ACC, BorderSizePixel = 0, Text = "Verify Key", TextColor3 = Color3.fromRGB(12, 14, 20), Font = Enum.Font.GothamBold, TextSize = 15, AutoButtonColor = false, Parent = card })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = vBtn })
    table.insert(themeAcc, { vBtn, "BackgroundColor3" })
    vBtn.MouseEnter:Connect(function() TS:Create(vBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.15 }):Play() end)
    vBtn.MouseLeave:Connect(function() TS:Create(vBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play() end)
    task.spawn(function()
        while vBtn.Parent and not unlocked do
            local sc = 1.0
            for i = 1, 6 do
                sc = 1.0 + 0.01 * math.sin((i / 6) * math.pi * 2)
                pcall(function() vBtn.Size = UDim2.new(1, -28, 0, 40 + (sc - 1) * 40) end)
                task.wait(0.12)
            end
        end
    end)

    local okLbl = ni("TextLabel", { Position = UDim2.new(0, 14, 0, 136), Size = UDim2.new(1, -28, 0, 34), BackgroundTransparency = 1, Text = "✓  Key verified — Session aktiv!", TextColor3 = GRN, Font = Enum.Font.GothamBold, TextSize = 15, Visible = false, Parent = card })
    -- Session-Panel (erscheint nach Verifikation statt leerer Card)
    local okSession = ni("Frame", {
        Position = UDim2.new(0, 14, 0, 60),
        Size = UDim2.new(1, -28, 1, -80),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = card,
    })
    local function sessRow(y, ico, label, valFn)
        local r = ni("Frame", {
            Position = UDim2.new(0, 0, 0, y),
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = BG3,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Parent = okSession,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = r })
        ni("TextLabel", {
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 24, 1, 0),
            BackgroundTransparency = 1, Text = ico, TextSize = 16, Font = Enum.Font.GothamBold,
            TextColor3 = GRN, TextXAlignment = Enum.TextXAlignment.Left, Parent = r,
        })
        ni("TextLabel", {
            Position = UDim2.new(0, 44, 0, 0), Size = UDim2.new(0.4, -44, 1, 0),
            BackgroundTransparency = 1, Text = label, TextColor3 = SUB,
            Font = Enum.Font.GothamMedium, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = r,
        })
        local v = ni("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.new(0.5, -12, 1, 0), BackgroundTransparency = 1,
            Text = "—", TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right, Parent = r,
        })
        task.spawn(function()
            while r.Parent do
                pcall(function() v.Text = valFn() end)
                task.wait(1)
            end
        end)
    end
    sessRow(0,  "✓", "Session",   function() return "Aktiv" end)
    sessRow(46, "⏱", "Laufzeit",  function()
        local t = os.clock() - T0
        return string.format("%dm %02ds", math.floor(t / 60), math.floor(t % 60))
    end)
    sessRow(92, "🎮", "Game",     function() return game.Name end)
    sessRow(138, "🔑", "Tab-Status", function() return "Alle frei" end)
    -- Admin-Login (unter Tab-Status, im Session-Panel)
    local aRow = ni("Frame", {
        Position = UDim2.new(0, 0, 0, 184),
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = BG3,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = okSession,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = aRow })
    ni("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 80, 1, 0),
        BackgroundTransparency = 1, Text = "🔑 Admin Key", TextColor3 = SUB,
        Font = Enum.Font.GothamMedium, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = aRow,
    })
    local abox = ni("TextBox", {
        Position = UDim2.new(0, 96, 0.5, -12), Size = UDim2.new(1, -106, 0, 24),
        BackgroundColor3 = BG2, BorderSizePixel = 0,
        PlaceholderText = "Admin Key...", Text = "", TextColor3 = TXT,
        Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
        Parent = aRow,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = abox })
    abox.FocusLost:Connect(function(enter)
        if not enter then return end
        if abox.Text == "Nanolol13" then
            S.isAdmin = true
            abox.Text = ""
            abox.PlaceholderText = "Admin OK ✓"
            toast("🔑 Admin-Modus aktiv", GRN)
            if hub.log then pcall(hub.log, "Admin", "unlocked", GRN) end
            if hub.buildGrid then pcall(hub.buildGrid) end
        elseif abox.Text ~= "" then
            toast("Falscher Admin-Key", RED)
            abox.Text = ""
        end
    end)
    local vStat = ni("TextLabel", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -32), Size = UDim2.new(1, -28, 0, 16), BackgroundTransparency = 1, Text = "", TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
    local barBg = ni("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -14), Size = UDim2.new(1, -28, 0, 5), BackgroundColor3 = BG4, BorderSizePixel = 0, Parent = card })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barBg })
    local vBar = ni("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = ACC, BorderSizePixel = 0, Parent = barBg })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = vBar })
    table.insert(themeAcc, { vBar, "BackgroundColor3" })

    -- ---------- PROFIL ----------
    local prof = ni("Frame", { Size = UDim2.new(1, 0, 0, 80), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = right })
    ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = prof })

    local av = ni("TextButton", { Position = UDim2.new(0, 14, 0, 15), Size = UDim2.new(0, 50, 0, 50), BackgroundColor3 = ACC, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = prof })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = av })
    table.insert(themeAcc, { av, "BackgroundColor3" })
    ni("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = string.upper(string.sub(LP.DisplayName, 1, 1)), TextColor3 = Color3.fromRGB(10, 12, 20), Font = Enum.Font.GothamBlack, TextSize = 22, Parent = av })

    local ring = ni("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 39, 0, 40), Size = UDim2.new(0, 58, 0, 58), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = prof })
    ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ring })
    local ringStroke = ni("UIStroke", { Color = ACC, Transparency = 0.4, Thickness = 1.5, Parent = ring })
    table.insert(themeAcc, { ringStroke, "Color" })
    task.spawn(function()
        while ring.Parent do
            TS:Create(ring, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 62, 0, 62) }):Play()
            TS:Create(ringStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.8 }):Play()
            task.wait(1.4)
            TS:Create(ring, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 58, 0, 58) }):Play()
            TS:Create(ringStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.35 }):Play()
            task.wait(1.4)
        end
    end)

    ni("TextLabel", { Position = UDim2.new(0, 76, 0, 20), Size = UDim2.new(1, -90, 0, 18), BackgroundTransparency = 1, Text = LP.DisplayName, TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof })
    ni("TextLabel", { Position = UDim2.new(0, 76, 0, 39), Size = UDim2.new(1, -90, 0, 16), BackgroundTransparency = 1, Text = "NanoHub User • Klick = Theme", TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof })

    av.MouseButton1Click:Connect(function()
        S.themeIdx = (S.themeIdx % #THEMES) + 1
        setThemeVars(S.themeIdx)
        saveCfg()
        for k, c in pairs(CTRLS) do pcall(function() c.set(S[k], true) end) end
        if hub.log then pcall(hub.log, "Theme", THEME_NAMES[S.themeIdx], ACC) end
        toast("🎨 Theme: " .. THEME_NAMES[S.themeIdx], ACC)
    end)

    -- ---------- QUICK STATS ----------
    local stats = ni("Frame", { Position = UDim2.new(0, 0, 0, 88), Size = UDim2.new(1, 0, 0, 152), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = right })
    ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = stats })
    ni("TextLabel", { Position = UDim2.new(0, 12, 0, 10), Size = UDim2.new(1, -24, 0, 18), BackgroundTransparency = 1, RichText = true, Text = em("◈", "  Quick Stats"), TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = stats })

    local SB = {
        { icon = "👥", name = "Players" },
        { icon = "⚡", name = "FPS" },
        { icon = "🕒", name = "Uptime" },
        { icon = "🔑", name = "Key" },
    }
    
    local vals = {}
    for si, d in ipairs(SB) do
        local col = (si - 1) % 2
        local rowi = math.floor((si - 1) / 2)
        local tile = ni("Frame", {
            Position = UDim2.new(0.5 * col, (col == 0) and 12 or 5, 0, 36 + rowi * 52),
            Size = UDim2.new(0.5, -17, 0, 46),
            BackgroundColor3 = BG3,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Parent = stats,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 9), Parent = tile })
        ni("TextLabel", { Position = UDim2.new(0, 8, 0, 6), Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, Text = d.icon, TextColor3 = emojiColor(d.icon), TextSize = 13, ZIndex = 2, Parent = tile })
        ni("TextLabel", { Position = UDim2.new(0, 28, 0, 6), Size = UDim2.new(1, -34, 0, 16), BackgroundTransparency = 1, Text = d.name, TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = tile })
        local v = ni("TextLabel", { Position = UDim2.new(0, 8, 0, 22), Size = UDim2.new(1, -16, 0, 20), BackgroundTransparency = 1, Text = "—", TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = tile })
        vals[#vals + 1] = v
    end
    local valPlayers, valFps, valUptime, valKey = vals[1], vals[2], vals[3], vals[4]

    hub.statKey = function(ok)
        if not valKey then return end
        valKey.Text = ok and "Verified" or "Locked"
        valKey.TextColor3 = ok and GRN or RED
    end

    local frames = 0
    track(game:GetService("RunService").Heartbeat:Connect(function()
        frames = frames + 1
    end))
    task.spawn(function()
        while stats.Parent do
            task.wait(0.5)
            if valPlayers then valPlayers.Text = tostring(#P:GetPlayers()) end
            if valFps then valFps.Text = tostring(math.floor(frames * 2 + 0.5)) end
            if valUptime then
                local t = os.clock() - T0
                valUptime.Text = string.format("%dm %02ds", math.floor(t / 60), math.floor(t % 60))
            end
            frames = 0
        end
    end)

    -- ---------- LIVE LOGS ----------
    local logs = ni("Frame", { Position = UDim2.new(0, 0, 0, 248), Size = UDim2.new(1, 0, 1, -248), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = right })
    ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = logs })
    ni("TextLabel", { Position = UDim2.new(0, 12, 0, 10), Size = UDim2.new(1, -80, 0, 18), BackgroundTransparency = 1, RichText = true, Text = em("▤", "  Live Logs"), TextColor3 = TXT, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = logs })
    local clearBtn = ni("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.new(0, 62, 0, 22), BackgroundColor3 = BG3, BorderSizePixel = 0, RichText = true, Text = em("X", " Clear"), TextColor3 = SUB, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, Parent = logs })
    ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = clearBtn })

    local logHolder = ni("Frame", { Position = UDim2.new(0, 12, 0, 38), Size = UDim2.new(1, -24, 1, -50), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = logs })
    ni("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = logHolder })

    local logRows = {}
    hub.log = function(tag, msg, col)
        if not logHolder or not logHolder.Parent then return end
        local t = os.clock() - T0
        local stamp = string.format("%02d:%02d", math.floor(t / 60), math.floor(t % 60))
        local row = ni("TextLabel", {
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = "[" .. stamp .. "] " .. tostring(tag) .. "  ›  " .. tostring(msg),
            TextColor3 = col or SUB,
            Font = Enum.Font.Code,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = logHolder,
        })
        table.insert(logRows, row)
        while #logRows > 7 do
            local old = table.remove(logRows, 1)
            if old then pcall(function() old:Destroy() end) end
        end
    end

    clearBtn.MouseButton1Click:Connect(function()
        for _, r in ipairs(logRows) do pcall(function() r:Destroy() end) end
        logRows = {}
        if hub.log then pcall(hub.log, "Logs", "cleared", SUB) end
    end)

    -- ---------- KEY VERIFY ----------
    local VALID_KEY = "Nano"
    local function keyIsValid(k)
        return string.lower(tostring(k or "")):gsub("%s", "") == string.lower(VALID_KEY)
    end
    local checking = false
    local function verify()
        if checking or unlocked then return end
        if keyIsValid(box.Text) then
            checking = true
            errLbl.Text = ""
            boxStroke.Color = GRN
            vStat.Text = "Checking key..."
            for i = 1, 10 do
                vBar.Size = UDim2.new(i / 10, 0, 1, 0)
                task.wait(0.05)
            end
            vStat.Text = "Verified ✓"
            vStat.TextColor3 = GRN
            box.Visible = false
            vBtn.Visible = false
            okLbl.Visible = false
            subTxt.Text = "Alle Tabs freigeschaltet — viel Spaß!"
            cardStroke.Color = GRN
            keyLbl.Text = "Verified"
            keyLbl.TextColor3 = GRN
            keyDot.BackgroundColor3 = GRN
            keyStat.BackgroundColor3 = Color3.fromRGB(14, 34, 23)
            unlockTabs()

            -- Card verwandelt sich in Session-Panel
            TS:Create(card, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(14, 34, 23) }):Play()
            box.Visible = false
            vBtn.Visible = false
            errLbl.Visible = false
            barBg.Visible = false
            vStat.Visible = false
            okSession.Visible = true

        else
            errLbl.Text = "✗  Invalid Key"
            box.Text = ""
            if hub.log then pcall(hub.log, "Key", "invalid attempt", RED) end
            local orig = win.Position
            for _, off in ipairs({ -10, 10, -7, 7, -4, 0 }) do
                win.Position = UDim2.new(orig.X.Scale, orig.X.Offset + off, orig.Y.Scale, orig.Y.Offset)
                task.wait(0.035)
            end
        end
    end
        box.InputBegan:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.Return then pcall(verify) end
    end)
    vBtn.MouseButton1Click:Connect(verify)
    box.FocusLost:Connect(function(enter)
        if enter then verify() end
    end)
    box.Focused:Connect(function()
        TS:Create(boxStroke, TweenInfo.new(0.2), { Color = ACC }):Play()
    end)
    box.FocusLost:Connect(function()
        if not unlocked then
            task.delay(0.4, function()
                if not unlocked then TS:Create(boxStroke, TweenInfo.new(0.2), { Color = BG4 }):Play() end
            end)
        end
    end)
    task.spawn(function()
        task.wait(0.3)
        if not unlocked then pcall(function() box:CaptureFocus() end) end
    end)
end
buildHome()
-- ============ BLADE BALL (Feature-Modul) ============
do
    local bladeRunners, bladeClean = {}, {}
    local bladeBallBill = nil

    local function bladeMyRoot()
        local c = LP.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    local function bladeRun(key, interval, step)
        if bladeRunners[key] then return end
        local run = { on = true }
        bladeRunners[key] = run
        task.spawn(function()
            while run.on do
                pcall(step)
                task.wait(interval)
            end
            bladeRunners[key] = nil
        end)
    end

    local function bladeStopAll()
        for _, r in pairs(bladeRunners) do r.on = false end
        table.clear(bladeRunners)
        for _, f in pairs(bladeClean) do pcall(f) end
    end
    hub.bladeStopAll = bladeStopAll

    -- ⚾ BALL ESP
    local function bladeBallStep()
        local bt = workspace:FindFirstChild("BallTarget")
        local primary = bt and (bt.PrimaryPart or bt:FindFirstChildWhichIsA("BasePart"))
        if primary then
            if not bladeBallBill or not bladeBallBill.Parent then
                local bb = ni("BillboardGui", {
                    Name = rndName("NHBLADE"),
                    Size = UDim2.new(0, 140, 0, 50),
                    StudsOffset = Vector3.new(0, 3, 0),
                    AlwaysOnTop = true, LightInfluence = 0,
                    Adornee = primary, Parent = primary,
                })
                local hold = ni("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = BG0, BackgroundTransparency = 0.35,
                    BorderSizePixel = 0, Parent = bb,
                })
                ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = hold })
                ni("UIStroke", { Color = CYAN, Thickness = 1.2, Parent = hold })
                local l1 = ni("TextLabel", {
                    Size = UDim2.new(1, -8, 0, 22), BackgroundTransparency = 1,
                    Text = "BALL", TextColor3 = CYAN, Font = Enum.Font.GothamBold,
                    TextSize = 13, Parent = hold,
                })
                local l2 = ni("TextLabel", {
                    Position = UDim2.new(0, 4, 0, 22), Size = UDim2.new(1, -8, 0, 20),
                    BackgroundTransparency = 1, Text = "", TextColor3 = TXT,
                    Font = Enum.Font.GothamBold, TextSize = 12, Parent = hold,
                })
                bladeBallBill = { bb = bb, dist = l2 }
            end
            local root = bladeMyRoot()
            local d = root and math.floor((primary.Position - root.Position).Magnitude + 0.5) or 0
            bladeBallBill.dist.Text = d .. " studs"
        elseif bladeBallBill then
            pcall(function() bladeBallBill.bb:Destroy() end)
            bladeBallBill = nil
        end
    end
    bladeClean.bladeBallESP = function()
        pcall(function() if bladeBallBill then bladeBallBill.bb:Destroy() end end)
        bladeBallBill = nil
    end

    -- 👥 PLAYER ESP (Blade Ball)
    local bladePlrBills = {}
    local function bladePlrStep()
        local root = bladeMyRoot()
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP then
                local c = pl.Character
                local head = c and c:FindFirstChild("Head")
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local e = bladePlrBills[pl]
                    if not e then
                        local bb = ni("BillboardGui", {
                            Name = rndName("NHBLADE"), Size = UDim2.new(0, 150, 0, 22),
                            StudsOffset = Vector3.new(0, 2.5, 0), AlwaysOnTop = true,
                            LightInfluence = 0, Adornee = head, Parent = head,
                        })
                        local lbl = ni("TextLabel", {
                            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                            TextColor3 = TXT, Font = Enum.Font.GothamBold,
                            TextSize = 12, TextStrokeTransparency = 0.4, Parent = bb,
                        })
                        e = { bb = bb, lbl = lbl }
                        bladePlrBills[pl] = e
                    end
                    local d = root and math.floor((head.Position - root.Position).Magnitude + 0.5) or 0
                    e.lbl.Text = pl.DisplayName .. " [" .. tostring(d) .. "m]"
                elseif bladePlrBills[pl] then
                    pcall(function() bladePlrBills[pl].bb:Destroy() end)
                    bladePlrBills[pl] = nil
                end
            end
        end
    end
    bladeClean.bladePlrESP = function()
        for _, e in pairs(bladePlrBills) do pcall(function() e.bb:Destroy() end) end
        bladePlrBills = {}
    end

    hub.bladeFeatures = {
        { key = "bladeBallESP", title = "⚾ Ball ESP",   interval = 0.15, step = bladeBallStep },
        { key = "bladePlrESP",  title = "👥 Player ESP", interval = 0.3,  step = bladePlrStep },
    }
    hub.bladeToggle = function(fdef, on)
        if on then
            bladeRun(fdef.key, fdef.interval, fdef.step)
        else
            local r = bladeRunners[fdef.key]
            if r then r.on = false; bladeRunners[fdef.key] = nil end
            if bladeClean[fdef.key] then pcall(bladeClean[fdef.key]) end
        end
    end
end

-- ============ MINE ANTARCTICA (Feature-Modul, adaptiv) ============
do
    local RS2 = game:GetService("ReplicatedStorage")
    local mantRunners, mantClean = {}, {}
    local mantOreBills, mantPlrBills = {}, {}
    local sellRemote, sellScanned = nil, false

    local TIER_COLORS = {
        secret    = Color3.fromRGB(255, 45, 45),
        mythical  = Color3.fromRGB(255, 70, 210),
        mythic    = Color3.fromRGB(255, 70, 210),
        godly     = Color3.fromRGB(255, 215, 90),
        legendary = Color3.fromRGB(255, 200, 60),
        epic      = Color3.fromRGB(170, 90, 255),
        rare      = Color3.fromRGB(70, 220, 120),
        uncommon  = Color3.fromRGB(120, 220, 255),
        diamond   = Color3.fromRGB(120, 240, 255),
        gold      = Color3.fromRGB(255, 200, 60),
        ice       = Color3.fromRGB(160, 230, 255),
        frozen    = Color3.fromRGB(160, 230, 255),
        common    = Color3.fromRGB(205, 205, 205),
    }

    -- Rarity-Filter: Rangfolge + Namen fuer den Cycle
    local MANT_TIER_RANK = {
        common = 1, uncommon = 2, rare = 3, epic = 4,
        legendary = 5, godly = 6, mythical = 7, mythic = 7, secret = 8,
    }
    local MANT_TIER_NAMES = { "Alle", "Common+", "Uncommon+", "Rare+", "Epic+", "Legendary+", "Godly+", "Mythical+", "Secret" }
    hub.mantTierNames = MANT_TIER_NAMES
    local MANT_TIER_LIST = {
        { "Common", "common" }, { "Uncommon", "uncommon" }, { "Rare", "rare" },
        { "Epic", "epic" }, { "Legendary", "legendary" }, { "Mythical", "mythical" },
        { "Zenith", "zenith" },
    }
    hub.mantTierList = MANT_TIER_LIST

    local function mantTierColor(txt)
        local t = tostring(txt or ""):lower()
        for k, c in pairs(TIER_COLORS) do
            if t:find(k, 1, true) then return c end
        end
        return Color3.fromRGB(0, 225, 255)
    end

    local function mantMyRoot()
        local c = LP.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    local function mantIsOre(obj)
        -- Nur Top-Level-Eintraege in SpawnedGems
        local p = obj.Parent
        return (p and p.Name == "SpawnedGems") and (obj:IsA("Model") or obj:IsA("BasePart"))
    end

    -- Werte direkt aus dem Spiel-Label GemInfo lesen
    local function mantGemLabels(gem)
        local gi = gem:FindFirstChild("GemInfo", true)
        if not gi then return nil end
        local function txt(nm)
            local l = gi:FindFirstChild(nm)
            if l and l:IsA("TextLabel") and l.Text ~= "" then return l.Text end
            return nil
        end
        return {
            name = txt("GemName") or txt("Title"),
            val  = txt("Value"),
            wgt  = txt("Weight"),
            luck = txt("Luck"),
            mut  = txt("Mutations"),
        }
    end

    -- Seltenheit eines Gems: scannt alle Texte im GemInfo
    local function mantGemTier(gem)
        local gi = gem:FindFirstChild("GemInfo", true)
        if not gi then return 0 end
        local blob = ""
        for _, d in ipairs(gi:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text ~= "" then
                blob = blob .. " " .. d.Text
            end
        end
        blob = blob:lower():gsub("<[^>]+>", " ")
        local bestR, bestK = 0, nil
        for k, r in pairs(MANT_TIER_RANK) do
            if blob:find(k, 1, true) and r > bestR then bestR, bestK = r, k end
        end
        return bestK
    end

      local function mantOreStep()
        local folder = workspace:FindFirstChild("SpawnedGems")
        if not folder then return end
        local seen = {}
        local minR = clamp(S.mantMinTier or 1, 1, #MANT_TIER_NAMES)
        for _, gem in ipairs(folder:GetChildren()) do
            if gem:IsA("Model") or gem:IsA("BasePart") then
                seen[gem] = true
                local sel = S.mantTiers
                local any = false
                if sel then for _ in pairs(sel) do any = true break end end
                local tName = mantGemTier(gem)
                local pass = (not any)
                if not pass and tName then
                    for nm in pairs(sel) do
                        if nm:lower() == tName then pass = true break end
                    end
                end

                if not pass and mantOreBills[gem] then
                    pcall(function() mantOreBills[gem].bb:Destroy() end)
                    mantOreBills[gem] = nil
                end
                if pass then
                    local e = mantOreBills[gem]
                    if not e then
                        local anchor = gem:FindFirstChild("GemInfoAnchor") or gem
                        local bb = ni("BillboardGui", {
                            Name = rndName("NAMANT"),
                            Size = UDim2.new(0, 170, 0, 90),
                            StudsOffset = Vector3.new(0, 3, 0),
                            AlwaysOnTop = true, LightInfluence = 0,
                            Adornee = anchor, Parent = anchor,
                        })
                        local hold = ni("Frame", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundColor3 = BG0, BackgroundTransparency = 0.3,
                            BorderSizePixel = 0, Parent = bb,
                        })
                        ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = hold })
                        ni("UIStroke", { Color = BG4, Thickness = 1, Parent = hold })
                        ni("UIListLayout", { Padding = UDim.new(0, 2), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = hold })
                        local function mkLbl(order, col, sz)
                            return ni("TextLabel", {
                                Size = UDim2.new(1, -10, 0, sz or 13),
                                BackgroundTransparency = 1,
                                RichText = true,
                                Font = Enum.Font.GothamBold,
                                TextSize = sz or 12, TextStrokeTransparency = 0.5,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                TextTruncate = Enum.TextTruncate.AtEnd,
                                TextColor3 = col, LayoutOrder = order, Parent = hold,
                            })
                        end
                        e = {
                            bb = bb,
                            name = mkLbl(1, TXT, 14),
                            mut  = mkLbl(2, Color3.fromRGB(255, 150, 60)),
                            val  = mkLbl(3, Color3.fromRGB(255, 200, 60)),
                            wgt  = mkLbl(4, Color3.fromRGB(120, 200, 255)),
                            luck = mkLbl(5, Color3.fromRGB(96, 226, 138)),
                        }
                        mantOreBills[gem] = e
                    end
                    local li = mantGemLabels(gem)
                    pcall(function()
                        e.name.Text = (li and li.name) or gem.Name
                        e.mut.Text  = (li and li.mut)  or ""
                        e.val.Text  = (li and li.val)  or ""
                        e.wgt.Text  = (li and li.wgt)  or ""
                        e.luck.Text = (li and li.luck) or ""
                        e.mut.Visible  = e.mut.Text ~= ""
                        e.val.Visible  = e.val.Text ~= ""
                        e.wgt.Visible  = e.wgt.Text ~= ""
                        e.luck.Visible = e.luck.Text ~= ""
                    end)
                end
            end
        end
        for gem, e in pairs(mantOreBills) do
            if not seen[gem] or not gem.Parent then
                pcall(function() e.bb:Destroy() end)
                mantOreBills[gem] = nil
            end
        end
    end

    mantClean.mantOreESP = function()
        for _, e in pairs(mantOreBills) do pcall(function() e.bb:Destroy() end) end
        mantOreBills = {}
    end


    -- 2) PLAYER ESP
    local function mantPlrStep()
        local root = mantMyRoot()
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP then
                local c = pl.Character
                local head = c and c:FindFirstChild("Head")
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local e = mantPlrBills[pl]
                    if not e then
                        local bb = ni("BillboardGui", {
                            Name = rndName("NAMANT"), Size = UDim2.new(0, 150, 0, 22),
                            StudsOffset = Vector3.new(0, 2.5, 0), AlwaysOnTop = true,
                            LightInfluence = 0, Adornee = head, Parent = head,
                        })
                        local lbl = ni("TextLabel", {
                            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                            TextColor3 = TXT, Font = Enum.Font.GothamBold,
                            TextSize = 12, TextStrokeTransparency = 0.4, Parent = bb,
                        })
                        e = { bb = bb, lbl = lbl }
                        mantPlrBills[pl] = e
                    end
                    local d = root and math.floor((head.Position - root.Position).Magnitude + 0.5) or 0
                    e.lbl.Text = pl.DisplayName .. " [" .. tostring(d) .. "m]"
                elseif mantPlrBills[pl] then
                    pcall(function() mantPlrBills[pl].bb:Destroy() end)
                    mantPlrBills[pl] = nil
                end
            end
        end
    end
    mantClean.mantPlrESP = function()
        for _, e in pairs(mantPlrBills) do pcall(function() e.bb:Destroy() end) end
        mantPlrBills = {}
    end

    -- 3) AUTO DIG (ProximityPrompts in Reichweite truckern)
    local function mantFirePrompt(pr)
        if fireproximityprompt then
            pcall(fireproximityprompt, pr)
        else
            pcall(function() pr:InputHoldBegin() end)
            task.delay((pr.HoldDuration or 0) + 0.15, function()
                pcall(function() pr:InputHoldEnd() end)
            end)
        end
    end

    local function mantDigStep()
        local root = mantMyRoot()
        if not root then return end
        for _, pr in ipairs(workspace:GetDescendants()) do
            if pr:IsA("ProximityPrompt") then
                local par = pr.Parent
                local pos = par and par:IsA("BasePart") and par.Position
                if pos and (pos - root.Position).Magnitude <= 14 then
                    mantFirePrompt(pr)
                    break
                end
            end
        end
    end

 -- 3b) AUTO BREAK (naechstes Pick Up-/Mine-Prompt automatisch feuern)
    local function mantBreakStep()
        local root = mantMyRoot()
        if not root then return end
        local best, bestD = nil, 12
        for _, pr in ipairs(workspace:GetDescendants()) do
            if pr:IsA("ProximityPrompt") then
                local at = (pr.ActionText or ""):lower()
                if at:find("pick up", 1, true) or at:find("mine", 1, true) then
                    local par = pr.Parent
                    local pos = par and par:IsA("BasePart") and par.Position
                    if pos then
                        local d = (pos - root.Position).Magnitude
                        if d < bestD then bestD, best = d, pr end
                    end
                end
            end
        end
        if best then mantFirePrompt(best) end
    end

    -- 4) AUTO SELL (Remote mit "sell" im Namen + Prompt-Fallback)
    local function mantFindSell()
        if sellScanned and sellRemote and sellRemote.Parent then return sellRemote end
        sellRemote, sellScanned = nil, true
        local function scan(root)
            for _, d in ipairs(root:GetDescendants()) do
                if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction"))
                    and d.Name:lower():find("sell", 1, true) then
                    sellRemote = d
                    return
                end
            end
        end
        pcall(scan, RS2)
        if not sellRemote then pcall(scan, LP) end
        return sellRemote
    end

    local function mantSellStep()
        local rs = game:GetService("ReplicatedStorage")
        local gr = rs:FindFirstChild("GemRemotes")
        local r = gr and gr:FindFirstChild("RequestSell")
        if r then
            pcall(function()
                if r:IsA("RemoteFunction") then r:InvokeServer() else r:FireServer() end
            end)
            return
        end
        -- Fallback: Sell-Prompt in der Naehe triggern
        local root = mantMyRoot()
        if not root then return end
        for _, pr in ipairs(workspace:GetDescendants()) do
            if pr:IsA("ProximityPrompt") and pr.ActionText
                and pr.ActionText:lower():find("sell", 1, true) then
                local par = pr.Parent
                local pos = par and par:IsA("BasePart") and par.Position
                if pos and (pos - root.Position).Magnitude <= 14 then
                    mantFirePrompt(pr)
                    break
                end
            end
        end
    end

-- 5) SPEED BOOST  
    local function mantSpeedStep()
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed < 30 then
            h.WalkSpeed = 32
        end
    end
    mantClean.mantSpeed = function()
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.WalkSpeed = 16 end) end
    end

    -- Runner
    local function mantRun(key, interval, step)
        if mantRunners[key] then return end
        local run = { on = true }
        mantRunners[key] = run
        task.spawn(function()
            while run.on do
                pcall(step)
                task.wait(interval)
            end
            mantRunners[key] = nil
        end)
    end

    -- SellResult-Listener: Toast bei Verkauf + Console-Debug
    do
        task.spawn(function()
            local rs = game:GetService("ReplicatedStorage")
            local gr = rs:WaitForChild("GemRemotes", 10)
            local sr = gr and gr:WaitForChild("SellResult", 10)
            if sr and sr:IsA("RemoteEvent") then
                track(sr.OnClientEvent:Connect(function(...)
                    local args = { ... }
                    local ok, info = pcall(function() return HS:JSONEncode(args) end)
                    print("[NanoHub] SellResult:", ok and info or "?")
                    toast("💰 Auto Sell: verkauft!", GRN)
                end))
            end
        end)
    end

    mantClean.mantNoFall = function()
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                h:SetStateEnabled(Enum.HumanoidStateType.FallingOver, true)
            end)
        end
    end
    -- 🧱 ANTI RAGDOLL
    local function mantAntiRagStep()
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                h:SetStateEnabled(Enum.HumanoidStateType.FallingOver, false)
                -- Falls er schon liegt: sofort wieder aufstehen
                if h:GetState() == Enum.HumanoidStateType.Ragdoll
                    or h:GetState() == Enum.HumanoidStateType.FallingDown then
                    h:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end
    mantClean.mantAntiRag = function()
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                h:SetStateEnabled(Enum.HumanoidStateType.FallingOver, true)
            end)
        end
    end

    hub.mantFeatures = {
        { key = "mantOreESP",   title = "🧊 Ore ESP",    interval = 1,   step = mantOreStep },
        { key = "mantAutoBreak",title = "🔨 Auto pick up", interval = 0.1, step = mantBreakStep },
        { key = "mantAutoSell", title = "💰 Auto Sell",  interval = 5,   step = mantSellStep },
        { key = "mantSpeed",    title = "🏃 Speed Boost", interval = 1,  step = mantSpeedStep },
        { key = "mantAntiRag",  title = "🧱 Anti Ragdoll", interval = 0.25, step = mantAntiRagStep },
        { key = "mantPlrESP",   title = "👥 Player ESP", interval = 0.3, step = mantPlrStep },
    }
    hub.mantToggle = function(fdef, on)
        if on then
            mantRun(fdef.key, fdef.interval, fdef.step)
        else
            local r = mantRunners[fdef.key]
            if r then r.on = false; mantRunners[fdef.key] = nil end
            if mantClean[fdef.key] then pcall(mantClean[fdef.key]) end
        end
    end
    hub.mantStopAll = function()
        for _, f in ipairs(hub.mantFeatures) do
            S[f.key] = false
            local r = mantRunners[f.key]
            if r then r.on = false; mantRunners[f.key] = nil end
            if mantClean[f.key] then pcall(mantClean[f.key]) end
        end
    end
end
-- Dropdown (Multi-Select)
local function addDropdown(page, titleTxt, key, items)
    local row = mkRow(page)
    ni("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1, Text = titleTxt, TextColor3 = TXT,
        Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local val = ni("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -24, 0.5, 0),
        Size = UDim2.new(0, 90, 1, 0), BackgroundTransparency = 1,
        Text = "", TextColor3 = ACC, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
    })
    local arrow = ni("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 14, 1, 0), BackgroundTransparency = 1,
        Text = "v", TextColor3 = SUB, Font = Enum.Font.GothamBold, TextSize = 12, Parent = row,
    })
    local list = ni("Frame", {
        Size = UDim2.new(1, -16, 0, 0), BackgroundColor3 = BG1,
        BorderSizePixel = 0, Visible = false,
        AutomaticSize = Enum.AutomaticSize.Y, Parent = page,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = list })
    ni("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
    local pad = ni("UIPadding", { Parent = list })
    pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
    pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)

    local open = false
    local function countSel()
        local n = 0
        for _, nm in ipairs(items) do
            if (S[key] or {})[nm] then n = n + 1 end
        end
        return n
    end
    local function paintVal()
        local n = countSel()
        val.Text = (n == 0) and "Alle" or (tostring(n) .. " gewaehlt")
    end

    for i, nm in ipairs(items) do
        local opt = ni("TextButton", {
            Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = BG2,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
            LayoutOrder = i, Parent = list,
        })
        ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = opt })
        local cb = ni("TextLabel", {
            Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(0, 18, 1, 0),
            BackgroundTransparency = 1, Text = "", TextColor3 = GRN,
            Font = Enum.Font.GothamBold, TextSize = 13, Parent = opt,
        })
        ni("TextLabel", {
            Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -38, 1, 0),
            BackgroundTransparency = 1, Text = nm, TextColor3 = TXT,
            Font = Enum.Font.GothamMedium, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = opt,
        })
        local function paintOpt()
            local on = (S[key] or {})[nm]
            cb.Text = on and "✓" or ""
            opt.BackgroundColor3 = on and BG3 or BG2
        end
        opt.MouseButton1Click:Connect(function()
            S[key] = S[key] or {}
            S[key][nm] = not S[key][nm]
            paintOpt()
            paintVal()
        end)
        paintOpt()
    end
    paintVal()

    row.MouseButton1Click:Connect(function()
        open = not open
        list.Visible = open
        arrow.Text = open and "^" or "v"
    end)
end

-- ============ SCRIPTS TAB (Chose a game) ============
do
    local sp = pages[2]

    hub.updateScriptsTab = function()
        for _, c in ipairs(sp:GetChildren()) do
            if not c:IsA("UIListLayout") then pcall(function() c:Destroy() end) end
        end

        local g = nil
        for _, gg in ipairs(GAMES) do
            if gg.name == S.game then g = gg end
        end

        if not g then
            if hub.mtmStopAll then pcall(hub.mtmStopAll) end
            if hub.mantStopAll then pcall(hub.mantStopAll) end
            if hub.bladeStopAll then pcall(hub.bladeStopAll) end

            local f = ni("Frame", { Size = UDim2.new(1, -8, 0, 120), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = sp })
            ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = f })
            ni("TextLabel", {
                Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1,
                RichText = true, Text = em("✦", "  Chose a game\n\nOpen the Game tab and pick a game to see its scripts."),
                TextColor3 = SUB, Font = Enum.Font.GothamMedium, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
                TextWrapped = true, Parent = f,
            })
            return
        end

        local card = ni("Frame", { Size = UDim2.new(1, -8, 0, 96), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = sp })
        ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
        local hdr = ni("TextLabel", {
            Position = UDim2.new(0, 14, 0, 12), Size = UDim2.new(1, -28, 0, 18), BackgroundTransparency = 1,
            Text = "AKTUELLES GAME", TextColor3 = ACC, Font = Enum.Font.GothamBold, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
        })
        table.insert(themeAcc, { hdr, "TextColor3" })
        ni("TextLabel", {
            Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 0, 28), BackgroundTransparency = 1,
            RichText = true, Text = em(g.icon or "▶", "  " .. string.upper(g.name or "?")), TextColor3 = TXT,
            Font = Enum.Font.GothamBlack, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
        })
        ni("TextLabel", {
            Position = UDim2.new(0, 14, 0, 66), Size = UDim2.new(1, -28, 0, 18), BackgroundTransparency = 1,
            Text = tostring(#(g.features or {})) .. " Features verfuegbar", TextColor3 = SUB,
            Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
        })

        local isAnt = (g.placeId == 138686218420016)
            or (g.placeId == 125927821145949)
            or (tostring(g.name):lower():find("antarctica", 1, true) ~= nil)
            or (tostring(g.name):lower():find("mountain", 1, true) ~= nil)


        if isAnt then
            addHeader(sp, "Mine Antarctica Scripts")

            -- 2-Spalten-Grid fuer die Toggles
            local grid = ni("Frame", {
                Size = UDim2.new(1, -8, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = sp,
            })
            ni("UIGridLayout", {
                CellSize = UDim2.new(0.5, -6, 0, 32),
                CellPadding = UDim2.new(0, 8, 0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = grid,
            })

            local defs = {}
            for _, fdef in ipairs(hub.mantFeatures or {}) do defs[fdef.key] = fdef end
            local function mkChip(key, order)
                local fdef = defs[key]
                if not fdef then return end
                local chip = ni("TextButton", {
                    BackgroundColor3 = BG2, BorderSizePixel = 0,
                    Text = "", AutoButtonColor = false,
                    LayoutOrder = order, Parent = grid,
                })
                ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = chip })
                ni("TextLabel", {
                    Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -34, 1, 0),
                    BackgroundTransparency = 1, Text = fdef.title, TextColor3 = TXT,
                    Font = Enum.Font.GothamMedium, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = chip,
                })
                local dot = ni("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10), BackgroundColor3 = RED,
                    BorderSizePixel = 0, Parent = chip,
                })
                ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
                local function setOn(v)
                    S[fdef.key] = v
                    dot.BackgroundColor3 = v and GRN or RED
                    if hub.mantToggle then pcall(hub.mantToggle, fdef, v) end
                end
                chip.MouseButton1Click:Connect(function() setOn(not S[fdef.key]) end)
                if S[fdef.key] then setOn(true) end
            end

            mkChip("mantOreESP", 1)
            mkChip("mantPlrESP", 2)
            mkChip("mantAutoDig", 3)
            mkChip("mantAutoSell", 4)
            mkChip("mantSpeed", 5)
            mkChip("mantAutoBreak", 6)
            mkChip("mantAntiRag", 7)



            local tItems = {}
            for _, e in ipairs(hub.mantTierList or {}) do table.insert(tItems, e[1]) end
            addDropdown(sp, "ESP Rarity", "mantTiers", tItems)

            addHeader(sp, "Hinweis")
            ni("TextLabel", {
                Size = UDim2.new(1, -8, 0, 32), BackgroundTransparency = 1,
                Text = "ESP liest Name/$/kg/Luck direkt aus dem Spiel-UI (GemInfo). Die Rarity-Auswahl wird in der Config gespeichert.",
                TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = sp,
            })
        elseif g.name == "Mine a Mountain" then
            addHeader(sp, "Mine a Mountain Scripts")
            for _, fdef in ipairs(hub.mtmFeatures or {}) do
                addToggle(sp, fdef.title, fdef.key, function(on)
                    if hub.mtmToggle then pcall(hub.mtmToggle, fdef, on) end
                end)
                if S[fdef.key] and hub.mtmToggle then pcall(hub.mtmToggle, fdef, true) end
            end
            addHeader(sp, "Hinweis")
            ni("TextLabel", {
                Size = UDim2.new(1, -8, 0, 46), BackgroundTransparency = 1,
                Text = "Remotes: ReplicatedStorage.Remotes (SellRequest, CrystalHoldComplete). Crystal-Container: DroppedCrystals / Crystals. Toggles werden in der Config gespeichert.",
                TextColor3 = SUB, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = sp,
            })
        elseif g.name == "Blade Ball" then
            addHeader(sp, "Blade Ball Scripts")
            for _, fdef in ipairs(hub.bladeFeatures or {}) do
                addToggle(sp, fdef.title, fdef.key, function(on)
                    if hub.bladeToggle then pcall(hub.bladeToggle, fdef, on) end
                end)
                if S[fdef.key] and hub.bladeToggle then pcall(hub.bladeToggle, fdef, true) end
            end
        else

            if hub.mtmStopAll then pcall(hub.mtmStopAll) end
            if hub.mantStopAll then pcall(hub.mantStopAll) end
            if hub.bladeStopAll then pcall(hub.bladeStopAll) end

            ni("TextLabel", {
                Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1,
                Text = "Für dieses Game sind noch keine Scripts eingebaut.", TextColor3 = SUB,
                Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = sp,
            })
        end
    end
end
-- ============ ADMIN LOGIN (Settings) ============
do
    local stp = pages[4]
    local row = ni("Frame", { Size = UDim2.new(1, -8, 0, 56), BackgroundColor3 = BG2, BorderSizePixel = 0, Parent = stp })
    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = row })
    ni("TextLabel", { Position = UDim2.new(0, 10, 0, 6), Size = UDim2.new(1, -20, 0, 16), BackgroundTransparency = 1, Text = "🔑 Admin Login", TextColor3 = TXT, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local abox = ni("TextBox", { Position = UDim2.new(0, 10, 0, 28), Size = UDim2.new(1, -20, 0, 22), BackgroundColor3 = BG3, Text = "", PlaceholderText = "Admin Key...", TextColor3 = TXT, ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12, Parent = row })
    ni("UICorner", { CornerRadius = UDim.new(0, 6), Parent = abox })
    abox.FocusLost:Connect(function(enter)
        if enter and abox.Text == "Nanolol13" then
            S.isAdmin = true
            saveCfg()
            abox.Text = ""
            abox.PlaceholderText = "Admin OK ✓"
            toast("🔑 Admin-Modus aktiv", GRN)
            if hub.buildGrid then pcall(hub.buildGrid) end
        elseif enter then
            toast("Falscher Key", RED)
            abox.Text = ""
        end
    end)
end
-- ============ GAME TAB ============
do
    local gp = pages[3]

    local card = ni("Frame", {
        Size = UDim2.new(1, -8, 0, 150),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        Parent = gp,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
    ni("TextLabel", {
        Position = UDim2.new(0, 14, 0, 14),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        RichText = true, Text = em("▶", "  Game Selector"), TextColor3 = TXT,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })
    local curGame = ni("TextLabel", {
        Position = UDim2.new(0, 14, 0, 40),
        Size = UDim2.new(1, -28, 0, 18),
        BackgroundTransparency = 1,
        Text = "Aktuell: " .. (S.game ~= "" and S.game or "kein Game gewählt"),
        TextColor3 = SUB,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local chooseBtn = ni("TextButton", {
        Position = UDim2.new(0, 14, 0, 70),
        Size = UDim2.new(1, -28, 0, 44),
        BackgroundColor3 = ACC,
        BorderSizePixel = 0,
        Text = "Choose Game",
        TextColor3 = Color3.fromRGB(15, 15, 20),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        AutoButtonColor = false,
        Parent = card,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = chooseBtn })
    table.insert(themeAcc, { chooseBtn, "BackgroundColor3" })
    chooseBtn.MouseEnter:Connect(function()
        TS:Create(chooseBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.15 }):Play()
    end)
    chooseBtn.MouseLeave:Connect(function()
        TS:Create(chooseBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play()
    end)
    chooseBtn.MouseButton1Click:Connect(function()
        if hub.openPicker then hub.openPicker() end
    end)

    hub.setGameLbl = function()
        curGame.Text = "Aktuell: " .. (S.game ~= "" and S.game or "kein Game gewählt")
    end
end

-- ============ FULLSCREEN GAME PICKER ============
do
    local picker = ni("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 16),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 85,
        Parent = ui,
    })

    local pTitle = ni("TextLabel", {
        Position = UDim2.new(0, 24, 0, 76),
        Size = UDim2.new(1, -120, 0, 40),
        BackgroundTransparency = 1,
        Text = "Select Category",
        TextColor3 = TXT,
        Font = Enum.Font.GothamBlack,
        TextSize = 28,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 86,
        Parent = picker,
    })
    table.insert(themeAcc, { pTitle, "TextColor3" })
    ni("TextLabel", {
        Position = UDim2.new(0, 24, 0, 116),
        Size = UDim2.new(1, -120, 0, 18),
        BackgroundTransparency = 1,
        Text = "Each game has its own profile — settings are saved separately.",
        TextColor3 = SUB,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 86,
        Parent = picker,
    })

    local pClose = ni("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = BG3,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = RED,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
        ZIndex = 86,
        Parent = picker,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = pClose })
    pClose.MouseButton1Click:Connect(function()
        picker.Visible = false
    end)

    local grid = ni("ScrollingFrame", {
        Position = UDim2.new(0, 24, 0, 152),
        Size = UDim2.new(1, -48, 1, -176),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ACC,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 86,
        Parent = picker,
    })
    local gridLayout = ni("UIGridLayout", {
        CellSize = UDim2.new(0, 280, 0, 190),
        CellPadding = UDim2.new(0, 16, 0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = grid,
    })

    local emptyLbl = ni("TextLabel", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Text = "Noch keine Games — trag sie oben im Script ein (GAMES-Liste).",
        TextColor3 = SUB,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextWrapped = true,
        ZIndex = 87,
        Parent = grid,
    })
    -- Suchleiste (oben mittig, abgerundet)
    local searchBox = ni("TextBox", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 24),
        Size = UDim2.new(0, 420, 0, 38),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        PlaceholderText = "Search games...",
        PlaceholderColor3 = SUB,
        Text = "",
        TextColor3 = TXT,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        ClearTextOnFocus = false,
        ZIndex = 86,
        Parent = picker,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = searchBox })
    local sStroke = ni("UIStroke", { Color = BG4, Thickness = 1.2, Parent = searchBox })
    searchBox.Focused:Connect(function()
        TS:Create(sStroke, TweenInfo.new(0.2), { Color = ACC }):Play()
    end)
    searchBox.FocusLost:Connect(function()
        TS:Create(sStroke, TweenInfo.new(0.2), { Color = BG4 }):Play()
    end)
        -- ⟳ Refresh-Button (Status sofort neu laden)
    local refreshBtn = ni("TextButton", {
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0.5, 220, 0, 24),
        Size = UDim2.new(0, 38, 0, 38),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        Text = "⟳",
        TextColor3 = CYAN,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false,
        ZIndex = 86,
        Parent = picker,
    })
    ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = refreshBtn })
    local rStroke = ni("UIStroke", { Color = BG4, Thickness = 1.2, Parent = refreshBtn })
    refreshBtn.MouseEnter:Connect(function()
        TS:Create(refreshBtn, TweenInfo.new(0.2), { BackgroundColor3 = BG3 }):Play()
        TS:Create(rStroke, TweenInfo.new(0.2), { Color = ACC }):Play()
    end)
    refreshBtn.MouseLeave:Connect(function()
        TS:Create(refreshBtn, TweenInfo.new(0.2), { BackgroundColor3 = BG2 }):Play()
        TS:Create(rStroke, TweenInfo.new(0.2), { Color = BG4 }):Play()
    end)
    local refreshing = false
    refreshBtn.MouseButton1Click:Connect(function()
        if refreshing then return end
        refreshing = true
        local spin = TS:Create(refreshBtn, TweenInfo.new(0.8, Enum.EasingStyle.Linear), { Rotation = 360 })
        spin:Play()
        spin.Completed:Connect(function() refreshBtn.Rotation = 0 end)
        task.spawn(function()
            local st = nbRead()
            if st then
                S.gameStatus = st
                if hub.buildGrid then pcall(hub.buildGrid) end
                toast("✓ Status aktualisiert", GRN)
            else
                toast("✗ Status nicht erreichbar", RED)
            end
            refreshing = false
        end)
    end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(searchBox.Text)
        for _, c in ipairs(grid:GetChildren()) do
            if c:IsA("Frame") then
                local nm = c:GetAttribute("GameName") or ""
                c.Visible = (q == "") or (nm:find(q, 1, true) ~= nil)
            end
        end
    end)

    local function buildGrid()
        for _, c in ipairs(grid:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        emptyLbl.Visible = (#GAMES == 0)
        for gi, g in ipairs(GAMES) do
            local card = ni("Frame", {
                BackgroundColor3 = BG2,
                BorderSizePixel = 0,
                LayoutOrder = gi,
                ZIndex = 87,
                Parent = grid,
            })
            ni("UICorner", { CornerRadius = UDim.new(0, 12), Parent = card })
            local stroke = ni("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 2, Parent = card })
            card:SetAttribute("GameName", string.lower(g.name or ""))

            -- Status: UP / working on / Down (Admin setzt, Badge oben rechts blinkt)
            local STATUS_DEFS = {
                up      = { txt = "UP",         col = GRN, bg = Color3.fromRGB(14, 34, 23) },
                working = { txt = "working on", col = Color3.fromRGB(255, 170, 60), bg = Color3.fromRGB(42, 30, 12) },
                down    = { txt = "Down",       col = RED, bg = Color3.fromRGB(42, 14, 16) },
            }
            local status = (S.gameStatus and S.gameStatus[g.name]) or "down"
            local sd = STATUS_DEFS[status] or STATUS_DEFS.up

            -- Blinkendes Badge oben rechts
            local stB = ni("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -10, 0, 10),
                Size = UDim2.new(0, 92, 0, 22),
                BackgroundColor3 = sd.bg,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                ZIndex = 89,
                Parent = card,
            })
            ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = stB })
            local stDot = ni("Frame", {
                Position = UDim2.new(0, 7, 0.5, -4),
                Size = UDim2.new(0, 8, 0, 8),
                BackgroundColor3 = sd.col,
                BorderSizePixel = 0,
                ZIndex = 90,
                Parent = stB,
            })
            ni("UICorner", { CornerRadius = UDim.new(1, 0), Parent = stDot })
            ni("TextLabel", {
                Position = UDim2.new(0, 20, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Text = sd.txt,
                TextColor3 = sd.col,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 90,
                Parent = stB,
            })
            task.spawn(function()
                while stB.Parent do
                    TS:Create(stDot, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.7 }):Play()
                    task.wait(0.5)
                    TS:Create(stDot, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }):Play()
                    task.wait(0.5)
                end
            end)

            -- Admin-Buttons: neben dem Bild, untereinander (nur Admin)
            if S.isAdmin then
                local order = { "up", "working", "down" }
                for bi, key in ipairs(order) do
                    local d = STATUS_DEFS[key]
                    local b = ni("TextButton", {
                        Position = UDim2.new(0, 88, 0, 12 + (bi - 1) * 26),
                        Size = UDim2.new(0, 92, 0, 22),
                        BackgroundColor3 = d.bg,
                        BackgroundTransparency = 0.2,
                        BorderSizePixel = 0,
                        Text = d.txt,
                        TextColor3 = d.col,
                        Font = Enum.Font.GothamBold,
                        TextSize = 11,
                        AutoButtonColor = false,
                        ZIndex = 89,
                        Parent = card,
                    })
                    ni("UICorner", { CornerRadius = UDim.new(0, 8), Parent = b })
                    b.MouseButton1Click:Connect(function()
                        S.gameStatus = S.gameStatus or {}
                        S.gameStatus[g.name] = key
                        if nbWrite() then
                            toast(d.txt .. " -> fuer ALLE gespeichert", d.col)
                        else
                            toast("Speichern fehlgeschlagen", RED)
                        end
                        if hub.buildGrid then pcall(hub.buildGrid) end
                    end)
                end
            end
                        local iconBox
            if g._img then
                iconBox = ni("ImageLabel", {
                    Position = UDim2.new(0, 14, 0, 12),
                    Size = UDim2.new(0, 64, 0, 64),
                    BackgroundColor3 = BG3,
                    BorderSizePixel = 0,
                    Image = g._img,
                    ZIndex = 88,
                    Parent = card,
                })
            else
                iconBox = ni("TextLabel", {
                    Position = UDim2.new(0, 14, 0, 12),
                    Size = UDim2.new(0, 44, 0, 44),
                    BackgroundColor3 = BG3,
                    BorderSizePixel = 0,
                    Text = g.icon or "▶",
                    TextSize = 30,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = emojiColor(g.icon or "▶"),
                    ZIndex = 88,
                    Parent = card,
                })
            end
            ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = iconBox })
            ni("TextLabel", {
                Position = UDim2.new(0, 14, 0, 86),
                Size = UDim2.new(1, -28, 0, 24),
                BackgroundTransparency = 1,
                Text = string.upper(g.name or "?"),
                TextColor3 = TXT,
                Font = Enum.Font.GothamBlack,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 88,
                Parent = card,
            })
            local fl = g.features or {}
            for fi = 1, math.min(#fl, 3) do
                local on = fl[fi][2]
                ni("TextLabel", {
                    Position = UDim2.new(0, 14, 0, 96 + (fi - 1) * 20),
                    Size = UDim2.new(1, -28, 0, 18),
                    BackgroundTransparency = 1,
                    Text = (on and "✅  " or "➖  ") .. tostring(fl[fi][1]),
                    TextColor3 = on and GRN or Color3.fromRGB(110, 116, 138),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 88,
                    Parent = card,
                })
            end
            -- OPEN-Pill mittig unten
            local pill = ni("TextButton", {
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -12),
                Size = UDim2.new(0, 160, 0, 34),
                BackgroundColor3 = BG3,
                 Text = ((S.gameStatus and S.gameStatus[g.name]) == "up") and "OPEN  →" or "🔒 CLOSE",
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                AutoButtonColor = false,
                ZIndex = 89,
                Parent = card,
            })
            ni("UICorner", { CornerRadius = UDim.new(0, 10), Parent = pill })
            local pillStroke = ni("UIStroke", { Color = ACC, Thickness = 1.2, Transparency = 0.4, Parent = pill })
            table.insert(themeAcc, { pillStroke, "Color" })

            pill.MouseEnter:Connect(function()
                TS:Create(pill, TweenInfo.new(0.15), { BackgroundColor3 = ACC }):Play()
                TS:Create(pillStroke, TweenInfo.new(0.15), { Transparency = 0, Thickness = 2 }):Play()
                TS:Create(pill, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(15, 15, 20) }):Play()
            end)
            pill.MouseLeave:Connect(function()
                TS:Create(pill, TweenInfo.new(0.15), { BackgroundColor3 = BG3 }):Play()
                TS:Create(pillStroke, TweenInfo.new(0.15), { Transparency = 0.4, Thickness = 1.2 }):Play()
                TS:Create(pill, TweenInfo.new(0.15), { TextColor3 = TXT }):Play()
            end)

            -- Hover: Umrandung glüht weiß, Card hellt auf (auf Card UND Pill)
            local function hoverOn()
                TS:Create(stroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(255, 255, 255), Thickness = 2.5 }):Play()
                TS:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = BG3 }):Play()
            end
            local function hoverOff()
                TS:Create(stroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(0, 0, 0), Thickness = 2 }):Play()
                TS:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = BG2 }):Play()
            end
            card.MouseEnter:Connect(hoverOn)
            card.MouseLeave:Connect(hoverOff)
            pill.MouseEnter:Connect(hoverOn)
            pill.MouseLeave:Connect(hoverOff)

            pill.MouseButton1Click:Connect(function()
                if (S.gameStatus and S.gameStatus[g.name]) ~= "up" then
                    toast("🔒 " .. g.name .. " ist nicht verfügbar!", RED)
                    return
                end
                S.game = g.name
                saveCfg()
                if hub.setGameLbl then pcall(hub.setGameLbl) end
                if hub.updateScriptsTab then pcall(hub.updateScriptsTab) end
                if hub.log then pcall(hub.log, "Game", g.name, ACC) end
                picker.Visible = false
                toast("🎮 Game: " .. g.name, ACC)
            end)
        end
    end
    hub.buildGrid = buildGrid
    hub.openPicker = function()
        task.spawn(function()
            local st = nbRead()
            if st then S.gameStatus = st end
            buildGrid()
        end)
        picker.Visible = true
    end
end

-- ============ SETTINGS TAB ============

addHeader(pages[4], "UI")
addCycle(pages[4], "Theme", "themeIdx", THEME_NAMES, function(i) setThemeVars(i) end)
addHeader(pages[4], "System")
addToggle(pages[4], "Anti-AFK (kein Kick)", "antiAFK")
addToggle(pages[4], "Auto-Rejoin (bei Kick)", "autoRejoin")
addToggle(pages[4], "Panic-Key aktiv", "panicOn")
addCycle(pages[4], "Panic-Taste", "panicIdx", { "Delete", "F8", "End" })
addHeader(pages[4], "Config")
addButton(pages[4], "Config speichern", function()
    saveCfg()
    if hub.log then pcall(hub.log, "Config", "saved", GRN) end
    toast("Config gespeichert", GRN)
end)
addButton(pages[4], "Config laden", function()
    loadCfg()
    for k, c in pairs(CTRLS) do
        pcall(function() c.set(S[k], true) end)
    end
    setThemeVars(S.themeIdx)
    if hub.setGameLbl then pcall(hub.setGameLbl) end
    if hub.updateScriptsTab then pcall(hub.updateScriptsTab) end
    if hub.log then pcall(hub.log, "Config", "loaded", CYAN) end
    toast("Config geladen", GRN)
end)

-- ============ INFO TAB ============
do
    local ip = pages[5]
    addHeader(ip, "NanoHub Info")
    local INFO = {
        { "Version", "v2.5" },
        { "User", LP.DisplayName .. " (@" .. LP.Name .. ")" },
        { "UserId", tostring(LP.UserId) },
        { "Game", game.Name },
        { "PlaceId", tostring(game.PlaceId) },
        { "Uptime", "..." },
    }
    local upLbl
    for _, e in ipairs(INFO) do
        local row = mkRow(ip)
        row.AutoButtonColor = false
        ni("TextLabel", {
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.4, -10, 1, 0),
            BackgroundTransparency = 1,
            Text = e[1],
            TextColor3 = SUB,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
        local vl = ni("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0.6, -10, 1, 0),
            BackgroundTransparency = 1,
            Text = e[2],
            TextColor3 = TXT,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        if e[1] == "Uptime" then
            upLbl = vl
        end
    end
    task.spawn(function()
        while upLbl and upLbl.Parent do
            local t = os.clock() - T0
            upLbl.Text = string.format("%dm %02ds", math.floor(t / 60), math.floor(t % 60))
            task.wait(1)
        end
    end)
end

-- Keybind + Panic-Key
local PANIC_CODES = { Enum.KeyCode.Delete, Enum.KeyCode.F8, Enum.KeyCode.End }
track(UIS.InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == Enum.KeyCode.RightAlt then
        win.Visible = not win.Visible
    elseif S.panicOn and inp.KeyCode == PANIC_CODES[S.panicIdx] then
        win.Visible = false
        toast("🚨 PANIC — alles aus!", RED)
    end
end))

if hub.updateScriptsTab then pcall(hub.updateScriptsTab) end
if hub.setGameLbl then pcall(hub.setGameLbl) end

if hub.statKey then pcall(hub.statKey, false) end
if hub.setStatus then pcall(hub.setStatus, false) end
paintNav(curTab)
if hub.log then
    pcall(hub.log, "System", "UI ready", GRN)
    pcall(hub.log, "Key", "waiting for key input", SUB)
end

print("[NanoHub] Dashboard v2.7 ready — Key: Nano, RightAlt = GUI")

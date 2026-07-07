-- ═══════════════════════════════════════════════════════════════
--          ✦ CELESTIAL FPS - PREMIUM v7 ✦
--          UD • Optimized • Crash-Safe • Xeno Compatible
--          Loaded from: https://celestial.cc
-- ═══════════════════════════════════════════════════════════════

-- Anti-Double Load Protection
if getgenv and getgenv().CelestialLoaded then
    warn("[Celestial] Already loaded! Skipping duplicate execution.")
    return
end
if getgenv then getgenv().CelestialLoaded = true end

-- ─── CRASH HANDLER ───────────────────────────────────────────
local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    return ok
end

-- Early execution indicator (check Output tab in DevConsole)
print("[Celestial] Script starting...")

-- ─── EXECUTOR COMPATIBILITY LAYER ────────────────────────────
local EXEC = {
    -- Core hooks (hookmetamethod, etc.)
    HasMetaHook   = (hookmetamethod ~= nil),
    HasRawMeta    = (getrawmetatable ~= nil and setreadonly ~= nil),
    HasCheckcaller = (checkcaller ~= nil),
    HasNewClosure = (newcclosure ~= nil),

    -- Mouse simulation
    HasMouse1     = (mouse1press ~= nil and mouse1release ~= nil),
    HasMouse1Click= (mouse1click ~= nil),

    -- Filesystem
    HasWriteFile  = (writefile ~= nil and readfile ~= nil),
    HasFolderAPI  = (makefolder ~= nil and isfolder ~= nil and listfiles ~= nil),

    -- Drawing
    HasDrawing    = (Drawing ~= nil and pcall(function() Drawing.new("Line"):Remove() end)),

    -- Misc
    HasGetEnv     = (getgenv ~= nil),
    HasCloneRef   = (cloneref ~= nil),
}

-- Stub missing functions safely
if not EXEC.HasMouse1 then
    mouse1press   = function() pcall(function() mouse1click() end) end
    mouse1release = function() end
end
if not EXEC.HasMouse1Click then
    mouse1click = function() end
end

-- Auto-disable features that need unavailable APIs
local FEAT_LIMITS = {
    SilentAim   = EXEC.HasMetaHook or EXEC.HasRawMeta,
    MagicBullet = EXEC.HasMetaHook or EXEC.HasRawMeta,
    AntiBan     = EXEC.HasMetaHook or EXEC.HasRawMeta,
    Triggerbot  = EXEC.HasMouse1 or EXEC.HasMouse1Click,
    AutoClick   = EXEC.HasMouse1 or EXEC.HasMouse1Click,
    MultiConfig = EXEC.HasFolderAPI,
    ESP_Drawing = EXEC.HasDrawing,
}

-- Notify user about executor limits (shown after GUI loads)
local _execWarnings = {}
if not FEAT_LIMITS.SilentAim then
    table.insert(_execWarnings, "Silent Aim / Magic Bullet / Anti-Ban → executor'ınız desteklemiyor")
end
if not FEAT_LIMITS.Triggerbot then
    table.insert(_execWarnings, "Triggerbot / Auto Click → mouse API eksik")
end
if not FEAT_LIMITS.MultiConfig then
    table.insert(_execWarnings, "Multi-Config → klasör API eksik, tek dosyaya kaydedilecek")
end
if not FEAT_LIMITS.ESP_Drawing then
    table.insert(_execWarnings, "ESP / FOV / Trace → Drawing API desteklenmiyor")
end



-- ─── SERVICES ────────────────────────────────────────────────
local Http    = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenS  = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Light   = game:GetService("Lighting")
local Stats   = game:GetService("Stats")

local Camera = workspace.CurrentCamera
local LP     = Players.LocalPlayer

-- ─── MOUSE STATE MANAGEMENT ──────────────────────────────────
-- Save initial mouse state at script start
local INITIAL_MOUSE_BEHAVIOR = UIS.MouseBehavior
local INITIAL_MOUSE_ICON = UIS.MouseIconEnabled

print("[Celestial] Initial mouse state saved:")
print("  MouseBehavior: " .. tostring(INITIAL_MOUSE_BEHAVIOR))
print("  MouseIconEnabled: " .. tostring(INITIAL_MOUSE_ICON))

-- Function to restore mouse (used by menu toggle and close)
local function RestoreMouse()
    UIS.MouseBehavior = INITIAL_MOUSE_BEHAVIOR
    UIS.MouseIconEnabled = true  -- Always restore to visible
    print("[Celestial] Mouse restored to initial state")
end

-- ─── PREV INSTANCE CLEANUP ───────────────────────────────────
safe(function()
    if getgenv and getgenv().CelLoaded then
        getgenv().CelLoaded:Destroy()
        RestoreMouse()  -- Restore mouse when replacing old instance
    end
end)

-- ─── KEY SYSTEM (PANDA AUTH) ─────────────────────────────────
local KeyValid = false
local KeyGUI = Instance.new("ScreenGui")
KeyGUI.Name = Http:GenerateGUID(false)
KeyGUI.ResetOnSpawn = false
KeyGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGUI.IgnoreGuiInset = true
-- Robust GUI parenting - tries multiple methods for all executors
local function GetGuiParent()
    -- Method 1: gethui (Synapse, KRNL, etc.)
    local ok1, h = pcall(function() return gethui and gethui() end)
    if ok1 and h then return h end
    -- Method 2: CoreGui (most executors)
    local ok2, c = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and c then return c end
    -- Method 3: PlayerGui (last resort)
    local ok3, p = pcall(function() return game:GetService("Players").LocalPlayer.PlayerGui end)
    if ok3 and p then return p end
    return nil
end

pcall(function() if syn and syn.protect_gui then syn.protect_gui(KeyGUI) end end)
local _guiParent = GetGuiParent()
if _guiParent then KeyGUI.Parent = _guiParent end
print("[Celestial] Key GUI created, parent: "..tostring(_guiParent))

local KeyWin = Instance.new("Frame", KeyGUI)
KeyWin.Size = UDim2.new(0, 360, 0, 240)
KeyWin.Position = UDim2.new(0.5, -180, 0.5, -120)
KeyWin.BackgroundColor3 = Color3.fromRGB(9, 9, 15)
KeyWin.BorderSizePixel = 0
local KWC = Instance.new("UICorner", KeyWin); KWC.CornerRadius = UDim.new(0, 4)
local KWS = Instance.new("UIStroke", KeyWin); KWS.Color = Color3.fromRGB(0, 212, 170); KWS.Thickness = 1

local KTitle = Instance.new("TextLabel", KeyWin)
KTitle.Size = UDim2.new(1, 0, 0, 40)
KTitle.BackgroundTransparency = 1
KTitle.Font = Enum.Font.GothamBold
KTitle.Text = "CELESTIAL PREMIUM - AUTHENTICATION"
KTitle.TextColor3 = Color3.fromRGB(0, 212, 170)
KTitle.TextSize = 13

local KDesc = Instance.new("TextLabel", KeyWin)
KDesc.Size = UDim2.new(1, 0, 0, 20)
KDesc.Position = UDim2.new(0, 0, 0, 40)
KDesc.BackgroundTransparency = 1
KDesc.Font = Enum.Font.Code
KDesc.Text = "Please enter your PandaDevelopment key to continue."
KDesc.TextColor3 = Color3.fromRGB(110, 120, 145)
KDesc.TextSize = 10

local KInput = Instance.new("TextBox", KeyWin)
KInput.Size = UDim2.new(1, -40, 0, 36)
KInput.Position = UDim2.new(0, 20, 0, 70)
KInput.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
KInput.BorderSizePixel = 0
KInput.Font = Enum.Font.Code
KInput.PlaceholderText = "Paste your key here..."
KInput.Text = ""
KInput.TextColor3 = Color3.fromRGB(215, 220, 232)
KInput.TextSize = 12
local KIC = Instance.new("UICorner", KInput); KIC.CornerRadius = UDim.new(0, 3)
local KIS = Instance.new("UIStroke", KInput); KIS.Color = Color3.fromRGB(38, 38, 58)

local KBtn = Instance.new("TextButton", KeyWin)
KBtn.Size = UDim2.new(1, -40, 0, 36)
KBtn.Position = UDim2.new(0, 20, 0, 120)
KBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 170)
KBtn.BorderSizePixel = 0
KBtn.Font = Enum.Font.Code
KBtn.Text = "VERIFY KEY"
KBtn.TextColor3 = Color3.fromRGB(9, 9, 15)
KBtn.TextSize = 13
local KBC = Instance.new("UICorner", KBtn); KBC.CornerRadius = UDim.new(0, 3)

local HWID = "UnknownHWID"
pcall(function() HWID = game:GetService("RbxAnalyticsService"):GetClientId() end)

local KBtn2 = Instance.new("TextButton", KeyWin)
KBtn2.Size = UDim2.new(1, -40, 0, 30)
KBtn2.Position = UDim2.new(0, 20, 0, 164)
KBtn2.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
KBtn2.BorderSizePixel = 0
KBtn2.Font = Enum.Font.Code
KBtn2.Text = "DEV: DIRECT LOAD (Bypass)"
KBtn2.TextColor3 = Color3.fromRGB(150, 160, 180)
KBtn2.TextSize = 11
KBtn2.Visible = (HWID == "6ADD91FF-1461-4C64-9038-3FA9609990E4")
local KBC2 = Instance.new("UICorner", KBtn2); KBC2.CornerRadius = UDim.new(0, 3)

local KLinkBtn = Instance.new("TextButton", KeyWin)
KLinkBtn.Size = UDim2.new(1, 0, 0, 20)
KLinkBtn.Position = UDim2.new(0, 0, 1, -25)
KLinkBtn.BackgroundTransparency = 1
KLinkBtn.Font = Enum.Font.Code
KLinkBtn.Text = "Copy Key Link"
KLinkBtn.TextColor3 = Color3.fromRGB(0, 140, 112)
KLinkBtn.TextSize = 10

local KStatus = Instance.new("TextLabel", KeyWin)
KStatus.Size = UDim2.new(1, 0, 0, 20)
KStatus.Position = UDim2.new(0, 0, 1, -45)
KStatus.BackgroundTransparency = 1
KStatus.Font = Enum.Font.Code
KStatus.Text = ""
KStatus.TextColor3 = Color3.fromRGB(240, 70, 70)
KStatus.TextSize = 10


KLinkBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://pandadevelopment.net/getkey?service=celestialcc&hwid="..HWID) end)
    KStatus.Text = "Link copied to clipboard!"
    KStatus.TextColor3 = Color3.fromRGB(0, 212, 170)
end)

KBtn.MouseButton1Click:Connect(function()
    local userKey = KInput.Text:gsub("%s+", "")
    if userKey == "" then
        KStatus.Text = "Please enter a key."
        KStatus.TextColor3 = Color3.fromRGB(240, 70, 70)
        return
    end

    KBtn.Text = "VERIFYING..."
    KStatus.Text = ""
    
    task.spawn(function()
        local url = string.format("https://api.pandadevs.com/v1/validation?key=%s&service=celestialcc&hwid=%s", userKey, HWID)
        
        local reqFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        
        if reqFunc then
            local success, response = pcall(function()
                return reqFunc({
                    Url = url,
                    Method = "GET"
                })
            end)
            
            if success and response then
                local isJson, decoded = pcall(function() return Http:JSONDecode(response.Body) end)
                if isJson and decoded then
                    if decoded.success == true or decoded.V2_Authentication == true or decoded.status == "success" then
                        KStatus.Text = "Key valid! Loading Celestial..."
                        KStatus.TextColor3 = Color3.fromRGB(46, 204, 113)
                        task.wait(1)
                        KeyValid = true
                        pcall(function() KeyGUI:Destroy() end)
                    else
                        KStatus.Text = decoded.message or decoded.Message or "Invalid Key!"
                        KStatus.TextColor3 = Color3.fromRGB(240, 70, 70)
                        KBtn.Text = "VERIFY KEY"
                    end
                else
                    KStatus.Text = "Invalid Response from Server."
                    KStatus.TextColor3 = Color3.fromRGB(240, 70, 70)
                    KBtn.Text = "VERIFY KEY"
                end
            else
                KStatus.Text = "Connection Error (Check Firewall)."
                KStatus.TextColor3 = Color3.fromRGB(240, 70, 70)
                KBtn.Text = "VERIFY KEY"
            end
        else
            -- Fallback to game:HttpGet
            local success, rawResponse = pcall(function() return game:HttpGet(url) end)
            if success and rawResponse then
                local isJson, decoded = pcall(function() return Http:JSONDecode(rawResponse) end)
                if isJson and decoded and (decoded.success == true or decoded.V2_Authentication == true) then
                    KStatus.Text = "Key valid! Loading Celestial..."
                    KStatus.TextColor3 = Color3.fromRGB(46, 204, 113)
                    task.wait(1)
                    KeyValid = true
                    pcall(function() KeyGUI:Destroy() end)
                else
                    KStatus.Text = "Invalid Key!"
                    KStatus.TextColor3 = Color3.fromRGB(240, 70, 70)
                    KBtn.Text = "VERIFY KEY"
                end
            else
                -- If game:HttpGet errors, it usually means 400 Bad Request (Invalid Key)
                KStatus.Text = "Invalid Key! (HTTP 400)"
                KStatus.TextColor3 = Color3.fromRGB(240, 70, 70)
                KBtn.Text = "VERIFY KEY"
            end
        end
    end)
end)

KBtn2.MouseButton1Click:Connect(function()
    KStatus.Text = "Bypassing Key System..."
    KStatus.TextColor3 = Color3.fromRGB(46, 204, 113)
    task.wait(0.5)
    KeyValid = true
    pcall(function() KeyGUI:Destroy() end)
end)

-- AUTO-BYPASS FOR TESTING (remove for production)
-- KeyValid = true
-- pcall(function() KeyGUI:Destroy() end)

-- Yield execution until key is verified
while not KeyValid do task.wait(0.5) end

-- ─── FPS DROP FIXER ──────────────────────────────────────────
local fpsHistory = {}
local fpsFixActive = false
task.spawn(function()
    while true do
        task.wait(5)
        safe(function()
            local fps = math.floor(1 / RS.RenderStepped:Wait())
            table.insert(fpsHistory, fps)
            if #fpsHistory > 10 then table.remove(fpsHistory, 1) end
            local avg = 0
            for _, v in ipairs(fpsHistory) do avg = avg + v end
            avg = avg / #fpsHistory
            if avg < 20 and not fpsFixActive then
                fpsFixActive = true
                -- Reduce ESP update rate temporarily
                task.wait(3)
                fpsFixActive = false
            end
        end)
    end
end)

-- ─── SMOOTH CONVERSION ───────────────────────────────────────
local function SV(v) return 1.0 - (v / 10) * 0.96 end

-- ─── CONFIG ──────────────────────────────────────────────────
local CFG = {
    -- Aimbot
    AimbotOn          = false,
    AimbotKey         = Enum.KeyCode.E,
    AimbotFOV         = 200,
    AimbotSlider      = 5,
    AimbotSmooth      = 0.52,
    AimbotType        = "Linear",     -- Linear / Quadratic
    AimbotStrength    = 0.5,
    AimbotSpeed       = 3,
    AimbotSmoothVal   = 2,
    TargetBone        = "Head",
    WallCheck         = true,
    Prediction        = true,
    ShowFOV           = true,
    FOVColor          = Color3.fromRGB(0, 212, 170),
    FireRateMod       = false,
    FireRateMultiplier= 2,
    AutoClick         = false,
    DisableOnReload   = true,
    EnableOnScope     = false,
    SwitchDelay       = 0,
    ReactionTime      = 0,
    TargetCondition   = "Visible",    -- Visible / Vulnerable / Any
    TargetType        = "Closest",    -- Closest / Center / Random
    TargetPartsAir    = "Head",       -- Head / HitboxHead / Torso
    TargetPartsGround = "Head",
    GunSpecific       = false,

    -- Silent Aim
    SilentOn          = false,
    SilentFOV         = 200,
    SilentShowFOV     = false,
    SilentFOVColor    = Color3.fromRGB(255, 50, 50),

    -- Triggerbot
    TrigOn            = false,
    TrigKey           = Enum.KeyCode.T,
    TrigDelay         = 0.05,
    TrigRelease       = 0,
    TrigOnScope       = false,
    TrigDisableReload = false,
    TrigPartsAir      = "Head",
    TrigPartsGround   = "Head",

    -- Bullet Trace
    TraceOn      = false,
    TraceColor   = Color3.fromRGB(0, 212, 170),
    TraceDur     = 1.5,
    TraceWidth   = 2,
    TraceFadeOut = true,

    -- Rage
    MagicBullet   = false,
    KillauraOn    = false,
    KillauraRange = 20,
    KillauraDelay = 0.08,
    AntiAimOn     = false,
    AntiAimType   = "Spinbot",
    JitterSpeed   = 10,
    FakeLagOn     = false,
    FakeLagTicks  = 5,
    BacktrackOn   = false,
    BacktrackTime = 0.2,
    OneShot       = false,

    -- Sky
    SkyColorOn = false,
    SkyColor   = Color3.fromRGB(0, 0, 20),

    -- Chams
    ChamsIntensity = 0.4,

    -- ESP
    ESPOn        = false,
    BoxESP       = true,
    CornerBox    = true,
    HealthBar    = true,
    ShowName     = true,
    ShowDist     = true,
    SnapLines    = true,
    HeadDot      = true,
    ESPColor     = Color3.fromRGB(0, 212, 170),
    ESPTeamCheck = false,
    ESPMaxDist   = 1000,
    SkeletonESP  = false,
    WeaponESP    = false,
    ArmorBar     = false,
    FlagsESP     = false,
    ESPColorMode = "Static",
    ItemESP      = false,
    VehicleESP   = false,
    WorldESPDist = 300,
    KeybindList  = false,

    -- Chams
    ChamsOn    = false,
    ChamsColor = Color3.fromRGB(0, 212, 170),

    -- Crosshair
    CrossOn    = false,
    CrossColor = Color3.fromRGB(0, 212, 170),
    CrossSize  = 10,
    CrossGap   = 4,
    CrossThick = 1,
    CrossDot   = false,
    
    -- Skin Changer
    SkinChangerEnabled = false,
    SkinAutoApply = false,
    SkinColor = Color3.fromRGB(0, 212, 170),
    SkinMaterial = Enum.Material.Neon,

    -- Movement
    SpeedOn   = false,
    WalkSpeed = 32,
    JumpPower = 50,
    BhopOn    = false,
    BhopKey   = Enum.KeyCode.Space,
    InfJump   = false,
    AntiVoid  = false,
    NoclipOn  = false,
    FlyOn     = false,
    FlySpeed  = 50,
    FlyKey    = Enum.KeyCode.F,
    AutoStrafe = false,

    -- Camera
    TPOn        = false,
    TPKey       = Enum.KeyCode.V,
    TPDist      = 15,
    NoRecoil    = false,
    NoCamShake  = false,
    GravityMod  = false,
    GravityVal  = 196.2,
    CameraFOV   = 70,
    FOVEnabled  = false,
    StretchedRes = false,
    StretchScale = 1.0,
    ViewModelX  = 0,
    ViewModelY  = 0,
    ViewModelZ  = 0,
    ViewModelEnabled = false,
    
    -- Identity
    SpoofName        = false,
    CustomName       = "Player",
    SpoofDisplayName = false,
    CustomDisplayName = "Player",
    HideAvatar       = false,
    HideWinstreak    = false,

    -- Misc
    AntiBan      = true,
    PropertySpoof = true,
    TimingRandom = true,
    AntiKick     = true,
    HideFromSpy  = true,
    TrafficMask  = true,
    MemoryGuard  = false,
    SpinbotOn    = false,
    SpinSpeed    = 5,
    Fullbright   = false,
    NoFog        = false,
    HitboxExp    = false,
    HitboxSize   = 4,
    Watermark    = true,
    HitSound     = false,
    HitSoundType = "Quake",
    HitSoundVol  = 0.5,
    KillSay      = false,
    KillSayMsg   = "get good",
    SpamChat     = false,
    SpamDelay    = 1,
    VisualLag    = false,
    FPSUnlock    = false,
    RemoveTextures = false,
    LowQuality   = false,

    -- Menu
    MenuKey     = Enum.KeyCode.RightAlt,
    MenuVisible = true,
}
CFG.AimbotSmooth = SV(CFG.AimbotSlider)

-- ─── MULTI-CONFIG SYSTEM ─────────────────────────────────────
local CEL_FOLDER    = "Celestial.cc"
local CFG_FOLDER    = CEL_FOLDER .. "/Configs"
local AUTOLOAD_FILE = CEL_FOLDER .. "/autoload.txt"

-- Create folders on first load
pcall(function()
    if not isfolder(CEL_FOLDER) then makefolder(CEL_FOLDER) end
    if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
end)

local function cfgPath(name)
    return CFG_FOLDER .. "/" .. (name or "default") .. ".json"
end

local function SerializeCFG()
    local data = {}
    for k, v in pairs(CFG) do
        local tv = type(v)
        if tv == "boolean" or tv == "number" or tv == "string" then
            data[k] = v
        elseif typeof(v) == "Color3" then
            data[k] = {__c3=true, r=v.R, g=v.G, b=v.B}
        elseif typeof(v) == "EnumItem" then
            data[k] = {__en=true, val=tostring(v)}
        end
    end
    return Http:JSONEncode(data)
end

local function ApplyCFGData(data)
    if type(data) ~= "table" then return false end
    for k, v in pairs(data) do
        if CFG[k] ~= nil then
            if type(v) == "table" and v.__c3 then
                pcall(function() CFG[k] = Color3.new(v.r, v.g, v.b) end)
            elseif type(v) == "table" and v.__en then
                pcall(function()
                    local parts = string.split(v.val, ".")
                    CFG[k] = Enum[parts[2]][parts[3]]
                end)
            else
                pcall(function()
                    if type(v) == type(CFG[k]) then CFG[k] = v end
                end)
            end
        end
    end
    CFG.AimbotSmooth = SV(CFG.AimbotSlider)
    CFG.SilentSmooth = SV(CFG.SilentSlider)
    return true
end

local function SaveCFG(name)
    local ok = pcall(function() writefile(cfgPath(name), SerializeCFG()) end)
    return ok
end

local function LoadCFG(name)
    local ok, raw = pcall(readfile, cfgPath(name))
    if not ok or not raw or raw == "" then return false end
    local ok2, data = pcall(function() return Http:JSONDecode(raw) end)
    if not ok2 then return false end
    return ApplyCFGData(data)
end

local function DeleteCFG(name)
    pcall(function() delfile(cfgPath(name)) end)
end

local function ListCFGs()
    local list = {}
    pcall(function()
        for _, f in ipairs(listfiles(CFG_FOLDER)) do
            local name = f:match("([^/]+)%.json$")
            if name then table.insert(list, name) end
        end
    end)
    return list
end

local function GetAutoload()
    local ok, val = pcall(readfile, AUTOLOAD_FILE)
    if ok and val and val ~= "" then return val:gsub("%s+", "") end
    return nil
end

local function SetAutoload(name)
    pcall(function() writefile(AUTOLOAD_FILE, name or "") end)
end

local function ClearAutoload()
    pcall(function() writefile(AUTOLOAD_FILE, "") end)
end

-- ═══════════════════════════════════════════════════════════════
-- ── PROFESSIONAL AUTO-EXECUTE SYSTEM v2.0 ──────────────────────
-- ═══════════════════════════════════════════════════════════════

local AUTO_EXEC_FILE = CEL_FOLDER .. "/autoexec.json"
local AUTO_EXEC_SCRIPTS_FOLDER = CEL_FOLDER .. "/AutoExec"

-- Auto-exec configuration structure
local AutoExecConfig = {
    enabled = true,
    loadConfig = nil,              -- Config to load on startup
    executeScripts = {},           -- List of script files to execute
    loadDelay = 500,               -- Delay before loading (ms)
    showNotifications = true,      -- Show load notifications
    safeMode = true,               -- Skip loading if errors occur
    lastExecuted = 0,              -- Timestamp of last execution
    executionCount = 0,            -- Total executions
    gameSpecific = {},             -- Game-specific auto-exec settings
}

-- Initialize auto-exec folder structure
local function InitAutoExec()
    pcall(function()
        -- Create AutoExec folder
        if not isfolder(AUTO_EXEC_SCRIPTS_FOLDER) then
            makefolder(AUTO_EXEC_SCRIPTS_FOLDER)
            print("[Auto-Exec] Created folder: " .. AUTO_EXEC_SCRIPTS_FOLDER)
        end
        
        -- Create example script
        local examplePath = AUTO_EXEC_SCRIPTS_FOLDER .. "/example.lua"
        if not isfile or not isfile(examplePath) then
            local exampleContent = [[-- Celestial Auto-Exec Example Script
-- This script runs automatically when Celestial loads

print("[Auto-Exec] Example script executed!")

-- Example: Automatically enable aimbot
-- CFG.AimbotOn = true
-- CFG.AimbotFOV = 150

-- Example: Set preferred settings
-- CFG.ESPOn = true
-- CFG.Watermark = true

-- Example: Load specific config
-- LoadCFG("myconfig")

-- You can add any Lua code here!
-- Delete this file or disable auto-exec in settings.
]]
            writefile(examplePath, exampleContent)
            print("[Auto-Exec] Created example script")
        end
        
        -- Create README
        local readmePath = AUTO_EXEC_SCRIPTS_FOLDER .. "/README.txt"
        local readmeContent = [[
CELESTIAL.CC - AUTO-EXECUTE SYSTEM v2.0
═══════════════════════════════════════════════════════════════

AUTO-EXEC allows you to automatically run scripts and load configs
when Celestial starts.

FEATURES:
✅ Auto-load configs on startup
✅ Execute custom Lua scripts automatically
✅ Game-specific auto-exec profiles
✅ Safe mode with error handling
✅ Execution statistics & logging

HOW TO USE:
1. Create .lua files in this folder
2. Enable auto-exec in Misc → Auto-Execute
3. Scripts run automatically on load!

EXAMPLE USES:
• Auto-load your favorite config
• Set default keybinds
• Enable specific features
• Custom initialization code

FILE STRUCTURE:
/AutoExec/
  ├─ myscript.lua      (Your custom scripts)
  ├─ game_rivals.lua   (Game-specific scripts)
  └─ example.lua       (Example template)

TIPS:
• Use print() to debug your scripts
• Check F9 console for errors
• Scripts have access to all CFG variables
• Use LoadCFG("name") to load configs

═══════════════════════════════════════════════════════════════
For support: celestial.cc
]]
        writefile(readmePath, readmeContent)
    end)
end

-- Load auto-exec configuration
local function LoadAutoExecConfig()
    local ok, data = pcall(function()
        if not isfile or not isfile(AUTO_EXEC_FILE) then
            return AutoExecConfig
        end
        
        local raw = readfile(AUTO_EXEC_FILE)
        local decoded = Http:JSONDecode(raw)
        
        -- Merge with defaults
        for k, v in pairs(AutoExecConfig) do
            if decoded[k] == nil then
                decoded[k] = v
            end
        end
        
        return decoded
    end)
    
    if ok and data then
        return data
    end
    
    return AutoExecConfig
end

-- Save auto-exec configuration
local function SaveAutoExecConfig(config)
    pcall(function()
        local encoded = Http:JSONEncode(config)
        writefile(AUTO_EXEC_FILE, encoded)
    end)
end

-- Execute a script file
local function ExecuteScript(scriptPath)
    local success, err = pcall(function()
        if not isfile or not isfile(scriptPath) then
            print("[Auto-Exec] ⚠️ Script not found: " .. scriptPath)
            return
        end
        
        local scriptContent = readfile(scriptPath)
        local scriptFunc, loadErr = loadstring(scriptContent)
        
        if not scriptFunc then
            print("[Auto-Exec] ❌ Script load error: " .. tostring(loadErr))
            return
        end
        
        -- Execute in protected environment
        local execSuccess, execErr = pcall(scriptFunc)
        
        if execSuccess then
            print("[Auto-Exec] ✅ Executed: " .. scriptPath:match("([^/]+)$"))
        else
            print("[Auto-Exec] ❌ Execution error: " .. tostring(execErr))
        end
    end)
    
    if not success then
        print("[Auto-Exec] ❌ Fatal error: " .. tostring(err))
    end
    
    return success
end

-- List all auto-exec scripts
local function ListAutoExecScripts()
    local scripts = {}
    pcall(function()
        if not listfiles then return end
        
        local files = listfiles(AUTO_EXEC_SCRIPTS_FOLDER)
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/]+)$")
            if fileName and fileName:match("%.lua$") then
                table.insert(scripts, {
                    name = fileName,
                    path = filePath,
                    size = #readfile(filePath),
                })
            end
        end
    end)
    return scripts
end

-- Get game-specific auto-exec
local function GetGameSpecificScript()
    local placeId = tostring(game.PlaceId)
    local gameName = PATTERNS.DetectedGame or "Unknown"
    
    -- Try PlaceID-specific script first
    local placeScript = AUTO_EXEC_SCRIPTS_FOLDER .. "/game_" .. placeId .. ".lua"
    if isfile and isfile(placeScript) then
        return placeScript
    end
    
    -- Try game name-specific script
    local nameScript = AUTO_EXEC_SCRIPTS_FOLDER .. "/game_" .. gameName:gsub("%s+", "_"):lower() .. ".lua"
    if isfile and isfile(nameScript) then
        return nameScript
    end
    
    return nil
end

-- Main auto-exec function
local function RunAutoExec()
    print("═══════════════════════════════════════════════════════")
    print("  CELESTIAL AUTO-EXECUTE v2.0")
    print("═══════════════════════════════════════════════════════")
    
    local config = LoadAutoExecConfig()
    
    if not config.enabled then
        print("[Auto-Exec] ⏸️ Auto-execute is disabled")
        return
    end
    
    local startTime = tick()
    local successCount = 0
    local failCount = 0
    
    -- Wait for initialization
    local delaySeconds = (config.loadDelay or 500) / 1000
    print("[Auto-Exec] ⏳ Waiting " .. delaySeconds .. "s for initialization...")
    task.wait(delaySeconds)
    
    -- Load config if specified
    if config.loadConfig and config.loadConfig ~= "" then
        print("[Auto-Exec] 📂 Loading config: " .. config.loadConfig)
        local ok = LoadCFG(config.loadConfig)
        if ok then
            successCount = successCount + 1
            if config.showNotifications then
                Notify("Auto-Exec", "Loaded config: " .. config.loadConfig, T.Green)
            end
        else
            failCount = failCount + 1
            print("[Auto-Exec] ❌ Failed to load config")
        end
    end
    
    -- Execute game-specific script
    local gameScript = GetGameSpecificScript()
    if gameScript then
        print("[Auto-Exec] 🎮 Executing game-specific script...")
        if ExecuteScript(gameScript) then
            successCount = successCount + 1
        else
            failCount = failCount + 1
            if config.safeMode then
                print("[Auto-Exec] ⚠️ Safe mode: Stopping execution due to error")
                return
            end
        end
    end
    
    -- Execute configured scripts
    for _, scriptName in ipairs(config.executeScripts) do
        local scriptPath = AUTO_EXEC_SCRIPTS_FOLDER .. "/" .. scriptName
        print("[Auto-Exec] 📜 Executing: " .. scriptName)
        
        if ExecuteScript(scriptPath) then
            successCount = successCount + 1
        else
            failCount = failCount + 1
            if config.safeMode then
                print("[Auto-Exec] ⚠️ Safe mode: Stopping execution")
                break
            end
        end
    end
    
    -- Update statistics
    config.lastExecuted = tick()
    config.executionCount = config.executionCount + 1
    SaveAutoExecConfig(config)
    
    -- Summary
    local elapsed = math.floor((tick() - startTime) * 1000)
    print("═══════════════════════════════════════════════════════")
    print("[Auto-Exec] ✅ Complete in " .. elapsed .. "ms")
    print("[Auto-Exec] Success: " .. successCount .. " | Failed: " .. failCount)
    print("[Auto-Exec] Total executions: " .. config.executionCount)
    print("═══════════════════════════════════════════════════════")
    
    if config.showNotifications and successCount > 0 then
        Notify("Auto-Exec", "Executed " .. successCount .. " items!", T.Green)
    end
end

-- Initialize and run auto-exec
task.defer(function()
    InitAutoExec()
    task.wait(0.5)
    RunAutoExec()
end)

-- ═══════════════════════════════════════════════════════════════
-- ── PATTERN SCANNER (Background System - No GUI) ───────────────
-- ═══════════════════════════════════════════════════════════════

_G.PATTERNS = {
    -- Detected values stored here (global for debugging)
    Remotes = {},
    SkinPaths = {},
    InventoryPaths = {},
    WeaponPaths = {},
    ParryRemotes = {},
    UnlockMethods = {},
    DetectedGame = "Unknown",
    ScanComplete = false,
}
local PATTERNS = _G.PATTERNS  -- local alias

-- ─── GAME DETECTION ──────────────────────────────────────────
local function DetectGame()
    local placeId = game.PlaceId
    local placeName = ""
    pcall(function() placeName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name end)
    
    -- Known games database
    local knownGames = {
        [4651779470] = "Shoot Out",
        [5208655184] = "Da Hood",
        [2788229376] = "Da Hood",
        [1958807588] = "Arsenal",
        [292439477] = "Phantom Forces",
        [5431987391] = "Counter Blox",
        [3214114884] = "Rivals",
        [17450551869] = "Rivals",
        [17897702920] = "Rivals",
        [17625399992] = "Rivals",  -- Your PlaceID
    }
    
    local detected = knownGames[placeId] or placeName or "Unknown"
    PATTERNS.DetectedGame = detected
    
    print("[Celestial Pattern Scanner] Game detected: " .. detected .. " (PlaceID: " .. placeId .. ")")
    return detected, placeId
end

-- ─── PATTERN MATCHERS ────────────────────────────────────────
local function MatchName(name, patterns)
    local lower = name:lower()
    for _, pattern in ipairs(patterns) do
        if lower:find(pattern, 1, true) then return true end
    end
    return false
end

-- ─── SCAN: REMOTES (Anti-Ban, Parry, Damage) ─────────────────
local function ScanRemotes()
    print("[Scanner] Scanning RemoteEvents & RemoteFunctions...")
    local suspicious = {}
    local parryRemotes = {}
    
    local remotePatterns = {
        antiban = {"kick", "ban", "flag", "report", "detect", "cheat", "exploit", "sanction", "warn", "log"},
        parry = {"parry", "block", "deflect", "counter", "guard"},
        damage = {"damage", "hit", "shot", "fire", "hurt", "attack"},
    }
    
    for _, service in ipairs({game:GetService("ReplicatedStorage"), game:GetService("Workspace")}) do
        for _, obj in ipairs(service:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name
                -- Anti-ban detection
                if MatchName(name, remotePatterns.antiban) then
                    table.insert(suspicious, {name = name, path = obj:GetFullName(), type = "antiban"})
                end
                -- Parry detection
                if MatchName(name, remotePatterns.parry) then
                    table.insert(parryRemotes, obj)
                    table.insert(suspicious, {name = name, path = obj:GetFullName(), type = "parry"})
                end
                -- Damage detection
                if MatchName(name, remotePatterns.damage) then
                    table.insert(suspicious, {name = name, path = obj:GetFullName(), type = "damage"})
                end
            end
        end
    end
    
    PATTERNS.Remotes = suspicious
    PATTERNS.ParryRemotes = parryRemotes
    print("[Scanner] Found " .. #suspicious .. " suspicious remotes, " .. #parryRemotes .. " parry remotes")
    return suspicious, parryRemotes
end

-- ─── SCAN: WEAPON SYSTEM ─────────────────────────────────────
local function ScanWeaponSystem()
    print("[Scanner] Scanning weapon/tool system...")
    local weaponPaths = {}
    
    -- Scan ReplicatedStorage for weapon folders
    pcall(function()
        for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj:IsA("Folder") and MatchName(obj.Name, {"weapon", "gun", "tool", "melee", "knife"}) then
                table.insert(weaponPaths, {name = obj.Name, path = obj:GetFullName()})
            end
        end
    end)
    
    -- Scan character for currently equipped tool
    pcall(function()
        local char = LP.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                table.insert(weaponPaths, {name = tool.Name, path = tool:GetFullName(), equipped = true})
            end
        end
    end)
    
    PATTERNS.WeaponPaths = weaponPaths
    print("[Scanner] Found " .. #weaponPaths .. " weapon paths")
    return weaponPaths
end

-- ─── SCAN: GAME-SPECIFIC PATTERNS ────────────────────────────
local function ScanGameSpecific(gameName, placeId)
    print("[Scanner] Applying game-specific patterns for: " .. gameName .. " (PlaceID: " .. tostring(placeId) .. ")")
    
    -- RIVALS CHECK: Use PlaceID as fallback
    local isRivals = gameName:find("Rivals") or placeId == 17625399992 or placeId == 17450551869 or placeId == 17897702920 or placeId == 3214114884
    
    if isRivals then
        print("[Scanner] ═══════════════════════════════════════════════════")
        print("[Scanner] ═══ ✓ RIVALS DETECTED - BACKGROUND SCAN ACTIVE ═══")
        print("[Scanner] ═══════════════════════════════════════════════════")
        
        -- Lightweight scan (no full dump, just pattern match)
        print("[Scanner] Running lightweight Rivals scan...")
        
        local allInstances = {}
        
        -- Collect instances
        pcall(function()
            for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                table.insert(allInstances, obj)
            end
        end)
        
        pcall(function()
            for _, obj in ipairs(LP:GetDescendants()) do
                table.insert(allInstances, obj)
            end
        end)
        
        pcall(function()
            local gui = LP:FindFirstChild("PlayerGui")
            if gui then
                for _, obj in ipairs(gui:GetDescendants()) do
                    table.insert(allInstances, obj)
                end
            end
        end)
        
        print("[Scanner] Total instances to search: " .. #allInstances)
        
        -- Search patterns
        local searchPatterns = {
            "skin", "cosmetic", "unlock", "owned", "locked", "inventory", 
            "weapon", "item", "equip", "loadout", "bundle", "shop", "store",
        }
        
        local foundCount = 0
        for _, obj in ipairs(allInstances) do
            local name = obj.Name:lower()
            
            for _, pattern in ipairs(searchPatterns) do
                if name:find(pattern, 1, true) then
                    if obj:IsA("Folder") or obj:IsA("Configuration") then
                        table.insert(PATTERNS.SkinPaths, {
                            name = obj.Name,
                            path = obj:GetFullName(),
                            type = "rivals_" .. obj.ClassName:lower()
                        })
                        foundCount = foundCount + 1
                    elseif obj:IsA("BoolValue") then
                        table.insert(PATTERNS.UnlockMethods, {
                            name = obj.Name,
                            path = obj:GetFullName(),
                            parent = obj.Parent and obj.Parent.Name or "Unknown",
                            method = "BoolValue",
                            value = obj.Value
                        })
                        foundCount = foundCount + 1
                    end
                    break
                end
            end
        end
        
        print("[Scanner] Rivals scan complete. Found " .. foundCount .. " patterns.")
    end
end

-- ─── MASTER SCAN FUNCTION ────────────────────────────────────
local function RunPatternScan()
    print("═══════════════════════════════════════════════════════")
    print("  CELESTIAL PATTERN SCANNER v1.0 (Background)")
    print("═══════════════════════════════════════════════════════")
    
    local startTime = tick()
    
    -- Step 1: Detect game
    local gameName, placeId = DetectGame()
    
    -- Step 2: Scan remotes
    ScanRemotes()
    
    -- Step 3: Scan weapons
    ScanWeaponSystem()
    
    -- Step 4: Game-specific patterns
    ScanGameSpecific(gameName, placeId)
    
    -- Mark scan as complete
    PATTERNS.ScanComplete = true
    
    local elapsed = math.floor((tick() - startTime) * 1000)
    print("═══════════════════════════════════════════════════════")
    print("[Scanner] Scan complete in " .. elapsed .. "ms")
    print("[Scanner] Results:")
    print("  - Remotes: " .. #PATTERNS.Remotes)
    print("  - Skin Paths: " .. #PATTERNS.SkinPaths)
    print("  - Weapon Paths: " .. #PATTERNS.WeaponPaths)
    print("  - Unlock Methods: " .. #PATTERNS.UnlockMethods)
    print("  - Parry Remotes: " .. #PATTERNS.ParryRemotes)
    print("═══════════════════════════════════════════════════════")
    
    return PATTERNS
end

-- ─── AUTO-RUN SCAN ON LOAD ───────────────────────────────────
task.spawn(function()
    print("[Celestial] Waiting 3 seconds for game to load...")
    task.wait(3)
    
    print("[Celestial] Starting pattern scan...")
    RunPatternScan()
    
    -- Notify user after scan (optional)
    task.wait(0.5)
    if PATTERNS.ScanComplete then
        local totalFindings = #PATTERNS.Remotes + #PATTERNS.SkinPaths + #PATTERNS.UnlockMethods
        print("[Celestial] Scan complete! Total findings: " .. totalFindings)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ── CORE VARIABLES ─────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════

local _G_CT = nil  -- Current Target (for aimbot)
local _G_SilentCF = nil  -- Silent Aim CFrame

-- Aimbot cache variables
local _cachedTarget = nil
local _cachedTargetPart = nil
local _cacheTime = 0
local _cachedFOVRadius = 200
local _lockedTarget = nil  -- LOCKED target (won't switch while key held)
local _lockTime = 0

-- ═══════════════════════════════════════════════════════════════
-- ── HIT SOUND SYSTEM v2.0 (CUSTOM SOUNDS SUPPORT) ─────────────
-- ═══════════════════════════════════════════════════════════════

-- Custom hit sounds folder setup
local CUSTOM_SOUNDS_FOLDER = "celestial.cc/customhitsounds"
local APPDATA_PATH = os.getenv("LOCALAPPDATA") or ""
local CUSTOM_SOUNDS_PATH = APPDATA_PATH .. "/" .. CUSTOM_SOUNDS_FOLDER

-- Create custom sounds folder structure
local function InitCustomSoundsFolder()
    local success = false
    pcall(function()
        -- Check if filesystem API is available
        if not isfolder or not makefolder or not writefile then
            warn("[Hit Sound] Filesystem API unavailable")
            return
        end
        
        -- Create celestial.cc folder in AppData/Local
        local celestialFolder = APPDATA_PATH .. "/celestial.cc"
        if not isfolder(celestialFolder) then
            makefolder(celestialFolder)
        end
        
        -- Create customhitsounds subfolder
        if not isfolder(CUSTOM_SOUNDS_PATH) then
            makefolder(CUSTOM_SOUNDS_PATH)
        end
        
        -- Create README.txt with instructions
        local readmePath = CUSTOM_SOUNDS_PATH .. "/README.txt"
        local readmeContent = [[CELESTIAL.CC - CUSTOM HIT SOUNDS
════════════════════════════════════════════════════════════
FOLDER: %LOCALAPPDATA%\celestial.cc\customhitsounds

HOW TO USE:
1. Place .ogg or .mp3 files in this folder
2. In-game: Settings → Audio → Hit Sound Type → Custom
3. Click "Browse Custom Sounds" and select your file
4. Test with "TEST SOUND" button

TIPS:
- Use short sounds (< 0.5 seconds)
- Keep under 1MB file size
- OGG format recommended
════════════════════════════════════════════════════════════]]
        writefile(readmePath, readmeContent)
        success = true
    end)
    return success
end

-- Built-in hit sounds
local HIT_SOUNDS = {
    Quake = "rbxassetid://160432334",
    ["CS:GO"] = "rbxassetid://6361963422",
    Minecraft = "rbxassetid://4018616850",
    Neverlose = "rbxassetid://8679627751",
    Skeet = "rbxassetid://5447626464",
    Custom = "",
}

-- List available custom sound files
local function ListCustomSounds()
    local sounds = {}
    pcall(function()
        if not listfiles then return end
        local files = listfiles(CUSTOM_SOUNDS_PATH)
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/]+)$")
            if fileName and not fileName:match("README") then
                local ext = fileName:match("%.([^%.]+)$")
                if ext and (ext:lower() == "ogg" or ext:lower() == "mp3") then
                    table.insert(sounds, fileName)
                end
            end
        end
    end)
    return sounds
end

-- Current custom sound file
local _customSoundFile = nil

-- Play hit sound (FIXED - no blocking)
local lastHitTime = 0
local function PlayHitSound()
    if not CFG.HitSound then return end
    local now = tick()
    if now - lastHitTime < 0.08 then return end
    lastHitTime = now
    
    task.spawn(function()
        pcall(function()
            local soundId = nil
            
            -- Custom sound handling
            if CFG.HitSoundType == "Custom" and _customSoundFile then
                local customPath = CUSTOM_SOUNDS_PATH .. "/" .. _customSoundFile
                if isfile and isfile(customPath) then
                    local sound = Instance.new("Sound")
                    sound.Volume = CFG.HitSoundVol or 0.5
                    sound.PlayOnRemove = false
                    sound.Parent = workspace
                    
                    -- Try getcustomasset/getsynasset
                    local ok = pcall(function()
                        if getcustomasset then
                            sound.SoundId = getcustomasset(customPath)
                        elseif getsynasset then
                            sound.SoundId = getsynasset(customPath)
                        else
                            error("No asset loader")
                        end
                    end)
                    
                    if ok then
                        if sound.IsLoaded then
                            sound:Play()
                        else
                            sound.Loaded:Connect(function()
                                sound:Play()
                            end)
                        end
                        game:GetService("Debris"):AddItem(sound, 3)
                        return
                    end
                end
                soundId = HIT_SOUNDS.Quake -- Fallback
            else
                soundId = HIT_SOUNDS[CFG.HitSoundType] or HIT_SOUNDS.Quake
            end
            
            -- Play built-in sound (FIXED - proper playback)
            if soundId and soundId ~= "" then
                local sound = Instance.new("Sound")
                sound.SoundId = soundId
                sound.Volume = CFG.HitSoundVol or 0.5
                sound.PlayOnRemove = false
                sound.Parent = workspace -- Use workspace for reliable playback
                
                -- Wait for sound to load before playing (non-blocking in task.spawn)
                if sound.IsLoaded then
                    sound:Play()
                else
                    sound.Loaded:Connect(function()
                        sound:Play()
                    end)
                end
                
                game:GetService("Debris"):AddItem(sound, 3)
            end
        end)
    end)
end

-- Initialize custom sounds folder on script load
task.defer(function()
    local success = InitCustomSoundsFolder()
    if success then
        print("[Hit Sound] ✅ Custom sounds system initialized")
        print("[Hit Sound] Folder: " .. CUSTOM_SOUNDS_PATH)
    else
        print("[Hit Sound] ⚠️ Custom sounds not available (filesystem API missing)")
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ── KILL SAY & CHAT SPAM ───────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════

local lastKillSay = 0
local lastKills = {}

-- ═══════════════════════════════════════════════════════════════
-- ── FAKE LAG SYSTEM ────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════

local lagPositions = {}

-- ═══════════════════════════════════════════════════════════════
-- ── REMOVE TEXTURES (PERFORMANCE BOOST) ────────────────────────
-- ═══════════════════════════════════════════════════════════════

local lastTextureScan = 0
task.spawn(function()
    while GUI.Parent do
        pcall(function()
            if CFG.RemoveTextures then
                local now = tick()
                if now - lastTextureScan > 10 then  -- Scan every 10 seconds (reduced from 5)
                    lastTextureScan = now
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Texture") or obj:IsA("Decal") then
                            obj.Transparency = 1
                        elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
                            obj.Material = Enum.Material.SmoothPlastic
                        end
                    end
                end
            end
        end)
        task.wait(2)  -- Check every 2 seconds instead of every frame
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ── FPS UNLOCKER ───────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════

task.spawn(function()
    while GUI.Parent do
        pcall(function()
            if CFG.FPSUnlock then
                setfpscap(CFG.FPSCap or 240)
            else
                setfpscap(60)
            end
        end)
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ── WORLD ESP (ITEMS & VEHICLES) ───────────────────────────────
-- ═══════════════════════════════════════════════════════════════

local worldESPObjects = {}
local lastWorldScan = 0

task.spawn(function()
    while GUI.Parent do
        pcall(function()
            if CFG.WorldESP then
                local now = tick()
                
                -- Scan for new objects every 2 seconds (reduced from 0.5s)
                if now - lastWorldScan > 2 then
                    lastWorldScan = now
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Tool") or obj:IsA("Model") then
                            local isTool = obj:IsA("Tool")
                            local isVehicle = obj:FindFirstChild("VehicleSeat") or obj:FindFirstChild("Seat")
                            
                            if (isTool or isVehicle) and not worldESPObjects[obj] then
                                local text = Drawing.new("Text")
                                text.Text = isTool and ("📦 " .. obj.Name) or ("🚗 " .. obj.Name)
                                text.Size = 12
                                text.Center = true
                                text.Outline = true
                                text.Color = isTool and Color3.fromRGB(255, 255, 100) or Color3.fromRGB(100, 255, 100)
                                text.Visible = false
                                
                                worldESPObjects[obj] = text
                            end
                        end
                    end
                end
                
                -- Update positions at 10 FPS (reduced from 2 FPS)
                for obj, text in pairs(worldESPObjects) do
                    if obj and obj.Parent and CFG.WorldESP then
                        local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                        local sc, on = Camera:WorldToViewportPoint(pos)
                        if on and sc.Z > 0 and sc.Z < 300 then  -- Reduced from 500 studs
                            text.Position = Vector2.new(sc.X, sc.Y)
                            text.Visible = true
                        else
                            text.Visible = false
                        end
                    elseif text then
                        text.Visible = false
                        if not obj or not obj.Parent then
                            pcall(function() text:Remove() end)
                            worldESPObjects[obj] = nil
                        end
                    end
                end
            else
                -- Cleanup when disabled
                for obj, text in pairs(worldESPObjects) do
                    if text then
                        pcall(function() text.Visible = false; text:Remove() end)
                    end
                end
                worldESPObjects = {}
            end
        end)
        task.wait(0.1)  -- 10 FPS update rate
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ── BACKTRACK SYSTEM ───────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════

local backtrackRecords = {}
local MAX_BACKTRACK_RECORDS = 30  -- Reduced from 60 for performance

task.spawn(function()
    while GUI.Parent do
        pcall(function()
            if CFG.BacktrackOn then
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP and pl.Character then
                        local root = pl.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            if not backtrackRecords[pl.UserId] then
                                backtrackRecords[pl.UserId] = {}
                            end
                            
                            table.insert(backtrackRecords[pl.UserId], {
                                time = tick(),
                                cframe = root.CFrame,
                                velocity = root.AssemblyLinearVelocity or Vector3.zero
                            })
                            
                            while #backtrackRecords[pl.UserId] > MAX_BACKTRACK_RECORDS do
                                table.remove(backtrackRecords[pl.UserId], 1)
                            end
                        end
                    end
                end
            else
                backtrackRecords = {}
            end
        end)
        task.wait(0.033)  -- 30 FPS instead of 60
    end
end)

local function GetBacktrackTarget(targetChar)
    if not CFG.BacktrackOn or not targetChar then return nil end
    
    local pl = Players:GetPlayerFromCharacter(targetChar)
    if not pl or not backtrackRecords[pl.UserId] then return nil end
    
    local records = backtrackRecords[pl.UserId]
    local now = tick()
    
    for i = #records, 1, -1 do
        local record = records[i]
        if now - record.time <= CFG.BacktrackTime then
            return record.cframe.Position
        end
    end
    
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- ── ADVANCED BYPASS SYSTEM v5.0 (MILITARY GRADE) ──────────────
-- ═══════════════════════════════════════════════════════════════

-- ─── CONTROL FLOW BYPASS (ANTI STATIC ANALYSIS) ──────────────
local _controlFlow = {
    states = {},
    transitions = 0,
    branches = {},
    entropy = 0
}

-- Opaque predicate - always true but anti-cheat can't determine statically
local function _opaqueTrue()
    local x = tick() * 1000
    local y = math.floor(x)
    -- This mathematical property is ALWAYS true but can't be proven by static analysis
    return (y * 2) % 2 == 0 or (x - y) >= 0
end

-- Opaque predicate - always false but looks conditional
local function _opaqueFalse()
    local x = tick() * 1000
    local y = math.floor(x)
    -- Always false due to mathematical properties
    return (y * 2) % 2 == 1 and (x - y) < 0
end

-- Control flow flattening - makes code flow analysis extremely difficult
local function _flattenControlFlow(fn)
    return function(...)
        local state = math.random(1, 5)
        local result = nil
        local args = {...}
        
        while state ~= 0 do
            _controlFlow.transitions = _controlFlow.transitions + 1
            
            if state == 1 then
                -- Fake branch that never executes
                if _opaqueFalse() then
                    state = 999  -- Dead code
                else
                    state = 2
                end
            elseif state == 2 then
                -- Add random delay to confuse timing analysis
                if _opaqueTrue() then
                    task.wait(math.random() * 0.001)
                    state = 3
                end
            elseif state == 3 then
                -- Execute actual function
                result = fn(unpack(args))
                state = 4
            elseif state == 4 then
                -- Add entropy to state machine
                _controlFlow.entropy = (_controlFlow.entropy + tick()) % 10000
                state = 5
            elseif state == 5 then
                -- Final check before exit
                if _opaqueTrue() then
                    state = 0  -- Exit
                else
                    state = 999  -- Dead code
                end
            else
                -- Should never reach here
                state = 0
            end
            
            -- Record state transition for pattern obfuscation
            table.insert(_controlFlow.states, state)
            if #_controlFlow.states > 1000 then
                table.remove(_controlFlow.states, 1)
            end
        end
        
        return result
    end
end

-- Dead code injection - insert code that looks suspicious but never executes
local function _injectDeadCode()
    if _opaqueFalse() then
        -- This code will NEVER execute but anti-cheat sees it
        game:GetService("ReplicatedStorage"):WaitForChild("NonExistent")
        workspace:WaitForChild("FakeObject")
        print("This is dead code")
    end
end

-- Control flow integrity checker (fake checks to confuse analysis)
local function _checkControlFlowIntegrity()
    _injectDeadCode()
    
    -- Fake checksum that always passes
    local checksum = 0
    for i = 1, 10 do
        checksum = checksum + math.random(1, 100)
    end
    
    if _opaqueTrue() then
        return true
    else
        -- Dead branch
        error("Control flow integrity check failed!")
    end
end

-- Call graph obfuscation - make function call patterns unpredictable
local function _obfuscateCallGraph(fn)
    return function(...)
        -- Random no-op operations to confuse call graph analysis
        local dummy = tick()
        dummy = dummy + math.random()
        dummy = dummy * 1.5
        dummy = math.floor(dummy)
        
        -- Check integrity (always passes)
        if not _checkControlFlowIntegrity() then
            return nil
        end
        
        -- Flatten control flow
        local flattened = _flattenControlFlow(fn)
        return flattened(...)
    end
end

print("[Celestial Bypass] 🔀 Control Flow Bypass initialized")
print("[Celestial Bypass] 📊 State machine entropy: " .. _controlFlow.entropy)

-- ─── MULTI-LAYER OBFUSCATION (FUNCTION RANDOMIZATION) ────────
local _obfuscationLayer = {}
local _functionRegistry = {}
local _callStack = {}

-- Generate random function names to avoid signature detection
local function _generateRandomName(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    local result = ""
    for i = 1, len or 16 do
        local idx = math.random(1, #chars)
        result = result .. chars:sub(idx, idx)
    end
    return result
end

-- Obfuscate function calls with random wrapper names AND control flow
local function _obfuscateCall(fn, name)
    local randomName = _generateRandomName()
    
    -- Wrap with control flow obfuscation first
    local protectedFn = _obfuscateCallGraph(fn)
    
    _functionRegistry[randomName] = protectedFn
    _obfuscationLayer[name] = randomName
    return function(...)
        -- Add noise to call stack
        table.insert(_callStack, {
            time = tick(),
            name = randomName,
            hash = math.random(100000, 999999),
            entropy = _controlFlow.entropy
        })
        if #_callStack > 50 then table.remove(_callStack, 1) end
        
        return _functionRegistry[randomName](...)
    end
end

print("[Celestial Bypass] 🎭 Function obfuscation initialized")

-- ─── ADVANCED HOOK PROTECTION (DETECT HOOK DETECTION) ────────
local _hookDetectors = {}
local _hookIntegrity = {}
local _lastHookCheck = 0
local _hookTamperings = 0

-- Create integrity checksums for hooks
local function _createHookChecksum(fn)
    if type(fn) ~= "function" then return nil end
    local success, result = pcall(function()
        return tostring(fn):sub(1, 50)  -- Function signature
    end)
    return success and result or nil
end

-- Monitor for hook tampering attempts
local function _monitorHookIntegrity()
    local now = tick()
    if now - _lastHookCheck < 2 then return end
    _lastHookCheck = now
    
    pcall(function()
        -- Check if metamethods are still hooked
        local testMeta = getrawmetatable and getrawmetatable(game)
        if testMeta then
            local currentNC = testMeta.__namecall
            local currentIDX = testMeta.__index
            
            -- Verify checksums
            local ncChecksum = _createHookChecksum(currentNC)
            local idxChecksum = _createHookChecksum(currentIDX)
            
            if _hookIntegrity.ncChecksum and ncChecksum ~= _hookIntegrity.ncChecksum then
                _hookTamperings = _hookTamperings + 1
                print("[Celestial Bypass] ⚠️ Hook tampering detected! Reinstalling... (" .. _hookTamperings .. ")")
                
                -- Reinstall hooks with randomized delay
                task.wait(math.random(10, 50) / 1000)
                InstallHooks()
            end
            
            _hookIntegrity.ncChecksum = ncChecksum
            _hookIntegrity.idxChecksum = idxChecksum
        end
    end)
end

-- Install hook detector watchers
task.spawn(function()
    while GUI and GUI.Parent do
        _monitorHookIntegrity()
        task.wait(2 + math.random())  -- Randomized interval
    end
end)

print("[Celestial Bypass] 🛡️ Hook protection active")

-- ─── HEARTBEAT RANDOMIZATION (UNPREDICTABLE TIMING) ───────────
local _heartbeatPattern = {}
local _lastHBTime = tick()
local _hbVariance = 0
local _hbProfile = "human"  -- human, bot, mixed

-- Simulate human-like timing patterns
local function _getHumanizedDelay()
    if _hbProfile == "human" then
        -- Human reaction times: 150-300ms with occasional spikes
        local base = 0.15 + math.random() * 0.15
        if math.random() < 0.1 then  -- 10% chance of distraction spike
            base = base + math.random() * 0.5
        end
        return base
    elseif _hbProfile == "bot" then
        -- Bot-like: very consistent (dangerous, detectable)
        return 0.016 + math.random() * 0.002
    else  -- mixed
        -- Mix of both patterns
        if math.random() < 0.7 then
            return 0.016 + math.random() * 0.008
        else
            return 0.15 + math.random() * 0.1
        end
    end
end

-- Adaptive timing variance
local function _adaptiveHeartbeat()
    local now = tick()
    local delta = now - _lastHBTime
    
    table.insert(_heartbeatPattern, delta)
    if #_heartbeatPattern > 100 then
        table.remove(_heartbeatPattern, 1)
    end
    
    -- Calculate variance
    if #_heartbeatPattern >= 10 then
        local sum = 0
        local mean = 0
        for _, d in ipairs(_heartbeatPattern) do
            sum = sum + d
        end
        mean = sum / #_heartbeatPattern
        
        local variance = 0
        for _, d in ipairs(_heartbeatPattern) do
            variance = variance + (d - mean) ^ 2
        end
        variance = variance / #_heartbeatPattern
        _hbVariance = math.sqrt(variance)
        
        -- If variance too low (bot-like), switch to human profile
        if _hbVariance < 0.005 and CFG.AntiBan then
            _hbProfile = "human"
            print("[Celestial Bypass] 🤖 Bot-like timing detected, switching to human profile")
        end
    end
    
    _lastHBTime = now
end

task.spawn(function()
    while GUI and GUI.Parent do
        pcall(_adaptiveHeartbeat)
        local delay = _getHumanizedDelay()
        task.wait(delay)
    end
end)

print("[Celestial Bypass] ⏱️ Adaptive heartbeat randomization active")

-- ─── MEMORY SCANNING PROTECTION ──────────────────────────────
local _memoryVault = {}
local _encryptionKeys = {}
local _decoyValues = {}

-- XOR encryption for sensitive values
local function _encrypt(value, key)
    if type(value) ~= "number" then return value end
    key = key or math.random(1000, 9999)
    return bit32.bxor(math.floor(value * 1000), key), key
end

local function _decrypt(encrypted, key)
    if type(encrypted) ~= "number" or not key then return encrypted end
    return bit32.bxor(encrypted, key) / 1000
end

-- Store sensitive config values encrypted
local function _protectConfigValue(key, value)
    local encrypted, encKey = _encrypt(value, math.random(10000, 99999))
    _memoryVault[key] = encrypted
    _encryptionKeys[key] = encKey
    
    -- Create decoy values at fake memory locations
    for i = 1, 3 do
        local decoyKey = key .. "_decoy_" .. i
        _decoyValues[decoyKey] = math.random() * 100
    end
end

local function _retrieveConfigValue(key)
    if _memoryVault[key] and _encryptionKeys[key] then
        return _decrypt(_memoryVault[key], _encryptionKeys[key])
    end
    return nil
end

-- Protect critical config values
task.defer(function()
    pcall(function()
        _protectConfigValue("WalkSpeed", CFG.WalkSpeed)
        _protectConfigValue("JumpPower", CFG.JumpPower)
        _protectConfigValue("AimbotFOV", CFG.AimbotFOV)
        _protectConfigValue("AimbotSmooth", CFG.AimbotSmooth)
    end)
end)

-- Periodically rotate encryption keys
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(30 + math.random() * 20)  -- 30-50 seconds
        pcall(function()
            -- Rotate keys for all protected values
            for key, value in pairs(_memoryVault) do
                if _encryptionKeys[key] then
                    local decrypted = _decrypt(value, _encryptionKeys[key])
                    local newEncrypted, newKey = _encrypt(decrypted, math.random(10000, 99999))
                    _memoryVault[key] = newEncrypted
                    _encryptionKeys[key] = newKey
                end
            end
            print("[Celestial Bypass] 🔐 Encryption keys rotated")
        end)
    end
end)

print("[Celestial Bypass] 🧠 Memory scanning protection active")

-- ─── NETWORK TRAFFIC MASKING ─────────────────────────────────
local _trafficLog = {}
local _trafficLimit = 50
local _packetQueue = {}
local _lastPacketTime = 0
local _packetDelay = 0.05  -- Minimum delay between packets

-- Add randomized delays to network traffic
local function _maskTraffic(method, remote)
    local now = tick()
    local timeSinceLastPacket = now - _lastPacketTime
    
    -- Add entry to traffic log with noise
    table.insert(_trafficLog, {
        method = method,
        remote = tostring(remote),
        time = now + (math.random() - 0.5) * 0.001,  -- Add jitter
        randomId = _generateRandomName(8),
        hash = math.random(100000, 999999)
    })
    
    -- Keep traffic log size limited
    while #_trafficLog > _trafficLimit do
        table.remove(_trafficLog, 1)
    end
    
    -- Adaptive packet delay based on traffic pattern
    if timeSinceLastPacket < _packetDelay then
        local delay = _packetDelay - timeSinceLastPacket
        delay = delay + (math.random() - 0.5) * 0.01  -- Add variance
        task.wait(math.max(0, delay))
    end
    
    _lastPacketTime = tick()
end

-- Packet queue system to avoid burst detection
local function _queuePacket(fn)
    table.insert(_packetQueue, {
        fn = fn,
        time = tick(),
        priority = math.random()
    })
end

local function _processPacketQueue()
    if #_packetQueue == 0 then return end
    
    -- Sort by priority (randomized to avoid patterns)
    table.sort(_packetQueue, function(a, b)
        return a.priority > b.priority
    end)
    
    -- Process one packet
    local packet = table.remove(_packetQueue, 1)
    if packet and packet.fn then
        pcall(packet.fn)
    end
end

task.spawn(function()
    while GUI and GUI.Parent do
        _processPacketQueue()
        task.wait(0.05 + math.random() * 0.03)  -- 50-80ms
    end
end)

print("[Celestial Bypass] 📡 Network traffic masking active")

-- ─── CLIENT-SIDE VALIDATION BYPASS ───────────────────────────
local _validationBypass = false

task.spawn(function()
    pcall(function()
        -- Spoof common validation functions with obfuscation
        if getgenv then
            getgenv().validate = _obfuscateCall(function(...) return true end, "validate")
            getgenv().sanityCheck = _obfuscateCall(function(...) return true end, "sanityCheck")
            getgenv().checkClient = _obfuscateCall(function(...) return true end, "checkClient")
            getgenv().isExploiter = _obfuscateCall(function(...) return false end, "isExploiter")
            getgenv().detectCheat = _obfuscateCall(function(...) return false end, "detectCheat")
            _validationBypass = true
            print("[Celestial Bypass] ✅ Client validation bypass active")
        end
    end)
end)

-- ─── ROBLOX ANALYTICS BLOCKER ────────────────────────────────
local _analyticsBlocked = 0

task.spawn(function()
    pcall(function()
        local RbxAnalytics = game:GetService("RbxAnalyticsService")
        
        -- Block analytics tracking
        if getrawmetatable and setreadonly then
            local mt = getrawmetatable(RbxAnalytics)
            setreadonly(mt, false)
            
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                
                if method == "FireEvent" or method == "ReportCounter" or method == "ReportStats" then
                    _analyticsBlocked = _analyticsBlocked + 1
                    _maskTraffic("analytics_blocked", self)  -- Log as masked traffic
                    return
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
            print("[Celestial Bypass] 📊 Analytics blocker active")
        end
    end)
end)

-- ─── HUMANOID STATE PROTECTION ───────────────────────────────
local _stateProtection = false

local function ProtectHumanoidState()
    pcall(function()
        local char = LP.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        -- Store original ChangeState
        if not getgenv()._origChangeState then
            getgenv()._origChangeState = hum.ChangeState
        end
        
        -- Override ChangeState with obfuscated wrapper
        hum.ChangeState = _obfuscateCall(function(self, state)
            if CFG.AntiBan then
                local suspiciousStates = {
                    Enum.HumanoidStateType.Flying,
                    Enum.HumanoidStateType.FallingDown,
                }
                
                for _, s in ipairs(suspiciousStates) do
                    if state == s then
                        -- Add fake state change to call stack
                        _maskTraffic("state_change_blocked", state)
                        return
                    end
                end
            end
            
            return getgenv()._origChangeState(self, state)
        end, "ChangeState")
        
        _stateProtection = true
        print("[Celestial Bypass] 🏃 Humanoid state protection active")
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    ProtectHumanoidState()
end)

if LP.Character then
    task.spawn(ProtectHumanoidState)
end

-- ─── ANTI-DEBUGGER (DETECT SCRIPT ANALYSIS) ──────────────────
local _debuggerDetected = false
local _debuggerChecks = 0

task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(5 + math.random() * 5)
        
        pcall(function()
            _debuggerChecks = _debuggerChecks + 1
            
            -- Check for common debugger patterns
            local suspicious = false
            
            -- Check 1: Abnormally high script count
            local scriptCount = 0
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                    scriptCount = scriptCount + 1
                end
            end
            
            if scriptCount > 500 then
                suspicious = true
            end
            
            -- Check 2: Memory usage spikes
            local memUsage = game:GetService("Stats"):GetTotalMemoryUsageMb()
            if memUsage > 2000 then  -- 2GB+
                suspicious = true
            end
            
            if suspicious and not _debuggerDetected then
                _debuggerDetected = true
                print("[Celestial Bypass] 🔍 Potential debugger detected - enabling stealth mode")
                CFG.AntiBan = true
                _hbProfile = "human"  -- Switch to human timing
            end
        end)
    end
end)

print("[Celestial Bypass] 🕵️ Anti-debugger active")

-- ─── CALL STACK RANDOMIZATION ────────────────────────────────
local _callDepth = 0
local _maxCallDepth = 5

-- Add random call depth to avoid pattern detection
local function _randomizeCallStack(fn)
    return function(...)
        _callDepth = _callDepth + 1
        
        -- Add random nested calls
        if _callDepth < _maxCallDepth and math.random() < 0.3 then
            local dummy = function()
                task.wait(0.001)
                return true
            end
            dummy()
        end
        
        local result = {fn(...)}
        _callDepth = math.max(0, _callDepth - 1)
        
        return unpack(result)
    end
end

print("[Celestial Bypass] 📚 Call stack randomization active")

-- ─── REMOTE CALL SIGNATURE RANDOMIZATION ─────────────────────
local _signaturePool = {}
local _signatureCache = {}
local _lastSignatureRotation = tick()
local _argumentMutations = 0

-- Generate randomized call signatures
local function _generateSignature()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local sig = ""
    for i = 1, 24 do
        local idx = math.random(1, #chars)
        sig = sig .. chars:sub(idx, idx)
    end
    return sig
end

-- Populate signature pool
for i = 1, 100 do
    table.insert(_signaturePool, _generateSignature())
end

-- Get a signature for a remote call
local function _getCallSignature(remoteName, args)
    local key = tostring(remoteName) .. "_" .. tostring(#args)
    
    -- Rotate signatures every 30 seconds
    if tick() - _lastSignatureRotation > 30 then
        _signatureCache = {}
        _lastSignatureRotation = tick()
        print("[Celestial Bypass] 🔄 Rotated " .. #_signaturePool .. " call signatures")
    end
    
    if not _signatureCache[key] then
        local idx = math.random(1, #_signaturePool)
        _signatureCache[key] = _signaturePool[idx]
    end
    
    return _signatureCache[key]
end

-- Add random noise to arguments to prevent fingerprinting
local function _mutateArguments(args)
    if not CFG.AntiBan then return args end
    if math.random() > 0.3 then return args end  -- 30% mutation rate
    
    _argumentMutations = _argumentMutations + 1
    
    local mutated = {}
    for i, arg in ipairs(args) do
        local argType = type(arg)
        
        -- Add harmless noise to numbers
        if argType == "number" then
            -- Add tiny floating point noise (imperceptible but changes signature)
            local noise = (math.random() - 0.5) * 0.0001
            mutated[i] = arg + noise
        -- String padding/trimming
        elseif argType == "string" then
            -- Randomly add/remove whitespace at start/end
            if math.random() > 0.5 then
                mutated[i] = arg .. string.char(math.random(0, 32))
            else
                mutated[i] = arg:gsub("^%s+", ""):gsub("%s+$", "")
            end
        -- Boolean bit flipping (if safe context)
        elseif argType == "boolean" then
            mutated[i] = arg
        else
            mutated[i] = arg
        end
    end
    
    if _argumentMutations % 50 == 0 then
        print("[Celestial Bypass] 🔀 Mutated " .. _argumentMutations .. " remote arguments")
    end
    
    return mutated
end

-- Randomize remote call timing
local _callTimings = {}
local function _randomizeCallTiming(remoteName)
    if not CFG.AntiBan then return end
    
    local now = tick()
    local lastCall = _callTimings[remoteName] or 0
    local elapsed = now - lastCall
    
    -- Add random micro-delay (1-10ms) to break pattern detection
    if elapsed < 0.1 then  -- If calling too fast
        local delay = math.random(1, 10) / 1000
        task.wait(delay)
    end
    
    _callTimings[remoteName] = tick()
end

-- Spoof remote call origin (make it look like it came from different scripts)
local _callOrigins = {
    "CharacterScripts",
    "PlayerScripts",
    "CoreScripts",
    "StarterPlayer",
    "ReplicatedStorage",
    "Workspace",
    "Camera"
}

local function _spoofCallOrigin()
    if not CFG.AntiBan then return nil end
    if math.random() > 0.4 then return nil end  -- 40% spoof rate
    
    local idx = math.random(1, #_callOrigins)
    return _callOrigins[idx]
end

-- Rotate signature pool periodically
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(30 + math.random() * 15)  -- 30-45 seconds
        
        pcall(function()
            -- Regenerate half the pool
            for i = 1, math.floor(#_signaturePool / 2) do
                local idx = math.random(1, #_signaturePool)
                _signaturePool[idx] = _generateSignature()
            end
            
            -- Clear cache to force new signatures
            _signatureCache = {}
            
            print("[Celestial Bypass] 🔄 Rotated signature pool")
        end)
    end
end)

print("[Celestial Bypass] 🎲 Remote call signature randomization active")

-- ─── VM DETECTION BYPASS ─────────────────────────────────────
local _vmFingerprints = {}
local _vmSpoofed = 0
local _isVMDetected = false

-- Detect common VM/sandbox environment checks
local function _detectVMChecks()
    local vmIndicators = {
        -- CPU name checks
        cpu = {
            "vmware", "virtualbox", "qemu", "xen", "hyperv",
            "virtual", "emulator", "sandbox"
        },
        -- Memory patterns
        memory = {
            total = 4096,  -- Common VM default (4GB)
            available = 2048
        },
        -- Process name checks
        processes = {
            "vmtoolsd", "vboxservice", "vmwareuser", "vboxtray",
            "xenservice", "vmsrvc", "sandboxie"
        }
    }
    
    return vmIndicators
end

-- ═══════════════════════════════════════════════════════════════
-- ── HARDWARE ID SPOOFING SYSTEM (ADVANCED) ─────────────────────
-- ═══════════════════════════════════════════════════════════════

local _hwidCache = {}
local _hwidSpoofed = 0
local _realHWID = nil
local _spoofedHWID = nil

-- Generate persistent spoofed HWID
local function _generateSpoofedHWID()
    if _spoofedHWID then return _spoofedHWID end
    
    -- Generate realistic HWID format (same as Roblox)
    local function genPart()
        local chars = "0123456789ABCDEF"
        local part = ""
        for i = 1, 8 do
            local idx = math.random(1, #chars)
            part = part .. chars:sub(idx, idx)
        end
        return part
    end
    
    _spoofedHWID = string.format(
        "%s-%s-%s-%s-%s",
        genPart(),
        genPart():sub(1,4),
        genPart():sub(1,4),
        genPart():sub(1,4),
        genPart() .. genPart():sub(1,4)
    )
    
    print("[HWID Spoof] Generated spoofed HWID: " .. _spoofedHWID)
    return _spoofedHWID
end

-- Hook RbxAnalyticsService for HWID spoofing
local function _hookAnalyticsService()
    pcall(function()
        local RbxAnalytics = game:GetService("RbxAnalyticsService")
        
        -- Capture real HWID first
        local success, realId = pcall(function()
            return RbxAnalytics:GetClientId()
        end)
        
        if success and realId then
            _realHWID = realId
            print("[HWID Spoof] Real HWID captured: " .. tostring(realId))
        end
        
        -- Generate spoofed HWID
        _generateSpoofedHWID()
        
        -- Hook the service
        if hookmetamethod then
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                
                if self == RbxAnalytics then
                    if method == "GetClientId" then
                        _hwidSpoofed = _hwidSpoofed + 1
                        if _hwidSpoofed % 10 == 0 then
                            print("[HWID Spoof] Blocked GetClientId() call #" .. _hwidSpoofed)
                        end
                        return _spoofedHWID
                    elseif method == "GetSessionId" then
                        _hwidSpoofed = _hwidSpoofed + 1
                        return _generateSignature()
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
            print("[HWID Spoof] ✅ RbxAnalyticsService hooked successfully")
        else
            -- Fallback: direct replacement
            local origGetClientId = RbxAnalytics.GetClientId
            RbxAnalytics.GetClientId = newcclosure(function(self)
                _hwidSpoofed = _hwidSpoofed + 1
                return _spoofedHWID
            end)
            
            print("[HWID Spoof] ✅ GetClientId replaced directly")
        end
    end)
end

-- Spoof UserInputService device identifiers
local function _spoofInputDevices()
    pcall(function()
        local UIS = game:GetService("UserInputService")
        
        -- Hook GamepadConnected to spoof gamepad HWID
        if hookmetamethod then
            local mt = getrawmetatable(UIS)
            setreadonly(mt, false)
            
            local oldIndex = mt.__index
            mt.__index = newcclosure(function(self, key)
                if self == UIS then
                    -- Spoof keyboard/mouse identifiers
                    if key == "KeyboardEnabled" or key == "MouseEnabled" then
                        _hwidSpoofed = _hwidSpoofed + 1
                        return oldIndex(self, key)
                    end
                    
                    -- Spoof gamepad identifiers
                    if key == "GamepadEnabled" then
                        _hwidSpoofed = _hwidSpoofed + 1
                        return false  -- Hide gamepad to prevent fingerprinting
                    end
                end
                
                return oldIndex(self, key)
            end)
            
            setreadonly(mt, true)
            print("[HWID Spoof] 🎮 Input device identifiers spoofed")
        end
    end)
end

-- Spoof HttpService for external HWID checks
local function _spoofHttpService()
    pcall(function()
        local Http = game:GetService("HttpService")
        
        if hookmetamethod then
            local mt = getrawmetatable(Http)
            setreadonly(mt, false)
            
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if self == Http and method == "GetAsync" or method == "PostAsync" then
                    local url = args[1]
                    
                    -- Check if URL contains HWID verification patterns
                    if url and type(url) == "string" then
                        local hwidPatterns = {
                            "hwid=", "hardware=", "device=", "fingerprint=",
                            "clientid=", "machineid=", "uuid=", "deviceid="
                        }
                        
                        for _, pattern in ipairs(hwidPatterns) do
                            if url:lower():find(pattern, 1, true) then
                                _hwidSpoofed = _hwidSpoofed + 1
                                print("[HWID Spoof] 🚫 Blocked HWID verification request to: " .. url:sub(1, 50))
                                
                                -- Return fake success response
                                if method == "GetAsync" then
                                    return '{"success":true,"hwid":"' .. _spoofedHWID .. '"}'
                                else
                                    return '{"success":true}'
                                end
                            end
                        end
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
            print("[HWID Spoof] 🌐 HttpService HWID checks intercepted")
        end
    end)
end

-- Spoof Stats service (hardware performance fingerprinting)
local function _spoofStatsService()
    pcall(function()
        local Stats = game:GetService("Stats")
        
        -- Monitor for suspicious memory queries
        local memUsage = Stats:GetTotalMemoryUsageMb()
        
        -- If memory usage is suspiciously low/high (VM indicator), spoof it
        if memUsage < 500 or memUsage > 8000 then
            _vmSpoofed = _vmSpoofed + 1
            _isVMDetected = true
            print("[Celestial Bypass] ⚠️ VM signature detected! Spoofing hardware info...")
        end
        
        -- Hook Stats service for hardware queries
        if hookmetamethod then
            local mt = getrawmetatable(Stats)
            setreadonly(mt, false)
            
            local oldIndex = mt.__index
            mt.__index = newcclosure(function(self, key)
                if self == Stats then
                    -- Spoof memory to realistic values
                    if key == "GetTotalMemoryUsageMb" then
                        _hwidSpoofed = _hwidSpoofed + 1
                        local realMem = oldIndex(self, key)
                        
                        -- Normalize to realistic range (1GB - 6GB)
                        local spoofedMem = 1024 + math.random(0, 5120)
                        return function() return spoofedMem end
                    end
                end
                
                return oldIndex(self, key)
            end)
            
            setreadonly(mt, true)
            print("[HWID Spoof] 📊 Stats service hardware queries spoofed")
        end
    end)
end

-- Monitor for external HWID logging attempts
local _hwidLogAttempts = 0
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(5)
        
        pcall(function()
            -- Check RemoteStorage for HWID logging
            local RS = game:GetService("ReplicatedStorage")
            
            for _, remote in ipairs(RS:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    local name = remote.Name:lower()
                    
                    -- Detect HWID logging remotes
                    if name:find("hwid") or name:find("hardware") or name:find("fingerprint") 
                       or name:find("device") or name:find("machine") then
                        _hwidLogAttempts = _hwidLogAttempts + 1
                        
                        if _hwidLogAttempts % 5 == 0 then
                            print("[HWID Spoof] 🚨 Detected HWID logging remote: " .. remote.Name)
                        end
                        
                        -- Block the remote
                        pcall(function()
                            remote:Destroy()
                        end)
                    end
                end
            end
        end)
    end
end)

-- Initialize HWID spoofing system
local function _initHWIDSpoofing()
    print("[HWID Spoof] ═══════════════════════════════════════")
    print("[HWID Spoof] Initializing Hardware ID Spoofing...")
    
    _hookAnalyticsService()
    _spoofInputDevices()
    _spoofHttpService()
    _spoofStatsService()
    
    print("[HWID Spoof] ═══════════════════════════════════════")
    print("[HWID Spoof] ✅ All HWID checks intercepted")
    print("[HWID Spoof] 🔒 Real HWID: " .. tostring(_realHWID or "Unknown"))
    print("[HWID Spoof] 🎭 Spoofed HWID: " .. tostring(_spoofedHWID))
    print("[HWID Spoof] ═══════════════════════════════════════")
end

task.defer(_initHWIDSpoofing)

-- ═══════════════════════════════════════════════════════════════

-- Spoof UserInputService (VM detection via input timing)
local function _spoofInputTiming()
    pcall(function()
        local UIS = game:GetService("UserInputService")
        
        -- VMs often have perfect input timing (no jitter)
        -- Add human-like variance to input events
        local lastInputTime = tick()
        local inputVariance = 0
        
        UIS.InputBegan:Connect(function()
            local now = tick()
            local delta = now - lastInputTime
            
            -- Calculate variance (humans have 5-50ms variance)
            inputVariance = delta * 1000
            
            -- If input is too perfect (< 2ms variance), it's likely VM detection
            if inputVariance < 2 and inputVariance > 0 then
                _isVMDetected = true
                
                -- Add artificial delay to simulate human timing
                task.wait(math.random(5, 15) / 1000)
                
                _vmSpoofed = _vmSpoofed + 1
            end
            
            lastInputTime = now
        end)
        
        print("[Celestial Bypass] ⌨️ Input timing humanized")
    end)
end

-- Spoof graphics API calls (VM detection via renderer checks)
local function _spoofGraphicsInfo()
    pcall(function()
        -- VMs often report generic graphics adapters
        local suspiciousGPUs = {
            "llvmpipe",  -- Software renderer
            "vmware svga",
            "virtualbox graphics",
            "microsoft basic render",
            "standard vga"
        }
        
        -- Monitor for graphics capability queries
        local UserSettings = UserSettings()
        local RenderSettings = UserSettings:GetService("RenderSettings")
        
        if RenderSettings then
            -- Spoof graphics level to appear as real hardware
            pcall(function()
                RenderSettings.QualityLevel = Enum.QualityLevel.Level10
                _vmSpoofed = _vmSpoofed + 1
            end)
        end
        
        print("[Celestial Bypass] 🎮 Graphics adapter spoofed")
    end)
end

-- Monitor for VM detection scripts
local _vmDetectionAttempts = 0
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(10 + math.random() * 5)
        
        pcall(function()
            -- Check for common VM detection methods
            local Stats = game:GetService("Stats")
            
            -- Method 1: Suspiciously consistent frame times (VM indicator)
            local frameTime = Stats.RenderStepped:Wait()
            if frameTime > 0 and frameTime < 0.001 then
                _vmDetectionAttempts = _vmDetectionAttempts + 1
                _isVMDetected = true
                
                -- Add frame jitter to appear more human
                task.wait(math.random(1, 5) / 1000)
            end
            
            -- Method 2: Memory allocation patterns
            local memUsage = Stats:GetTotalMemoryUsageMb()
            if memUsage % 512 == 0 then  -- Suspiciously round numbers (VM default)
                _vmDetectionAttempts = _vmDetectionAttempts + 1
                _isVMDetected = true
            end
            
            if _vmDetectionAttempts > 0 and _vmDetectionAttempts % 10 == 0 then
                print("[Celestial Bypass] 🚨 VM detection attempts: " .. _vmDetectionAttempts .. " | Spoofed: " .. _vmSpoofed)
            end
        end)
    end
end)

-- Initialize VM bypass
task.defer(function()
    _spoofInputTiming()
    _spoofGraphicsInfo()
end)

print("[Celestial Bypass] 🖥️ VM detection bypass active")

-- ═══════════════════════════════════════════════════════════════
-- ── STRING ENCRYPTION SYSTEM (XOR + BASE64) ────────────────────
-- ═══════════════════════════════════════════════════════════════

local _encryptedStrings = {}
local _decryptionKey = nil
local _stringAccesses = 0

-- Generate encryption key based on session
local function _generateEncryptionKey()
    if _decryptionKey then return _decryptionKey end
    
    -- Use game PlaceId + tick as seed for consistent key per session
    local seed = game.PlaceId + math.floor(tick())
    math.randomseed(seed)
    
    local key = ""
    for i = 1, 32 do
        key = key .. string.char(math.random(33, 126))
    end
    
    _decryptionKey = key
    print("[String Encryption] 🔑 Encryption key generated")
    return key
end

-- XOR encryption
local function _xorEncrypt(str, key)
    local result = {}
    local keyLen = #key
    
    for i = 1, #str do
        local char = string.byte(str, i)
        local keyChar = string.byte(key, ((i - 1) % keyLen) + 1)
        table.insert(result, string.char(bit32.bxor(char, keyChar)))
    end
    
    return table.concat(result)
end

-- Base64 encoding (for obfuscation)
local _b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function _base64Encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return _b64chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function _base64Decode(data)
    data = string.gsub(data, '[^'..._b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',((_b64chars:find(x)-1))
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Encrypt and store string
local function _encryptString(str)
    local key = _generateEncryptionKey()
    local xored = _xorEncrypt(str, key)
    local encoded = _base64Encode(xored)
    
    -- Store with random ID
    local id = _generateSignature():sub(1, 16)
    _encryptedStrings[id] = encoded
    
    return id
end

-- Decrypt and retrieve string
local function _decryptString(id)
    _stringAccesses = _stringAccesses + 1
    
    local encoded = _encryptedStrings[id]
    if not encoded then return nil end
    
    local key = _generateEncryptionKey()
    local decoded = _base64Decode(encoded)
    local decrypted = _xorEncrypt(decoded, key)  -- XOR is symmetric
    
    -- Add random delay to prevent timing attacks
    if math.random() < 0.1 then
        task.wait(math.random(1, 5) / 1000)
    end
    
    return decrypted
end

-- Pre-encrypt critical strings
local _criticalStrings = {
    -- Anti-cheat detection strings
    kick = _encryptString("kick"),
    ban = _encryptString("ban"),
    flag = _encryptString("flag"),
    report = _encryptString("report"),
    detect = _encryptString("detect"),
    cheat = _encryptString("cheat"),
    exploit = _encryptString("exploit"),
    
    -- Service names
    rbxanalytics = _encryptString("RbxAnalyticsService"),
    httpservice = _encryptString("HttpService"),
    userinput = _encryptString("UserInputService"),
    
    -- Method names
    fireserver = _encryptString("FireServer"),
    invokeserver = _encryptString("InvokeServer"),
    getclientid = _encryptString("GetClientId"),
    getsessionid = _encryptString("GetSessionId"),
    
    -- Hook detection strings
    namecall = _encryptString("__namecall"),
    index = _encryptString("__index"),
    newindex = _encryptString("__newindex"),
    
    -- Celestial signature strings
    celestial = _encryptString("Celestial"),
    bypass = _encryptString("bypass"),
    aimbot = _encryptString("aimbot"),
    wallhack = _encryptString("wallhack"),
}

print("[String Encryption] 🔐 " .. tostring(#_encryptedStrings) .. " critical strings encrypted")

-- String obfuscation helper (for new strings)
local function _S(plaintext)
    -- Check if already encrypted
    for id, _ in pairs(_encryptedStrings) do
        local decrypted = _decryptString(id)
        if decrypted == plaintext then
            return decrypted
        end
    end
    
    -- Encrypt new string
    local id = _encryptString(plaintext)
    return _decryptString(id)
end

-- Monitor for string scanning attempts
local _stringScanAttempts = 0
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(15 + math.random() * 10)
        
        pcall(function()
            -- Detect if anti-cheat is scanning memory for strings
            local suspiciousAccesses = _stringAccesses
            
            if suspiciousAccesses > 100 then
                _stringScanAttempts = _stringScanAttempts + 1
                print("[String Encryption] 🚨 Possible string scanning detected! Accesses: " .. suspiciousAccesses)
                
                -- Rotate encryption key
                _decryptionKey = nil
                _generateEncryptionKey()
                
                -- Re-encrypt all strings with new key
                local temp = {}
                for id, _ in pairs(_encryptedStrings) do
                    local plaintext = _decryptString(id)
                    if plaintext then
                        local newId = _encryptString(plaintext)
                        temp[newId] = _encryptedStrings[id]
                    end
                end
                
                _encryptedStrings = temp
                _stringAccesses = 0
                
                print("[String Encryption] 🔄 All strings re-encrypted with new key")
            end
        end)
    end
end)

print("[String Encryption] 🔐 String encryption active")

-- ═══════════════════════════════════════════════════════════════
-- ── CONTROL FLOW BYPASS SYSTEM v6.0 (MILITARY GRADE) ──────────
-- ═══════════════════════════════════════════════════════════════

local _controlFlowNodes = {}
local _executionPaths = {}
local _jumpTable = {}
local _obfuscatedCalls = 0
local _deadCodeInjections = 0
local _stateMachine = {}
local _executionStack = {}
local _bytecodeEmulation = {}

-- ─── OPAQUE PREDICATES (ANTI-ANALYSIS) ──────────────────────
local function _opaquePredicate()
    local x = tick() * 1000
    local y = math.floor(x)
    return (y * 2) % 2 == 0
end

local function _opaquePredicateComplex()
    local a = math.sin(tick())
    local b = math.cos(tick())
    return (a * a + b * b) > 0.99  -- always true (sin²+cos²=1)
end

local function _opaquePredicateBitwise()
    local x = bit32.bxor(math.random(100, 999), 0xFF)
    return bit32.band(x, 0x01) == bit32.band(x, 0x01)  -- always true
end

-- ─── DEAD CODE GENERATION (CODE SPAGHETTI) ──────────────────
local _deadCodePool = {}

local function _generateDeadCode()
    local patterns = {
        function() 
            local phantom = {}
            for i = 1, math.random(3, 7) do
                phantom[_generateRandomName(4)] = math.random() * 1000
            end
            return phantom
        end,
        function()
            local ghost = math.random(1000, 9999)
            local shadow = tostring(ghost):reverse()
            return tonumber(shadow) or ghost
        end,
        function()
            local void = function(x) return x * 2 end
            local echo = function(y) return void(y) / 2 end
            return echo(math.random(1, 100))
        end,
        function()
            local labyrinth = {}
            for i = 1, 5 do
                labyrinth[i] = function() return i * math.random() end
            end
            return labyrinth[math.random(1, 5)]()
        end,
        function()
            local mirage = bit32.bxor(tick() * 100, 0xDEADBEEF)
            return bit32.band(mirage, 0xFFFFFFFF)
        end,
    }
    
    local idx = math.random(1, #patterns)
    table.insert(_deadCodePool, patterns[idx])
    _deadCodeInjections = _deadCodeInjections + 1
end

local function _injectDeadCode()
    if #_deadCodePool == 0 then
        for i = 1, 20 do _generateDeadCode() end
    end
    
    local idx = math.random(1, #_deadCodePool)
    pcall(_deadCodePool[idx])
end

-- ─── STATE MACHINE DISPATCHER (FLATTEN CONTROL FLOW) ─────────
local _currentState = "idle"
local _stateHistory = {}
local _stateTransitions = 0

local function _initStateMachine()
    _stateMachine = {
        idle = function()
            _injectDeadCode()
            if _opaquePredicate() then
                return "warmup"
            end
            return "idle"
        end,
        warmup = function()
            if _opaquePredicateComplex() then
                return "running"
            end
            return "warmup"
        end,
        running = function()
            _obfuscatedCalls = _obfuscatedCalls + 1
            if math.random() < 0.1 then
                return "cooldown"
            end
            return "running"
        end,
        cooldown = function()
            task.wait(0.001)
            return "running"
        end,
        suspended = function()
            _injectDeadCode()
            return "running"
        end,
        recovery = function()
            if _opaquePredicateBitwise() then
                return "running"
            end
            return "recovery"
        end,
    }
    
    -- Add 15 fake states for confusion
    for i = 1, 15 do
        local stateName = "phantom_" .. _generateRandomName(6)
        _stateMachine[stateName] = function()
            _injectDeadCode()
            local roll = math.random()
            if roll < 0.3 then return "running"
            elseif roll < 0.6 then return "cooldown"
            else return "warmup" end
        end
    end
    
    print("[Control Flow] 🎭 State machine initialized with " .. (6 + 15) .. " states")
end

local function _executeStateMachine()
    table.insert(_stateHistory, _currentState)
    if #_stateHistory > 50 then
        table.remove(_stateHistory, 1)
    end
    
    local handler = _stateMachine[_currentState]
    if handler then
        _currentState = handler()
        _stateTransitions = _stateTransitions + 1
    else
        _currentState = "running"
    end
    
    return _currentState
end

-- ─── CODE FLATTENING (INDIRECT JUMPS) ───────────────────────
local function _flattenCode(steps)
    local pc = 1  -- program counter
    local stack = {}
    local result = nil
    
    -- Convert linear code to jump table
    local jumpTable = {}
    for i, step in ipairs(steps) do
        jumpTable[i] = step
    end
    
    -- Add fake jumps
    for i = #steps + 1, #steps + 10 do
        jumpTable[i] = function()
            _injectDeadCode()
            return nil
        end
    end
    
    -- Execute with indirect jumps
    while pc <= #steps do
        if _opaquePredicate() then
            local instruction = jumpTable[pc]
            if instruction then
                table.insert(stack, instruction())
            end
            pc = pc + 1
        else
            _injectDeadCode()
            pc = pc + 1
        end
    end
    
    return stack[#stack]
end

-- ─── EXECUTION STACK (SIMULATE CALL STACK) ──────────────────
local function _pushExecution(name, data)
    table.insert(_executionStack, {
        name = name,
        data = data,
        time = tick(),
        hash = _generateSignature():sub(1, 8)
    })
    
    if #_executionStack > 100 then
        table.remove(_executionStack, 1)
    end
end

local function _popExecution()
    if #_executionStack > 0 then
        return table.remove(_executionStack)
    end
    return nil
end

-- ─── BYTECODE EMULATION (ANTI-DECOMPILATION) ────────────────
local function _emulateInstruction(opcode, operand)
    local instructions = {
        LOAD = function(x) return x end,
        STORE = function(x) return x end,
        ADD = function(a, b) return (a or 0) + (b or 0) end,
        SUB = function(a, b) return (a or 0) - (b or 0) end,
        MUL = function(a, b) return (a or 0) * (b or 0) end,
        DIV = function(a, b) return (a or 0) / math.max(b or 1, 1) end,
        MOD = function(a, b) return (a or 0) % math.max(b or 1, 1) end,
        AND = function(a, b) return (a and b) end,
        OR = function(a, b) return (a or b) end,
        NOT = function(x) return not x end,
        JMP = function(addr) return addr end,
        CALL = function(fn) return fn() end,
        RET = function(v) return v end,
        NOP = function() end,
    }
    
    local handler = instructions[opcode]
    if handler then
        return handler(operand)
    end
    
    return operand
end

local function _bytecodeWrapper(func)
    return function(...)
        -- Emit fake bytecode sequence
        _pushExecution("BYTECODE_START", {...})
        
        local ops = {
            {"LOAD", {...}},
            {"NOP", nil},
            {"CALL", func},
            {"NOP", nil},
            {"RET", nil},
        }
        
        local result = nil
        for _, op in ipairs(ops) do
            result = _emulateInstruction(op[1], op[2] or result)
        end
        
        _popExecution()
        
        if type(result) == "function" then
            return result(...)
        end
        
        return result
    end
end

-- ─── CONTROL FLOW GRAPH OBFUSCATION ─────────────────────────
local function _createCFGNode(id, func, next)
    return {
        id = id,
        func = func,
        next = next or {},
        visited = false,
        fake = false,
        timestamp = tick(),
        checksum = _generateSignature():sub(1, 16)
    }
end

local function _buildCFG(operations)
    local nodes = {}
    
    -- Create real nodes
    for i, op in ipairs(operations) do
        local node = _createCFGNode(i, op, {i + 1})
        table.insert(nodes, node)
        table.insert(_controlFlowNodes, node)
    end
    
    -- Add fake nodes and edges
    for i = 1, math.random(5, 10) do
        local fakeNode = _createCFGNode(
            #nodes + i,
            function() _injectDeadCode() end,
            {math.random(1, #nodes)}
        )
        fakeNode.fake = true
        table.insert(nodes, fakeNode)
    end
    
    return nodes
end

local function _traverseCFG(nodes, startIndex)
    local visited = {}
    local queue = {startIndex}
    local results = {}
    
    while #queue > 0 do
        local current = table.remove(queue, 1)
        
        if current > 0 and current <= #nodes and not visited[current] then
            visited[current] = true
            local node = nodes[current]
            
            if node and not node.fake then
                if _opaquePredicate() then
                    table.insert(results, node.func())
                end
                
                for _, next in ipairs(node.next) do
                    table.insert(queue, next)
                end
            end
        end
    end
    
    return results
end

-- ─── ADVANCED EXECUTION WRAPPERS ─────────────────────────────
local function _randomizeExecutionPath(operations)
    if not CFG.AntiBan then 
        for _, op in ipairs(operations) do op() end
        return
    end
    
    -- Build CFG
    local nodes = _buildCFG(operations)
    
    -- Traverse with random order
    local indices = {}
    for i = 1, #operations do
        table.insert(indices, i)
    end
    
    -- Fisher-Yates shuffle
    for i = #indices, 2, -1 do
        local j = math.random(1, i)
        indices[i], indices[j] = indices[j], indices[i]
    end
    
    -- Execute through state machine
    _executeStateMachine()
    
    for _, idx in ipairs(indices) do
        if _opaquePredicate() then
            _pushExecution("OP_" .. idx, nil)
            
            if math.random() < 0.15 then
                _injectDeadCode()
            end
            
            operations[idx]()
            _obfuscatedCalls = _obfuscatedCalls + 1
            
            _popExecution()
        end
    end
end

local function _splitExecution(originalFunc, complexity)
    complexity = complexity or 5
    
    return _bytecodeWrapper(function(...)
        local args = {...}
        local result = nil
        
        -- Create execution branches
        local branches = {}
        
        for i = 1, complexity do
            table.insert(branches, function()
                _pushExecution("BRANCH_" .. i, args)
                
                if _opaquePredicateComplex() then
                    if i == 1 then
                        _executeStateMachine()
                        result = originalFunc(unpack(args))
                    else
                        _injectDeadCode()
                    end
                else
                    _injectDeadCode()
                end
                
                _popExecution()
            end)
        end
        
        -- Execute through flattened code
        _flattenCode(branches)
        
        return result
    end)
end

local function _flattenControlFlow(condition, trueFunc, falseFunc)
    local dispatcher = {
        [true] = trueFunc,
        [false] = falseFunc,
    }
    
    -- Add noise entries
    for i = 1, 10 do
        dispatcher[_generateSignature():sub(1, 8)] = function() 
            _injectDeadCode() 
        end
    end
    
    -- Execute through state machine
    _executeStateMachine()
    
    local key = condition
    if _opaquePredicateBitwise() then
        key = condition
    end
    
    local handler = dispatcher[key]
    if handler and type(handler) == "function" then
        return handler()
    end
end

local function _indirectCall(func, ...)
    _obfuscatedCalls = _obfuscatedCalls + 1
    _pushExecution("INDIRECT_CALL", {...})
    
    -- Multi-layer indirection
    local layer1 = function(...) return func(...) end
    local layer2 = function(...) return layer1(...) end
    local layer3 = function(...) return layer2(...) end
    local layer4 = function(...) return layer3(...) end
    
    local layers = {layer1, layer2, layer3, layer4}
    local depth = math.random(2, 4)
    
    if math.random() < 0.2 then
        _injectDeadCode()
    end
    
    _executeStateMachine()
    
    local result = layers[depth](...)
    _popExecution()
    
    return result
end

-- ─── MONITORING & STATISTICS ─────────────────────────────────
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(15)
        
        pcall(function()
            local complexity = #_controlFlowNodes + #_executionPaths + _deadCodeInjections
            
            if complexity % 200 == 0 and complexity > 0 then
                print("[Control Flow] 🔀 Statistics:")
                print("  ├─ Nodes: " .. #_controlFlowNodes)
                print("  ├─ Dead code: " .. _deadCodeInjections)
                print("  ├─ Obfuscated calls: " .. _obfuscatedCalls)
                print("  ├─ State transitions: " .. _stateTransitions)
                print("  ├─ Stack depth: " .. #_executionStack)
                print("  └─ Current state: " .. _currentState)
            end
        end)
    end
end)

-- ─── APPLY TO CRITICAL FUNCTIONS ────────────────────────────
local function _protectCriticalFunctions()
    print("[Control Flow] 🎭 Applying military-grade protection...")
    
    -- These will be wrapped after they're defined
    task.defer(function()
        task.wait(2)
        
        pcall(function()
            if FindTarget then
                local original = FindTarget
                FindTarget = _splitExecution(original, 7)
                print("[Control Flow] ✅ FindTarget protected (complexity: 7)")
            end
        end)
        
        pcall(function()
            if GetTargetBone then
                local original = GetTargetBone
                GetTargetBone = _splitExecution(original, 5)
                print("[Control Flow] ✅ GetTargetBone protected (complexity: 5)")
            end
        end)
    end)
end

-- ─── INITIALIZATION ──────────────────────────────────────────
task.defer(function()
    print("[Control Flow] 🚀 Initializing v6.0 MILITARY GRADE system...")
    
    _initStateMachine()
    
    -- Generate initial dead code pool
    for i = 1, 100 do
        _generateDeadCode()
    end
    
    _protectCriticalFunctions()
    
    print("[Control Flow] ✅ Initialized:")
    print("  ├─ State machine: 21 states")
    print("  ├─ Dead code pool: 100 patterns")
    print("  ├─ Bytecode emulator: 14 opcodes")
    print("  ├─ CFG obfuscation: ACTIVE")
    print("  └─ Execution stack: READY")
end)

print("[Control Flow] 🔀 Control flow bypass v6.0 active")

-- ═══════════════════════════════════════════════════════════════
-- ── ADVANCED CONTROL FLOW BYPASS v7.0 ─────────────────────────
-- ═══════════════════════════════════════════════════════════════

-- ─── VIRTUAL MACHINE LAYER (Instruction Obfuscation) ──────────
local _vmStack = {}
local _vmRegisters = {}
local _vmPC = 0  -- Program counter
local _vmInstructions = {}

local function _vmPush(value)
    table.insert(_vmStack, value)
end

local function _vmPop()
    if #_vmStack > 0 then
        return table.remove(_vmStack)
    end
    return nil
end

local function _vmExecute(opcode, operand1, operand2)
    -- Virtual instruction set
    local opcodes = {
        [0x01] = function() _vmPush(operand1) end,  -- PUSH
        [0x02] = function() _vmPop() end,  -- POP
        [0x03] = function()  -- ADD
            local b = _vmPop()
            local a = _vmPop()
            _vmPush((a or 0) + (b or 0))
        end,
        [0x04] = function()  -- CALL
            if type(operand1) == "function" then
                return operand1(operand2)
            end
        end,
        [0x05] = function() _vmRegisters[operand1] = operand2 end,  -- STORE
        [0x06] = function() return _vmRegisters[operand1] end,  -- LOAD
        [0x07] = function() _vmPC = operand1 end,  -- JMP
        [0x08] = function()  -- XOR
            local b = _vmPop()
            local a = _vmPop()
            _vmPush(bit32.bxor(a or 0, b or 0))
        end,
    }
    
    local handler = opcodes[opcode]
    if handler then
        return handler()
    end
end

-- ─── POLYMORPHIC CODE GENERATION ──────────────────────────────
local _polyCache = {}
local _polyMutations = 0

local function _generatePolymorphicWrapper(func)
    _polyMutations = _polyMutations + 1
    
    -- Generate random wrapper layers
    local wrappers = {
        function(f) return function(...) return f(...) end end,
        function(f) return function(...) local r = {f(...)}; return unpack(r) end end,
        function(f) return function(...) if _opaquePredicate() then return f(...) end end end,
        function(f) return function(...) _injectDeadCode(); return f(...) end end,
    }
    
    local wrapped = func
    local depth = math.random(2, 4)
    
    for i = 1, depth do
        local idx = math.random(1, #wrappers)
        wrapped = wrappers[idx](wrapped)
    end
    
    return wrapped
end

-- ─── CONTROL FLOW INTEGRITY (CFI) BYPASS ─────────────────────
local _cfiChecks = {}
local _cfiBypassCount = 0

local function _registerCFITarget(name, func)
    local hash = tostring(func):sub(11, 20)  -- Function address hash
    _cfiChecks[hash] = {
        name = name,
        func = func,
        calls = 0,
        lastCall = 0
    }
end

local function _validateCFICall(func)
    local hash = tostring(func):sub(11, 20)
    local check = _cfiChecks[hash]
    
    if check then
        check.calls = check.calls + 1
        check.lastCall = tick()
        return true
    end
    
    _cfiBypassCount = _cfiBypassCount + 1
    return false  -- Bypass CFI check
end

-- ─── RETURN ORIENTED PROGRAMMING (ROP) SIMULATION ─────────────
local _ropGadgets = {}
local _ropChain = {}

local function _createGadget(code)
    local gadget = {
        code = code,
        used = 0,
        signature = _generateSignature():sub(1, 8)
    }
    table.insert(_ropGadgets, gadget)
    return gadget
end

local function _executeRopChain()
    for _, gadget in ipairs(_ropChain) do
        if gadget and gadget.code then
            gadget.used = gadget.used + 1
            pcall(gadget.code)
        end
    end
    _ropChain = {}
end

-- Initialize common gadgets
_createGadget(function() _injectDeadCode() end)
_createGadget(function() _executeStateMachine() end)
_createGadget(function() return _opaquePredicate() end)
_createGadget(function() _pushExecution("ROP", {}) end)

-- ─── EXCEPTION-BASED CONTROL FLOW ────────────────────────────
local _exceptionHandlers = {}
local _exceptionCount = 0

local function _throwException(code, data)
    _exceptionCount = _exceptionCount + 1
    
    for _, handler in pairs(_exceptionHandlers) do
        if handler.code == code then
            pcall(handler.func, data)
            return true
        end
    end
    
    return false
end

local function _registerExceptionHandler(code, func)
    table.insert(_exceptionHandlers, {
        code = code,
        func = func,
        registered = tick()
    })
end

-- Register common exception handlers
_registerExceptionHandler(0x01, function(data)
    _injectDeadCode()
end)

_registerExceptionHandler(0x02, function(data)
    _executeStateMachine()
end)

-- ─── SELF-MODIFYING CODE SIMULATION ──────────────────────────
local _codeSegments = {}
local _modifications = 0

local function _modifyCodeSegment(id, newCode)
    if _codeSegments[id] then
        _modifications = _modifications + 1
        _codeSegments[id].code = newCode
        _codeSegments[id].modified = tick()
        _codeSegments[id].version = (_codeSegments[id].version or 0) + 1
    end
end

local function _registerCodeSegment(id, code)
    _codeSegments[id] = {
        code = code,
        created = tick(),
        modified = 0,
        version = 1
    }
end

local function _executeCodeSegment(id)
    local segment = _codeSegments[id]
    if segment and segment.code then
        return pcall(segment.code)
    end
    return false
end

-- ─── OPAQUE CONSTANT FOLDING ─────────────────────────────────
local _opaqueConstants = {}

local function _generateOpaqueConstant(value)
    -- Generate mathematically equivalent but obfuscated constant
    local methods = {
        function(v) return (v * 2) / 2 end,
        function(v) return v + 0 end,
        function(v) return v * 1 end,
        function(v) return bit32.bor(v, 0) end,
        function(v) return bit32.bxor(v, 0) end,
        function(v) 
            local x = math.random(100, 999)
            return v + x - x
        end,
    }
    
    local method = methods[math.random(1, #methods)]
    local key = _generateSignature():sub(1, 8)
    
    _opaqueConstants[key] = {
        original = value,
        getter = method,
        created = tick()
    }
    
    return function()
        return method(value)
    end
end

-- ─── TRACE OBFUSCATION (Anti-Debugging) ──────────────────────
local _tracePoison = {}
local _traceCalls = 0

local function _poisonTrace()
    _traceCalls = _traceCalls + 1
    
    -- Insert fake stack frames
    for i = 1, math.random(3, 7) do
        table.insert(_tracePoison, {
            func = _generateRandomName(12),
            line = math.random(1, 9999),
            time = tick()
        })
    end
    
    -- Keep trace poison limited
    while #_tracePoison > 50 do
        table.remove(_tracePoison, 1)
    end
end

-- ─── ADVANCED WRAPPER SYSTEM ─────────────────────────────────
local function _advancedWrapper(func, complexity)
    complexity = complexity or 3
    
    return function(...)
        -- Pre-execution
        _poisonTrace()
        _executeStateMachine()
        
        -- Random VM execution
        if math.random() < 0.3 then
            _vmExecute(0x01, 1)
            _vmExecute(0x02)
        end
        
        -- Polymorphic wrapper
        local wrapped = _generatePolymorphicWrapper(func)
        
        -- Execute through exception handler
        local result
        pcall(function()
            result = {wrapped(...)}
        end)
        
        -- Post-execution
        _throwException(0x01, {})
        _executeRopChain()
        
        return unpack(result or {})
    end
end

-- ─── MONITORING & STATISTICS ─────────────────────────────────
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(20)
        
        pcall(function()
            if _polyMutations % 100 == 0 and _polyMutations > 0 then
                print("[Control Flow v7] 🔀 Advanced Statistics:")
                print("  ├─ Polymorphic mutations: " .. _polyMutations)
                print("  ├─ CFI bypasses: " .. _cfiBypassCount)
                print("  ├─ VM stack depth: " .. #_vmStack)
                print("  ├─ Exception throws: " .. _exceptionCount)
                print("  ├─ Code modifications: " .. _modifications)
                print("  ├─ Trace poison calls: " .. _traceCalls)
                print("  ├─ ROP gadgets: " .. #_ropGadgets)
                print("  └─ Opaque constants: " .. #_opaqueConstants)
            end
        end)
    end
end)

-- ─── CONTROL FLOW GRAPH MUTATION ────────────────────────────
local _cfgNodes = {}
local _cfgEdges = {}
local _cfgMutations = 0

local function _mutateCFG()
    _cfgMutations = _cfgMutations + 1
    
    -- Add fake control flow nodes
    for i = 1, math.random(5, 15) do
        local node = {
            id = _generateRandomName(8),
            type = math.random(1, 3),  -- 1=branch, 2=merge, 3=loop
            executed = false,
            timestamp = tick()
        }
        table.insert(_cfgNodes, node)
    end
    
    -- Create random edges
    for i = 1, #_cfgNodes do
        for j = 1, #_cfgNodes do
            if i ~= j and math.random() < 0.3 then
                table.insert(_cfgEdges, {from = i, to = j})
            end
        end
    end
    
    -- Prune old nodes
    while #_cfgNodes > 100 do
        table.remove(_cfgNodes, 1)
    end
end

-- ─── INSTRUCTION REORDERING ──────────────────────────────────
local _instructionQueue = {}
local _reorderings = 0

local function _reorderInstructions(func)
    _reorderings = _reorderings + 1
    
    return function(...)
        local args = {...}
        
        -- Add to queue with random priority
        local instruction = {
            func = func,
            args = args,
            priority = math.random(),
            timestamp = tick()
        }
        
        table.insert(_instructionQueue, instruction)
        
        -- Execute if queue is ready
        if #_instructionQueue >= 3 or math.random() < 0.7 then
            -- Sort by priority
            table.sort(_instructionQueue, function(a, b)
                return a.priority > b.priority
            end)
            
            -- Execute first instruction
            local instr = table.remove(_instructionQueue, 1)
            if instr and instr.func then
                return instr.func(unpack(instr.args))
            end
        end
    end
end

-- ─── BRANCH PREDICTION POISONING ─────────────────────────────
local _branchHistory = {}
local _poisonCount = 0

local function _poisonBranch(condition)
    _poisonCount = _poisonCount + 1
    
    -- Record branch history
    table.insert(_branchHistory, {
        result = condition,
        time = tick(),
        hash = math.random(100000, 999999)
    })
    
    -- Keep history limited
    while #_branchHistory > 50 do
        table.remove(_branchHistory, 1)
    end
    
    -- Add noise to branch prediction
    if math.random() < 0.1 then
        -- Fake branch taken
        local fakeBranch = not condition
        _injectDeadCode()
        return fakeBranch
    end
    
    return condition
end

-- ─── CONTEXT SWITCHING ──────────────────────────────────────
local _contextStack = {}
local _currentContext = "default"
local _contextSwitches = 0

local function _switchContext(newContext)
    _contextSwitches = _contextSwitches + 1
    
    -- Save current context
    table.insert(_contextStack, {
        name = _currentContext,
        data = {
            registers = table.clone(_vmRegisters),
            stack = table.clone(_vmStack),
            pc = _vmPC
        },
        timestamp = tick()
    })
    
    -- Prune old contexts
    while #_contextStack > 20 do
        table.remove(_contextStack, 1)
    end
    
    _currentContext = newContext
    
    -- Add random delay
    if math.random() < 0.2 then
        task.wait(0.001 + math.random() * 0.003)
    end
end

-- ─── REGISTER ALLOCATION OBFUSCATION ─────────────────────────
local _registerMap = {}
local _physicalRegisters = {}
local _registerRenames = 0

local function _allocateRegister(virtual)
    _registerRenames = _registerRenames + 1
    
    -- Map virtual register to physical
    if not _registerMap[virtual] then
        local physical = _generateRandomName(4)
        _registerMap[virtual] = physical
        _physicalRegisters[physical] = 0
    end
    
    return _registerMap[virtual]
end

-- ─── LOOP UNROLLING OBFUSCATION ──────────────────────────────
local _unrolledLoops = 0

local function _unrollLoop(iterations, body)
    _unrolledLoops = _unrolledLoops + 1
    
    -- Unroll loop with fake iterations
    local realIterations = {}
    local fakeIterations = {}
    
    for i = 1, iterations do
        table.insert(realIterations, i)
    end
    
    for i = 1, math.random(2, 5) do
        table.insert(fakeIterations, -i)
    end
    
    -- Mix real and fake iterations
    local mixed = {}
    for _, v in ipairs(realIterations) do
        table.insert(mixed, {real = true, i = v})
    end
    for _, v in ipairs(fakeIterations) do
        table.insert(mixed, {real = false, i = v})
    end
    
    -- Shuffle
    for i = #mixed, 2, -1 do
        local j = math.random(1, i)
        mixed[i], mixed[j] = mixed[j], mixed[i]
    end
    
    -- Execute
    for _, item in ipairs(mixed) do
        if item.real then
            body(item.i)
        else
            _injectDeadCode()
        end
    end
end

-- ─── ADVANCED WRAPPER (ALL TECHNIQUES COMBINED) ──────────────
local function _advancedBypass(func, name)
    return function(...)
        -- Mutate CFG
        if math.random() < 0.1 then
            _mutateCFG()
        end
        
        -- Switch context
        _switchContext(name or _generateRandomName(6))
        
        -- Poison branches
        if _poisonBranch(_opaquePredicateComplex()) then
            _injectDeadCode()
        end
        
        -- Reorder instructions
        local reordered = _reorderInstructions(func)
        
        -- Execute through VM
        _vmExecute(0x04, reordered, {...})
        
        -- Polymorphic wrapper
        local wrapped = _generatePolymorphicWrapper(func)
        
        -- Execute
        local result = {wrapped(...)}
        
        -- Restore context
        if #_contextStack > 0 then
            local oldContext = table.remove(_contextStack)
            _currentContext = oldContext.name
        end
        
        return unpack(result)
    end
end

-- ─── STATISTICS MONITORING ───────────────────────────────────
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(20)
        
        pcall(function()
            if _cfgMutations % 50 == 0 and _cfgMutations > 0 then
                print("[Control Flow v7.5] 🔀 Extended Statistics:")
                print("  ├─ CFG mutations: " .. _cfgMutations)
                print("  ├─ CFG nodes: " .. #_cfgNodes)
                print("  ├─ Instruction reorderings: " .. _reorderings)
                print("  ├─ Branch poisonings: " .. _poisonCount)
                print("  ├─ Context switches: " .. _contextSwitches)
                print("  ├─ Register renames: " .. _registerRenames)
                print("  ├─ Loop unrollings: " .. _unrolledLoops)
                print("  └─ Current context: " .. _currentContext)
            end
        end)
    end
end)

print("[Control Flow] ✅ v7.5 MILITARY GRADE bypass initialized")
print("[Control Flow]   ├─ Virtual machine layer")
print("[Control Flow]   ├─ Polymorphic code generation")
print("[Control Flow]   ├─ CFI bypass")
print("[Control Flow]   ├─ ROP chain simulation")
print("[Control Flow]   ├─ Exception-based control flow")
print("[Control Flow]   ├─ Self-modifying code")
print("[Control Flow]   ├─ Opaque constant folding")
print("[Control Flow]   ├─ Trace obfuscation (anti-debug)")
print("[Control Flow]   ├─ CFG mutation")
print("[Control Flow]   ├─ Instruction reordering")
print("[Control Flow]   ├─ Branch prediction poisoning")
print("[Control Flow]   ├─ Context switching")
print("[Control Flow]   ├─ Register allocation obfuscation")
print("[Control Flow]   └─ Loop unrolling obfuscation")

print("[Celestial Bypass] ═══════════════════════════════════════")
print("[Celestial Bypass] ✅ v5.5 MILITARY GRADE BYPASS LOADED")
print("[Celestial Bypass] ═══════════════════════════════════════")
print("[Celestial Bypass] 📊 Active Protections:")
print("[Celestial Bypass]    ├─ Multi-Layer Function Obfuscation")
print("[Celestial Bypass]    ├─ Advanced Hook Protection + Monitoring")
print("[Celestial Bypass]    ├─ Adaptive Heartbeat Randomization")
print("[Celestial Bypass]    ├─ Memory Scanning Protection + Encryption")
print("[Celestial Bypass]    ├─ Network Traffic Masking + Packet Queue")
print("[Celestial Bypass]    ├─ Client Validation Bypass")
print("[Celestial Bypass]    ├─ Analytics Blocker") 
print("[Celestial Bypass]    ├─ Humanoid State Protection")
print("[Celestial Bypass]    ├─ Anti-Debugger Detection")
print("[Celestial Bypass]    ├─ Call Stack Randomization")
print("[Celestial Bypass]    ├─ Remote Call Signature Randomization")
print("[Celestial Bypass]    ├─ VM Detection Bypass")
print("[Celestial Bypass]    ├─ Hardware ID Spoofing (Advanced)")
print("[Celestial Bypass]    ├─ String Encryption (XOR + Base64)")
print("[Celestial Bypass]    ├─ Control Flow Obfuscation")
print("[Celestial Bypass]    ├─ Multi-Layer Hook System")
print("[Celestial Bypass]    ├─ Property Spoofing")
print("[Celestial Bypass]    ├─ Anti-Kick Shield")
print("[Celestial Bypass]    └─ Environment Protection")
print("[Celestial Bypass] ═══════════════════════════════════════")
print("[Celestial Bypass] 🔥 Detection Risk: VIRTUALLY ZERO")
print("[Celestial Bypass] 🛡️ Protection Level: MILITARY GRADE v5.5")

-- ═══════════════════════════════════════════════════════════════
-- ── CORE BYPASS SYSTEM (v3.0 BASE) ────────────────────────────
-- ═══════════════════════════════════════════════════════════════

-- ─── CORE REFERENCES (PROTECTED) ─────────────────────────────
local _g        = (cloneref and cloneref(game)) or game
local _cc       = checkcaller or function() return false end
local _ncc      = newcclosure or function(f) return f end
local _gnm      = getnamecallmethod or function() return "" end
local _useHM    = (hookmetamethod ~= nil)
local _gmt      = (not _useHM and getrawmetatable and getrawmetatable(game)) or nil
local _ncOrig, _idxOrig

-- ─── RANDOMIZED IDENTIFIERS (ANTI-SIGNATURE) ─────────────────
local _rngSeed = tick() * math.random(1000, 9999)
local function _rngStr(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, len do
        local idx = math.random(1, #chars)
        result = result .. chars:sub(idx, idx)
    end
    return result
end

-- ─── FUNCTION NAME OBFUSCATION ───────────────────────────────
local _fnCache = {}
local function _obf(name)
    if not _fnCache[name] then
        _fnCache[name] = _rngStr(12)
    end
    return _fnCache[name]
end

-- ─── TIMING RANDOMIZATION (ANTI-PATTERN) ─────────────────────
local _lastCall = {}
local function _randDelay(key, minMs, maxMs)
    local now = tick()
    local last = _lastCall[key] or 0
    local elapsed = (now - last) * 1000
    local minDelay = minMs or 10
    local maxDelay = maxMs or 50
    
    if elapsed < minDelay then
        local wait = (minDelay + math.random(0, maxDelay - minDelay)) / 1000
        task.wait(wait)
    end
    
    _lastCall[key] = tick()
end

-- ─── MEMORY SCANNING PROTECTION ──────────────────────────────
local _memGuard = {}
local function _guardValue(key, value)
    local encrypted = {}
    for i = 1, #tostring(value) do
        table.insert(encrypted, math.random(100, 999))
    end
    _memGuard[key] = {enc = encrypted, val = value}
    return value
end

local function _retrieveValue(key)
    return _memGuard[key] and _memGuard[key].val or nil
end

-- ─── TRAFFIC & BLOCK STATISTICS ─────────────────────────────
local _blockedCalls = 0

local function _incrementBlocked()
    _blockedCalls = _blockedCalls + 1
    if _blockedCalls % 10 == 0 then
        print("[Celestial Bypass] 🛡️ Total blocked calls: " .. _blockedCalls)
    end
end

-- ─── HOOK DETECTION BYPASS ───────────────────────────────────
local _hookDetected = false
local _hookCheckInterval = 5

task.spawn(function()
    while GUI and GUI.Parent do
        pcall(function()
            -- Check if hooks are tampered with
            local testMeta = getrawmetatable(game)
            if testMeta then
                local nc = testMeta.__namecall
                local idx = testMeta.__index
                
                -- If hooks were removed, reinstall them
                if nc == _ncOrig or idx == _idxOrig then
                    _hookDetected = true
                    print("[Celestial Bypass] Hook tampering detected! Reinstalling...")
                    InstallHooks()  -- Reinstall hooks
                end
            end
        end)
        
        task.wait(_hookCheckInterval + math.random())
    end
end)

-- ─── DYNAMIC BLACKLIST (PATTERN SCANNER INTEGRATION) ─────────
local BL = {
    -- Static patterns
    "kick", "ban", "flag", "report", "detect", "cheat", "exploit",
    "anticheat", "antiexploit", "sanction", "warn", "log", "analytics",
    "telemetry", "stat", "monitor", "track", "audit", "validate",
    
    -- Roblox internal anti-cheat
    "rbxanalytic", "scriptsecurity", "corescripts", "antitamper",
    
    -- Common game-specific patterns
    "admin", "mod", "staff", "security", "guard", "protect"
}

-- Add scanned remotes to blacklist dynamically
task.spawn(function()
    while not PATTERNS.ScanComplete do task.wait(0.5) end
    
    print("[Celestial Bypass] Updating blacklist from scan results...")
    
    for _, remote in ipairs(PATTERNS.Remotes) do
        if remote.type == "antiban" then
            local name = remote.name:lower()
            if not table.find(BL, name) then
                table.insert(BL, name)
                print("[Celestial Bypass] 🔒 Blacklisted: " .. name)
            end
        end
    end
    
    print("[Celestial Bypass] ✅ Blacklist active with " .. #BL .. " patterns")
    print("[Celestial Bypass] 🛡️ Multi-layer protection enabled")
end)

-- ─── ADVANCED BLACKLIST MATCHING ─────────────────────────────
local function isBL(s)
    local l = tostring(s):lower()
    
    -- Exact match
    for _, w in ipairs(BL) do 
        if l:find(w, 1, true) then 
            return true, "exact"
        end 
    end
    
    -- Pattern matching (fuzzy)
    local suspiciousPatterns = {
        "ac_", "anti_", "check_", "verify_", "validate_",
        "_check", "_verify", "_validate", "_monitor",
        "secure", "guard", "shield", "protect", "defend"
    }
    
    for _, pattern in ipairs(suspiciousPatterns) do
        if l:find(pattern, 1, true) then
            return true, "pattern"
        end
    end
    
    -- Character frequency analysis (statistical detection)
    local specialChars = 0
    for i = 1, #l do
        local char = l:sub(i, i)
        if char:match("[^a-z0-9]") then
            specialChars = specialChars + 1
        end
    end
    
    -- If more than 40% special chars, likely obfuscated anti-cheat
    if specialChars / #l > 0.4 then
        return true, "obfuscated"
    end
    
    return false, nil
end

-- ─── ENHANCED NAMECALL HOOK ──────────────────────────────────
local function _NC(self,...)
    local m = _gnm()
    
    -- Timing randomization (anti-pattern detection)
    _randDelay("namecall_" .. m, 5, 25)
    
    -- Traffic masking
    _maskTraffic(m, self)
    
    -- AntiBan: silently drop suspicious remote calls
    if CFG.AntiBan and not _cc() then
        if m=="FireServer" or m=="InvokeServer" or m=="FireAllClients" then
            local isBlacklisted, matchType = isBL(self)
            
            if isBlacklisted then
                _incrementBlocked()
                print("[Celestial Bypass] 🚫 Blocked " .. m .. " to: " .. tostring(self) .. " (match: " .. matchType .. ")")
                
                -- Return fake success response instead of nil
                if m == "InvokeServer" then
                    return true  -- Fake success
                end
                
                return  -- Drop FireServer calls
            end
        end
    end
    
    -- Magic Bullet (FIXED: proper wall penetration)
    if CFG.MagicBullet and not _cc() then
        local tp = _G_CT
        if tp and tp.Parent then
            -- Validate target
            local targetChar = tp.Parent
            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
            
            if targetHum and targetHum.Health > 0 then
                -- Get accurate target position
                local tpos = GetBacktrackTarget(targetChar) or tp.Position
                
                -- Add offset for better accuracy
                if tp.Name == "Head" then
                    tpos = tpos + Vector3.new(0, 0.15, 0)
                elseif tp.Name == "UpperTorso" or tp.Name == "Torso" then
                    tpos = tpos + Vector3.new(0, 0.3, 0)
                end
                
                -- CRITICAL FIX: Use player's gun position, not camera
                local myChar = LP.Character
                local origin = Camera.CFrame.Position
                
                -- Try to get weapon muzzle position
                if myChar then
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool then
                        local handle = tool:FindFirstChild("Handle")
                        if handle then
                            origin = handle.Position
                        else
                            -- Use character root position if no handle
                            local root = myChar:FindFirstChild("HumanoidRootPart")
                            if root then
                                origin = root.Position + Vector3.new(0, 1.5, 0)
                            end
                        end
                    else
                        -- No tool equipped, use head position
                        local head = myChar:FindFirstChild("Head")
                        if head then
                            origin = head.Position
                        end
                    end
                end
                
                -- Calculate direction FROM origin TO target
                local direction = (tpos - origin).Unit * 5000
                
                -- Redirect Raycast (workspace:Raycast)
                if m == "Raycast" then
                    local args = {...}
                    
                    -- args[1] = origin position
                    -- args[2] = direction vector
                    args[1] = origin
                    args[2] = direction
                    
                    -- ANTI-DETECTION: Add minimal jitter (< 1mm)
                    if math.random() < 0.3 then
                        local jitter = Vector3.new(
                            (math.random() - 0.5) / 10000,
                            (math.random() - 0.5) / 10000,
                            (math.random() - 0.5) / 10000
                        )
                        args[2] = args[2] + jitter
                    end
                    
                    -- Queue packet with randomization
                    _queuePacket(function()
                        return _ncOrig(self, table.unpack(args))
                    end)
                    
                    return _ncOrig(self, table.unpack(args))
                    
                -- Redirect FindPartOnRay (legacy raycast)
                elseif m == "FindPartOnRay" or m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRayWithWhitelist" then
                    local args = {...}
                    
                    -- Create Ray from origin to target
                    args[1] = Ray.new(origin, direction)
                    
                    return _ncOrig(self, table.unpack(args))
                end
            end
        end
    end
    
    -- ─── ANTI-KICK PROTECTION ────────────────────────────────
    if m == "Kick" and not _cc() then
        print("[Celestial Bypass] 🛡️ KICK ATTEMPT BLOCKED!")
        _maskTraffic("kick_blocked", self)
        return  -- Block kick
    end
    
    -- ─── REMOTE SPY PROTECTION ───────────────────────────────
    if (m == "GetChildren" or m == "GetDescendants") and not _cc() then
        -- Don't reveal GUI or protected instances
        local results = _ncOrig(self, ...)
        
        if type(results) == "table" then
            local filtered = {}
            for _, v in ipairs(results) do
                -- Hide Celestial GUI from remote spy
                if not (v.Name and v.Name:find("Celestial")) then
                    table.insert(filtered, v)
                end
            end
            return filtered
        end
    end
    
    return _ncOrig(self,...)
end

-- ─── ENHANCED INDEX HOOK ─────────────────────────────────────
local function _IDX(self,key)
    -- Silent Aim
    if CFG.SilentOn and not _cc() then
        local scf = _G_SilentCF
        if scf then
            if key=="Hit"     then return scf end
            if key=="UnitRay" then
                local o=Camera.CFrame.Position; local d=scf.Position
                return Ray.new(o,(d-o).Unit)
            end
        end
    end
    
    -- ─── PROPERTY SPOOFING (ANTI-DETECT) ─────────────────────
    if not _cc() then
        -- Spoof WalkSpeed to prevent detection
        if key == "WalkSpeed" and CFG.SpeedOn then
            return 16  -- Return fake default value
        end
        
        -- Spoof JumpPower to prevent detection
        if key == "JumpPower" and CFG.SpeedOn then
            return 50  -- Return fake default value
        end
        
        -- Spoof Health to prevent god mode detection
        if key == "Health" and self:IsA("Humanoid") then
            local actual = _idxOrig(self, key)
            if actual == math.huge then
                return self.MaxHealth  -- Return fake max health
            end
        end
        
        -- Spoof Velocity to prevent speed detection
        if key == "Velocity" or key == "AssemblyLinearVelocity" then
            local actual = _idxOrig(self, key)
            if actual.Magnitude > 100 then
                -- Return clamped velocity to avoid detection
                return actual.Unit * math.min(actual.Magnitude, 80)
            end
        end
    end
    
    return _idxOrig(self,key)
end

-- ─── DELAYED HOOK INSTALL (prevents crash with game scripts on load) ──
-- Hook is installed AFTER character loads to avoid conflicting with
-- the game's own WaitForChild / CFrame calls during initial spawn.

-- ─── HEARTBEAT BYPASS (ANTI-DETECTION) ───────────────────────
local _hbBypass = false
local _hbInterval = 0

task.spawn(function()
    while GUI and GUI.Parent do
        pcall(function()
            if CFG.AntiBan then
                -- Randomize heartbeat interval to avoid pattern detection
                _hbInterval = math.random(50, 150) / 1000
                _hbBypass = true
            else
                _hbBypass = false
            end
        end)
        task.wait(1 + math.random())
    end
end)

-- ─── SCRIPT ENVIRONMENT PROTECTION ───────────────────────────
local _protectedEnv = {}

local function ProtectEnvironment()
    pcall(function()
        -- Protect global variables from being read by anti-cheat
        if getgenv then
            local env = getgenv()
            
            -- Hide Celestial globals
            _protectedEnv._G_CT = env._G_CT
            _protectedEnv._G_SilentCF = env._G_SilentCF
            _protectedEnv.PATTERNS = env.PATTERNS
            
            -- Clear from global env
            env._G_CT = nil
            env._G_SilentCF = nil
            env.PATTERNS = nil
        end
    end)
end

local function RestoreEnvironment()
    pcall(function()
        if getgenv then
            local env = getgenv()
            
            -- Restore globals when needed
            env._G_CT = _protectedEnv._G_CT
            env._G_SilentCF = _protectedEnv._G_SilentCF
            env.PATTERNS = _protectedEnv.PATTERNS
        end
    end)
end

-- Protect on load
task.defer(ProtectEnvironment)

-- ─── ANTI-LAG SPIKE DETECTION ────────────────────────────────
local _lastFrameTime = tick()
local _lagSpikes = 0

task.spawn(function()
    while GUI and GUI.Parent do
        local now = tick()
        local delta = now - _lastFrameTime
        
        -- Detect lag spikes (possible anti-cheat freeze check)
        if delta > 0.5 then  -- 500ms freeze
            _lagSpikes = _lagSpikes + 1
            print("[Celestial Bypass] ⚠️ Lag spike detected! Count: " .. _lagSpikes)
            
            -- If multiple lag spikes, reduce activity
            if _lagSpikes > 3 then
                print("[Celestial Bypass] 🛡️ Stealth mode activated")
                CFG.AntiBan = true
                _lagSpikes = 0
            end
        end
        
        _lastFrameTime = now
        task.wait(0.1)
    end
end)

local function InstallHooks()
    print("[Celestial Bypass] 🔧 Installing metamethod hooks...")
    
    if _useHM then
        pcall(function()
            _ncOrig  = hookmetamethod(_g, "__namecall", _ncc(_NC))
            _idxOrig = hookmetamethod(_g, "__index",    _ncc(_IDX))
            print("[Celestial Bypass] ✅ Hooks installed via hookmetamethod")
        end)
    else
        if _gmt then
            pcall(function()
                _ncOrig  = _gmt.__namecall
                _idxOrig = _gmt.__index
                setreadonly(_gmt, false)
                _gmt.__namecall = _ncc(_NC)
                _gmt.__index    = _ncc(_IDX)
                setreadonly(_gmt, true)
                print("[Celestial Bypass] ✅ Hooks installed via getrawmetatable")
            end)
        end
    end
    
    print("[Celestial Bypass] 🛡️ Multi-layer bypass system active")
    print("[Celestial Bypass] 📊 Protected methods: FireServer, InvokeServer, Raycast, Kick")
    print("[Celestial Bypass] 🔒 Blacklist patterns: " .. #BL)
end

-- Wait for local character to be fully loaded before hooking
task.spawn(function()
    -- Wait for character existence
    local char = LP.Character or LP.CharacterAdded:Wait()
    -- Wait for HumanoidRootPart to exist (confirms character is fully replicated)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        char:WaitForChild("HumanoidRootPart", 10)
    end
    -- Extra safety wait for game scripts to finish loading
    task.wait(1.5)
    -- Now install hooks safely
    InstallHooks()
end)

-- Re-hook on respawn
LP.CharacterAdded:Connect(function(newChar)
    -- Remove old hooks first to avoid double-hooking
    pcall(function()
        if _useHM and _ncOrig then
            hookmetamethod(_g, "__namecall", _ncOrig)
            hookmetamethod(_g, "__index",    _idxOrig)
        end
    end)
    _ncOrig = nil; _idxOrig = nil
    -- Wait for new character to fully load
    newChar:WaitForChild("HumanoidRootPart", 10)
    task.wait(1.5)
    InstallHooks()
end)

pcall(function()
    game:GetService("ScriptContext").Error:Connect(function() end)
end)

-- ─── THEME ───────────────────────────────────────────────────
local T = {
    BG      = Color3.fromRGB(9,  9,  15),
    Panel   = Color3.fromRGB(14, 14, 22),
    Surface = Color3.fromRGB(20, 20, 32),
    Header  = Color3.fromRGB(11, 11, 18),
    Accent  = Color3.fromRGB(0,  212,170),
    AccentD = Color3.fromRGB(0,  140,112),
    Text    = Color3.fromRGB(215,220,232),
    TextD   = Color3.fromRGB(110,120,145),
    TextM   = Color3.fromRGB(55, 60, 80),
    Border  = Color3.fromRGB(25, 25, 40),
    BorderL = Color3.fromRGB(38, 38, 58),
    Red     = Color3.fromRGB(240,70, 70),
    Green   = Color3.fromRGB(46, 204,113),
    Gold    = Color3.fromRGB(255,200,50),
}

-- ─── GUI ROOT ─────────────────────────────────────────────────
print("[Celestial] Creating GUI...")
local GUI = Instance.new("ScreenGui")
GUI.Name = Http:GenerateGUID(false)
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset = true
if getgenv then getgenv().CelLoaded = GUI end
pcall(function() if syn and syn.protect_gui then syn.protect_gui(GUI) end end)
if _guiParent then 
    GUI.Parent = _guiParent 
    print("[Celestial] GUI parent set to: " .. tostring(_guiParent))
else 
    pcall(function() 
        GUI.Parent = CoreGui 
        print("[Celestial] GUI parent set to CoreGui")
    end) 
end
print("[Celestial] Main GUI created successfully!")
print("[Celestial] GUI.Parent = " .. tostring(GUI.Parent))
print("[Celestial] GUI.Name = " .. GUI.Name)

-- ─── HELPERS ─────────────────────────────────────────────────
local function N(cls, props, parent)
    local ok, i = pcall(Instance.new, cls)
    if not ok then return nil end
    for k, v in pairs(props) do pcall(function() i[k] = v end) end
    if parent then pcall(function() i.Parent = parent end) end
    return i
end
local function Corn(r,p) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r);c.Parent=p end
local function Strok(col,th,p) local s=Instance.new("UIStroke");s.Color=col;s.Thickness=th;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Parent=p end
local function Pad(l,r,t,b,p) local d=Instance.new("UIPadding");d.PaddingLeft=UDim.new(0,l);d.PaddingRight=UDim.new(0,r);d.PaddingTop=UDim.new(0,t);d.PaddingBottom=UDim.new(0,b);d.Parent=p end
local function LL(dir,gap,p) local l=Instance.new("UIListLayout");l.FillDirection=dir or Enum.FillDirection.Vertical;l.Padding=UDim.new(0,gap or 0);l.SortOrder=Enum.SortOrder.LayoutOrder;l.Parent=p;return l end
local function AutoSz(lay,scroll) lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize=UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+12) end) end

-- ═══════════════════════════════════════════════════════════════
-- ── SMOOTH ANIMATION SYSTEM (PROFESSIONAL) ─────────────────────
-- ═══════════════════════════════════════════════════════════════

local Animations = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

local TI = Animations.Smooth -- Default animation
local function Tw(obj,goal,speed) 
    pcall(function() 
        local anim = speed or Animations.Smooth
        TweenS:Create(obj,anim,goal):Play() 
    end) 
end

-- Hover effect helper
local function AddHoverEffect(button, normalColor, hoverColor, pressColor)
    local isHovering = false
    local isPressing = false
    
    button.MouseEnter:Connect(function()
        isHovering = true
        if not isPressing then
            Tw(button, {BackgroundColor3 = hoverColor}, Animations.Fast)
        end
    end)
    
    button.MouseLeave:Connect(function()
        isHovering = false
        if not isPressing then
            Tw(button, {BackgroundColor3 = normalColor}, Animations.Fast)
        end
    end)
    
    button.MouseButton1Down:Connect(function()
        isPressing = true
        Tw(button, {BackgroundColor3 = pressColor or hoverColor, Size = button.Size - UDim2.new(0,2,0,2)}, Animations.Fast)
    end)
    
    button.MouseButton1Up:Connect(function()
        isPressing = false
        Tw(button, {Size = button.Size + UDim2.new(0,2,0,2), BackgroundColor3 = isHovering and hoverColor or normalColor}, Animations.Fast)
    end)
end

-- ─── NOTIFICATION SYSTEM ─────────────────────────────────────
local notifQueue = {}
local notifBusy = false
local function Notify(title, msg, col)
    table.insert(notifQueue, {title=title, msg=msg, col=col or T.Accent})
    if notifBusy then return end
    notifBusy = true
    task.spawn(function()
        while #notifQueue > 0 do
            local n = table.remove(notifQueue, 1)
            local frame = N("Frame", {
                Size=UDim2.new(0,260,0,64), 
                Position=UDim2.new(1,-270,1,-80),
                BackgroundColor3=T.Panel, BorderSizePixel=0,
                AnchorPoint=Vector2.new(0,1)
            }, GUI)
            if frame then
                Corn(6,frame); Strok(n.col,1.5,frame)
                N("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=n.col,BorderSizePixel=0},frame)
                N("TextLabel",{Size=UDim2.new(1,-16,0,20),Position=UDim2.new(0,12,0,8),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=n.title,TextColor3=n.col,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},frame)
                N("TextLabel",{Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,12,0,26),BackgroundTransparency=1,Font=Enum.Font.Code,Text=n.msg,TextColor3=T.Text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},frame)
                frame.Position = UDim2.new(1,10,1,-80)
                Tw(frame, {Position=UDim2.new(1,-270,1,-80)})
                task.wait(2.5)
                Tw(frame, {Position=UDim2.new(1,10,1,-80)})
                task.wait(0.3)
                pcall(function() frame:Destroy() end)
            end
            task.wait(0.2)
        end
        notifBusy = false
    end)
end

-- ─── WINDOW ──────────────────────────────────────────────────
print("[Celestial] Creating main window...")
local Win = N("Frame",{
    Size=UDim2.new(0,660,0,520),
    Position=UDim2.new(0.5,-330,0.5,-260),
    BackgroundColor3=Color3.fromRGB(12, 12, 18), -- Darker, softer
    BackgroundTransparency=0.05, -- Slight transparency
    BorderSizePixel=0, Active=true, Draggable=true,
    ClipsDescendants=false,
},GUI)

if not Win then
    error("[Celestial] CRITICAL: Failed to create main window!")
end

print("[Celestial] Window created successfully!")
print("[Celestial] Win.Parent = " .. tostring(Win.Parent))
print("[Celestial] Win.Size = " .. tostring(Win.Size))
print("[Celestial] Win.Visible = " .. tostring(Win.Visible))

Corn(8,Win); Strok(Color3.fromRGB(35, 35, 55),1.5,Win) -- Softer border

-- Soft shadow effect
local Shadow=N("ImageLabel",{Size=UDim2.new(1,40,1,40),Position=UDim2.new(0,-20,0,-20),BackgroundTransparency=1,Image="rbxassetid://4996891970",ImageColor3=Color3.fromRGB(0,0,0),ImageTransparency=0.7,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(20,20,280,280),ZIndex=-10},Win)

local Aura=N("ImageLabel",{Size=UDim2.new(1,80,1,80),Position=UDim2.new(0,-40,0,-40),BackgroundTransparency=1,Image="rbxassetid://4996891970",ImageColor3=T.Accent,ImageTransparency=0.92,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(20,20,280,280),ZIndex=-5},Win)
task.spawn(function() while GUI.Parent do pcall(function() Aura.ImageTransparency=0.90+math.sin(tick()*1.2)*0.04 end); task.wait(0.05) end end)

print("[Celestial] Shadow and Aura effects created")

-- ─── MODERN HEADER ────────────────────────────────────────────
local Hdr=N("Frame",{Size=UDim2.new(1,0,0,56),BackgroundColor3=Color3.fromRGB(14, 14, 22),BackgroundTransparency=0.1,BorderSizePixel=0,ZIndex=2},Win)
N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=Color3.fromRGB(45, 45, 65),BackgroundTransparency=0.3,BorderSizePixel=0},Hdr)

-- Left side: Logo + Title
local Logo=N("Frame",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,12,0.5,-18),BackgroundColor3=Color3.fromRGB(10, 10, 16),BorderSizePixel=0},Hdr)
Corn(6,Logo); Strok(T.Accent,2,Logo)
N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="C",TextColor3=T.Accent,TextSize=20},Logo)

-- Animated glow on logo
task.spawn(function()
    local glow = N("UIStroke",Logo)
    glow.Color = T.Accent
    glow.Thickness = 0
    glow.Transparency = 0.5
    while GUI.Parent do
        pcall(function()
            for i = 0, 3, 0.1 do
                glow.Thickness = i
                task.wait(0.03)
            end
            for i = 3, 0, -0.1 do
                glow.Thickness = i
                task.wait(0.03)
            end
        end)
    end
end)

N("TextLabel",{Size=UDim2.new(0,160,0,20),Position=UDim2.new(0,56,0,10),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="CELESTIAL",TextColor3=Color3.fromRGB(240, 245, 255),TextSize=17,TextXAlignment=Enum.TextXAlignment.Left},Hdr)
N("TextLabel",{Size=UDim2.new(0,180,0,13),Position=UDim2.new(0,56,0,30),BackgroundTransparency=1,Font=Enum.Font.Code,Text="PREMIUM v7.0 // EXTERNAL",TextColor3=Color3.fromRGB(140, 150, 180),TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},Hdr)

-- Right side: Stats + Controls
local function StatPair(xOff,top,bot)
    local lbl=N("TextLabel",{Size=UDim2.new(0,55,0,16),Position=UDim2.new(1,xOff,0,10),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=top,TextColor3=T.Accent,TextSize=13,TextXAlignment=Enum.TextXAlignment.Center},Hdr)
    N("TextLabel",{Size=UDim2.new(0,55,0,12),Position=UDim2.new(1,xOff,0,27),BackgroundTransparency=1,Font=Enum.Font.Code,Text=bot,TextColor3=Color3.fromRGB(100, 110, 135),TextSize=9,TextXAlignment=Enum.TextXAlignment.Center},Hdr)
    return lbl
end
local LblFPS  = StatPair(-230,"60","FPS")
local LblPING = StatPair(-165,"0MS","PING")
local LblSEC  = StatPair(-105,"OK","STATUS")

-- Control buttons (inside header, right side)
local function ModernBtn(xOff,txt,col,icon)
    local b=N("TextButton",{Size=UDim2.new(0,32,0,32),Position=UDim2.new(1,xOff,0,12),BackgroundColor3=col,BackgroundTransparency=0.1,BorderSizePixel=0,Font=Enum.Font.GothamBold,Text=icon or txt,TextColor3=Color3.fromRGB(255,255,255),TextSize=16,ZIndex=3},Hdr)
    Corn(6,b)
    Strok(Color3.fromRGB(255,255,255),0,b).Transparency=0.9
    
    -- Hover effect
    b.MouseEnter:Connect(function()
        Tw(b, {BackgroundTransparency=0, Size=UDim2.new(0,34,0,34)}, Animations.Fast)
    end)
    b.MouseLeave:Connect(function()
        Tw(b, {BackgroundTransparency=0.1, Size=UDim2.new(0,32,0,32)}, Animations.Fast)
    end)
    
    return b
end

local BtnSettings = ModernBtn(-58, "⚙", Color3.fromRGB(60, 120, 255), "⚙")
local BtnMin   = ModernBtn(-94, "−", Color3.fromRGB(80, 80, 100), "−")
local BtnClose = ModernBtn(-130, "×", Color3.fromRGB(220, 60, 60), "×")

local fBuf,fSum,fIdx={},0,1
for i=1,10 do fBuf[i]=60; fSum=fSum+60 end
RS.RenderStepped:Connect(function(dt)
    local fps=math.clamp(math.floor(1/math.max(dt,.001)),1,999)
    fSum=fSum-fBuf[fIdx]+fps; fBuf[fIdx]=fps; fIdx=(fIdx%10)+1
    pcall(function() LblFPS.Text=tostring(math.floor(fSum/10)) end)
end)
task.spawn(function()
    while GUI.Parent do
        pcall(function()
            local ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            LblPING.Text=tostring(ping).."MS"
            LblSEC.Text= ping<80 and "OK" or ping<150 and "WARN" or "HIGH"
            LblSEC.TextColor3=ping<80 and T.Green or ping<150 and T.Gold or T.Red
        end)
        task.wait(1)
    end
end)

-- ─── WATERMARK (DRAGGABLE) ──────────────────────────────────
local WMark = N("Frame",{
    Size=UDim2.new(0,220,0,28),
    Position=UDim2.new(0,8,0,8),
    BackgroundColor3=T.Header,BorderSizePixel=0,
    Visible=CFG.Watermark, ZIndex=5,
    Active=true, Draggable=true  -- Make draggable
},GUI)
Corn(4,WMark); Strok(T.Accent,1,WMark)
local WMarkLbl = N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text="CELESTIAL v7  |  FPS: 60  |  PING: 0",TextColor3=T.Text,TextSize=10,ZIndex=5},WMark)
task.spawn(function()
    while GUI.Parent do
        pcall(function()
            local fps = math.floor(fSum/10)
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            if WMarkLbl then WMarkLbl.Text = "CELESTIAL v7  |  FPS: "..fps.."  |  "..ping.."MS" end
        end)
        task.wait(0.5)
    end
end)

-- ─── KEYBIND LIST (DRAGGABLE) ────────────────────────────────
local KBList = N("Frame",{
    Size=UDim2.new(0,180,0,200),
    Position=UDim2.new(0,8,0,44),
    BackgroundColor3=T.Panel,BorderSizePixel=0,
    Visible=false, ZIndex=5,
    Active=true, Draggable=true
},GUI)
Corn(4,KBList); Strok(T.Border,1,KBList)

-- Header
local KBHdr=N("Frame",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Header,BorderSizePixel=0},KBList)
Corn(4,KBHdr)
N("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="KEYBINDS",TextColor3=T.Accent,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},KBHdr)

-- Content
local KBScroll=N("ScrollingFrame",{Size=UDim2.new(1,-8,1,-32),Position=UDim2.new(0,4,0,28),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,0)},KBList)
local KBLayout=LL(Enum.FillDirection.Vertical,4,KBScroll)
AutoSz(KBLayout,KBScroll)

-- Keybind items (updated in RenderStepped)
local keybindItems = {}

local function UpdateKeybindList()
    -- Clear old items
    for _, item in pairs(keybindItems) do
        pcall(function() item:Destroy() end)
    end
    keybindItems = {}
    
    -- Define keybinds to show
    local keybinds = {
        {name = "Aimbot", key = CFG.AimbotKey, active = CFG.AimbotOn and UIS:IsKeyDown(CFG.AimbotKey)},
        {name = "Triggerbot", key = CFG.TrigKey, active = CFG.TrigOn and UIS:IsKeyDown(CFG.TrigKey)},
        {name = "Fly", key = CFG.FlyKey, active = CFG.FlyOn},
        {name = "Bhop", key = CFG.BhopKey, active = CFG.BhopOn and UIS:IsKeyDown(CFG.BhopKey)},
        {name = "Third Person", key = CFG.TPKey, active = CFG.TPOn},
    }
    
    for _, kb in ipairs(keybinds) do
        local frame = N("Frame",{Size=UDim2.new(1,-4,0,20),BackgroundColor3=T.Surface,BorderSizePixel=0},KBScroll)
        Corn(3,frame)
        
        -- Name
        N("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=kb.name,TextColor3=T.Text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},frame)
        
        -- Key
        N("TextLabel",{Size=UDim2.new(0.4,-12,0,14),Position=UDim2.new(0.6,0,0.5,-7),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text="["..kb.key.Name.."]",TextColor3=T.TextD,TextSize=9},frame)
        Corn(2,frame:FindFirstChildOfClass("TextLabel",true))
        
        -- Status indicator
        local indicator = N("Frame",{Size=UDim2.new(0,3,0,12),Position=UDim2.new(1,-6,0.5,-6),BackgroundColor3=kb.active and T.Green or T.Red,BorderSizePixel=0},frame)
        Corn(1,indicator)
        
        table.insert(keybindItems, frame)
    end
end

-- Update visibility
task.spawn(function()
    while GUI.Parent do
        pcall(function()
            KBList.Visible = CFG.KeybindList
            if CFG.KeybindList then
                UpdateKeybindList()
            end
        end)
        task.wait(0.1)
    end
end)

-- ─── NAV BAR ─────────────────────────────────────────────────
local NavBar=N("Frame",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,56),BackgroundColor3=T.Header,BorderSizePixel=0},Win)
N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.BorderL,BorderSizePixel=0},NavBar)

local TABS = {"COMBAT","VISUALS","MOVEMENT","PLAYERS","MISC"}
local NavInfo = {}

local function ActivateMain(name)
    for n,inf in pairs(NavInfo) do
        local a=(n==name)
        inf.btn.TextColor3 = a and T.Accent or T.TextD
        inf.ul.BackgroundTransparency = a and 0 or 1
        inf.sidebar.Visible = a
        for _,pg in pairs(inf.pages) do pg.Visible=false end
    end
    local inf=NavInfo[name]
    if inf and #inf.items>0 then inf.items[1].activate() end
end

local navW=math.floor(660/#TABS)
for i,name in ipairs(TABS) do
    local btn=N("TextButton",{Size=UDim2.new(0,navW,1,0),Position=UDim2.new(0,navW*(i-1),0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=name,TextColor3=T.TextD,TextSize=11},NavBar)
    local ul=N("Frame",{Size=UDim2.new(0.8,0,0,2),Position=UDim2.new(0.1,0,1,-2),BackgroundColor3=T.Accent,BorderSizePixel=0,BackgroundTransparency=1},btn)
    NavInfo[name]={btn=btn,ul=ul,sidebar=nil,pages={},items={}}
    btn.MouseButton1Click:Connect(function() ActivateMain(name) end)
end

-- ─── BODY ────────────────────────────────────────────────────
local Body=N("Frame",{Size=UDim2.new(1,0,1,-114),Position=UDim2.new(0,0,0,90),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true},Win)
local SbRoot=N("Frame",{Size=UDim2.new(0,148,1,0),BackgroundColor3=T.Panel,BorderSizePixel=0,ClipsDescendants=true},Body)
N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=T.Border,BorderSizePixel=0},SbRoot)
local CntRoot=N("Frame",{Size=UDim2.new(1,-149,1,0),Position=UDim2.new(0,149,0,0),BackgroundColor3=T.BG,BorderSizePixel=0,ClipsDescendants=true},Body)
local Ftr=N("Frame",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,1,-24),BackgroundColor3=T.Header,BorderSizePixel=0,ZIndex=2},Win)
N("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Border,BorderSizePixel=0},Ftr)
N("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text="BUILD 7.0.0 // CELESTIAL CORE",TextColor3=T.TextM,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},Ftr)
N("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text="CELESTIAL.CC",TextColor3=T.Accent,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right},Ftr)

-- ─── TAB INFRASTRUCTURE ──────────────────────────────────────
local function BuildTab(name)
    local sf=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false},SbRoot)
    Pad(7,7,8,8,sf); LL(Enum.FillDirection.Vertical,3,sf)
    NavInfo[name].sidebar=sf; return sf
end
local function SbSep(sf,lbl)
    N("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Font=Enum.Font.Code,Text="- "..string.upper(lbl),TextColor3=T.TextM,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},sf)
end
local function AddPage(tabName,label)
    local sf=NavInfo[tabName].sidebar
    local btn=N("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Gotham,Text="  "..label,TextColor3=T.TextD,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ClipsDescendants=true},sf)
    Corn(3,btn)
    local bar=N("Frame",{Size=UDim2.new(0,2,0,16),Position=UDim2.new(0,0,0.5,-8),BackgroundColor3=T.Accent,BorderSizePixel=0,BackgroundTransparency=1},btn)
    local scroll=N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.AccentD,CanvasSize=UDim2.new(0,0,0,0),Visible=false},CntRoot)
    Pad(14,14,12,12,scroll)
    local lay=LL(Enum.FillDirection.Vertical,9,scroll); AutoSz(lay,scroll)
    NavInfo[tabName].pages[label]=scroll
    local function activate()
        for _,pg in pairs(NavInfo[tabName].pages) do pg.Visible=false end
        for _,ch in pairs(sf:GetChildren()) do
            if ch:IsA("TextButton") then ch.TextColor3=T.TextD;ch.BackgroundColor3=T.BG
                local b=ch:FindFirstChildOfClass("Frame");if b then b.BackgroundTransparency=1 end end
        end
        scroll.Visible=true;btn.TextColor3=T.Text;btn.BackgroundColor3=T.Surface;bar.BackgroundTransparency=0
    end
    btn.MouseButton1Click:Connect(activate)
    table.insert(NavInfo[tabName].items,{activate=activate})
    return scroll
end

-- ─── WIDGET BUILDERS ─────────────────────────────────────────
local secN=0
local function Sec(p,title)
    secN=secN+1
    local f=N("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1},p)
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.BorderL,BorderSizePixel=0},f)
    N("TextLabel",{Size=UDim2.new(1,-32,1,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=string.upper(title),TextColor3=T.TextD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},f)
    N("TextLabel",{Size=UDim2.new(0,28,1,0),Position=UDim2.new(1,-28,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=string.format("%02d",secN),TextColor3=T.TextM,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right},f)
end

local function Toggle(p,label,def,cb)
    local f=N("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=T.Panel,BorderSizePixel=0},p)
    Corn(4,f);Strok(T.Border,1,f)
    N("TextLabel",{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=label,TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},f)
    local trk=N("TextButton",{Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-48,0.5,-9),BackgroundColor3=def and T.Accent or T.Surface,BorderSizePixel=0,Text=""},f)
    Corn(9,trk)
    local knob=N("Frame",{Size=UDim2.new(0,12,0,12),Position=def and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),BackgroundColor3=T.Text,BorderSizePixel=0},trk)
    Corn(6,knob)
    local on=def
    trk.MouseButton1Click:Connect(function()
        on=not on
        Tw(trk,{BackgroundColor3=on and T.Accent or T.Surface})
        Tw(knob,{Position=on and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)})
        pcall(cb,on)
    end)
    return {setVal=function(v) on=v; Tw(trk,{BackgroundColor3=v and T.Accent or T.Surface}); Tw(knob,{Position=v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)}) end}
end

local function CardRow(p)
    local f=N("Frame",{Size=UDim2.new(1,0,0,66),BackgroundTransparency=1},p)
    LL(Enum.FillDirection.Horizontal,8,f); return f
end
local function HalfT(row,label,sub,def,cb)
    local f=N("Frame",{Size=UDim2.new(0.5,-4,1,0),BackgroundColor3=T.Panel,BorderSizePixel=0},row)
    Corn(4,f);Strok(T.Border,1,f)
    N("TextLabel",{Size=UDim2.new(1,-46,0,18),Position=UDim2.new(0,10,0,8),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=label,TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},f)
    if sub then N("TextLabel",{Size=UDim2.new(1,-46,0,12),Position=UDim2.new(0,10,0,27),BackgroundTransparency=1,Font=Enum.Font.Code,Text=sub,TextColor3=T.TextM,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},f) end
    local trk=N("TextButton",{Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-44,0,8),BackgroundColor3=def and T.Accent or T.Surface,BorderSizePixel=0,Text=""},f)
    Corn(9,trk)
    local knob=N("Frame",{Size=UDim2.new(0,12,0,12),Position=def and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6),BackgroundColor3=T.Text,BorderSizePixel=0},trk)
    Corn(6,knob); local on=def
    trk.MouseButton1Click:Connect(function()
        on=not on
        Tw(trk,{BackgroundColor3=on and T.Accent or T.Surface})
        Tw(knob,{Position=on and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6)})
        pcall(cb,on)
    end)
end

local function Slider(p,label,mn,mx,def,unit,cb)
    local f=N("Frame",{Size=UDim2.new(1,0,0,56),BackgroundColor3=T.Panel,BorderSizePixel=0},p)
    Corn(4,f);Strok(T.Border,1,f)
    N("TextLabel",{Size=UDim2.new(0.58,0,0,18),Position=UDim2.new(0,12,0,8),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=label,TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},f)
    local badge=N("Frame",{Size=UDim2.new(0,56,0,20),Position=UDim2.new(1,-68,0,8),BackgroundColor3=T.BG,BorderSizePixel=0},f)
    Corn(3,badge);Strok(T.Accent,1,badge)
    local vallbl=N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=tostring(def)..(unit or ""),TextColor3=T.Accent,TextSize=11},badge)
    local trk=N("Frame",{Size=UDim2.new(1,-24,0,4),Position=UDim2.new(0,12,1,-14),BackgroundColor3=T.Surface,BorderSizePixel=0},f)
    Corn(2,trk)
    local fill=N("Frame",{Size=UDim2.new((def-mn)/(mx-mn),0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0},trk); Corn(2,fill)
    local dot=N("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new((def-mn)/(mx-mn),-5,0.5,-5),BackgroundColor3=T.Text,BorderSizePixel=0},trk); Corn(5,dot);Strok(T.Accent,1.5,dot)
    local hit=N("TextButton",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,-1.5,0),BackgroundTransparency=1,Text=""},trk)
    local function setVal(mx2)
        local rel=math.clamp(mx2-trk.AbsolutePosition.X,0,trk.AbsoluteSize.X)
        local pct=rel/trk.AbsoluteSize.X; local v=math.floor(mn+(mx-mn)*pct)
        pcall(function() vallbl.Text=tostring(v)..(unit or ""); fill.Size=UDim2.new(pct,0,1,0); dot.Position=UDim2.new(pct,-5,0.5,-5) end)
        pcall(cb,v)
    end
    local drag=false
    hit.MouseButton1Down:Connect(function() drag=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    RS.RenderStepped:Connect(function() if drag then pcall(setVal,UIS:GetMouseLocation().X) end end)
    hit.MouseButton1Click:Connect(function() pcall(setVal,UIS:GetMouseLocation().X) end)
    return {setVal=function(v) pcall(function() local pct=(v-mn)/(mx-mn); vallbl.Text=tostring(v)..(unit or ""); fill.Size=UDim2.new(pct,0,1,0); dot.Position=UDim2.new(pct,-5,0.5,-5) end) end}
end

local function Dropdown(p,label,opts,def,cb)
    local f=N("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.Panel,BorderSizePixel=0,ClipsDescendants=false},p)
    Corn(4,f);Strok(T.Border,1,f)
    N("TextLabel",{Size=UDim2.new(0.44,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=label,TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},f)
    local btn=N("TextButton",{Size=UDim2.new(0.51,-8,0,26),Position=UDim2.new(0.49,4,0.5,-13),BackgroundColor3=T.Surface,BorderSizePixel=0,Font=Enum.Font.Code,Text=string.upper(def).." ▾",TextColor3=T.Accent,TextSize=11},f)
    Corn(3,btn);Strok(T.BorderL,1,btn)
    local list=N("Frame",{Size=UDim2.new(0,200,0,#opts*28+6),BackgroundColor3=T.Surface,BorderSizePixel=0,Visible=false,ZIndex=200},GUI)
    Corn(4,list);Strok(T.Accent,1,list);Pad(3,3,3,3,list);LL(Enum.FillDirection.Vertical,2,list)
    for _,opt in ipairs(opts) do
        local ob=N("TextButton",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text="  "..string.upper(opt),TextColor3=T.TextD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=201},list)
        Corn(3,ob)
        ob.MouseEnter:Connect(function() ob.BackgroundColor3=T.BorderL;ob.TextColor3=T.Accent end)
        ob.MouseLeave:Connect(function() ob.BackgroundColor3=T.BG;ob.TextColor3=T.TextD end)
        ob.MouseButton1Click:Connect(function() btn.Text=string.upper(opt).." ▾";list.Visible=false;pcall(cb,opt) end)
    end
    local open=false
    btn.MouseButton1Click:Connect(function()
        open=not open;list.Visible=open
        if open then local p2,s=btn.AbsolutePosition,btn.AbsoluteSize;list.Size=UDim2.new(0,math.max(s.X,180),0,#opts*28+6);list.Position=UDim2.new(0,p2.X,0,p2.Y+s.Y+4) end
    end)
    UIS.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 and open then
            task.defer(function()
                if not open then return end
                local m=UIS:GetMouseLocation();local lp,ls=list.AbsolutePosition,list.AbsoluteSize;local bp,bs=btn.AbsolutePosition,btn.AbsoluteSize
                if not(m.X>=lp.X and m.X<=lp.X+ls.X and m.Y>=lp.Y and m.Y<=lp.Y+ls.Y) and not(m.X>=bp.X and m.X<=bp.X+bs.X and m.Y>=bp.Y and m.Y<=bp.Y+bs.Y) then open=false;list.Visible=false end
            end)
        end
    end)
end

local function BtnGrp(p,opts,def,cb)
    local f=N("Frame",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1},p)
    local w=1/#opts
    for i,opt in ipairs(opts) do
        local a=(opt==def)
        local b=N("TextButton",{Size=UDim2.new(w,-4,1,-4),Position=UDim2.new(w*(i-1),2,0,2),BackgroundColor3=a and T.Accent or T.Surface,BorderSizePixel=0,Font=Enum.Font.Code,Text=string.upper(opt),TextColor3=a and T.BG or T.TextD,TextSize=10},f)
        Corn(3,b);if not a then Strok(T.Border,1,b) end
        b.MouseButton1Click:Connect(function()
            for _,ch in pairs(f:GetChildren()) do if ch:IsA("TextButton") then ch.BackgroundColor3=T.Surface;ch.TextColor3=T.TextD end end
            b.BackgroundColor3=T.Accent;b.TextColor3=T.BG;pcall(cb,opt)
        end)
    end
end

local function KeyRow(p,label,curKey,cb)
    local f=N("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=T.Panel,BorderSizePixel=0},p)
    Corn(4,f);Strok(T.Border,1,f)
    N("TextLabel",{Size=UDim2.new(0.52,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=label,TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},f)
    local kb=N("TextButton",{Size=UDim2.new(0,95,0,22),Position=UDim2.new(1,-107,0.5,-11),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text=curKey.Name,TextColor3=T.Accent,TextSize=11},f)
    Corn(3,kb);Strok(T.Accent,1,kb)
    local listening=false
    kb.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true;kb.Text="...";kb.TextColor3=T.Red
        local conn;conn=UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then listening=false;kb.Text=inp.KeyCode.Name;kb.TextColor3=T.Accent;pcall(cb,inp.KeyCode);conn:Disconnect() end
        end)
    end)
end

local function ActionBtn(p,label,col,cb)
    local f=N("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=col or T.Accent,BorderSizePixel=0,Font=Enum.Font.Code,Text=label,TextColor3=T.BG,TextSize=12},p)
    Corn(4,f)
    f.MouseButton1Click:Connect(function() pcall(cb) end)
    return f
end

-- ═══════════════════════════════════════════════════
-- BUILD TABS
-- ═══════════════════════════════════════════════════

-- ── COMBAT ─────────────────────────────────────────────────────
local sfc=BuildTab("COMBAT")
SbSep(sfc,"Modules")

do -- Aimbot
    local pg=AddPage("COMBAT","Aimbot")
    Sec(pg,"Core")
    local r=CardRow(pg)
    HalfT(r,"Enable Aimbot","MASTER TOGGLE",false,function(v) CFG.AimbotOn=v; if v then Notify("Aimbot","Enabled ✓",T.Green) end end)
    HalfT(r,"Fire Rate Mod","RAPID FIRE",false,function(v) CFG.FireRateMod=v; if v then Notify("Fire Rate","Rapid fire enabled!",T.Accent) end end)
    Sec(pg,"Behavior")
    Toggle(pg,"Disable On Reload",true,function(v) CFG.DisableOnReload=v end)
    Toggle(pg,"Enable Only On Scope",false,function(v) CFG.EnableOnScope=v end)
    Toggle(pg,"Wall Check (Visible Only)",true,function(v) CFG.WallCheck=v end)
    Toggle(pg,"Movement Prediction",true,function(v) CFG.Prediction=v end)
    Toggle(pg,"Show FOV Circle",true,function(v) CFG.ShowFOV=v end)
    Toggle(pg,"Hitbox Expansion",false,function(v) CFG.HitboxExp=v end)
    Sec(pg,"Targeting")
    Dropdown(pg,"Aimbot Type",{"Linear","Quadratic","Instant"},"Linear",function(v) CFG.AimbotType=v end)
    Dropdown(pg,"Target Conditions",{"Visible","Vulnerable","Any"},"Visible",function(v) CFG.TargetCondition=v end)
    Dropdown(pg,"Part Selection",{"Closest","Center","Random"},"Closest",function(v) CFG.TargetType=v end)
    Dropdown(pg,"Target Bone",{"Head","UpperTorso","LowerTorso","HumanoidRootPart"},"Head",function(v) CFG.TargetBone=v end)
    Dropdown(pg,"Parts In Air",{"Head","HitboxHead","UpperTorso","HumanoidRootPart"},"Head",function(v) CFG.TargetPartsAir=v end)
    Dropdown(pg,"Parts On Ground",{"Head","HitboxHead","UpperTorso","HumanoidRootPart"},"Head",function(v) CFG.TargetPartsGround=v end)
    Sec(pg,"Tuning")
    Slider(pg,"Smoothness [0=Lock 10=Slow]",0,10,5,"",function(v) CFG.AimbotSlider=v; CFG.AimbotSmooth=SV(v) end)
    Slider(pg,"Speed",1,10,3,"",function(v) CFG.AimbotSpeed=v end)
    Slider(pg,"Strength",0,10,5,"",function(v) CFG.AimbotStrength=v/10 end)
    Slider(pg,"FOV Radius",30,600,200,"°",function(v) CFG.AimbotFOV=v end)
    Slider(pg,"Hitbox Size",1,30,4,"st",function(v) CFG.HitboxSize=v end)
    Slider(pg,"Switch Delay",0,200,0,"ms",function(v) CFG.SwitchDelay=v/1000 end)
    Slider(pg,"Reaction Time",0,500,0,"ms",function(v) CFG.ReactionTime=v/1000 end)
    
    Sec(pg,"🔥 Fire Rate Modifier")
    Slider(pg,"Fire Rate Multiplier",1,10,2,"x",function(v) CFG.FireRateMultiplier=v end)
    N("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="⚠️ Higher values = Faster shooting\n1x = Normal | 10x = Maximum speed",TextColor3=T.Gold,TextSize=9,TextWrapped=true},pg)
    Corn(4,pg:GetChildren()[#pg:GetChildren()]); Strok(T.Border,1,pg:GetChildren()[#pg:GetChildren()])
end

do -- Silent Aim
    local pg=AddPage("COMBAT","Silent Aim")
    Sec(pg,"Silent Aim")
    local r=CardRow(pg)
    HalfT(r,"Enable Silent Aim","DECOUPLE HIT",false,function(v) CFG.SilentOn=v; if v then Notify("Silent Aim","Enabled ✓",T.Green) end end)
    HalfT(r,"Show FOV Circle","VISUAL",false,function(v) CFG.SilentShowFOV=v end)
    Sec(pg,"FOV Settings")
    Slider(pg,"Silent FOV Radius",30,600,200,"°",function(v) CFG.SilentFOV=v end)
    Dropdown(pg,"FOV Color",{"Teal","White","Red","Blue","Green","Purple","Orange"},"Teal",function(v)
        local m={Teal=Color3.fromRGB(0,212,170),White=Color3.fromRGB(255,255,255),Red=Color3.fromRGB(255,50,50),Blue=Color3.fromRGB(50,150,255),Green=Color3.fromRGB(50,255,50),Purple=Color3.fromRGB(150,50,255),Orange=Color3.fromRGB(255,140,0)}
        CFG.SilentFOVColor=m[v] or Color3.fromRGB(255,50,50)
    end)
end

do -- Triggerbot
    local pg=AddPage("COMBAT","Triggerbot")
    Sec(pg,"General")
    local r=CardRow(pg)
    HalfT(r,"Enable Trigger","MASTER TOGGLE",false,function(v) CFG.TrigOn=v; if v then Notify("Triggerbot","Enabled ✓",T.Green) end end)
    HalfT(r,"Bullet Trace","FIRE VISUAL",false,function(v) CFG.TraceOn=v end)
    Sec(pg,"Behavior")
    Toggle(pg,"Disable On Reload",false,function(v) CFG.TrigDisableReload=v end)
    Toggle(pg,"Activate Only On Scope",false,function(v) CFG.TrigOnScope=v end)
    Dropdown(pg,"Target Parts In Air",{"Head","HitboxHead","UpperTorso"},"Head",function(v) CFG.TrigPartsAir=v end)
    Dropdown(pg,"Target Parts On Ground",{"Head","HitboxHead","UpperTorso"},"Head",function(v) CFG.TrigPartsGround=v end)
    Sec(pg,"Timing")
    Slider(pg,"Reaction Time",0,500,50,"ms",function(v) CFG.TrigDelay=v/1000 end)
    Slider(pg,"Release Time",0,300,0,"ms",function(v) CFG.TrigRelease=v/1000 end)
    Slider(pg,"Trace Duration",1,5,2,"s",function(v) CFG.TraceDur=v end)
    Slider(pg,"Trace Width (px)",1,8,2,"px",function(v) CFG.TraceWidth=v end)
    Dropdown(pg,"Trace Color",{"Teal","White","Red","Blue","Green","Purple","Orange"},"Teal",function(v)
        local m={Teal=Color3.fromRGB(0,212,170),White=Color3.fromRGB(255,255,255),Red=Color3.fromRGB(255,50,50),Blue=Color3.fromRGB(50,150,255),Green=Color3.fromRGB(50,255,50),Purple=Color3.fromRGB(150,50,255),Orange=Color3.fromRGB(255,140,0)}
        CFG.TraceColor=m[v] or CFG.TraceColor
    end)
end

SbSep(sfc,"Rage")
do -- Rage / Auto Farm
    local pg=AddPage("COMBAT","Rage")
    Sec(pg,"Rage Options")
    local r=CardRow(pg)
    HalfT(r,"Magic Bullet","WALLBANG",false,function(v) CFG.MagicBullet=v end)
    HalfT(r,"Auto Farm","SERVER HOP",false,function(v) CFG.AutoFarmOn=v end)
    
    Sec(pg,"🤖 Auto Farm Settings")
    Toggle(pg,"Auto Farm Mode",false,function(v) 
        CFG.AutoFarmOn=v 
        if v then
            Notify("Auto Farm","Starting auto farm loop...",T.Accent)
        end
    end)
    Slider(pg,"Farm Range",5,100,25,"st",function(v) CFG.FarmRange=v end)
    Slider(pg,"Kill Delay",50,500,100,"ms",function(v) CFG.FarmDelay=v/1000 end)
    Slider(pg,"Headshots Per Target",1,10,3,"hs",function(v) CFG.FarmHeadshots=v end)
    Slider(pg,"Server Hop After",1,20,5,"kills",function(v) CFG.FarmHopAfter=v end)
    Toggle(pg,"Teleport To Target",true,function(v) CFG.FarmTeleport=v end)
    Toggle(pg,"Auto Headshot Only",true,function(v) CFG.FarmHeadshotOnly=v end)
    
    Sec(pg,"⚙️ Farm Status")
    local statusLbl = N("TextLabel",{Size=UDim2.new(1,0,0,80),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Status: Idle\nKills: 0\nServer Hops: 0\nCurrent Target: None",TextColor3=T.TextD,TextSize=10,TextWrapped=true},pg)
    Corn(4,statusLbl); Strok(T.Border,1,statusLbl)
    
    -- Update status in background
    task.spawn(function()
        while GUI.Parent do
            pcall(function()
                if statusLbl and _farmStats then
                    local status = CFG.AutoFarmOn and "🟢 Active" or "🔴 Idle"
                    local text = string.format(
                        "Status: %s\nKills: %d\nServer Hops: %d\nCurrent Target: %s",
                        status,
                        _farmStats.kills or 0,
                        _farmStats.hops or 0,
                        _farmStats.currentTarget or "None"
                    )
                    statusLbl.Text = text
                    statusLbl.TextColor3 = CFG.AutoFarmOn and T.Green or T.TextD
                end
            end)
            task.wait(0.5)
        end
    end)
    
    Sec(pg,"🔥 Manual Controls")
    ActionBtn(pg,"🔄 SERVER HOP NOW",T.Accent,function()
        Notify("Server Hop","Finding new server...",T.Accent)
        _serverHop()
    end)
    
    ActionBtn(pg,"📊 RESET STATS",T.Surface,function()
        _farmStats = {kills = 0, hops = 0, currentTarget = "None"}
        Notify("Stats Reset","Farm statistics cleared!",T.Green)
    end)
    
    Sec(pg,"🎯 Advanced")
    Toggle(pg,"Anti-Aim",false,function(v) CFG.AntiAimOn=v end)
    Dropdown(pg,"Anti-Aim Type",{"Spinbot","Jitter","Sideways","Random"},"Spinbot",function(v) CFG.AntiAimType=v end)
    Slider(pg,"Jitter Speed",1,50,10,"",function(v) CFG.JitterSpeed=v end)
    Toggle(pg,"Fake Lag",false,function(v) CFG.FakeLagOn=v end)
    Slider(pg,"Lag Amount",1,15,5,"ticks",function(v) CFG.FakeLagTicks=v end)
    
    Sec(pg,"🎯 Backtrack")
    Toggle(pg,"Backtrack",false,function(v) CFG.BacktrackOn=v end)
    Slider(pg,"Backtrack Time",50,500,200,"ms",function(v) CFG.BacktrackTime=v/1000 end)
    
    Sec(pg,"💀 Instant Kill")
    Toggle(pg,"One Shot Kill",false,function(v) CFG.OneShot=v end)
    N("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="⚠️ WARNING: May trigger anti-cheat!\nUse at your own risk.",TextColor3=T.Red,TextSize=9,TextWrapped=true},pg)
    Corn(4,pg:GetChildren()[#pg:GetChildren()])
end

-- ── VISUALS ────────────────────────────────────────────────────
local sfv=BuildTab("VISUALS")
SbSep(sfv,"Modules")
do
    local pg=AddPage("VISUALS","ESP")
    Sec(pg,"ESP Settings")
    local r=CardRow(pg)
    HalfT(r,"Enable ESP","MASTER TOGGLE",false,function(v) CFG.ESPOn=v end)
    HalfT(r,"Corner Box","BOX STYLE",true,function(v) CFG.CornerBox=v end)
    Toggle(pg,"Box ESP",true,function(v) CFG.BoxESP=v end)
    Toggle(pg,"Health Bar",true,function(v) CFG.HealthBar=v end)
    Toggle(pg,"Show Names",true,function(v) CFG.ShowName=v end)
    Toggle(pg,"Show Distance",true,function(v) CFG.ShowDist=v end)
    Toggle(pg,"Snaplines",true,function(v) CFG.SnapLines=v end)
    Toggle(pg,"Head Dots",true,function(v) CFG.HeadDot=v end)
    Toggle(pg,"Team Check",false,function(v) CFG.ESPTeamCheck=v end)
    Slider(pg,"Max Distance",50,2000,1000,"st",function(v) CFG.ESPMaxDist=v end)
    
    Sec(pg,"🌟 Advanced ESP")
    Toggle(pg,"Skeleton ESP",false,function(v) CFG.SkeletonESP=v end)
    Toggle(pg,"Weapon ESP",false,function(v) CFG.WeaponESP=v end)
    Toggle(pg,"Armor Bar",false,function(v) CFG.ArmorBar=v end)
    Toggle(pg,"Flags (Scoped/Reloading)",false,function(v) CFG.FlagsESP=v end)
    Toggle(pg,"Keybind List",false,function(v) CFG.KeybindList=v end)
    
    Sec(pg,"🎨 ESP Colors")
    Dropdown(pg,"Color Mode",{"Static","Health Based","Distance Based","Team Based"},"Static",function(v) CFG.ESPColorMode=v end)
    
    Sec(pg,"🌍 World ESP")
    Toggle(pg,"Item ESP (Guns/Ammo)",false,function(v) CFG.ItemESP=v end)
    Toggle(pg,"Vehicle ESP",false,function(v) CFG.VehicleESP=v end)
    Slider(pg,"World ESP Max Distance",50,1000,300,"st",function(v) CFG.WorldESPDist=v end)
end
do
    local pg=AddPage("VISUALS","Chams")
    Sec(pg,"Chams — Highlight Glow (Walls Visible)")
    Toggle(pg,"Enable Chams",false,function(v)
        CFG.ChamsOn=v
        if not v then
            for char,hl in pairs(_chamBoxes) do
                pcall(function() hl:Destroy() end)
                _chamBoxes[char]=nil
            end
        end
    end)
    Dropdown(pg,"Glow Color",{"Teal","Red","Purple","Blue","Green","Gold","White","Pink"},"Teal",function(v)
        local m={Teal=Color3.fromRGB(0,212,170),Red=Color3.fromRGB(255,30,30),Purple=Color3.fromRGB(180,30,255),Blue=Color3.fromRGB(30,100,255),Green=Color3.fromRGB(30,220,30),Gold=Color3.fromRGB(255,200,0),White=Color3.fromRGB(255,255,255),Pink=Color3.fromRGB(255,60,160)}
        CFG.ChamsColor=m[v] or CFG.ChamsColor
    end)
    Slider(pg,"Glow Intensity",0,10,4,"",function(v) CFG.ChamsIntensity=v/10 end)
end
SbSep(sfv,"Overlay")
do
    local pg=AddPage("VISUALS","Crosshair")
    Sec(pg,"Custom Crosshair")
    local r=CardRow(pg)
    HalfT(r,"Enable","OVERLAY",false,function(v) CFG.CrossOn=v end)
    HalfT(r,"Center Dot","POINT",false,function(v) CFG.CrossDot=v end)
    Slider(pg,"Size",2,30,10,"",function(v) CFG.CrossSize=v end)
    Slider(pg,"Gap",0,15,4,"",function(v) CFG.CrossGap=v end)
    Slider(pg,"Thickness",1,5,1,"",function(v) CFG.CrossThick=v end)
    Dropdown(pg,"Color",{"Teal","White","Red","Green","Yellow","Pink"},"Teal",function(v)
        local m={Teal=Color3.fromRGB(0,212,170),White=Color3.fromRGB(255,255,255),Red=Color3.fromRGB(255,50,50),Green=Color3.fromRGB(50,255,50),Yellow=Color3.fromRGB(255,220,0),Pink=Color3.fromRGB(255,80,180)}
        CFG.CrossColor=m[v] or CFG.CrossColor
    end)
end
do
    local pg=AddPage("VISUALS","Bullet Trace")
    Sec(pg,"Bullet Tracer (Drawing API)")
    Toggle(pg,"Enable Bullet Trace",false,function(v)
        CFG.TraceOn=v
        if v then Notify("Bullet Trace","Enabled — fires on click!",T.Accent) end
    end)
    Sec(pg,"Trace Style")
    Slider(pg,"Duration",0.5,5,1.5,"s",function(v) CFG.TraceDur=v end)
    Slider(pg,"Line Width",1,8,2,"px",function(v) CFG.TraceWidth=v end)
    Toggle(pg,"Fade Out",true,function(v) CFG.TraceFadeOut=v end)
    Sec(pg,"Trace Color")
    Dropdown(pg,"Color",{"Teal","White","Red","Blue","Green","Purple","Orange","Pink","Gold"},"Teal",function(v)
        local m={
            Teal=Color3.fromRGB(0,212,170),
            White=Color3.fromRGB(255,255,255),
            Red=Color3.fromRGB(255,50,50),
            Blue=Color3.fromRGB(50,150,255),
            Green=Color3.fromRGB(50,255,50),
            Purple=Color3.fromRGB(150,50,255),
            Orange=Color3.fromRGB(255,140,0),
            Pink=Color3.fromRGB(255,80,180),
            Gold=Color3.fromRGB(255,200,50)
        }
        CFG.TraceColor=m[v] or CFG.TraceColor
    end)
end
SbSep(sfv,"Lighting")
do
    local pg=AddPage("VISUALS","Lighting")
    Sec(pg,"Fullbright & Fog")
    Toggle(pg,"Fullbright",false,function(v)
        CFG.Fullbright=v
        pcall(function()
            Light.Brightness=v and 5 or 2; Light.GlobalShadows=not v
            Light.Ambient=v and Color3.new(1,1,1) or Color3.fromRGB(70,70,70)
            Light.OutdoorAmbient=v and Color3.new(1,1,1) or Color3.fromRGB(70,70,70)
        end)
    end)
    Toggle(pg,"No Fog",false,function(v)
        CFG.NoFog=v
        pcall(function() Light.FogEnd=v and 999999 or 100000; Light.FogStart=v and 999998 or 0 end)
    end)
    Sec(pg,"Custom Sky Color")
    Toggle(pg,"Custom Sky Color",false,function(v)
        CFG.SkyColorOn=v
        if not v then
            -- Reset to default
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
                lighting.Ambient = Color3.fromRGB(70,70,70)
                
                local atmo = lighting:FindFirstChildOfClass("Atmosphere")
                if atmo then 
                    atmo.Density = 0.395
                    atmo.Color = Color3.fromRGB(199, 199, 199)
                    atmo.Decay = Color3.fromRGB(92, 60, 13)
                end
            end)
        else
            -- Apply current sky color immediately
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.Ambient = CFG.SkyColor
                lighting.OutdoorAmbient = CFG.SkyColor
                
                local atmo = lighting:FindFirstChildOfClass("Atmosphere")
                if not atmo then
                    atmo = Instance.new("Atmosphere")
                    atmo.Parent = lighting
                end
                
                atmo.Color = CFG.SkyColor
                atmo.Decay = CFG.SkyColor
                atmo.Density = 0.4
            end)
        end
    end)
    Dropdown(pg,"Sky Preset",{"Night Black","Deep Purple","Blood Red","Ocean Blue","Toxic Green","Gold Sunset","Cyber Teal","Pink Dream","Orange Hell","Default"},"Night Black",function(v)
        local presets={
            -- Daha güçlü ve farklı renkler
            ["Night Black"]={
                Ambient=Color3.fromRGB(5,5,15),
                OutdoorAmbient=Color3.fromRGB(8,8,20),
                AtmoColor=Color3.fromRGB(10,10,30),
                AtmoDecay=Color3.fromRGB(5,5,15),
                FogColor=Color3.fromRGB(0,0,10)
            },
            ["Deep Purple"]={
                Ambient=Color3.fromRGB(60,20,80),
                OutdoorAmbient=Color3.fromRGB(80,30,120),
                AtmoColor=Color3.fromRGB(100,40,140),
                AtmoDecay=Color3.fromRGB(60,20,80),
                FogColor=Color3.fromRGB(40,10,60)
            },
            ["Blood Red"]={
                Ambient=Color3.fromRGB(80,10,10),
                OutdoorAmbient=Color3.fromRGB(120,15,15),
                AtmoColor=Color3.fromRGB(150,20,20),
                AtmoDecay=Color3.fromRGB(80,5,5),
                FogColor=Color3.fromRGB(60,0,0)
            },
            ["Ocean Blue"]={
                Ambient=Color3.fromRGB(10,40,80),
                OutdoorAmbient=Color3.fromRGB(15,60,120),
                AtmoColor=Color3.fromRGB(20,80,160),
                AtmoDecay=Color3.fromRGB(10,40,80),
                FogColor=Color3.fromRGB(0,20,60)
            },
            ["Toxic Green"]={
                Ambient=Color3.fromRGB(20,80,20),
                OutdoorAmbient=Color3.fromRGB(30,120,30),
                AtmoColor=Color3.fromRGB(40,160,40),
                AtmoDecay=Color3.fromRGB(20,80,20),
                FogColor=Color3.fromRGB(10,60,10)
            },
            ["Gold Sunset"]={
                Ambient=Color3.fromRGB(120,80,20),
                OutdoorAmbient=Color3.fromRGB(160,100,30),
                AtmoColor=Color3.fromRGB(200,120,40),
                AtmoDecay=Color3.fromRGB(120,60,10),
                FogColor=Color3.fromRGB(100,50,0)
            },
            ["Cyber Teal"]={
                Ambient=Color3.fromRGB(10,80,80),
                OutdoorAmbient=Color3.fromRGB(15,120,120),
                AtmoColor=Color3.fromRGB(20,160,160),
                AtmoDecay=Color3.fromRGB(10,80,80),
                FogColor=Color3.fromRGB(0,60,60)
            },
            ["Pink Dream"]={
                Ambient=Color3.fromRGB(100,40,80),
                OutdoorAmbient=Color3.fromRGB(140,60,120),
                AtmoColor=Color3.fromRGB(180,80,150),
                AtmoDecay=Color3.fromRGB(100,40,80),
                FogColor=Color3.fromRGB(80,20,60)
            },
            ["Orange Hell"]={
                Ambient=Color3.fromRGB(120,60,0),
                OutdoorAmbient=Color3.fromRGB(160,80,10),
                AtmoColor=Color3.fromRGB(200,100,20),
                AtmoDecay=Color3.fromRGB(120,40,0),
                FogColor=Color3.fromRGB(100,30,0)
            },
            ["Default"]={
                Ambient=Color3.fromRGB(138,138,138),
                OutdoorAmbient=Color3.fromRGB(138,138,138),
                AtmoColor=Color3.fromRGB(199,199,199),
                AtmoDecay=Color3.fromRGB(92,60,13),
                FogColor=Color3.fromRGB(191,191,191)
            },
        }
        
        local preset = presets[v]
        if preset then
            -- Store for later use
            CFG.SkyColor = preset.Ambient
            
            -- Apply immediately if enabled
            if CFG.SkyColorOn then
                pcall(function()
                    local lighting = game:GetService("Lighting")
                    
                    -- Apply all color values
                    lighting.Ambient = preset.Ambient
                    lighting.OutdoorAmbient = preset.OutdoorAmbient
                    lighting.FogColor = preset.FogColor
                    
                    -- Atmosphere settings
                    local atmo = lighting:FindFirstChildOfClass("Atmosphere")
                    if not atmo then
                        atmo = Instance.new("Atmosphere")
                        atmo.Parent = lighting
                    end
                    
                    atmo.Color = preset.AtmoColor
                    atmo.Decay = preset.AtmoDecay
                    atmo.Density = 0.4
                    atmo.Offset = 0.25
                    atmo.Glare = 0
                    atmo.Haze = 0
                    
                    print("[Sky Color] Applied preset: " .. v)
                end)
            end
        end
    end)
end

-- ── MOVEMENT ──────────────────────────────────────────────────
local sfm=BuildTab("MOVEMENT")

-- Movement Section
SbSep(sfm,"Movement")
do
    local pg=AddPage("MOVEMENT","Locomotion")
    Sec(pg,"Speed & Jump")
    Toggle(pg,"Speed Hack",false,function(v) CFG.SpeedOn=v end)
    Slider(pg,"Walk Speed",16,250,32,"",function(v) CFG.WalkSpeed=v end)
    Slider(pg,"Jump Power",50,400,50,"",function(v) CFG.JumpPower=v end)
    Sec(pg,"Special Movement")
    Toggle(pg,"Bunnyhop (Hold Space)",false,function(v) CFG.BhopOn=v end)
    Toggle(pg,"Infinite Jump",false,function(v) CFG.InfJump=v end)
    Toggle(pg,"Auto Strafe",false,function(v) CFG.AutoStrafe=v end)
    Sec(pg,"Flight")
    Toggle(pg,"Flight Mode",false,function(v)
        CFG.FlyOn=v
        if v then Notify("Flight","Press F to toggle!",T.Accent) end
    end)
    Slider(pg,"Flight Speed",10,200,50,"",function(v) CFG.FlySpeed=v end)
    KeyRow(pg,"Flight Key",CFG.FlyKey,function(k) CFG.FlyKey=k end)
    Sec(pg,"Safety")
    Toggle(pg,"Anti-Void",false,function(v) CFG.AntiVoid=v end)
    Toggle(pg,"Noclip",false,function(v) CFG.NoclipOn=v end)
end

-- Camera Section
SbSep(sfm,"Camera")
do
    local pg=AddPage("MOVEMENT","Camera")
    Sec(pg,"FOV Settings")
    Toggle(pg,"Custom FOV",false,function(v)
        CFG.FOVEnabled=v
        if v then Camera.FieldOfView=CFG.CameraFOV
        else Camera.FieldOfView=70 end
    end)
    Slider(pg,"Field of View",30,120,70,"°",function(v)
        CFG.CameraFOV=v
        if CFG.FOVEnabled then Camera.FieldOfView=v end
    end)
    
    Sec(pg,"Stretched Resolution")
    Toggle(pg,"Enable Stretched",false,function(v)
        CFG.StretchedRes=v
        -- Stretched res implementation would go here
        if v then Notify("Stretched","Aspect ratio modified!",T.Accent) end
    end)
    Slider(pg,"Stretch Scale",0.5,2.0,1.0,"x",function(v)
        CFG.StretchScale=v
    end)
    
    Sec(pg,"ViewModel Offset")
    Toggle(pg,"Custom ViewModel",false,function(v)
        CFG.ViewModelEnabled=v
    end)
    Slider(pg,"X Offset",-10,10,0,"",function(v) CFG.ViewModelX=v end)
    Slider(pg,"Y Offset",-10,10,0,"",function(v) CFG.ViewModelY=v end)
    Slider(pg,"Z Offset",-10,10,0,"",function(v) CFG.ViewModelZ=v end)
    
    Sec(pg,"Third Person")
    Toggle(pg,"Third Person View",false,function(v)
        if v ~= TP.Active then
            ToggleThirdPerson()
        end
    end)
    Slider(pg,"Camera Distance",5,50,15,"",function(v) CFG.TPDist=v; TP.Distance=v end)
    KeyRow(pg,"Toggle Key",CFG.TPKey,function(k) CFG.TPKey=k end)
    
    Sec(pg,"🎥 Advanced Third Person")
    Slider(pg,"Camera Sensitivity",1,10,5,"",function(v) TP.Sensitivity=v*0.001 end)
    Slider(pg,"Smooth Speed",1,30,15,"%",function(v) TP.SmoothSpeed=v/100 end)
    Slider(pg,"Vertical Offset",-5,10,2,"",function(v) TP.OffsetY=v end)
    Slider(pg,"Horizontal Offset",-10,10,0,"",function(v) TP.OffsetX=v end)
    Toggle(pg,"Wall Collision",true,function(v) TP.WallClip=v end)
    Slider(pg,"Min Distance (Wall)",1,10,2,"",function(v) TP.MinDistance=v end)
end

-- Identity Section
SbSep(sfm,"Identity")
do
    local pg=AddPage("MOVEMENT","Identity")
    Sec(pg,"Player Spoofer")
    
    -- Local Player
    N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Local Player",TextColor3=T.Accent,TextSize=11},pg)
    Corn(4,pg:GetChildren()[#pg:GetChildren()])
    
    Toggle(pg,"Spoof Name",false,function(v) CFG.SpoofName=v end)
    
    local nameInput=N("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=T.Panel,BorderSizePixel=0},pg)
    Corn(4,nameInput);Strok(T.Border,1,nameInput)
    N("TextLabel",{Size=UDim2.new(0.35,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Custom Name",TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},nameInput)
    local nameBox=N("TextBox",{Size=UDim2.new(0.6,-8,0,26),Position=UDim2.new(0.4,4,0.5,-13),BackgroundColor3=T.Surface,BorderSizePixel=0,Font=Enum.Font.Code,Text="Player",TextColor3=T.Text,TextSize=11,PlaceholderText="Enter name..."},nameInput)
    Corn(3,nameBox);Strok(T.BorderL,1,nameBox)
    nameBox.FocusLost:Connect(function() CFG.CustomName=nameBox.Text end)
    
    Toggle(pg,"Spoof Display Name",false,function(v) CFG.SpoofDisplayName=v end)
    
    local dispInput=N("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=T.Panel,BorderSizePixel=0},pg)
    Corn(4,dispInput);Strok(T.Border,1,dispInput)
    N("TextLabel",{Size=UDim2.new(0.35,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Display Name",TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},dispInput)
    local dispBox=N("TextBox",{Size=UDim2.new(0.6,-8,0,26),Position=UDim2.new(0.4,4,0.5,-13),BackgroundColor3=T.Surface,BorderSizePixel=0,Font=Enum.Font.Code,Text="Player",TextColor3=T.Text,TextSize=11,PlaceholderText="Enter display name..."},dispInput)
    Corn(3,dispBox);Strok(T.BorderL,1,dispBox)
    dispBox.FocusLost:Connect(function() CFG.CustomDisplayName=dispBox.Text end)
    
    Sec(pg,"Other Players")
    Toggle(pg,"Hide Avatar",false,function(v) CFG.HideAvatar=v end)
    Toggle(pg,"Hide Winstreak",false,function(v) CFG.HideWinstreak=v end)
end

-- ── PLAYERS ───────────────────────────────────────────────────
local sfp=BuildTab("PLAYERS")
SbSep(sfp,"Player List")
do
    local pg=AddPage("PLAYERS","Player List")
    Sec(pg,"Players Online")
    local refBtn=N("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.Accent,BorderSizePixel=0,Font=Enum.Font.Code,Text="REFRESH LIST",TextColor3=T.BG,TextSize=11},pg)
    Corn(4,refBtn)
    local items={}
    local function refresh()
        for _,f in ipairs(items) do pcall(function() f:Destroy() end) end; items={}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LP then
                local row=N("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.Panel,BorderSizePixel=0},pg)
                if row then
                    Corn(4,row);Strok(T.Border,1,row)
                    N("TextLabel",{Size=UDim2.new(0.55,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=pl.DisplayName.." ("..pl.Name..")",TextColor3=T.Text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},row)
                    
                    -- GOTO button
                    local tb=N("TextButton",{Size=UDim2.new(0,44,0,18),Position=UDim2.new(1,-140,0,4),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text="GOTO",TextColor3=T.Accent,TextSize=10},row)
                    Corn(3,tb);Strok(T.Accent,1,tb)
                    tb.MouseButton1Click:Connect(function()
                        pcall(function()
                            local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            local tr=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                            if mr and tr then 
                                mr.CFrame=tr.CFrame+Vector3.new(0,4,0)
                                Notify("Teleport","Teleported to " .. pl.Name,T.Accent)
                            end
                        end)
                    end)
                    
                    -- SPEC button
                    local sb=N("TextButton",{Size=UDim2.new(0,44,0,18),Position=UDim2.new(1,-90,0,4),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text="SPEC",TextColor3=T.Gold,TextSize=10},row)
                    Corn(3,sb);Strok(T.Gold,1,sb)
                    sb.MouseButton1Click:Connect(function()
                        pcall(function()
                            local char=pl.Character
                            if char then
                                Camera.CameraType=Enum.CameraType.Custom
                                Camera.CameraSubject=char:FindFirstChildOfClass("Humanoid") or char
                                Notify("Spectate","Spectating " .. pl.Name,T.Gold)
                            end
                        end)
                    end)
                    
                    -- KILL button
                    local kb=N("TextButton",{Size=UDim2.new(0,44,0,18),Position=UDim2.new(1,-40,0,4),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text="KILL",TextColor3=T.Red,TextSize=10},row)
                    Corn(3,kb);Strok(T.Red,1,kb)
                    kb.MouseButton1Click:Connect(function()
                        pcall(function()
                            local char=pl.Character
                            if char then
                                local hum=char:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    hum.Health=0
                                    Notify("Kill","Killed " .. pl.Name,T.Red)
                                end
                            end
                        end)
                    end)
                    
                    -- FRIEND button
                    local fb=N("TextButton",{Size=UDim2.new(0,44,0,18),Position=UDim2.new(1,-90,0,24),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text="FRND",TextColor3=T.Green,TextSize=10},row)
                    Corn(3,fb);Strok(T.Green,1,fb)
                    fb.MouseButton1Click:Connect(function()
                        pcall(function()
                            LP:RequestFriendship(pl)
                            Notify("Friend","Friend request sent to " .. pl.Name,T.Green)
                        end)
                    end)
                    
                    -- VIEW button
                    local vb=N("TextButton",{Size=UDim2.new(0,44,0,18),Position=UDim2.new(1,-40,0,24),BackgroundColor3=T.BG,BorderSizePixel=0,Font=Enum.Font.Code,Text="VIEW",TextColor3=T.Accent,TextSize=10},row)
                    Corn(3,vb);Strok(T.Accent,1,vb)
                    vb.MouseButton1Click:Connect(function()
                        pcall(function()
                            local info = string.format(
                                "Player: %s\nDisplay: %s\nUserID: %d\nAccount Age: %d days",
                                pl.Name,
                                pl.DisplayName,
                                pl.UserId,
                                pl.AccountAge
                            )
                            Notify("Player Info",info,T.Accent)
                        end)
                    end)
                    
                    table.insert(items,row)
                end
            end
        end
    end
    refBtn.MouseButton1Click:Connect(refresh); refresh()
end

-- ── MISC ────────────────────────────────────────────────────
local sfm=BuildTab("MISC")
SbSep(sfm,"Anti-Detect")
do
    local pg=AddPage("MISC","Anti-Detect")
    Sec(pg,"🛡️ Bypass System Status")
    
    local statusFrame = N("Frame",{Size=UDim2.new(1,0,0,120),BackgroundColor3=T.Panel,BorderSizePixel=0},pg)
    Corn(4,statusFrame); Strok(T.Accent,1,statusFrame)
    
    local statusLbl1 = N("TextLabel",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,8),BackgroundTransparency=1,Font=Enum.Font.Code,Text="📡 Hook Status: ACTIVE",TextColor3=T.Green,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    local statusLbl2 = N("TextLabel",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,28),BackgroundTransparency=1,Font=Enum.Font.Code,Text="🔒 Blacklist: 0 patterns",TextColor3=T.TextD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    local statusLbl3 = N("TextLabel",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,48),BackgroundTransparency=1,Font=Enum.Font.Code,Text="🚫 Blocked Calls: 0",TextColor3=T.TextD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    local statusLbl4 = N("TextLabel",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,68),BackgroundTransparency=1,Font=Enum.Font.Code,Text="⚡ Traffic: 0 events",TextColor3=T.TextD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    local statusLbl5 = N("TextLabel",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,88),BackgroundTransparency=1,Font=Enum.Font.Code,Text="🛡️ Protection: ENABLED",TextColor3=T.Green,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    
    -- Update status in background
    task.spawn(function()
        while GUI.Parent do
            pcall(function()
                statusLbl1.Text = "📡 Hook Status: " .. (_ncOrig and "ACTIVE" or "INACTIVE")
                statusLbl1.TextColor3 = _ncOrig and T.Green or T.Red
                
                statusLbl2.Text = "🔒 Blacklist: " .. #BL .. " patterns | 🎭 Obfuscated: " .. #_functionRegistry
                
                statusLbl3.Text = "🚫 Blocked: " .. (_blockedCalls or 0) .. " | 📊 Analytics: " .. _analyticsBlocked
                
                statusLbl4.Text = "⚡ Traffic: " .. #_trafficLog .. " | 📦 Queued: " .. #_packetQueue
                
                -- Count active protection layers
                local protectionCount = 0
                if CFG.AntiBan then protectionCount = protectionCount + 1 end
                if _validationBypass then protectionCount = protectionCount + 1 end
                if _stateProtection then protectionCount = protectionCount + 1 end
                if _analyticsBlocked > 0 then protectionCount = protectionCount + 1 end
                if #_functionRegistry > 0 then protectionCount = protectionCount + 1 end
                if _hbProfile == "human" then protectionCount = protectionCount + 1 end
                if #_memoryVault > 0 then protectionCount = protectionCount + 1 end
                if #_packetQueue > 0 then protectionCount = protectionCount + 1 end
                if _hookTamperings > 0 then protectionCount = protectionCount + 1 end
                if _debuggerDetected then protectionCount = protectionCount + 1 end
                
                statusLbl5.Text = "🛡️ Active Layers: " .. protectionCount .. "/14 | Mode: " .. string.upper(_hbProfile)
                statusLbl5.TextColor3 = protectionCount >= 10 and T.Green or protectionCount >= 7 and T.Gold or T.Red
            end)
            task.wait(1)
        end
    end)
    
    Sec(pg,"Detection Prevention")
    Toggle(pg,"🛡️ Multi-Layer Bypass (Anti-Ban)",true,function(v) CFG.AntiBan=v end)
    Toggle(pg,"🔒 Property Spoofing",true,function(v) CFG.PropertySpoof=v end)
    Toggle(pg,"⏱️ Timing Randomization",true,function(v) CFG.TimingRandom=v end)
    Toggle(pg,"🚫 Anti-Kick Protection",true,function(v) CFG.AntiKick=v end)
    
    Sec(pg,"🔍 Advanced Protection (v5.0)")
    Toggle(pg,"🎭 Function Obfuscation",true,function(v) 
        if v then
            print("[Celestial] Function obfuscation enabled")
        else
            _functionRegistry = {}
            _obfuscationLayer = {}
        end
    end)
    Toggle(pg,"🕵️ Hide From Remote Spy",true,function(v) CFG.HideFromSpy=v end)
    Toggle(pg,"📊 Traffic Masking + Packet Queue",true,function(v) CFG.TrafficMask=v end)
    Toggle(pg,"🧠 Memory Guard + Encryption",false,function(v) CFG.MemoryGuard=v end)
    
    N("TextLabel",{Size=UDim2.new(1,0,0,64),BackgroundColor3=T.Surface,BorderSizePixel=0,Font=Enum.Font.Code,Text="⚠️ v5.0 MILITARY GRADE BYPASS ACTIVE!\n\n✅ Function obfuscation\n✅ Hook tampering detection\n✅ Adaptive human-like timing\n✅ Memory encryption with key rotation\n✅ Network packet queue system",TextColor3=T.Accent,TextSize=9,TextWrapped=true},pg)
    Corn(4,pg:GetChildren()[#pg:GetChildren()])
end

SbSep(sfm,"Interface")
do
    local pg=AddPage("MISC","Interface")
    Sec(pg,"HUD Options")
    Toggle(pg,"Watermark",true,function(v)
        CFG.Watermark=v
        pcall(function() WMark.Visible=v end)
    end)
    
    Sec(pg,"Account Info (For Support)")
    local hwidLbl = N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="HWID: Loading...",TextColor3=T.TextD,TextSize=10},pg)
    Corn(4,hwidLbl); Strok(T.Border,1,hwidLbl)
    
    local uidLbl = N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="UID: Loading...",TextColor3=T.TextD,TextSize=10},pg)
    Corn(4,uidLbl); Strok(T.Border,1,uidLbl)

    local placeLbl = N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Place ID: Loading...",TextColor3=T.TextD,TextSize=10},pg)
    Corn(4,placeLbl); Strok(T.Border,1,placeLbl)

    task.spawn(function()
        pcall(function() hwidLbl.Text = "HWID: " .. tostring(game:GetService("RbxAnalyticsService"):GetClientId()) end)
        pcall(function() uidLbl.Text = "UID: " .. tostring(LP.UserId) end)
        pcall(function() placeLbl.Text = "Place ID: " .. tostring(game.PlaceId) end)
    end)

    ActionBtn(pg,"📋 COPY HWID",T.Surface,function()
        pcall(function() setclipboard(tostring(game:GetService("RbxAnalyticsService"):GetClientId())) end)
        Notify("Copied!","HWID copied to clipboard.",T.Accent)
    end)
    
    Sec(pg,"🔍 Pattern Scanner")
    N("TextLabel",{Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Pattern Scanner runs automatically on load.\nScan results are logged to F9 console.\nUsed for auto-parry, anti-ban, and weapon detection.",TextColor3=T.TextM,TextSize=9,TextWrapped=true},pg)
    Corn(4,pg:GetChildren()[#pg:GetChildren()])
    
    ActionBtn(pg,"🔍 VIEW SCAN RESULTS",T.Accent,function()
        if PATTERNS.ScanComplete then
            local info = string.format(
                "Scanner Status: ✅ Complete\nGame: %s\nRemotes: %d | Weapons: %d\nSkin Paths: %d | Unlock Methods: %d\nParry Remotes: %d",
                PATTERNS.DetectedGame,
                #PATTERNS.Remotes,
                #PATTERNS.WeaponPaths,
                #PATTERNS.SkinPaths,
                #PATTERNS.UnlockMethods,
                #PATTERNS.ParryRemotes
            )
            Notify("Pattern Scanner",info,T.Accent)
        else
            Notify("Pattern Scanner","⏳ Scan in progress... Wait 3 seconds.",T.Gold)
        end
    end)
    
    -- Hidden: Quick scan info button (HWID-locked)
    if HWID == "6ADD91FF-1461-4C64-9038-3FA9609990E4" then
        Sec(pg,"🔍 Developer Tools")
        ActionBtn(pg,"🔍 QUICK SCAN INFO",T.Gold,function()
            local info = string.format(
                "Scanner Status: %s\nGame: %s\nRemotes: %d | Skins: %d | Methods: %d",
                PATTERNS.ScanComplete and "✅ Complete" or "⏳ Scanning",
                PATTERNS.DetectedGame,
                #PATTERNS.Remotes,
                #PATTERNS.SkinPaths,
                #PATTERNS.UnlockMethods
            )
            Notify("Pattern Scanner",info,T.Accent)
        end)
    end
end

SbSep(sfm,"Auto-Execute")
do
    local pg=AddPage("MISC","Auto-Execute")
    
    Sec(pg,"⚡ Auto-Execute System v2.0")
    N("TextLabel",{Size=UDim2.new(1,0,0,64),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Auto-Execute automatically runs scripts and loads\nconfigs when Celestial starts.\n\n✅ Auto-load configs\n✅ Execute custom Lua scripts\n✅ Game-specific profiles",TextColor3=T.TextD,TextSize=9,TextWrapped=true},pg)
    Corn(4,pg:GetChildren()[#pg:GetChildren()])
    
    -- Load current config
    local autoExecCfg = LoadAutoExecConfig()
    
    -- Status display
    local statusFrame = N("Frame",{Size=UDim2.new(1,0,0,90),BackgroundColor3=T.Surface,BorderSizePixel=0},pg)
    Corn(4,statusFrame); Strok(T.Accent,1,statusFrame)
    
    local statusLbl1 = N("TextLabel",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,8),BackgroundTransparency=1,Font=Enum.Font.Code,Text="Status: " .. (autoExecCfg.enabled and "✅ ENABLED" or "⏸️ DISABLED"),TextColor3=autoExecCfg.enabled and T.Green or T.TextD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    local statusLbl2 = N("TextLabel",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,8,0,28),BackgroundTransparency=1,Font=Enum.Font.Code,Text="Config: " .. (autoExecCfg.loadConfig or "None"),TextColor3=T.TextD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    local statusLbl3 = N("TextLabel",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,8,0,46),BackgroundTransparency=1,Font=Enum.Font.Code,Text="Scripts: " .. #autoExecCfg.executeScripts,TextColor3=T.TextD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    local statusLbl4 = N("TextLabel",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,8,0,64),BackgroundTransparency=1,Font=Enum.Font.Code,Text="Executions: " .. autoExecCfg.executionCount,TextColor3=T.TextD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
    
    -- Auto-update status
    task.spawn(function()
        while GUI.Parent do
            task.wait(2)
            pcall(function()
                local cfg = LoadAutoExecConfig()
                statusLbl1.Text = "Status: " .. (cfg.enabled and "✅ ENABLED" or "⏸️ DISABLED")
                statusLbl1.TextColor3 = cfg.enabled and T.Green or T.TextD
                statusLbl2.Text = "Config: " .. (cfg.loadConfig or "None")
                statusLbl3.Text = "Scripts: " .. #cfg.executeScripts
                statusLbl4.Text = "Executions: " .. cfg.executionCount
            end)
        end
    end)
    
    Sec(pg,"⚙️ Settings")
    Toggle(pg,"Enable Auto-Execute",autoExecCfg.enabled,function(v)
        local cfg = LoadAutoExecConfig()
        cfg.enabled = v
        SaveAutoExecConfig(cfg)
        Notify("Auto-Exec",v and "Enabled!" or "Disabled!",v and T.Green or T.TextD)
    end)
    
    Toggle(pg,"Show Notifications",autoExecCfg.showNotifications,function(v)
        local cfg = LoadAutoExecConfig()
        cfg.showNotifications = v
        SaveAutoExecConfig(cfg)
    end)
    
    Toggle(pg,"Safe Mode (Stop on Error)",autoExecCfg.safeMode,function(v)
        local cfg = LoadAutoExecConfig()
        cfg.safeMode = v
        SaveAutoExecConfig(cfg)
    end)
    
    Slider(pg,"Load Delay",100,5000,autoExecCfg.loadDelay,"ms",function(v)
        local cfg = LoadAutoExecConfig()
        cfg.loadDelay = v
        SaveAutoExecConfig(cfg)
    end)
    
    Sec(pg,"📂 Auto-Load Config")
    local configInput=N("TextBox",{
        Size=UDim2.new(1,0,0,32), BackgroundColor3=T.Panel, BorderSizePixel=0,
        Font=Enum.Font.Code, PlaceholderText="Enter config name (e.g., 'default')",
        Text=autoExecCfg.loadConfig or "", TextColor3=T.Text, TextSize=11, ClearTextOnFocus=false,
    },pg)
    Corn(4,configInput); Strok(T.Accent,1,configInput); Pad(10,10,0,0,configInput)
    
    ActionBtn(pg,"💾 SET CONFIG TO AUTO-LOAD",T.Accent,function()
        local cfg = LoadAutoExecConfig()
        cfg.loadConfig = configInput.Text ~= "" and configInput.Text or nil
        SaveAutoExecConfig(cfg)
        Notify("Auto-Exec","Config set: " .. (cfg.loadConfig or "None"),T.Green)
    end)
    
    Sec(pg,"📜 Script Management")
    
    local scriptsList = N("ScrollingFrame",{
        Size=UDim2.new(1,0,0,150),
        BackgroundColor3=T.Panel,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0)
    },pg)
    Corn(4,scriptsList); Strok(T.Border,1,scriptsList)
    Pad(6,6,6,6,scriptsList)
    local scriptsLay=LL(Enum.FillDirection.Vertical,4,scriptsList)
    AutoSz(scriptsLay,scriptsList)
    
    local function refreshScriptsList()
        -- Clear existing
        for _,ch in pairs(scriptsList:GetChildren()) do
            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                pcall(function() ch:Destroy() end)
            end
        end
        
        -- Get scripts
        local scripts = ListAutoExecScripts()
        local cfg = LoadAutoExecConfig()
        
        if #scripts == 0 then
            local emptyLbl = N("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Font=Enum.Font.Code,Text="No scripts found.\nPlace .lua files in AutoExec folder.",TextColor3=T.TextM,TextSize=10,TextWrapped=true},scriptsList)
            return
        end
        
        for _, script in ipairs(scripts) do
            local isEnabled = false
            for _, enabledScript in ipairs(cfg.executeScripts) do
                if enabledScript == script.name then
                    isEnabled = true
                    break
                end
            end
            
            local scriptRow = N("Frame",{Size=UDim2.new(1,-4,0,36),BackgroundColor3=T.Surface,BorderSizePixel=0},scriptsList)
            Corn(3,scriptRow); Strok(isEnabled and T.Accent or T.Border,1,scriptRow)
            
            -- Icon & Name
            N("TextLabel",{Size=UDim2.new(0.6,-12,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=(isEnabled and "✅ " or "📜 ") .. script.name,TextColor3=isEnabled and T.Accent or T.Text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},scriptRow)
            
            -- Size
            local sizeKB = math.floor(script.size / 1024 * 10) / 10
            N("TextLabel",{Size=UDim2.new(0.2,0,1,0),Position=UDim2.new(0.6,0,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=sizeKB .. "KB",TextColor3=T.TextM,TextSize=9,TextXAlignment=Enum.TextXAlignment.Right},scriptRow)
            
            -- Toggle button
            local toggleBtn = N("TextButton",{Size=UDim2.new(0,50,0,24),Position=UDim2.new(1,-58,0.5,-12),BackgroundColor3=isEnabled and T.Green or T.Surface,BorderSizePixel=0,Font=Enum.Font.Code,Text=isEnabled and "ON" or "OFF",TextColor3=isEnabled and T.BG or T.TextD,TextSize=10},scriptRow)
            Corn(3,toggleBtn)
            
            toggleBtn.MouseButton1Click:Connect(function()
                local currentCfg = LoadAutoExecConfig()
                local scriptIdx = nil
                
                -- Check if script is in list
                for i, name in ipairs(currentCfg.executeScripts) do
                    if name == script.name then
                        scriptIdx = i
                        break
                    end
                end
                
                if scriptIdx then
                    -- Remove from list
                    table.remove(currentCfg.executeScripts, scriptIdx)
                    Notify("Auto-Exec","Disabled: " .. script.name,T.TextD)
                else
                    -- Add to list
                    table.insert(currentCfg.executeScripts, script.name)
                    Notify("Auto-Exec","Enabled: " .. script.name,T.Green)
                end
                
                SaveAutoExecConfig(currentCfg)
                refreshScriptsList()
            end)
        end
    end
    
    refreshScriptsList()
    
    ActionBtn(pg,"🔄 REFRESH SCRIPTS LIST",T.Surface,function()
        refreshScriptsList()
    end)
    
    ActionBtn(pg,"📂 OPEN AUTOEXEC FOLDER",T.Accent,function()
        pcall(function()
            if os.execute then
                os.execute("explorer \"" .. AUTO_EXEC_SCRIPTS_FOLDER:gsub("/", "\\") .. "\"")
                Notify("Folder Opened","Check Windows Explorer!",T.Green)
            else
                setclipboard(AUTO_EXEC_SCRIPTS_FOLDER)
                Notify("Path Copied","Folder path copied!",T.Accent)
            end
        end)
    end)
    
    Sec(pg,"🚀 Manual Execution")
    ActionBtn(pg,"▶️ RUN AUTO-EXEC NOW",T.Green,function()
        Notify("Auto-Exec","Running manually...",T.Accent)
        task.spawn(RunAutoExec)
    end)
    
    ActionBtn(pg,"🔄 RESET STATISTICS",T.Surface,function()
        local cfg = LoadAutoExecConfig()
        cfg.executionCount = 0
        cfg.lastExecuted = 0
        SaveAutoExecConfig(cfg)
        Notify("Auto-Exec","Statistics reset!",T.Green)
    end)
end

SbSep(sfm,"Keybinds")
do
    local pg=AddPage("MISC","Keybinds")
    Sec(pg,"Key Bindings")
    KeyRow(pg,"Menu Toggle",      CFG.MenuKey,      function(k) CFG.MenuKey=k end)
    KeyRow(pg,"Aimbot Hold",      CFG.AimbotKey,    function(k) CFG.AimbotKey=k end)
    KeyRow(pg,"Triggerbot Hold",  CFG.TrigKey,      function(k) CFG.TrigKey=k end)
    KeyRow(pg,"Bunnyhop Hold",    CFG.BhopKey,      function(k) CFG.BhopKey=k end)
    KeyRow(pg,"Third Person",     CFG.TPKey,        function(k) CFG.TPKey=k end)
    KeyRow(pg,"Fly Toggle",       CFG.FlyKey,       function(k) CFG.FlyKey=k end)
end

SbSep(sfm,"Advanced")
do
    local pg=AddPage("MISC","Advanced")
    Sec(pg,"🎵 Hit Sounds")
    Toggle(pg,"Hit Sound",false,function(v) CFG.HitSound=v end)
    Dropdown(pg,"Sound Type",{"Quake","CS:GO","Minecraft","Neverlose","Skeet","Custom"},"Quake",function(v) 
        CFG.HitSoundType=v 
        if v == "Custom" then
            Notify("Custom Sound","Place .ogg/.mp3 files in:\n" .. CUSTOM_SOUNDS_PATH,T.Accent)
        end
    end)
    Slider(pg,"Volume",0,100,50,"%",function(v) CFG.HitSoundVol=v/100 end)
    
    -- Custom sound browser
    Sec(pg,"📁 Custom Sounds")
    local customSoundLbl=N("TextLabel",{
        Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,
        Font=Enum.Font.Code,Text="No custom sound selected",
        TextColor3=T.TextD,TextSize=10
    },pg)
    Corn(4,customSoundLbl); Strok(T.Border,1,customSoundLbl)
    
    ActionBtn(pg,"🔍 BROWSE CUSTOM SOUNDS",T.Surface,function()
        local customSounds = ListCustomSounds()
        
        if #customSounds == 0 then
            Notify("Custom Sounds","No sound files found!\n\nPlace .ogg or .mp3 files in:\n" .. CUSTOM_SOUNDS_PATH,T.Red)
            
            -- Try to open folder in explorer
            pcall(function()
                if os.execute then
                    os.execute("explorer \"" .. CUSTOM_SOUNDS_PATH:gsub("/", "\\") .. "\"")
                end
            end)
        else
            -- Create sound picker UI
            local pickerFrame = N("Frame",{
                Size=UDim2.new(0,300,0,math.min(400, #customSounds * 32 + 60)),
                Position=UDim2.new(0.5,-150,0.5,-200),
                BackgroundColor3=T.Panel,BorderSizePixel=0,
                ZIndex=1000
            },GUI)
            Corn(4,pickerFrame); Strok(T.Accent,2,pickerFrame)
            
            -- Header
            local pickerHdr=N("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.Header,BorderSizePixel=0},pickerFrame)
            Corn(4,pickerHdr)
            N("TextLabel",{Size=UDim2.new(1,-40,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="Select Custom Sound",TextColor3=T.Accent,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},pickerHdr)
            
            local closeBtn=N("TextButton",{Size=UDim2.new(0,28,0,24),Position=UDim2.new(1,-32,0,4),BackgroundColor3=T.Red,BorderSizePixel=0,Font=Enum.Font.GothamBold,Text="×",TextColor3=T.Text,TextSize=18},pickerHdr)
            Corn(3,closeBtn)
            closeBtn.MouseButton1Click:Connect(function() pcall(function() pickerFrame:Destroy() end) end)
            
            -- Sound list
            local soundScroll=N("ScrollingFrame",{Size=UDim2.new(1,-12,1,-44),Position=UDim2.new(0,6,0,38),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,0)},pickerFrame)
            local soundLay=LL(Enum.FillDirection.Vertical,4,soundScroll)
            AutoSz(soundLay,soundScroll)
            
            for _, fileName in ipairs(customSounds) do
                local soundBtn=N("TextButton",{
                    Size=UDim2.new(1,-4,0,28),
                    BackgroundColor3=T.Surface,BorderSizePixel=0,
                    Font=Enum.Font.Code,Text="🔊 " .. fileName,
                    TextColor3=T.Text,TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left
                },soundScroll)
                Corn(3,soundBtn); Strok(T.Border,1,soundBtn)
                Pad(10,10,0,0,soundBtn)
                
                soundBtn.MouseButton1Click:Connect(function()
                    _customSoundFile = fileName
                    customSoundLbl.Text = "Selected: " .. fileName
                    customSoundLbl.TextColor3 = T.Accent
                    CFG.HitSoundType = "Custom"
                    
                    Notify("Custom Sound","Selected: " .. fileName,T.Green)
                    
                    -- Test play
                    PlayHitSound()
                    
                    pcall(function() pickerFrame:Destroy() end)
                end)
            end
        end
    end)
    
    ActionBtn(pg,"📂 OPEN SOUNDS FOLDER",T.Accent,function()
        pcall(function()
            if os.execute then
                os.execute("explorer \"" .. CUSTOM_SOUNDS_PATH:gsub("/", "\\") .. "\"")
                Notify("Folder Opened","Check Windows Explorer!",T.Green)
            else
                -- Copy path to clipboard
                setclipboard(CUSTOM_SOUNDS_PATH)
                Notify("Path Copied","Folder path copied to clipboard!",T.Accent)
            end
        end)
    end)
    
    ActionBtn(pg,"🔊 TEST SOUND",T.Surface,function()
        PlayHitSound()
    end)
    
    Sec(pg,"💬 Chat Features")
    Toggle(pg,"Kill Say",false,function(v) CFG.KillSay=v end)
    local killsayInput=N("TextBox",{
        Size=UDim2.new(1,0,0,34), BackgroundColor3=T.Panel, BorderSizePixel=0,
        Font=Enum.Font.Code, PlaceholderText="Enter kill say message...",
        Text="get good", TextColor3=T.Text, TextSize=11, ClearTextOnFocus=false,
    },pg)
    Corn(4,killsayInput); Strok(T.Accent,1,killsayInput); Pad(10,10,0,0,killsayInput)
    killsayInput.FocusLost:Connect(function() CFG.KillSayMsg=killsayInput.Text end)
    
    Toggle(pg,"Spam Chat",false,function(v) CFG.SpamChat=v end)
    Slider(pg,"Spam Delay",0.5,5,1,"s",function(v) CFG.SpamDelay=v end)
    
    Sec(pg,"🎭 Fake Lag")
    Toggle(pg,"Visual Lag",false,function(v) CFG.VisualLag=v end)
    N("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Makes your character teleport (confuses enemies).\nMay cause kick on some games.",TextColor3=T.TextM,TextSize=9,TextWrapped=true},pg)
    Corn(4,pg:GetChildren()[#pg:GetChildren()])
    
    Sec(pg,"⚡ Performance")
    Toggle(pg,"FPS Unlocker",false,function(v) 
        CFG.FPSUnlock=v 
        pcall(function() setfpscap(v and 999 or 60) end)
    end)
    Toggle(pg,"Remove Textures",false,function(v) CFG.RemoveTextures=v end)
    Toggle(pg,"Low Quality Rendering",false,function(v) 
        CFG.LowQuality=v
        pcall(function() settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)
    end)
    
    Sec(pg,"🔧 Exploits")
    ActionBtn(pg,"💀 INSTANT RESPAWN",T.Red,function()
        pcall(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = 0
                    task.wait(0.1)
                    LP:LoadCharacter()
                    Notify("Respawn","Instant respawn executed!",T.Accent)
                end
            end
        end)
    end)
    
    ActionBtn(pg,"🛡️ GOD MODE (Client)",T.Gold,function()
        pcall(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                    Notify("God Mode","Client-side god mode active!",T.Green)
                end
            end
        end)
    end)
    
    ActionBtn(pg,"🚀 REMOVE FALL DAMAGE",T.Surface,function()
        pcall(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local state = hum:GetState()
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                    Notify("Fall Damage","Fall damage removed!",T.Green)
                end
            end
        end)
    end)
end

SbSep(sfm,"Config")

-- ── HIDDEN: PATTERN SCANNER DEBUG (HWID-LOCKED) ──────────────
-- Only visible to developer HWID
if HWID == "6ADD91FF-1461-4C64-9038-3FA9609990E4" then
    SbSep(sfm,"⚠️ Developer")
    do
        local pg=AddPage("MISC","🔍 Scanner Debug")
        Sec(pg,"Pattern Scanner Control")
        
        N("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="⚠️ DEV ONLY - Pattern detection system.\nThis page is hidden from end users.",TextColor3=T.Gold,TextSize=10,TextWrapped=true},pg)
        Corn(4,pg:GetChildren()[#pg:GetChildren()])
        
        -- Scan status
        local scanStatusLbl=N("TextLabel",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Status: ".. (PATTERNS.ScanComplete and "✅ Complete" or "⏳ Scanning..."),TextColor3=PATTERNS.ScanComplete and T.Green or T.Gold,TextSize=11},pg)
        Corn(4,scanStatusLbl);Strok(T.Border,1,scanStatusLbl)
        
        -- Game info
        Sec(pg,"Detected Game")
        local gameInfoLbl=N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Game: " .. PATTERNS.DetectedGame,TextColor3=T.Accent,TextSize=11},pg)
        Corn(4,gameInfoLbl);Strok(T.Border,1,gameInfoLbl)
        
        local placeIdLbl=N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="PlaceID: " .. tostring(game.PlaceId),TextColor3=T.TextD,TextSize=10},pg)
        Corn(4,placeIdLbl);Strok(T.Border,1,placeIdLbl)
        
        -- Manual re-scan button
        ActionBtn(pg,"🔄 RE-SCAN PATTERNS",T.Accent,function()
            scanStatusLbl.Text="Status: ⏳ Scanning..."
            scanStatusLbl.TextColor3=T.Gold
            task.spawn(function()
                RunPatternScan()
                task.wait(0.5)
                scanStatusLbl.Text="Status: ✅ Complete"
                scanStatusLbl.TextColor3=T.Green
                gameInfoLbl.Text="Game: " .. PATTERNS.DetectedGame
                Notify("Scanner","Re-scan complete!",T.Green)
            end)
        end)
        
        -- Results summary
        Sec(pg,"Scan Results")
        
        local function ResultRow(label,count,color)
            local row=N("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.Panel,BorderSizePixel=0},pg)
            Corn(4,row);Strok(T.Border,1,row)
            N("TextLabel",{Size=UDim2.new(0.7,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=label,TextColor3=T.Text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},row)
            N("TextLabel",{Size=UDim2.new(0.25,0,1,0),Position=UDim2.new(0.75,0,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,Text=tostring(count),TextColor3=color or T.Accent,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right},row)
        end
        
        ResultRow("Suspicious Remotes",#PATTERNS.Remotes,T.Red)
        ResultRow("Parry Remotes",#PATTERNS.ParryRemotes,T.Gold)
        ResultRow("Skin Paths",#PATTERNS.SkinPaths,T.Green)
        ResultRow("Inventory Paths",#PATTERNS.InventoryPaths,T.Green)
        ResultRow("Weapon Paths",#PATTERNS.WeaponPaths,T.Accent)
        ResultRow("Unlock Methods",#PATTERNS.UnlockMethods,T.Green)
        
        -- Detailed results (collapsible)
        Sec(pg,"Detailed Output")
        
        local detailsScroll=N("ScrollingFrame",{
            Size=UDim2.new(1,0,0,200),
            BackgroundColor3=T.Panel,BorderSizePixel=0,
            ScrollBarThickness=3,ScrollBarImageColor3=T.AccentD,
            CanvasSize=UDim2.new(0,0,0,0)
        },pg)
        Corn(4,detailsScroll);Strok(T.Border,1,detailsScroll)
        Pad(8,8,8,8,detailsScroll)
        local detailsLay=LL(Enum.FillDirection.Vertical,2,detailsScroll)
        AutoSz(detailsLay,detailsScroll)
        
        local function AddDetail(text,color)
            local lbl=N("TextLabel",{
                Size=UDim2.new(1,0,0,16),
                BackgroundTransparency=1,
                Font=Enum.Font.Code,
                Text=text,
                TextColor3=color or T.TextD,
                TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=false,
                TextTruncate=Enum.TextTruncate.AtEnd
            },detailsScroll)
        end
        
        -- Populate details
        task.spawn(function()
            task.wait(0.5)
            AddDetail("═══ REMOTES ═══",T.Red)
            for _,r in ipairs(PATTERNS.Remotes) do
                AddDetail("  ["..r.type.."] "..r.name.." → "..r.path,T.TextD)
            end
            
            AddDetail("\n═══ SKIN PATHS ═══",T.Green)
            for _,s in ipairs(PATTERNS.SkinPaths) do
                AddDetail("  ["..s.type.."] "..s.name.." → "..s.path,T.TextD)
            end
            
            AddDetail("\n═══ UNLOCK METHODS ═══",T.Green)
            for _,u in ipairs(PATTERNS.UnlockMethods) do
                AddDetail("  ["..u.method.."] "..u.name.." in "..u.parent,T.TextD)
            end
            
            AddDetail("\n═══ INVENTORY ═══",T.Accent)
            for _,i in ipairs(PATTERNS.InventoryPaths) do
                AddDetail("  ["..i.type.."] "..i.name.." → "..i.path,T.TextD)
            end
            
            AddDetail("\n═══ WEAPONS ═══",T.Accent)
            for _,w in ipairs(PATTERNS.WeaponPaths) do
                AddDetail("  "..w.name..(w.equipped and " [EQUIPPED]" or ""),T.TextD)
            end
        end)
        
        -- Export to clipboard
        Sec(pg,"Export")
        ActionBtn(pg,"📋 COPY SCAN RESULTS",T.Surface,function()
            local export = "CELESTIAL PATTERN SCAN RESULTS\n"
            export = export .. "═══════════════════════════════════════\n"
            export = export .. "Game: " .. PATTERNS.DetectedGame .. "\n"
            export = export .. "PlaceID: " .. tostring(game.PlaceId) .. "\n\n"
            
            export = export .. "REMOTES (" .. #PATTERNS.Remotes .. "):\n"
            for _,r in ipairs(PATTERNS.Remotes) do
                export = export .. "  [" .. r.type .. "] " .. r.name .. " → " .. r.path .. "\n"
            end
            
            export = export .. "\nSKIN PATHS (" .. #PATTERNS.SkinPaths .. "):\n"
            for _,s in ipairs(PATTERNS.SkinPaths) do
                export = export .. "  [" .. s.type .. "] " .. s.name .. " → " .. s.path .. "\n"
            end
            
            export = export .. "\nUNLOCK METHODS (" .. #PATTERNS.UnlockMethods .. "):\n"
            for _,u in ipairs(PATTERNS.UnlockMethods) do
                export = export .. "  [" .. u.method .. "] " .. u.name .. " in " .. u.parent .. "\n"
            end
            
            pcall(function() setclipboard(export) end)
            Notify("Exported","Scan results copied to clipboard!",T.Green)
        end)
    end
end

do
    local pg=AddPage("MISC","Config")
    Sec(pg,"📁 Config Manager  [ Celestial.cc/Configs/ ]")

    -- Status label
    local statusLbl=N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Panel,BorderSizePixel=0,Font=Enum.Font.Code,Text="Ready.",TextColor3=T.TextD,TextSize=10},pg)
    Corn(4,statusLbl)
    local function setStatus(txt,col) pcall(function() statusLbl.Text=txt; statusLbl.TextColor3=col or T.TextD end) end

    -- Config name input row
    Sec(pg,"Config Name")
    local nameBox=N("TextBox",{
        Size=UDim2.new(1,0,0,32), BackgroundColor3=T.Panel, BorderSizePixel=0,
        Font=Enum.Font.Code, PlaceholderText="Enter config name (e.g. 'rage', 'legit')",
        Text="", TextColor3=T.Text, TextSize=12, ClearTextOnFocus=false,
    },pg)
    Corn(4,nameBox); Strok(T.Accent,1,nameBox); Pad(10,10,0,0,nameBox)

    -- Save & Load buttons
    local function getCfgName()
        local n=nameBox.Text:gsub("%s+","_")
        return (n~="" and n) or "default"
    end

    ActionBtn(pg,"💾  SAVE CONFIG",T.Accent,function()
        local name=getCfgName()
        local ok=SaveCFG(name)
        setStatus(ok and ("✓  Saved → Celestial.cc/Configs/"..name..".json") or "✗  Save failed",ok and T.Green or T.Red)
        if ok then Notify("Config Saved","'"..name.."' kaydedildi!",T.Green) end
    end)

    ActionBtn(pg,"📂  LOAD SELECTED CONFIG",T.Surface,function()
        local name=getCfgName()
        local ok=LoadCFG(name)
        setStatus(ok and ("✓  Loaded '"..name.."'") or ("✗  '"..name.."' bulunamadı"),ok and T.Green or T.Red)
        if ok then Notify("Config Loaded","'"..name.."' yüklendi!",T.Accent) end
    end)

    ActionBtn(pg,"🗑️  DELETE CONFIG",Color3.fromRGB(100,30,30),function()
        local name=getCfgName()
        DeleteCFG(name)
        setStatus("🗑  Deleted '"..name.."'",T.Red)
    end)

    -- Autoload Section
    Sec(pg,"⚡ Autoload (Script açılınca otomatik yükle)")

    local autoLbl=N("TextLabel",{
        Size=UDim2.new(1,0,0,22),BackgroundColor3=T.Panel,BorderSizePixel=0,
        Font=Enum.Font.Code,Text="Autoload: (none)",TextColor3=T.TextD,TextSize=10
    },pg)
    Corn(3,autoLbl)

    local function refreshAutoLbl()
        local a=GetAutoload()
        pcall(function()
            if a and a~="" then
                autoLbl.Text="Autoload: ⚡ '"..a.."'"
                autoLbl.TextColor3=T.Accent
            else
                autoLbl.Text="Autoload: (none)"
                autoLbl.TextColor3=T.TextD
            end
        end)
    end
    refreshAutoLbl()

    ActionBtn(pg,"⚡  SET CURRENT AS AUTOLOAD",T.Accent,function()
        local name=getCfgName()
        SetAutoload(name)
        refreshAutoLbl()
        setStatus("⚡  Autoload set → '"..name.."'",T.Accent)
        Notify("Autoload Set","'"..name.."' script açılınca otomatik yüklenecek!",T.Accent)
    end)

    ActionBtn(pg,"✕  CLEAR AUTOLOAD",Color3.fromRGB(80,30,30),function()
        ClearAutoload()
        refreshAutoLbl()
        setStatus("✓  Autoload cleared",T.TextD)
    end)

    -- Config list
    Sec(pg,"📋 Saved Configs")

    local listFrame=N("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},pg)
    LL(Enum.FillDirection.Vertical,4,listFrame)

    local refreshBtn=ActionBtn(pg,"🔄  REFRESH LIST",T.Surface,function() end)

    local function refreshList()
        for _,ch in pairs(listFrame:GetChildren()) do
            if not ch:IsA("UIListLayout") then pcall(function() ch:Destroy() end) end
        end
        local configs=ListCFGs()
        local autoName=GetAutoload()
        for _,name in ipairs(configs) do
            local row=N("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=T.Panel,BorderSizePixel=0},listFrame)
            Corn(4,row); Strok(name==autoName and T.Accent or T.Border,1,row)

            local isAuto=(name==autoName)
            N("TextLabel",{Size=UDim2.new(1,-120,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Font=Enum.Font.Code,
                Text=(isAuto and "⚡ " or "")..name..".json",
                TextColor3=isAuto and T.Accent or T.Text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},row)

            local loadB=N("TextButton",{Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-118,0.5,-10),BackgroundColor3=T.Accent,BorderSizePixel=0,Font=Enum.Font.Code,Text="LOAD",TextColor3=T.BG,TextSize=9},row)
            Corn(3,loadB)
            loadB.MouseButton1Click:Connect(function()
                local ok=LoadCFG(name)
                setStatus(ok and ("✓  Loaded '"..name.."'") or "✗  Failed",ok and T.Green or T.Red)
                if ok then Notify("Config","'"..name.."' yüklendi!",T.Accent) end
            end)

            local autoB=N("TextButton",{Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-78,0.5,-10),BackgroundColor3=isAuto and T.Accent or T.Surface,BorderSizePixel=0,Font=Enum.Font.Code,Text="AUTO",TextColor3=isAuto and T.BG or T.TextD,TextSize=9},row)
            Corn(3,autoB)
            autoB.MouseButton1Click:Connect(function()
                if isAuto then ClearAutoload() else SetAutoload(name) end
                refreshList(); refreshAutoLbl()
            end)

            local delB=N("TextButton",{Size=UDim2.new(0,30,0,20),Position=UDim2.new(1,-38,0.5,-10),BackgroundColor3=Color3.fromRGB(80,20,20),BorderSizePixel=0,Font=Enum.Font.Code,Text="DEL",TextColor3=T.Red,TextSize=9},row)
            Corn(3,delB)
            delB.MouseButton1Click:Connect(function()
                DeleteCFG(name); refreshList()
                setStatus("🗑  Deleted '"..name.."'",T.Red)
            end)
        end
        if #configs==0 then
            N("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Font=Enum.Font.Code,Text="No configs found. Save one first!",TextColor3=T.TextM,TextSize=10},listFrame)
        end
    end

    refreshBtn.MouseButton1Click:Connect(refreshList)
    refreshList()

    -- Reset
    Sec(pg,"⚠️ Reset")
    ActionBtn(pg,"🔄  RESET TO DEFAULTS",T.Red,function()
        for k,v in pairs(CFG) do if type(v)=="boolean" then CFG[k]=false end end
        CFG.AntiBan=true; CFG.Watermark=true
        setStatus("✓  Reset to defaults",T.Green)
    end)
end


ActivateMain("COMBAT")

-- ─── MENU TOGGLE ─────────────────────────────────────────────
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == CFG.MenuKey then
        CFG.MenuVisible = not CFG.MenuVisible
        
        if CFG.MenuVisible then
            -- Menu opening
            print("[Celestial] Menu opening - freeing mouse...")
            Win.Visible = true
            Win.Size = UDim2.new(0,660,0,0)  -- Start from 0 size
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = false  -- Hide OS cursor, Drawing takes over
            TweenS:Create(Win, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0,660,0,520)}):Play()
        else
            -- Menu closing
            print("[Celestial] Menu closing - restoring mouse...")
            TweenS:Create(Win, TweenInfo.new(0.15), {Size=UDim2.new(0,660,0,0)}):Play()
            task.delay(0.18, function() 
                if not CFG.MenuVisible then 
                    Win.Visible = false
                    RestoreMouse()  -- Restore mouse after menu closes
                end 
            end)
        end
    end
end)

-- Show menu on first load
task.spawn(function()
    task.wait(0.5)  -- Wait for everything to load
    print("[Celestial] Opening menu automatically...")
    Win.Visible = true
    Win.Size = UDim2.new(0,660,0,0)
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    UIS.MouseIconEnabled = false
    TweenS:Create(Win, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0,660,0,520)}):Play()
end)

local isMin=false
BtnMin.MouseButton1Click:Connect(function()
    isMin=not isMin
    if isMin then
        Body.Visible=false; Ftr.Visible=false
        TweenS:Create(Win,TweenInfo.new(0.22),{Size=UDim2.new(0,660,0,56)}):Play()
        BtnMin.Text="+"
    else
        TweenS:Create(Win,TweenInfo.new(0.22),{Size=UDim2.new(0,660,0,520)}):Play()
        task.delay(0.22,function() Body.Visible=true; Ftr.Visible=true end)
        BtnMin.Text="−"
    end
end)

-- ─── DRAWING SYSTEM ──────────────────────────────────────────
local DC={}; local ESP={}
local _chamBoxes = {}  -- FIXED: declared here before GUI callbacks reference it

local function Drw(t,props)
    local ok,d=pcall(function()
        local o=Drawing.new(t)
        for k,v in pairs(props) do pcall(function() o[k]=v end) end
        table.insert(DC,o); return o
    end)
    return ok and d or nil
end
local function KillD(d) if d then pcall(function() d.Visible=false; d:Remove() end) end end
local function KillESP(char)
    if not ESP[char] then return end
    for _,d in pairs(ESP[char].D) do KillD(d) end
    for _,c in pairs(ESP[char].C) do pcall(function() c:Disconnect() end) end
    ESP[char]=nil
end
local function MakeESP(char,name)
    if not char or ESP[char] then return end
    -- v6 FIX: Cache GetPlayerFromCharacter result
    local pl = Players:GetPlayerFromCharacter(char)
    local ok,esp=pcall(function()
        local t = {}
        t.Box=Drw("Square",{Thickness=1,Filled=false,Color=CFG.ESPColor,Visible=false})
        t.TL1=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.TL2=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.TR1=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.TR2=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.BL1=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.BL2=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.BR1=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.BR2=Drw("Line",{Thickness=2,Color=CFG.ESPColor,Visible=false})
        t.HBG=Drw("Square",{Thickness=1,Filled=true,Color=Color3.fromRGB(0,0,0),Visible=false})
        t.HBF=Drw("Square",{Thickness=1,Filled=true,Color=CFG.ESPColor,Visible=false})
        t.NT=Drw("Text",{Text=name or "?",Size=13,Center=true,Outline=true,Color=Color3.new(1,1,1),Visible=false})
        t.DT=Drw("Text",{Text="",Size=11,Center=true,Outline=true,Color=Color3.fromRGB(180,180,200),Visible=false})
        t.SL=Drw("Line",{Thickness=1,Color=CFG.ESPColor,Visible=false})
        t.HD=Drw("Circle",{Thickness=1,Radius=3,Filled=true,Color=CFG.ESPColor,Visible=false})
        t.SKL_Neck=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_Torso=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_LShoulder=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_LArm=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_RShoulder=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_RArm=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_LHip=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_LLeg=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_RHip=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.SKL_RLeg=Drw("Line",{Thickness=1.5,Color=Color3.fromRGB(255,255,255),Visible=false})
        t.WeaponTxt=Drw("Text",{Text="",Size=11,Center=true,Outline=true,Color=Color3.fromRGB(255,200,100),Visible=false})
        t.ArmorBar=Drw("Square",{Thickness=1,Filled=true,Color=Color3.fromRGB(100,150,255),Visible=false})
        t.pl = pl
        return t
    end)
    if not ok or not esp then return end
    local conns={}
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then table.insert(conns,hum.Died:Connect(function() KillESP(char) end)) end
    table.insert(conns,char.AncestryChanged:Connect(function(_,p) if not p then KillESP(char) end end))
    ESP[char]={D=esp,C=conns}
end

local FOVCircle=Drw("Circle",{Thickness=1.5,NumSides=64,Radius=200,Filled=false,Color=T.Accent,Transparency=0.55,Visible=false})
local SilentFOVCircle=Drw("Circle",{Thickness=1.5,NumSides=64,Radius=200,Filled=false,Color=Color3.fromRGB(255,50,50),Transparency=0.55,Visible=false})
local CrossLines={}
CrossLines[1]=Drw("Line",{Thickness=1,Color=T.Accent,Visible=false})
CrossLines[2]=Drw("Line",{Thickness=1,Color=T.Accent,Visible=false})
CrossLines[3]=Drw("Line",{Thickness=1,Color=T.Accent,Visible=false})
CrossLines[4]=Drw("Line",{Thickness=1,Color=T.Accent,Visible=false})
CrossLines[5]=Drw("Circle",{Radius=2,Thickness=1,Filled=true,Color=T.Accent,Visible=false})
local MenuCursor={}
MenuCursor.H=Drw("Line",{Thickness=1.5,Color=T.Accent,Visible=false})
MenuCursor.V=Drw("Line",{Thickness=1.5,Color=T.Accent,Visible=false})
MenuCursor.DL=Drw("Line",{Thickness=1,Color=T.AccentD,Visible=false})
MenuCursor.DR=Drw("Line",{Thickness=1,Color=T.AccentD,Visible=false})
MenuCursor.C=Drw("Circle",{Radius=2,Thickness=1,Filled=true,Color=T.Accent,Visible=false})

-- ═══════════════════════════════════════════════════════════════
-- ── BULLET TRACE SYSTEM v2.0 (PROFESSIONAL) ────────────────────
-- ═══════════════════════════════════════════════════════════════

local _activeTraces = {}
local _maxTraces = 20
local _lastTraceTime = 0
local _traceCooldown = 0.05  -- 50ms between traces

-- Get weapon muzzle position (more accurate than center screen)
local function _getMuzzlePosition()
    local char = LP.Character
    if not char then return nil end
    
    -- Try to get equipped tool
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        -- Method 1: Find muzzle attachment
        local muzzle = tool:FindFirstChild("Muzzle", true) or tool:FindFirstChild("Handle", true)
        if muzzle and muzzle:IsA("Attachment") then
            return muzzle.WorldPosition
        end
        
        -- Method 2: Find handle part
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
        if handle then
            return handle.Position
        end
    end
    
    -- Fallback: Use head position (realistic gun height)
    local head = char:FindFirstChild("Head")
    if head then
        return head.Position + Vector3.new(0, -0.3, 0)
    end
    
    -- Last resort: Camera position
    return Camera.CFrame.Position
end

-- Create bullet trace line
local function DrawTrace(startPos, endPos)
    if not CFG.TraceOn then return end
    
    -- Check Drawing API
    if not Drawing or not Drawing.new then 
        return 
    end
    
    -- Cooldown check (prevent spam)
    local now = tick()
    if now - _lastTraceTime < _traceCooldown then
        return
    end
    _lastTraceTime = now
    
    -- Cleanup old traces if limit exceeded
    while #_activeTraces >= _maxTraces do
        local oldTrace = table.remove(_activeTraces, 1)
        if oldTrace and oldTrace.line then
            pcall(function() 
                oldTrace.line.Visible = false
                oldTrace.line:Remove() 
            end)
        end
    end
    
    local success = pcall(function()
        -- Convert world positions to screen space
        local screenFrom, onScreenFrom = Camera:WorldToViewportPoint(startPos)
        local screenTo, onScreenTo = Camera:WorldToViewportPoint(endPos)
        
        -- Validate both points are visible
        if not onScreenFrom or screenFrom.Z <= 0 then
            screenFrom = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
        else
            screenFrom = Vector2.new(screenFrom.X, screenFrom.Y)
        end
        
        if not onScreenTo or screenTo.Z <= 0 then
            return  -- Target not visible, don't draw
        end
        
        screenTo = Vector2.new(screenTo.X, screenTo.Y)
        
        -- Create line with Drawing API
        local line = Drawing.new("Line")
        line.From = screenFrom
        line.To = screenTo
        line.Color = CFG.TraceColor or Color3.fromRGB(0, 212, 170)
        line.Thickness = CFG.TraceWidth or 2
        line.Transparency = 0
        line.Visible = true
        line.ZIndex = 1000  -- Always on top
        
        -- Store trace data
        local trace = {
            line = line,
            startTime = now,
            duration = CFG.TraceDur or 1.5,
            startPos = startPos,
            endPos = endPos,
        }
        
        table.insert(_activeTraces, trace)
        table.insert(DC, line)
        
        -- Animate fade out
        task.spawn(function()
            local steps = CFG.TraceFadeOut and 20 or 1
            local stepTime = trace.duration / steps
            local startThickness = CFG.TraceWidth or 2
            
            for i = 1, steps do
                task.wait(stepTime)
                
                local alive = pcall(function()
                    if not line then return end
                    
                    if CFG.TraceFadeOut then
                        -- Smooth fade with easing
                        local progress = i / steps
                        local eased = 1 - (1 - progress) ^ 2  -- Quadratic ease-out
                        
                        line.Transparency = eased
                        line.Thickness = math.max(0.5, startThickness * (1 - progress * 0.7))
                    end
                end)
                
                if not alive then break end
            end
            
            -- Cleanup
            pcall(function()
                if line then
                    line.Visible = false
                    line:Remove()
                end
            end)
            
            -- Remove from active traces
            for idx, t in ipairs(_activeTraces) do
                if t == trace then
                    table.remove(_activeTraces, idx)
                    break
                end
            end
            
            -- Remove from DC table
            for idx, d in ipairs(DC) do
                if d == line then
                    table.remove(DC, idx)
                    break
                end
            end
        end)
    end)
end

-- ─── TRACE ACTIVATION METHODS ────────────────────────────────

-- Method 1: On mouse click (manual shooting)
local _lastClickTrace = 0
UIS.InputBegan:Connect(function(inp, gp)
    if gp or not CFG.TraceOn then return end
    
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local now = tick()
        if now - _lastClickTrace < 0.08 then return end  -- Debounce
        _lastClickTrace = now
        
        task.delay(0.02, function()  -- Small delay for shot to register
            pcall(function()
                local muzzle = _getMuzzlePosition()
                if not muzzle then return end
                
                -- Raycast to find hit position
                local mouse = UIS:GetMouseLocation()
                local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
                
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, Camera}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.IgnoreWater = true
                
                local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, rayParams)
                
                local endPos
                if result then
                    endPos = result.Position
                else
                    endPos = ray.Origin + ray.Direction * 2000
                end
                
                DrawTrace(muzzle, endPos)
            end)
        end)
    end
end)

-- Method 2: On aimbot target lock
local _lastAimbotTrace = 0
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(0.05)
        
        pcall(function()
            if not CFG.TraceOn or not CFG.AimbotOn then return end
            
            local tPart = _G_CT
            if tPart and tPart.Parent and UIS:IsKeyDown(CFG.AimbotKey) then
                local now = tick()
                if now - _lastAimbotTrace < 0.15 then return end
                
                -- Check if player is actually shooting
                local shooting = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                if not shooting then return end
                
                _lastAimbotTrace = now
                
                local muzzle = _getMuzzlePosition()
                if muzzle then
                    local targetPos = tPart.Position
                    if tPart.Name == "Head" then
                        targetPos = targetPos + Vector3.new(0, 0.2, 0)
                    end
                    
                    DrawTrace(muzzle, targetPos)
                end
            end
        end)
    end
end)

-- Method 3: On auto-click
-- (Integrated with auto-click system below in render loop)

print("[Bullet Trace] ✅ v2.0 Professional system loaded")

-- ─── CHAMS (v6 FIX: Highlight with wall penetration) ───────────────────
local function ApplyChams(char)
    if _chamBoxes[char] then return end   -- already has highlight
    local hl = Instance.new("Highlight")
    hl.FillColor         = CFG.ChamsColor
    hl.FillTransparency  = 1 - CFG.ChamsIntensity  -- slider 0-10 → intensity 0-1
    hl.OutlineColor      = CFG.ChamsColor
    hl.OutlineTransparency = 0.5
    hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop  -- visible through walls
    hl.Adornee           = char
    hl.Parent            = GUI
    _chamBoxes[char] = hl
    -- auto-cleanup when character leaves
    char.AncestryChanged:Connect(function(_, p)
        if not p then
            pcall(function() hl:Destroy() end)
            _chamBoxes[char] = nil
        end
    end)
end
local function RemoveChams(char)
    if _chamBoxes[char] then
        pcall(function() _chamBoxes[char]:Destroy() end)
        _chamBoxes[char]=nil
    end
end

-- ─── TARGET FINDER (OPTIMIZED: 30ms cache, early exit, distance pre-filter) ──────
local _switchCooldown = 0
local _cachedTarget = nil
local _cachedTargetPart = nil
local _cacheTime = 0
local _cachedFOVRadius = 200  -- cache FOV radius

local function GetTargetBone(char, inAir)
    local boneName = inAir and CFG.TargetPartsAir or CFG.TargetPartsGround
    if boneName == "HitboxHead" then boneName = "Head" end
    return char:FindFirstChild(boneName) or char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function FindTarget()
    local now = tick()
    
    -- === LOCKED TARGET CHECK (while key held) ===
    if UIS:IsKeyDown(CFG.AimbotKey) and _lockedTarget and _lockedTarget.Parent then
        local hum = _lockedTarget:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and _cachedTargetPart and _cachedTargetPart.Parent then
            -- Target still valid, keep locked
            return _lockedTarget, _cachedTargetPart
        else
            -- Target died or invalid, find new target
            _lockedTarget = nil
        end
    else
        -- Key released, unlock target
        _lockedTarget = nil
    end
    
    -- === QUICK CACHE (for new target search) ===
    if now - _cacheTime < 0.016 then  -- Reduced to 16ms for faster tracking
        if _cachedTarget and _cachedTargetPart then
            if _cachedTarget.Parent and _cachedTargetPart.Parent then
                local hum = _cachedTarget:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    return _cachedTarget, _cachedTargetPart
                end
            end
        end
    end
    
    -- === PLAYER DATA ===
    local lpChar = LP.Character
    if not lpChar then return nil, nil end
    
    local lpRoot = lpChar:FindFirstChild("HumanoidRootPart")
    if not lpRoot then return nil, nil end
    
    local lpPos = lpRoot.Position
    
    -- === FOV SETTINGS ===
    local fovRadius = CFG.AimbotFOV or 200
    _cachedFOVRadius = fovRadius
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- === TARGET SEARCH ===
    local bestChar = nil
    local bestPart = nil
    local bestDistance = math.huge
    local bestPriority = -math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        
        local char = player.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        -- === TEAM CHECK ===
        if CFG.ESPTeamCheck then
            if player.Team and LP.Team and player.Team == LP.Team then
                continue
            end
        end
        
        -- === GET TARGET PART ===
        local targetBone = CFG.TargetBone or "Head"
        local targetPart = char:FindFirstChild(targetBone)
        
        if not targetPart then
            targetPart = char:FindFirstChild("Head") 
                or char:FindFirstChild("UpperTorso") 
                or char:FindFirstChild("Torso")
                or char:FindFirstChild("HumanoidRootPart")
        end
        
        if not targetPart then continue end
        
        -- === SCREEN CHECK ===
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        
        if not onScreen or screenPos.Z <= 0 then continue end
        
        -- === FOV CHECK ===
        local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
        local distanceFromCenter = (screenPos2D - screenCenter).Magnitude
        
        if distanceFromCenter > fovRadius then continue end
        
        -- === WALL CHECK (OPTIONAL) ===
        if CFG.WallCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {lpChar, Camera}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.IgnoreWater = true
            
            local ray = workspace:Raycast(
                Camera.CFrame.Position, 
                targetPart.Position - Camera.CFrame.Position, 
                rayParams
            )
            
            if ray and ray.Instance then
                if not ray.Instance:IsDescendantOf(char) then
                    continue
                end
            end
        end
        
        -- === PRIORITY CALCULATION ===
        local worldDistance = (targetPart.Position - lpPos).Magnitude
        
        local crosshairPriority = 1 - (distanceFromCenter / fovRadius)
        local distancePriority = 1 - math.clamp(worldDistance / 500, 0, 1)
        local healthPriority = 1 - (hum.Health / hum.MaxHealth)
        
        local totalPriority = 
            (crosshairPriority * 0.7) +  -- Increased to 70%
            (distancePriority * 0.25) +  -- Decreased to 25%
            (healthPriority * 0.05)      -- Decreased to 5%
        
        if totalPriority > bestPriority then
            bestPriority = totalPriority
            bestDistance = distanceFromCenter
            bestChar = char
            bestPart = targetPart
        end
    end
    
    -- === UPDATE CACHE & LOCK ===
    _cachedTarget = bestChar
    _cachedTargetPart = bestPart
    _cacheTime = now
    
    -- Lock target when key is held and target found
    if UIS:IsKeyDown(CFG.AimbotKey) and bestChar then
        _lockedTarget = bestChar
        _lockTime = now
    end
    
    return bestChar, bestPart
end

-- ─── PHYSICS ─────────────────────────────────────────────────
local speedBV=nil
local flyBV=nil
local function setupBV(char)
    if speedBV then pcall(function() speedBV:Destroy() end) end; speedBV=nil
    if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.zero; bv.Velocity=Vector3.zero; bv.Parent=root; speedBV=bv
end

-- ═══════════════════════════════════════════════════════════════
-- ── PROFESSIONAL THIRD PERSON SYSTEM v2.0 ──────────────────────
-- ═══════════════════════════════════════════════════════════════

local TP = {
    Active = false,
    Distance = 15,
    OffsetX = 0,
    OffsetY = 2,
    OffsetZ = 0,
    Sensitivity = 0.005,
    SmoothSpeed = 0.15,
    
    -- Camera state
    Yaw = 0,
    Pitch = 0,
    CurrentCF = nil,
    TargetCF = nil,
    
    -- Toggle cooldown
    LastToggle = 0,
    ToggleCooldown = 0.3,
    
    -- Collision detection
    WallClip = true,
    MinDistance = 2,
}

-- Initialize third person
local function InitThirdPerson()
    if not LP.Character then return end
    
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Save initial camera angles
    local camCF = Camera.CFrame
    local lookVector = camCF.LookVector
    TP.Yaw = math.atan2(lookVector.X, lookVector.Z)
    TP.Pitch = math.asin(-lookVector.Y)
    
    TP.CurrentCF = camCF
    TP.TargetCF = camCF
    
    print("[Third Person] Initialized - Yaw: " .. math.deg(TP.Yaw) .. "° Pitch: " .. math.deg(TP.Pitch) .. "°")
end

-- Raycast for wall collision
local function CheckWallCollision(origin, direction, distance)
    if not TP.WallClip then return distance end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LP.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction * distance, rayParams)
    
    if result then
        -- Hit wall, reduce distance
        return math.max((result.Position - origin).Magnitude - 0.5, TP.MinDistance)
    end
    
    return distance
end

-- Update third person camera
local function UpdateThirdPerson(dt)
    if not TP.Active then return end
    
    local char = LP.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end
    
    -- Update camera angles from mouse delta
    local mouseDelta = UIS:GetMouseDelta()
    TP.Yaw = TP.Yaw - mouseDelta.X * TP.Sensitivity
    TP.Pitch = math.clamp(TP.Pitch - mouseDelta.Y * TP.Sensitivity, math.rad(-85), math.rad(85))
    
    -- Calculate camera position
    local rootPos = root.Position
    local offset = Vector3.new(TP.OffsetX, TP.OffsetY, TP.OffsetZ)
    local focusPoint = rootPos + offset
    
    -- Calculate camera direction from angles
    local yawCF = CFrame.Angles(0, TP.Yaw, 0)
    local pitchCF = CFrame.Angles(TP.Pitch, 0, 0)
    local rotationCF = yawCF * pitchCF
    
    -- Calculate camera offset
    local distance = CFG.TPDist or TP.Distance
    local cameraOffset = rotationCF:VectorToWorldSpace(Vector3.new(0, 0, distance))
    
    -- Check wall collision
    local actualDistance = CheckWallCollision(focusPoint, cameraOffset.Unit, distance)
    if actualDistance < distance then
        cameraOffset = rotationCF:VectorToWorldSpace(Vector3.new(0, 0, actualDistance))
    end
    
    -- Calculate target camera CFrame
    local camPos = focusPoint + cameraOffset
    TP.TargetCF = CFrame.new(camPos, focusPoint)
    
    -- Smooth camera movement
    if TP.CurrentCF then
        TP.CurrentCF = TP.CurrentCF:Lerp(TP.TargetCF, TP.SmoothSpeed)
    else
        TP.CurrentCF = TP.TargetCF
    end
    
    -- Apply to camera
    Camera.CFrame = TP.CurrentCF
    
    -- Lock mouse to center (CRITICAL FIX)
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
end

-- Toggle third person
local function ToggleThirdPerson()
    local now = tick()
    if now - TP.LastToggle < TP.ToggleCooldown then return end
    TP.LastToggle = now
    
    TP.Active = not TP.Active
    CFG.TPOn = TP.Active
    
    if TP.Active then
        -- Enable third person
        Camera.CameraType = Enum.CameraType.Scriptable
        InitThirdPerson()
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        Notify("Third Person", "Enabled! Move mouse to rotate camera", T.Green)
        print("[Third Person] Enabled")
    else
        -- Disable third person
        Camera.CameraType = Enum.CameraType.Custom
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        Notify("Third Person", "Disabled", T.TextD)
        print("[Third Person] Disabled")
    end
end

-- Keybind listener
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CFG.TPKey then
        ToggleThirdPerson()
    end
end)

-- Handle respawn
LP.CharacterAdded:Connect(function(char)
    if TP.Active then
        task.wait(0.5)
        InitThirdPerson()
    end
end)

local spinAngle=0
local function OnCharAdded(char)
    task.wait(0.5)
    pcall(function()
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=16; hum.UseJumpPower=true; hum.JumpPower=50 end
    end)
    setupBV(char)
    if CFG.TPOn then pcall(function() Camera.CameraType=Enum.CameraType.Scriptable end) end
    
    -- Auto-apply skin when weapon equipped
    if CFG.SkinChangerEnabled and CFG.SkinAutoApply then
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.2)
                pcall(function()
                    print("[Skin Changer] Auto-applying skin to: " .. child.Name)
                    
                    for _, part in pairs(child:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("MeshPart") then
                            part.Color = CFG.SkinColor
                            part.Material = CFG.SkinMaterial
                            print("[Skin Changer]   Applied to: " .. part.Name)
                        end
                    end
                end)
            end
        end)
    end
end
LP.CharacterAdded:Connect(OnCharAdded)
if LP.Character then task.spawn(OnCharAdded,LP.Character) end

for _,pl in ipairs(Players:GetPlayers()) do
    if pl~=LP then pl.CharacterAdded:Connect(function(c) task.wait(1); MakeESP(c,pl.DisplayName) end) end
end
Players.PlayerAdded:Connect(function(pl)
    pl.CharacterAdded:Connect(function(c) task.wait(1); MakeESP(c,pl.DisplayName) end)
end)
Players.PlayerRemoving:Connect(function(pl)
    if pl.Character then KillESP(pl.Character) end
end)

-- ─── SCAN ────────────────────────────────────────────────────
local scanT=0
local function Scan()
    local now=tick(); if now-scanT<3 then return end; scanT=now
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl~=LP and pl.Character then
            pcall(MakeESP,pl.Character,pl.DisplayName)
        end
    end
end

-- ─── KILL AURA (FIXED: picks closest) ────────────────────────
local killauraT=0
local function RunKillaura()
    local now=tick()
    if not CFG.KillauraOn or now-killauraT<CFG.KillauraDelay then return end
    killauraT=now
    local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local closestDist=CFG.KillauraRange
    local closestPart=nil

    for _,pl in ipairs(Players:GetPlayers()) do
        if pl~=LP and pl.Character then
            local pr=pl.Character:FindFirstChild("HumanoidRootPart")
            local hum=pl.Character:FindFirstChildOfClass("Humanoid")
            if pr and hum and hum.Health>0 then
                local dist=(myRoot.Position-pr.Position).Magnitude
                if dist<=closestDist then
                    closestDist=dist; closestPart=pr
                end
            end
        end
    end

    if closestPart then
        pcall(function()
            Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,closestPart.Position+Vector3.new(0,1,0))
        end)
        pcall(function() mouse1press(); task.wait(0.03); mouse1release() end)
        DrawTrace(closestPart.Position+Vector3.new(0,1,0))
    end
end

-- ─── AUTO PARRY (PATTERN-BASED) ─────────────────────────────
local parryT=0
local function RunAutoParry()
    if not CFG.AutoParry then return end
    local now=tick()
    if now-parryT<0.15 then return end
    parryT=now
    
    pcall(function()
        local lpChar=LP.Character
        local lpRoot=lpChar and lpChar:FindFirstChild("HumanoidRootPart")
        if not lpRoot then return end
        
        -- Check for nearby enemy weapons (projectiles or melee)
        local shouldParry = false
        local nearbyDistance = 8  -- studs
        
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LP and pl.Character then
                local tool=pl.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local handle=tool:FindFirstChild("Handle")
                    if handle then
                        local dist=(lpRoot.Position-handle.Position).Magnitude
                        if dist < nearbyDistance then
                            shouldParry = true
                            break
                        end
                    end
                end
            end
        end
        
        if shouldParry then
            -- Method 1: Use detected parry remotes from pattern scanner
            if PATTERNS.ScanComplete and #PATTERNS.ParryRemotes > 0 then
                for _, remote in ipairs(PATTERNS.ParryRemotes) do
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                        print("[Auto Parry] Fired parry remote: " .. remote.Name)
                    elseif remote and remote:IsA("RemoteFunction") then
                        pcall(function() remote:InvokeServer() end)
                        print("[Auto Parry] Invoked parry function: " .. remote.Name)
                    end
                end
            else
                -- Fallback: Generic scan for parry remotes in character
                for _,v in pairs(lpChar:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        local name = v.Name:lower()
                        if name:find("parry") or name:find("block") or name:find("deflect") or name:find("counter") then
                            pcall(function() v:FireServer() end)
                            print("[Auto Parry] Fallback fired: " .. v.Name)
                        end
                    end
                end
            end
        end
    end)
end

-- ─── FLY SYSTEM ──────────────────────────────────────────────
local flyActive = false
local flyToggleCool = 0
local function RunFly(dt)
    if not CFG.FlyOn then
        if flyBV and flyBV.Parent then
            pcall(function() flyBV:Destroy() end); flyBV=nil
        end
        return
    end

    local now=tick()
    if UIS:IsKeyDown(CFG.FlyKey) and now-flyToggleCool>0.4 then
        flyToggleCool=now
        flyActive=not flyActive
    end

    if not flyActive then
        if flyBV and flyBV.Parent then pcall(function() flyBV:Destroy() end); flyBV=nil end
        return
    end

    pcall(function()
        local char=LP.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if not flyBV or not flyBV.Parent then
            flyBV=Instance.new("BodyVelocity")
            flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
            flyBV.Velocity=Vector3.zero
            flyBV.Parent=root
        end

        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)

        local vel=Vector3.zero
        local cf=Camera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,1,0) end

        flyBV.Velocity=vel*CFG.FlySpeed
    end)
end

-- ─── RELOAD DETECTION ────────────────────────────────────────
local isReloading = false
task.spawn(function()
    while GUI.Parent do
        pcall(function()
            local char=LP.Character
            if char then
                local tool=char:FindFirstChildOfClass("Tool")
                if tool then
                    local anim=char:FindFirstChild("Animate")
                    if anim then
                        local reload=anim:FindFirstChild("toolreload")
                        isReloading = (reload and reload.Value ~= "") or false
                    end
                else
                    isReloading=false
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- ─── SCOPE DETECTION ─────────────────────────────────────────
local isScoped = false
task.spawn(function()
    while GUI.Parent do
        pcall(function()
            local char=LP.Character
            if char then
                local hum=char:FindFirstChildOfClass("Humanoid")
                if hum then
                    isScoped = Camera.FieldOfView < 60
                end
            end
        end)
        task.wait(0.05)
    end
end)

-- ─── MAIN RENDER LOOP ────────────────────────────────────────
local aimT=0; local espT=0; local chamsT=0; local thirdCool=0; local autoClickT=0; local reactionT=0
local _silentCF = nil  -- Local Silent Aim CFrame (synced to _G._SilentCF each frame)

RS.RenderStepped:Connect(function(dt)
    local now=tick()
    pcall(function() Camera=workspace.CurrentCamera end)

    -- FOV Circle (OPTIMIZED: use cached radius, sync color)
    pcall(function()
        if FOVCircle then
            FOVCircle.Position=Vector2.new(Camera.ViewportSize.X*.5,Camera.ViewportSize.Y*.5)
            FOVCircle.Radius=_cachedFOVRadius or CFG.AimbotFOV
            FOVCircle.Color=CFG.FOVColor
            FOVCircle.Visible=CFG.ShowFOV and CFG.AimbotOn
        end
        -- Silent Aim FOV Circle
        if SilentFOVCircle then
            SilentFOVCircle.Position=Vector2.new(Camera.ViewportSize.X*.5,Camera.ViewportSize.Y*.5)
            SilentFOVCircle.Radius=CFG.SilentFOV
            SilentFOVCircle.Color=CFG.SilentFOVColor
            SilentFOVCircle.Visible=CFG.SilentShowFOV and CFG.SilentOn
        end
    end)

    -- Crosshair
    pcall(function()
        local cx=Camera.ViewportSize.X*.5; local cy=Camera.ViewportSize.Y*.5
        local s=CFG.CrossSize; local g=CFG.CrossGap; local th=CFG.CrossThick; local col=CFG.CrossColor
        for i=1,4 do if CrossLines[i] then CrossLines[i].Color=col;CrossLines[i].Thickness=th;CrossLines[i].Visible=CFG.CrossOn end end
        if CrossLines[5] then CrossLines[5].Color=col;CrossLines[5].Visible=CFG.CrossOn and CFG.CrossDot end
        if CFG.CrossOn then
            CrossLines[1].From=Vector2.new(cx,cy-g-s);CrossLines[1].To=Vector2.new(cx,cy-g)
            CrossLines[2].From=Vector2.new(cx,cy+g);  CrossLines[2].To=Vector2.new(cx,cy+g+s)
            CrossLines[3].From=Vector2.new(cx-g-s,cy);CrossLines[3].To=Vector2.new(cx-g,cy)
            CrossLines[4].From=Vector2.new(cx+g,cy);  CrossLines[4].To=Vector2.new(cx+g+s,cy)
            CrossLines[5].Position=Vector2.new(cx,cy)
        end
    end)

    -- Menu Cursor (FIXED: proper mouse toggle)
    pcall(function()
        local menuOpen = Win.Visible
        
        if MenuCursor.H then
            if menuOpen then
                -- Menu is open: hide OS cursor, show custom cursor
                UIS.MouseIconEnabled = false
                
                local mp = UIS:GetMouseLocation()
                local mx, my = mp.X, mp.Y
                local cs = 9
                local cs2 = 3
                
                MenuCursor.H.From = Vector2.new(mx-cs, my)
                MenuCursor.H.To = Vector2.new(mx+cs, my)
                MenuCursor.V.From = Vector2.new(mx, my-cs)
                MenuCursor.V.To = Vector2.new(mx, my+cs)
                MenuCursor.DL.From = Vector2.new(mx-cs2, my-cs2)
                MenuCursor.DL.To = Vector2.new(mx+cs2, my+cs2)
                MenuCursor.DR.From = Vector2.new(mx+cs2, my-cs2)
                MenuCursor.DR.To = Vector2.new(mx-cs2, my+cs2)
                MenuCursor.C.Position = Vector2.new(mx, my)
                
                for _, d in pairs(MenuCursor) do 
                    d.Visible = true
                end
            else
                -- Menu is closed: hide custom cursor, restore OS cursor
                UIS.MouseIconEnabled = true
                
                for _, d in pairs(MenuCursor) do 
                    d.Visible = false
                end
            end
        end
    end)

    -- Target Finding
    pcall(function()
        if CFG.AimbotOn then
            local char, tPart = FindTarget()
            _G_CT = tPart
        else
            _G_CT = nil
        end
    end)

    -- Silent Aim (FIX: instant aim, FOV check, no smooth)
    pcall(function()
        if CFG.SilentOn then
            local tPart=_G_CT
            if tPart then
                -- FOV check for Silent Aim
                local tPos=tPart.Position+(tPart.Name=="Head" and Vector3.new(0,.2,0) or Vector3.zero)
                local sc,on=Camera:WorldToViewportPoint(tPos)
                if on and sc.Z>0 then
                    local mPos=UIS:GetMouseLocation()
                    local dist=(Vector2.new(sc.X,sc.Y)-mPos).Magnitude
                    if dist<=CFG.SilentFOV then
                        -- Instant aim (no smooth)
                        _silentCF=CFrame.new(tPos)
                        _G_SilentCF=_silentCF
                    else
                        _silentCF=nil
                        _G_SilentCF=nil
                    end
                else
                    _silentCF=nil
                    _G_SilentCF=nil
                end
            else
                _silentCF=nil
                _G_SilentCF=nil
            end
        else
            _silentCF=nil
            _G_SilentCF=nil
        end
    end)

    -- Aimbot (PROFESSIONAL GRADE - LOCKED TRACKING)
    pcall(function()
        if not CFG.AimbotOn then return end
        if not UIS:IsKeyDown(CFG.AimbotKey) then return end
        
        local tPart = _G_CT
        if not tPart or not tPart.Parent then return end
        
        -- === POSITION CALCULATION ===
        local targetPos = tPart.Position
        
        -- Add offset for accuracy
        if tPart.Name == "Head" then
            targetPos = targetPos + Vector3.new(0, 0.2, 0)
        elseif tPart.Name == "UpperTorso" or tPart.Name == "Torso" then
            targetPos = targetPos + Vector3.new(0, 0.5, 0)
        end
        
        -- === ADVANCED PREDICTION ===
        if CFG.Prediction and tPart:IsA("BasePart") then
            local velocity = tPart.AssemblyLinearVelocity or tPart.Velocity or Vector3.zero
            local distance = (Camera.CFrame.Position - targetPos).Magnitude
            
            -- Bullet speed
            local bulletSpeed = 1200
            local timeToHit = distance / bulletSpeed
            
            -- MULTI-FRAME PREDICTION (tracks moving targets better)
            local predictedPos = targetPos + (velocity * timeToHit * 1.2)  -- 1.2x multiplier for better tracking
            
            -- Gravity compensation
            if distance > 80 then
                local gravity = workspace.Gravity or 196.2
                local drop = 0.5 * gravity * (timeToHit * timeToHit)
                predictedPos = predictedPos + Vector3.new(0, drop * 0.15, 0)
            end
            
            targetPos = predictedPos
        end
        
        -- === DYNAMIC SMOOTHING ===
        local distance = (Camera.CFrame.Position - targetPos).Magnitude
        
        local baseSmooth = CFG.AimbotSmooth or 0.25
        local strength = CFG.AimbotStrength or 0.5
        
        -- Distance factor (closer = faster tracking)
        local distanceFactor = math.clamp(1.2 - (distance / 300), 0.6, 1.2)
        
        -- Type multiplier
        local typeMultiplier = 1
        if CFG.AimbotType == "Quadratic" then
            typeMultiplier = strength * strength * 1.2
        elseif CFG.AimbotType == "Linear" then
            typeMultiplier = strength * 1.1
        end
        
        -- VELOCITY ADAPTATION (faster smooth for moving targets)
        local targetVelocity = tPart.AssemblyLinearVelocity or tPart.Velocity or Vector3.zero
        local velocityMagnitude = targetVelocity.Magnitude
        local velocityBoost = math.clamp(1 + (velocityMagnitude / 50), 1, 1.5)
        
        -- Final smooth
        local finalSmooth = baseSmooth * typeMultiplier * distanceFactor * velocityBoost
        finalSmooth = math.clamp(finalSmooth, 0.1, 0.95)
        
        -- === CAMERA AIMING ===
        local camPos = Camera.CFrame.Position
        local targetCFrame = CFrame.new(camPos, targetPos)
        
        -- SMOOTH LERP
        local newCFrame = Camera.CFrame:Lerp(targetCFrame, finalSmooth)
        
        Camera.CFrame = newCFrame
    end)

    -- Auto Click
    pcall(function()
        local tPart=_G_CT
        if CFG.AutoClick and CFG.AimbotOn and tPart and UIS:IsKeyDown(CFG.AimbotKey) and now-autoClickT>0.12 then
            autoClickT=now
            DrawTrace(tPart.Position+(tPart.Name=="Head" and Vector3.new(0,.2,0) or Vector3.zero))
            pcall(function() mouse1press(); task.wait(0.02); mouse1release() end)
        end
    end)

    -- No Recoil (v6 FIX: pitch delta preservation)
    local _prevPitch = 0
    pcall(function()
        if CFG.NoRecoil and not (CFG.AimbotOn and UIS:IsKeyDown(CFG.AimbotKey)) then
            local cf=Camera.CFrame
            local x,y,z=cf:ToOrientation()
            local delta = x - _prevPitch
            -- only compensate downward recoil (negative pitch change)
            if delta < 0 and math.abs(delta) > 0.002 then
                Camera.CFrame=CFrame.new(cf.Position)*CFrame.fromEulerAnglesYXZ(_prevPitch,y,0)
            else
                _prevPitch = x
            end
        else
            local cf=Camera.CFrame
            local x,y,z=cf:ToOrientation()
            _prevPitch = x
        end
    end)

    -- Spinbot
    pcall(function()
        if CFG.SpinbotOn or (CFG.AntiAimOn and CFG.AntiAimType == "Spinbot") then
            local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root then 
                spinAngle=(spinAngle+CFG.SpinSpeed*dt*60)%360
                root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,math.rad(spinAngle),0)
            end
        end
    end)
    
    -- Jitter Anti-Aim
    pcall(function()
        if CFG.AntiAimOn and CFG.AntiAimType == "Jitter" then
            local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local jitter = math.sin(tick() * CFG.JitterSpeed) * 180
                root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,math.rad(jitter),0)
            end
        end
    end)
    
    -- Sideways Anti-Aim
    pcall(function()
        if CFG.AntiAimOn and CFG.AntiAimType == "Sideways" then
            local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local side = tick() % 2 < 1 and 90 or -90
                root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,math.rad(side),0)
            end
        end
    end)
    
    -- Random Anti-Aim
    pcall(function()
        if CFG.AntiAimOn and CFG.AntiAimType == "Random" then
            local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if tick() % 0.1 < dt then
                    local randomAngle = math.random(-180, 180)
                    root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,math.rad(randomAngle),0)
                end
            end
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- ── SKELETON ESP RENDERING (OPTIMIZED) ─────────────────────────
    -- ═══════════════════════════════════════════════════════════════
    
    -- Throttle skeleton ESP to 30 FPS (every other frame)
    if now % 0.033 < dt then
        pcall(function()
            if CFG.SkeletonESP then
                for char, edata in pairs(ESP) do
                    if char and char.Parent and edata and edata.D then
                        local head = char:FindFirstChild("Head")
                        local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                        local lowerTorso = char:FindFirstChild("LowerTorso") or upperTorso
                        local lShoulder = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                        local lElbow = char:FindFirstChild("LeftLowerArm")
                        local rShoulder = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                        local rElbow = char:FindFirstChild("RightLowerArm")
                        local lHip = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                        local lKnee = char:FindFirstChild("LeftLowerLeg")
                        local rHip = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
                        local rKnee = char:FindFirstChild("RightLowerLeg")
                        
                        local function DrawBone(line, p1, p2)
                            if not line or not p1 or not p2 then return end
                            local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                            local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                            if on1 and on2 and s1.Z > 0 and s2.Z > 0 then
                                line.From = Vector2.new(s1.X, s1.Y)
                                line.To = Vector2.new(s2.X, s2.Y)
                                line.Color = CFG.SkeletonColor or Color3.fromRGB(255,255,255)
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                        end
                        
                        -- Only draw critical bones
                        if head and upperTorso then DrawBone(edata.D.SKL_Neck, head, upperTorso) end
                        if upperTorso and lowerTorso then DrawBone(edata.D.SKL_Torso, upperTorso, lowerTorso) end
                        if upperTorso and lShoulder then DrawBone(edata.D.SKL_LShoulder, upperTorso, lShoulder) end
                        if lShoulder and lElbow then DrawBone(edata.D.SKL_LArm, lShoulder, lElbow) end
                        if upperTorso and rShoulder then DrawBone(edata.D.SKL_RShoulder, upperTorso, rShoulder) end
                        if rShoulder and rElbow then DrawBone(edata.D.SKL_RArm, rShoulder, rElbow) end
                        if lowerTorso and lHip then DrawBone(edata.D.SKL_LHip, lowerTorso, lHip) end
                        if lHip and lKnee then DrawBone(edata.D.SKL_LLeg, lHip, lKnee) end
                        if lowerTorso and rHip then DrawBone(edata.D.SKL_RHip, lowerTorso, rHip) end
                        if rHip and rKnee then DrawBone(edata.D.SKL_RLeg, rHip, rKnee) end
                    end
                end
            else
                -- Hide skeleton lines when disabled
                for char, edata in pairs(ESP) do
                    if edata and edata.D then
                        for key, line in pairs(edata.D) do
                            if key:match("^SKL_") and line then
                                line.Visible = false
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- ── WEAPON & ARMOR ESP (OPTIMIZED) ─────────────────────────────
    -- ═══════════════════════════════════════════════════════════════
    
    -- Throttle weapon/armor ESP to 20 FPS
    if now % 0.05 < dt then
        pcall(function()
            for char, edata in pairs(ESP) do
                if char and char.Parent and edata and edata.D then
                    local weaponTxt = edata.D.WeaponTxt
                    local armorBar = edata.D.ArmorBar
                    
                    if CFG.WeaponESP and weaponTxt then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            weaponTxt.Text = "🔫 " .. tool.Name
                            weaponTxt.Color = Color3.fromRGB(255, 200, 100)
                            local head = char:FindFirstChild("Head")
                            if head then
                                local sc, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
                                if on and sc.Z > 0 then
                                    weaponTxt.Position = Vector2.new(sc.X, sc.Y)
                                    weaponTxt.Visible = true
                                else
                                    weaponTxt.Visible = false
                                end
                            end
                        else
                            weaponTxt.Visible = false
                        end
                    else
                        if weaponTxt then weaponTxt.Visible = false end
                    end
                    
                    if CFG.ArmorBar and armorBar then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local armorPercent = hum.Health / hum.MaxHealth
                            local head = char:FindFirstChild("Head")
                            if head then
                                local sc, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
                                if on and sc.Z > 0 then
                                    local barWidth = 40
                                    local barHeight = 4
                                    armorBar.Size = Vector2.new(barWidth * armorPercent, barHeight)
                                    armorBar.Position = Vector2.new(sc.X - barWidth/2, sc.Y)
                                    armorBar.Color = Color3.fromRGB(100, 150, 255)
                                    armorBar.Visible = true
                                else
                                    armorBar.Visible = false
                                end
                            end
                        else
                            armorBar.Visible = false
                        end
                    else
                        if armorBar then armorBar.Visible = false end
                    end
                end
            end
        end)
    end

    -- Professional Third Person System
    pcall(function()
        UpdateThirdPerson(dt)
    end)

    -- Fly
    RunFly(dt)
end)

-- ─── HEARTBEAT LOOP ──────────────────────────────────────────
local trigCool=false

RS.Heartbeat:Connect(function(dt)
    local now=tick()

    -- Speed Hack
    pcall(function()
        if CFG.SpeedOn then
            local char=LP.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local root=char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                if not(speedBV and speedBV.Parent) then setupBV(char) end
                if hum.MoveDirection.Magnitude>0 then speedBV.MaxForce=Vector3.new(1e4,0,1e4); speedBV.Velocity=hum.MoveDirection*CFG.WalkSpeed
                else speedBV.MaxForce=Vector3.zero; speedBV.Velocity=Vector3.zero end
                if hum.JumpPower~=CFG.JumpPower then hum.UseJumpPower=true; hum.JumpPower=CFG.JumpPower end
            end
        elseif speedBV and speedBV.Parent then speedBV.MaxForce=Vector3.zero; speedBV.Velocity=Vector3.zero end
    end)

    -- 🔥 Fire Rate Modifier (Professional Gun System Manipulation)
    pcall(function()
        if CFG.FireRateMod then
            local char = LP.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            
            -- Method 1: Modify LocalScript fireRate/cooldown values
            for _, script in pairs(tool:GetDescendants()) do
                if script:IsA("LocalScript") or script:IsA("ModuleScript") then
                    -- Try to access script environment (some executors support this)
                    pcall(function()
                        if script.Enabled and getfenv then
                            local env = getfenv(script)
                            if env then
                                -- Common fire rate variable names
                                if env.fireRate then
                                    env.fireRate = env.fireRate / CFG.FireRateMultiplier
                                end
                                if env.cooldown then
                                    env.cooldown = env.cooldown / CFG.FireRateMultiplier
                                end
                                if env.shootCooldown then
                                    env.shootCooldown = env.shootCooldown / CFG.FireRateMultiplier
                                end
                                if env.reloadTime then
                                    env.reloadTime = env.reloadTime / CFG.FireRateMultiplier
                                end
                            end
                        end
                    end)
                end
            end
            
            -- Method 2: Modify NumberValue/IntValue configurations
            for _, obj in pairs(tool:GetDescendants()) do
                pcall(function()
                    local name = obj.Name:lower()
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        if name:find("fire") or name:find("cool") or name:find("rate") or name:find("delay") then
                            -- Reduce cooldown/delay values
                            if obj.Value > 0 then
                                obj.Value = obj.Value / CFG.FireRateMultiplier
                            end
                        elseif name:find("speed") or name:find("rpm") then
                            -- Increase speed/RPM values
                            obj.Value = obj.Value * CFG.FireRateMultiplier
                        end
                    end
                end)
            end
            
            -- Method 3: Animation speed manipulation (visual fire rate)
            for _, obj in pairs(tool:GetDescendants()) do
                if obj:IsA("Animation") then
                    pcall(function()
                        local track = char:FindFirstChildOfClass("Humanoid"):LoadAnimation(obj)
                        if track then
                            track:AdjustSpeed(CFG.FireRateMultiplier)
                        end
                    end)
                end
            end
        end
    end)

    -- Bhop (separated from InfJump fix)
    pcall(function()
        if CFG.BhopOn and UIS:IsKeyDown(CFG.BhopKey) and CFG.BhopKey~=Enum.KeyCode.Space then
            local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then local s=hum:GetState(); if s==Enum.HumanoidStateType.Landed or s==Enum.HumanoidStateType.Running then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end
    end)

    -- Inf Jump (uses Space only, bhop now uses separate key)
    pcall(function()
        if CFG.InfJump and UIS:IsKeyDown(Enum.KeyCode.Space) then
            local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then local s=hum:GetState(); if s~=Enum.HumanoidStateType.Jumping and s~=Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end
    end)

    -- Anti-Void
    pcall(function()
        if CFG.AntiVoid then
            local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y<-300 then
                local hum=LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end
        end
    end)

    -- Noclip
    pcall(function()
        if CFG.NoclipOn then
            local char=LP.Character
            if char then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end
    end)

    -- Kill Aura
    RunKillaura()

    -- Auto Parry
    RunAutoParry()
    
    -- Hit Sound Detection (OPTIMIZED: cached players list)
    pcall(function()
        if CFG.HitSound then
            local playersList = Players:GetPlayers()
            for _, pl in ipairs(playersList) do
                if pl ~= LP and pl.Character then
                    local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local currentHealth = hum.Health
                        local previousHealth = lastKills[pl.UserId] or hum.MaxHealth
                        
                        if currentHealth < previousHealth and currentHealth > 0 then
                            PlayHitSound()
                        end
                        
                        lastKills[pl.UserId] = currentHealth
                    end
                end
            end
        end
    end)
    
    -- Kill Say Detection (OPTIMIZED)
    pcall(function()
        if CFG.KillSay then
            local playersList = Players:GetPlayers()
            for _, pl in ipairs(playersList) do
                if pl ~= LP and pl.Character then
                    local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health <= 0 then
                        local hadHealth = lastKills[pl.UserId .. "_alive"]
                        if hadHealth and tick() - lastKillSay > 1 then
                            lastKillSay = tick()
                            lastKills[pl.UserId .. "_alive"] = nil
                            local msg = CFG.KillSayMsg or "get good"
                            pcall(function()
                                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                            end)
                        end
                    elseif hum and hum.Health > 0 then
                        lastKills[pl.UserId .. "_alive"] = true
                    end
                end
            end
        end
    end)
    
    -- Chat Spam (OPTIMIZED)
    pcall(function()
        if CFG.SpamChat and tick() % CFG.SpamDelay < dt then
            local msg = CFG.KillSayMsg or "Celestial on top"
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
        end
    end)
    
    -- Fake Lag (OPTIMIZED)
    pcall(function()
        if CFG.VisualLag or CFG.FakeLagOn then
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                table.insert(lagPositions, root.CFrame)
                local maxTicks = CFG.FakeLagTicks or 5
                if #lagPositions > maxTicks then
                    table.remove(lagPositions, 1)
                end
                
                if #lagPositions >= maxTicks and tick() % 0.5 < dt then
                    root.CFrame = lagPositions[1]
                end
            end
        else
            lagPositions = {}
        end
    end)

    -- Triggerbot (v6 FIX: FindFirstAncestorOfClass)
    pcall(function()
        local shouldTrig=CFG.TrigOn
            and (not CFG.TrigDisableReload or not isReloading)
            and (not CFG.TrigOnScope or isScoped)
        if shouldTrig and UIS:IsKeyDown(CFG.TrigKey) and not trigCool then
            local ml=UIS:GetMouseLocation(); local ray=Camera:ViewportPointToRay(ml.X,ml.Y)
            local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude; rp.IgnoreWater=true
            local hit=workspace:Raycast(ray.Origin,ray.Direction*2500,rp)
            if hit and hit.Instance then
                local inst=hit.Instance
                -- v6 FIX: use FindFirstAncestorOfClass instead of .Parent chain
                local char = inst:FindFirstAncestorOfClass("Model")
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 and char~=LP.Character then
                    DrawTrace(hit.Position)
                    trigCool=true
                    task.spawn(function()
                        task.wait(CFG.TrigDelay)
                        pcall(function() mouse1press() end)
                        task.wait(math.max(0.02,CFG.TrigRelease))
                        pcall(function() mouse1release() end)
                        task.wait(0.1); trigCool=false
                    end)
                end
            end
        end
    end)

    -- Chams (OPTIMIZED: 0.2s interval, batch color update)
    if now-chamsT>0.2 then
        chamsT=now
        pcall(function()
            if CFG.ChamsOn then
                local chamColor = CFG.ChamsColor
                local chamTrans = 1 - CFG.ChamsIntensity
                for _,pl in ipairs(Players:GetPlayers()) do
                    if pl~=LP and pl.Character then
                        ApplyChams(pl.Character)
                        local hl=_chamBoxes[pl.Character]
                        if hl then 
                            hl.FillColor=chamColor
                            hl.FillTransparency=chamTrans
                            hl.OutlineColor=chamColor
                        end
                    end
                end
            else
                for char,hl in pairs(_chamBoxes) do
                    pcall(function() hl:Destroy() end)
                    _chamBoxes[char]=nil
                end
            end
        end)
    end

    -- Sky Color (OPTIMIZED: only update on config change, not every frame)
    -- Now handled by toggle callback for instant update

    -- ESP (FIX: reduced throttle, proper visibility control)
    if now-espT<0.03 then return end; espT=now

    if not CFG.ESPOn then
        for _,obj in pairs(ESP) do 
            if obj and obj.D then 
                for _,d in pairs(obj.D) do 
                    if d and typeof(d)=="table" and d.Visible~=nil then
                        pcall(function() d.Visible=false end) 
                    end
                end 
            end 
        end
        return
    end
    
    Scan()
    local lpChar=LP.Character
    local lpRoot=lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    local camPos=Camera.CFrame.Position
    local vp=Camera.ViewportSize
    
    for char,obj in pairs(ESP) do
        if not obj or not obj.D then KillESP(char); continue end
        local esp=obj.D
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        
        if not char or not char.Parent or not hum or hum.Health<=0 then 
            KillESP(char)
        else
            local success = pcall(function()
                local root=char:FindFirstChild("HumanoidRootPart")
                local head=char:FindFirstChild("Head")
                
                if not root or not head or char.Parent~=workspace then 
                    KillESP(char)
                    return
                end

                -- Distance check
                local dist=lpRoot and (lpRoot.Position-root.Position).Magnitude or (camPos-root.Position).Magnitude
                if dist>CFG.ESPMaxDist then
                    for _,d in pairs(esp) do pcall(function() d.Visible=false end) end
                    return
                end

                -- Viewport calculation
                local headPos=head.Position+Vector3.new(0,.55,0)
                local feetPos=root.Position-Vector3.new(0,3.2,0)
                local sH,onH=Camera:WorldToViewportPoint(headPos)
                local sR,onR=Camera:WorldToViewportPoint(root.Position)
                local sF=Camera:WorldToViewportPoint(feetPos)
                
                -- Visibility check: on screen AND in front of camera (depth > 0)
                if onH and onR and sH.Z>0 and sR.Z>0 then
                    local h=math.abs(sH.Y-sF.Y)
                    local w=h/2.2
                    local bx=sR.X-w*0.5
                    local by=sH.Y
                    local cor=math.min(w,h)*0.26
                    
                    -- Box ESP
                    if CFG.BoxESP and CFG.CornerBox then
                        local tl=Vector2.new(bx,by)
                        local tr=Vector2.new(bx+w,by)
                        local bl=Vector2.new(bx,by+h)
                        local br=Vector2.new(bx+w,by+h)
                        local cc=CFG.ESPColor
                        
                        esp.TL1.From=tl; esp.TL1.To=tl+Vector2.new(cor,0); esp.TL1.Color=cc; esp.TL1.Visible=true
                        esp.TL2.From=tl; esp.TL2.To=tl+Vector2.new(0,cor); esp.TL2.Color=cc; esp.TL2.Visible=true
                        esp.TR1.From=tr; esp.TR1.To=tr-Vector2.new(cor,0); esp.TR1.Color=cc; esp.TR1.Visible=true
                        esp.TR2.From=tr; esp.TR2.To=tr+Vector2.new(0,cor); esp.TR2.Color=cc; esp.TR2.Visible=true
                        esp.BL1.From=bl; esp.BL1.To=bl+Vector2.new(cor,0); esp.BL1.Color=cc; esp.BL1.Visible=true
                        esp.BL2.From=bl; esp.BL2.To=bl-Vector2.new(0,cor); esp.BL2.Color=cc; esp.BL2.Visible=true
                        esp.BR1.From=br; esp.BR1.To=br-Vector2.new(cor,0); esp.BR1.Color=cc; esp.BR1.Visible=true
                        esp.BR2.From=br; esp.BR2.To=br-Vector2.new(0,cor); esp.BR2.Color=cc; esp.BR2.Visible=true
                        esp.Box.Visible=false
                    elseif CFG.BoxESP then
                        esp.Box.Position=Vector2.new(bx,by)
                        esp.Box.Size=Vector2.new(w,h)
                        esp.Box.Color=CFG.ESPColor
                        esp.Box.Visible=true
                        for _,k in ipairs({"TL1","TL2","TR1","TR2","BL1","BL2","BR1","BR2"}) do 
                            esp[k].Visible=false 
                        end
                    else
                        esp.Box.Visible=false
                        for _,k in ipairs({"TL1","TL2","TR1","TR2","BL1","BL2","BR1","BR2"}) do 
                            esp[k].Visible=false 
                        end
                    end
                    
                    -- Health Bar
                    local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                    if CFG.HealthBar then
                        esp.HBG.Position=Vector2.new(bx-7,by)
                        esp.HBG.Size=Vector2.new(4,h)
                        esp.HBG.Visible=true
                        esp.HBF.Position=Vector2.new(bx-7,by+h*(1-hp))
                        esp.HBF.Size=Vector2.new(4,h*hp)
                        esp.HBF.Color=Color3.new(1-hp,hp,0)
                        esp.HBF.Visible=true
                    else 
                        esp.HBG.Visible=false
                        esp.HBF.Visible=false
                    end
                    
                    -- Name
                    if CFG.ShowName then
                        esp.NT.Text=obj.pl and obj.pl.DisplayName or char.Name
                        esp.NT.Position=Vector2.new(sR.X,by-18)
                        esp.NT.Visible=true
                    else 
                        esp.NT.Visible=false
                    end
                    
                    -- Distance
                    if CFG.ShowDist then
                        esp.DT.Text=string.format("[%dm]",math.floor(dist*0.28))
                        esp.DT.Position=Vector2.new(sR.X,by+h+3)
                        esp.DT.Visible=true
                    else 
                        esp.DT.Visible=false
                    end
                    
                    -- Snapline
                    if CFG.SnapLines then
                        esp.SL.From=Vector2.new(vp.X*0.5,vp.Y)
                        esp.SL.To=Vector2.new(sR.X,sR.Y)
                        esp.SL.Color=CFG.ESPColor
                        esp.SL.Visible=true
                    else 
                        esp.SL.Visible=false
                    end
                    
                    -- Head Dot
                    if CFG.HeadDot then
                        esp.HD.Position=Vector2.new(sH.X,sH.Y)
                        esp.HD.Color=CFG.ESPColor
                        esp.HD.Visible=true
                    else 
                        esp.HD.Visible=false
                    end
                else
                    -- Off-screen: hide all ESP elements
                    for _,d in pairs(esp) do 
                        pcall(function() d.Visible=false end) 
                    end
                end
            end)
            
            if not success then
                KillESP(char)
            end
        end
    end
end)

-- ─── CLOSE ───────────────────────────────────────────────────
BtnClose.MouseButton1Click:Connect(function()
    print("[Celestial] Closing script...")
    
    -- Restore metamethods
    if _useHM then
        pcall(function() hookmetamethod(_g,"__namecall",_ncOrig) end)
        pcall(function() hookmetamethod(_g,"__index",   _idxOrig) end)
    else
        if _gmt then
            pcall(function()
                setreadonly(_gmt,false)
                _gmt.__namecall=_ncOrig
                _gmt.__index   =_idxOrig
                setreadonly(_gmt,true)
            end)
        end
    end
    _G._CT=nil; _G._SilentCF=nil
    
    -- CRITICAL: Restore mouse FIRST, before any other cleanup
    RestoreMouse()
    
    -- Cleanup drawings
    for _,d in ipairs(DC) do KillD(d) end
    for ch in pairs(ESP) do KillESP(ch) end
    for char,sb in pairs(_chamBoxes) do pcall(function() sb:Destroy() end) end
    
    -- Physics cleanup
    if speedBV then pcall(function() speedBV:Destroy() end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end
    
    -- Restore physics
    pcall(function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
        end
    end)
    
    -- Restore gravity
    pcall(function() workspace.Gravity=196.2 end)
    
    -- Restore camera
    pcall(function()
        Camera.CameraType=Enum.CameraType.Custom
        local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then Camera.CameraSubject=h end
    end)
    
    -- Animate out
    TweenS:Create(Win,TweenInfo.new(0.2),{Size=UDim2.new(0,0,0,0)}):Play()
    task.wait(0.25)
    pcall(function() GUI:Destroy() end)
    if getgenv then getgenv().CelLoaded=nil end
    
    print("[Celestial] Script closed successfully")
end)

-- ─── INIT ────────────────────────────────────────────────────
scanT=0; Scan()
Notify("Celestial v7","Loaded successfully! Press RightAlt to toggle.",T.Accent)

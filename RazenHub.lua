--[[
    Razen Hub - Premium UI Foundation
    Standalone Roblox Lua UI scaffold; no external UI libraries required.

    This file implements the draggable GUI, tabs, notifications, sliders,
    feature switches, hotkey, and experience-name detection. Feature switches
    intentionally manage UI state only; connect legitimate game-owned handlers
    in your own Roblox experience before enabling actual gameplay behavior.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("Razen Hub: LocalPlayer not available.")
    return
end

local CONFIG = {
    Name = "Razen Hub",
    Version = "1.0.0 UI",
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(232, 232, 238),
    Background = Color3.fromRGB(8, 8, 11),
    Panel = Color3.fromRGB(15, 15, 19),
    PanelLight = Color3.fromRGB(22, 22, 28),
    Border = Color3.fromRGB(47, 47, 57),
    Muted = Color3.fromRGB(145, 145, 158),
    Text = Color3.fromRGB(244, 244, 248),
    Red = Color3.fromRGB(255, 88, 96),
    Blue = Color3.fromRGB(82, 164, 255),
    Green = Color3.fromRGB(84, 216, 139),
    Yellow = Color3.fromRGB(255, 210, 82),
}

local oldGui
local function getGuiParent()
    -- Prefer an executor-provided UI container when available, but remain usable
    -- in an ordinary LocalScript by falling back to PlayerGui.
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
oldGui = guiParent:FindFirstChild("RazenHubUI")
if oldGui then
    oldGui:Destroy()
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function stroke(parent, color, transparency, thickness)
    return make("UIStroke", {
        Color = color or CONFIG.Border,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    }, parent)
end

local function tween(obj, duration, props)
    local animation = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
    animation:Play()
    return animation
end

local function addText(parent, text, size, color, font, props)
    props = props or {}
    props.BackgroundTransparency = 1
    props.Text = text
    props.TextSize = size or 13
    props.TextColor3 = color or CONFIG.Text
    props.Font = font or Enum.Font.Gotham
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    return make("TextLabel", props, parent)
end

local screen = make("ScreenGui", {
    Name = "RazenHubUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, guiParent)

local root = make("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(700, 460),
    BackgroundColor3 = CONFIG.Background,
    BorderSizePixel = 0,
}, screen)
corner(root, 12)
stroke(root, CONFIG.Border, 0.12, 1)

local scale = make("UIScale", { Scale = 1 }, root)
local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    scale.Scale = math.clamp(math.min(viewport.X / 780, viewport.Y / 540), 0.62, 1)
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- Soft monochrome highlight at the top edge.
make("Frame", {
    Name = "TopAccent",
    Position = UDim2.new(0, 18, 0, 0),
    Size = UDim2.new(1, -36, 0, 2),
    BackgroundColor3 = CONFIG.Accent,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
}, root)

local topbar = make("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundTransparency = 1,
}, root)

local logo = make("Frame", {
    Position = UDim2.fromOffset(18, 14),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = CONFIG.PanelLight,
    BorderSizePixel = 0,
}, topbar)
corner(logo, 9)
stroke(logo, CONFIG.Border, 0.15, 1)
addText(logo, "R", 20, CONFIG.Text, Enum.Font.GothamBold, {
    Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
})

addText(topbar, "RAZEN HUB", 16, CONFIG.Text, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(62, 12), Size = UDim2.fromOffset(170, 21),
})
addText(topbar, "PREMIUM  /  " .. CONFIG.Version, 9, CONFIG.Muted, Enum.Font.GothamMedium, {
    Position = UDim2.fromOffset(63, 34), Size = UDim2.fromOffset(220, 15),
})

local experienceLabel = addText(topbar, "DETECTING EXPERIENCE...", 10, CONFIG.Muted, Enum.Font.GothamMedium, {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -100, 0, 31),
    Size = UDim2.fromOffset(230, 22), TextXAlignment = Enum.TextXAlignment.Right,
})
local closeButton = make("TextButton", {
    Name = "HideButton", AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -15, 0, 17), Size = UDim2.fromOffset(30, 28),
    BackgroundColor3 = CONFIG.PanelLight, Text = "×", TextSize = 20,
    TextColor3 = CONFIG.Text, Font = Enum.Font.Gotham, AutoButtonColor = false,
    BorderSizePixel = 0,
}, topbar)
corner(closeButton, 7)

make("Frame", {
    Position = UDim2.new(0, 0, 0, 61), Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = CONFIG.Border, BackgroundTransparency = 0.2, BorderSizePixel = 0,
}, root)

local sidebar = make("Frame", {
    Name = "Sidebar", Position = UDim2.fromOffset(0, 62),
    Size = UDim2.new(0, 174, 1, -62), BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
}, root)
make("Frame", {
    Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = CONFIG.Border, BackgroundTransparency = 0.3, BorderSizePixel = 0,
}, sidebar)

addText(sidebar, "WORKSPACE", 9, CONFIG.Muted, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(17, 18), Size = UDim2.fromOffset(130, 18),
})
local navHolder = make("Frame", {
    Position = UDim2.fromOffset(10, 43), Size = UDim2.new(1, -20, 0, 210),
    BackgroundTransparency = 1,
}, sidebar)
make("UIListLayout", {
    Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
}, navHolder)

local pageHost = make("Frame", {
    Name = "PageHost", Position = UDim2.fromOffset(175, 62),
    Size = UDim2.new(1, -175, 1, -62), BackgroundTransparency = 1,
    ClipsDescendants = true,
}, root)

local statusCard = make("Frame", {
    Position = UDim2.new(0, 11, 1, -64), Size = UDim2.new(1, -22, 0, 49),
    BackgroundColor3 = CONFIG.PanelLight, BorderSizePixel = 0,
}, sidebar)
corner(statusCard, 8)
stroke(statusCard, CONFIG.Border, 0.35, 1)
make("Frame", {
    Position = UDim2.fromOffset(11, 15), Size = UDim2.fromOffset(7, 7),
    BackgroundColor3 = CONFIG.Green, BorderSizePixel = 0,
}, statusCard)
corner(statusCard:FindFirstChildOfClass("Frame"), 10)
addText(statusCard, "UI STATUS", 9, CONFIG.Muted, Enum.Font.GothamBold, {
    Position = UDim2.fromOffset(26, 6), Size = UDim2.fromOffset(100, 14),
})
addText(statusCard, "Ready", 11, CONFIG.Text, Enum.Font.GothamMedium, {
    Position = UDim2.fromOffset(26, 21), Size = UDim2.fromOffset(100, 16),
})

local toastLayer = make("Frame", {
    Name = "Notifications", AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, 18), Size = UDim2.fromOffset(280, 280),
    BackgroundTransparency = 1, ZIndex = 100,
}, screen)
make("UIListLayout", {
    Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
}, toastLayer)

local function notify(title, message)
    local toast = make("Frame", {
        Size = UDim2.fromOffset(270, 66), BackgroundColor3 = CONFIG.Panel,
        BackgroundTransparency = 0.03, BorderSizePixel = 0, ZIndex = 101,
    }, toastLayer)
    corner(toast, 9)
    stroke(toast, CONFIG.Border, 0.08, 1)
    make("Frame", {
        Size = UDim2.new(0, 3, 1, -18), Position = UDim2.fromOffset(0, 9),
        BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0, ZIndex = 102,
    }, toast)
    addText(toast, title, 12, CONFIG.Text, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -24, 0, 19), ZIndex = 102,
    })
    addText(toast, message, 10, CONFIG.Muted, Enum.Font.Gotham, {
        Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -24, 0, 23),
        TextWrapped = true, ZIndex = 102,
    })
    toast.BackgroundTransparency = 1
    tween(toast, 0.18, { BackgroundTransparency = 0.03 })
    task.delay(3.5, function()
        if toast and toast.Parent then
            tween(toast, 0.18, { BackgroundTransparency = 1 })
            task.wait(0.2)
            if toast then toast:Destroy() end
        end
    end)
end

local settings = {
    Speed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    HitboxSize = 5,
    EggESP = false,
    AutoStealDivine = false,
    AutoStealSecret = false,
    AutoStealInternal = false,
    AutoStealMythic = false,
    AntiTrap = false,
    AntiHit = false,
    SheriffESP = true,
    MurdererESP = true,
    InnocentESP = true,
    GunESP = true,
    AimBot = false,
    AutoFarmCoins = false,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    SafeMode = true,
}

-- Feature switches update the GUI's local configuration only. Hook your own
-- server-authorized game code to FeatureChanged for real behavior.
local featureChanged = Instance.new("BindableEvent")
local FEATURE_CHANGED_EVENT = featureChanged.Event
local function setFeature(key, value)
    settings[key] = value
    featureChanged:Fire(key, value, settings)
    notify(key, value and "Enabled in UI settings" or "Disabled in UI settings")
end

local pages = {}
local selectedPage = nil
local navButtons = {}
local navCount = 0

local function createPage(name, title, subtitle)
    local page = make("ScrollingFrame", {
        Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, pageHost)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20),
        PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18),
    }, page)
    local content = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, page)
    make("UIListLayout", {
        Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)
    addText(content, title, 20, CONFIG.Text, Enum.Font.GothamBold, {
        Size = UDim2.new(1, 0, 0, 29), LayoutOrder = 1,
    })
    addText(content, subtitle, 11, CONFIG.Muted, Enum.Font.Gotham, {
        Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 2,
    })
    pages[name] = { frame = page, content = content, nextOrder = 3 }
    return pages[name]
end

local function selectPage(name)
    if not pages[name] then return end
    selectedPage = name
    for pageName, page in pairs(pages) do
        page.frame.Visible = pageName == name
    end
    for buttonName, button in pairs(navButtons) do
        local active = buttonName == name
        tween(button, 0.12, {
            BackgroundColor3 = active and CONFIG.PanelLight or CONFIG.Panel,
            TextColor3 = active and CONFIG.Text or CONFIG.Muted,
        })
        local indicator = button:FindFirstChild("ActiveIndicator")
        if indicator then indicator.Visible = active end
    end
end

local function nav(name, label, glyph)
    navCount += 1
    local button = make("TextButton", {
        Name = name .. "Nav", Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = CONFIG.Panel, Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, LayoutOrder = navCount,
    }, navHolder)
    corner(button, 7)
    local indicator = make("Frame", {
        Name = "ActiveIndicator", Position = UDim2.fromOffset(0, 8),
        Size = UDim2.fromOffset(2, 20), BackgroundColor3 = CONFIG.Accent,
        BorderSizePixel = 0, Visible = false,
    }, button)
    corner(indicator, 2)
    addText(button, glyph, 13, CONFIG.Muted, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(12, 0), Size = UDim2.fromOffset(20, 36),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    addText(button, label, 12, CONFIG.Muted, Enum.Font.GothamMedium, {
        Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -48, 1, 0),
    })
    navButtons[name] = button
    button.MouseButton1Click:Connect(function() selectPage(name) end)
end

local function section(pageName, title)
    local page = pages[pageName]
    if not page then return end
    local wrap = make("Frame", {
        Size = UDim2.new(1, 0, 0, 31), BackgroundTransparency = 1,
        LayoutOrder = page.nextOrder,
    }, page.content)
    page.nextOrder += 1
    addText(wrap, string.upper(title), 10, CONFIG.Muted, Enum.Font.GothamBold, {
        Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, 0, 1, 0),
    })
    make("Frame", {
        Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = CONFIG.Border, BackgroundTransparency = 0.45, BorderSizePixel = 0,
    }, wrap)
end

local function row(pageName, title, description, height)
    local page = pages[pageName]
    local frame = make("Frame", {
        Size = UDim2.new(1, 0, 0, height or 54), BackgroundColor3 = CONFIG.Panel,
        BorderSizePixel = 0, LayoutOrder = page.nextOrder,
    }, page.content)
    page.nextOrder += 1
    corner(frame, 8)
    stroke(frame, CONFIG.Border, 0.5, 1)
    addText(frame, title, 12, CONFIG.Text, Enum.Font.GothamMedium, {
        Position = UDim2.fromOffset(12, 7), Size = UDim2.new(1, -120, 0, 19),
    })
    if description and description ~= "" then
        addText(frame, description, 10, CONFIG.Muted, Enum.Font.Gotham, {
            Position = UDim2.fromOffset(12, 27), Size = UDim2.new(1, -120, 0, 17),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
    end
    return frame
end

local function addToggle(pageName, label, description, key, defaultValue)
    settings[key] = settings[key] == nil and (defaultValue or false) or settings[key]
    local frame = row(pageName, label, description, 54)
    local toggle = make("TextButton", {
        Name = key .. "Toggle", AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(42, 23),
        BackgroundColor3 = settings[key] and CONFIG.Accent or CONFIG.Border,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0,
    }, frame)
    corner(toggle, 12)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(17, 17), Position = settings[key] and UDim2.new(1, -20, 0.5, -8) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = settings[key] and CONFIG.Background or CONFIG.Text,
        BorderSizePixel = 0,
    }, toggle)
    corner(knob, 10)
    toggle.MouseButton1Click:Connect(function()
        local value = not settings[key]
        setFeature(key, value)
        tween(toggle, 0.13, { BackgroundColor3 = value and CONFIG.Accent or CONFIG.Border })
        tween(knob, 0.13, {
            Position = value and UDim2.new(1, -20, 0.5, -8) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = value and CONFIG.Background or CONFIG.Text,
        })
    end)
end

local function addSlider(pageName, label, description, key, minimum, maximum, initial)
    settings[key] = settings[key] or initial
    local frame = row(pageName, label, description, 78)
    local valueLabel = addText(frame, tostring(settings[key]), 11, CONFIG.Text, Enum.Font.GothamBold, {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 8),
        Size = UDim2.fromOffset(90, 18), TextXAlignment = Enum.TextXAlignment.Right,
    })
    local minus = make("TextButton", {
        Position = UDim2.new(1, -112, 0, 43), Size = UDim2.fromOffset(24, 24),
        Text = "−", TextSize = 17, TextColor3 = CONFIG.Text, Font = Enum.Font.Gotham,
        BackgroundColor3 = CONFIG.PanelLight, BorderSizePixel = 0, AutoButtonColor = false,
    }, frame)
    corner(minus, 6)
    local plus = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 43),
        Size = UDim2.fromOffset(24, 24), Text = "+", TextSize = 17,
        TextColor3 = CONFIG.Text, Font = Enum.Font.Gotham,
        BackgroundColor3 = CONFIG.PanelLight, BorderSizePixel = 0, AutoButtonColor = false,
    }, frame)
    corner(plus, 6)
    local track = make("Frame", {
        Position = UDim2.new(0, 12, 0, 51), Size = UDim2.new(1, -146, 0, 7),
        BackgroundColor3 = CONFIG.Border, BorderSizePixel = 0,
    }, frame)
    corner(track, 6)
    local ratio = math.clamp((settings[key] - minimum) / math.max(maximum - minimum, 1), 0, 1)
    local fill = make("Frame", {
        Size = UDim2.new(ratio, 0, 1, 0), BackgroundColor3 = CONFIG.Accent,
        BorderSizePixel = 0,
    }, track)
    corner(fill, 6)
    local dragging = false
    local function setValue(value)
        settings[key] = math.clamp(math.floor(value + 0.5), minimum, maximum)
        valueLabel.Text = tostring(settings[key])
        local nextRatio = (settings[key] - minimum) / math.max(maximum - minimum, 1)
        tween(fill, 0.08, { Size = UDim2.new(nextRatio, 0, 1, 0) })
        featureChanged:Fire(key, settings[key], settings)
    end
    minus.MouseButton1Click:Connect(function() setValue(settings[key] - math.max(1, math.floor((maximum - minimum) / 100))) end)
    plus.MouseButton1Click:Connect(function() setValue(settings[key] + math.max(1, math.floor((maximum - minimum) / 100))) end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setValue(minimum + rel * (maximum - minimum))
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setValue(minimum + rel * (maximum - minimum))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function addInfo(pageName, title, message, color)
    local frame = row(pageName, title, message, 61)
    local line = make("Frame", {
        Position = UDim2.fromOffset(0, 9), Size = UDim2.fromOffset(3, 43),
        BackgroundColor3 = color or CONFIG.Accent, BorderSizePixel = 0,
    }, frame)
    corner(line, 2)
end

-- Build all tabs.
createPage("Home", "Welcome to Razen Hub", "A premium monochrome control center.")
createPage("Egg", "Steal an Egg", "Experience-specific panel — settings and UI states.")
createPage("MM2", "Murder Mystery 2", "Role and item display preferences.")
createPage("Universal", "Universal", "General controls for your own test experience.")
createPage("Settings", "Settings", "Interface behavior and local preferences.")

nav("Home", "Overview", "◈")
nav("Egg", "Steal an Egg", "◇")
nav("MM2", "Murder Mystery 2", "◉")
nav("Universal", "Universal", "⌘")
nav("Settings", "Settings", "⚙")

section("Home", "Session")
addInfo("Home", "Razen is ready", "The interface is loaded. Choose a section from the sidebar.", CONFIG.Green)
addInfo("Home", "Experience detection", "The active experience name is detected when Roblox exposes it.", CONFIG.Blue)
addInfo("Home", "Feature adapter", "Controls store values and fire FeatureChanged for your own game logic.", CONFIG.Yellow)

section("Egg", "Egg display")
addToggle("Egg", "Egg ESP", "Preference toggle · UI state only", "EggESP", false)
section("Egg", "Auto-steal categories")
addToggle("Egg", "Divine eggs", "Preference toggle · UI state only", "AutoStealDivine", false)
addToggle("Egg", "Secret eggs", "Preference toggle · UI state only", "AutoStealSecret", false)
addToggle("Egg", "Internal eggs", "Preference toggle · UI state only", "AutoStealInternal", false)
addToggle("Egg", "Mythic eggs", "Preference toggle · UI state only", "AutoStealMythic", false)
section("Egg", "Character options")
addSlider("Egg", "Walk speed", "Range 16–800 · UI value only", "Speed", 16, 800, 16)
addToggle("Egg", "Anti-trap preference", "UI state only; no trap bypass is applied", "AntiTrap", false)
addToggle("Egg", "Anti-hit preference", "UI state only; no hit bypass is applied", "AntiHit", false)

section("MM2", "Role colors")
addInfo("MM2", "Murderer", "Red · " .. "#FF5860", CONFIG.Red)
addInfo("MM2", "Sheriff", "Blue · " .. "#52A4FF", CONFIG.Blue)
addInfo("MM2", "Innocent", "Green · " .. "#54D88B", CONFIG.Green)
addInfo("MM2", "Gun", "Yellow · " .. "#FFD252", CONFIG.Yellow)
section("MM2", "Feature preferences")
addToggle("MM2", "Sheriff ESP", "Preference toggle · UI state only", "SheriffESP", true)
addToggle("MM2", "Murderer ESP", "Preference toggle · UI state only", "MurdererESP", true)
addToggle("MM2", "Innocent ESP", "Preference toggle · UI state only", "InnocentESP", true)
addToggle("MM2", "Gun ESP", "Preference toggle · UI state only", "GunESP", true)
addToggle("MM2", "Aim assist", "Preference toggle · no targeting is performed", "AimBot", false)
addToggle("MM2", "Coin farming", "Preference toggle · no automated collection is performed", "AutoFarmCoins", false)
addSlider("MM2", "Hitbox size", "Range 5–30 · UI value only", "HitboxSize", 5, 30, 5)

section("Universal", "Movement settings")
addSlider("Universal", "Walk speed", "Range 16–100000 · UI value only", "Speed", 16, 100000, 16)
addSlider("Universal", "Jump power", "Range 1–10000000 · UI value only", "JumpPower", 1, 10000000, 50)
addToggle("Universal", "Fly", "Preference toggle · no movement is applied", "Fly", false)
addSlider("Universal", "Fly speed", "Range 1–1000 · UI value only", "FlySpeed", 1, 1000, 50)
addToggle("Universal", "Noclip", "Preference toggle · collision is not changed", "Noclip", false)
addToggle("Universal", "Infinite jump", "Preference toggle · jump behavior is not changed", "InfiniteJump", false)

section("Settings", "Interface")
addInfo("Settings", "Toggle menu", "Press RightShift to show or hide the interface.")
addInfo("Settings", "Drag window", "Drag the top bar to move the GUI.")
addToggle("Settings", "Safe mode", "Keep controls as UI preferences only", "SafeMode", true)
addInfo("Settings", "Anti-cheat", "No anti-cheat bypass or undetectability is provided.", CONFIG.Yellow)
addInfo("Settings", "FeatureChanged event", "Use the event to connect approved logic in your own Roblox experience.", CONFIG.Blue)

-- Drag from the title bar (ignore clicks on buttons).
local draggingWindow = false
local dragStart, startPosition
local function isButtonUnderPointer(input)
    local pos = input.Position
    local objects = GuiService:GetGuiObjectsAtPosition(pos.X, pos.Y)
    for _, object in ipairs(objects) do
        if object:IsA("TextButton") then return true end
    end
    return false
end

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Title bar controls remain clickable; only drag if not on a button.
        if isButtonUnderPointer(input) then return end
        draggingWindow = true
        dragStart = input.Position
        startPosition = root.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = false
    end
end)

local isVisible = true
local function setVisible(value)
    isVisible = value
    root.Visible = value
    if value then
        notify("Razen Hub", "Interface opened")
    end
end
closeButton.MouseButton1Click:Connect(function() setVisible(false) end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        setVisible(not isVisible)
    end
end)

local function detectExperience()
    local experienceName = game.Name
    local ok, productInfo = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and productInfo and productInfo.Name then
        experienceName = productInfo.Name
    end
    local normalized = string.lower(experienceName or "")
    if string.find(normalized, "steal an egg", 1, true) then
        experienceLabel.Text = "STEAL AN EGG"
        selectPage("Egg")
    elseif string.find(normalized, "murder mystery", 1, true) or string.find(normalized, "mm2", 1, true) then
        experienceLabel.Text = "MURDER MYSTERY 2"
        selectPage("MM2")
    else
        experienceLabel.Text = string.upper(string.sub(experienceName or "UNIVERSAL", 1, 28))
        selectPage("Universal")
    end
    notify("Experience detected", experienceName or "Unknown experience")
end

task.spawn(detectExperience)
selectPage("Home")
notify("Razen Hub", "Premium interface loaded · RightShift to toggle")

-- Optional bridge for code in the same environment. Keep a reference to the
-- event if attaching approved handlers after this script runs.
_G.RazenHub = {
    Settings = settings,
    FeatureChanged = FEATURE_CHANGED_EVENT,
    Notify = notify,
    SetVisible = setVisible,
    SelectPage = selectPage,
    Destroy = function()
        if screen then screen:Destroy() end
        featureChanged:Destroy()
        _G.RazenHub = nil
    end,
}

print("[Razen Hub] UI ready. Features are UI-state controls until connected to approved game logic.")

-- ===================================================================
--                       RAZEN HUB - MAIN SCRIPT
--                  Built Custom without External Libraries
-- ===================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables State
local States = {
    Speed = 16,
    Jump = 50,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    InfiniteJump = false,
    StealEggs = false,
    MM2_SheriffESP = false,
    MM2_MurderESP = false,
    MM2_InnocentESP = false,
    MM2_Aimbot = false,
    MM2_AutoFarm = false,
    MM2_HitboxSize = 2,
    Steal_EggESP = false
}

-- ===================================================================
-- SECTION 1: ADVANCED ANTI-CHEAT BYPASS & SECURITY HOOKS
-- ===================================================================

local function ApplyAntiCheatBypass()
    local RawMetatable = getrawmetatable(game)
    if setreadonly then setreadonly(RawMetatable, false) end
    
    local OldIndex = RawMetatable.__index
    local OldNamecall = RawMetatable.__namecall
    local OldNewIndex = RawMetatable.__newindex
    
    -- Spoofing WalkSpeed and JumpPower checks
    RawMetatable.__index = newcclosure(function(Self, Key)
        if not checkcaller() and Self == LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            if Key == "WalkSpeed" then return 16 end
            if Key == "JumpPower" or Key == "JumpHeight" then return 50 end
        end
        return OldIndex(Self, Key)
    end)
    
    -- Block remote detection / crash attempts
    RawMetatable.__namecall = newcclosure(function(Self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        
        if not checkcaller() then
            if Method == "FireServer" or Method == "InvokeServer" then
                local RemoteName = string.lower(Self.Name)
                if string.find(RemoteName, "cheat") or string.find(RemoteName, "ban") or string.find(RemoteName, "detect") or string.find(RemoteName, "exploit") then
                    return nil
                end
            end
        end
        return OldNamecall(Self, ...)
    end)
    
    if setreadonly then setreadonly(RawMetatable, true) end
end

pcall(ApplyAntiCheatBypass)

-- Disable Memory / Detection Scripts locally
task.spawn(function()
    while task.wait(5) do
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                local name = string.lower(v.Name)
                if string.find(name, "anti") or string.find(name, "detect") or string.find(name, "ac") then
                    v.Disabled = true
                end
            end
        end
    end
end)

-- ===================================================================
-- SECTION 2: DARK CUSTOM MONOCHROME UI DESIGN (NO LIBRARIES)
-- ===================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RazenHubUI"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- Floating Button (Draggable & Toggle)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "RazenToggleBtn"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BorderSizePixel = 1
ToggleButton.Text = "RH"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Title Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.BorderColor3 = Color3.fromRGB(255, 255, 255)
Header.BorderSizePixel = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RAZEN HUB  |  MONOCHROME EDITION"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Sidebar Navigation Container
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Sidebar.BorderColor3 = Color3.fromRGB(255, 255, 255)
Sidebar.BorderSizePixel = 1
Sidebar.Parent = MainFrame

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -35)
ContentContainer.Position = UDim2.new(0, 130, 0, 35)
ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

local function CreateTab(tabName)
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, -20, 1, -20)
    TabFrame.Position = UDim2.new(0, 10, 0, 10)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ScrollBarThickness = 2
    TabFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    TabFrame.Visible = false
    TabFrame.Parent = ContentContainer
    
    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)
    UIList.Parent = TabFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = UDim2.new(0, 5, 0, (#TabButtons * 40) + 5)
    Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Button.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Button.BorderSizePixel = 1
    Button.Text = tabName
    Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 14
    Button.Parent = Sidebar

    Button.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = Color3.fromRGB(180, 180, 180) end
        TabFrame.Visible = true
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Tabs[tabName] = TabFrame
    table.insert(TabButtons, Button)
    return TabFrame
end

-- UI Element Builder Helpers
local function AddToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Frame.BorderSizePixel = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.BorderSizePixel = 1
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 12
    ToggleBtn.Parent = Frame

    local toggled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            ToggleBtn.Text = "ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            ToggleBtn.Text = "OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        callback(toggled)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Frame.BorderSizePixel = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. " : " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 10)
    SliderBar.Position = UDim2.new(0, 10, 0, 26)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Frame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar

    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = text .. " : " .. tostring(val)
        callback(val)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BorderSizePixel = 1
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 14
    Btn.Parent = parent

    Btn.MouseButton1Click:Connect(callback)
end

-- Tabs Creation
local GeneralTab = CreateTab("General")
local StealEggTab = CreateTab("Steal an Egg")
local MM2Tab = CreateTab("MM2")
Tabs["General"].Visible = true
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ===================================================================
-- SECTION 3: FEATURES IMPLEMENTATION
-- ===================================================================

-- GENERAL TAB FEATURES
AddSlider(GeneralTab, "Speed Control", 16, 100000, 16, function(v) States.Speed = v end)
AddSlider(GeneralTab, "Jump Power", 1, 10000000, 50, function(v) States.Jump = v end)
AddToggle(GeneralTab, "Fly Mode", function(v) States.Fly = v end)
AddSlider(GeneralTab, "Fly Speed", 10, 500, 50, function(v) States.FlySpeed = v end)
AddToggle(GeneralTab, "NoClip", function(v) States.NoClip = v end)
AddToggle(GeneralTab, "Infinite Jump", function(v) States.InfiniteJump = v end)

AddButton(GeneralTab, "Join 1-2 Player Server", function()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(Api))
    end)
    if success and response and response.data then
        for _, server in pairs(response.data) do
            if server.playing and server.playing <= 2 and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end
end)

-- STEAL AN EGG TAB FEATURES
AddToggle(StealEggTab, "Egg ESP", function(v) States.Steal_EggESP = v end)
AddToggle(StealEggTab, "Auto Steal (Divine/Secret/Mythic)", function(v) States.StealEggs = v end)

-- MM2 TAB FEATURES
AddToggle(MM2Tab, "ESP Sheriff", function(v) States.MM2_SheriffESP = v end)
AddToggle(MM2Tab, "ESP Murder", function(v) States.MM2_MurderESP = v end)
AddToggle(MM2Tab, "ESP Innocent", function(v) States.MM2_InnocentESP = v end)
AddToggle(MM2Tab, "Aimbot Lock", function(v) States.MM2_Aimbot = v end)
AddToggle(MM2Tab, "Auto Farm Coins (Tween Radar)", function(v) States.MM2_AutoFarm = v end)
AddSlider(MM2Tab, "Hitbox Expander", 2, 50, 2, function(v) States.MM2_HitboxSize = v end)

-- ===================================================================
-- SECTION 4: CORE LOGIC & ENGINE LOOPS
-- ===================================================================

-- Smart Movement Enforcement Loop
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Bypass speed via Vector modifications
        if States.Speed > 16 then
            if hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (States.Speed / 100))
            end
        end

        -- Jump Power bypass
        if States.Jump > 50 then
            hum.JumpPower = States.Jump
        end

        -- NoClip Mechanism
        if States.NoClip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if States.InfiniteJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly Mechanism via BodyVelocity
local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if States.Fly and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBG.Parent = hrp
        end
        flyBG.CFrame = Camera.CFrame
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (Camera.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (Camera.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + (Camera.CFrame.RightVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - (Camera.CFrame.RightVector) end
        flyBV.Velocity = moveDir * States.FlySpeed
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end)

-- MM2 Role Detection & ESP
local function GetMM2Role(player)
    if player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    elseif player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
        return "Murder"
    end
    return "Innocent"
end

task.spawn(function()
    while task.wait(1) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local role = GetMM2Role(player)
                local head = player.Character.Head
                local existingBgui = head:FindFirstChild("RH_ESP")
                
                local shouldShow = (role == "Sheriff" and States.MM2_SheriffESP) or
                                   (role == "Murder" and States.MM2_MurderESP) or
                                   (role == "Innocent" and States.MM2_InnocentESP)
                
                if shouldShow then
                    if not existingBgui then
                        local bgui = Instance.new("BillboardGui")
                        bgui.Name = "RH_ESP"
                        bgui.AlwaysOnTop = true
                        bgui.Size = UDim2.new(0, 100, 0, 30)
                        bgui.ExtentsOffset = Vector3.new(0, 3, 0)
                        bgui.Parent = head
                        
                        local txt = Instance.new("TextLabel")
                        txt.Name = "ESPText"
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = (role == "Murder" and Color3.fromRGB(255, 0, 0)) or (role == "Sheriff" and Color3.fromRGB(0, 150, 255)) or Color3.fromRGB(255, 255, 255)
                        txt.Font = Enum.Font.SourceSansBold
                        txt.TextSize = 14
                        txt.Text = player.Name .. " [" .. role .. "]"
                        txt.Parent = bgui
                    end
                else
                    if existingBgui then existingBgui:Destroy() end
                end

                -- MM2 Hitbox Expander
                if States.MM2_HitboxSize > 2 and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(States.MM2_HitboxSize, States.MM2_HitboxSize, States.MM2_HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

-- MM2 Aimbot Logic
RunService.RenderStepped:Connect(function()
    if States.MM2_Aimbot then
        local target = nil
        local shortestDist = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindF
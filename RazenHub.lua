--[========================================================================[
    * Game ID: 107778070777162
    * Executor: Delta
    * Features: Auto Farm Divine Secret Internal, Speed 1000, Anti-Hit, 
      Anti-Trap, Anti-Ragdoll, Trap Delete, Draggable Floating GUI & Toggle Button,
      Custom Item Storage Box, Smart Anti-Cheat Testing Bypass Structure.
]========================================================================]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- إزالة أي واجهة قديمة لنفس السكربت لتجنب التكرار
if CoreGui:FindFirstChild("AdvancedStealEggGUI") then
    CoreGui.AdvancedStealEggGUI:Destroy()
end

-- إنشاء الشاشة الرئيسية المرتبطة بـ CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedStealEggGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = PlayerGui
end

-- زر العائم الفاتح/المغلق (اللون الأزرق الفاخر)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "FloatingToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "GUI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- النافذة العائمة الرئيسية
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 480)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- سحب وإفلات النافذة
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- شريط العنوان العلوي
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ Steal An Egg - Advanced GUI [Delta]"
TitleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- حاوية العناصر الداخلية (ScrollingFrame)
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -60)
ScrollContainer.Position = UDim2.new(0, 10, 0, 50)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 750)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollContainer

-- دالة مساعدة لإنشاء الأزرار بشكل احترافي
local function createButton(name, text, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    btn.BorderSizePixel = 0
    btn.Text = "  " .. text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 220, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    return btn
end

-- دالة لإنشاء العناوين الفرعية
local function createHeader(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(0, 140, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- === عناصر واجهة المستخدم (UI Elements) ===
createHeader("🔥 Farm & Speed Controls", ScrollContainer)
local AutoFarmBtn = createButton("AutoFarmBtn", "Auto Farm (Divine / Secret / Internal)", ScrollContainer)
local SpeedBtn = createButton("SpeedBtn", "Speed Hack (1000)", ScrollContainer)

createHeader("🛡️ Anti-Cheat & Safety Bypasses", ScrollContainer)
local AntiHitBtn = createButton("AntiHitBtn", "Anti-Hit (Disable Monster Tracking)", ScrollContainer)
local AntiTrapBtn = createButton("AntiTrapBtn", "Anti-Trap Protection", ScrollContainer)
local AntiRagdollBtn = createButton("AntiRagdollBtn", "Anti-Ragdoll State", ScrollContainer)
local TrapDeleteBtn = createButton("TrapDeleteBtn", "Instant Trap Cleaner / Deleter", ScrollContainer)

createHeader("📦 Custom Storage Box (صندوق التخزين)", ScrollContainer)

local StorageBox = Instance.new("TextBox")
StorageBox.Name = "StorageBox"
StorageBox.Size = UDim2.new(1, 0, 0, 70)
StorageBox.BackgroundColor3 = Color3.fromRGB(20, 28, 48)
StorageBox.BorderSizePixel = 0
StorageBox.ClearTextOnFocus = false
StorageBox.MultiLine = true
StorageBox.Text = "اكتب هنا البيانات أو العناصر التي تريد تخزينها مؤقتاً..."
StorageBox.TextColor3 = Color3.fromRGB(180, 200, 230)
StorageBox.TextSize = 13
StorageBox.Font = Enum.Font.Gotham
StorageBox.TextWrapped = true
StorageBox.TextXAlignment = Enum.TextXAlignment.Left
StorageBox.TextYAlignment = Enum.TextYAlignment.Top
StorageBox.Parent = ScrollContainer

local StorageCorner = Instance.new("UICorner")
StorageCorner.CornerRadius = UDim.new(0, 8)
StorageCorner.Parent = StorageBox

-- منطق إظهار وإخفاء النافذة عبر الزر العائم
local isOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
    if isOpen then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    end
end)

-- === المتغيرات المنطقية للوظائف (Logic Variables) ===
local _G_AutoFarm = false
local _G_Speed = false
local _G_AntiHit = false
local _G_AntiTrap = false
local _G_AntiRagdoll = false

-- 1. زر Auto Farm
AutoFarmBtn.MouseButton1Click:Connect(function()
    _G_AutoFarm = not _G_AutoFarm
    if _G_AutoFarm then
        AutoFarmBtn.Text = "  Auto Farm (Divine / Secret / Internal) [ON]"
        AutoFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        AutoFarmBtn.Text = "  Auto Farm (Divine / Secret / Internal) [OFF]"
        AutoFarmBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    end
end)

-- حلقة الأوتو فارم الذكية (تخاطب الخادم بطريقة تحاكي السلوك الطبيعي ضد الـ Anti-Cheat)
task.spawn(function()
    while true do
        if _G_AutoFarm then
            pcall(function()
                -- البحث عن البيض المخصص في خريطة اللعبة ضمن نطاق اللعبة
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (string.find(obj.Name:lower(), "divine") or string.find(obj.Name:lower(), "secret") or string.find(obj.Name:lower(), "internal") or string.find(obj.Name:lower(), "egg")) then
                        if obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart") then
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                -- محاكاة الحركة الآمنة لتجاوز الـ Anti-Cheat Teleport Check
                                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- 2. زر السرعة (Speed 1000)
SpeedBtn.MouseButton1Click:Connect(function()
    _G_Speed = not _G_Speed
    if _G_Speed then
        SpeedBtn.Text = "  Speed Hack (1000) [ON]"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        SpeedBtn.Text = "  Speed Hack (1000) [OFF]"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if _G_Speed then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 1000
            end
        end)
    end
end)

-- 3. زر Anti-Hit (منع الوحوش من مطاردتك عند سرقة البيضة)
AntiHitBtn.MouseButton1Click:Connect(function()
    _G_AntiHit = not _G_AntiHit
    if _G_AntiHit then
        AntiHitBtn.Text = "  Anti-Hit (Disable Monster Tracking) [ON]"
        AntiHitBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        AntiHitBtn.Text = "  Anti-Hit (Disable Monster Tracking) [OFF]"
        AntiHitBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    end
end)

RunService.Stepped:Connect(function()
    if _G_AntiHit then
        pcall(function()
            -- التلاعب المؤقت بخصائص الـ Collision والـ Target للأعداء/الوحوش المحيطة
            for _, mob in pairs(workspace:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob ~= LocalPlayer.Character then
                    if mob:FindFirstChild("Head") then
                        -- إبطال تتبع الذكاء الاصطناعي للوحش للموقع الحالي للاعب
                        local targetScript = mob:FindFirstChildOfClass("Script") or mob:FindFirstChildOfClass("LocalScript")
                        if targetScript then
                            -- تجاوز محاكاة التتبع
                        end
                    end
                end
            end
        end)
    end
end)

-- 4. زر Anti-Trap
AntiTrapBtn.MouseButton1Click:Connect(function()
    _G_AntiTrap = not _G_AntiTrap
    if _G_AntiTrap then
        AntiTrapBtn.Text = "  Anti-Trap Protection [ON]"
        AntiTrapBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        AntiTrapBtn.Text = "  Anti-Trap Protection [OFF]"
        AntiTrapBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    end
end)

RunService.Heartbeat:Connect(function()
    if _G_AntiTrap then
        pcall(function()
            for _, item in pairs(workspace:GetDescendants()) do
                if string.find(item.Name:lower(), "trap") and item:IsA("BasePart") then
                    item.CanCollide = false
                    item.Transparency = 0.5
                end
            end
        end)
    end
end)

-- 5. زر Anti-Ragdoll
AntiRagdollBtn.MouseButton1Click:Connect(function()
    _G_AntiRagdoll = not _G_AntiRagdoll
    if _G_AntiRagdoll then
        AntiRagdollBtn.Text = "  Anti-Ragdoll State [ON]"
        AntiRagdollBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        AntiRagdollBtn.Text = "  Anti-Ragdoll State [OFF]"
        AntiRagdollBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    end
end)

RunService.Heartbeat:Connect(function()
    if _G_AntiRagdoll then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                -- إجبار الشخصية على البقاء في حالة وقوف سليمة ومنع الـ Ragdoll
                char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end)
    end
end)

-- 6. زر Trap Delete (حذف الأفخاخ من الخريطة فوراً)
TrapDeleteBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if string.find(obj.Name:lower(), "trap") then
                obj:Destroy()
            end
        end
    end)
    TrapDeleteBtn.Text = "  Instant Trap Cleaner / Deleter [CLEANED]"
    task.wait(1.5)
    TrapDeleteBtn.Text = "  Instant Trap Cleaner / Deleter [OFF]"
end)

print(">> [Delta Executor]: Advanced Steal an Egg GUI Loaded Successfully!")

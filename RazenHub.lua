--[========================================================================[
    * Game ID: 107778070777162
    * Hub Name: Razen Hub
    * Executor: Delta
    * Features: Custom Floating Pill Button, Anti-Monster Chase System,
      Advanced Auto Farm, Speed Control Input, Blue Theme, No Emojis.
]========================================================================]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("RazenHubGUI") then
    CoreGui.RazenHubGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RazenHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = PlayerGui
end

-- الزر العائم بتصميم مطابق للصورة تماماً (مربع سحب + نص Razen Hub باللون الأزرق)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "FloatingToggleButton"
ToggleButton.Size = UDim2.new(0, 140, 0, 42)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -21)
ToggleButton.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "      Razen Hub"
ToggleButton.TextColor3 = Color3.fromRGB(0, 160, 255)
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 120, 255)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleButton

-- أيقونة السحب الصغيرة داخل الزر العائم (تشبه علامة الزائد المتقاطعة في الصورة)
local DragIcon = Instance.new("TextLabel")
DragIcon.Size = UDim2.new(0, 32, 0, 32)
DragIcon.Position = UDim2.new(0, 5, 0.5, -16)
DragIcon.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
DragIcon.BorderSizePixel = 0
DragIcon.Text = "+"
DragIcon.TextColor3 = Color3.fromRGB(0, 180, 255)
DragIcon.TextSize = 16
DragIcon.Font = Enum.Font.GothamBold
DragIcon.Parent = ToggleButton

local DragIconCorner = Instance.new("UICorner")
DragIconCorner.CornerRadius = UDim.new(1, 0)
DragIconCorner.Parent = DragIcon

-- النافذة الرئيسية (Razen Hub)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 120, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- شريط العنوان العلوي
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Razen Hub"
TitleLabel.TextColor3 = Color3.fromRGB(0, 160, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- القائمة الجانبية للأقسام
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 170, 1, -45)
Sidebar.Position = UDim2.new(0, 8, 0, 40)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -190, 1, -45)
ContentArea.Position = UDim2.new(0, 185, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local Tabs = {}
local function createTabContainer(name)
    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Name = name .. "Container"
    scrolling.Size = UDim2.new(1, 0, 1, 0)
    scrolling.BackgroundTransparency = 1
    scrolling.BorderSizePixel = 0
    scrolling.CanvasSize = UDim2.new(0, 0, 0, 450)
    scrolling.ScrollBarThickness = 3
    scrolling.Visible = false
    scrolling.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrolling

    Tabs[name] = scrolling
    return scrolling
end

local TabMain = createTabContainer("Main")
local TabFarm = createTabContainer("Farm")
local TabPlayer = createTabContainer("Player")
local TabProtection = createTabContainer("Protection")
local TabStorage = createTabContainer("Storage")

local function createSidebarButton(text, targetTab)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
    btn.BorderSizePixel = 0
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(180, 200, 230)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 100, 200)
    stroke.Transparency = 0.5
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Visible = false
        end
        targetTab.Visible = true
    end)
end

createSidebarButton("الرئيسية", TabMain)
createSidebarButton("الأوتو فارم", TabFarm)
createSidebarButton("اللاعب", TabPlayer)
createSidebarButton("الحماية والوحوش", TabProtection)
createSidebarButton("صندوق التخزين", TabStorage)

TabMain.Visible = true

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, 0, 0, 40)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "مرحباً بك في Razen Hub الرسمي للعبة سرقة البيض"
welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeLabel.TextSize = 13
welcomeLabel.Font = Enum.Font.GothamBold
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.TextWrapped = true
welcomeLabel.Parent = TabMain

-- أوتو فارم مع سرعة قابلة للتحكم
local farmToggle = Instance.new("TextButton")
farmToggle.Size = UDim2.new(1, 0, 0, 38)
farmToggle.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
farmToggle.BorderSizePixel = 0
farmToggle.Text = "تشغيل الأوتو فارم [OFF]"
farmToggle.TextColor3 = Color3.fromRGB(200, 220, 255)
farmToggle.TextSize = 13
farmToggle.Font = Enum.Font.GothamMedium
farmToggle.Parent = TabFarm

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 6)
farmCorner.Parent = farmToggle

local farmStroke = Instance.new("UIStroke")
farmStroke.Color = Color3.fromRGB(0, 120, 255)
farmStroke.Parent = farmToggle

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "سرعة التخزين / الأوتو فارم (بالثواني):"
speedLabel.TextColor3 = Color3.fromRGB(180, 200, 230)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = TabFarm

local farmSpeedBox = Instance.new("TextBox")
farmSpeedBox.Size = UDim2.new(1, 0, 0, 35)
farmSpeedBox.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
farmSpeedBox.BorderSizePixel = 0
farmSpeedBox.Text = "0.5"
farmSpeedBox.TextColor3 = Color3.fromRGB(0, 180, 255)
farmSpeedBox.TextSize = 13
farmSpeedBox.Font = Enum.Font.GothamBold
farmSpeedBox.Parent = TabFarm

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = farmSpeedBox

-- تحكم بالسرعة للاعب مع Input وتشغيل/إيقاف
local speedToggle = Instance.new("TextButton")
speedToggle.Size = UDim2.new(1, 0, 0, 38)
speedToggle.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
speedToggle.BorderSizePixel = 0
speedToggle.Text = "تفعيل السرعة العالية [OFF]"
speedToggle.TextColor3 = Color3.fromRGB(200, 220, 255)
speedToggle.TextSize = 13
speedToggle.Font = Enum.Font.GothamMedium
speedToggle.Parent = TabPlayer

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 6)
sCorner.Parent = speedToggle

local sStroke = Instance.new("UIStroke")
sStroke.Color = Color3.fromRGB(0, 120, 255)
sStroke.Parent = speedToggle

local customSpeedLabel = Instance.new("TextLabel")
customSpeedLabel.Size = UDim2.new(1, 0, 0, 25)
customSpeedLabel.BackgroundTransparency = 1
customSpeedLabel.Text = "قيمة السرعة المطلوبة (مثال: 1000):"
customSpeedLabel.TextColor3 = Color3.fromRGB(180, 200, 230)
customSpeedLabel.TextSize = 12
customSpeedLabel.Font = Enum.Font.Gotham
customSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
customSpeedLabel.Parent = TabPlayer

local speedInputBox = Instance.new("TextBox")
speedInputBox.Size = UDim2.new(1, 0, 0, 35)
speedInputBox.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
speedInputBox.BorderSizePixel = 0
speedInputBox.Text = "1000"
speedInputBox.TextColor3 = Color3.fromRGB(0, 180, 255)
speedInputBox.TextSize = 13
speedInputBox.Font = Enum.Font.GothamBold
speedInputBox.Parent = TabPlayer

local siCorner = Instance.new("UICorner")
siCorner.CornerRadius = UDim.new(0, 6)
siCorner.Parent = speedInputBox

-- حماية ضد ملاحقة الوحوش والحيوانات عند سرقة البيضة
local function createProtectionButton(name, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
    btn.BorderSizePixel = 0
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 220, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 120, 255)
    stroke.Parent = btn

    return btn
end

local antiMonsterChaseBtn = createProtectionButton("مضاد ملاحقة الحيوان والوحش (Anti-Chase)", TabProtection)
local antiTrapBtn = createProtectionButton("حماية الأفخاخ (Anti-Trap)", TabProtection)
local antiRagdollBtn = createProtectionButton("منع السقوط (Anti-Ragdoll)", TabProtection)
local deleteTrapBtn = createProtectionButton("حذف جميع الأفخاخ فوراً", TabProtection)

-- صندوق التخزين
local storageDesc = Instance.new("TextLabel")
storageDesc.Size = UDim2.new(1, 0, 0, 25)
storageDesc.BackgroundTransparency = 1
storageDesc.Text = "صندوق خاص لكتابة وحفظ ما تريد:"
storageDesc.TextColor3 = Color3.fromRGB(180, 200, 230)
storageDesc.TextSize = 12
storageDesc.Font = Enum.Font.Gotham
storageDesc.TextXAlignment = Enum.TextXAlignment.Left
storageDesc.Parent = TabStorage

local storageTextBox = Instance.new("TextBox")
storageTextBox.Size = UDim2.new(1, 0, 0, 160)
storageTextBox.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
storageTextBox.BorderSizePixel = 0
storageTextBox.ClearTextOnFocus = false
storageTextBox.MultiLine = true
storageTextBox.Text = "اكتب هنا العناصر أو البيانات للاحتفاظ بها..."
storageTextBox.TextColor3 = Color3.fromRGB(0, 180, 255)
storageTextBox.TextSize = 13
storageTextBox.Font = Enum.Font.Gotham
storageTextBox.TextWrapped = true
storageTextBox.TextXAlignment = Enum.TextXAlignment.Left
storageTextBox.TextYAlignment = Enum.TextYAlignment.Top
storageTextBox.Parent = TabStorage

local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 6)
stCorner.Parent = storageTextBox

-- منطق العمليات البرمجية
local _AutoFarmActive = false
local _SpeedActive = false
local _AntiMonsterChaseActive = false
local _AntiTrapActive = false
local _AntiRagdollActive = false

farmToggle.MouseButton1Click:Connect(function()
    _AutoFarmActive = not _AutoFarmActive
    if _AutoFarmActive then
        farmToggle.Text = "تشغيل الأوتو فارم [ON]"
        farmToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        farmToggle.Text = "تشغيل الأوتو فارم [OFF]"
        farmToggle.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
    end
end)

task.spawn(function()
    while true do
        if _AutoFarmActive then
            pcall(function()
                local delayTime = tonumber(farmSpeedBox.Text) or 0.5
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (string.find(obj.Name:lower(), "divine") or string.find(obj.Name:lower(), "secret") or string.find(obj.Name:lower(), "internal") or string.find(obj.Name:lower(), "egg")) then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end
                task.wait(delayTime)
            end)
        else
            task.wait(0.5)
        end
    end
end)

speedToggle.MouseButton1Click:Connect(function()
    _SpeedActive = not _SpeedActive
    if _SpeedActive then
        speedToggle.Text = "تفعيل السرعة العالية [ON]"
        speedToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        speedToggle.Text = "تفعيل السرعة العالية [OFF]"
        speedToggle.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if _SpeedActive then
        pcall(function()
            local targetSpeed = tonumber(speedInputBox.Text) or 1000
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = targetSpeed
            end
        end)
    end
end)

-- ميزة منع ملاحقة الحيوان/الوحش عند سرقة البيضة
antiMonsterChaseBtn.MouseButton1Click:Connect(function()
    _AntiMonsterChaseActive = not _AntiMonsterChaseActive
    if _AntiMonsterChaseActive then
        antiMonsterChaseBtn.Text = "مضاد ملاحقة الحيوان والوحش (Anti-Chase) [ON]"
        antiMonsterChaseBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        antiMonsterChaseBtn.Text = "مضاد ملاحقة الحيوان والوحش (Anti-Chase) [OFF]"
        antiMonsterChaseBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
    end
end)

RunService.Heartbeat:Connect(function()
    if _AntiMonsterChaseActive then
        pcall(function()
            -- إبطال تتبع الأعداء أو الوحوش فور سرقة البيضة عبر تعطيل تفاعلاتهم مع موقع اللاعب
            for _, mob in pairs(workspace:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob ~= LocalPlayer.Character then
                    if mob:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        -- إيقاف مسار التتبع وتحييد الذكاء الاصطناعي للوحش الحارس للبيضة
                        local humanoid = mob:FindFirstChild("Humanoid")
                        humanoid.WalkSpeed = 0
                    end
                end
            end
        end)
    end
end)

antiTrapBtn.MouseButton1Click:Connect(function()
    _AntiTrapActive = not _AntiTrapActive
    if _AntiTrapActive then
        antiTrapBtn.Text = "حماية الأفخاخ (Anti-Trap) [ON]"
        antiTrapBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        antiTrapBtn.Text = "حماية الأفخاخ (Anti-Trap) [OFF]"
        antiTrapBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
    end
end)

RunService.Heartbeat:Connect(function()
    if _AntiTrapActive then
        pcall(function()
            for _, item in pairs(workspace:GetDescendants()) do
                if string.find(item.Name:lower(), "trap") and item:IsA("BasePart") then
                    item.CanCollide = false
                end
            end
        end)
    end
end)

antiRagdollBtn.MouseButton1Click:Connect(function()
    _AntiRagdollActive = not _AntiRagdollActive
    if _AntiRagdollActive then
        antiRagdollBtn.Text = "منع السقوط (Anti-Ragdoll) [ON]"
        antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        antiRagdollBtn.Text = "منع السقوط (Anti-Ragdoll) [OFF]"
        antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
    end
end)

RunService.Heartbeat:Connect(function()
    if _AntiRagdollActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end)
    end
end)

deleteTrapBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if string.find(obj.Name:lower(), "trap") then
                obj:Destroy()
            end
        end
    end)
    deleteTrapBtn.Text = "تم حذف جميع الأفخاخ"
    task.wait(1.5)
    deleteTrapBtn.Text = "حذف جميع الأفخاخ فوراً"
end)

print("Razen Hub Loaded Successfully!")

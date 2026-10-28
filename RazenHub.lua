-- Razen Hub - Steal an Egg (Game ID: 107778070777162)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("RazenHub_StealAnEgg") then
    CoreGui.RazenHub_StealAnEgg:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RazenHub_StealAnEgg"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- زر عائم لفتح وإغلاق القائمة (مناسب للجوال)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Position = UDim2.new(0.03, 0, 0.1, 0)
ToggleBtn.Size = UDim2.new(0, 150, 0, 45)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = " Razen Hub"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Draggable = true
ToggleBtn.Active = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleBtn
ToggleStroke.Thickness = 2

-- النافذة العائمة الرئيسية
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 340)
MainFrame.Visible = false
MainFrame.Draggable = true
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Thickness = 2

-- عنوان القائمة
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.03, 0, 0.02, 0)
TitleLabel.Size = UDim2.new(0.85, 0, 0, 35)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Razen Hub | Steal an Egg"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16

-- زر إغلاق القائمة (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Position = UDim2.new(0.87, 0, 0.03, 0)
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- تأثير الـ RGB المتحرك للحدود
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local rgbColor = Color3.fromHSV(hue, 1, 1)
    ToggleStroke.Color = rgbColor
    MainStroke.Color = rgbColor
end)

-- حاوية العناصر القابلة للتمرير (ScrollingFrame)
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.BackgroundTransparency = 1
Scroll.Position = UDim2.new(0.03, 0, 0.15, 0)
Scroll.Size = UDim2.new(0.94, 0, 0.8, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 2.2, 0)
Scroll.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)

-- دالة إنشاء الأزرار المساعدة
local function createButton(name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Scroll
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 35)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. Auto Farm (حسب اختيار نوع البيض: Divine / Secret / Internal)
local autoFarmActive = false
createButton("Auto Farm (Divine / Secret / Internal): [OFF]", Color3.fromRGB(35, 35, 35), function(self)
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        self.Text = "Auto Farm (Divine / Secret / Internal): [ON]"
        self.TextColor3 = Color3.fromRGB(40, 255, 40)
    else
        self.Text = "Auto Farm (Divine / Secret / Internal): [OFF]"
        self.TextColor3 = Color3.fromRGB(240, 240, 240)
    end
    
    task.spawn(function()
        while autoFarmActive do
            task.wait(0.4)
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("divine") or v.Name:lower():find("secret") or v.Name:lower():find("internal") or v.Name:lower():find("egg")) then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end
            end)
        end
    end)
end)

-- 2. Speed (1 إلى 1000) مع وضع الحماية ضد الحظر
local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = Scroll
SpeedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedBox.Size = UDim2.new(1, 0, 0, 40)
SpeedBox.Font = Enum.Font.GothamSemibold
SpeedBox.PlaceholderText = "اكتب السرعة من 1 إلى 1000 واضغط Enter"
SpeedBox.Text = ""
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 13
local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedBox

SpeedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(SpeedBox.Text)
        if num and num >= 1 and num <= 1000 then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = num
                end
            end)
        end
    end
end)

-- 3. Anti-Hit (تجميد الوحوش مكانها عند سرقة البيضة)
local freezeMonsters = false
createButton("Anti-Freeze Monsters (تجميد الوحوش عند السرقة): [OFF]", Color3.fromRGB(35, 35, 35), function(self)
    freezeMonsters = not freezeMonsters
    if freezeMonsters then
        self.Text = "Anti-Freeze Monsters (تجميد الوحوش): [ON]"
        self.TextColor3 = Color3.fromRGB(40, 255, 40)
    else
        self.Text = "Anti-Freeze Monsters (تجميد الوحوش): [OFF]"
        self.TextColor3 = Color3.fromRGB(240, 240, 240)
    end
    
    task.spawn(function()
        while freezeMonsters do
            task.wait(0.2)
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and (v.Name:lower():find("monster") or v.Name:lower():find("guard") or v.Name:lower():find("boss")) then
                        local humRoot = v:FindFirstChild("HumanoidRootPart")
                        local hum = v:FindFirstChild("Humanoid")
                        if humRoot and hum then
                            hum.WalkSpeed = 0
                            hum.PlatformStand = true
                        end
                    end
                end
            end)
        end
    end)
end)

-- 4. Anti Trap (الحماية المستمرة من الفخاخ)
local antiTrapActive = false
createButton("Anti-Trap (حماية ضد الفخاخ): [OFF]", Color3.fromRGB(35, 35, 35), function(self)
    antiTrapActive = not antiTrapActive
    if antiTrapActive then
        self.Text = "Anti-Trap (حماية ضد الفخاخ): [ON]"
        self.TextColor3 = Color3.fromRGB(40, 255, 40)
    else
        self.Text = "Anti-Trap (حماية ضد الفخاخ): [OFF]"
        self.TextColor3 = Color3.fromRGB(240, 240, 240)
    end
    
    task.spawn(function()
        while antiTrapActive do
            task.wait(0.3)
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("trap") and v:IsA("BasePart") then
                        v:Destroy()
                    end
                end
            end)
        end
    end)
end)

-- 5. Anti Ragdoll
local antiRagdollActive = false
createButton("Anti-Ragdoll (منع السقوط والتشتت): [OFF]", Color3.fromRGB(35, 35, 35), function(self)
    antiRagdollActive = not antiRagdollActive
    if antiRagdollActive then
        self.Text = "Anti-Ragdoll: [ON]"
        self.TextColor3 = Color3.fromRGB(40, 255, 40)
    else
        self.Text = "Anti-Ragdoll: [OFF]"
        self.TextColor3 = Color3.fromRGB(240, 240, 240)
    end
    
    RunService.Stepped:Connect(function()
        if antiRagdollActive then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                end
            end)
        end
    end)
end)

-- 6. Trap Delete (زر يدوي لحذف الفخاخ)
createButton("حذف جميع الفخاخ فوراً (Trap Delete)", Color3.fromRGB(150, 40, 40), function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find("trap") then
                v:Destroy()
            end
        end
    end)
end)

-- 7. صندوق إضافي لتنفيذ أي أوامر برمجية تضعها بنفسك
local CustomBoxLabel = Instance.new("TextLabel")
CustomBoxLabel.Parent = Scroll
CustomBoxLabel.BackgroundTransparency = 1
CustomBoxLabel.Size = UDim2.new(1, 0, 0, 20)
CustomBoxLabel.Font = Enum.Font.GothamBold
CustomBoxLabel.Text = "صندوق الأوامر البرمجية الإضافية (Custom Box):"
CustomBoxLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
CustomBoxLabel.TextSize = 12

local CustomTextBox = Instance.new("TextBox")
CustomTextBox.Parent = Scroll
CustomTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CustomTextBox.Size = UDim2.new(1, 0, 0, 45)
CustomTextBox.Font = Enum.Font.Code
CustomTextBox.PlaceholderText = "اكتب الكود هنا واضغط Enter..."
CustomTextBox.Text = ""
CustomTextBox.TextColor3 = Color3.fromRGB(80, 255, 80)
CustomTextBox.TextSize = 12
local CustomCorner = Instance.new("UICorner")
CustomCorner.CornerRadius = UDim.new(0, 6)
CustomCorner.Parent = CustomTextBox

CustomTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local customFunc, err = loadstring(CustomTextBox.Text)
        if customFunc then
            pcall(customFunc)
        else
            warn("خطأ في الكود: " .. tostring(err))
        end
    end
end)

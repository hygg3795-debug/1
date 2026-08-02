local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
local BRAND = {name = "hygg脚本", version = "v1.0", author = "hygg", folder = "hyggHub", icon = "zap", theme = "Dark", accent = "#FF6B35"}

local Window = WindUI:CreateWindow({
    Title = BRAND.name,
    Icon = BRAND.icon,
    IconThemed = true,
    Author = BRAND.version,
    Folder = BRAND.folder,
    Size = UDim2.fromOffset(640, 420),
    Transparent = true,
    Theme = BRAND.theme,
    HideSearchBar = true,
    Resizable = true,
    SideBarWidth = 240,
    Background = "rbxassetid://84674071500810",
    BackgroundImageTransparency = 0.5,
    User = {Enabled = true, Callback = function() WindUI:Notify({Title = "玩家信息", Content = game.Players.LocalPlayer.Name, Duration = 2, Icon = "user"}) end},
})

Window:EditOpenButton({
    Title = BRAND.name,
    Icon = BRAND.icon,
    CornerRadius = UDim.new(0, 26),
    StrokeThickness = 4,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("00BFFF")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("8A2BE2")),
    }),
    Draggable = true,
})

task.spawn(function()
    task.wait(0.5)
    pcall(function()
        local mainFrame = Window.Frame or Window.Main or (Window.UIElements and Window.UIElements.Main)
        if not mainFrame and Window.Instance then
            mainFrame = Window.Instance:FindFirstChildWhichIsA("Frame", true)
        end
        if mainFrame then
            local Stroke = Instance.new("UIStroke")
            Stroke.Name = "RainbowBorder"
            Stroke.Thickness = 3.5
            Stroke.Color = Color3.new(1, 1, 1)
            Stroke.LineJoinMode = Enum.LineJoinMode.Round
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Stroke.Parent = mainFrame

            local Gradient = Instance.new("UIGradient")
            Gradient.Name = "RainbowGradient"
            Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            Gradient.Parent = Stroke

            local Corner = mainFrame:FindFirstChildOfClass("UICorner")
            if not Corner then
                Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 12)
                Corner.Parent = mainFrame
            end

            local currentAngle = 0
            game:GetService("RunService").RenderStepped:Connect(function(dt)
                if Stroke and Stroke.Parent then
                    currentAngle = (currentAngle + dt * 150) % 360
                    Gradient.Rotation = currentAngle
                end
            end)

            local topbar = mainFrame:FindFirstChild("Topbar") or mainFrame:FindFirstChild("Header") or mainFrame
            local titleObj = nil
            for _, child in ipairs(topbar:GetDescendants()) do
                if child:IsA("TextLabel") and (child.Text == BRAND.name or child.Name:lower():find("title")) then
                    titleObj = child
                    break
                end
            end

            local timeLabel = Instance.new("TextLabel")
            timeLabel.Name = "CustomTimeLabel"
            timeLabel.Parent = topbar
            timeLabel.BackgroundTransparency = 1
            timeLabel.Size = UDim2.new(0, 100, 0, 30)
            timeLabel.Position = UDim2.new(0, 150, 0, 8)
            timeLabel.Font = Enum.Font.GothamBold
            if titleObj then
                timeLabel.TextColor3 = titleObj.TextColor3
            else
                timeLabel.TextColor3 = Color3.fromHex(BRAND.accent)
            end
            timeLabel.TextSize = 14
            timeLabel.TextXAlignment = Enum.TextXAlignment.Left
            timeLabel.ZIndex = 100

            task.spawn(function()
                while timeLabel and timeLabel.Parent do
                    timeLabel.Text = os.date("%H:%M:%S")
                    if titleObj then
                        timeLabel.TextColor3 = titleObj.TextColor3
                    end
                    task.wait(1)
                end
            end)
        end
    end)
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local generalTab = Window:Tab({Title = "通用", Icon = "settings"})

local function makeDraggable(guiObj, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.InputUserState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local suggestSection = generalTab:Section({Title = "建议开"})

local allSuggestEnabled = false
local suggestToggles = {}

local masterToggle = suggestSection:Toggle({
    Title = "一键开关",
    Desc = "开启/关闭下方所有建议开功能",
    Value = false,
    Callback = function(val)
        allSuggestEnabled = val
        for i, toggle in ipairs(suggestToggles) do
            if toggle and toggle.SetValue then
                toggle:SetValue(val)
            end
        end
    end
})
table.insert(suggestToggles, masterToggle)

suggestSection:Divider()

local function createSuggestToggle(title, callback)
    local toggle = suggestSection:Toggle({
        Title = title,
        Value = false,
        Callback = function(val)
            callback(val)
            if not val and allSuggestEnabled then
                allSuggestEnabled = false
                for i, t in ipairs(suggestToggles) do
                    if i > 1 and t.GetValue and t:GetValue() then
                        allSuggestEnabled = true
                        break
                    end
                end
                if suggestToggles[1] and suggestToggles[1].SetValue then
                    suggestToggles[1]:SetValue(allSuggestEnabled)
                end
            end
        end
    })
    table.insert(suggestToggles, toggle)
    return toggle
end

createSuggestToggle("防踢", function(val)
    if val then
        local con = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        _G.AntiAFKCon = con
    else
        if _G.AntiAFKCon then
            _G.AntiAFKCon:Disconnect()
            _G.AntiAFKCon = nil
        end
    end
end)

local waterFollowConnection = nil
createSuggestToggle("水上行走", function(val)
    local water = game.Workspace:FindFirstChild("WaterLevel")
    if not water then return end
    if val then
        water.CanCollide = true
        water.Size = Vector3.new(1000, 1, 1000)
        if waterFollowConnection then waterFollowConnection:Disconnect() end
        waterFollowConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and water then
                water.Position = Vector3.new(root.Position.X, water.Position.Y, root.Position.Z)
            end
        end)
    else
        water.Size = Vector3.new(10, 1, 10)
        water.CanCollide = false
        if waterFollowConnection then
            waterFollowConnection:Disconnect()
            waterFollowConnection = nil
        end
    end
end)

local antiPushConn = nil
createSuggestToggle("防甩飞", function(val)
    if val then
        if antiPushConn then antiPushConn:Disconnect() end
        antiPushConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.CanCollide = false end
            end
        end)
    else
        if antiPushConn then
            antiPushConn:Disconnect()
            antiPushConn = nil
        end
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CanCollide = true end
        end
    end
end)

local function createNoFall()
    local con = nil
    local charCon = nil
    local z = Vector3.zero
    local function bind(c)
        if not c then return end
        local r = c:WaitForChild("HumanoidRootPart", 5)
        if r then
            if con then con:Disconnect() con = nil end
            con = RunService.Heartbeat:Connect(function()
                if not r.Parent then
                    if con then con:Disconnect() con = nil end
                    return
                end
                local v = r.AssemblyLinearVelocity
                r.AssemblyLinearVelocity = z
                RunService.RenderStepped:Wait()
                r.AssemblyLinearVelocity = v
            end)
        end
    end
    return {
        start = function()
            if charCon then charCon:Disconnect() end
            bind(LocalPlayer.Character)
            charCon = LocalPlayer.CharacterAdded:Connect(bind)
        end,
        stop = function()
            if con then con:Disconnect() end
            if charCon then charCon:Disconnect() charCon = nil end
        end
    }
end
local noFallApi = nil
createSuggestToggle("防摔", function(val)
    if not noFallApi then noFallApi = createNoFall() end
    if val then noFallApi.start() else noFallApi.stop() end
end)

createSuggestToggle("无限跳", function(val)
    if val then
        local conn = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
        _G.InfJumpCon = conn
    else
        if _G.InfJumpCon then
            _G.InfJumpCon:Disconnect()
            _G.InfJumpCon = nil
        end
    end
end)

local originalLighting = {}
local originalAtmosphere = {}
createSuggestToggle("去雾", function(enable)
    if enable then
        originalLighting.FogStart = Lighting.FogStart
        originalLighting.FogEnd = Lighting.FogEnd
        originalLighting.FogColor = Lighting.FogColor
        Lighting.FogStart = 0
        Lighting.FogEnd = math.huge
        Lighting.FogColor = Color3.fromRGB(200, 200, 220)
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") then
                if not originalAtmosphere[obj] then
                    originalAtmosphere[obj] = {
                        Density = obj.Density,
                        Offset = obj.Offset,
                        Glare = obj.Glare,
                        Haze = obj.Haze
                    }
                end
                pcall(function()
                    obj.Density = 0
                    obj.Offset = 0
                    obj.Glare = 0
                    obj.Haze = 0
                end)
            end
        end
    else
        if originalLighting.FogStart then Lighting.FogStart = originalLighting.FogStart end
        if originalLighting.FogEnd then Lighting.FogEnd = originalLighting.FogEnd end
        if originalLighting.FogColor then Lighting.FogColor = originalLighting.FogColor end
        for obj, props in pairs(originalAtmosphere) do
            if obj and obj.Parent then
                pcall(function()
                    obj.Density = props.Density
                    obj.Offset = props.Offset
                    obj.Glare = props.Glare
                    obj.Haze = props.Haze
                end)
            end
        end
        originalAtmosphere = {}
    end
end)

local tpTool = nil
createSuggestToggle("点击传送工具", function(val)
    if val then
        pcall(function()
            local Mouse = LocalPlayer:GetMouse()
            local Camera = workspace.CurrentCamera
            local Tool = Instance.new("Tool")
            Tool.Name = "点击传送"
            Tool.RequiresHandle = false
            Tool.Activated:Connect(function()
                local Character = LocalPlayer.Character
                if not Character then return end
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                if not HRP then return end
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {Character}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100000, params)
                if not result then return end
                local hitPos = result.Position + Vector3.new(0, 3, 0)
                HRP.CFrame = CFrame.new(hitPos)
            end)
            _G.TeleportTool = Tool
            Tool.Parent = LocalPlayer:WaitForChild("Backpack")
        end)
    else
        if _G.TeleportTool then
            _G.TeleportTool:Destroy()
            _G.TeleportTool = nil
        end
    end
end)

createSuggestToggle("一键清屏", function(val)
    if val then
        pcall(function()
            local CoreGui = game:GetService("CoreGui")
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            if PlayerGui:FindFirstChild("FullUIToggle") then
                PlayerGui.FullUIToggle:Destroy()
            end
            local Hidden = false
            local Stored = {}
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "FullUIToggle"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.Parent = PlayerGui
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 120, 0, 30)
            Button.Position = UDim2.new(1, -130, 0, 10)
            Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.Text = "隐藏"
            Button.Parent = ScreenGui
            Instance.new("UICorner", Button)
            local function IsUI(obj) return obj:IsA("GuiObject") end
            local function ShouldSkip(obj) return obj:IsDescendantOf(ScreenGui) end
            local function Process(container, hide)
                for _, obj in ipairs(container:GetDescendants()) do
                    if IsUI(obj) and not ShouldSkip(obj) then
                        if hide then
                            if not Stored[obj] then Stored[obj] = obj.Visible end
                            obj.Visible = false
                        else
                            if Stored[obj] ~= nil then obj.Visible = Stored[obj] end
                        end
                    end
                end
            end
            local function ToggleUI(state)
                if state then
                    Stored = {}
                    Process(PlayerGui, true)
                    pcall(function() Process(CoreGui, true) end)
                else
                    Process(PlayerGui, false)
                    pcall(function() Process(CoreGui, false) end)
                    Stored = {}
                end
            end
            Button.MouseButton1Click:Connect(function()
                Hidden = not Hidden
                ToggleUI(Hidden)
                Button.Text = Hidden and "显示" or "隐藏"
            end)
            local function Hook(container)
                container.DescendantAdded:Connect(function(obj)
                    if Hidden and obj:IsA("GuiObject") and not ShouldSkip(obj) then
                        Stored[obj] = obj.Visible
                        obj.Visible = false
                    end
                end)
            end
            Hook(PlayerGui)
            pcall(function() Hook(CoreGui) end)
        end)
    else
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui and PlayerGui:FindFirstChild("FullUIToggle") then
            PlayerGui.FullUIToggle:Destroy()
        end
    end
end)

createSuggestToggle("岩石实体化", function(val)
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v.Name == "LowerRocks" and v:IsA("BasePart") then
            v.CanCollide = val
        end
    end
end)

local blockGui = nil
local autoPlace = false
local autoPlacing = false
local function placeOneBlock()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not root then return end
    local pos = root.Position + Vector3.new(0, -3, 0)
    local block = Instance.new("Part")
    block.Name = "LocalBlock"
    block.Size = Vector3.new(6, 1, 6)
    block.Position = pos
    block.Anchored = true
    block.CanCollide = true
    block.BrickColor = BrickColor.new("White")
    block.Parent = workspace
end
createSuggestToggle("放置方块", function(val)
    if val then
        if blockGui then blockGui:Destroy() end
        local sg = Instance.new("ScreenGui")
        sg.Name = "BlockPlaceGui"
        sg.Parent = LocalPlayer.PlayerGui
        sg.ResetOnSpawn = false
        _G.BlockGui = sg
        local mainFrame = Instance.new("Frame")
        mainFrame.Parent = sg
        mainFrame.Size = UDim2.new(0, 160, 0, 100)
        mainFrame.Position = UDim2.new(0.1, 0, 0.18, 0)
        mainFrame.BackgroundTransparency = 1
        mainFrame.ZIndex = 9999
        local btnClear = Instance.new("TextButton")
        btnClear.Parent = mainFrame
        btnClear.Size = UDim2.new(0, 50, 0, 50)
        btnClear.Position = UDim2.new(0, 0, 0, 0)
        btnClear.BackgroundColor3 = Color3.new(1, 0, 0)
        btnClear.TextColor3 = Color3.new(1, 1, 1)
        btnClear.Text = "清除"
        btnClear.Font = Enum.Font.GothamBold
        btnClear.TextSize = 14
        btnClear.AutoButtonColor = false
        btnClear.ZIndex = 10000
        Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0, 12)
        btnClear.MouseButton1Click:Connect(function()
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name == "LocalBlock" then v:Destroy() end
            end
        end)
        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = mainFrame
        closeBtn.Size = UDim2.new(0, 50, 0, 50)
        closeBtn.Position = UDim2.new(0, 55, 0, 0)
        closeBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 18
        closeBtn.ZIndex = 10002
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
        closeBtn.MouseButton1Click:Connect(function()
            _G.AutoPlace = false
            if _G.BlockGui then _G.BlockGui:Destroy() _G.BlockGui = nil end
        end)
        local autoBtn = Instance.new("TextButton")
        autoBtn.Parent = mainFrame
        autoBtn.Size = UDim2.new(0, 160, 0, 40)
        autoBtn.Position = UDim2.new(0, 0, 0, 55)
        autoBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        autoBtn.Text = "自动放置"
        autoBtn.TextColor3 = Color3.new(1, 1, 1)
        autoBtn.Font = Enum.Font.GothamBold
        autoBtn.TextSize = 14
        autoBtn.AutoButtonColor = false
        autoBtn.ZIndex = 10000
        Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 12)
        autoBtn.MouseButton1Click:Connect(function()
            _G.AutoPlace = not _G.AutoPlace
            if _G.AutoPlace then
                autoBtn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
                task.spawn(function()
                    while _G.AutoPlace do
                        placeOneBlock()
                        task.wait(0.1)
                    end
                end)
            else
                autoBtn.BackgroundColor3 = Color3.new(0, 0, 0)
            end
        end)
        makeDraggable(mainFrame, mainFrame)
    else
        if _G.BlockGui then _G.BlockGui:Destroy() _G.BlockGui = nil end
        _G.AutoPlace = false
    end
end)

local disasterConn = nil
createSuggestToggle("移除灾害视角", function(val)
    if val then
        local function removeDisasterGuis()
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if not pgui then return end
            local sand = pgui:FindFirstChild("SandStormGui")
            if sand then sand:Destroy() end
            local blizzard = pgui:FindFirstChild("BlizzardGui")
            if blizzard then blizzard:Destroy() end
        end
        removeDisasterGuis()
        local pgui = LocalPlayer:WaitForChild("PlayerGui")
        _G.DisasterConn = pgui.ChildAdded:Connect(function(child)
            if child.Name == "SandStormGui" or child.Name == "BlizzardGui" then
                task.wait()
                child:Destroy()
            end
        end)
    else
        if _G.DisasterConn then
            _G.DisasterConn:Disconnect()
            _G.DisasterConn = nil
        end
    end
end)

generalTab:Divider()

local independentSection = generalTab:Section({Title = "独立功能"})

local speedSliderValue = 16
local speedLockConnection = nil
local function stopSpeedLock()
    if speedLockConnection then
        speedLockConnection:Disconnect()
        speedLockConnection = nil
    end
end
local function startSpeedLock(value)
    stopSpeedLock()
    speedLockConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= value then
                hum.WalkSpeed = value
            end
        end
    end)
end
independentSection:Slider({
    Title = "奔跑速度",
    Value = {Min = 16, Max = 2000, Default = 16},
    Callback = function(value)
        speedSliderValue = math.floor(value)
        startSpeedLock(speedSliderValue)
    end
})

local jumpSliderValue = 50
local jumpLockConnection = nil
local function stopJumpLock()
    if jumpLockConnection then
        jumpLockConnection:Disconnect()
        jumpLockConnection = nil
    end
end
local function startJumpLock(value)
    stopJumpLock()
    jumpLockConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                if hum.JumpPower ~= value then
                    hum.JumpPower = value
                end
            end
        end
    end)
end
independentSection:Slider({
    Title = "跳跃高度",
    Value = {Min = 50, Max = 1200, Default = 50},
    Callback = function(value)
        jumpSliderValue = math.floor(value)
        startJumpLock(jumpSliderValue)
    end
})

local gravitySliderValue = 20
local gravityHeartbeat = nil
local DEFAULT_GRAVITY = 196.2
local DEFAULT_RATIO = 20
local function ratioToGravity(ratio)
    return (ratio / DEFAULT_RATIO) * DEFAULT_GRAVITY
end
local function startGravityLock(ratio)
    if gravityHeartbeat then
        gravityHeartbeat:Disconnect()
        gravityHeartbeat = nil
    end
    local targetGravity = ratioToGravity(ratio)
    gravityHeartbeat = RunService.Heartbeat:Connect(function()
        workspace.Gravity = targetGravity
    end)
end
independentSection:Slider({
    Title = "重力",
    Value = {Min = 0, Max = 1000, Default = 20},
    Callback = function(value)
        gravitySliderValue = math.floor(value)
        startGravityLock(gravitySliderValue)
    end
})

independentSection:Toggle({Title = "穿墙", Value = false, Callback = function(val)
    if val then
        _G.NoclipCon = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            root.CanCollide = false
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end)
    else
        if _G.NoclipCon then
            _G.NoclipCon:Disconnect()
            _G.NoclipCon = nil
        end
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CanCollide = true end
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and not v.CanCollide then
                    v.CanCollide = true
                end
            end
        end
    end
end})

independentSection:Toggle({Title = "锁定视角", Value = false, Callback = function(val)
    if val then
        _G.LockViewCon = RunService:BindToRenderStep("LockView", Enum.RenderPriority.Camera.Value + 1, function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local camDir = workspace.CurrentCamera.CFrame.LookVector
            local flatDir = Vector3.new(camDir.X, 0, camDir.Z)
            if flatDir.Magnitude > 0.01 then
                root.CFrame = CFrame.new(root.Position, root.Position + flatDir)
            end
        end)
    else
        if _G.LockViewCon then
            RunService:UnbindFromRenderStep("LockView")
            _G.LockViewCon = nil
        end
    end
end})

independentSection:Toggle({Title = "透视玩家", Value = false, Callback = function(enabled)
    _G.ESPEnabled = enabled
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "NH_ESP"
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
            end
        end
        _G.ESPAddedCon = Players.PlayerAdded:Connect(function(player)
            if _G.ESPEnabled and player ~= LocalPlayer then
                player.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "NH_ESP"
                    highlight.FillTransparency = 0.7
                    highlight.OutlineTransparency = 0
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Adornee = char
                    highlight.Parent = char
                end)
            end
        end)
    else
        if _G.ESPAddedCon then
            _G.ESPAddedCon:Disconnect()
            _G.ESPAddedCon = nil
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local hl = player.Character:FindFirstChild("NH_ESP")
                if hl then hl:Destroy() end
            end
        end
    end
end})

independentSection:Toggle({Title = "透视", Value = false, Callback = function(val)
    if val then
        _G.XrayCon = RunService.Heartbeat:Connect(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and
                    not (v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChildWhichIsA("Humanoid")) then
                    v.LocalTransparencyModifier = 0.5
                end
            end
        end)
    else
        if _G.XrayCon then
            _G.XrayCon:Disconnect()
            _G.XrayCon = nil
        end
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
    end
end})

independentSection:Toggle({Title = "飞行", Value = false, Callback = function(val)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if val then
        if hum then
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(state, false)
            end
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
        end
        if char.Animate then char.Animate.Disabled = true end
        local bg = Instance.new("BodyGyro", root)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = root.CFrame
        local bv = Instance.new("BodyVelocity", root)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        if hum then hum.PlatformStand = true end
        _G.FlyBody = {bg = bg, bv = bv}
        _G.FlyEnabled = true
        _G.FlyCon1 = RunService.RenderStepped:Connect(function()
            if not _G.FlyEnabled or not char or not hum or hum.Health <= 0 then
                if _G.FlyCon1 then _G.FlyCon1:Disconnect() end
                return
            end
            if root then bg.CFrame = workspace.CurrentCamera.CoordinateFrame end
        end)
        _G.FlyCon2 = RunService.Heartbeat:Connect(function()
            if not _G.FlyEnabled or not char or not hum then return end
            if hum.MoveDirection.Magnitude > 0 then
                char:TranslateBy(hum.MoveDirection * 1)
            end
        end)
    else
        if hum then
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(state, true)
            end
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.PlatformStand = false
        end
        if char.Animate then char.Animate.Disabled = false end
        if _G.FlyBody and _G.FlyBody.bg then _G.FlyBody.bg:Destroy() end
        if _G.FlyBody and _G.FlyBody.bv then _G.FlyBody.bv:Destroy() end
        _G.FlyBody = {}
        _G.FlyEnabled = false
        if _G.FlyCon1 then _G.FlyCon1:Disconnect() _G.FlyCon1 = nil end
        if _G.FlyCon2 then _G.FlyCon2:Disconnect() _G.FlyCon2 = nil end
    end
end})

independentSection:Toggle({Title = "自动存活", Value = false, Callback = function(val)
    if val then
        _G.AutoTpCon = RunService.Stepped:Connect(function()
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-273, 179.5, 394)
            end
        end)
    else
        if _G.AutoTpCon then
            _G.AutoTpCon:Disconnect()
            _G.AutoTpCon = nil
        end
    end
end})

independentSection:Toggle({Title = "地图投票", Value = false, Callback = function(val)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("MainGui")
    local mapPage = mainGui and mainGui:FindFirstChild("MapVotePage")
    if mapPage then mapPage.Visible = val end
end})

local function setTransparency(character, transparency)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = transparency
        end
    end
end

independentSection:Toggle({Title = "隐身", Value = false, Callback = function(val)
    if val then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local savedpos = char.HumanoidRootPart.CFrame
            task.wait()
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            local Seat = Instance.new('Seat', workspace)
            Seat.Anchored = false
            Seat.CanCollide = false
            Seat.Name = 'invischair'
            Seat.Transparency = 1
            Seat.Position = Vector3.new(-25.95, 84, 3537.55)
            local Weld = Instance.new("Weld", Seat)
            Weld.Part0 = Seat
            Weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            task.wait()
            Seat.CFrame = savedpos
            setTransparency(char, 0.5)
        end
    else
        local invisChair = workspace:FindFirstChild('invischair')
        if invisChair then invisChair:Destroy() end
        if LocalPlayer.Character then setTransparency(LocalPlayer.Character, 0) end
    end
end})

independentSection:Toggle({Title = "偷取所有物品", Value = false, Callback = function(val)
    _G.StealLoop = val
    if val then
        task.spawn(function()
            while _G.StealLoop do
                local myBackpack = LocalPlayer:FindFirstChild("Backpack")
                if not myBackpack then
                    myBackpack = Instance.new("Backpack")
                    myBackpack.Parent = LocalPlayer
                end
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if targetPlayer == LocalPlayer or not targetPlayer.Character then continue end
                    local containers = {
                        targetPlayer:FindFirstChild("Backpack"),
                        targetPlayer:FindFirstChild("Inventory"),
                        targetPlayer:FindFirstChild("Storage"),
                        targetPlayer:FindFirstChild("Bag"),
                        targetPlayer.Character:FindFirstChild("Backpack")
                    }
                    for _, container in ipairs(containers) do
                        if not container then continue end
                        for _, item in ipairs(container:GetChildren()) do
                            if item:IsA("Tool") or item:IsA("Model") or item:IsA("Part") or item:IsA("Accessory") then
                                pcall(function() item.Parent = myBackpack end)
                                task.wait(0.05)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end})

local carFlyEnabled = false
local carFlyUI = nil
local carFlyBodyVelocity = nil
local carFlyBodyGyro = nil
local carFlyBodyPosition = nil
local carFlyMoveConnection = nil
local carFlyUpPressed = false
local carFlyDownPressed = false
local carFlySpeed = 100
local carFlyUpDownConnection = nil

local function createCarFlyUI()
    if carFlyUI then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Name = "CarFlyGui"
    screenGui.ResetOnSpawn = false
    carFlyUI = screenGui
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, 125, 0, 100)
    frame.Position = UDim2.new(0.5, -62, 0.5, -50)
    frame.BackgroundTransparency = 1
    frame.Active = true
    frame.Draggable = true
    local function createButton(text, xPos, yPos, color, w, h)
        local btn = Instance.new("TextButton")
        btn.Parent = frame
        btn.Size = UDim2.new(0, w or 50, 0, h or 30)
        btn.Position = UDim2.new(0, xPos, 0, yPos)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end
    local flyBtn = createButton("飞", 0, 5, Color3.fromRGB(0, 180, 0), 48, 28)
    local stopBtn = createButton("停", 0, 36, Color3.fromRGB(180, 0, 0), 48, 28)
    local closeBtn = createButton("关", 0, 67, Color3.fromRGB(200, 50, 50), 48, 28)
    local upBtn = createButton("↑", 77, 5, Color3.fromRGB(0, 100, 255), 48, 42)
    local downBtn = createButton("↓", 77, 50, Color3.fromRGB(0, 100, 255), 48, 42)

    local function startCarFly()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if carFlyBodyVelocity then carFlyBodyVelocity:Destroy() end
        if carFlyBodyGyro then carFlyBodyGyro:Destroy() end
        if carFlyBodyPosition then carFlyBodyPosition:Destroy() end
        if carFlyMoveConnection then carFlyMoveConnection:Disconnect() end
        carFlyBodyVelocity = Instance.new("BodyVelocity", root)
        carFlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        carFlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        carFlyBodyGyro = Instance.new("BodyGyro", root)
        carFlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        carFlyBodyGyro.D = 5000
        carFlyBodyGyro.P = 50000
        carFlyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
        carFlyBodyPosition = Instance.new("BodyPosition", root)
        carFlyBodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
        carFlyBodyPosition.Position = root.Position
        carFlyBodyPosition.D = 20000
        carFlyBodyPosition.P = 200000
        _G.CarFlyBody = {velocity = carFlyBodyVelocity, gyro = carFlyBodyGyro, position = carFlyBodyPosition}
        carFlyMoveConnection = RunService.Heartbeat:Connect(function()
            if not carFlyEnabled or not carFlyBodyVelocity then return end
            local charNow = LocalPlayer.Character
            local rootNow = charNow and charNow:FindFirstChild("HumanoidRootPart")
            local humNow = charNow and charNow:FindFirstChildOfClass("Humanoid")
            if not rootNow or not humNow then return end
            local moveDir = humNow.MoveDirection
            if moveDir.Magnitude > 0 then
                rootNow.Anchored = false
                carFlyBodyVelocity.Velocity = moveDir * carFlySpeed
            else
                carFlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
        _G.CarFlyMoveCon = carFlyMoveConnection
        carFlyUpDownConnection = RunService.RenderStepped:Connect(function()
            if not carFlyEnabled or not carFlyBodyPosition then return end
            local charNow = LocalPlayer.Character
            local rootNow = charNow and charNow:FindFirstChild("HumanoidRootPart")
            if not rootNow then return end
            local pos = rootNow.Position
            if carFlyUpPressed then
                carFlyBodyPosition.Position = Vector3.new(pos.X, pos.Y + carFlySpeed * 2.5, pos.Z)
            elseif carFlyDownPressed then
                carFlyBodyPosition.Position = Vector3.new(pos.X, pos.Y - carFlySpeed * 2.5, pos.Z)
            else
                carFlyBodyPosition.Position = Vector3.new(pos.X, pos.Y, pos.Z)
            end
        end)
        _G.CarFlyUpDownCon = carFlyUpDownConnection
    end

    local function stopCarFly()
        if _G.CarFlyBody and _G.CarFlyBody.velocity then _G.CarFlyBody.velocity:Destroy() end
        if _G.CarFlyBody and _G.CarFlyBody.gyro then _G.CarFlyBody.gyro:Destroy() end
        if _G.CarFlyBody and _G.CarFlyBody.position then _G.CarFlyBody.position:Destroy() end
        if _G.CarFlyMoveCon then _G.CarFlyMoveCon:Disconnect() _G.CarFlyMoveCon = nil end
        if _G.CarFlyUpDownCon then _G.CarFlyUpDownCon:Disconnect() _G.CarFlyUpDownCon = nil end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
    end

    local function closeCarFlyUI()
        stopCarFly()
        if carFlyUI then carFlyUI:Destroy() carFlyUI = nil end
        carFlyEnabled = false
    end

    flyBtn.MouseButton1Click:Connect(startCarFly)
    stopBtn.MouseButton1Click:Connect(stopCarFly)
    closeBtn.MouseButton1Click:Connect(closeCarFlyUI)
    upBtn.MouseButton1Down:Connect(function() carFlyUpPressed = true end)
    upBtn.MouseButton1Up:Connect(function() carFlyUpPressed = false end)
    upBtn.MouseLeave:Connect(function() carFlyUpPressed = false end)
    downBtn.MouseButton1Down:Connect(function() carFlyDownPressed = true end)
    downBtn.MouseButton1Up:Connect(function() carFlyDownPressed = false end)
    downBtn.MouseLeave:Connect(function() carFlyDownPressed = false end)
end

independentSection:Toggle({Title = "飞车", Value = false, Callback = function(val)
    carFlyEnabled = val
    if val then
        createCarFlyUI()
    else
        if carFlyBodyVelocity then carFlyBodyVelocity:Destroy() carFlyBodyVelocity = nil end
        if carFlyBodyGyro then carFlyBodyGyro:Destroy() carFlyBodyGyro = nil end
        if carFlyBodyPosition then carFlyBodyPosition:Destroy() carFlyBodyPosition = nil end
        if carFlyMoveConnection then carFlyMoveConnection:Disconnect() carFlyMoveConnection = nil end
        if carFlyUpDownConnection then carFlyUpDownConnection:Disconnect() carFlyUpDownConnection = nil end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
        if carFlyUI then carFlyUI:Destroy() carFlyUI = nil end
    end
end})

independentSection:Button({Title = "自杀", Callback = function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end})

local teleportTab = Window:Tab({Title = "传送", Icon = "map-pin"})
local teleportSection = teleportTab:Section({Title = "坐标传送", Box = true})
local coordLabel = teleportSection:Label({Title = "X: 0.00  Y: 0.00  Z: 0.00"})
local inputValue = ""
teleportSection:Input({Title = "输入坐标", Placeholder = "例如: 100, 200, 300", Callback = function(text) inputValue = text end})
teleportSection:Button({Title = "复制坐标", Callback = function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        local coordText = string.format("%.2f,%.2f,%.2f", pos.X, pos.Y, pos.Z)
        if setclipboard then
            setclipboard(coordText)
            WindUI:Notify({Title = "复制成功", Content = coordText, Duration = 2, Icon = "check"})
        else
            WindUI:Notify({Title = "复制失败", Content = "当前环境不支持复制", Duration = 2, Icon = "x"})
        end
    end
end})
teleportSection:Button({Title = "传送", Callback = function()
    if inputValue == "" then
        WindUI:Notify({Title = "提示", Content = "请先输入坐标", Duration = 2, Icon = "alert"})
        return
    end
    local parts = {}
    for part in inputValue:gmatch("[^,，%s]+") do
        local num = tonumber(part)
        if num then table.insert(parts, num) end
    end
    if #parts >= 3 then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(parts[1], parts[2], parts[3]))
            WindUI:Notify({Title = "传送成功", Content = string.format("已传送到 (%.2f, %.2f, %.2f)", parts[1], parts[2], parts[3]), Duration = 2, Icon = "check"})
        end
    else
        WindUI:Notify({Title = "格式错误", Content = "请输入如: 100,200,300", Duration = 2, Icon = "alert"})
    end
end})

RunService.Heartbeat:Connect(function()
    if coordLabel then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            coordLabel.Text = string.format("X: %.2f  Y: %.2f  Z: %.2f", pos.X, pos.Y, pos.Z)
        end
    end
end)

local quickTeleportSection = teleportTab:Section({Title = "快速传送", Box = true})
local function createTeleportToggle(name, coords)
    quickTeleportSection:Toggle({Title = name, Value = false, Callback = function(val)
        if val then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(coords)
                WindUI:Notify({Title = name, Content = "已传送", Duration = 2, Icon = "check"})
            end
            task.wait(0.1)
        end
    end})
end
createTeleportToggle("传送出生岛", Vector3.new(-247.14, 180.45, 309.40))
createTeleportToggle("传送岛屿", Vector3.new(-104.44, 48.65, 13.03))
createTeleportToggle("传送虚空", Vector3.new(0, 100000000, 0))

local playerTab = Window:Tab({Title = "玩家", Icon = "users"})
local targetPlayer = nil
local playerMap = {}
local function getPlayerNames()
    local names = {}
    playerMap = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local label = p.DisplayName .. " (@" .. p.Name .. ")"
            table.insert(names, label)
            playerMap[label] = p
        end
    end
    return names
end

local playerSection = playerTab:Section({Title = "玩家", Box = true})
local playerDropdown = playerSection:Dropdown({
    Title = "选择目标玩家",
    Values = getPlayerNames(),
    Callback = function(selected)
        targetPlayer = playerMap[selected]
    end,
    OnOpen = function()
        playerDropdown:SetValues(getPlayerNames())
    end
})

local function refreshDropdown()
    if playerDropdown and playerDropdown.SetValues then
        playerDropdown:SetValues(getPlayerNames())
    end
end
Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)

playerSection:Toggle({Title = "平滑跟随", Value = false, Callback = function(val)
    if val then
        if not targetPlayer then
            WindUI:Notify({Title = "提示", Content = "请先选择目标玩家", Duration = 2, Icon = "alert"})
            return
        end
        _G.SmoothFollowCon = RunService.Heartbeat:Connect(function()
            local myChar = LocalPlayer.Character
            if not myChar then return end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local target = targetPlayer
            if not target or not target.Character then return end
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end
            local offset = targetRoot.CFrame.LookVector * -2.5
            myRoot.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
        end)
    else
        if _G.SmoothFollowCon then
            _G.SmoothFollowCon:Disconnect()
            _G.SmoothFollowCon = nil
        end
    end
end})

playerSection:Button({Title = "传送至选中玩家", Callback = function()
    if not targetPlayer then
        WindUI:Notify({Title = "提示", Content = "请先选择目标玩家", Duration = 2, Icon = "alert"})
        return
    end
    local target = targetPlayer
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = target.Character.HumanoidRootPart.Position
    myChar.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 0, 3))
end})

playerSection:Button({Title = "r15道馆", Callback = function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
    end)
end})

local suckConnection = nil
local suckAnimation = nil
local originalGravity = nil
playerSection:Toggle({Title = "口人", Value = false, Callback = function(val)
    if val then
        if not targetPlayer then
            WindUI:Notify({Title = "提示", Content = "请先选择目标玩家", Duration = 2, Icon = "alert"})
            return
        end
        local target = targetPlayer
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetChar = target.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not myRoot or not targetRoot then return end
        originalGravity = workspace.Gravity
        workspace.Gravity = 0
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://5918726674"
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            suckAnimation = humanoid:LoadAnimation(animation)
            suckAnimation:Play()
            suckAnimation:AdjustSpeed(1)
        end
        local targetTorso = targetChar:FindFirstChild("LowerTorso") or targetChar:FindFirstChild("UpperTorso")
        if targetTorso then
            suckConnection = RunService.Heartbeat:Connect(function()
                if myRoot and targetTorso then
                    myRoot.CFrame = targetTorso.CFrame * CFrame.new(0, -2.3, -1.0) * CFrame.Angles(0, math.pi, 0)
                end
            end)
        end
    else
        if suckConnection then suckConnection:Disconnect() suckConnection = nil end
        if suckAnimation then suckAnimation:Stop() suckAnimation = nil end
        if originalGravity then workspace.Gravity = originalGravity originalGravity = nil end
    end
end})

local bangConnection = nil
local bangAnimation = nil
playerSection:Toggle({Title = "配人", Value = false, Callback = function(val)
    if val then
        if not targetPlayer then
            WindUI:Notify({Title = "提示", Content = "请先选择目标玩家", Duration = 2, Icon = "alert"})
            return
        end
        local target = targetPlayer
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://10714068222"
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            bangAnimation = humanoid:LoadAnimation(animation)
            bangAnimation:Play()
            bangAnimation:AdjustSpeed(2)
        end
        bangConnection = RunService.Heartbeat:Connect(function()
            if not val then return end
            local targetChar = target.Character
            if not targetChar then return end
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHRP or not myRoot then return end
            local forwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
            local backwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)
            local tweenForward = TweenService:Create(myRoot, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = forwardCFrame})
            tweenForward:Play()
            tweenForward.Completed:Wait()
            local tweenBackward = TweenService:Create(myRoot, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = backwardCFrame})
            tweenBackward:Play()
            tweenBackward.Completed:Wait()
        end)
    else
        if bangConnection then bangConnection:Disconnect() bangConnection = nil end
        if bangAnimation then bangAnimation:Stop() bangAnimation = nil end
    end
end})

local susConnection = nil
local susAnimation = nil
playerSection:Toggle({Title = "被配", Value = false, Callback = function(val)
    if val then
        if not targetPlayer then
            WindUI:Notify({Title = "提示", Content = "请先选择目标玩家", Duration = 2, Icon = "alert"})
            return
        end
        local target = targetPlayer
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://10714360343"
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            susAnimation = humanoid:LoadAnimation(animation)
            susAnimation:Play()
        end
        susConnection = RunService.Heartbeat:Connect(function()
            if not val then return end
            local targetChar = target.Character
            if not targetChar then return end
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHRP or not myRoot then return end
            local forwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, -1.5)
            local backwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, -1.1)
            local tweenForward = TweenService:Create(myRoot, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = forwardCFrame})
            tweenForward:Play()
            tweenForward.Completed:Wait()
            local tweenBackward = TweenService:Create(myRoot, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = backwardCFrame})
            tweenBackward:Play()
            tweenBackward.Completed:Wait()
        end)
    else
        if susConnection then susConnection:Disconnect() susConnection = nil end
        if susAnimation then susAnimation:Stop() susAnimation = nil end
    end
end})

local getSuckedConnection = nil
local getSuckedAnimation = nil
local getSuckedGravity = nil
local getSuckedRunning = false
playerSection:Toggle({Title = "人口", Value = false, Callback = function(val)
    if val then
        if not targetPlayer then
            WindUI:Notify({Title = "提示", Content = "请先选择目标玩家", Duration = 2, Icon = "alert"})
            return
        end
        getSuckedRunning = true
        local target = targetPlayer
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetChar = target.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not myRoot or not targetRoot then return end
        getSuckedGravity = workspace.Gravity
        workspace.Gravity = 0
        coroutine.wrap(function()
            while getSuckedRunning and myRoot and targetRoot and myRoot.Position.Y <= 44 do
                wait()
                myRoot.CFrame = myRoot.CFrame * CFrame.new(0, 1.5, 0)
            end
            wait(1)
            if getSuckedRunning then
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://5918726674"
                local humanoid = myChar:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    getSuckedAnimation = humanoid:LoadAnimation(animation)
                    getSuckedAnimation:Play()
                    getSuckedAnimation:AdjustSpeed(1)
                end
                getSuckedConnection = RunService.Stepped:Connect(function()
                    if getSuckedRunning and myRoot and targetRoot then
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2.3, -1.1) * CFrame.Angles(0, math.pi, 0)
                        myRoot.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
        end)()
    else
        getSuckedRunning = false
        if getSuckedConnection then getSuckedConnection:Disconnect() getSuckedConnection = nil end
        if getSuckedAnimation then getSuckedAnimation:Stop() getSuckedAnimation = nil end
        if getSuckedGravity then workspace.Gravity = getSuckedGravity getSuckedGravity = nil end
    end
end})

local blackholeTab = Window:Tab({Title = "黑洞", Icon = "circle"})
local parts = {}
local enabled1 = false
local con1 = nil
local partCon1 = nil
local removeCon1 = nil
local config1 = {radius = 50, height = 100, rotationSpeed = 10, attractionStrength = 1000}
local hrPart = nil
local folder = nil
local part = nil
local attachment1 = nil
local enabled2 = false
local heartbeatCon2 = nil

local function retainPart1(p)
    if p:IsA("BasePart") and not p.Anchored and p:IsDescendantOf(Workspace) then
        if p.Parent == LocalPlayer.Character or p:IsDescendantOf(LocalPlayer.Character) then return false end
        pcall(function()
            p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            p.CanCollide = false
        end)
        return true
    end
    return false
end
local function addPart1(p)
    if retainPart1(p) and not table.find(parts, p) then table.insert(parts, p) end
end
local function removePart1(p)
    local idx = table.find(parts, p)
    if idx then table.remove(parts, idx) end
end
local function refreshParts1()
    parts = {}
    for _, p in pairs(Workspace:GetDescendants()) do addPart1(p) end
end
local function startH1()
    if con1 then return end
    enabled1 = true
    refreshParts1()
    if partCon1 then partCon1:Disconnect() end
    partCon1 = Workspace.DescendantAdded:Connect(addPart1)
    if removeCon1 then removeCon1:Disconnect() end
    removeCon1 = Workspace.DescendantRemoving:Connect(removePart1)
    con1 = RunService.Heartbeat:Connect(function()
        if not enabled1 then return end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local center = root.Position
        for _, p in pairs(parts) do
            if p.Parent and not p.Anchored then
                local pos = p.Position
                local dist = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
                local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
                local newAngle = angle + math.rad(config1.rotationSpeed)
                local targetPos = Vector3.new(
                    center.X + math.cos(newAngle) * math.min(config1.radius, dist),
                    center.Y + (config1.height * (math.abs(math.sin((pos.Y - center.Y) / config1.height)))),
                    center.Z + math.sin(newAngle) * math.min(config1.radius, dist)
                )
                local dir = (targetPos - p.Position).unit
                p.Velocity = dir * config1.attractionStrength
            end
        end
    end)
end
local function stopH1()
    enabled1 = false
    if con1 then con1:Disconnect() con1 = nil end
    if partCon1 then partCon1:Disconnect() partCon1 = nil end
    if removeCon1 then removeCon1:Disconnect() removeCon1 = nil end
    parts = {}
end

local function setupH2()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    hrPart = character:WaitForChild("HumanoidRootPart")
    folder = Instance.new("Folder", Workspace)
    part = Instance.new("Part", folder)
    attachment1 = Instance.new("Attachment", part)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    if not getgenv().Network then
        getgenv().Network = {BaseParts = {}, Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)}
        Network.RetainPart = function(p)
            if typeof(p) == "Instance" and p:IsA("BasePart") and p:IsDescendantOf(Workspace) then
                table.insert(Network.BaseParts, p)
                p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                p.CanCollide = false
            end
        end
        local function EnablePartControl()
            LocalPlayer.ReplicationFocus = Workspace
            RunService.Heartbeat:Connect(function()
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                for _, p in pairs(Network.BaseParts) do
                    if p:IsDescendantOf(Workspace) then
                        p.Velocity = Network.Velocity
                    end
                end
            end)
        end
        EnablePartControl()
    end
end

local function ForcePart(v)
    if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in next, v:GetChildren() do
            if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then v:FindFirstChild("Attachment"):Destroy() end
        if v:FindFirstChild("AlignPosition") then v:FindFirstChild("AlignPosition"):Destroy() end
        if v:FindFirstChild("Torque") then v:FindFirstChild("Torque"):Destroy() end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = 9999999999999999
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = attachment1
    end
end

local function startH2()
    if enabled2 then return end
    enabled2 = true
    setupH2()
    for _, v in next, Workspace:GetDescendants() do ForcePart(v) end
    Workspace.DescendantAdded:Connect(function(v) if enabled2 then ForcePart(v) end end)
    heartbeatCon2 = RunService.Heartbeat:Connect(function()
        if enabled2 and attachment1 and hrPart then
            attachment1.WorldCFrame = hrPart.CFrame
        end
    end)
end

local function stopH2()
    enabled2 = false
    if heartbeatCon2 then heartbeatCon2:Disconnect() heartbeatCon2 = nil end
    if folder then folder:Destroy() folder = nil end
    hrPart = nil
    attachment1 = nil
    part = nil
end

local sectionH1 = blackholeTab:Section({Title = "h1", Box = true})
sectionH1:Toggle({Title = "开启h1", Value = false, Callback = function(val)
    if val then
        startH1()
        WindUI:Notify({Title = "h1", Content = "已开启", Duration = 2, Icon = "check"})
        local settingsTab = Window:Tab({Title = "h1设置", Icon = "settings"})
        local settingsSection = settingsTab:Section({Title = "h1参数", Box = true})
        settingsSection:Slider({Title = "半径", Value = config1.radius, Min = 0, Max = 500, Callback = function(val) config1.radius = val end})
        settingsSection:Slider({Title = "高度", Value = config1.height, Min = 0, Max = 500, Callback = function(val) config1.height = val end})
        settingsSection:Slider({Title = "转速", Value = config1.rotationSpeed, Min = 0, Max = 200, Callback = function(val) config1.rotationSpeed = val end})
        settingsSection:Slider({Title = "吸力", Value = config1.attractionStrength, Min = 0, Max = 50000, Callback = function(val) config1.attractionStrength = val end})
    else
        stopH1()
        WindUI:Notify({Title = "h1", Content = "已关闭", Duration = 2, Icon = "x"})
    end
end})

local sectionH2 = blackholeTab:Section({Title = "h2", Box = true})
sectionH2:Toggle({Title = "开启h2", Value = false, Callback = function(val)
    if val then
        startH2()
        WindUI:Notify({Title = "h2", Content = "已开启", Duration = 2, Icon = "check"})
    else
        stopH2()
        WindUI:Notify({Title = "h2", Content = "已关闭", Duration = 2, Icon = "x"})
    end
end})

local superTab = Window:Tab({Title = "超人", Icon = "zap"})
local superSection = superTab:Section({Title = "加载超人脚本", Box = true})
superSection:Button({Title = "祖国人", Callback = function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/refs/heads/main/homelander.lua"))()
    end)
end})
superSection:Button({Title = "无敌少侠", Callback = function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/invincible-characters-animations-by-GioBolqv1-/refs/heads/main/universal.lua"))()
    end)
end})
superSection:Button({Title = "火车头", Callback = function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/A-Train-by-GioBolqv1-/refs/heads/main/train.lua"))()
    end)
end})

local lightTab = Window:Tab({Title = "光影", Icon = "sun"})
local lightSection = lightTab:Section({Title = "光影效果"})
local originalLighting2 = {}
local originalTerrain = {}
local createdEffects = {}
local runningConnections = {}

local function clearEffects()
    for _, effect in ipairs(createdEffects) do pcall(function() effect:Destroy() end) end
    createdEffects = {}
    for _, conn in ipairs(runningConnections) do pcall(function() conn:Disconnect() end) end
    runningConnections = {}
end

local function saveLighting()
    originalLighting2 = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        ShadowSoftness = Lighting.ShadowSoftness,
        FogColor = Lighting.FogColor,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        ClockTime = Lighting.ClockTime,
        GeographicLatitude = Lighting.GeographicLatitude,
        ExposureCompensation = Lighting.ExposureCompensation,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    }
    originalTerrain = {
        WaterReflectance = Terrain.WaterReflectance,
        WaterTransparency = Terrain.WaterTransparency,
        WaterWaveSize = Terrain.WaterWaveSize,
        WaterWaveSpeed = Terrain.WaterWaveSpeed,
        WaterColor = Terrain.WaterColor
    }
end

local function restoreLighting()
    for key, value in pairs(originalLighting2) do pcall(function() Lighting[key] = value end) end
    for key, value in pairs(originalTerrain) do pcall(function() Terrain[key] = value end) end
end

local function createEffect(effectType, properties)
    local effect = Instance.new(effectType)
    for prop, value in pairs(properties) do
        if effect[prop] ~= nil then effect[prop] = value end
    end
    effect.Parent = Lighting
    table.insert(createdEffects, effect)
    return effect
end

lightSection:Toggle({Title = "真实光影", Value = false, Callback = function(val)
    if val then
        saveLighting()
        clearEffects()
        Lighting.Brightness = 0.2
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.GlobalShadows = false
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    else
        clearEffects()
        restoreLighting()
    end
end})

lightSection:Toggle({Title = "明亮光影", Value = false, Callback = function(val)
    if val then
        saveLighting()
        clearEffects()
        Lighting.ClockTime = 12
        Lighting.GeographicLatitude = 0
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.3
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.new(0.8, 0.8, 0.8)
        Lighting.Ambient = Color3.new(0.6, 0.6, 0.6)
        Lighting.Technology = Enum.Technology.ShadowMap
        createEffect("SunRaysEffect", {Intensity = 0.2, Spread = 0.5})
        createEffect("BloomEffect", {Intensity = 0.3, Size = 10})
        createEffect("Atmosphere", {Density = 0.1, Offset = 0.5, Color = Color3.new(0.9, 0.9, 0.9), Decay = Color3.new(0.9, 0.9, 0.9), Glare = 0, Haze = 0})
        createEffect("ColorCorrectionEffect", {Saturation = -0.1, Contrast = 0.1})
        createEffect("BlurEffect", {Size = 1})
    else
        clearEffects()
        restoreLighting()
    end
end})

lightSection:Toggle({Title = "画质增强Pro Max", Value = false, Callback = function(val)
    if val then
        saveLighting()
        clearEffects()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Sky") then child:Destroy() end
        end
        createEffect("ColorCorrectionEffect", {Contrast = 0.18, Brightness = 0.05, Saturation = 0.3, TintColor = Color3.fromRGB(255, 242, 230)})
        createEffect("BloomEffect", {Intensity = 0.25, Size = 48, Threshold = 0.85})
        createEffect("SunRaysEffect", {Intensity = 0.25, Spread = 1.0})
        createEffect("Atmosphere", {Density = 0.4, Offset = 0.25, Color = Color3.fromRGB(220, 220, 255), Decay = Color3.fromRGB(20, 25, 45), Glare = 0.15, Haze = 0.25})
        local sky = Instance.new("Sky")
        sky.Parent = Lighting
        sky.SkyboxBk = "rbxassetid://6444337006"
        sky.SkyboxDn = "rbxassetid://6444336728"
        sky.SkyboxFt = "rbxassetid://6444337006"
        sky.SkyboxLf = "rbxassetid://6444337006"
        sky.SkyboxRt = "rbxassetid://6444337006"
        sky.SkyboxUp = "rbxassetid://6444336728"
        sky.StarCount = 3000
        table.insert(createdEffects, sky)
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.05
        Lighting.Brightness = 2.8
        Lighting.ExposureCompensation = 0.7
        Lighting.FogColor = Color3.fromRGB(140, 158, 178)
        Lighting.FogEnd = 3000
        Terrain.WaterReflectance = 0.35
        Terrain.WaterTransparency = 0.88
        Terrain.WaterWaveSize = 0.15
        Terrain.WaterWaveSpeed = 25
        Terrain.WaterColor = Color3.fromRGB(72, 141, 202)
    else
        clearEffects()
        restoreLighting()
    end
end})

lightSection:Toggle({Title = "固定黄昏光影", Value = false, Callback = function(val)
    if val then
        saveLighting()
        clearEffects()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Atmosphere") then child:Destroy() end
        end
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.06
        Lighting.Brightness = 3.5
        Lighting.ExposureCompensation = 0.5
        Lighting.EnvironmentSpecularScale = 1.2
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.FogColor = Color3.fromRGB(130, 140, 160)
        Lighting.FogEnd = 8000
        Lighting.FogStart = 50
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 130, 150)
        Lighting.GeographicLatitude = 40.0
        Lighting.ClockTime = 16.5
        createEffect("ColorCorrectionEffect", {Contrast = 0.15, Brightness = 0.04, Saturation = 0.25, TintColor = Color3.fromRGB(255, 245, 235)})
        createEffect("BloomEffect", {Intensity = 0.08, Size = 40, Threshold = 0.95})
        createEffect("SunRaysEffect", {Intensity = 0.22, Spread = 0.8})
        createEffect("DepthOfFieldEffect", {FarIntensity = 0.1, FocusDistance = 35, InFocusRadius = 22, NearIntensity = 0.3})
        createEffect("Atmosphere", {Density = 0.25, Offset = 0.25, Color = Color3.fromRGB(180, 190, 210), Decay = Color3.fromRGB(35, 40, 50), Haze = 0.12})
        Terrain.WaterReflectance = 0.2
        Terrain.WaterTransparency = 0.93
        Terrain.WaterWaveSize = 0.12
        Terrain.WaterWaveSpeed = 16
        Terrain.WaterColor = Color3.fromRGB(75, 135, 200)
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
        sky.Parent = Lighting
        sky.CelestialBodiesShown = true
        sky.StarCount = 3500
        sky.SkyboxBk = "rbxassetid://2711140172"
        sky.SkyboxDn = "rbxassetid://2711140372"
        sky.SkyboxFt = "rbxassetid://2711140592"
        sky.SkyboxLf = "rbxassetid://2711140792"
        sky.SkyboxRt = "rbxassetid://2711141042"
        sky.SkyboxUp = "rbxassetid://2711141282"
        table.insert(createdEffects, sky)
        Workspace.CurrentCamera.FieldOfView = 70
    else
        clearEffects()
        restoreLighting()
    end
end})

local actionTab = Window:Tab({Title = "动作", Icon = "sparkles"})
local actionSection = actionTab:Section({Title = "动作列表", Box = true})
local active = {}

local function clik()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://87152549167464"
    s.Parent = workspace
    s.Volume = 1.2
    s.TimePosition = 0.1
    s:Play()
    game:GetService("Debris"):AddItem(s, 3)
end

local function playAnimation(id, speed, timepos)
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid
            for _, track in pairs(active) do
                if track then track:Stop() end
            end
            active = {}
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://" .. tostring(id)
            local track = animator:LoadAnimation(animation)
            if track then
                track.Looped = true
                track:Play()
                track:AdjustSpeed(speed or 1)
                track.TimePosition = timepos or 0
                active[id] = track
            end
        end
    end
end

local function stopAnimation()
    clik()
    for _, track in pairs(active) do
        if track then track:Stop() end
    end
    active = {}
end

actionSection:Button({Title = "悬浮躺", Callback = function() clik() playAnimation(77840765435893, 1, 0) end})
actionSection:Button({Title = "JOJO姿势", Callback = function() clik() playAnimation(120629563851640, 1, 0) end})
actionSection:Button({Title = "直升机", Callback = function() clik() playAnimation(95301257497525, 1, 0) end})
actionSection:Button({Title = "俄罗斯舞蹈", Callback = function() clik() playAnimation(97148848007002, 1, 0) end})
actionSection:Button({Title = "俯卧撑", Callback = function() clik() playAnimation(108313130500811, 1, 0) end})
actionSection:Button({Title = "停止当前动作", Desc = "打断并停止所有正在播放的动作", Callback = function() stopAnimation() end})

task.spawn(function()
    local WindUI = _G._LCF_WindUI
    if not WindUI then return end
    local oldDialog = WindUI.Dialog
    WindUI.Dialog = function(options)
        options = options or {}
        if options.Title == "Close" or options.Title == "Close Window" then
            options.Title = "关闭窗口"
        end
        if options.Content then
            options.Content = string.gsub(options.Content, "Are you sure you want to close the window?", "确定要关闭窗口吗？")
            options.Content = string.gsub(options.Content, "Are you sure you want to close?", "确定要关闭吗？")
            options.Content = string.gsub(options.Content, "Are you sure", "确定")
        end
        if options.Buttons then
            for _, btn in ipairs(options.Buttons) do
                if btn.Title == "Confirm" or btn.Title == "Yes" then
                    btn.Title = "确定"
                elseif btn.Title == "Cancel" or btn.Title == "No" then
                    btn.Title = "取消"
                end
            end
        end
        return oldDialog(options)
    end
end)

_G._LCF_WindUI = WindUI
_G._LCF_TmplWin = Window
print("[" .. BRAND.name .. "] 全新 UI 加载完成 ✅")

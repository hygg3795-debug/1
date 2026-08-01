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

local superTab = Window:Tab({Title = "超人", Icon = "zap"})
local superSection = superTab:Section({Title = "加载超人脚本", Box = true})
superSection:Button({Title = "祖国人", Callback = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/refs/heads/main/homelander.lua"))() end) end})
superSection:Button({Title = "无敌少侠", Callback = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/invincible-characters-animations-by-GioBolqv1-/refs/heads/main/universal.lua"))() end) end})
superSection:Button({Title = "火车头", Callback = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/A-Train-by-GioBolqv1-/refs/heads/main/train.lua"))() end) end})

local teleportTab = Window:Tab({Title = "传送", Icon = "map-pin"})
local teleportSection = teleportTab:Section({Title = "坐标传送", Box = true})
local coordLabel = nil
local inputBox = nil
local heartbeatConnection = nil
local inputValue = ""

local function parseCoords(input)
    local parts = {}
    for part in input:gmatch("[^,，%s]+") do
        local num = tonumber(part)
        if num then table.insert(parts, num) end
    end
    if #parts >= 3 then
        return parts[1], parts[2], parts[3]
    end
    return nil, nil, nil
end

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        WindUI:Notify({Title = "复制成功", Content = text, Duration = 2, Icon = "check"})
    else
        WindUI:Notify({Title = "复制失败", Content = "当前环境不支持复制", Duration = 2, Icon = "x"})
    end
end

local function updateCoordDisplay()
    if not coordLabel then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        coordLabel.Text = string.format("X: %.2f  Y: %.2f  Z: %.2f", pos.X, pos.Y, pos.Z)
    end
end

coordLabel = teleportSection:Label({Title = "X: 0.00  Y: 0.00  Z: 0.00"})
inputBox = teleportSection:Input({Title = "输入坐标", Placeholder = "例如: 100, 200, 300", Callback = function(text) inputValue = text end})
teleportSection:Button({Title = "复制坐标", Callback = function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        local coordText = string.format("%.2f,%.2f,%.2f", pos.X, pos.Y, pos.Z)
        copyToClipboard(coordText)
    end
end})
teleportSection:Button({Title = "传送", Callback = function()
    if inputValue == "" then
        WindUI:Notify({Title = "提示", Content = "请先输入坐标", Duration = 2, Icon = "alert"})
        return
    end
    local x, y, z = parseCoords(inputValue)
    if not x or not y or not z then
        WindUI:Notify({Title = "格式错误", Content = "请输入如: 100,200,300", Duration = 2, Icon = "alert"})
        return
    end
    teleportTo(Vector3.new(x, y, z))
end})
if heartbeatConnection then heartbeatConnection:Disconnect() end
heartbeatConnection = RunService.Heartbeat:Connect(updateCoordDisplay)

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

local lightTab = Window:Tab({Title = "光影", Icon = "sun"})
local lightSection = lightTab:Section({Title = "光影效果"})
local originalLighting = {}
local originalTerrain = {}
local createdEffects = {}
local runningConnections = {}
local effectObjects = {}
local function clearEffects()
    for _, effect in ipairs(createdEffects) do
        pcall(function() effect:Destroy() end)
    end
    createdEffects = {}
    for _, conn in ipairs(runningConnections) do
        pcall(function() conn:Disconnect() end)
    end
    runningConnections = {}
    for _, obj in ipairs(effectObjects) do
        pcall(function() obj:Destroy() end)
    end
    effectObjects = {}
end
local function saveLighting()
    originalLighting = {
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
    for key, value in pairs(originalLighting) do
        pcall(function() Lighting[key] = value end)
    end
    for key, value in pairs(originalTerrain) do
        pcall(function() Terrain[key] = value end)
    end
end
local function createEffect(effectType, properties)
    local effect = Instance.new(effectType)
    for prop, value in pairs(properties) do
        if effect[prop] ~= nil then
            effect[prop] = value
        end
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
            if child:IsA("PostEffect") or child:IsA("Sky") then
                child:Destroy()
            end
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
            if child:IsA("PostEffect") or child:IsA("Atmosphere") then
                child:Destroy()
            end
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
suggestSection:Toggle({Title = "防踢", Value = false, Callback = function(val)
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
end})
suggestSection:Toggle({Title = "水上行走", Value = false, Callback = function(val)
    local water = game.Workspace:FindFirstChild("WaterLevel")
    if not water then return end
    if val then
        water.CanCollide = true
        water.Size = Vector3.new(1000, 1, 1000)
    else
        water.Size = Vector3.new(10, 1, 10)
        water.CanCollide = false
    end
end})
suggestSection:Toggle({Title = "防甩飞", Value = false, Callback = function(val)
    if val then
        _G.AntiPushCon = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.CanCollide = false end
            end
        end)
    else
        if _G.AntiPushCon then
            _G.AntiPushCon:Disconnect()
            _G.AntiPushCon = nil
        end
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CanCollide = true end
        end
    end
end})
suggestSection:Toggle({Title = "防摔", Value = false, Callback = function(val)
    local api = _G.NoFallAPI
    if not api then
        local con, charCon, z = nil, nil, Vector3.zero
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
        api = {start = function()
            if charCon then charCon:Disconnect() end
            bind(LocalPlayer.Character)
            charCon = LocalPlayer.CharacterAdded:Connect(bind)
        end, stop = function()
            if con then con:Disconnect() end
            if charCon then charCon:Disconnect() charCon = nil end
        end}
        _G.NoFallAPI = api
    end
    if val then api.start() else api.stop() end
end})
suggestSection:Toggle({Title = "无限跳", Value = false, Callback = function(val)
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
end})
suggestSection:Toggle({Title = "去雾", Value = false, Callback = function(enable)
    if enable then
        Lighting.FogStart = 0
        Lighting.FogEnd = math.huge
        Lighting.FogColor = Color3.fromRGB(200, 200, 220)
    else
        Lighting.FogStart = 0
        Lighting.FogEnd = 10000
        Lighting.FogColor = Color3.fromRGB(127, 127, 127)
    end
end})
suggestSection:Toggle({Title = "点击传送工具", Value = false, Callback = function(val)
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
end})
suggestSection:Toggle({Title = "一键清屏", Value = false, Callback = function(val)
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
                            if not Stored[obj] then
                                Stored[obj] = obj.Visible
                            end
                            obj.Visible = false
                        else
                            if Stored[obj] ~= nil then
                                obj.Visible = Stored[obj]
                            end
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
end})
suggestSection:Toggle({Title = "岩石实体化", Value = false, Callback = function(val)
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v.Name == "LowerRocks" and v:IsA("BasePart") then
            v.CanCollide = val
        end
    end
end})
suggestSection:Toggle({Title = "放置方块", Value = false, Callback = function(val)
    if val then
        if _G.BlockGui then _G.BlockGui:Destroy() end
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
                if v.Name == "LocalBlock" then
                    v:Destroy()
                end
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
        if _G.BlockGui then
            _G.BlockGui:Destroy()
            _G.BlockGui = nil
        end
        _G.AutoPlace = false
    end
end})
suggestSection:Toggle({Title = "移除灾害视角", Value = false, Callback = function(val)
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
end})
generalTab:Divider()
local independentSection = generalTab:Section({Title = "独立功能"})
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
independentSection:Toggle({Title = "碰飞", Value = false, Callback = function(val)
    if val then
        _G.FlingRunning = true
        _G.FlingThread = coroutine.create(function()
            local movel = 0.1
            while _G.FlingRunning do
                RunService.Heartbeat:Wait()
                local c = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.Velocity
                    hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                    RunService.RenderStepped:Wait()
                    hrp.Velocity = vel
                    RunService.Stepped:Wait()
                    hrp.Velocity = vel + Vector3.new(0, movel, 0)
                    movel = -movel
                end
            end
        end)
        coroutine.resume(_G.FlingThread)
    else
        _G.FlingRunning = false
        if _G.FlingThread then
            coroutine.close(_G.FlingThread)
            _G.FlingThread = nil
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
        _G.FlyEnabled = true
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
        if _G.FlyCon1 then _G.FlyCon1:Disconnect() _G.FlyCon1 = nil end
        if _G.FlyCon2 then _G.FlyCon2:Disconnect() _G.FlyCon2 = nil end
        _G.FlyEnabled = false
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
independentSection:Toggle({Title = "隐身", Value = false, Callback = function(val)
    local function setTransparency(character, transparency)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = transparency
            end
        end
    end
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
independentSection:Toggle({Title = "飞车", Value = false, Callback = function(val)
    if val then
        local function createCarFlyUI()
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            screenGui.Name = "CarFlyGui"
            screenGui.ResetOnSpawn = false
            _G.CarFlyUI = screenGui
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
            local carFlySpeed = 100
            local carFlyBodyVelocity, carFlyBodyGyro, carFlyBodyPosition, carFlyMoveConnection, carFlyUpDownConnection = nil, nil, nil, nil, nil
            local carFlyUpPressed, carFlyDownPressed = false, false
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
                    if not _G.CarFlyEnabled or not carFlyBodyVelocity then return end
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
                    if not _G.CarFlyEnabled or not carFlyBodyPosition then return end
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
                if _G.CarFlyUI then
                    _G.CarFlyUI:Destroy()
                    _G.CarFlyUI = nil
                end
                _G.CarFlyEnabled = false
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
        _G.CarFlyEnabled = true
        createCarFlyUI()
    else
        _G.CarFlyEnabled = false
        if _G.CarFlyBody and _G.CarFlyBody.velocity then _G.CarFlyBody.velocity:Destroy() end
        if _G.CarFlyBody and _G.CarFlyBody.gyro then _G.CarFlyBody.gyro:Destroy() end
        if _G.CarFlyBody and _G.CarFlyBody.position then _G.CarFlyBody.position:Destroy() end
        if _G.CarFlyMoveCon then _G.CarFlyMoveCon:Disconnect() _G.CarFlyMoveCon = nil end
        if _G.CarFlyUpDownCon then _G.CarFlyUpDownCon:Disconnect() _G.CarFlyUpDownCon = nil end
        if _G.CarFlyUI then
            _G.CarFlyUI:Destroy()
            _G.CarFlyUI = nil
        end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
    end
end})
independentSection:Button({Title = "自杀", Callback = function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end})

local blackholeTab = Window:Tab({Title = "黑洞", Icon = "circle"})
local blackholeParts = {}
local blackholeEnabled = false
local blackholeCon = nil
local blackholeConfig = {radius = 50, height = 100, rotationSpeed = 10, attractionStrength = 1000}

blackholeTab:Toggle({Title = "开启黑洞", Value = false, Callback = function(val)
    if val then
        blackholeEnabled = true
        blackholeParts = {}
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and not p.Anchored and p:IsDescendantOf(Workspace) then
                if p.Parent ~= LocalPlayer.Character and not p:IsDescendantOf(LocalPlayer.Character) then
                    pcall(function()
                        p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                        p.CanCollide = false
                    end)
                    table.insert(blackholeParts, p)
                end
            end
        end
        blackholeCon = RunService.Heartbeat:Connect(function()
            if not blackholeEnabled then return end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local center = root.Position
            for _, p in pairs(blackholeParts) do
                if p.Parent and not p.Anchored then
                    local pos = p.Position
                    local dist = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
                    local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
                    local newAngle = angle + math.rad(blackholeConfig.rotationSpeed)
                    local targetPos = Vector3.new(
                        center.X + math.cos(newAngle) * math.min(blackholeConfig.radius, dist),
                        center.Y + (blackholeConfig.height * (math.abs(math.sin((pos.Y - center.Y) / blackholeConfig.height)))),
                        center.Z + math.sin(newAngle) * math.min(blackholeConfig.radius, dist)
                    )
                    local dir = (targetPos - p.Position).unit
                    p.Velocity = dir * blackholeConfig.attractionStrength
                end
            end
        end)
        WindUI:Notify({Title = "黑洞", Content = "已开启", Duration = 2, Icon = "check"})
    else
        blackholeEnabled = false
        if blackholeCon then blackholeCon:Disconnect() blackholeCon = nil end
        blackholeParts = {}
        WindUI:Notify({Title = "黑洞", Content = "已关闭", Duration = 2, Icon = "x"})
    end
end})

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
local playerDropdown = playerSection:Dropdown({Title = "选择目标玩家", Values = getPlayerNames(), Callback = function(selected) targetPlayer = playerMap[selected] end, OnOpen = function() playerDropdown:SetValues(getPlayerNames()) end})
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
    pcall(function() loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))() end)
end})

_G._LCF_WindUI = WindUI
_G._LCF_TmplWin = Window
print("[" .. BRAND.name .. "] 全新 UI 加载完成 ✅")

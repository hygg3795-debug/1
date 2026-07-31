game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Hygg UI",
    Text = "加载中...",
    Duration = 1,
})

local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/%E7%9A%AE%E8%84%9A%E6%9C%ACUI%E6%BA%90%E7%A0%81.lua"))():new("Hygg UI")

local function notify(title, text, duration)
    duration = duration or 3
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration,
    })
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

----------------------------------------
-- 通用 Tab
----------------------------------------
local generalTab = UILibrary:Tab("通用", "18930406865")
local generalSection = generalTab:section("建议开", true)

local antiAFKEnabled = false
generalSection:Toggle("防踢", "", false, function(val)
    antiAFKEnabled = val
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

local waterCollisionEnabled = false
local originalWaterSize = nil
local originalWaterCollide = nil
local waterFollowConnection = nil
generalSection:Toggle("水上行走", "", false, function(val)
    local water = Workspace:FindFirstChild("WaterLevel")
    if not water then return end
    if val then
        originalWaterSize = water.Size
        originalWaterCollide = water.CanCollide
        water.CanCollide = true
        water.Size = Vector3.new(1000, 1, 1000)
        waterCollisionEnabled = true
        if waterFollowConnection then waterFollowConnection:Disconnect() end
        waterFollowConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and water then
                water.Position = Vector3.new(root.Position.X, water.Position.Y, root.Position.Z)
            end
        end)
    else
        if waterFollowConnection then
            waterFollowConnection:Disconnect()
            waterFollowConnection = nil
        end
        if originalWaterSize then
            water.Size = originalWaterSize
        else
            water.Size = Vector3.new(10, 1, 10)
        end
        if originalWaterCollide ~= nil then
            water.CanCollide = originalWaterCollide
        else
            water.CanCollide = false
        end
        waterCollisionEnabled = false
    end
end)

local antiPushConn = nil
generalSection:Toggle("防甩飞", "", false, function(val)
    if val then
        if antiPushConn then antiPushConn:Disconnect() end
        antiPushConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CanCollide = false
                end
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
            if root then
                root.CanCollide = true
            end
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
    local function start()
        if charCon then charCon:Disconnect() end
        bind(LocalPlayer.Character)
        charCon = LocalPlayer.CharacterAdded:Connect(bind)
    end
    local function stop()
        if con then con:Disconnect() end
        if charCon then charCon:Disconnect() charCon = nil end
    end
    return {start = start, stop = stop}
end
generalSection:Toggle("防摔", "", false, function(val)
    local api = _G.NoFallAPI
    if not api then
        api = createNoFall()
        _G.NoFallAPI = api
    end
    if val then api.start() else api.stop() end
end)

generalSection:Toggle("无限跳", "", false, function(val)
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
generalSection:Toggle("去雾", "", false, function(enable)
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
generalSection:Toggle("点击传送工具", "", false, function(val)
    if val then
        pcall(function()
            local Mouse = LocalPlayer:GetMouse()
            local Camera = Workspace.CurrentCamera
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
                local rayOrigin = unitRay.Origin
                local rayDirection = unitRay.Direction * 100000
                local result = Workspace:Raycast(rayOrigin, rayDirection, params)
                if not result then return end
                local hitPos = result.Position + Vector3.new(0, 3, 0)
                HRP.CFrame = CFrame.new(hitPos)
            end)
            tpTool = Tool
            Tool.Parent = LocalPlayer:WaitForChild("Backpack")
        end)
    else
        if tpTool then tpTool:Destroy() tpTool = nil end
        if LocalPlayer.Character then
            local heldTool = LocalPlayer.Character:FindFirstChild("点击传送")
            if heldTool then heldTool:Destroy() end
        end
    end
end)

generalSection:Toggle("一键清屏", "", false, function(val)
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
            local dragging = false
            local dragInput, startPos, startFramePos
            Button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    startPos = input.Position
                    startFramePos = Button.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.InputUserState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            Button.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    local delta = input.Position - startPos
                    Button.Position = UDim2.new(
                        startFramePos.X.Scale,
                        startFramePos.X.Offset + delta.X,
                        startFramePos.Y.Scale,
                        startFramePos.Y.Offset + delta.Y
                    )
                end
            end)
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

generalSection:Toggle("岩石实体化", "", false, function(val)
    for _, v in pairs(Workspace:GetDescendants()) do
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
    block.Parent = Workspace
end
generalSection:Toggle("放置方块", "", false, function(val)
    if val then
        if blockGui then blockGui:Destroy() end
        local sg = Instance.new("ScreenGui")
        sg.Name = "BlockPlaceGui"
        sg.Parent = LocalPlayer.PlayerGui
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        blockGui = sg
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
            for _, v in pairs(Workspace:GetChildren()) do
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
            autoPlace = false
            autoPlacing = false
            if blockGui then blockGui:Destroy() blockGui = nil end
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
            autoPlace = not autoPlace
            if autoPlace then
                autoBtn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
                if not autoPlacing then
                    autoPlacing = true
                    task.spawn(function()
                        while autoPlace and task.wait(0.1) do
                            placeOneBlock()
                        end
                        autoPlacing = false
                    end)
                end
            else
                autoBtn.BackgroundColor3 = Color3.new(0, 0, 0)
            end
        end)
    else
        autoPlace = false
        autoPlacing = false
        if blockGui then blockGui:Destroy() blockGui = nil end
    end
end)

local disasterConn = nil
generalSection:Toggle("移除灾害视角", "", false, function(val)
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
        if disasterConn then disasterConn:Disconnect() end
        disasterConn = pgui.ChildAdded:Connect(function(child)
            if child.Name == "SandStormGui" or child.Name == "BlizzardGui" then
                task.wait()
                child:Destroy()
            end
        end)
    else
        if disasterConn then
            disasterConn:Disconnect()
            disasterConn = nil
        end
    end
end)

local generalTab2 = UILibrary:Tab("通用", "18930406865") -- 因为一个Tab只能有一个section，我们再创建一个Tab放独立功能
local generalSection2 = generalTab2:section("独立功能", true)

local NoclipEnabled = false
local noclipConnection = nil
local lastGroundY = 0
generalSection2:Toggle("穿墙", "", false, function(val)
    NoclipEnabled = val
    if val then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not NoclipEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                lastGroundY = root.Position.Y
            end
            root.CanCollide = false
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
            if lastGroundY ~= 0 and root.Position.Y < lastGroundY - 5 then
                root.CFrame = CFrame.new(root.CFrame.X, lastGroundY, root.CFrame.Z)
                if hum then hum:ChangeState(Enum.HumanoidStateType.Landed) end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
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
end)

local lockViewEnabled = false
local lockViewConnection = nil
generalSection2:Toggle("锁定视角", "", false, function(val)
    lockViewEnabled = val
    if val then
        if lockViewConnection then
            RunService:UnbindFromRenderStep("LockView")
            lockViewConnection = nil
        end
        lockViewConnection = RunService:BindToRenderStep("LockView", Enum.RenderPriority.Camera.Value + 1, function()
            if not lockViewEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local camDir = Workspace.CurrentCamera.CFrame.LookVector
            local flatDir = Vector3.new(camDir.X, 0, camDir.Z)
            if flatDir.Magnitude > 0.01 then
                root.CFrame = CFrame.new(root.Position, root.Position + flatDir)
            end
        end)
    else
        if lockViewConnection then
            RunService:UnbindFromRenderStep("LockView")
            lockViewConnection = nil
        end
    end
end)

local espEnabled = false
local espConnections = {}
local playerAddedConn = nil
local function createESP(player)
    if not espEnabled or player == LocalPlayer then return end
    if player.Character then
        local existing = player.Character:FindFirstChild("NH_ESP")
        if existing then existing:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name = "NH_ESP"
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
    end
    if not espConnections[player] then
        local connection = player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if espEnabled and player ~= LocalPlayer then
                local existing = char:FindFirstChild("NH_ESP")
                if existing then existing:Destroy() end
                local highlight = Instance.new("Highlight")
                highlight.Name = "NH_ESP"
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Adornee = char
                highlight.Parent = char
            end
        end)
        espConnections[player] = connection
    end
end
generalSection2:Toggle("透视玩家", "", false, function(enabled)
    espEnabled = enabled
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
        playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if espEnabled and player ~= LocalPlayer then createESP(player) end
        end)
    else
        if playerAddedConn then playerAddedConn:Disconnect() playerAddedConn = nil end
        for player, conn in pairs(espConnections) do
            if conn then conn:Disconnect() end
        end
        espConnections = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local hl = player.Character:FindFirstChild("NH_ESP")
                if hl then hl:Destroy() end
            end
        end
    end
end)

local flingEnabled = false
local flingThread = nil
local flingRunning = false
generalSection2:Toggle("碰飞", "", false, function(val)
    flingEnabled = val
    if val then
        if flingRunning then flingRunning = false if flingThread then coroutine.close(flingThread) flingThread = nil end end
        flingRunning = true
        flingThread = coroutine.create(function()
            local movel = 0.1
            while flingRunning do
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
        coroutine.resume(flingThread)
    else
        flingRunning = false
        if flingThread then coroutine.close(flingThread) flingThread = nil end
    end
end)

local xrayEnabled = false
local xrayConnection = nil
generalSection2:Toggle("透视", "", false, function(val)
    xrayEnabled = val
    if val then
        if xrayConnection then xrayConnection:Disconnect() end
        xrayConnection = RunService.Heartbeat:Connect(function()
            if not xrayEnabled then return end
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and
                    not (v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChildWhichIsA("Humanoid")) then
                    v.LocalTransparencyModifier = 0.5
                end
            end
        end)
    else
        if xrayConnection then xrayConnection:Disconnect() xrayConnection = nil end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
        end
    end
end)

local flyEnabled = false
local flyConnections = {}
local flyBody = {}
generalSection2:Toggle("飞行", "", false, function(val)
    flyEnabled = val
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
        flyBody = {bg = bg, bv = bv}
        local conn = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not char or not hum or hum.Health <= 0 then
                if conn then conn:Disconnect() end
                return
            end
            if root then bg.CFrame = Workspace.CurrentCamera.CoordinateFrame end
        end)
        table.insert(flyConnections, conn)
        local conn2 = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not char or not hum then return end
            if hum.MoveDirection.Magnitude > 0 then
                char:TranslateBy(hum.MoveDirection * 1)
            end
        end)
        table.insert(flyConnections, conn2)
    else
        if hum then
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(state, true)
            end
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.PlatformStand = false
        end
        if char.Animate then char.Animate.Disabled = false end
        if flyBody.bg then flyBody.bg:Destroy() end
        if flyBody.bv then flyBody.bv:Destroy() end
        flyBody = {}
        for _, c in pairs(flyConnections) do pcall(function() c:Disconnect() end) end
        flyConnections = {}
    end
end)

local tpConnection = nil
generalSection2:Toggle("自动存活", "", false, function(val)
    if val then
        if tpConnection then tpConnection:Disconnect() end
        tpConnection = RunService.Stepped:Connect(function()
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-273, 179.5, 394)
            end
        end)
    else
        if tpConnection then tpConnection:Disconnect() tpConnection = nil end
    end
end)

generalSection2:Toggle("地图投票", "", false, function(val)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("MainGui")
    local mapPage = mainGui and mainGui:FindFirstChild("MapVotePage")
    if mapPage then mapPage.Visible = val end
end)

local function playActionSound()
    local sound = Instance.new("Sound", LocalPlayer:WaitForChild("PlayerGui"))
    sound.SoundId = "rbxassetid://942127495"
    sound.Volume = 1
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end
local function setTransparency(character, transparency)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = transparency
        end
    end
end
local invis_on = false
generalSection2:Toggle("隐身", "", false, function(val)
    invis_on = val
    playActionSound()
    if invis_on then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local savedpos = char.HumanoidRootPart.CFrame
            task.wait()
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            local Seat = Instance.new('Seat', Workspace)
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
        local invisChair = Workspace:FindFirstChild('invischair')
        if invisChair then invisChair:Destroy() end
        if LocalPlayer.Character then setTransparency(LocalPlayer.Character, 0) end
    end
end)

local stealLoop = false
local function stealAllItems()
    local count = 0
    local myBackpack = LocalPlayer:FindFirstChild("Backpack")
    if not myBackpack then
        myBackpack = Instance.new("Backpack")
        myBackpack.Parent = LocalPlayer
    end
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == LocalPlayer or not targetPlayer.Character then continue end
        local itemContainers = {
            targetPlayer:FindFirstChild("Backpack"),
            targetPlayer:FindFirstChild("Inventory"),
            targetPlayer:FindFirstChild("Storage"),
            targetPlayer:FindFirstChild("Bag"),
            targetPlayer.Character:FindFirstChild("Backpack")
        }
        for _, container in ipairs(itemContainers) do
            if not container then continue end
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Model") or item:IsA("Part") or item:IsA("Accessory") then
                    local success = pcall(function() item.Parent = myBackpack end)
                    if success then count = count + 1 task.wait(0.05) end
                end
            end
        end
    end
    return count
end
generalSection2:Toggle("偷取所有物品", "", false, function(val)
    stealLoop = val
    if val then
        task.spawn(function()
            while stealLoop do
                stealAllItems()
                task.wait(1)
            end
        end)
    end
end)

local speedJumpGuiObj = nil
local speedHeartbeat = nil
local jumpHeartbeat = nil
local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function stopSpeedLock() if speedHeartbeat then speedHeartbeat:Disconnect() speedHeartbeat = nil end end
local function stopJumpLock() if jumpHeartbeat then jumpHeartbeat:Disconnect() jumpHeartbeat = nil end end
local function startSpeedLock(sVal)
    stopSpeedLock()
    speedHeartbeat = RunService.Heartbeat:Connect(function()
        local hum = getHumanoid()
        if hum and hum.WalkSpeed ~= sVal then hum.WalkSpeed = sVal end
    end)
end
local function startJumpLock(jVal)
    stopJumpLock()
    jumpHeartbeat = RunService.Heartbeat:Connect(function()
        local hum = getHumanoid()
        if hum then
            hum.UseJumpPower = true
            if hum.JumpPower ~= jVal then hum.JumpPower = jVal end
        end
    end)
end
generalSection2:Toggle("移速跳高调整", "", false, function(val)
    if val then
        if speedJumpGuiObj then speedJumpGuiObj:Destroy() end
        local sg = Instance.new("ScreenGui")
        sg.Name = "SpeedJumpGui"
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        speedJumpGuiObj = sg
        local panel = Instance.new("Frame")
        panel.Parent = sg
        panel.Size = UDim2.new(0, 320, 0, 260)
        panel.Position = UDim2.new(0.5, -160, 0.5, -130)
        panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        panel.BackgroundTransparency = 0.1
        panel.ZIndex = 200
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", panel).Thickness = 2
        local dragHeader = Instance.new("Frame")
        dragHeader.Name = "DragHeader"
        dragHeader.Parent = panel
        dragHeader.Size = UDim2.new(1, 0, 0, 35)
        dragHeader.BackgroundTransparency = 1
        dragHeader.ZIndex = 201
        local title = Instance.new("TextLabel")
        title.Parent = dragHeader
        title.Size = UDim2.new(1, -40, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "移速跳高调整 (按住此处拖动)"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        local speedLabel = Instance.new("TextLabel")
        speedLabel.Parent = panel
        speedLabel.Size = UDim2.new(1, -40, 0, 20)
        speedLabel.Position = UDim2.new(0, 20, 0, 40)
        speedLabel.BackgroundTransparency = 1
        speedLabel.Text = "调整移速"
        speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        speedLabel.Font = Enum.Font.GothamBold
        speedLabel.TextSize = 13
        speedLabel.TextXAlignment = Enum.TextXAlignment.Left
        local speedSlider = Instance.new("Frame")
        speedSlider.Parent = panel
        speedSlider.Size = UDim2.new(1, -120, 0, 24)
        speedSlider.Position = UDim2.new(0, 20, 0, 65)
        speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 6)
        local speedFill = Instance.new("Frame")
        speedFill.Parent = speedSlider
        speedFill.Size = UDim2.new(0, 0, 1, 0)
        speedFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        speedFill.BorderSizePixel = 0
        Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0, 6)
        local speedKnob = Instance.new("TextButton")
        speedKnob.Parent = speedSlider
        speedKnob.Size = UDim2.new(0, 18, 0, 18)
        speedKnob.Position = UDim2.new(0, -9, 0.5, -9)
        speedKnob.Text = ""
        speedKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        speedKnob.AutoButtonColor = false
        Instance.new("UICorner", speedKnob).CornerRadius = UDim.new(1, 0)
        local speedBox = Instance.new("TextBox")
        speedBox.Parent = panel
        speedBox.Size = UDim2.new(0, 70, 0, 28)
        speedBox.Position = UDim2.new(1, -90, 0, 63)
        speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        speedBox.Text = "16"
        speedBox.TextColor3 = Color3.new(1, 1, 1)
        speedBox.Font = Enum.Font.Gotham
        speedBox.TextSize = 14
        Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)
        local minSpeed, maxSpeed = 5, 1000
        local function updateSpeedSliderDisplay(val)
            local percent = (val - minSpeed) / (maxSpeed - minSpeed)
            speedFill.Size = UDim2.new(percent, 0, 1, 0)
            speedKnob.Position = UDim2.new(percent, -9, 0.5, -9)
        end
        local jumpLabel = Instance.new("TextLabel")
        jumpLabel.Parent = panel
        jumpLabel.Size = UDim2.new(1, -40, 0, 20)
        jumpLabel.Position = UDim2.new(0, 20, 0, 105)
        jumpLabel.BackgroundTransparency = 1
        jumpLabel.Text = "调整跳高"
        jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        jumpLabel.Font = Enum.Font.GothamBold
        jumpLabel.TextSize = 13
        jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
        local jumpSlider = Instance.new("Frame")
        jumpSlider.Parent = panel
        jumpSlider.Size = UDim2.new(1, -120, 0, 24)
        jumpSlider.Position = UDim2.new(0, 20, 0, 130)
        jumpSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", jumpSlider).CornerRadius = UDim.new(0, 6)
        local jumpFill = Instance.new("Frame")
        jumpFill.Parent = jumpSlider
        jumpFill.Size = UDim2.new(0, 0, 1, 0)
        jumpFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        jumpFill.BorderSizePixel = 0
        Instance.new("UICorner", jumpFill).CornerRadius = UDim.new(0, 6)
        local jumpKnob = Instance.new("TextButton")
        jumpKnob.Parent = jumpSlider
        jumpKnob.Size = UDim2.new(0, 18, 0, 18)
        jumpKnob.Position = UDim2.new(0, -9, 0.5, -9)
        jumpKnob.Text = ""
        jumpKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        jumpKnob.AutoButtonColor = false
        Instance.new("UICorner", jumpKnob).CornerRadius = UDim.new(1, 0)
        local jumpBox = Instance.new("TextBox")
        jumpBox.Parent = panel
        jumpBox.Size = UDim2.new(0, 70, 0, 28)
        jumpBox.Position = UDim2.new(1, -90, 0, 128)
        jumpBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        jumpBox.Text = "50"
        jumpBox.TextColor3 = Color3.new(1, 1, 1)
        jumpBox.Font = Enum.Font.Gotham
        jumpBox.TextSize = 14
        Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 6)
        local minJump, maxJump = 50, 600
        local function updateJumpSliderDisplay(val)
            local percent = (val - minJump) / (maxJump - minJump)
            jumpFill.Size = UDim2.new(percent, 0, 1, 0)
            jumpKnob.Position = UDim2.new(percent, -9, 0.5, -9)
        end
        local speedDragging, jumpDragging = false, false
        speedKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                speedDragging = true
            end
        end)
        jumpKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                jumpDragging = true
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if speedDragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local sliderAbs = speedSlider.AbsolutePosition
                    local sliderSize = speedSlider.AbsoluteSize
                    local relativeX = math.clamp(mousePos.X - sliderAbs.X, 0, sliderSize.X)
                    local percent = relativeX / sliderSize.X
                    local newVal = math.floor(minSpeed + (maxSpeed - minSpeed) * percent)
                    speedBox.Text = tostring(newVal)
                    updateSpeedSliderDisplay(newVal)
                elseif jumpDragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local sliderAbs = jumpSlider.AbsolutePosition
                    local sliderSize = jumpSlider.AbsoluteSize
                    local relativeX = math.clamp(mousePos.X - sliderAbs.X, 0, sliderSize.X)
                    local percent = relativeX / sliderSize.X
                    local newVal = math.floor(minJump + (maxJump - minJump) * percent)
                    jumpBox.Text = tostring(newVal)
                    updateJumpSliderDisplay(newVal)
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                speedDragging = false
                jumpDragging = false
            end
        end)
        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Parent = panel
        confirmBtn.Size = UDim2.new(0, 120, 0, 35)
        confirmBtn.Position = UDim2.new(0, 20, 0, 185)
        confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        confirmBtn.Text = "确认"
        confirmBtn.TextColor3 = Color3.new(1, 1, 1)
        confirmBtn.Font = Enum.Font.GothamBold
        confirmBtn.TextSize = 15
        Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)
        confirmBtn.MouseButton1Click:Connect(function()
            local sVal = tonumber(speedBox.Text) or 16
            local jVal = tonumber(jumpBox.Text) or 50
            sVal = math.clamp(math.floor(sVal), minSpeed, maxSpeed)
            jVal = math.clamp(math.floor(jVal), minJump, maxJump)
            startSpeedLock(sVal)
            startJumpLock(jVal)
            if speedJumpGuiObj then speedJumpGuiObj:Destroy() speedJumpGuiObj = nil end
        end)
        local resetBtn = Instance.new("TextButton")
        resetBtn.Parent = panel
        resetBtn.Size = UDim2.new(0, 120, 0, 35)
        resetBtn.Position = UDim2.new(1, -140, 0, 185)
        resetBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 0)
        resetBtn.Text = "重置"
        resetBtn.TextColor3 = Color3.new(1, 1, 1)
        resetBtn.Font = Enum.Font.GothamBold
        resetBtn.TextSize = 15
        Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
        resetBtn.MouseButton1Click:Connect(function()
            speedBox.Text = "16"
            jumpBox.Text = "50"
            updateSpeedSliderDisplay(16)
            updateJumpSliderDisplay(50)
        end)
        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = panel
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -35, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "X"
        closeBtn.TextSize = 16
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.ZIndex = 202
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseButton1Click:Connect(function()
            stopSpeedLock()
            stopJumpLock()
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 16 hum.JumpPower = 50 end
            if speedJumpGuiObj then speedJumpGuiObj:Destroy() speedJumpGuiObj = nil end
        end)
        updateSpeedSliderDisplay(16)
        updateJumpSliderDisplay(50)
    else
        stopSpeedLock()
        stopJumpLock()
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 hum.JumpPower = 50 end
        if speedJumpGuiObj then speedJumpGuiObj:Destroy() speedJumpGuiObj = nil end
    end
end)

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
        carFlyBodyGyro.CFrame = Workspace.CurrentCamera.CFrame
        carFlyBodyPosition = Instance.new("BodyPosition", root)
        carFlyBodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
        carFlyBodyPosition.Position = root.Position
        carFlyBodyPosition.D = 20000
        carFlyBodyPosition.P = 200000
        local hum = char and char:FindFirstChildOfClass("Humanoid")
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
    end
    local function stopCarFly()
        if carFlyBodyVelocity then carFlyBodyVelocity:Destroy() carFlyBodyVelocity = nil end
        if carFlyBodyGyro then carFlyBodyGyro:Destroy() carFlyBodyGyro = nil end
        if carFlyBodyPosition then carFlyBodyPosition:Destroy() carFlyBodyPosition = nil end
        if carFlyMoveConnection then carFlyMoveConnection:Disconnect() carFlyMoveConnection = nil end
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
    if carFlyUpDownConnection then carFlyUpDownConnection:Disconnect() end
    carFlyUpDownConnection = RunService.RenderStepped:Connect(function()
        if not carFlyEnabled or not carFlyBodyPosition then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local pos = root.Position
        if carFlyUpPressed then
            carFlyBodyPosition.Position = Vector3.new(pos.X, pos.Y + carFlySpeed * 2.5, pos.Z)
        elseif carFlyDownPressed then
            carFlyBodyPosition.Position = Vector3.new(pos.X, pos.Y - carFlySpeed * 2.5, pos.Z)
        else
            carFlyBodyPosition.Position = Vector3.new(pos.X, pos.Y, pos.Z)
        end
    end)
end
generalSection2:Toggle("飞车", "", false, function(val)
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
end)

generalSection2:Button("自杀", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

----------------------------------------
-- 传送 Tab
----------------------------------------
local teleportTab = UILibrary:Tab("传送", "18930406865")
local teleportSection = teleportTab:section("坐标传送", true)

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
    if #parts >= 3 then return parts[1], parts[2], parts[3] end
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
        notify("复制成功", text, 2)
    else
        notify("复制失败", "当前环境不支持复制", 2)
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
coordLabel = teleportSection:Label("X: 0.00  Y: 0.00  Z: 0.00")
inputBox = teleportSection:Textbox("输入坐标", "", "例如: 100, 200, 300", function(text)
    inputValue = text
end)
teleportSection:Button("复制坐标", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        copyToClipboard(string.format("%.2f,%.2f,%.2f", pos.X, pos.Y, pos.Z))
    end
end)
teleportSection:Button("传送", function()
    if inputValue == "" then
        notify("提示", "请先输入坐标", 2)
        return
    end
    local x, y, z = parseCoords(inputValue)
    if not x or not y or not z then
        notify("格式错误", "请输入如: 100,200,300", 2)
        return
    end
    teleportTo(Vector3.new(x, y, z))
end)
if heartbeatConnection then heartbeatConnection:Disconnect() end
heartbeatConnection = RunService.Heartbeat:Connect(updateCoordDisplay)

----------------------------------------
-- 玩家 Tab
----------------------------------------
local playerTab = UILibrary:Tab("玩家", "18930406865")
local playerSection = playerTab:section("玩家", true)

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
local playerDropdown = playerSection:Dropdown("选择目标玩家", "", getPlayerNames(), function(selected)
    targetPlayer = playerMap[selected]
end)
local function refreshDropdown()
    if playerDropdown then playerDropdown:SetOptions(getPlayerNames()) end
end
Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)

local smoothFollowConnection = nil
local smoothFollowToggle = false
playerSection:Toggle("平滑跟随", "", false, function(val)
    smoothFollowToggle = val
    if val then
        if not targetPlayer then
            notify("提示", "请先选择目标玩家", 2)
            smoothFollowToggle = false
            return
        end
        if smoothFollowConnection then smoothFollowConnection:Disconnect() smoothFollowConnection = nil end
        smoothFollowConnection = RunService.Heartbeat:Connect(function()
            if not smoothFollowToggle then
                if smoothFollowConnection then smoothFollowConnection:Disconnect() smoothFollowConnection = nil end
                return
            end
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
        if smoothFollowConnection then smoothFollowConnection:Disconnect() smoothFollowConnection = nil end
    end
end)

playerSection:Button("传送至选中玩家", function()
    if not targetPlayer then
        notify("提示", "请先选择目标玩家", 2)
        return
    end
    local target = targetPlayer
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = target.Character.HumanoidRootPart.Position
    myChar.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 0, 3))
end)

playerSection:Button("r15道馆", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
    end)
end)

local suckConnection = nil
local suckAnimation = nil
local originalGravity = nil
local suckToggle = false
playerSection:Toggle("口人", "", false, function(val)
    suckToggle = val
    if val then
        if not targetPlayer then
            notify("提示", "请先选择目标玩家", 2)
            suckToggle = false
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
        originalGravity = Workspace.Gravity
        Workspace.Gravity = 0
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
                if suckToggle and myRoot and targetTorso then
                    myRoot.CFrame = targetTorso.CFrame * CFrame.new(0, -2.3, -1.0) * CFrame.Angles(0, math.pi, 0)
                end
            end)
        end
    else
        suckToggle = false
        if suckConnection then suckConnection:Disconnect() suckConnection = nil end
        if suckAnimation then suckAnimation:Stop() suckAnimation = nil end
        if originalGravity then Workspace.Gravity = originalGravity originalGravity = nil end
    end
end)

local bangConnection = nil
local bangAnimation = nil
local bangToggle = false
playerSection:Toggle("配人", "", false, function(val)
    bangToggle = val
    if val then
        if not targetPlayer then
            notify("提示", "请先选择目标玩家", 2)
            bangToggle = false
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
            if not bangToggle then return end
            local targetChar = target.Character
            if not targetChar then bangToggle = false return end
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHRP or not myRoot then return end
            local forwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
            local backwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)
            local tweenForward = TweenService:Create(
                myRoot,
                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                {CFrame = forwardCFrame}
            )
            tweenForward:Play()
            tweenForward.Completed:Wait()
            local tweenBackward = TweenService:Create(
                myRoot,
                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                {CFrame = backwardCFrame}
            )
            tweenBackward:Play()
            tweenBackward.Completed:Wait()
        end)
    else
        bangToggle = false
        if bangConnection then bangConnection:Disconnect() bangConnection = nil end
        if bangAnimation then bangAnimation:Stop() bangAnimation = nil end
    end
end)

local susConnection = nil
local susAnimation = nil
local susToggle = false
playerSection:Toggle("被配", "", false, function(val)
    susToggle = val
    if val then
        if not targetPlayer then
            notify("提示", "请先选择目标玩家", 2)
            susToggle = false
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
            if not susToggle then return end
            local targetChar = target.Character
            if not targetChar then susToggle = false return end
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHRP or not myRoot then return end
            local forwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, -1.5)
            local backwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, -1.1)
            local tweenForward = TweenService:Create(
                myRoot,
                TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                {CFrame = forwardCFrame}
            )
            tweenForward:Play()
            tweenForward.Completed:Wait()
            local tweenBackward = TweenService:Create(
                myRoot,
                TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                {CFrame = backwardCFrame}
            )
            tweenBackward:Play()
            tweenBackward.Completed:Wait()
        end)
    else
        susToggle = false
        if susConnection then susConnection:Disconnect() susConnection = nil end
        if susAnimation then susAnimation:Stop() susAnimation = nil end
    end
end)

local getSuckedConnection = nil
local getSuckedAnimation = nil
local getSuckedGravity = nil
local getSuckedToggle = false
local getSuckedRunning = false
playerSection:Toggle("人口", "", false, function(val)
    getSuckedToggle = val
    if val then
        if not targetPlayer then
            notify("提示", "请先选择目标玩家", 2)
            getSuckedToggle = false
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
        getSuckedGravity = Workspace.Gravity
        Workspace.Gravity = 0
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
        getSuckedToggle = false
        getSuckedRunning = false
        if getSuckedConnection then getSuckedConnection:Disconnect() getSuckedConnection = nil end
        if getSuckedAnimation then getSuckedAnimation:Stop() getSuckedAnimation = nil end
        if getSuckedGravity then Workspace.Gravity = getSuckedGravity getSuckedGravity = nil end
    end
end)

----------------------------------------
-- 黑洞 Tab
----------------------------------------
local blackholeTab = UILibrary:Tab("黑洞", "18930406865")
local blackholeSection = blackholeTab:section("H1", true)

local parts = {}
local enabled1 = false
local con1 = nil
local partCon1 = nil
local removeCon1 = nil
local config1 = {radius = 50, height = 100, rotationSpeed = 10, attractionStrength = 1000}
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
blackholeSection:Toggle("开启H1", "", false, function(val)
    if val then
        startH1()
        notify("H1", "已开启", 2)
    else
        stopH1()
        notify("H1", "已关闭", 2)
    end
end)

local h1SettingsSection = blackholeTab:section("H1参数", true)
h1SettingsSection:Slider("半径", "", 0, 500, config1.radius, function(val) config1.radius = val end)
h1SettingsSection:Slider("高度", "", 0, 500, config1.height, function(val) config1.height = val end)
h1SettingsSection:Slider("转速", "", 0, 200, config1.rotationSpeed, function(val) config1.rotationSpeed = val end)
h1SettingsSection:Slider("吸力", "", 0, 50000, config1.attractionStrength, function(val) config1.attractionStrength = val end)

local blackholeSection2 = blackholeTab:section("H2", true)
local hrPart = nil
local folder = nil
local part = nil
local attachment1 = nil
local enabled2 = false
local heartbeatCon2 = nil
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
        getgenv().Network = {
            BaseParts = {},
            Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
        }
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
    Workspace.DescendantAdded:Connect(function(v)
        if enabled2 then ForcePart(v) end
    end)
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
blackholeSection2:Toggle("开启H2", "", false, function(val)
    if val then
        startH2()
        notify("H2", "已开启", 2)
    else
        stopH2()
        notify("H2", "已关闭", 2)
    end
end)

----------------------------------------
-- 超人 Tab
----------------------------------------
local superTab = UILibrary:Tab("超人", "18930406865")
local superSection = superTab:section("加载超人脚本", true)
superSection:Button("祖国人", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/refs/heads/main/homelander.lua"))()
    end)
end)
superSection:Button("无敌少侠", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/invincible-characters-animations-by-GioBolqv1-/refs/heads/main/universal.lua"))()
    end)
end)
superSection:Button("火车头", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/A-Train-by-GioBolqv1-/refs/heads/main/train.lua"))()
    end)
end)

----------------------------------------
-- 动作 Tab
----------------------------------------
local actionTab = UILibrary:Tab("动作", "18930406865")
local actionSection = actionTab:section("动作列表", true)

local active = {}
local function clik()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://87152549167464"
    s.Parent = Workspace
    s.Volume = 1.2
    s.TimePosition = 0.1
    s:Play()
    game:GetService("Debris"):AddItem(s, 3)
end
local function playAnimation(id, speed, timepos)
    local player = LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid
            for _, track in pairs(active) do if track then track:Stop() end end
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
    for _, track in pairs(active) do if track then track:Stop() end end
    active = {}
end
actionSection:Button("悬浮躺", function()
    clik()
    playAnimation(77840765435893, 1, 0)
end)
actionSection:Button("JOJO姿势", function()
    clik()
    playAnimation(120629563851640, 1, 0)
end)
actionSection:Button("直升机", function()
    clik()
    playAnimation(95301257497525, 1, 0)
end)
actionSection:Button("俄罗斯舞蹈", function()
    clik()
    playAnimation(97148848007002, 1, 0)
end)
actionSection:Button("俯卧撑", function()
    clik()
    playAnimation(108313130500811, 1, 0)
end)
actionSection:Button("停止当前动作", function()
    stopAnimation()
end)

----------------------------------------
-- 光影 Tab
----------------------------------------
local lightingTab = UILibrary:Tab("光影", "18930406865")
local lightingSection = lightingTab:section("光影效果", true)

local originalLighting2 = {}
local originalTerrain = {}
local createdEffects = {}
local runningConnections2 = {}
local effectObjects = {}
local function clearEffects()
    for _, effect in ipairs(createdEffects) do pcall(function() effect:Destroy() end) end
    createdEffects = {}
    for _, conn in ipairs(runningConnections2) do pcall(function() conn:Disconnect() end) end
    runningConnections2 = {}
    for _, obj in ipairs(effectObjects) do pcall(function() obj:Destroy() end) end
    effectObjects = {}
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

local realLightingEnabled = false
local realLightingConn = nil
local realLightingParts = {}
local realLightingCharConn = nil
lightingSection:Toggle("真实光影", "", false, function(val)
    if val then
        saveLighting()
        clearEffects()
        Lighting.Brightness = 0.2
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.GlobalShadows = false
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        local camera = Workspace.CurrentCamera
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local sunDirection = Vector3.new(1, -1, 1).Unit
        local sunColor = Color3.fromRGB(255, 255, 224)
        local sunIntensity = 100
        local skyColor = Color3.fromRGB(135, 206, 235)
        local skyIntensity = 0.5
        local maxDistance = 50000
        local gammaCorrection = 10
        local maxRays = 100000
        local minRays = 10000
        local lodDistance = 200
        local function getSurfaceNormal(part, position)
            if part:IsA("MeshPart") or part:IsA("UnionOperation") then
                return (position - part.Position).Unit
            else
                local relativePosition = part.CFrame:PointToObjectSpace(position)
                local halfSize = part.Size / 2
                local normals = {
                    Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
                    Vector3.new(0, 1, 0), Vector3.new(0, -1, 0),
                    Vector3.new(0, 0, 1), Vector3.new(0, 0, -1)
                }
                local distances = {
                    math.abs(halfSize.X - relativePosition.X),
                    math.abs(-halfSize.X - relativePosition.X),
                    math.abs(halfSize.Y - relativePosition.Y),
                    math.abs(-halfSize.Y - relativePosition.Y),
                    math.abs(halfSize.Z - relativePosition.Z),
                    math.abs(-halfSize.Z - relativePosition.Z)
                }
                local minDistance = math.huge
                local normal = Vector3.new(0, 1, 0)
                for i = 1, 6 do
                    if distances[i] < minDistance then
                        minDistance = distances[i]
                        normal = normals[i]
                    end
                end
                return part.CFrame:VectorToWorldSpace(normal)
            end
        end
        local function computeLightingForPoint(part, position)
            local accumulatedColor = Color3.new(0, 0, 0)
            local surfaceNormal = getSurfaceNormal(part, position)
            local offsetPosition = position + surfaceNormal * 0.01
            local distanceFromCamera = (camera.CFrame.Position - position).Magnitude
            local numRays = maxRays
            if distanceFromCamera > lodDistance then
                numRays = math.max(minRays, math.floor(maxRays * (lodDistance / distanceFromCamera)))
            end
            local skySamples = 10000000
            local skyLight = Color3.new(0, 0, 0)
            for i = 1, numRays do
                local u = math.random()
                local v = math.random()
                local theta = math.acos(math.sqrt(1 - u))
                local phi = 2 * math.pi * v
                local x = math.sin(theta) * math.cos(phi)
                local y = math.cos(theta)
                local z = math.sin(theta) * math.sin(phi)
                local randomDirection = Vector3.new(x, y, z).Unit
                local up = Vector3.new(0, 1, 0)
                local rotation = CFrame.fromAxisAngle(up:Cross(surfaceNormal), math.acos(up:Dot(surfaceNormal)))
                randomDirection = rotation:VectorToWorldSpace(randomDirection)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {part, character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.IgnoreWater = true
                local result = Workspace:Raycast(offsetPosition, randomDirection * maxDistance, rayParams)
                if not result then
                    skyLight += skyColor
                    skySamples = skySamples + 1
                end
            end
            if skySamples > 0 then
                skyLight = (skyLight / skySamples) * skyIntensity
                accumulatedColor += skyLight
            end
            local normalDotLight = math.max(0, surfaceNormal:Dot(-sunDirection))
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {part, character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.IgnoreWater = true
            local sunOccluded = Workspace:Raycast(offsetPosition, -sunDirection * maxDistance, rayParams)
            local shadowFactor = sunOccluded and 0 or 1
            local materialReflectance = part.Reflectance
            local materialColor = part.Color
            local sunIntensityFactor = normalDotLight * sunIntensity * (1 - materialReflectance) * shadowFactor
            local sunLight = sunColor * sunIntensityFactor
            sunLight = Color3.new(
                sunLight.R * materialColor.R,
                sunLight.G * materialColor.G,
                sunLight.B * materialColor.B
            )
            accumulatedColor += sunLight
            accumulatedColor = Color3.new(
                accumulatedColor.R ^ (1 / gammaCorrection),
                accumulatedColor.G ^ (1 / gammaCorrection),
                accumulatedColor.B ^ (1 / gammaCorrection)
            )
            accumulatedColor = Color3.new(
                math.clamp(accumulatedColor.R, 0, 1),
                math.clamp(accumulatedColor.G, 0, 1),
                math.clamp(accumulatedColor.B, 0, 1)
            )
            return accumulatedColor
        end
        realLightingParts = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Transparency < 1 then
                obj.Material = Enum.Material.SmoothPlastic
                table.insert(realLightingParts, obj)
                obj.CastShadow = false
            end
        end
        local function addCharacterParts(character)
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency < 1 then
                    table.insert(realLightingParts, part)
                    part.CastShadow = false
                end
            end
        end
        addCharacterParts(character)
        local function updateLighting()
            for _, part in ipairs(realLightingParts) do
                local color = computeLightingForPoint(part, part.Position)
                if color then part.Color = color end
            end
        end
        if realLightingConn then realLightingConn:Disconnect() end
        realLightingConn = RunService.RenderStepped:Connect(updateLighting)
        local partAddedConn = Workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") and descendant.Transparency < 1 then
                descendant.Material = Enum.Material.SmoothPlastic
                table.insert(realLightingParts, descendant)
                descendant.CastShadow = false
            end
        end)
        table.insert(runningConnections2, partAddedConn)
        local partRemovedConn = Workspace.DescendantRemoving:Connect(function(descendant)
            if descendant:IsA("BasePart") then
                for i, part in ipairs(realLightingParts) do
                    if part == descendant then
                        table.remove(realLightingParts, i)
                        break
                    end
                end
            end
        end)
        table.insert(runningConnections2, partRemovedConn)
        if realLightingCharConn then realLightingCharConn:Disconnect() end
        realLightingCharConn = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            addCharacterParts(character)
        end)
        realLightingEnabled = true
    else
        if realLightingConn then realLightingConn:Disconnect() realLightingConn = nil end
        if realLightingCharConn then realLightingCharConn:Disconnect() realLightingCharConn = nil end
        realLightingParts = {}
        clearEffects()
        restoreLighting()
        realLightingEnabled = false
    end
end)

local brightLightingEnabled = false
local brightClockConn = nil
lightingSection:Toggle("明亮光影", "", false, function(val)
    if val then
        saveLighting()
        clearEffects()
        Lighting.ClockTime = 12
        Lighting.GeographicLatitude = 0
        if brightClockConn then brightClockConn:Disconnect() end
        brightClockConn = RunService.Heartbeat:Connect(function()
            Lighting.ClockTime = 12
            Lighting.GeographicLatitude = 0
        end)
        table.insert(runningConnections2, brightClockConn)
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.3
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.new(0.8, 0.8, 0.8)
        Lighting.Ambient = Color3.new(0.6, 0.6, 0.6)
        Lighting.Technology = Enum.Technology.ShadowMap
        local sunRays = createEffect("SunRaysEffect", {Intensity = 0.2, Spread = 0.5})
        local bloom = createEffect("BloomEffect", {Intensity = 0.3, Size = 10})
        local atmosphere = createEffect("Atmosphere", {
            Density = 0.1,
            Offset = 0.5,
            Color = Color3.new(0.9, 0.9, 0.9),
            Decay = Color3.new(0.9, 0.9, 0.9),
            Glare = 0,
            Haze = 0
        })
        local colorCorrection = createEffect("ColorCorrectionEffect", {Saturation = -0.1, Contrast = 0.1})
        local blur = createEffect("BlurEffect", {Size = 1})
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then part.Reflectance = 0 end
        end
        local reflectConn = Workspace.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") then part.Reflectance = 0 end
        end)
        table.insert(runningConnections2, reflectConn)
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Material == Enum.Material.Glass then
                part.Transparency = 1
                part.Reflectance = 0
            end
        end
        local glassConn = Workspace.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") and part.Material == Enum.Material.Glass then
                part.Transparency = 1
                part.Reflectance = 0
            end
        end)
        table.insert(runningConnections2, glassConn)
        brightLightingEnabled = true
    else
        if brightClockConn then brightClockConn:Disconnect() brightClockConn = nil end
        clearEffects()
        restoreLighting()
        brightLightingEnabled = false
    end
end)

local proMaxEnabled = false
local proMaxConn = nil
lightingSection:Toggle("画质增强Pro Max", "", false, function(val)
    if val then
        saveLighting()
        clearEffects()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Sky") then child:Destroy() end
        end
        local colorCorrection = createEffect("ColorCorrectionEffect", {
            Contrast = 0.18,
            Brightness = 0.05,
            Saturation = 0.3,
            TintColor = Color3.fromRGB(255, 242, 230)
        })
        local bloom = createEffect("BloomEffect", {Intensity = 0.25, Size = 48, Threshold = 0.85})
        local sunRays = createEffect("SunRaysEffect", {Intensity = 0.25, Spread = 1.0})
        local atmosphere = createEffect("Atmosphere", {
            Density = 0.4,
            Offset = 0.25,
            Color = Color3.fromRGB(220, 220, 255),
            Decay = Color3.fromRGB(20, 25, 45),
            Glare = 0.15,
            Haze = 0.25
        })
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
        if proMaxConn then proMaxConn:Disconnect() end
        proMaxConn = RunService.RenderStepped:Connect(function()
            Lighting.ClockTime = Lighting.ClockTime + 0.0005
            local timeFactor = math.sin(Lighting.ClockTime * math.pi / 12)
            bloom.Intensity = 0.2 + timeFactor * 0.1
            sunRays.Intensity = 0.2 + timeFactor * 0.1
        end)
        table.insert(runningConnections2, proMaxConn)
        proMaxEnabled = true
    else
        if proMaxConn then proMaxConn:Disconnect() proMaxConn = nil end
        clearEffects()
        restoreLighting()
        proMaxEnabled = false
    end
end)

local duskLightingEnabled = false
local duskConn = nil
lightingSection:Toggle("固定黄昏光影", "", false, function(val)
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
        local colorCorrection = createEffect("ColorCorrectionEffect", {
            Contrast = 0.15,
            Brightness = 0.04,
            Saturation = 0.25,
            TintColor = Color3.fromRGB(255, 245, 235)
        })
        local bloom = createEffect("BloomEffect", {Intensity = 0.08, Size = 40, Threshold = 0.95})
        local sunRays = createEffect("SunRaysEffect", {Intensity = 0.22, Spread = 0.8})
        local dof = createEffect("DepthOfFieldEffect", {
            FarIntensity = 0.1,
            FocusDistance = 35,
            InFocusRadius = 22,
            NearIntensity = 0.3
        })
        local atmosphere = createEffect("Atmosphere", {
            Density = 0.25,
            Offset = 0.25,
            Color = Color3.fromRGB(180, 190, 210),
            Decay = Color3.fromRGB(35, 40, 50),
            Haze = 0.12
        })
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
        if duskConn then duskConn:Disconnect() end
        duskConn = RunService.RenderStepped:Connect(function()
            local time = os.time()
            local subtleChange = math.sin(time * 0.1) * 0.03
            Lighting.ClockTime = (time / 3600) % 24
            local targetBrightness = 3.2 + math.sin(Lighting.ClockTime * math.pi / 12) * 0.3
            Lighting.Brightness = math.clamp(targetBrightness, 2.8, 3.5)
            bloom.Intensity = 0.08 + subtleChange * 0.02
        end)
        table.insert(runningConnections2, duskConn)
        duskLightingEnabled = true
    else
        if duskConn then duskConn:Disconnect() duskConn = nil end
        clearEffects()
        restoreLighting()
        duskLightingEnabled = false
    end
end)

notify("Hygg UI", "加载完成", 2)

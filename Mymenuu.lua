
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ INITIALIZE STATE TRACKING ]] --
local Toggles = { Fly = false, Noclip = false, Aimbot = false, ESP = false, Tracers = false, KillAll = false, Music = false, Rainbow = false }
local FlySpeed, WalkSpeed = 50, 16
local BodyVel, BodyGyr
local CurrentRainbowColor = Color3.fromRGB(255, 0, 0)

-- Configure Universal Audio Track Asset
local BackgroundSound = SoundService:FindFirstChild("XenoBackgroundMusic") or Instance.new("Sound")
BackgroundSound.Name = "XenoBackgroundMusic"
BackgroundSound.SoundId = "rbxassetid://9045765634" 
BackgroundSound.Volume = 0.75
BackgroundSound.Looped = true
BackgroundSound.Parent = SoundService

-- [[ BYPASS PIPELINE: DRAW OVER CHARACTER HEAD ]] --
local function AttachBypassMenu()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Head = Character:WaitForChild("Head", 15)
    if not Head then return end
    
    -- Cleanup previous clones to completely patch re-execution or respawn bugs
    if Head:FindFirstChild("XenoBypassContainer") then Head.XenoBypassContainer:Destroy() end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "XenoBypassContainer"
    Billboard.Size = UDim2.new(0, 240, 0, 295)
    Billboard.Adornee = Head
    Billboard.AlwaysOnTop = true 
    Billboard.ExtentsOffset = Vector3.new(0, 3.5, 0) 
    Billboard.Parent = Head
    
    local MainBox = Instance.new("Frame")
    MainBox.Size = UDim2.new(1, 0, 1, 0)
    MainBox.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainBox.BorderSizePixel = 1
    MainBox.BorderColor3 = Color3.fromRGB(220, 0, 0) 
    MainBox.Parent = Billboard
    Instance.new("UICorner", MainBox).CornerRadius = UDim.new(0, 4)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 28)
    Title.BackgroundColor3 = Color3.fromRGB(25, 15, 15)
    Title.Text = "  idk Client (Xeno Bypass V2)"
    Title.TextColor3 = Color3.fromRGB(255, 50, 50)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 11
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainBox
    
    -- Top-Right Corner Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 28)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Parent = MainBox
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainBox.Visible = false
    end)
    
    local Scroller = Instance.new("ScrollingFrame")
    Scroller.Size = UDim2.new(1, -10, 1, -38)
    Scroller.Position = UDim2.new(0, 5, 0, 33)
    Scroller.BackgroundTransparency = 1
    Scroller.CanvasSize = UDim2.new(0, 0, 0, 390)
    Scroller.ScrollBarThickness = 2
    Scroller.Parent = MainBox
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = Scroller
    
    local function CreateMenuButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 11
        btn.Parent = Scroller
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function() pcall(callback, btn) end)
        return btn
    end
    
    -- [[ CORE ACTIONS BINDING PORT ]] --
    
    CreateMenuButton("Flight (WASD): OFF", function(btn)
        Toggles.Fly = not Toggles.Fly
        btn.Text = "Flight (WASD): " .. (Toggles.Fly and "ON" or "OFF")
        if not Toggles.Rainbow then btn.BackgroundColor3 = Toggles.Fly and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(28, 28, 32) end
        
        local Root = Character:FindFirstChild("HumanoidRootPart")
        if Toggles.Fly and Root then
            BodyVel = Instance.new("BodyVelocity", Root)
            BodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            BodyGyr = Instance.new("BodyGyro", Root)
            BodyGyr.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        else
            if BodyVel then BodyVel:Destroy() end
            if BodyGyr then BodyGyr:Destroy() end
            if Character:FindFirstChild("Humanoid") then Character.Humanoid.PlatformStand = false end
        end
    end)
    
    CreateMenuButton("Toggle Speed (100 / 16)", function(btn)
        if WalkSpeed == 16 then WalkSpeed = 100 else WalkSpeed = 16 end
        btn.Text = "Current Speed: " .. tostring(WalkSpeed)
        if not Toggles.Rainbow then btn.BackgroundColor3 = WalkSpeed == 100 and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(28, 28, 32) end
    end)
    
    CreateMenuButton("Noclip Hack: OFF", function(btn)
        Toggles.Noclip = not Toggles.Noclip
        btn.Text = "Noclip Hack: " .. (Toggles.Noclip and "ON" or "OFF")
        if not Toggles.Rainbow then btn.BackgroundColor3 = Toggles.Noclip and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(28, 28, 32) end
    end)
    
    CreateMenuButton("Aimbot Tracking: OFF", function(btn)
        Toggles.Aimbot = not Toggles.Aimbot
        btn.Text = "Aimbot Tracking: " .. (Toggles.Aimbot and "ON" or "OFF")
        if not Toggles.Rainbow then btn.BackgroundColor3 = Toggles.Aimbot and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(28, 28, 32) end
    end)
    
    CreateMenuButton("Wall ESP Visuals: OFF", function(btn)
        Toggles.ESP = not Toggles.ESP
        Toggles.Tracers = Toggles.ESP
        btn.Text = "Wall ESP Visuals: " .. (Toggles.ESP and "ON" or "OFF")
        if not Toggles.Rainbow then btn.BackgroundColor3 = Toggles.ESP and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(28, 28, 32) end
    end)
    
    CreateMenuButton("Teleport Kill Loop: OFF", function(btn)
        Toggles.KillAll = not Toggles.KillAll
        btn.Text = "Teleport Kill Loop: " .. (Toggles.KillAll and "ON" or "OFF")
        if not Toggles.Rainbow then btn.BackgroundColor3 = Toggles.KillAll and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(28, 28, 32) end
    end)
    
    CreateMenuButton("RAINBOW WORLD MODE: OFF", function(btn)
        Toggles.Rainbow = not Toggles.Rainbow
        btn.Text = "RAINBOW WORLD MODE: " .. (Toggles.Rainbow and "ON" or "OFF")
        if not Toggles.Rainbow then 
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
            Title.TextColor3 = Color3.fromRGB(255, 50, 50)
            CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
            MainBox.BorderColor3 = Color3.fromRGB(220, 0, 0)
            Lighting.Ambient = Color3.fromRGB(127,127,127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
        end
    end)
    
    CreateMenuButton("Play Audio Track: OFF", function(btn)
        Toggles.Music = not Toggles.Music
        btn.Text = "Play Audio Track: " .. (Toggles.Music and "ON" or "OFF")
        if not Toggles.Rainbow then btn.BackgroundColor3 = Toggles.Music and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(28, 28, 32) end
        if Toggles.Music then BackgroundSound:Play() else BackgroundSound:Stop() end
    end)
    
    CreateMenuButton("Execute Max FPS Boost", function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("Sky") then obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = false
            elseif obj:IsA("BasePart") and not Toggles.Rainbow then obj.Material = Enum.Material.SmoothPlastic end
        end
    end)
    
    CreateMenuButton("Server Hop", function()
        local HttpService = game:GetService("HttpService")
        local serversUrl = "https://roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(serversUrl)) end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end)
    
    -- [[ FIXED KEYBOARD TOGGLE LISTENERS ]] --
    local controlConn; controlConn = UIS.InputBegan:Connect(function(input, chat)
        if chat then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            if MainBox then MainBox.Visible = not MainBox.Visible end
        end
    end)
    
    -- Dynamic Engine Connections to handle Rainbow layout modifications
    local rainbowConn; rainbowConn = RunService.RenderStepped:Connect(function()
        if not MainBox or not MainBox.Parent then rainbowConn:Disconnect() return end
        if Toggles.Rainbow then
            MainBox.BorderColor3 = CurrentRainbowColor
            Title.TextColor3 = CurrentRainbowColor
            CloseBtn.TextColor3 = CurrentRainbowColor
            Lighting.Ambient = CurrentRainbowColor
            Lighting.OutdoorAmbient = CurrentRainbowColor
            -- Cycle background elements smoothly

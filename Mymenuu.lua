local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Folder for 3D Visuals (ESP Fix)
local VisualsFolder = workspace:FindFirstChild("Visuals") or Instance.new("Folder", workspace)
VisualsFolder.Name = "Visuals"

local Window = Rayfield:CreateWindow({
   Name = "my Menu V1.0",
   LoadingTitle = "Do people even read this...",
   ConfigurationSaving = { Enabled = false }
})

-- [[ STATE ]] --
local Toggles = { Fly = false, Noclip = false, Aimbot = false, ESP = false, Tracers = false, Disco = false }
local FlySpeed, WalkSpeed = 50, 16
local BodyVel, BodyGyr

-- [[ TAB: MOVEMENT ]] --
local MoveTab = Window:CreateTab("Movement", 4483362458)
MoveTab:CreateToggle({
    Name = "Flight (WASD)", 
    CurrentValue = false, 
    Callback = function(V) 
        Toggles.Fly = V 
        local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if V and Root then
            BodyVel = Instance.new("BodyVelocity", Root)
            BodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            BodyGyr = Instance.new("BodyGyro", Root)
            BodyGyr.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        else
            if BodyVel then BodyVel:Destroy() end
            if BodyGyr then BodyGyr:Destroy() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
})
MoveTab:CreateSlider({Name = "Fly Speed", Range = {10, 500}, Increment = 1, CurrentValue = 50, Callback = function(V) FlySpeed = V end})
MoveTab:CreateSlider({Name = "Walk Speed", Range = {16, 250}, Increment = 1, CurrentValue = 16, Callback = function(V) WalkSpeed = V end})
MoveTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(V) Toggles.Noclip = V end})

-- [[ TAB: COMBAT ]] --
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(V) Toggles.Aimbot = V end})
CombatTab:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(V) Toggles.ESP = V end})
CombatTab:CreateToggle({Name = "Tracers", CurrentValue = false, Callback = function(V) Toggles.Tracers = V end})

-- [[ TAB: VISUALS ]] --
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateToggle({Name = "Disco Sky", CurrentValue = false, Callback = function(V) Toggles.Disco = V end})
VisualTab:CreateButton({Name = "Reset Lighting", Callback = function() Toggles.Disco = false; Lighting.Ambient = Color3.fromRGB(127,127,127); Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127) end})

-- [[ TAB: GAMES ]] --
local GamesTab = Window:CreateTab("Games", 4483362458)

GamesTab:CreateButton({
    Name = "99 Nights in the Forest",
    Callback = function()
        Rayfield:Notify({
            Title = "Executing 99 Nights",
            Content = "Loading Voidware script...",
            Duration = 3,
            Image = 4483362458,
        })
        
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://files.vapevoidware.xyz/VapeVoidware/VW-Add/main/loader.lua", true))()
            end)
            if not success then
                warn("Failed to load 99 Nights script: " .. tostring(err))
            end
        end)
    end
})

GamesTab:CreateButton({
    Name = "Steal an Egg",
    Callback = function()
        Rayfield:Notify({
            Title = "Executing Steal an Egg",
            Content = "Loading ONhub script...",
            Duration = 3,
            Image = 4483362458,
        })
        
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/davizin713/ONhub/refs/heads/main/main.lua", true))()
            end)
            if not success then
                warn("Failed to load Steal an Egg script: " .. tostring(err))
            end
        end)
    end
})

-- [[ TAB: DISCORD ]] --
local DiscordTab = Window:CreateTab("Discord", 4483362458)
DiscordTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/ckHuejszg") 
        Rayfield:Notify({
            Title = "Link Copied!",
            Content = "The Discord invite has been copied to your clipboard. Paste it in your browser!",
            Duration = 5,
            Image = 4483362458,
        })
    end
})

--- [[ FIXED VISUAL ENGINE (ESP & TRACERS) ]] ---
local function CreateVisuals(plr)
    if plr == LocalPlayer then return end
    local function Apply(char)
        local root = char:WaitForChild("HumanoidRootPart", 10)
        if not root then return end
        
        local hl = Instance.new("Highlight", char)
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        
        local line = Instance.new("LineHandleAdornment", VisualsFolder)
        line.Thickness, line.AlwaysOnTop, line.Color3 = 2, true, Color3.fromRGB(255, 0, 0)

        local conn; conn = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent then line:Destroy(); conn:Disconnect(); return end
            hl.Enabled = Toggles.ESP
            if Toggles.Tracers and root then
                local _, OnScreen = Camera:WorldToViewportPoint(root.Position)
                if OnScreen then
                    line.Visible = true; line.Adornee = workspace.Terrain
                    local Start = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y).Origin
                    line.CFrame = CFrame.new(Start, root.Position); line.Length = (Start - root.Position).Magnitude
                else line.Visible = false end
            else line.Visible = false end
        end)
    end
    if plr.Character then Apply(plr.Character) end
    plr.CharacterAdded:Connect(Apply)
end

for _, p in pairs(Players:GetPlayers()) do CreateVisuals(p) end
Players.PlayerAdded:Connect(CreateVisuals)

--- [[ MOVEMENT & COMBAT ENGINE ]] ---
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("Humanoid") then return end
    Char.Humanoid.WalkSpeed = WalkSpeed

    if Toggles.Fly and BodyVel and BodyGyr then
        Char.Humanoid.PlatformStand = true
        local Dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + Camera.CFrame.RightVector end
        BodyVel.Velocity = Dir * FlySpeed
        BodyGyr.CFrame = Camera.CFrame
    end
    
    if Toggles.Aimbot then
        local Target, Dist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local Pos, OnScreen = Camera:WorldToViewportPoint(p.Character.PrimaryPart.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Mag < Dist then Target = p; Dist = Mag end
                end
            end
        end
        if Target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Character.PrimaryPart.Position), 0.2) end
    end
end)

-- Noclip and Disco Loops...
task.spawn(function()
    local hue = 0
    while task.wait(0.05) do
        if Toggles.Disco then
            hue = (hue + 0.01) % 1
            Lighting.Ambient = Color3.fromHSV(hue, 1, 1)
            Lighting.OutdoorAmbient = Color3.fromHSV(hue, 1, 1)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Toggles.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

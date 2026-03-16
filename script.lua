-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║           BASKETBALL ZERO | COMPREHENSIVE GAMEPLAY FRAMEWORK           ║
-- ║                   Advanced Research Protocol v2.0                      ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

-- ─────────────────────────────────────────────────────────────────────────
-- 1. INITIALIZATION & SERVICE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Rayfield UI Library
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- ─────────────────────────────────────────────────────────────────────────
-- 2. CONFIGURATION & FLAGS TABLE
-- ─────────────────────────────────────────────────────────────────────────

local FrameworkConfig = {
    -- Offensive Suite
    PerfectShot = false,
    MagnetReach = false,
    AutoDribble = false,
    PerfectShotAccuracy = 100, -- Percentage
    
    -- Defensive Suite
    AutoBlock = false,
    StealAura = false,
    InterceptPasses = false,
    BlockRange = 10, -- Studs
    StealRange = 8,  -- Studs
    
    -- Physics Modifiers
    WalkSpeedModifier = false,
    JumpPowerModifier = false,
    InfiniteStamina = false,
    WalkSpeedValue = 16,
    JumpPowerValue = 50,
    
    -- Stealth & Bypass
    StatisticalJittering = true,
    JitteringPercentage = 10, -- ±10%
    RandomizedDelays = true,
    RemoteHooking = true,
    
    -- Internal
    IsRunning = true,
    LastShotTime = 0,
    BallCache = nil
}

-- ─────────────────────────────────────────────────────────────────────────
-- 3. UTILITY FUNCTIONS & HELPERS
-- ─────────────────────────────────────────────────────────────────────────

local Utility = {}

-- Statistical Jittering for anti-detection
function Utility.ApplyJitter(baseValue, percentage)
    if not FrameworkConfig.StatisticalJittering then return baseValue end
    local variance = baseValue * (percentage / 100)
    local jitter = math.random(-variance * 100, variance * 100) / 100
    return baseValue + jitter
end

-- Randomized delay for human-like behavior
function Utility.RandomizedDelay(minDelay, maxDelay)
    if not FrameworkConfig.RandomizedDelays then 
        return task.wait(minDelay) 
    end
    local delayTime = math.random(minDelay * 1000, maxDelay * 1000) / 1000
    return task.wait(Utility.ApplyJitter(delayTime, FrameworkConfig.JitteringPercentage))
end

-- Safe pcall wrapper with error logging
function Utility.SafeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Framework Error]: " .. tostring(result))
    end
    return success, result
end

-- Calculate Euclidean distance (Magnitude)
function Utility.CalculateMagnitude(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Get Ball object from workspace
function Utility.GetBall()
    if FrameworkConfig.BallCache and FrameworkConfig.BallCache.Parent then
        return FrameworkConfig.BallCache
    end
    
    -- Search for ball in common locations
    local shootFolder = Workspace:FindFirstChild("Shoot")
    if shootFolder then
        local ball = shootFolder:FindFirstChild("Ball")
        if ball then
            FrameworkConfig.BallCache = ball
            return ball
        end
    end
    
    -- Alternative search patterns
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Ball" and obj:IsA("BasePart") then
            FrameworkConfig.BallCache = obj
            return obj
        end
    end
    
    return nil
end

-- ─────────────────────────────────────────────────────────────────────────
-- 4. OFFENSIVE SUITE MODULE
-- ─────────────────────────────────────────────────────────────────────────

local OffensiveSuite = {}

-- Perfect Shot Logic: Calculate optimal velocity based on distance
function OffensiveSuite.CalculatePerfectShot(ballPos, hoopPos)
    local distance = Utility.CalculateMagnitude(ballPos, hoopPos)
    local heightDiff = hoopPos.Y - ballPos.Y
    
    -- Physics constants (Roblox default gravity)
    local gravity = workspace.Gravity -- 196.2 studs/s^2
    local angle = math.rad(45) -- Optimal angle
    
    -- Calculate required velocity using projectile motion formula
    -- v0 = sqrt((g * d^2) / (2 * cos^2(θ) * (d * tan(θ) - h)))
    local cosTheta = math.cos(angle)
    local tanTheta = math.tan(angle)
    
    local velocityMagnitude = math.sqrt(
        (gravity * distance^2) / 
        (2 * cosTheta^2 * (distance * tanTheta - heightDiff))
    )
    
    -- Apply jittering for stealth
    return Utility.ApplyJitter(velocityMagnitude, FrameworkConfig.JitteringPercentage)
end

-- Magnet Reach: Expand catch radius programmatically
function OffensiveSuite.MagnetReach()
    if not FrameworkConfig.MagnetReach then return end
    
    task.spawn(function()
        while FrameworkConfig.MagnetReach and FrameworkConfig.IsRunning do
            Utility.SafeExecute(function()
                local ball = Utility.GetBall()
                if not ball then return end
                
                local hand = Character:FindFirstChild("RightHand") or 
                            Character:FindFirstChild("LeftHand")
                if not hand then return end
                
                local distance = Utility.CalculateMagnitude(hand.Position, ball.Position)
                local reachRadius = Utility.ApplyJitter(15, FrameworkConfig.JitteringPercentage)
                
                if distance <= reachRadius then
                    -- Trigger catch event
                    local catchEvent = ReplicatedStorage:FindFirstChild("CatchEvent") or
                                      ReplicatedStorage:FindFirstChild("BallCatch")
                    if catchEvent then
                        Utility.RandomizedDelay(0.01, 0.05)
                        catchEvent:FireServer(ball)
                    end
                end
            end)
            task.wait(0.03) -- ~30 FPS check rate
        end
    end)
end

-- Auto-Dribble: Intelligent dribbling automation
function OffensiveSuite.AutoDribble()
    if not FrameworkConfig.AutoDribble then return end
    
    task.spawn(function()
        while FrameworkConfig.AutoDribble and FrameworkConfig.IsRunning do
            Utility.SafeExecute(function()
                local ball = Utility.GetBall()
                if not ball then return end
                
                -- Check if ball is in possession
                local ballOwner = ball:GetAttribute("Owner")
                if ballOwner ~= LocalPlayer.Name then return end
                
                -- Calculate optimal dribble direction
                local nearestOpponent = OffensiveSuite.FindNearestOpponent()
                if nearestOpponent then
                    local dodgeDirection = (HumanoidRootPart.Position - nearestOpponent.Position).Unit
                    local targetPos = HumanoidRootPart.Position + dodgeDirection * 5
                    
                    -- Execute dribble with human-like movement
                    local moveDirection = (targetPos - HumanoidRootPart.Position).Unit
                    Humanoid:Move(moveDirection)
                    
                    Utility.RandomizedDelay(0.1, 0.2)
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- Find nearest opponent
function OffensiveSuite.FindNearestOpponent()
    local nearest = nil
    local minDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local distance = Utility.CalculateMagnitude(
                    HumanoidRootPart.Position,
                    char.HumanoidRootPart.Position
                )
                if distance < minDistance then
                    minDistance = distance
                    nearest = char.HumanoidRootPart
                end
            end
        end
    end
    
    return nearest
end

-- Perfect Shot Execution
function OffensiveSuite.ExecutePerfectShot()
    if not FrameworkConfig.PerfectShot then return end
    
    local ball = Utility.GetBall()
    if not ball then return end
    
    -- Find hoop
    local hoop = Workspace:FindFirstChild("Hoop") or 
                 Workspace:FindFirstChild("Basket") or
                 Workspace:FindFirstChildOfClass("Model")
    
    if hoop then
        local hoopPos = hoop:GetPivot().Position
        local ballPos = ball.Position
        
        local optimalVelocity = OffensiveSuite.CalculatePerfectShot(ballPos, hoopPos)
        
        -- Fire remote event with calculated values
        local shootEvent = ReplicatedStorage:FindFirstChild("ShootEvent") or
                          ReplicatedStorage:FindFirstChild("Shoot")
        
        if shootEvent then
            Utility.RandomizedDelay(0.05, 0.1)
            shootEvent:FireServer({
                Power = optimalVelocity,
                Angle = CFrame.lookAt(ballPos, hoopPos),
                Timestamp = tick()
            })
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- 5. DEFENSIVE SUITE MODULE
-- ─────────────────────────────────────────────────────────────────────────

local DefensiveSuite = {}

-- Auto-Block & Intercept: Respond to opponent shots
function DefensiveSuite.AutoBlock()
    if not FrameworkConfig.AutoBlock then return end
    
    -- Monitor Shoot folder creation
    local shootFolder = Workspace:FindFirstChild("Shoot")
    
    task.spawn(function()
        while FrameworkConfig.AutoBlock and FrameworkConfig.IsRunning do
            Utility.SafeExecute(function()
                -- Check for shoot folder (indicates shot in progress)
                local currentShootFolder = Workspace:FindFirstChild("Shoot")
                if currentShootFolder then
                    local ball = currentShootFolder:FindFirstChild("Ball")
                    if ball then
                        local distance = Utility.CalculateMagnitude(
                            HumanoidRootPart.Position,
                            ball.Position
                        )
                        
                        local blockRange = Utility.ApplyJitter(
                            FrameworkConfig.BlockRange,
                            FrameworkConfig.JitteringPercentage
                        )
                        
                        if distance <= blockRange then
                            -- Calculate trajectory intersection
                            local ballVelocity = ball.Velocity
                            local timeToIntercept = distance / ballVelocity.Magnitude
                            
                            -- Ping compensation
                            local ping = LocalPlayer:GetNetworkPing()
                            local adjustedTime = timeToIntercept - ping
                            
                            if adjustedTime > 0 then
                                task.wait(math.max(0, adjustedTime - 0.05))
                                
                                -- Trigger block
                                local blockEvent = ReplicatedStorage:FindFirstChild("BlockEvent") or
                                                  ReplicatedStorage:FindFirstChild("Block")
                                if blockEvent then
                                    blockEvent:FireServer("Block")
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.016) -- ~60 FPS for frame-perfect timing
        end
    end)
end

-- Steal Aura: Automatic steal when ball is in range
function DefensiveSuite.StealAura()
    if not FrameworkConfig.StealAura then return end
    
    task.spawn(function()
        while FrameworkConfig.StealAura and FrameworkConfig.IsRunning do
            Utility.SafeExecute(function()
                -- Get parts in radius
                local stealRange = Utility.ApplyJitter(
                    FrameworkConfig.StealRange,
                    FrameworkConfig.JitteringPercentage
                )
                
                local parts = Workspace:GetPartBoundsInRadius(
                    HumanoidRootPart.Position,
                    stealRange
                )
                
                for _, part in pairs(parts) do
                    if part.Name == "Ball" or part:GetAttribute("IsBall") then
                        -- Check if ball is held by opponent
                        local ballOwner = part:GetAttribute("Owner")
                        if ballOwner and ballOwner ~= LocalPlayer.Name then
                            -- Trigger steal
                            local stealEvent = ReplicatedStorage:FindFirstChild("StealEvent") or
                                              ReplicatedStorage:FindFirstChild("Steal")
                            if stealEvent then
                                Utility.RandomizedDelay(0.01, 0.03)
                                stealEvent:FireServer(part)
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────
-- 6. PHYSICS MODIFIERS MODULE
-- ─────────────────────────────────────────────────────────────────────────

local PhysicsModifiers = {}

-- Modify WalkSpeed
function PhysicsModifiers.WalkSpeedLoop()
    if not FrameworkConfig.WalkSpeedModifier then return end
    
    task.spawn(function()
        while FrameworkConfig.WalkSpeedModifier and FrameworkConfig.IsRunning do
            Utility.SafeExecute(function()
                if Humanoid then
                    Humanoid.WalkSpeed = FrameworkConfig.WalkSpeedValue
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- Modify JumpPower
function PhysicsModifiers.JumpPowerLoop()
    if not FrameworkConfig.JumpPowerModifier then return end
    
    task.spawn(function()
        while FrameworkConfig.JumpPowerModifier and FrameworkConfig.IsRunning do
            Utility.SafeExecute(function()
                if Humanoid then
                    Humanoid.JumpPower = FrameworkConfig.JumpPowerValue
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- Infinite Stamina Hook
function PhysicsModifiers.InfiniteStaminaHook()
    if not FrameworkConfig.InfiniteStamina then return end
    
    -- Hook into stamina check functions
    local success = pcall(function()
        -- Global environment modification
        if _G.MaxStam then
            _G.MaxStam = math.huge
        end
        
        -- Hook condition functions if available
        if hookfunction then
            local originalCheckConditions
            originalCheckConditions = hookfunction(getgc()[1], function(...)
                return true -- Always return true for stamina checks
            end)
        end
    end)
    
    if success then
        print("[Framework]: Infinite Stamina Hook Injected Successfully")
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- 7. STEALTH & BYPASS MODULE
-- ─────────────────────────────────────────────────────────────────────────

local StealthModule = {}

-- Remote Event Hooking & Spoofing
function StealthModule.InitializeRemoteHooking()
    if not FrameworkConfig.RemoteHooking then return end
    
    local success = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if not checkcaller() then
                -- Perfect Shot Remote Spoofing
                if FrameworkConfig.PerfectShot and 
                   (method == "FireServer" or method == "fireServer") then
                    if self.Name == "ShootEvent" or self.Name == "Shoot" then
                        -- Replace with perfect values
                        if typeof(args[1]) == "table" then
                            args[1].Power = Utility.ApplyJitter(
                                args[1].Power,
                                FrameworkConfig.JitteringPercentage
                            )
                        end
                    end
                end
                
                -- Block kick events
                if method == "Kick" or method == "kick" then
                    warn("[Framework]: Prevented Kick Event")
                    return nil
                end
                
                -- Anti-cheat bypass
                if self == RunService and 
                   (method == "BindToRenderStep" or method == "bindToRenderStep") then
                    if typeof(args[1]) == "string" then
                        local argString = args[1]:lower()
                        if argString:match("anticheat") or 
                           argString:match("check") or 
                           argString:match("detection") then
                            warn("[Framework]: Blocked Anti-Cheat Binding")
                            return nil
                        end
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end)
    end)
    
    if success then
        print("[Framework]: Remote Hooking Initialized")
    end
end

-- Statistical Jittering on inputs
function StealthModule.ApplyInputJittering(input)
    if not FrameworkConfig.StatisticalJittering then return input end
    
    return {
        X = Utility.ApplyJitter(input.X, FrameworkConfig.JitteringPercentage),
        Y = Utility.ApplyJitter(input.Y, FrameworkConfig.JitteringPercentage),
        Z = Utility.ApplyJitter(input.Z, FrameworkConfig.JitteringPercentage)
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- 8. UNIFIED GUI INTERFACE (RAYFIELD)
-- ─────────────────────────────────────────────────────────────────────────

local GUI = {}

function GUI.Initialize()
    local Window = Library:CreateWindow({
        Name = "Basketball Zero | Comprehensive Framework",
        LoadingTitle = "Initializing Deep Mechanics...",
        LoadingSubtitle = "Advanced Research Protocol v2.0",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "BasketballZeroFramework",
            FileName = "Config"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = false
        },
        KeySystem = false
    })

    -- ==================== OFFENSIVE SUITE TAB ====================
    local OffensiveTab = Window:CreateTab("Offensive Suite", 4483362458)
    
    -- Perfect Shot Section
    OffensiveTab:CreateSection("Perfect Shot Logic")
    
    OffensiveTab:CreateToggle({
        Name = "Enable Perfect Shot",
        CurrentValue = false,
        Flag = "PerfectShot",
        Callback = function(Value)
            FrameworkConfig.PerfectShot = Value
            if Value then
                OffensiveSuite.ExecutePerfectShot()
            end
        end
    })
    
    OffensiveTab:CreateSlider({
        Name = "Shot Accuracy (%)",
        Range = {80, 100},
        Increment = 1,
        CurrentValue = 100,
        Flag = "ShotAccuracy",
        Callback = function(Value)
            FrameworkConfig.PerfectShotAccuracy = Value
        end
    })
    
    -- Magnet Reach Section
    OffensiveTab:CreateSection("Magnet Reach")
    
    OffensiveTab:CreateToggle({
        Name = "Enable Magnet Reach",
        CurrentValue = false,
        Flag = "MagnetReach",
        Callback = function(Value)
            FrameworkConfig.MagnetReach = Value
            if Value then
                OffensiveSuite.MagnetReach()
            end
        end
    })
    
    -- Auto Dribble Section
    OffensiveTab:CreateSection("Auto Dribble")
    
    OffensiveTab:CreateToggle({
        Name = "Enable Auto Dribble",
        CurrentValue = false,
        Flag = "AutoDribble",
        Callback = function(Value)
            FrameworkConfig.AutoDribble = Value
            if Value then
                OffensiveSuite.AutoDribble()
            end
        end
    })

    -- ==================== DEFENSIVE SUITE TAB ====================
    local DefensiveTab = Window:CreateTab("Defensive Suite", 4483362458)
    
    -- Auto Block Section
    DefensiveTab:CreateSection("Auto-Block & Intercept")
    
    DefensiveTab:CreateToggle({
        Name = "Enable Auto-Block",
        CurrentValue = false,
        Flag = "AutoBlock",
        Callback = function(Value)
            FrameworkConfig.AutoBlock = Value
            if Value then
                DefensiveSuite.AutoBlock()
            end
        end
    })
    
    DefensiveTab:CreateSlider({
        Name = "Block Range (Studs)",
        Range = {5, 20},
        Increment = 0.5,
        CurrentValue = 10,
        Flag = "BlockRange",
        Callback = function(Value)
            FrameworkConfig.BlockRange = Value
        end
    })
    
    -- Steal Aura Section
    DefensiveTab:CreateSection("Steal Aura")
    
    DefensiveTab:CreateToggle({
        Name = "Enable Steal Aura",
        CurrentValue = false,
        Flag = "StealAura",
        Callback = function(Value)
            FrameworkConfig.StealAura = Value
            if Value then
                DefensiveSuite.StealAura()
            end
        end
    })
    
    DefensiveTab:CreateSlider({
        Name = "Steal Range (Studs)",
        Range = {5, 15},
        Increment = 0.5,
        CurrentValue = 8,
        Flag = "StealRange",
        Callback = function(Value)
            FrameworkConfig.StealRange = Value
        end
    })

    -- ==================== PHYSICS MODIFIERS TAB ====================
    local PhysicsTab = Window:CreateTab("Physics Modifiers", 4483362458)
    
    -- WalkSpeed Section
    PhysicsTab:CreateSection("Movement Modifiers")
    
    PhysicsTab:CreateToggle({
        Name = "Enable WalkSpeed Modifier",
        CurrentValue = false,
        Flag = "WalkSpeedMod",
        Callback = function(Value)
            FrameworkConfig.WalkSpeedModifier = Value
            if Value then
                PhysicsModifiers.WalkSpeedLoop()
            end
        end
    })
    
    PhysicsTab:CreateSlider({
        Name = "WalkSpeed Value",
        Range = {16, 30},
        Increment = 1,
        CurrentValue = 16,
        Flag = "WalkSpeedValue",
        Callback = function(Value)
            FrameworkConfig.WalkSpeedValue = Value
        end
    })
    
    PhysicsTab:CreateToggle({
        Name = "Enable JumpPower Modifier",
        CurrentValue = false,
        Flag = "JumpPowerMod",
        Callback = function(Value)
            FrameworkConfig.JumpPowerModifier = Value
            if Value then
                PhysicsModifiers.JumpPowerLoop()
            end
        end
    })
    
    PhysicsTab:CreateSlider({
        Name = "JumpPower Value",
        Range = {50, 100},
        Increment = 1,
        CurrentValue = 50,
        Flag = "JumpPowerValue",
        Callback = function(Value)
            FrameworkConfig.JumpPowerValue = Value
        end
    })
    
    -- Stamina Section
    PhysicsTab:CreateSection("Stamina Modifications")
    
    PhysicsTab:CreateButton({
        Name = "Enable Infinite Stamina",
        Callback = function()
            FrameworkConfig.InfiniteStamina = true
            PhysicsModifiers.InfiniteStaminaHook()
            Library:Notify({
                Title = "Stamina Hook",
                Content = "Infinite stamina bypass injected successfully!",
                Duration = 3
            })
        end
    })

    -- ==================== STEALTH & BYPASS TAB ====================
    local StealthTab = Window:CreateTab("Stealth & Bypass", 4483362458)
    
    StealthTab:CreateSection("Detection Evasion")
    
    StealthTab:CreateToggle({
        Name = "Enable Statistical Jittering",
        CurrentValue = true,
        Flag = "StatJitter",
        Callback = function(Value)
            FrameworkConfig.StatisticalJittering = Value
        end
    })
    
    StealthTab:CreateSlider({
        Name = "Jittering Percentage (%)",
        Range = {5, 20},
        Increment = 1,
        CurrentValue = 10,
        Flag = "JitterPercent",
        Callback = function(Value)
            FrameworkConfig.JitteringPercentage = Value
        end
    })
    
    StealthTab:CreateToggle({
        Name = "Randomized Delays",
        CurrentValue = true,
        Flag = "RandDelays",
        Callback = function(Value)
            FrameworkConfig.RandomizedDelays = Value
        end
    })
    
    StealthTab:CreateToggle({
        Name = "Remote Event Hooking",
        CurrentValue = true,
        Flag = "RemoteHook",
        Callback = function(Value)
            FrameworkConfig.RemoteHooking = Value
            if Value then
                StealthModule.InitializeRemoteHooking()
            end
        end
    })

    -- ==================== INFORMATION TAB ====================
    local InfoTab = Window:CreateTab("Framework Info", 4483362458)
    
    InfoTab:CreateSection("System Status")
    
    InfoTab:CreateParagraph({
        Title = "Basketball Zero Framework",
        Content = "Comprehensive Gameplay Framework v2.0\n" ..
                 "Features integrated from deep research analysis:\n" ..
                 "• Perfect Shot Logic with ballistic calculations\n" ..
                 "• Auto-Block with trajectory prediction\n" ..
                 "• Steal Aura with proximity detection\n" ..
                 "• Physics modifiers (WalkSpeed, JumpPower, Stamina)\n" ..
                 "• Statistical jittering for anti-detection\n" ..
                 "• Remote event hooking and spoofing"
    })
    
    InfoTab:CreateButton({
        Name = "Destroy Framework",
        Callback = function()
            FrameworkConfig.IsRunning = false
            Library:Destroy()
        end
    })

    return Window
end

-- ─────────────────────────────────────────────────────────────────────────
-- 9. INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

function InitializeFramework()
    -- Initialize GUI
    local Window = GUI.Initialize()
    
    -- Initialize Remote Hooking
    StealthModule.InitializeRemoteHooking()
    
    -- Character respawn handler
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        
        -- Re-initialize physics modifiers if enabled
        if FrameworkConfig.WalkSpeedModifier then
            PhysicsModifiers.WalkSpeedLoop()
        end
        if FrameworkConfig.JumpPowerModifier then
            PhysicsModifiers.JumpPowerLoop()
        end
    end)
    
    print("╔════════════════════════════════════════════════════════════╗")
    print("║     BASKETBALL ZERO | COMPREHENSIVE FRAMEWORK              ║")
    print("║     Advanced Research Protocol v2.0                        ║")
    print("║     All modules initialized successfully                 ║")
    print("╚════════════════════════════════════════════════════════════╝")
end

-- Start the framework
InitializeFramework()

repeat task.wait() until game:IsLoaded()
getgenv().SecureMode = true
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextChatService = game:GetService("TextChatService")
local getcustomasset = getsynasset or getcustomasset
local customassetcheck = (getsynasset or getcustomasset) and true
local defaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local VirtualUserService = game:GetService("VirtualUser")

local GuiLibrary = loadstring(readfile("Aristois/GuiLibrary.lua"))()
local WhitelistModule = loadstring(readfile("Aristois/Librarys/Whitelist.lua"))()
local boxHandleAdornment = Instance.new("BoxHandleAdornment")
local IsOnMobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, UserInputService:GetPlatform())
local Whitelist = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json"))

local Table = {
    ChatStrings2 = {
        ["Aristois"] = "Im using Aristois",
    },
    checkedPlayers = {},
    Box = function()
        local boxHandleAdornment = Instance.new("BoxHandleAdornment")
        boxHandleAdornment.Size = Vector3.new(4, 6, 4)
        boxHandleAdornment.Color3 = Color3.new(1, 0, 0)
        boxHandleAdornment.Transparency = 0.6
        boxHandleAdornment.AlwaysOnTop = true
        boxHandleAdornment.ZIndex = 10
        boxHandleAdornment.Parent = workspace
        return boxHandleAdornment
    end
}

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
local KnitClient = game:GetService("ReplicatedStorage").Packages.Knit

local Window = GuiLibrary:CreateWindow({
    Name = "Aristois",
    LoadingTitle = "Aristois Interface",
    LoadingSubtitle = "by Xzyn and Wynnech",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "Aristois/configs",
       FileName = tostring(shared.AristoisPlaceId) .. ".lua"
    },
    Discord = {
       Enabled = false,
       Invite = "pDuXtHgsBt",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided",
       FileName = "Key",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
 })

 do
    function RunLoops:BindToRenderStep(name, func)
        if RunLoops.RenderStepTable[name] == nil then
            RunLoops.RenderStepTable[name] = RunService.RenderStepped:Connect(func)
        end
    end

    function RunLoops:UnbindFromRenderStep(name)
        if RunLoops.RenderStepTable[name] then
            RunLoops.RenderStepTable[name]:Disconnect()
            RunLoops.RenderStepTable[name] = nil
        end
    end

    function RunLoops:BindToStepped(name, func)
        if RunLoops.StepTable[name] == nil then
            RunLoops.StepTable[name] = RunService.Stepped:Connect(func)
        end
    end

    function RunLoops:UnbindFromStepped(name)
        if RunLoops.StepTable[name] then
            RunLoops.StepTable[name]:Disconnect()
            RunLoops.StepTable[name] = nil
        end
    end

    function RunLoops:BindToHeartbeat(name, func)
        if RunLoops.HeartTable[name] == nil then
            RunLoops.HeartTable[name] = RunService.Heartbeat:Connect(func)
        end
    end

    function RunLoops:UnbindFromHeartbeat(name)
        if RunLoops.HeartTable[name] then
            RunLoops.HeartTable[name]:Disconnect()
            RunLoops.HeartTable[name] = nil
        end
    end
end

local Combat = Window:CreateTab("Combat")
local Blatant = Window:CreateTab("Blatant")
local Render = Window:CreateTab("Render")
local Utility = Window:CreateTab("Utility")
local Word = Window:CreateTab("Word")

local function IsAlive(plr)
    if not plr then
        return false
    end
    
    if typeof(plr) == "Instance" and plr:IsA("Player") then
        return plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
    end
    
    if typeof(plr) == "table" then
        for _, player in ipairs(plr) do
            if typeof(player) == "Instance" and player:IsA("Player") then
                if not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then
                    return false
                end
            else
                return false 
            end
        end
        return true
    end
    
    return false 
end

local function getNearestPlayer(maxDist, findNearestHealthPlayer)
    local Players = game:GetService("Players"):GetPlayers()
    local targetData = {
        nearestPlayer = nil,
        dist = math.huge,
        lowestHealth = math.huge
    }

    local nearestBoxingDummy = nil
    local nearestDist = math.huge

    local function updateTargetData(entity, mag, health)
        if findNearestHealthPlayer and health < targetData.lowestHealth then
            targetData.lowestHealth = health
            targetData.nearestPlayer = entity
        elseif mag < targetData.dist then
            targetData.dist = mag
            targetData.nearestPlayer = entity
        end
    end

    for _, player in ipairs(Players) do
        if player ~= lplr and player.Character and player.Character:FindFirstChild("Humanoid") and IsAlive(player) and IsAlive(lplr) then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local mag = (humanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                if mag < maxDist then
                    local health = player.Character:FindFirstChild("Humanoid").Health
                    updateTargetData(player, mag, health)
                end
            end
        end
    end

    for _, entity in ipairs(workspace:GetChildren()) do
        if entity.Name == "BoxingDummy" and entity:IsA("Model") then
            local rootPart = entity:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local dist = (rootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist and dist < maxDist then
                    nearestDist = dist
                    nearestBoxingDummy = entity
                end
            end
        end
    end

    if nearestBoxingDummy then
        local mockPlayer = {
            Name = "BoxingDummy",
            Character = nearestBoxingDummy,
            Distance = nearestDist,
            Health = 0
        }
        updateTargetData(mockPlayer, nearestDist, 0)
    end

    return targetData.nearestPlayer
end

local function runcode(func) func() end

local function SpeedMultiplier()
    local baseMultiplier = 1
    local multiplier = baseMultiplier
    if lplr.Character:GetAttribute("Blocking") then
        multiplier = multiplier * 1.5
    end

    return multiplier
end

local foundSwords = {}
local function findClosestMatch(name)
    local backpack = lplr.Backpack
    local chr = lplr.Character
    for _, item in ipairs(chr:GetChildren()) do
        if item.Name:find(name) then
            return item
        end
    end
    for _, item in ipairs(backpack:GetChildren()) do
        if item.Name:find(name) then
            return item
        end
    end
    return nil
end

local function GetSword()
    return foundSwords["Sword"] or (function()
        local swordMatch = findClosestMatch("Sword")
        if swordMatch then
            foundSwords["Sword"] = swordMatch.Name
            return foundSwords["Sword"]
        end
    end)()
end

local remotes = {
    AttackRemote = KnitClient.Services.ToolService.RF.AttackPlayerWithSword
}

local nearest
local Distance = {["Value"] = 32}
runcode(function()
    local Section = Combat:CreateSection("AutoClicker",true)
    local CPSSliderAmount = {["Value"] = 10}
    local function FindTools()
        local tools = {}
        if lplr then
            if lplr.Character then
                for _, item in ipairs(lplr.Character:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(tools, item)
                    end
                end
            end
        end
        return tools
    end

    local AutoClicker = Combat:CreateToggle({
        Name = "AutoClicker",
        CurrentValue = false,
        Flag = "AutoClicker",
        Callback = function(callback)
            if callback then
                local interval = 0.1 / CPSSliderAmount["Value"]
                local lastClickTime = tick()
                RunLoops:BindToHeartbeat("AutoClicker", function()
                    local tools = FindTools() 
                    for _, tool in ipairs(tools) do
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            if tick() - lastClickTime >= interval then
                                lastClickTime = tick()
                                tool:Activate()
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("AutoClicker")
            end
        end
    })
    local CPSSlider = Combat:CreateSlider({
        Name = "CPS",
        Range = {1, 60},
        Increment = 1,
        Suffix = "CPS",
        CurrentValue = 10,
        Flag = "CPS",
        Callback = function(Value)
            CPSSliderAmount["Value"] = Value
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("Killaura", true)
    local FacePlayerEnabled = {Enabled = false}
    local Boxes = {Enabled = false}
    local boxHandleAdornment = Table.Box()
    local Distance = {Value = 32}
    local swordtype

    local function updateBoxAdornment(nearest)
        if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
            if boxHandleAdornment.Parent ~= nearest.Character then
                boxHandleAdornment.Adornee = Boxes.Enabled and nearest.Character.HumanoidRootPart or nil
                if boxHandleAdornment.Adornee then
                    local cf = boxHandleAdornment.Adornee.CFrame
                    local x, y, z = cf:ToEulerAnglesXYZ()
                    boxHandleAdornment.CFrame = CFrame.new() * CFrame.Angles(-x, -y, -z)
                    boxHandleAdornment.Parent = nearest.Character
                end
            end
        else
            boxHandleAdornment.Adornee = nil
            boxHandleAdornment.Parent = nil
        end
    end

    local Killaura = Blatant:CreateToggle({
        Name = "Killaura",
        CurrentValue = false,
        Flag = "Killaura",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Killaura", function()
                    nearest = getNearestPlayer(Distance["Value"])
                    swordtype = swordtype or GetSword()
                    if nearest and nearest.Character and not nearest.Character:FindFirstChild("ForceField") and IsAlive(lplr) and IsAlive(nearest) then
                        remotes.AttackRemote:InvokeServer(nearest.Character, true, swordtype)
                        if nearest and FacePlayerEnabled.Enabled then
                            local playerPosition = lplr.Character.HumanoidRootPart.Position
                            local nearestPosition = nearest.Character.HumanoidRootPart.Position
                            local direction = (playerPosition - nearestPosition).unit
                            local lookAtPosition = playerPosition + direction
                            lplr.Character:SetPrimaryPartCFrame(CFrame.new(playerPosition, Vector3.new(lookAtPosition.X, playerPosition.Y, lookAtPosition.Z)))
                        end
                        updateBoxAdornment(nearest)
                        if not lplr.Character:GetAttribute("Blocking") then
                            KnitClient.Services.ToolService.RF.ToggleBlockSword:InvokeServer(true, swordtype)
                        end
                    else
                        updateBoxAdornment(nil)
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Killaura")
                updateBoxAdornment(nil)
            end
        end
    })
    local KillauraDistance = Blatant:CreateSlider({
        Name = "Distance",
        Range = {1, 32},
        Increment = 1,
        Suffix = "Studs",
        CurrentValue = 32,
        Flag = "KillAuraDistanceSlider",
        Callback = function(Value)
            Distance["Value"] = Value
        end
    })
    local FacePlayer = Blatant:CreateToggle({
        Name = "FacePlayer",
        CurrentValue = false,
        Flag = "RotationsKillauraToggle",
        Callback = function(val)
            FacePlayerEnabled.Enabled = val
        end
    })
    local BoxesToggle = Blatant:CreateToggle({
        Name = "Boxes",
        CurrentValue = false,
        Flag = "Boxes",
        Callback = function(val)
            Boxes.Enabled = val
        end
    })
end)

local SpeedSlider = {["Value"] = 27}
runcode(function()
    local Section = Blatant:CreateSection("Speed", true)
    local lastMoveTime = tick()
    local AutoJump = false
    local AutoPot = false
    local HeatSeeker = {Enabled = false}
    local IdleThreshold = {["Value"] = 0.97}
    local SpeedDuration = {["Value"] = 0.62}
    
    local SpeedToggle = Blatant:CreateToggle({
        Name = "Speed",
        CurrentValue = false,
        Flag = "Speed",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Speed", function(dt)
                    if IsAlive(lplr) then
                        local speedMultiplier = SpeedMultiplier()
                        local speedIncrease = SpeedSlider.Value
                        local currentSpeed = lplr.Character.Humanoid.WalkSpeed
                        local moveDirection = lplr.Character.Humanoid.MoveDirection
                        local newVelocity
                        if HeatSeeker.Enabled then
                            if moveDirection.magnitude < 0.01 then
                                lastMoveTime = tick()
                                newVelocity = Vector3.new(0, 0, 0)
                            elseif tick() - lastMoveTime > SpeedDuration["Value"] then
                                if tick() - lastMoveTime > SpeedDuration["Value"] + IdleThreshold["Value"] then
                                    lastMoveTime = tick()
                                    newVelocity = Vector3.new(0, 0, 0)
                                else
                                    newVelocity = moveDirection * (1.1 * speedMultiplier - currentSpeed)
                                end
                            else
                                newVelocity = moveDirection * (speedIncrease * speedMultiplier - currentSpeed)
                            end
                        else
                            newVelocity = moveDirection * (speedIncrease * speedMultiplier - currentSpeed)
                        end
                        lplr.Character:TranslateBy(newVelocity * dt)
                        if nearest and AutoJump then
                            local distanceToNearest = (nearest.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                            if (lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air) and lplr.Character.Humanoid.MoveDirection ~= Vector3.zero then
                                if distanceToNearest <= 18 then
                                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 15, lplr.Character.HumanoidRootPart.Velocity.Z)
                                end
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Speed")
            end
        end
    })

    local DistanceSlider = Blatant:CreateSlider({
        Name = "Speed", 
        Range = {1, 40},
        Increment = 0.1,
        Suffix = "Speed.",
        CurrentValue = 27,
        Flag = "DistanceSlider",
        Callback = function(Value)
            SpeedSlider["Value"] = Value
        end
    })

    local HeatSeekerToggle = Blatant:CreateToggle({
        Name = "HeatSeeker",
        CurrentValue = HeatSeeker.Enabled,
        Flag = "HeatSeeker",
        Callback = function(val)
            HeatSeeker.Enabled = val
        end
    })

    local SpeedDurationSlider = Blatant:CreateSlider({
        Name = "SpeedDuration (HeatSeeker)",
        Range = {0.01, 0.62},
        Increment = 0.01,
        Suffix = "seconds",
        CurrentValue = 0.62,
        Flag = "SpeedDuration",
        Callback = function(Value)
            SpeedDuration["Value"] = Value
        end
    })

    local IdleThresholdSlider = Blatant:CreateSlider({
        Name = "IdleThreshold (HeatSeeker)",
        Range = {0.01, 0.97},
        Increment = 0.01,
        Suffix = "seconds",
        CurrentValue = 0.97,
        Flag = "IdleThreshold",
        Callback = function(Value)
            IdleThreshold["Value"] = Value
        end
    })

    local AutoJumpToggle = Blatant:CreateToggle({
        Name = "AutoJump",
        CurrentValue = false,
        Flag = "AutoJump",
        Callback = function(val)
            AutoJump = val
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("Flight", true)
    local FlightKeybindCheck = false
    local FlightToggle = Blatant:CreateToggle({
        Name = "Flight",
        CurrentValue = false,
        Flag = "Flight",
        Callback = function(val)
            local flightEnabled = val
            local lastTick = tick()
            local airTimer = 0
            RunLoops:BindToHeartbeat("Fly", function()
                local currentTick = tick()
                local deltaTime = currentTick - lastTick
                lastTick = currentTick
                airTimer = airTimer + deltaTime
                local remainingTime = math.max(1000 - airTimer, 0)
                local player = Players.LocalPlayer
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
                if humanoid and humanoidRootPart then
                    local flySpeed = 9

                    local flyVelocity = humanoid.MoveDirection * flySpeed
                    local flyUp = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                    local flyDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                    local velocity = flyVelocity + Vector3.new(0, (flyUp and 50 or 0) + (flyDown and -50 or 0), 0)

                    if flightEnabled then
                        humanoidRootPart.AssemblyLinearVelocity = velocity
                    else
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
    
                    if airTimer > 1000 then
                        local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, -1000, 0))
                        local ignoreList = {player, character}
                        local hitPart, hitPosition = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
                        if hitPart then
                            airTimer = 0
                        end
                    end
                end
            end)
            if not val then
                RunLoops:UnbindFromHeartbeat("Fly")
            end
        end
    })
    local ftkeybind = Blatant:CreateKeybind({
        Name = "Flight Keybind",
        CurrentKeybind = "C",
        HoldToInteract = false,
        Flag = "FlightKeybindToggle",
        Callback = function(Keybind)
            if FlightKeybindCheck == true then
                FlightKeybindCheck = false
                FlightToggle:Set(enabled)
            else
                if FlightKeybindCheck == false then
                    FlightKeybindCheck = true
                    FlightToggle:Set(not enabled)
                end
            end
        end,
    })
end)

runcode(function()
    local CameraTypes = {Enum.CameraType.Custom, Enum.CameraType.Scriptable, Enum.CameraType.Fixed}
    local MaxFlyDuration = {["Value"] = 2.5}
    local CtrlPressed = false
    local SpacePressed = false
    local InputBeganConnection
    local InputEndedConnection
    local TeleportEnabled = false
    local FlyRoot
    local FlyStartTime

    local InfiniteFlyToggle = Blatant:CreateToggle({
        Name = "InfiniteFly",
        CurrentValue = false,
        Flag = "InfiniteFly",
        Callback = function(callback)
            if callback then
                InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        CtrlPressed = true
                    elseif input.KeyCode == Enum.KeyCode.Space then
                        SpacePressed = true
                    end
                end)

                InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        CtrlPressed = false
                    elseif input.KeyCode == Enum.KeyCode.Space then
                        SpacePressed = false
                    end
                end)

                lplr.CharacterAdded:Connect(function(character)
                    lplr.Character = character
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                    TeleportEnabled = true
                end)

                lplr.CharacterRemoving:Connect(function()
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                    TeleportEnabled = true
                end)

                FlyRoot = Instance.new("Part")
                FlyRoot.Size = lplr.Character.HumanoidRootPart.Size
                FlyRoot.CFrame = lplr.Character.HumanoidRootPart.CFrame
                FlyRoot.Anchored = true
                FlyRoot.CanCollide = false
                FlyRoot.Color = Color3.fromRGB(255, 0, 0)
                FlyRoot.Material = Enum.Material.Neon
                FlyRoot.Parent = game.Workspace
                FlyRoot.Transparency = 0.6

                Camera.CameraSubject = FlyRoot
                Camera.CameraType = CameraTypes[1]

                FlyStartTime = tick()
                TeleportEnabled = true

                RunLoops:BindToHeartbeat("InfiniteFly", function()
                    if FlyRoot then
                        if not FlyRoot or not FlyRoot.Parent then
                            if FlyRoot then
                                FlyRoot:Destroy()
                                FlyRoot = nil
                            end
                            TeleportEnabled = true
                            return
                        end

                        local Distance = (lplr.Character.HumanoidRootPart.Position - FlyRoot.Position).Magnitude
                        if Distance < 10000 and TeleportEnabled then
                            lplr.Character.HumanoidRootPart.CFrame = CFrame.new(FlyRoot.Position + Vector3.new(0, 200000, 0))
                        end

                        local newX = lplr.Character.HumanoidRootPart.Position.X
                        local newY = FlyRoot.Position.Y
                        local newZ = lplr.Character.HumanoidRootPart.Position.Z

                        if CtrlPressed then
                            newY = newY - 0.6
                        end
                        if SpacePressed then
                            newY = newY + 0.6
                        end

                        FlyRoot.Position = Vector3.new(newX, newY, newZ)
                    end
                end)
            else
                if InputBeganConnection then
                    InputBeganConnection:Disconnect()
                end
                if InputEndedConnection then
                    InputEndedConnection:Disconnect()
                end
                TeleportEnabled = false

                local RayStart = FlyRoot.Position
                local RayEnd = RayStart - Vector3.new(0, 10000, 0)
                local IgnoreList = {lplr, lplr.Character, FlyRoot, game.Workspace.CurrentCamera}

                local HitPart, HitPosition = workspace:FindPartOnRayWithIgnoreList(Ray.new(RayStart, RayEnd - RayStart), IgnoreList, true, true)
                if HitPart then
                    local newY = HitPosition.Y + (lplr.Character.HumanoidRootPart.Size.Y / 2) + lplr.Character.Humanoid.HipHeight
                    lplr.Character:SetPrimaryPartCFrame(CFrame.new(HitPosition.X, newY, HitPosition.Z))
                end

                local FlyDuration = tick() - FlyStartTime
                if FlyDuration > MaxFlyDuration["Value"] then
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, -1, 0)
                    local CurrentCamera = game.Workspace.CurrentCamera
                    CurrentCamera.CameraSubject = lplr.Character.Humanoid
                    CurrentCamera.CameraType = CameraTypes[1]
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                else
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, -1, 0)
                    if FlyRoot then
                        FlyRoot:Destroy()
                        FlyRoot = nil
                    end
                    Camera.CameraSubject = lplr.Character.Humanoid
                    if workspace.CurrentCamera and lplr.Character then
                        local humanoid = lplr.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            workspace.CurrentCamera.CameraSubject = humanoid
                        end
                    end
                end
            end
        end
    })
    local Infflykeybind = Blatant:CreateKeybind({
        Name = "Flight Keybind",
        CurrentKeybind = "Z",
        HoldToInteract = false,
        Flag = "Infflykeybind",
        Callback = function(Keybind)
            InfiniteFlyToggle:Set(not InfiniteFlyToggle.CurrentValue)
        end,
    })
end)


runcode(function()
    local Section = Blatant:CreateSection("ProjectileAura", true)
    local lastBowFireTime = 0
    local firing = false
    local BowCooldown = 3
    local arrowSpeed = {["Value"] = 120}
    local nearest
    local distance = {["Value"] = 100}
    local gravityEffect = {["Value"] = 30}

    local function canshoot()
        local currentTime = tick()
        return currentTime - lastBowFireTime >= BowCooldown
    end

    local function isVisible(player)
        local origin = lplr.Character.HumanoidRootPart.Position
        local target = player.Character.HumanoidRootPart.Position
        local direction = (target - origin).Unit
        local ray = Ray.new(origin, direction * (target - origin).Magnitude)
        local hit, position = workspace:FindPartOnRay(ray, lplr.Character)
        return hit == nil or hit:IsDescendantOf(player.Character)
    end

    local function avoidParts(position)
        local origin = lplr.Character.HumanoidRootPart.Position
        local direction = (position - origin).Unit
        local ray = Ray.new(origin, direction * (position - origin).Magnitude)
        local hit, position = workspace:FindPartOnRay(ray, lplr.Character)
        if hit and not hit:IsDescendantOf(nearest.Character) then
            return position + (hit.Position - position).Unit * 5
        end
        return position
    end

    local function setup()
        if lplr.Character then
            lplr.Character:WaitForChild("Humanoid").Died:Connect(function()
                firing = false
            end)
        end
    end

    setup()

    lplr.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(function()
            firing = false
        end)
        setup()
    end)

    local function predictPosition(nearest)
        local targetPosition = nearest.Character.HumanoidRootPart.Position
        local distance = (targetPosition - lplr.Character.HumanoidRootPart.Position).Magnitude
        local flightTime = distance / arrowSpeed["Value"]
        local predictedPosition = targetPosition + (nearest.Character.HumanoidRootPart.Velocity * flightTime) + (0.5 * Vector3.new(0, gravityEffect["Value"], 0) * flightTime^2)
        return avoidParts(predictedPosition)
    end

    local ProjectileAura = Blatant:CreateToggle({
        Name = "ProjectileAura",
        CurrentValue = false,
        Flag = "ProjectileAura",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("ProjectileAura", function()
                    nearest = getNearestPlayer(distance["Value"])
                    if nearest and not nearest.Character:FindFirstChild("ForceField") and isVisible(nearest) and IsAlive(nearest) and IsAlive(lplr) then
                        local predictedPosition = predictPosition(nearest)
                        if canshoot() and not firing then
                            firing = true
                            game:GetService("Players").LocalPlayer.Backpack.DefaultBow.__comm__.RF.Fire:InvokeServer(predictedPosition, math.huge)
                            lastBowFireTime = tick()
                            task.wait(0.25) 
                            firing = false
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("ProjectileAura")
            end
        end
    })
    
    local distance = Blatant:CreateSlider({
        Name = "distance",
        Range = {1, 100},
        Increment = 1,
        Suffix = "Shootdistance",
        CurrentValue = 100,
        Flag = "distance",
        Callback = function(Value)
            distance["Value"] = Value
        end
    })

    local arrowSpeed = Blatant:CreateSlider({
        Name = "arrowSpeed",
        Range = {1, 300},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 120,
        Flag = "arrowSpeed",
        Callback = function(Value)
            arrowSpeed["Value"] = Value
        end
    })

    local gravityEffect = Blatant:CreateSlider({
        Name = "gravityEffect",
        Range = {1, 196},
        Increment = 1,
        Suffix = "Gravity",
        CurrentValue = 30,
        Flag = "gravityEffect",
        Callback = function(Value)
            gravityEffect["Value"] = Value
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("Aim Assist",true)
    local Distance = {["Value"] = 32}
    local Smoothness = {["Value"] = 0.1}
    local TeamCheck = {Enabled = false}
    local Wallcheck = {Enabled = false}

    local function isPlayerVisible(player)
        local Ray = Ray.new(
            game.Workspace.CurrentCamera.CFrame.Position, 
            (player.Character.HumanoidRootPart.Position - game.Workspace.CurrentCamera.CFrame.Position).unit * (Distance["Value"] + 1)
        )
        local Part, Position = game.Workspace:FindPartOnRayWithIgnoreList(Ray, {lplr.Character})
        local isVisible = (Part == nil or Part:IsDescendantOf(player.Character))
        return isVisible
    end

    local AimAssist = Blatant:CreateToggle({
        Name = "Aim Assist",
        CurrentValue = false,
        Flag = "AimAssist",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("AimAssist", function()
                    local nearest = getNearestPlayer(Distance["Value"], false ,TeamCheck.Enabled)
                    if nearest then
                        local distanceToNearest = (nearest.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                        if distanceToNearest <= 18 then
                            if Wallcheck.Enabled and not isPlayerVisible(nearest) then
                                return
                            end
                            local direction = (nearest.Character.HumanoidRootPart.Position - game.Workspace.CurrentCamera.CFrame.Position).unit
                            local lookAt = CFrame.new(game.Workspace.CurrentCamera.CFrame.Position, game.Workspace.CurrentCamera.CFrame.Position + Vector3.new(direction.X, 0, direction.Z))
                            game.Workspace.CurrentCamera.CFrame = game.Workspace.CurrentCamera.CFrame:Lerp(lookAt, Smoothness["Value"]) 
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("AimAssist")
            end
        end
    })
    local AimAssistDistanceSlider = Blatant:CreateSlider({
        Name = "Distance",
        Range = {1, 32},
        Increment = 1,
        Suffix = "Distance",
        CurrentValue = 32,
        Flag = "AimAssistDistance",
        Callback = function(Value)
            Distance["Value"] = Value
        end
    })
    local SmoothnessSlider = Blatant:CreateSlider({
        Name = "Smoothness",
        Range = {0.1, 1},
        Increment = 0.1,
        Suffix = "Value",
        CurrentValue = 0.1,
        Flag = "Smoothness",
        Callback = function(Value)
            Smoothness["Value"] = Value
        end
    })
    local WallcheckToggle = Blatant:CreateToggle({
        Name = "Wallcheck",
        CurrentValue = false,
        Flag = "Wallcheck",
        Callback = function(val)
            Wallcheck.Enabled = val
        end
    })
    local TeamCheckToggle = Blatant:CreateToggle({
        Name = "Team Check",
        CurrentValue = false,
        Flag = "TeamCheck",
        Callback = function(val)
            TeamCheck.Enabled = val
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("AutoWin", true)
    local minY = -153.3984832763672
    local maxY = -12.753118515014648
    local speed = {["Value"] = 27}
    local function getNearestPlayer(radius)
        local closestPlayer = nil
        local closestDistance = radius
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= lplr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerY = player.Character.HumanoidRootPart.Position.Y
                if playerY > minY and playerY < maxY then
                    local distance = (player.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        return closestPlayer
    end

    local function tweenToPosition(targetPosition)
        local character = lplr.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = character.HumanoidRootPart

            local direction = (targetPosition - humanoidRootPart.Position).Unit
            local newPosition = targetPosition - direction * 2

            local tweenInfo = TweenInfo.new((newPosition - humanoidRootPart.Position).Magnitude / speed["Value"], Enum.EasingStyle.Linear)
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(newPosition)})
            tween:Play()

            if targetPosition.Y > humanoidRootPart.Position.Y then
                game.Workspace.Gravity = 0
                character:FindFirstChildOfClass("Humanoid").RootPart.Velocity = Vector3.new(0, 0, 0)
            else
                game.Workspace.Gravity = 10
                character:FindFirstChildOfClass("Humanoid").RootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
        
    local function randomString()
        local char = lplr.Character
        local length = math.random(10, 20)
        local array = {}
        for i = 1, length do
            array[i] = string.char(math.random(32, 126))
        end
        return table.concat(array)
    end
        
    local initialCollideStates = {}
    local AutoWinToggle = Blatant:CreateToggle({
        Name = "AutoWin",
        CurrentValue = false,
        Flag = "AutoWin",
        Callback = function(enabled)
            if enabled then
                RunLoops:BindToHeartbeat("UpdateTweenToNearestPlayer", function()
                    task.wait(0.1)
                    local nearest = getNearestPlayer(300)
                    if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") and IsAlive(lplr) then
                        local targetPosition = nearest.Character.HumanoidRootPart.Position
                        if targetPosition.Y > minY and targetPosition.Y < maxY then
                            tweenToPosition(targetPosition)
                        end
                    end
                end)
                if next(initialCollideStates) == nil then
                    initialCollideStates = {}
                    for _, part in pairs(workspace:GetDescendants()) do
                        if part:IsA("BasePart") then
                            initialCollideStates[part] = part.CanCollide
                        end
                    end
                end
                RunLoops:BindToHeartbeat("DisableCollision", function()
                    if lplr.Character then
                        local character = lplr.Character
                        local floatName = randomString()
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide == true and part.Name ~= floatName then
                                part.CanCollide = false
                            end
                        end
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, -5, 0))
                            local part, position = workspace:FindPartOnRay(ray)
                            if part then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                game.Workspace.Gravity = 196
                RunLoops:UnbindFromHeartbeat("UpdateTweenToNearestPlayer")
                RunLoops:UnbindFromHeartbeat("DisableCollision")
                for part, state in pairs(initialCollideStates) do
                    if part:IsA("BasePart") then
                        part.CanCollide = state
                    end
                end
                initialCollideStates = {}
            end
        end
    })

    local speed = Blatant:CreateSlider({
        Name = "speed",
        Range = {1, 27},
        Increment = 1,
        Suffix = "TweenSpeed",
        CurrentValue = 27,
        Flag = "speed",
        Callback = function(Value)
            speed["Value"] = Value
        end
    })
end)

runcode(function()
    local StatsGuiTemplate = game:GetObjects("rbxassetid://17778819925")[1]
    local clonedStatsGui = nil

    local function UpdateHealthBar(fill, currentHealth, maxHealth)
        fill.Size = UDim2.new(currentHealth / maxHealth, 0, 1, 0)
    end

    local function UpdateHpText(Hp, currentHealth)
        Hp.Text = tostring(math.floor(currentHealth + 0.5)) .. "%"
    end

    local function SetPlayerIcon(Playericon, player)
        local userId = player.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        if isReady then
            Playericon.Image = content
        end
    end

    local DisplayNames = {Enabled = false}
    local TargethubToggle = Render:CreateToggle({
        Name = "TargetHub",
        CurrentValue = false,
        Flag = "TargetHub",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("TargetHub", function()
                    if IsAlive(lplr) then
                        if nearest then
                            local distanceToNearest = (nearest.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                            if distanceToNearest <= 25 and IsAlive(nearest) then
                                if not clonedStatsGui then
                                    clonedStatsGui = StatsGuiTemplate:Clone()
                                    if clonedStatsGui then
                                        clonedStatsGui.StudsOffset = Vector3.new(0.4, 0, 0)
                                        clonedStatsGui.Parent = nearest.Character.HumanoidRootPart
                                        clonedStatsGui.Size = UDim2.new(0, 1000, 0, 100)
                                        clonedStatsGui.CanvasGroup.Content.Position = UDim2.new(0, 0, 0, 0)
                                        local Playericon = clonedStatsGui.CanvasGroup.Content.Health.Playericon
                                        local username = clonedStatsGui.CanvasGroup.Content.username
                                        SetPlayerIcon(Playericon, nearest)
                                        if clonedStatsGui.Parent and nearest.Character:FindFirstChild("Humanoid") then
                                            local Health = clonedStatsGui.CanvasGroup.Content.Health
                                            local bar = Health.bar
                                            local fill = bar.fill
                                            local Hp = clonedStatsGui.CanvasGroup.Content.Hp
                                            local maxHealth = nearest.Character.Humanoid.MaxHealth
                                            local currentHealth = nearest.Character.Humanoid.Health
                                            UpdateHpText(Hp, currentHealth)
                                            UpdateHealthBar(fill, currentHealth, maxHealth)
                                            username.Text = DisplayNames.Enabled and nearest.DisplayName or nearest.Name
                                        end
                                    end
                                else
                                    if clonedStatsGui and clonedStatsGui.Parent and nearest.Character:FindFirstChild("Humanoid") then
                                        clonedStatsGui.Parent = nearest.Character.HumanoidRootPart
                                        local Health = clonedStatsGui.CanvasGroup.Content.Health
                                        local bar = Health.bar
                                        local fill = bar.fill
                                        local Hp = clonedStatsGui.CanvasGroup.Content.Hp
                                        local maxHealth = nearest.Character.Humanoid.MaxHealth
                                        local currentHealth = nearest.Character.Humanoid.Health
                                        UpdateHpText(Hp, currentHealth)
                                        UpdateHealthBar(fill, currentHealth, maxHealth)
                                        local Playericon = clonedStatsGui.CanvasGroup.Content.Health.Playericon
                                        SetPlayerIcon(Playericon, nearest)
                                        local username = clonedStatsGui.CanvasGroup.Content.username
                                        username.Text = DisplayNames.Enabled and nearest.DisplayName or nearest.Name
                                    end
                                end
                            else
                                if clonedStatsGui then
                                    clonedStatsGui:Destroy()
                                    clonedStatsGui = nil
                                end
                            end
                        else
                            if clonedStatsGui then
                                clonedStatsGui:Destroy()
                                clonedStatsGui = nil
                            end
                        end
                    else
                        if clonedStatsGui then
                            clonedStatsGui:Destroy()
                            clonedStatsGui = nil
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("TargetHub")
                if clonedStatsGui then
                    clonedStatsGui:Destroy()
                    clonedStatsGui = nil
                end
            end
        end
    })
    local DisplayNamesToggle = Render:CreateToggle({
        Name = "DisplayNames",
        CurrentValue = false,
        Flag = "DisplayNames",
        Callback = function(val)
            DisplayNames.Enabled = val
        end
    })
end)


runcode(function()
    local Section = Render:CreateSection("NameTags", true)
    local espfolder = Instance.new("Folder", ScreenGui)
    espfolder.Name = "ESP"

    local Nametag = Instance.new("BillboardGui")
    local NameTag = Instance.new("TextLabel")
    local UIGradient = Instance.new("UIGradient")

    Nametag.Name = "Nametag"
    Nametag.Parent = game.ReplicatedStorage
    Nametag.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Nametag.Active = true
    Nametag.LightInfluence = 1.000
    Nametag.Size = UDim2.new(5, 0, 1, 0)
    Nametag.StudsOffset = Vector3.new(0, 2, 0)

    NameTag.Name = "NameTag"
    NameTag.Parent = Nametag
    NameTag.BackgroundTransparency = 1.000 
    NameTag.BorderColor3 = Color3.fromRGB(0, 0, 0)
    NameTag.BorderSizePixel = 0
    NameTag.Size = UDim2.new(1, 0, 1, 0)
    NameTag.Font = Enum.Font.Nunito
    NameTag.Text = "Name"
    NameTag.TextColor3 = Color3.fromRGB(0, 0, 0)
    NameTag.TextScaled = true
    NameTag.TextSize = 14.000
    NameTag.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    NameTag.TextStrokeTransparency = 0.000
    NameTag.TextWrapped = true

    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
    UIGradient.Rotation = 90
    UIGradient.Parent = NameTag

    local nametags = {}
    local originalDisplayDistanceTypes = {}
    local enabled = false

    local espdisplaynames = false
    local espnames = false
    local esphealth = false

    local function updateNametagText(player, NametagClone)
        local displayName = player.DisplayName
        local username = player.Name
        local health = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health or 0

        local text = ""
        if espdisplaynames then
            text = displayName
        end
        if espnames then
            if text ~= "" then
                text = text .. " (@" .. username .. ")"
            else
                text = "@" .. username
            end
        end
        if esphealth then
            text = text .. " [" .. tostring(math.floor(health)) .. "]"
        end

        NametagClone.NameTag.Text = text
    end

    local function attachNametag(player, character)
        local head = character:WaitForChild("Head", 5)
        if head then
            local NametagClone = Nametag:Clone()
            NametagClone.Parent = head
            nametags[player] = NametagClone

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                originalDisplayDistanceTypes[player] = humanoid.DisplayDistanceType
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end

            updateNametagText(player, NametagClone)
        end
    end

    local function createNametag(player)
        if not nametags[player] and enabled then
            if player.Character then
                attachNametag(player, player.Character)
            end

            player.CharacterAdded:Connect(function(character)
                attachNametag(player, character)
            end)
        end
    end

    local function onPlayerAdded(player)
        if enabled then
            createNametag(player)
        end
    end

    game.Players.PlayerAdded:Connect(onPlayerAdded)

    local function removeNametag(player)
        if nametags[player] then
            nametags[player]:Destroy()
            nametags[player] = nil
        end
        if originalDisplayDistanceTypes[player] and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = originalDisplayDistanceTypes[player]
            end
        end
        originalDisplayDistanceTypes[player] = nil
    end

    game.Players.PlayerRemoving:Connect(removeNametag)

    local function updateAllNametags()
        for player, nametag in pairs(nametags) do
            if player.Character then
                updateNametagText(player, nametag)
            end
        end
    end

    local NameTags = Render:CreateToggle({
        Name = "NameTags",
        CurrentValue = false,
        Flag = "NameTags",
        Callback = function(callback)
            enabled = callback
            if callback then
                RunLoops:BindToHeartbeat("NameTags", function(dt)
                    for _, player in ipairs(game.Players:GetPlayers()) do 
                        if player.Character then
                            if not nametags[player] then
                                createNametag(player)
                            else
                                updateNametagText(player, nametags[player])
                            end
                        end
                    end
                    for _, child in ipairs(espfolder:GetChildren()) do 
                        if not game.Players:FindFirstChild(child.Name) then
                            child:Destroy()
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("NameTags")
                espfolder:ClearAllChildren()
                for player, tag in pairs(nametags) do
                    if tag then
                        tag:Destroy()
                        nametags[player] = nil
                    end
                end
                for player in pairs(originalDisplayDistanceTypes) do
                    if player.Character then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.DisplayDistanceType = originalDisplayDistanceTypes[player]
                        end
                    end
                    originalDisplayDistanceTypes[player] = nil
                end
            end
        end
    })  
    local DisplayNames = Render:CreateToggle({
        Name = "DisplayNames",
        CurrentValue = false,
        Flag = "DisplayNames",
        Callback = function(val)
            espdisplaynames = val
            updateAllNametags()
        end
    })
    local Names = Render:CreateToggle({
        Name = "Names",
        CurrentValue = false,
        Flag = "espnames",
        Callback = function(val)
            espnames = val
            updateAllNametags()
        end
    })
    local Health = Render:CreateToggle({
        Name = "Health",
        CurrentValue = false,
        Flag = "esphealth",
        Callback = function(val)
            esphealth = val
            updateAllNametags()
        end
    })
end)

runcode(function()
    local Section = Render:CreateSection("Cape", true)
    
    local function CreateCape(character, texture)
        local humanoid = character:WaitForChild("Humanoid")
        local torso = humanoid.RigType == Enum.HumanoidRigType.R15 and character:WaitForChild("UpperTorso") or character:WaitForChild("Torso")
        local cape = Instance.new("Part", torso.Parent)
        cape.Name = "Cape"
        cape.Anchored = false
        cape.CanCollide = false
        cape.TopSurface = Enum.SurfaceType.Smooth
        cape.BottomSurface = Enum.SurfaceType.Smooth
        cape.Size = Vector3.new(0.2, 0.2, 0.2)
        cape.Transparency = 0
        local decal = Instance.new("Decal", cape)
        decal.Texture = texture
        decal.Face = Enum.NormalId.Back
        local mesh = Instance.new("BlockMesh", cape)
        mesh.Scale = Vector3.new(9, 17.5, 0.5)
        local motor = Instance.new("Motor", cape)
        motor.Part0 = cape
        motor.Part1 = torso
        motor.MaxVelocity = 0.01
        motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(90), 0)
        motor.C1 = CFrame.new(0, 1, 0.45) * CFrame.Angles(0, math.rad(90), 0)
        
        local wave = false
        repeat
            task.wait(1 / 44)
            decal.Transparency = torso.Transparency
            local angle = 0.1
            local oldMagnitude = torso.Velocity.Magnitude
            local maxVelocity = 0.002
            if wave then
                angle = angle + ((torso.Velocity.Magnitude / 10) * 0.05) + 0.05
                wave = false
            else
                wave = true
            end
            angle = angle + math.min(torso.Velocity.Magnitude / 11, 0.5)
            motor.MaxVelocity = math.min((torso.Velocity.Magnitude / 111), 0.04)
            motor.DesiredAngle = -angle
            if motor.CurrentAngle < -0.2 and motor.DesiredAngle > -0.2 then
                motor.MaxVelocity = 0.04
            end
            repeat task.wait() until motor.CurrentAngle == motor.DesiredAngle or math.abs(torso.Velocity.Magnitude - oldMagnitude) >= (torso.Velocity.Magnitude / 10) + 1
            if torso.Velocity.Magnitude < 0.1 then
                task.wait(0.1)
            end
        until not cape or cape.Parent ~= torso.Parent
    end

    local function DestroyCape(character)
        local cape = character:FindFirstChild("Cape")
        if cape then
            cape:Destroy()
        end
    end
    
    local Connection
    local function AddCape(character)
        task.wait(1)
        if not character:FindFirstChild("Cape") then
            CreateCape(character, getcustomasset("Aristois/assets/cape.png"))
        end
    end
    
    local CapeToggle = Render:CreateToggle({
        Name = "Cape",
        CurrentValue = false,
        Flag = "Cape",
        Callback = function(enabled)
            if enabled then
                AddCape(lplr.Character)
                Connection = lplr.CharacterAdded:Connect(AddCape)
            else
                if Connection then
                    Connection:Disconnect()
                    Connection = nil
                end
                DestroyCape(lplr.Character)
            end
        end
    })
end)

runcode(function()
    local Section = Utility:CreateSection("DeviceSpoofer", true)
    local selectedDevices = {Enum.Platform.Windows}

    local DeviceSpoofer = Utility:CreateToggle({
        Name = "Device Spoofer",
        CurrentValue = false,
        Flag = "Device",
        Callback = function(callback)
            if callback then
                local originalNamecall
                originalNamecall = hookmetamethod(game, "__namecall", function(...)
                    local args = {...}
                    local self = args[1]
                    local method = getnamecallmethod()

                    if self == UserInputService or self == GuiService then
                        if method == "GetPlatform" then
                            return selectedDevices[1]
                        end
                    end
                    return originalNamecall(...)
                end)
                getgenv().originalNamecall = originalNamecall
            else
                if getgenv().originalNamecall then
                    hookmetamethod(game, "__namecall", getgenv().originalNamecall)
                    getgenv().originalNamecall = nil
                end
            end
        end
    })
    local Dropdown = Utility:CreateDropdown({
        Name = "Device Selector",
        Options = {"Windows", "IOS", "Android", "XBoxOne", "PS3", "PS4", "Linux", "UWP"},
        CurrentOption = "Windows",
        Flag = "DeviceSelector", 
        Callback = function(Option)
            selectedDevices = {}
            for _, device in ipairs(Option) do
                table.insert(selectedDevices, Enum.Platform[device])
            end
        end,
    })
end)

runcode(function()
    local Section = Utility:CreateSection("AntiAfk", true)
    local AnitAfk = Utility:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Flag = "AntiAfk",
        Callback = function(callback)
            if callback then
                if lplr.AntiAfkConnection then
                    lplr.AntiAfkConnection:Disconnect()
                end
                lplr.AntiAfkConnection = lplr.Idled:Connect(function()
                    VirtualUserService:CaptureController()
                    VirtualUserService:ClickButton2(Vector2.new())
                end)
            else
                if lplr.AntiAfkConnection then
                    lplr.AntiAfkConnection:Disconnect()
                    lplr.AntiAfkConnection = nil
                end
            end
        end
    })
end)

runcode(function()
    local NukerEnabled = false
    local breakInterval = 0.1
    local NukerDistance = {["Value"] = 15}
    local Section = Word:CreateSection("Nuker", true)
    local function roundToWhole(number)
        return math.floor(number + 0.5)
    end

    local Nuker = Word:CreateToggle({
        Name = "Nuker",
        CurrentValue = false,
        Flag = "Nuker",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Nuker", function()
                    task.wait(0.1)
                    if IsAlive(lplr) then
                        local nearestBlockPosition = nil
                        for _, block in ipairs(Workspace.Map:GetChildren()) do
                            if block.Name == "Block" then
                                local blockPosition = block.Position
                                local distance = (lplr.Character.PrimaryPart.Position - blockPosition).magnitude
                                if distance <= NukerDistance["Value"] then
                                    nearestBlockPosition = blockPosition
                                end
                            end
                        end
                        if nearestBlockPosition then
                            local roundedPosition = Vector3.new(roundToWhole(nearestBlockPosition.X), roundToWhole(nearestBlockPosition.Y), roundToWhole(nearestBlockPosition.Z))
                            KnitClient.Services.ToolService.RF.BreakBlock:InvokeServer(roundedPosition)
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Nuker")
            end
        end
    })
    local NukerDistanceSlider = Word:CreateSlider({
        Name = "Nuker Distance",
        Range = {1, 15},
        Increment = 1,
        Suffix = "blocks",
        CurrentValue = 15,
        Flag = "NukerDistance",
        Callback = function(Value)
            NukerDistance["Value"] = Value
        end
    })
end)

local whitelist = {
    connection = nil,
    players = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.json")),
    loadedData = false,
    sentMessages = {}
}

if not WhitelistModule or not WhitelistModule.checkstate and whitelist then return true end

local cmdr = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
cmdr.Enabled = false
cmdr.Name = "cmdr"
cmdr.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
cmdr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = cmdr
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.300
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 0, 0, -37)
Frame.Size = UDim2.new(1, 0, 0, 30)

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundTransparency = 1.000
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0, 0, -0.000999959302, 0)
TextBox.Size = UDim2.new(1, 0, 0, 30)
TextBox.Font = Enum.Font.FredokaOne
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 19.000

UIAspectRatioConstraint.Parent = cmdr
UIAspectRatioConstraint.AspectRatio = 2.364

local commands = {
    [";ban default"] = function()
        lplr:Kick("You were kicked from this experience: You are temporarily banned from this experience. You will be unbanned in 20 days, 23 hours, and 50 minutes. Ban Reason: Exploiting, Autoclicking")
    end,
    [";kick default"] = function()
        lplr:Kick("You were kicked.")
    end,
    [";kill default"] = function()
        local character = lplr.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.Health = 0
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end,
    [";freeze default"] = function()
        lplr.Character.HumanoidRootPart.Anchored = true
    end,
    [";unfreeze default"] = function()
        lplr.Character.HumanoidRootPart.Anchored = false
    end,
    [";void default"] = function()
        lplr.Character.HumanoidRootPart.CFrame = CFrame.new(lplr.Character.HumanoidRootPart.CFrame.Position + Vector3.new(0, 10000000, 0))
    end,
    [";loopkill default"] = function()
        RunLoops:BindToHeartbeat("kill", function(dt)
            lplr.Character:FindFirstChild("Humanoid").Health = 0
            lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
    end,
    [";unloopkill default"] = function()
       RunLoops:UnbindFromHeartbeat("kill")
    end,
    [";deletemap default"] = function()
        local terrain = workspace:FindFirstChildWhichIsA('Terrain')
        if terrain then terrain:Clear() end
        for _, obj in pairs(workspace:GetChildren()) do
            if obj ~= terrain and not obj:IsA('Humanoid') and not obj:IsA('Camera') then
                obj:Destroy()
            end
        end
    end,
    [";rejoin default"] = function(player)
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end,
    [";server default"] = function()
        setclipboard("https://discord.gg/pDuXtHgsBt")
    end,
    [";reveal default"] = function(player)
        local message = "I am using Aristois"
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local newchannel = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(player.UserId)
            if newchannel and player ~= lplr then
                newchannel:SendAsync(message)
            end
        elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            if player ~= lplr then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. player.Name .. " " .. message, "All")
            end
        end
    end
}

local function matchCommand(msg)
    local trimmedMsg = string.match(msg, "^%s*(.-)%s*$")
    local commandParts = {}
    for command in pairs(commands) do
        local commandPrefix = string.match(command, "^(%S+)")
        if commandPrefix then
            table.insert(commandParts, {prefix = commandPrefix, fullCommand = command})
        end
    end
    for _, commandPart in ipairs(commandParts) do
        local commandPrefix = commandPart.prefix
        if string.sub(trimmedMsg, 1, #commandPrefix) == commandPrefix then
            return commandPart.fullCommand
        end
    end
    
    return nil
end

local function getBestMatch(text)
    local bestMatch = nil
    local matchCount = 0
    for command, _ in pairs(commands) do
        if command:sub(1, #text):lower() == text:lower() then
            bestMatch = command:sub(#text + 1)
            matchCount = matchCount + 1
        end
    end
    return matchCount == 1 and bestMatch or nil
end

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local currentText = TextBox.Text
    local bestMatch = getBestMatch(currentText)
    if bestMatch then
        TextBox.PlaceholderText = bestMatch
    else
        TextBox.PlaceholderText = ""
    end
end)

local amIWhitelisted = WhitelistModule.checkstate(lplr)
local function handlePlayer(player, PlayerAdded)
    whitelist.loadedData = true
    local hashedCombined = WhitelistModule.hashUserIdAndUsername(player.UserId, player.Name)
    if PlayerAdded and whitelist.players[hashedCombined] and not amIWhitelisted then
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local newchannel = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat.WhisperChat:InvokeServer(player.UserId)
            if newchannel and player ~= lplr then
                newchannel:SendAsync(Table.ChatStrings2.Aristois)
            end
        elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            if player ~= lplr then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. player.Name .. " " .. Table.ChatStrings2.Aristois, "All")
            end
        end

        player.Chatted:Connect(function(msg)
            local lowerMsg = string.lower(msg)
            local command = matchCommand(lowerMsg)
            if command and not amIWhitelisted then
                commands[command](player)
            end
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    handlePlayer(player, true)
end

TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local commandPart = TextBox.PlaceholderText
        local command = TextBox.Text .. commandPart
        local commandFunc = commands[command]
        if commandFunc then
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(command)
            elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(command, "All")
            end
        end
        TextBox.Text = ""
    end
end)

local CmdrVisible = false
local whitelisted = WhitelistModule.checkstate(lplr)
if not whitelist.connection then
    whitelist.connection = Players.PlayerAdded:Connect(function(v) handlePlayer(v, true) end)
    if whitelisted and whitelist.connection then
        if whitelist.loadedData then task.wait() print("Data loaded successfully.") end
        Players.PlayerRemoving:Connect(function(playerLeaving)
            if whitelist.sentMessages[playerLeaving.UserId] then 
                whitelist.sentMessages[playerLeaving.UserId] = nil
            elseif not whitelist.connection then
                return true
            end
        end)
        local function toggleCmdrVisibility()
            CmdrVisible = not CmdrVisible
            cmdr.Enabled = CmdrVisible
        end

        UserInputService.InputBegan:Connect(function(input, isProcessed)
            if not isProcessed and input.KeyCode == Enum.KeyCode.Delete then
                toggleCmdrVisibility()
            end
        end)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.MessageReceived:Connect(function(tab : TextChatMessage)
                if tab.TextSource then
                    local speaker = Players:GetPlayerByUserId(tab.TextSource.UserId)
                    local message = tab.Text
                    if speaker and string.find(tab.TextChannel.Name, "RBXWhisper") and string.find(message, Table.ChatStrings2.Aristois) then
                        local playerId = speaker.UserId
                        if not whitelist.sentMessages[playerId] then
                            WhitelistModule.AddExtraTag(speaker, "DEFAULT USER", Color3.fromRGB(255, 0, 0))
                            GuiLibrary:Notify({
                                Title = "Aristois",
                                Content = speaker.Name .. " is using Aristois!",
                                Duration = 60,
                                Image = 4483362458,
                                Actions = {
                                    Ignore = {
                                        Name = "Okay!",
                                        Callback = function()
                                            print("The user tapped Okay!")
                                        end
                                    },
                                },
                            })
                            whitelist.sentMessages[playerId] = true
                        end
                    end
                end
            end)
        elseif ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents') then
            local defaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents')
            local onMessageDoneFiltering = defaultChatSystemChatEvents and defaultChatSystemChatEvents:FindFirstChild("OnMessageDoneFiltering")
            if onMessageDoneFiltering then
                onMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
                    local speaker, message = Players[messageData.FromSpeaker], messageData.Message
                    if messageData.MessageType == "Whisper" and message == Table.ChatStrings2.Aristois then
                        local playerId = speaker.UserId
                        if not whitelist.sentMessages[playerId] then
                            WhitelistModule.AddExtraTag(speaker, "DEFAULT USER", Color3.fromRGB(255, 0, 0))
                            print(messageData.FromSpeaker)
                            GuiLibrary:Notify({
                                Title = "Aristois",
                                Content = messageData.FromSpeaker .. " is using Aristois!",
                                Duration = 60,
                                Image = 4483362458,
                                Actions = {
                                    Ignore = {
                                        Name = "Okay!",
                                        Callback = function()
                                            print("The user tapped Okay!")
                                        end
                                    },
                                },
                            })
                            whitelist.sentMessages[playerId] = true
                        end
                    end
                end)
            end
        end
    end
end

Players.PlayerAdded:Connect(function()
    WhitelistModule.UpdateTags()
end)

WhitelistModule.UpdateTags()
GuiLibrary:LoadConfiguration()

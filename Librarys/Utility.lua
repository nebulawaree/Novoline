local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local Utility = {}

function Utility.IsAlive(plr)
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

function Utility.getNearestEntity(maxDist, findNearestHealthEntity, teamCheck, entityName)
    local targetData = {
        nearestEntity = nil,
        dist = math.huge,
        lowestHealth = math.huge
    }
    
    local function updateTargetData(entity, mag, health)
        if findNearestHealthEntity and health < targetData.lowestHealth then
            targetData.lowestHealth = health
            targetData.nearestEntity = entity
        elseif mag < targetData.dist then
            targetData.dist = mag
            targetData.nearestEntity = entity
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lplr and player.Character and Utility.IsAlive(player) and Utility.IsAlive(lplr) then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local mag = (humanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                local health = player.Character:FindFirstChild("Humanoid").Health
                
                if mag < maxDist then
                    if not teamCheck or player.Team ~= lplr.Team then
                        updateTargetData(player, mag, health)
                    end
                end
            end
        end
    end
    
    for _, entity in ipairs(workspace:GetChildren()) do
        if entity.Name == entityName and entity:IsA("Model") then
            local rootPart = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("PrimaryPart") or entity:FindFirstChildWhichIsA("BasePart")
            if rootPart then
                local dist = (rootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                if dist < maxDist then
                    local mockEntity = {
                        Name = entityName,
                        Character = entity,
                        Distance = dist,
                        Health = 0
                    }
                    updateTargetData(mockEntity, dist, 0)
                end
            end
        end
    end

    return targetData.nearestEntity
end

function Utility.getNearestPlayerToMouse(teamCheck)
    local nearestPlayer, nearestDistance = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lplr and (not teamCheck or player.Team ~= lplr.Team) then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local pos = character.HumanoidRootPart.Position
                local screenPos, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(pos)
                if onScreen then
                    local mousePos = game.Players.LocalPlayer:GetMouse()
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
                    if distance < nearestDistance then
                        nearestPlayer, nearestDistance = player, distance
                    end
                end
            end
        end
    end

    return nearestPlayer
end

return Utility

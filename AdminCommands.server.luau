--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Create RemoteEvent for admin commands
local adminEvent = Instance.new("RemoteEvent")
adminEvent.Name = "AdminEvent"
adminEvent.Parent = ReplicatedStorage

-- DataStore for player data
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- Function to handle admin commands
local function handleAdminCommand(player: Player, command: string, args: any)
    if not player:GetAttribute("IsAdmin") then
        return
    end

    if command == "AntiDie" then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:SetAttribute("AntiDie", true)
        humanoid.Died:Connect(function()
            if humanoid:GetAttribute("AntiDie") then
                task.wait(1)
                humanoid:Respawn()
            end
        end)
    elseif command == "GodMode" then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:SetAttribute("GodMode", true)
        humanoid.HealthChanged:Connect(function(health)
            if humanoid:GetAttribute("GodMode") and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    elseif command == "Forcefield" then
        local character = player.Character or player.CharacterAdded:Wait()
        local forcefield = Instance.new("ForceField")
        forcefield.Parent = character
        forcefield.Visible = args
    elseif command == "SpeedEnhancer" then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = args
    elseif command == "JumpEnhancer" then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.JumpPower = args
    elseif command == "GetAllGamepasses" then
        local success, err = pcall(function()
            playerDataStore:UpdateAsync("Player_" .. player.UserId, function(oldData)
                local newData = oldData or {}
                newData.Gamepasses = {}
                for _, gamepass in ipairs(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Gamepasses) do
                    newData.Gamepasses[gamepass.ID] = true
                end
                return newData
            end)
        end)
        if not success then
            warn("Error updating gamepasses: " .. tostring(err))
        end
    elseif command == "GetAllMortyCoins" then
        local success, err = pcall(function()
            playerDataStore:UpdateAsync("Player_" .. player.UserId, function(oldData)
                local newData = oldData or {}
                newData.MortyCoins = 999999
                return newData
            end)
        end)
        if not success then
            warn("Error updating Morty coins: " .. tostring(err))
        end
    elseif command == "CoinMultiplier" then
        local success, err = pcall(function()
            playerDataStore:UpdateAsync("Player_" .. player.UserId, function(oldData)
                local newData = oldData or {}
                newData.CoinMultiplier = args
                return newData
            end)
        end)
        if not success then
            warn("Error updating coin multiplier: " .. tostring(err))
        end
    elseif command == "ZeroSlowdown" then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:SetAttribute("ZeroSlowdown", true)
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid:GetAttribute("ZeroSlowdown") then
                humanoid.WalkSpeed = args
            end
        end)
    elseif command == "TeleportToPlayer" then
        local targetPlayer = Players:FindFirstChild(args)
        if targetPlayer then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local targetCharacter = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
            local targetHumanoidRootPart = targetCharacter:WaitForChild("HumanoidRootPart")
            humanoidRootPart.CFrame = targetHumanoidRootPart.CFrame
        end
    elseif command == "FlingPlayer" then
        local targetPlayer = Players:FindFirstChild(args)
        if targetPlayer then
            local character = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local humanoid = character:WaitForChild("Humanoid")
            humanoidRootPart.Velocity = Vector3.new(0, 100, 0)
            humanoid:TakeDamage(10)
        end
    end
end

-- Connect RemoteEvent to handle admin commands
adminEvent.OnServerEvent:Connect(handleAdminCommand)

local maxPeds = 100 -- Maximum amount of peds that can be spawned.
local deleteRange = 100 -- Distance from player to delete spawned peds.
local currentSpawnedPeds = {} -- Table of current spawned peds.
local pedModels = { -- List of models to use during ped creation.
    `a_f_y_tourist_01`,
    `a_m_m_business_01`,
    `a_f_m_bodybuild_01`,
    `s_m_y_cop_01`,
    `a_m_m_fatlatin_01`,
    `a_m_m_soucent_03`,
    `a_m_o_soucent_03`,
    `a_m_y_runner_01`,
}

function PedDistanceDelete() -- Auto-delete spawned Peds that exceed 100m from the player that spawned them.
    for i = #currentSpawnedPeds, 1, -1 do
        local ped = currentSpawnedPeds[i]
        if DoesEntityExist(ped) then
            local pedPos = GetEntityCoords(ped)
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local distance = #(playerPos - pedPos)

            if distance > deleteRange then
                DeleteEntity(ped)
                table.remove(currentSpawnedPeds, i)
            end
        else
            table.remove(currentSpawnedPeds, i)
        end
    end
end

function EnsureModelIsLoaded(models) -- Ensures ped models are loaded by the client.
    for _, model in ipairs(models) do
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
    end
end

function ShowMissionText(message, duration) -- Displays GTA mission text.
    BeginTextCommandPrint('STRING')
    AddTextComponentString(message)
    EndTextCommandPrint(duration, true)
end

function NormaliseVector(vector) -- Conversion to direction vector.
    local length = math.sqrt(vector.x^2 + vector.y^2 + vector.z^2) -- Length from origin to 3D point.
    if length == 0 then -- Prevents division by 0.
        return vector3(0,0,0)
    else
       return vector3(vector.x / length, vector.y / length, vector.z / length) -- Returns a direction vector.
    end
end

CreateThread(function() -- Thread for spawned ped deletion.
    while true do
       Wait(5000)
       PedDistanceDelete()
    end
end)

----------------------------------------------------------------------------------------------

-- Event for spawning peds
RegisterNetEvent('PedInteraction:spawnped')
AddEventHandler('PedInteraction:spawnped', function(x, y, z, heading)
    EnsureModelIsLoaded(pedModels) -- Ensures model is loaded before spawning.

    if #currentSpawnedPeds >= maxPeds then -- Checks if the number of spawned peds has reached the limit.
        local oldPed = table.remove(currentSpawnedPeds, 1) -- Removes the oldest ped from the table.
        if DoesEntityExist(oldPed) then
            DeleteEntity(oldPed)
            SetModelAsNoLongerNeeded(GetEntityModel(oldPed))
        end
    end

    local model = pedModels[math.random(#pedModels)] -- Selects a random model from the table.
    local ped = CreatePed(0, model, x, y, z, heading, true, true)
    
    if DoesEntityExist(ped) then
        table.insert(currentSpawnedPeds, ped) -- Adds the created ped into the current ped table.
        SetPedRandomComponentVariation(ped, true)
        SetPedAsNoLongerNeeded(ped)
        SetModelAsNoLongerNeeded(model)
    else 
        TriggerEvent('chat:addMessage', {args = {'Ped creation failed'}
        })
    end
end)

----------------------------------------------------------------------------------------------

-- Event for spawn notifications
RegisterNetEvent('PedInteraction:spawnnotification')
AddEventHandler('PedInteraction:spawnnotification', function(pedNumber)

    TriggerEvent('chat:addMessage', {args = {tostring(pedNumber).. ' peds spawned'}})
end)

----------------------------------------------------------------------------------------------

-- Spawn Peds in a line from the direction the camera is facing
RegisterCommand('spawnpedline', function(_, args)
    local pedAmount = tonumber(args[1])
    local camRotation = GetGameplayCamRot(2) -- Gets current camera rotation.
    local camHeading = math.rad(camRotation.z) + math.pi -- Converts to radians and adds 180 degrees, so peds spawn within view.

    if not pedAmount then
        TriggerEvent('chat:addMessage', {args = {'Invalid ped amount. Please input a number'}})
        return
    end

    if pedAmount <= 0 or pedAmount > maxPeds then
        TriggerEvent('chat:addMessage', {args = {'Number of peds must be greater than 0 and less than ' .. maxPeds}})
        return
    end 

    TriggerServerEvent('PedInteraction:spawnpedline', pedAmount, camHeading)
end)

----------------------------------------------------------------------------------------------

-- Spawn Peds in a radius around player
RegisterCommand('spawnpedradius', function(_, args)
    local pedAmount = tonumber(args[1])

    if not pedAmount then
        TriggerEvent('chat:addMessage', {args = {'Invalid ped amount. Please input a number'}})
        return
    end 

    if pedAmount <= 0 or pedAmount > maxPeds then
        TriggerEvent('chat:addMessage', {args = {'Number of peds must be greater than 0 and less than ' .. maxPeds}})
        return
    end 

    TriggerServerEvent('PedInteraction:spawnpedradius', pedAmount)
end)

----------------------------------------------------------------------------------------------

-- Explode all NPC Peds in a radius around the player
RegisterCommand('explodepeds', function(_, args)
    local pedRadius = tonumber(args[1])

    if not pedRadius then 
        TriggerEvent('chat:addMessage', {args = {'Invalid radius. Please input a number'}})
        return
    end 

    if pedRadius <= 0 then
        TriggerClientEvent('chat:addMessage', playerId {args = {'Radius must be greater than 0'}})
        return
    end

    TriggerServerEvent('PedInteraction:explodepeds', pedRadius)
end)

----------------------------------------------------------------------------------------------

-- Ignite all NPC Peds in a radius around the player
RegisterCommand('ignitepeds', function(_, args)
    local pedRadius = tonumber(args[1])

    if not pedRadius then 
        TriggerEvent('chat:addMessage', {args = {'Invalid radius. Please input a number'}})
        return
    end

    if pedRadius <= 0 then
        TriggerClientEvent('chat:addMessage', playerId {args = {'Radius must be greater than 0'}})
        return
    end

    TriggerServerEvent('PedInteraction:ignitepeds', pedRadius)
end)

----------------------------------------------------------------------------------------------

-- Brings up Ped Debug
RegisterCommand('debugped', function(_, args)
    local pedRadius = tonumber(args[1])
    TriggerServerEvent('PedInteraction:debugped', pedRadius)
end)

----------------------------------------------------------------------------------------------

-- Event for exploding Peds in a radius
RegisterNetEvent('PedInteraction:explode')
AddEventHandler('PedInteraction:explode', function(pedRadius)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local peds = GetGamePool('CPed')
    local explodeCount = 0

    for i = 1, #peds do
        local ped = peds[i]
        local isDead = IsPedDeadOrDying(ped, false)
        if ped ~= playerPed and not IsPedAPlayer(ped) and not isDead then
            local pedPos = GetEntityCoords(ped)
            local distance = #(playerPos - pedPos)
            if distance <= pedRadius then
                AddExplosion(pedPos.x, pedPos.y, pedPos.z, 8, 2, true, false, 0)
                SetEntityHealth(ped, 0) -- Kills ped once exploded.
                explodeCount = explodeCount + 1
            end
        end
    end

    TriggerEvent('chat:addMessage', {args = {explodeCount .. ' peds exploded'}
    })
end)

----------------------------------------------------------------------------------------------

-- Event for igniting Peds in a radius
RegisterNetEvent('PedInteraction:ignite')
AddEventHandler('PedInteraction:ignite', function(pedRadius)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local peds = GetGamePool('CPed')
    local pedsToIgnite = {}
    local igniteCount = 0

    for i = 1, #peds do -- Iterates over total number of peds.
        local ped = peds[i]
        local isDead = IsPedDeadOrDying(ped, false)

        if ped ~= playerPed and not IsPedAPlayer(ped) and not isDead and not IsEntityOnFire(ped) then
            local pedPos = GetEntityCoords(ped)
            local distance = #(playerPos - pedPos)
            if distance <= pedRadius then -- Checks if the ped is within the radius.
                table.insert(pedsToIgnite, ped)
            end
        end
    end

    table.sort(pedsToIgnite, function(a, b)  -- Sorts by the closest distance from the player.
        return GetDistanceBetweenCoords(playerPos, GetEntityCoords(a), true) < 
        GetDistanceBetweenCoords(playerPos, GetEntityCoords(b), true) 
    end)

    CreateThread(function()
        local batchSize = 10 -- Number of peds that will ignite per batch.
        local batchDelay = 300 -- Delay between next batch.

        for i = 1, #pedsToIgnite, batchSize do
            for j = i, math.min(i + batchSize - 1, #pedsToIgnite) do -- Iterate through the batch.
                StartEntityFire(pedsToIgnite[j])
                igniteCount = igniteCount + 1
            end

            Wait(batchDelay)
        end
    
        TriggerEvent('chat:addMessage', {args = {igniteCount .. ' peds ignited'}
        })
    end)
end)

----------------------------------------------------------------------------------------------

-- Event for ped debug
local isDebugActive = false
RegisterNetEvent('PedInteraction:debug')
AddEventHandler('PedInteraction:debug', function(pedRadius)
    isDebugActive = not isDebugActive -- Toggles debug state.

    if isDebugActive then
        SendNuiMessage(json.encode({type = 'display', display = true})) -- Display debug UI.
        TriggerEvent('chat:addMessage', {args = {'Ped debug started'}})

        CreateThread(function()
            while isDebugActive do
                SendNuiMessage(json.encode({type = "updatePedCount", count = #currentSpawnedPeds})) -- Updates spawned ped count in UI.
               Wait(100)
            end
        end)

        CreateThread(function()
            while isDebugActive do
                local playerPed = PlayerPedId()
                local playerPos = GetEntityCoords(playerPed)
                local peds = GetGamePool('CPed')
                local pedAmount = 0 -- Counter for number of peds within the radius.

                for i = 1, #peds do
                    local ped = peds[i]
                    if ped ~= playerPed and not IsPedAPlayer(ped) then -- Exclude players.
                        local pedPos = GetEntityCoords(ped)
                        local distance = #(playerPos - pedPos)
                        if distance <= pedRadius then
                            DrawMarker(28, pedPos.x, pedPos.y, pedPos.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                            pedAmount = pedAmount + 1
                        end
                    end
                end
        
                ShowMissionText('Peds detected in radius (~y~' .. pedRadius .. '~s~): ~r~' .. pedAmount .. '~s~', 50)
                Wait(2)
            end
        end)
    else
        SendNuiMessage(json.encode({type = 'display', display = false}))
        TriggerEvent('chat:addMessage', {args = {'Ped debug stopped'}})
    end
end)

----------------------------------------------------------------------------------------------

-- Event for the hand of god command
local isHandOfGodActive = false
local lastPlayerTarget = nil
local lastTargetHit = false
RegisterNetEvent('PedInteraction:god')
AddEventHandler('PedInteraction:god', function()
    isHandOfGodActive = not isHandOfGodActive -- Toggles hand of god state.
    SendNUIMessage({type = "toggleHandOfGod", isActive = isHandOfGodActive}) -- Display hand of god UI.

    if isHandOfGodActive then
        CreateThread(function()
            while isHandOfGodActive do
                Wait(100)
                local playerPed = PlayerPedId()

                if IsPedInMeleeCombat(playerPed) then -- Checks if player is in melee combat.
                    local currentTarget = GetMeleeTargetForPed(playerPed) -- Gets the current target.

                    if currentTarget and DoesEntityExist(currentTarget) then
                        if currentTarget ~= lastPlayerTarget then
                            lastPlayerTarget = currentTarget -- Updates the lastPlayerTarget if changed.
                            lastTargetHit = false -- Was not hit.
                        end

                        if not lastTargetHit then
                            Wait(500) -- Delay so that a punch connects/almost connects before applying force.

                            local status, error = pcall(function() -- Error handling because I kept crashing.
                                local pedPos = GetEntityCoords(currentTarget)
                                local playerPos = GetEntityCoords(playerPed)
                                local dirVector = pedPos - playerPos
                                local normalisedVector = NormaliseVector(dirVector)
                                ApplyForceToEntity(currentTarget, 1, normalisedVector.x * 300, normalisedVector.y * 300, -normalisedVector.z * 250, 0, 0, 0, 0, false, true, true, false, true)
                                AddExplosion(pedPos.x, pedPos.y, pedPos.z, 18, 0, true, false, 0)
                                Wait(30) -- Delay so force is applied before ragdolling.
                                SetPedToRagdoll(currentTarget, 1000, 2000, 0, false, false, false) 
                                lastTargetHit = true
                            end)

                            if not status then -- If an error occurrs.
                                print("Error applying force: " .. tostring(error))
                            end
                        end
                    else
                        lastPlayerTarget = nil -- Reset variables.
                        lastTargetHit = false
                    end
                else
                    lastPlayerTarget = nil -- Reset variables.
                    lastTargetHit = false
                end
            end
        end)
    else
        lastPlayerTarget = nil -- Reset variables.
        lastTargetHit = false
    end
end)
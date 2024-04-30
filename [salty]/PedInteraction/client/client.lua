local maxPeds = 100
local deleteRange = 100
local currentSpawnedPeds = {}
local pedModels = {
    `a_f_y_tourist_01`,
    `a_m_m_business_01`,
    `a_f_m_bodybuild_01`,
    `s_m_y_cop_01`,
    `a_m_m_fatlatin_01`,
    `a_m_m_soucent_03`,
    `a_m_o_soucent_03`,
    `a_m_y_runner_01`,
}

function PedDistanceDelete()
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

function EnsureModelIsLoaded(models)
    for _, model in ipairs(models) do
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
    end
end

function ShowMissionText(message, duration)
    BeginTextCommandPrint('STRING')
    AddTextComponentString(message)
    EndTextCommandPrint(duration, true)
end

function ShowNotif(message, colour, flash, saveToBrief)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    ThefeedNextPostBackgroundColor(colour)
    EndTextCommandThefeedPostTicker(flash, saveToBrief)
end

CreateThread(function()
    while true do
       Wait(5000)
       PedDistanceDelete()
    end
end)

----------------------------------------------------------------------------------------------

-- Event for spawning peds
RegisterNetEvent('PedInteraction:spawnped')
AddEventHandler('PedInteraction:spawnped', function(x, y, z, heading)
    EnsureModelIsLoaded(pedModels)

    if #currentSpawnedPeds >= maxPeds then
        local oldPed = table.remove(currentSpawnedPeds, 1)
        if DoesEntityExist(oldPed) then
            DeleteEntity(oldPed)
            SetModelAsNoLongerNeeded(GetEntityModel(oldPed))
        end
    end

    local model = pedModels[math.random(#pedModels)]
    local ped = CreatePed(0, model, x, y, z, heading, true, true)
    
    if DoesEntityExist(ped) then
        table.insert(currentSpawnedPeds, ped)
        SetPedRandomComponentVariation(ped, true)
        SetPedAsNoLongerNeeded(ped)
        SetModelAsNoLongerNeeded(model)
    else 
        TriggerEvent('chat:addMessage' , {
            args = {'Ped creation failed',}
        })
    end
end)

----------------------------------------------------------------------------------------------

-- Event for spawn notifications
RegisterNetEvent('PedInteraction:spawnnotification')
AddEventHandler('PedInteraction:spawnnotification', function(pedNumber)

    TriggerEvent('chat:addMessage' , {
        args = {tostring(pedNumber).. ' peds spawned',}
    })
end)

----------------------------------------------------------------------------------------------

-- Spawn Peds in a line from the direction the camera is facing
RegisterCommand('spawnpedline', function(_, args)
    local pedAmount = tonumber(args[1])
    local camRotation = GetGameplayCamRot(2)
    local camHeading = math.rad(camRotation.z) + math.pi -- Added 180 degrees as it was spawning behind the camera

    if not pedAmount then
        TriggerEvent('chat:addMessage', {
            args = { 'Invalid ped amount. Please input a number', },
        })
        return
    end

    if pedAmount <= 0 or pedAmount > maxPeds then
        TriggerEvent('chat:addMessage', {
            args = { 'Number of peds must be greater than 0 and less than ' .. maxPeds, },
        })
        return
    end 

    TriggerServerEvent('PedInteraction:spawnpedline', pedAmount, camHeading)
end)

----------------------------------------------------------------------------------------------

-- Spawn Peds in a radius around player
RegisterCommand('spawnpedradius', function(_, args)
    local pedAmount = tonumber(args[1])

    if not pedAmount then
        TriggerEvent('chat:addMessage', {
            args = { 'Invalid ped amount. Please input a number', },
        })
        return
    end 

    if pedAmount <= 0 or pedAmount > maxPeds then
        TriggerEvent('chat:addMessage', {
            args = { 'Number of peds must be greater than 0 and less than ' .. maxPeds, },
        })
        return
    end 

    TriggerServerEvent('PedInteraction:spawnpedradius', pedAmount)
end)

----------------------------------------------------------------------------------------------

-- Explode all NPC Peds in a radius around the player
RegisterCommand('explodepeds', function(_, args)
    local pedRadius = tonumber(args[1])

    if not pedRadius then 
        TriggerEvent('chat:addMessage', {
            args = { 'Invalid radius. Please input a number', },
        })
        return
    end 

    if pedRadius <= 0 then
        TriggerClientEvent('chat:addMessage', playerId {
            args = { 'Radius must be greater than 0', },
        })
        return
    end

    TriggerServerEvent('PedInteraction:explodepeds', pedRadius)
end)

----------------------------------------------------------------------------------------------

-- Ignite all NPC Peds in a radius around the player
RegisterCommand('ignitepeds', function(_, args)
    local pedRadius = tonumber(args[1])

    if not pedRadius then 
        TriggerEvent('chat:addMessage', {
            args = { 'Invalid radius. Please input a number', },
        })
        return
    end 

    if pedRadius <= 0 then
        TriggerClientEvent('chat:addMessage', playerId {
            args = { 'Radius must be greater than 0', },
        })
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
            --print("Player Position: " .. tostring(playerPos) .. " | Ped Position: " .. tostring(pedPos) .. " | Distance: " .. tostring(distance))
            if distance <= pedRadius then
                AddExplosion(pedPos.x, pedPos.y, pedPos.z, 8, 2, true, false, 0)
                SetEntityHealth(ped, 0)
                explodeCount = explodeCount + 1
            end
        end
    end
    TriggerEvent('chat:addMessage' , {
        args = {explodeCount .. ' peds exploded',}
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
    local maxIgnitePeds = 100
    local igniteCount = 0

    for i = 1, #peds do
        local ped = peds[i]
        local isDead = IsPedDeadOrDying(ped, false)

        if ped ~= playerPed and not IsPedAPlayer(ped) and not isDead and not IsEntityOnFire(ped) then
            local pedPos = GetEntityCoords(ped)
            local distance = #(playerPos - pedPos)
            if distance <= pedRadius then
                table.insert(pedsToIgnite, ped)
            end
        end
    end

    table.sort(pedsToIgnite, function(a, b) return GetDistanceBetweenCoords(playerPos, GetEntityCoords(a), true) < GetDistanceBetweenCoords(playerPos, GetEntityCoords(b), true) end)

    CreateThread(function()
        local batchSize = 10
        local batchDelay = 300
        for i = 1, #pedsToIgnite, batchSize do
            for j = i, math.min(i + batchSize - 1, #pedsToIgnite) do
                StartEntityFire(pedsToIgnite[j])
                igniteCount = igniteCount + 1
            end
            Wait(batchDelay)
        end
    
        TriggerEvent('chat:addMessage' , {
            args = {igniteCount .. ' peds ignited',}
        })
    end)
end)

----------------------------------------------------------------------------------------------

-- Event for ped debug
local isActive = false
RegisterNetEvent('PedInteraction:debug')
AddEventHandler('PedInteraction:debug', function(pedRadius)
    isActive = not isActive
    if isActive then
        TriggerEvent('chat:addMessage' , {
            args = {'Ped debug started',}
        })

        CreateThread(function()
            while isActive do
                local playerPed = PlayerPedId()
                local playerPos = GetEntityCoords(playerPed)
                local peds = GetGamePool('CPed')
                local pedAmount = 0

                for i = 1, #peds do
                    local ped = peds[i]

                    if ped ~= playerPed and not IsPedAPlayer(ped) then
                        local pedPos = GetEntityCoords(ped)
                        local distance = #(playerPos - pedPos)
                        if distance <= pedRadius then
                            DrawMarker(28, pedPos.x, pedPos.y, pedPos.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                            pedAmount = pedAmount + 1
                        end
                    end
                end
        
                ShowMissionText('Peds detected in radius (~y~' .. pedRadius .. '~s~): ~r~' .. pedAmount .. '~s~', 50)
                --ShowNotif('Current spawned ped count: ~r~' .. #currentSpawnedPeds .. '~s~', 140, false, false)
                Wait(2)
            end
        end)

        CreateThread(function()
            while isActive do
                ShowNotif('Current spawned ped count: ~r~' .. #currentSpawnedPeds .. '~s~', 140, false, false)
                Wait(10)
            end
        end)

    else
        TriggerEvent('chat:addMessage' , {
            args = {'Ped debug stopped',}
        })
    end
end)
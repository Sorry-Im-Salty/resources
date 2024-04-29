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

function EnsureModelIsLoaded(models)
    for _, model in ipairs(models) do
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
    end
end

----------------------------------------------------------------------------------------------

-- Event for spawning peds
RegisterNetEvent('PedInteraction:spawnped')
AddEventHandler('PedInteraction:spawnped', function(x, y, z, heading)

    EnsureModelIsLoaded(pedModels)

    local model = pedModels[math.random(#pedModels)]
    local ped = CreatePed(0, model, x, y, z, heading, true, true)
    
    if not DoesEntityExist(ped) then
        TriggerEvent('chat:addMessage' , {
            args = {'Ped creation failed',}
        })
    end

    SetPedRandomComponentVariation(ped, true)
    SetPedAsNoLongerNeeded(ped)
    SetModelAsNoLongerNeeded(model)
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

    if pedAmount <= 0 or pedAmount >= 500 then
        TriggerEvent('chat:addMessage', {
            args = { 'Number of peds must be greater than 0 and less than 500', },
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

    if pedAmount <= 0 or pedAmount >= 500 then
        TriggerEvent('chat:addMessage', {
            args = { 'Number of peds must be greater than 0 and less than 500', },
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
    local playerPos = GetEntityCoords()
    local peds = GetGamePool('CPed')
    local explodeCount = 0

    for i = 1, #peds do
        local ped = peds[i]
        local isDead = IsPedDeadOrDying(ped, false)
        if ped ~= playerPed and not IsPedAPlayer(ped) and not isDead then
            local pedPos = GetEntityCoords(ped)
            local distance = #(playerPos - pedPos)

            if distance <= pedRadius * 1000 then
                local xPos = pedPos.x
                local yPos = pedPos.y
                local zPos = pedPos.z
                AddExplosion(xPos, yPos, zPos, 8, 2, true, false, 0)
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
    local playerPos = GetEntityCoords()
    local peds = GetGamePool('CPed')
    local igniteCount = 0

    for i = 1, #peds do
        local ped = peds[i]
        local isDead = IsPedDeadOrDying(ped, false)

        if ped ~= playerPed and not IsPedAPlayer(ped) and not isDead then
            local pedPos = GetEntityCoords(ped)
            local distance = #(playerPos - pedPos)

            if distance <= pedRadius * 1000 then
                StartEntityFire(ped)
                igniteCount = igniteCount + 1
            end
        end
    end

    TriggerEvent('chat:addMessage' , {
        args = {igniteCount .. ' peds ignited',}
    })
end)

----------------------------------------------------------------------------------------------

-- Event for ped debug
local isActive = false
RegisterNetEvent('PedInteraction:debug')
AddEventHandler('PedInteraction:debug', function(pedRadius)
    isActive = not isActive

    if isActive then
        local playerPed = PlayerPedId()

        TriggerEvent('chat:addMessage' , {
            args = {'Ped debug started',}
        })

        CreateThread(function()
            while isActive do
                local playerPos = GetEntityCoords()
                local peds = GetGamePool('CPed')
                local pedAmount = 1

                for i = 1, #peds do
                    local ped = peds[i]

                    if ped ~= playerPed and not IsPedAPlayer(ped) then
                        local pedPos = GetEntityCoords(ped)
                        local distance = #(playerPos - pedPos)
                        if distance <= pedRadius * 1000 then
                            local bHeight = 1
                            local bWidth = 1
                            local bDepth = 1
                            local x1 = pedPos.x - bWidth / 2
                            local y1 = pedPos.y - bDepth / 2
                            local z1 = pedPos.z
                            local x2 = pedPos.x + bWidth / 2
                            local y2 = pedPos.y + bDepth / 2
                            local z2 = pedPos.z + bHeight
                            DrawBox(x1, y1, z1, x2, y2, z2, 255, 0, 0, 150)
                            pedAmount = pedAmount + 1
                        end
                    end
                end
        
                -- TriggerEvent('chat:addMessage' , {
                --     args = {'Peds detected in radius: ' .. pedAmount,}
                -- })

                Wait(2)
            end
        end)

    else
        TriggerEvent('chat:addMessage' , {
            args = {'Ped debug stopped',}
        })
    end
end)
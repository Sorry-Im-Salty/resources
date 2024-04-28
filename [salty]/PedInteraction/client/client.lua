RegisterCommand('spawnpedline', function(_, args)
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

    TriggerServerEvent('PedInteraction:spawnpedline', pedAmount)
end)

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

RegisterNetEvent('PedInteraction:spawnline')
AddEventHandler('PedInteraction:spawnline', function(pedAmount)
    local playerPed = PlayerPedId()
    local spawnPos = GetEntityCoords(playerPed)

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

    function EnsureModelisLoaded(models)
        for _, model in ipairs(models) do
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(500)
            end
        end
    end

    EnsureModelisLoaded(pedModels)


    TriggerEvent('chat:addMessage' , {
        args = {tostring(pedAmount).. ' peds spawning in a line on player',}
    })

    for i = 1, pedAmount do
        local spawnX = spawnPos.x
        local spawnY = spawnPos.y + i
        local spawnZ = spawnPos.z
        local model = pedModels[math.random(#pedModels)]
        local ped = CreatePed(0, model, spawnX, spawnY, spawnZ, 0, true, false)
        SetPedRandomComponentVariation(ped, true)
        SetPedAsNoLongerNeeded(ped)
        SetModelAsNoLongerNeeded(model)
    end
end)

RegisterNetEvent('PedInteraction:spawnradius')
AddEventHandler('PedInteraction:spawnradius', function(pedAmount)
    local playerPed = PlayerPedId()
    local spawnPos = GetEntityCoords(playerPed)
    local radius = 10

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

    function EnsureModelisLoaded(models)
        for _, model in ipairs(models) do
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(500)
            end
        end
    end

    EnsureModelisLoaded(pedModels)


    TriggerEvent('chat:addMessage' , {
        args = {tostring(pedAmount).. ' peds spawning in a radius around player',}
    })

    for i = 1, pedAmount do
        local angle = math.random() * 360
        local radian = math.rad(angle)
        local randomRadius = math.random() * radius
        local offsetX = math.cos(radian) * randomRadius
        local offsetY = math.sin(radian) * randomRadius
        local spawnX = spawnPos.x + offsetX
        local spawnY = spawnPos.y + offsetY
        local spawnZ = spawnPos.z

        local model = pedModels[math.random(#pedModels)]
        local ped = CreatePed(0, model, spawnX, spawnY, spawnZ, 0, true, false)
        SetPedRandomComponentVariation(ped, true)
        SetPedAsNoLongerNeeded(ped)
        SetModelAsNoLongerNeeded(model)
    end
end)

RegisterNetEvent('PedInteraction:explode')
AddEventHandler('PedInteraction:explode', function(pedRadius)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords()
    local peds = GetGamePool('CPed')

    for i = 1, #peds do
        local ped = peds[i]

        if ped ~= playerPed and not IsPedAPlayer(ped) then
            local pedPos = GetEntityCoords(ped)
            local distance = #(playerPos - pedPos)

            if distance <= pedRadius * 1000 then
                local xPos = pedPos.x
                local yPos = pedPos.y
                local zPos = pedPos.z
                AddExplosion(xPos, yPos, zPos, 8, 2, true, false, 0)
                SetEntityHealth(ped, 0)
            end
        end
    end
end)

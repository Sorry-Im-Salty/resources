RegisterCommand('spawnped', function(_, args)
    local pedAmount = tonumber(args[1])

    if not pedAmount then
        TriggerEvent('chat:addMessage', {
            args = { 'Invalid ped amount. Please input a number', },
        })
        return
    end 

    TriggerServerEvent('PedInteraction:spawnped', pedAmount)
end)

RegisterCommand('explodeped', function(_, args)
    local pedRadius = args[1]

    if not pedRadius then 
        TriggerEvent('chat:addMessage', {
            args = { 'Invalid radius. Please input a number', },
        })
        return
    end 

    TriggerServerEvent('PedInteraction:explodeped', pedRadius)
end)

RegisterNetEvent('PedInteraction:spawn')
AddEventHandler('PedInteraction:spawn', function(pedAmount)
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
        args = {tostring(pedAmount).. ' peds spawning on client',}
    })

    for i = 1, pedAmount do
        local model = pedModels[math.random(#pedModels)]
        local ped = CreatePed(0, model, spawnPos.x, spawnPos.y + i, spawnPos.z, 0, true, false)
        SetPedRandomComponentVariation(ped, true)
        SetPedAsNoLongerNeeded(ped)
        SetModelAsNoLongerNeeded(model)
    end
end)
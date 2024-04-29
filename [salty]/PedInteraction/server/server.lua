RegisterNetEvent('PedInteraction:spawnpedline', function(pedAmount)
    local playerId = source
    local pedNumber = tonumber(pedAmount)

    TriggerClientEvent('PedInteraction:spawnline', playerId, pedNumber)
end)

RegisterNetEvent('PedInteraction:spawnpedradius', function(pedAmount)
    local playerId = source
    local pedNumber = tonumber(pedAmount)

    TriggerClientEvent('PedInteraction:spawnradius', playerId, pedNumber)
end)

RegisterNetEvent('PedInteraction:explodepeds', function(pedRadius)
    local playerId = source
    local radius = tonumber(pedRadius)

    TriggerClientEvent('PedInteraction:explode', playerId, radius)
end)

RegisterNetEvent('PedInteraction:ignitepeds', function(pedRadius)
    local playerId = source
    local radius = tonumber(pedRadius)

    TriggerClientEvent('PedInteraction:ignite', playerId, radius)
end)

RegisterNetEvent('PedInteraction:debugped', function(pedRadius)
    local playerId = source
    local radius = tonumber(pedRadius)

    if not radius or radius < 10 then
        radius = 10
    elseif radius > 100 then
        radius = 100
    end

    TriggerClientEvent('PedInteraction:debug', playerId, radius)
end)
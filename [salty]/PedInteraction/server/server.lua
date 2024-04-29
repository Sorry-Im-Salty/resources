-- Spawn Line
RegisterServerEvent('PedInteraction:spawnpedline')
AddEventHandler('PedInteraction:spawnpedline', function(pedAmount)
    local playerId = source
    local pedNumber = tonumber(pedAmount)
    local spawnPos = GetEntityCoords(GetPlayerPed(playerId))
    local heading = GetEntityHeading(GetPlayerPed(playerId))

    for i = 1, pedNumber do
        local offsetX = math.cos(math.rad(heading)) * i
        local offsetY = math.sin(math.rad(heading)) * i
        TriggerClientEvent('PedInteraction:spawnped', playerId, spawnPos.x + offsetX, spawnPos.y - offsetY, spawnPos.z, heading)
    end

    TriggerClientEvent('PedInteraction:spawnnotification', playerId, pedNumber)
end)

----------------------------------------------------------------------------------------------

-- Spawn Radius
RegisterNetEvent('PedInteraction:spawnpedradius', function(pedAmount)
    local playerId = source
    local pedNumber = tonumber(pedAmount)

    TriggerClientEvent('PedInteraction:spawnradius', playerId, pedNumber)
end)

----------------------------------------------------------------------------------------------

-- Explode
RegisterNetEvent('PedInteraction:explodepeds', function(pedRadius)
    local playerId = source
    local radius = tonumber(pedRadius)

    TriggerClientEvent('PedInteraction:explode', playerId, radius)
end)

----------------------------------------------------------------------------------------------

-- Ignite
RegisterNetEvent('PedInteraction:ignitepeds', function(pedRadius)
    local playerId = source
    local radius = tonumber(pedRadius)

    TriggerClientEvent('PedInteraction:ignite', playerId, radius)
end)

----------------------------------------------------------------------------------------------

-- Debug
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
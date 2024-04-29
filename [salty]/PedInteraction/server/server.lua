-- Spawn Line
RegisterServerEvent('PedInteraction:spawnpedline')
AddEventHandler('PedInteraction:spawnpedline', function(pedAmount, camHeading)
    local playerId = source
    local pedNumber = tonumber(pedAmount)
    local spawnPos = GetEntityCoords(GetPlayerPed(playerId))

    for i = 1, pedNumber do
        local offsetX = math.sin(camHeading) * i
        local offsetY = math.cos(camHeading) * i

        --print("Offset X: " .. offsetX .. " Offset Y: " .. offsetY)
        TriggerClientEvent('PedInteraction:spawnped', playerId, spawnPos.x + offsetX, spawnPos.y - offsetY, spawnPos.z, camHeading)
    end

    TriggerClientEvent('PedInteraction:spawnnotification', playerId, pedNumber)
end)

----------------------------------------------------------------------------------------------

-- Spawn Radius
RegisterServerEvent('PedInteraction:spawnpedradius')
AddEventHandler('PedInteraction:spawnpedradius', function(pedAmount)
    local playerId = source
    local pedNumber = tonumber(pedAmount)
    local spawnPos = GetEntityCoords(GetPlayerPed(playerId))
    local radius = 10

    for i = 1, pedNumber do
        local angle = math.random() * 360
        local radian = math.rad(angle)
        local randomRadius = math.random() * radius
        local offsetX = math.sin(radian) * randomRadius
        local offsetY = math.cos(radian) * randomRadius
  
        TriggerClientEvent('PedInteraction:spawnped', playerId, spawnPos.x + offsetX, spawnPos.y - offsetY, spawnPos.z, 0)
    end

    TriggerClientEvent('PedInteraction:spawnnotification', playerId, pedNumber)
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
    elseif radius > 500 then
        radius = 500
    end

    TriggerClientEvent('PedInteraction:debug', playerId, radius)
end)
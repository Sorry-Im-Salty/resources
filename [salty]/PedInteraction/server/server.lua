-- Spawn Line
RegisterServerEvent('PedInteraction:spawnpedline')
AddEventHandler('PedInteraction:spawnpedline', function(pedAmount, camHeading)
    local playerId = source
    local pedNumber = tonumber(pedAmount)
    local spawnPos = GetEntityCoords(GetPlayerPed(playerId))

    for i = 1, pedNumber do
        local offsetX = math.sin(camHeading) * i -- Generates an offset based on the direction of the camera.
        local offsetY = math.cos(camHeading) * i -- Generates an offset based on the direction of the camera.

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
        local angle = math.random() * 360 -- Generates a random angle in degrees.
        local radian = math.rad(angle) -- Conversion from degrees to radians.
        local randomRadius = math.random() * radius -- Converts to a random distance from the player within the specified radius.
        local offsetX = math.sin(radian) * randomRadius -- Generates an offset based on the angle and distance.
        local offsetY = math.cos(radian) * randomRadius -- Generates an offset based on the angle and distance.
  
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

    if not radius then
        radius = 500
    elseif radius < 10 then
        radius = 10
    elseif radius > 500 then
        radius = 500
    end

    TriggerClientEvent('PedInteraction:debug', playerId, radius)
end)

----------------------------------------------------------------------------------------------

-- The hand of god
RegisterCommand('handofgod', function(source, args, rawCommand)
    local playerId = source
    
    TriggerClientEvent('PedInteraction:god', playerId)
end, false)
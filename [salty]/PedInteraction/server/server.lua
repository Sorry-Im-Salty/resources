RegisterNetEvent('PedInteraction:spawnpedline')
AddEventHandler('PedInteraction:spawnpedline', function(pedAmount)
    local playerId = source
    local pedNumber = tonumber(pedAmount)

    TriggerClientEvent('PedInteraction:spawnline', playerId, pedNumber)
end)

RegisterNetEvent('PedInteraction:spawnpedradius', function(pedAmount)
    local playerId = source
    local pedNumber = tonumber(pedAmount)

    TriggerClientEvent('PedInteraction:spawnradius', playerId, pedNumber)
end)

RegisterNetEvent('PedInteraction:explodeped', function(pedRadius)
    local playerId = source
    local radius = tonumber(pedRadius)

    if radius <= 0 then
        TriggerClientEvent('chat:addMessage', playerId {
            args = { 'Radius must be greater than 0', },
        })

        return
    end
end)
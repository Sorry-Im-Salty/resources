RegisterCommand('goto', function(_, args)

    local targetId = args[1]

    if not targetId then
        TriggerEvent('chat:addMessage', {
            args = {'Please provide a target ID.', },


        })

        return
    end        

    TriggerServerEvent('ch_teleporter:goto', targetId)
end)

RegisterCommand('bring', function(_, args)

    local targetId = args[1]

    if not targetId then
        TriggerEvent('chat:addMessage', {
            args = {'Please provide a target ID.', },


        })

        return
    end  

    TriggerServerEvent('ch_teleporter:bring', targetId)
end)
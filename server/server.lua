RegisterNetEvent('Serve_Whiskey')
AddEventHandler('Serve_Whiskey', function (pedServerID)
    TriggerClientEvent('Serve_Whiskey_SendClient', pedServerID)
end)
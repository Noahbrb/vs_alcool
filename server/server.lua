RegisterNetEvent('Serve_Whiskey')
AddEventHandler('Serve_Whiskey', function (pedServerID, playerName)
    TriggerClientEvent('Serve_Whiskey_SendClient', pedServerID, playerName)
end)
--[[
    Déclaration des variables 
]]

local playerId = PlayerPedId()
local playerHasBottle = false
local whiskeyBottle = 'prop_whiskey_bottle'
local hashWhiskeyBottle = GetHashKey(whiskeyBottle)


--[[
    créer la commande pour récupérer une bouteille pleine
]]
RegisterCommand('bottle', function (source, args, rawCommand)
    local playerPos = {
        x= GetEntityCoords(playerId).x,
        y= GetEntityCoords(playerId).y,
        z= GetEntityCoords(playerId).z,
        hdg=GetEntityHeading(playerId),
    }
    playerHasBottle = true
    print(playerHasBottle)

    
    RequestAnimDict('amb@world_human_drinking@beer@male@idle_a')
    while not HasAnimDictLoaded('amb@world_human_drinking@beer@male@idle_a') do
        Wait(100)
    end
    local whiskeyBottle_spawn = CreateObject(hashWhiskeyBottle, playerPos.x, playerPos.y, playerPos.z, true, true, true)
    TaskPlayAnim(playerId, 'amb@world_human_drinking@beer@male@idle_a', 'idle_a', 8.0, -8.0, -1, 50, 0, false, false, false)

    Wait(3000)
    DeleteObject(whiskeyBottle_spawn)
end, false)

Citizen.CreateThread(function ()
    while playerHasBottle do
        

        Citizen.Wait(1)
    end
end)
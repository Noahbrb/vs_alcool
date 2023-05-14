---@diagnostic disable: undefined-global
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

    
    RequestAnimDict('amb@world_human_drinking@coffee@male@idle_a')
    while not HasAnimDictLoaded('amb@world_human_drinking@coffee@male@idle_a') do
        Wait(100)
    end
    whiskeyBottle_spawn = CreateObject(hashWhiskeyBottle, playerPos.x, playerPos.y, playerPos.z, true, true, true)
    TaskPlayAnim(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', 8.0, -8.0, -1, 50, 0, false, false, false)
    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, playerPos.hdg, 3.0, 3.0, -1, 50, 1.0, 0, 0)
    
    
    
    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.0,0.0,-0.1,0.0,0.0,0.0,1,1,0,1,0,1)
    Wait(3000)
    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.0,0.0,-0.2,0.0,0.0,0.0,1,1,0,1,0,1)
    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, playerPos.hdg, 3.0, 3.0, -1, 50, 0.7, 0, 0)
    Wait(3000)
    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.0,0.0,-0.1,0.0,0.0,0.0,1,1,0,1,0,1)
end, false)

RegisterCommand('an', function (source, args, rawCommand)
    ClearPedTasks(playerId)
    DeleteEntity(whiskeyBottle_spawn)
end, false)

Citizen.CreateThread(function ()
    while playerHasBottle do
        

        Citizen.Wait(1)
    end
end)
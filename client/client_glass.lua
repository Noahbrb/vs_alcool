--[[
    Déclaration des variables 
]]

local playerId = PlayerPedId()
local playerHasGlass = false
local whiskeyGlass = 'prop_whiskey_01'
local hashWhiskeyGlass = GetHashKey(whiskeyGlass)


--[[
    créer l'event pour récupérer le verre
]]
RegisterNetEvent('Serve_Whiskey_SendClient')
AddEventHandler('Serve_Whiskey_SendClient', function (playerName)

    --Reset des parametres
    playerHasGlass = false
    Wait(10)
    ClearPedTasks(playerId)
    DeleteEntity(whiskeyGlass_spawn)
    items.glass_alcohol.contain = 1
    --

    playerPos = {
        x= GetEntityCoords(playerId).x,
        y= GetEntityCoords(playerId).y,
        z= GetEntityCoords(playerId).z,
        hdg=GetEntityHeading(playerId),
    }
    playerHasGlass = true
    ShowAboveRadarMessage('~b~'..playerName..' est entrain de vous servir')

    
    RequestAnimDict('amb@world_human_drinking@coffee@male@idle_a')
    while not HasAnimDictLoaded('amb@world_human_drinking@coffee@male@idle_a') do
        Wait(100)
    end
    whiskeyGlass_spawn = CreateObject(hashWhiskeyGlass, playerPos.x, playerPos.y, playerPos.z, true, true, true)
    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, playerPos.hdg, 3.0, 3.0, -1, 50, 1.0, 0, 0)
    AttachEntityToEntity(whiskeyGlass_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.05,0.0,0.0,0.0,1,1,0,1,0,1)
    playerActionWithGlass()
end, false)

--[[
Action avec le verre
]]
function playerActionWithGlass()
    Citizen.CreateThread(function ()
        while playerHasGlass do
            ControlHelp("F1 : Boire\nF3 : Jeter le verre")
            --[[
                Action pour boire dans le verre
            ]]
            if IsControlJustPressed(1, 288) then
                if items.glass_alcohol.contain == 0 then
                    ShowAboveRadarMessage('~r~Le verre est vide')
                else
                
                    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, GetEntityHeading(playerId), 3.0, 3.0, -1, 50, 0.7, 0, 0)
                    Citizen.Wait(3500)
                    items.glass_alcohol.contain = items.glass_alcohol.contain-1
                end 
            end

            --[[
                Action pour jeter le verre
            ]]
            if IsControlJustPressed(1, 170) then
                ClearPedTasks(playerId)
                DeleteEntity(whiskeyGlass_spawn)
                playerHasGlass = false
                ShowAboveRadarMessage('~b~Vous avez jeté votre verre !')

                items.glass_alcohol.contain = 1
            end

            Citizen.Wait(1)
        end
    end)
end


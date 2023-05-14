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
    ClearPedTasks(playerId)
    ClearArea(GetEntityCoords(playerId), 0.1, true, false, false, false)
    playerPos = {
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
    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, playerPos.hdg, 3.0, 3.0, -1, 50, 1.0, 0, 0)
    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.1,0.0,0.0,45.0,1,1,0,1,0,1)
    playerActionWithBottle()
end, false)

function playerActionWithBottle()
    Citizen.CreateThread(function ()
        while playerHasBottle do
            --[[
                Action pour boire à la bouteille
            ]]
            if IsControlJustPressed(1, 288) and items.bottle_alcohol.onGround == false then
                if items.bottle_alcohol.contain == 0 then
                    print('La bouteille est vide')
                else
                AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.18,0.0,0.0,45.0,1,1,0,1,0,1)
                TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, GetEntityHeading(playerId), 3.0, 3.0, -1, 50, 0.7, 0, 0)
                Citizen.Wait(3500)
                AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.1,0.0,0.0,45.0,1,1,0,1,0,1)
                items.bottle_alcohol.contain = items.bottle_alcohol.contain-1
                print('il vous reste '..items.bottle_alcohol.contain..' gorgées')

                if items.bottle_alcohol.contain == 0 then
                    print('La bouteille est vide')
                    DeleteEntity(whiskeyBottle_spawn)
                    whiskeyBottle_spawn_empty = CreateObject(GetHashKey('p_whiskey_notop_empty'), playerPos.x, playerPos.y, playerPos.z, true, true, true)
                    AttachEntityToEntity(whiskeyBottle_spawn_empty,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,0.0,0.0,0.0,45.0,1,1,0,1,0,1)
                end
                end 
            end

            --[[
                Action pour jeter la bouteille
            ]]
            if IsControlJustPressed(1, 170) then
                ClearPedTasks(playerId)
                if items.bottle_alcohol.contain == 0 then
                    DeleteEntity(whiskeyBottle_spawn_empty)
                else
                DeleteEntity(whiskeyBottle_spawn)
                end
                items.bottle_alcohol.onGround = false
                playerHasBottle = false
                print(playerHasBottle)

                items.bottle_alcohol = {
                    contain = 8,
                    onGround = false
                }
                
            end

            --[[
                Action pour poser la bouteille
            ]]
            if IsControlJustPressed(1, 311) and items.bottle_alcohol.onGround == false then
                RequestAnimDict("random@domestic")
                while not HasAnimDictLoaded("random@domestic") do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(playerId, "random@domestic", "pickup_low", 8.0, -8.0, -1, 50, 0, false, false, false)
                Citizen.Wait(800)
                DetachEntity(whiskeyBottle_spawn, false, true)

                SetEntityCoords(whiskeyBottle_spawn, GetEntityCoords(whiskeyBottle_spawn).x, 
                GetEntityCoords(whiskeyBottle_spawn).y, 
                GetEntityCoords(whiskeyBottle_spawn).z-GetEntityHeightAboveGround(whiskeyBottle_spawn), 
                0, 0, 0, false)
                SetEntityRotation(whiskeyBottle_spawn, vector3(0.0, 0.0, 90.0))
                ClearPedTasks(playerId)
                items.bottle_alcohol.onGround = true
            end

            Citizen.CreateThread(function ()
                OnGroundBottleCoords = GetEntityCoords(whiskeyBottle_spawn)
                if #(OnGroundBottleCoords - GetEntityCoords(playerId)) < 1.5 and IsControlJustPressed(1, 311) and items.bottle_alcohol.onGround == true then
                    RequestAnimDict("random@domestic")
                    while not HasAnimDictLoaded("random@domestic") do
                        Citizen.Wait(100)
                    end
                    TaskPlayAnim(playerId, "random@domestic", "pickup_low", 8.0, -8.0, -1, 50, 0, false, false, false)
                    Citizen.Wait(800)
                    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.1,0.0,0.0,45.0,1,1,0,1,0,1)
                    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, playerPos.hdg, 3.0, 3.0, -1, 50, 1.0, 0, 0)
                    items.bottle_alcohol.onGround = false                    
                end
            end)

            Citizen.CreateThread(function ()
                if playerHasBottle == true and items.bottle_alcohol.onGround == false then
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local closestPlayer = nil
                    local minDistance = math.huge
            
                    for _, pedID in ipairs(GetActivePlayers()) do
                        if pedID ~= PlayerId() then
                            targetCoords = GetEntityCoords(GetPlayerPed(pedID))
                            distance = #(playerCoords - targetCoords)
                        
                            if distance < minDistance then
                                minDistance = distance
                                closestPlayer = pedID
                            end
                        end
                    end
            
                    if closestPlayer ~= nil and distance <= 1.5 and IsControlJustPressed(1, 38) then
                        if items.bottle_alcohol.contain == 0 then
                            print('La bouteille est vide. Il est impossible de servir cette personne.')
                        else
                            local pedServerID = GetPlayerServerId(closestPlayer)
                            items.bottle_alcohol.contain = items.bottle_alcohol.contain-1
                            TriggerServerEvent('Serve_Whiskey', pedServerID)
                        end
                    end
                end
            end)

            Citizen.Wait(1)
        end
    end)
end





RegisterCommand('an', function (source, args, rawCommand)
    ClearPedTasks(playerId)
    DeleteEntity(whiskeyBottle_spawn)
    playerHasBottle = false
    print(playerHasBottle)
end, false)


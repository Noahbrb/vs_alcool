--[[
    Déclaration des variables 
]]

local playerId = PlayerPedId()
local playerHasBottle = false
local whiskeyBottle = 'prop_whiskey_bottle'
local hashWhiskeyBottle = GetHashKey(whiskeyBottle)
local playerDrinkcount = 0 
local isPlayerDrunk = false
currentBottle = nil


--[[
    créer la commande pour récupérer une bouteille pleine
]]
RegisterCommand('bottle', function (source, args, rawCommand)
    if playerHasBottle == true then
        ShowAboveRadarMessage('~r~Vous avez déjà une bouteille !')
        return
    end
    ClearPedTasks(playerId)

    playerPos = {
        x= GetEntityCoords(playerId).x,
        y= GetEntityCoords(playerId).y,
        z= GetEntityCoords(playerId).z,
        hdg=GetEntityHeading(playerId),
    }
    playerHasBottle = true
    ShowAboveRadarMessage('~b~Vous avez récupéré une bouteille de whiskey !')

    
    RequestAnimDict('amb@world_human_drinking@coffee@male@idle_a')
    while not HasAnimDictLoaded('amb@world_human_drinking@coffee@male@idle_a') do
        Wait(100)
    end
    --Créer l'entité Bouteille, Actionne l'animation et Active les options
    whiskeyBottle_spawn = CreateObject(hashWhiskeyBottle, playerPos.x, playerPos.y, playerPos.z, true, true, true)
    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, playerPos.hdg, 3.0, 3.0, -1, 50, 1.0, 0, 0)
    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.1,0.0,0.0,45.0,1,1,0,1,0,1)
    currentBottle = whiskeyBottle_spawn

    playerActionWithBottle()
end, false)

--[[
    Action avec la bouteille
]]
function playerActionWithBottle()
    Citizen.CreateThread(function ()
        while playerHasBottle do
            ControlHelp("F1 : Boire\nF3 : Jeter la bouteille\nK : Poser/récupérer la bouteille\nE : Servir à boire")
            --[[
                Action pour boire à la bouteille
            ]]
            if IsControlJustPressed(1, 288) and items.bottle_alcohol.onGround == false then
                if items.bottle_alcohol.contain == 0 then
                    ShowAboveRadarMessage('~r~La bouteille est vide')
                else
                    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.18,0.0,0.0,45.0,1,1,0,1,0,1)
                    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, GetEntityHeading(playerId), 3.0, 3.0, -1, 50, 0.7, 0, 0)
                    Citizen.Wait(3500)
                    AttachEntityToEntity(whiskeyBottle_spawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.1,0.0,0.0,45.0,1,1,0,1,0,1)
                    items.bottle_alcohol.contain = items.bottle_alcohol.contain-1
                    ShowAboveRadarMessage('~g~Il vous reste '..items.bottle_alcohol.contain..' gorgées')
                    playerDrinkcount = playerDrinkcount+1
                    isBottleEmpty()
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
                currentBottle = nil
                ShowAboveRadarMessage('~b~Vous avez jeté votre bouteille.')

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

                if items.bottle_alcohol.contain == 0 then
                    -- Si la bouteille est vide :
                    DetachEntity(whiskeyBottle_spawn_empty, false, true)
                    SetEntityCoords(whiskeyBottle_spawn_empty, GetEntityCoords(whiskeyBottle_spawn_empty).x, 
                    GetEntityCoords(whiskeyBottle_spawn_empty).y, 
                    GetEntityCoords(whiskeyBottle_spawn_empty).z-GetEntityHeightAboveGround(whiskeyBottle_spawn_empty)+0.15, 
                    0, 0, 0, false)
                    SetEntityRotation(whiskeyBottle_spawn_empty, vector3(0.0, 0.0, 90.0))
                else
                    --Si la bouteille n'est pas vide
                    DetachEntity(whiskeyBottle_spawn, false, true)
                    SetEntityCoords(whiskeyBottle_spawn, GetEntityCoords(whiskeyBottle_spawn).x, 
                    GetEntityCoords(whiskeyBottle_spawn).y, 
                    GetEntityCoords(whiskeyBottle_spawn).z-GetEntityHeightAboveGround(whiskeyBottle_spawn), 
                    0, 0, 0, false)
                    SetEntityRotation(whiskeyBottle_spawn, vector3(0.0, 0.0, 90.0))
                end


                ClearPedTasks(playerId)
                items.bottle_alcohol.onGround = true
                ShowAboveRadarMessage('~b~La bouteille est par terre.')
            end

            --[[
                Action pour récupérer la bouteille
            ]]
            Citizen.CreateThread(function ()
                OnGroundBottleCoords = GetEntityCoords(currentBottle)
                if #(OnGroundBottleCoords - GetEntityCoords(playerId)) < 1.5 and IsControlJustPressed(1, 311) and items.bottle_alcohol.onGround == true then
                    RequestAnimDict("random@domestic")
                    while not HasAnimDictLoaded("random@domestic") do
                        Citizen.Wait(100)
                    end
                    TaskPlayAnim(playerId, "random@domestic", "pickup_low", 8.0, -8.0, -1, 50, 0, false, false, false)
                    Citizen.Wait(800)
                    if currentBottle == whiskeyBottle_spawn_empty then
                        AttachEntityToEntity(currentBottle,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,0.0,0.0,0.0,45.0,1,1,0,1,0,1)                        
                    else
                        AttachEntityToEntity(currentBottle,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,-0.1,0.0,0.0,45.0,1,1,0,1,0,1)
                    end
                    TaskPlayAnimAdvanced(playerId, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', GetEntityCoords(playerId), 0.0, 0.0, playerPos.hdg, 3.0, 3.0, -1, 50, 1.0, 0, 0)
                    items.bottle_alcohol.onGround = false
                    ShowAboveRadarMessage('~b~Vous avez récupéré la bouteille.')                   
                end
            end)

            --[[
                Action pour servir un joueur
            ]]
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
                            ShowAboveRadarMessage('~r~La bouteille est vide. Il est impossible de servir cette personne.')
                        else
                            local pedServerID = GetPlayerServerId(closestPlayer)
                            local pedServerName = GetPlayerName(closestPlayer)
                            items.bottle_alcohol.contain = items.bottle_alcohol.contain-1
                            ShowAboveRadarMessage('~g~il vous reste '..items.bottle_alcohol.contain..' gorgées')
                            ShowAboveRadarMessage('~b~Vous servez '..pedServerName)
                            isBottleEmpty()
                            TriggerServerEvent('Serve_Whiskey', pedServerID,playerName)
                        end
                    end
                end
            end)

            Citizen.Wait(1)
        end
    end)
end

--[[
    Ajouter un effet au joueur si il boit plus de 8 fois (avec possibilité de l'enlever)
]]
Citizen.CreateThread(function ()
    while true do
        if playerDrinkcount >= 8 and isPlayerDrunk == false then
            SetTimecycleModifier("spectator5")
            ShakeGameplayCam("DRUNK_SHAKE", 1.0)
            RequestAnimSet("move_m@drunk@verydrunk")
            while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                Citizen.Wait(1)
            end
            SetPedMovementClipset(PlayerPedId(), "move_m@drunk@verydrunk", true)

            isPlayerDrunk = true
        end
        Citizen.Wait(1000)
    end
end)

RegisterCommand('undrunk', function ()
    SetTimecycleModifier("default")
    SetPedIsDrunk(PlayerPedId(), false)
    StopGameplayCamShaking()
    ResetPedMovementClipset(PlayerPedId())
    RemoveAnimSet("move_m@drunk@verydrunk")

    playerDrinkcount = 0
    isPlayerDrunk = false
end, false)
items = {
    bottle_alcohol = {
        contain = 8,
        onGround = false
    },
    glass_alcohol = {
        contain = 1,
    }
}

playerParam = {
    playerDrinkcount = 0,
    isPlayerDrunk = false
}

function isBottleEmpty()
    if items.bottle_alcohol.contain == 0 then
        ShowAboveRadarMessage('~r~La bouteille est vide')
        DeleteEntity(whiskeyBottle_spawn)
        whiskeyBottle_spawn_empty = CreateObject(GetHashKey('p_whiskey_notop_empty'), playerPos.x, playerPos.y, playerPos.z, true, true, true)
        AttachEntityToEntity(whiskeyBottle_spawn_empty,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,0.0,0.0,0.0,45.0,1,1,0,1,0,1)
        currentBottle = whiskeyBottle_spawn_empty
    end
end

function ShowAboveRadarMessage(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end

function ControlHelp(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


--Ajouter un effet au joueur si il boit plus de 8 fois (avec possibilité de l'enlever)
function isPlayerDrunk()
    if playerParam.playerDrinkcount >= 8 and playerParam.isPlayerDrunk == false then
        SetTimecycleModifier("spectator5")
        ShakeGameplayCam("DRUNK_SHAKE", 1.0)
        RequestAnimSet("move_m@drunk@verydrunk")
        while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
            Citizen.Wait(1)
        end
        SetPedMovementClipset(PlayerPedId(), "move_m@drunk@verydrunk", true)

        playerParam.isPlayerDrunk = true
    end
end

function unDrunk()
    SetTimecycleModifier("default")
    StopGameplayCamShaking()
    ResetPedMovementClipset(PlayerPedId())
    RemoveAnimSet("move_m@drunk@verydrunk")

    playerParam.playerDrinkcount = 0
    playerParam.isPlayerDrunk = false
end
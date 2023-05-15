items = {
    bottle_alcohol = {
        contain = 8,
        onGround = false
    },
    glass_alcohol = {
        contain = 1,
    }
}

function isBottleEmpty()
    if items.bottle_alcohol.contain == 0 then
        ShowAboveRadarMessage('~r~La bouteille est vide')
        DeleteEntity(whiskeyBottle_spawn)
        whiskeyBottle_spawn_empty = CreateObject(GetHashKey('p_whiskey_notop_empty'), playerPos.x, playerPos.y, playerPos.z, true, true, true)
        AttachEntityToEntity(whiskeyBottle_spawn_empty,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.01,0.0,0.0,0.0,0.0,45.0,1,1,0,1,0,1)
    end
end

function ShowAboveRadarMessage(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end
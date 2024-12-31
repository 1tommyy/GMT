loadouts = {
    ['Basic'] = {
        permission = "police.armoury",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_PDGLOCK20VA5",
        },
    },
    ['SCO-19'] = {
        permission = "police.loadshop2",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_PDGLOCK20VA5",
            "WEAPON_G36GMT",
        },
    },
    ['CTSFO'] = {
        permission = "police.maxarmour",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_PDGLOCK20VA5",
            "WEAPON_SPAR17",
            "WEAPON_REMINGTON700",
            "WEAPON_FLASHBANG",
        },
    },
    ['GMT'] = {
        permission = "police.dev",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_PDGLOCK20VA5",
            "WEAPON_SPAR17",
            "WEAPON_REMINGTON700",
            "WEAPON_FLASHBANG",
        },
    },
}


RegisterNetEvent('GMT:getPoliceLoadouts')
AddEventHandler('GMT:getPoliceLoadouts', function()
    local source = source
    local user_id = GMT.getUserId(source)
    local loadoutsTable = {}
    if GMT.hasPermission(user_id, 'police.armoury') then
        for k,v in pairs(loadouts) do
            v.hasPermission = GMT.hasPermission(user_id, v.permission) 
            loadoutsTable[k] = v
        end
        TriggerClientEvent('GMT:gotLoadouts', source, loadoutsTable)
    end
end)

RegisterNetEvent('GMT:selectLoadout')
AddEventHandler('GMT:selectLoadout', function(loadout)
    local source = source
    local user_id = GMT.getUserId(source)
    for k,v in pairs(loadouts) do
        if k == loadout then
            if GMT.hasPermission(user_id, 'police.armoury') and GMT.hasPermission(user_id, v.permission) then
                for a,b in pairs(v.weapons) do
                    GMTclient.giveWeapons(source, {{[b] = {ammo = 250}}, false, globalpasskey})
                end
                GMT.notify(source, "~g~Received "..loadout.." loadout.")
            else
                GMT.notify(source, "You do not have permission to select this loadout")
            end
        end
    end
end)
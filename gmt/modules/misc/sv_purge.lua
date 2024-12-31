local topFraggers = {} 
local leaderboard = {}
local purgeActive = {}
local playersInPurge = 0

RegisterServerEvent('GMT:getTopFraggers')
AddEventHandler('GMT:getTopFraggers', function()
    SendLeaderboard()
end)

RegisterServerEvent('GMT:purgeActive')
AddEventHandler('GMT:purgeActive', function(value)
    local source = source
    local user_id = GMT.getUserId(source)
    if value then
        purgeActive[user_id] = true
        playersInPurge = playersInPurge + 1
        SetPlayerRoutingBucket(source,666)
        TriggerClientEvent('GMT:purge:catchData', source, playersInPurge,true)
    elseif not value then
        purgeActive[user_id] = nil
        playersInPurge = playersInPurge - 1
        SetPlayerRoutingBucket(source,0)
        GMTclient.ClearWeapons(source,{})
        TriggerClientEvent('GMT:purge:catchData', source, playersInPurge, false)
    else
        GMT.ACBan(15,user_id,"GMT:purgeActive")
    end
end)

RegisterNetEvent('GMT:playerKilled')
AddEventHandler('GMT:playerKilled', function(targetId)
    local playerId = source
    local user_id = GMT.getUserId(playerId)
    if purgeActive[user_id] then
        for i, data in pairs(leaderboard) do
            if data.id == playerId then
                data.kills = data.kills + 1
                UpdatePlayerKills(playerId, data.kills)
                break
            end
        end
        TriggerClientEvent('GMT:updateKills', playerId, data.kills)
    end
end)

function UpdatePlayerKills(playerId, newKills)
    for i, data in pairs(leaderboard) do
        if data.id == playerId then
            data.kills = newKills
            break
        end
    end
    table.sort(leaderboard, function(a, b) return a.kills > b.kills end)
    SendLeaderboard() 
end

function SendLeaderboard()
    TriggerClientEvent('GMT:gotTopFraggers', -1, leaderboard)
end

RegisterCommand("testpurgekills", function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    local name = GMT.getPlayerName(user_id)
    if GMT.isDeveloper(user_id) then
        TriggerEvent('GMT:playerKilled', source, targetId)
    end
end)

RegisterServerEvent('GMT:triggerPurgeSpawn')
AddEventHandler('GMT:triggerPurgeSpawn', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if purgeActive[user_id] then
        TriggerClientEvent('GMT:purgeSpawnClient', source)
    else
        GMT.ACBan(15,user_id,"GMT:triggerPurgeSpawn")
    end
end)

local randomWeapons = {
    'WEAPON_ROOK',
    'WEAPON_MOSIN',
    'WEAPON_COLTM4A1',
    'WEAPON_OLYMPIA',
    'WEAPON_UZI',
    'WEAPON_AK74KASHNAR',
    'WEAPON_G36',
    'WEAPON_REMINGTON870',
    'WEAPON_SPAR17',
    'WEAPON_WINCHESTER12',
    'WEAPON_SPAZ',
    'WEAPON_BERETTA',
    'WEAPON_P90MD',
    'WEAPON_M1911',
    'WEAPON_TEC9',
}

RegisterNetEvent("GMT:purgeClientHasSpawned")
AddEventHandler("GMT:purgeClientHasSpawned", function()
    local source = source
    local user_id = GMT.getUserId(source)
    local randomWeapon = randomWeapons[math.random(1, #randomWeapons)]
    if purgeActive[user_id] then
        GMTclient.giveWeapons(source, {{[randomWeapon] = {ammo = 250}}, false, globalpasskey})
        GMT.notify(source, "~o~Random weapon received!")
        GMTclient.FrontendSound(source, {"Weapon_Upgrade", "DLC_GR_Weapon_Upgrade_Soundset"})
    else
        GMT.ACBan(15,user_id,"GMT:purgeClientHasSpawned")
    end
end)

AddEventHandler("GMT:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        TriggerClientEvent("GMT:purgeAnnounce",source)
        TriggerClientEvent('GMT:purge:catchData', source, playersInPurge,false)
    end
end)

AddEventHandler("playerDropped",function(reason)
    local source = source
    local user_id = GMT.getUserId(source)
    if purgeActive[user_id] then
        purgeActive[user_id] = nil
        playersInPurge = playersInPurge - 1
    end
end)
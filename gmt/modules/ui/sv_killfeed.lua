local killdata = {}
local f = module("cfg/weapons")
f = f.weapons
local illegalWeapons = f.nativeWeaponModelsToNames

local function getWeaponName(weapon)
    for k,v in pairs(f) do
        if weapon == 'Mosin Nagant' then
            return 'Mosin'
        elseif weapon == 'Nerf Mosin' then
            return 'Mosin'
        elseif weapon == 'CB Mosin' then
            return 'Mosin'
        elseif weapon == 'Black Ice Mosin' then
            return 'Mosin'
        elseif weapon == 'Manor Mosin' then
            return 'Mosin'
        elseif weapon == 'Fists' then
            return 'Fist'
        elseif weapon == 'Fire' then
            return 'Fire'
        elseif weapon == 'Explosion' then
            return 'Explode'
        elseif weapon == 'Suicide' then
            return 'Suicide'
        elseif weapon == 'Knife' then
            return 'Knife'
        elseif weapon == 'Pistol' then
            return 'Handgun'
        elseif weapon == 'Shotgun' then
            return 'Shotgun'
        elseif weapon == 'Sniper' then
            return 'Sniper'
        end
        if v.name == weapon then
            return v.class
        end
    end
    return "Unknown"
end

local WeaponCFG = module("cfg/weapons")
WeaponNames = {}

for hash,table in pairs(WeaponCFG.weapons) do
    WeaponNames[hash] = table.name
end

function GetWeaponClass(WeaponHash)
    for _,table in pairs(WeaponCFG.weapons) do
        if table.name == WeaponHash then
            return table.class
        elseif weapon == 'Fists' then
            return 'Fist'
        elseif weapon == 'Fire' then
            return 'Fire'
        elseif weapon == 'Explosion' then
            return 'Explode'
        end
    end
    return "Unknown"
end

local function getweaponnames(weaponHash)
    for k,v in pairs(f) do
        if v.hash == weaponHash then
            return v.name
        end
    end
    return "Unknown"
end

RegisterNetEvent('GMT:KillProcessed')
AddEventHandler('GMT:KillProcessed', function(killid,videodata)
    local source = source
    local user_id = GMT.getUserId(source)
    if not videodata then
        print("Fatal Error videodata is nil? further info\nkillid: "..tostring(killid).."\nuser_id: "..tostring(user_id).."\n"..(killdata[killid] and killdata[killid].killerid or "No killerid found").."\n"..(killdata[killid] and killdata[killid].victimid or "No victimid found"))
        return
    end
    if killdata[killid] and killdata[killid].killerid == user_id then
        GMT.sendDCLog('kills',"GMT Kill Video","> **Killer:** "..GMT.getPlayerName(killdata[killid].killerid).." ["..killdata[killid].killerid.."]\n> **Victim:** "..GMT.getPlayerName(killdata[killid].victimid).." ["..killdata[killid].victimid.."]\n> **Video:** https://discord.com/channels/1319675915747196999/1319676512491802755"..videodata.channel_id.."/"..videodata.id)
    end
end)

RegisterNetEvent('GMT:onPlayerKilled')
AddEventHandler('GMT:onPlayerKilled', function(killtype, killer, weaponhash, suicide, distance)
    local source = source
    local killergroup = 'none'
    local killedgroup = 'none'
    local headShot = false
    local user_id = GMT.getUserId(source)
    local killerID = GMT.getUserId(killer)
    weaponhash = getWeaponName(weaponhash)
    if distance then
        distance = math.floor(distance)
    end
    if killtype == 'killed' then
        if GMT.hasPermission(user_id, 'police.armoury') then
            killedgroup = 'police'
        elseif GMT.hasPermission(user_id, 'nhs.menu') then
            killedgroup = 'nhs'
        end
        if GMT.hasPermission(killerID, 'police.armoury') then
            killergroup = 'police'
        elseif GMT.hasPermission(killerID, 'nhs.menu') then
            killergroup = 'nhs'
        end
        if killer then
            if not GMTclient.InMainEvent(user_id) then
                local killid = #killdata +1
                killdata[killid] = {killerid = killerID,victimid = user_id}
                if killerID ~= user_id then
                    TriggerClientEvent("GMT:takeClientVideoAndUploadKills",killer,GMT.getWebhook('media-cache'),killid)
                end
                headShot = GMT.GetLatestHeadShot(killerID) == user_id
                local bucket = GetPlayerRoutingBucket(source)
                for k,v in pairs(GetPlayers()) do
                    if GetPlayerRoutingBucket(v) == bucket then
                        TriggerClientEvent('GMT:newKillFeed', v, GMT.getPlayerName(killerID), GMT.getPlayerName(user_id), weaponhash, suicide, distance, killedgroup, killergroup, headShot)
                    end
                end
                GMT.sendDCLog('killfeed-logs', "GMT Kill Logs", "> Killer Name: **"..GMT.getPlayerName(killerID).."**\n> Killer ID: **"..GMT.getUserId(killer).."**\n> Weapon: **"..getweaponnames(weaponhash).."**\n> Victim Name: **"..GMT.getPlayerName(source).."**\n> Victim ID: **"..GMT.getUserId(source).."**\n> Distance: **"..distance.."m**")
                GMT.AddStat(killerID,"kills",1)
            else
                GMT.ManagePlayerDeath(source,killer,getweaponnames(weaponhash),distance)
            end
            return
        end
    end
    if suicide then
        local bucket = GetPlayerRoutingBucket(source)
        for k,v in pairs(GetPlayers()) do
            if GetPlayerRoutingBucket(v) == bucket then
                TriggerClientEvent('GMT:newKillFeed', v, GMT.getPlayerName(user_id), GMT.getPlayerName(user_id), 'suicide', suicide, distance, killedgroup, killergroup)
            end
        end
    end
    TriggerEvent("GMT:playerKilled", source, killerID)
    TriggerClientEvent('GMT:deathSound', -1, GetEntityCoords(GetPlayerPed(source)))
    GMT.AddStat(user_id,"deaths",1)
end)

AddEventHandler('weaponDamageEvent', function(sender, ev)
    local user_id = GMT.getUserId(sender)
    local name = GMT.getPlayerName(user_id)
    if user_id then
        if ev.weaponDamage ~= 0 then
            if ev.weaponType == 911657153 and not GMT.hasPermission(user_id, 'police.armoury') or ev.weaponType == 3452007600 then
                GMT.ACBan(5,user_id,"Using a weapon that is not allowed")
            end
            GMT.sendDCLog('damage-logs', "GMT Damage Logs", "> Player Name: **"..name.."**\n> Player Temp ID: **"..sender.."**\n> Player Perm ID: **"..user_id.."**\n> Damage: **"..ev.weaponDamage.."**\n> Weapon : **"..getweaponnames(ev.weaponType).."**")
        end
    end
end)

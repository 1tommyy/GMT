local playersInOrganHeist = {}
local timeTillOrgan = 0
local inWaitingStage = false
local inGamePhase = false
local policeInGame = 0
local civsInGame = 0
local cfg = module('cfg/cfg_organheist')


RegisterNetEvent("GMT:joinOrganHeist")
AddEventHandler("GMT:joinOrganHeist",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if not playersInOrganHeist[user_id] then
        if inWaitingStage then
            if GMT.hasPermission(user_id, 'police.armoury') then
                playersInOrganHeist[source] = {type = 'police'}
                policeInGame = policeInGame+1
                TriggerClientEvent('GMT:addOrganHeistPlayer', -1, source, 'police')
                TriggerClientEvent('GMT:teleportToOrganHeist', source, cfg.locations[1].safePositions[math.random(2)], timeTillOrgan, 'police', 1)
                GMT.sendDCLog('organ-tp', 'GMT Organ Logs', "> Player Name: **"..GMT.getPlayerName(GMT.getUserId(user_id)).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Status: **Joined Police**")
            elseif GMT.hasPermission(user_id, 'nhs.menu') then
                GMT.notify(source, 'You cannot enter Organ Heist whilst clocked on NHS.')
            else
                playersInOrganHeist[source] = {type = 'civ'}
                civsInGame = civsInGame+1
                TriggerClientEvent('GMT:addOrganHeistPlayer', -1, source, 'civ')
                TriggerClientEvent('GMT:teleportToOrganHeist', source, cfg.locations[2].safePositions[math.random(2)], timeTillOrgan, 'civ', 2)
                GMTclient.giveWeapons(source, {{['WEAPON_ROOK'] = {ammo = 250}}, false, globalpasskey})
                GMT.sendDCLog('organ-tp', 'GMT Organ Logs', "> Player Name: **"..GMT.getPlayerName(GMT.getUserId(user_id)).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Status: **Joined Civ**")
            end
            GMT.setBucket(source, 15)
            GMTclient.setArmour(source, {100, true})
        else
            GMT.notify(source, 'The organ heist has already started.')
        end
    end
end)

RegisterNetEvent("GMT:diedInOrganHeist")
AddEventHandler("GMT:diedInOrganHeist",function(killer)
    local source = source
    if playersInOrganHeist[source] then
        if GMT.getUserId(killer) then
            local killerID = GMT.getUserId(killer)
            GMT.giveBankMoney(killerID, 25000)
            TriggerClientEvent('GMT:organHeistKillConfirmed', killer, GMT.getPlayerName(GMT.getUserId(source)))
        end
        TriggerClientEvent('GMT:endOrganHeist', source)
        TriggerClientEvent('GMT:removeFromOrganHeist', -1, source)
        GMT.setBucket(source, 0)
        playersInOrganHeist[source] = nil
        GMT.sendDCLog('organ-tp', 'GMT Organ Logs', "> Player Name: **"..GMT.getPlayerName(GMT.getUserId(source)).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..GMT.getUserId(source).."**\n> Killer: **" ..GMT.getPlayerName(killerID).. "**\n> Status: **Died in organ**")
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    if playersInOrganHeist[source] then
        playersInOrganHeist[source] = nil
        TriggerClientEvent('GMT:removeFromOrganHeist', -1, source)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local time = os.date("*t")
        if inGamePhase then
            local policeAlive = 0
            local civAlive = 0
            for k,v in pairs(playersInOrganHeist) do
                if v.type == 'police' then
                    policeAlive = policeAlive + 1
                elseif v.type == 'civ' then
                    civAlive = civAlive +1
                end
            end
            if policeAlive == 0 or civAlive == 0 then
                for k,v in pairs(playersInOrganHeist) do
                    if policeAlive == 0 then
                        TriggerClientEvent('GMT:endOrganHeistWinner', k, 'Civillians')
                    elseif civAlive == 0 then
                        TriggerClientEvent('GMT:endOrganHeistWinner', k, 'Police')
                    end
                    TriggerClientEvent('GMT:endOrganHeist', k)
                    GMT.setBucket(k, 0)
                    GMT.giveBankMoney(GMT.getUserId(k), 250000)
                    GMT.sendDCLog('organ-tp', 'GMT Organ Logs', "> Player Name: **"..GMT.getPlayerName(GMT.getUserId(k)).."**\n> Player TempID: **"..k.."**\n> Player PermID: **"..GMT.getUserId(k).."**\n> Status: **Ended, Winners rewarded £250k**")
                end
                playersInOrganHeist = {}
                inWaitingStage = false
                inGamePhase = false
            end
        else
            if timeTillOrgan > 0 then
                timeTillOrgan = timeTillOrgan - 1
            end
            if tonumber(time["hour"]) == 18 and tonumber(time["min"]) >= 50 and tonumber(time["sec"]) == 0 then
                TriggerClientEvent("GMT:ReadyForOrgan", -1)
                inWaitingStage = true
                timeTillOrgan = ((60-tonumber(time["min"]))*60)
                TriggerClientEvent('chatMessage', -1, "^7Organ Heist begins in "..math.floor((timeTillOrgan/60)).." minutes! Make your way to the Morgue with a weapon!", { 128, 128, 128 }, message, "alert")
            elseif tonumber(time["hour"]) == 19 and tonumber(time["min"]) == 00 and tonumber(time["sec"]) == 0 then
                if civsInGame > 0 and policeInGame > 0 then
                    TriggerClientEvent('GMT:startOrganHeist', -1)
                    inGamePhase = true
                    inWaitingStage = false
                    GMT.sendDCLog('organ-tp', 'GMT Organ Logs', "> Player Name: **"..GMT.getPlayerName(GMT.getUserId(k)).."**\n> Player TempID: **"..k.."**\n> Player PermID: **"..GMT.getUserId(k).."**\n> Status: **Organ heist has begun!**")
                else
                    for k,v in pairs(playersInOrganHeist) do
                        TriggerClientEvent('GMT:endOrganHeist', k)
                        GMT.notify(k, 'Organ Heist was cancelled as not enough players joined.')
                        SetEntityCoords(GetPlayerPed(k), 240.31098937988, -1379.8699951172, 33.741794586182)
                        GMT.setBucket(k, 0)
                        GMT.sendDCLog('organ-tp', 'GMT Organ Logs', "> Player Name: **"..GMT.getPlayerName(GMT.getUserId(k)).."**\n> Player TempID: **"..k.."**\n> Player PermID: **"..GMT.getUserId(k).."**\n> Status: **Cancelled not enough players joined**")
                    end
                end
            end
        end
    end
end)

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    if first_spawn and inWaitingStage then
        Citizen.Wait(5000)
        GMT.notify(source, '~g~Organ Heist is in its waiting stage, Use /tporgan.') -- 
    end
end)
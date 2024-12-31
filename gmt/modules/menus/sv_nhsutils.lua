local bodyBags = {}

RegisterServerEvent("GMT:requestBodyBag")
AddEventHandler('GMT:requestBodyBag', function(playerToBodyBag)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('GMT:placeBodyBag', playerToBodyBag)
        GMT.AddStat(user_id,"bodybagged",1)
    end
end)

RegisterServerEvent("GMT:removeBodybag")
AddEventHandler('GMT:removeBodybag', function(bodybagObject)
    local source = source
    local user_id = GMT.getUserId(source)
    TriggerClientEvent('GMT:removeIfOwned', -1, NetworkGetEntityFromNetworkId(bodybagObject))
end)

RegisterServerEvent("GMT:playNhsSound")
AddEventHandler('GMT:playNhsSound', function(sound)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('GMT:clientPlayNhsSound', -1, GetEntityCoords(GetPlayerPed(source)), sound)
    else
        GMT.ACBan(15,user_id,"GMT:playNhsSound")
    end
end)

-- a = coma
-- c = userid
-- b = permid
-- 4th ready to revive
-- name

local lifePaksConnected = {}

RegisterServerEvent("GMT:attachLifepakServer")
AddEventHandler('GMT:attachLifepakServer', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'nhs.menu') then
        GMTclient.getNearestPlayer(source, {3}, function(nplayer)
            local nuser_id = GMT.getUserId(nplayer)
            if nuser_id then
                GMTclient.isInComa(nplayer, {}, function(in_coma)
                    TriggerClientEvent('GMT:attachLifepak', source, in_coma, nuser_id, nplayer, GMT.getPlayerName(nuser_id))
                    lifePaksConnected[user_id] = {permid = nuser_id} 
                end)
            else
                GMT.notify(source, "~r~There is no player nearby")
            end
        end)
    else
        GMT.ACBan(15,user_id,"GMT:attachLifepakServer")
    end
end)


RegisterServerEvent("GMT:finishRevive")
AddEventHandler('GMT:finishRevive', function(permid)
    local source = source
    local user_id = GMT.getUserId(source)
    local nuser_id = GMT.getUserSource(permid)
    if GMT.hasPermission(user_id, 'nhs.menu') then 
        for k,v in pairs(lifePaksConnected) do
            if k == user_id and v.permid == permid then
                TriggerClientEvent('GMT:returnRevive', source)
                lifePaksConnected[k] = nil
                TriggerClientEvent('GMT:attemptCPR', source)
                Wait(15000)
                GMT.giveBankMoney(user_id, 5000)
                TriggerClientEvent('TriggerTazer', nuser_id)
                GMT.notify(source, "~g~Successfully shocked patient " .. GMT.getPlayerName(permid) .. "!")
                TriggerClientEvent('GMT:cancelCPRAttempt', source)
                GMTclient.RevivePlayer(nuser_id, {})
                GMT.notify(nuser_id, "~g~You have been medically treated. Please remember to thank the NHS!")
                GMT.AddStat(user_id,"revives",1)
                GMT.sendDCLog('nhs-cpr', 'GMT NHS CPR Logs',"> NHS Name: **"..GMT.getPlayerName(user_id).."**\n> NHS TempID: **"..source.."**\n> NHS PermID: **"..user_id.."**\n> Paitent PermID: **"..permid.."**")
            end
        end
    else
        GMT.ACBan(15,user_id,"GMT:finishRevive")
    end
end)


RegisterServerEvent("GMT:nhsRevive") -- nhs radial revive
AddEventHandler('GMT:nhsRevive', function(playersrc)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'nhs.menu') then
        GMTclient.isInComa(playersrc, {}, function(in_coma)
            if in_coma then
                TriggerClientEvent('GMT:beginRevive', source, in_coma, GMT.getUserId(playersrc), playersrc, GMT.getPlayerName(GMT.getUserId(playersrc)))
                lifePaksConnected[user_id] = {permid = GMT.getUserId(playersrc)} 
            end
        end)
    else
        GMT.ACBan(15,user_id,"GMT:nhsRevive")
    end
end)

local playersInCPR = {}
RegisterServerEvent("GMT:attemptCPR")
AddEventHandler('GMT:attemptCPR', function(playersrc)
    local source = source
    local user_id = GMT.getUserId(source)
    GMTclient.getNearestPlayers(source,{15},function(nplayers)
        if nplayers[playersrc] then
            if GetEntityHealth(GetPlayerPed(playersrc)) > 102 then
                GMT.notify(source, "~r~This person has passed away. and can no longer be saved.")
            else
                playersInCPR[user_id] = true
                TriggerClientEvent('GMT:attemptCPR', source)
                Wait(15000)
                if playersInCPR[user_id] then
                    if GMT.tryGetInventoryItem(user_id,"medkit",1) then
                        GMTclient.RevivePlayer(playersrc, {})
                        GMT.notify(playersrc, "~b~" .. GMT.getPlayerName(GMT.getUserId(source)) .." saved your life with a medkit.")
                        GMT.notify(source, "~b~You saved " .. GMT.getPlayerName(GMT.getUserId(playersrc)) .."'s life.")
                    else
                        local cprChance = math.random(1,5)
                        if cprChance == 1 then -- tayser
                            GMTclient.RevivePlayer(playersrc, {})
                            GMT.notify(playersrc, "~b~" .. GMT.getPlayerName(GMT.getUserId(source)) .." saved your life.")
                            GMT.notify(source, "~b~You saved " .. GMT.getPlayerName(GMT.getUserId(playersrc)) .."'s life.")
                        else
                            GMT.notify(source, '~b~You tried to save this persons life, but you have failed.')
                        end
                        GMT.notify(source, "~r~CPR attempt has been canceled.")
                    end
                    playersInCPR[user_id] = nil
                    TriggerClientEvent('GMT:cancelCPRAttempt', source)
                end
            end
        else
            GMT.notify(source, "Player not found.")
        end
    end)
end)

RegisterServerEvent("GMT:cancelCPRAttempt")
AddEventHandler('GMT:cancelCPRAttempt', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if playersInCPR[user_id] then
        playersInCPR[user_id] = nil
        GMT.notify(source, "~r~CPR attempt has been canceled.")
        TriggerClientEvent('GMT:cancelCPRAttempt', source)
    end
end)

RegisterServerEvent("GMT:syncWheelchairPosition")
AddEventHandler('GMT:syncWheelchairPosition', function(netid, coords, heading)
    local source = source
    local user_id = GMT.getUserId(source)
    entity = NetworkGetEntityFromNetworkId(netid)
    SetEntityCoords(entity, coords.x, coords.y, coords.z)
    SetEntityHeading(entity, heading)
end)

RegisterServerEvent("GMT:wheelchairAttachPlayer")
AddEventHandler('GMT:wheelchairAttachPlayer', function(entity)
    local source = source
    local user_id = GMT.getUserId(source)
    TriggerClientEvent('GMT:wheelchairAttachPlayer', -1, entity, source)
end)
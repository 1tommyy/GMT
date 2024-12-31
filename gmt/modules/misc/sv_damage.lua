local headshots = {}

function GMT.GetLatestHeadShot(user_id)
    if headshots[user_id] then
        return headshots[user_id].lastHit
    end
    return nil
end

RegisterNetEvent("GMT:syncEntityDamage")
AddEventHandler("GMT:syncEntityDamage", function(u, v, t, s, m, n) -- s head
    local source = source
    local user_id = GMT.getUserId(source)
    local user_id2 = GMT.getUserId(t)
    if user_id2 then
        if not headshots[user_id2] then
            headshots[user_id2] = {headshots = 0, bodyshots = 0, lastHit = nil}
        end
        if s then
            headshots[user_id2].headshots = headshots[user_id2].headshots + 1
            headshots[user_id2].lastHit = user_id
        else
            headshots[user_id2].bodyshots = headshots[user_id2].bodyshots + 1
            headshots[user_id2].lastHit = nil
        end
    end
    if user_id ~= user_id2 or not GMT.FetchDisputePlayers(user_id, user_id2) then
        GMT.AddDisputePlayer(user_id2, user_id, GMT.getPlayerName(user_id))
        GMT.AddDisputePlayer(user_id, user_id2, GMT.getPlayerName(user_id2))
    end
    TriggerClientEvent('GMT:onEntityHealthChange', t, GetPlayerPed(source), u, v, s)
end)

AddEventHandler("GMT:playerLeave", function(user_id, source)
    if headshots[user_id] then
        local totalShots = headshots[user_id].headshots + headshots[user_id].bodyshots
        local headshotPercentage = math.floor((headshots[user_id].headshots / totalShots) * 100)
        GMT.sendDCLog('headshot', "GMT HS % Logs", "> Players Perm ID: **"..user_id.."**\n> Total Shots Hit: **"..totalShots.."**\n> Total Headshots: **"..headshots[user_id].headshots.."**\n> Total Headshot Percentage: **"..headshotPercentage.."%**\n> Please keep in mind that these are logs. Please investigate further into high headshot percentages.")
        headshots[user_id] = nil
    end
end)

RegisterCommand("finishoffpill", function(source, args, rawCommand)
    local source = source
    local user_id = GMT.getUserId(source)
    
    if user_id then
        TriggerClientEvent("GMT:eatPill", source)
    end
end, false)

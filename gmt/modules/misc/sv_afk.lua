function getPlayerFaction(user_id)
    if GMT.hasPermission(user_id, 'police.armoury') then
        return 'pd'
    elseif GMT.hasPermission(user_id, 'nhs.menu') then
        return 'nhs'
    elseif GMT.hasPermission(user_id, 'hmp.menu') then
        return 'hmp'
    elseif GMT.hasPermission(user_id, 'lfb.menu') then
        return 'lfb'
    elseif GMT.hasPermission(user_id, 'gang.whitelisted') then
        return 'gang'
    elseif GMT.hasPermission(user_id, 'ukbf.armoury') then
        return 'ukbf'
    elseif GMT.hasPermission(user_id, 'tutorial.user') then
        return 'user'
    end
    return nil
end

RegisterServerEvent('GMT:factionAfkAlert')
AddEventHandler('GMT:factionAfkAlert', function(text)
    local source = source
    local user_id = GMT.getUserId(source)
    if getPlayerFaction(user_id) then
        GMT.sendDCLog(getPlayerFaction(user_id)..'-afk', 'GMT AFK Logs', "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**")
    end
end)

RegisterServerEvent('GMT:setNoLongerAFK')
AddEventHandler('GMT:setNoLongerAFK', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if getPlayerFaction(user_id) then
        GMT.sendDCLog(getPlayerFaction(user_id)..'-afk', 'GMT AFK Logs', "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**")
    end
end)

RegisterServerEvent('kick:AFK')
AddEventHandler('kick:AFK', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if not GMT.hasPermission(user_id, 'group.add') then
        DropPlayer(source, 'You have been kicked for being AFK for too long.')
    end
end)

RegisterServerEvent('kick:PauseMenu')
AddEventHandler('kick:PauseMenu', function()
    local source = source
    local user_id = GMT.getUserId(source)
    DropPlayer(source, 'You have disconnected from GMT.')
end)
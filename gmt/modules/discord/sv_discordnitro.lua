RegisterCommand('craftbmx', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("GMT:spawnNitroBMX", source)
    else
        if GMT.checkForRole(user_id, '1257756376588091452') then
            TriggerClientEvent("GMT:spawnNitroBMX", source)
        end
    end
end)

RegisterCommand('craftmoped', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    GMTclient.isPlatClub(source, {}, function(isPlatClub)
        if GMT.hasPermission(user_id, 'admin.tickets') or isPlatClub or GMT.getUserId() == 1 then -- tayser
            TriggerClientEvent("GMT:spawnMoped", source)
        end
    end)
end)
function CheckDiscordActivity()
    for i = 0, GetNumPlayerIndices() - 1 do
        local source = GetPlayerFromIndex(i)
        local user_id = GMT.getUserId(source)

        if user_id then
            local kickReason = '[GMT] Connection Refused \nReason: Not Present In The Discord \nPlease Contact management if this was a mistake \nUser ID:' .. user_id

            if not GMT.checkForRole(user_id, '1304983610574770268') then
                print("[GMT] Player " .. GMT.getPlayerName(user_id) .. " was not detected in the discord!")
                GMT.sendDCLog('kick-player', 'GMT Kick Logs', "> Player Name: **" .. GMT.getPlayerName(user_id).. "**\n> Player PermID: **" .. user_id .. "**\n> Player TempID: **" .. source .. "**\n> Reason: **Not Detected in the discord**")
                DropPlayer(source, kickReason)
            end
        else
            print("[GMT] No one online to check discord activity.")
        end
    end
end
exports('CheckDiscordActivity', CheckDiscordActivity)

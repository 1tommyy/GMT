RegisterNetEvent('GMT:logWeaponSpawn')
AddEventHandler('GMT:logWeaponSpawn', function(logType, logTitle, weapon)
    local source = source
    local user_id = GMT.getUserId(source)
    local playerName = GMT.getPlayerName(user_id)

    if GMT.hasPermission(user_id, "dev.menu") then
        GMT.sendDCLog(logType, logTitle, "> Player Name: **"..playerName.."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Weapon: **" .. weapon .. "**")
    else
       -- GMT.ACBan(15,user_id,"GMT:logWeaponSpawn")
    end
end)
RegisterServerEvent("GMT:CheckUserId",function(kvpid)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        if user_id ~= kvpid then
            GMT.isBanned(kvpid,function(banned)
                if banned then
                    GMT.banConsole(user_id,"perm","Ban Evading","ID Banned: "..kvpid)
                    GMT.sendDCLog("banevading",GMT.getPlayerName(user_id).." has been banned for ban evading","> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Temp ID: **"..source.."**\n> Perm ID: **"..user_id.."**\n> Ban Evading ID: **"..kvpid.."**")
                end
            end)
        end
    end
end)

RegisterServerEvent("GMT:VerifyUserId",function(id)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        if user_id ~= id then
            GMT.ACBan(15,user_id,"Attempted to change their user id to "..id)
        end
    end
end)
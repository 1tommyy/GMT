local giveerrrors = true

AddEventHandler("GMT:serverIssue",function(errorfile,data)
    print("Server Issue: "..data.." at file: "..errorfile .. "^7")
    if giveerrrors then
        GMT.sendDCLog("server-bug","Server Issue","**Issue at file: **"..errorfile.."\n**Error: **"..data)
    end
end)

RegisterServerEvent("GMT:clientIssue",function(errorfile,data)
    local source = source
    print("Client Issue: "..data.." at file: "..errorfile .. "^7")
    if giveerrrors then
        GMT.sendDCLog("client-bug","Client Issue","Source: "..source.."\n**Issue at file: **"..errorfile.."\n**Error: **"..data)
    end
end)

RegisterCommand("toggleerrors",function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if source == 0 then
        giveerrrors = not giveerrrors
        print("Errors are now "..(giveerrrors and "enabled" or "disabled ^7"))
    end
end)
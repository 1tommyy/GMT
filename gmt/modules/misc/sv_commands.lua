RegisterServerEvent("GMT:AChat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = GMT.getUserId(source)   
    local message = args
    local name = GMT.getPlayerName(user_id)

    if GMT.hasPermission(user_id, "admin.tickets") then
        GMT.sendDCLog('staff', "GMT Chat Logs", "```"..message.."```".."\n> Admin Name: **"..name.."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **"..source.."**")
        for k, v in pairs(GMT.getUsers({})) do
            if GMT.hasPermission(k, 'admin.tickets') then
                TriggerClientEvent('chatMessage', v, "^3Admin Chat | " .. name..": " , { 128, 128, 128 }, message, "ooc", "Admin")
            end
        end
    end
end)
RegisterCommand("a", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("GMT:AChat", source, message)
end)
RegisterServerEvent("GMT:PoliceChat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = GMT.getUserId(source)   
    local message = args
    if GMT.hasPermission(user_id, "police.armoury") then
        local callsign = ""
        if getCallsign('Police', source, user_id, 'Police') then
            callsign = "["..getCallsign('Police', source, user_id, 'Police').."]"
        end
        local playerName =  "^4Police Chat | "..callsign.." "..GMT.getPlayerName(user_id)..": "
        for k, v in pairs(GMT.getUsers({})) do
            if GMT.hasPermission(k, 'police.armoury') then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "Police")
            end
        end
    end
end)

RegisterCommand("p", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("GMT:PoliceChat", source, message)
end)
RegisterCommand("n", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("GMT:Nchat", source, message)
end)

RegisterCommand("g", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("GMT:GangChat", source, message)
end)
RegisterCommand("h", function(source,args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = GMT.getUserId(source)   
    local message = table.concat(args, " ")
    if GMT.hasPermission(user_id, "hmp.menu") or GMT.hasPermission(k, 'police.armoury') then
        local callsign = ""
        if getCallsign('HMP', source, user_id, 'HMP') then
            callsign = "["..getCallsign('HMP', source, user_id, 'HMP').."]"
        end
        local playerName =  "^4HMP Chat | "..callsign.." "..GMT.getPlayerName(user_id)..": "
        for k, v in pairs(GMT.getUsers({})) do
            if GMT.hasPermission(k, 'hmp.menu') or GMT.hasPermission(k, 'police.armoury') then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "HMP")
            end
        end
    end
end)

RegisterServerEvent("GMT:Nchat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = GMT.getUserId(source)   
    local message = args
    if GMT.hasPermission(user_id, "nhs.menu") then
        local playerName =  "^2NHS Chat | "..GMT.getPlayerName(user_id)..": "
        for k, v in pairs(GMT.getUsers({})) do
            if GMT.hasPermission(k, 'nhs.menu') then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "NHS")
            end
        end
    end
end)
RegisterCommand("n", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("GMT:Nchat", source, message)
end)

RegisterServerEvent("GMT:Fchat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = GMT.getUserId(source)   
    local message = args
    if GMT.hasPermission(user_id, "nhs.menu") or GMT.hasPermission(user_id, "hmp.menu") or GMT.hasPermission(user_id, "lfb.menu") or GMT.hasPermission(user_id, "police.armoury") then
        local playerName =  "^2Faction's Chat | "..GMT.getPlayerName(user_id)..": "
        for k, v in pairs(GMT.getUsers({})) do
            if GMT.hasPermission(user_id, "nhs.menu") or GMT.hasPermission(user_id, "hmp.menu") or GMT.hasPermission(user_id, "lfb.menu") or GMT.hasPermission(user_id, "police.armoury") then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "Faction")
            end
        end
    end
end)

RegisterCommand("f", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("GMT:Fchat", source, message)
end)

RegisterCommand("g", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("GMT:GangChat", source, message)
end)
RegisterServerEvent("GMT:GangChat", function(source, message)
    local source = source
    local user_id = GMT.getUserId(source)   
    local msg = message
    local senderName = GMT.getPlayerName(user_id)

    if GMT.hasGroup(user_id,"Gang") then
        local gang = exports['gmt']:executeSync('SELECT gangname FROM gmt_user_gangs WHERE user_id = @user_id', {user_id = user_id})[1].gangname
        if gang then
            exports["gmt"]:execute("SELECT * FROM gmt_user_gangs WHERE gangname = @gangname", {gangname = gang},function(ganginfo)
                for A,B in pairs(ganginfo) do
                    local playersource = GMT.getUserSource(B.user_id)
                    if playersource then
                        TriggerClientEvent('chatMessage',playersource,"^2[" .. B.gangname .. " Chat] " .. senderName ..": ",{ 128, 128, 128 },msg,"ooc", "Gang")
                    end
                end
                GMT.sendDCLog('gang', "GMT Chat Logs", "```"..msg.."```".."\n> Player Name: **"..senderName.."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
            end)
        end
    end
end)


local hour = 3600 

-- RegisterCommand("kit", function(source, args, rawCommand)
--     local user_id = GMT.getUserId(source)
--     local message = ""

--     if user_id then
--         local current_time = os.time()
--         local kit_name = "Mosin Nagant + Max Armour"

--         exports['gmt']:execute('SELECT last_kit_usage FROM gmt_users WHERE id = @id', { id = user_id }, function(kitRows)
--             if kitRows[1] then
--                 local last_kit_usage = kitRows[1].last_kit_usage or 0

--                 if current_time - last_kit_usage >= hour then
--                     exports['gmt']:execute('UPDATE gmt_users SET last_kit_usage = @current_time WHERE id = @id', { current_time = current_time, id = user_id })

--                     GMTclient.giveWeapons(source, {{["WEAPON_MOSIN"] = {ammo = 250}}, false,globalpasskey})
--                     GMTclient.setArmour(source, {100, true})
--                     GMT.notify(source, "~g~Kit Redeemed, Received " .. kit_name .. "")
--                     message = "> Kit Redeemed: **".. kit_name .. "**\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**"
--                 else
--                     local remaining_time = hour - (current_time - last_kit_usage)
--                     GMT.notify(source, "~r~You can only redeem this kit hourly. Please wait " .. math.ceil(remaining_time / 60) .. " minutes.")
--                     message = "> Kit cooldown: **" .. math.ceil(remaining_time / 60) .. " minutes** \n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**"
--                 end
--             else
--                 GMT.notify(source, "~r~Kit not found: " .. kit_name)
--                 message = "> Kit not found: **" .. kit_name .. "**\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**"
--             end
--             GMT.sendDCLog('kit-redeem', "GMT Kit Logs", message)
--         end)
--     end
-- end, false)
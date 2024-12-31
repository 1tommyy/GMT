local tickets = {}
local callID = 0
local cooldown = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for k,v in pairs(cooldown) do
            if cooldown[k].time > 0 then
                cooldown[k].time = cooldown[k].time - 1
            end
        end
    end
end)

for _, command in ipairs({"calladmin", "help"}) do
    RegisterCommand(command, function(source)
        local user_id = GMT.getUserId(source)
        local user_source = GMT.getUserSource(user_id)
        local currentStaff = GMT.getUsersByPermission('admin.tickets')
        for k, v in pairs(cooldown) do
            if k == user_id and v.time > 0 then
                GMT.notify(user_source, "~r~You have already called an admin, please wait 5 minutes before calling again.")
                return
            end
        end
        if #currentStaff >= 0 then
            TriggerClientEvent("GMT:startPhoneAnim", user_source)
            GMT.prompt(user_source, "Please enter a call reason:", "", function(player, reason)
                if reason ~= "" then
                    if #reason >= 10 then
                        callID = callID + 1
                        tickets[callID] = {
                            permID = user_id,
                            name = GMT.getPlayerName(user_id),
                            tempID = user_source,
                            reason = reason,
                            type = 'admin',
                        }
                        cooldown[user_id] = { time = 5 } -- 5 Minutes
                        
                        for k, v in pairs(GMT.getUsers({})) do
                            TriggerClientEvent("GMT:addEmergencyCall", v, callID, GMT.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'admin')
                        end
                        
                        GMT.notify(user_source, "~b~Your request has been sent.")
                       -- GMT.notify(user_source, "~y~If you are reporting a player, you can also create a report @ discord.gg/gmtrp")
                    else
                        GMT.notify(user_source, "~r~Please enter a minimum of 10 characters.")
                    end
                else
                    GMT.notify(user_source, "~r~Please enter a valid reason.")
                end
                TriggerClientEvent("GMT:clearPhoneAnim", user_source)
            end)
        else
            GMT.notify(user_source, "~r~There are no admins online currently to take your request.")
        end
    end)
end

RegisterCommand("999", function(source)
    local user_id = GMT.getUserId(source)
    local user_source = GMT.getUserSource(user_id)
    TriggerClientEvent("GMT:startPhoneAnim", user_source)
    GMT.prompt(user_source, "Please enter call reason: ", "", function(player, reason)
        if reason == "" then
            reason = "Empty Message"
            GMT.notify(user_source, reason)
        end
        callID = callID + 1
        tickets[callID] = {
            name = GMT.getPlayerName(user_id),
            permID = user_id,
            tempID = user_source,
            reason = reason,
            type = 'met'
        }
        for k, v in pairs(GMT.getUsers({})) do
            TriggerClientEvent("GMT:addEmergencyCall", v, callID, GMT.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'met')
        end
        GMT.notify(user_source, "~g~Your message has been placed.")
        TriggerClientEvent("GMT:clearPhoneAnim", user_source)
    end)
end)

RegisterCommand("aa", function(source)
    local user_id = GMT.getUserId(source)
    local user_source = GMT.getUserSource(user_id)
    TriggerClientEvent("GMT:startPhoneAnim", user_source)
    GMT.prompt(user_source, "Enter your message: ", "", function(player, reason)
        if reason == "" then
            reason = "Empty Message"
            GMT.notify(user_source, reason)
        end
        callID = callID + 1
        tickets[callID] = {
            name = GMT.getPlayerName(user_id),
            permID = user_id,
            tempID = user_source,
            reason = reason,
            type = 'aa'
        }
        for k, v in pairs(GMT.getUsers({})) do
            TriggerClientEvent("GMT:addEmergencyCall", v, callID, GMT.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'aa')
        end
        GMT.notify(user_source, "~g~Your message has been placed.")
        TriggerClientEvent("GMT:clearPhoneAnim", user_source)
    end)
end)

RegisterCommand("08001111", function(source)
    local user_id = GMT.getUserId(source)
    local user_source = GMT.getUserSource(user_id)
    TriggerClientEvent("GMT:startPhoneAnim", user_source)
    GMT.prompt(user_source, "Please enter call reason: ", "", function(player, reason)
        if reason ~= "" then
            GMT.notify(user_source, "~b~We are not here for you, Your call is going to get laughed at.")
        else
            GMT.notify(user_source, "~r~Please enter a valid reason.")
        end
        TriggerClientEvent("GMT:clearPhoneAnim", user_source)
    end)
end)


RegisterCommand("111", function(source)
    local user_id = GMT.getUserId(source)
    local user_source = GMT.getUserSource(user_id)
    TriggerClientEvent("GMT:startPhoneAnim", user_source)
    GMT.prompt(user_source, "Please enter call reason: ", "", function(player, reason)
        if reason ~= "" then
            callID = callID + 1
            tickets[callID] = {
                name = GMT.getPlayerName(user_id),
                permID = user_id,
                tempID = user_source,
                reason = reason,
                type = 'nhs'
            }
            for k, v in pairs(GMT.getUsers({})) do
                TriggerClientEvent("GMT:addEmergencyCall", v, callID, GMT.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'nhs')
            end
            GMT.notify(user_source, "~g~Sent NHS Call.")
        else
            GMT.notify(user_source, "~r~Please enter a valid reason.")
        end
        TriggerClientEvent("GMT:clearPhoneAnim", user_source)
    end)
end)

local savedPositions = {}
RegisterCommand("return", function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    pendingFeedback = false
    
    if GMT.hasPermission(user_id, 'admin.tickets') then
        if savedPositions[user_id] then
            pendingFeedback = true
            GMT.setBucket(source, savedPositions[user_id].bucket)
            GMTclient.teleport(source, {table.unpack(savedPositions[user_id].coords)})
            GMT.notify(source, '~g~Returned to position.')
            savedPositions[user_id] = nil
            TriggerClientEvent('GMT:sendTicketInfo', source)
            GMTclient.staffMode(source, {false})
            SetTimeout(1000, function()
                GMTclient.setPlayerCombatTimer(source, {0})
            end)
        else
            GMT.notify(source, "~r~Unable to find the last location.")
        end
    end
end)

RegisterNetEvent("GMT:TakeTicket")
AddEventHandler("GMT:TakeTicket", function(ticketID)
    local user_id = GMT.getUserId(source)
    local admin_source = GMT.getUserSource(user_id)
    if tickets[ticketID] then
        for k, v in pairs(tickets) do
            if ticketID == k then
                if tickets[ticketID].type == 'admin' and GMT.hasPermission(user_id, "admin.tickets") then
                    if GMT.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            local adminbucket = GetPlayerRoutingBucket(admin_source)
                            local playerbucket = GetPlayerRoutingBucket(v.tempID)
                            savedPositions[user_id] = {bucket = adminbucket, coords = GetEntityCoords(GetPlayerPed(admin_source))}
                            if adminbucket ~= playerbucket then
                                GMT.setBucket(admin_source, playerbucket)
                                GMT.notify(admin_source, '~g~Player was in another bucket, you have been set into their bucket.')
                            end
                            GMTclient.getPosition(v.tempID, {}, function(coords)
                                GMTclient.staffMode(admin_source, {true})
                                TriggerClientEvent('GMT:sendTicketInfo', admin_source, v.permID, v.name, v.reason)
                                local ticketPay = 0
                                if GMT.hasGroup(user_id,"Founder") then
                                    ticketPay = 30000
                                elseif GMT.hasGroup(user_id,"Lead Developer") then
                                    ticketPay = 28000
                                elseif GMT.hasGroup(user_id,"Developer") then
                                    ticketPay = 26000
                                elseif GMT.hasGroup(user_id,"Community Manager") then
                                    ticketPay = 25000
                                elseif GMT.hasGroup(user_id,"Staff Manager") then    
                                    ticketPay = 23000
                                elseif GMT.hasGroup(user_id,"Head Administrator") then
                                    ticketPay = 22000
                                elseif GMT.hasGroup(user_id,"Senior Administrator") then
                                    ticketPay = 20000
                                elseif GMT.hasGroup(user_id,"Administrator") then
                                    ticketPay = 19000
                                elseif GMT.hasGroup(user_id,"Senior Moderator") then
                                    ticketPay = 18000
                                elseif GMT.hasGroup(user_id,"Moderator") then
                                    ticketPay = 17000
                                elseif GMT.hasGroup(user_id,"Support Team") then
                                    ticketPay = 15000
                                elseif GMT.hasGroup(user_id,"Trial Staff") then
                                    ticketPay = 10000
                                end
                                exports['gmt']:execute("SELECT * FROM `gmt_staff_tickets` WHERE user_id = @user_id", {user_id = user_id}, function(result)
                                    if result then 
                                        for k,v in pairs(result) do
                                            if v.user_id == user_id then
                                                exports['gmt']:execute("UPDATE gmt_staff_tickets SET ticket_count = @ticket_count, username = @username WHERE user_id = @user_id", {user_id = user_id, ticket_count = v.ticket_count + 1, username = GMT.getPlayerName(user_id)}, function() end)
                                                return
                                            end
                                        end
                                        exports['gmt']:execute("INSERT INTO gmt_staff_tickets (`user_id`, `ticket_count`, `username`) VALUES (@user_id, @ticket_count, @username);", {user_id = user_id, ticket_count = 1, username = GMT.getPlayerName(user_id)}, function() end) 
                                    end
                                end)
                                GMT.giveBankMoney(user_id, ticketPay)
                                GMT.notify(admin_source, "~g~You earned £"..getMoneyStringFormatted(ticketPay).." for being a cutie.")
                                GMT.notify(v.tempID, "~g~An admin has taken your ticket.")
                                TriggerClientEvent('GMT:smallAnnouncement', v.tempID, 'ticket accepted', "Your admin ticket has been accepted by "..GMT.getPlayerName(user_id), 33, 10000)
                                GMT.sendDCLog('adminticket-logs',"GMT Ticket Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..admin_source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..v.name.."**\n> Player PermID: **"..v.permID.."**\n> Player TempID: **"..v.tempID.."**\n> Reason: **"..v.reason.."**")
                                GMTclient.teleport(admin_source, {table.unpack(coords)})
                                TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                                tickets[ticketID] = nil
                                while not pendingFeedback do
                                    Citizen.Wait(0) 
                                end
                                TriggerClientEvent('GMT:adminTicketFeedback', v.tempID, admin_source)
                                pendingFeedback = false
                            end)
                        else
                            GMT.notify(admin_source, "~r~You can't take your own ticket!")
                        end
                    else
                        GMT.notify(admin_source, "~r~You cannot take a ticket from an offline player.")
                        TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                    end
                elseif tickets[ticketID].type == 'met' and GMT.hasPermission(user_id, "police.armoury") then
                    if GMT.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            if v.tempID then
                                GMT.notify(v.tempID, "~b~Your MET Police call has been accepted!")
                            end
                            tickets[ticketID] = nil
                            TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                        else
                            GMT.notify(admin_source, "~r~You can't take your own call!")
                        end
                    else
                        TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                    end
                elseif tickets[ticketID].type == 'aa' and GMT.hasPermission(user_id, "aa.menu") then
                    if GMT.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            if v.tempID then
                                GMT.notify(v.tempID, "~y~An AA Mechanic is enroute to your location.")
                            end
                            tickets[ticketID] = nil
                            TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                        else
                            GMT.notify(admin_source, "~r~You can't take your own call!")
                        end
                    else
                        TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                    end
                elseif tickets[ticketID].type == 'nhs' and GMT.hasPermission(user_id, "nhs.menu") then
                    if GMT.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            GMT.notify(v.tempID, "~g~Your NHS call has been accepted!")
                            tickets[ticketID] = nil
                            TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                        else
                            GMT.notify(admin_source, "~r~You can't take your own call!")
                        end
                    else
                        TriggerClientEvent("GMT:removeEmergencyCall", -1, ticketID)
                    end
                end
            end
        end
    end         
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local user_id = GMT.getUserId(source)
    local hasTicket = false
    for id, ticket in pairs(tickets) do
        if ticket.permID == user_id then
            tickets[id] = nil
            hasTicket = true
            break
        end
    end
end)

AddEventHandler("GMT:PDRobberyCall", function(source, store, position)
    local source = source
    local user_id = GMT.getUserId(source)
    callID = callID + 1
    tickets[callID] = {
        name = 'Store Robbery',
        permID = 999,
        tempID = nil,
        reason = 'Robbery in progress at '..store,
        type = 'met'
    }
    for k, v in pairs(GMT.getUsers({})) do
        TriggerClientEvent("GMT:addEmergencyCall", v, callID, 'Store Robbery', 999, position, 'Robbery in progress at '..store, 'met')
    end
end)

AddEventHandler("GMT:PDHeistRobberyCall", function(source, store, position)
    local source = source
    local user_id = GMT.getUserId(source)
    callID = callID + 1
    tickets[callID] = {
        name = 'Heist Robbery',
        permID = 999,
        tempID = nil,
        reason = 'Robbery in progress at '..store,
        type = 'met'
    }
    for k, v in pairs(GMT.getUsers({})) do
        TriggerClientEvent("GMT:addEmergencyCall", v, callID, 'Heist Robbery', 999, position, 'Robbery in progress at '..store, 'met')
    end
end)

AddEventHandler("GMT:PDTruckingCall", function(source, store, position)
    local source = source
    local user_id = GMT.getUserId(source)
    callID = callID + 1
    tickets[callID] = {
        name = 'Illegal Trucking Activity',
        permID = 999,
        tempID = nil,
        reason = 'Illegal Trucking in progress',
        type = 'met'
    }
    for k, v in pairs(GMT.getUsers({})) do
        TriggerClientEvent("GMT:addEmergencyCall", v, callID, 'Illegal Trucking', 999, position, 'Illegal Trucking in progress', 'met')
    end
end)

RegisterNetEvent("GMT:NHSComaCall")
AddEventHandler("GMT:NHSComaCall", function()
    local user_id = GMT.getUserId(source)
    local user_source = GMT.getUserSource(user_id)
    local reason = 'Immediate Attention'
    callID = callID + 1
    tickets[callID] = {
        name = GMT.getPlayerName(user_id),
        permID = user_id,
        tempID = user_source,
        reason = reason,
        type = 'nhs'
    }
    for k, v in pairs(GMT.getUsers({})) do
        TriggerClientEvent("GMT:addEmergencyCall", v, callID, GMT.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'nhs')
    end
end)
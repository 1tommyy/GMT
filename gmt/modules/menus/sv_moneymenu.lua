RegisterServerEvent("GMT:getUserinformation")
AddEventHandler("GMT:getUserinformation",function(id)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.moneymenu') then
        if not GMT.getUserSource(id) then
            GMT.notify(source, '~r~User is not online')
            return
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                GMT.notify(source, '~g~Managing money for ID: '..id..'.')
                TriggerClientEvent('GMT:receivedUserInformation', source, GMT.getUserSource(id), GMT.getPlayerName(id), math.floor(GMT.getBankMoney(id)), math.floor(GMT.getMoney(id)), chips)
            end
        end)
    else
        GMT.ACBan(15,user_id,"GMT:getUserinformation")
    end
end)

RegisterServerEvent("GMT:ManagePlayerBank")
AddEventHandler("GMT:ManagePlayerBank",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    local userstemp = GMT.getUserSource(id)
    if GMT.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            GMT.giveBankMoney(id, amount)
            GMT.notify(source, "~g~Added £" .. getMoneyStringFormatted(amount) .. " to players Bank Balance.")
            GMT.sendDCLog('manage-balance',"GMT Money Menu Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Bank**\n> Type: **"..cashtype.."**")
        elseif cashtype == 'Decrease' then
            GMT.tryBankPayment(id, amount)
            GMT.notify(source, "~r~Removed £" .. getMoneyStringFormatted(amount) .. " to players Bank Balance.")
            GMT.sendDCLog('manage-balance',"GMT Money Menu Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Bank**\n> Type: **"..cashtype.."**")
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('GMT:receivedUserInformation', source, GMT.getUserSource(id), GMT.getPlayerName(id), math.floor(GMT.getBankMoney(id)), math.floor(GMT.getMoney(id)), chips)
            end
        end)
    else
        GMT.ACBan(15,user_id,"GMT:ManagePlayerBank")
    end
end)

RegisterServerEvent("GMT:ManagePlayerCash")
AddEventHandler("GMT:ManagePlayerCash", function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    local userstemp = GMT.getUserSource(id)

    if GMT.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            if type(amount) == "number" and amount > 0 then
                GMT.giveMoney(id, amount)
                GMT.notify(source, "~g~Added £" .. getMoneyStringFormatted(amount) .. " to players Cash Balance.")
                GMT.sendDCLog('manage-balance', "GMT Money Menu Logs", "> Admin Name: **" .. GMT.getPlayerName(user_id) .. "**\n> Admin TempID: **" .. source .. "**\n> Admin PermID: **" .. user_id .. "**\n> Player Name: **" .. GMT.getPlayerName(id) .. "**\n> Player PermID: **" .. id .. "**\n> Player TempID: **" .. userstemp .. "**\n> Amount: **£" .. amount .. " Cash**\n> Type: **" .. cashtype .. "**")
            else
                GMT.notify(source,  '~r~Invalid amount.' )
            end
        elseif cashtype == 'Decrease' then
            if type(amount) == "number" and amount > 0 and GMT.tryPayment(id, amount) then
                GMT.notify(source, "~r~Removed £" .. getMoneyStringFormatted(amount) .. " to players Cash Balance.")
                GMT.sendDCLog('manage-balance', "GMT Money Menu Logs", "> Admin Name: **" .. GMT.getPlayerName(user_id) .. "**\n> Admin TempID: **" .. source .. "**\n> Admin PermID: **" .. user_id .. "**\n> Player Name: **" .. GMT.getPlayerName(id) .. "**\n> Player PermID: **" .. id .. "**\n> Player TempID: **" .. userstemp .. "**\n> Amount: **£" .. amount .. " Cash**\n> Type: **" .. cashtype .. "**")
            else
                GMT.notify(source,  '~r~Invalid amount or insufficient funds.' )
            end
        end

        MySQL.query("casinochips/get_chips", { user_id = id }, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('GMT:receivedUserInformation', source, GMT.getUserSource(id), GMT.getPlayerName(id), math.floor(GMT.getBankMoney(id)), math.floor(GMT.getMoney(id)), chips)
            end
        end)
    else
        GMT.ACBan(15,user_id,"GMT:ManagePlayerCash")
    end
end)

RegisterServerEvent("GMT:ManagePlayerDirtyCash")
AddEventHandler("GMT:ManagePlayerDirtyCash",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    local userstemp = GMT.getUserSource(id)
    if GMT.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            GMT.giveDirtyCash(id, amount)
            GMT.notify(source, '~g~Added £'..getMoneyStringFormatted(amount)..' to players Dirty Cash Balance.')
            GMT.sendDCLog('manage-balance',"GMT Money Menu Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Dirty Cash**\n> Type: **"..cashtype.."**")
        elseif cashtype == 'Decrease' then
            GMT.tryRedPayment(id, amount)
            GMT.notify(source, '~r~Removed £'..getMoneyStringFormatted(amount)..' from players Dirty Cash Balance.')
            GMT.sendDCLog('manage-balance',"GMT Money Menu Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Dirty Cash**\n> Type: **"..cashtype.."**")
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('GMT:receivedUserInformation', source, GMT.getUserSource(id), GMT.getPlayerName(id), math.floor(GMT.getBankMoney(id)), math.floor(GMT.getMoney(id)), chips)
            end
        end)
    else
        GMT.ACBan(15,user_id,"GMT:ManagePlayerDirtyCash")
    end
end)


RegisterServerEvent("GMT:ManagePlayerChips")
AddEventHandler("GMT:ManagePlayerChips",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    local userstemp = GMT.getUserSource(id)
    if GMT.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            MySQL.execute("casinochips/add_chips", {user_id = id, amount = amount})
            GMT.notify(source, '~g~Added '..getMoneyStringFormatted(amount)..' to players Casino Chips.')
            GMT.sendDCLog('manage-balance',"GMT Money Menu Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **"..amount.." Chips**\n> Type: **"..cashtype.."**")
            MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
                if #rows > 0 then
                    local chips = rows[1].chips
                    TriggerClientEvent('GMT:receivedUserInformation', source, GMT.getUserSource(id), GMT.getPlayerName(id), math.floor(GMT.getBankMoney(id)), math.floor(GMT.getMoney(id)), chips)
                end
            end)
        elseif cashtype == 'Decrease' then
            MySQL.execute("casinochips/remove_chips", {user_id = id, amount = amount})
            GMT.notify(source, '~r~Removed '..getMoneyStringFormatted(amount)..' from players Casino Chips.')
            GMT.sendDCLog('manage-balance',"GMT Money Menu Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **"..amount.." Chips**\n> Type: **"..cashtype.."**")
            MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
                if #rows > 0 then
                    local chips = rows[1].chips
                    TriggerClientEvent('GMT:receivedUserInformation', source, GMT.getUserSource(id), GMT.getPlayerName(id), math.floor(GMT.getBankMoney(id)), math.floor(GMT.getMoney(id)), chips)
                end
            end)
        end
    else
        GMT.ACBan(15,user_id,"GMT:ManagePlayerChips")
    end
end)
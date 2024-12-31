RegisterServerEvent("GMT:getCommunityPotAmount")
AddEventHandler("GMT:getCommunityPotAmount", function()
    local source = source
    local user_id = GMT.getUserId(source)
    exports['gmt']:execute("SELECT value FROM gmt_community_pot", function(potbalance)
        TriggerClientEvent('GMT:gotCommunityPotAmount', source, parseInt(potbalance[1].value))
    end)
end)

RegisterServerEvent("GMT:tryDepositCommunityPot")
AddEventHandler("GMT:tryDepositCommunityPot", function(amount)
    local amount = tonumber(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['gmt']:execute("SELECT value FROM gmt_community_pot", function(potbalance)
            if GMT.tryFullPayment(user_id,amount) then
                local newpotbalance = parseInt(potbalance[1].value) + amount
                exports['gmt']:execute("UPDATE gmt_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
                TriggerClientEvent('GMT:gotCommunityPotAmount', source, newpotbalance)
                GMT.sendDCLog('com-pot', 'GMT Community Pot Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Deposit**\n> Amount: £**"..getMoneyStringFormatted(amount).."**")
            end
        end)
    end
end)

RegisterServerEvent("GMT:tryWithdrawCommunityPot")
AddEventHandler("GMT:tryWithdrawCommunityPot", function(amount)
    local amount = tonumber(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['gmt']:execute("SELECT value FROM gmt_community_pot", function(potbalance)
            if parseInt(potbalance[1].value) >= amount then
                local newpotbalance = parseInt(potbalance[1].value) - amount
                exports['gmt']:execute("UPDATE gmt_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
                TriggerClientEvent('GMT:gotCommunityPotAmount', source, newpotbalance)
                GMT.giveMoney(user_id, amount)
                GMT.sendDCLog('com-pot', 'GMT Community Pot Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Withdraw**\n> Amount: £**"..getMoneyStringFormatted(amount).."**")
            end
        end)
    end
end)

RegisterServerEvent("GMT:distributeCommunityPot")
AddEventHandler("GMT:distributeCommunityPot", function(amountToDistribute)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['gmt']:execute("SELECT value FROM gmt_community_pot", function(potbalance)
            local totalAmount = tonumber(potbalance[1].value)
            amountToDistribute = tonumber(amountToDistribute)
            if totalAmount and amountToDistribute and totalAmount >= amountToDistribute then
                local players = GetPlayers()
                local amountPerPlayer = amountToDistribute / #players
                for i, player in ipairs(players) do
                    GMT.giveBankMoney(GMT.getUserId(player), amountPerPlayer)
                end
                local remainingAmount = totalAmount - amountToDistribute
                GMT.notify(-1, "~g~Received £"..getMoneyStringFormatted(amountPerPlayer).." distributed from the community pot.")
                GMT.notify(source, "~g~Distributed £"..getMoneyStringFormatted(amountPerPlayer).." to all online players.")
                exports['gmt']:execute("UPDATE gmt_community_pot SET value = @value", {['@value'] = remainingAmount})
                TriggerClientEvent('GMT:gotCommunityPotAmount', source, remainingAmount)
                GMT.sendDCLog('com-pot', 'GMT Community Pot Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Distribute**\n> Amount: £**"..getMoneyStringFormatted(amountToDistribute).."**")
            else
                GMT.notify(source, "~r~Not enough money in the community pot.")
            end
        end)
    end
end)

RegisterServerEvent("GMT:addToCommunityPot")
AddEventHandler("GMT:addToCommunityPot", function(amount)
    if source ~= '' then return end
    exports['gmt']:execute("SELECT value FROM gmt_community_pot", function(potbalance)
        local newpotbalance = parseInt(potbalance[1].value) + amount
        exports['gmt']:execute("UPDATE gmt_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
    end)
end)
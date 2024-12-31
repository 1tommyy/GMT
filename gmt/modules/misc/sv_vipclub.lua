MySQL.createCommand("subscription/set_plushours","UPDATE gmt_subscriptions SET plushours = @plushours WHERE user_id = @user_id")
MySQL.createCommand("subscription/set_plathours","UPDATE gmt_subscriptions SET plathours = @plathours WHERE user_id = @user_id")
MySQL.createCommand("subscription/set_lastused","UPDATE gmt_subscriptions SET last_used = @last_used WHERE user_id = @user_id")
MySQL.createCommand("subscription/get_subscription","SELECT * FROM gmt_subscriptions WHERE user_id = @user_id")
MySQL.createCommand("subscription/get_all_subscriptions","SELECT * FROM gmt_subscriptions")
MySQL.createCommand("subscription/add_id", "INSERT IGNORE INTO gmt_subscriptions SET user_id = @user_id, plushours = 0, plathours = 0, last_used = ''")

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:executeSync("INSERT IGNORE INTO gmt_subscriptions SET user_id = @user_id, plushours = 0, plathours = 0, last_used = ''", {user_id = user_id})
end)

function GMT.getSubscriptions(user_id,cb)
    MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
           cb(true, rows[1].plushours, rows[1].plathours, rows[1].last_used)
        else
            cb(false)
        end
    end)
end

RegisterNetEvent("GMT:setPlayerSubscription")
AddEventHandler("GMT:setPlayerSubscription", function(playerid, subtype)
    local source = source
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)
    if GMT.hasGroup(user_id, "Founder") or GMT.hasGroup(user_id, "Lead Developer") or GMT.hasGroup(user_id, "Developer") then
        GMT.prompt(player,"Number of days ","",function(player, hours)
            if tonumber(hours) and tonumber(hours) >= 0 then
                hours = hours * 24
                if subtype == "Plus" then
                    MySQL.asyncQuery("subscription/set_plushours", {user_id = playerid, plushours = hours})
                elseif subtype == "Platinum" then
                    MySQL.asyncQuery("subscription/set_plathours", {user_id = playerid, plathours = hours})
                end
                TriggerClientEvent('GMT:userSubscriptionUpdated', player)
                GMT.getSubscriptions(playerid, function(bool, plushours, plathours, last_used)
                    if not bool then
                        return
                    end
                    if plathours > 0 then
                        GMT.updateInvCap(playerid, 50)
                    elseif plushours > 0 then
                        GMT.updateInvCap(playerid, 40)
                    else
                        GMT.updateInvCap(playerid, 30)
                    end
                end)  
            else
                GMT.notify(player, "~r~Number of days must be a number.")
            end
        end)
    else
        GMT.ACBan(15,user_id,"GMT:setPlayerSubscription")
    end
end)

RegisterNetEvent("GMT:getPlayerSubscription")
AddEventHandler("GMT:getPlayerSubscription", function(playerid)
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)
    if playerid then
        GMT.getSubscriptions(playerid, function(cb, plushours, plathours)
            if cb then
                TriggerClientEvent('GMT:getUsersSubscription', player, playerid, plushours, plathours)
            else
                GMT.notify(player, "~r~Player not found.")
            end
        end)
    else
        GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
            if cb then
                TriggerClientEvent('GMT:setVIPClubData', player, plushours, plathours)
            end
        end)
    end
end)

RegisterNetEvent("GMT:beginSellSubscriptionToPlayer")
AddEventHandler("GMT:beginSellSubscriptionToPlayer", function(subtype)
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)
    GMTclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
        usrList = ""
        for k, v in pairs(nplayers) do 
            usrList = usrList .. "[" .. GMT.getUserId(k) .. "]" .. GMT.getPlayerName(GMT.getUserId(k)) .. " | " --add ids to usrList
        end
        if usrList ~= "" then
            GMT.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, target_id) --ask for id
                target_id = target_id
                if target_id and target_id ~= "" then --validation
                    local target = GMT.getUserSource(tonumber(target_id)) --get source of the new owner id
                    if target then
                        GMT.prompt(player,"Number of days ","",function(player, hours) -- ask for number of hours
                            if tonumber(hours) and tonumber(hours) > 0 then
                                MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
                                    sellerplushours = rows[1].plushours
                                    sellerplathours = rows[1].plathours
                                    if (subtype == 'Plus' and sellerplushours >= tonumber(hours)*24) or (subtype == 'Platinum' and sellerplathours >= tonumber(hours)*24) then
                                        GMT.prompt(player,"Price £: ","",function(player, amount) --ask for price
                                            if tonumber(amount) and tonumber(amount) > 0 then
                                                GMT.request(target,GMT.getPlayerName(GMT.getUserId(player)).." wants to sell: " ..hours.. " days of "..subtype.." subscription for £"..getMoneyStringFormatted(amount), 30, function(target,ok) --request player if they want to buy sub
                                                    if ok then --bought
                                                        MySQL.query("subscription/get_subscription", {user_id = GMT.getUserId(target)}, function(rows, affected)
                                                            if subtype == "Plus" then
                                                                if GMT.tryFullPayment(GMT.getUserId(target),tonumber(amount)) then
                                                                    MySQL.execute("subscription/set_plushours", {user_id = GMT.getUserId(target), plushours = rows[1].plushours + tonumber(hours)*24})
                                                                    MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = sellerplushours - tonumber(hours)*24})
                                                                    GMT.notify(player, '~g~You have sold '..hours..' days of GMT '..subtype..' subscription to '..GMT.getPlayerName(GMT.getUserId(target))..' for £'..amount)
                                                                    GMT.notify(target, '~g~ You\'ve purchased '..hours..' days of GMT '..subtype)
                                                                    GMT.notify(target, '~g~ Your GMT ' .. subtype .. ' has been activated!')
                                                                    GMT.giveBankMoney(user_id,tonumber(amount))
                                                                    GMT.updateInvCap(GMT.getUserId(target), 40)
                                                                else
                                                                    GMT.notify(player, "~r~".. GMT.getPlayerName(GMT.getUserId(target)).." doesn't have enough money!") --notify original owner
                                                                    GMT.notify(target, "~r~You don't have enough money!") --notify new owner
                                                                end
                                                            elseif subtype == "Platinum" then
                                                                if GMT.tryFullPayment(GMT.getUserId(target),tonumber(amount)) then
                                                                    MySQL.execute("subscription/set_plathours", {user_id = GMT.getUserId(target), plathours = rows[1].plathours + tonumber(hours)*24})
                                                                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = sellerplathours - tonumber(hours)*24})
                                                                    GMT.notify(player, '~g~You have sold '..hours..' days of GMT '..subtype..' subscription to '..GMT.getPlayerName(GMT.getUserId(target))..' for £'..amount)
                                                                    GMT.notify(target, '~g~'..GMT.getPlayerName(GMT.getUserId(player))..' has sold '..hours..' days of '..subtype..' subscription to you for £'..amount)
                                                                    GMT.giveBankMoney(user_id,tonumber(amount))
                                                                    GMT.updateInvCap(GMT.getUserId(target), 50)
                                                                    TriggerClientEvent('GMT:refreshGunStorePermissions', target)
                                                                else
                                                                    GMT.notify(player, "~r~".. GMT.getPlayerName(GMT.getUserId(target)).." doesn't have enough money!") --notify original owner
                                                                    GMT.notify(target, "~r~You don't have enough money!") --notify new owner
                                                                end
                                                            end
                                                        end)
                                                    else
                                                        GMT.notify(player, "~r~"..GMT.getPlayerName(GMT.getUserId(target)).." has refused to buy " ..hours.. " days of "..subtype.." subscription for £"..amount) --notify owner that refused
                                                        GMT.notify(target, "~r~You have refused to buy " ..hours.. " days of "..subtype.." subscription for £"..amount) --notify new owner that refused
                                                    end
                                                end)
                                            else
                                                GMT.notify(player, "~r~Price of subscription must be a number.")
                                            end
                                        end)
                                    else
                                        GMT.notify(player, "~r~You do not have "..hours.." days of "..subtype..".")
                                    end
                                end)
                            else
                                GMT.notify(player, "~r~Number of days must be a number.")
                            end
                        end)
                    else
                        GMT.notify(player, "~r~That Perm ID seems to be invalid!") --couldnt find perm id
                    end
                else
                    GMT.notify(player, "~r~No Perm ID selected!") --no perm id selected
                end
            end)
        else
            GMT.notify(player, "~r~No players nearby!") --no players nearby
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        MySQL.query("subscription/get_all_subscriptions", {}, function(rows, affected)
            if rows and #rows > 0 then
                for k,v in pairs(rows) do
                    local plushours = v.plushours
                    local plathours = v.plathours
                    local user_id = v.user_id
                    local user = GMT.getUserSource(user_id)
                    if plushours >= 1/60 then
                        MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = plushours-1/60})
                    else
                        MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = 0})
                    end
                    if plathours >= 1/60 then
                        MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = plathours-1/60})
                    else
                        MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = 0})
                    end
                    if user then
                        TriggerClientEvent('GMT:setVIPClubData', user, plushours, plathours)
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent("GMT:claimWeeklyKit") -- need to add a thing for restricting the kit to actually being weekly
AddEventHandler("GMT:claimWeeklyKit", function()
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.getSubscriptions(user_id, function(cb, plushours, plathours, last_used)
        if cb then
            if plathours >= 168 or plushours >= 168 then
                if last_used == '' or (os.time() >= tonumber(last_used+24*60*60*7)) then
                    if plathours >= 168 then
                        GMT.giveInventoryItem(user_id, "wbody|WEAPON_M1911",1, true)
                        GMT.giveInventoryItem(user_id, "wbody|WEAPON_OLYMPIA", 1, true)
                        GMT.giveInventoryItem(user_id, "wbody|WEAPON_UMP45", 1, true)
                        GMT.giveInventoryItem(user_id, "12 Gauge Bullets",250)
                        GMT.giveInventoryItem(user_id, "9mm Bullets", 250)
                        GMT.giveInventoryItem(user_id, "Morphine", 5, true)
                        GMT.giveInventoryItem(user_id, "Taco", 5, true)
                        GMTclient.setArmour(source, {100, true})
                        MySQL.execute("subscription/set_lastused", {user_id = user_id, last_used = os.time()})
                    elseif plushours >= 168 then
                        GMT.giveInventoryItem(user_id, "wbody|WEAPON_M1911", 1, true)
                        GMT.giveInventoryItem(user_id, "wbody|WEAPON_UMP45", 1, true)
                        GMT.giveInventoryItem(user_id, "9mm Bullets",500,true)
                        GMT.giveInventoryItem(user_id, "Morphine", 5, true)
                        GMT.giveInventoryItem(user_id, "Taco", 5, true)
                        GMTclient.setArmour(source, {100, true})
                        MySQL.execute("subscription/set_lastused", {user_id = user_id, last_used = os.time()})
                    else
                        GMT.notify(source, "~r~You need at least 1 week of subscription to redeem the kit.")
                    end
                else
                    GMT.notify(source, "~r~You can only claim your weekly kit once a week.")
                end
            else
                GMT.notify(source, "~r~You require at least 1 week of a subscription to claim a kit.")
            end
        end
    end)
end)

RegisterNetEvent("GMT:fuelAllVehicles")
AddEventHandler("GMT:fuelAllVehicles", function()
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            if plushours > 0 or plathours > 0 then
                if GMT.tryFullPayment(user_id,25000) then
                    exports["gmt"]:execute("UPDATE gmt_user_vehicles SET fuel_level = 100 WHERE user_id = @user_id", {user_id = user_id}, function() end)
                    TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                    GMT.notify(source, "~g~Vehicles Refueled.")
                end
            end
        end
    end)
end)


RegisterCommand('redeem', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.checkForRole(user_id, '1304983610574770268') then
        MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then
                local redeemed = rows[1].redeemed
               -- print('Redeemed:', redeemed)
                if redeemed == 0 then
                   -- print('Redeeming perks...')
                    exports["gmt"]:execute("UPDATE gmt_subscriptions SET redeemed = 1 WHERE user_id = @user_id", {user_id = user_id}, function() end)
                    GMT.giveBankMoney(user_id, 500000)
                    GMT.notify(source, '~g~You have redeemed your perks of £500,000 and 1 Week of Platinum Subscription.')
                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = rows[1].plathours + 168})
                else
                   -- print('Already redeemed.')
                    GMT.notify(source, '~r~You have already redeemed your subscription.')
                end
            else
              --  print('No subscription found for user:', user_id)
              GMT.notify(source, '~r~No subscription found.')
            end
        end)
    else
        GMT.notify(source, '~r~You are not boosting the discord, Unable to redeem your subscription.')
    end
end)


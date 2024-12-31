RegisterServerEvent('GMT:checkForPolicewhitelist')
AddEventHandler('GMT:checkForPolicewhitelist', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') then
        if GMT.hasPermission(user_id, 'police.announce') then
            TriggerClientEvent('GMT:openPNC', source, true, {}, {})
        else
            TriggerClientEvent('GMT:openPNC', source, false, {}, {})
        end
    end
end)

RegisterServerEvent('GMT:searchPerson')
AddEventHandler('GMT:searchPerson', function(firstname, lastname)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') then
        exports['gmt']:execute("SELECT * FROM gmt_user_identities WHERE firstname = @firstname AND name = @lastname", {firstname = firstname, lastname = lastname}, function(result) 
            if result then
                local returnedUsers = {}
                for k,v in pairs(result) do
                    local user_id = result[k].user_id
                    local firstname = result[k].firstname
                    local lastname = result[k].name
                    local data = exports['gmt']:executeSync("SELECT * FROM gmt_dvsa WHERE user_id = @user_id", {user_id = user_id})[1]
                    local licence = data.licence
                    local points = data.points
                    local age = result[k].age
                    local phone = result[k].phone
                    local ownedVehicles = exports['gmt']:executeSync("SELECT * FROM gmt_user_vehicles WHERE user_id = @user_id", {user_id = user_id})
                    local actualVehicles = {}
                    for a,b in pairs(ownedVehicles) do 
                        table.insert(actualVehicles, b.vehicle)
                    end
                    local ownedProperties = exports['gmt']:executeSync("SELECT * FROM gmt_user_homes WHERE user_id = @user_id", {user_id = user_id})
                    local actualHouses = {}
                    for a,b in pairs(ownedProperties) do 
                        table.insert(actualHouses, b.home)
                    end
                    table.insert(returnedUsers, {user_id = user_id, firstname = firstname, lastname = lastname, age = age, phone = phone, licence = licence, points = points, vehicles = actualVehicles, playerhome = actualHouses, warrants = {}, warning_markers = {}})
                end
                if next(returnedUsers) then
                    TriggerClientEvent('GMT:sendSearcheduser', source, returnedUsers)
                else
                    TriggerClientEvent('GMT:noPersonsFound', source)
                end
            end
        end)
    end
end)

RegisterServerEvent('GMT:finePlayer')
AddEventHandler('GMT:finePlayer', function(id, charges, amount, notes)
    local source = source
    local user_id = GMT.getUserId(source)
    local amount = tonumber(amount)
    if amount > 250000 then
        amount = 250000
    end
    if next(charges) then
        local chargesList = ""
        for k,v in pairs(charges) do
            chargesList = chargesList.."\n> - **"..v.fine.."**"
        end
        if GMT.hasPermission(user_id, 'police.armoury') then
            if id == user_id then
                TriggerClientEvent('GMT:verifyFineSent', source, false, "Can't fine yourself!")
                return
            end
            if GMT.tryBankPayment(id, amount) then
                GMT.giveBankMoney(user_id, amount*0.1)
                GMT.notifyPicture6(GMT.getUserSource(id), "walletnotification", "notification", "You have been fined ~r~£" .. getMoneyStringFormatted(amount), "Wallet", "Fine received")
                GMT.notifyPicture6(source, "walletnotification", "notification", "You have received ~g~£" .. getMoneyStringFormatted(amount) .. " ~s~for fining " ..GMT.getPlayerName(id).. ".", "Wallet", "Fine player")
                TriggerEvent('GMT:addToCommunityPot', tonumber(amount))
                TriggerClientEvent('GMT:verifyFineSent', source, true)
                GMT.sendDCLog('fine-player', 'GMT Fine Logs',"> Officer Name: **"..GMT.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Criminal Name: **"..GMT.getPlayerName(id).."**\n> Criminal PermID: **"..id.."**\n> Criminal TempID: **"..GMT.getUserSource(id).."**\n> Amount: **£"..amount.."**\n> Charges: "..chargesList)--.."\n> Notes: **"..notes.."**")
                -- do notes later
                GMT.AddStat(user_id,"amount_fined",amount)
            else
                TriggerClientEvent('GMT:verifyFineSent', source, false, 'The player does not have enough money.')
            end
        end
    end
end)


RegisterServerEvent('GMT:addPoints')
AddEventHandler('GMT:addPoints', function(charges, id)
    local source = source
    local user_id = GMT.getUserId(source)
    
    if GMT.hasPermission(user_id, 'police.armoury') then
        local totalPoints = 0 
        for i, v in pairs(charges) do
            local point = v.points 
            local reason = v.name
            totalPoints = totalPoints + point 
        end
        if totalPoints > 12 then
            totalPoints = 12
        end
        exports['gmt']:execute("UPDATE gmt_dvsa SET points = points + @newpoints WHERE user_id = @user_id", {user_id = id, newpoints = totalPoints})
        exports['gmt']:execute('SELECT * FROM gmt_dvsa WHERE user_id = @user_id', {user_id = user_id}, function(licenceInfo)
            local licenceType = licenceInfo[1].licence
            local userPoints = tonumber(licenceInfo[1].points)
            if (licenceType == "active" or licenceType == "full") and userPoints > 12 then
                GMT.notify(GMT.getUserSource(id), '~r~You have received '..totalPoints..' on your licence. You now have '..userPoints..'/12 points. Your licence has been suspended.')
                exports['gmt']:execute("UPDATE gmt_dvsa SET licence = 'banned' WHERE user_id = @user_id", {user_id = id})
                Wait(100)
                dvsaUpdate(user_id)
            else
                GMT.notify(GMT.getUserSource(id), '~r~You have received '..totalPoints..' on your licence. You now have '..userPoints..'/12 points.')
            end
            if userPoints > 12 then
                exports['gmt']:execute("UPDATE gmt_dvsa SET points = @points WHERE user_id = @user_id", {user_id = id, points = 12})
            end
        end)
    end
end)

RegisterServerEvent('GMT:searchPlate')
AddEventHandler('GMT:searchPlate', function(plate)
    TriggerClientEvent('GMT:displayPlate', source, plate)
end)

RegisterCommand('testad', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id == 1 then
        TriggerClientEvent('GMT:notifyAD', source, 'Phase 3 Firearms', 'Red Vauxhall Corsa')
    end
end)
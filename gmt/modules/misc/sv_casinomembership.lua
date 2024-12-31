RegisterNetEvent('GMT:purchaseHighRollersMembership')
AddEventHandler('GMT:purchaseHighRollersMembership', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if not GMT.hasGroup(user_id, 'Highroller') then
        if GMT.tryFullPayment(user_id,5000000) then
            GMT.addUserGroup(user_id, 'Highroller')
            GMT.notify(source, '~g~You have purchased the ~b~High Rollers ~g~membership.')
            GMT.sendDCLog('purchase-highrollers',"GMT Purchased Highrollers Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**")
        else
            GMT.notify(source, 'You do not have enough money to purchase this membership.')
        end
    else
        GMT.notify(source, "You already have High Roller's License.")
    end
end)

RegisterNetEvent('GMT:removeHighRollersMembership')
AddEventHandler('GMT:removeHighRollersMembership', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasGroup(user_id, 'Highroller') then
        GMT.removeUserGroup(user_id, 'Highroller')
    else
        GMT.notify(source, "You do not have High Roller's License.")
    end
end)
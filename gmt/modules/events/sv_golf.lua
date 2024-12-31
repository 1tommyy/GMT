RegisterServerEvent('GMT:takeGolfMoney')
AddEventHandler('GMT:takeGolfMoney', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.tryBankPayment(user_id, 5000) then
        TriggerClientEvent('GMT:startGolf', source)
        GMT.notify(source, "~g~Paid £5,000")
    else
        GMT.notify(source, "~r~You do not have enough money.")
    end
end)
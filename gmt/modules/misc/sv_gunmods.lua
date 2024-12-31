RegisterServerEvent('GMT:tryBuyAttachment')
AddEventHandler('GMT:tryBuyAttachment', function(weapon, attachment, price)
    local source = source
    local user_id = GMT.getUserId(source)

    if GMT.tryBankPayment(user_id, price) then
        TriggerClientEvent('GMT:updateBoughtAttachments', source, attachment, weapon)
    else
        GMT.notify(source,"~r~Not enough money.")
    end
end)
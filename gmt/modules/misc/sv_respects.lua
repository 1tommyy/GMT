local cayoPaymentCooldowns = {}

RegisterNetEvent("GMT:cayoPayment")
AddEventHandler("GMT:cayoPayment", function()
    local source = source
    local user_id = GMT.getUserId(source)

    if not cayoPaymentCooldowns[user_id] then
        GMT.giveMoney(user_id, 500000)
        cayoPaymentCooldowns[user_id] = true
    else
        GMT.notify(source, '~r~You have already paid your respects.')
    end
end)
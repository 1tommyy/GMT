local cfg = module("cfg/cfg_stores")

RegisterNetEvent("GMT:BuyStoreItem")
AddEventHandler("GMT:BuyStoreItem", function(item, amount)
    local source = source
    local user_id = GMT.getUserId(source)
    local ped = GetPlayerPed(source)
    for k,v in pairs(cfg.shopItems) do
        if item == v.itemID then
            if GMT.getInventoryWeight(user_id) <= 25 then
                local totalPrice = v.price * amount
                local cash = GMT.getMoney(user_id)
                if item ~= "ticket" then
                    if cash >= totalPrice then
                        if GMT.tryPayment(user_id, totalPrice) then
                            GMT.giveInventoryItem(user_id, item, amount, false)
                            GMT.notify(source, "~g~Paid £".. getMoneyStringFormatted(totalPrice) ..".")
                            TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                        end
                    elseif cash > 0 and cash >= totalPrice then
                        local remaining = totalPrice - cash
                        if GMT.tryPayment(user_id, cash) and GMT.tryBankPayment(user_id, remaining) then
                            GMT.giveInventoryItem(user_id, item, amount, false)
                            GMT.notify(source, "~g~Paid £".. getMoneyStringFormatted(totalPrice) ..".")
                            TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                        else
                            GMT.notify(source, "~r~Not enough money.")
                            TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
                        end
                    else
                        GMT.notify(source, "~r~Not enough money.")
                        TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
                    end
                else
                    GMT.notify(source, '~g~You have been entered into the lottery.')
                    TriggerEvent("GMT:setPersonalAmountBought", user_id, amount)
                    TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                end
            else
                GMT.notify(source, '~r~Not enough inventory space.')
                TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
            end
        end
    end
end)
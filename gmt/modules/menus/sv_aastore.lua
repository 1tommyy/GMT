local cfg = module("cfg/cfg_aastore")

RegisterNetEvent("GMT:BuyAAStoreItem")
AddEventHandler("GMT:BuyAAStoreItem", function(item, amount)
    local source = source
    local user_id = GMT.getUserId(source)
    local ped = GetPlayerPed(source)
    for k,v in pairs(cfg.shopAAItems) do
        if item == v.itemID then
            if GMT.hasPermission(user_id, "aa.menu") then
                if GMT.getInventoryWeight(user_id) <= 25 then
                    local totalPrice = v.price * amount
                    local cash = GMT.getMoney(user_id)
                    if cash >= totalPrice then
                        if GMT.tryPayment(user_id, totalPrice) then
                            GMT.giveInventoryItem(user_id, item, amount, false)
                            GMT.notify(source, "~g~Paid £".. getMoneyStringFormatted(totalPrice) ..".")
                            TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                        end
                    elseif cash > 0 and cash + GMT.getBankMoney(user_id) >= totalPrice then
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
                    GMT.notify(source, '~r~Not enough inventory space.')
                    TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
                end
            else
                GMT.notify(source, '~r~You are not on duty as an AA Mechanic, Head to the city hall to clock on.')
                TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
            end
        end
    end
end)

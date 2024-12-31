local lang = GMT.lang
local cfg = module("cfg/atms")
RegisterServerEvent("GMT:depositAtm",function(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if user_id then
            if GMT.tryDeposit(user_id, amount) then
                GMT.notify(source, lang.atm.deposit.deposited({getMoneyStringFormatted(amount)}))
            else
                GMT.notify(source, lang.money.not_enough())
            end
        end
    else
        GMT.notify(source, lang.common.invalid_value())
    end
end)

RegisterServerEvent("GMT:withdrawAtm",function(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if user_id then
            if GMT.tryWithdraw(user_id, amount) then
                GMT.notify(source, lang.atm.withdraw.withdrawn({getMoneyStringFormatted(amount)}))
            else
                GMT.notify(source, lang.atm.withdraw.not_enough())
            end
        end
    else
        GMT.notify(source, lang.common.invalid_value())
    end
end)

RegisterServerEvent("GMT:depositAll",function()
    local source = source
    local user_id = GMT.getUserId(source)
    local amount = GMT.getMoney(user_id)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if GMT.tryDeposit(user_id, amount) then
            GMT.notify(source, lang.atm.deposit.deposited({getMoneyStringFormatted(amount)}))
        else
            GMT.notify(source, lang.money.not_enough())
        end
    else
        GMT.notify(source, lang.common.invalid_value())
    end
end)

RegisterServerEvent("GMT:withdrawAll",function()
    local source = source
    local user_id = GMT.getUserId(source)
    local amount = GMT.getBankMoney(user_id)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if GMT.tryWithdraw(user_id, amount) then
            GMT.notify(source, lang.atm.withdraw.withdrawn({getMoneyStringFormatted(amount)}))
        else
            GMT.notify(source, lang.atm.withdraw.not_enough())
        end
    else
        GMT.notify(source, lang.common.invalid_value())
    end
end)

local robbedableatms = {}

for atmid,coords in pairs(cfg.robberyAtms) do
    robbedableatms[atmid] = {robbed = false, robberid = nil, lastrobbed = 0}
end

RegisterServerEvent("GMT:atmWireCutSparks",function(atmid)
    local source = source
    local user_id = GMT.getUserId(source)
    if robbedableatms[atmid].robbed then
        if user_id == robbedableatms[atmid].robberid then
            TriggerClientEvent("GMT:atmWireCutSparks",-1,atmid)
        else
            GMT.notify(source, "~r~You wasn't robbing this atm!")
        end
    end
end)

RegisterServerEvent("GMT:returnAtmWireCutting",function(storeid,success)
    local source = source
    local user_id = GMT.getUserId(source)
    if robbedableatms[storeid].robbed then
        if user_id == robbedableatms[storeid].robberid then
            if success then
                local chance = math.random(1,4)
                GMT.notify(source, "~g~You have successfully cut the wires!")
                if chance ~= 2 then
                    local amount = math.random(650000, 1000000)*grindBoost
                    TriggerClientEvent("GMT:atmRobberyFakeMoney",source,GMT.getDirtyCash(user_id),amount)
                    TriggerClientEvent("GMT:atmWireCuttingSuccessSync",-1,storeid)
                    TriggerClientEvent("GMT:atmWireCuttingSuccess",source)
                    Wait(10000)
                    GMT.giveDirtyCash(user_id, amount)
                else
                    GMT.notify(source, "~r~Failed to pick up money. A fail safe has covered it in ink.")
                    TriggerClientEvent("GMT:atmInkArea",source,storeid)
                    TriggerClientEvent("GMT:atmGenericAlarm",source,storeid)
                end
            else
                GMT.notify(source, "~r~You have failed to cut the wires.")
                TriggerClientEvent("GMT:atmInkArea",source,storeid)
                TriggerClientEvent("GMT:atmGenericAlarm",source,storeid)
            end
        else
            GMT.notify(source, "~r~You wasn't robbing this atm!")
        end
    end
end)

RegisterServerEvent("GMT:startAtmWireCutting",function(storeid)
    local source = source
    local user_id = GMT.getUserId(source)
    if not robbedableatms[storeid].robbed then
        robbedableatms[storeid].robbed = true
        robbedableatms[storeid].robberid = user_id
        robbedableatms[storeid].lastrobbed = GetGameTimer()+15*60*1000
        TriggerClientEvent("GMT:startAtmWireCutting",source,storeid)
    end
end)

RegisterServerEvent("GMT:atmStopWireCutting",function(storeid)
    local source = source
    local user_id = GMT.getUserId(source)
    if robbedableatms[storeid].robbed then
        if user_id == robbedableatms[storeid].robberid then
            robbedableatms[storeid].robbed = false
            robbedableatms[storeid].robberid = nil
            robbedableatms[storeid].lastrobbed = 0
            TriggerClientEvent("GMT:atmStopWireCutting",-1,storeid)
        end
    end
end)

RegisterServerEvent("GMT:getAtmHasBeenRobbed",function(storeid)
    local source = source
    TriggerClientEvent("GMT:setAtmHasBeenRobbed",source,robbedableatms[storeid].lastrobbed)
end)
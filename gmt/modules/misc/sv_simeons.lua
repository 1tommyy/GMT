local cfg=module("cfg/cfg_simeons")
local inventory=module("GMTVeh", "cfg/cfg_inventory")


RegisterNetEvent("GMT:refreshSimeonsPermissions")
AddEventHandler("GMT:refreshSimeonsPermissions",function()
    local source=source
    local simeonsCategories={}
    local user_id = GMT.getUserId(source)
    for k,v in pairs(cfg.simeonsCategories) do
        for a,b in pairs(v) do
            if a == "_config" then
                if b.permissionTable[1] then
                    if GMT.hasPermission(GMT.getUserId(source),b.permissionTable[1])then
                        for c,d in pairs(v) do
                            if inventory.vehicle_chest_weights[c] then
                                table.insert(v[c],inventory.vehicle_chest_weights[c])
                            else
                                table.insert(v[c],30)
                            end
                        end
                        simeonsCategories[k] = v
                    end
                else
                    for c,d in pairs(v) do
                        if inventory.vehicle_chest_weights[c] then
                            table.insert(v[c],inventory.vehicle_chest_weights[c])
                        else
                            table.insert(v[c],30)
                        end
                    end
                    simeonsCategories[k] = v
                end
            end
        end
    end
    TriggerClientEvent("GMT:gotCarDealerInstances",source,cfg.simeonsInstances)
    TriggerClientEvent("GMT:gotCarDealerCategories",source,simeonsCategories)
end)

RegisterNetEvent('GMT:purchaseCarDealerVehicle')
AddEventHandler('GMT:purchaseCarDealerVehicle', function(vehicleclass, vehicle)
    local source = source
    local user_id = GMT.getUserId(source)
    local playerName = GMT.getPlayerName(GMT.getUserId(source))   
    for k,v in pairs(cfg.simeonsCategories[vehicleclass]) do
        if k == vehicle then
            local vehicle_name = v[1]
            local vehicle_price = v[2]
            MySQL.query("GMT/get_vehicle", {user_id = user_id, vehicle = vehicle}, function(pvehicle, affected)
                if #pvehicle > 0 then
                    GMT.notify(source, "~r~Vehicle already owned.")
                else
                    if GMT.tryFullPayment(user_id, vehicle_price) then
                        GMTclient.generateUUID(source, {"plate", 5, "alphanumeric"}, function(uuid)
                            local uuid = string.upper(uuid)
                            MySQL.execute("GMT/add_vehicle", {user_id = user_id, vehicle = vehicle, registration = 'P'..uuid})
                            if tGMT.GetPlayTime(user_id) <= 48 then
                                GMT.notify(source, "~g~Vehicle purchased! Pick up your vehicle from the nearest garage!")
                            elseif vehicle_price == 0 then
                                GMT.notify(source, "~g~You got "..vehicle_name.." for free.")
                            else
                                GMT.notify(source, "~g~You paid £"..vehicle_price.." for "..vehicle_name..".")
                            end
                            TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                        end)
                    else
                        GMT.notify(source, "~r~Not enough money.")
                        TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
                    end
                end
            end)
        end
    end
end)

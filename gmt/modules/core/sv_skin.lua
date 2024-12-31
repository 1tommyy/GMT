RegisterNetEvent("GMT:saveFaceData")
AddEventHandler("GMT:saveFaceData", function(faceSaveData)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.setUData(user_id, "GMT:Face:Data", json.encode(faceSaveData))
end)

RegisterNetEvent("GMT:saveClothingHairData") -- this updates hair from clothing stores
AddEventHandler("GMT:saveClothingHairData", function(hairtype, haircolour)
    local source = source
    local user_id = GMT.getUserId(source)
    local facesavedata = {}
    GMT.getUData(user_id, "GMT:Face:Data", function(data)
        if data and data ~= 0 and hairtype and haircolour then
            facesavedata = json.decode(data)
            if facesavedata == nil then
                facesavedata = {}
            end
            facesavedata["hair"] = hairtype
            facesavedata["haircolor"] = haircolour
            GMT.setUData(user_id, "GMT:Face:Data", json.encode(facesavedata))
        end
    end)
end)

RegisterNetEvent("GMT:getPlayerHairstyle")
AddEventHandler("GMT:getPlayerHairstyle", function()
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.getUData(user_id, "GMT:Face:Data", function(data)
        if data and data ~= 0 then
            TriggerClientEvent("GMT:setHairstyle", source, json.decode(data))
        end
    end)
end)

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    SetTimeout(1000, function() 
        local source = source
        local user_id = GMT.getUserId(source)
        GMT.getUData(user_id, "GMT:Face:Data", function(data)
            if data and data ~= 0 then
                TriggerClientEvent("GMT:setHairstyle", source, json.decode(data))
            end
        end)
    end)
end)
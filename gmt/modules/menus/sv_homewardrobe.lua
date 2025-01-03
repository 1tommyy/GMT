local outfitCodes = {}

RegisterNetEvent("GMT:saveWardrobeOutfit")
AddEventHandler("GMT:saveWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.getUData(user_id, "GMT:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        GMTclient.getCustomization(source,{},function(custom)
            sets[outfitName] = custom
            GMT.setUData(user_id,"GMT:home:wardrobe",json.encode(sets))
            GMT.notify(source, "~g~Saved outfit "..outfitName.." to wardrobe!")
            TriggerClientEvent("GMT:refreshOutfitMenu", source, sets)
        end)
    end)
end)

RegisterNetEvent("GMT:deleteWardrobeOutfit")
AddEventHandler("GMT:deleteWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.getUData(user_id, "GMT:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        sets[outfitName] = nil
        GMT.setUData(user_id,"GMT:home:wardrobe",json.encode(sets))
        GMT.notify(source, "~g~Removed outfit "..outfitName.." from wardrobe!")
        TriggerClientEvent("GMT:refreshOutfitMenu", source, sets)
    end)
end)

RegisterNetEvent("GMT:equipWardrobeOutfit")
AddEventHandler("GMT:equipWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.getUData(user_id, "GMT:home:wardrobe", function(data)
        local sets = json.decode(data)
        GMTclient.setCustomization(source, {sets[outfitName]})
        GMTclient.getHairAndTats(source, {})
    end)
end)

RegisterNetEvent("GMT:initWardrobe")
AddEventHandler("GMT:initWardrobe", function()
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.getUData(user_id, "GMT:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        TriggerClientEvent("GMT:refreshOutfitMenu", source, sets)
    end)
end)

RegisterNetEvent("GMT:getCurrentOutfitCode")
AddEventHandler("GMT:getCurrentOutfitCode", function()
    local source = source
    local user_id = GMT.getUserId(source)
    GMTclient.getCustomization(source,{},function(custom)
        GMTclient.generateUUID(source, {"outfitcode", 5, "alphanumeric"}, function(uuid)
            local uuid = string.upper(uuid)
            outfitCodes[uuid] = custom
            GMTclient.CopyToClipBoard(source, {uuid})
           -- GMT.notify(source, "~g~Outfit code copied to clipboard.")
            TriggerClientEvent("GMT:showNotification",
                {
                    text = "Outfit code Copied To Clipboard.",
                    height = "200px",
                    width = "auto",
                    colour = "#FFF",
                    background = "#32CD32",
                    pos = "bottom-right",
                    icon = "good"
                }, 5000
            )
            GMT.notify(source, "The code ~y~"..uuid.."~w~ will persist until restart.")
        end)
    end)
end)

RegisterNetEvent("GMT:applyOutfitCode")
AddEventHandler("GMT:applyOutfitCode", function(outfitCode)
    local source = source
    local user_id = GMT.getUserId(source)
    if outfitCodes[outfitCode] then
        GMTclient.setCustomization(source, {outfitCodes[outfitCode]})
        GMT.notify(source, "~g~Outfit code applied.")
        GMTclient.getHairAndTats(source, {})
    else
        GMT.notify(source, "Outfit code not found.")
    end
end)

RegisterCommand('wardrobe', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id == 1 then
        TriggerClientEvent("GMT:openOutfitMenu", source)
    end
end)

RegisterCommand('copyfit', function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    local permid = tonumber(args[1])
    if GMT.hasGroup(user_id, 'Founder') or GMT.hasGroup(user_id, 'Lead Developer') then
        GMTclient.getCustomization(GMT.getUserSource(permid),{},function(custom)
            GMTclient.setCustomization(source, {custom})
        end)
    end
end)


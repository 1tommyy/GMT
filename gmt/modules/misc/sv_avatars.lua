AddEventHandler("GMT:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        Citizen.Wait(6000)
        TriggerClientEvent("GMT:setProfilePictures",source,RequestPFP(user_id))
    end
end)

RegisterNetEvent('GMT:requestAvatar')
AddEventHandler('GMT:requestAvatar', function(user_id)
    local source = source
    local avatar = exports["gmt"]:Get_Discord_Avatar(exports['gmt']:Get_Client_Discord_ID(GMT.getUserSource(user_id)))
    TriggerClientEvent('GMT:receiveAvatar', source, avatar)
end)

function RequestPFP(user_id)
    local table,ids = {},{}
    for _,id in pairs(GetPlayerIdentifiers(GMT.getUserSource(user_id))) do
        local key,value = string.match(id, "([^:]+):(.+)")
        if key and value then
            ids[key] = ids[key] or key..":"..value
        end
    end
    if ids["steam"] then
        PerformHttpRequest("http://steamcommunity.com/profiles/"..tonumber(stringsplit(ids["steam"],":")[2],16).."/?xml=1", function(err, text, headers)
            if text then
                local SteamProfileSplitted = stringsplit(text, '\n')
                for i, Line in ipairs(SteamProfileSplitted) do
                    if Line:find('<avatarFull>') then
                        table["Steam"] = Line:gsub('<avatarFull><!%[CDATA%[', ''):gsub(']]></avatarFull>', '')
                        break
                    end
                end
            end
        end)
    end
    table["Steam"] = table["Steam"] or "https://imgur.com/a/xmYNJG7"
    table["Discord"] = "https://imgur.com/a/1ehlA01"
    if user_id and GMT.getUserSource(user_id) then
        exports["gmt"]:Get_Discord_Avatar(exports['gmt']:Get_Client_Discord_ID(GMT.getUserSource(user_id)))
    end
    table["None"] = "https://i.imgur.com/rxGznrr.png"
    return table
end 

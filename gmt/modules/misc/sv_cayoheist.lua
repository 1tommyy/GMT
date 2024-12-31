local playersInHeist = {}
local lobbiesCreated = 0

RegisterServerEvent("GMT:CayoHeist:Active", function()
    local source = source
    local user_id = GMT.getUserId(source)
    if not playersInHeist[user_id] then
        playersInHeist[user_id] = true
        print("[GMT Cayo Heist] " .. GMT.getPlayerName(user_id) .. " has entered the Cayo Perico Heist.")
        TriggerClientEvent("GMT:CayoHeist:Active", source, true, #playersInHeist)
    else
        playersInHeist[user_id] = nil
        print("[GMT Cayo Heist] " .. GMT.getPlayerName(user_id) .. " has exited the Cayo Perico Heist.")
        TriggerClientEvent("GMT:CayoHeist:Active", source, false, #playersInHeist)
    end
end)

RegisterServerEvent("GMT:CayoHeist:LobbyCreated", function()
    local source = source
    local user_id = GMT.getUserId(source)
    if playersInHeist[user_id] then
        lobbiesCreated = lobbiesCreated + 1
        TriggerClientEvent("GMT:CayoHeist:LobbyCreated", source, lobbiesCreated)
    else
        GMT.notify(source, "~r~You have not entered the Cayo Perico Heist.")
    end
end)
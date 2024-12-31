local trainingWorlds = {}
local trainingWorldsCount = 0
RegisterCommand('trainingworlds', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') then
        TriggerClientEvent('GMT:trainingWorldSendAll', source, trainingWorlds)
        TriggerClientEvent('GMT:trainingWorldOpen', source, GMT.hasPermission(user_id, 'police.announce'))
    end
end)

RegisterNetEvent("GMT:trainingWorldCreate")
AddEventHandler("GMT:trainingWorldCreate", function()
    local source = source
    local user_id = GMT.getUserId(source)
    trainingWorldsCount = trainingWorldsCount + 1
    GMT.prompt(source,"World Name:","",function(player,worldname) 
        if string.gsub(worldname, "%s+", "") ~= '' then
            if next(trainingWorlds) then
                for k,v in pairs(trainingWorlds) do
                    if v.name == worldname then
                        GMT.notify(source, "This world name already exists.")
                        return
                    elseif v.ownerUserId == user_id then
                        GMT.notify(source, "You already have a world, please delete it first.")
                        return
                    end
                end
            end
            GMT.prompt(source,"World Password:","",function(player,password) 
                trainingWorlds[trainingWorldsCount] = {name = worldname, ownerName = GMT.getPlayerName(GMT.getUserId(source)), ownerUserId = user_id, bucket = trainingWorldsCount, members = {}, password = password}
                table.insert(trainingWorlds[trainingWorldsCount].members, user_id)
                GMT.setBucket(source, trainingWorldsCount)
                TriggerClientEvent('GMT:trainingWorldSend', -1, trainingWorldsCount, trainingWorlds[trainingWorldsCount])
                GMT.notify(source, '~g~Training World Created!')
            end)
        else
            GMT.notify(source, "Invalid World Name.")
        end
    end)
end)

RegisterNetEvent("GMT:trainingWorldRemove")
AddEventHandler("GMT:trainingWorldRemove", function(world)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.announce') then
        if trainingWorlds[world] then
            TriggerClientEvent('GMT:trainingWorldRemove', -1, world)
            for k,v in pairs(trainingWorlds[world].members) do
                local memberSource = GMT.getUserSource(v)
                if memberSource then
                    GMT.setBucket(memberSource, 0)
                    GMT.notify(memberSource, "~b~The training world you were in was deleted, you have been returned to the main dimension.")
                end
            end
            trainingWorlds[world] = nil
        end
    end
end)

RegisterNetEvent("GMT:trainingWorldJoin")
AddEventHandler("GMT:trainingWorldJoin", function(world)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.prompt(source,"Enter Password:","",function(player,password) 
        if password ~= trainingWorlds[world].password then
            GMT.notify(source, "Invalid Password.")
            return
        else
            GMT.setBucket(source, world)
            table.insert(trainingWorlds[world].members, user_id)
            GMT.notify(source, "~b~You have joined training world "..trainingWorlds[world].name..' owned by '..trainingWorlds[world].ownerName..'.')
        end
    end)
end)

RegisterNetEvent("GMT:trainingWorldLeave")
AddEventHandler("GMT:trainingWorldLeave", function()
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.setBucket(source, 0)
    GMT.notify(source, "~b~You have left the training world.")
end)


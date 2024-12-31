local tutorialStartTimes = {}


RegisterNetEvent('GMT:checkTutorial')
AddEventHandler('GMT:checkTutorial', function()
    local source = source
    local user_id = GMT.getUserId(source)
    local discord  = "N/A"
    for k,v in pairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end 
    end
    if not GMT.hasGroup(user_id, 'TutorialDone') then
        GMT.addUserGroup(user_id, 'TutorialDone')
        GMT.addUserGroup(user_id, 'NewPlayer')
        GMT.addUserGroup(user_id, 'Supporter')
        GMT.addUserGroup(user_id, 'VIP')
        GMT.setBucket(source, 0)
        TriggerClientEvent('GMT:setBucket', source, 0)
        GMT.sendDCLog('tutorial', 'GMT Tutorial Logs', "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player Discord: **"..discord.."**\n> Player PermID: **"..user_id.."**\n> Info: **Started the Tutorial**")
        TriggerClientEvent('GMT:setIsNewPlayer', source)
        tutorialStartTimes[user_id] = os.time()
    end
end)

RegisterNetEvent('GMT:setCompletedTutorial')
AddEventHandler('GMT:setCompletedTutorial', function()
    local source = source
    local user_id = GMT.getUserId(source)
    local discord  = "N/A"
    for k,v in pairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end 
    end
    if not GMT.hasGroup(user_id, 'TutorialDone') then
        GMT.addUserGroup(user_id, 'TutorialDone')
        GMT.addUserGroup(user_id, 'NewPlayer')
        GMT.addUserGroup(user_id, 'Supporter')
        GMT.addUserGroup(user_id, 'VIP')
        GMT.setBucket(source, 0)
        TriggerClientEvent('GMT:setBucket', source, 0)
        local duration = os.time() - tutorialStartTimes[user_id]
        tutorialStartTimes[user_id] = nil 
        GMT.sendDCLog('tutorial', 'GMT Tutorial Logs', "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player Discord: **"..discord.."**\n> Player PermID: **"..user_id.."**\n> Info: **Finished the Tutorial**\n> Tutorial Duration: **"..duration.." seconds**")
    end
end)
local currentdata = {
    eventactive = true,
    teams = {
        ["Red"] = {},
        ["Blue"] = {},
    }
}
local resetdata = currentdata

local function AlreadyInTeam(user_id)
    for _, team in ipairs({"Red","Blue"}) do
        for i = 1,2 do
            if currentdata.teams[team][i] == user_id then
                return true,team
            end
        end
    end
    return false,"None"
end

local function ActionTeam(actiontype,team,team2,user_id)
    if actiontype == "join" then
        if #currentdata.teams[team] < 2 then
            for i = 1,2 do
                if not currentdata.teams[team][i] then
                    currentdata.teams[team][i] = user_id
                    break
                end
            end
        end
    elseif actiontype == "leave" then
        for i = 1,2 do
            if currentdata.teams[team][i] == user_id then
                if i == 1 then
                    currentdata.teams[team][i] = currentdata.teams[team][2]
                    currentdata.teams[team][2] = nil
                else
                    currentdata.teams[team][i] = nil
                end
            end
        end
    elseif actiontype == "joinleave" then
        ActionTeam("leave",team,nil,user_id)
        ActionTeam("join",team2,nil,user_id)
    end
end

RegisterServerEvent('GMT:StartEvent', function()
    local source = source
    local user_id = GMT.getUserId(source)
    local slotsAvailable = 0
    if GMT.hasPermission(user_id,"admin.managecommunitypot") then
        currentdata.eventactive = true
        if currentdata.eventactive and not currentdata.teams[team] then
            slotsAvailable = 4
        end
        TriggerClientEvent("GMT:EventInit",-1,true)
        TriggerClientEvent("GMT:announceEventJoinable", -1, "2v2 Event", slotsAvailable)
        TriggerClientEvent('chatMessage', -1, "^8[GMT] ", { 128, 128, 128 }, "2v2 Event Started, Use /joinevent!", "goodalert")
        GMT.sendDCLog('event-logs', "GMT Event Logs", "> Event Started \n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterServerEvent('GMT:EndEvent', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id,"admin.managecommunitypot") then
        currentdata = resetdata
        TriggerClientEvent('GMT:EventInit',-1,false)
        TriggerClientEvent('chatMessage', -1, "^8[GMT] ", { 128, 128, 128 }, "2v2 Event Ended", "goodalert")
        GMT.sendDCLog('event-logs', "GMT Event Logs", "> Event Ended \n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterCommand('eventspectate', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if currentdata.eventactive and currentdata.teams[team] and GMT.hasPermission(user_id,"admin.managecommunitypot") then
        local players = {}
        for _, team in ipairs({"Red","Blue"}) do
            for i = 1,2 do
                if currentdata.teams[team][i] then
                    table.insert(players, GMT.getUserSource(currentdata.teams[team][i]))
                end
            end
        end
        GMT.setBucket(source, 50)
        TriggerClientEvent('GMT:StartSpectating', source, players)
    else
        GMT.notify(source, '~r~The event is empty.')
    end
end)

RegisterServerEvent("GMT:Request2v2",function()
    local source = source
    TriggerClientEvent("GMT:Update2v2Data",source,currentdata.teams)
end)

RegisterServerEvent("GMT:Join2v2",function(team)
    local source = source
    local user_id = GMT.getUserId(source)
    if currentdata.eventactive and currentdata.teams[team] then
        local alreadyInTeam,currentteam = AlreadyInTeam(user_id)
        if not alreadyInTeam then
            ActionTeam("join",team,nil,user_id)
            TriggerClientEvent("GMT:Update2v2Data",-1,currentdata.teams)
        else
            if currentteam ~= team then
                ActionTeam("joinleave",currentteam,team,user_id)
                TriggerClientEvent("GMT:Update2v2Data",-1,currentdata.teams)
            end
        end
    end
end)

RegisterServerEvent("GMT:Leave2v2",function(team)
    local source = source
    local user_id = GMT.getUserId(source)
    if currentdata.eventactive and currentdata.teams[team] then
        local alreadyInTeam,currentteam = AlreadyInTeam(user_id)
        if alreadyInTeam then
            ActionTeam("leave",team,nil,user_id)
            TriggerClientEvent("GMT:Update2v2Data",-1,currentdata.teams)
        end
    end
end)

RegisterServerEvent("GMT:LeaveEvent",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if currentdata.eventactive then
        local alreadyInTeam,currentteam = AlreadyInTeam(user_id)
        if alreadyInTeam then
            ActionTeam("leave",currentteam,nil,user_id)
            TriggerClientEvent("GMT:Update2v2",source,false)
            TriggerClientEvent("GMT:Update2v2Data",-1,currentdata.teams)
        end
    end
end)


RegisterServerEvent("GMT:Create2v2",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if currentdata.eventactive then
        local alreadyInTeam,currentteam = AlreadyInTeam(user_id)
        if alreadyInTeam then
            if #currentdata.teams["Red"] == 2 and #currentdata.teams["Blue"] == 2 then
                for _, team in ipairs({"Red","Blue"}) do
                    for i = 1,2 do
                        if currentdata.teams[team][i] then
                            local source = GMT.getUserSource(currentdata.teams[team][i])
                            if source then
                                TriggerClientEvent("GMT:Update2v2",source,true)
                                GMT.notify(source, '~g~Event Started!')
                                GMTclient.giveWeapons(source, {{["WEAPON_ROOK"] = {ammo = 250}}, false, globalpasskey})
                                GMTclient.teleport(source,team == "Red" and vector3(-356.64,-2655.59,6.0) or vector3(-396.04,-2681.61,6.0))
                            end
                        end
                    end
                end
                GMT.sendDCLog('event-logs', "GMT Event Logs", "> Event Started \n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
            end
        end
    end
end)

RegisterServerEvent("GMT:DiedIn2v2",function(killersrc)
    local source = source
    local user_id = GMT.getUserId(source)
    if currentdata.eventactive then
        local alreadyInTeam,currentteam = AlreadyInTeam(user_id)
        local alreadyInTeam2,currentteam2 = AlreadyInTeam(GMT.getUserId(killersrc))
        if alreadyInTeam and alreadyInTeam2 then
            if #currentdata.teams[currentteam] == 1 then
                for _, team in ipairs({"Red","Blue"}) do
                    for i = 1,2 do
                        if currentdata.teams[team][i] then
                            local source = GMT.getUserSource(currentdata.teams[team][i])
                            if source then
                                TriggerClientEvent("GMT:EventInit",source,false)
                                TriggerClientEvent("GMT:Update2v2",source,false)
                            end
                        end
                    end
                end
                currentdata = resetdata
            else
                ActionTeam("leave",currentteam,nil,user_id)
                GMTclient.teleport(source, vector3(-345.68,-2649.14,6.0))
            end
            GMT.giveBankMoney(GMT.getUserId(killersrc), 25000)
            TriggerClientEvent("GMT:Update2v2Data",-1,currentdata.teams)
        end
    end
end)

AddEventHandler("GMT:playerLeave",function(user_id,source)
    local alreadyInTeam,currentteam = AlreadyInTeam(user_id)
    if alreadyInTeam then
        ActionTeam("leave",currentteam,nil,user_id)
        TriggerClientEvent("GMT:Update2v2Data",-1,currentdata.teams)
    end
end)

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    if first_spawn and currentdata.eventactive and currentdata.teams[team] then
        Citizen.Wait(5000)
        GMT.notify(source, '~g~There is a 2v2 event active, Use /joinevent.')
    end
end)
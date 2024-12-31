local serverRestarting = false
local triggeredBy = "None"

RegisterCommand('consolerestart', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) then
        local timeLeft = args[1]
        TriggerEvent('GMT:CloseToRestartServer', true)
        TriggerClientEvent('GMT:CloseToRestart', -1)
        TriggerClientEvent('GMT:announceRestart', -1, tonumber(timeLeft), false)
        TriggerEvent('GMT:restartTime', timeLeft)
        print('Restarting server in : ' .. timeLeft .. ' seconds')
        serverRestarting = true
        triggeredBy = "Console"
        GMT.sendDCLog('server-restart', "Server Restart Triggered \n> Console Trigger \n> " .. timeLeft ..  " seconds")
    end
end)

RegisterCommand('restartserver', function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    local name = GMT.getPlayerName(user_id)
    
    if user_id == 1 or user_id == 2 then
        if args[1] then
            local timeLeft = args[1]
            TriggerClientEvent('GMT:CloseToRestart', -1)
            TriggerEvent('GMT:CloseToRestartServer', true)
            TriggerClientEvent('GMT:announceRestart', -1, tonumber(timeLeft), false)
            TriggerEvent('GMT:restartTime', timeLeft)
            serverRestarting = true
            triggeredBy = name
            GMT.sendDCLog('server-restart', "Server Restart Triggered", "> User ID: **" .. user_id .. "**\n> Name: **" .. name .."**\n> Time **" .. timeLeft .. "** seconds")
        end
    end
end)

RegisterCommand('cancelrestart', function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    local name = GMT.getPlayerName(user_id)
    
    if user_id == 1 or user_id == 2 then
        serverRestarting = false
        triggeredBy = "None"
        GMT.sendDCLog('server-restart', "Server Restart Cancelled", "> User ID: **" .. user_id .. "**\n> Name: **" .. name .."**")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local time = os.date("*t") -- 0-23 (24 hour format)
        local hour = tonumber(time["hour"])
        local min = tonumber(time["min"])
        if hour == 9 then
            if min == 50 and tonumber(time["sec"]) == 0 then
                TriggerClientEvent('chatMessage', -1, "^1GMT: ", { 128, 128, 128 }, "^7The server is restarting in 10 minutes!", "ooc")
            end
        elseif hour == 10 then -- tayser
            if min == 0 and tonumber(time["sec"]) == 0 then
                local restartTime = 60
                TriggerClientEvent('GMT:announceRestart', -1, restartTime, true)
                TriggerEvent('GMT:restartTime', restartTime)
                TriggerClientEvent('GMT:CloseToRestart', -1)
                TriggerEvent('GMT:CloseToRestartServer', true)
                local remainingSeconds = restartTime
                serverRestarting = true
                triggeredBy = "Scheduled"
                GMT.sendDCLog('server-restart', "Scheduled Server Restart \n> At " .. time.hour .. ":" .. time.min .. ":" .. time.sec)
            end
        end
    end
end)

RegisterServerEvent("GMT:restartTime")
AddEventHandler("GMT:restartTime", function(time)
    time = tonumber(time)
    if source ~= '' then return end
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            time = time - 1
            if time == 0 and serverRestarting then
                for k,v in pairs(GMT.getUsers({})) do
                    DropPlayer(v, "[GMT] Server is restarting, please rejoin in a couple minutes!.")
                end
                os.exit()
            end
        end
    end)
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 and not serverRestarting then
        TriggerClientEvent('GMT:announceRestart', -1, 60, true)
        TriggerClientEvent('GMT:CloseToRestart', -1)
        TriggerEvent('GMT:CloseToRestartServer', true)
        GMT.sendDCLog('server-restart', "txAdmin scheduled restart in " .. eventData.secondsRemaining ..  " seconds")
    end
end)
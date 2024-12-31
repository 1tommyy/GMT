local EventTypes = {
    ["Battle Royale"] = {"Legion","Sandy Shores","Paleto","Cayo Perico"}, -- Event Locations for Battle Royale
   -- ["Dropzone"] = {"Sandy Airfield","Grapeseed Airfield","LSD South","Kortz","Rebel Hill","H Bunker"}, -- Event Locations for Dropzone
    -- ["FFA"] = {"Heroin","LSD ATM"}, -- Event Locations for FFA
    -- ["Race"] = {"Forest Playground","Sanchez Parkour","Total Wipeout","District Afterglow","BMX Parkour","Blazer Shootin","Rally Racing","Heathrow Grand Prix","Devil's Breath","Batman Begins","DuneLoader Hell","TNT (Parkour)","Atomic Circuit","City Rooftop","Rainbowland","Sandy Run","Valley Valentine"}, -- Event Locations for Races
  --  ["Musket Wars"] = {"Map"},
}

CurrentEvent = {
    players = {}, -- Players in the event
    isActive = false, -- Is the event active
    eventName = "", -- Name of the event
    eventID = 0, -- Count Up 1 for each event
    eventData = {}, -- Event Data
}

local function CreateEvent(catagory,location,spawncode,user_id)
    if not CurrentEvent.isActive then
        CurrentEvent.isActive = true
        CurrentEvent.eventName = catagory
        CurrentEvent.eventLocation = location
        CurrentEvent.eventID = CurrentEvent.eventID + 1
        CurrentEvent.eventData.spawncode = spawncode or ""
        TriggerClientEvent("chatMessage",-1,"^7^*[GMT Events]",{180,0,0},catagory.." event has started, type /joinevent to join", "eventalert")
        TriggerClientEvent("GMT:announceEventJoinable", -1, catagory, 15)
        if user_id ~= "Console" then
            CurrentEvent.players[user_id] = {name = GMT.getPlayerName(user_id),source = source, user_id = user_id}
            TriggerClientEvent("GMT:EventSequence",source)
            TriggerClientEvent("GMT:addEventPlayer",-1,tbl)
            TriggerClientEvent("GMT:OpentHostEventMenu",source,true,CurrentEvent.eventID)
            TriggerClientEvent("GMT:syncPlayers",source,CurrentEvent.players,CurrentEvent.eventID)
            GMT.sendDCLog("event-create","Event Created","> Event Name: "..catagory.."\n> Event Location: "..location.."\n> Event Host: "..GMT.getPlayerName(user_id).."\n> Host Perm ID: "..user_id)
        end
    else
        GMT.notify(GMT.getuserSource(user_id),"~r~There is already an event active")
    end
end

local function StartEvent()
    if table.maxKeys(CurrentEvent.players) >= 1 then
        if CurrentEvent.eventName == "Battle Royale" then
            TriggerEvent("GMT:Event:BattleRoyale",CurrentEvent.eventLocation)
        elseif CurrentEvent.eventName == "Dropzone" then
            TriggerEvent("GMT:Event:Drop",CurrentEvent.eventLocation)
        elseif CurrentEvent.eventName == "FFA" then
            TriggerEvent("GMT:Event:FFA",CurrentEvent.eventLocation)
        elseif CurrentEvent.eventName == "Race" then
            TriggerEvent("GMT:Event:Race",CurrentEvent.eventLocation,CurrentEvent.eventData.spawncode)
        elseif CurrentEvent.eventName == "Musket Wars" then
            TriggerEvent("GMT:Event:MusketWars",CurrentEvent.eventLocation)
        end
    else
        TriggerClientEvent("chatMessage",-1,"^7^*[GMT Events]",{180,0,0},CurrentEvent.eventName.." event has been cancelled due to not enough players", "eventalert")
        GMT.ResetEvent()
    end
end

local function CanJoinEvent(user_id)
    for k,v in pairs(CurrentEvent.players) do
        if v.user_id == user_id then
            return true
        end
    end
    return false
end

-- [[ Commands ]] --

RegisterCommand("eventMenu",function(source) -- Event Menu for Devs
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.GetStaffLevel(user_id) >=4 or GMT.isDeveloper(user_id) or user_id == 1 then -- tayser
        TriggerClientEvent("GMT:OpenEventMenu",source,EventTypes)
        TriggerClientEvent("GMT:IsAnyEventActive",source,CurrentEvent.isActive)
    end
end)

RegisterCommand("joinevent",function(source) -- Join the event if there is one active
    local source = source
    local user_id = GMT.getUserId(source)
    if CurrentEvent.isActive then
        if not CurrentEvent.players[user_id] then
            local tbl = {name = GMT.getPlayerName(user_id),source = source, user_id = user_id}
            CurrentEvent.players[user_id] = tbl
            TriggerClientEvent("GMT:EventSequence",source)
            TriggerClientEvent("GMT:addEventPlayer",-1,tbl)
            TriggerClientEvent("GMT:OpentHostEventMenu",source,false,CurrentEvent.eventID)
            TriggerClientEvent("GMT:syncPlayers",source,CurrentEvent.players,CurrentEvent.eventID)
        else
            GMT.notify(source, (CurrentEvent.players[user_id] and "~r~You are already in the event") or "~r~You do not meet the requirements to join this event")
        end
    else
        GMT.notify(source, "~r~There is no event active")
    end
end)

RegisterCommand("leaveevent",function(source) -- Leave the event if there is one active
    local source = source
    local user_id = GMT.getUserId(source)
    if CurrentEvent.isActive then
        if CurrentEvent.players[user_id] then
            if CurrentEvent.eventName == "Battle Royale" then
                TriggerClientEvent("GMT:removePlayerFromBR",-1,source)
                TriggerClientEvent("GMT:BattleGrounds:Cleanup",source)
            elseif CurrentEvent.eventName == "Dropzone" then
                GMT.LeaveDropzone(source)
            elseif CurrentEvent.eventName == "FFA" then
                TriggerClientEvent("GMT:FFA:RemovePlayer",-1,source)
            elseif CurrentEvent.eventName == "Musket Wars" then
                TriggerClientEvent("GMT:MusketWars:Leave",-1,source)
                TriggerClientEvent("GMT:MusketWars:End",source)
            end
            SetPlayerRoutingBucket(source,0)
            TriggerClientEvent("GMT:ClearEventData",source)
            TriggerClientEvent("GMT:Teleport",source,vector3(-2265.09, 3224.25, 32.81))
            TriggerClientEvent("GMT:removeEventPlayer",-1, CurrentEvent.players[user_id])
            if #CurrentEvent.players <= 1 then
                TriggerClientEvent("chatMessage",-1,"^7^*[GMT Events]",{180,0,0},CurrentEvent.eventName.." event has ended", "eventalert")
                GMT.ResetEvent()
            end
            CurrentEvent.players[user_id] = nil
        else
            GMT.notify(source, "~r~You are not in the event")
        end
    else
        GMT.notify(source, "~r~There is no event active")
    end
end)

-- [[ Events ]] --

RegisterServerEvent("GMT:RequestActiveEvent",function() -- Request if there is an active event
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.GetStaffLevel(user_id) >=4 or GMT.isDeveloper(user_id) then
        TriggerClientEvent("GMT:IsAnyEventActive",source,CurrentEvent.isActive)
    else
        GMT.notify(source, "~r~You do not have permission to do this")
    end
end)

RegisterServerEvent("GMT:CreateEvent",function(catagory,location,spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.GetStaffLevel(user_id) >=4 or GMT.isDeveloper(user_id) then
        CreateEvent(catagory,location,spawncode,user_id)
        TriggerClientEvent("GMT:Closemenu",source)
    else
        GMT.notify(source, "~r~You do not have permission to do this")
    end
end)

RegisterServerEvent("GMT:StartEvent",function(eventID,leave)
    local source = source
    local user_id = GMT.getUserId(source)
    if (GMT.GetStaffLevel(user_id) >=4 or GMT.isDeveloper(user_id)) and CurrentEvent.isActive then
        if CurrentEvent.eventID == eventID then
            if leave then
                TriggerClientEvent("GMT:ClearEventData",source)
                TriggerClientEvent("GMT:Teleport",source,vector3(-2265.09, 3224.25, 32.81))
                TriggerClientEvent("GMT:removeEventPlayer",-1, CurrentEvent.players[user_id])
                CurrentEvent.players[user_id] = nil
            end
            StartEvent()
        else
            GMT.notify(source, "~r~This event is not active")
        end
    else
        -- GMT.ACBan(15,user_id,"GMT:StartEvent")
    end
end)

RegisterServerEvent("GMT:EndEvent",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.GetStaffLevel(user_id) >=4 or GMT.isDeveloper(user_id) then
        if CurrentEvent.isActive then
            GMT.sendDCLog("event-end","Event Ended","> Event Name: "..CurrentEvent.eventName.."\n> Event Location: "..CurrentEvent.eventLocation.."\n> Event Host: "..GMT.getPlayerName(user_id).."\n> Host Perm ID: "..user_id)
            TriggerClientEvent("chatMessage",-1,"^7^*[GMT Events]",{180,0,0},"Event has been ended by "..GMT.getPlayerName(user_id), "eventalert")
            GMT.ResetEvent()
        else
            GMT.notify(source, "~r~There is no event active") -- tayser
        end
    else
        GMT.ACBan(15,user_id,"GMT:EndEvent")
    end
end)

function GMT.ManagePlayerDeath(killedsource,killersource,WeaponName,distance)
    local user_id = GMT.getUserId(killedsource)
    local killer_id = GMT.getUserId(killersource)
    local killedname = GMT.getPlayerName(user_id)
    local killername = GMT.getPlayerName(killer_id)
    local killergroup = 'none'
    local killedgroup = 'none'
    if GMT.hasPermission(user_id, 'police.armoury') then
        killedgroup = 'police'
    elseif GMT.hasPermission(user_id, 'nhs.menu') then
        killedgroup = 'nhs'
    end
    if GMT.hasPermission(killerID, 'police.armoury') then
        killergroup = 'police'
    elseif GMT.hasPermission(killerID, 'nhs.menu') then
        killergroup = 'nhs'
    end
    if killedsource ~= killersource then
        for k,v in pairs(CurrentEvent.players) do
            TriggerClientEvent('GMT:newKillFeed', v.source, killername, killedname, GetWeaponClass(WeaponName), false, math.floor(distance), killedgroup, killergroup)
        end
    end
    if CurrentEvent.eventName == "Battle Royale" then
        TriggerClientEvent("GMT:removeEventPlayer",-1, CurrentEvent.players[user_id])
        TriggerClientEvent("GMT:addBRKill",-1,killersource,GMT.getPlayerName(killer_id))
        TriggerClientEvent("GMT:removePlayerFromBR",-1,killedsource)
        TriggerClientEvent("GMT:BattleGrounds:Cleanup",killedsource)--, false, {name=GMT.getPlayerName(user_id),source=killedsource})
        TriggerClientEvent("GMT:ClearEventData",killedsource)
        GMT.notify(killedsource, "~r~You have been eliminated from the event")
        SetPlayerRoutingBucket(killedsource,0)
        CurrentEvent.players[user_id] = nil
        if #CurrentEvent.players <= 1 then
            TriggerClientEvent("chatMessage",-1,"^7^*[GMT Events]",{180,0,0},killername.." has won the "..CurrentEvent.eventName.." event", "eventalert")
            if killedsource ~= killersource then
                local winners = {{name=GMT.getPlayerName(killer_id), source=killersource}}
                local losers = {{name=GMT.getPlayerName(user_id),source=killedsource}}
                for k,v in pairs(CurrentEvent.players) do
                    GMTclient.RevivePlayer(v.source, {})
                    TriggerClientEvent("GMT:Battlegrounds:Podium",v.source, winners, losers)
                end
            end
            GMT.giveBankMoney(killer_id, math.random(250000,450000))
            GMT.ResetEvent()
        end
    elseif CurrentEvent.eventName == "Dropzone" then
        GMT.RespawnDrop(killedsource)
    elseif CurrentEvent.eventName == "Musket Wars" then
        GMT.MusketKill(killedsource,killersource)
    end
end

RegisterCommand("testbrkills",function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.isDeveloper(user_id) then
        TriggerClientEvent("GMT:addBRKill",-1,source,GMT.getPlayerName(source))
    end
end)

AddEventHandler("playerDropped",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if CurrentEvent.isActive then
        if CurrentEvent.players[user_id] then
            if CurrentEvent.eventName == "Battle Royale" then
                TriggerClientEvent("GMT:removePlayerFromBR",-1,source)
            elseif CurrentEvent.eventName == "Dropzone" then
                TriggerClientEvent("GMT:removeLootcrate",source,1)
                TriggerClientEvent("GMT:removeCrateRedzone",source)
            elseif CurrentEvent.eventName == "FFA" then
                TriggerClientEvent("GMT:FFA:RemovePlayer",-1,source)
            end
            if #CurrentEvent.players <= 1 then
                TriggerClientEvent("chatMessage",-1,"^7^*[GMT Events]",{180,0,0},CurrentEvent.eventName.." event has ended", "eventalert")
                GMT.ResetEvent()
            end
            TriggerClientEvent("GMT:removeEventPlayer",-1, CurrentEvent.players[user_id])
        end
    end
end)

-- [[ Functions ]] --

function GMT.InEvent(user_id)
    if CurrentEvent.players[user_id] then
        return true
    else
        return false
    end
end

function GMT.ResetEvent()
    for k,v in pairs(CurrentEvent.players) do
        SetPlayerRoutingBucket(v.source,0)
        TriggerClientEvent("GMT:syncPlayers",v.source,{},CurrentEvent.eventID)
        TriggerClientEvent("GMT:ClearEventData",v.source)
        TriggerClientEvent("GMT:Teleport",v.source,vector3(-2265.09, 3224.25, 32.81))
        if CurrentEvent.eventName == "Battle Royale" then
            TriggerClientEvent("GMT:BattleGrounds:Cleanup",v.source)
            TriggerClientEvent("GMT:ClearEventData",v.source)
        elseif CurrentEvent.eventName == "Dropzone" then
            GMT.LeaveDropzone(v.source)
        elseif CurrentEvent.eventName == "Musket Wars" then
            TriggerClientEvent("GMT:MusketWars:End",v.source)
        end
    end
    CurrentEvent.isActive = false
    CurrentEvent.eventName = ""
    CurrentEvent.eventLocation = ""
    CurrentEvent.players = {}
end


-- Citizen.CreateThread(function()
--     Wait(30*60*1000)
--     while true do
--         local players = GetPlayers()
--         if not CurrentEvent.isActive then -- and #players >= 3 then
--             local catagory,location = "",""
--             if #players >= 10 then
--                 catagory = "Battle Royale"
--                 location = EventTypes["Battle Royale"][math.random(1,#EventTypes["Battle Royale"])]
--             elseif #players >= 3 then
--                 catagory = "Dropzone"
--                 location = EventTypes["Dropzone"][math.random(1,#EventTypes["Dropzone"])]
--             end
--             CreateEvent(catagory,location,nil,"Console")
--             Wait(60000)
--             StartEvent()
--         end
--         Wait(30*60*1000)
--     end
-- end)
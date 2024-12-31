local htmlEntities = module("util/server/htmlEntities")
local Tools = module("util/server/Tools")

RegisterServerEvent('GMT:OpenSettings')
AddEventHandler('GMT:OpenSettings', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        if GMT.hasPermission(user_id, "admin.tickets") then
            TriggerClientEvent("GMT:OpenAdminMenu", source, true)
        else
            TriggerClientEvent("GMT:OpenSettingsMenu", source, false)
        end
    end
end)

RegisterNetEvent("GMT:sendNoclipData")
AddEventHandler("GMT:sendNoclipData", function(startCoords, endCoords)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.tickets") then
        local formattedDistance = getMoneyStringFormatted(math.floor(#(startCoords-endCoords))).."m"
        GMT.sendDCLog("staff","GMT Noclip","No Clip Distance\n\n> Admin Name: "..GMT.getPlayerName(user_id).."\n> Admin TempID: "..source.."\n> Admin PermID: "..user_id.."\n> Distance Traveled: "..formattedDistance.."\n> Start Coords: "..startCoords.."\n> End Coords: "..endCoords)
    -- else
    --     GMT.ACBan(15,user_id,"sendNoclipData") -- tayser
    end
end)

-- RegisterCommand("gethours", function(source, args)
--     local v = source
--     local D = math.ceil(GMT.getUserDataTable(v).PlayerTime/60) or 0
--     if GMT.hasGroup(user_id,"Founder") then
--         GMT.notify(v, "~g~You currently have ~b~"..D.." ~g~hours.")
--     end
-- end)





local warningCooldowns = {}
local currentTime = os.time()
local formattedTime = os.date("%Y-%m-%d %H:%M:%S", currentTime)
local warningCooldownSeconds = 15

RegisterCommand('staffdm', function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    local their_id = tonumber(args[1])
    local their_source = GMT.getUserSource(their_id)
    local adminName = GMT.getPlayerName(user_id)
    if warningCooldowns[user_id] and warningCooldowns[user_id] > os.time() then
        GMT.notify(source, '~r~Staff DM is on cooldown.')
        return
    end
    if their_source == nil then return GMT.notify(source, '~r~User is not online.') end
    GMT.prompt(source, 'Please Enter Message:', '', function(source,msg)
        if msg == '' then return GMT.notify(source, '~r~Invalid Message') end
        if GMT.hasPermission(user_id, "admin.tickets") then
            TriggerClientEvent('GMT:StaffDMMessage', their_source, adminName, msg)
            GMT.notify(source, '~g~Message sent')
            GMT.sendDCLog('staff-dm', "GMT Staff DM Logs", "> Admin Name: **"..adminName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Target ID: **"..their_id.."**\n> Target TempID: **"..their_source.."**\n> Message: **"..msg.."**")
            warningCooldowns[user_id] = os.time() + warningCooldownSeconds 
        else
            GMT.notify(source, '~r~You do not have the necessary permissions to send a dm.')
        end
    end)
end)

RegisterNetEvent("GMT:TriggerSendWarning")
AddEventHandler("GMT:TriggerSendWarning", function(target, warningMessage)
    local source = source
    local user_id = GMT.getUserId(source)
    local adminName = GMT.getPlayerName(user_id)
    local tuser_id = GMT.getUserId(target)

    if warningCooldowns[user_id] and warningCooldowns[user_id] > os.time() then
        GMT.notify(source, '~r~Warning is on cooldown.')
        return
    end

    if GMT.hasPermission(user_id, "admin.tickets") then
        TriggerClientEvent('GMT:SendWarning', target, warningMessage)

        local query = "INSERT INTO gmt_staff_warnings (admin_id, admin_name, target_id, warning_message, timestamp) VALUES (@admin_id, @admin_name, @target_id, @warning_message, @timestamp)"
        local params = {
            ["@admin_id"] = user_id,
            ["@admin_name"] = adminName,
            ["@target_id"] = tuser_id,
            ["@warning_message"] = warningMessage,
            ["@timestamp"] = formattedTime
        }

        exports["gmt"]:executeSync(query, params, function()
            GMT.sendDCLog('warning', "GMT Warning Logs", "> Admin Name: **"..adminName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Target ID: **"..target.."**\n> Warning Message: **"..warningMessage.."**\n> Timestamp: **"..formattedTime.."**")
        end)
        warningCooldowns[user_id] = currentTime + warningCooldownSeconds 
    else
        GMT.notify(source, '~r~You do not have the necessary permissions to send a warning.')
    end
end)

RegisterCommand("sethours", function(source, args) 
    if source == 0 then 
        local data = GMT.getUserDataTable(tonumber(args[1]))
        data.PlayerTime = tonumber(args[2])*60
        print(GMT.getPlayerName(tonumber(args[1])).."'s hours have been set to: "..tonumber(args[2]))
    end  
end)

RegisterServerEvent("GMT:GetGroups")
AddEventHandler("GMT:GetGroups",function(perm)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("GMT:GotGroups", source, GMT.getUserGroups(perm))
    end
end)

RegisterServerEvent("GMT:CheckPov")
AddEventHandler("GMT:CheckPov",function(userperm)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.tickets") then
        if GMT.hasPermission(userperm, 'pov.list') then
            TriggerClientEvent('GMT:ReturnPov', source, true)
        else
            TriggerClientEvent('GMT:ReturnPov', source, false)
        end
    end
end)

RegisterServerEvent("wk:fixVehicle")
AddEventHandler("wk:fixVehicle",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent('wk:fixVehicle', source)
        GMT.sendDCLog('staff', "GMT Fix Vehicle Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**")
    end
end)

local spectatingPositions = {}
RegisterServerEvent("GMT:spectatePlayer")
AddEventHandler("GMT:spectatePlayer", function(id)
    local source = source
    local user_id = GMT.getUserId(source)
    local playerssource = GMT.getUserSource(id)
    if GMT.hasPermission(user_id, "admin.spectate") then
        if playerssource then
            spectatingPositions[user_id] = {coords = GetEntityCoords(GetPlayerPed(source)), bucket = GetPlayerRoutingBucket(source)}
            GMT.setBucket(source, GetPlayerRoutingBucket(playerssource))
            TriggerClientEvent("GMT:spectatePlayer", source, playerssource, GetEntityCoords(GetPlayerPed(playerssource)))
            GMT.sendDCLog('spectate', "GMT Spectate Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..playerssource.."**")
        else
            GMT.notify(source, "~r~You can't spectate an offline player.")
        end
    end
end)

RegisterServerEvent("GMT:stopSpectatePlayer")
AddEventHandler("GMT:stopSpectatePlayer", function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.spectate") then
        TriggerClientEvent("GMT:stopSpectatePlayer",source)
        for k,v in pairs(spectatingPositions) do
            if k == user_id then
                TriggerClientEvent("GMT:stopSpectatePlayer",source,v.coords,v.bucket)
                SetEntityCoords(GetPlayerPed(source),v.coords)
                GMT.setBucket(source, v.bucket)
                spectatingPositions[k] = nil
            end
        end
    end
end)

RegisterServerEvent("GMT:Giveweapon")
AddEventHandler("GMT:Giveweapon",function()
    local source = source
    local user_id = GMT.getUserId(source)
    local weapon = 'WEAPON_'..string.upper(hash)
    if GMT.hasPermission(user_id, "dev.menu") then
        GMT.prompt(source,"Weapon Name:","",function(source,hash) 
            GMTclient.giveWeapons(source, {{[weapon] = {ammo = 250}}, false,globalpasskey})
            GMT.notify(source, "~g~Successfully spawned ~b~"..hash)
            GMT.sendDCLog('spawn-weapon',"GMT Weapon Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Weapon: **" .. weapon)
        end)
    end
end)

RegisterServerEvent("GMT:ForceClockOff")
AddEventHandler("GMT:ForceClockOff", function(player_temp)
    local source = source
    local user_id = GMT.getUserId(source)
    local player_perm = GMT.getUserId(player_temp)
    if GMT.hasPermission(user_id,"admin.tp2waypoint") then
        GMT.removeAllJobs(player_perm)
        GMT.notify(source, '~g~User clocked off')
        GMT.notify(player_temp, '~b~You have been force clocked off.')
        GMT.sendDCLog('force-clock-off',"GMT Faction Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..GMT.getPlayerName(player_perm).."**\n> Players TempID: **"..player_temp.."**\n> Players PermID: **"..player_perm.."**")
        TriggerClientEvent("GMT:jobSelectorCooldown", player_temp, true)
    else
        GMT.ACBan(15,user_id,"Force Clock Off")
    end
end)

RegisterServerEvent("GMT:AddGroup")
AddEventHandler("GMT:AddGroup",function(perm, selgroup)
    local source = source
    local user_id = GMT.getUserId(source)
    local permsource = GMT.getUserSource(perm)
    if GMT.hasPermission(user_id, "group.add") then
        if selgroup == "pov" and not GMT.hasPermission(user_id, "group.add.pov") then
            GMT.notify(source, "You don't have permission to do that")
        else
            GMT.addUserGroup(perm, selgroup)
            local user_groups = GMT.getUserGroups(perm)
            TriggerClientEvent("GMT:GotGroups", source, user_groups)
            GMT.sendDCLog('group',"GMT Group Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..GMT.getPlayerName(perm).."**\n> Players TempID: **"..permsource.."**\n> Players PermID: **"..perm.."**\n> Group: **"..selgroup.."**\n> Type: **Added**")
        end
    end
end)

RegisterServerEvent("GMT:RemoveGroup")
AddEventHandler("GMT:RemoveGroup",function(perm, selgroup)
    local source = source
    local user_id = GMT.getUserId(source)
    local permsource = GMT.getUserSource(perm)
    if GMT.hasPermission(user_id, "group.remove") then
        if selgroup == "Founder" and not GMT.hasPermission(user_id, "group.remove.founder") then
            GMT.notify(source, "You don't have permission to do that") 
            elseif selgroup == "Developer" and not GMT.hasPermission(user_id, "group.remove.developer") then
                GMT.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Staff Manager" and not GMT.hasPermission(user_id, "group.remove.staffmanager") then
            GMT.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Community Manager" and not GMT.hasPermission(user_id, "group.remove.commanager") then
            GMT.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Head Administrator" and not GMT.hasPermission(user_id, "group.remove.headadmin") then
            GMT.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Senior Admin" and not GMT.hasPermission(user_id, "group.remove.senioradmin") then
            GMT.notify(source, "You don't have permission to do that")
        elseif selgroup == "Admin" and not GMT.hasPermission(user_id, "group.remove.administrator") then
            GMT.notify(source, "You don't have permission to do that")
        elseif selgroup == "Senior Moderator" and not GMT.hasPermission(user_id, "group.remove.srmoderator") then
            GMT.notify(source, "You don't have permission to do that")
        elseif selgroup == "Moderator" and not GMT.hasPermission(user_id, "group.remove.moderator") then
            GMT.notify(source, "You don't have permission to do that")
        elseif selgroup == "Support Team" and not GMT.hasPermission(user_id, "group.remove.supportteam") then
            GMT.notify(source, "You don't have permission to do that")
        elseif selgroup == "Trial Staff" and not GMT.hasPermission(user_id, "group.remove.trial") then
            GMT.notify(source, "You don't have permission to do that")
        elseif selgroup == "pov" and not GMT.hasPermission(user_id, "group.remove.pov") then
            GMT.notify(source, "You don't have permission to do that")
        else
            GMT.removeUserGroup(perm, selgroup)
            local user_groups = GMT.getUserGroups(perm)
            TriggerClientEvent("GMT:GotGroups", source, user_groups)
            GMT.sendDCLog('group',"GMT Group Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..GMT.getPlayerName(perm).."**\n> Players TempID: **"..permsource.."**\n> Players PermID: **"..perm.."**\n> Group: **"..selgroup.."**\n> Type: **Removed**")
        end
    end
end)

local bans = {
    {id = "trolling",name = "1.0 Trolling",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "trollingminor",name = "1.0 Trolling (Minor)",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "metagaming",name = "1.1 Metagaming",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "powergaming",name = "1.2 Power Gaming ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "failrp",name = "1.3 Fail RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rdm", name = "1.4 RDM",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "massrdm",name = "1.4.1 Mass RDM",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "nrti",name = "1.5 No Reason to Initiate (NRTI) ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "vdm", name = "1.6 VDM",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "massvdm",name = "1.6.1 Mass VDM",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "offlanguageminor",name = "1.7 Offensive Language/Toxicity (Minor)",durations = {2,24,72},bandescription = "1st Offense: 2hr\n2nd Offense: 24hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "offlanguagestandard",name = "1.7 Offensive Language/Toxicity (Standard)",durations = {48,72,168},bandescription = "1st Offense: 48hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "offlanguagesevere",name = "1.7 Offensive Language/Toxicity (Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "breakrp",name = "1.8 Breaking Character",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "combatlog",name = "1.9 Combat logging",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "combatstore",name = "1.10 Combat storing",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "exploitingstandard",name = "1.11 Exploiting (Standard)",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "exploitingsevere",name = "1.11 Exploiting (Severe)",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "oogt",name = "1.12 Out of game transactions (OOGT)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "spitereport",name = "1.13 Spite Reporting",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "scamming",name = "1.14 Scamming",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "loans",name = "1.15 Loans",durations = {48,168,-1},bandescription = "1st Offense: 48hr\n2nd Offense: 168hr\n3rd Offense: Permanent",itemchecked = false},
    {id = "wastingadmintime",name = "1.16 Wasting Admin Time",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "ftvl",name = "2.1 Value of Life",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "sexualrp",name = "2.2 Sexual RP",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "terrorrp",name = "2.3 Terrorist RP",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "impwhitelisted",name = "2.4 Impersonation of Whitelisted Factions",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gtadriving",name = "2.5 GTA Online Driving",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "nlr", name = "2.6 NLR",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "badrp",name = "2.7 Bad RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "kidnapping",name = "2.8 Kidnapping",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "stealingems",name = "3.0 Theft of Emergency Vehicles",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "whitelistabusestandard",name = "3.1 Whitelist Abuse",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "whitelistabusesevere",name = "3.1 Whitelist Abuse",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "copbaiting",name = "3.2 Cop Baiting",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "pdkidnapping",name = "3.3 PD Kidnapping",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "unrealisticrevival",name = "3.4 Unrealistic Revival",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "interjectingrp",name = "3.5 Interjection of RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "combatrev",name = "3.6 Combat Reviving",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gangcap",name = "3.7 Gang Cap",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "maxgang",name = "3.8 Max Gang Numbers",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "gangalliance",name = "3.9 Gang Alliance",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "impgang",name = "3.10 Impersonation of Gangs",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gzstealing",name = "4.1 Stealing Vehicles in Greenzone",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "gzillegal",name = "4.2 Selling Illegal Items in Greenzone",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gzretretreating",name = "4.3 Greenzone Retreating ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rzhostage",name = "4.5 Taking Hostage into Redzone",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rzretreating",name = "4.6 Redzone Retreating",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "advert",name = "1.1 Advertising",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "bullying",name = "1.2 Bullying",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "impersonationrule",name = "1.3 Impersonation",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "language",name = "1.4 Language",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "discrim",name = "1.5 Discrimination ",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "attacks",name = "1.6 Malicious Attacks ",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false    },
    {id = "PIIstandard",name = "1.7 PII (Personally Identifiable Information)(Standard)",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "PIIsevere",name = "1.7 PII (Personally Identifiable Information)(Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "chargeback",name = "1.8 Chargeback",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "discretion",name = "1.9 Staff Discretion",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false    },
    {id = "cheating",name = "1.10 Cheating",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "banevading",name = "1.11 Ban Evading",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "fivemcheats",name = "1.12 Withholding/Storing FiveM Cheats",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "altaccount",name = "1.13 Multi-Accounting",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "association",name = "1.14 Association with External Modifications",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "pov",name = "1.15 Failure to provide POV ",durations = {2,-1,-1},bandescription = "1st Offense: 2hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false    },
    {id = "withholdinginfostandard",name = "1.16 Withholding Information From Staff (Standard)",durations = {48,72,168},bandescription = "1st Offense: 48hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "withholdinginfosevere",name = "1.16 Withholding Information From Staff (Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "blackmail",name = "1.17 Blackmailing",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "breachterms",name = "1.18 Breach of Management Terms",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
}
    
   

local PlayerOffenses = {}
local PlayerBanCachedDuration = {}
local defaultBans = {}

RegisterServerEvent("GMT:GenerateBan")
AddEventHandler("GMT:GenerateBan", function(PlayerID, RulesBroken)
    local source = source
    local PlayerCacheBanMessage = {}
    local PermOffense = false
    local separatormsg = {}
    local points = 0
    PlayerBanCachedDuration[PlayerID] = 0
    PlayerOffenses[PlayerID] = {}
    if GMT.hasPermission(GMT.getUserId(source), "admin.tickets") then
        exports['gmt']:execute("SELECT * FROM gmt_bans_offenses WHERE UserID = @UserID", {UserID = PlayerID}, function(result)
            if #result > 0 then
                points = result[1].points
                PlayerOffenses[PlayerID] = json.decode(result[1].Rules)
                for k,v in pairs(RulesBroken) do
                    for a,b in pairs(bans) do
                        if b.id == k then
                            PlayerOffenses[PlayerID][k] = PlayerOffenses[PlayerID][k] + 1
                            if PlayerOffenses[PlayerID][k] > 3 then
                                PlayerOffenses[PlayerID][k] = 3
                            end
                            PlayerBanCachedDuration[PlayerID] = PlayerBanCachedDuration[PlayerID] + bans[a].durations[PlayerOffenses[PlayerID][k]]
                            if bans[a].durations[PlayerOffenses[PlayerID][k]] ~= -1 then
                                points = points + bans[a].durations[PlayerOffenses[PlayerID][k]]/24
                            end
                            table.insert(PlayerCacheBanMessage, bans[a].name)
                            if bans[a].durations[PlayerOffenses[PlayerID][k]] == -1 then
                                PlayerBanCachedDuration[PlayerID] = -1
                                PermOffense = true
                            end
                            if PlayerOffenses[PlayerID][k] == 1 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~1st Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            elseif PlayerOffenses[PlayerID][k] == 2 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~2nd Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            elseif PlayerOffenses[PlayerID][k] >= 3 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~3rd Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            end
                        end
                    end
                end
                if PermOffense then 
                    PlayerBanCachedDuration[PlayerID] = -1
                end
                Wait(100)
                TriggerClientEvent("GMT:ReceiveBanPlayerData", source, PlayerBanCachedDuration[PlayerID], table.concat(PlayerCacheBanMessage, ", "), separatormsg, math.floor(points))
            end
        end)
    end
end)

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = GMT.getUserId(source)
    for k,v in pairs(bans) do
        defaultBans[v.id] = 0
    end
    exports["gmt"]:executeSync("INSERT IGNORE INTO gmt_bans_offenses(UserID,Rules) VALUES(@UserID, @Rules)", {UserID = user_id, Rules = json.encode(defaultBans)})
    exports["gmt"]:executeSync("INSERT IGNORE INTO gmt_user_notes(user_id) VALUES(@user_id)", {user_id = user_id})
end)

RegisterCommand('refreshwarningpoints', function(source, args) -- for removing points each month
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id == 1 then
        for k,v in pairs(bans) do
            defaultBans[v.id] = 0
        end
        exports["gmt"]:executeSync("INSERT IGNORE INTO gmt_bans_offenses(UserID,Rules) VALUES(@UserID, @Rules)", {UserID = user_id, Rules = json.encode(defaultBans)})
        exports["gmt"]:executeSync("INSERT IGNORE INTO gmt_user_notes(user_id) VALUES(@user_id)", {user_id = user_id})
    end
end)

RegisterCommand('removepoints', function(source, args) -- for removing points each month
    local source = source
    if GMT.getUserId(source) == 1 then
        removePoints = tonumber(args[1])
        exports['gmt']:execute("UPDATE gmt_bans_offenses SET points = CASE WHEN ((points-@removepoints)>0) THEN (points-@removepoints) ELSE 0 END WHERE points > 0", {removepoints = removePoints}, function() end)
        GMT.notify(source, '~g~Removed '..removePoints..' points from all users.')
    end
end)

RegisterServerEvent("GMT:BanPlayer")
AddEventHandler("GMT:BanPlayer", function(PlayerID, Duration, BanMessage, BanPoints)
    local source = source
    local AdminPermID = GMT.getUserId(source)
    local AdminName = GMT.getPlayerName(AdminPermID)
    local CurrentTime = os.time()

    if GMT.hasPermission(AdminPermID, 'admin.ban') then
        local PlayerDiscordID = 0
        local PlayerSource = GMT.getUserSource(PlayerID)
        local PlayerName = GMT.getPlayerName(PlayerID) or GMT.GetNameOffline(PlayerID)
        GMT.prompt(source, "Extra Ban Information (Hidden)", "", function(player, Evidence)
            if GMT.hasPermission(AdminPermID, "admin.tickets") then
                if Evidence == "" then
                    GMT.notify(source, "~r~Evidence field was left empty, please fill this in via Discord.")
                    Evidence = "No Evidence Provided"
                end
                local banDuration
                local BanChatMessage
                if Duration == -1 then
                    banDuration = "perm"
                    BanPoints = 0
                    BanChatMessage = "has been permanently banned for "..BanMessage
                else
                    banDuration = CurrentTime + (60 * 60 * tonumber(Duration))
                    BanChatMessage = "has been banned for "..BanMessage.." ("..Duration.."hrs)"
                end
                GMT.sendDCLog('banned-player', "GMT Banned Players", "> Admin PermID: **"..AdminPermID.."**\n> Players PermID: **"..PlayerID.."**\n> Ban Duration: **"..Duration.."**\n> Reason: **"..BanMessage.."**\n> Evidence: "..Evidence)
                TriggerClientEvent("chatMessage", -1, "^8", {180, 0, 0}, "^1"..PlayerName .. " ^3"..BanChatMessage, "alert")
                GMT.sendDCLog('ban-player', "GMT Ban Logs", AdminName.. " banned "..PlayerID, "> Admin Name: **"..AdminName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..AdminPermID.."**\n> Players PermID: **"..PlayerID.."**\n> Ban Duration: **"..Duration.."**\n> Reason(s): **"..BanMessage.."**")
            -- if PlayerID == 1 then
                --    GMT.notify(PlayerSource, "[BAN]\nName: ".. PlayerName .. "\nPoints: " .. BanPoints)
            -- else
                GMT.notify(source, "~g~Banned User ID: ".. PlayerID .. "(" .. PlayerName .. ")")
                    GMT.ban(source, PlayerID, banDuration, BanMessage, Evidence)
            -- end
                GMT.AddWarnings(PlayerID, AdminName, BanMessage, Duration, BanPoints)
                exports['gmt']:execute("UPDATE gmt_bans_offenses SET Rules = @Rules, points = @points WHERE UserID = @UserID", {Rules = json.encode(PlayerOffenses[PlayerID]), UserID = PlayerID, points = BanPoints}, function() end)
                local a = exports['gmt']:executeSync("SELECT * FROM gmt_bans_offenses WHERE UserID = @uid", {uid = PlayerID})
                for k, v in pairs(a) do
                    if v.UserID == PlayerID then
                        if v.points > 10 then
                            exports['gmt']:execute("UPDATE gmt_bans_offenses SET Rules = @Rules, points = @points WHERE UserID = @UserID", {Rules = json.encode(PlayerOffenses[PlayerID]), UserID = PlayerID, points = 10}, function() end)
                            GMT.banConsole(PlayerID, 2160, "You have reached 10 points and have received a 3-month ban.")
                        end
                    end
                end
            end
        end)
    else
    end
end)


local screenshotdata = {}

RegisterServerEvent('GMT:RequestScreenshot')
AddEventHandler('GMT:RequestScreenshot', function(admin,target)
    local source = source
    local user_id = GMT.getUserId(source)
    local target_id = GMT.getUserId(target)
    if GMT.hasPermission(user_id, 'admin.screenshot') then
        local screenshotid = #screenshotdata + 1
        screenshotdata[screenshotid] = {target = target_id, admin = user_id}
        TriggerClientEvent("GMT:takeClientScreenshotAndUpload", target, GMT.getWebhook('media-cache'),screenshotid)
    else
        GMT.ACBan(15,user_id,"GMT:RequestScreenshot")
    end
end)

RegisterServerEvent('GMT:RequestVideo')
AddEventHandler('GMT:RequestVideo', function(admin,target)
    local source = source
    local user_id = GMT.getUserId(source)
    local target_id = GMT.getUserId(target)
    if GMT.hasPermission(user_id, 'admin.screenshot') then
        TriggerClientEvent("GMT:takeClientVideoAndUpload", target, GMT.getWebhook('media-cache'),"Admin")
    else
        GMT.ACBan(15,user_id,"GMT:RequestVideo")
    end
end)

RegisterServerEvent("GMT:ScreenshotProcessed",function(screenshotid,screenshot)
    local source = source
    local user_id = GMT.getUserId(source)
    if screenshotdata[screenshotid] and screenshotdata[screenshotid].target == user_id then
        --print("Screenshot | ID: " .. screenshotdata[screenshotid].target)
        GMT.sendDCLog('screenshot', 'GMT Screenshot Logs', "> Players Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**",screenshot)
    end
end)

RegisterServerEvent("GMT:VideoProcessed",function(videoType,video)
    local source = source
    local user_id = GMT.getUserId(source)
    if not video then
        print("fatal error video is nil src:"..source.." usrid:"..user_id)
        return
    end
    local videolink = "https://discord.com/channels/1319675915747196999/1319676512491802755"..video.channel_id.."/"..video.id
    if videoType == "Admin" then
        GMT.sendDCLog('video', 'GMT Video Logs', "> Players Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Video: "..videolink)
    elseif videoType == "Anticheat" then
        GMT.VideoProcessed(user_id,videolink)
    elseif videoType == "Lootbag" then
        GMT.sendDCLog('lootbag', 'GMT Lootbag Logs', "> Players Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Video: "..videolink)
    else
       GMT.ACBan(15, user_id, "GMT:VideoProccessed")
    end
end)

RegisterServerEvent('GMT:KickPlayer')
AddEventHandler('GMT:KickPlayer', function(admin, target, tempid)
    local source = source
    local user_id = GMT.getUserId(source)
    local target_id = GMT.getUserSource(target)
    if GMT.hasPermission(user_id, 'admin.kick') then
        GMT.prompt(source,"Reason:","",function(source,Reason) 
            if Reason == "" then return end
            GMT.sendDCLog('kick-player', 'GMT Kick Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(target).."**\n> Player TempID: **"..target_id.."**\n> Player PermID: **"..target.."**\n> Kick Reason: **"..Reason.."**")
            GMT.kick(target_id, "GMT You have been kicked | Your ID is: "..target.." | Reason: " ..Reason.." | Kicked by "..GMT.getPlayerName(user_id) or "No reason specified")
            GMT.notify(admin, '~g~Kicked Player.')
        end)
    else
        GMT.ACBan(15,user_id,"GMT:KickPlayer")
    end
end)


RegisterServerEvent('GMT:RemoveWarning')
AddEventHandler('GMT:RemoveWarning', function(warningid)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        if GMT.hasPermission(user_id, "admin.removewarn") then 
            exports['gmt']:execute("SELECT * FROM gmt_warnings WHERE warning_id = @warning_id", {warning_id = tonumber(warningid)}, function(result) 
                if result then
                    for k,v in pairs(result) do
                        if v.warning_id == tonumber(warningid) then
                            exports['gmt']:execute("DELETE FROM gmt_warnings WHERE warning_id = @warning_id", {warning_id = v.warning_id})
                            exports['gmt']:execute("UPDATE gmt_bans_offenses SET points = CASE WHEN ((points-@removepoints)>0) THEN (points-@removepoints) ELSE 0 END WHERE UserID = @UserID", {UserID = v.user_id, removepoints = (v.duration/24)}, function() end)
                            GMT.notify(source, '~g~Removed F10 Warning #'..warningid..' ('..(v.duration/24)..' points) from ID: '..v.user_id)
                            GMT.sendDCLog('remove-warning', 'GMT Remove Warning Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Warning ID: **"..warningid.."**")
                        end
                    end
                end
            end)
        else
            GMT.ACBan(15,user_id,"GMT:RemoveWarning")
        end
    end
end)

RegisterServerEvent("GMT:Unban")
AddEventHandler("GMT:Unban",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.unban') then
        GMT.prompt(source,"Perm ID:","",function(source,permid) 
            if permid == '' then return end
            permid = parseInt(permid)
            local permsource = GMT.getUserSource(permid)
            GMT.notify(source, '~g~Unbanned ID: ' .. permid)
            GMT.sendDCLog('unban-player', 'GMT Unban Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player PermID: **"..permid.."**")
            GMT.setBanned(permid,false)
        end)
    else
        GMT.ACBan(15,user_id,"GMT:Unban")
    end
end)


RegisterServerEvent("GMT:getNotes")
AddEventHandler("GMT:getNotes",function(player)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tickets') then
        exports['gmt']:execute("SELECT * FROM gmt_user_notes WHERE user_id = @user_id", {user_id = player}, function(result) 
            if result and #result > 0 then
                TriggerClientEvent('GMT:sendNotes', source, result[1].info)
            end
        end)
    end
end)

RegisterServerEvent("GMT:updatePlayerNotes")
AddEventHandler("GMT:updatePlayerNotes",function(player, notes)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tickets') then
        exports['gmt']:execute("SELECT * FROM gmt_user_notes WHERE user_id = @user_id", {user_id = player}, function(result) 
            if result then
                exports['gmt']:execute("UPDATE gmt_user_notes SET info = @info WHERE user_id = @user_id", {user_id = player, info = json.encode(notes)})
                GMT.notify(source, '~g~Notes updated.')
            end
        end)
    end
end)

local cooldowns = {}
local cooldownSeconds = 5 

RegisterServerEvent('GMT:SlapPlayer')
AddEventHandler('GMT:SlapPlayer', function(admin, target)
    local source = source
    local user_id = GMT.getUserId(source)
    
    if cooldowns[user_id] and cooldowns[user_id] > os.time() then
        GMT.notify(admin, '~r~Slap player is on cooldown.')
        --DropPlayer(admin,"Stop slapping players!")
        return
    end

    local player_id = GMT.getUserId(target)
    if GMT.hasPermission(user_id, "admin.slap") then
        if GMTclient.staffMode(source, {false}) then
            GMTclient.staffMode(source, {true}) 
        end
        GMT.sendDCLog('slap', 'GMT Slap Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(player_id).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..player_id.."**")
        TriggerClientEvent('GMT:SlapPlayer', target)
        GMT.notify(admin, '~g~Slapped '.. GMT.getPlayerName(player_id)..'.')
        cooldowns[user_id] = os.time() + cooldownSeconds 
    else
        GMT.ACBan(15,user_id,"GMT:SlapPlayer")
    end
end)

RegisterServerEvent('GMT:RevivePlayer')
AddEventHandler('GMT:RevivePlayer', function(admin, targetid, reviveall)
    local source = source
    local user_id = GMT.getUserId(source)
    local player_id = targetid
    local target = GMT.getUserSource(player_id)
    if target then
        if GMT.hasPermission(user_id, "admin.revive") and not GMTclient.isStaffedOn(source) then
            GMTclient.RevivePlayer(target, {})
            GMTclient.setPlayerCombatTimer(target, {0})
            if not reviveall then
                GMT.sendDCLog('revive', 'GMT Revive Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(player_id).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..player_id.."**")
                GMT.notify(admin, '~g~Revived '..GMT.getPlayerName(player_id) .. '.')
                return
            end
            GMT.notify(admin, '~g~Revived all Nearby.')
        else
            GMT.ACBan(15,user_id,"GMT:RevivePlayer")
        end
    end
end)

frozenplayers = {}

RegisterServerEvent('GMT:FreezeSV')
AddEventHandler('GMT:FreezeSV', function(admin, newtarget, isFrozen)
    local source = source
    local user_id = GMT.getUserId(source)
    local player_id = GMT.getUserId(newtarget)
    if GMT.hasPermission(user_id, 'admin.freeze') then
        if isFrozen then
            GMT.sendDCLog('freeze', 'GMT Freeze Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(player_id).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**\n> Type: **Frozen**")
            GMT.notify(source, '~g~Froze: '..GMT.getPlayerName(player_id))
            frozenplayers[player_id] = true
            GMT.notify(newtarget, '~g~You have been frozen.')
        else
            GMT.sendDCLog('freeze', 'GMT Freeze Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(player_id).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**\n> Type: **Unfrozen**")
            GMT.notify(source, '~g~Unfrozen: '..GMT.getPlayerName(player_id))
            GMT.notify(newtarget, '~g~You have been unfrozen.')
            frozenplayers[player_id] = nil
        end
        TriggerClientEvent('GMT:Freeze', newtarget, isFrozen)
    else
        GMT.ACBan(15,user_id,"GMT:FreezeSV")
    end
end)

RegisterServerEvent("GMT:RequestIfFrozen",function(perm)
    local source = source
    local user_id = GMT.getUserId(source)
    perm = tonumber(perm)
    if GMT.hasPermission(user_id, 'admin.freeze') then
        if frozenplayers[perm] ~= nil then
            TriggerClientEvent("GMT:SendIfFrozen",source,perm,frozenplayers[perm])
        else
            TriggerClientEvent("GMT:SendIfFrozen",source,perm,false)
        end
    else
        GMT.ACBan(15,user_id,"GMT:RequestIfFrozen")
    end
end)

RegisterServerEvent('GMT:TeleportToPlayer')
AddEventHandler('GMT:TeleportToPlayer', function(source, newtarget)
    local source = source
    local coords = GetEntityCoords(GetPlayerPed(newtarget))
    local user_id = GMT.getUserId(source)
    local player_id = GMT.getUserId(newtarget)
    if GMT.hasPermission(user_id, 'admin.tp2player') then
        local adminbucket = GetPlayerRoutingBucket(source)
        local playerbucket = GetPlayerRoutingBucket(newtarget)
        if adminbucket ~= playerbucket then
            GMT.setBucket(source, playerbucket) -- tayser
            GMT.notify(source, '~g~Player was in another bucket, you have been set into their bucket.')
        end
        GMTclient.teleport(source, coords)
        GMT.notify(newtarget, '~g~An admin has teleported to you.')
        if player_id then
            GMT.sendDCLog('tp-to-player', 'GMT Teleport Legion Logs', "> Admin Name: **"..GMT.getPlayerName(player_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(player_id).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**")
        end
    else
        GMT.ACBan(15,user_id,"GMT:TeleportToPlayer")
    end
end)

RegisterServerEvent('GMT:Teleport2Legion')
AddEventHandler('GMT:Teleport2Legion', function(newtarget)
    local source = source
    local user_id = GMT.getUserId(source)
    local player_id = GMT.getUserId(newtarget)
    if GMT.hasPermission(user_id, 'admin.tp2player') then
        GMTclient.teleport(newtarget, vector3(152.66354370117,-1035.9771728516,29.337995529175))
        GMT.notify(newtarget, '~g~You\'ve been teleported to Legion by an admin.')
        GMTclient.setPlayerCombatTimer(newtarget, {0})
        GMT.sendDCLog('tp-to-legion', 'GMT Teleport Legion Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(player_id).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**")
    else
        GMT.ACBan(15,user_id,"GMT:Teleport2Legion")
    end
end)

RegisterNetEvent('GMT:BringPlayer')
AddEventHandler('GMT:BringPlayer', function(id)
    local source = source 
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tp2player') then
        if id and GMT.getUserId(id) then
            GMT.sendDCLog('tp-player-to-me', 'GMT Bring Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(GMT.getUserId(id)).."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..GMT.getUserId(id).."**")
            GMTclient.teleport(id, GetEntityCoords(GetPlayerPed(source)))
            local adminbucket = GetPlayerRoutingBucket(source)
            local playerbucket = GetPlayerRoutingBucket(id)
            if adminbucket ~= playerbucket then
                GMT.setBucket(id, adminbucket)
                GMT.notify(source, '~g~Player was in another bucket, they have been set into your bucket.')
            end
            GMTclient.setPlayerCombatTimer(id, {0})
        else 
            GMT.notify(source, "This player may have left the game.")
        end
    else
        GMT.ACBan(15,user_id,"GMT:BringPlayer")
    end
end)

RegisterNetEvent('GMT:TpALL')
AddEventHandler('GMT:TpALL', function()
    local source = source 
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tp2player') then
        local admin_coords = GetEntityCoords(GetPlayerPed(source))
        local players = GetPlayers()
        for _, id in ipairs(players) do
            GMTclient.teleport(id, admin_coords)
            local adminbucket = GetPlayerRoutingBucket(source)
            local playerbucket = GetPlayerRoutingBucket(id)
            if adminbucket ~= playerbucket then
                GMT.setBucket(id, adminbucket)
                GMT.notify(source, '~g~Player was in another bucket, they have been set into your bucket.')
            end
            GMTclient.setPlayerCombatTimer(id, {0})
        end
    else
        GMT.ACBan(15,user_id,"GMT:TpALL")
    end
end)

RegisterNetEvent('GMT:GetCoords')
AddEventHandler('GMT:GetCoords', function()
    local source = source 
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.tickets") then
        GMTclient.getPosition(source,{},function(coords)
            local x,y,z = table.unpack(coords)
            GMT.prompt(source,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z,function(player,choice) 
            end)
        end)
    else
        GMT.ACBan(15,user_id,"GMT:GetCoords")
    end
end)

RegisterNetEvent('GMT:GetVec4Coords')
AddEventHandler('GMT:GetVec4Coords', function()
    local source = source 
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.tickets") then
        local playerPed = GetPlayerPed(source)
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)
        GMT.prompt(source,"Copy the coordinates using Ctrl-A Ctrl-C",coords.x..","..coords.y..","..coords.z .. "," ..heading,function(player,choice) 
        end)
    else
        GMT.ACBan(15,user_id,"GMT:GetVec4Coords")
    end
end)

RegisterServerEvent('GMT:Tp2Coords')
AddEventHandler('GMT:Tp2Coords', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.tp2coords") then
        GMT.prompt(source,"Coords x,y,z:","",function(player,fcoords) 
            local coords = {}
            for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
            table.insert(coords,tonumber(coord))
            end
        
            local x,y,z = 0,0,0
            if coords[1] then x = coords[1] end
            if coords[2] then y = coords[2] end
            if coords[3] then z = coords[3] end

            if x and y and z == 0 then
                GMT.notify(source, "We couldn't find those coords, try again!")
            else
                GMTclient.teleport(player,{x,y,z})
            end 
        end)
    else
        GMT.ACBan(15,user_id,"GMT:Tp2Coords")
    end
end)

RegisterServerEvent("GMT:Teleport2AdminIsland")
AddEventHandler("GMT:Teleport2AdminIsland",function(id)
    local source = source
    local user_id = GMT.getUserId(source)
    if id then
        local player_id = GMT.getUserId(id)
        if GMT.hasPermission(user_id, 'admin.tp2player') then
            local ped = GetPlayerPed(source)
            local ped2 = GetPlayerPed(id)
            FreezeEntityPosition(ped, true)
            SetEntityCoords(ped2,4593.7651367188,-4873.0043945312,18.245407485962)
            GMT.setBucket(id, 77)
            GMT.notify(GMT.getUserSource(player_id), '~g~You are now in an admin situation, do not leave the game.')
            GMTclient.setPlayerCombatTimer(id, {0})
            Wait(500)
            FreezeEntityPosition(ped, false)
            GMT.sendDCLog('tp-to-admin-zone', 'GMT Teleport Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(player_id).."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..player_id.."**")
        else
            GMT.ACBan(15,user_id,"GMT:Teleport2AdminIsland")
        end
    end
end)

RegisterServerEvent("GMT:TeleportBackFromAdminZone")
AddEventHandler("GMT:TeleportBackFromAdminZone",function(id, savedCoordsBeforeAdminZone)
    local source = source
    local user_id = GMT.getUserId(source)
    if id then
        if GMT.hasPermission(user_id, 'admin.tp2player') then
            local ped = GetPlayerPed(id)
            SetEntityCoords(ped, savedCoordsBeforeAdminZone)
            GMT.setBucket(id, 0)
            GMT.sendDCLog('tp-back-from-admin-zone', 'GMT Teleport Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GMT.getPlayerName(GMT.getUserId(id)).."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..GMT.getUserId(id).."**")
        else
            GMT.ACBan(15,user_id,"GMT:TeleportBackFromAdminZone")
        end
    end
end)

RegisterNetEvent('GMT:AddCar')
AddEventHandler('GMT:AddCar', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.addcar') then
        GMT.prompt(source,"Add to Perm ID:","",function(source, permid)
            if permid == "" then 
                return 
            end
            permid = tonumber(permid)
            GMT.prompt(source,"Car Spawncode:","",function(source, car) 
                if car == "" then return end
                local car = car
                GMT.prompt(source,"Locked:","",function(source, locked) 
                    if locked == '0' or locked == '1' then
                        if permid and car ~= "" then  
                            GMTclient.generateUUID(source, {"plate", 5, "alphanumeric"}, function(uuid)
                                local uuid = string.upper(uuid)
                                exports['gmt']:execute("SELECT * FROM `gmt_user_vehicles` WHERE vehicle_plate = @plate", {plate = uuid}, function(result)
                                    if #result > 0 then
                                        GMT.notify(source, 'Error adding car, please try again.')
                                        return
                                    else
                                        MySQL.execute("GMT/add_vehicle", {user_id = permid, vehicle = car, registration = uuid, locked = locked})
                                        GMT.notify(source,  '~g~Successfully added car ' .. car .. ' to PermID (' .. permid .. ')' )
                                        GMT.sendDCLog('add-car', 'GMT Add Car To Player Logs', "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player PermID: **"..permid.."**\n> Spawncode: **"..car.."**")
                                    end
                                end)
                            end)
                        else 
                            GMT.notify(source, '~r~Failed to add Player\'s car')
                        end
                    else
                        GMT.notify(source, '~g~Locked must be either 1 or 0') 
                    end
                end)
            end)
        end)
    else
        GMT.ACBan(15,user_id,"GMT:AddCar")
    end
end)

RegisterNetEvent('GMT:CleanAll')
AddEventHandler('GMT:CleanAll', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllVehicles()) do 
            DeleteEntity(v)
        end
        for i,v in pairs(GetAllPeds()) do 
            DeleteEntity(v)
        end
        for i,v in pairs(GetAllObjects()) do
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'GMT^7 │ ', {255, 255, 255}, "Cleanup Completed by ^3" .. GMT.getPlayerName(user_id) .. "^0!", "alert")
        GMT.sendDCLog('cleanup', "GMT Cleanup Logs", "**Triggered** \n\n```Clean all Completed```\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterNetEvent('GMT:CleanVeh')
AddEventHandler('GMT:CleanVeh', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllVehicles()) do 
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'GMT^7 │ ', {255, 255, 255}, "Vehicle Cleanup Completed by ^3" .. GMT.getPlayerName(user_id) .. "^0!", "alert")
       GMT.sendDCLog('cleanup', "GMT Cleanup Logs", "**Triggered** \n\n```Vehicle Cleanup Completed```\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterNetEvent('GMT:CleanPed')
AddEventHandler('GMT:CleanPed', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllPeds()) do 
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'GMT^7 │ ', {255, 255, 255}, "Ped Cleanup Completed by ^3" .. GMT.getPlayerName(user_id) .. "^0!", "alert")
       GMT.sendDCLog('cleanup', "GMT Cleanup Logs", "**Triggered** \n\n```Ped Cleanup Completed```\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterNetEvent('GMT:CleanObj')
AddEventHandler('GMT:CleanObj', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllObjects()) do
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'GMT^7 │ ', {255, 255, 255}, "Object Cleanup Completed by ^3" .. GMT.getPlayerName(user_id) .. "^0!", "alert")
       GMT.sendDCLog('cleanup', "GMT Cleanup Logs", "**Triggered** \n\n```Object Cleanup Completed```\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterServerEvent("GMT:GetPlayerData")
AddEventHandler("GMT:GetPlayerData",function()
    local source = source
    user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.tickets') then
        players = GetPlayers()
        players_table = {}
        useridz = {}
        for i, p in pairs(GMT.getUsers()) do
            user_idz = i
            name = GMT.getPlayerName(user_idz)
            data = GMT.getUserDataTable(user_idz)
            stafflevel = GMT.GetStaffLevel(user_idz)
            playtime = data.PlayerTime or 0
            PlayerTimeInHours = playtime/60
            if PlayerTimeInHours < 1 then
                PlayerTimeInHours = 0
            end
            players_table[user_idz] = {name, p, user_idz, math.ceil(PlayerTimeInHours), stafflevel}
            table.insert(useridz, user_idz)
        end
        TriggerClientEvent("GMT:getPlayersInfo", source, players_table, bans)
    end
end)

function tGMT.GetPlayTime(user_id)
    if user_id then
        data = GMT.getUserDataTable(user_id)
        playtime = data.PlayerTime or 0
        PlayerTimeInHours = playtime / 60
        if PlayerTimeInHours < 1 then
            PlayerTimeInHours = 0
        end
        PlayerTimeInHours = math.ceil(PlayerTimeInHours)
        GMT.SetStat(user_id, 'playtime', PlayerTimeInHours)
        return PlayerTimeInHours
    else
        return 0
    end
end

RegisterServerEvent("GMT:StaffModeLogs")
AddEventHandler("GMT:StaffModeLogs", function(status)
    local source = source
    local user_id = GMT.getUserId(source)
    local action = status and "Activated" or "Deactivated"
    if GMT.hasPermission(user_id, "admin.tickets") then
        GMT.sendDCLog('staff', 'GMT Staff Mode Log', "**Staff Mode "..action.."**\n\n> Admin Name: ** "..GMT.getPlayerName(user_id).."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **" ..source.. "**")
    else
        GMT.ACBan(15,user_id,"GMT:StaffModeLogs")
    end
end)

RegisterCommand("staffon", function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.tickets") then
        if globalPreventStaff then
            GMT.notify("~r~You cannot staff on while in the pit.")
            return
        end
        GMTclient.staffMode(source, {true})
        GMT.sendDCLog('staff', 'GMT Staff Mode Log', "**Staff Mode Activated**\n\n> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **" ..source.. "**")
    end
end)

RegisterCommand("staffoff", function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, "admin.tickets") then
        GMTclient.staffMode(source, {false})
        GMT.sendDCLog('staff', 'GMT Staff Mode Log', "**Staff Mode Deactivated**\n\n> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **" ..source.. "**")
    end
end)

RegisterServerEvent('GMT:getAdminLevel')
AddEventHandler('GMT:getAdminLevel', function()
    local source = source
    local user_id = GMT.getUserId(source)
    local adminlevel = GMT.GetStaffLevel(user_id)
    GMTclient.setStaffLevel(source, {adminlevel})
end)

RegisterServerEvent("GMT:VerifyStaffLevel",function(stafflvl)
    local source = source
    local user_id = GMT.getUserId(source)
    if stafflvl > 0 then
        for k, v in pairs(GMT.GetStaffTable()) do
            if v == stafflvl then
                if not GMT.hasGroup(user_id, k) then
                    GMT.ACBan(15,user_id,"GMT:VerifyStaffLevel")
                end
            end
        end
    end
end)

RegisterServerEvent("GMT:VerifyDev",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if not GMT.isDeveloper(user_id) and not GMT.hasGroup(user_id,"Founder") and not GMT.hasGroup(user_id,"Lead Developer") and not GMT.hasGroup(user_id,"Developer") then
        GMT.ACBan(15,user_id,"GMT:VerifyDev")
    end
end)

RegisterServerEvent("GMT:VerifyUserID",function(id)
    local source = source
    local user_id = GMT.getUserId(source)
    if id ~= user_id then
        GMT.ACBan(15,user_id,"GMT:VerifyUserID")
    end
end)

RegisterNetEvent('GMT:zapPlayer')
AddEventHandler('GMT:zapPlayer', function(A)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasGroup(user_id, 'Founder') then
        TriggerClientEvent("GMT:useTheForceTarget", A)
        for k,v in pairs(GMT.getUsers()) do
            TriggerClientEvent("GMT:useTheForceSync", v, GetEntityCoords(GetPlayerPed(A)), GetEntityCoords(GetPlayerPed(v)))
        end
    end
end)

RegisterNetEvent('GMT:theForceSync')
AddEventHandler('GMT:theForceSync', function(A, q, r, s)
    local source = source
    if GMT.getUserId(source) == 1 then
        TriggerClientEvent("GMT:useTheForceSync", A, q, r, s)
        TriggerClientEvent("GMT:useTheForceTarget", A)
    end
end)

RegisterCommand("cleararea", function(source, args) -- these events are gonna be used for vehicle cleanup in future also
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.noclip') then
        TriggerClientEvent('GMT:clearVehicles', -1)
        TriggerClientEvent('GMT:clearBrokenVehicles', -1)
        GMT.sendDCLog('cleanup', "GMT Cleanup Logs", "**Triggered** \n\n```Clear Area Command```\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end 
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(590000)
        TriggerClientEvent('chatMessage', -1, 'Announcement │ ', {255, 255, 255}, "^0Vehicle cleanup in 10 seconds! All unoccupied vehicles will be deleted.", "alert")
        Citizen.Wait(10000)
        TriggerClientEvent('chatMessage', -1, 'Announcement │ ', {255, 255, 255}, "^0Vehicle cleanup complete.", "alert")
        TriggerClientEvent('GMT:clearVehicles', -1)
        TriggerClientEvent('GMT:clearBrokenVehicles', -1)
       -- GMT.sendDCLog('cleanup', "GMT Cleanup Logs", "**Automatic** \n\n```Vehicle cleanup Completed```")
	end
end)

RegisterCommand("getbucket", function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.notify(source, '~g~You are currently in Bucket: '..GetPlayerRoutingBucket(source)) -- tayser
end)

RegisterCommand("setbucket", function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.managecommunitypot') then
        GMT.setBucket(source, tonumber(args[1]))
        GMT.notify(source, '~g~You are now in Bucket: '..GetPlayerRoutingBucket(source))
    end 
end)

RegisterCommand("clipboard", function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'group.remove') then
        local permid = tonumber(args[1])
        table.remove(args, 1)
        local msg = table.concat(args, " ")
        GMTclient.CopyToClipBoard(GMT.getUserSource(permid), {msg})
    end
end)
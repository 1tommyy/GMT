local staffGroups = {
    ['Founder'] = true,
    ['Lead Developer'] = true,
    ['Developer'] = true,
    ['Staff Manager'] = true,
    ['Community Manager'] = true,
    ['Head Administrator'] = true,
    ['Senior Administrator'] = true,
    ['Administrator'] = true,
    ['Senior Moderator'] = true,
    ['Moderator'] = true,
    ['Support Team'] = true,
    ['Trial Staff'] = true,
}
local pdGroups = {
    ["Commissioner Clocked"]=true,
    ["Deputy Commissioner Clocked"] =true,
    ["Assistant Commissioner Clocked"]=true,
    ["Dep. Asst. Commissioner Clocked"] =true,
    ["Commander Clocked"]=true,
    ["Chief Superintendent Clocked"]=true,
    ["Superintendent Clocked"]=true,
    ["Chief Inspector Clocked"]=true,
    ["Inspector Clocked"]=true,
    ["Sergeant Clocked"]=true,
    ["Senior Constable Clocked"]=true,
    ["PC Clocked"]=true,
    ["PCSO Clocked"]=true,
    ["Special Constable Clocked"]=true,
    ["NPAS Clocked"]=true,
}
local nhsGroups = {
    ["NHS Trainee Paramedic Clocked"] = true,
    ["NHS Paramedic Clocked"] = true,
    ["NHS Critical Care Clocked"] = true,
    ["NHS Junior Doctor Clocked"] = true,
    ["NHS Doctor Clocked"] = true,
    ["NHS Senior Doctor Clocked"] = true,
    ["NHS Specialist Clocked"] = true,
    ["NHS Consultant Clocked"] = true,
    ["NHS Captain Clocked"] = true,
    ["NHS Combat Medic Clocked"] = true,
    ["NHS Deputy Chief Clocked"] = true,
    ["NHS Assistant Chief Clocked"] = true,
    ["NHS Head Chief Clocked"] = true,
    ["HEMS Clocked"]=true,
}
local lfbGroups = {
    ["Trainee Firefighter Clocked"] = true,
    ["Firefighter Clocked"] = true,
    ["Crew Manager Clocked"] = true,
    ["Watch Manager Clocked"] = true,
    ["Station Manager Clocked"] = true,
    ["Group Manager Clocked"] = true,
    ["Area Manager Clocked"] = true,
    ["Sector Command Clocked"] = true,
    ["Divisional Command Clocked"] = true,
    ["Divisional Officer Clocked"] = true,
    ["Honourable Firefighter Clocked"] = true,
    ["Fire Command Advisor Clocked"] = true,
    ["Assistant Chief Fire Officer Clocked"] = true,
    ["Deputy Chief Fire Clocked"] = true,
    ["Chief Fire Officer Clocked"] = true
}
local hmpGroups = {
    ["Governor Clocked"] = true,
    ["Deputy Governor Clocked"] = true,
    ["Divisional Commander Clocked"] = true,
    ["Custodial Supervisor Clocked"] = true,
    ["Custodial Officer Clocked"] = true,
    ["Honourable Guard Clocked"] = true,
    ["Supervising Officer Clocked"] = true,
    ["Principal Officer Clocked"] = true,
    ["Specialist Officer Clocked"] = true,
    ["Senior Officer Clocked"] = true,
    ["Prison Officer Clocked"] = true,
    ["Trainee Prison Officer Clocked"] = true
}
local aaGroups = {
    ["AA Mechanic"] = true,
}
local ukbfGroups = {
    ["Director General Clocked"] = true,
    ["Regional Director Clocked"] = true,
    ["Assistant Director Clocked"] = true,
    ["HM Inspector Clocked"] = true,
    ["Chief Immigration Clocked"] = true,
    ["Tactical Command Clocked"] = true,
    ["Senior Immigration Officer Clocked"] = true,
    ["Higher Immigration Officer Clocked"] = true,
    ["Assistant Immigration Officer Clocked"] = true,
    ["Administrative Assistant Clocked"] = true,
    ["Special Officer Clocked"] = true,
    ["Cutters Specialist Clocked"] = true,
    ["Cutters Instructor Clocked"] = true,
    ["Chief Captain Clocked"] = true,
    ["Captain Clocked"] = true,
    ["Coxswain Clocked"] = true,
    ["Senior Deckhand Clocked"] = true,
    ["Deckhand Clocked"] = true,
}
local defaultGroups = {
    ["Royal Mail Driver"] = true,
    ["Deliveroo"] = true,
    ["G4S Driver"] = true,
    ["Lorry Driver"] = true,
    ["Taco Seller"] = true,
}
local tridentGroups = {
    ["Trident Officer Clocked"] = true,
    ["Trident Command Clocked"] = true,
}
function getGroupInGroups(id, type)
    if type == 'Staff' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if staffGroups[k] then 
                return k
            end 
        end
    elseif type == 'Police' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if pdGroups[k] or tridentGroups[k] then 
                return k
            end 
        end
    elseif type == 'NHS' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if nhsGroups[k] then 
                return k
            end 
        end
    elseif type == 'LFB' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if lfbGroups[k] then 
                return k
            end 
        end
    elseif type == 'HMP' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if hmpGroups[k] then 
                return k
            end 
        end
    elseif type == 'AA' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if aaGroups[k] then 
                return k
            end 
        end
    elseif type == 'UKBF' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if ukbfGroups[k] then 
                return k
            end 
        end
    elseif type == 'Default' then
        for k,v in pairs(GMT.getUserGroups(id)) do
            if defaultGroups[k] then 
                return k
            end 
        end
        return "Unemployed"
    end
end

local hiddenUsers = {}
RegisterNetEvent("GMT:setUserHidden")
AddEventHandler("GMT:setUserHidden",function(state)
    local source=source
    local user_id=GMT.getUserId(source)
    if user_id == 1 then
        if state then
            hiddenUsers[user_id] = true
            GMT.sendDCLog('hidden-state', 'GMT Hidden Logs', "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Status: **True**")
        else
            hiddenUsers[user_id] = nil
            GMT.sendDCLog('hidden-state', 'GMT Hidden Logs', "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Status: **False**")
        end
    end
end)

local uptime = 0
local function playerListMetaUpdates()
    local uptimemessage = ''
    if uptime < 60 then
        uptimemessage = math.floor(uptime) .. ' secs'
    elseif uptime >= 60 and uptime < 3600 then
        uptimemessage = math.floor(uptime/60) .. ' mins ' .. math.floor(uptime%60) .. ' secs'
    elseif uptime >= 3600 then
        uptimemessage = math.floor(uptime/3600) .. ' hrs, ' .. math.floor((uptime%3600)/60) .. ' mins and ' .. math.floor(uptime%60) .. ' secs'
    end
    return {uptimemessage, #GetPlayers(), GetConvarInt("sv_maxclients",64)}
end

Citizen.CreateThread(function()
    while true do
        local time = os.date("*t")
        uptime = uptime + 1
        TriggerClientEvent('GMT:playerListMetaUpdate', -1, playerListMetaUpdates())
        if os.date('%A') == 'Sunday' and tonumber(time["hour"]) == 23 and tonumber(time["min"]) == 0 and tonumber(time["sec"]) == 0 then
            exports['gmt']:execute("UPDATE gmt_police_hours SET weekly_hours = 0")
            exports['gmt']:execute("UPDATE gmt_staff_tickets SET ticket_count = 0")
            exports['gmt']:execute("UPDATE gmt_dvsa SET points = 0")
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(GMT.getUsers()) do
            local user_id = GMT.getUserId(k)
            if GMT.hasGroup(user_id,"AA Mechanic") then
                TriggerClientEvent("chatMessage",-1,"^1[GMT]",{180,0,0},"^3AA is available in the city. Require vehicle assistance? Call /aa", "ooc")
            end
        end
        Citizen.Wait(60000 * 3)
    end
end)

RegisterNetEvent('GMT:getPlayerListData')
AddEventHandler('GMT:getPlayerListData', function()
    local source = source
    local user_id = GMT.getUserId(source)
    local staff = {}
    local police = {}
    local nhs = {}
    local lfb = {}
    local hmp = {}
    local aa = {}
    local ukbf = {}
    local civillians = {}
    local hourz = hourz or {}
    for k,v in pairs(GMT.getUsers()) do
        if not hiddenUsers[k] then
            local name = GMT.getPlayerName(k)
            if name then
                local minutesPlayed = GMT.getUserDataTable(k).PlayerTime or 0
                local hours = math.floor(minutesPlayed/60)
                hourz[k] = hours
                if GMT.hasPermission(k, 'admin.tickets') then
                    staff[k] = {name = name, rank = getGroupInGroups(k, 'Staff'), hours = hours}
                end
                if GMT.hasPermission(k, 'police.armoury') and not GMT.hasPermission(k, 'police.undercover') then
                    police[k] = {name = name, rank = string.gsub(getGroupInGroups(k, 'Police'), ' Clocked', ''), hours = hours}
                elseif GMT.hasPermission(k, 'nhs.menu') then
                    nhs[k] = {name = name, rank = string.gsub(getGroupInGroups(k, 'NHS'), ' Clocked', ''), hours = hours}
                elseif GMT.hasPermission(k, 'lfb.menu') then
                    lfb[k] = {name = name, rank = string.gsub(getGroupInGroups(k, 'LFB'), ' Clocked', ''), hours = hours}
                elseif GMT.hasPermission(k, 'hmp.menu') then
                    hmp[k] = {name = name, rank = string.gsub(getGroupInGroups(k, 'HMP'), ' Clocked', ''), hours = hours}
                elseif GMT.hasPermission(k, 'aa.menu') then
                    aa[k] = {name = name, rank = string.gsub(getGroupInGroups(k, 'AA'), ' Clocked', ''), hours = hours}
                elseif GMT.hasPermission(k, 'ukbf.armoury') then
                    ukbf[k] = {name = name, rank = string.gsub(getGroupInGroups(k, 'UKBF'), ' Clocked', ''), hours = hours}
                end
                if (not GMT.hasPermission(k, "police.armoury") or GMT.hasPermission(k, 'police.undercover')) and not GMT.hasPermission(k, "nhs.menu") and not GMT.hasPermission(k, "lfb.menu") and not GMT.hasPermission(k, "hmp.menu") and not GMT.hasPermission(k, "aa.menu") and not GMT.hasPermission(k, "ukbf.armoury") then
                    civillians[k] = {name = name, rank = getGroupInGroups(k, 'Default'), hours = hours}
                end
            end
        end
    end
    TriggerClientEvent('GMT:gotFullPlayerListData', source, staff, police, nhs, lfb, hmp, aa, ukbf, civillians)
    TriggerClientEvent('GMT:gotJobTypes', source, nhsGroups, pdGroups, lfbGroups, ukbfGroups, hmpGroups,tridentGroups, aaGroups)
    TriggerClientEvent('GMT:gotPlayerHours', source, user_id, hourz[user_id] or 0)
    TriggerClientEvent("GMT:EmploymentStatus", source, (getGroupInGroups(user_id, 'Police') or getGroupInGroups(user_id, 'NHS') or getGroupInGroups(user_id, 'LFB') or getGroupInGroups(user_id, 'HMP') or getGroupInGroups(user_id, 'AA') or getGroupInGroups(user_id, 'Default') or getGroupInGroups(user_id, 'Default') or "Unemployed"):gsub(' Clocked', ''))
end)

-- [[ Paycheck System ]]

local paycheckscfg = module('cfg/cfg_factiongroups')

local function paycheck(tempid, permid, money, group)
    local pay = grindBoost * money
    GMT.giveBankMoney(permid, pay)
    local notificationPicture = group == "Police" and "polnotification" 
        or group == "NHS" and "nhsnotification" 
        or group == "LFB" and "lfbnotification" 
        or group == "HMP" and "hmpnotification" 
        or group == "UKBF" and "ukbfnotification" 
        or group == "Staff" and "walletnotification" 
        or group == "Default" and "walletnotification"
    GMT.notifyPicture(tempid, notificationPicture, "notification", "You've been paid! Amount: £" .. getMoneyStringFormatted(tostring(pay)),(group == "Default" and "Welfare Cheque" or group.. " Paycheck"))
    GMT.sendDCLog('paycheck', 'GMT Paycheck Logs', "> Player Name: **"..GMT.getPlayerName(permid).."**\n> Player TempID: **"..tempid.."**\n> Player PermID: **"..permid.."**\n> Paycheck Type: "..group == "Default" and "Welfare Cheque" or group.."\n> Amount: **£" .. getMoneyStringFormatted(tostring(pay)) .. "**" )
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000*60*30) 
        for k, v in pairs(GMT.getUsers()) do
            local group = ""
            if GMT.hasPermission(k, "admin.tickets") then
                group = getGroupInGroups(k, 'Staff')
                for a, b in pairs(paycheckscfg.adminPay) do
                    if b[1] == group then
                        paycheck(v, k, b[2], "Staff")
                    end
                end
        elseif GMT.hasPermission(k, "police.armoury") then
                group = string.gsub(getGroupInGroups(k, 'Police'), ' Clocked', '')
                for a, b in pairs(paycheckscfg.metPoliceRanks) do
                    if b[1] == group then
                        paycheck(v, k, b[2], "Police")
                    end
                end
            elseif GMT.hasPermission(k, "ukbf.armoury") then
                group = string.gsub(getGroupInGroups(k, 'ukbf'), ' Clocked', '')
                for a, b in pairs(paycheckscfg.ukbfRanks) do
                    if b[1] == group then
                        paycheck(v, k, b[2], "UKBF")
                    end
                end
            elseif GMT.hasPermission(k, "nhs.menu") then
                group = string.gsub(getGroupInGroups(k, 'NHS'), ' Clocked', '')
                for a, b in pairs(paycheckscfg.nhsRanks) do
                    if b[1] == group then
                        paycheck(v, k, b[2], "NHS")
                    end
                end
            elseif GMT.hasPermission(k, "lfb.menu") then
                group = string.gsub(getGroupInGroups(k, 'LFB'), ' Clocked', '')
                for a, b in pairs(paycheckscfg.lfbRanks) do
                    if b[1] == group then
                        paycheck(v, k, b[2], "LFB")
                    end
                end
            elseif GMT.hasPermission(k, "hmp.menu") then
                group = string.gsub(getGroupInGroups(k, 'HMP'), ' Clocked', '')
                for a, b in pairs(paycheckscfg.hmpRanks) do
                    if b[1] == group then
                        paycheck(v, k, b[2], "HMP")
                    end
                end
            else
                paycheck(v,k, paycheckscfg.defaultPay, "Default")
            end
        end
    end
end)
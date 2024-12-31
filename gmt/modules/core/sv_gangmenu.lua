local gangWithdraw = {}
local gangDeposit = {}
local gangTable = {}
local playerinvites = {}
local fundscooldown = {}
local cooldown = 5
MySQL.createCommand("gmt_edituser", "UPDATE gmt_user_gangs SET gangname = @gangname WHERE user_id = @user_id")
MySQL.createCommand("gmt_adduser", "INSERT IGNORE INTO gmt_user_gangs (user_id,gangname) VALUES (@user_id,@gangname)")
function addGangLog(playername,userid,action,actionvalue)
    local gangname = GMT.getGangName(userid)
    if gangname and gangname ~= "" then
        exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
            if #ganginfo > 0 then
                local ganglogs = {}
                if ganginfo[1].logs == "NOTHING" then
                    ganglogs = {}
                else
                    ganglogs = json.decode(ganginfo[1].logs)
                    if ganglogs == nil then
                        ganglogs = {}
                    end
                end
                if ganginfo[1].webhook then
                    GMT.sendDCLog(ganginfo[1].webhook, "(".. gangname..") Gang Logs", "**Name:** " ..playername.. "**\n**User ID:** " ..userid.. "\n**Action:** " ..actionvalue .. "**")
                else
                    GMT.sendDCLog("gang-info", "(".. gangname..") Gang Logs", "**Name:** " ..playername.. "**\n**User ID:** " ..userid.. "\n**Action:** " .. action.. " ("..actionvalue.. ")**")
                end
                table.insert(ganglogs,1,{playername,userid,os.date("%d/%m/%Y at %X"),action,actionvalue})
                exports["gmt"]:execute("UPDATE gmt_gangs SET logs = @logs WHERE gangname = @gangname", {logs = json.encode(ganglogs), gangname = gangname})
                TriggerClientEvent("GMT:ForceRefreshData",GMT.getUserSource(userid))
            end
        end)
    end
end
RegisterServerEvent('GMT:CreateGang', function(gangName)
    local source = source
    local user_id = GMT.getUserId(source)
    local currenttime = os.time()
    
    if GMT.hasGroup(user_id,"Gang") then
        if not fundscooldown[source] or (currenttime - fundscooldown[source]) >= cooldown then
            fundscooldown[source] = currenttime
            local hasgang = GMT.getGangName(user_id)
            if hasgang == nil or hasgang == "" then
                exports['gmt']:execute("SELECT * FROM gmt_user_gangs WHERE gangname = @gang", {gang = gangName}, function(gangData)
                    if #gangData <= 0 then
                        local gangTable = {[tostring(user_id)] = {["rank"] = 4,["gangPermission"] = 4,["color"] = "White"}}
                        gangTables = json.encode(gangTable)
                        GMT.notify(source, "~g~Gang created.")
                        MySQL.execute("gmt_edituser", {user_id = user_id, gangname = gangName})
                        exports['gmt']:execute("INSERT INTO gmt_gangs (gangname,gangmembers,funds,logs) VALUES(@gangname,@gangmembers,@funds,@logs)", {gangname=gangName,gangmembers=gangTables,funds=0,logs="NOTHING"}, function() end)
                        TriggerClientEvent("GMT:gangNameNotTaken",source)
                        TriggerClientEvent("GMT:ForceRefreshData",source)
                    else
                        GMT.notify(source, "~r~Gang already exists.")
                    end
                end)
            else
                GMT.notify(source, "~r~You already have a gang, If not contact a developer.")
            end
        else
            GMT.notify(source, "~r~You are being rate limited, please wait")
        end
    else
        GMT.notify(source, "~r~A gang license is required to create a gang.")
    end
    syncRadio(source)
end)

RegisterServerEvent("GMT:GetGangData", function()
    local source = source
    local user_id = GMT.getUserId(source)
    local gangName = GMT.getGangName(user_id)
    if gangName and gangName ~= "" then
        local gangmembers = {}
        local gangData = {}
        local ganglogs = {}
        local memberids = {}
        local gangpermission = {}  -- Initialize gangpermission as a table
        exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangName}, function(gangInfo)
            local gangInfo = gangInfo[1]
            local gangMembers = json.decode(gangInfo.gangmembers)
            gangData["money"] = math.floor(gangInfo.funds)
            gangData["id"] = gangName
            gangpermission = tonumber(gangMembers[tostring(user_id)].gangPermission) or 0 
            ganglogs = json.decode(gangInfo.logs)
            ganglock = tobool(gangInfo.lockedfunds)
            for member_id, member_data in pairs(gangMembers) do
                memberids[#memberids + 1] = tostring(member_id)
            end
            local placeholders = string.rep('?,', #memberids):sub(1, -2)
            local playerData = exports['gmt']:executeSync('SELECT * FROM gmt_users WHERE id IN (' .. placeholders .. ')', memberids)
            local userData = exports['gmt']:executeSync('SELECT * FROM gmt_user_data WHERE user_id IN (' .. placeholders .. ')', memberids)
            for _, playerRow in ipairs(playerData) do
                local member_id = tonumber(playerRow.id)
                local member_gangpermission = tonumber(gangMembers[tostring(member_id)].gangPermission) or 0  
                local online
                if playerRow.banned then
                    online = '~r~Banned'
                elseif GMT.getUserSource(member_id) then
                    online = '~g~Online'
                elseif playerRow.last_login then
                    online = '~y~Offline'
                else
                    online = '~r~Never joined'
                end
                local playtime = 0

                for _, userData in ipairs(userData) do
                    if userData.user_id == member_id and userData.dkey == 'GMT:datatable' then
                        local data = json.decode(userData.dvalue)

                        playtime = math.ceil((data.PlayerTime or 0) / 60)
                        if playtime < 1 then
                            playtime = 0
                        end
                        break
                    end
                end
                table.insert(gangmembers, { playerRow.username, member_id, member_gangpermission, online, playtime })
            end
            for _, member_id in ipairs(memberids) do
                local tempid = GMT.getUserSource(tonumber(member_id))
                if tempid then
                    TriggerClientEvent('GMT:GotGangData', tempid, gangData, gangmembers, gangpermission, ganglogs, ganglock, false)
                end
            end
        end)
    end
end)

RegisterServerEvent("GMT:addUserToGang",function(gangName)
    local source = source
    local user_id = GMT.getUserId(source)
    if table.includes(playerinvites[source],gangName) then
        exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname",{gangname = gangName}, function(ganginfo)
            if json.encode(ganginfo) == "[]" and ganginfo == nil and json.encode(ganginfo) == nil then
                GMT.notify(source, "~b~Gang no longer exists.")
                return
            end
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(ganginfo) do
                gangmembers[tostring(user_id)] = {["rank"] = 1,["gangPermission"] = 1,["color"] = "White"}
                exports["gmt"]:execute("UPDATE gmt_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname",{gangmembers = json.encode(gangmembers),gangname = gangName})
                MySQL.execute("gmt_edituser", {user_id = user_id, gangname = gangName})
                TriggerClientEvent("GMT:ForceRefreshData",source)
                syncRadio(source)
            end
        end)
    else
        GMT.notify(source, "~r~You have not been invited to this gang.")
    end
end)
local colourwait = false
RegisterServerEvent("GMT:setPersonalGangBlipColour")
AddEventHandler("GMT:setPersonalGangBlipColour", function(color)
    local source = source
    local user_id = GMT.getUserId(source)
    local gangName = GMT.getGangName(user_id)
    if gangName and gangName ~= "" then
        exports['gmt']:execute('SELECT * FROM gmt_gangs WHERE gangname = @gangname', {gangname = gangName}, function(gangs)
            if #gangs > 0 then
                local gangmembers = json.decode(gangs[1].gangmembers)
                gangmembers[tostring(user_id)] = {["rank"] = gangmembers[tostring(user_id)].rank, ["gangPermission"] = gangmembers[tostring(user_id)].gangPermission,["color"] = color}
                exports['gmt']:execute("UPDATE gmt_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangName})
                TriggerClientEvent("GMT:setGangMemberColour",-1,user_id,color)
            end
        end)
    end
end)

RegisterServerEvent("GMT:depositGangBalance",function(gangname, amount)
    local source = source
    local user_id = GMT.getUserId(source)
    exports['gmt']:execute('SELECT * FROM gmt_gangs WHERE gangname = @gangname', {gangname = gangname}, function(gotGangs)
        for K,V in pairs(gotGangs) do
            local array = json.decode(V.gangmembers)
            for I,L in pairs(array) do
                if tostring(user_id) == I then
                    local funds = V.funds
                    local gangname = V.gangname
                    if tonumber(amount) < 0 then
                        GMT.notify(source, "~r~Invalid Amount")
                        return
                    end
                    if tonumber(GMT.getBankMoney(user_id)) < tonumber(amount) then
                        GMT.notify(source, "~r~Not enough Money.")
                    else
                        GMT.setBankMoney(user_id, (GMT.getBankMoney(user_id))-tonumber(amount))
                        GMT.notify(source, "~g~Deposited £"..getMoneyStringFormatted(amount))
                        addGangLog(GMT.getPlayerName(user_id),user_id,"Deposited","£"..getMoneyStringFormatted(amount))
                        exports['gmt']:execute("UPDATE gmt_gangs SET funds = @funds WHERE gangname = @gangname", {funds = tonumber(amount)+tonumber(funds), gangname = gangname})
                    end
                end
            end
        end
    end)
end)
RegisterServerEvent("GMT:depositAllGangBalance", function()
    local source = source
    local user_id = GMT.getUserId(source)
    local gangName = exports['gmt']:executeSync("SELECT * FROM gmt_user_gangs WHERE user_id = @user_id", {user_id = user_id})[1].gangname
    local currenttime = os.time()

    if gangName and gangName ~= "" then
        if not fundscooldown[source] or (currenttime - fundscooldown[source]) >= cooldown then
            fundscooldown[source] = currenttime
            local bank = GMT.getBankMoney(user_id)
            exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
                if #ganginfo > 0 then
                    local gangmembers = json.decode(ganginfo[1].gangmembers)
                    for A, B in pairs(gangmembers) do
                        if tostring(user_id) == A then
                            local gangfunds = ganginfo[1].funds
                            if tonumber(bank) < 0 then
                                GMT.notify(source, "~r~Invalid Amount")
                                return
                            end
                            GMT.setBankMoney(user_id, 0)
                            GMT.notify(source, "~g~Deposited £" .. getMoneyStringFormatted(bank))
                            GMT.notify(source, "~g~£" .. getMoneyStringFormatted(tonumber(bank) * 0.02) .. " tax paid.")
                            addGangLog(GMT.getPlayerName(user_id), user_id, "Deposited", "£" .. getMoneyStringFormatted(bank))
                            local newbal = tonumber(bank) + tonumber(gangfunds) - tonumber(bank) * 0.02
                            exports["gmt"]:execute("UPDATE gmt_gangs SET funds = @funds WHERE gangname = @gangname", {funds = tostring(newbal), gangname = gangName})
                        end
                    end
                end
            end)
        else
            GMT.notify(source, "~r~You are being rate limited, please wait")
        end
    end
end)

local fundscooldown = {}
local gangFundsLock = {}

RegisterServerEvent("GMT:withdrawAllGangBalance", function()
    local source = source
    local user_id = GMT.getUserId(source)
    local gangName = exports['gmt']:executeSync("SELECT * FROM gmt_user_gangs WHERE user_id = @user_id", {user_id = user_id})[1].gangname
    local currenttime = os.time()

    if gangName and gangName ~= "" then
        if not fundscooldown[source] or (currenttime - fundscooldown[source]) >= cooldown then
            fundscooldown[source] = currenttime
            
            -- Ensure only one person can withdraw at a time
            if gangFundsLock[gangName] then
                GMT.notify(source, "~r~Another withdrawal is already in progress. Please wait.")
                return
            end

            gangFundsLock[gangName] = true

            exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
                if #ganginfo > 0 then
                    local gangmembers = json.decode(ganginfo[1].gangmembers)
                    for A, B in pairs(gangmembers) do
                        if tostring(user_id) == A then
                            local gangfunds = ganginfo[1].funds
                            if tonumber(gangfunds) < 0 then
                                GMT.notify(source, "~r~Invalid Amount")
                                gangFundsLock[gangName] = nil
                                return
                            end
                            GMT.setBankMoney(user_id, (GMT.getBankMoney(user_id)) + tonumber(gangfunds))
                            GMT.notify(source, "~g~Withdrew £" .. getMoneyStringFormatted(gangfunds))
                            addGangLog(GMT.getPlayerName(user_id), user_id, "Withdrew", "£" .. getMoneyStringFormatted(gangfunds))
                            exports["gmt"]:execute("UPDATE gmt_gangs SET funds = @funds WHERE gangname = @gangname", {funds = 0, gangname = gangName})
                        end
                    end
                end
                gangFundsLock[gangName] = nil
            end)
        else
            GMT.notify(source, "~r~You are being rate limited, please wait")
        end
    end
end)



RegisterServerEvent("GMT:withdrawGangBalance",function(amount)
    local source = source
    local user_id = GMT.getUserId(source)
    if not amount or not tonumber(amount) then
        GMT.notify(source, "~r~Invalid Amount")
        return
    end
    local gangName = GMT.getGangName(user_id)
    if gangName and gangName ~= "" then
        if not gangWithdraw[source] then
            gangWithdraw[source] = true
            exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
                if #ganginfo > 0 then
                    local gangmembers = json.decode(ganginfo[1].gangmembers)
                    for A,B in pairs(gangmembers) do
                        if tostring(user_id) == A then
                            local gangfunds = ganginfo[1].funds
                            if tonumber(amount) < 0 then
                                GMT.notify(source, "~r~Invalid Amount")
                                return
                            end
                            if tonumber(gangfunds) < tonumber(amount) then
                                GMT.notify(source, "~r~Not enough Money.")
                            else
                                GMT.setBankMoney(user_id, (GMT.getBankMoney(user_id))+tonumber(amount))
                                GMT.notify(source, "~g~Withdrew £"..getMoneyStringFormatted(amount))
                                addGangLog(GMT.getPlayerName(user_id),user_id,"Withdrew","£"..getMoneyStringFormatted(amount))
                                exports["gmt"]:execute("UPDATE gmt_gangs SET funds = @funds WHERE gangname = @gangname", {funds = tonumber(gangfunds)-tonumber(amount), gangname = gangName})
                            end
                        end
                    end
                    gangWithdraw[source] = false
                end
            end)
        end
    end
end)

RegisterServerEvent("GMT:PromoteUser",function(gangname,memberid)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank >= 4 then
                        local rank = gangmembers[tostring(memberid)].rank
                        local gangpermission = gangmembers[tostring(memberid)].gangPermission
                        if rank < 4 and gangpermission < 4 and tostring(user_id) ~= A then
                            GMT.notify(source, "~r~Only the leader can promote.")
                            return
                        end
                        if gangmembers[tostring(memberid)].rank == 3 and gangpermission == 3 and tostring(user_id) == A then
                            GMT.notify(source, "~r~There can only be one leader.")
                            return
                        end
                        if tonumber(memberid) == tonumber(user_id) and rank == 4 and gangpermission == 4 then
                            GMT.notify(source, "~r~You are already the highest rank.")
                            return
                        end
                        gangmembers[tostring(memberid)].rank = tonumber(rank) + 1
                        gangmembers[tostring(memberid)].gangPermission = tonumber(gangpermission) + 1
                        GMT.notify(source, "~g~Promoted User.")
                        addGangLog(GMT.getPlayerName(user_id),user_id,"Promoted","ID: "..memberid)
                        exports["gmt"]:execute("UPDATE gmt_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangname})
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:DemoteUser", function(gangname,member)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname},function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank >= 4 then
                        local rank = gangmembers[tostring(member)].rank
                        local gangpermission = gangmembers[tostring(member)].gangPermission
                        if rank < 4 and gangpermission < 4 and tostring(user_id) ~= A then
                            GMT.notify(source, "~r~Only the leader can demote.")
                            return
                        end
                        if gangmembers[tostring(member)].rank == 1 and gangpermission == 1 and tostring(user_id) == A then
                            GMT.notify(source, "~r~There can only be one leader.")
                            return
                        end
                        if tonumber(member) == tonumber(user_id) and rank == 1 and gangpermission == 1 then
                            GMT.notify(source, "~r~You are already the lowest rank.")
                            return
                        end
                        gangmembers[tostring(member)].rank = tonumber(rank)-1
                        gangmembers[tostring(member)].gangPermission = tonumber(gangpermission)-1
                        gangmembers = json.encode(gangmembers)
                        GMT.notify(source, "~g~Demoted User.")
                        addGangLog(GMT.getPlayerName(user_id),user_id,"Demoted","ID: "..member)
                        exports["gmt"]:execute("UPDATE gmt_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = gangmembers, gangname = gangname})
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:KickUser",function(gangname,member)
    local source = source
    local user_id = GMT.getUserId(source)
    local membersource = GMT.getUserSource(member)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    local memberrank = gangmembers[tostring(member)].rank
                    local leaderrank = gangmembers[tostring(user_id)].rank
                    if B.rank >= 3 then
                        if tonumber(member) == tonumber(user_id) then
                            GMT.notify(source, "~r~You cannot kick yourself.")
                            return
                        end
                        if tonumber(memberrank) >= leaderrank then
                            GMT.notify(source, "~r~You do not have permission to kick this member from this gang")
                            return
                        end
                        gangmembers[tostring(member)] = nil
                        addGangLog(GMT.getPlayerName(user_id),user_id,"Kicked","ID: "..member)
                        exports["gmt"]:execute("UPDATE gmt_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangname})
                        MySQL.execute("gmt_edituser", {user_id = member, gangname = nil})
                        if membersource then
                            GMT.notify(membersource, "~r~You have been kicked from the gang.")
                            syncRadio(membersource)
                            TriggerClientEvent("GMT:disbandedGang",membersource)
                        end
                    else
                        GMT.notify(source, "~r~You do not have permission to kick this member from this gang")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:LeaveGang", function(gangname)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        GMT.notify(source, "~r~You cannot leave the gang as you are the leader.")
                        return
                    end
                    gangmembers[tostring(user_id)] = nil
                    exports["gmt"]:execute("UPDATE gmt_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangname})
                    MySQL.execute("gmt_edituser", {user_id = user_id, gangname = nil})
                    if GMT.getUserSource(user_id) then
                        GMT.notify(source, "~r~You have left the gang.")
                        syncRadio(source)
                        TriggerClientEvent("GMT:disbandedGang",source)
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:InviteUser",function(gangname,playerid)
    local source = source
    local user_id = GMT.getUserId(source)
    local playersource = GMT.getUserSource(tonumber(playerid))
    if source ~= playersource then
        if playersource == nil then
            GMT.notify(source, "~r~Player is not online.")
            return
        else
            table.insert(playerinvites[playersource],gangname)
            addGangLog(GMT.getPlayerName(user_id),user_id,"Invited","ID: "..playerid)
            TriggerClientEvent("GMT:InviteReceived",playersource,"~g~Gang invite received from: " ..GMT.getPlayerName(user_id),gangname)
            GMT.notify(source, "~g~Successfully invited " ..GMT.getPlayerName(playerid).. " to the gang.")
        end
    else
        GMT.notify(source, "~r~You cannot invite yourself.")
    end
end)

RegisterServerEvent("GMT:DeleteGang",function(gangname)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        exports["gmt"]:execute("DELETE FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname})
                        for A,B in pairs(gangmembers) do
                            MySQL.execute("gmt_edituser", {user_id = A, gangname = nil})
                            if GMT.getUserSource(tonumber(A)) then
                                syncRadio(GMT.getUserSource(tonumber(A)))
                                TriggerClientEvent("GMT:disbandedGang",GMT.getUserSource(tonumber(A)))
                            else
                                print("User is not online, unable to disbanded gang for them.")
                            end
                        end
                        
                        GMT.notify(source, "~r~You have disbanded the gang.")
                    else
                        GMT.notify(source, "~r~You do not have permission to disband this gang.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:RenameGang", function(gangname,newname)
    local source = source
    local user_id = GMT.getUserId(source)
    local gangnamecheck = exports["gmt"]:scalarSync("SELECT gangname FROM gmt_gangs WHERE gangname = @gangname", {gangname = newname})
    if gangnamecheck == nil then
        exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
            if #ganginfo > 0 then
                local gangmembers = json.decode(ganginfo[1].gangmembers)
                for A,B in pairs(gangmembers) do
                    if tostring(user_id) == A then
                        if B.rank == 4 then
                            exports["gmt"]:execute("UPDATE gmt_gangs SET gangname = @gangname WHERE gangname = @oldgangname", {gangname = newname, oldgangname = gangname})
                            for A,B in pairs(gangmembers) do
                                MySQL.execute("gmt_edituser", {user_id = A, gangname = newname})
                                syncRadio(GMT.getUserSource(tonumber(A)))
                            end
                            GMT.notify(source, "~g~You have renamed the gang to: " ..newname)
                            addGangLog(GMT.getPlayerName(user_id),user_id,"Renamed gang",newname)
                        else
                            GMT.notify(source, "~r~You do not have permission to rename this gang.")
                        end
                    end
                end
            end
        end)
    else
        GMT.notify(source, "~r~Gang name is already taken.")
        return
    end
end)

RegisterServerEvent("GMT:SetGangWebhook")
AddEventHandler("GMT:SetGangWebhook", function(gangid)
    local source = source 
    local user_id = GMT.getUserId(source)
    exports['gmt']:execute('SELECT * FROM gmt_gangs WHERE gangname = @gangname', {gangname = gangid}, function(G)
        for K, V in pairs(G) do
            local array = json.decode(V.gangmembers) -- Convert the JSON string to a table
            for I, L in pairs(array) do
                if tostring(user_id) == I then
                    if L["rank"] == 4 then
                        GMT.prompt(source, "Webhook (Enter the webhook here): ", "", function(source, webhook)
                            local pattern = "^https://discord.com/api/webhooks/%d+/%S+$"
                            if webhook and string.match(webhook, pattern) then 
                                exports['gmt']:execute("UPDATE gmt_gangs SET webhook = @webhook WHERE gangname = @gangname", {gangname = gangid, webhook = webhook}, function(gotGangs) end)
                                GMT.notify(source, "~g~Webhook set.")
                                TriggerClientEvent('GMT:ForceRefreshData', -1)
                            else
                                GMT.notify(source, "~r~Invalid value.")
                            end
                        end)
                    else
                        GMT.notify(source, "~r~You do not have permission.")
                    end
                end
            end
        end
    end)
end)


RegisterServerEvent("GMT:LockGangFunds", function(gangname)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        local newlocked = not tobool(ganginfo[1].lockedfunds)
                        exports["gmt"]:execute("UPDATE gmt_gangs SET lockedfunds = @lockedfunds WHERE gangname = @gangname", {lockedfunds = newlocked, gangname = gangname}) 
                        GMT.notify(source, "~g~You have " ..(newlocked and "locked" or "unlocked") .." the gang funds.")
                        TriggerClientEvent("GMT:ForceRefreshData",source)
                        addGangLog(GMT.getPlayerName(user_id),user_id,"Locked Funds","")
                    else
                        GMT.notify(source, "~r~You do not have permission to lock the gang funds.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:sendGangMarker",function(Gangname,coords)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = Gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    for C,D in pairs(gangmembers) do
                        local temp = GMT.getUserSource(tonumber(C))
                        if temp then
                            TriggerClientEvent("GMT:drawGangMarker",temp,GMT.getPlayerName(user_id),coords)
                        end
                    end
                    break
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:setGangFit",function(gangName)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        GMTclient.getCustomization(source,{},function(customization)
                            exports["gmt"]:execute("UPDATE gmt_gangs SET gangfit = @gangfit WHERE gangname = @gangname", {gangfit = json.encode(customization), gangname = gangName})
                            GMT.notify(source, "~g~You have set the gang fit.")
                            addGangLog(GMT.getPlayerName(user_id),user_id,"Set Gang Fit","")
                            TriggerClientEvent("GMT:ForceRefreshData",source)
                        end)
                    else
                        GMT.notify(source, "~r~You do not have permission to set the gang fit.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("GMT:applyGangFit", function(gangName)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT gangfit FROM gmt_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
        if #ganginfo > 0 then
            GMTclient.setCustomization(source, {json.decode(ganginfo[1].gangfit)}, function()
                GMT.notify(source, "~g~You have applied the gang fit.")
                addGangLog(GMT.getPlayerName(user_id),user_id,"Apply Gang Fit","")
            end)
        end
    end)
end)

AddEventHandler("GMT:onServerSpawn", function(user_id,source,fspawn)
    if fspawn then
        playerinvites[source] = {}
        exports["gmt"]:execute("INSERT IGNORE INTO gmt_user_gangs (user_id) VALUES (@user_id)", {user_id = user_id})
    end
end)
RegisterServerEvent("GMT:newGangPanic")
AddEventHandler("GMT:newGangPanic", function(a,playerName)
    local source = source
    local user_id = GMT.getUserId(source)   
    local peoplesids = {}
    local gangmembers = {}
    exports['gmt']:execute('SELECT * FROM gmt_gangs', function(gotGangs)
        for K,V in pairs(gotGangs) do
            local array = json.decode(V.gangmembers)
            for I,L in pairs(array) do
                if tostring(user_id) == I then
                    isingang = true
                    for U,D in pairs(array) do
                        peoplesids[tostring(U)] = tostring(D.gangPermission)
                    end
                    exports['gmt']:execute('SELECT * FROM gmt_users', function(gotUser)
                        for J,G in pairs(gotUser) do
                            if peoplesids[tostring(G.id)] then
                                local player = GMT.getUserSource(tonumber(G.id))
                                if player then
                                    TriggerClientEvent("GMT:returnPanic", player, player, a, playerName,V.gangname)
                                    addGangLog(GMT.getPlayerName(user_id),user_id,"Panic","ID: "..G.id)
                                end
                            end
                        end
                    end)
                    break
                end
            end
        end
    end)
end)

local gangtable = {}
Citizen.CreateThread(function()
    while true do
        Wait(10000)
        for _,a in pairs(GetPlayers()) do
            local user_id = GMT.getUserId(a)
            if user_id then
                gangtable[user_id] = {health = GetEntityHealth(GetPlayerPed(a)), armor = GetPedArmour(GetPlayerPed(a))}
            end
        end
        TriggerClientEvent("GMT:sendGangHPStats", -1, gangtable)
    end
end)

AddEventHandler("playerDropped", function(reason)
    local source = source
    local user_id = GMT.getUserId(source)
    if gangtable[user_id] ~= nil then
        gangtable[user_id] = nil
        TriggerClientEvent("GMT:sendGangHPStats", -1, gangtable)
        syncRadio(source)
    end
end)

Citizen.CreateThread(function()
    Wait(2500)
    exports['gmt']:execute([[
    CREATE TABLE IF NOT EXISTS `gmt_user_gangs` (
    `user_id` int(11) NOT NULL,
    `gangname` VARCHAR(100) NULL,
    PRIMARY KEY (`user_id`)
    );]])
end)

RegisterCommand("gangconvert",function(source)
    if source == 0 then
        exports['gmt']:execute("SELECT * FROM gmt_gangs",{},function(gangs)
            for A,B in pairs(gangs) do
                local gangmembers = json.decode(B.gangmembers)
                for C,D in pairs(gangmembers) do
                    print("Setting gang for user: "..C.." to "..B.gangname)
                    MySQL.execute("gmt_adduser", {user_id = C, gangname = B.gangname})
                end
            end
        end)
    end
end)

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    syncRadio(source)
end)
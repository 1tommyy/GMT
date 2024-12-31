local disputes = {}
local blockedUsers = {}

local function RefreshDispute()
    disputes = {}
    exports["gmt"]:execute("SELECT * FROM gmt_disputedata",function(result)
        if result then
            for k,v in pairs(result) do
                disputes[v.user_id] = json.decode(v.disputeData)
            end
        end
    end)
end

local function updateDisputeData(user_id, other_user_id, from_id, message)
    local function updatePlayerData(user_id, other_user_id, from_id, message)
        local disputeData = disputes[user_id]
        if not disputeData then
            disputeData = {
                user_id = user_id,
                players = {
                    {
                        id = other_user_id,
                        name = GMT.getPlayerName(other_user_id),
                        messages = {{from = from_id, to = user_id, message = message, timestamp = os.date('%Y-%m-%d %H:%M:%S')}}
                    }
                }
            }
            exports["gmt"]:execute("INSERT INTO gmt_disputedata (user_id, name, disputeData) VALUES (@user_id, @name, @disputeData)", {user_id = user_id, name = GMT.getPlayerName(user_id), disputeData = json.encode(disputeData)})
        else
            if disputeData.players == nil then
                disputeData.players = {}
            end
            local playerFound = false
            for _, player in ipairs(disputeData.players) do
                if player.id == other_user_id then
                    playerFound = true
                    if player.messages == nil then
                        player.messages = {}
                    end
                    table.insert(player.messages, {from = from_id, to = other_user_id, message = message, timestamp = os.date('%Y-%m-%d %H:%M:%S')})
                    break
                end
            end
            if not playerFound then
                local player_name = GMT.getPlayerName(other_user_id) 
                table.insert(disputeData.players, {id = other_user_id, name = player_name, messages = {{from = from_id, to = other_user_id, message = message, timestamp = os.date('%Y-%m-%d %H:%M:%S')}}})
            end
            exports["gmt"]:execute("UPDATE gmt_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = user_id, disputeData = json.encode(disputeData)})
        end
    end

    updatePlayerData(user_id, other_user_id, from_id, message)
    updatePlayerData(other_user_id, user_id, from_id, message)

    RefreshDispute()
end

function GMT.AddDisputeMessage(src, user_id, other_user_id, message)
    print("Adding dispute message from " .. user_id .. " to " .. other_user_id .. ": " .. message)
    if user_id and other_user_id and message then
        exports["gmt"]:execute("SELECT * FROM gmt_disputedata WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
             --   print("Success! :" .. message)
                local disputeData = json.decode(result[1].disputeData)
                for _, player in ipairs(disputeData.players) do
                    if player.id == other_user_id and player.blocked == 1 then
                        print("Message not sent, sender is blocked by the receiver")
                        return
                    end
                end
                updateDisputeData(user_id, other_user_id, user_id, message) -- sender
                updateDisputeData(other_user_id, user_id, user_id, message) -- receiver
                if GMT.getUserSource(other_user_id) then
                    --print("Added message :" .. message)
                    TriggerClientEvent("GMT:MessageHasBeenSent", GMT.getUserSource(other_user_id), user_id, other_user_id, message) -- receiver
                    RefreshDispute()
                else
                    print("Error: No client with user_id " .. other_user_id)
                end
                RefreshDispute()
            end
        end)
    end
end

RegisterServerEvent('GMT:calladdDisputeMessage')
AddEventHandler('GMT:calladdDisputeMessage', function(message)
    local source = source
    local user_id = GMT.getUserId(source)
    local other_user_id = message.to
    GMT.AddDisputeMessage(source, user_id, other_user_id, message.message)
    RefreshDispute()
end)

function GMT.AddDisputePlayer(user_id, other_user_id, player_name)
    if user_id and other_user_id and player_name then
        exports["gmt"]:execute("SELECT * FROM gmt_disputedata WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                if not disputeData then
                    local defaultdata = {user_id = other_user_id}
                    MySQL.execute("gmt_disputes/adduser",{user_id = other_user_id,name = GMT.getPlayerName(other_user_id),disputeData = json.encode(defaultdata)})
                end
                if disputeData.players == nil then
                    disputeData.players = {}
                end
                for _, player in ipairs(disputeData.players) do
                    if player.id == other_user_id then
                        return -- If other_user_id is found, stop the function
                    end
                end
                table.insert(disputeData.players, {id = other_user_id, name = player_name, messages = {}})
                exports["gmt"]:execute("UPDATE gmt_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = user_id, disputeData = json.encode(disputeData)}, function()
                    RefreshDispute()
                end)
            end
        end)
    end
end

function GMT.FetchDisputePlayers(user_id, other_user_id)
    if user_id and other_user_id then
        local disputeData = disputes[user_id]
        if disputeData and disputeData.players then
            for _, player in ipairs(disputeData.players) do
                if player.id == other_user_id then
                    return true 
                end
            end
        end
    end
    return false
end

function GMT.GetDisputeMessages(user_id, source)
    if user_id then
        local disputeData = disputes[user_id]
        local messages = disputeData and disputeData.messages or nil
        return messages
    end
end

RegisterServerEvent('GMT:getMessagesUpdated')
AddEventHandler('GMT:getMessagesUpdated', function(userId)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.GetDisputeMessages(userId, source)
end)

RegisterCommand("refreshMessages",function(source,args)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id == 1 then
        GMT.GetDisputeMessages(user_id, source)
    end
end)

MySQL.createCommand("gmt_disputes/adduser","INSERT INTO gmt_disputedata (user_id,name,disputeData) VALUES (@user_id,@name,@disputeData) ON DUPLICATE KEY UPDATE name = @name, disputeData = @disputeData")

RegisterServerEvent("GMT:requestdisputedatas")
AddEventHandler("GMT:requestdisputedatas", function()
    local source = source
    local user_id = GMT.getUserId(source)
    local disputeData = disputes[user_id]
    local sentMessages = {}
    local receivedMessages = {}
    if disputeData then
        for _, player in ipairs(disputeData.players or {}) do
            if player.messages then
                for _, message in ipairs(player.messages) do
                    if message.from == user_id then
                        table.insert(sentMessages, message)
                    else
                        table.insert(receivedMessages, message)
                    end
                end
            end
        end
    end
    RefreshDispute()
    TriggerClientEvent("GMTDISPUTEUI:setdisputedatas", source, disputeData, user_id, sentMessages, receivedMessages)
end)

function GMT.MuteUser(triggering_user_id, selected_user_id)
    if triggering_user_id and selected_user_id then
        print("User " .. selected_user_id .. " has been muted by " .. triggering_user_id)
    end
end

function GMT.BlockUser(triggering_user_id, selected_user_id)
    if triggering_user_id and selected_user_id then
        exports["gmt"]:execute("SELECT * FROM gmt_disputedata WHERE user_id = @user_id", {user_id = triggering_user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                for _, player in ipairs(disputeData.players) do
                    if player.id == selected_user_id then
                        player.blocked = 1
                        break
                    end
                end
                exports["gmt"]:execute("UPDATE gmt_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = triggering_user_id, disputeData = json.encode(disputeData)})
                print("User " .. selected_user_id .. " has been blocked by " .. triggering_user_id)
                RefreshDispute()
            end
        end)
    end
end

function GMT.DelUser(triggering_user_id, selected_user_id)
    if triggering_user_id and selected_user_id then
        exports["gmt"]:execute("SELECT * FROM gmt_disputedata WHERE user_id = @user_id", {user_id = triggering_user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                for i, player in ipairs(disputeData.players) do
                    if player.id == selected_user_id then
                        table.remove(disputeData.players, i)
                        break
                    end
                end
                exports["gmt"]:execute("UPDATE gmt_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = triggering_user_id, disputeData = json.encode(disputeData)})
                print("User " .. selected_user_id .. " has been deleted by " .. triggering_user_id)
                RefreshDispute()
            end
        end)
        exports["gmt"]:execute("SELECT * FROM gmt_disputedata WHERE user_id = @user_id", {user_id = selected_user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                for i, player in ipairs(disputeData.players) do
                    if player.id == triggering_user_id then
                        table.remove(disputeData.players, i)
                        break
                    end
                end
                exports["gmt"]:execute("UPDATE gmt_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = selected_user_id, disputeData = json.encode(disputeData)})
                print("User " .. triggering_user_id .. " has been deleted from " .. selected_user_id .. "'s player list")
                RefreshDispute()
            end
        end)
    end
end

RegisterServerEvent('GMT:callMuteUser')
AddEventHandler('GMT:callMuteUser', function(user2bMuted)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.MuteUser(user_id, user2bMuted)
end)

RegisterServerEvent('GMT:callDelUser')
AddEventHandler('GMT:callDelUser', function(user2bMuted)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.DelUser(user_id, user2bMuted)
end)

RegisterServerEvent('GMT:callBlockUser')
AddEventHandler('GMT:callBlockUser', function(user2bMuted)
    local source = source
    local user_id = GMT.getUserId(source)
    GMT.BlockUser(user_id, user2bMuted)
end)

AddEventHandler("GMT:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        local defaultdata = {user_id = user_id}
        MySQL.execute("gmt_disputes/adduser",{user_id = user_id,name = GMT.getPlayerName(user_id),disputeData = json.encode(defaultdata)})
    end
end)

RegisterCommand("adddispute",function(source,args)
    local source = source
    local other = tonumber(args[1])
    local othername = GMT.getPlayerName(other)
    local sourceUserId = GMT.getUserId(source)
    local sourcename = GMT.getPlayerName(source)
    if sourceUserId == 1 then
        GMT.AddDisputePlayer(sourceUserId, other, othername)
        GMT.AddDisputePlayer(other, sourceUserId, sourcename)
    end
end)

RefreshDispute()
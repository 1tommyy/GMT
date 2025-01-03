RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

-- this is a built-in event, but somehow needs to be registered
RegisterNetEvent('playerJoining')


local blockedWords = {
    "nigger",
    "nigga",
    "wog",
    "coon",
    "paki",
    "faggot",
    "anal",
    "kys",
    "homosexual",
    "lesbian",
    "suicide",
    "negro",
    "queef",
    "queer",
    "allahu akbar",
    "terrorist",
    "wanker",
    "n1gger",
    "f4ggot",
    "n0nce",
    "d1ck",
    "h0m0",
    "n1gg3r",
    "h0m0s3xual",
    "nazi",
    "hitler",
    "fag",
    "fa5",
}


exports('addMessage', function(target, message)
    if not message then
        message = target
        target = -1
    end

    if not target or not message then return end

    TriggerClientEvent('chat:addMessage', target, message)
end)

local hooks = {}
local hookIdx = 1

exports('registerMessageHook', function(hook)
    local resource = GetInvokingResource()
    hooks[hookIdx + 1] = {
        fn = hook,
        resource = resource
    }

    hookIdx = hookIdx + 1
end)

local modes = {}

local function getMatchingPlayers(seObject)
    local players = GetPlayers()
    local retval = {}

    for _, v in ipairs(players) do
        if IsPlayerAceAllowed(v, seObject) then
            retval[#retval + 1] = v
        end
    end

    return retval
end
exports('registerMode', function(modeData)
    if not modeData.name or not modeData.displayName or not modeData.cb then
        return false
    end

    local resource = GetInvokingResource()

    modes[modeData.name] = modeData
    modes[modeData.name].resource = resource

    local clObj = {
        name = modeData.name,
        displayName = modeData.displayName,
        color = modeData.color or '#fff',
        isChannel = modeData.isChannel,
        isGlobal = modeData.isGlobal,
    }

    if not modeData.seObject then
        TriggerClientEvent('chat:addMode', -1, clObj)
    else
        for _, v in ipairs(getMatchingPlayers(modeData.seObject)) do
            TriggerClientEvent('chat:addMode', v, clObj)
        end
    end

    return true
end)

local function unregisterHooks(resource)
    local toRemove = {}

    for k, v in pairs(hooks) do
        if v.resource == resource then
            table.insert(toRemove, k)
        end
    end

    for _, v in ipairs(toRemove) do
        hooks[v] = nil
    end

    toRemove = {}

    for k, v in pairs(modes) do
        if v.resource == resource then
            table.insert(toRemove, k)
        end
    end

    for _, v in ipairs(toRemove) do
        TriggerClientEvent('chat:removeMode', -1, {
            name = v
        })

        modes[v] = nil
    end
end

-- local hideadminchat = false

-- AddEventHandler('GMT:hideAdminChat', function(value)
--     hideadminchat = value
-- end)

local function routeMessage(source, author, message, mode, fromConsole)
    if source >= 1 then
        author = exports["gmt"]:GetDiscordName(source)
    end

    local outMessage = {
        color = { 0, 0, 255 },
        multiline = true,
        args = { message },
        mode = mode
    }

    if author ~= "" then
        outMessage.args = { author, message }
    end

    if mode and modes[mode] then
        local modeData = modes[mode]

        if modeData.seObject and not IsPlayerAceAllowed(source, modeData.seObject) then
            return
        end
    end

    local messageCanceled = false
    local routingTarget = -1

    local hookRef = {
        updateMessage = function(t)
            -- shallow merge
            for k, v in pairs(t) do
                if k == 'template' then
                    outMessage['template'] = v:gsub('%{%}', outMessage['template'] or '@default')
                elseif k == 'params' then
                    if not outMessage.params then
                        outMessage.params = {}
                    end

                    for pk, pv in pairs(v) do
                        outMessage.params[pk] = pv
                    end
                else
                    outMessage[k] = v
                end
            end
        end,

        cancel = function()
            messageCanceled = true
        end,

        setSeObject = function(object)
            routingTarget = getMatchingPlayers(object)
        end,

        setRouting = function(target)
            routingTarget = target
        end
    }

    for _, hook in pairs(hooks) do
        if hook.fn then
            hook.fn(source, outMessage, hookRef)
        end
    end

    if modes[mode] then
        local m = modes[mode]

        m.cb(source, outMessage, hookRef)
    end

    if messageCanceled then
        return
    end
    if string.sub(message, 1, 1) == "/" then
        CancelEvent()
        return
    end
    if mode == "OOC" then
        TriggerEvent("GMT:ooc", source, message)
        return
    end
    if mode == "Gang" then 
        TriggerEvent("GMT:GangChat", source, message)
        return
    end
    if mode == "Anonymous" then
        TriggerEvent("GMT:Anon", source, message)
        return
    end
    if mode == "Police" then
        TriggerEvent("GMT:PoliceChat", source, message)
        return
    end
    if mode == "Faction" then
        TriggerEvent("GMT:Fchat", source, message)
        return
    end
    if mode == "NHS" then
        TriggerEvent("GMT:Nchat", source, message)
        return
    end
    if mode == "Admin" then --and not hideadminchat then
        for k,v in ipairs(GetPlayers()) do
            if exports['gmt']:hasPermission(v, "admin.tickets") then
                TriggerClientEvent('chatMessage', v, "^3Admin Chat | " .. author..": " , { 128, 128, 128 }, message, "ooc", "Admin")
            end
        end
        return
    end
    TriggerClientEvent('chatMessage', -1, "Global @"..author..":",  { 255, 255, 255 }, message, "glbl", "Global")
end
local cooldown = {}
local lastMessage = {}
AddEventHandler('_chat:messageEntered', function(author, color, message, mode)
    if not message or not author then
        return
    end
    if not WasEventCanceled() then
        author = exports["gmt"]:GetDiscordName(source)
        if lastMessage[source] and lastMessage[source] == message then
            TriggerClientEvent('chatMessage', source, "",  { 255, 255, 255 }, "^1" .. author .. " ^3Sending duplicate messages is forbidden.^0", "alert", mode)
            return
        end
        if cooldown[source] and not (os.time() > cooldown[source]) then
            TriggerClientEvent('chatMessage', source, "",  { 255, 255, 255 }, "^1" .. author .. " ^3You are being rate limited. ^0", "alert", mode)
            return
        else
            cooldown[source] = nil
        end
        for word in pairs(blockedWords) do
            if(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(message:lower(), "-", ""), ",", ""), "%.", ""), " ", ""), "*", ""), "+", ""):find(blockedWords[word])) then
                TriggerClientEvent('GMT:chatFilterScaleform', source, 10, 'That word is not allowed.', author, user_id)
                CancelEvent()
                return
            end
        end
        cooldown[source] = os.time() + 1
        lastMessage[source] = message
        routeMessage(source, author, message, mode)
    end
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = exports["gmt"]:GetDiscordName(source)
    routeMessage(source, name, '/' .. command, nil, true)
    if not WasEventCanceled() then
        routeMessage(source, name, '/' .. command, nil, true)
    end
    CancelEvent()
end)

-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end

        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end
AddEventHandler('chatMessage', function(Source, Name, Msg, mode)
    args = stringsplit(Msg, " ")
    CancelEvent()
    if string.find(args[1], "/") then
        local cmd = args[1]
        table.remove(args, 1)
	else
		TriggerClientEvent('chatMessage', -1, Name, { 255, 255, 255 }, Msg, mode)
	end
end)


AddEventHandler('chat:init', function()
    local source = source
    refreshCommands(source)

    for _, modeData in pairs(modes) do
        local clObj = {
            name = modeData.name,
            displayName = modeData.displayName,
            color = modeData.color or '#fff',
            isChannel = modeData.isChannel,
            isGlobal = modeData.isGlobal,
        }

        if not modeData.seObject or IsPlayerAceAllowed(source, modeData.seObject) then
            TriggerClientEvent('chat:addMode', source, clObj)
        end
    end
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)

    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)

AddEventHandler('onResourceStop', function(resName)
    unregisterHooks(resName)
end)
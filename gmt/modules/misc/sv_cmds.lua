local chatCooldown = {}
local lastmsg = nil
local lastMessage = {}
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

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		for k,v in pairs(chatCooldown) do
			chatCooldown[k] = nil
		end
	end
end)

RegisterCommand("anon", function(source, args)
	local message = table.concat(args, " ")
	TriggerEvent("GMT:Anon", source, message)
end)

--Dispatch Message
RegisterServerEvent("GMT:Anon", function(source, args)
	local source = source
    local message = args
	local user_id = GMT.getUserId(source)
	local name = GMT.getPlayerName(user_id)
    if message == "" then 
        return 
    end
	if name then 
		for word in pairs(blockedWords) do
			if(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(message:lower(), "-", ""), ",", ""), "%.", ""), " ", ""), "*", ""), "+", ""):find(blockedWords[word])) then
				TriggerClientEvent('GMT:chatFilterScaleform', source, 10, 'That word is not allowed.', name, user_id)
                GMT.sendDCLog('filtered-message', 'GMT Banned Words Logs', "Filtered Message!\n```" .. message.. "```\n> Player Name: **".. name .."**\n> Player PermID: **".. user_id .. "**")   
				CancelEvent()
				return
			end
		end
		GMT.sendDCLog('anon', "GMT Chat Logs", "```"..message.."```".."\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
		TriggerClientEvent('chatMessage', -1, "^4Global @^1Anonymous: ", { 128, 128, 128 }, message, "ooc", "Anonymous")	
	end
end)

function GMT.ooc(source, args, raw)
	if #args <= 0 then 
		return 
	end
	local source = source
	local message = args
	local user_id = GMT.getUserId(source)
	local name = GMT.getPlayerName(user_id)
    if lastMessage[source] and lastMessage[source] == message then
        TriggerClientEvent('chatMessage', source, "",  { 128, 128, 128 }, "^1" .. GMT.getPlayerName(user_id) .. " ^3Sending duplicate messages is forbidden.^0", "alert", "OOC")
        return
    end
	if not chatCooldown[source] then 
		for word in pairs(blockedWords) do
			if(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(args:lower(), "-", ""), ",", ""), "%.", ""), " ", ""), "*", ""), "+", ""):find(blockedWords[word])) then
                TriggerClientEvent('GMT:chatFilterScaleform', source, 10, 'That word is not allowed.', name, user_id)
                GMT.sendDCLog('filtered-message', 'GMT Banned Words Logs', "Filtered Message!\n```" .. message.. "```\n> Player Name: **".. name .."**\n> Player PermID: **".. user_id .. "**")   
				CancelEvent()
				return
			end
		end
		if GMT.hasGroup(user_id, "Founder") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^8 Founder ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")	
		elseif GMT.hasGroup(user_id, "Lead Developer") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^3 Lead Developer ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")	
		elseif GMT.hasGroup(user_id, "Developer") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^4 Developer ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")	
		elseif GMT.hasGroup(user_id, "Community Manager") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^1 Community Manager ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")	
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Staff Manager") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^6 Staff Manager ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")	
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Head Administrator") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^3 Head Administrator ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")	
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Senior Administrator") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^3 Senior Administrator ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")	
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Administrator") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^4 Administrator ^7" .. GMT.getPlayerName(user_id) .. " : " ,{ 128, 128, 128 }, message, "ooc", "OOC")					
			chatCooldown[source] = true			
		elseif GMT.hasGroup(user_id, "Senior Moderator") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^2 Senior Moderator ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")				
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Moderator") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^2 Moderator ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")				
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Support Team") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^2 Support Team ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Trial Staff") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^5 Trial Staff ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Baller") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^3" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Rainmaker") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^4" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Kingpin") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^1" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Supreme") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^5" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Premium") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^6" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "Supporter") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^2" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif GMT.hasGroup(user_id, "B") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^2" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		else
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^7" .. GMT.getPlayerName(user_id) .. " : " , { 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		end
		GMT.sendDCLog('chat-logs', "GMT Chat Logs", "```"..message.."```".."\n> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
	else
		TriggerClientEvent('chatMessage', source, "^1[GMT]", { 128, 128, 128 }, " Chat Spam | Retry in 3 Seconds", "alert", "OOC")
		chatCooldown[source] = true
		lastMessage[source] = message
	end
end
RegisterServerEvent("GMT:ooc", function(source, args)
	GMT.ooc(source, args)
end)

RegisterCommand("ooc", function(source, args, raw)
    local message = table.concat(args, " ")
    GMT.ooc(source, message)
end)

RegisterCommand("/", function(source, args, raw)
	local message = table.concat(args, " ")
	message = message:sub(1)
    GMT.ooc(source, message)
end)

RegisterCommand('cc', function(source, args, rawCommand)
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'admin.ban') then
        TriggerClientEvent('chat:clear',-1)             
    end
end, false)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end
-- RegisterCommand('beta', function(source, args, rawCommand) -- tayser
--     local source = source
--     local user_id = GMT.getUserId(source)
--     if not GMT.hasGroup(user_id, 'Supporter') and not GMT.hasGroup(user_id, 'Gang') then
--         GMT.addUserGroup(user_id, "Supporter")
--         GMT.addUserGroup(user_id, "Gang")
--         GMT.giveBankMoney(user_id, 5000000)
--         GMT.notify(source, {'~o~Received Gang License'})
--         GMT.notify(source, {'~o~Received Supporter'})
--         GMT.notify(source, {'~o~Received £5000000'})
--         Wait(100)
--         GMT.notify(source, {'~o~Thankyou for participating in the GMT Beta ❤'})
--     else
--         GMT.notify(source, {'~r~You have already claimed the beta rewards!'})
--     end
-- end)
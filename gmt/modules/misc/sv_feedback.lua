noFeedbackGiven = false

RegisterServerEvent("GMT:adminTicketNoFeedback")
AddEventHandler("GMT:adminTicketNoFeedback", function(aL)
    local user_id = GMT.getUserId(source)
    local PlayerName = GMT.getPlayerName(user_id)

    noFeedbackGiven = true

    GMT.sendDCLog('feedback', 'GMT Feedback Logs', "> Player Name: **" .. PlayerName .. "**\n> Player PermID: **" .. user_id .. "**\n> Empty Feedback: **No Feedback Given**")
end)

RegisterServerEvent("GMT:adminTicketFeedback")
AddEventHandler("GMT:adminTicketFeedback", function(AdminID, FeedBackType, Message)
    if AdminID == nil then -- AdminID is Admin PermID
        return
    end
    local source = source
    local user_id = GMT.getUserId(source)
    local admintemp = GMT.getUserSource(AdminID)
    local amount = 0
    local colour = "~b~"
    if FeedBackType == "good" then
        colour = "~g~"
        amount = 25000
    elseif FeedBackType == "neutral" then
        colour = "~o~"
        amount = 10000
    elseif FeedBackType == "bad" then
        colour = "~r~"
        amount = 5000
    end
    GMT.giveBankMoney(admintemp, amount)
    if admintemp then
        GMT.notify(admintemp, colour.."You have received £"..getMoneyStringFormatted(amount).." for " ..FeedBackType.." feedback.")
    end
    GMT.notify(source, colour.."You have given "..GMT.getPlayerName(AdminID).." "..FeedBackType.." feedback.")
    if FeedBackType == "good" then
        GMT.sendDCLog('be-like-this', 'GMT Feedback Logs',  "> Admin Name: **" .. GMT.getPlayerName(AdminID) .. "**\n> Admin TempID **"..admintemp.. "**\n> Admin PermID **".. AdminID .. "**\n> Player Name: **" .. GMT.getPlayerName(user_id) .. "**\n> Player TempID **"..source.. "**\n> Player PermID: **" .. user_id .. "**\n> Feedback Type: **" .. FeedBackType .. "**\n> Message: **" .. Message .."**")
    elseif FeedBackType == "bad" then
        GMT.sendDCLog('dont-be-like-this', 'GMT Feedback Logs',  "> Admin Name: **" .. GMT.getPlayerName(AdminID) .. "**\n> Admin TempID **"..admintemp.. "**\n> Admin PermID **".. AdminID .. "**\n> Player Name: **" .. GMT.getPlayerName(user_id) .. "**\n> Player TempID **"..source.. "**\n> Player PermID: **" .. user_id .. "**\n> Feedback Type: **" .. FeedBackType .. "**\n> Message: **" .. Message .."**")
    else
        GMT.sendDCLog('be-like-this', 'GMT Feedback Logs', "> Admin Name: **" .. GMT.getPlayerName(AdminID) .. "**\n> Admin TempID **"..admintemp.. "**\n> Admin PermID **".. AdminID .. "**\n> Player Name: **" .. GMT.getPlayerName(user_id) .. "**\n> Player TempID **"..source.. "**\n> Player PermID: **" .. user_id .. "**\n> Feedback Type: **" .. FeedBackType .. "**\n> Message: **" .. Message .."**")
    end
end)
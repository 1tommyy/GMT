local isDisputeMenuOpen = false
local urlIsOpen = false

local function openDisputeMenu()
    if not isDisputeMenuOpen then
        isDisputeMenuOpen = true
        TriggerServerEvent('GMT:requestdisputedatas', function(disputeData, userID, sentMessages, receivedMessages)
            SendNUIMessage({
                type = "RefreshDispute",
                disputeData = disputeData,
                userID = userID,
                sentMessages = sentMessages,
                receivedMessages = receivedMessages
            })
        end)
    end
end

local function closeDisputeMenu()
    if isDisputeMenuOpen then
        gmtCloseDisputeMenu()
        SetNuiFocus(false, false) 
    end
end

RegisterKeyMapping("closedispute", "", "keyboard", "H")
RegisterCommand('dispute', openDisputeMenu)
RegisterCommand('closedispute', closeDisputeMenu)

RegisterNUICallback('closeDisputeMenu', function(data, cb)
    SetNuiFocus(false, false)
    ExecuteCommand('closedispute')
    cb('ok')
end)

RegisterNetEvent('GMTDISPUTEUI:setdisputedatas')
AddEventHandler('GMTDISPUTEUI:setdisputedatas', function(disputeData, userId, sentMessages, receivedMessages)
    gmtShowDisputeMenu(disputeData, userId, sentMessages, receivedMessages)
    isDisputeMenuOpen = true
end)

RegisterNetEvent('GMT:RefreshDispute')
AddEventHandler('GMT:RefreshDispute', function(disputeData, userID, sentMessages, receivedMessages)
    SendNUIMessage({
        type = "RefreshDispute",
        disputeData = disputeData,
        userID = userID,
        sentMessages = sentMessages,
        receivedMessages = receivedMessages
    })
end)

RegisterNUICallback('mutePlr', function(data, cb)
    TriggerServerEvent('GMT:callMuteUser', data.user2bMuted)
    cb('ok')
end)

RegisterNUICallback('openPReport', function(data, cb)
    TriggerEvent('GMT:callOpenPReport', "https://discord.gg/gmtrp")
    cb('ok')
end)

RegisterNUICallback('delPlr', function(data, cb)
    TriggerServerEvent('GMT:callDelUser', data.user2bMuted)
    cb('ok')
end)

RegisterNUICallback('blockPlr', function(data, cb)
    TriggerServerEvent('GMT:callBlockUser', data.user2bMuted)
    cb('ok')
end)

RegisterNUICallback('newMessage', function(data, cb)
    TriggerServerEvent('GMT:calladdDisputeMessage', data.message)
    cb('ok')
end)

RegisterNetEvent('GMT:MessageHasBeenSent')
AddEventHandler('GMT:MessageHasBeenSent', function(from_id, to_id, message)
    SendNUIMessage({
        type = "newMessage",
        from = from_id,
        to = to_id,
        message = message
    })
    SendNUIMessage({
        type = "showmessageNotification",
        from = from_id,
    })
end)

function gmtShowDisputeMenu(disputeData, userId, sentMessages, receivedMessages)
    isDisputeMenuOpen = true
    DisableIdleCamera(true)
    SetNuiFocusKeepInput(false)
    TransitionToBlurred(1000)
    SetNuiFocus(true, true)
    ExecuteCommand('hideui')
    SendNUIMessage({
        type = "toggleDisputeSystem",
        toggle = true,
        disputeData = json.encode(disputeData),
        userID = userId,
        sentMessages = json.encode(sentMessages),
        receivedMessages = json.encode(receivedMessages),
    })
end

function gmtCloseDisputeMenu()
    isDisputeMenuOpen = false
    DisableIdleCamera(false)
    ExecuteCommand('showui')
    TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "toggleDisputeSystem",
        toggle = false
    })
end

RegisterNetEvent('gmtHideDisputeMenu')
AddEventHandler('gmtHideDisputeMenu', function()
	gmtCloseDisputeMenu()
end)

RegisterNetEvent('gmtShowDisputeMenu')
AddEventHandler('gmtShowDisputeMenu', function()
	gmtShowDisputeMenu()
end)
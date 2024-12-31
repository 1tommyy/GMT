local isPauseMenuOpen = false
local urlIsOpen = false
RegisterKeyMapping("gmtTogglePauseMenu", "", "keyboard", "ESCAPE")
RegisterKeyMapping("gmtTogglePauseMenuController", "", "controller", "START")
local function togglePauseMenu()
    if IsPauseMenuActive() then
        return
    end

    if isPauseMenuOpen then
        gmtClosePauseMenu()
    elseif not tGMT.isInComa() then
        TriggerServerEvent('GMT:getPlayerListData')
        gmtShowPauseMenu()
    end
end
RegisterCommand('gmtTogglePauseMenu', togglePauseMenu)
RegisterCommand('gmtTogglePauseMenuController', togglePauseMenu)

function tGMT.isPauseMenuOpen()
    return isPauseMenuOpen
end

function gmtShowPauseMenu()
    if IsPauseMenuActive() and tGMT.isInComa() then
        return
    end
    SetPauseMenuActive(true)
    DisableIdleCamera(true)
    ExecuteCommand('hideui')
    SetNuiFocusKeepInput(false)
    -- TriggerScreenblurFadeIn(5.0)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "gmtTogglePauseMenu",
        toggle = true,
        gmtDLastName = tostring(getMoneyStringFormatted(GMT.getPlayerHours(GMT.getUserId()))), -- PLAYTIME
        gmtDBirthdate = GMT.getEmploymentStatus(), -- EMPLOYMENT
        totalPlayers = #GetPlayers() .. "/" .. GetConvar("sv_maxclients", "64"), -- TOTAL PLAYERS ONLINE
        gmtDGender = getMoneyStringFormatted(GMT.getUserId()), -- ID
        deathmatchPlayers = "0/" .. GetConvar("sv_maxclients", "64"), -- TOTAL DEATHMATCH PLAYERS ONLINE
        gmtPlrName = GMT.getPlayerName(GetPlayerServerId(PlayerId())), -- NAME
    })
    isPauseMenuOpen = true
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPauseMenuActive(false)
    end
end)

RegisterNUICallback('Close', function(data)
    gmtClosePauseMenu()
end)

RegisterNUICallback('Settings', function(data)
    gmtClosePauseMenu()
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'),0,-1) 
end)

RegisterNUICallback('Dispute', function(data)
    gmtClosePauseMenu()
    ExecuteCommand('dispute')
end)

RegisterNUICallback('ReadRules', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://docs.google.com/document/d/1_mEm3XMy6OYOcM_jOr6hFy7_HsHwdtGdWKuKdu13Y4w/edit?tab=t.0#heading=h.54h65raatskz')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('DeathMatchDiscord', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://discord.gg/gmtrp')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('DeathMatchF8', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        TriggerEvent("GMT:showNotification",
            {
                text = "F8 Connect Copied To Clipboard.",
                height = "200px",
                width = "auto",
                colour = "#FFF",
                background = "#32CD32",
                pos = "bottom-right",
                icon = "good"
            }, 5000
        )
        tGMT.CopyToClipBoard("deathmatch.gmt.city")
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)


RegisterNUICallback('Rules', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://docs.google.com/document/d/1_mEm3XMy6OYOcM_jOr6hFy7_HsHwdtGdWKuKdu13Y4w/edit?tab=t.0#heading=h.54h65raatskz')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('ComRules', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://docs.google.com/document/d/1_mEm3XMy6OYOcM_jOr6hFy7_HsHwdtGdWKuKdu13Y4w/edit?tab=t.0#heading=h.54h65raatskz')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('GMTDiscord', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://discord.gg/gmtrp')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Guide', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://wiki.gmtstudios.ltd/')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Twitter', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://x.com/GMTFiveM')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Website', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://gmtstudios.ltd')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Store', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tGMT.OpenUrl('https://store.gmtstudios.ltd')
    else
        GMT.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Map', function(data)
    gmtClosePauseMenu()
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'),0,-1)
end)

RegisterNUICallback('Disconnect', function(data)
    gmtClosePauseMenu()
	TriggerServerEvent('kick:PauseMenu')
end)

function gmtClosePauseMenu()
    if IsPauseMenuActive() then
        return
    end
    ExecuteCommand('showui')
    DisableIdleCamera(false)
    -- TriggerScreenblurFadeOut(5.0)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SetFrontendActive(false) -- Close the frontend menu
    SendNUIMessage({
        type = "gmtTogglePauseMenu",
        toggle = false
    })
    isPauseMenuOpen = false
end

Citizen.CreateThread(function()
    while true do
        Wait(1500) -- 1.5 seconds
        if urlIsOpen then
           urlIsOpen = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 
        if IsControlJustReleased(0, 199) then

            if isPauseMenuOpen then
                gmtClosePauseMenu()
            elseif not tGMT.isInComa() then
                gmtShowPauseMenu()
            end
        end
    end
end)

RegisterNetEvent('GMT:callOpenPReport')
AddEventHandler('GMT:callOpenPReport', function(data)
    tGMT.OpenUrl(data)
end)

RegisterNetEvent('gmtHidePauseMenu')
AddEventHandler('gmtHidePauseMenu', function()
	gmtClosePauseMenu()
end)

RegisterNetEvent('gmtShowPauseMenu')
AddEventHandler('gmtShowPauseMenu', function()
	gmtShowPauseMenu()
end)
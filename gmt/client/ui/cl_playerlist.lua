local a = false

local sortedPlayersStaff = {}
local sortedPlayersPolice = {}
local sortedPlayersNHS = {}
local sortedPlayersLFB = {}
local sortedPlayersHMP = {}
local sortedPlayersAA = {}
local sortedPlayersUKBF = {}
local sortedPlayersCivillians = {}

function func_playerlistControl()
    if IsUsingKeyboard(2) then
        if IsControlJustPressed(0, 212) then
            a = not a
            TriggerServerEvent("GMT:getPlayerListData")
            Wait(100)
            sendFullPlayerListData()
            SetNuiFocus(true, true)
           -- TriggerScreenblurFadeIn(100.0)
            SendNUIMessage({showPlayerList = true})
        end
    end
end
GMT.createThreadOnTick(func_playerlistControl)
RegisterNUICallback("closeGMTPlayerList",function(b, c)
    SetNuiFocus(false, false)
    --  TriggerScreenblurFadeOut(100.0)
end)
AddEventHandler("GMT:onClientSpawn",function(d, e)
    if e then
        TriggerServerEvent("GMT:getPlayerListData")
    end
end)
RegisterNetEvent("GMT:gotFullPlayerListData",function(f, g, h, i, j, l0, l1, k)
    sortedPlayersStaff = f
    sortedPlayersPolice = g
    sortedPlayersNHS = h
    sortedPlayersLFB = i
    sortedPlayersHMP = j
    sortedPlayersAA = l0
    sortedPlayersUKBF = l1
    sortedPlayersCivillians = k
end)
local l, m, n
RegisterNetEvent("GMT:playerListMetaUpdate",function(o)
    l, m, n = table.unpack(o)
    SendNUIMessage({wipeFooterPlayerList = true})
    SendNUIMessage({appendToFooterPlayerList = '<span class="foot">Server #1 | </span>'})
    SendNUIMessage({appendToFooterPlayerList = '<span class="foot" style="color: rgb(0, 255, 20);">Server uptime ' ..tostring(l) .. "</span>"})
    SendNUIMessage({appendToFooterPlayerList = '<span class="foot">  |  Number of players ' ..tostring(m) .. "/" .. tostring(n) .. "</span>"})
end)
function getLength(p)
    local q = 0
    for r in pairs(p) do
        q = q + 1
    end
    return q
end

function GMT.getEmploymentStatus(playerId)
    local playerId = playerId or GMT.getUserId()
    local ranks = {
        Police = sortedPlayersPolice[playerId] and sortedPlayersPolice[playerId].rank or "Unemployed",
        NHS = sortedPlayersNHS[playerId] and sortedPlayersNHS[playerId].rank or "Unemployed",
        LFB = sortedPlayersLFB[playerId] and sortedPlayersLFB[playerId].rank or "Unemployed",
        HMP = sortedPlayersHMP[playerId] and sortedPlayersHMP[playerId].rank or "Unemployed",
        AA = sortedPlayersAA[playerId] and sortedPlayersAA[playerId].rank or "Unemployed",
        UKBF = sortedPlayersUKBF[playerId] and sortedPlayersUKBF[playerId].rank or "Unemployed",
        Civillians = sortedPlayersCivillians[playerId] and sortedPlayersCivillians[playerId].rank or "Unemployed",
        Staff = sortedPlayersStaff[playerId] and sortedPlayersStaff[playerId].rank or "Unemployed"

    }

    for _, rank in pairs(ranks) do
        if rank ~= "Unemployed" then
            return rank
        end
    end

    return "Unemployed"
end

function sendFullPlayerListData()
    local s = getLength(sortedPlayersStaff)
    local t = getLength(sortedPlayersPolice)
    local u = getLength(sortedPlayersNHS)
    local v = getLength(sortedPlayersLFB)
    local w = getLength(sortedPlayersHMP)
    local z0 = getLength(sortedPlayersAA)
    local z1 = getLength(sortedPlayersUKBF)
    local x = getLength(sortedPlayersCivillians)
    SendNUIMessage({wipePlayerList = true})
    SendNUIMessage({clearServerMetaData = true})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/gmt.png" align="top" width="26px",height="26px"><span class="staff">' .. tostring(s) .. "</span>"})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/nhs.png" align="top" width="23",height="23"><span class="nhs">' .. tostring(u) .. "</span>"})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/lfb.png" align="top" width="20",height="20"><span class="lfb">' .. tostring(v) .. "</span>"})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/met.png" align="top"  width="27",height="27"><span class="police">' .. tostring(t) .. "</span>"})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/hmp.png" align="top"  width="24",height="24"><span class="hmp">' .. tostring(w) .. "</span>"})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/aa.png" align="top" width="24",height="24"><span class="aa">' .. tostring(z0) .. "</span>"})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/ukbf.png" align="top" width="24",height="24"><span class="ukbf">' .. tostring(z1) .. "</span>"})
    SendNUIMessage({setServerMetaData = '<img src="playerlist_images/danny.png" align="top" width="24",height="24"><span class="Civilians">' .. tostring(x) .. "</span>"})
    SendNUIMessage({wipeFooterPlayerList = true})
    SendNUIMessage({appendToFooterPlayerList = '<span class="foot">Server #1 | </span>'})
    SendNUIMessage({appendToFooterPlayerList = '<span class="foot" style="color: rgb(0, 255, 20);">Server uptime ' .. tostring(l) .. "</span>"})
    SendNUIMessage({appendToFooterPlayerList = '<span class="foot">  |  Number of players ' .. tostring(m) .. "/" .. tostring(n) .. "</span>"})
    if s >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_staff">Staff</span>'})
    end
    for y, z in pairs(sortedPlayersStaff) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersStaff[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersStaff[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersStaff[y].hours)) .. " hrs</span><br/>"})
    end
    if t >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_police">MET Police</span>'})
    end
    for y, z in pairs(sortedPlayersPolice) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersPolice[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersPolice[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersPolice[y].hours)) .. " hrs</span><br/>"})
    end
    if u >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_nhs">NHS</span>'})
    end
    for y, z in pairs(sortedPlayersNHS) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersNHS[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersNHS[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersNHS[y].hours)) .. " hrs</span><br/>"})
    end
    if v >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_lfb">LFB</span>'})
    end
    for y, z in pairs(sortedPlayersLFB) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersLFB[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersLFB[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersLFB[y].hours)) .. " hrs</span><br/>"})
    end
    if w >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_hmp">HMP</span>'})
    end
    for y, z in pairs(sortedPlayersHMP) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersHMP[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersHMP[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersHMP[y].hours)) .. " hrs</span><br/>"})
    end
    if z0 >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_aa">AA</span>'})
    end
    for y, z in pairs(sortedPlayersAA) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersAA[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersAA[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersAA[y].hours)) .. " hrs</span><br/>"})
    end
    if z1 >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_ukbf">UKBF</span>'})
    end
    for y, z in pairs(sortedPlayersUKBF) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersUKBF[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersUKBF[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersUKBF[y].hours)) .. " hrs</span><br/>"})
    end
    if x >= 1 then
        SendNUIMessage({appendToContentPlayerList = '<span id="playerlist_seperator_civs">Civilians</span>'})
    end
    for y, z in pairs(sortedPlayersCivillians) do
        SendNUIMessage({appendToContentPlayerList = '<span class="username">' .. tostring(sortedPlayersCivillians[y].name) .. '</span><span class="job">' .. tostring(sortedPlayersCivillians[y].rank) .. '</span><span class="playtime">' .. tostring(getMoneyStringFormatted(sortedPlayersCivillians[y].hours)) .. " hrs</span><br/>"})
    end
end

local hourz = {}

RegisterNetEvent('GMT:gotPlayerHours')
AddEventHandler('GMT:gotPlayerHours', function(userId, hours)
    hourz[userId] = hours
end)

function GMT.getPlayerHours(userId)
    return hourz[userId] or 0
end

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if l and m and n then
            local A = GMT.getUserId()
            local userHours = hourz[A] or 0
                SetDiscordAppId(1264305385184165930)
                SetDiscordRichPresenceAsset('gmt')
                SetDiscordRichPresenceAssetText('discord.gg/gmtrp')
                SetDiscordRichPresenceAssetSmallText(GMT.getPlayerName(GetPlayerServerId(PlayerId())))
                SetDiscordRichPresenceAssetSmall(GMT.getUserProfilePFP())
                SetDiscordRichPresenceAction(1, "Join GMT", "https://discord.gg/gmtrp")
                SetRichPresence("[ID:" .. tostring(A) .. "] | " .. tostring(m) .. "/" .. tostring(n) .. "\n" .. GMT.getPlayerName(GetPlayerServerId(PlayerId())) .. " | " .. tostring(getMoneyStringFormatted(userHours)) ..  " Hours" .. " | " .. GMT.getEmploymentStatus())
                end    

    end
end)

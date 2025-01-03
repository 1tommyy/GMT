local a = 0
local b = 0
local c = 0
local d = 3
proximityIdToString = {[1] = "Whisper", [2] = "Talking", [3] = "Shouting"}
local e, f = GetActiveScreenResolution()
local g = {}
local h = GetResourceKvpString("gmt_custom_pfp") or ""
g["Custom"] = h
RegisterNetEvent("GMT:showHUD")
AddEventHandler(
    "GMT:showHUD",
    function(i)
        showhudUI(i)
    end
)
AddEventHandler(
    "pma-voice:setTalkingMode",
    function(j)
        d = j
        local k = tGMT.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
function updateMoneyUI(l, m, n, o, k, p)
    SendNUIMessage(
        {
            updateMoney = true,
            cash = l,
            bank = m,
            redmoney = n,
            proximity = proximityIdToString[o],
            topLeftAnchor = k,
            yAnchor = p
        }
    )
end
function showhudUI(i)
    SendNUIMessage({showMoney = i})
end
RegisterNetEvent("GMT:setProfilePictures")
AddEventHandler(
    "GMT:setProfilePictures",
    function(q)
        g = q
    end
)
RegisterNetEvent("GMT:setDisplayMoney")
RegisterNetEvent(
    "GMT:setDisplayMoney",
    function(r)
        local s = tostring(math.floor(r))
        a = getMoneyStringFormatted(s)
        local k = tGMT.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
RegisterNetEvent("GMT:setDisplayBankMoney")
AddEventHandler(
    "GMT:setDisplayBankMoney",
    function(r)
        local s = tostring(math.floor(r))
        b = getMoneyStringFormatted(s)
        local k = tGMT.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
RegisterNetEvent("GMT:setDisplayRedMoney")
AddEventHandler(
    "GMT:setDisplayRedMoney",
    function(r)
        local s = tostring(math.floor(r))
        c = getMoneyStringFormatted(s)
        local k = tGMT.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
RegisterNetEvent("GMT:initMoney")
AddEventHandler(
    "GMT:initMoney",
    function(l, m)
        local t = tostring(math.floor(l))
        a = getMoneyStringFormatted(t)
        local s = tostring(math.floor(m))
        b = getMoneyStringFormatted(s)
        local k = tGMT.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
Citizen.CreateThread(
    function()
        Wait(4000)
        while GMT.getUserId() == nil do
            Wait(100)
        end
        TriggerServerEvent("GMT:requestPlayerBankBalance")
        TriggerServerEvent("GMT:SetDiscordName")
        local u = false
        while true do
            local v, w = GetActiveScreenResolution()
            if v ~= e or w ~= f then
                e, f = GetActiveScreenResolution()
                cachedMinimapAnchor = GetMinimapAnchor()
                updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, cachedMinimapAnchor.rightX * cachedMinimapAnchor.resX)
            end
            if NetworkIsPlayerTalking(PlayerId()) then
                if not u then
                    u = true
                    SendNUIMessage({moneyTalking = true})
                end
            else
                if u then
                    u = false
                    SendNUIMessage({moneyTalking = false})
                end
            end
            Wait(0)
        end
    end
)
RegisterNUICallback(
    "moneyUILoaded",
    function(data, cb)
        local k = tGMT.getCachedMinimapAnchor()
        updateMoneyUI("£" .. tostring(a), "£" .. tostring(b), "£" .. tostring(c), d, k.rightX * k.resX)

        -- Trigger server event to get user ID
        TriggerServerEvent('requestUserId')
    end
)


RegisterNetEvent('receiveUserId')
AddEventHandler('receiveUserId', function(userId)
    SendNUIMessage({
        action = "displayUserId",
        userId = userId
    })
end)

-- Request user ID from the server
TriggerServerEvent('requestUserId')


local pfp = nil
function tGMT.updatePFPType(z)
    pfp = z
    if z == "Custom" then
        SendNUIMessage({setPFP = GetResourceKvpString("gmt_custom_pfp")})
    else
        SendNUIMessage({setPFP = g[z]})
    end
end
function tGMT.updatePFPSize(A)
    SendNUIMessage({setPFPSize = A})
end

function tGMT.GetPFP()
    return pfp == "Custom" and GetResourceKvpString("gmt_custom_pfp") or g[pfp]
end
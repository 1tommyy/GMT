PlayerIsInGang = false
GangBalance = 0
GMTGangInvites = {}
GMTGangInviteIndex = 0
selectedGangInvite = nil
selectedMember = nil
gangID = nil
gangPermission = 0
local a = nil
local b = {}
local c = 1
local d = 1
local e = 1
local f = 1
GMTGangMembers = {}
local g = false
local h = nil
local i = nil
local j = {
    ["White"] = {hud = 0, blip = 0},
    ["Red"] = {hud = 6, blip = 1},
    ["Green"] = {hud = 18, blip = 2},
    ["Blue"] = {hud = 9, blip = 3},
    ["Yellow"] = {hud = 12, blip = 5},
    ["Violet"] = {hud = 21, blip = 7},
    ["Pink"] = {hud = 24, blip = 8},
    ["Orange"] = {hud = 15, blip = 17},
    ["Cyan"] = {hud = 52, blip = 30},
    ["Black"] = {hud = 3, blip = 39},
    ["Baby Pink"] = {hud = 193, blip = 34}
}
local k = j["Red"]
local l = GetResourceKvpString("gmt_gang_colour") or "Red"
local function m()
    return GMTGangMembers
end
AddEventHandler(
    "GMT:onClientSpawn",
    function()
        TriggerEvent("GMT:ForceRefreshData")
        TriggerServerEvent("GMT:GetGangData")
    end
)

RegisterNetEvent("GMT:GotGangData")
AddEventHandler(
    "GMT:GotGangData",
    function(n, o, h, p, q, r, s)
        if n == nil then
            PlayerIsInGang = false
        else
            PlayerIsInGang = true
            TriggerServerEvent("GMT:setPersonalGangBlipColour", l)
            b = {}
            gangLogs = {}
            e = 1
            f = 1
            GangBalance = getMoneyStringFormatted(math.floor(n.money))
            gangID = n.id
            gangPermission = tonumber(h)
            g = q
            gangMaxWithdraw = r
            gangLimitWithdrawDeposit = s
            if o then
                GMTGangMembers = o
                local t = 1
                b[t] = {}
                for n, u in ipairs(o) do
                    if (n - 1) % 10 == 0 and n ~= 1 then
                        t = t + 1
                        b[t] = {}
                        e = e + 1
                    end
                    b[t][n - (t - 1) * 10] = u
                end
            end
            if p then
                local t = 1
                gangLogs[t] = {}
                for i, u in pairs(p) do
                    if i % 11 == 0 then
                        t = t + 1
                        gangLogs[t] = {}
                        f = f + 1
                    else
                        gangLogs[t][i - (t - 1) * 11] = u
                    end
                end
            end
        end
    end
)
RegisterNetEvent("GMT:disbandedGang")
AddEventHandler(
    "GMT:disbandedGang",
    function()
        a = "none"
        PlayerIsInGang = false
        GMTGangMembers = {}
        TriggerEvent("GMT:ForceRefreshData")
    end
)
RegisterNetEvent("GMT:ForceRefreshData")
AddEventHandler(
    "GMT:ForceRefreshData",
    function()
        TriggerServerEvent("GMT:GetGangData")
    end
)
RegisterNetEvent("GMT:InviteReceived")
AddEventHandler(
    "GMT:InviteReceived",
    function(v, w)
        GMTGangInvites[GMTGangInviteIndex] = w
        GMTGangInviteIndex = GMTGangInviteIndex + 1
        GMT.notify(v)
    end
)
RegisterNetEvent("GMT:gangNameNotTaken")
AddEventHandler(
    "GMT:gangNameNotTaken",
    function()
        a = "main"
        PlayerIsInGang = true
    end
)
local onGangFundsButton = false
function GMT.IsOnGangFundsButton()
    return a == "funds" and onGangFundsButton
end

function func_drawGangUI()
    if a == "none" then
        if GMT.isNewPlayer() then
            drawNativeNotification("Press ~INPUT_SELECT_CHARACTER_MICHAEL~ to toggle the Gang Menu.")
        end
        DrawRect(0.471, 0.329, 0.285, -0.005, 0, 168, 255, 204)
        DrawRect(0.471, 0.304, 0.285, 0.046, 0, 0, 0, 150)
        DrawRect(0.471, 0.428, 0.285, 0.194, 0, 0, 0, 150)
        DrawRect(
            0.383,
            0.442,
            0.066,
            0.046,
            CreateGangSelectionRed,
            CreateGangSelectionGreen,
            CreateGangSelectionBlue,
            150
        )
        DrawRect(0.469, 0.442, 0.066, 0.046, JoinGangSelectionRed, JoinGangSelectionGreen, JoinGangSelectionBlue, 150)
        DrawAdvancedText(0.558, 0.303, 0.005, 0.0028, 0.539, "GMT GANGS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.478, 0.442, 0.005, 0.0028, 0.473, "Create Gang", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.564, 0.443, 0.005, 0.0028, 0.473, "Join Gang", 255, 255, 255, 255, 4, 0)
        DrawRect(0.561, 0.377, 0.065, -0.003, 0, 168, 255, 204)
        DrawAdvancedText(0.654, 0.37, 0.005, 0.0028, 0.364, "Invite list", 255, 255, 255, 255, 4, 0)
        for x, y in pairs(GMTGangInvites) do
            DrawAdvancedText(0.656, 0.398 + 0.020 * x, 0.005, 0.0028, 0.234, y, 255, 255, 255, 255, 0, 0)
            if CursorInArea(0.525, 0.59, 0.38 + 0.02 * x, 0.396 + 0.02 * x) and x ~= selectedGangInvite then
                DrawRect(0.56, 0.39 + 0.02 * x, 0.062, 0.019, 0, 168, 255, 150)
                if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                    selectedGangInvite = x
                end
            elseif x == selectedGangInvite then
                DrawRect(0.56, 0.39 + 0.02 * x, 0.062, 0.019, 0, 168, 255, 150)
            end
        end
        if CursorInArea(0.35, 0.415, 0.415, 0.46) then
            CreateGangSelectionRed = 0
            CreateGangSelectionGreen = 168
            CreateGangSelectionBlue = 255
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                createGangName = GetGangNameText()
                if createGangName and createGangName ~= "null" and createGangName ~= "" then
                    TriggerServerEvent("GMT:CreateGang", createGangName)
                else
                    GMT.notify("~r~No gang name entered!")
                end
            end
        else
            CreateGangSelectionRed = 0
            CreateGangSelectionGreen = 0
            CreateGangSelectionBlue = 0
        end
        if CursorInArea(0.435, 0.51, 0.415, 0.46) then
            JoinGangSelectionRed = 0
            JoinGangSelectionGreen = 168
            JoinGangSelectionBlue = 255
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if selectedGangInvite then
                    selectedGangInvite = GMTGangInvites[selectedGangInvite]
                    TriggerServerEvent("GMT:addUserToGang", selectedGangInvite)
                    GMTGangInvites = {}
                    a = "main"
                    GMTGangInviteIndex = 0
                    PlayerIsInGang = true
                else
                    GMT.notify("~r~No gang invite selected")
                end
            end
        else
            JoinGangSelectionRed = 0
            JoinGangSelectionGreen = 0
            JoinGangSelectionBlue = 0
        end
    end
    if a == "funds" then
        DrawRect(0.501, 0.558, 0.421, 0.326, 0, 0, 0, 150)
        DrawRect(0.501, 0.374, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.378, 0.005, 0.0028, 0.48, "GMT GANGS - FUNDS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.591, 0.464, 0.005, 0.0028, 0.5, "GANG FUNDS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.591, 0.502, 0.005, 0.0028, 0.4, "£" .. GangBalance, 25, 199, 65, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.436, 0.578, 0.005, 0.0028, 0.4, "Deposit (1% Fee)", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.536, 0.578, 0.005, 0.0028, 0.4, "Deposit All (1% Fee)", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.637, 0.578, 0.005, 0.0028, 0.4, "Withdraw", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.737, 0.578, 0.005, 0.0028, 0.4, "Withdraw All", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        local OnButton = false
        if CursorInArea(0.3083, 0.3718, 0.5490, 0.5999) then
            OnButton = true
            DrawRect(0.341, 0.576, 0.075, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                amount = GetMoneyAmountText()
                if amount then
                    TriggerServerEvent("GMT:depositGangBalance", gangID, amount)
                else
                    GMT.notify("~r~No amount entered!")
                end
            end
        else
            DrawRect(0.341, 0.576, 0.075, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.4083, 0.4718, 0.5490, 0.5999) then
            OnButton = true
            DrawRect(0.441, 0.576, 0.075, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                TriggerServerEvent("GMT:depositAllGangBalance", gangID)
            end
        else
            DrawRect(0.441, 0.576, 0.075, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.5088, 0.5739, 0.5481, 0.6018) then
            OnButton = true
            DrawRect(0.542, 0.576, 0.075, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                amount = GetMoneyAmountText()
                if amount then
                    if gangPermission >= 3 then
                        TriggerServerEvent("GMT:withdrawGangBalance", amount)
                    else
                        GMT.notify("~r~You don't have a high enough rank to withdraw")
                    end
                else
                    GMT.notify("~r~No amount entered!")
                end
            end
        else
            DrawRect(0.542, 0.576, 0.075, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.6088, 0.6739, 0.5481, 0.6018) then
            OnButton = true
            DrawRect(0.642, 0.576, 0.075, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if gangPermission >= 3 then
                    TriggerServerEvent("GMT:withdrawAllGangBalance")
                else
                    GMT.notify("~r~You don't have a high enough rank to withdraw")
                end
            end
        else
            DrawRect(0.642, 0.576, 0.075, 0.056, 0, 0, 0, 150)
        end
        if OnButton then
            onGangFundsButton = true
        else
            onGangFundsButton = false
        end
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "main"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "contributions" then
        DrawRect(0.501, 0.525, 0.421, 0.387, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - CONTRIBUTIONS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawRect(0.502, 0.518, 0.387, 0.283, 0, 0, 0, 150)
        DrawAdvancedText(0.449, 0.365, 0.005, 0.0028, 0.4, "Name", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.53, 0.365, 0.005, 0.0028, 0.4, "UserID", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.63, 0.365, 0.005, 0.0028, 0.4, "Last Contribution", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.730, 0.365, 0.005, 0.0028, 0.4, "Total Amount", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.547, 0.688, 0.005, 0.0028, 0.4, "Previous", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.639, 0.688, 0.005, 0.0028, 0.4, "Next", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.591, 0.688, 0.005, 0.0028, 0.4, tostring(c) .. "/" .. tostring(e), 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        for x, z in pairs(b[c]) do
            name, id = table.unpack(z)
            DrawAdvancedText(0.449, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, name, 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(0.53, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, id, 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(
                0.63,
                0.361 + 0.0287 * x,
                0.005,
                0.0028,
                0.4,
                z.contributions.date,
                255,
                255,
                255,
                255,
                6,
                0
            )
            DrawAdvancedText(
                0.730,
                0.361 + 0.0287 * x,
                0.005,
                0.0028,
                0.4,
                z.contributions.amount,
                255,
                255,
                255,
                255,
                6,
                0
            )
        end
        if CursorInArea(0.419271, 0.482813, 0.667593, 0.699074) then
            DrawRect(0.452, 0.686, 0.065, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if c <= 1 then
                    GMT.notify("~r~Lowest page reached")
                else
                    c = c - 1
                end
            end
        else
            DrawRect(0.452, 0.686, 0.065, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.512500, 0.575521, 0.667593, 0.699074) then
            DrawRect(0.545, 0.686, 0.065, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if c >= e then
                    GMT.notify("~r~Max page reached")
                else
                    c = c + 1
                end
            end
        else
            DrawRect(0.545, 0.686, 0.065, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "funds"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "members" then
        DrawRect(0.501, 0.525, 0.421, 0.387, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - MEMBERS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawRect(0.460, 0.52, 0.310, 0.291, 0, 0, 0, 150)
        DrawAdvancedText(0.429, 0.359, 0.005, 0.0028, 0.4, "Name", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.486, 0.359, 0.005, 0.0028, 0.4, "ID", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.535, 0.359, 0.005, 0.0028, 0.4, "Rank", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.605, 0.359, 0.005, 0.0028, 0.4, "Last Seen", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.665, 0.359, 0.005, 0.0028, 0.4, "Playtime", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.700, 0.359, 0.005, 0.0028, 0.4, "Pin", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.746, 0.39, 0.005, 0.0028, 0.4, "Promote", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.746, 0.465, 0.005, 0.0028, 0.4, "Demote", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.746, 0.54, 0.005, 0.0028, 0.4, "Kick", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.746, 0.615, 0.005, 0.0028, 0.4, "Invite", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.491, 0.695, 0.005, 0.0028, 0.4, "Previous", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.581, 0.695, 0.005, 0.0028, 0.4, "Next", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.536, 0.695, 0.005, 0.0028, 0.4, tostring(c) .. "/" .. tostring(e), 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        for x, z in pairs(b[c]) do
            name, id, rank, lastseen, playtime = table.unpack(z)
            rank = tostring(rank)
            if rank == nil or rank == "nil" or rank == "NULL" then
                rank = "1"
            elseif rank <= "1" then
                rank = "Recruit"
            elseif rank == "2" then
                rank = "Member"
            elseif rank == "3" then
                rank = "Senior"
            elseif rank >= "4" then
                rank = "Leader"
            end
            DrawAdvancedText(0.429, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, name, 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(0.486, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, id, 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(0.535, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, rank, 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(0.605, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, lastseen, 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(0.665, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4,getMoneyStringFormatted(playtime) .. " hours",255,255,255,255,6,0)
            local A = h.pinnedPlayers[id] and "📌" or "⭕"
            DrawAdvancedText(0.700, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.3, A, 255, 255, 255, 255, 6, 0)
            if
                CursorInArea(0.3005, 0.5955, 0.3731 + 0.0287 * (x - 1), 0.4018 + 0.0287 * (x - 1)) and
                    selectedMember ~= id
             then
                DrawRect(0.460, 0.388 + 0.0287 * (x - 1), 0.310, 0.027, h.theme.r, h.theme.g, h.theme.b, 150)
                if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                    selectedMember = id
                end
            elseif selectedMember == id then
                DrawRect(0.460, 0.388 + 0.0287 * (x - 1), 0.310, 0.027, h.theme.r, h.theme.g, h.theme.b, 150)
            end
            if CursorInArea(0.597, 0.610, 0.3731 + 0.0287 * (x - 1), 0.4018 + 0.0287 * (x - 1)) then
                if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                    if h.pinnedPlayers[id] then
                        h.pinnedPlayers[id] = nil
                    else
                        h.pinnedPlayers[id] = true
                    end
                    SetResourceKvp("gmt_gang_pinned", json.encode(h.pinnedPlayers))
                end
            end
        end
        if CursorInArea(0.6182, 0.6822, 0.360, 0.416) then
            DrawRect(0.651, 0.388, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if selectedMember and PlayerIsInGang and gangID then
                    if gangPermission >= 4 then
                        TriggerServerEvent("GMT:PromoteUser", gangID, tonumber(selectedMember))
                    else
                        GMT.notify("~r~You don't have permission to promote!")
                    end
                else
                    GMT.notify("~r~No gang member selected")
                end
            end
        else
            DrawRect(0.651, 0.388, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.6182, 0.6822, 0.435, 0.491) then
            DrawRect(0.651, 0.463, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if selectedMember and PlayerIsInGang and gangID then
                    if gangPermission >= 4 then
                        if selectedMember == GMT.getUserId() then
                            GMT.notify("~r~You can't demote yourself.")
                        else
                            TriggerServerEvent("GMT:DemoteUser", gangID, selectedMember)
                        end
                    else
                        GMT.notify("~r~You don't have permission to demote!")
                    end
                else
                    GMT.notify("~r~No gang member selected")
                end
            end
        else
            DrawRect(0.651, 0.463, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.6182, 0.6822, 0.510, 0.566) then
            DrawRect(0.651, 0.538, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if selectedMember then
                    if gangPermission >= 3 then
                        if YesNoConfirm() then
                            TriggerServerEvent("GMT:KickUser", gangID, selectedMember)
                        end
                    else
                        GMT.notify("~r~You don't have permission to kick!")
                    end
                else
                    GMT.notify("~r~No gang member selected")
                end
            end
        else
            DrawRect(0.651, 0.538, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.6182, 0.6822, 0.585, 0.641) then
            DrawRect(0.651, 0.613, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                local B = GetPlayerPermID()
                if B then
                    if gangPermission >= 2 then
                        TriggerServerEvent("GMT:InviteUser", gangID, B)
                    else
                        GMT.notify("~r~You don't have permission to invite players")
                    end
                else
                    GMT.notify("No player name entered")
                end
            end
        else
            DrawRect(0.651, 0.613, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.3735, 0.4185, 0.6768, 0.7074) then
            DrawRect(0.396, 0.693, 0.045, 0.033, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if c <= 1 then
                    GMT.notify("~r~Lowest page reached")
                else
                    c = c - 1
                end
            end
        else
            DrawRect(0.396, 0.693, 0.045, 0.033, 0, 0, 0, 150)
        end
        if CursorInArea(0.4635, 0.5085, 0.6712, 0.7064) then
            DrawRect(0.486, 0.693, 0.045, 0.033, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if c >= e then
                    GMT.notify("~r~Max page reached")
                else
                    c = c + 1
                end
            end
        else
            DrawRect(0.486, 0.693, 0.045, 0.033, 0, 0, 0, 150)
        end
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "main"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "logs" then
        DrawRect(0.501, 0.525, 0.421, 0.387, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - LOGS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawRect(0.502, 0.518, 0.387, 0.283, 0, 0, 0, 150)
        DrawAdvancedText(0.449, 0.365, 0.005, 0.0028, 0.4, "Name", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.51, 0.365, 0.005, 0.0028, 0.4, "UserID", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.583, 0.365, 0.005, 0.0028, 0.4, "Date", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.460, 0.688, 0.005, 0.0028, 0.4, "Set Webhook", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.547, 0.688, 0.005, 0.0028, 0.4, "Previous", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.639, 0.688, 0.005, 0.0028, 0.4, "Next", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.591, 0.688, 0.005, 0.0028, 0.4, tostring(d) .. "/" .. tostring(f), 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.673, 0.365, 0.005, 0.0028, 0.4, "Action", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.757, 0.365, 0.005, 0.0028, 0.4, "Value", 255, 255, 255, 255, 4, 0)
        if gangLogs[d] then
            for x, z in pairs(gangLogs[d]) do
                name, id, date, action, value = table.unpack(z)
                DrawAdvancedText(0.449, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, name, 255, 255, 255, 255, 6, 0)
                DrawAdvancedText(0.51, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, id, 255, 255, 255, 255, 6, 0)
                DrawAdvancedText(0.583, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, date, 255, 255, 255, 255, 6, 0)
                DrawAdvancedText(0.673, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, action, 255, 255, 255, 255, 6, 0)
                DrawAdvancedText(0.757, 0.361 + 0.0287 * x, 0.005, 0.0028, 0.4, value, 255, 255, 255, 255, 6, 0)
            end
        end
        if CursorInArea(0.33, 0.395, 0.667593, 0.699074) then
            DrawRect(0.365, 0.686, 0.065, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                TriggerServerEvent("GMT:SetGangWebhook", gangID)
            end
        else
            DrawRect(0.365, 0.686, 0.065, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.419271, 0.482813, 0.667593, 0.699074) then
            DrawRect(0.452, 0.686, 0.065, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if d <= 1 then
                    GMT.notify("~r~Lowest page reached")
                else
                    d = d - 1
                end
            end
        else
            DrawRect(0.452, 0.686, 0.065, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.512500, 0.575521, 0.667593, 0.699074) then
            DrawRect(0.545, 0.686, 0.065, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if d >= f then
                    GMT.notify("~r~Max page reached.")
                else
                    d = d + 1
                end
            end
        else
            DrawRect(0.545, 0.686, 0.065, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "main"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "guide" then
        DrawRect(0.501, 0.525, 0.421, 0.387, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - PERMISSIONS GUIDE", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.6, 0.363, 0.005, 0.0028, 0.46, "A recruit can deposit to the gang funds only.", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.6, 0.391, 0.005, 0.0028, 0.46, "A Member can invite users and deposit to the gang funds only.", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.6, 0.416, 0.005, 0.0028, 0.46, "A senior can invite and kick members and withdraw from the gang funds and also set log webhooks.", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.6, 0.440, 0.005, 0.0028, 0.46, "A leader can promote and demote members and also set log webhooks.", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                Wait(100)
                a = "settings"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "settings" then
        DrawRect(0.501, 0.525, 0.421, 0.387, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - SETTINGS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.7, 0.360, 0.005, 0.0028, 0.46, "Current Gang: " .. gangID, 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.7, 0.398, 0.005, 0.0028, 0.46, "Permissions Guide", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(0.7, 0.439, 0.005, 0.0028, 0.4,"Read Guide", 255, 255, 255, 255, 6, 0)
        if CursorInArea(0.5671, 0.6416, 0.4194, 0.4509) then
            DrawRect(0.605, 0.437, 0.075, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "guide"
            end
        else
            DrawRect(0.605, 0.437, 0.075, 0.036, 0, 0, 0, 150)
        end
        local C = h.blips and "Disable" or "Enable"
        DrawAdvancedText(0.451, 0.416, 0.005, 0.0028, 0.4, C .. " Blips", 255, 255, 255, 255, 6, 0)
        if CursorInArea(0.3187, 0.3937, 0.3712, 0.4462) then
            DrawRect(0.357, 0.41, 0.075, 0.076, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                h.blips = not h.blips
                SetResourceKvp("gmt_gang_blips", tostring(h.blips))
            end
        else
            DrawRect(0.357, 0.41, 0.075, 0.076, 0, 0, 0, 150)
        end
        local D = h.pings and "Disable" or "Enable"
        DrawAdvancedText(0.554, 0.415, 0.005, 0.0028, 0.4, D .. " Pings", 255, 255, 255, 255, 4, 0)
        if CursorInArea(0.4197, 0.4932, 0.3712, 0.4462) then
            DrawRect(0.457, 0.41, 0.075, 0.076, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                h.pings = not h.pings
                SetResourceKvp("gmt_gang_pings", tostring(h.pings))
            end
        else
            DrawRect(0.457, 0.41, 0.075, 0.076, 0, 0, 0, 150)
        end
        local E = h.names and "Disable" or "Enable"
        DrawAdvancedText(0.451, 0.516, 0.005, 0.0028, 0.4, E .. " Names", 255, 255, 255, 255, 6, 0)
        if CursorInArea(0.3187, 0.3937, 0.4712, 0.5462) then
            DrawRect(0.357, 0.51, 0.075, 0.076, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                h.names = not h.names
                SetResourceKvp("gmt_gang_turf_alerts", tostring(h.names))
            end
        else
            DrawRect(0.357, 0.51, 0.075, 0.076, 0, 0, 0, 150)
        end
        DrawAdvancedText(0.554, 0.515, 0.005, 0.0028, 0.4, "Rename Gang", 255, 255, 255, 255, 4, 0)
        if CursorInArea(0.4197, 0.4932, 0.4712, 0.5462) then
            DrawRect(0.457, 0.51, 0.075, 0.076, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                newGangName = GetGangNameText()
                if newGangName and newGangName ~= "null" and newGangName ~= "" and gangID then
                    TriggerServerEvent("GMT:RenameGang", gangID, newGangName)
                    -- GMT.notify("~r~Contact a dev!")
                else
                    GMT.notify("~r~No gang name entered!")
                end
            end
        else
            DrawRect(0.457, 0.51, 0.075, 0.076, 0, 0, 0, 150)
        end
        DrawAdvancedText(0.451, 0.616, 0.005, 0.0028, 0.4, "Leave Gang", 255, 255, 255, 255, 6, 0)
        if CursorInArea(0.3187, 0.3937, 0.5712, 0.6462) then
            DrawRect(0.357, 0.61, 0.075, 0.076, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if YesNoConfirm() then
                    TriggerServerEvent("GMT:LeaveGang", gangID)
                    setCursor(0)
                    SetPlayerControl(PlayerId(), 1, 0)
                end
            end
        else
            DrawRect(0.357, 0.61, 0.075, 0.076, 0, 0, 0, 150)
        end
        DrawAdvancedText(0.554, 0.615, 0.005, 0.0028, 0.4, "Disband Gang", 255, 255, 255, 255, 6, 0)
        if CursorInArea(0.4197, 0.4932, 0.5712, 0.6462) then
            DrawRect(0.457, 0.61, 0.075, 0.076, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if gangPermission >= 4 then
                    if YesNoConfirm() == true and gangID then
                        TriggerServerEvent("GMT:DeleteGang", gangID)
                    end
                else
                    GMT.notify("~r~You don't have permission to disband!")
                end
            end
        else
            DrawRect(0.457, 0.61, 0.075, 0.076, 0, 0, 0, 150)
        end
        DrawAdvancedText(
            0.451,
            0.693,
            0.005,
            0.0028,
            0.4,
            h.healthui and "Disable Health UI" or "Enable Health UI",
            255,
            255,
            255,
            255,
            4,
            0
        )
        if CursorInArea(0.31, 0.39, 0.6712, 0.7064) then
            DrawRect(0.357, 0.689, 0.075, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                h.healthui = not h.healthui
                SetResourceKvp("gmt_gang_healthui", tostring(h.healthui))
            end
        else
            DrawRect(0.357, 0.689, 0.075, 0.036, 0, 0, 0, 150)
        end
        DrawAdvancedText(0.551, 0.693, 0.005, 0.0028, 0.4, "Set Gang Fit", 255, 255, 255, 255, 4, 0)
        if CursorInArea(0.41, 0.49, 0.6712, 0.7064) then
            DrawRect(0.457, 0.689, 0.075, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if gangPermission >= 4 then
                    TriggerServerEvent("GMT:setGangFit", gangID)
                else
                    GMT.notify("~r~You don't have permission to set gang fit!")
                end
            end
        else
            DrawRect(0.457, 0.689, 0.075, 0.036, 0, 0, 0, 150)
        end
        local F, G, H = GetHudColour(j[l].hud)
        DrawAdvancedText(0.645, 0.63, 0.005, 0.0028, 0.46, "Your Blip Colour: ", 255, 255, 255, 255, 6, 0)
        DrawRect(0.62, 0.628, 0.05, 0.025, F, G, H, 255)
        if CursorInArea(0.595, 0.645, 0.6155, 0.6405) then
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                local I = false
                local J = false
                for K in pairs(j) do
                    if K == l then
                        I = true
                    elseif I then
                        l = K
                        J = true
                        break
                    end
                end
                if not J then
                    for K in pairs(j) do
                        l = K
                        break
                    end
                end
                SetResourceKvp("gmt_gang_colour", l)
                TriggerServerEvent("GMT:setPersonalGangBlipColour", l)
            end
        end
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "main"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "turfs" then
        DrawRect(0.501, 0.533, 0.421, 0.497, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - TURFS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.5, 0.353, 0.005, 0.0028, 0.325, "Turf profits updated every 15 minutes", 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.399, 0.38, 0.005, 0.0028, 0.4, "Weed - (Owned by " .. turfData[1].gangOwner .. ") Commission - " .. globalWeedCommissionPercent .. "% | Profit ~g~£" .. getMoneyStringFormatted(turfData[1].profit), 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.399, 0.44, 0.005, 0.0028, 0.4, "Cocaine - (Owned by " .. turfData[2].gangOwner .. ") Commission - " .. globalCocaineCommissionPercent .. "% | Profit ~g~£" .. getMoneyStringFormatted(turfData[2].profit), 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.399, 0.50, 0.005, 0.0028, 0.4, "Meth - (Owned by " .. turfData[3].gangOwner .. ") Commission - " .. globalMethCommissionPercent .. "% | Profit ~g~£" .. getMoneyStringFormatted(turfData[3].profit), 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.399, 0.56, 0.005, 0.0028, 0.4, "Heroin - (Owned by " .. turfData[4].gangOwner .. ") Commission - " .. globalHeroinCommissionPercent .. "% | Profit ~g~£" .. getMoneyStringFormatted(turfData[4].profit), 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.399, 0.62, 0.005, 0.0028, 0.4, "Large Arms - (Owned by " .. turfData[5].gangOwner .. ") Commission - " .. globalLargeArmsCommission .. "% | Profit ~g~£" .. getMoneyStringFormatted(turfData[5].profit), 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.399, 0.68, 0.005, 0.0028, 0.4, "LSD North - (Owned by " .. turfData[6].gangOwner .. ") Commission - " .. globalLSDNorthCommissionPercent .. "% | Profit ~g~£" .. getMoneyStringFormatted(turfData[6].profit), 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.399, 0.74, 0.005, 0.0028, 0.4, "LSD South - (Owned by " .. turfData[7].gangOwner .. ") Commission - " .. globalLSDSouthCommissionPercent .. "% | Profit ~g~£" .. getMoneyStringFormatted(turfData[7].profit), 255, 255, 255, 255, 0, 1)
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "main"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "security" then
        DrawRect(0.501, 0.525, 0.421, 0.387, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - SECURITY", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.4, 0.575, 0.005, 0.0028, 0.46, "Lock gang funds:", 255, 255, 255, 255, 6, 1)
        DrawAdvancedText(
            0.4,
            0.605,
            0.005,
            0.0028,
            0.4,
            "Prevents any member from withdrawing funds from the gang.",
            255,
            255,
            255,
            255,
            6,
            1
        )
        DrawRect(0.525, 0.575, 0.1, 0.03, 0, 0, 0, 175)
        DrawAdvancedText(0.575, 0.575, 0.005, 0.0028, 0.46, g and "Yes" or "No", 255, 255, 255, 255, 6, 1)
        if CursorInArea(0.31, 0.65, 0.56, 0.61) then
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                if gangPermission >= 4 then
                    TriggerServerEvent("GMT:LockGangFunds", gangID)
                else
                    notify("~r~You must be a leader to change security.")
                end
            end
        end
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "main"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "theme" then
        DrawRect(0.501, 0.525, 0.421, 0.387, 0, 0, 0, 150)
        DrawRect(0.501, 0.308, 0.421, 0.047, h.theme.r, h.theme.g, h.theme.b, 248)
        DrawAdvancedText(0.591, 0.312, 0.005, 0.0028, 0.48, "GMT GANGS - THEME", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(
            0.7,
            0.360,
            0.005,
            0.0028,
            0.46,
            "The theme will be frequent throughout the",
            255,
            255,
            255,
            255,
            6,
            0
        )
        DrawAdvancedText(
            0.7,
            0.396,
            0.005,
            0.0028,
            0.46,
            "gang menu and used as your marker colour.",
            255,
            255,
            255,
            255,
            6,
            0
        )
        DrawAdvancedText(0.490, 0.380, 0.005, 0.0028, 0.48, "Current Theme", 255, 255, 255, 255, 6, 0)
        DrawAdvancedText(
            0.490,
            0.405,
            0.005,
            0.0028,
            0.48,
            "(" .. h.theme.r .. "," .. h.theme.g .. "," .. h.theme.b .. ")",
            255,
            255,
            255,
            255,
            6,
            0
        )
        DrawAdvancedText(0.420, 0.693, 0.005, 0.0028, 0.4, "Blue", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.480, 0.693, 0.005, 0.0028, 0.4, "Pink", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.540, 0.693, 0.005, 0.0028, 0.4, "Green", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.600, 0.693, 0.005, 0.0028, 0.4, "Red", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.660, 0.693, 0.005, 0.0028, 0.4, "Cyan", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.720, 0.693, 0.005, 0.0028, 0.4, "Orange", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.647, 0.447, 0.005, 0.0028, 0.4, "Copy theme", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.647, 0.573, 0.005, 0.0028, 0.4, "Random Colour", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.746, 0.447, 0.005, 0.0028, 0.4, "Reset Colour", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.746, 0.572, 0.005, 0.0028, 0.4, "Custom Colour", 255, 255, 255, 255, 4, 0)
        DrawAdvancedText(0.775, 0.693, 0.005, 0.0028, 0.4, "Back", 255, 255, 255, 255, 4, 0)
        DrawRect(0.395, 0.51, 0.1, 0.13, h.theme.r, h.theme.g, h.theme.b, 248)
        if CursorInArea(0.5187, 0.5828, 0.4138, 0.4694) then
            DrawRect(0.552, 0.443, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                tGMT.CopyToClipBoard(h.theme.r .. "," .. h.theme.g .. "," .. h.theme.b)
                TriggerEvent("GMT:showNotification",
                {
                    text = "Theme Copied To Clipboard.",
                    height = "200px",
                    width = "auto",
                    colour = "#FFF",
                    background = "#32CD32",
                    pos = "bottom-right",
                    icon = "good"
                }, 5000
            )
            end
        else
            DrawRect(0.552, 0.443, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.5187, 0.5828, 0.5407, 0.5962) then
            DrawRect(0.552, 0.569, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(math.random(1, 255), math.random(1, 255), math.random(1, 255))
            end
        else
            DrawRect(0.552, 0.569, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.6182, 0.6822, 0.4138, 0.4694) then
            DrawRect(0.651, 0.443, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(18, 82, 228)
            end
        else
            DrawRect(0.651, 0.443, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.6182, 0.6822, 0.5407, 0.5962) then
            DrawRect(0.651, 0.569, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                tGMT.clientPrompt(
                    "Enter rgb value eg 255,100,150:",
                    "",
                    function(L)
                        if L ~= "" then
                            local M = stringsplit(L, ",")
                            if M[1] and M[2] and M[3] then
                                GMT.gangMenuTheme(tonumber(M[1]), tonumber(M[2]), tonumber(M[3]))
                            else
                                GMT.notify("~r~Invalid value")
                            end
                        else
                            GMT.notify("~r~Invalid value")
                        end
                    end
                )
            end
        else
            DrawRect(0.651, 0.569, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.3033, 0.3506, 0.6712, 0.7064) then
            DrawRect(0.326, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(18, 82, 228)
            end
        else
            DrawRect(0.326, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.3633, 0.4106, 0.6712, 0.7064) then
            DrawRect(0.386, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(255, 0, 255)
            end
        else
            DrawRect(0.386, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.4233, 0.4706, 0.6712, 0.7064) then
            DrawRect(0.446, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(0, 128, 0)
            end
        else
            DrawRect(0.446, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.4833, 0.5306, 0.6712, 0.7064) then
            DrawRect(0.506, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(255, 0, 0)
            end
        else
            DrawRect(0.506, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.5433, 0.5906, 0.6712, 0.7064) then
            DrawRect(0.566, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(0, 100, 100)
            end
        else
            DrawRect(0.566, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.6033, 0.6506, 0.6712, 0.7064) then
            DrawRect(0.626, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                GMT.gangMenuTheme(255, 165, 0)
            end
        else
            DrawRect(0.626, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
        if CursorInArea(0.6583, 0.7056, 0.6712, 0.7064) then
            DrawRect(0.681, 0.689, 0.045, 0.036, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "main"
            end
        else
            DrawRect(0.681, 0.689, 0.045, 0.036, 0, 0, 0, 150)
        end
    end
    if a == "main" then
        if GMT.isNewPlayer() then
            drawNativeNotification("Press ~INPUT_SELECT_CHARACTER_MICHAEL~ to toggle the Gang Menu.")
        end
        DrawRect(0.501, 0.532, 0.375, 0.225, 0, 0, 0, 150)
        DrawRect(0.501, 0.396, 0.375, 0.046, h.theme.r, h.theme.g, h.theme.b, 255)
        DrawAdvancedText(0.595, 0.395, 0.005, 0.0028, 0.51, "GMT GANGS", 255, 255, 255, 255, GMT.getFontId("Akrobat-ExtraBold"), 0)
        DrawAdvancedText(0.46, 0.534, 0.005, 0.0028, 0.4, "funds", 255, 255, 255, 255, 7, 0)
        DrawAdvancedText(0.554, 0.534, 0.005, 0.0028, 0.4, "members", 255, 255, 255, 255, 7, 0)
        DrawAdvancedText(0.642, 0.534, 0.005, 0.0028, 0.4, "logs", 255, 255, 255, 255, 7, 0)
        DrawAdvancedText(0.732, 0.534, 0.005, 0.0028, 0.4, "settings", 255, 255, 255, 255, 7, 0)
        DrawAdvancedText(0.51, 0.604, 0.005, 0.0028, 0.4, "Turfs", 255, 255, 255, 255, 7, 0)
        DrawAdvancedText(0.598, 0.604, 0.005, 0.0028, 0.4, "Security", 255, 255, 255, 255, 7, 0)
        DrawAdvancedText(0.686, 0.604, 0.005, 0.0028, 0.4, "Theme", 255, 255, 255, 255, 7, 0)
        if CursorInArea(0.3333, 0.3973, 0.4981, 0.5537) then
            DrawRect(0.366, 0.527, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "funds"
            end
        else
            DrawRect(0.366, 0.527, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.4244, 0.4903, 0.4981, 0.5537) then
            DrawRect(0.458, 0.527, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "members"
            end
        else
            DrawRect(0.458, 0.527, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.5140, 0.5776, 0.4981, 0.5537) then
            DrawRect(0.546, 0.527, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "logs"
            end
        else
            DrawRect(0.546, 0.527, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.6020, 0.6677, 0.4981, 0.5537) then
            DrawRect(0.635, 0.527, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "settings"
            end
        else
            DrawRect(0.635, 0.527, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.3804, 0.4463, 0.5722, 0.6259) then
            DrawRect(0.414, 0.6, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "turfs"
            end
        else
            DrawRect(0.414, 0.6, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.47, 0.5336, 0.5722, 0.6259) then
            DrawRect(0.502, 0.6, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "security"
            end
        else
            DrawRect(0.502, 0.6, 0.065, 0.056, 0, 0, 0, 150)
        end
        if CursorInArea(0.558, 0.6216, 0.5722, 0.6259) then
            DrawRect(0.59, 0.6, 0.065, 0.056, h.theme.r, h.theme.g, h.theme.b, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                a = "theme"
            end
        else
            DrawRect(0.59, 0.6, 0.065, 0.056, 0, 0, 0, 150)
        end
    end
end
createThreadOnTick(func_drawGangUI)
GMT.createThreadOnTick(b5)
Citizen.CreateThread(
    function()
        local N = json.decode(GetResourceKvpString("gmt_gang_pinned") or "{}") or {}
        h = {
            blips = GetResourceKvpString("gmt_gang_blips") == "true",
            pings = GetResourceKvpString("gmt_gang_pings") == "true",
            names = GetResourceKvpString("gmt_gang_turf_alerts") == "true",
            healthui = GetResourceKvpString("gmt_gang_healthui") == "true",
            pinnedPlayers = {}
        }
        for O in pairs(N) do
            h.pinnedPlayers[tonumber(O)] = true
        end
        h.theme = json.decode(GetResourceKvpString("gmt_gang_theme")) or {r = 18, g = 82, b = 228}
        while true do
            if IsControlJustPressed(0, 166) or IsDisabledControlJustPressed(0, 166) then
                TriggerEvent("GMT:ForceRefreshData")
                if not PlayerIsInGang then
                    if a == "none" then
                        a = nil
                        setCursor(0)
                        inGUIGMT = false
                        selectedGangInvite = nil
                    else
                        a = "none"
                        setCursor(1)
                        inGUIGMT = true
                    end
                end
                if PlayerIsInGang then
                    if a == "main" then
                        a = nil
                        setCursor(0)
                        inGUIGMT = false
                        selectedMember = nil
                    else
                        a = "main"
                        setCursor(1)
                        inGUIGMT = true
                    end
                end
                Wait(100)
            end
            Wait(0)
        end
    end
)
function GetGangNameText()
    AddTextEntry("FMMC_MPM_NA", "Enter Gang Name:")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local L = GetOnscreenKeyboardResult()
        return L
    end
    return nil
end
function GetPlayerPermID()
    AddTextEntry("FMMC_MPM_NA", "Enter exact player permid to invite:")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local L = GetOnscreenKeyboardResult()
        return L
    end
    return nil
end
function YesNoConfirm()
    AddTextEntry("FMMC_MPM_NA", "Are you sure?")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Are you sure?", "Yes | No", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local L = GetOnscreenKeyboardResult()
        if string.upper(L) == "YES" then
            return true
        else
            return false
        end
    end
    return false
end
function GetMoneyAmountText()
    AddTextEntry("FMMC_MPM_NA", "Enter amount:")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Enter amount:", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local L = GetOnscreenKeyboardResult()
        return L
    end
    return nil
end
RegisterNetEvent(
    "GMT:setGangMemberColour",
    function(P, K)
        for h, k in pairs(GMTGangMembers) do
            if k[2] == P then
                GMTGangMembers[h].colour = K
            end
        end
    end
)
function GMT.gangMenuTheme(Q, R, S)
    if Q and R and S then
        h.theme = {r = Q, g = R, b = S}
        SetResourceKvp("gmt_gang_theme", json.encode(h.theme))
    else
        GMT.notify("~r~Invalid value")
    end
end
function GMT.hasGangNamesEnabled()
    local M = m()
    if M and h then
        return h.names
    else
        return nil
    end
end
function GMT.isPlayerInSelectedGang(O)
    local M = m()
    if M then
        local P = GMT.clientGetUserIdFromSource(O)
        if P and GMT.getJobType(P) == "" then
            for T, U in pairs(GMTGangMembers) do
                if P == U[2] then
                    return true, j[U.colour] or k
                end
            end
        end
    end
    return false, k
end
function GMT.hasGangBlipsEnabled()
    if h and h.blips then
        return true
    end
    return false
end
local V = {}
local W = {}
RegisterKeyMapping("drawmarker", "Gang Marker", "MOUSE_BUTTON", "MOUSE_MIDDLE")
RegisterCommand(
    "drawmarker",
    function()
        if h.pings and not GMT.isEmergencyService() and not globalHideUi and not GMT.inEvent() then
            local X = GetGameplayCamCoord()
            local Y = GMT.rotationToDirection(GetGameplayCamRot(2))
            local Z = {x = X.x + Y.x * 1000.0, y = X.y + Y.y * 1000.0, z = X.z + Y.z * 1000.0}
            local T, U, _, c = GetShapeTestResult(StartShapeTestRay(X.x, X.y, X.z, Z.x, Z.y, Z.z, -1, -1, 1))
            if _ ~= vector3(0.0, 0.0, 0.0) then
                TriggerServerEvent("GMT:sendGangMarker", gangID, _)
            end
        end
    end
)
local function a0(a1)
    if GMT.getGangPingMarkerIndex() == 2 and not GMT.isEmergencyService() and not GMT.inEvent() then
        local a2, a3 = GetGroundZFor_3dCoord(a1.x, a1.y, a1.z, a1.z, false)
        local a4 = math.abs(a3 - a1.z)
        local a5 = (a4 > 10.0 and a1.z or a3) - 1.0
        return CreateCheckpoint(
            47,
            a1.x,
            a1.y,
            a5,
            a1.x,
            a1.y,
            a1.z + 200.0,
            1.0,
            h.theme.r,
            h.theme.g,
            h.theme.b,
            150,
            0
        )
    else
        return nil
    end
end
local function a6(a1)
    if GMT.displayPingsOnMinimap() then
        tmpBlip = AddBlipForCoord(a1.x, a1.y, a1.z)
        SetBlipSprite(tmpBlip, 252)
        SetBlipColour(tmpBlip, h.theme.r, h.theme.g, h.theme.b, 255)
        SetBlipScale(tmpBlip, 1.5)
        return tmpBlip
    else
        return nil
    end
end
RegisterNetEvent("GMT:drawGangMarker")
AddEventHandler(
    "GMT:drawGangMarker",
    function(a7, a8)
        if h.pings and not GMT.isEmergencyService() and not globalHideUi and not GMT.inEvent() then
            local a9 = #(GetEntityCoords(PlayerPedId()) - a8)
            if a9 < 1000.0 then
                local aa = V[a7]
                if aa and aa.checkpoint then
                    DeleteCheckpoint(aa.checkpoint)
                    aa.checkpoint = nil
                end
                if aa and aa.mapBlip then
                    RemoveBlip(aa.mapBlip)
                    aa.mapBlip = nil
                end
                if a8 then
                    V[a7] = {
                        coords = a8,
                        time = GetGameTimer(),
                        dist = a9,
                        creator = a7,
                        checkpoint = a0(a8),
                        mapBlip = a6(a8),
                        time = GetGameTimer()
                    }
                    if W[a7] then
                        RemoveBlip(W[a7])
                    end
                    if GMT.getGangPingSound() > 1 then
                        SendNUIMessage(
                            {
                                transactionType = "gangping" .. GMT.getGangPingSound() - 1,
                                volume = GMT.getGangPingVolume() * 0.1
                            }
                        )
                    end
                else
                    W[a7] = nil
                    V[a7] = nil
                end
            end
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if h and h.pings and PlayerIsInGang then
                for T, U in pairs(V) do
                    if GetGameTimer() - U.time > 10000 then
                        DeleteCheckpoint(V[T].checkpoint)
                        RemoveBlip(V[T].mapBlip)
                        V[T] = nil
                    end
                end
            end
            Citizen.Wait(1000)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if h and h.pings and PlayerIsInGang then
                for T, U in pairs(V) do
                    if V[T] then
                        local source = source
                        local user_id = GMT.getUserId(source)
                        local playerPos = GetEntityCoords(PlayerPedId())
                        local gangPingLog = false
                        U.dist = #(playerPos - U.coords)
                        

                        if GMT.getGangPingMarkerIndex() == 3 then
                            GMT.DrawSprite3d(
                                {
                                    pos = U.coords + vector3(0.0, 0.0, U.dist / 100),
                                    textureDict = "menus",
                                    textureName = "ping",
                                    width = 0.06,
                                    height = 0.1,
                                    r = h.theme.r,
                                    g = h.theme.g,
                                    b = h.theme.b,
                                    a = 255
                                }
                            )
                        end
                        GMT.DrawText3D(U.coords, U.creator .. "\n" .. tostring(math.floor(U.dist)) .. "m", 0.2)
                    end
                end
            end
            Citizen.Wait(0)
        end
    end
)
local ab = {}
RegisterNetEvent("GMT:sendGangHPStats")
AddEventHandler(
    "GMT:sendGangHPStats",
    function(ac)
        ab = ac
    end
)
local ad = 0.008
local ae = 0.35
local af = {0, 0, 0, 255}
local function ag(ah, ai, aj, ak, F, G, H, b5)
    DrawRect(ah + aj / 2.0, ai + ak / 2.0, aj, ak, F, G, H, b5)
end
local healthColors = {
    {max = 0, color = {255, 0, 0, 200}}, -- red
    {max = 36, color = {255, 0, 0, 200}}, -- red
    {max = 75, color = {255, 165, 0, 200}}, -- orange
    {max = 90, color = {86, 215, 64, 200}} -- green
}
local function al()
    local am = 0
    local M = m()
    if h and h.healthui and PlayerIsInGang then
        if M and not GMT.isEmergencyService() and not globalHideUi and not GMT.inEvent() then
            local an = 0
            local ao = GMT.getShowHealthPercentageFlag()
            if GMTGangMembers then
                for ap, aq in pairs(GMTGangMembers) do
                    name, id, rank, lastseen, playtime = table.unpack(aq)
                    if lastseen == "~g~Online" and GMT.getJobType(id) == "" and h.pinnedPlayers[id] then
                        local ar = true
                        local as = nil
                        local at = nil
                        local ac = ab[id]
                        if ac then
                            as = ac.health
                            at = ac.armor
                        end
                        local au = GMT.getTempFromPerm(id)
                        if au then
                            local av = GetPlayerFromServerId(au)
                            if av ~= -1 then
                                local aw = GetPlayerPed(av)
                                if aw ~= 0 then
                                    as = GetEntityHealth(aw)
                                    at = GetPedArmour(aw)
                                    ar = false
                                end
                            end
                        end
                        if as and at then
                            local ax = an * 0.05 + ae
                            GMT.DrawText(ad, ax, name, 0.3)
                            ag(ad + 0.0011, ax + 0.025, 0.125, 0.0035, 9, 31, 0, 100)
                            local ay = 0.125 * at / 100
                            if as <= 102 then
                                ay = 0.0
                            end
                            ag(ad + 0.0011, ax + 0.025, ay, 0.0035, 66, 145, 243, 255)
                            ag(ad + 0.0011, ax + 0.032, 0.125, 0.009, 9, 31, 0, 100)
                            if as >= 198 then
                                as = 200
                            end
                            local az = 0.125 * (as - 100) / 100
                            if az < 0.0 then
                                az = 0.0
                            end
                            local healthColor = {86, 215, 64, 200}
                            if GMT.getShowcolourHealthBar() then
                                for _, v in ipairs(healthColors) do
                                    if (as - 100) <= v.max then
                                        healthColor = v.color
                                        break
                                    end
                                end
                            end
                            ag(ad + 0.0011, ax + 0.032, az, 0.009, table.unpack(healthColor))
                            if ao then
                                local aA = math.floor((as - 100) / 100.0 * 100)
                                if aA < 0 then
                                    aA = 0
                                end
                                GMT.DrawText(
                                    ad + 0.125 / 2.0 - 0.0025,
                                    ax + 0.03,
                                    tostring(aA) .. "%",
                                    0.15,
                                    nil,
                                    nil,
                                    af
                                )
                            end
                            an = an + 1
                        end
                        if ar then
                            am = am + 1
                        end
                    end
                end
            end
        end
    end
    if i and i == M then
        if am <= 0 then
            TriggerServerEvent("GMT:getGangHealthTable", nil)
            i = nil
        end
    else
        if am > 0 then
            TriggerServerEvent("GMT:getGangHealthTable", gangID)
            i = M
        end
    end
end
GMT.createThreadOnTick(al)
function GMT.setGangUIXPos(aB)
    local aC = tonumber(string.match(aB, "%d+")) / 100
    ad = 0.008 * aC
end
function GMT.setGangUIYPos(aB)
    local aC = tonumber(string.match(aB, "%d+")) / 100
    ae = 0.35 * aC
end
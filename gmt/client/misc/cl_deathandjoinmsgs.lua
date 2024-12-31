local a = false
local b = true
RegisterCommand(
    "togglekillfeed",
    function()
        if not a then
            b = not b
            if b then
                GMT.notify("~g~Killfeed is now enabled")
                SendNUIMessage({type = "killFeedEnable"})
            else
                GMT.notify("~r~Killfeed is now disabled")
                SendNUIMessage({type = "killFeedDisable"})
            end
        end
    end
)
RegisterCommand(
    "showkillfeed",
    function()
        if not a then
            b = not b
            if b then
                GMT.notify("~g~Killfeed is now enabled")
                SendNUIMessage({type = "killFeedEnable"})
            end
        end
    end
)
RegisterCommand(
    "disablekillfeed",
    function()
        if not a then
            b = not b
            if b then
                GMT.notify("~g~Killfeed is now disabled")
                SendNUIMessage({type = "killFeedDisable"})
            end
        end
    end
)
RegisterNetEvent(
    "GMT:showHUD",
    function(c)
        a = not c
        if b then
            if c then
                SendNUIMessage({type = "killFeedEnable"})
            else
                SendNUIMessage({type = "killFeedDisable"})
            end
        end
    end
)
RegisterNetEvent(
    "GMT:newKillFeed",
    function(d, e, f, g, h, i, j, headShot)
        if GetIsLoadingScreenActive() then
            return
        end
        local k = "other"
        local l = GMT.getPlayerName(GetPlayerServerId(PlayerId()))
        if e == l or d == l then
            k = "self"
        end
        local m = GetResourceKvpString("gmt_oldkillfeed") or "false"
        if m == "false" then
            oldKillfeed = false
        else
            oldKillfeed = true
        end
        if oldKillfeed and (tGMT.isPlatClub() or tGMT.isPlusClub()) then
            if g then
                GMT.notify("~o~" .. e .. " ~w~died.")
            else
                GMT.notify("~o~" .. d .. " ~w~killed ~o~" .. e .. "~w~.")
            end
        else
            SendNUIMessage(
                {
                    type = "addKill",
                    victim = e,
                    killer = d,
                    weapon = f,
                    suicide = g,
                    victimGroup = i,
                    isHeadshot = headShot,
                    killerGroup = j,
                    range = h,
                    uuid = tGMT.generateUUID("kill", 10, "alphabet"),
                    category = k
                }
            )
        end
    end
)

RegisterCommand('testkillfeed', function()
    if GMT.getUserId() == 1 then
        local killer = 'Tayser'
        local victim = 'SEAN'
        local weapon = 'LMG'
        local headShot = true
        -- local killerID = GMT.getUserId(killer)
        local suicide = false
        local victimGroup = 'police'
        local killerGroup = 'none'
        local range = math.random(10,78)
        local uuid = tGMT.generateUUID("kill", 10, "alphabet")
        local category = 'self'
        -- headShot = GMT.GetLatestHeadShot(killerID) == user_id
        TriggerEvent('GMT:newKillFeed', killer, victim, weapon, suicide, range, victimGroup, killerGroup, uuid, category, headShot)
    end
end, false)
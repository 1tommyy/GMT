local a = {
    {coords = vector3(3533.4428710938, 3713.8090820313, 36.17896270752), radius = 150},
    {coords = vector3(1459.3325195313, 6350.8974609375, 23.534168243408), radius = 150},
    {coords = vector3(1359.7745361328, 4371.7626953125, 44.287654876709), radius = 150},
    {coords = vector3(2506.5634765625, -390.224609375, 94.119445800781), radius = 150},
    {coords = vector3(-1498.1591796875, -215.69320678711, 50.195583343506), radius = 20},
    {coords = vector3(-3171.8498535156, 1085.7032470703, 20.838762283325), radius = 45}
}
local function b(c, d, e)
    local f = true
    local g = false
    local h = PlayerPedId()
    Citizen.CreateThread(function()
        repeat
            if c > 0 then
                PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", true)
            else
                PlaySoundFrontend(-1, "Countdown_GO", "DLC_SR_TR_General_Sounds")
                ClearPedTasksImmediately(h)
            end
            Wait(1000)
            c = c - 1
            if g then
                c = -1
            end
        until c == -1
        if not g then
            DoScreenFadeOut(350)
            Wait(500)
            SetEntityCoords(h, e.x, e.y, e.z + 1.5, 0.0, 0.0, 0.0, false)
            Wait(500)
            DoScreenFadeIn(500)
            GMT.notifyPicture("CHAR_BLOCKED","CHAR_BLOCKED","Attempting to teleport to surface... \n\nIf you are still not on the surface please use /calladmin.","GMT","Utilities",nil,nil)
            TriggerServerEvent("GMT:unstuckSuccessful", d, e)
        else
            GMT.notifyPicture("CHAR_BLOCKED","CHAR_BLOCKED","You moved during the countdown so the teleportation was cancelled.","GMT","Utilities",nil,nil)
        end
        f = false
        g = false
    end)
    Citizen.CreateThread(function()
        local i = Scaleform("mp_big_message_freemode")
        while true do
            Wait(0)
            if IsControlJustReleased(0, 73) then
                g = true
                ClearPedTasksImmediately(h)
            end
            if f then
                local j = GMT.getPlayerCoords()
                if #(j - d) < 0.5 or #(j - e) < 0.5 and not g then
                    if c > -1 then
                        DisablePlayerFiring(id, true)
                        DisableControlAction(1, 140, true)
                        DisableControlAction(1, 141, true)
                        DisableControlAction(1, 142, true)
                        i.RunFunction("SHOW_SHARD_WASTED_MP_MESSAGE",{"~r~DONT MOVE", "You will be teleported to the surface in " .. c .. " seconds."})
                        i.Render2D()
                        local h = PlayerPedId()
                        if not IsEntityPlayingAnim(h, "timetable@amanda@ig_4", "ig_4_base", 3) and not g then
                            TaskPlayAnim(h, "timetable@amanda@ig_4", "ig_4_base", 8.0, -8.0, -1, 0, 0.0, 0, 0, 0)
                        end
                    else
                        break
                    end
                else
                    DisablePlayerFiring(id, true)
                    DisableControlAction(1, 140, true)
                    DisableControlAction(1, 141, true)
                    DisableControlAction(1, 142, true)
                    BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
                    BeginTextCommandScaleformString("STRING")
                    ScaleformMovieMethodAddParamTextureNameString("~r~CANCELLED")
                    ScaleformMovieMethodAddParamTextureNameString("You moved during the countdown.")
                    EndTextCommandScaleformString()
                    EndScaleformMovieMethod()
                    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
                    g = true
                    break
                end
            end
        end
    end)
end
local function k(l)
    for m, n in ipairs(a) do
        if #(l - n.coords) < n.radius then
            return true
        end
    end
    return false
end
local function o()
    local h = PlayerPedId()
    local j = GMT.getPlayerCoords()
    local m, p = GetNthClosestVehicleNode(j.x, j.y, j.z, 1)
    return not (p == vector3(0, 0, 0) or p.z < j.z or k(j) or GetRoomKeyFromEntity(PlayerPedId()) ~= 0 or
        IsEntityInWater(h) or
        IsPedInAnyVehicle(h, false)), p
end
RegisterCommand("unstuck",function(q, r, s)
    local h = PlayerPedId()
    local t, p = o()
    if not t or GMT.getPlayerCombatTimer() > 0 then
        GMT.notifyPicture("CHAR_BLOCKED","CHAR_BLOCKED","You are unable to use this right now. Use /calladmin if you still need assistance.","GMT","Utilities",nil,nil)
    else
        GMT.loadAnimDict("timetable@amanda@ig_4")
        TaskPlayAnim(h, "timetable@amanda@ig_4", "ig_4_base", 8.0, -8.0, -1, 0, 0.0, 0, 0, 0)
        RemoveAnimDict("timetable@amanda@ig_4")
        Wait(1000)
        b(45, GMT.getPlayerCoords(), p)
    end
end)

local u = 0
RegisterCommand("reset",function(q, r, s)
    local h = PlayerPedId()
    local t =
        GMT.getPlayerCombatTimer() > 0 or GMT.isPlayerInRedZone() or GetRoomKeyFromEntity(PlayerPedId()) ~= 0 or
        IsEntityInWater(h) or
        IsPedInAnyVehicle(h, false)
    if u < GetGameTimer() then
        if t then
            GMT.notifyPicture("CHAR_BLOCKED","CHAR_BLOCKED","You are unable to use this right now.","GMT","Utilities",nil,nil)
        else
            local v = GMT.getPlayerCoords() -- tayser
            tGMT.teleport(3094.446, -4811.093, 15.26162)
            Wait(500)
            tGMT.teleport(v.x, v.y, v.z)
            u = GetGameTimer() + 60000
        end
    else
        GMT.notifyPicture("CHAR_BLOCKED","CHAR_BLOCKED","You must wait 60 seconds before using this again.","GMT","Utilities",nil,nil)
    end
end)

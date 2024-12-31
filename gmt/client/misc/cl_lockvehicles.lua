local function a()
    local b = GMT.getPlayerPed()
    if GetEntityHealth(b) > 102 then
        local c, d = GMT.getNearestOwnedVehicle(8)
        if d then
            if c then
                GMT.vc_toggleLock(d)
                GMT.playSound("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING")
                Citizen.Wait(1000)
            else
                Citizen.Wait(1000)
                GMT.notify("~r~You do not own this vehicle")
            end
        else
            GMT.notify("~r~No owned vehicle found nearby to lock/unlock")
        end
    else
        GMT.notify("~r~You may not lock/unlock your vehicle whilst dead.")
    end
end
RegisterCommand('lockVehicle', function(source, args, rawCommand)
    a()
end, false)
AddEventHandler("GMT:lockNearestVehicle",function()
    a()
end)

RegisterKeyMapping("lockVehicle", "Lock closest vehicle", "keyboard", "COMMA")
local a = true
RegisterCommand("roll",function(b, c, d)
    local e = GMT.getPlayerPed()
    if IsPedInAnyVehicle(e, false) then
        local f = GetVehiclePedIsIn(e, false)
        if GetPedInVehicleSeat(f, -1) == e then
            SetEntityAsMissionEntity(f, true, true)
            if a then
                RollDownWindow(f, 0)
                RollDownWindow(f, 1)
                TriggerEvent("chatMessage", "", {255, 0, 0}, "Windows down")
                a = false
            else
                RollUpWindow(f, 0)
                RollUpWindow(f, 1)
                TriggerEvent("chatMessage", "", {255, 0, 0}, "Windows up")
                a = true
            end
        end
    end
end,false)

local thanked = false 

local combatNotifications = {
    "~r~Ew no get away.",
    "~r~You are ugly",
    "~r~Haha small pp",
    "~r~You won the ~y~baller ~r~rank!"
}

local cam = nil

RegisterCommand('thankyou', function(source, args, rawCommand)
    if GMT.getPlayerCombatTimer() > 0 and not thanked then --tayser
        local randomIndex = math.random(1, #combatNotifications)
        local notification = combatNotifications[randomIndex]

        TriggerEvent("Horrific:FuckYou")
        GMT.notify(notification)

    else
        GMT.notify('~g~Your welcome twat.')
        ExecuteCommand("e thumbsup2")

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)

        local camPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.4) 
        local camRot = vector3(20.0, 0.0, playerHeading + 180) 

        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos, camRot, 60.0, true, 0)
        RenderScriptCams(true, true, 1000, true, true)

        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < 10000 do
            playerPed = PlayerPedId()
            local newCamPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.4)
            local newCamRot = vector3(20.0, 0.0, GetEntityHeading(playerPed) + 180)
            SetCamCoord(cam, newCamPos)
            SetCamRot(cam, newCamRot, 2)
            Citizen.Wait(0)
        end

        ExecuteCommand("e c")
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
    end
end)

local a = {}
local b = 0
local c = {}
local showingF10 = false
function func_f10warnings()
    if not recordingMode then
        if IsControlJustPressed(0, 57) then
            TriggerServerEvent("GMT:refreshWarningSystem")
            Citizen.Wait(100)
            showingF10 = true
            SetNuiFocus(true, true)
            SendNUIMessage({showF10 = true})
        end
        if showingF10 and GMT.isNewPlayer() then
            drawNativeNotification("Press ~INPUT_DROP_AMMO~ to toggle the Warnings Menu.")
        end
    end
end
RegisterNUICallback("closeGMTF10", function(b, d)
   showingF10 = false
    SetNuiFocus(false, false)
end)
GMT.createThreadOnTick(func_f10warnings)
RegisterNetEvent("GMT:recievedRefreshedWarningData")
AddEventHandler("GMT:recievedRefreshedWarningData", function(e, f, g, pt, pid)
    a = e
    c = g
    SendNUIMessage({type = "sendWarnings", localHourCount = GMT.getPlayerHours(GMT.getUserId()), localUserId = GMT.getUserId(), warnings = json.encode(a), points = f, info = json.encode(c)})
end)
RegisterNetEvent("GMT:showWarningsOfUser")
AddEventHandler("GMT:showWarningsOfUser", function(e, f, g, pt, pid)
    a = e
    c = g
    SendNUIMessage({type = "sendWarnings", localHourCount = GMT.getPlayerHours(GMT.getUserId()), localUserId = GMT.getUserId(), warnings = json.encode(a), points = f, info = json.encode(c)})
    SendNUIMessage({showF10 = true})
    showingF10 = true
    SetNuiFocus(true, true)
  --  TriggerScreenblurFadeIn(100.0)
end)

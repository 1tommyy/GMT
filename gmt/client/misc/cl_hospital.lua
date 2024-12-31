local a = GetGameTimer() - 30000
local b = {
    ["city"] = vector3(309.04260253906, -592.22509765625, 42.284008026123),
    ["sandy"] = vector3(1833.0328369141, 3682.8110351563, 33.270057678223),
    ["paleto"] = vector3(-251.9546661377, 6334.146484375, 31.427177429199),
    ["london"] = vector3(355.45614624023, -1416.0190429688, 32.510429382324),
    ["mountzenah"] = vector3(-436.04296875, -326.27416992188, 33.910766601562),
    ["vip"] = vector3(-2670.2504882812,-1480.91015625,3.7972581386566),
    -- ["PVP"] = vector3(-502.03567504883,-267.41232299805,35.704616546631)
}
local nurseModel = "s_f_y_scrubs_01"

Citizen.CreateThread(function()
    RequestModel(GetHashKey(nurseModel))
    while not HasModelLoaded(GetHashKey(nurseModel)) do
        Wait(1)
    end

    RequestAnimDict("amb@medic@standing@tendtodead@idle_a")
    while not HasAnimDictLoaded("amb@medic@standing@tendtodead@idle_a") do
        Wait(1)
    end

    for h, i in pairs(b) do
        local c = function(d)
            GMT.drawNativeNotification("Press ~INPUT_PICKUP~ to receive medical attention.")
        end
        local e = function(d)
        end

        local f = function(d)
            if IsControlJustPressed(1, 51) then
                if h == "VIP" and not tGMT.isPlatClub() then
                    GMT.notify("~r~Only Platinum members can use this service.")
                    return
                end
                FreezeEntityPosition(PlayerPedId(), true)
                GMT.notify("~g~You are being checked out.")
                TaskPlayAnim(nursePed, "amb@medic@standing@tendtodead@idle_a", "idle_b", 8.0, -8.0, -1, 49, 0, false, false, false)
                tGMT.startCircularProgressBar("",5000,nil,function()
                     FreezeEntityPosition(PlayerPedId(), false)
                     
                local g = GMT.getPlayerPed()
                if not tGMT.isInComa() then
                    if GMT.getPlayerVehicle() == 0 then
                        if GMT.getPlayerCombatTimer() == 0 then
                            if GetGameTimer() > a + 30000 then
                                tGMT.setHealth(200)
                                GMT.notify("~g~You have been patched up, free of charge by the NHS.")
                                a = GetGameTimer()
                            else
                                GMT.notify("~r~The nurses are tired, come back later.")
                            end
                        else
                            GMT.notify("~r~You cannot heal while in combat.")
                        end
                    else
                        GMT.notify("~r~You cannot heal while in a vehicle.")
                    end
                else
                    GMT.notify("~r~You are bleeding out, call a doctor ASAP!")
                end
            end)
            end
        end

        tGMT.addMarker(i.x, i.y, i.z, 1.0, 1.0, 1.0, 0, 0, 255, 100, 50, 27, false, false, true)
        tGMT.createDynamicPed("s_f_y_scrubs_01", vector3(i.x, i.y, i.z),20.87,true,"mini@strip_club@idles@bouncer@base","base",100,false)
        GMT.createArea(h .. "_hospital", i, 1.5, 6, c, e, f, {})
    end
end)
local j = 0
function tGMT.setHealth(k)
    if k then
        if GMT.isPedScriptGuidChanging() and k < 200 then
            return
        end
        local l = math.floor(k)
        j = l
        SetEntityHealth(PlayerPedId(), l)
    end
end
function GMT.getHealth()
    return GetEntityHealth(PlayerPedId())
end
Citizen.CreateThread(
    function()
        Wait(60000)
        while true do
            if not spawning then
                if GMT.getHealth() > j then
                    if GMT.getHealth() - 2 == j then
                        return
                    end
                    tGMT.setHealth(j)
                end
            end
            Wait(0)
        end
    end
)

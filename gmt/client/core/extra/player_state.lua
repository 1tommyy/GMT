local a = false
AddEventHandler("playerSpawned",function()
    a = false
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        a = true
    end)
end)
local b = {}
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(3000)
            if IsPlayerPlaying(PlayerId()) and a then
                if b ~= tGMT.getWeapons() then
                    b = tGMT.getWeapons()
                    GMTserver.updateWeapons({tGMT.getWeapons()})
                end
            end
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(60000)
            GMTserver.UpdatePlayTime()
        end
    end
)
local c = {}
Citizen.CreateThread(function()
   -- print("[GMT] Loading cached user data.")
    c = json.decode(GetResourceKvpString("gmt_userdata") or "{}")
    if type(c) ~= "table" then
        c = {}
        print("[GMT] Loading cached user data - failed to load setting to default.")
    else
        print("[GMT] Loaded user data.")
    end
end)
local function loadUserData()
    local file = LoadResourceFile(GetCurrentResourceName(), userDataFilePath)
    if file then
        return json.decode(file)
    else
        print("[GMT] Loading cached user data - failed to load setting to default.")
        return {}
    end
end
local function saveUserData(data)
    SaveResourceFile(GetCurrentResourceName(), userDataFilePath, json.encode(data), -1)
end
function GMT.updateCustomization(d)
    local e = tGMT.getCustomization()
    if e.modelhash ~= 0 and IsModelValid(e.modelhash) then
        c.customisation = e
        if d then
            SetResourceKvp("gmt_userdata", json.encode(c))
        end
    end
end
function GMT.updateHealth(d)
    c.health = GetEntityHealth(PlayerPedId())
    if c.health == 198 then
        c.health = 200
    end
    if d then
        SetResourceKvp("gmt_userdata", json.encode(c))
    end
end
function tGMT.updateArmour(d)
    c.armour = GetPedArmour(PlayerPedId())
    if d then
        SetResourceKvp("gmt_userdata", json.encode(c))
    end
end
local f = vector3(0.0, 0.0, 0.0)
function GMT.updatePos(d)
    local g = GetEntityCoords(PlayerPedId())
    if g.z > -150.0 and #(g - f) > 15.0 then
        c.position = g
        if d then
            SetResourceKvp("gmt_userdata", json.encode(c))
        end
    end
end
Citizen.CreateThread(
    function()
        Wait(30000)
        while true do
            Wait(5000)
            if
                not GMT.isInHouse() and not inOrganHeist and not GMT.isPlayerInRedZone() and
                    not GMT.isInSpectate() and
                    not GMT.isInStoreTesting()
             then
                GMT.updatePos()
            end
            if
                not tGMT.isStaffedOn() and not customizationSaveDisabled and not spawning and
                    not GMT.isPlayerInAnimalForm()
             then
                GMT.updateCustomization()
            end
            GMT.updateHealth()
            tGMT.updateArmour()
            SetResourceKvp("gmt_userdata", json.encode(c))
        end
    end
)
function GMT.checkCustomization()
    local e = c.customisation
    if e == nil or e.modelhash == 0 or not IsModelValid(e.modelhash) then
        tGMT.setCustomization(getDefaultCustomization(), true, true)
    else
        tGMT.setCustomization(e, true, true)
    end
end
local h = true
local i = 0
function GMT.canAnim()
    return h
end
function tGMT.setCanAnim(j)
    if j then
        if i > 0 then
            i = i - 1
        end
        if i == 0 then
            h = true
        else
            print(string.format("Can not setCanAnim(true) as %d other references exist", i))
        end
    else
        i = i + 1
        h = false
    end
end
function getDefaultCustomization()
    local j = {}
    j = {}
    j.model = "mp_m_freemode_01"
    for k = 0, 19 do
        j[k] = {0, 0}
    end
    j[0] = {0, 0}
    j[1] = {0, 0}
    j[2] = {47, 0}
    j[3] = {5, 0}
    j[4] = {4, 0}
    j[5] = {0, 0}
    j[6] = {7, 0}
    j[7] = {51, 0}
    j[8] = {0, 240}
    j[9] = {0, 1}
    j[10] = {0, 0}
    j[11] = {5, 0}
    j[12] = {4, 0}
    j[15] = {0, 2}
    return j
end
function tGMT.spawnAnim(l)
    if l then
        DoScreenFadeOut(250)
        ExecuteCommand("hideui")
        local m = c.position or vector3(178.5132598877, -1007.5575561523, 29.329647064209)
        Wait(500)
        TriggerScreenblurFadeIn(100.0)
        RequestCollisionAtCoord(m.x, m.y, m.z)
        NewLoadSceneStartSphere(m.x, m.y, m.z, 100.0, 2)
        SetEntityCoordsNoOffset(PlayerPedId(), m.x, m.y, m.z, true, false, false)
        SetEntityVisible(PlayerPedId(), false, false)
        FreezeEntityPosition(PlayerPedId(), true)
        local n = GetGameTimer()
        local o = 0
        while (not HaveAllStreamingRequestsCompleted(PlayerPedId()) or GetNumberOfStreamingRequests() > 0) and
            GetGameTimer() - n < 10000 do
            Wait(0)
            if GetGameTimer() - o > 1000 then
                --print("[GMT] Waiting for streaming requests to complete!")
                o = GetGameTimer()
            end
        end
        NewLoadSceneStop()
        GMT.checkCustomization()
        TriggerServerEvent("GMT:getPlayerHairstyle")
        TriggerServerEvent("GMT:getPlayerTattoos")
        TriggerEvent("GMT:playGTAIntro")
        DoScreenFadeIn(1000)
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        if not GMT.isDev() then
            SetFocusPosAndVel(m.x, m.y, m.z + 1000)
            local p = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", m.x, m.y, m.z + 1000, 0.0, 0.0, 0.0, 65.0, 0, 2)
            SetCamActive(p, true)
            RenderScriptCams(true, true, 0, 1, 0)
            local q = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", m.x, m.y, m.z, 0.0, 0.0, 0.0, 65.0, 0, 2)
            SetCamActiveWithInterp(q, p, 5000, 0, 0)
            Wait(2500)
            ClearFocus()
            TriggerScreenblurFadeOut(2000.0)
            Wait(2000)
            DestroyCam(p)
            DestroyCam(q)
            RenderScriptCams(false, true, 2000, 0, 0)
        else
            if GetScreenblurFadeCurrentTime() ~= 100.0 then
                DisableScreenblurFade()
            else
                TriggerScreenblurFadeOut(500.0)
            end
        end
        -- print("[GMT] cachedUserData.health", c.health)
        -- print("[GMT] cachedUserData.armour", c.armour)
        tGMT.setHealth(c.health or 200)
        tGMT.setArmour(c.armour)
        print("[GMT] Loaded health data")
        SetEntityVisible(PlayerPedId(), true, false)
        FreezeEntityPosition(PlayerPedId(), false)
        if GMT.isDev() then
            Citizen.Wait(500)
        end
        ExecuteCommand("showui")
        -- if GMT.isInTutorial() then
           TriggerEvent('GMT:sendTutorialThingy', true)
        -- end
    end
    spawning = false
end
AddEventHandler(
    "GMT:playGTAIntro",
    function()
        if not GMT.isDev() then
            SendNUIMessage({transactionType = "gtaloadin"})
        end
    end
)
RegisterNetEvent("GMT:setHairstyle")
AddEventHandler("GMT:setHairstyle", function(r)
        if r then
            dad = r["dad"] or 0
            mum = r["mum"] or 0
            skin = r["skin"] or 0
            dadmumpercent = r["dadmumpercent"] or 0
            eyecolor = r["eyecolor"] or 0
            acne = r["acne"] or 0
            skinproblem = r["skinproblem"] or 0
            freckle = r["freckle"] or 0
            wrinkle = r["wrinkle"] or 0
            wrinkleopacity = r["wrinkleopacity"] or 0
            hair = r["hair"] or 0
            haircolor = r["haircolor"] or 0
            eyebrow = r["eyebrow"] or 0
            eyebrowopacity = r["eyebrowopacity"] or 0
            beard = r["beard"] or 0
            beardopacity = r["beardopacity"] or 0
            beardcolor = r["beardcolor"] or 0
            eyeshadow = r["eyeshadow"] or 0
            lipstick = r["lipstick"] or 0
            eyeshadowcolour = r["eyeshadowcolour"] or 0
            lipstickcolour = r["lipstickcolour"] or 0
            facepaints = r["facepaints"] or 16
            facepaintscolour = r["facepaintscolour"] or 16
            SetPedHeadBlendData(
                GetPlayerPed(-1),
                dad,
                mum,
                0,
                skin,
                skin,
                skin,
                dadmumpercent,
                dadmumpercent,
                0.0,
                false
            )
            SetPedEyeColor(GetPlayerPed(-1), eyecolor)
            if acne == 0 then
                SetPedHeadOverlay(GetPlayerPed(-1), 0, acne, 0.0)
            else
                SetPedHeadOverlay(GetPlayerPed(-1), 0, acne, 1.0)
            end
            SetPedHeadOverlay(GetPlayerPed(-1), 6, skinproblem, 1.0)
            if freckle == 0 then
                SetPedHeadOverlay(GetPlayerPed(-1), 9, freckle, 0.0)
            else
                SetPedHeadOverlay(GetPlayerPed(-1), 9, freckle, 1.0)
            end
            SetPedHeadOverlay(GetPlayerPed(-1), 3, wrinkle, wrinkleopacity * 0.1)
            SetPedComponentVariation(GetPlayerPed(-1), 2, hair, 0, 2)
            SetPedHairColor(GetPlayerPed(-1), haircolor, haircolor)
            SetPedHeadOverlay(GetPlayerPed(-1), 2, eyebrow, eyebrowopacity * 0.1)
            SetPedHeadOverlay(GetPlayerPed(-1), 1, beard, beardopacity * 0.1)
            SetPedHeadOverlayColor(GetPlayerPed(-1), 1, 1, beardcolor, beardcolor)
            SetPedHeadOverlayColor(GetPlayerPed(-1), 2, 1, beardcolor, beardcolor)
            eyeShadowOpacity = 1.0
            if eyeshadow == 0 then
                eyeShadowOpacity = 0.0
            end
            lipstickOpacity = 1.0
            if lipstick == 0 then
                lipstickOpacity = 0.0
            end
            SetPedHeadOverlay(GetPlayerPed(-1), 4, eyeshadow, eyeShadowOpacity)
            SetPedHeadOverlay(GetPlayerPed(-1), 8, lipstick, lipstickOpacity)
            SetPedHeadOverlayColor(GetPlayerPed(-1), 4, 1, eyeshadowcolour, eyeshadowcolour)
            SetPedHeadOverlayColor(GetPlayerPed(-1), 8, 1, lipstickcolour, lipstickcolour)
            SetPedHeadOverlay(GetPlayerPed(-1), 4, facepaints, 1.0)
            SetPedHeadOverlayColor(GetPlayerPed(-1), 4, 1, facepaintscolour, 0)
        end
    end
)
ReplaceHudColourWithRgba(116, 42, 87, 141, 255)
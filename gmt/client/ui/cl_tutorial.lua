local a = vector3(-1035.9499511719, -2734.6240234375, 13.756628036499)
local b = vector3(-1037.8022460938, -2737.9750976562, 13.798089027405)
local c = vector3(-1056.6693115234, -2695.5822753906, -8.2877798080444)
local d = vector3(103.13236236572, -1710.0469970703, 29.128242492676)
local e = {
    {
        vector3(95.41603088379, -1727.3582763672, 28.85818862915),
        vector3(95.41603088379, -1727.3582763672, 28.85818862915),
        50.0
    },
    {
        vector3(94.067138671875, -1740.6694335938, 29.305875778198),
        vector3(94.067138671875, -1740.6694335938, 28.305875778198),
        320.0
    },
    {
        vector3(96.752075195312, -1745.4302978516, 29.315612792968),
        vector3(96.752075195312, -1745.4302978516, 28.315612792968),
        320.0
    },
    {
        vector3(103.90421295166, -1751.818359375, 29.321237564086),
        vector3(103.90421295166, -1751.818359375, 28.321237564086),
        320.0
    },
    {
        vector3(108.07794952392, -1756.5098876954, 29.360332489014),
        vector3(108.07794952392, -1756.5098876954, 28.360332489014),
        320.0
    },
    {
        vector3(111.3772354126, -1740.8269042968, 28.854513168334),
        vector3(111.3772354126, -1740.8269042968, 28.854513168334),
        50.0
    },
    {
        vector3(97.749137878418, -1728.8994140625, 28.873386383056),
        vector3(97.749137878418, -1728.8994140625, 28.873386383056),
        50.0
    }
}
local f = false
local g = false
local h = nil
local startingTutorial = true
local i = nil
local j = 0
local k = "INVALID"
local l = 0
local m = 0
DecorRegister("lastSpeed", 1)
RegisterNetEvent(
    "GMT:initMoney",
    function(n, o)
        m = o
    end
)
local function p(q)
    SendNUIMessage({transactionType = q})
end
local function qA(r, ...)
    print("[Tutorial] " .. r, ...)
end
local function r(s, t)
    local u = CreateCheckpoint(1, s.x, s.y, s.z, t.x, t.y, t.z, 2.0, 204, 204, 1, 100, 0)
    local v = AddBlipForCoord(s.x, s.y, s.z)
    while #(GMT.getPlayerCoords() - s) > 4.0 do
        Citizen.Wait(0)
    end
    RemoveBlip(v)
    DeleteCheckpoint(u)
end
function TP2DEALERSHIP()
    local player = PlayerPedId()
    FreezeEntityPosition(player, false)
    SetEntityCoords(player, -21.057991027832,-1085.2326660156,26.615484237671, true, false, false, false)
    i = "You are now in the city, You can purchase vehicles here."
    h = "~y~Walk up to the £ sign to buy a car."
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",-37.71187210083,-1096.9548339844,26.422437667847,0.0,0.0,0.0,GetGameplayCamFov(),true,2)
    PointCamAtEntity(cam, player, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 0, true, true)
    TaskGoStraightToCoord(player, -27.203210830688,-1083.5098876953,26.591089248657, 1.0, -1, 0.0, 0.0)
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(player)
        local distance = #(playerCoords - vector3(-27.203210830688,-1083.5098876953,26.591089248657))
        if distance < 0.1 then
            break
        end
    end
    TaskGoStraightToCoord(player, -36.446365356445,-1100.9317626953,26.422437667847, 1.0, -1, 0.0, 0.0)
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(player)
        local distance = #(playerCoords - vector3(-36.446365356445,-1100.9317626953,26.422437667847))
        if distance < 0.1 then
            break
        end
    end
    TaskTurnPedToFaceCoord(player, -37.71187210083,-1096.9548339844,26.422437667847, -1)
    Citizen.Wait(1000)
    FreezeEntityPosition(player, true)
    DetachEntity(player, true, true)
    FreezeEntityPosition(player, false)
    SetPlayerControl(PlayerId(), true, 0)
    SetEntityInvincible(player, false)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent("GMT:setCompletedTutorial")
    RenderScriptCams(false, false, 0, false, false)
    SetCamActive(cam, false)
    DestroyCam(cam, false)
end
local ableToStart = false
RegisterNetEvent("GMT:sendTutorialThingy")
AddEventHandler("GMT:sendTutorialThingy", function(value)
    ableToStart = value
end)
function startScreen()
    local player = PlayerPedId()
    qA("Starting the sequence", g)
    while not ableToStart do
        Citizen.Wait(0)
    end
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    g = true
    tGMT.setCanAnim(false)
    SetEntityCoords(player, -795.36151123047,321.90255737305,242.12379455566, true, false, false, false)
    i = "You will soon decide if you want to continue with the tutorial."
    h = "~y~Welcome to GMT!"
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",-804.25805664062,332.68701171875,244.22398376465,0.0,0.0,0.0,GetGameplayCamFov(),true,2)
    PointCamAtEntity(cam, player, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 0, true, true)
    TaskGoStraightToCoord(player, -800.89245605469,321.66741943359,241.69665527344, 1.0, -1, 0.0, 0.0)
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(player)
        local distance = #(playerCoords - vector3(-800.89245605469,321.66741943359,241.69665527344))
        if distance < 0.1 then
            break
        end
    end
    TaskGoStraightToCoord(player, -800.93035888672,326.86352539062,243.22471618652, 1.0, -1, 0.0, 0.0)
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(player)
        local distance = #(playerCoords - vector3(-800.93035888672,326.86352539062,243.22471618652))
        if distance < 0.1 then
            break
        end
    end
    i = "If you are unfarmiliar with the server, it is recommended to continue with the tutorial."
    h = "~y~Are you ready to start the tutorial?"
    TaskGoStraightToCoord(player, -806.29278564453,329.28143310547,243.22462463379, 1.0, -1, 0.0, 0.0)
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(player)
        local distance = #(playerCoords - vector3(-806.29278564453,329.28143310547,243.22462463379))
        if distance < 0.1 then
            break
        end
    end
    TaskTurnPedToFaceCoord(player, -804.25805664062,332.68701171875,243.22398376465, -1)
    Citizen.Wait(500)
    i = "If you are unfarmiliar with the server, it is recommended to continue with the tutorial."
    h = "~y~Press [E] to start the tutorial, or [X] to skip."
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 51) then
            i = "Great! Let's get started."
            h = "~y~You will be guided through the tutorial."
            TaskGoStraightToCoord(player, -802.80053710938,327.12075805664,243.22441101074, 1.0, -1, 0.0, 0.0)
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(player)
                local distance = #(playerCoords - vector3(-802.80053710938,327.12075805664,243.22441101074))
                if distance < 0.1 then
                    break
                end
            end
            TaskGoStraightToCoord(player, -800.82299804688,327.58889770508,243.22441101074, 1.0, -1, 0.0, 0.0)
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(player)
                local distance = #(playerCoords - vector3(-800.82299804688,327.58889770508,243.22441101074))
                if distance < 0.1 then
                    break
                end
            end
            TaskGoStraightToCoord(player, -800.28698730469,343.3151550293,243.22441101074, 1.0, -1, 0.0, 0.0)
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(player)
                local distance = #(playerCoords - vector3(-800.28698730469,343.3151550293,243.22441101074))
                if distance < 2.5 then
                    DoScreenFadeOut(1000)
                    RenderScriptCams(false, false, 0, false, false)
                    SetCamActive(cam, false)
                    DestroyCam(cam, false)
                    h = nil
                    i = nil
                    startingTutorial = true
                    StartTutorial()
                end
            end
        elseif IsControlJustPressed(0, 73) then
            i = "Okay, skipping tutorial"
            h = "~y~Reminder: Press ESC To to read rules."
            TaskGoStraightToCoord(player, -801.29284667969,327.0830078125,243.22451782227, 1.0, -1, 0.0, 0.0)
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(player)
                local distance = #(playerCoords - vector3(-801.29284667969,327.0830078125,243.22451782227))
                if distance < 0.1 then
                    break
                end
            end
            h = "~y~You can always ask about for help."
            TaskGoStraightToCoord(player, -801.01428222656,322.345703125,241.69720458984, 1.0, -1, 0.0, 0.0)
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(player)
                local distance = #(playerCoords - vector3(-801.01428222656,322.345703125,241.69720458984))
                if distance < 0.1 then
                    break
                end
            end
            h = "~y~You will start at the dealership."
            TaskGoStraightToCoord(player, -796.93493652344,322.05853271484,241.69662475586, 1.0, -1, 0.0, 0.0)
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(player)
                local distance = #(playerCoords - vector3(-796.93493652344,322.05853271484,241.69662475586))
                if distance < 1.5 then
                    DoScreenFadeOut(1000)
                    h = nil
                    i = nil
                    startingTutorial = false
                    StartTutorial()
                end
            end
        end
    end
    RenderScriptCams(false, false, 0, false, false)
    SetCamActive(cam, false)
    DestroyCam(cam, false)
end
local function w(x, y, z)
    qA("Starting the train sequence")
    GMT.loadModel("metrotrain")
    GMT.loadModel("s_m_m_lsmetro_01")
    local A = 0
    while true do
        local B = CreateMissionTrain(25, x, y, z, true)
        Citizen.Wait(1000)
        if DoesEntityExist(B) and NetworkGetEntityIsNetworked(B) and NetworkGetNetworkIdFromEntity(B) ~= 0 then
            j = B
            break
        else
            print("[Tutorial] Failed to create train, retrying.")
            DeleteMissionTrain(B)
            for n, C in pairs(GetGamePool("CVehicle")) do
                if IsThisModelATrain(GetEntityModel(C)) then
                    DeleteEntity(C)
                end
            end
            A = A + 1
            if A > 5 then
                return
            end
        end
    end
    CreatePedInsideVehicle(j, 0, "s_m_m_lsmetro_01", -1, false, false)
    SetCanClimbOnEntity(j, false)
    local v = AddBlipForEntity(j)
    SetBlipSprite(v, 795)
    SetBlipColour(v, 3)
    SetModelAsNoLongerNeeded("metrotrain")
    SetModelAsNoLongerNeeded("s_m_m_lsmetro_01")
end
local function D()
    local E = PlayerPedId()
    SetEntityCoords(E, 146.50889587402, -1752.2452392578, 29.243356704712, true, false, false, false)
    Citizen.Wait(2000)
    w(177.9623260498, -1774.7336425781, 29.108749389648)
    SetEntityHeading(E, GetEntityHeading(j))
    AttachEntityToEntity(E, j, -1, 0.0, 0.0, 1.83, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
    local F =
        CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        116.66564178467,
        -1724.0200195312,
        31.544952392578,
        0.0,
        0.0,
        0.0,
        GetGameplayCamFov(),
        true,
        2
    )
    PointCamAtEntity(F, j, 0.0, 0.0, 0.0, true)
    SetCamActive(F, true)
    RenderScriptCams(true, true, 0, true, true)
    k = "ARRIVE_TAXI"
    Citizen.Wait(1000)
    p("tubearriving")
    DoScreenFadeIn(1000)
    Citizen.Wait(1000)
    while DoesEntityExist(j) and GetTrainDoorOpenRatio(j, 0) < 0.95 do
        Citizen.Wait(0)
    end
    RenderScriptCams(false, false, 0, false, false)
    SetCamActive(F, false)
    DestroyCam(F, false)
    ExecuteCommand("showui")
    FreezeEntityPosition(j, true)
    RemoveBlip(GetBlipFromEntity(j))
    DetachEntity(E, true, true)
    FreezeEntityPosition(E, false)
    SetPlayerControl(PlayerId(), true, 0)
    SetEntityCoordsNoOffset(E, 101.46366882324, -1711.6800537109, 30.114803314209, false, false, false)
    SetEntityHeading(E, 142.655)
    SetEntityInvincible(E, false)
end
local function G()
    while DoesEntityExist(j) and GetTrainDoorOpenRatio(j, 0) > 0.05 do
        SetCanClimbOnEntity(j, false)
        local H = GMT.getPlayerCoords()
        local I = StartExpensiveSynchronousShapeTestLosProbe(H.x, H.y, H.z, H.x, H.y, H.z - 5.0, -1, PlayerPedId(), 4)
        local n, J, n, n, K = GetShapeTestResult(I)
        local L = GetFrameTime()
        if J and K == j then
            DisableControlAction(0, 22, true)
            SetTrainDoorOpenRatio(j, 0, GetTrainDoorOpenRatio(j, 0) - 0.25 * L)
            SetTrainDoorOpenRatio(j, 2, GetTrainDoorOpenRatio(j, 2) - 0.25 * L)
            k = "PREPARE_DEPART_INTRO"
        else
            k = "ARRIVE_INTRO"
        end
        subtitleText("Enter the ~b~train~w~")
        Citizen.Wait(0)
    end
    ExecuteCommand("hideui")
    SetPlayerControl(PlayerId(), false, 0)
    local F =
        CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        -1071.7298583984,
        -2706.7395019531,
        -5.5527291297913,
        0.0,
        0.0,
        0.0,
        GetGameplayCamFov(),
        true,
        2
    )
    PointCamAtEntity(F, j, 0.0, 0.0, 0.0, true)
    SetCamActive(F, true)
    RenderScriptCams(true, true, 0, true, true)
    k = "DEPART_INTRO"
    p("tubeleaving")
    SetEntityInvincible(PlayerPedId(), true)
    Citizen.Wait(6000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    RenderScriptCams(false, false, 0, false, false)
    SetCamActive(F, false)
    DestroyCam(F, false)
    local M = GetPedInVehicleSeat(j, -1)
    DeleteEntity(M)
    DeleteMissionTrain(j)
    DeleteEntity(j)
    j = nil
end
local function N()
    qA("Starting the markers sequence")
    TriggerEvent("GMT:Announce", "FOLLOW THE YELLOW MARKERS!")
    h = "Yo welcome brother Im CJ and Im gonna help you settle in"
    r(vector3(-1040.8200683594, -2742.2243652344, 12.5), vector3(-1054.2639160156, -2766.0249023438, 3.0))
    h = "You are at Heathrow Airport, Make your way by following the yellow markers to get on the tube."
    r(vector3(-1054.2639160156, -2766.0249023438, 3.0), vector3(-1032.3704833984, -2773.8217773438, 3.0))
    h = "You can open your phone by pressing ~y~[K]~w~, Pressing ~y~[ESC]~w~ will close the phone."
    r(vector3(-1032.3704833984, -2773.8217773438, 3.0), vector3(-1014.4043579102, -2752.3588867188, -0.5))
    h = "Open your inventory by pressing ~y~[L]~w~, Pressing ~y~[L]~w~ will close the inventory."
    r(vector3(-1014.4043579102, -2752.3588867188, -0.5), vector3(-1061.8685302734, -2717.7609863282, -0.5))
    h = "Follow the markers to get on the damn tube!"
    r(vector3(-1061.8685302734, -2717.7609863282, -0.5), vector3(-1075.8397216796, -2728.1538085938, -0.5))
    h = nil
    p("tubearriving")
    Citizen.CreateThreadNow(function()
        w(-1135.8150634766, -2806.2873535156, -8.3283023834229)
        k = "ARRIVE_INTRO"
    end)
    r(vector3(-1075.8397216796, -2728.1538085938, -0.5), vector3(-1080.8995361328, -2715.8703613282, -0.5))
    h = "Hurry up fool!"
    r(vector3(-1080.8995361328, -2715.8703613282, -0.5), vector3(-1063.7435302734, -2699.1303710938, -9.4100732803344))
    h = nil
    r(vector3(-1063.7435302734, -2699.1303710938, -8.4100732803344),vector3(-1063.7435302734, -2699.1303710938, -8.4100732803344))
    while DoesEntityExist(j) and GetTrainDoorOpenRatio(j, 0) < 0.95 do
        Citizen.Wait(0)
    end
end
local function O()
    local P = tGMT.addMarker(b.x, b.y, b.z, 1.0, 1.0, 1.0, 50, 205, 50, 150, 50, 32, false, false, true)
    local Q = RequestScaleformMovie("mp_mission_name_freemode")
    while not HasScaleformMovieLoaded(Q) do
        Citizen.Wait(0)
    end
    BeginScaleformMovieMethod(Q, "SET_MISSION_INFO")
    ScaleformMovieMethodAddParamTextureNameString("GMT TUTORIAL")
    ScaleformMovieMethodAddParamTextureNameString("~g~Welcome to GMT")
    ScaleformMovieMethodAddParamTextureNameString("0")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("0")
    ScaleformMovieMethodAddParamTextureNameString("0")
    ScaleformMovieMethodAddParamTextureNameString("~g~Press [E] begin!")
    EndScaleformMovieMethod()
    local E = PlayerPedId()
    while true do
        local R = #(GMT.getPlayerCoords() - b)
        if R < 3.0 then
            DrawScaleformMovie(Q, 0.5, 0.35, 0.3, 0.4615, 255, 255, 255, 255, 0)
            drawNativeNotification("~g~Press ~INPUT_PICKUP~ to start the tutorial")
            if IsControlJustPressed(0, 51) then
                break
            end
        elseif R > 20.0 then
            SetEntityCoordsNoOffset(E, a.x, a.y, a.z, true, false, false)
        end
        Citizen.Wait(0)
    end
    tGMT.removeMarker(P)
    SetScaleformMovieAsNoLongerNeeded(Q)
    qA("Starting the phone sequence")
    GMT.loadAnimDict("cellphone@")
    GMT.loadModel("prop_amb_phone")
    p("ring")
    Citizen.Wait(1500)
    local H = GMT.getPlayerCoords()
    local S = CreateObject("prop_amb_phone", H.x, H.y, H.z, true, true, false)
    AttachEntityToEntity(S, E, GetPedBoneIndex(E, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 0, true)
    SetModelAsNoLongerNeeded("prop_amb_phone")
    TaskPlayAnim(E, "cellphone@", "cellphone_text_in", 3.0, -1, -1, 50, 0, false, false, false)
    Citizen.Wait(1500)
    TaskPlayAnim(E, "cellphone@", "cellphone_text_to_call", 3.0, -1, -1, 50, 0, false, false, false)
    p("herewegoagain")
    h = "~c~Ah shit, Here we go again."
    Citizen.Wait(2700)
    h = nil
    TaskPlayAnim(E, "cellphone@", "cellphone_call_out", 3.0, -1, -1, 50, 0, false, false, false)
    Citizen.Wait(1000)
    DeleteEntity(S)
    ClearPedTasks(E)
    RemoveAnimDict("cellphone@")
end
local function T()
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    local E = PlayerPedId()
    SetEntityVisible(E, false, false)
    FreezeEntityPosition(E, true)
    SetEntityCoordsNoOffset(E, a.x, a.y, a.z, true, false, false)
    SetEntityHeading(E, 146.0)
    local U = GetGameTimer()
    while GetNumberOfStreamingRequests() > 0 and GetGameTimer() - U < 10000 do
        Citizen.Wait(0)
    end
    SetEntityVisible(E, true, false)
    FreezeEntityPosition(E, false)
    DoScreenFadeIn(500)
    Citizen.Wait(500)
    qA("Starting gender stage")
    tGMT.OpenTutorialMenu()
end
local function V()
    qA("Starting the taxi sequence")
    h = "I called a taxi for you"
    local W = e[math.random(1, #e)]
    TaskGoStraightToCoord(PlayerPedId(), W[1].x, W[1].y, W[1].z, 1.5, -1, 0.0, 1.0)
    GMT.loadModel("taxi")
    l = CreateVehicle("taxi", W[1].x, W[1].y, W[1].z, W[3], true, true)
    DecorSetInt(l, decor, 955)
    SetEntityInvincible(l, true)
    SetModelAsNoLongerNeeded("taxi")
    local u =
        CreateCheckpoint(
        1,
        W[2].x,
        W[2].y,
        W[2].z,
        -515.47406005859,
        -264.78549194336,
        34.403575897217,
        2.0,
        204,
        204,
        1,
        100,
        0
    )
    local v = AddBlipForCoord(W[1].x, W[1].y, W[1].z)
    SetBlipFlashes(v, true)
    Citizen.Wait(2000)
    h = "Oh shit looks like he had to run! It should be parked pretty close"
    Citizen.Wait(1000)
    ClearPedTasks(PlayerPedId())
    Citizen.Wait(5000)
    h = "Get in the ~b~taxi~w~"
    while GMT.getPlayerVehicle() ~= l do
        Citizen.Wait(0)
    end
    h = nil
    DeleteCheckpoint(u)
    RemoveBlip(v)
end
local function X(Y, Z, _)
    local v = AddBlipForCoord(Y.x, Y.y, Y.z)
    SetBlipRoute(v, true)
    local u = CreateCheckpoint(1, Y.x, Y.y, Y.z, 0.0, 0.0, 0.0, 2.0, 204, 204, 1, 100, 0)
    local a0 = Z and 10.0 or 5.0
    while #(GMT.getPlayerCoords() - Y) > a0 do
        if _ then
            _()
        end
        Citizen.Wait(0)
    end
    RemoveBlip(v)
    DeleteCheckpoint(u)
end
local function a1()
    qA("Starting the dealership sequence")
    h = "Drive to ~y~Simeons~w~ to purchase your first vehicle"
    X(vector3(-47.785835266113, -1117.1357421875, 25.435224533081), true)
    DeleteEntity(GetPedInVehicleSeat(j, -1))
    DeleteMissionTrain(j)
    h = "Exit your ~b~vehicle~w~"
    local C = GMT.getPlayerVehicle()
    while GMT.getPlayerVehicle() ~= 0 do
        Citizen.Wait(0)
    end
    SetVehicleDoorsLocked(C, 2)
    SetVehicleDoorsLockedForAllPlayers(C, true)
    h = "Locate the ~y~store selector~w~"
    X(vector3(-34.113563537598, -1101.7242431641, 25.422456741333), false)
    while table.count(VehiclesFetchedTable) == 0 do
        if RageUI.Visible(RMenu:Get("cardealer", "mainmenu")) then
            i = "The category can determine the cars handling, power and price. Pick a category in your price range."
            h = "Select a vehicle category"
        elseif RageUI.Visible(RMenu:Get("cardealer", "categories")) then
            i = "Each category has an arrangement of stock and custom vehicles to pick from."
            h = "Select a vehicle to purchase or preview"
        elseif RageUI.Visible(RMenu:Get("cardealer", "vehicle")) then
            i = "Previewing a vehicle gives you a minute to test how the vehicle drives without upgrades."
            h = "Purchase or preview this vehicle"
        elseif RageUI.Visible(RMenu:Get("cardealer", "confirm")) then
            i = "Money will be taken from your bank account for this vehicle and it will be delivered to your garage."
            h = "Purchase this vehicle"
        elseif DoesEntityExist(testDriveCar) then
            i = "Previewing with no modifications. This will have improved performance if upgraded in LS Customs."
            h = "Experiment with the top speed, acceleration and cornering"
        else
            local a2 = #(vector3(-34.113563537598, -1101.7242431641, 25.422456741333) - GMT.getPlayerCoords()) <= 2.5
            if a2 then
                i = "To enter the store selector walk away from the marker and back into it."
            else
                i = "To enter the store selector walk into the marker."
            end
            h = "Enter the ~y~store selector~w~"
        end
        Citizen.Wait(0)
    end
    i = nil
    h = "Head outside of Simeons to get in your new vehicle"
    DeleteEntity(l)
end
local function a3()
    qA("Starting the garages sequence")
    i = "Garages can be located anywhere on the map, indicated by a green shutter icon."
    X(vector3(-50.955089569092,-1112.9544677734,26.43804359436), false)
    while table.count(globalVehicleModelHashMapping) == 0 or GMT.getPlayerVehicle() == 0 do
        if RageUI.Visible(RMenu:Get("GMTGarages", "main")) then
            i =
                "This is the main UI for any garage. From here you can get out or store a vehicle, view rented vehicles and configure custom folders."
            h = "Select Garages"
        elseif RageUI.Visible(RMenu:Get("GMTGarages", "owned_vehicles")) then
            i = "This lists all your garage types. For now you will only have the Standard Garage."
            h = "Select Standard Garage"
        elseif RageUI.Visible(RMenu:Get("GMTGarages", "owned_vehicles_submenu")) then
            i = "This lists all the vehicles you have bought for this garage type."
            h = "Select your newly purchased vehicle"
        elseif RageUI.Visible(RMenu:Get("GMTGarages", "owned_vehicles_submenu_manage")) then
            i = "You can spawn your vehicle, or choose to sell and rent it to another player here."
            h = "Press Spawn Vehicle"
        elseif RageUI.Visible(RMenu:Get("GMTGarages", "settings")) then
            i = nil
            h = "Go back to the main menu"
        elseif
            RageUI.Visible(RMenu:Get("GMTGarages", "rented_vehicles")) or
                RageUI.Visible(RMenu:Get("GMTGarages", "customfolders"))
         then
            RageUI.Visible(RMenu:Get("GMTGarages", "main"), true)
            notify("~r~This section is not avaliable during the tutorial")
        else
            local a2 = #(vector3(-51.893981933594, -1112.7712402344, 25.438014984131) - GMT.getPlayerCoords()) < 2.5
            if a2 then
                i = "To enter the garage walk away from the marker and back into it."
            else
                i = "To enter the garage walk into the marker."
            end
        end
        Citizen.Wait(0)
    end
    Citizen.Wait(1000)
    SetEntityInvincible(GMT.getPlayerVehicle(), true)
    i = nil
    h = nil
end
local function a6()
    qA("Starting the clothing sequence")
    i = "Clothing stores can be located anywhere on the map, indicated by a green shirt icon."
    h = "Drive to the marked ~y~clothing store~w~"
    X(vector3(131.44483947754, -197.50875854492, 53.463317871094), true)
    i = "Clothing stores can be used to change your character, outfit and gender."
    h = "Locate the ~y~clothing selector~w~"
    X(vector3(123.60697174072, -219.52917480469, 53.557830810547), false)
    local a7 = tGMT.getCustomization()
    local a8 = false
    while true do
        if not RageUI.IsAnyMenuOfTypeVisible("GMTclothing") then
            if a8 then
                break
            end
            local a2 = #(vector3(123.60697174072, -219.52917480469, 53.557830810547) - GMT.getPlayerCoords()) < 2.5
            if a2 then
                i = "To enter the clothing selector walk away from the marker and back into it."
            else
                i = "To enter the clothing selector walk into the marker."
            end
        else
            if RageUI.Visible(RMenu:Get("GMTclothing", "mainMenu")) then
                i = "This is the main UI for any clothing store. From here you can change your outfit and gender."
                h = "Select Clothes"
            elseif RageUI.Visible(RMenu:Get("GMTclothing", "changeClothing")) then
                i = "You can pick from an arrangement of stock and custom clothing. Scroll through to see each item."
                h = "Change your outfit"
            elseif RageUI.Visible(RMenu:Get("GMTclothing", "changePed")) then
                i = "You can change between a male and female body here. This will reset your outfit."
                h = "Change your gender or go back to pick an outfit"
            elseif RageUI.Visible(RMenu:Get("GMTclothing", "clearProps")) then
                i = "This can be used to remove accessories. You can also toggle them through the Y menu."
                h = "Go back to pick an outfit"
            end
            if not table.contentEquals(tGMT.getCustomization(), a7) then
                a8 = true
            end
        end
        Citizen.Wait(0)
    end
    h = "Once you're finished, return to your ~y~vehicle~w~."
    while GMT.getPlayerVehicle() == 0 do
        Citizen.Wait(0)
    end
    i = nil
    h = nil
end
local function a178()
    qA("Starting the barbers sequence")
    i = "Barbers can be found throughout the city, marked by a distinctive grey scissors icon on the map."
    h = "Drive to the designated ~y~barbershop~w~ location."
    X(vector3(-28.031188964844, -138.6298828125, 55.517011260986), true)
    i = "Barbershops offer a variety of services, including changes to your facial features, hair, and head type."
    h = "Find the ~y~barbershop marker~w~."
    X(vector3(-34.594581604004, -151.05613708496, 56.036498260498), false)
    i = "Press ~INPUT_PICKUP~ To Change your appearince"
    h = "Once you're finished, return to your ~y~vehicle~w~."
    while GMT.getPlayerVehicle() == 0 do
        Citizen.Wait(0)
    end
    i = nil
    h = nil
end
local function a9()
    qA("Starting the city hall sequence")
    h = "Drive to the ~y~City Hall~w~"
    local U = GetGameTimer()
    X(
        vector3(-511.79125976562, -262.69219970703, 34.451602935791),
        true,
        function()
            local aa = GetGameTimer()
            if aa - U < 10000 then
                i = "To start your career drive to the City Hall."
            elseif aa - U < 20000 then
                i = "You can apply to become a Police Officer, Medic, Prison Officer or Firefighter at a later date."
            elseif aa - U < 30000 then
                i = "Some jobs require a minimum amount of in-game hours in order to apply."
            elseif aa - U < 40000 then
                i = "Continue driving to the City Hall."
            end
        end
    )
    i = nil
    h = nil
end
local function ab()
    qA("Continuing the city hall sequence")
    i = "The City Hall is used to get a job, change your identity and to purchase licenses."
    h = "Head inside of the ~y~City Hall~w~"
    X(vector3(-551.80096435547, -193.8653717041, 37.219680786133), false)
    h = "Locate the ~y~Job Center Office~w~"
    X(vector3(-561.52203369141, -197.43280029297, 37.219356536865), false)
    h = "Head to the job selector"
    X(vector3(-566.19732666016, -193.69425964355, 37.219661712646), false)
    i = "Press ~INPUT_CONTEXT~ to open the job selector and pick your first job."
    h = "Start your first job by pressing ~y~[E]~w~"
    while not RageUI.Visible(RMenu:Get("main", "groupselector")) do
        Citizen.Wait(0)
    end
    i = nil
    h = nil
end
local function ae()
    i = "Rules can be found by pressing ~INPUT_FRONTEND_CANCEL~."
    h = "Open the ~b~pause menu~w~ by pressing ~y~[ESC]~w~"
    local a1 = GetGameTimer()
    local af = false
    while true do
        if af and GetGameTimer() - a1 > 10000 then
            break
        end
        if tGMT.isPauseMenuOpen() then
            af = true
        end
        Citizen.Wait(0)
    end
    i = nil
    h = nil
end
local function ac()
    local Q = RequestScaleformMovie("mp_mission_name_freemode")
    while not HasScaleformMovieLoaded(Q) do
        Citizen.Wait(0)
    end
    BeginScaleformMovieMethod(Q, "SET_MISSION_INFO")
    ScaleformMovieMethodAddParamTextureNameString("Press ESC for a quick starter guide and the rules to our server!")
    ScaleformMovieMethodAddParamTextureNameString("~g~Tutorial Complete")
    ScaleformMovieMethodAddParamTextureNameString("0")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("")
    ScaleformMovieMethodAddParamTextureNameString("0")
    ScaleformMovieMethodAddParamTextureNameString("0")
    ScaleformMovieMethodAddParamTextureNameString("")
    EndScaleformMovieMethod()
    p("questcomplete")
    qA("Setting complete tutorial flag")
    TriggerServerEvent("GMT:setCompletedTutorial")
    local U = GetGameTimer()
    while GetGameTimer() - U < 7000 do
        DrawScaleformMovie(Q, 0.5, 0.35, 0.3, 0.4615, 255, 255, 255, 255, 0)
        Citizen.Wait(0)
    end
    SetScaleformMovieAsNoLongerNeeded(Q)
end
function StartTutorial()
    qA("Starting the sequence", g)
    g = true
    ClearPedTasks(PlayerPedId())
    tGMT.setCanAnim(false)
    DoScreenFadeIn(500)
    if startingTutorial then
        T()
        O() 
        N()
        G()
        D()
        V()
        if table.count(VehiclesFetchedTable) == 0 or GMT.isDev() then
            if m > 20000 then
                a1()
            end
        else
            h = "Head to the marked garage to get a vehicle out"
        end
        if table.count(VehiclesFetchedTable) > 0 then
            a3()
        end
        ae()
        a6()
        a178()
        a9()
        ab()
        ac()
        tGMT.setCanAnim(true)
        g = false
    else
        TP2DEALERSHIP()
        tGMT.setCanAnim(true)
        g = false
    end
end
RegisterCommand("tutorial", function()
    if GMT.isDev() then
        startScreen()
    end
end, false)
RegisterNetEvent("GMT:playTutorial", startScreen)
AddEventHandler("GMT:onClientSpawn", function(ae, af)
    if af and not GMT.isInPurge() then
        Citizen.Wait(5000)
        qA("Checking completed stage")
        TriggerServerEvent("GMT:checkTutorial")
    end
end)
local function ag()
    if g then
        if h then
            drawNativeText(h)
        end
        if i then
            drawNativeNotification(i)
        end
        if j then
            if k == "ARRIVE_INTRO" or k == "ARRIVE_TAXI" or k == "PREPARE_DEPART_INTRO" then
                local ah = nil
                if k == "ARRIVE_INTRO" or k == "PREPARE_DEPART_INTRO" then
                    ah = c
                else
                    ah = d
                end
                local R = #(GetEntityCoords(j, true) - ah)
                local ai = R / 5.0
                local aj = false
                if ai > 10.0 then
                    ai = 10.0
                elseif ai < 1.0 then
                    ai = 0.0
                    FreezeEntityPosition(j, true)
                    aj = true
                end
                pcall(
                    function()
                        SetTrainSpeed(j, ai)
                        SetTrainCruiseSpeed(j, ai)
                    end
                )
                SetTrainsForceDoorsOpen(false)
                if aj and GetTrainDoorOpenRatio(j, 0) < 1.0 and k ~= "PREPARE_DEPART_INTRO" then
                    local L = GetFrameTime()
                    SetTrainDoorOpenRatio(j, 0, GetTrainDoorOpenRatio(j, 0) + 0.25 * L)
                    SetTrainDoorOpenRatio(j, 2, GetTrainDoorOpenRatio(j, 2) + 0.25 * L)
                end
            else
                local L = GetFrameTime()
                local ak = DecorGetFloat(j, "lastSpeed")
                if ak < 0.0 then
                    ak = 0.0
                end
                local al = ak + 3.0 * L
                if al > 15.0 then
                    al = 15.0
                end
                DecorSetFloat(j, "lastSpeed", al)
                pcall(
                    function()
                        FreezeEntityPosition(j, false)
                        SetTrainSpeed(j, al)
                        SetTrainCruiseSpeed(j, al)
                    end
                )
            end
        end
        if not GMT.isInPurge() then
            local E = PlayerPedId()
            if GetSelectedPedWeapon(E) ~= `WEAPON_UNARMED` then
                drawNativeNotification("Your weapon has been stored. You must complete the tutorial first.")
            end
            GMT.setWeapon(E, "WEAPON_UNARMED", true)
        end
    end
end
GMT.createThreadOnTick(ag)
RegisterNetEvent(
    "GMT:setIsNewPlayer",
    function()
        f = true
    end
)
function GMT.isNewPlayer()
    return f
end
function GMT.isInTutorial()
    return g
end
function tGMT.OpenTutorialMenu()
    if GMT.isInTutorial() then
        FreezeEntityPosition(PlayerPedId(), true)
        TriggerEvent("GMT:characterTutorial")
        DisableControlAction(0, 322, true)
    end
end
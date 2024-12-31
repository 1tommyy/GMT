local a = module("cfg/cfg_purge")
local b = a.coords[a.location]
local purgeActive = false
local players = 0
local cooldown = 0
local blip = nil
local checkpointCoords = vector3(199.17549133301, -933.71490478516, 30.686817169189)
local f

-- [[ Threads ]] --

Citizen.CreateThread(function()
    if GMT.isPurge() then
        local y = tGMT.addBlip(checkpointCoords, 1, 1, 429, "Purge Event")
        SetBlipColour(y, 1)
        SetBlipScale(y, 2.0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if GMT.isInPurge() then
           drawNativeNotification("You have entered GMT Purge! To leave return to Legion or Disconnect.")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if cooldown > 0 then
            cooldown = cooldown - 1
        end
    end
end)

Citizen.CreateThread(function()
    local Q = RequestScaleformMovie("mp_mission_name_freemode")
    while not HasScaleformMovieLoaded(Q) do
        Citizen.Wait(0)
    end
    RequestStreamedTextureDict("mpleaderboard", true)
    while not HasStreamedTextureDictLoaded("mpleaderboard") do
        Wait(0)
    end
    while true do
        Citizen.Wait(0)
        if GMT.isPurge() then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - checkpointCoords)
            if distance <= 50.0 then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local direction = vector3(playerCoords.x - checkpointCoords.x, playerCoords.y - checkpointCoords.y, 0)
                local rotation = vector3(0.0, 0.0, 270.0 - math.deg(math.atan2(direction.y, direction.x)))
                DrawMarker(1, checkpointCoords.x, checkpointCoords.y, checkpointCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 12.0, 12.0, 4.0, 255, 0, 0, 255, false, false, 2, false, false, false, false)                BeginScaleformMovieMethod(Q, "SET_MISSION_INFO")
                ScaleformMovieMethodAddParamPlayerNameString(GMT.isInPurge() and "Press [E] to exit" or "Press [E] to enter")
                ScaleformMovieMethodAddParamPlayerNameString("~y~gmt purge")
                ScaleformMovieMethodAddParamPlayerNameString("0")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("0")
                ScaleformMovieMethodAddParamPlayerNameString("0")
                ScaleformMovieMethodAddParamPlayerNameString(players == 1 and players .. " Player" or players.." Players")
                EndScaleformMovieMethod()
                DrawScaleformMovie_3dSolid(Q, checkpointCoords.x, checkpointCoords.y, checkpointCoords.z - 0.5, rotation.x, rotation.y, rotation.z, 4.0, 4.0, 1.0, 14.0, 14.0, 2.0, 2)
                if distance < 7.0 then
                    drawNativeNotification(GMT.isInPurge() and "Press ~INPUT_PICKUP~ to exit the purge" or "Press ~INPUT_PICKUP~ to enter the purge")
                    if IsControlJustPressed(0, 38) then
                        if cooldown == 0 then
                            cooldown = 30
                            if GMT.isInPurge() then
                                TriggerServerEvent('GMT:purgeActive', false)
                            else
                                TriggerServerEvent('GMT:purgeActive', true)
                                TriggerServerEvent('GMT:triggerPurgeSpawn')
                            end
                        else
                            GMT.notify("~r~You must wait " .. cooldown .. " seconds before making this decision.")
                        end
                    end
                end
            end
        end
    end
end)

-- [[ Functions ]] --

function GMT.isPurge()
    return GMTConfig.Purge
end

function GMT.isInPurge()
    return purgeActive
end

function tGMT.FrontendSound(sound, soundSet)
    PlaySoundFrontend(-1, sound, soundSet, true)
end

local function c()
    math.random()
    math.random()
    math.random()
    return b[math.random(1, #b)]
end

local d = false
function GMT.hasSpawnProtection()
    return d
end

local function e()
    d = true
    SetTimeout(10000, function()
            d = false
        end)
    Citizen.CreateThread(function()
        SetLocalPlayerAsGhost(true)
        while d do
            SetEntityProofs(PlayerPedId(), true, true, true, true, true, true, true, true)
            SetEntityAlpha(PlayerPedId(), 100, false)
            Wait(0)
        end
        SetEntityAlpha(PlayerPedId(), 255, false)
        SetLocalPlayerAsGhost(false)
        ResetGhostedEntityAlpha()
        GMT.notify("~g~Spawn protection ended!")
        SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
    end)
end

-- [[ Events ]] --

RegisterNetEvent("GMT:purge:catchData", function(playersInPurge,value)
    if GMT.isPurge() then
        purgeActive = value
        if value then
            blip = AddBlipForRadius(0.0, 0.0, 0.0, 50000.0)
            SetBlipColour(blip, 1)
            SetBlipAlpha(blip, 180)
        elseif not value then
            if blip then
                RemoveBlip(blip) 
                blip = nil 
            end
        end
        players = playersInPurge
    end
end)

RegisterNetEvent("GMT:purgeSpawnClient")
AddEventHandler("GMT:purgeSpawnClient", function(g)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    e()
    DoScreenFadeOut(250)
    GMT.showUI()
    Wait(500)
    TriggerScreenblurFadeIn(100.0)
    f = c()
    RequestCollisionAtCoord(f.x, f.y, f.z)
    local h = GetGameTimer()
    while HaveAllStreamingRequestsCompleted(PlayerPedId()) ~= 1 and GetGameTimer() - h < 5000 do
        Wait(0)
       -- print("[GMT] Waiting for streaming requests to complete!")
    end
    GMT.checkCustomization()
    TriggerServerEvent("GMT:getPlayerHairstyle")
    TriggerServerEvent("GMT:getPlayerTattoos")
    DoScreenFadeIn(1000)
    GMT.showUI()
    local i = GMT.getPlayerCoords()
    SetEntityCoordsNoOffset(PlayerPedId(), i.x, i.y, 1200.0, false, false, false)
    SetEntityVisible(PlayerPedId(), false, false)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), true, true)
    SetFocusPosAndVel(f.x, f.y, f.z + 1000, 0.0, 0.0, 0.0)
    spawnCam = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", f.x, f.y, f.z + 1000, 0.0, 0.0, 0.0, 65.0, 0, 2)
    SetCamActive(spawnCam, true)
    RenderScriptCams(true, true, 0, true, false)
    spawnCam2 = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", f.x, f.y, f.z, 0.0, 0.0, 0.0, 65.0, 0, 2)
    SetCamActiveWithInterp(spawnCam2, spawnCam, 5000, 0, 0)
    Wait(2500)
    ClearFocus()
    if not g then
        SetEntityCoords(PlayerPedId(), f.x, f.y, f.z)
    end
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerScreenblurFadeOut(2000.0)
    Wait(2000)
    DestroyCam(spawnCam, false)
    DestroyCam(spawnCam2, false)
    RenderScriptCams(false, true, 2000, 0, 0)
    tGMT.setHealth(200)
    TriggerServerEvent("GMT:purgeClientHasSpawned")
end)

RegisterNetEvent("GMT:purgeAnnounce",function()
    if GMT.isPurge() then
        PlaySound(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", false, 0, true)
        tGMT.announceMpBigMsg("~r~purge event has started!","To join go to Legion and enter the marker",15000)
    end
end)

-- [[ Commands ]] --

RegisterCommand("airport", function()
    if GMT.isInPurge() then
        local k = GMT.getPlayerCoords()
        GMT.notify("~g~Teleporting to airport... please wait.")
        Wait(10000)
        if k == GMT.getPlayerCoords() then
            tGMT.teleport(-1113.495, -2917.377, 13.94363)
            GMT.notify("~g~Teleported to airport, use /suicide to return to the purge.")
        else
            GMT.notify("~r~Teleportation failed, please remain still when teleporting.")
        end
    end
end)
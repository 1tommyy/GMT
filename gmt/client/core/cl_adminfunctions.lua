noclipActive = false
local a = nil
local b = 1
local c = 0
local d = false
local e = false
local f = {
    controls = {
        openKey = 288,
        goUp = 85,
        goDown = 38,
        turnLeft = 34,
        turnRight = 35,
        goForward = 32,
        goBackward = 33,
        reduceSpeed = 19,
        increaseSpeed = 21
    },
    speeds = {
        {label = "Very Slow", speed = 0.1},
        {label = "Slow", speed = 0.5},
        {label = "Normal", speed = 2},
        {label = "Fast", speed = 4},
        {label = "Very Fast", speed = 6},
        {label = "Extremely Fast", speed = 10},
        {label = "Extremely Fast v2.0", speed = 20},
        {label = "Max Speed", speed = 25}
    },
    offsets = {y = 0.5, z = 0.2, h = 3},
    bgR = 0,
    bgG = 0,
    bgB = 0,
    bgA = 80
}
local function g(h)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(h)
    EndTextCommandScaleformString()
end
local function i(j)
    ScaleformMovieMethodAddParamPlayerNameString(j)
end
local function k(l)
    local l = RequestScaleformMovie(l)
    while not HasScaleformMovieLoaded(l) do
        Citizen.Wait(1)
    end
    BeginScaleformMovieMethod(l, "CLEAR_ALL")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(1)
    i(GetControlInstructionalButton(1, f.controls.goBackward, true))
    i(GetControlInstructionalButton(1, f.controls.goForward, true))
    g("Go Forwards/Backwards")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(0)
    i(GetControlInstructionalButton(2, f.controls.reduceSpeed, true))
    i(GetControlInstructionalButton(2, f.controls.increaseSpeed, true))
    g("Increase/Decrease Speed (" .. f.speeds[b].label .. ")")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(f.bgR)
    ScaleformMovieMethodAddParamInt(f.bgG)
    ScaleformMovieMethodAddParamInt(f.bgB)
    ScaleformMovieMethodAddParamInt(f.bgA)
    EndScaleformMovieMethod()
    return l
end
local noclipStartPosition = vector3(0, 0, 0)
local noclipEndPosition = vector3(0, 0, 0)
local distanceTraveled = 0.0

function GMT.toggleNoclip()
    noclipActive = not noclipActive
    if IsPedInAnyVehicle(GMT.getPlayerPed(), false) then
        c = GetVehiclePedIsIn(GMT.getPlayerPed(), false)
    else
        c = GMT.getPlayerPed()
    end

    if noclipActive then
        noclipStartPosition = GetEntityCoords(c)
    else
        noclipEndPosition = GetEntityCoords(c)
    end
    SetEntityCollision(c, not noclipActive, not noclipActive)
    FreezeEntityPosition(c, noclipActive)
    SetEntityInvincible(c, noclipActive)
    SetVehicleRadioEnabled(c, not noclipActive)

    if IsPedInAnyVehicle(c, false) then
        local vehicle = GetVehiclePedIsIn(c, false)
        SetVehicleRadioEnabled(vehicle, not noclipActive)
    end

    if noclipActive then
        SetEntityVisible(GMT.getPlayerPed(), false, false)
        GMT.setRedzoneTimerDisabled(true)
    else
        SetEntityVisible(GMT.getPlayerPed(), true, false)
        GMT.setRedzoneTimerDisabled(false)
        TriggerServerEvent("GMT:sendNoclipData", noclipStartPosition, noclipEndPosition, formattedDistance)   
    end
end
TriggerEvent("chat:addSuggestion", "/staffdm", "Usage: /staffdm [permid]", {
    {name="permid", help="The PermID of the player you want to DM."}
})

RegisterKeyMapping("noclip", "Staff Noclip", "keyboard", "F4")
RegisterCommand("noclip",function()
    local a4 = GMT.getPlayerCoords()
    if not GMT.isInPurge() and GMT.getStaffLevel() >= 4 or GMT.isDev() then
        GMT.toggleNoclip()
    end
end)

Citizen.CreateThread(function()
    local m = k("instructional_buttons")
    local n = f.speeds[b].speed
    while true do
        if noclipActive then
            DrawScaleformMovieFullscreen(m)
            local o = 0.0
            local p = 0.0
            local r, s, t = table.unpack(tGMT.getPosition())
            local u, v, w = GMT.getCamDirection()
            if IsDisabledControlJustPressed(1, f.controls.reduceSpeed) then
                if b ~= 1 then
                    b = b - 1
                    n = f.speeds[b].speed
                end
                k("instructional_buttons")
            end
            if IsDisabledControlJustPressed(1, f.controls.increaseSpeed) then
                if b ~= 8 then
                    b = b + 1
                    n = f.speeds[b].speed
                end
                k("instructional_buttons")
            end
            if IsControlPressed(0, f.controls.goForward) then
                r = r + n * u
                s = s + n * v
                t = t + n * w
            end
            if IsControlPressed(0, f.controls.goBackward) then
                r = r - n * u
                s = s - n * v
                t = t - n * w
            end
            if IsControlPressed(0, f.controls.goUp) then
                p = f.offsets.z
            end
            if IsControlPressed(0, f.controls.goDown) then
                p = -f.offsets.z
            end
            local x = GetEntityHeading(c)
            SetEntityVelocity(c, 0.0, 0.0, 0.0)
            SetEntityRotation(c, u, v, w, 0, false)
            SetEntityHeading(c, x)
            SetEntityCoordsNoOffset(c, r, s, t, noclipActive, noclipActive, noclipActive)
        end
        Wait(0)
    end
end)

RegisterCommand('staffmode', function()
    if GMT.getStaffLevel() > 0 then
        if globalPreventStaff then
            GMT.notify("~r~You cannot staff on while in the pit.")
            return
        end
        status = not staffMode
        tGMT.staffMode(status)
        TriggerServerEvent("GMT:StaffModeLogs", status)
    end
end)

staffMode = false
local isInTicket = false
local a = {}
function tGMT.staffMode(status)
    if GMT.getStaffLevel() > 0 then
        if staffMode ~= status then
            staffMode = status
            if staffMode then
                local source = source
                local user_id = GMT.getUserId(source)
                local name = GMT.getPlayerName(GMT.getPlayerId())
                GMT.notify('~g~Staff Powerz enabled.')
                GMT.setRedzoneTimerDisabled(true)
                tGMT.RevivePlayer()
                 tGMT.setHealth(200)
                a = tGMT.getCustomization()

                if GMT.getModelGender() == "male" then
                    if GMT.isHalloween() then
                        GMT.loadCustomisationPreset("StaffHalloweenMale")
                        SetPedComponentVariation(PlayerPedId(), 11, 200, GMT.getStaffLevel(), 0)
                    elseif GMT.isChristmas() then
                        GMT.loadCustomisationPreset("StaffChristmasMale")
                        GMT.loadCustomisationPreset("StaffMale")
                        SetPedComponentVariation(PlayerPedId(), 11, 200, GMT.getStaffLevel(), 0)
                    else
                        GMT.loadCustomisationPreset("StaffMale")
                        SetPedComponentVariation(PlayerPedId(), 11, 200, GMT.getStaffLevel(), 0)
                    end
                elseif GMT.isHalloween() then
                    GMT.loadCustomisationPreset("StaffHalloweenFemale")
                    GMT.loadCustomisationPreset("StaffFemale")
                    SetPedComponentVariation(PlayerPedId(), 11, 202, GMT.getStaffLevel(), 0)
                elseif GMT.isChristmas() then
                    GMT.loadCustomisationPreset("StaffChristmasFemale")
                    GMT.loadCustomisationPreset("StaffFemale")
                    SetPedComponentVariation(PlayerPedId(), 11, 202, GMT.getStaffLevel(), 0)
                else
                    GMT.loadCustomisationPreset("StaffFemale")
                    SetPedComponentVariation(PlayerPedId(), 11, 202, GMT.getStaffLevel(), 0)
                end                                      
            else
                if not GMT.isInPurge() then
                    GMT.setRedzoneTimerDisabled(false)
                    SetEntityInvincible(PlayerPedId(), false)
                    SetPlayerInvincible(PlayerId(), false)
                    SetPedCanRagdoll(PlayerPedId(), true)
                    ClearPedBloodDamage(PlayerPedId())
                    ResetPedVisibleDamage(PlayerPedId())
                    ClearPedLastWeaponDamage(PlayerPedId())
                    SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
                    SetEntityCanBeDamaged(PlayerPedId(), true)
                end
                tGMT.setCustomization(a)
                GMT.notify('~r~Staff Powerz disabled.')
            end
        end
    end
end

function loadModel(r)
  local s
  if type(r)~="string"then 
      s=r 
  else 
      s=GetHashKey(r)
  end
  if IsModelInCdimage(s)then 
      if not HasModelLoaded(s)then 
          RequestModel(s)
          while not HasModelLoaded(s)do 
              Wait(0)
          end 
      end
      return s 
  else 
      return nil 
  end 
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        if staffMode then 
            local B=PlayerPedId()
            SetEntityInvincible(B,true)
            SetPlayerInvincible(PlayerId(),true)
            SetPedCanRagdoll(B,false)
            ClearPedBloodDamage(B)
            ResetPedVisibleDamage(B)
            ClearPedLastWeaponDamage(B)
            SetEntityProofs(B,true,true,true,true,true,true,true,true)
            SetEntityCanBeDamaged(B,false)
            if not GMT.isInPurge() then
                tGMT.setHealth(200)
            end
            if not isInTicket then
                drawNativeText("~r~Reminder: You are /staffon'd.", 255, 0, 0, 255, true)
            end
        end
    end
end)

RegisterNetEvent('GMT:sendTicketInfo')
AddEventHandler('GMT:sendTicketInfo', function(permid, name, reason)
    if permid ~= nil and name ~= nil then
        isInTicket = true
    else
        isInTicket = false
    end
    while isInTicket do
        Wait(0)
        if permid ~= nil and name ~= nil then
            drawNativeText("~y~You've taken the ticket of " ..name.. "("..permid..")\n~o~Reason: " .. reason, 255, 0, 0, 255, true)   
        end
    end
end)

RegisterCommand("fix", function()
    if (tGMT.isStaffedOn() and GMT.getStaffLevel() >= 6 or GMT.isDev()) then
        TriggerServerEvent("wk:fixVehicle")
    end
end)

RegisterNetEvent("wk:fixVehicle")
AddEventHandler("wk:fixVehicle", function()
    local p = PlayerPedId()
    if IsPedInAnyVehicle(p) then
        local q = GetVehiclePedIsIn(p)
        SetVehicleEngineHealth(q, 9999)
        SetVehiclePetrolTankHealth(q, 9999)
        SetVehicleFixed(q)
        GMT.notify('~g~Fixed Vehicle')
    else
        GMT.notify('~r~You are not in a vehicle')
    end
end)


function GMT.staffBlips(P)
    if GMT.getStaffLevel() >= 6 then
        d = P
        if d then
            GMT.notify("~g~Blips enabled")
        else
            GMT.notify("~r~Blips disabled")
            for Q, R in ipairs(GetActivePlayers()) do
                local S = GetPlayerPed(R)
                if GetPlayerPed(R) ~= GMT.getPlayerPed() then
                    S = GetPlayerPed(R)
                    blip = GetBlipFromEntity(S)
                    RemoveBlip(blip)
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        if d then
            for Q, R in ipairs(GetActivePlayers()) do
                local I = GetPlayerPed(R)
                if I ~= PlayerPedId() then
                    local blip = GetBlipFromEntity(I)
                    local T = GetPlayerServerId(R)
                    local U = GMT.clientGetUserIdFromSource(T)
                    if not DoesBlipExist(blip) and not GMT.isUserHidden(U) then
                        blip = AddBlipForEntity(I)
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        local V = GetVehiclePedIsIn(I, false)
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(V)))
                        SetBlipNameToPlayerName(blip, R)
                        SetBlipScale(blip, 0.85)
                        SetBlipAlpha(blip, 255)
                    end
                end
            end
        end
        Wait(1000)
    end
end)

function GMT.hasStaffBlips()
    return d
end

globalIgnoreDeathSound = false
RegisterNetEvent("GMT:deathSound",function(E)
    local F = GMT.getPlayerCoords()
    local G = #(F - E)
    if not globalIgnoreDeathSound and G <= 15 then
        if GMT.getDeathSound() == "custom_death" then
            local song = GetResourceKvpString("gmt_custom_death_sound")
            GMT.playCustomSound(song, 5000)
        else
            SendNUIMessage({transactionType = GMT.getDeathSound()})
        end
    end
end)

function GMT.playCustomSound(H, duration)
    SendNUIMessage({type='djPlay',song=H,volume=90})
    Wait(duration)
    SendNUIMessage({type='djStop'})
end
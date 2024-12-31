local isWaterMonitorOn = false
local aC = 3 
local fires = {}
local fireTables = {}
local supplyLines = {}
local hoses = {}
local monitors = {}
local tents = {}
local cushions = {}
local stabilisers = {}
local fans = {}
local throwBags = {}
local liftingEntities = {}
local particleLocations = {}
local vehicleDoors = {}
local props = {}
local Jacks = {}
local Chocks = {}

RegisterServerEvent("GMT:spawnThrowBag")
AddEventHandler("GMT:spawnThrowBag", function(t, aq, bT)
    local throwBag = {t = t, aq = aq, bT = bT}
    table.insert(throwBags, throwBag)
    TriggerClientEvent("GMT:spawnThrowBag", -1, t, aq, bT)
end)

RegisterServerEvent("GMT:lfbHandlingLifting")
AddEventHandler("GMT:lfbHandlingLifting", function(bm, by, bz)
    local liftingEntity = {bm = bm, by = by, bz = bz}
    table.insert(liftingEntities, liftingEntity)
    TriggerClientEvent("GMT:lfbHandlingLifting", -1, bm, by, bz)
end)

RegisterServerEvent("GMT:lfbLiftingFreeze")
AddEventHandler("GMT:lfbLiftingFreeze", function(bm)
    for i, entity in ipairs(liftingEntities) do
        if entity.bm == bm then
            entity.isFrozen = true
        end
    end
    TriggerClientEvent("GMT:lfbLiftingFreeze", -1, bm)
end)

RegisterServerEvent("GMT:updateJackTable")
AddEventHandler("GMT:updateJackTable", function(jackId, jackData, removeJack)
    if removeJack then
        Jacks[jackId] = nil
    else
        Jacks[jackId] = jackData
    end

    TriggerClientEvent("GMT:updateJackTable", -1, jackId, Jacks[jackId], removeJack)
end)

RegisterServerEvent("GMT:updateChockTable")
AddEventHandler("GMT:updateChockTable", function(chockId, chockData, removeChock)
    if removeChock then
        Chocks[chockId] = nil
    else
        Chocks[chockId] = chockData
    end

    TriggerClientEvent("GMT:updateChockTable", -1, chockId, Chocks[chockId], removeChock)
end)

RegisterServerEvent("GMT:toggleChockWheels")
AddEventHandler("GMT:toggleChockWheels", function(vehicleId)
    TriggerClientEvent("GMT:toggleChockWheels", -1, vehicleId)
end)

RegisterServerEvent("GMT:createLFBPropLog")
AddEventHandler("GMT:createLFBPropLog", function(propName, propCoords)
    print("Prop " .. propName .. " created at " .. tostring(propCoords))
end)

RegisterServerEvent("GMT:deleteProp")
AddEventHandler("GMT:deleteProp", function(propId)
    if props[propId] then
        props[propId] = nil
        print("Prop " .. propId .. " deleted.")
    end
end)

RegisterServerEvent("GMT:updateStabilisersTable")
AddEventHandler("GMT:updateStabilisersTable", function(stabiliserId, stabiliserData, removeStabiliser)
    if removeStabiliser then
        stabilisers[stabiliserId] = nil
    else
        stabilisers[stabiliserId] = stabiliserData
    end

    TriggerClientEvent("GMT:updateStabilisersTable", -1, stabiliserId, stabilisers[stabiliserId], removeStabiliser)
end)

RegisterServerEvent("GMT:removeVehicleStablisers")
AddEventHandler("GMT:removeVehicleStablisers", function(vehicleId)
    for stabiliserId, stabiliserData in pairs(stabilisers) do
        if stabiliserData.vehicleId == vehicleId then
            stabilisers[stabiliserId] = nil
        end
    end
end)

RegisterServerEvent("GMT:updateFansTable")
AddEventHandler("GMT:updateFansTable", function(fanId, fanData, removeFan)
    if removeFan then
        fans[fanId] = nil
    else
        fans[fanId] = fanData
    end

    TriggerClientEvent("GMT:updateFansTable", -1, fanId, fans[fanId], removeFan)
end)

RegisterServerEvent("GMT:stopRtcParticles")
AddEventHandler("GMT:stopRtcParticles", function(playerCoords)
    table.insert(particleLocations, playerCoords)
    TriggerClientEvent("GMT:stopRtcParticles", -1, playerCoords)
end)

RegisterServerEvent("GMT:rtcOpenDoor")
AddEventHandler("GMT:rtcOpenDoor", function(vehicleId, doorIndex, playerCoords, breakDoor)
    local vehicleDoor = {vehicleId = vehicleId, doorIndex = doorIndex, playerCoords = playerCoords, breakDoor = breakDoor}
    table.insert(vehicleDoors, vehicleDoor)
    TriggerClientEvent("GMT:rtcOpenDoor", -1, vehicleId, doorIndex, playerCoords, breakDoor)
end)

RegisterServerEvent("GMT:updateCushionsTable")
AddEventHandler("GMT:updateCushionsTable", function(cushionId, cushionData, removeCushion)
    if removeCushion then
        cushions[cushionId] = nil
    else
        cushions[cushionId] = cushionData
    end

    TriggerClientEvent("GMT:updateCushionsTable", -1, cushionId, cushions[cushionId], removeCushion)
end)

RegisterServerEvent("GMT:updateFansTable")
AddEventHandler("GMT:updateFansTable", function(fanId, fanData, removeFan)
    if removeFan then
        fans[fanId] = nil
    else
        fans[fanId] = fanData
    end

    TriggerClientEvent("GMT:updateFansTable", -1, fanId, fans[fanId], removeFan)
end)

RegisterServerEvent("GMT:updateTentsTable")
AddEventHandler("GMT:updateTentsTable", function(tentId, tentData, removeTent)
    if removeTent then
        tents[tentId] = nil
    else
        tents[tentId] = tentData
    end

    TriggerClientEvent("GMT:updateTentsTable", -1, tentId, tents[tentId], removeTent)
end)

RegisterServerEvent("GMT:toggleWaterTents")
AddEventHandler("GMT:toggleWaterTents", function(tentId)
    if tents[tentId] then
        tents[tentId][8] = not tents[tentId][8]
    end

    TriggerClientEvent("GMT:toggleWaterTents", -1, tentId, tents[tentId][8])
end)

RegisterServerEvent("GMT:adjustPitchServer")
AddEventHandler("GMT:adjustPitchServer", function(monitorId, pitchChange)
    if monitors[monitorId] then
        monitors[monitorId].pitch = monitors[monitorId].pitch + pitchChange
    end

    TriggerClientEvent("GMT:adjustPitchClient", -1, monitorId, monitors[monitorId].pitch)
end)

RegisterServerEvent("GMT:toggleWaterServer")
AddEventHandler("GMT:toggleWaterServer", function(monitorId)
    if monitors[monitorId] then
        monitors[monitorId].waterOn = not monitors[monitorId].waterOn
    end

    TriggerClientEvent("GMT:toggleWaterClient", -1, monitorId, monitors[monitorId].waterOn)
end)

RegisterServerEvent("GMT:updateMonitorsTable")
AddEventHandler("GMT:updateMonitorsTable", function(monitorId, monitorData, removeMonitor)
    if removeMonitor then
        monitors[monitorId] = nil
    else
        monitors[monitorId] = monitorData
    end

    TriggerClientEvent("GMT:updateMonitorsTable", -1, monitorId, monitors[monitorId], removeMonitor)
end)

RegisterServerEvent("GMT:hoseUpdateServer")
AddEventHandler("GMT:hoseUpdateServer", function(hoseId, hoseData, removeHose)
    if removeHose then
        hoses[hoseId] = nil
    else
        hoses[hoseId] = hoseData
    end

    TriggerClientEvent("GMT:hoseUpdate", -1, hoseId, hoses[hoseId], removeHose)
end)

RegisterServerEvent("GMT:updateSupplyLineTable")
AddEventHandler("GMT:updateSupplyLineTable", function(supplyLineId, supplyLineData, removeSupplyLine)
    if removeSupplyLine then
        supplyLines[supplyLineId] = nil
    else
        supplyLines[supplyLineId] = supplyLineData
    end

    TriggerClientEvent("GMT:updateSupplyLines", -1, supplyLineId, supplyLines[supplyLineId], removeSupplyLine)
end)

RegisterServerEvent("GMT:lfbDeleteSupplyLine")
AddEventHandler("GMT:lfbDeleteSupplyLine", function(supplyLineId)
    if supplyLines[supplyLineId] then
        supplyLines[supplyLineId] = nil
        TriggerClientEvent("GMT:supplyLineRemoved", -1, supplyLineId)
    end
end)

local v, w, x, y, z, A, B, C, D = {}, {}, {}, {}, {}, {}, {}, {}, {} 

RegisterServerEvent("GMT:sendLFBTables")
AddEventHandler("GMT:sendLFBTables", function()
    v = nil
    w = nil
    x = nil
    y = nil
    z = nil
    A = nil
    B = nil
    C = nil
    D = nil

    TriggerClientEvent("GMT:receiveLFBTables", source, v, w, x, y, z, A, B, C, D)
end)

local v = v or {}

RegisterServerEvent("GMT:updateFireTableServer")
AddEventHandler("GMT:updateFireTableServer", function(R, S, T, U)
    if T then
        if v[R] and v[R].active then
            v[R] = nil
        end
    elseif U then
        if v[R] and S.size then
            v[R].size = S.size
        end
    else
        v[R] = S
    end
    TriggerClientEvent("GMT:updateFireTable", source, R, S, T, U)
end)

RegisterServerEvent("GMT:updateFireTable")
AddEventHandler("GMT:updateFireTable", function(fireId, fireData, removeFire, updateFire)
    if removeFire then
        fires[fireId] = nil
    elseif updateFire then
        if fires[fireId] then
            fires[fireId].size = fireData.size
        end
    else
        fires[fireId] = fireData
    end

    TriggerClientEvent("GMT:updateFires", -1, fireId, fires[fireId], removeFire, updateFire)
end)

RegisterServerEvent("GMT:updateFireOptions")
AddEventHandler("GMT:updateFireOptions", function(autoFires, fireSize, fireCooldown)
    print("Received fire options: autoFires=" .. tostring(autoFires) .. ", fireSize=" .. tostring(fireSize) .. ", fireCooldown=" .. tostring(fireCooldown))
    TriggerClientEvent("GMT:updateFireTable", -1, autoFires, fireSize, fireCooldown, true)
end)

RegisterServerEvent("GMT:stopAllFires")
AddEventHandler("GMT:stopAllFires", function()
    fires = {}
    TriggerClientEvent("GMT:allFiresStopped", -1)
end)

function supplyLineNearby(playerCoords)
    local supplyLineCoords = {x = 1206.6981201172, y = -1448.4521484375, z = 34.670917510986} -- Testing on the water supply on the yellow thing outside the LFB station
    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(supplyLineCoords.x, supplyLineCoords.y, supplyLineCoords.z))
    local maxDistance = 30.0 

    if distance <= maxDistance then
        return true
    else
        return false
    end
end
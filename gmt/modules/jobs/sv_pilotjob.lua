local pilotJobUsers = {}
local pilotLevels = {}  

RegisterServerEvent("GMT:startPilotJob")
AddEventHandler("GMT:startPilotJob", function(planeIndex)
    local src = source
    local user_id = GMT.getUserId(src)
    print("Starting pilot job for plane index:", planeIndex)
    pilotJobUsers[user_id] = true
    TriggerClientEvent("GMT:pilotJobStarted", src, planeIndex)
    TriggerClientEvent("GMT:updateClientPilotLevel", src, pilotLevels[user_id] or 0)  -- Trigger to update client's pilot level
end)

RegisterServerEvent("GMT:setOnPilotDuty")
AddEventHandler("GMT:setOnPilotDuty", function(onDuty)
    local src = source
    local user_id = GMT.getUserId(src)
    pilotJobUsers[user_id] = onDuty
end)

RegisterServerEvent('GMT:pilotJobCreatePlane')
AddEventHandler('GMT:pilotJobCreatePlane', function(planeType, planeLoc, tugLoc)
    local src = source
    local user_id = GMT.getUserId(src)
    if pilotJobUsers[user_id] then 
        TriggerClientEvent('GMT:spawnVehicle', src, planeType, planeLoc, tugLoc, true, true, true, 100)
    else
        print("User " .. user_id .. " tried to create a plane but is not on the pilot job.")
    end
end)

RegisterCommand('setpilotduty', function(source, args, rawCommand)
    local src = source
    local user_id = GMT.getUserId(src)
    TriggerClientEvent('GMT:setOnPilotDuty', src, true)
end)

RegisterNetEvent("GMT:getPilotLevel")
AddEventHandler("GMT:getPilotLevel", function()
    local src = source
    local user_id = GMT.getUserId(src)
    local level = pilotLevels[user_id] or 0  

    TriggerClientEvent("GMT:updateClientPilotLevel", src, level)
end)

RegisterServerEvent('GMT:pilotJobReset')
AddEventHandler('GMT:pilotJobReset', function()
    local src = source
    local user_id = GMT.getUserId(src)
    pilotJobUsers[user_id] = false
    print("User " .. user_id .. " has ended their shift.")
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local user_id = GMT.getUserId(src)
    if pilotJobUsers[user_id] then
        print("User " .. user_id .. " was on the pilot job but has disconnected.")
        pilotJobUsers[user_id] = nil
        pilotLevels[user_id] = nil  
    end
end)

RegisterServerEvent('GMT:increasePilotLevel')
AddEventHandler('GMT:increasePilotLevel', function(levelIncrease)
    local src = source
    local user_id = GMT.getUserId(src)
    if pilotJobUsers[user_id] then
        pilotLevels[user_id] = (pilotLevels[user_id] or 0) + levelIncrease
        print("User " .. user_id .. " has increased their pilot level to " .. pilotLevels[user_id])
        TriggerClientEvent("GMT:updateClientPilotLevel", src, pilotLevels[user_id])  -- Update client's pilot level
    end
end)
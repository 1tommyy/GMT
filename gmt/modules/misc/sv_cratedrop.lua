local crateLocations = {
    vector3(2558.714, 6155.399, 161.8665), -- Rebel 
    vector3(375.0662, 6852.992, 4.083869), -- Paleto 
    vector3(-880.6389, 4414.064, 20.36799), -- Large arms
    vector3(-3032.489, 3402.802, 8.417397), -- mil base 
    vector3(-119.2925, 3022.1, 32.18053), -- diamond mine river
    vector3(36.50002, 4344.443, 41.47789), -- Large arms bridge
    vector3(499.4316, 5536.806, 777.696), -- mount chilliad
    vector3(-1518.191, 2140.92, 55.53791), -- wine mansion
    vector3(-191.0104, 1477.419, 288.4325), -- Vinewood 1
    vector3(828.4253, 1300.878, 363.6823), -- Vinewood sign
    vector3(2348.622, 2138.061, 104.3607), -- wind turbines
    vector3(1877.604, 352.0831, 162.9319), -- Vinewood lake
    vector3(2836.016, -1447.626, 10.45845), -- island near lsd
    vector3(2543.626, 3615.884, 96.89672), -- Youtool hill
    vector3(2856.744, 4631.319, 48.39237), -- H Bunker
    vector3(4784.917, -5530.945, 19.46264), -- Cayo Perico
    vector3(254.3428, 3583.882, 33.73079), -- Biker city
}
local rigLocations = {
    vector3(-1716.5004882812,8886.94921875,27.144144058228), -- oil rig
}
local activeCrates = {}
local spawnTime = 20*60 -- Time between each airdrop (Its a 20min timer)

local availableItems = {
    {"wbody|WEAPON_UMP45", 1},
    {"wbody|WEAPON_SHANK", 1},
    {"9mm Bullets", 250},
    {"wbody|WEAPON_MOSIN", 1},
    {"Morphine", 1},
    {"Taco", 1},
    {"wbody|WEAPON_AKKAL", 1},
    {"7.62mm Bullets", 250},
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for k,v in pairs(activeCrates) do
            if activeCrates[k].timeTillOpen > 0 then
                activeCrates[k].timeTillOpen = activeCrates[k].timeTillOpen - 1
            end
        end
    end
end)


AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
       if next(activeCrates) then
            for k,v in pairs(activeCrates) do
                local location = v.oilrig and rigLocations[k] or crateLocations[k]
                if location then
                    TriggerClientEvent('GMT:addCrateDropRedzone', source, v, location)
                end
            end
       end
    end
end)

local crateLoot = {}

function ProcessCrateDrop(name)
    if not string.find(name, "CrateDrop") then return end
    local crateID = string.gsub(name, "CrateDrop", "")
    crateID = tonumber(crateID)
    TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "The Crate drop has been looted!", "alert")
    TriggerClientEvent("GMT:removeLootcrate", -1, crateID)
    activeCrates[crateID] = nil
end

RegisterServerEvent('GMT:openCrate', function(crateID)
    local source = source
    local user_id = GMT.getUserId(source)
    --if activeCrates[crateID] == nil then return end
    print("open crate", crateID)
    if not crateLocations[crateID] and not rigLocations[crateID] then 
        return 
    end
    if activeCrates[crateID] and activeCrates[crateID].timeTillOpen > 0 then
        GMT.notify(source, '~r~Loot crate unlocking in '..activeCrates[crateID].timeTillOpen..' seconds.')
    else
        if not GMTclient.InMainEvent(user_id) and (crateLocations[crateID] and #(GetEntityCoords(GetPlayerPed(source)) - crateLocations[crateID]) < 3.5) or (rigLocations[crateID] and #(GetEntityCoords(GetPlayerPed(source)) - rigLocations[crateID]) < 3.5) then
            local name = "CrateDrop"..crateID
            if not crateLoot[crateID] then
                local lootAmount = nil
                if activeCrates[crateID].oilrig then
                    lootAmount = 9
                else
                    lootAmount = 5
                end
                local loot = {}
                while lootAmount > 0 do
                    local randomItem = math.random(1, #availableItems)
                    for k,v in pairs(availableItems) do
                        if k == randomItem then
                            if loot[v[1]] then
                                loot[v[1]].amount = loot[v[1]].amount + v[2]
                            else
                                loot[v[1]] = {amount = v[2]}
                            end
                            -- GMT.giveInventoryItem(user_id, v[1], v[2], true)
                        end
                    end
                    lootAmount = lootAmount - 1
                end
                crateLoot[crateID] = true
                LootBagEntities[name] = {}
                LootBagEntities[name].name = "CrateDrop"
                LootBagEntities[name].Items = loot
                LootBagEntities[name][3] = true;
                LootBagEntities[name][5] = source
                GMT.giveMoney(user_id,math.random(100000,250000))
            end
            local anims = {
                {'amb@medic@standing@kneel@base', 'base', 1},
                {'anim@gangops@facility@servers@bodysearch@', 'player_search', 1},
            }
            GMTclient.playAnim(source,{true,anims,false})
            Wait(500)
            if table.count(LootBagEntities[name].Items) == 0 then
                TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "The Crate drop has been looted!", "alert")
                TriggerClientEvent("GMT:removeLootcrate", -1, crateID)
                activeCrates[crateID] = nil
                return
            end
            OpenInv(source, name, LootBagEntities[name].Items)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(30 * 60 * 1000)
        local crateID = math.random(1, #crateLocations)
        local crateCoords = crateLocations[crateID]
        TriggerClientEvent('GMT:crateDrop', -1, crateCoords, crateID, false) -- Add 'false' as the third parameter
        activeCrates[crateID] = { oilrig = false, timeTillOpen = 300 }
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "A cartel plane carrying supplies has had to bail and is parachuting to the ground! Get to it quick, check your GPS!", "alert")
        Wait(20 * 60 * 1000)
        if activeCrates[crateID] then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "The airdrop has disappeared.", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("GMT:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(3 * 60 * 60 * 1000)
        local crateID = math.random(1, #rigLocations)
        local crateCoords = rigLocations[crateID]
        TriggerClientEvent('GMT:crateDrop', -1, crateCoords, crateID, true) -- Add 'true' as the third parameter
        activeCrates[crateID] = { oilrig = true, timeTillOpen = 300 }
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "An Oil Rig off the coast of paleto is hiding a hidden cache of high tier weaponry and sapphires. Get to it quick, check your GPS!", "alert")
        Wait(20 * 60 * 1000)
        if activeCrates[crateID] then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "The Oil Rig has been looted!", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("GMT:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    end
end)

RegisterCommand('startrig', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.GetStaffLevel(user_id) >=7 then
        local crateID = math.random(1, #rigLocations)
        local crateCoords = rigLocations[crateID]
        TriggerClientEvent('GMT:crateDrop', -1, crateCoords, crateID, true)
        activeCrates[crateID] = {oilrig = true, timeTillOpen = 300}
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "An Oil Rig off the coast of paleto is hiding a hidden cache of high tier weaponry and sapphires. Get to it quick, check your GPS!", "alert")
        Wait(20*60*1000)
        if activeCrates[crateID] ~= nil then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "The Oil Rig has disappeared.", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("GMT:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    else
        GMT.notify(source, {'You do not have permission to do this.'})
    end
end)

RegisterCommand('startdrop', function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.GetStaffLevel(user_id) >=7 then
        local crateID = math.random(1, #crateLocations)
        local crateCoords = crateLocations[crateID]
        TriggerClientEvent('GMT:crateDrop', -1, crateCoords, crateID, false)
        activeCrates[crateID] = {oilrig = false, timeTillOpen = 300}
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "A cartel plane carrying supplies has had to bail and is parachuting to the ground! Get to it quick, check your GPS!", "alert")
        Wait(20*60*1000)
        if activeCrates[crateID] ~= nil then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "The airdrop has disappeared.", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("GMT:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    else
        GMT.notify(source, {'You do not have permission to do this.'})
    end
end)
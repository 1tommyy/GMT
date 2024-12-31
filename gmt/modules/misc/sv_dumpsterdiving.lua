local lang = GMT.lang

local dumpsterItems = {
    [1] = {chance = 2, id = '7.62mm Bullets', name = 'Shaver', quantity = math.random(1,3)},
    -- ... other existing items with unique indices

    -- New items from your list with random quantities
    [1] = {chance = 3, id = 'repairkit', name = 'Repair Kit', quantity = math.random(1,3)},
    [2] = {chance = 2, id = 'Headbag', name = 'Head Bag', quantity = math.random(1,3)},
    [3] = {chance = 4, id = 'Wallet', name = 'Wallet', quantity = math.random(1,3)},
    [4] = {chance = 3, id = '7.62mm Bullets', name = '7.62mm Bullets', quantity = math.random(1,3)},
    [5] = {chance = 3, id = 'handcuffkeys', name = 'Handcuff Keys', quantity = math.random(1,3)},
    [6] = {chance = 3, id = 'handcuff', name = 'Handcuff', quantity = math.random(1,3)},
    [7] = {chance = 5, id = 'hackingDevice', name = 'Hacking Device', quantity = math.random(1,3)},
    [8] = {chance = 2, id = 'armourplate', name = 'Armour Plate', quantity = math.random(1,3)},
    [9] = {chance = 1, id = 'wbody|WEAPON_MOSIN', name = 'Mosin', quantity = math.random(1,2)}
    -- Add other items as needed
}

local function getRandomQuantity(min, max)
    return math.random(min, max)
end

RegisterServerEvent('GMT:item')
AddEventHandler('GMT:item', function(source)
    local user_id = GMT.getUserId(tonumber(source))
    local cash = getRandomQuantity(3000, 5000)
    local chance = math.random(1, 2)

    if chance == 2 then
        GMTclient.notify(source, {"~g~You find £" .. cash .. " inside the wallet"})
        GMT.giveMoney(user_id, 20000)
        if math.random(1, 40) == 20 then
            GMTclient.notify(source, {"~g~You found a Green Keycard inside the wallet"})
            GMT.giveInventoryItem(user_id, "green_keycard", 1, true) 
        end
    else
        GMTclient.notify(source, {"The wallet was empty"})
    end
    GMT.tryGetInventoryItem(user_id, "wallet", 1, false)
end)

RegisterServerEvent('GMT:startDumpsterTimer')
AddEventHandler('GMT:startDumpsterTimer', function(dumpster)
    if dumpster == nil then
        print("Error: No dumpster provided for GMT:startDumpsterTimer")
        return
    end

    SetTimeout(10 * 60000, function()
        if source then
            TriggerClientEvent('GMT:removeDumpster', source, dumpster)
        else
            print("Error: 'source' is null in GMT:startDumpsterTimer")
        end
    end)
end)



RegisterServerEvent('GMT:giveDumpsterReward')
AddEventHandler('GMT:giveDumpsterReward', function()
    local user_id = GMT.getUserId(source)
    local gotID = {}
    local rolls = math.random(1, 2)

    for i = 1, rolls do
        local item = dumpsterItems[math.random(1, #dumpsterItems)]
        if math.random(1, 10) >= item.chance and not gotID[item.id] then
            gotID[item.id] = true
            GMTclient.notify(source, {"~g~You find " .. item.quantity .. "x " .. item.name})
            GMT.giveInventoryItem(user_id, item.id, item.quantity, true)
        end
    end

    if not next(gotID) then
        GMTclient.notify(source, {"~r~You find nothing"})
    end
end)


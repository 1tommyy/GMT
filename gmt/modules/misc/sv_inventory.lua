MySQL = module("modules/database/MySQL")

local Inventory = module("GMTVeh", "cfg/cfg_inventory")
local Housing = module("gmt", "cfg/cfg_housing")
local Dumpster = {}
local InventorySpamTrack = {}
LootBagEntities = {}
local InventoryCoolDown = {}
local a = module("cfg/weapons")

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        if not InventorySpamTrack[source] then
            InventorySpamTrack[source] = true;
            local UserId = GMT.getUserId(source) 
            local data = GMT.getUserDataTable(UserId)
            if data and data.inventory then
                if type(data.inventory) == "string" then
                    data.inventory = json.decode(data.inventory)
                end
                local FormattedInventoryData = {}
                for i,v in pairs(data.inventory) do
                    FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                end
                if data.invcap == nil then
                    data.invcap = 30
                end
                GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
                    if cb then
                        if plathours > 0 and data.invcap < 50 then
                            data.invcap = 50
                        elseif plushours > 0 and data.invcap < 40 then
                            data.invcap = 40
                        end
                    end
                    TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(UserId))
                    InventorySpamTrack[source] = false;
                end)  
            else 
                --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
            end
        end
    end
end)

RegisterServerEvent("GMT:closeChest")
AddEventHandler("GMT:closeChest", function()
    local source = source
    local user_id = GMT.getUserId(source)
    TriggerClientEvent("GMT:endRobbingPlayer", source)
end)

RegisterNetEvent('GMT:FetchPersonalInventory')
AddEventHandler('GMT:FetchPersonalInventory', function()
    local source = source
    if not InventorySpamTrack[source] then
        InventorySpamTrack[source] = true;
        local UserId = GMT.getUserId(source) 
        local data = GMT.getUserDataTable(UserId)
        if data and data.inventory then
            local FormattedInventoryData = {}
            for i,v in pairs(data.inventory) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
            end
            TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(UserId))
            InventorySpamTrack[source] = false;
        else 
            --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
        end
    end
end)

RegisterNetEvent('GMT:FetchPersonalWeapons')
AddEventHandler('GMT:FetchPersonalWeapons', function()
    local source = source
    if not InventorySpamTrack[source] then
        InventorySpamTrack[source] = true
        local UserId = GMT.getUserId(source) 
        GMTclient.getWeapons(source, {}, function(weapons)
            if weapons then
                local FormattedWeaponData = {}
                for i, v in pairs(weapons) do
                    FormattedWeaponData[i] = {amount = v.amount, ItemName = GMT.getItemName(i)}
                end
                TriggerClientEvent('GMT:FetchPersonalWeapons', source, FormattedWeaponData)
                InventorySpamTrack[source] = false
            else 
                --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
            end
        end)
    end
end)

AddEventHandler('GMT:RefreshInventory', function(source)
    local UserId = GMT.getUserId(source) 
    local data = GMT.getUserDataTable(UserId)
    if data and data.inventory then
        local FormattedInventoryData = {}
        for i,v in pairs(data.inventory) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
        end
        TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(UserId))
        InventorySpamTrack[source] = false;
    else 
        --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)

RegisterNetEvent('GMT:GiveItem')
AddEventHandler('GMT:GiveItem', function(itemId, itemLoc)
    local source = source
    if not itemId then  GMT.notify(source, '~r~You need to select an item, first!') return end
    if itemLoc == "Plr" then
        GMT.RunGiveTask(source, itemId)
        TriggerEvent('GMT:RefreshInventory', source)
    else
        GMT.notify(source, '~r~You need to have this item on you to give it.')
    end
end)

RegisterNetEvent('GMT:GiveItemAll')
AddEventHandler('GMT:GiveItemAll', function(itemId, itemLoc)
    local source = source
    if not itemId then  GMT.notify(source, '~r~You need to select an item, first!') 
        return 
    end
    if itemLoc == "Plr" then
        GMT.RunGiveAllTask(source, itemId)
        TriggerEvent('GMT:RefreshInventory', source)
    else
        GMT.notify(source, '~r~You need to have this item on you to give it.')
    end
end)

RegisterNetEvent('GMT:TrashItem')
AddEventHandler('GMT:TrashItem', function(itemId, itemLoc)
    local source = source
    if not itemId then  GMT.notify(source, '~r~You need to select an item, first!') return end
    if itemLoc == "Plr" then
        GMT.RunTrashTask(source, itemId)
        TriggerEvent('GMT:RefreshInventory', source)
    else
        GMT.notify(source, '~r~You need to have this item on you to drop it.')
    end
end)

RegisterNetEvent('GMT:FetchTrunkInventory')
AddEventHandler('GMT:FetchTrunkInventory', function(spawnCode, owner_id)
    local source = source
    local user_id = GMT.getUserId(source)
    if not owner_id then owner_id = UserId end
    if not owner_id then owner_id = user_id end
    if InventoryCoolDown[source] then GMT.notify(source, '~r~Please wait before moving more items.') return end
    local carformat = "chest:u1veh_" .. spawnCode .. '|' .. owner_id
    GMT.getSData(carformat, function(cdata)
        local processedChest = {};
        cdata = json.decode(cdata) or {}
        local FormattedInventoryData = {}
        for i, v in pairs(cdata) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
        end
        local maxVehKg = Inventory.vehicle_chest_weights[spawnCode] or Inventory.default_vehicle_chest_weight
        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
        TriggerEvent('GMT:RefreshInventory', source)
    end)
end)

local inHouse = {}
RegisterNetEvent('GMT:FetchHouseInventory')
AddEventHandler('GMT:FetchHouseInventory', function(nameHouse)
    local source = source
    local user_id = GMT.getUserId(source)
    getUserByAddress(nameHouse, 1, function(huser_id)
        if huser_id == user_id or GMT.RecentlyRobbed(nameHouse) then
            inHouse[user_id] = nameHouse
            local homeformat = "chest:u" ..huser_id.. "home" ..inHouse[user_id]
            GMT.getSData(homeformat, function(cdata)
                local processedChest = {};
                cdata = json.decode(cdata) or {}
                local FormattedInventoryData = {}
                for i, v in pairs(cdata) do
                    FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                end
                local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
            end)
        else
            GMT.notify(source, "~r~You do not own this house!")
        end
    end)
end)

local inDumpster = {}
RegisterNetEvent('GMT:FetchDumpsterInventory')
AddEventHandler('GMT:FetchDumpsterInventory', function(nameDumpster)
    local source = source
    local user_id = GMT.getUserId(source)
    inDumpster[user_id] = nameDumpster
    local dumpsterformat = "chest:u" ..user_id.. "dumpster" ..inDumpster[user_id]
    GMT.getSData(dumpsterformat, function(cdata)
        local processedChest = {};
        cdata = json.decode(cdata) or {}

        cdata["wbody|WEAPON_MOSIN"] = {amount = 1}
        cdata["7.62mm Bullets"] = {amount = 255}

        local FormattedInventoryData = {}
        for i, v in pairs(cdata) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
        end
        local maxVehKg = 500
        TriggerClientEvent('GMT:callmemaybe', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
    end)
end)

local currentlySearching = {}

RegisterNetEvent('GMT:cancelPlayerSearch')
AddEventHandler('GMT:cancelPlayerSearch', function()
    local source = source
    local user_id = GMT.getUserId(source) 
    if currentlySearching[user_id] then
        TriggerClientEvent('GMT:cancelPlayerSearch', currentlySearching[user_id])
    end
end)

RegisterNetEvent('GMT:searchPlayer')
AddEventHandler('GMT:searchPlayer', function(playersrc)
    local source = source
    local user_id = GMT.getUserId(source) 
    local data = GMT.getUserDataTable(user_id)
    local their_id = GMT.getUserId(playersrc) 
    local their_data = GMT.getUserDataTable(their_id)
    if data and data.inventory and not currentlySearching[user_id] then
        currentlySearching[user_id] = playersrc
        TriggerClientEvent('GMT:startSearchingSuspect', source)
        TriggerClientEvent('GMT:startBeingSearching', playersrc, source)
        GMT.notify(playersrc, '~b~You are being searched.')
        Wait(10000)
        if currentlySearching[user_id] then
            local FormattedInventoryData = {}
            for i,v in pairs(data.inventory) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
            end
            exports['gmt']:execute("SELECT * FROM gmt_subscriptions WHERE user_id = @user_id", {user_id = user_id}, function(vipClubData)
                if #vipClubData > 0 then
                    if their_data and their_data.inventory then
                        local FormattedSecondaryInventoryData = {}
                        for i,v in pairs(their_data.inventory) do
                            FormattedSecondaryInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        if GMT.getMoney(their_id) > 0 then
                            FormattedSecondaryInventoryData['cash'] = {amount = GMT.getMoney(their_id), ItemName = 'Cash', Weight = 0.00}
                        end
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedSecondaryInventoryData, GMT.computeItemsWeight(their_data.inventory), 200)
                    end
                    if vipClubData[1].plathours > 0 then
                        TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(user_id)+20)
                    elseif vipClubData[1].plushours > 0 then
                        TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(user_id)+10)
                    else
                        TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(user_id))
                    end
                    GMT.sendDCLog('search-player', 'GMT Search Player Logs', "> Searchers Name: **"..GMT.getPlayerName(user_id).."**\n> Searchers TempID: **"..source.."**\n> Searchers PermID: **"..user_id.."**\n> Players TempID: **"..playersrc.."**\n> Players PermID: **"..their_id.."**")
                    TriggerClientEvent('GMT:InventoryOpen', source, true)
                    currentlySearching[user_id] = nil
                end
            end)
        end
    end
end)


-- rob player where it gives you their inventory
RegisterNetEvent('GMT:robPlayer')
AddEventHandler('GMT:robPlayer', function(playersrc)
    local source = source
    GMTclient.globalSurrenderring(playersrc, {}, function(globalSurrenderring) 
        if globalSurrenderring then
            TriggerClientEvent('GMT:startRobbingPlayer', playersrc)
            if not InventorySpamTrack[source] then
                InventorySpamTrack[source] = true;
                local user_id = GMT.getUserId(source) 
                local data = GMT.getUserDataTable(user_id)
                local their_id = GMT.getUserId(playersrc) 
                local their_data = GMT.getUserDataTable(their_id)
                if data and data.inventory then
                    local FormattedInventoryData = {}
                    for i,v in pairs(data.inventory) do
                        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                    end
                    TriggerClientEvent("GMT:endRobbingPlayer", playersrc)
                    TriggerClientEvent("GMT:endRobbingPlayer", source)
                    exports['gmt']:execute("SELECT * FROM gmt_subscriptions WHERE user_id = @user_id", {user_id = user_id}, function(vipClubData)
                        if #vipClubData > 0 then
                            if their_data and their_data.inventory then
                                local FormattedSecondaryInventoryData = {}
                                for i,v in pairs(their_data.inventory) do
                                    GMT.giveInventoryItem(user_id, i, v.amount)
                                    GMT.tryGetInventoryItem(their_id, i, v.amount)
                                end
                            end
                            if GMT.getMoney(their_id) > 0 then
                                GMT.AddStat(user_id,"amount_robbed",GMT.getMoney(their_id))
                                GMT.giveMoney(user_id, GMT.getMoney(their_id))
                                GMT.tryPayment(their_id, GMT.getMoney(their_id))
                            end
                            if vipClubData[1].plathours > 0 then
                                TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(user_id)+20)
                            elseif vipClubData[1].plushours > 0 then
                                TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(user_id)+10)
                            else
                                TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(user_id))
                            end
                            TriggerClientEvent('GMT:InventoryOpen', source, true)
                            InventorySpamTrack[source] = false;
                        end
                    end)
                else 
                    --print('An error has occured while trying to fetch inventory data from: ' .. user_id .. ' This may be a saving / loading data error you will need to investigate this.')
                end
            end
        else
            GMT.notify(source, '~r~This player is not on their knees.')
        end
    end)
end)

RegisterNetEvent('GMT:UseItem')
AddEventHandler('GMT:UseItem', function(itemId, itemLoc)
    local source = source
    local user_id = GMT.getUserId(source) 
    local data = GMT.getUserDataTable(user_id)
    if not itemId then 
        GMT.notify(source, '~r~You need to select an item, first!') 
        return
     end
    if itemLoc ~= "Plr" then
        GMT.notify(source, '~r~You need to have this item on you to use it.')
        return
    end
    GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            local invcap = 30
            if plathours > 0 then
                invcap = 50
            elseif plushours > 0 then
                invcap = 40
            end
            if GMT.getInventoryMaxWeight(user_id) then
                if GMT.getInventoryMaxWeight(user_id) > invcap then
                    return
                end
            end
            if itemId == "offwhitebag" then
                GMT.tryGetInventoryItem(user_id, itemId, 1, true)
                GMT.updateInvCap(user_id, invcap+15)
                TriggerClientEvent('GMT:boughtBackpack', source, 5, 92, 0,40000,15, 'Off White Bag (+15kg)')
            elseif itemId == "guccibag" then 
                GMT.tryGetInventoryItem(user_id, itemId, 1, true)
                GMT.updateInvCap(user_id, invcap+20)
                TriggerClientEvent('GMT:boughtBackpack', source, 5, 94, 0,60000,20, 'Gucci Bag (+20kg)')
            elseif itemId == "nikebag" then 
                GMT.tryGetInventoryItem(user_id, itemId, 1, true)
                GMT.updateInvCap(user_id, invcap+30)
            elseif itemId == "huntingbackpack" then 
                GMT.tryGetInventoryItem(user_id, itemId, 1, true)
                GMT.updateInvCap(user_id, invcap+35)
                TriggerClientEvent('GMT:boughtBackpack', source, 5, 91, 0,100000,35, 'Hunting Backpack (+35kg)')
            elseif itemId == "greenhikingbackpack" then 
                GMT.tryGetInventoryItem(user_id, itemId, 1, true)
                GMT.updateInvCap(user_id, invcap+40)
            elseif itemId == "rebelbackpack" then 
                GMT.tryGetInventoryItem(user_id, itemId, 1, true)
                GMT.updateInvCap(user_id, invcap+70)
                TriggerClientEvent('GMT:boughtBackpack', source, 5, 90, 0,250000,70, 'Rebel Backpack (+70kg)')
            elseif itemId == "Shaver" then 
                GMT.ShaveHead(source)
            -- elseif itemId == "rift2go" then 
            --     GMTclient.RiftIsAGo(source)
            --     GMT.tryGetInventoryItem(user_id, 'rift2go', 1)
            elseif itemId == "burnerphone" then 
                TriggerEvent("GMT:CreateDirtyCashDealer", user_id)
            elseif itemId == "handcuffkeys" then 
                GMT.handcuffKeys(source)
            elseif itemId == "armourplate" then 
                if GMT.hasGroup(user_id,"AdvancedRebel") then
                    GMT.ArmourPlate(source)
                else
                    GMT.notify(source,"~r~A advanced rebel license is required to apply armour!")
                end
            end
        end
    end) 
    GMT.RunInventoryTask(source, itemId)
    TriggerEvent('GMT:RefreshInventory', source)
end)

local alreadyEquiping = {}
RegisterNetEvent('GMT:EquipAll')
AddEventHandler('GMT:EquipAll', function()
    local source = source
    local user_id = GMT.getUserId(source) 
    if alreadyEquiping[user_id] then
        GMT.notify(source, '~r~You are already equiping all items')
        return
    end
    alreadyEquiping[user_id] = true
    local data = GMT.getUserDataTable(user_id)
    local sortedTable = {}
    for item,v in pairs(data.inventory) do
        if string.find(item, 'wbody|') or seizeBullets[item] then
            table.insert(sortedTable, item)
        end
    end
    table.sort(sortedTable, function(a,b) 
        if string.find(a, 'wbody|') and string.find(b, 'wbody|') then
            return a < b
        elseif string.find(a, 'wbody|') then
            return true
        elseif string.find(b, 'wbody|') then
            return false
        else
            return a < b
        end
    end)
    for _, item in ipairs(sortedTable) do
        if string.find(item:lower(), 'wbody|') then
            GMT.RunInventoryTask(source, item)
        elseif seizeBullets[item] then
            GMT.LoadAllTask(source, item)
        end
        Wait(500)
    end
    TriggerEvent('GMT:RefreshInventory', source)
    alreadyEquiping[user_id] = false
end)

local alreadyTransfering = {}
RegisterNetEvent("GMT:TransferAll")
AddEventHandler("GMT:TransferAll",function(spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    if not alreadyTransfering[user_id] then
        alreadyTransfering[user_id] = true
        local inventory = GMT.getUserDataTable(user_id).inventory
        local carformat = "chest:u1veh_" .. spawncode .. "|" .. user_id
        local maxVehKg = Inventory.vehicle_chest_weights[spawncode] or Inventory.default_vehicle_chest_weight
        GMT.getSData(carformat,function(cardata)
            cardata = json.decode(cardata) or {}
            local carweight = GMT.computeItemsWeight(cardata)
            for A,B in pairs(inventory) do
                local amount = B.amount
                local itemweight = GMT.getItemWeight(A)*amount
                if carweight+itemweight <= maxVehKg then
                    if GMT.tryGetInventoryItem(user_id,A,amount,true) then
                        if cardata[A] then
                            cardata[A].amount = cardata[A].amount + amount
                        else
                            cardata[A] = {}
                            cardata[A].amount = amount
                        end
                        local FormattedInventoryData = {}
                        for i, v in pairs(cardata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        TriggerClientEvent('GMT:SendSecondaryInventoryData',source,FormattedInventoryData,GMT.computeItemsWeight(cardata),maxVehKg)
                        carweight = carweight+itemweight
                        Wait(500)
                    end
                else
                    GMT.notify(source, '~r~You cannot move this item.')
                end
            end
            alreadyTransfering[user_id] = false
            GMT.setSData(carformat,json.encode(cardata))
        end)
    else
        GMT.notify(source, '~r~You are already transfering all items')
        return
    end
end)

RegisterNetEvent('GMT:MoveItem')
AddEventHandler('GMT:MoveItem', function(inventoryType, itemId, inventoryInfo, Lootbag, owner_id)
    local source = source
    local UserId = GMT.getUserId(source) 
    if not owner_id then owner_id = UserId end
    local data = GMT.getUserDataTable(UserId)
    if InventoryCoolDown[source] then GMT.notify(source, '~r~Please wait before moving more items.') return end
    if not itemId then GMT.notify(source, '~r~You need to select an item, first!') return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
            GMT.getSData(carformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = GMT.getInventoryWeight(UserId)+GMT.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('GMT:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        GMT.setSData(carformat, json.encode(cdata))
                    else 
                        InventoryCoolDown[source] = false;
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    InventoryCoolDown[source] = false;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end)
        elseif inventoryType == "LootBag" or inventoryType == "Crate" then  
            if itemId then  
                if LootBagEntities[inventoryInfo].Items[itemId] then 
                    local weightCalculation = GMT.getInventoryWeight(UserId)+GMT.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        if LootBagEntities[inventoryInfo].Items[itemId] and LootBagEntities[inventoryInfo].Items[itemId].amount > 1 then
                            LootBagEntities[inventoryInfo].Items[itemId].amount = LootBagEntities[inventoryInfo].Items[itemId].amount - 1 
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            LootBagEntities[inventoryInfo].Items[itemId] = nil;
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        end
                        local FormattedInventoryData = {}
                        for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        local maxVehKg = 200
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                        TriggerEvent('GMT:RefreshInventory', source)
                        InventoryCoolDown[source] = false
                        if not next(LootBagEntities[inventoryInfo].Items) then
                            CloseInv(source)
                            ProcessCrateDrop(inventoryInfo)
                        end
                    else 
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                end
            end
        elseif inventoryType == "Dumpster" then
            InventoryCoolDown[source] = true
            local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
            GMT.getSData(dumpsterformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = GMT.getInventoryWeight(UserId)+GMT.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        local maxVehKg = 500
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('GMT:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        GMT.setSData(dumpsterformat, json.encode(cdata))
                    else 
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                end
            end)
        elseif inventoryType == "Housing" then
            InventoryCoolDown[source] = true
            local recentlyrobbed,owner_id = GMT.RecentlyRobbed(inHouse[UserId])
            local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
            GMT.getSData(homeformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = GMT.getInventoryWeight(UserId)+GMT.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            GMT.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('GMT:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        GMT.setSData(homeformat, json.encode(cdata))
                    else 
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                end
            end)
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "dumpster" then --start of housing intergration (moveitem)
                        local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
                        GMT.getSData(dumpsterformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = GMT.computeItemsWeight(cdata)+GMT.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = 500
                                if weightCalculation <= maxVehKg then
                                    if GMT.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                    end
                                    local maxVehKg = 500
                                    TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('GMT:RefreshInventory', source)
                                    GMT.setSData(dumpsterformat, json.encode(cdata))
                                else 
                                    GMT.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                            end
                        end)
                    elseif inventoryInfo == "home" then --start of housing intergration (moveitem)
                        local recentlyrobbed,owner_id = GMT.RecentlyRobbed(inHouse[UserId])
                        local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                        GMT.getSData(homeformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = GMT.computeItemsWeight(cdata)+GMT.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                if weightCalculation <= maxVehKg then
                                    if GMT.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                    end
                                    local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                    TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('GMT:RefreshInventory', source)
                                    GMT.setSData(homeformat, json.encode(cdata))
                                else 
                                    GMT.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                            end
                        end) --end of housing intergration (moveitem)
                    else
                        InventoryCoolDown[source] = true;
                        local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                        GMT.getSData(carformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = GMT.computeItemsWeight(cdata)+GMT.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                if weightCalculation <= maxVehKg then
                                    if GMT.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                        cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                    end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('GMT:RefreshInventory', source)
                                    InventoryCoolDown[source] = nil;
                                    GMT.setSData(carformat, json.encode(cdata))
                                else 
                                    InventoryCoolDown[source] = nil;
                                    GMT.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                InventoryCoolDown[source] = nil;
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                            end
                        end)
                    end
                else
                    InventoryCoolDown[source] = nil;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        InventoryCoolDown[source] = nil;
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)

local alreadyLootingAll = {}
RegisterNetEvent('GMT:LootItemAll')
AddEventHandler('GMT:LootItemAll', function(inventoryInfo)
    local source = source
    local user_id = GMT.getUserId(source) 
    if alreadyLootingAll[user_id] then
        GMT.notify(source, '~r~You are already looting all items')
        return
    end
    local data = GMT.getUserDataTable(user_id)
    local totalBagWeight = 0
    local CarBoot = 0
    for itemId, _ in pairs(LootBagEntities[inventoryInfo].Items) do
        if LootBagEntities[inventoryInfo].Items[itemId] ~= nil then
            local weightCalculation = GMT.getInventoryWeight(user_id)+GMT.getItemWeight(itemId)
            if weightCalculation then 
                totalBagWeight = totalBagWeight + weightCalculation
            end
        end
    end
    if totalBagWeight > GMT.getInventoryMaxWeight(user_id) then
        GMT.notify(source, '~r~You do not have enough inventory space.')
        return
    end
    alreadyLootingAll[user_id] = true
    for itemId, _ in pairs(LootBagEntities[inventoryInfo].Items) do
        if LootBagEntities[inventoryInfo].Items[itemId] ~= nil then
            GMT.giveInventoryItem(user_id, itemId, LootBagEntities[inventoryInfo].Items[itemId].amount, true)
            LootBagEntities[inventoryInfo].Items[itemId] = nil;

            local FormattedInventoryData = {}
            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
            end
            local maxVehKg = 200
            TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)    
            Wait(500)
        end
    end
    CloseInv(source)
    TriggerEvent('GMT:RefreshInventory', source)
    ProcessCrateDrop(inventoryInfo)
    alreadyLootingAll[user_id] = false
end)

RegisterNetEvent('GMT:UseAllItem')
AddEventHandler('GMT:UseAllItem', function(itemId, itemLoc)
    local source = source
    local user_id = GMT.getUserId(source) 
    if not itemId then GMT.notify(source, '~r~You need to select an item, first!') return end
    if itemLoc == "Plr" then
        GMT.LoadAllTask(source, itemId)
        TriggerEvent('GMT:RefreshInventory', source)
    else
        GMT.notify(source, '~r~You need to have this item on you to use it.')
    end
end)

RegisterNetEvent('GMT:MoveItemX')
AddEventHandler('GMT:MoveItemX', function(inventoryType, itemId, inventoryInfo, Lootbag, Quantity, owner_id)
    local source = source
    local UserId = GMT.getUserId(source) 
    if not owner_id then owner_id = UserId end
    local data = GMT.getUserDataTable(UserId)
    if InventoryCoolDown[source] then GMT.notify(source, '~r~Please wait before moving more items.') return end
    if not itemId then  GMT.notify(source, '~r~You need to select an item, first!') return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            if Quantity >= 1 then
                local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                GMT.getSData(carformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = GMT.getInventoryWeight(UserId)+(GMT.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                            end
                            local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                            TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('GMT:RefreshInventory', source)
                            InventoryCoolDown[source] = nil;
                            GMT.setSData(carformat, json.encode(cdata))
                        else 
                            InventoryCoolDown[source] = nil;
                            GMT.notify(source, '~r~You do not have enough inventory space.')
                        end
                    else 
                        InventoryCoolDown[source] = nil;
                        GMT.notify(source, '~r~You are trying to move more then there actually is!')
                    end
                end)
            else
                InventoryCoolDown[source] = nil;
                GMT.notify(source, '~r~Invalid Amount!')
            end
        elseif inventoryType == "LootBag" or inventoryType == "Crate" then    
            if LootBagEntities[inventoryInfo].Items[itemId] then 
                Quantity = parseInt(Quantity)
                if Quantity then
                    local weightCalculation = GMT.getInventoryWeight(UserId)+(GMT.getItemWeight(itemId) * Quantity)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        if Quantity <= LootBagEntities[inventoryInfo].Items[itemId].amount then 
                            if LootBagEntities[inventoryInfo].Items[itemId] and LootBagEntities[inventoryInfo].Items[itemId].amount > Quantity then
                                LootBagEntities[inventoryInfo].Items[itemId].amount = LootBagEntities[inventoryInfo].Items[itemId].amount - Quantity
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                LootBagEntities[inventoryInfo].Items[itemId] = nil;
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            end
                            local FormattedInventoryData = {}
                            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                            end
                            local maxVehKg = 200
                            TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                            TriggerEvent('GMT:RefreshInventory', source)
                            if not next(LootBagEntities[inventoryInfo].Items) then
                                CloseInv(source)
                                ProcessCrateDrop(inventoryInfo)
                            end
                        else 
                            GMT.notify(source, '~r~You are trying to move more then there actually is!')
                        end 
                    else 
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    GMT.notify(source, '~r~Invalid input!')
                end
            end
        elseif inventoryType == "Housing" then
            Quantity = parseInt(Quantity)
            if Quantity then
                local recentlyrobbed,owner_id = GMT.RecentlyRobbed(inHouse[UserId])
                local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                GMT.getSData(homeformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = GMT.getInventoryWeight(UserId)+(GMT.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                            end
                            print(json.encode(FormattedInventoryData))
                            print(json.encode(cdata))
                            local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                            TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('GMT:RefreshInventory', source)
                            GMT.setSData(homeformat, json.encode(cdata))
                        else 
                            GMT.notify(source, '~r~You do not have enough inventory space.')
                        end
                    else 
                        GMT.notify(source, '~r~You are trying to move more then there actually is!')
                    end
                end)
            else 
                GMT.notify(source, '~r~Invalid input!')
            end
        elseif inventoryType == "Dumpster" then
            Quantity = parseInt(Quantity)
            if Quantity then
                local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
                GMT.getSData(dumpsterformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = GMT.getInventoryWeight(UserId)+(GMT.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                GMT.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                            end
                            print(json.encode(FormattedInventoryData))
                            print(json.encode(cdata))
                            local maxVehKg = 500
                            TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('GMT:RefreshInventory', source)
                            GMT.setSData(dumpsterformat, json.encode(cdata))
                        else 
                            GMT.notify(source, '~r~You do not have enough inventory space.')
                        end
                    else 
                        GMT.notify(source, '~r~You are trying to move more then there actually is!')
                    end
                end)
            else 
                GMT.notify(source, '~r~Invalid input!')
            end
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "dumpster" then --start of housing intergration (moveitem)
                        local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
                        GMT.getSData(dumpsterformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = GMT.computeItemsWeight(cdata)+GMT.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = 500
                                if weightCalculation <= maxVehKg then
                                    if GMT.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                    end
                                    local maxVehKg = 500
                                    TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('GMT:RefreshInventory', source)
                                    GMT.setSData(dumpsterformat, json.encode(cdata))
                                else 
                                    GMT.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                            end
                        end)
                    elseif inventoryInfo == "home" then --start of housing intergration (moveitemx)
                        Quantity = parseInt(Quantity)
                        if Quantity then
                            local recentlyrobbed,owner_id = GMT.RecentlyRobbed(inHouse[UserId])
                            local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                            GMT.getSData(homeformat, function(cdata)
                                cdata = json.decode(cdata) or {}
                                if data.inventory[itemId] and Quantity <= data.inventory[itemId].amount  then
                                    local weightCalculation = GMT.computeItemsWeight(cdata)+(GMT.getItemWeight(itemId) * Quantity)
                                    if weightCalculation == nil then return end
                                    local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                    if weightCalculation <= maxVehKg then
                                        if GMT.tryGetInventoryItem(UserId, itemId, Quantity, true) then
                                            if cdata[itemId] then
                                                cdata[itemId].amount = cdata[itemId].amount + Quantity
                                            else 
                                                cdata[itemId] = {}
                                                cdata[itemId].amount = Quantity
                                            end
                                        end 
                                        local FormattedInventoryData = {}
                                        for i, v in pairs(cdata) do
                                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                        end
                                        local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                        TriggerEvent('GMT:RefreshInventory', source)
                                        GMT.setSData(homeformat, json.encode(cdata))
                                    else 
                                        GMT.notify(source, '~r~You do not have enough inventory space.')
                                    end
                                else 
                                    GMT.notify(source, '~r~You are trying to move more then there actually is!')
                                end
                            end)
                        else 
                            GMT.notify(source, '~r~Invalid input!')
                        end
                    else
                        InventoryCoolDown[source] = true;
                        Quantity = parseInt(Quantity)
                        if Quantity then
                            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                            GMT.getSData(carformat, function(cdata)
                                cdata = json.decode(cdata) or {}
                                if data.inventory[itemId] and Quantity <= data.inventory[itemId].amount  then
                                    local weightCalculation = GMT.computeItemsWeight(cdata)+(GMT.getItemWeight(itemId) * Quantity)
                                    if weightCalculation == nil then return end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    if weightCalculation <= maxVehKg then
                                        if GMT.tryGetInventoryItem(UserId, itemId, Quantity, true) then
                                            if cdata[itemId] then
                                                cdata[itemId].amount = cdata[itemId].amount + Quantity
                                            else 
                                                cdata[itemId] = {}
                                                cdata[itemId].amount = Quantity
                                            end
                                        end 
                                        local FormattedInventoryData = {}
                                        for i, v in pairs(cdata) do
                                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                        end
                                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                        TriggerEvent('GMT:RefreshInventory', source)
                                        InventoryCoolDown[source] = nil;
                                        GMT.setSData(carformat, json.encode(cdata))
                                    else 
                                        InventoryCoolDown[source] = nil;
                                        GMT.notify(source, '~r~You do not have enough inventory space.')
                                    end
                                else 
                                    InventoryCoolDown[source] = nil;
                                    GMT.notify(source, '~r~You are trying to move more then there actually is!')
                                end
                            end)
                        else 
                            GMT.notify(source, '~r~Invalid input!')
                        end
                    end
                else
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)


RegisterNetEvent('GMT:MoveItemAll')
AddEventHandler('GMT:MoveItemAll', function(inventoryType, itemId, inventoryInfo, vehid, owner_id)
    local source = source
    local UserId = GMT.getUserId(source) 
    if not owner_id then owner_id = UserId end
    local data = GMT.getUserDataTable(UserId)
    if not itemId then GMT.notify(source, '~r~You need to select an item, first!') return end
    if InventoryCoolDown[source] then GMT.notify(source, '~r~Please wait before moving more items.') return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            local idz = NetworkGetEntityFromNetworkId(vehid)
            local user_id = GMT.getUserId(NetworkGetEntityOwner(idz))
            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
            GMT.getSData(carformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = GMT.getInventoryWeight(user_id)+(GMT.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    local amount = cdata[itemId].amount
                    if weightCalculation > GMT.getInventoryMaxWeight(user_id) and GMT.getInventoryWeight(user_id) ~= GMT.getInventoryMaxWeight(user_id) then
                        amount = math.floor((GMT.getInventoryMaxWeight(user_id)-GMT.getInventoryWeight(user_id)) / GMT.getItemWeight(itemId))
                    end
                    if math.floor(amount) > 0 or (weightCalculation <= GMT.getInventoryMaxWeight(user_id)) then
                        GMT.giveInventoryItem(user_id, itemId, amount, true)
                        local FormattedInventoryData = {}
                        if (cdata[itemId].amount - amount) > 0 then
                            cdata[itemId].amount = cdata[itemId].amount - amount
                        else
                            cdata[itemId] = nil
                        end
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('GMT:RefreshInventory', source)
                        InventoryCoolDown[source] = nil;
                        GMT.setSData(carformat, json.encode(cdata))
                    else 
                        InventoryCoolDown[source] = nil;
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    InventoryCoolDown[source] = nil;
                    GMT.notify(source, '~r~You are trying to move more then there actually is!')
                end
            end)
        elseif inventoryType == "LootBag" or inventoryType == "Crate" then  
            if itemId then    
                if LootBagEntities[inventoryInfo].Items[itemId] then 
                    local weightCalculation = GMT.getInventoryWeight(UserId)+(GMT.getItemWeight(itemId) *  LootBagEntities[inventoryInfo].Items[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        if  LootBagEntities[inventoryInfo].Items[itemId].amount <= LootBagEntities[inventoryInfo].Items[itemId].amount then 
                            GMT.giveInventoryItem(UserId, itemId, LootBagEntities[inventoryInfo].Items[itemId].amount, true)
                            LootBagEntities[inventoryInfo].Items[itemId] = nil;
                            local FormattedInventoryData = {}
                            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                            end
                            local maxVehKg = 200
                            TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                            TriggerEvent('GMT:RefreshInventory', source)
                            if not next(LootBagEntities[inventoryInfo].Items) then
                                CloseInv(source)
                                ProcessCrateDrop(inventoryInfo)
                            end
                        else 
                            GMT.notify(source, '~r~You are trying to move more then there actually is!')
                        end 
                    else 
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                end
            end
        elseif inventoryType == "Dumpster" then
            local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
            GMT.getSData(dumpsterformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = GMT.getInventoryWeight(UserId)+(GMT.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        GMT.giveInventoryItem(UserId, itemId, cdata[itemId].amount, true)
                        cdata[itemId] = nil;
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        local maxVehKg = 500
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('GMT:RefreshInventory', source)
                        GMT.setSData(dumpsterformat, json.encode(cdata))
                    else 
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    GMT.notify(source, '~r~You are trying to move more then there actually is!')
                end
            end)
        elseif inventoryType == "Housing" then
            local recentlyrobbed,owner_id = GMT.RecentlyRobbed(inHouse[UserId])
            local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
            GMT.getSData(homeformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = GMT.getInventoryWeight(UserId)+(GMT.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= GMT.getInventoryMaxWeight(UserId) then
                        GMT.giveInventoryItem(UserId, itemId, cdata[itemId].amount, true)
                        cdata[itemId] = nil;
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                        end
                        local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                        TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('GMT:RefreshInventory', source)
                        GMT.setSData(homeformat, json.encode(cdata))
                    else 
                        GMT.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    GMT.notify(source, '~r~You are trying to move more then there actually is!')
                end
            end)
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "home" then
                        local recentlyrobbed,owner_id = GMT.RecentlyRobbed(inHouse[UserId])
                        local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                        GMT.getSData(homeformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount <= data.inventory[itemId].amount  then
                                local itemAmount = data.inventory[itemId].amount
                                local weightCalculation = GMT.computeItemsWeight(cdata)+(GMT.getItemWeight(itemId) * itemAmount)
                                if weightCalculation == nil then return end
                                local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                if weightCalculation <= maxVehKg then
                                    if GMT.tryGetInventoryItem(UserId, itemId, itemAmount, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + itemAmount
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = itemAmount
                                        end 
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                    end
                                    local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                    TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('GMT:RefreshInventory', source)
                                    GMT.setSData(homeformat, json.encode(cdata))
                                else 
                                    GMT.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                GMT.notify(source, '~r~You are trying to move more then there actually is!')
                            end
                        end) --end of housing intergration (moveitemall)
                    else 
                        InventoryCoolDown[source] = true;
                        local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                        GMT.getSData(carformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount <= data.inventory[itemId].amount  then
                                local itemAmount = data.inventory[itemId].amount
                                local weightCalculation = GMT.computeItemsWeight(cdata)+(GMT.getItemWeight(itemId) * itemAmount)
                                if weightCalculation == nil then return end
                                local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                if weightCalculation <= maxVehKg then
                                    if GMT.tryGetInventoryItem(UserId, itemId, itemAmount, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + itemAmount
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = itemAmount
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
                                    end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('GMT:RefreshInventory', source)
                                    InventoryCoolDown[source] = nil;
                                    GMT.setSData(carformat, json.encode(cdata))
                                else 
                                    InventoryCoolDown[source] = nil;
                                    GMT.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                InventoryCoolDown[source] = nil;
                                GMT.notify(source, '~r~You are trying to move more then there actually is!')
                            end
                        end)
                    end
                else
                    InventoryCoolDown[source] = nil;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        InventoryCoolDown[source] = nil;
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)


-- LOOTBAGS CODE BELOW HERE 

function GMT.createDropBag(source,item,amount)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local closestBag = nil
    local closestDistance = 4.0 

    for netId, bag in pairs(LootBagEntities) do
        local bagCoords = GetEntityCoords(bag[1])
        local distance = #(playerCoords - bagCoords)

        if distance < closestDistance then
            closestBag = netId
            closestDistance = distance
        end
    end
    if closestBag == nil then
        local lootbag = CreateObjectNoOffset(`xm_prop_x17_bag_01a`, playerCoords - 0.9, true, true, false)
        local lootbagnetid = NetworkGetNetworkIdFromEntity(lootbag)
        SetEntityRoutingBucket(lootbag, GetPlayerRoutingBucket(source))
        LootBagEntities[lootbagnetid] = {lootbag, lootbag, false, source}
        LootBagEntities[lootbagnetid].Items = {}
        LootBagEntities[lootbagnetid].Items[item] = {amount = amount}
        LootBagEntities[lootbagnetid].name = GMT.getPlayerName(GMT.getUserId(source))
    else
        if LootBagEntities[closestBag].Items[item] then
            LootBagEntities[closestBag].Items[item].amount = LootBagEntities[closestBag].Items[item].amount + amount
        else
            LootBagEntities[closestBag].Items[item] = {amount = amount}
        end
    end
end

RegisterNetEvent('GMT:InComa')
AddEventHandler('GMT:InComa', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if not user_id or not GMTclient then return end
    if not GMTclient.InMainEvent(user_id) then
        GMTclient.isInComa(source, {}, function(in_coma) 
            if in_coma then
                Wait(1500)
                local ndata = GMT.getUserDataTable(user_id)
                if not ndata then return end
                if not ndata.inventory then return end
                if table.count(ndata.inventory) == 0 then return end
                if CloseToRestart then 
                    GMT.notify(source, '~r~Lootbag not dropped due to server restart.')
                    return 
                end 
                GMT.setDirtyCash(user_id, 0, true)
                local model = GetHashKey('xs_prop_arena_bag_01')
                local name1 = GMT.getPlayerName(user_id)
                local lootbag = CreateObjectNoOffset(model, GetEntityCoords(GetPlayerPed(source)) + 0.2, true, true, false)
                local lootbagnetid = NetworkGetNetworkIdFromEntity(lootbag)
                SetEntityRoutingBucket(lootbag, GetPlayerRoutingBucket(source))
                local stored_inventory = nil;
                TriggerEvent('GMT:StoreWeaponsRequest', source)
                LootBagEntities[lootbagnetid] = {lootbag, lootbag, false, source}
                LootBagEntities[lootbagnetid].Items = {}
                LootBagEntities[lootbagnetid].name = name1 
                stored_inventory = ndata.inventory
                GMT.clearInventory(user_id)
                for k, v in pairs(stored_inventory) do
                    LootBagEntities[lootbagnetid].Items[k] = {}
                    LootBagEntities[lootbagnetid].Items[k].amount = v.amount
                end
            end
        end)
    end
end)
local videoQueue = {}
local isProcessingQueue = false

local function processQueue()
    if #videoQueue > 0 and not isProcessingQueue then
        isProcessingQueue = true
        local task = table.remove(videoQueue, 1)
        TriggerClientEvent("GMT:takeClientVideoAndUpload", task.source, GMT.getWebhook('media-cache'), "Lootbag")
        SetTimeout(15000, function()
            isProcessingQueue = false
            processQueue()
        end)
    end
end
RegisterNetEvent('GMT:LootBag')
AddEventHandler('GMT:LootBag', function(netid)
    local source = source
    GMTclient.isInComa(source, {}, function(in_coma) 
        if not in_coma then
            if LootBagEntities[netid] then
                LootBagEntities[netid][3] = true;
                local user_id = GMT.getUserId(source)
                if user_id then
                    TriggerClientEvent("GMT:playZipperSound", -1, GetEntityCoords(GetPlayerPed(source)))
                    table.insert(videoQueue, {source = source})
                    processQueue()
                    LootBagEntities[netid][5] = source
                    if GMT.hasPermission(user_id, "police.armoury") then
                        local bagData = LootBagEntities[netid].Items
                        if bagData == nil then return end
                        for a,b in pairs(bagData) do
                            if string.find(a, 'wbody|') then
                                c = a:gsub('wbody|', '')
                                bagData[c] = b
                                bagData[a] = nil
                            end
                        end
                        for k,v in pairs(a.weapons) do
                            if bagData[k] then
                                if not v.policeWeapon then
                                    GMT.notify(source, '~r~Seized '..v.name..' x'..bagData[k].amount..'.')
                                    bagData[k] = nil
                                end
                            end
                        end
                        for c,d in pairs(bagData) do
                            if seizeBullets[c] then
                                GMT.notify(source, '~r~Seized '..c..' x'..d.amount..'.')
                                bagData[c] = nil
                            end
                        end
                        LootBagEntities[netid].Items = bagData
                        GMT.notify(source, "~r~You have seized " .. LootBagEntities[netid].name .. "'s items")
                        if #LootBagEntities[netid].Items > 0 then
                            GMT.notify(source, "~g~You opened " .. LootBagEntities[netid].name .. "'s lootbag.")
                            OpenInv(source, netid, LootBagEntities[netid].Items)
                        end
                    else
                        GMT.notify(source, "~g~You opened " .. LootBagEntities[netid].name .. "'s lootbag.")
                        OpenInv(source, netid, LootBagEntities[netid].Items)
                    end  
                end
            else
                GMT.notify(source, '~r~This loot bag is unavailable.')
                local bag = NetworkGetEntityFromNetworkId(netid)
                if DoesEntityExist(bag) then
                    DeleteEntity(bag)
                end
                TriggerClientEvent("GMT:deletePropClient", -1, netid)
            end
        else 
            GMT.notify(source, '~r~You cannot open this while dead.')
        end
    end)
end)

Citizen.CreateThread(function()
    while true do 
        Wait(250)
        for i,v in pairs(LootBagEntities) do 
            if v[5] then 
                local coords = GetEntityCoords(GetPlayerPed(v[5]))
                local objectcoords = GetEntityCoords(v[1])
                if #(objectcoords - coords) > 5.0 then
                    CloseInv(v[5])
                    Wait(3000)
                    v[3] = false; 
                    v[5] = nil;
                end
            end
        end
    end
end)

RegisterNetEvent('GMT:CloseLootbag')
AddEventHandler('GMT:CloseLootbag', function()
    local source = source
    for i,v in pairs(LootBagEntities) do 
        if v[5] and v[5] == source then 
            CloseInv(v[5])
            Wait(3000)
            v[3] = false; 
            v[5] = nil;
        end
    end
end)

function CloseInv(source)
    TriggerClientEvent('GMT:InventoryOpen', source, false, false)
    TriggerClientEvent("GMT:closeSecondInventory", source)
end

function OpenInv(source, netid, LootBagItems)
    local UserId = GMT.getUserId(source)
    local data = GMT.getUserDataTable(UserId)
    if data and data.inventory then
        local FormattedInventoryData = {}
        for i,v in pairs(data.inventory) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
        end
        TriggerClientEvent('GMT:FetchPersonalInventory', source, FormattedInventoryData, GMT.computeItemsWeight(data.inventory), GMT.getInventoryMaxWeight(UserId))
        InventorySpamTrack[source] = false;
    else 
        --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
    TriggerClientEvent('GMT:InventoryOpen', source, true, true, netid)
    local FormattedInventoryData = {}
    for i, v in pairs(LootBagItems) do
        FormattedInventoryData[i] = {amount = v.amount, ItemName = GMT.getItemName(i), Weight = GMT.getItemWeight(i)}
    end
    local maxVehKg = 200
    TriggerClientEvent('GMT:SendSecondaryInventoryData', source, FormattedInventoryData, GMT.computeItemsWeight(LootBagItems), maxVehKg)
end


-- Garabge collector for empty lootbags.
Citizen.CreateThread(function()
    while true do 
        Wait(500)
        for i,v in pairs(LootBagEntities) do 
            local itemCount = 0;
            for i,v in pairs(v.Items) do
                itemCount = itemCount + 1
            end
            if itemCount == 0 then
                if DoesEntityExist(v[1]) then 
                    DeleteEntity(v[1])
                    LootBagEntities[i] = nil;
                end
            end
        end
    end
end)

function getMoneyStringFormatted(cashString)
	local i, j, minus, int, fraction = tostring(cashString):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction 
end

local usersLockpicking = {}
local userLockpicked = {}

RegisterNetEvent('GMT:attemptLockpick')
AddEventHandler('GMT:attemptLockpick', function(veh, netveh, ownerid, spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    local owner_source = GMT.getUserSource(ownerid)
    local mods = GMT.GetDefaultMods()
    if GMT.tryGetInventoryItem(user_id, 'Lockpick', 1, true) then
        local chance = math.random(1,8)
        TriggerClientEvent('GMT:playLockpickAlarm', -1, netveh)
        if chance == 1 then
            usersLockpicking[user_id] = true
            TriggerClientEvent('GMT:lockpickClient', source, veh, true, spawncode)
            if mods.security_alarm then
               TriggerClientEvent('GMT:vehicleBeingLockpicked', owner_source, spawncode)
            end
            GMT.sendDCLog('lock-pick', 'Vehicle Being Lockpicked', 'Vehicle: ' .. spawncode .. ' | Owner User ID: ' .. ownerid .. ' | Lockpicker User ID: ' .. user_id)
            userLockpicked[ownerid] = userLockpicked[ownerid] or {}
            userLockpicked[ownerid][spawncode] = true 
        else
            TriggerClientEvent('GMT:lockpickClient', source, veh, false)
        end
    end
end)

RegisterNetEvent('GMT:callLockpickNotify')
AddEventHandler('GMT:callLockpickNotify', function(veh, netveh, ownerid)
    local owner_source = GMT.getUserSource(ownerid)
    if userLockpicked[ownerid] and userLockpicked[ownerid][veh] then
        GMT.notify(owner_source, '~r~Your vehicle has been lockpicked since it was last out.')
        userLockpicked[ownerid][veh] = false 
    end
end)

RegisterNetEvent('GMT:lockpickVehicle')
AddEventHandler('GMT:lockpickVehicle', function(vehicle, ownerid, spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    if usersLockpicking[user_id] then
        GMTclient.setVehicleOwner(source,{vehicle,spawncode, ownerid}) 
    end
end)

RegisterNetEvent('GMT:setVehicleLock')
AddEventHandler('GMT:setVehicleLock', function(netid)
    local source = source
    local user_id = GMT.getUserId(source)
    if usersLockpicking[user_id] then
        SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(netid), false)
        usersLockpicking[user_id] = nil 
    end
end)
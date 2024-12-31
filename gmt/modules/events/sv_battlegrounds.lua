local cfg = module("cfg/cfg_battleroyale")
local WeaponCFG = module("cfg/weapons")
local lootTable = {"WEAPON_AK74U","WEAPON_UMP45","WEAPON_UZI","WEAPON_REVOLVER357","WEAPON_SVD","WEAPON_MOSIN","WEAPON_ROOK"}

--[[ Functions ]]--
local function Reset(locationid)
    currentRoyale = {lootBoxes = {},armourPlates = {}}
    for i = 1,#cfg.locations[locationid].armourLocations do
        currentRoyale.armourPlates[i] = false
    end
    for i = 1,#cfg.locations[locationid].lootLocations do
        currentRoyale.lootBoxes[i] = false
    end
end

local function GetLocationID(locationname)
    if locationname == "Legion" then
        return 1
    elseif locationname == "Sandy Shores" then
        return 2
    elseif locationname == "Paleto" then
        return 3
    elseif locationname == "Cayo Perico" then
        return 4
    end
    return "Unknown"
end

--[[ Events ]]

AddEventHandler("GMT:Event:BattleRoyale",function(locationname)
    local locationID = GetLocationID(locationname)
    Reset(locationID)
    for _,tbl in pairs(CurrentEvent.players) do
        SetPlayerRoutingBucket(tbl.source,1337)
        TriggerClientEvent("GMT:startBattlegrounds",tbl.source,locationID)
        TriggerClientEvent("GMT:syncLootboxesTable",tbl.source,locationname)
        TriggerClientEvent("GMT:EventStarting",tbl.source)
        GMTclient.setArmour(tbl.source, {50})
    end
end)

RegisterServerEvent("GMT:removeArmourPlate",function(plateId)
    local source = source
    local user_id = GMT.getUserId(source)
    if not currentRoyale.armourPlates[plateId] then
        if CurrentEvent.players[user_id] then
            currentRoyale.armourPlates[plateId] = true
            GMTclient.setArmour(source, {100})
            TriggerClientEvent("GMT:removeArmourPlateCl",-1,plateId)
        else
            GMT.ACBan(15,user_id,"GMT:removeArmourPlate")
        end
    else
        GMT.notify(source, "~r~This armour plate has already been used")
    end
end)

function GMT.getWeaponName(weaponCode)
    local weapon = WeaponCFG.weapons[weaponCode]
    if weapon then
        return weapon.name
    end
    return "Unknown"
end

-- GMT #0005 -- Invalid spawn code

RegisterServerEvent("GMT:LootBox",function(boxid)
    local source = source
    local user_id = GMT.getUserId(source)
    if not currentRoyale.lootBoxes[boxid] then
        if CurrentEvent.players[user_id] then
            currentRoyale.lootBoxes[boxid] = true
            local randomWeaponSpawnCode = lootTable[math.random(1,#lootTable)]
           -- if GMT.getWeaponName(randomWeaponSpawnCode) ~= "Unknown" then
                GMTclient.giveWeapons(source, {{[randomWeaponSpawnCode] = {ammo = 250}}, false,globalpasskey})
                local weapons = {}
                GMT.notify(source, "~g~You have received a "..GMT.getWeaponName(randomWeaponSpawnCode))
                TriggerClientEvent("GMT:removeLootBox",-1,boxid)
            -- else
            --     GMT.notify(source, "~r~An Error Occurred, Please contact a developer with the following code: GMT #0005")
            -- end
        else
            GMT.ACBan(15,user_id,"GMT:LootBox")
        end
    else
        GMT.notify(source, "~r~This loot box has already been used")
    end
end)

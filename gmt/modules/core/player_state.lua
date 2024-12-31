local cfg = module("cfg/player_state")
local a = module("cfg/weapons")
--local leftPlayersWithCombatTimer = {}
local lang = GMT.lang

baseplayers = {}

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    Debug.pbegin("playerSpawned_player_state")
    local player = source
    GMT.getFactionGroups(source)
    local data = GMT.getUserDataTable(user_id)
    local tmpdata = GMT.getUserTmpTable(user_id)
    TriggerEvent("GMT:AddChatModes", source)
    TriggerClientEvent("GMT:SetClientUserId",source,user_id)
    if first_spawn then -- first spawn
        GMTclient.setdecor(source, {decor,globalpasskey})
        if data.customization == nil then
            data.customization = cfg.default_customization
        end
        if data.position == nil and cfg.spawn_enabled then
            local x = cfg.spawn_position[1] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local y = cfg.spawn_position[2] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local z = cfg.spawn_position[3] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            data.position = {
                x = x,
                y = y,
                z = z
            }
        end
        if data.customization then
            GMTclient.spawnAnim(source, {data.position})
            if data.weapons then
                GMTclient.giveWeapons(source, {data.weapons, true,globalpasskey})
            end
            GMTclient.setDiscordNames(source,{dscnames})
            GMTclient.setUserID(source, {user_id})
            if GMT.hasGroup(user_id, 'Founder') or GMT.hasGroup(user_id, 'Lead Developer') or GMT.hasGroup(user_id, 'Developer') then
                GMTclient.setDev(source, {})
            end
            if GMT.hasPermission(user_id, 'cardev.menu') then
                TriggerClientEvent('GMT:setCarDev', source)
            end
            if GMT.hasPermission(user_id, 'police.armoury') then
                GMTclient.setPolice(source, {true})
                TriggerClientEvent('gmtui:globalOnPoliceDuty', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasPermission(user_id, 'aa.menu') then
                GMTclient.setAA(source, {true})
                TriggerClientEvent('gmtui:globalOnAADuty', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasPermission(user_id, 'nhs.menu') then
                GMTclient.setNHS(source, {true})
                TriggerClientEvent('gmtui:globalOnNHSDuty', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasPermission(user_id, 'hmp.menu') then
                GMTclient.setHMP(source, {true})
                TriggerClientEvent('gmtui:globalOnPrisonDuty', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasPermission(user_id, 'lfb.menu') then
                GMTclient.setLFB(source, {true})
                TriggerClientEvent('gmtui:globalLFBOnDuty', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasPermission(user_id, 'ukbf.armoury') then
                GMTclient.setUKBF(source, {true})
                TriggerClientEvent('gmtui:globalUKBFOnDuty', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasGroup(user_id, 'Taco Seller') then
                TriggerClientEvent('GMT:toggleTacoJob', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasGroup(user_id, 'Lorry Driver') then
                TriggerClientEvent('GMT:setTruckerOnDuty', source, true)
                TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
            end
            if GMT.hasGroup(user_id, 'Police Horse Trained') then
                GMTclient.setglobalHorseTrained(source, {})
            end
            GMTclient.setStaffLevel(source, {GMT.GetStaffLevel(user_id)})
            GMTclient.setgrindBoost(source, {grindBoost})
            TriggerClientEvent('GMT:sendGarageSettings', source)
           -- TriggerClientEvent("GMT:setProfilePictures",source,RequestPFP(user_id))
            TriggerEvent("GMT:DVSASpawned", source, user_id)
            if GMT.hasGroup(user_id, "NewPlayer") then
                if tGMT.GetPlayTime(user_id) > 48 then
                    GMT.removeUserGroup(user_id, "NewPlayer")
                else
                    TriggerClientEvent("GMT:setIsNewPlayer", source)
                end
            end
            players = GMT.getUsers({})
            for k,v in pairs(players) do
                baseplayers[v] = GMT.getUserId(v)
            end
            GMTclient.setBasePlayers(source, {baseplayers})
            print(GMT.getPlayerName(user_id).."(" .. user_id .. ") ^2| Spawned^7")
        else
            if data.weapons then -- load saved weapons
                GMTclient.giveWeapons(source, {data.weapons, true,globalpasskey})
            end
            -- if leftPlayersWithCombatTimer[user_id] then
            --     GMTclient.setHealth(source, 102)
            --     leftPlayersWithCombatTimer[user_id] = nil
            --     print("^3GMT: " .. GMT.getPlayerName(user_id).."(" .. user_id .. ") left with combat timer^0")
           -- else
            if data.health then
                GMTclient.setHealth(source, {data.health})
              --  print("^3GMT: " .. GMT.getPlayerName(user_id).."(" .. user_id .. ") health set to " .. data.health .. "^0")
            end
        end

    else -- not first spawn (player died), don't load weapons, empty wallet, empty inventory
        Wait(1000)
        GMT.clearInventory(user_id) 
        GMT.setMoney(user_id, 0)
        GMTclient.setHandcuffed(player, {false})

        -- if cfg.spawn_enabled then -- respawn (CREATED SPAWN_DEATH)
        --     local x = cfg.spawn_death[1] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
        --     local y = cfg.spawn_death[2] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
        --     local z = cfg.spawn_death[3] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
        --     data.position = {
        --         x = x,
        --         y = y,
        --         z = z
        --     }
        --     GMTclient.teleport(source, {x, y, z})
        --end
    end
  --  Debug.pend()
end)

-- local combatTimers = {}

-- AddEventHandler("GMT:playerLeave",function(user_id,source)
--     local user_id = user_id
--     if combatTimers[user_id] and combatTimers[user_id] > 0 then
--         print("^3GMT: " .. GMT.getPlayerName(user_id).."(" .. user_id .. ") left with combat timer^0")
--         leftPlayersWithCombatTimer[user_id] = true
--     end
-- end)

-- RegisterServerEvent("GMT:setCombatTimer")
-- AddEventHandler("GMT:setCombatTimer", function(g)
--     local source = source
--     local user_id = GMT.getUserId(source)
--     combatTimers[user_id] = g
--     print("^3GMT: " .. GMT.getPlayerName(GMT.getUserId(source)).."(" .. GMT.getUserId(source) .. ") set combat timer to " .. g .. "^0")
-- end)

function ConvertRawPlaytime(rawPlaytime)
    local hours = math.floor(rawPlaytime / 60)
    local minutes = rawPlaytime % 60
    return hours, minutes
end

function tGMT.updateWeapons(weapons)
    local user_id = GMT.getUserId(source)
    if user_id then
        local data = GMT.getUserDataTable(user_id)
        if data then
            data.weapons = weapons
        end
    end
end

function tGMT.UpdatePlayTime()
    local user_id = GMT.getUserId(source)
    if user_id then
        local data = GMT.getUserDataTable(user_id)
        if data then
            if data.PlayerTime then
                data.PlayerTime = tonumber(data.PlayerTime) + 1
            else
                data.PlayerTime = 1
            end
        end
        if GMT.hasPermission(user_id, 'police.armoury') then
            local lastClockedRank = string.gsub(getGroupInGroups(user_id, 'Police'), ' Clocked', '')
            exports['gmt']:execute("INSERT INTO gmt_police_hours (user_id, username, weekly_hours, total_hours, last_clocked_rank, last_clocked_date, total_players_fined, total_players_jailed) VALUES (@user_id, @username, @weekly_hours, @total_hours, @last_clocked_rank, @last_clocked_date, @total_players_fined, @total_players_jailed) ON DUPLICATE KEY UPDATE weekly_hours = weekly_hours + 1/60, total_hours = total_hours + 1/60, username = @username, last_clocked_rank = @last_clocked_rank, last_clocked_date = @last_clocked_date, total_players_fined = @total_players_fined, total_players_jailed = @total_players_jailed", {user_id = user_id, username = GMT.getPlayerName(user_id), weekly_hours = 1/60, total_hours = 1/60, last_clocked_rank = lastClockedRank, last_clocked_date = os.date("%d/%m/%Y"), total_players_fined = 0, total_players_jailed = 0})
        end
        TriggerClientEvent("GMT:updatePlaytime", source, data.PlayerTime)
    end
end

-- function tGMT.UpdateStatsPlayTime()
--     local user_id = GMT.getUserId(source)
--     if user_id then
--         local data = GMT.getUserDataTable(user_id)
--         if data then
--             local newPlaytimeMinutes = tonumber(data.PlayerTime) + 1
--             local newPlaytimeHours = math.floor(newPlaytimeMinutes / 60 + 0.5)
--             local currentPlaytimeHours = GMT.GetStat(user_id, "playtime") or 0
--             if newPlaytimeHours > currentPlaytimeHours then
--                 local difference = newPlaytimeHours - currentPlaytimeHours
--                 GMT.AddStat(user_id, "playtime", difference)
--             end
--         end
--         TriggerClientEvent("GMT:updateStatsPlaytime", source, data.PlayerTime)
--     end
-- end

function GMT.updateInvCap(user_id, invcap)
    if user_id then
        local data = GMT.getUserDataTable(user_id)
        if data then
            if data.invcap then
                data.invcap = invcap
            else
                data.invcap = 30
            end
        end
    end
end

function GMT.setBucket(source, bucket)
    local source = source
    local user_id = GMT.getUserId(source)
    SetPlayerRoutingBucket(source, bucket)
    TriggerClientEvent('GMT:setBucket', source, bucket)
end

local isStoring = {}
AddEventHandler('GMT:StoreWeaponsRequest', function(source)
    local player = source 
    local user_id = GMT.getUserId(player)
	GMTclient.getWeapons(player,{},function(weapons)
        if not isStoring[player] then
            isStoring[player] = true
            GMTclient.giveWeapons(player,{{},true,globalpasskey}, function(removedwep) -- tayser
                for k,v in pairs(weapons) do
                    if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k~= 'WEAPON_SMOKEGRENADE' and k~= 'WEAPON_FLASHBANG' then
                        if v.ammo > 0 and k ~= 'WEAPON_STUNGUN' then
                            for i,c in pairs(a.weapons) do
                                if i == k then
                                    GMT.giveInventoryItem(user_id, "wbody|"..k, 1, false)
                                end   
                            end
                        end
                    end
                end
                GMT.notify(player, "~g~Weapons Stored")
                SetTimeout(3000,function()
                      isStoring[player] = nil 
                end)
            end)
        else
            GMT.notify(player, "~o~Your weapons are already being stored...")
        end
    end)
end)

RegisterNetEvent('GMT:forceStoreWeapons')
AddEventHandler('GMT:forceStoreWeapons', function()
    local source = source 
    local user_id = GMT.getUserId(source)
    local data = GMT.getUserDataTable(user_id)
    Wait(3000)
    if data then
        data.inventory = {}
    end
    GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            local invcap = 30
            if plathours > 0 then
                invcap = invcap + 20
            elseif plushours > 0 then
                invcap = invcap + 10
            end
            if invcap == 30 then
            return
            end
            if data.invcap - 15 == invcap then
            GMT.giveInventoryItem(user_id, "offwhitebag", 1, false)
            elseif data.invcap - 20 == invcap then
            GMT.giveInventoryItem(user_id, "guccibag", 1, false)
            elseif data.invcap - 30 == invcap  then
            GMT.giveInventoryItem(user_id, "nikebag", 1, false)
            elseif data.invcap - 30 == invcap  then
            GMT.giveInventoryItem(user_id, "primarkbag", 1, false)
            elseif data.invcap - 35 == invcap  then
            GMT.giveInventoryItem(user_id, "huntingbackpack", 1, false)
            elseif data.invcap - 40 == invcap  then
            GMT.giveInventoryItem(user_id, "tanhikingbackpack", 1, false)
            elseif data.invcap - 40 == invcap  then
            GMT.giveInventoryItem(user_id, "greenhikingbackpack", 1, false)
            elseif data.invcap - 70 == invcap  then
            GMT.giveInventoryItem(user_id, "rebelbackpack", 1, false)
            end
            GMT.updateInvCap(user_id, invcap)
        end
    end)
end)

RegisterServerEvent("GMT:AddChatModes", function(source)
    local source = source
    local user_id = GMT.getUserId(source)
    local adminlevel = GMT.GetStaffLevel(user_id)
    local main = {
        name = "Global",
        displayName = "Global",
        isChannel = "Global",
        isGlobal = true,
    }
    local ooc = {
        name = "OOC",
        displayName = "OOC",
        isChannel = "OOC",
        isGlobal = false,
    }
    local Admin = {
        name = "Admin",
        displayName = "Admin",
        isChannel = "Admin",
        isGlobal = false, -- tayser
    }
    TriggerClientEvent('chat:addMode', source, main)
    TriggerClientEvent('chat:addMode', source, ooc)
    if adminlevel > 0 then
        TriggerClientEvent('chat:addMode', source, Admin)
    end
end)
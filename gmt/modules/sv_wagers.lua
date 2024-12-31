local weapons = module("cfg/weapons").weapons
local whitelists = module("cfg/cfg_gunstores").whitelistedGuns
local cfg = module("cfg/cfg_wagers").settings
local wagerTeam = {}
local wagerCurrentlyIn = {}

local function getOwnerDetails(id)
    if wagerTeam[id] then
        return wagerTeam[id]
    end
    return false
end

MySQL.createCommand("AMBWagers/add_id", "INSERT IGNORE INTO amb_wager_stats SET user_id = @user_id")

AddEventHandler("AMB:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        MySQL.execute("AMBWagers/add_id", {user_id = user_id})
    end
end)

RegisterNetEvent("AMB:getWagerWhitelists", function()
    local source = source
    local user_id = AMB.getUserId(source)
    local cfg_whitelists = {}
    for k,v in pairs(whitelists) do
        for a,b in pairs(v) do
            if weapons[a] and b[6] == user_id and not weapons[a].policeWeapon and weapons[a].class ~= "Melee" then
                cfg_whitelists[a] = weapons[a].name
            end
        end
    end
    TriggerClientEvent("AMB:gotWagerWhitelists", source, cfg_whitelists, AMB.getFlagStatus("minigames_wagers"))
end)

RegisterServerEvent("AMB:createWager", function(bestOf, wagerWeapon, WagerWeaponCategory, betAmount, armourValues,mapLoc)
    local source = source
    local user_id = AMB.getUserId(source)
    if AMB.InEvent(user_id) then return AMB.notify(source, "~r~Cannot do this while in an event") end
    for k,v in pairs(wagerTeam) do
        if v.teamA.players[user_id] then
            v.teamA.players[user_id] = nil
        elseif v.teamB.players[user_id] then
            v.teamB.players[user_id] = nil
        end
        if v.owner_id == user_id then
            wagerTeam[user_id] = nil
        end
    end
    wagerTeam[user_id] = {
        teamA = {
            players = {
                [user_id] = {source = source, user_id = user_id, name = AMB.getPlayerName(user_id)},
            },
            wins = 0,
        },
        teamB = {
            players = {},
            wins = 0
        },
        currentRound = 0,
        owner = true,
        owner_id = user_id,
        name = AMB.getPlayerName(user_id),
        bestOf = bestOf,
        armourValues = armourValues,
        wagerWeapon = wagerWeapon,
        WagerWeaponCategory = WagerWeaponCategory,
        betAmount = betAmount,
        teamALoc = mapLoc.A,
        teamBLoc = mapLoc.B,
        Radius = mapLoc.radius,
        inProgress = false
    }
    TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
end)

RegisterServerEvent("AMB:joinWager", function(wager_owner, team)
    local source = source
    local user_id = AMB.getUserId(source)
    if AMB.InEvent(user_id) then return AMB.notify(source, "~r~Cannot do this while in an event") end
    wager_owner = tonumber(wager_owner)
    local ownerDetails = getOwnerDetails(wager_owner)
    if not ownerDetails.inProgress then
        if AMB.getAllMoney(user_id) < tonumber(ownerDetails.betAmount) then
            AMB.notify(source, "~r~You cannot afford to join this wager!")
            return
        end
        if ownerDetails.owner_id ~= user_id and wagerTeam[user_id] then
            wagerTeam[user_id] = nil
        end
        if table.count(ownerDetails[team].players) == 2 then
            AMB.notify(source, "~r~"..team.." is full!")
            return
        end
        for k,v in pairs(wagerTeam) do
            if v.teamA.players[user_id] then
                v.teamA.players[user_id] = nil
            elseif v.teamB.players[user_id] then
                v.teamB.players[user_id] = nil
            end
        end
        if ownerDetails then
            local isOwner = user_id == wager_owner
            local otherTeam = team == "teamA" and "teamB" or "teamA"
            if ownerDetails[otherTeam].players[user_id] then
                ownerDetails[otherTeam].players[user_id] = nil
            end
            wagerTeam[wager_owner][team].players[user_id] = {
                source = source,
                user_id = user_id,
                name = AMB.getPlayerName(user_id),
                owner = isOwner
            }
            TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
        else
            AMB.notify(source, "~r~Couldn't find the owner for this wager.")
        end
    else
        AMB.notify(source, "~r~This wager is currently in progress.")
    end
end)

RegisterServerEvent("AMB:leaveTeam", function(wager_owner, team)
    local source = source
    local user_id = AMB.getUserId(source)
    wager_owner = tonumber(wager_owner)
    local ownerDetails = getOwnerDetails(wager_owner)
    if ownerDetails and ownerDetails[team] and ownerDetails[team].players[user_id] then
        wagerTeam[wager_owner][team].players[user_id] = nil
        if ownerDetails.owner_id == user_id then
            wagerTeam[user_id] = nil
        end
        TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
    else
        AMB.notify(source, "~r~You are not in a team to leave!")
    end
end)

RegisterServerEvent("AMB:cancelWager", function(wager_owner)
    local source = source
    local user_id = AMB.getUserId(source)
    wager_owner = tonumber(wager_owner)
    local ownerDetails = getOwnerDetails(wager_owner)
    if ownerDetails and ownerDetails.owner_id == user_id then
        for k,v in pairs(ownerDetails.teamA.players) do
            AMB.notify(v.source, "~r~" .. AMB.getPlayerName(ownerDetails.owner_id) .. " has cancelled the wager!")
        end
        for k,v in pairs(ownerDetails.teamB.players) do
            AMB.notify(v.source, "~r~" .. AMB.getPlayerName(ownerDetails.owner_id) .. " has cancelled the wager!")
        end
        wagerTeam[user_id] = nil
        TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
    end
end)

local function startDistCheck(source)
    Citizen.CreateThread(function()
        while getOwnerDetails(wagerCurrentlyIn[source]) and getOwnerDetails(wagerCurrentlyIn[source]).inProgress do
            local ownerDetails = getOwnerDetails(wagerCurrentlyIn[source])
            
            if ownerDetails.teamA.players[AMB.getUserId(source)] then
                if #(GetEntityCoords(GetPlayerPed(source)) - vector(ownerDetails.teamALoc[1].x,ownerDetails.teamALoc[1].y,ownerDetails.teamALoc[1].z)) > ownerDetails.Radius then
                    AMB.notify(source, "~r~You've gone too far away from the wager location!")
                    vRPclient.teleport(source, {ownerDetails.teamALoc[1].x,ownerDetails.teamALoc[1].y,ownerDetails.teamALoc[1].z,globalpasskey})
                end
            elseif ownerDetails.teamB.players[AMB.getUserId(source)] then
                if #(GetEntityCoords(GetPlayerPed(source)) - vector(ownerDetails.teamBLoc[1].x,ownerDetails.teamBLoc[1].y,ownerDetails.teamBLoc[1].z)) > ownerDetails.Radius then
                    AMB.notify(source, "~r~You've gone too far away from the wager location!")
                    vRPclient.teleport(source, {ownerDetails.teamBLoc[1].x,ownerDetails.teamBLoc[1].y,ownerDetails.teamBLoc[1].z,globalpasskey})
                end
            end
            Wait(ownerDetails and 1000 or 0)
        end
    end)
end

RegisterServerEvent("AMB:startWager", function()
    local source = source
    local user_id = AMB.getUserId(source)
    local ownerDetails = getOwnerDetails(user_id)
    if AMB.InEvent(user_id) then return AMB.notify(source, "~r~Cannot do this while in an event") end
    if wagerTeam[user_id] then
        local allPlayersCanAfford = true
        local allPlayersInRadius = true
        local playerTables = {
            ownerDetails.teamA.players,
            ownerDetails.teamB.players
        }
        for a,b in pairs(playerTables) do
            for _, playerDetails in pairs(b) do
                if AMB.getAllMoney(playerDetails.user_id) < tonumber(ownerDetails.betAmount) then
                    allPlayersCanAfford = false
                end
                if #(GetEntityCoords(GetPlayerPed(playerDetails.source)) - cfg.wagerStartLoc) > 10 then
                    allPlayersInRadius = false
                end
            end
        end
        if allPlayersCanAfford then
            if allPlayersInRadius then
                if table.count(ownerDetails.teamA.players) == 0 or table.count(ownerDetails.teamB.players) == 0 then
                    AMB.notify(source,"~r~Cannot start the wager one of the teams are empty!")
                    return
                end
                if table.count(ownerDetails.teamA.players) ~= table.count(ownerDetails.teamB.players) then
                    AMB.notify(source,"~r~Teams must be balanced to start the wager!")
                    return
                end
                local function preparePlayerForWager(playerDetails, location)
                    AMB.tryFullPayment(playerDetails.user_id, tonumber(ownerDetails.betAmount))
                    AMB.setBucket(playerDetails.source, 5555+ownerDetails.owner_id)
                    --AMB.setUData(playerDetails.user_id, "AMB:datatable", json.encode(AMB.getUserDataTable(playerDetails.user_id)))
                    vRPclient.clearWeapons(playerDetails.source,{true})
                    vRPclient.teleport(playerDetails.source, {location.x,location.y,location.z,globalpasskey})
                    vRPclient.playAnim(playerDetails.source, {true, {{"mini@triathlon", "idle_d", 1}}, true})
                    Citizen.Wait(50)
                    FreezeEntityPosition(GetPlayerPed(playerDetails.source), true)
                    vRPclient.giveWeapons(playerDetails.source, {{[ownerDetails.wagerWeapon] = {ammo = 250}}, true, globalpasskey})
                    local armourValue = ownerDetails.armourValues and (ownerDetails.armourValues):gsub("%%", "") or 0
                    vRPclient.setArmour(playerDetails.source, {tonumber(armourValue), true})
                    vRPclient.showCountdownTimer(playerDetails.source, {3})
                    vRPclient.isStaffedOn(playerDetails.source, {}, function(staffedOn) 
                        if staffedOn then
                            vRPclient.staffMode(playerDetails.source, {false})
                        end
                    end)
                    TriggerClientEvent("AMB:toggleInWager", playerDetails.source, true)
                    SetTimeout(4000, function()      
                        wagerCurrentlyIn[playerDetails.source] = ownerDetails.owner_id
                        local inTeam = ownerDetails.teamA.players[playerDetails.user_id] and "teamA" or "teamB"
                        TriggerClientEvent("AMB:startWager", playerDetails.source, inTeam)
                        TriggerClientEvent('AMB:smallAnnouncement', playerDetails.source, "~r~Round 1/" .. ownerDetails.bestOf, "", 2, 3000)
                        startDistCheck(playerDetails.source)
                    end)
                end
                local i = 1
                for _, playerDetails in pairs(ownerDetails.teamA.players) do
                    preparePlayerForWager(playerDetails, ownerDetails.teamALoc[i])
                    i = i + 1
                end
                i = 1
                for _, playerDetails in pairs(ownerDetails.teamB.players) do
                    preparePlayerForWager(playerDetails, ownerDetails.teamBLoc[i])
                    i = i + 1
                end
                wagerTeam[user_id].inProgress = true
                AMB.discordLog("wagers","AMB Wagers Logs","> Owner Name: **"..AMB.getPlayerName(user_id).."**\n> Bet Amount: **£"..getMoneyStringFormatted(ownerDetails.betAmount).."**\n> Best Of: **"..ownerDetails.bestOf.."**\n> Weapon: **"..ownerDetails.wagerWeapon.."**\n> Weapon Category: **"..ownerDetails.WagerWeaponCategory.."**\n> Armour: **"..ownerDetails.armourValues.."%**")
                TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
            else
                AMB.notify(source, "~r~Not all players are close enough to start the wager!")
            end
        else
            AMB.notify(source, "~r~Not all players can afford the wager!")
        end
    else
        AMB.notify(source, "~r~Only the leader can start the wager!")
    end
end)
 
function AMB.inWager(source)
    local user_id = AMB.getUserId(source)
    for _,details in pairs(wagerTeam) do
        if details.teamA.players[user_id] or details.teamB.players[user_id] then
            if details.inProgress then
                return true
            end
        end
    end
    return false
end

local function FinishWager(src, names, win, cancelled)
    local user_id = AMB.getUserId(src)
    local ownerDetails = getOwnerDetails(wagerCurrentlyIn[src])
    AMB.setBucket(src, 0)
    vRPclient.getWeapons(src,{true})
    if cancelled then
        AMB.notify(src, "~r~Wager has been cancelled!")
    elseif names ~= nil then
        TriggerClientEvent('AMB:smallAnnouncement', src, win and "WAGER WON " or "WAGER LOST ", names.." has won the wager!", win and 33 or 6, 5000)
    end
    vRPclient.setPlayerCombatTimer(src, {0, false})
    vRPclient.clearWeapons(src, {})
    vRPclient.teleport(src, {cfg.wagerStartLoc.x,cfg.wagerStartLoc.y,cfg.wagerStartLoc.z,globalpasskey})
    vRPclient.RevivePlayer(src, {globalpasskey})
    vRPclient.setArmour(src, {0})
    --AMB.giveItemsBackAfterWager(src)
    Wait(50)
    wagerCurrentlyIn[src] = nil
    if wagerTeam[user_id] then
       wagerTeam[user_id] = nil
    end
    if ownerDetails then
        AMB.updateWagerStats(user_id, ownerDetails.betAmount, win, ownerDetails.WagerWeaponCategory, ownerDetails.wagerWeapon)
        AMB.discordLog("wagers", "AMB Wagers Logs", "> Owner Name: **" .. (AMB.getPlayerName(ownerDetails.owner_id) or "N/A") .. "**\n> Owner ID: **" .. (ownerDetails.owner_id or "N/A") .. "**\n> Winners: **" .. (names or "N/A") .. "**\n> Player Name: **"..AMB.getPlayerName(user_id).."**\n> Player ID:**"..user_id.."**\n> Win Amount: **£" .. getMoneyStringFormatted(tostring(ownerDetails.betAmount * 2)) .. "**\n> Cancelled: **" .. (cancelled and "Yes" or "No") .. "**")
    end
    TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
    TriggerClientEvent("AMB:toggleInWager", src, false)
end

local function preparePlayerForDuel(playerDetails, teleportLocation, wagerOwner)
    local ownerDetails = getOwnerDetails(wagerOwner)
    if ownerDetails then
        vRPclient.RevivePlayer(playerDetails.source, {globalpasskey})
        vRPclient.teleport(playerDetails.source, teleportLocation)
        vRPclient.playAnim(playerDetails.source, {true, {{"mini@triathlon", "idle_d", 1}}, true})
        FreezeEntityPosition(GetPlayerPed(playerDetails.source), true)
        vRPclient.giveWeapons(playerDetails.source, {{[ownerDetails.wagerWeapon] = {ammo = 250}}, true, globalpasskey})
        local armourValue = ownerDetails.armourValues and (ownerDetails.armourValues):gsub("%%", "") or 0
        vRPclient.setArmour(playerDetails.source, {tonumber(armourValue), true})
        vRPclient.showCountdownTimer(playerDetails.source, {3})
        SetTimeout(4000, function()      
            TriggerClientEvent("AMB:toggleInWager", playerDetails.source, true)
            TriggerClientEvent('AMB:startWager', playerDetails.source)
            TriggerClientEvent('AMB:smallAnnouncement', playerDetails.source, "~r~Round " .. ownerDetails.currentRound + 1 .. "/" .. ownerDetails.bestOf, "", 2, 3000) 
        end)
    end
end

local function isTeamDead(players)
    for _, playerDetails in pairs(players) do
        if GetEntityHealth(GetPlayerPed(playerDetails.source)) > 102 then
            return false
        end
    end
    return true
end

local function getPlayerNames(players)
    local names = {}
    for _, playerDetails in pairs(players) do
        table.insert(names, playerDetails.name)
    end
    return table.concat(names, " and ")
end

function AMB.handleWagerDeath(civsource, killersource)
    local killerID = AMB.getUserId(killersource)
    local ownerDetails = getOwnerDetails(wagerCurrentlyIn[civsource])
    if not ownerDetails then return end
    local teamADead, teamBDead = false, false
    teamADead = isTeamDead(ownerDetails.teamA.players)
    teamBDead = isTeamDead(ownerDetails.teamB.players)
    if teamBDead or teamADead then
        if teamADead then
            ownerDetails.teamB.wins = ownerDetails.teamB.wins + 1
        elseif teamBDead then
            ownerDetails.teamA.wins = ownerDetails.teamA.wins + 1
        end
        ownerDetails.currentRound = ownerDetails.currentRound + 1
        if ownerDetails then
            if ownerDetails.teamA.wins > ownerDetails.bestOf/2 or ownerDetails.teamB.wins > ownerDetails.bestOf/2 or tonumber(ownerDetails.currentRound) >= tonumber(ownerDetails.bestOf) then
                local winningTeam = ownerDetails.teamA.wins > ownerDetails.teamB.wins and ownerDetails.teamA.players or ownerDetails.teamB.players
                local losingTeam = ownerDetails.teamA.wins > ownerDetails.teamB.wins and ownerDetails.teamB.players or ownerDetails.teamA.players
                for _, playerDetails in pairs(winningTeam) do
                    FinishWager(playerDetails.source, getPlayerNames(winningTeam), true)
                    AMB.notify(playerDetails.source, "~g~Received £" .. getMoneyStringFormatted(ownerDetails.betAmount*2) .. " from the wager!")
                    AMB.giveBankMoney(playerDetails.user_id, tonumber(ownerDetails.betAmount*2))
                end
                for _, playerDetails in pairs(losingTeam) do
                    FinishWager(playerDetails.source, getPlayerNames(winningTeam), false)
                end
                TriggerClientEvent('chatMessage', -1, "^7AMB Arena | " .. getPlayerNames(winningTeam) .. " has WON £" .. getMoneyStringFormatted(ownerDetails.betAmount*2) .. " from a wager!", { 128, 128, 128 }, message, "green")
            else
                local i = 1
                for _, playerDetails in pairs(ownerDetails.teamA.players) do
                    preparePlayerForDuel(playerDetails, {ownerDetails.teamALoc[i].x, ownerDetails.teamALoc[i].y, ownerDetails.teamALoc[i].z, globalpasskey}, ownerDetails.owner_id)
                    i = i + 1
                end
                i = 1
                for _, playerDetails in pairs(ownerDetails.teamB.players) do
                    preparePlayerForDuel(playerDetails, {ownerDetails.teamBLoc[i].x, ownerDetails.teamBLoc[i].y, ownerDetails.teamBLoc[i].z, globalpasskey}, ownerDetails.owner_id)
                    i = i + 1
                end
            end
        end
        TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
    end
end

RegisterServerEvent("AMB:getWagerData", function()
    local source = source
    if wagerTeam then
        TriggerClientEvent("AMB:sendWagerData", source, wagerTeam)
    end
end)

AddEventHandler("AMB:playerLeave", function(user_id, source)
    local ownerDetails = getOwnerDetails(wagerCurrentlyIn[source])
    if ownerDetails then
        if ownerDetails.teamA.players[user_id] then
            ownerDetails.teamA.players[user_id] = nil
        end
        if ownerDetails.teamB.players[user_id] then
            ownerDetails.teamB.players[user_id] = nil
        end
        if ownerDetails.teamA.players then
            for _, playerDetails in pairs(ownerDetails.teamA.players) do
                FinishWager(playerDetails.source, nil, false, true)
            end
        end
        if ownerDetails.teamB.players then
            for _, playerDetails in pairs(ownerDetails.teamB.players) do
                FinishWager(playerDetails.source, nil, false, true)
            end
        end
    end
    if wagerTeam[user_id] then
        wagerTeam[user_id] = nil
    end
    TriggerClientEvent("AMB:sendWagerData", -1, wagerTeam)
end)

RegisterNetEvent("AMB:getWagerStats")
AddEventHandler("AMB:getWagerStats", function()
    local source = source
    local user_id = AMB.getUserId(source)
    local sql = exports['amb']:executeSync("SELECT * FROM amb_wager_stats WHERE user_id = @user_id", {user_id = user_id})[1]
    local data = json.decode(sql.wager_stats)
    if data == nil then
        data = {total_bets = 0, weapons = {}, most_used_weapon = "N/A", categories = {}, most_played_category = "N/A", total_bets_won = 0, total_bets_lost = 0, total_money_won = 0, total_money_lost = 0}
    end
    local wagerStats = {
        [1] = 'Bets ~b~'..getMoneyStringFormatted(data.total_bets),
        [2] = 'Bets Won ~b~'..getMoneyStringFormatted(data.total_bets_won),
        [3] = 'Bets Lost ~b~'..getMoneyStringFormatted(data.total_bets_lost),
        [4] = '',
        [5] = 'Money Won ~b~'..getMoneyStringFormatted(data.total_money_won),
        [6] = 'Money Lost ~b~'..getMoneyStringFormatted(data.total_money_lost),
        [7] = 'W/L Ratio ~b~'..math.floor(data.total_bets_won/data.total_bets*100) .. '%',
        [8] = '',
        [9] = 'Most Played Category ~b~'..data.most_played_category or "N/A",
        [10] = 'Most Used Weapon ~b~'..data.most_used_weapon or "N/A"
    }
    TriggerClientEvent("AMB:setWagerStats", source, wagerStats)
end)

function AMB.updateWagerStats(user_id, amount, won, category, weapon)
    weapon = AMB.getWeaponName(weapon)
    local data = json.decode(exports['amb']:executeSync("SELECT * FROM amb_wager_stats WHERE user_id = @user_id", {user_id = user_id})[1].wager_stats)
    if data == nil then
        data = {total_bets = 0, weapons = {}, most_used_weapon = "N/A", categories = {}, most_played_category = "N/A", total_bets_won = 0, total_bets_lost = 0, total_money_won = 0, total_money_lost = 0}
    end
    if won then
        data.total_bets_won = data.total_bets_won + 1
        data.total_money_won = data.total_money_won + amount*2
    else
        data.total_bets_lost = data.total_bets_lost + 1
        data.total_money_lost = data.total_money_lost + amount
    end
    if category then data.categories[category] = (data.categories[category] or 0) + 1 end
    if weapon then data.weapons[weapon] = (data.weapons[weapon] or 0) + 1 end
    data.most_played_category = findMaxKey(data.categories) or "N/A"
    data.most_used_weapon = findMaxKey(data.weapons) or "N/A"
    data.total_bets = data.total_bets + 1
    exports['amb']:executeSync("UPDATE amb_wager_stats SET wager_stats = @wager_stats WHERE user_id = @user_id", {wager_stats = json.encode(data), user_id = user_id})
end

-- function AMB.giveItemsBackAfterWager(source)
--     local user_id = AMB.getUserId(source)
--     AMB.getUData(user_id, "AMB:datatable", function(data)
--         data = json.decode(data)
--         vRPclient.giveWeapons(source, {data.weapons, true, globalpasskey})
--     end)
-- end
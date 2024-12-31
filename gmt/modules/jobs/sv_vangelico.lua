local userRewards = {}
local heistTeam = {}
local pendingInvites = {}
local heistInProgress = false
local TotalSum = 0

--[[ 
    heistTeam = {
        [owner_id] = {
            players = {
                [player_id] = {
                    src = src,
                    user_id = player_id,
                    name = GMT.getPlayerName(player_id),
                    owner = true,
                    hackedComputer = false,
                    inHeist = false
                },
            },
            heistInProgress = false
        },
        [player_id] = {
            players = {},
            heistInProgress = false
        }
    }
 ]]

RegisterServerEvent('GMT:server:rewardItem')
AddEventHandler('GMT:server:rewardItem', function(item)
    local source = source
    local user_id = GMT.getUserId(source)
    local isInHeistTeam = false
    for _, teamPlayer in pairs(heistTeam) do
        if teamPlayer.user_id == user_id then
            isInHeistTeam = true
            break
        end
    end
    if isInHeistTeam then
        local reward = math.random(70000,500000)
        TotalSum = TotalSum + reward
        for _, teamPlayer in pairs(heistTeam) do
            TriggerClientEvent('GMT:client:TotalSum', teamPlayer.src, TotalSum)
        end
        if not userRewards[user_id] then
            userRewards[user_id] = {}
        end
        userRewards[user_id] = {src = source, user_id = user_id, item = item, reward = reward}
    else
        GMT.notify(source, "~r~Don't try that again....")
    end
end)

RegisterServerEvent('GMT:server:notifyPolice')
AddEventHandler('GMT:server:notifyPolice', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if heistInProgress then
       TriggerClientEvent('GMT:GenericAlarm', -1)
        for a, b in pairs(GMT.getUsers({})) do
            if GMT.hasPermission(a, "police.armoury") then
                TriggerClientEvent('chatMessage', b, "^7Robbery in progress at ^2Vangelico Jewelry Store", { 128, 128, 128 }, message, "alert")
                TriggerEvent('GMT:PDHeistRobberyCall', b, "Vangelico Jewelry Store", GetEntityCoords(GetPlayerPed(source)))
            end
        end
    end
end)

RegisterServerEvent("GMT:server:startHeist")
AddEventHandler("GMT:server:startHeist", function(amount)
    local src = source
    local player = GMT.getUserId(src)
    if #GMT.getUsersByPermission('police.armoury') <= 3 then
        GMT.notify(src, "~r~There are not enough police on duty to rob Vangelico.")
        return
    end
    if not GMT.tryBankPayment(player, amount) then
        GMT.notify(src, "~r~You do not have enough money to start the heist!")
            return
    end
    if not heistInProgress then
        heistTeam[player].inHeist = true
        TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam)
        TriggerClientEvent('GMT:client:setInHeist', src, true)
        GMT.notify(src, "~g~Paid £" .. getMoneyStringFormatted(amount))
    else
        GMT.notify(src, "~r~A heist is already in progress!")
    end
end)

RegisterServerEvent("GMT:server:startHeist")
AddEventHandler("GMT:server:startHeist", function()
    local src = source
    local player = GMT.getUserId(src)
    if heistTeam[player] then  
        if heistTeam[player].inHeist then
            if heistTeam[player].owner then
                for _, teamPlayer in pairs(heistTeam) do
                Wait(5000)
                --
                TriggerClientEvent('GMT:jewelryHeistReady', teamPlayer.src, true)
                TriggerClientEvent('GMT:jewelryComputerHackArea', teamPlayer.src, true)
                TriggerClientEvent('GMT:client:setHeist', teamPlayer.src, true)
                TriggerClientEvent('GMT:client:VangelicoSetup', teamPlayer.src, true)
                TriggerClientEvent('GMT:client:setInHeist', teamPlayer.src, true)
                --
                heistTeam[teamPlayer.user_id].inHeist = true
                heistInProgress = true
                GMTclient.giveWeapons(teamPlayer.src, {{["WEAPON_BZGAS"] = {ammo = 25}}, false, globalpasskey})
                print("[GMT] In Heist: " .. GMT.getPlayerName(teamPlayer.user_id))
            end
            TriggerClientEvent('GMT:jewelrySyncDoor', -1, true)
        else
            GMT.notify(src, "~r~Only the heist leader can start the heist!")
        end
    else
        GMT.notify(src, "~r~Unable to start the heist!")
    end
else
    GMT.notify(src, "~r~Player not found in heist team!")
end
end)

function GMT.inHeist(player)
    if heistTeam[player] then
        return heistTeam[player].inHeist
    end
    return false
end

RegisterServerEvent("GMT:server:beginVangelicoSetup")
AddEventHandler("GMT:server:beginVangelicoSetup", function()
    local src = source
    local player = GMT.getUserId(src)

    if #GMT.getUsersByPermission('police.armoury') > 3 then
        if not heistInProgress then
            heistTeam = {}
            heistTeam[player] = {src = src, user_id = player, name = GMT.getPlayerName(player), owner = true, hackedComputer = false, inHeist = false}
            TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam)
            TriggerClientEvent('GMT:client:setInHeist', src, true)
        else
            GMT.notify(src, "~r~A heist is already in progress!")
        end
    else
        GMT.notify(src, "~r~There are not enough police on duty to rob Vangelico.")
    end
end)

RegisterServerEvent('GMT:server:joinHeist')
AddEventHandler('GMT:server:joinHeist', function()
    local src = source
    local player = GMT.getUserId(src)
    if not heistTeam[player] then
        if #heistTeam <=3 then
            if not heistInProgress then
                if pendingInvites[player].invited then
                    heistTeam[player] = {src = src, user_id = player, name = GMT.getPlayerName(player), owner = false, hackedComputer = false, inHeist = false}
                    TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam) 
                    TriggerClientEvent('GMT:client:setInHeist', src, true)
                    TriggerClientEvent('GMT:client:toggleHeistMenu', src, true)
                    pendingInvites[player] = nil
                else
                    GMT.notify(src, "~r~You have no pending invites!")
                end
            else
                GMT.notify(src, "~r~There is currently no heist in progress!")
            end
        else
            GMT.notify(src, "~r~The heist is full!")
        end
    else
        GMT.notify(src, "~r~You are already in the heist!")
    end
end)

RegisterServerEvent('GMT:server:invitePlayerHeist')
AddEventHandler('GMT:server:invitePlayerHeist', function(player_id)
    local src = source
    local player = GMT.getUserId(src)
    if heistTeam[player].owner then
        if #heistTeam <=10 then
            if GMT.getUserSource(tonumber(player_id)) then
                if tonumber(player_id) ~= player then
                    pendingInvites[tonumber(player_id)] = {src = GMT.getUserSource(tonumber(player_id)), user_id = tonumber(player_id), name = GMT.getPlayerName(player_id), invited = true}
                    TriggerClientEvent('GMT:client:invitePlayerHeist', GMT.getUserSource(tonumber(player_id)), GMT.getPlayerName(player))
                else
                    GMT.notify(src, "~r~You cannot invite yourself!")
                end
            else
                GMT.notify(src, "~r~Player is not online!")
            end
        else
            GMT.notify(src, "~r~The heist is full!")
        end
    else
        GMT.notify(src, "~r~Only the heist leader can invite players!")
    end
end)

RegisterServerEvent('GMT:HeistsBuyFullArmour')
AddEventHandler('GMT:HeistsBuyFullArmour', function()
    local src = source
    local player = GMT.getUserId(src)
    if heistTeam[player] then
        if GMT.tryBankPayment(player, 50000) then
            GMTclient.setArmour(src, {100, true})
            GMT.notify(src,"~g~Paid £" .. getMoneyStringFormatted(50000))
        else
            GMT.notify(src, "~r~Not enough money")
        end
    else
        GMT.notify(src, "~r~Wait till the heist starts!")
    end
end)

local hacking = false
local computerHacking = false

RegisterServerEvent("GMT:jewelryHackDoor")
AddEventHandler("GMT:jewelryHackDoor", function()
    local src = source
    local player = GMT.getUserId(src)
    if not hacking then
        hacking = true
        TriggerClientEvent("GMT:jewelryStartDoorHackSf",src)
    else
        GMT.notify(src, "~r~Door is already being hacked!")
    end
end)

RegisterServerEvent("GMT:jewelryHackComputer")
AddEventHandler("GMT:jewelryHackComputer", function()
    local src = source
    local player = GMT.getUserId(src)
    if not computerHacking then
        computerHacking = true
        TriggerClientEvent("GMT:jewelryStartComputerHackSf",src)
    else
        GMT.notify(src, "~r~Computer is already being hacked!")
    end
end)

RegisterServerEvent("GMT:jewelryDoorHackSuccess")
AddEventHandler("GMT:jewelryDoorHackSuccess", function()
    local src = source
    local player = GMT.getUserId(src)
    if hacking then
        hacking = false
        -- for _, teamPlayer in pairs(heistTeam) do
        --     heistTeam[teamPlayer.user_id].hackedDoor = true
        -- end
        --TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam) 
    end
end)

RegisterServerEvent("GMT:jewelryDoorHackFailed")
AddEventHandler("GMT:jewelryDoorHackFailed", function()
    local src = source
    local player = GMT.getUserId(src)
    if hacking then
        hacking = false
    end
end)


RegisterServerEvent("GMT:jewelryComputerHackSuccess")
AddEventHandler("GMT:jewelryComputerHackSuccess", function()
    local src = source
    local player = GMT.getUserId(src)
    if computerHacking then
        computerHacking = false
        for _, teamPlayer in pairs(heistTeam) do
            heistTeam[teamPlayer.user_id].hackedComputer = true
        end
        TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam) 
    end
end)

RegisterServerEvent("GMT:jewelryComputerHackFailed")
AddEventHandler("GMT:jewelryComputerHackFailed", function()
    local src = source
    local player = GMT.getUserId(src)
    if computerHacking then
        computerHacking = false
        -- for _, teamPlayer in pairs(heistTeam) do
        --     --
        -- end
    end
end)

RegisterServerEvent("GMT:server:syncGas")
AddEventHandler("GMT:server:syncGas", function()
    local src = source
    local player = GMT.getUserId(src)

    for _, teamPlayer in pairs(heistTeam) do
        TriggerClientEvent('GMT:client:BeginVangelicoHeist', teamPlayer.src)
    end
end)

RegisterServerEvent("GMT:server:syncWinnerScreen")
AddEventHandler("GMT:server:syncWinnerScreen", function()
    local src = source
    local player = GMT.getUserId(src)

    for _, teamPlayer in pairs(heistTeam) do
        TriggerClientEvent('GMT:client:syncWinnerScreen', teamPlayer.src)
    end
end)

RegisterServerEvent("GMT:server:winnerSRV")
AddEventHandler("GMT:server:winnerSRV", function()
    local src = source
    local player = GMT.getUserId(src)

    for _, teamPlayer in pairs(heistTeam) do
        TriggerClientEvent('GMT:client:outside', teamPlayer.src)
    end
    TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam) 
end)

RegisterServerEvent("GMT:server:cancelHeist")
AddEventHandler("GMT:server:cancelHeist", function()
    local src = source
    local player = GMT.getUserId(src)

    if heistTeam[player].owner then
        for i, teamPlayer in pairs(heistTeam) do
            TriggerClientEvent('GMT:client:setHeist', teamPlayer.src, false)
        end
        heistInProgress = false
        heistTeam = {}
        TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam) 
    else
        GMT.notify(src, "~r~Only the heist leader can cancel the heist!")
    end
end)

RegisterServerEvent("GMT:server:getHeistData")
AddEventHandler("GMT:server:getHeistData", function()
    local src = source
    local player = GMT.getUserId(src)
    if heistTeam then
        TriggerClientEvent("GMT:client:sendHeistData", src, heistTeam)
    end
end)

RegisterServerEvent('GMT:server:leaveHeist')
AddEventHandler('GMT:server:leaveHeist', function()
    local src = source
    local player = GMT.getUserId(src)

    if GMT.inHeist(player) then
        heistTeam[player] = nil
        TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam) 
        GMT.notify(src, "~r~Left the heist!")
    else
        GMT.notify(src, "~r~You are not in a heist?")
    end
end)

RegisterServerEvent('GMT:server:kickHeist')
AddEventHandler('GMT:server:kickHeist', function(SelectedDetails)
    local src = source
    local player = GMT.getUserId(src)
    if SelectedDetails.user_id ~= player then
        if heistTeam[player].owner then
            for i, teamPlayer in pairs(heistTeam) do
                if teamPlayer.src == SelectedDetails.src then
                    heistTeam[i] = nil
                    break
                end
            end
            TriggerClientEvent('GMT:client:setHeist', SelectedDetails.src, false)
            TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam) 
        else
            GMT.notify(src, "~r~Only the heist leader can kick players!")
        end
    else
        GMT.notify(src, "~r~You cannot kick yourself!")
    end
end)

RegisterServerEvent('GMT:server:promoteHeist')
AddEventHandler('GMT:server:promoteHeist', function(SelectedDetails)
    local src = source
    local player = GMT.getUserId(src)
    if SelectedDetails.user_id ~= player then
        if heistTeam[player].owner then
            heistTeam[SelectedDetails.user_id].owner = true
            heistTeam[player].owner = false
            TriggerClientEvent('GMT:client:BeginSetupVangelico', SelectedDetails.src, true)
            TriggerClientEvent("GMT:client:sendHeistData", -1, heistTeam)
        else
            GMT.notify(src, "~r~Only the heist leader can promote players!")
        end
    else
        GMT.notify(src, "~r~You are already the heist leader!")
    end
end)

RegisterServerEvent('GMT:server:sellRewardItems')
AddEventHandler('GMT:server:sellRewardItems', function(TotalSumOfMoney)
    local src = source
    local player = GMT.getUserId(src)
    if player then
        local cut = TotalSumOfMoney / #heistTeam
        for _, teamPlayer in pairs(heistTeam) do
            GMT.giveDirtyCash(teamPlayer.user_id, cut)
            TriggerClientEvent("GMT:client:TotalSum", teamPlayer.src, 0)
            TriggerClientEvent("GMT:client:winVangelicoHeist", teamPlayer.src, math.floor(cut), teamPlayer.name)
        end
        GMT.sendDCLog("vangelico-heist", "GMT Vangelico Heist Logs", "Started talkin to dat guy, money thing: " .. math.floor(cut))
        GMT.notify(src,'~b~Received ~r~' .. math.floor(cut) .. ' ~b~dirty cash')
        userRewards[player] = {}
        if GMT.inHeist(player) then
            heistInProgress = false
            heistTeam = {}
        end
    end
end)

RegisterServerEvent('GMT:server:startGas')
AddEventHandler('GMT:server:startGas', function()
    TriggerClientEvent('GMT:client:startGas', -1)
end)

RegisterServerEvent("GMT:server:syncMarker")
AddEventHandler("GMT:server:syncMarker", function(index)
    TriggerClientEvent('GMT:client:markerSync', -1,index)
end)

RegisterServerEvent('GMT:server:insideLoop')
AddEventHandler('GMT:server:insideLoop', function()
    TriggerClientEvent('GMT:client:insideLoop', -1)
end)

RegisterServerEvent('GMT:server:lootSync')
AddEventHandler('GMT:server:lootSync', function(ggg, index)
    TriggerClientEvent('GMT:client:lootSync', -1, ggg, index)
end)

RegisterServerEvent('GMT:server:globalObject')
AddEventHandler('GMT:server:globalObject', function(obj, random)
    TriggerClientEvent('GMT:client:globalObject', -1, obj, random)
end)

RegisterServerEvent('GMT:server:smashSync')
AddEventHandler('GMT:server:smashSync', function(sceneConfig)
    TriggerClientEvent('GMT:client:smashSync', -1, sceneConfig)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local player = GMT.getUserId(src)
    if userRewards[player] then
        userRewards[player] = nil
    end
    if GMT.inHeist(player) then
        heistTeam[player] = nil
    end
end)
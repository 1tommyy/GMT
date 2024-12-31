local cfg = module("cfg/cfg_trucking")
local currentJob = {}
local currentVehicle = {}
local playerLevels = {}
local usersInTruckerJob = {}
local rentedTrucks = {}
local spawnedVehicles = {}
local playerXP = {}
local rentedTruck = {}
local amountOfXPGained = 400
RegisterServerEvent('GMT:startTruckerJob')
AddEventHandler('GMT:startTruckerJob', function(jobName, isNextJob)
    local source = source
    local user_id = GMT.getUserId(source)
    local jobConfig = cfg.jobs[jobName]

    if jobConfig == nil then
        print("Error: job name " .. jobName .. " does not exist in cfg.jobs")
        return
    end

    currentJob = jobConfig
    
    if GMT.hasGroup(user_id,"Lorry Driver") then
        if rentedTruck[user_id] then
            exports['gmt']:execute("SELECT level, xp FROM gmt_trucking WHERE user_id = @user_id", {['@user_id'] = user_id}, function(result)
                playerLevels[user_id] = result[1].level
                playerXP[user_id] = result[1].xp
                spawnedVehicles = {}

                if not isNextJob then
                    GMT.notify(source, "~y~Notice: Goverment regulations have limited trucking to 150 MPH")
                    TriggerClientEvent('GMT:GMTSetInitialXPLevels', source, playerXP[user_id], false, false)
                    TriggerClientEvent('GMT:SetInitialXPLevels', source, playerLevels[user_id])
                    usersInTruckerJob[user_id] = true
                end
                TriggerClientEvent("GMT:startTruckerJobCl", source, jobConfig, isNextJob)
            end)
        else
            GMT.notify(source, "~r~You do not currently own or rent any trucks You can get one outside.")
        end
    else
        GMT.notify(source, "~r~You are not a trucker!")
    end
end)

RegisterServerEvent("GMT:TruckerLevelUp")
AddEventHandler("GMT:TruckerLevelUp", function(level)
    local source = source
    local user_id = GMT.getUserId(source)
    local CurLevel = level
    if GMT.hasGroup(user_id,"Lorry Driver") and usersInTruckerJob[user_id] then
        if CurLevel == 0 then
            CurLevel = 1
        end
        exports['gmt']:execute("UPDATE gmt_trucking SET level = @level WHERE user_id = @user_id",{['@user_id'] = user_id,['@level'] = CurLevel})
        GMT.notify(source, "~h~~b~LEVEL UP~h~:\n~g~You have reached Trucking Level: " .. CurLevel)
       -- print("[TRUCKING]: Updating LEVEL for " .. GMT.getPlayerName(user_id) .. " to " .. CurLevel)
    else
        GMT.ACBan(15,user_id,"GMT:TruckerLevelUp")
    end
end)

RegisterServerEvent('GMT:jobCompleted')
AddEventHandler('GMT:jobCompleted', function(jobType)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasGroup(user_id,"Lorry Driver") and usersInTruckerJob[user_id] then
        exports['gmt']:execute("SELECT level, xp FROM gmt_trucking WHERE user_id = @user_id", {['@user_id'] = user_id}, function(result)
            local currentLevel = result[1].level
            local currentXP = result[1].xp
            local payout = currentJob[1].payout
            if jobType == "Illegal" then
                if currentLevel % 2 == 0 then
                    payout = payout + 600000 -- Extra 600k every 2 levels
                end
                message = "~b~Received ~g~£" .. getMoneyStringFormatted(payout)
                GMT.notify(source, "Received ~g~Dirty Cash ~w~" .. payout)
                GMT.giveDirtyCash(user_id, payout)
                if math.random(1, 100) <= 20 then -- 20% chance
                    for a, b in pairs(GMT.getUsers({})) do
                        if GMT.hasPermission(a, "police.armoury") then
                            TriggerEvent('GMT:PDTruckingCall', b, "Illegal Trucking Activity", GetEntityCoords(GetPlayerPed(source)))
                        end
                    end
                    print("[TRUCKING]: " .. GMT.getPlayerName(user_id) .. " has been reported for illegal trucking activity")
                end
            else
                if currentLevel % 2 == 0 then
                    payout = payout + 300000 -- Extra 300k every 2 levels
                end
                message = "~b~Received ~g~£" .. getMoneyStringFormatted(payout)
                GMT.giveBankMoney(user_id, payout)
            end
            local newXP = currentXP + amountOfXPGained
            exports['gmt']:execute("UPDATE gmt_trucking SET xp = @xp WHERE user_id = @user_id",{['@user_id'] = user_id,['@xp'] = newXP})
            TriggerClientEvent('GMT:AddPlayerXP', source, amountOfXPGained)
            GMT.notify(source, message)
            TriggerClientEvent('GMT:startNextJob', source)
        end)
    else
      -- GMT.ACBan(15,user_id,"GMT:jobCompleted")
    end
end)

-- Trucking renting --

MySQL.createCommand("GMT/get_rented_trucks", "SELECT vehicle FROM gmt_user_vehicles WHERE user_id = @user_id AND rentedtime IS NOT NULL")
MySQL.createCommand("GMT/update_rented_time", "UPDATE gmt_user_vehicles SET rentedtime = NOW() WHERE user_id = @user_id AND vehicle = @vehicle")

RegisterServerEvent('GMT:getRentedTrucks')
AddEventHandler('GMT:getRentedTrucks', function()
    local src = source
    local user_id = GMT.getUserId(src)
    MySQL.query("GMT/get_rented_trucks", {user_id = user_id}, function(result)
        if result then
            for k,v in pairs(result) do
                table.insert(rentedTrucks, v.vehicle)
            end
            TriggerClientEvent('GMT:updateOwnedTrucks', src, rentedTrucks)
        end
    end)
end)

RegisterServerEvent('GMT:spawnTruck')
AddEventHandler('GMT:spawnTruck', function(truckName)
    local src = source
    local user_id = GMT.getUserId(src)
    if GMT.hasGroup(user_id,"Lorry Driver") then
        MySQL.query("GMT/get_rented_trucks", {user_id = user_id}, function(result)
            if result ~= nil then
                if spawnedVehicles[truckName] then
                    GMT.notify(src, "~r~That Truck is already out!")
                else
                    TriggerClientEvent('GMT:spawnTruckCl', src, truckName)
                    spawnedVehicles[truckName] = true
                end
            else
                GMT.notify(src, "~r~You have not rented this truck!")
            end
        end)
    else
        GMT.notify(src, "~r~You must be a trucker to spawn a truck!")
    end
end)

RegisterServerEvent('GMT:rentTruck')
AddEventHandler('GMT:rentTruck', function(truckName, truckPrice)
    local src = source
    local user_id = GMT.getUserId(src)
    if GMT.hasGroup(user_id,"Lorry Driver") then
        MySQL.query("GMT/get_rented_trucks", {user_id = user_id}, function(result)
            local isRented = false
            for k,v in pairs(result) do
                if v.vehicle == truckName then
                    isRented = true
                    break
                end
            end
            if GMT.tryBankPayment(user_id, truckPrice) then
                TriggerEvent('GMT:getRentedTrucks')
                GMT.notify(src, "~r~Paid £" .. getMoneyStringFormatted(truckPrice) .. ".")
                rentedTruck[user_id] = true
                MySQL.execute("GMT/update_rented_time", {user_id = user_id, vehicle = truckName})
            else
                GMT.notify(src, "~r~You cannot afford this :(")
            end
        end)
    else
        GMT.notify(src, "~r~You must be a trucker to rent a truck!")
    end
end)

-- End Truck Renting --

RegisterNetEvent('GMT:setTruck')
AddEventHandler('GMT:setTruck', function(networkId)
    local source = source
    local user_id = GMT.getUserId(source)
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    if GMT.hasGroup(user_id,"Lorry Driver") and usersInTruckerJob[user_id] then
        spawnedVehicles[vehicle] = true
      --  print("[TRUCKING]: " .. GMT.getPlayerName(user_id) .. " truck set to " .. vehicle)
    else
        GMT.ACBan(15,user_id,"GMT:setTruck")
    end
end)

RegisterServerEvent('GMT:endTruckerJob')
AddEventHandler('GMT:endTruckerJob', function(message)
    local source = source
    local user_id = GMT.getUserId(source)

    if GMT.hasGroup(user_id,"Lorry Driver") then
        TriggerClientEvent('GMT:endTruckerJobCl', source, message)
        usersInTruckerJob[user_id] = nil
        spawnedVehicles = nil
    else
        GMT.ACBan(15,user_id,"GMT:endTruckerJob")
    end
end)

MySQL.createCommand("gmt_trucking/adduser","INSERT INTO gmt_trucking (user_id,xp,level) VALUES (@user_id,@xp,@level) ON DUPLICATE KEY UPDATE xp = @xp, level = @level")
MySQL.createCommand("gmt_trucking/getuser","SELECT * FROM gmt_trucking WHERE user_id = @user_id")

AddEventHandler("GMT:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        local defaultdata = {user_id = user_id, xp = 0, level = 1}
        MySQL.execute("gmt_trucking/adduser",{user_id = user_id, xp = defaultdata.xp, level = defaultdata.level})
        Wait(15000)
        exports['gmt']:execute("SELECT level FROM gmt_trucking WHERE user_id = @user_id", {['@user_id'] = user_id}, function(result)
            playerLevels[user_id] = result[1].level
            TriggerClientEvent('GMT:SetInitialXPLevels', source, playerLevels[user_id], false, false)
        end)
    end
end)
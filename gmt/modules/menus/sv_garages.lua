local lang = GMT.lang
local cfg = module("cfg/cfg_garages")
local cfg_inventory = module("cfg/cfg_inventory")
local vehicle_groups = cfg.garages
local limit = cfg.limit or 100000000
MySQL.createCommand("GMT/add_vehicle","INSERT IGNORE INTO gmt_user_vehicles(user_id,vehicle,vehicle_plate,locked) VALUES(@user_id,@vehicle,@registration,@locked)")
MySQL.createCommand("GMT/remove_vehicle","DELETE FROM gmt_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("GMT/get_vehicles", "SELECT vehicle, rentedtime, vehicle_plate, fuel_level, impounded FROM gmt_user_vehicles WHERE user_id = @user_id")
MySQL.createCommand("GMT/get_vehicle_by_plate", "SELECT vehicle, rentedtime, vehicle_plate, fuel_level, impounded FROM gmt_user_vehicles WHERE user_id = @user_id AND vehicle_plate = @plate")
MySQL.createCommand("GMT/get_rented_vehicles_in", "SELECT vehicle, rentedtime, user_id FROM gmt_user_vehicles WHERE user_id = @user_id AND rented = 1")
MySQL.createCommand("GMT/get_rented_vehicles_out", "SELECT vehicle, rentedtime, user_id FROM gmt_user_vehicles WHERE rentedid = @user_id AND rented = 1")
MySQL.createCommand("GMT/get_vehicle","SELECT vehicle FROM gmt_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("GMT/get_vehicle_fuellevel","SELECT fuel_level FROM gmt_user_vehicles WHERE vehicle = @vehicle")
MySQL.createCommand("GMT/check_rented","SELECT * FROM gmt_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND rented = 1")
MySQL.createCommand("GMT/sell_vehicle_player","UPDATE gmt_user_vehicles SET user_id = @user_id, vehicle_plate = @registration WHERE user_id = @oldUser AND vehicle = @vehicle")
MySQL.createCommand("GMT/rentedupdate", "UPDATE gmt_user_vehicles SET user_id = @id, rented = @rented, rentedid = @rentedid, rentedtime = @rentedunix WHERE user_id = @user_id AND vehicle = @veh")
MySQL.createCommand("GMT/fetch_rented_vehs", "SELECT * FROM gmt_user_vehicles WHERE rented = 1")
MySQL.createCommand("GMT/get_vehicle_count","SELECT vehicle FROM gmt_user_vehicles WHERE vehicle = @vehicle")

RegisterServerEvent("GMT:spawnPersonalVehicle")
AddEventHandler('GMT:spawnPersonalVehicle', function(vehicle)
    local source = source
    local user_id = GMT.getUserId(source)
    MySQL.query("GMT/get_vehicles", {user_id = user_id}, function(result)
        if result then 
            for k,v in pairs(result) do
                if v.vehicle == vehicle then
                    if v.impounded then
                        GMT.notify(source, '~r~This vehicle is currently impounded.')
                        return
                    else
                        GMT.sendDCLog("vehicle", "GMT Spawn Vehicle Logs", "> Vehicle Spawncode: " .. vehicle .. " \n> Players Name: " .. GMT.getPlayerName(user_id) .. " \n> Players TempID: " .. source .. " \n> Players PermID: " .. user_id)
                        TriggerClientEvent('GMT:spawnPersonalVehicle', source, v.vehicle, GMT.GetMods(v.vehicle,user_id), false, GetEntityCoords(GetPlayerPed(source)), v.vehicle_plate, v.fuel_level)
                        return
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent('phone:garage:getVehicles')
AddEventHandler('phone:garage:getVehicles', function()
    local source = source
    local user_id = GMT.getUserId(source)
    MySQL.query("GMT/get_vehicles", {user_id = user_id}, function(result)
        if result then 
            local vehicles = {}
            for i, vehicle in ipairs(result) do
                vehicles[i] = {model = vehicle.vehicle, plate = vehicle.vehicle_plate}
            end

            TriggerClientEvent('phone:garage:receiveVehicles', source, vehicles)
        end
    end)
end)

valetCooldown = {}
RegisterServerEvent("GMT:valetSpawnVehicle")
AddEventHandler('GMT:valetSpawnVehicle', function(spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    GMTclient.isPlusClub(source,{},function(plusclub)
        GMTclient.isPlatClub(source,{},function(platclub)
            if plusclub or platclub then
                if valetCooldown[source] and not (os.time() > valetCooldown[source]) then
                    TriggerClientEvent("GMT:SpawnValetSuccess", source, false)
                    return GMT.notify(source, "~r~You are being rate limited, please wait.")
                else
                    valetCooldown[source] = nil
                end
                MySQL.query("GMT/get_vehicles", {user_id = user_id}, function(result)
                    if result then 
                        for k,v in pairs(result) do
                            if v.vehicle == spawncode then
                                TriggerClientEvent("GMT:SpawnValetSuccess", source, true)
                                TriggerClientEvent('GMT:spawnPersonalVehicle', source, v.vehicle, GMT.GetMods(v.vehicle,user_id), true, GetEntityCoords(GetPlayerPed(source)), v.vehicle_plate, v.fuel_level)
                                valetCooldown[source] = os.time() + 60
                                return
                            end
                        end
                    end
                end)
            else
                TriggerClientEvent("GMT:SpawnValetSuccess", source, false)
                GMT.notify(source, "~g~You are not a subscriber of GMT Plus or GMT Platinum.")
            end
        end)
    end)
end)

RegisterServerEvent("GMT:getVehicleRarity")
AddEventHandler('GMT:getVehicleRarity', function(spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    MySQL.query("GMT/get_vehicle_count", {vehicle = spawncode}, function(result)
        if result then 
            TriggerClientEvent('GMT:setVehicleRarity', source, spawncode, #result)
        end
    end)
end)

RegisterServerEvent("GMT:displayVehicleBlip")
AddEventHandler('GMT:displayVehicleBlip', function(spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    local mods = GMT.GetDefaultMods()
    GMTclient.getOwnedVehiclePosition(source, {spawncode}, function(x,y,z)
        if vector3(x,y,z) ~= vector3(0,0,0) then
            if mods.security_blips then
                local position = {}
                position.x, position.y, position.z = x,y,z
                if next(position) then
                    TriggerClientEvent('GMT:displayVehicleBlip', source, position)
                    GMT.notify(source, "~g~Vehicle blip enabled.")
                    return
                end
            else
                GMT.notify(source, "~r~This vehicle does not have a remote vehicle blip installed.")
            end
        else
            GMT.notify(source, "~r~Can not locate vehicle with the plate "..mods.vehicle_plate.." in this city.")
        end
    end)
end)

RegisterServerEvent("GMT:viewRemoteDashcam")
AddEventHandler('GMT:viewRemoteDashcam', function(spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    local mods = GMT.GetDefaultMods()
    GMTclient.getOwnedVehiclePosition(source, {spawncode}, function(x,y,z)
        if vector3(x,y,z) ~= vector3(0,0,0) then
            if mods.security_dashcam then
                local position = table.pack(x,y,z)
                if next(position) then
                    for k,v in pairs(netObjects) do
                        TriggerClientEvent('GMT:viewRemoteDashcam', source, position, k)
                        return
                    end
                end
            else
                GMT.notify(source, "~r~This vehicle does not have a remote dashcam installed.")
            end
        else
            GMT.notify(source, "~r~Can not locate vehicle with the plate "..mods.vehicle_plate.." in this city.")
        end
    end)
end)

RegisterServerEvent("GMT:updateFuel")
AddEventHandler('GMT:updateFuel', function(vehicle, fuel_level)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("UPDATE gmt_user_vehicles SET fuel_level = @fuel_level WHERE user_id = @user_id AND vehicle = @vehicle", {fuel_level = fuel_level, user_id = user_id, vehicle = vehicle}, function() end)
end)

RegisterServerEvent("GMT:getCustomFolders")
AddEventHandler('GMT:getCustomFolders', function()
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * from `gmt_custom_garages` WHERE user_id = @user_id", {user_id = user_id}, function(Result)
        if #Result > 0 then
            TriggerClientEvent("GMT:sendFolders", source, json.decode(Result[1].folder))
        end
    end)
end)


RegisterServerEvent("GMT:updateFolders")
AddEventHandler('GMT:updateFolders', function(FolderUpdated)
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:execute("SELECT * from `gmt_custom_garages` WHERE user_id = @user_id", {user_id = user_id}, function(Result)
        if #Result > 0 then
            exports['gmt']:execute("UPDATE gmt_custom_garages SET folder = @folder WHERE user_id = @user_id", {folder = json.encode(FolderUpdated), user_id = user_id}, function() end)
        else
            exports['gmt']:execute("INSERT INTO gmt_custom_garages (`user_id`, `folder`) VALUES (@user_id, @folder);", {user_id = user_id, folder = json.encode(FolderUpdated)}, function() end)
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        MySQL.query('GMT/fetch_rented_vehs', {}, function(pvehicles)
            if pvehicles then
                for i,v in pairs(pvehicles) do 
                    if os.time() > tonumber(v.rentedtime) then
                        MySQL.execute('GMT/rentedupdate', {id = v.rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = v.user_id, veh = v.vehicle})
                        if GMT.getUserSource(v.rentedid) then
                            GMT.notify(GMT.getUserSource(v.rentedid), "~r~Your rented vehicle has been returned.")
                        end
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('GMT:FetchCars')
AddEventHandler('GMT:FetchCars', function(type)
    local source = source
    local user_id = GMT.getUserId(source)
    local returned_table = {}
    local fuellevels = {}
    local vehicleweights = {}
    local vehicledata = {total = 0,processed = 0}
    if user_id then
        MySQL.query("GMT/get_vehicles", {user_id = user_id}, function(pvehicles, affected)
            for _, veh in pairs(pvehicles) do
                for i, v in pairs(vehicle_groups) do
                    local perms = false
                    local config = vehicle_groups[i]._config
                    if config.type == vehicle_groups[type]._config.type then 
                        local perm = config.permissions or nil
                        if next(perm) then
                            for i, v in pairs(perm) do
                                if GMT.hasPermission(user_id, v) then
                                    perms = true
                                end
                            end
                        else
                            perms = true
                        end
                        if perms then 
                            for a, z in pairs(v) do
                                if a ~= "_config" and veh.vehicle == a then
                                    vehicledata.total = vehicledata.total + 1
                                    if not returned_table[i] then 
                                        returned_table[i] = {["_config"] = config}
                                    end
                                    if not returned_table[i].vehicles then 
                                        returned_table[i].vehicles = {}
                                    end
                                    returned_table[i].vehicles[a] = {z[1], z[2], veh.vehicle_plate, veh.fuel_level}
                                    fuellevels[a] = veh.fuel_level
                                end
                            end
                            for a, z in pairs(v) do
                                if a ~= "_config" and veh.vehicle == a then
                                    GMT.getSData("chest:u1veh_"..a.."|" ..user_id,function(data)
                                        if data then
                                            vehicleweights[a] = GMT.computeItemsWeight(json.decode(data) or {})
                                        end
                                        vehicledata.processed = vehicledata.processed + 1
                                        if vehicledata.processed == vehicledata.total then
                                            TriggerClientEvent('GMT:ReturnFetchedCars', source, returned_table, fuellevels, vehicleweights)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            TriggerClientEvent('GMT:ReturnFetchedCars', source, returned_table, fuellevels, vehicleweights)
        end)
    end
end)

RegisterNetEvent('GMT:CrushVehicle')
AddEventHandler('GMT:CrushVehicle', function(vehicle)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then 
        MySQL.query("GMT/check_rented", {user_id = user_id, vehicle = vehicle}, function(pvehicles)
            MySQL.query("GMT/get_vehicle", {user_id = user_id, vehicle = vehicle}, function(pveh)
                if #pveh < 0 then 
                    GMT.notify(source, "~r~You cannot destroy a vehicle you do not own")
                    return
                end
                if #pvehicles > 0 then 
                    GMT.notify(source, "~r~You cannot destroy a rented vehicle!")
                    return
                end
                GMT.sendDCLog('vehicle', "GMT Crush Vehicle Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Vehicle: **"..vehicle.."**")
                MySQL.execute('GMT/remove_vehicle', {user_id = user_id, vehicle = vehicle})
                TriggerClientEvent('GMT:CloseGarage', source)
            end)
        end)
    end
end)

RegisterNetEvent('GMT:SellVehicle')
AddEventHandler('GMT:SellVehicle', function(veh)
    local name = veh
    local player = source 
    local playerID = GMT.getUserId(source)
    if playerID then
		GMTclient.getNearestPlayers(player,{15},function(nplayers)
			usrList = ""
			for k,v in pairs(nplayers) do
				usrList = usrList .. "[" .. GMT.getUserId(k) .. "]" .. GMT.getPlayerName(GMT.getUserId(k)) .. " | "
			end
			if usrList ~= "" then
				GMT.prompt(player,"Players Nearby: " .. usrList .. "","",function(player,user_id) 
					user_id = user_id
					if user_id and user_id ~= "" then 
						local target = GMT.getUserSource(tonumber(user_id))
						if target then
							GMT.prompt(player,"Price £: ","",function(player,amount)
								if tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) < limit then
									MySQL.query("GMT/get_vehicle", {user_id = user_id, vehicle = name}, function(pvehicle, affected)
										if #pvehicle > 0 then
											GMT.notify(player, "~r~The player already has this vehicle type.")
										else
											local tmpdata = GMT.getUserTmpTable(playerID)
											MySQL.query("GMT/check_rented", {user_id = playerID, vehicle = veh}, function(pvehicles)
                                                if #pvehicles > 0 then 
                                                    GMT.notify(player, "~r~You cannot sell a rented vehicle!")
                                                    return
                                                else
                                                    GMT.request(target,GMT.getPlayerName(GMT.getUserId(player)).." wants to sell: " ..name.. " Price: £"..getMoneyStringFormatted(amount), 10, function(target,ok)
                                                        if ok then
                                                            local pID = GMT.getUserId(target)
                                                            amount = tonumber(amount)
                                                            if GMT.tryFullPayment(pID,amount) then
                                                                GMTclient.despawnGarageVehicle(player,{'car',15}) 
                                                                GMT.getUserIdentity(pID, function(identity)
                                                                    MySQL.execute("GMT/sell_vehicle_player", {user_id = user_id, registration = "P "..identity.registration, oldUser = playerID, vehicle = name}) 
                                                                end)
                                                                GMT.giveBankMoney(playerID, amount)
                                                                GMT.notify(player, "~g~You have successfully sold the vehicle to ".. GMT.getPlayerName(GMT.getUserId(target)).." for £"..getMoneyStringFormatted(amount).."!")
                                                                GMT.notify(target, "~g~"..GMT.getPlayerName(GMT.getUserId(player)).." has successfully sold you the car for £"..getMoneyStringFormatted(amount).."!")
                                                                GMT.sendDCLog('vehicle', "GMT Sell Vehicle Logs", "> Seller Name: **"..GMT.getPlayerName(GMT.getUserId(player)).."**\n> Seller TempID: **"..player.."**\n> Seller PermID: **"..playerID.."**\n> Buyer Name: **"..GMT.getPlayerName(GMT.getUserId(target)).."**\n> Buyer TempID: **"..target.."**\n> Buyer PermID: **"..user_id.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**\n> Vehicle: **"..veh.."**")
                                                                TriggerClientEvent('GMT:CloseGarage', player)
                                                            else
                                                                GMT.notify(player, "~r~".. GMT.getPlayerName(GMT.getUserId(target)).." doesn't have enough money!")
                                                                GMT.notify(target, "~r~You don't have enough money!")
                                                            end
                                                        else
                                                            GMT.notify(player, "~r~"..GMT.getPlayerName(GMT.getUserId(target)).." has refused to buy the car.")
                                                            GMT.notify(target, "~r~You have refused to buy "..GMT.getPlayerName(GMT.getUserId(player)).."'s car.")
                                                        end
                                                    end)
                                                end
                                            end)
										end
									end) 
								else
									GMT.notify(player, "~r~The price of the car has to be a number.")
								end
							end)
						else
							GMT.notify(player, "~r~That ID seems invalid.")
						end
					else
						GMT.notify(player, "~r~No player ID selected.")
					end
				end)
			else
				GMT.notify(player, "~r~No players nearby.")
			end
		end)
    end
end)


RegisterNetEvent('GMT:RentVehicle')
AddEventHandler('GMT:RentVehicle', function(veh)
    local name = veh
    local player = source 
    local playerID = GMT.getUserId(source)
    if playerID then
		GMTclient.getNearestPlayers(player,{15},function(nplayers)
			usrList = ""
			for k,v in pairs(nplayers) do
				usrList = usrList .. "[" .. GMT.getUserId(k) .. "]" .. GMT.getPlayerName(GMT.getUserId(k)) .. " | "
			end
			if usrList ~= "" then
				GMT.prompt(player,"Players Nearby: " .. usrList .. "","",function(player,user_id) 
					user_id = user_id
					if user_id and user_id ~= "" then 
						local target = GMT.getUserSource(tonumber(user_id))
						if target then
							GMT.prompt(player,"Price £: ","",function(player,amount)
                                GMT.prompt(player,"Rent time (in hours): ","",function(player,rent)
                                    if tonumber(rent) and tonumber(rent) >  0 then 
                                        if tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) < limit then
                                            MySQL.query("GMT/get_vehicle", {user_id = user_id, vehicle = name}, function(pvehicle, affected)
                                                if #pvehicle > 0 then
                                                    GMT.notify(player, "~r~The player already has this vehicle.")
                                                else
                                                    local tmpdata = GMT.getUserTmpTable(playerID)
                                                    MySQL.query("GMT/check_rented", {user_id = playerID, vehicle = veh}, function(pvehicles)
                                                        if #pvehicles > 0 then 
                                                            return
                                                        else
                                                            GMT.prompt(player, "Please replace text with YES or NO to confirm", "Rent Details:\nVehicle: "..name.."\nRent Cost: "..getMoneyStringFormatted(amount).."\nDuration: "..rent.." hours\nRenting to player: "..GMT.getPlayerName(GMT.getUserId(target)).."("..GMT.getUserId(target)..")",function(player,details)
                                                                if string.upper(details) == 'YES' then
                                                                    GMT.notify(player, '~g~Rent offer sent!')
                                                                    GMT.request(target,GMT.getPlayerName(GMT.getUserId(player)).." wants to rent: " ..name.. " Price: £"..getMoneyStringFormatted(amount) .. ' | for: ' .. rent .. 'hours', 10, function(target,ok)
                                                                        if ok then
                                                                            local pID = GMT.getUserId(target)
                                                                            amount = tonumber(amount)
                                                                            if GMT.tryFullPayment(pID,amount) then
                                                                                GMTclient.despawnGarageVehicle(player,{'car',15}) 
                                                                                GMT.getUserIdentity(pID, function(identity)
                                                                                    local rentedTime = os.time()
                                                                                    rentedTime = rentedTime  + (60 * 60 * tonumber(rent)) 
                                                                                    MySQL.execute("GMT/rentedupdate", {user_id = playerID, veh = name, id = pID, rented = 1, rentedid = playerID, rentedunix =  rentedTime }) 
                                                                                end)
                                                                                GMT.giveBankMoney(playerID, amount)
                                                                                GMT.notify(player, "~g~You have successfully rented the vehicle to "..GMT.getPlayerName(GMT.getUserId(target)).." for £"..getMoneyStringFormatted(amount)..' for ' ..rent.. 'hours')
                                                                                GMT.notify(target, "~g~"..GMT.getPlayerName(GMT.getUserId(player)).." has successfully rented you the car for £"..getMoneyStringFormatted(amount)..' for ' ..rent.. 'hours')
                                                                                GMT.sendDCLog('vehicle', "GMT Rent Vehicle Logs", "> Renter Name: **"..GMT.getPlayerName(GMT.getUserId(player)).."**\n> Renter TempID: **"..player.."**\n> Renter PermID: **"..playerID.."**\n> Rentee Name: **"..GMT.getPlayerName(GMT.getUserId(target)).."**\n> Rentee TempID: **"..target.."**\n> Rentee PermID: **"..pID.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**\n> Duration: **"..rent.." hours**\n> Vehicle: **"..veh.."**")
                                                                                --TriggerClientEvent('GMT:CloseGarage', player)
                                                                            else
                                                                                GMT.notify(player, "~r~".. GMT.getPlayerName(GMT.getUserId(target)).." doesn't have enough money!")
                                                                                GMT.notify(target, "~r~You don't have enough money!")
                                                                            end
                                                                        else
                                                                            GMT.notify(player, "~r~"..GMT.getPlayerName(GMT.getUserId(target)).." has refused to rent the car.")
                                                                            GMT.notify(target, "~r~You have refused to rent "..GMT.getPlayerName(GMT.getUserId(player)).."'s car.")
                                                                        end
                                                                    end)
                                                                else
                                                                    GMT.notify(player, '~r~Rent offer cancelled!')
                                                                end
                                                            end)
                                                        end
                                                    end)
                                                end
                                            end) 
                                        else
                                            GMT.notify(player, "~r~The price of the car has to be a number.")
                                        end
                                    else 
                                        GMT.notify(player, "~r~The rent time of the car has to be in hours and a number.")
                                    end
                                end)
							end)
						else
							GMT.notify(player, "~r~That ID seems invalid.")
						end
					else
						GMT.notify(player, "~r~No player ID selected.")
					end
				end)
			else
				GMT.notify(player, "~r~No players nearby.")
			end
		end)
    end
end)



RegisterNetEvent('GMT:FetchRented')
AddEventHandler('GMT:FetchRented', function()
    local rentedin = {}
    local rentedout = {}
    local source = source
    local user_id = GMT.getUserId(source)
    MySQL.query("GMT/get_rented_vehicles_in", {user_id = user_id}, function(pvehicles, affected)
        for _, veh in pairs(pvehicles) do
            for i, v in pairs(vehicle_groups) do
                local config = vehicle_groups[i]._config
                local perm = config.permissions or nil
                if perm then
                    for i, v in pairs(perm) do
                        if not GMT.hasPermission(user_id, v) then
                            break
                        end
                    end
                end
                for a, z in pairs(v) do
                    if a ~= "_config" and veh.vehicle == a then
                        if not rentedin.vehicles then 
                            rentedin.vehicles = {}
                        end
                        local hoursLeft = ((tonumber(veh.rentedtime)-os.time()))/3600
                        local minutesLeft = nil
                        if hoursLeft < 1 then
                            minutesLeft = hoursLeft * 60
                            minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
                            datetime = minutesLeft .. " mins" 
                        else
                            hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
                            datetime = hoursLeft .. " hours" 
                        end
                        rentedin.vehicles[a] = {z[1], datetime, veh.user_id, a}
                    end
                end
            end
        end
        MySQL.query("GMT/get_rented_vehicles_out", {user_id = user_id}, function(pvehicles, affected)
            for _, veh in pairs(pvehicles) do
                for i, v in pairs(vehicle_groups) do
                    local config = vehicle_groups[i]._config
                    local perm = config.permissions or nil
                    if perm then
                        for i, v in pairs(perm) do
                            if not GMT.hasPermission(user_id, v) then
                                break
                            end
                        end
                    end
                    for a, z in pairs(v) do
                        if a ~= "_config" and veh.vehicle == a then
                            if not rentedout.vehicles then 
                                rentedout.vehicles = {}
                            end
                            local hoursLeft = ((tonumber(veh.rentedtime)-os.time()))/3600
                            local minutesLeft = nil
                            if hoursLeft < 1 then
                                minutesLeft = hoursLeft * 60
                                minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
                                datetime = minutesLeft .. " mins" 
                            else
                                hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
                                datetime = hoursLeft .. " hours" 
                            end
                            rentedout.vehicles[a] = {z[1], datetime, veh.user_id, a}
                        end
                    end
                end
            end
            TriggerClientEvent('GMT:ReturnedRentedCars', source, rentedin, rentedout)
        end)
    end)
end)

RegisterNetEvent('GMT:CancelRent')
AddEventHandler('GMT:CancelRent', function(spawncode, VehicleName, a)
    local source = source
    local user_id = GMT.getUserId(source)
    if a == 'owner' then
        exports['gmt']:execute("SELECT * FROM gmt_user_vehicles WHERE rentedid = @id", {id = user_id}, function(result)
            if #result > 0 then 
                for i = 1, #result do 
                    if result[i].vehicle == spawncode and result[i].rented then
                        local target = GMT.getUserSource(result[i].user_id)
                        if target then
                            GMT.request(target,GMT.getPlayerName(user_id).." would like to cancel the rent on the vehicle: ", 10, function(target,ok)
                                if ok then
                                    MySQL.execute('GMT/rentedupdate', {id = user_id, rented = 0, rentedid = "", rentedunix = "", user_id = result[i].user_id, veh = spawncode})
                                    GMT.notify(target, "~r~" ..VehicleName.." has been returned to the vehicle owner.")
                                    GMT.notify(source, "~r~" ..VehicleName.." has been returned to your garage.")
                                else
                                    GMT.notify(source, "~r~User has declined the request to cancel the rental of vehicle: " ..VehicleName)
                                end
                            end)
                        else
                            GMT.notify(source, "~r~The player is not online.")
                        end
                    end
                end
            end
        end)
    elseif a == 'renter' then
        exports['gmt']:execute("SELECT * FROM gmt_user_vehicles WHERE user_id = @id", {id = user_id}, function(result)
            if #result > 0 then 
                for i = 1, #result do 
                    if result[i].vehicle == spawncode and result[i].rented then
                        local rentedid = tonumber(result[i].rentedid)
                        local target = GMT.getUserSource(rentedid)
                        if target then
                            GMT.request(target,GMT.getPlayerName(user_id).." would like to cancel the rent on the vehicle: ", 10, function(target,ok)
                                if ok then
                                    MySQL.execute('GMT/rentedupdate', {id = rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = user_id, veh = spawncode})
                                    GMT.notify(source, "~r~" ..VehicleName.." has been returned to the vehicle owner.")
                                    GMT.notify(target, "~r~" ..VehicleName.." has been returned to your garage.")
                                else
                                    GMT.notify(source, "~r~User has declined the request to cancel the rental of vehicle: " ..VehicleName)
                                end
                            end)
                        else
                            GMT.notify(source, "~r~The player is not online.")
                        end
                    end
                end
            end
        end)
    end
end)

-- repair nearest vehicle
RegisterNetEvent("GMT:attemptRepairVehicle")
AddEventHandler("GMT:attemptRepairVehicle", function(entityNetworkId)
    local source = source
    local user_id = GMT.getUserId(source)
    local ai = NetworkGetEntityFromNetworkId(entityNetworkId)
    if ai then
        if GMT.tryGetInventoryItem(user_id, "repairkit", 1, true) then
            GMTclient.playAnim(source, {false, {task = "WORLD_HUMAN_WELDING"}, false})
            GMTclient.startCircularProgressBar(source, {"", 15000, nil})
            SetTimeout(15000, function()
                GMTclient.fixeNearestVehicle(source, {7}, ai)
                GMTclient.stopAnim(source, {false})
            end)
        else
            --GMT.notify(source, "~r~Missing DIY Repair Kit 1.") 
        end
    else
        GMT.notify(source, "~r~No vehicle nearby to repair.") 
    end
    -- else
    --     GMT.ACBan(15,user_id,"GMT:attemptRepairVehicle")
    -- end
end)

RegisterNetEvent("GMT:PayVehicleTax")
AddEventHandler("GMT:PayVehicleTax", function()
    local user_id = GMT.getUserId(source)
    if user_id then
        local bank = GMT.getBankMoney(user_id)
        local payment = bank / 10000

        if payment > 0 then
            if GMT.tryBankPayment(user_id, payment) then
                GMT.notify(source, "~g~Paid £"..getMoneyStringFormatted(math.floor(payment)).." vehicle tax.")
                TriggerEvent('GMT:addToCommunityPot', math.floor(payment))
            else
                GMT.notify(source, "~r~Vehicle tax paid kindly via the government.")
            end
        else
            GMT.notify(source, "~r~Vehicle tax paid kindly via the government.")
        end
    end
end)


RegisterNetEvent("GMT:refreshGaragePermissions")
AddEventHandler("GMT:refreshGaragePermissions",function()
    local source=source
    local garageTable={}
    local user_id = GMT.getUserId(source)
    for k,v in pairs(cfg.garages) do
        for a,b in pairs(v) do
            if a == "_config" then
                if json.encode(b.permissions) ~= '[""]' then
                    local hasPermissions = 0
                    for c,d in pairs(b.permissions) do
                        if GMT.hasPermission(user_id, d) then
                            hasPermissions = hasPermissions + 1
                        end
                    end
                    if hasPermissions == #b.permissions then
                        table.insert(garageTable, k)
                    end
                else
                    table.insert(garageTable, k)
                end
            end
        end
    end
    local ownedVehicles = {}
    if user_id then
        MySQL.query("GMT/get_vehicles", {user_id = user_id}, function(pvehicles, affected)
            for k,v in pairs(pvehicles) do
                table.insert(ownedVehicles, v.vehicle)
            end
            TriggerClientEvent('GMT:updateOwnedVehicles', source, ownedVehicles)
        end)
    end
    TriggerClientEvent("GMT:receivedRefreshedGaragePermissions",source,garageTable)
end)


RegisterNetEvent("GMT:getGarageFolders")
AddEventHandler("GMT:getGarageFolders",function()
    local source = source
    local user_id = GMT.getUserId(source)
    local garageFolders = {}
    local addedFolders = {}
    MySQL.query("GMT/get_vehicles", {user_id = user_id}, function(result)
        if result then 
            for k,v in pairs(result) do
                local spawncode = v.vehicle 
                for a,b in pairs(vehicle_groups) do
                    if not string.find(a,"Aircraft") and not string.find(a,"Helicopters") and not string.find(a,"Boats") then
                        local hasPerm = true
                        if next(b._config.permissions) then
                            if not GMT.hasPermission(user_id, b._config.permissions[1]) then
                                hasPerm = false
                            end
                        end
                        if hasPerm then
                            for c,d in pairs(b) do
                                if c == spawncode and not v.impounded then
                                    if not addedFolders[a] then
                                        table.insert(garageFolders, {display = a})
                                        addedFolders[a] = true
                                    end
                                    for e,f in pairs (garageFolders) do
                                        if f.display == a then
                                            if f.vehicles == nil then
                                                f.vehicles = {}
                                            end
                                            table.insert(f.vehicles, {display = d[1], spawncode = spawncode})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            TriggerClientEvent('GMT:setVehicleFolders', source, garageFolders)
        end
    end)
end)

local cfg_weapons = module("cfg/weapons")

RegisterServerEvent("GMT:searchVehicle")
AddEventHandler('GMT:searchVehicle', function(entity, permid)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, 'ukbf.armoury') then
        if GMT.getUserSource(permid) then
            GMTclient.getNetworkedVehicleInfos(GMT.getUserSource(permid), {entity}, function(owner, spawncode)
                if spawncode and owner == permid then
                    local vehformat = 'chest:u1veh_'..spawncode..'|'..permid
                    GMT.getSData(vehformat, function(cdata)
                        if cdata then
                            cdata = json.decode(cdata)
                            if next(cdata) then
                                for a,b in pairs(cdata) do
                                    if string.find(a, 'wbody|') then
                                        c = a:gsub('wbody|', '')
                                        cdata[c] = b
                                        cdata[a] = nil
                                    end
                                end
                                for k,v in pairs(cfg_weapons.weapons) do
                                    if cdata[k] then
                                        if not v.policeWeapon then
                                            GMT.notify(source, '~r~Seized '..v.name..' x'..cdata[k].amount..'.')
                                            cdata[k] = nil
                                        end
                                    end
                                end
                                for c,d in pairs(cdata) do
                                    if seizeBullets[c] then
                                        GMT.notify(source, '~r~Seized '..c..' x'..d.amount..'.')
                                        cdata[c] = nil
                                    end
                                    if seizeDrugs[c] then
                                        GMT.notify(source, '~r~Seized '..c..' x'..d.amount..'.')
                                        cdata[c] = nil
                                    end
                                end
                                GMT.setSData(vehformat, json.encode(cdata))
                                GMT.sendDCLog('seize-boot', 'GMT Seize Boot Logs', "> Officer Name: **"..GMT.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Vehicle: **"..spawncode.."**\n> Owner ID: **"..permid.."**")
                            else
                                GMT.notify(source, '~r~This vehicle is empty.')
                            end
                        else
                            GMT.notify(source, '~r~This vehicle is empty.')
                        end
                    end)
                end
            end)
        end
    end
end)


Citizen.CreateThread(function()
    Wait(1500)
    exports['gmt']:execute([[
        CREATE TABLE IF NOT EXISTS `gmt_custom_garages` (
            `user_id` INT(11) NOT NULL AUTO_INCREMENT,
            `folder` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
            PRIMARY KEY (`user_id`) USING BTREE
        );
    ]])
end)

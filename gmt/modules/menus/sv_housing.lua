h = {}
local cfg = module("cfg/cfg_housing")
local housedata = {
    homedata = {
        -- [housename] = {users = {user_id = {}}}
    },
    robberydata = {
        -- [housename] = {open = false,boltcuttingtime = startedanim,lastrobbed = openedtime,
        -- startedanim = When the player started the animation
        -- openedtime = When the house gets cracked open
        -- open = If the house is opened or not
    }
}

for k, v in pairs(cfg.homes) do
    housedata.homedata[k] = {users = {}}
    housedata.robberydata[k] = {open = false,houseowner = nil,boltcuttingtime = 0,lastrobbed = 0}
end

MySQL = module("modules/database/MySQL")

MySQL.createCommand("GMT/get_address","SELECT home, number FROM gmt_user_homes WHERE user_id = @user_id")
MySQL.createCommand("GMT/get_home_owner","SELECT user_id FROM gmt_user_homes WHERE home = @home AND number = @number")
MySQL.createCommand("GMT/rm_address","DELETE FROM gmt_user_homes WHERE user_id = @user_id AND home = @home")
MySQL.createCommand("GMT/set_address","REPLACE INTO gmt_user_homes(user_id,home,number) VALUES(@user_id,@home,@number)")
MySQL.createCommand("GMT/fetch_rented_houses", "SELECT * FROM gmt_user_homes WHERE rented = 1")
MySQL.createCommand("GMT/rentedupdatehouse", "UPDATE gmt_user_homes SET user_id = @id, rented = @rented, rentedid = @rentedid, rentedtime = @rentedunix WHERE user_id = @user_id AND home = @home")

Citizen.CreateThread(function()
    while true do
        Wait(300000)
        MySQL.query('GMT/fetch_rented_houses', {}, function(rentedhouses)
            for i,v in pairs(rentedhouses) do 
               if os.time() > tonumber(v.rentedtime) then
                  MySQL.execute('GMT/rentedupdatehouse', {id = v.rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = v.user_id, home = v.home})
               end
            end
        end)
    end
end)

function getUserAddress(user_id, cbr)
    local task = Task(cbr)
  
    MySQL.query("GMT/get_address", {user_id = user_id}, function(rows, affected)
        task({rows[1]})
    end)
end
  
function setUserAddress(user_id, home, number)
    MySQL.execute("GMT/set_address", {user_id = user_id, home = home, number = number})
end
  
function removeUserAddress(user_id, home)
    MySQL.execute("GMT/rm_address", {user_id = user_id, home = home})
end

function getOwnedHouses(user_id, cb)
    local ownedHouses = {}

    for k, v in pairs(cfg.homes) do
        getUserByAddress(k, 1, function(owner)
            if owner == user_id then
                table.insert(ownedHouses, k)
            end
        end)
    end

    cb(ownedHouses)
end

function getUserByAddress(home, number, cbr)
    local task = Task(cbr)
  
    MySQL.query("GMT/get_home_owner", {home = home, number = number}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].user_id})
        else
            task()
        end
    end)
end

exports('getOwnedHouses', getOwnedHouses)

function leaveHome(user_id, home, number, cbr)
    local task = Task(cbr)
    local player = GMT.getUserSource(user_id)
    GMT.setBucket(player, 0)
    for k, v in pairs(cfg.homes) do
        if k == home then
            local x,y,z = table.unpack(v.entry_point)
            GMTclient.teleport(player, {x,y,z})
            GMTclient.setInHome(player, {false})
            housedata.homedata[home].users[user_id] = nil
            task({true})
        end
    end
end

function accessHome(user_id, home, number, cbr)
    local task = Task(cbr)
    local player = GMT.getUserSource(user_id)
    local count = 0
    for k, v in pairs(cfg.homes) do
        count = count+1
        if k == home then
            GMT.setBucket(player, count)
            local x,y,z = table.unpack(v.leave_point)
            GMTclient.teleport(player, {x,y,z})
            GMTclient.setInHome(player, {true})
            housedata.homedata[home].users[user_id] = true
            task({true})
        end
    end
end

function GMT.RecentlyRobbed(home)
    if housedata.robberydata[home].open then
        return true, housedata.robberydata[home].houseowner
    end
    return false, housedata.robberydata[home].houseowner
end

RegisterNetEvent("GMT:buyHome")
AddEventHandler("GMT:buyHome", function(house)
    local source = source
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)

    for k, v in pairs(cfg.homes) do
        if house == k then
            getUserByAddress(house,1,function(noowner) --check if house already has a owner
                if noowner == nil then
                    getUserAddress(user_id, function(address) -- check if user already has a home
                        if GMT.tryFullPayment(user_id,v.buy_price) then --try payment
                            local price = v.buy_price
                            setUserAddress(user_id,house,1) --set address
                            GMT.notify(player, "~g~You bought "..k.."!") --notify
                            for a,b in pairs(GMT.getUsers({})) do
                                local x,y,z = table.unpack(v.entry_point)
                                GMTclient.removeBlipAtCoords(b,{x,y,z})
                                if user_id == a then
                                    GMTclient.addBlip(b,{x,y,z,374,1,house})
                                    TriggerClientEvent('GMT:ownedStatus', source, k, true)
                                end
                            end
                            GMT.sendDCLog('housing-buy', 'GMT Housing Logs', "**User Name:** "..GMT.getPlayerName(user_id).."\n**User ID:** "..user_id.."\n**Price: **".. price.. "\n **House Name: **" ..k)
                        else
                            GMT.notify(player, "~r~You do not have enough money to buy "..k) --not enough money
                        end
                    end)
                else
                    GMT.notify(player, "~r~Someone already owns "..k)
                end
                if noowner then
                    TriggerClientEvent('GMT:addHome', source)
                    clientOwnsHome = true
                end
            end)
        end
    end
end)

RegisterNetEvent("GMT:enterHome")
AddEventHandler("GMT:enterHome", function(house)
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)
    local name = GMT.getPlayerName(user_id)

    getUserByAddress(house, 1, function(huser_id) --check if player owns home
        local hplayer = GMT.getUserSource(huser_id) --temp id of home owner

        if huser_id then
            if huser_id == user_id then
                accessHome(user_id, house, 1, function(ok) --enter home
                    if not ok then
                        GMT.notify(player, "Unable to enter home") --notify unable to enter home for whatever reason
                    end
                end)
            else
                if hplayer then --check if home owner is online
                    GMT.notify(player, "~r~You do not own this home, Knocked on door!")
                    GMT.request(hplayer,name.." knocked on your door!", 30, function(v,ok) --knock on door
                        if ok then
                            GMT.notify(player, "~g~Doorbell Accepted") --doorbell accepted
                            accessHome(user_id, house, 1, function(ok) --enter home
                                if not ok then
                                    GMT.notify(player, "~r~Unable to enter home!") --notify unable to enter home for whatever reason
                                end
                            end)
                        end
                        if not ok then
                            GMT.notify(player, "~r~Doorbell Refused ") -- doorbell refused
                        end
                    end)
                else
                    GMT.notify(player, "~r~Home owner not online!") -- home owner not online
                end
            end
        else
            GMT.notify(player, "~r~Nobody owns "..house.."") --no home owner & user_id already doesn't have a house
        end
    end)
end)

RegisterNetEvent("GMT:Leave")
AddEventHandler("GMT:Leave", function(house)
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)

    leaveHome(user_id, house, 1, function(ok) --leave home
        if not ok then
            GMT.notify(player, "~r~Unable to leave home!") --notify if some error
        end
    end)
end)

RegisterNetEvent("GMT:Sell")
AddEventHandler("GMT:Sell", function(house)
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)

    getUserByAddress(house, 1, function(huser_id)
        if huser_id == user_id then
            GMTclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
                usrList = ""
                for k, v in pairs(nplayers) do
                    usrList = usrList .. "[" .. GMT.getUserId(k) .. "]" .. GMT.getPlayerName(GMT.getUserId(k)) .. " | " --add ids to usrList
                end
                if usrList ~= "" then
                    GMT.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, target_id) --ask for id
                        target_id = target_id
                        if target_id and target_id ~= "" then --validation
                            local target = GMT.getUserSource(tonumber(target_id)) --get source of the new owner id
                            if target then
                                GMT.prompt(player,"Price £: ","",function(player, amount) --ask for price
                                    if tonumber(amount) and tonumber(amount) > 0 then
                                        GMT.request(target,GMT.getPlayerName(GMT.getUserId(player)).." wants to sell: " ..house.. " Price: £"..amount, 30, function(target,ok) --request new owner if they want to buy
                                            if ok then --bought
                                                local buyer_id = GMT.getUserId(target) --get perm id of new owner
                                                amount = tonumber(amount) --convert amount str to int
                                                if GMT.tryFullPayment(buyer_id,amount) then
                                                    setUserAddress(buyer_id, house, 1) --give house
                                                    removeUserAddress(user_id, house) -- remove house
                                                    GMT.giveBankMoney(user_id, amount) --give money to original owner
                                                    TriggerClientEvent('GMT:ownedStatus', source, house, false)
                                                    GMT.notify(player, "~g~You have successfully sold "..house.." to ".. GMT.getPlayerName(buyer_id).." for £"..amount.."!") --notify original owner
                                                    GMT.notify(target, "~g~"..GMT.getPlayerName(GMT.getUserId(player)).." has successfully sold you "..house.." for £"..amount.."!") --notify new owner
                                                    GMT.sendDCLog('housing-sell', 'GMT Housing Logs', "**User Name:** "..GMT.getPlayerName(user_id).."\n**User ID:** "..GMT.getUserId(source).."\n**Buyer Name: **"..GMT.getPlayerName(buyer_id).. "\n**Buyer ID: **" ..GMT.getUserId(source).. "\n**Price: **".. amount.. "\n**House Name: **" ..house)
                                               
                                                else
                                                    GMT.notify(player, "".. GMT.getPlayerName(buyer_id).." doesn't have enough money!") --notify original owner
                                                    GMT.notify(target, "~r~You don't have enough money!") --notify new owner
                                                end
                                            else
                                                GMT.notify(player, ""..GMT.getPlayerName(buyer_id).." has refused to buy "..house.."!") --notify owner that refused
                                                GMT.notify(target, "~r~You have refused to buy "..house.."!") --notify new owner that refused
                                            end
                                        end)
                                    else
                                        GMT.notify(player, "~r~Price of home needs to be a number!") -- if price of home is a string not a int
                                    end
                                end)
                            else
                                GMT.notify(player, "~r~That Perm ID seems to be invalid!") --couldnt find perm id
                            end
                        else
                            GMT.notify(player, "~r~No Perm ID selected!") --no perm id selected
                        end
                    end)
                else
                    GMT.notify(player, "~r~No players nearby!") --no players nearby
                end
            end)
        else
            GMT.notify(player, "~r~You do not own "..house.."!")
        end
    end)
end)

RegisterNetEvent('GMT:Rent')
AddEventHandler('GMT:Rent', function(house)
    local user_id = GMT.getUserId(source)
    local player = GMT.getUserSource(user_id)

    getUserByAddress(house, 1, function(huser_id)
        if huser_id == user_id then
            GMTclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
                usrList = ""
                for k, v in pairs(nplayers) do
                    usrList = usrList .. "[" .. GMT.getUserId(k) .. "]" .. GMT.getPlayerName(GMT.getUserId(k)) .. " | " --add ids to usrList
                end
                if usrList ~= "" then
                    GMT.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, target_id) --ask for id
                        target_id = target_id
                        if target_id and target_id ~= "" then --validation
                            local target = GMT.getUserSource(tonumber(target_id)) --get source of the new owner id
                            if target then
                                GMT.prompt(player,"Price £: ","",function(player, amount) --ask for price
                                    if tonumber(amount) and tonumber(amount) > 0 then
                                        GMT.prompt(player,"Duration: ","",function(player, duration) --ask for price
                                            if tonumber(duration) and tonumber(duration) > 0 then
                                                GMT.prompt(player, "Please replace text with YES or NO to confirm", "Rent Details:\nHouse: "..house.."\nRent Cost: "..amount.."\nDuration: "..duration.." hours\nRenting to player: "..GMT.getPlayerName(buyer_id).."("..target_id..")",function(player,details)
                                                    if string.upper(details) == 'YES' then
                                                        GMT.notify(player, '~g~Rent offer sent!')
                                                        GMT.request(target,GMT.getPlayerName(GMT.getUserId(player)).." wants to rent: " ..house.. " for "..duration.." hours, for £"..amount, 30, function(target,ok) --request new owner if they want to buy
                                                            if ok then 
                                                                local buyer_id = GMT.getUserId(target) --get perm id of new owner
                                                                amount = tonumber(amount) --convert amount str to int
                                                                if GMT.tryFullPayment(buyer_id,amount) then
                                                                    local rentedTime = os.time()
                                                                    rentedTime = rentedTime  + (60 * 60 * tonumber(duration)) 
                                                                    MySQL.execute("GMT/rentedupdatehouse", {user_id = user_id, home = house, id = target_id, rented = 1, rentedid = user_id, rentedunix =  rentedTime }) 
                                                                    GMT.giveBankMoney(user_id, amount)
                                                                    TriggerClientEvent('GMT:ownedStatus', source, house, false)
                                                                    GMT.notify(player, "~g~You have successfully rented "..house.." to ".. GMT.getPlayerName(buyer_id).." for £"..amount.."!") --notify original owner
                                                                    GMT.notify(target, "~g~"..GMT.getPlayerName(GMT.getUserId(player)).." has successfully rented you "..house.." for £"..amount.."!") --notify new owner
                                                                    GMT.sendDCLog('housing-rent', 'GMT Housing Logs', "**User Name:** "..GMT.getPlayerName(user_id).."\n**User ID:** "..user_id.."\n**Buyer Name: **"..GMT.getPlayerName(buyer_id).. "\n**Buyer ID: **" ..buyer_id.. "\n**Price: **".. amount.. "\n**House Name: **" ..house)
                                                                else
                                                                    GMT.notify(player, "".. GMT.getPlayerName(buyer_id).." doesn't have enough money!") --notify original owner
                                                                    GMT.notify(target, "~r~You don't have enough money!") --notify new owner
                                                                end
                                                            else
                                                                GMT.notify(player, ""..GMT.getPlayerName(buyer_id).." has refused to rent "..house.."!") --notify owner that refused
                                                                GMT.notify(target, "~r~You have refused to rent "..house.."!") --notify new owner that refused
                                                            end
                                                        end)
                                                    end
                                                end)
                                            end
                                        end)
                                    else
                                        GMT.notify(player, "~r~Price of home needs to be a number!") -- if price of home is a string not a int
                                    end
                                end)
                            else
                                GMT.notify(player, "~r~That Perm ID seems to be invalid!") --couldnt find perm id
                            end
                        else
                            GMT.notify(player, "~r~No Perm ID selected!") --no perm id selected
                        end
                    end)
                else
                    GMT.notify(player, "~r~No players nearby!") --no players nearby
                end
            end)
        else
            GMT.notify(player, "~r~You do not own "..house.."!")
        end
    end)
end)

RegisterServerEvent("GMT:raidHome")
AddEventHandler("GMT:raidHome", function(house)
    local source = source
    local user_id = GMT.getUserId(source)
    if GetPlayerRoutingBucket(source) == 0 then
        getUserByAddress(house, 1, function(owner_id)
            if GMT.getUserSource(owner_id) then
                if user_id ~= owner_id then
                    GMTclient.startCircularProgressBar(source, {"", 15000, nil})
                    TriggerClientEvent("GMT:houseGettingRobbed",GMT.getUserSource(owner_id),house, true)
                    SetTimeout(15000, function() 
                        accessHome(user_id, house, 1, function(ok) --enter home
                            if not ok then
                                GMT.notify(source, "Unable to enter home") --notify unable to enter home for whatever reason
                            else
                                GMT.notify(source, "~g~You have successfully raided "..house..", You have 10 minutes")
                                GMT.notify(GMT.getUserSource(owner_id), "~g~Your house "..house.." is being raided by the MET Police!")
                                SetTimeout(120000, function()
                                    for k, v in pairs(housedata.homedata[house].users) do
                                        local player = GMT.getUserSource(k)
                                        if player then
                                            leaveHome(k, house, 1, function(ok) --leave home
                                                if not ok then
                                                    GMT.notify(player, "~r~Unable to leave home!") --notify if some error
                                                else
                                                    GMT.notify(player, "~r~House raid is over!")
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end
                        end)
                    end)
                else
                    GMT.notify(source, "~r~You cannot raid your own house!")
                end
            else
                GMT.notify(source, "~r~House owner is not online!")
            end
        end)
    else
        GMT.notify(source, "~r~You are in the incorrect universe to do this!")
    end
end)

RegisterServerEvent("GMT:HouseRobbery",function(house)
    local source = source
    local user_id = GMT.getUserId(source)
    if GetPlayerRoutingBucket(source) == 0 then
        if not housedata.robberydata[house].open then
            getUserByAddress(house,1,function(owner_id)
                if GMT.getUserSource(owner_id) then
                    if user_id ~= owner_id then
                        if GMT.tryGetInventoryItem(user_id,"boltcutters",1,false) then
                            housedata.robberydata[house].boltcuttingtime = os.time()
                            TriggerClientEvent("GMT:forceBoltCutting",source)
                            TriggerClientEvent("GMT:houseGettingRobbed",GMT.getUserSource(owner_id),house)
                            while os.time() - housedata.robberydata[house].boltcuttingtime < 60 do
                                Wait(1000)
                                if #(GetEntityCoords(GetPlayerPed(source)) - cfg.homes[house].entry_point) < 3.0 then
                                    GMTclient.isPlayingAnim(source,{"WORLD_HUMAN_WELDING"},function(anim)
                                        if not anim then
                                            GMT.notify(source, "~r~Failed to break into house!")
                                            return
                                        end
                                    end)
                                else
                                    GMT.notify(source, "~r~You moved too far away from the door!")
                                    return
                                end
                            end
                            GMTclient.stopAnim(source)
                            housedata.robberydata[house].open = true
                            housedata.robberydata[house].houseowner = owner_id
                            accessHome(user_id, house, 1, function(ok) --enter home
                                if not ok then
                                    GMT.notify(source, "Unable to enter home") --notify unable to enter home for whatever reason
                                else
                                    GMT.notify(source, "~g~You have successfully broken into "..house..", You have 10 minutes")
                                    GMT.notify(GMT.getUserSource(owner_id), "~g~Your house "..house..", has been broken into!")
                                    GMT.sendDCLog('housing-rob', 'GMT Housing Logs', "**User Name:** "..GMT.getPlayerName(user_id).."\n**User ID:** "..user_id.."\n**Type: **Robbery\n **House Name: **" ..house)
                                end
                                SetTimeout(120000,function()
                                    housedata.robberydata[house].open = false
                                    housedata.robberydata[house].houseowner = nil
                                    for k, v in pairs(housedata.homedata[house].users) do
                                        local player = GMT.getUserSource(k)
                                        if player then
                                            leaveHome(k, house, 1, function(ok) --leave home
                                                if not ok then
                                                    GMT.notify(player, "~r~Unable to leave home!") --notify if some error
                                                else
                                                    GMT.notify(player, "~r~House robberey ended!")
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end)
                        else
                            GMT.notify(source, "~r~You do not have boltcutters!")
                        end
                    else
                        GMT.notify(source, "~r~You cannot rob your own house!")
                    end
                else
                    GMT.notify(source, "~r~House owner is not online!")
                end
            end)
        else
            accessHome(user_id, house, 1, function(ok) --enter home
                if not ok then
                    GMT.notify(player, "Unable to enter home") --notify unable to enter home for whatever reason
                end
            end)
        end
    else
        GMT.notify(source, "~r~You are in the incorrect universe to do this!")
    end
end)

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    for k, v in pairs(cfg.homes) do
        local x, y, z = table.unpack(v.entry_point)
        getUserByAddress(k, 1, function(owner)
            local owned = owner == user_id
            if owner == nil then
                GMTclient.addBlip(source, {x, y, z, 374, 2, k, 0.8, true}) -- remove the 0.8 and true to display on full map instead of minimap
            end
            if owned then
                GMTclient.addBlip(source, {x, y, z, 374, 1, k})
                TriggerClientEvent('GMT:ownedStatus', source, k, owned)
            end
        end)
    end
end)
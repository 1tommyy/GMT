RegisterCommand('addgroup', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) and args[2] then
        local userid = tonumber(args[1])
        local group = args[2]
        GMT.addUserGroup(userid,group)
        print('Added Group: ' .. group .. ' to UserID: ' .. userid)
    else 
        print('Incorrect usage: addgroup [permid] [group]')
    end
end)

RegisterCommand('removegroup', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) and args[2] then
        local userid = tonumber(args[1])
        local group = args[2]
        GMT.removeUserGroup(userid,group)
        print('Removed Group: ' .. group .. ' from UserID: ' .. userid)
    else 
        print('Incorrect usage: addgroup [permid] [group]')
    end
end) 

RegisterCommand("viewgroups", function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) then
        local userid = tonumber(args[1])
        local groups = GMT.getUserGroups(userid)
        print('Groups for UserID: ' .. userid.. ' are: ' ..json.encode(groups))
    else 
        print('Incorrect usage: viewgroups [permid]')
    end
end)

RegisterCommand('ban', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) and args[2] then
        local userid = tonumber(args[1])
        local hours = args[2]
        local reason = table.concat(args," ", 3)
        if reason then 
            GMT.banConsole(userid,hours,reason)
        else 
            print('Incorrect usage: ban [permid] [hours] [reason]')
        end 
    else 
        print('Incorrect usage: ban [permid] [hours] [reason]')
    end
end)

RegisterCommand('unban', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1])  then
        local userid = tonumber(args[1])
        GMT.setBanned(userid,false)
        print('Unbanned user: ' .. userid )
    else 
        print('Incorrect usage: unban [permid]')
    end
end)
RegisterCommand('cashtoall', function(source, args)
    if source ~= 0 then return end;
    if tonumber(args[1])  then
        local amount = tonumber(args[1])
        print('Given £' .. amount .. ' to all users online')
        for k,v in pairs(GMT.getUsers()) do
            GMT.notify(v, '~g~You have received £' .. getMoneyStringFormatted(amount) .. ' from the server.')
            GMT.giveBankMoney(k, amount)

        end
    else 
        print('Incorrect usage: cashtoall [amount]')
    end
end)



local weapon = 'WEAPON_MANORMOSIN'
RegisterCommand("Founders", function(source, args, rawCommand)
    local user_id = GMT.getUserId(source)
    if GMT.hasGroup(user_id, 'Founder') then
        GMTclient.giveBankMoney(source, 5000000)
        GMTclient.giveWeapons(source, {{[weapon] = {ammo = 250}}, false, globalpasskey})
        GMTclient.setArmour(source, {200, true})
        GMT.notify(source, "~g~ Manor Mosin + Full Armour received")
    else
        GMT.notify(source, "~r~You don't have permission to do that!")
    end
end)

RegisterCommand("dev", function(source, args, rawCommand)
    local user_id = GMT.getUserId(source)
    if GMT.hasGroup(user_id, 'Lead Developer') then
        GMTclient.giveBankMoney(source, 5000000)
        GMTclient.giveWeapons(source, {{[weapon] = {ammo = 250}}, false, globalpasskey})
        GMTclient.setArmour(source, {200, true})
        GMT.notify(source, "~g~ Manor Mosin + Full Armour received")
    else
        GMT.notify(source, "~r~You don't have permission to do that!")
    end
end)

local WeaponCFG = module("cfg/weapons")
RegisterCommand("mosinall", function(source, args, rawCommand)
    local user_id = GMT.getUserId(source)
    if GMT.hasGroup(user_id, 'TutorialDone') then
        GMTclient.giveWeapons(source, {{[weapon] = {ammo = 250}}, false, globalpasskey})
        GMT.giveWeapons(source, {{['WEAPON_MOSINCMG'], ['WEAPON_MANORMOSIN'], ['WEAPON_GREENMANORMOSIN'], ['WEAPON_BLACKICEMOSIN'], ['WEAPON_BLOODMOSIN'], ['WEAPON_NIGHTMOSIN'], ['WEAPON_PINKMANORMOSINMOSIN'] = {ammo = 250}}, false,globalpasskey})
        GMTclient.setArmour(source, {200, true})
        GMT.notify(source, "~g~ All Mosins + Full Armour received")
    else
        GMT.notify(source, "~r~You don't have permission to do that!")
    end
end)
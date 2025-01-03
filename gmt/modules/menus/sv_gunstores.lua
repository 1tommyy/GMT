local cfg = {}
cfg.GunStores={
    ["policeLargeArms"]={
        ["_config"]={{vector3(1840.6104736328,3691.4741210938,33.350730895996),vector3(461.43179321289,-982.66412353516,29.689668655396),vector3(-440.69451904297,5987.109375,30.716192245483),vector3(-1102.5059814453,-820.62091064453,13.282785415649)},110,5,"MET Police Large Arms",{"police.armoury","police.loadshop2"},false,true}, 
        ["WEAPON_FLASHBANG"]={"Flashbang",0,0,"N/A","w_me_flashbang"},
        ["WEAPON_SMOKEGRENADEGMTPD"]={"Smoke Grenade",0,0,"N/A","w_ex_smokegrenade"},
        -- ["WEAPON_G36K"]={"G36K",0,0,"N/A","w_ar_g36k"}, 
        ["WEAPON_M4A1GMT"]={"M4 Carbine",0,0,"N/A","w_ar_m4a1"}, 
        ["WEAPON_MP5GMT"]={"MP5",0,0,"N/A","w_sb_mp5"},
        ["WEAPON_REMINGTON700"]={"Remington 700",0,0,"N/A","w_sr_remington700"}, 
        ["WEAPON_SIGMCX"]={"SigMCX",0,0,"N/A","w_ar_sigmcx"},
        ["WEAPON_SPAR17"]={"SPAR17",0,0,"N/A","w_ar_spar17"},
        ["WEAPON_STING"]={"Sting 9mm",0,0,"N/A","w_sb_sting"},
    },
    ["policeSmallArms"]={
        ["_config"]={{vector3(461.53082275391,-979.35876464844,29.689668655396),vector3(1842.9096679688,3690.7692871094,33.267082214355),vector3(-442.54290771484,5988.7456054688,30.716192245483),vector3(-1104.5264892578,-821.70153808594,13.282785415649)},110,5,"MET Police Small Arms",{"police.armoury"},false,true},
        ["WEAPON_FLASHLIGHT"]={"Flashlight",0,0,"N/A","w_me_flashlight"},
        ["WEAPON_PDGLOCK20VA5"]={"Glock",0,0,"N/A","w_pi_glock"},
        ["WEAPON_NIGHTSTICK"]={"Police Baton",0,0,"N/A","w_me_nightstick"},
        ["WEAPON_REMINGTON870"]={"Remington 870",0,0,"N/A","w_sg_remington870"},
        ["WEAPON_STAFFGUN"]={"Speed Gun",0,0,"N/A","w_pi_staffgun"},
    },
    ["nhsSmallArms"]={
        ["_config"]={{vector3(304.52716064453,-600.37548828125,42.284084320068)},110,5,"NHS Combat Medic Small Arms",{"nhs.combatmedic"},false,true},
        ["WEAPON_PDGLOCK20VA5"]={"Glock",0,0,"N/A","w_pi_glock"},
    },
    ["prisonArmoury"]={
        ["_config"]={{vector3(1779.3741455078,2542.5639648438,45.797782897949)},110,5,"Prison Armoury",{"hmp.menu"},false,true},
        ["WEAPON_FLASHLIGHT"]={"Flashlight",0,0,"N/A","w_me_flashlight"},
        ["WEAPON_PDGLOCK20VA5"]={"Glock",0,0,"N/A","w_pi_glock"},
        ["WEAPON_NIGHTSTICK"]={"Police Baton",0,0,"N/A","w_me_nightstick"},
        ["WEAPON_REMINGTON870"]={"Remington 870",0,0,"N/A","w_sg_remington870"},
    },
    ["ukbfArmoury"]={
        ["_config"]={{vector3(1779.3741455078, 2542.5639648438, 52.557)},110,5,"UK Border Force Armoury",{"ukbf.armoury"},false,true},
        ["WEAPON_FLASHLIGHT"]={"Flashlight",0,0,"N/A","w_me_flashlight"},
        ["WEAPON_PDGLOCK20VA5"]={"Glock",0,0,"N/A","w_pi_glock"},
        ["WEAPON_NIGHTSTICK"]={"Police Baton",0,0,"N/A","w_me_nightstick"},
        ["WEAPON_REMINGTON870"]={"Remington 870",0,0,"N/A","w_sg_remington870"},
    },
    ["NHS"]={
        ["_config"]={{vector3(340.41757202148,-582.71209716797,27.973259765625),vector3(-435.27032470703,-318.29010009766,34.08971484375)},110,5,"NHS Armoury",{"nhs.menu"},false,true},
        ["WEAPON_FLASHLIGHT"]={"Flashlight",0,0,"N/A","w_me_flashlight"},
    },
    ["LFB"]={
        ["_config"]={{vector3(1210.193359375,-1484.1494140625,34.241326171875),vector3(216.63296508789,-1648.6680908203,29.0179375)},110,5,"LFB Armoury",{"lfb.onduty.permission"},false,true},
        ["WEAPON_FLASHLIGHT"]={"Flashlight",0,0,"N/A","w_me_flashlight"},
        ["WEAPON_FIREAXE"]={"Fireaxe",0,0,"N/A","w_me_fireaxe"},
    },
    ["VIP"]={
        ["_config"]={{vector3(-2152.08,5191.95,15.72)},110,5,"VIP Gun Store",{"vip.gunstore"},false},
        -- -2151.5891113281,5190.8930664062,15.718825340271 right place for VIP
        -- -2150.3408203125,5189.42578125,15.718823432922 wrong vip
        ["WEAPON_AK74KASHNAR"]={"Golden AK-47",750000,0,"N/A","w_ar_goldak"},
        ["WEAPON_FIREEXTINGUISHER"]={"Fire Extinguisher",10000,0,"N/A","prop_fire_exting_1b"},
        ["WEAPON_MJOLNIR"]={"Mjlonir",10000,0,"N/A","w_me_mjolnir"},
        ["WEAPON_MOLOTOV"]={"Molotov Cocktail",5000,0,"N/A","w_ex_molotov"},
        ["WEAPON_MOSIN"]={"Mosin Bolt-Action",1000000,0,"N/A","w_ar_mosin",nil,1000000},
        ["WEAPON_SMOKEGRENADEGMT"]={"Smoke Grenade",25000,0,"N/A","w_ex_smokegrenade"},
        -- ["WEAPON_SNOWBALL"]={"Snowball",10000,0,"N/A","w_ex_snowball"},
    },
    ["Rebel"]={
        ["_config"]={{vector3(1545.2521972656, 6331.5615234375, 23.07857131958),vector3(4925.6259765625,-5243.0908203125,1.524599313736)},110,5,"Rebel Gun Store",{"rebellicense.whitelisted"},true},
        ["GADGET_PARACHUTE"]={"Parachute",1000,0,"N/A","p_parachute_s"},
        ["WEAPON_AKKAL"]={"AK-200",750000,0,"N/A","w_ar_akkal"},
        ["WEAPON_SVD"]={"Dragunov SVD",2000000,0,"N/A","w_sr_svd"},
        ["WEAPON_REVOLVER357"]={"Rebel Revolver",200000,0,"N/A","w_pi_revolver"},
        ["WEAPON_SPAZ"]={"Spaz 12",400000,0,"N/A","w_sg_spaz"},
        ["WEAPON_WINCHESTER12"]={"Winchester 12",350000,0,"N/A","w_sg_winchester12"},
        ["item"]={"LVL 1 Armour",25000,0,"N/A","prop_armour_pickup"},
        ["item2"]={"LVL 2 Armour",50000,0,"N/A","prop_bodyarmour_02"},
        ["item3"]={"LVL 3 Armour",75000,0,"N/A","prop_bodyarmour_03"},
        ["item4"]={"LVL 4 Armour",100000,0,"N/A","prop_bodyarmour_04"},
        ["item|fillUpArmour"]={"Replenish Armour",100000,0,"N/A","prop_armour_pickup"},
        
    },
    ["LargeArmsDealer"]={
        ["_config"]={{vector3(-1111.4790039062,4937.29296875,218.38996887207),vector3(5065.6201171875, -4591.3857421875, 1.8652405738831)},110,1,"Large Arms Dealer",{"gang.whitelisted"},false},
        ["WEAPON_AK74KASHNAR"]={"Golden AK-47",750000,0,"N/A","w_ar_goldak",nil,750000},
        ["WEAPON_MOSIN"]={"Mosin Bolt-Action",1500000,0,"N/A","w_ar_mosin",nil,950000},
        ["WEAPON_UMP45"]={"UMP45 SMG",350000,0,"N/A","w_sb_ump45",nil,350000},
        ["WEAPON_UZI"]={"Uzi SMG",250000,0,"N/A","w_sb_uzi",nil,250000},
        -- ["armourplate"]={"Armour Plate",100000,0,"N/A","prop_armour_pickup"},
        ["item"]={"LVL 1 Armour",25000,0,"N/A","prop_armour_pickup"},
        ["item2"]={"LVL 2 Armour",50000,0,"N/A","prop_bodyarmour_02"},
    },
    ["SmallArmsDealer"]={
        ["_config"]={{vector3(2437.5708007813,4966.5610351563,41.34761428833),vector3(-1500.4978027344,-216.72758483887,46.889373779297),vector3(1242.7232666016,-426.84201049805,67.913963317871),vector3(1242.791,-426.7525,67.93467)},110,1,"Small Arms Dealer",{""},true},
        ["WEAPON_BERETTA"]={"Berreta M9 Pistol",60000,0,"N/A","w_pi_beretta"},
        ["WEAPON_M1911"]={"M1911 Pistol",60000,0,"N/A","w_pi_m1911"},
        ["WEAPON_MPX"]={"MPX",300000,0,"N/A","w_ar_mpx"},
        ["WEAPON_PYTHON"]={"Python .357 Revolver",50000,0,"N/A","w_pi_python"},
        ["WEAPON_ROOK"]={"Rook 9mm",60000,0,"N/A","w_pi_rook"},
        ["WEAPON_TEC9"]={"Tec-9",50000,0,"N/A","w_sb_tec9"},
        ["WEAPON_UMP45"]={"UMP-45",350000,0,"N/A","w_sb_ump45"},
        -- ["armourplate"]={"Armour Plate",100000,0,"N/A","prop_armour_pickup"},
        ["item"]={"LVL 1 Armour",25000,0,"N/A","prop_armour_pickup"},
    },
    ["Legion"]={
        ["_config"]={{vector3(22.76,-1105.53,29.80)},154,1,"Legion Gun Store",{""},true},
        ["WEAPON_MANORMOSIN"]={"Manor Mosin",1500000,0,"N/A","w_me_manormosin"},
    },
}
local organheist = module('cfg/cfg_organheist')

MySQL.createCommand("GMT/get_weapons", "SELECT weapon_info FROM gmt_weapon_whitelists WHERE user_id = @user_id")
MySQL.createCommand("GMT/set_weapons", "UPDATE gmt_weapon_whitelists SET weapon_info = @weapon_info WHERE user_id = @user_id")
MySQL.createCommand("GMT/add_user", "INSERT IGNORE INTO gmt_weapon_whitelists SET user_id = @user_id")
MySQL.createCommand("GMT/get_all_weapons", "SELECT * FROM gmt_weapon_whitelists")
MySQL.createCommand("GMT/create_weapon_code", "INSERT IGNORE INTO gmt_weapon_codes SET user_id = @user_id, spawncode = @spawncode, weapon_code = @weapon_code")
MySQL.createCommand("GMT/remove_weapon_code", "DELETE FROM gmt_weapon_codes WHERE weapon_code = @weapon_code")
MySQL.createCommand("GMT/get_weapon_codes", "SELECT * FROM gmt_weapon_codes")


AddEventHandler("playerJoining", function()
    local user_id = GMT.getUserId(source)
    MySQL.execute("GMT/add_user", {user_id = user_id})
end)


whitelistedGuns = {
    ["policeLargeArms"]={
        ["WEAPON_MK18V2"]={"MK18 V2",0,0,"N/A","w_ar_mk18v2"},
    },
    -- ["policeSmallArms"]={},
    --["prisonArmoury"]={},
    -- ["NHS"]={},
    -- ["LFB"]={},
    ["VIP"]={
        ["WEAPON_WESTYARES"]={"Westy Ares",1000000,0,"N/A","w_mg_westyares"},
        ["WEAPON_ANIMEM16"]={"UWU AR",500000,0,"N/A","w_ar_animem16"},
        ["WEAPON_SCORPIONBLUE"]={"SCORPION BLUE",500000,0,"N/A","w_sb_scorpionblue"},
        ["WEAPON_CBHONEYBADGER"]={"CB Honey Badger",1,0,"N/A","w_sb_cbhoneybadger"},
        ["WEAPON_YELLOWM4A1S"]={"Yellow Demon M4A1-S",900000,0,"N/A","w_ar_yellowm4a1s"},
        ["WEAPON_M4A1SPURPLE"]={"M4A1-S Purple",900000,0,"N/A","w_ar_m4a1spurple"},
        ["WEAPON_BARRET50NRP"]={"Barret 50 Cal",1000000,0,"N/A", "w_sr_barret50cal"},
        ["WEAPON_MP5K"]={"MP5K",0,0,"N/A","w_sb_mp5k"},
        ["WEAPON_M4A1WHITENOISE"] = {"M4A1 White Noise",825000,0, "N/A", "w_ar_m4a1whitenoise"},
    },
    -- ["Rebel"]={},
    ["LargeArmsDealer"] = {
         ["WEAPON_MP5K"]={"MP5K",750000,0,"N/A","w_sb_mp5k",6,750000},
         ["WEAPON_BLACKICEMOSIN"]={"Black Ice Mosin",1750000,0,"N/A","w_sr_blackicemosin",6,1750000},
         ["WEAPON_M4A1WHITENOISE"] = {"M4A1 White Noise",825000,0, "N/A", "w_ar_m4a1whitenoise"},
         
    },
    ["SmallArmsDealer"] = {
    },
    ["Legion"] = {
        ["WEAPON_PIGEON"]={"Pigeon",7000,0,"N/A","w_me_pigeon"},
    },
}

local VIPWithPlat = {
    ["item"]={"LVL 1 Armour",25000,0,"N/A","prop_armour_pickup"},
    ["item2"]={"LVL 2 Armour",50000,0,"N/A","prop_bodyarmour_02"},
    ["item3"]={"LVL 3 Armour",75000,0,"N/A","prop_bodyarmour_03"},
    ["item4"]={"LVL 4 Armour",100000,0,"N/A","prop_bodyarmour_04"},
    ["item|fillUpArmour"]={"Replenish Armour",100000,0,"N/A","prop_armour_pickup"},
}

local RebelWithAdvanced = {
    -- mk1emr
    ["WEAPON_MXM"]={"MXM",950000,0,"N/A","w_ar_mxm"},
    ["WEAPON_SPAR16"]={"Spar 16",900000,0,"N/A","w_ar_spar16"},
    ["WEAPON_MK14"]={"MK14",1850000,0,"N/A","w_sr_mk14"},
    ["armourplate"]={"Armour Plate",100000,0,"N/A","prop_armour_pickup"},
}


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

RegisterNetEvent("GMT:getCustomWeaponsOwned")
AddEventHandler("GMT:getCustomWeaponsOwned",function()
    local source = source
    local user_id = GMT.getUserId(source)
    local ownedWhitelists = {}
    MySQL.query("GMT/get_weapons", {user_id = user_id}, function(weaponWhitelists)
        for k,v in pairs(weaponWhitelists) do
            if v['weapon_info'] then
                data = json.decode(v['weapon_info'])
                for c,d in pairs(whitelistedGuns) do
                    for e,f in pairs(d) do
                        if data.gunhash and e == string.upper(data.gunhash) then
                            ownedWhitelists[e] = f[1]
                        end
                    end
                end
            end
            TriggerClientEvent('GMT:gotCustomWeaponsOwned', source, ownedWhitelists)
        end
    end)
end)

RegisterNetEvent("GMT:requestWhitelistedUsers")
AddEventHandler("GMT:requestWhitelistedUsers",function(spawncode)
    local source = source
    local user_id = GMT.getUserId(source)
    local whitelistOwners = {}
    MySQL.query("GMT/get_all_weapons", {}, function(weaponWhitelists)
        for k,v in pairs(weaponWhitelists) do
            if v['weapon_info'] then
                data = json.decode(v['weapon_info'])
                for a,b in pairs(data) do
                    if b[spawncode] then
                        whitelistOwners[v['user_id']] = (exports['gmt']:executeSync("SELECT username FROM gmt_users WHERE id = @user_id", {user_id = v['user_id']})[1]).username
                    end
                end
            end
        end
        TriggerClientEvent('GMT:getWhitelistedUsers', source, whitelistOwners)
    end)
end)

RegisterNetEvent("GMT:generateWeaponAccessCode")
AddEventHandler("GMT:generateWeaponAccessCode", function(spawncode, id)
    local source = source
    local user_id = GMT.getUserId(source)
    local code = math.random(100000, 999999)
    print("[GMT] - Weapon Code: " .. id .. " Spawn Code: " .. spawncode .. " Code: " .. code)
    MySQL.execute("GMT/create_weapon_code", {user_id = id, spawncode = spawncode, weapon_code = code})
    TriggerClientEvent('GMT:generatedAccessCode', source, code)
end)

RegisterCommand("genwl", function(source, args)
    if source == 0 then
        if args and args[1] and args[2] then
            local code = math.random(100000, 999999)
            print("[GMT] - Weapon Code: " .. args[1] .. " Spawn Code: " .. args[2] .. " Code: " .. code)
            MySQL.execute("GMT/create_weapon_code", {user_id = args[1], spawncode = args[2], weapon_code = code})
        else
            print("[GMT] - Invalid Arguments, /genwl [user_id] [spawncode]")
        end
    end
end)
function GMT.RefreshGunstoreData(user_id)
    MySQL.query("GMT/get_weapons", {user_id = user_id}, function(weaponWhitelists)
        local gunstoreData = deepcopy(cfg.GunStores)
        if weaponWhitelists and #weaponWhitelists > 0 then
            for k,v in pairs(weaponWhitelists) do
                if v['weapon_info'] then
                    data = json.decode(v['weapon_info'])
                    for c,d in pairs(whitelistedGuns) do
                        for e,f in pairs(d) do
                            if data.gunhash and e == string.upper(data.gunhash) then
                                gunstoreData[c][e] = f
                            end
                        end
                    end
                end
            end
        end 
        GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
            if cb then
                if plathours > 0 and GMT.hasPermission(user_id, "vip.gunstore") then
                    for k,v in pairs(VIPWithPlat) do
                        gunstoreData["VIP"][k] = v
                    end
                end
            end
            if GMT.hasPermission(user_id, 'advancedrebel.license') then
                for k,v in pairs(RebelWithAdvanced) do
                    gunstoreData["Rebel"][k] = v
                end
            end
            TriggerClientEvent('GMT:recieveFilteredGunStoreData', GMT.getUserSource(user_id), gunstoreData)
        end)
    end)
end


RegisterNetEvent("GMT:requestNewGunshopData")
AddEventHandler("GMT:requestNewGunshopData",function()
    local source = source
    GMT.RefreshGunstoreData(GMT.getUserId(source))
end)

function gunStoreLogs(weaponshop, webhook, title, text)
    if weaponshop == 'policeLargeArms' or weaponshop == 'policeSmallArms' then
        GMT.sendDCLog('pd-armoury', 'GMT Police Armoury Logs', text)
    elseif weaponshop == 'NHS' then
        GMT.sendDCLog('nhs-armoury', 'GMT NHS Armoury Logs', text)
    elseif weaponshop == 'prisonArmoury' then
        GMT.sendDCLog('hmp-armoury', 'GMT HMP Armoury Logs', text)
    elseif weaponshop == 'ukbfArmoury' then
        GMT.sendDCLog('ukbf-armoury', 'GMT UKBF Armoury Logs', text)
    elseif weaponshop == 'LFB' then
        GMT.sendDCLog('lfb-armoury', 'GMT LFB Armoury Logs', text)
    end
    GMT.sendDCLog(webhook,title,text)
end

RegisterNetEvent("GMT:buyWeapon")
AddEventHandler("GMT:buyWeapon",function(spawncode, price, name, weaponshop, purchasetype, vipstore)
    local source = source
    local user_id = GMT.getUserId(source)
    local hasPerm = false
    local gunstoreData = deepcopy(cfg.GunStores)
    local payFunc = "tryPayment"
    if vipstore or weaponshop == 'VIP' then
        payFunc = "tryFullPayment"
    end
    MySQL.query("GMT/get_weapons", {user_id = user_id}, function(weaponWhitelists)
        local gunstoreData = deepcopy(cfg.GunStores)
        if weaponWhitelists and #weaponWhitelists > 0 then
            for k,v in pairs(weaponWhitelists) do
                if v['weapon_info'] then
                    data = json.decode(v['weapon_info'])
                    for c,d in pairs(whitelistedGuns) do
                        for e,f in pairs(d) do
                            if data.gunhash and e == string.upper(data.gunhash) then
                                gunstoreData[c][e] = f
                            end
                        end
                    end
                end
            end
        end 
        for k,v in pairs(gunstoreData[weaponshop]) do
            if k == '_config' then
                local withinRadius = false
                for a,b in pairs(v[1]) do
                    if #(GetEntityCoords(GetPlayerPed(source)) - b) < 10 then
                        withinRadius = true
                    end
                end
                if vipstore then
                    if #(GetEntityCoords(GetPlayerPed(source)) - gunstoreData["VIP"]['_config'][1][1] ) < 10 then
                        withinRadius = true
                    end
                end
                for c,d in pairs(organheist.locations) do
                    for e,f in pairs(d.gunStores) do
                        for g,h in pairs(f) do
                            if #(GetEntityCoords(GetPlayerPed(source)) - h[3]) < 10 then
                                withinRadius = true
                            end
                        end
                    end
                end
                if not withinRadius then return end
                if json.encode(v[5]) ~= '[""]' then
                    local hasPermissions = 0
                    for a,b in pairs(v[5]) do
                        if GMT.hasPermission(user_id, b) then
                            hasPermissions = hasPermissions + 1
                        end
                    end
                    if hasPermissions == #v[5] then
                        hasPerm = true
                    end
                else
                    hasPerm = true
                end
                GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
                    if cb then
                        if plathours > 0 and GMT.hasPermission(user_id, "vip.gunstore") then
                            for k,v in pairs(VIPWithPlat) do
                                gunstoreData["VIP"][k] = v
                            end
                        end
                    end
                    if GMT.hasPermission(user_id, 'advancedrebel.license') then
                        for k,v in pairs(RebelWithAdvanced) do
                            gunstoreData["Rebel"][k] = v
                        end
                    end
                    for c,d in pairs(gunstoreData[weaponshop]) do
                        if c ~= '_config' then
                            if hasPerm then
                                if c == spawncode then
                                    if name == d[1] then
                                        if purchasetype == 'armour' then
                                            if string.find(spawncode, "fillUp") then
                                                price = (100 - GetPedArmour(GetPlayerPed(source))) * 1000
                                                if GMT[payFunc](user_id,price) then
                                                    GMT.notify(source, "~g~Purchased " .. name .. " for ~g~£" .. getMoneyStringFormatted(price) .. ".")
                                                    TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                                                    GMTclient.setArmour(source, {100, true})
                                                    gunStoreLogs(weaponshop, 'weapon-logs',"GMT Weapon Shop Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Purchased: **"..name.."**\n> Price: **£"..getMoneyStringFormatted(price).."**\n> Weapon Shop: **"..weaponshop.."**\n> Purchase Type: **"..purchasetype.."**")
                                                    return
                                                end
                                            elseif GetPedArmour(GetPlayerPed(source)) >= (price/1000) then
                                                GMT.notify(source, 'You already have '..GetPedArmour(GetPlayerPed(source))..'% armour.')
                                                return
                                            end
                                            if GMT[payFunc](user_id,d[2]) then
                                                GMT.notify(source, "~g~Purchased " .. name .. " for ~g~£" .. getMoneyStringFormatted(price) .. ".")
                                                TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                                                GMTclient.setArmour(source, {price/1000, true})
                                                gunStoreLogs(weaponshop, 'weapon-logs',"GMT Weapon Shop Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Purchased: **"..name.."**\n> Price: **£"..getMoneyStringFormatted(price).."**\n> Weapon Shop: **"..weaponshop.."**\n> Purchase Type: **"..purchasetype.."**")
                                                if weaponshop == 'LargeArmsDealer' then
                                                    GMT.turfSaleToGangFunds(price, 'LargeArms')
                                                end
                                            else
                                                GMT.notify(source, 'You do not have enough money for this purchase.')
                                                TriggerClientEvent("gmt:PlaySound", source, 2)
                                            end
                                        elseif purchasetype == 'weapon' then
                                            if spawncode ~= "armourplate" then
                                                GMTclient.hasWeapon(source, {spawncode}, function(hasWeapon)
                                                    if hasWeapon then
                                                        GMT.notify(source, 'You must store your current '..name..' before purchasing another.')
                                                    else
                                                        if GMT[payFunc](user_id,d[2]) then
                                                            if price > 0 then
                                                                GMT.notify(source, "~g~Purchased " .. name .. " for ~g~£" .. getMoneyStringFormatted(price) .. ".")
                                                                if weaponshop == 'LargeArmsDealer' then
                                                                    GMT.turfSaleToGangFunds(price, 'LargeArms')
                                                                end
                                                            else
                                                                GMT.notify(source, '~g~'..name..' purchased.')
                                                            end
                                                            TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                                                            GMTclient.giveWeapons(source, {{[spawncode] = {ammo = 250}}, false, globalpasskey})
                                                            gunStoreLogs(weaponshop, 'weapon-logs',"GMT Weapon Shop Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Purchased: **"..name.."**\n> Price: **£"..getMoneyStringFormatted(price).."**\n> Weapon Shop: **"..weaponshop.."**\n> Purchase Type: **"..purchasetype.."**")
                                                        else
                                                            GMT.notify(source, 'You do not have enough money for this purchase.')
                                                            TriggerClientEvent("gmt:PlaySound", source, 2)
                                                        end
                                                    end
                                                end)
                                            else
                                                if GMT.getInventoryWeight(user_id) + 5 <= GMT.getInventoryMaxWeight(user_id) then
                                                    if GMT[payFunc](user_id,d[2]) then
                                                        GMT.notify(source, "~g~Purchased " .. name .. " for ~g~£" .. getMoneyStringFormatted(price) .. ".")
                                                        GMT.giveInventoryItem(user_id, 'armourplate', 1)
                                                        TriggerClientEvent("GMT:PlaySound", source, "playMoney")
                                                        gunStoreLogs(weaponshop, 'weapon-logs',"GMT Weapon Shop Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Purchased: **"..name.."**\n> Price: **£"..getMoneyStringFormatted(price).."**\n> Weapon Shop: **"..weaponshop.."**\n> Purchase Type: **"..purchasetype.."**")
                                                    else
                                                        GMT.notify(source, 'You do not have enough money for this purchase.')
                                                        TriggerClientEvent("GMT:PlaySound", source, 2)
                                                    end
                                                else
                                                    GMT.notify(source, 'You do not have enough space in your inventory for this purchase.')
                                                    TriggerClientEvent("GMT:PlaySound", source, 2)
                                                end
                                            end
                                        elseif purchasetype == 'ammo' then
                                            price = price/2
                                            if GMT[payFunc](user_id,price) then
                                                if price > 0 then
                                                    GMT.notify(source, "~g~Purchased " .. name .. " for ~g~£" .. getMoneyStringFormatted(price) .. ".")
                                                    if weaponshop == 'LargeArmsDealer' then
                                                        GMT.turfSaleToGangFunds(price, 'LargeArms')
                                                    end
                                                else
                                                    GMT.notify(source, "~g~Purchased 250x Ammo.")
                                                end
                                                TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                                                GMTclient.giveWeapons(source, {{[spawncode] = {ammo = 250}}, false,globalpasskey})
                                                gunStoreLogs(weaponshop, 'weapon-logs',"GMT Weapon Shop Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Purchased: **"..name.."**\n> Price: **£"..getMoneyStringFormatted(price).."**\n> Weapon Shop: **"..weaponshop.."**\n> Purchase Type: **"..purchasetype.."**")
                                            else
                                                GMT.notify(source, 'You do not have enough money for this purchase.')
                                                TriggerClientEvent("gmt:PlaySound", source, 2)
                                            end
                                        end
                                    end
                                end
                            else
                                if weaponshop == 'policeLargeArms' or weaponshop == 'policeSmallArms' or weaponshop == 'nhsSmallArms' then
                                    GMT.notify(source, "~r~You shouldn't be in here, ALARM TRIGGERED!!!")
                                else
                                    GMT.notify(source, "~r~You do not have permission to access this store.")
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end)
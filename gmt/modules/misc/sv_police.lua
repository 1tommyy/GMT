
-- this module define some police tools and functions
local lang = GMT.lang
local a = module("cfg/weapons")

local isStoring = {}
choice_store_weapons = function(player, choice, death)
    local user_id = GMT.getUserId(player)
    local data = GMT.getUserDataTable(user_id)
    GMTclient.getWeapons(player,{},function(weapons)
      if not isStoring[player] then
        GMT.getSubscriptions(user_id, function(cb, plushours, plathours)
          if cb then
            local maxWeight = 30
            if plathours > 0 then
              maxWeight = 50
            elseif plushours > 0 then
              maxWeight = 40
            end
            if GMT.getInventoryWeight(user_id) <= maxWeight or death then
              isStoring[player] = true
              local weaponWeights = 0
              for k,v in pairs(weapons) do
                if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k~= 'WEAPON_SMOKEGRENADE' and k~= 'WEAPON_FLASHBANG' then
                  weaponWeights = weaponWeights + GMT.getItemWeight(k)
                end
              end
              if GMT.getInventoryWeight(user_id)+weaponWeights > maxWeight then
                GMT.notify(player, "~r~You do not have enough Weight to store Weapons.")
                  isStoring[player] = nil 
                return
              end
              GMTclient.giveWeapons(player,{{},true,globalpasskey}, function(removedwep)
                for k,v in pairs(weapons) do
                  if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k~= 'WEAPON_SMOKEGRENADE' and k~= 'WEAPON_FLASHBANG' then
                    GMT.giveInventoryItem(user_id, "wbody|"..k, 1, not death)
                    if v.ammo > 0 and k ~= 'WEAPON_STUNGUN' then
                      for i,c in pairs(a.weapons) do
                        if i == k and c.class ~= 'Melee' then
                          if v.ammo > 250 then
                            v.ammo = 250
                          end
                          GMT.giveInventoryItem(user_id, c.ammo, v.ammo, not death)
                        end   
                      end
                    end
                  end
                end
                GMT.notify(player, "~g~Weapons Stored")
                TriggerEvent('GMT:RefreshInventory', player)
                GMTclient.ClearWeapons(player,{})
                data.weapons = {}
                if choice then
                  choice(true)
                end
              end)
            else
              GMT.notify(player, '~r~You do not have enough Weight to store Weapons.')
            end
          end
          if choice then
            choice(false)
          end
          isStoring[player] = nil 
        end)
      end 
    end)
end

RegisterServerEvent("GMT:forceStoreSingleWeapon")
AddEventHandler("GMT:forceStoreSingleWeapon",function(model)
    local source = source
    local user_id = GMT.getUserId(source)
    if model then
      GMTclient.getWeapons(source,{},function(weapons)
        for k,v in pairs(weapons) do
          if k == model then
            local new_weight = GMT.getInventoryWeight(user_id)+GMT.getItemWeight(model)
            if new_weight <= GMT.getInventoryMaxWeight(user_id) then
              SetPedAmmo(GetPlayerPed(source), k, 0)
              RemoveWeaponFromPed(GetPlayerPed(source), k)
              GMTclient.removeWeapon(source,{k})
              GMT.giveInventoryItem(user_id, "wbody|"..k, 1, true)
              if v.ammo > 0 then
                for i,c in pairs(a.weapons) do
                  if i == model and c.class ~= 'Melee' then
                    GMT.giveInventoryItem(user_id, c.ammo, v.ammo, true)
                    TriggerEvent('GMT:RefreshInventory', source)
                  end   
                end
              end
            end
          end
        end
      end)
    end
end)

local swcd = {}

RegisterCommand('storeallweapons', function(source)
  local source = source
  local user_id = GMT.getUserId(source)
  if swcd[user_id] and (os.time() - swcd[user_id]) < 3 then
    GMT.notify(source, "~r~Store weapon cooldown. Please wait!")
    return
  end
  swcd[user_id] = os.time()
  choice_store_weapons(source,nil,false)
end)

RegisterServerEvent("GMT:ForceStoreAllWeapons", function(death)
    choice_store_weapons(source,nil,death)
end)

RegisterCommand('shield', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasPermission(user_id, 'police.armoury') then
    TriggerClientEvent('GMT:toggleShieldMenu', source)
  end
end)

RegisterCommand('cuff', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  GMTclient.isHandcuffed(source,{},function(handcuffed)
    if handcuffed then
      return
    else
      GMTclient.isStaffedOn(source, {}, function(staffedOn) 
        if (staffedOn and GMT.hasPermission(user_id, 'admin.tickets')) or GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, 'ukbf.armoury') or GMT.hasPermission(user_id, 'hmp.menu') then
          GMTclient.getNearestPlayer(source,{5},function(nplayer)
            if nplayer then
              local nplayer_id = GMT.getUserId(nplayer)
              if (not GMT.hasPermission(nplayer_id, 'police.armoury') or GMT.hasPermission(user_id, 'hmp.menu') or GMT.hasPermission(nplayer_id, 'police.undercover') or GMT.hasPermission(user_id, 'ukbf.armoury')) then
                GMTclient.isHandcuffed(nplayer,{},function(handcuffed)
                  if handcuffed then
                    TriggerClientEvent('GMT:uncuffAnim', source, nplayer, false)
                    TriggerClientEvent('GMT:unHandcuff', source, false)
                  else
                    TriggerClientEvent('GMT:arrestCriminal', nplayer, source)
                    TriggerClientEvent('GMT:arrestFromPolice', source)
                  end
                  TriggerClientEvent('GMT:toggleHandcuffs', nplayer, false)
                  TriggerClientEvent('GMT:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
                end)
              end
            else
              GMT.notify(source, lang.common.no_player_near())
            end
          end)
        end
      end)
    end
  end)
end)

RegisterCommand('frontcuff', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  GMTclient.isHandcuffed(source,{},function(handcuffed)
    if handcuffed then
      return
    else
      GMTclient.isStaffedOn(source, {}, function(staffedOn) 
        if (staffedOn and GMT.hasPermission(user_id, 'admin.tickets')) or GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, 'ukbf.armoury') then
          GMTclient.getNearestPlayer(source,{5},function(nplayer)
            if nplayer then
              local nplayer_id = GMT.getUserId(nplayer)
              if (not GMT.hasPermission(nplayer_id, 'police.armoury') or GMT.hasPermission(nplayer_id, 'police.undercover') or GMT.hasPermission(user_id, 'ukbf.armoury')) then
                GMTclient.isHandcuffed(nplayer,{},function(handcuffed)
                  if handcuffed then
                    TriggerClientEvent('GMT:uncuffAnim', source, nplayer, true)
                    TriggerClientEvent('GMT:unHandcuff', source, true)
                  else
                    TriggerClientEvent('GMT:arrestCriminal', nplayer, source)
                    TriggerClientEvent('GMT:arrestFromPolice', source)
                  end
                  TriggerClientEvent('GMT:toggleHandcuffs', nplayer, true)
                  TriggerClientEvent('GMT:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
                end)
              end
            else
              GMT.notify(source, lang.common.no_player_near())
            end
          end)
        end
      end)
    end
  end)
end)

function GMT.handcuffKeys(source)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.getInventoryItemAmount(user_id, 'handcuffkeys') >= 1 then
    GMTclient.getNearestPlayer(source,{5},function(nplayer)
      if nplayer then
        local nplayer_id = GMT.getUserId(nplayer)
        GMTclient.isHandcuffed(nplayer,{},function(handcuffed)
          if handcuffed then
            GMT.tryGetInventoryItem(user_id, 'handcuffkeys', 1)
            TriggerClientEvent('GMT:uncuffAnim', source, nplayer, false)
            TriggerClientEvent('GMT:unHandcuff', source, false)
            TriggerClientEvent('GMT:toggleHandcuffs', nplayer, false)
            TriggerClientEvent('GMT:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
          end
        end)
      else
        GMT.notify(source, lang.common.no_player_near())
      end
    end)
  end
end

local section60s = {}
RegisterCommand('s60', function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.announce') then
        if args[1] and args[2] then
            local radius = tonumber(args[1])
            local duration = tonumber(args[2])*60
            local section60UUID = #section60s+1
            section60s[section60UUID] = {radius = radius, duration = duration, uuid = section60UUID}
            TriggerClientEvent("GMT:addS60", -1, GetEntityCoords(GetPlayerPed(source)), radius, section60UUID)
        else
            GMT.notify(source, '~r~Invalid Arguments.')
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(section60s) do
            if section60s[k].duration > 0 then
                section60s[k].duration = section60s[k].duration-1 
            else
                TriggerClientEvent('GMT:removeS60', -1, section60s[k].uuid)
            end
        end
        Citizen.Wait(1000)
    end
end)

RegisterCommand('handbook', function(source, args)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') then
      TriggerClientEvent('GMT:toggleHandbook', source)
    end
end)

local draggingPlayers = {}

RegisterServerEvent('GMT:dragPlayer')
AddEventHandler('GMT:dragPlayer', function(playersrc)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id and (GMT.hasPermission(user_id, "police.armoury") or GMT.hasPermission(user_id, "hmp.menu") or GMT.hasPermission(user_id, "ukbf.armoury")) then
      if playersrc then
        local nuser_id = GMT.getUserId(playersrc)
          if nuser_id then
            GMTclient.isHandcuffed(playersrc,{},function(handcuffed)
                if handcuffed then
                    if draggingPlayers[user_id] then
                      TriggerClientEvent("GMT:undrag", playersrc, source)
                      draggingPlayers[user_id] = nil
                    else
                      TriggerClientEvent("GMT:drag", playersrc, source)
                      draggingPlayers[user_id] = playersrc
                    end
                else
                    GMT.notify(source, "~r~Player is not handcuffed.")
                end
            end)
          else
              GMT.notify(source, "~r~There is no player nearby")
          end
      else
          GMT.notify(source, "~r~There is no player nearby")
      end
    end
end)

RegisterServerEvent('GMT:putInVehicle')
AddEventHandler('GMT:putInVehicle', function(playersrc)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id and GMT.hasPermission(user_id, "police.armoury") or GMT.hasPermission(user_id, "ukbf.armoury") then
      if playersrc then
        GMTclient.isHandcuffed(playersrc,{}, function(handcuffed)  -- check handcuffed
          if handcuffed then
            GMTclient.putInNearestVehicleAsPassenger(playersrc, {10})
          else
            GMT.notify(source, lang.police.not_handcuffed())
          end
        end)
      end
    end
end)

RegisterServerEvent('GMT:ejectFromVehicle')
AddEventHandler('GMT:ejectFromVehicle', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id and GMT.hasPermission(user_id, "police.armoury") or GMT.hasPermission(user_id, "police.armoury") or GMT.hasPermission(user_id, 'ukbf.armoury') then
      GMTclient.getNearestPlayer(source,{10},function(nplayer)
        local nuser_id = GMT.getUserId(nplayer)
        if nuser_id then
          GMTclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
            if handcuffed then
              GMTclient.ejectVehicle(nplayer, {})
            else
              GMT.notify(source, lang.police.not_handcuffed())
            end
          end)
        else
          GMT.notify(source, lang.common.no_player_near())
        end
      end)
    end
end)


RegisterServerEvent("GMT:Knockout")
AddEventHandler('GMT:Knockout', function()
    local source = source
    local user_id = GMT.getUserId(source)
    GMTclient.getNearestPlayer(source, {2}, function(nplayer)
        local nuser_id = GMT.getUserId(nplayer)
        if nuser_id then
            TriggerClientEvent('GMT:knockOut', nplayer)
            SetTimeout(30000, function()
                TriggerClientEvent('GMT:knockOutDisable', nplayer)
            end)
        end
    end)
end)

RegisterServerEvent("GMT:KnockoutNoAnim")
AddEventHandler('GMT:KnockoutNoAnim', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasGroup(user_id, 'Founder') then
      GMTclient.getNearestPlayer(source, {2}, function(nplayer)
          local nuser_id = GMT.getUserId(nplayer)
          if nuser_id then
              TriggerClientEvent('GMT:knockOut', nplayer)
              SetTimeout(30000, function()
                  TriggerClientEvent('GMT:knockOutDisable', nplayer)
              end)
          end
      end)
    end
end)

RegisterServerEvent("GMT:requestPlaceBagOnHead")
AddEventHandler('GMT:requestPlaceBagOnHead', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.getInventoryItemAmount(user_id, 'Headbag') >= 1 then
      GMTclient.getNearestPlayer(source, {10}, function(nplayer)
          local nuser_id = GMT.getUserId(nplayer)
          if nuser_id then
              GMT.tryGetInventoryItem(user_id, 'Headbag', 1, true)
              TriggerClientEvent('GMT:placeHeadBag', nplayer)
          end
      end)
    end
end)

RegisterServerEvent('GMT:gunshotTest')
AddEventHandler('GMT:gunshotTest', function(playersrc)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id and GMT.hasPermission(user_id, "police.armoury") or GMT.hasPermission(user_id, "ukbf.armoury") then
      if playersrc then
        GMTclient.hasRecentlyShotGun(playersrc,{}, function(shotagun)
          if shotagun then
            GMT.notify(source, "~r~Player has recently shot a gun.")
          else
            GMT.notify(source, "~r~Player has no gunshot residue on fingers.")
          end
        end)
      end
    end
end)

RegisterServerEvent('GMT:tryTackle')
AddEventHandler('GMT:tryTackle', function(id)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, "ukbf.armoury") or GMT.hasPermission(user_id, 'hmp.menu') or GMT.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent('GMT:playTackle', source)
        TriggerClientEvent('GMT:getTackled', id, source)
    end
end)

RegisterCommand('drone', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasGroup(user_id, 'Drone') then
      TriggerClientEvent('toggleDrone', source)
  end
end)

RegisterCommand('trafficmenu', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, 'hmp.menu') or GMT.hasPermission(user_id, 'nhs.menu') then
      TriggerClientEvent('GMT:toggleTrafficMenu', source)
  end
end)

RegisterCommand('lfb', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasPermission(user_id, 'lfb.menu') then
      TriggerClientEvent('GMT:toggleLFBMenu', source)
  end
end)

RegisterCommand('lfbfire', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasPermission(user_id, 'lfb.menu') then
      TriggerClientEvent('GMT:startFireMenu', source)
  end
end)


RegisterServerEvent('GMT:startThrowSmokeGrenade')
AddEventHandler('GMT:startThrowSmokeGrenade', function(name)
    local source = source
    TriggerClientEvent('GMT:displaySmokeGrenade', -1, name, GetEntityCoords(GetPlayerPed(source)))
end)

RegisterCommand('breathalyse', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasPermission(user_id, 'police.armoury') then
      TriggerClientEvent('GMT:breathalyserCommand', source)
  end
end)

RegisterServerEvent('GMT:breathalyserRequest')
AddEventHandler('GMT:breathalyserRequest', function(temp)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') then
      TriggerClientEvent('GMT:beingBreathalysed', temp)
      TriggerClientEvent('GMT:breathTestResult', source, math.random(0, 100), GMT.getPlayerName(GMT.getUserId(temp)))
    end
end)

seizeBullets = {
  ['9mm Bullets'] = true,
  ['7.62mm Bullets'] = true,
  ['.357 Bullets'] = true,
  ['12 Gauge Bullets'] = true,
  ['.308 Sniper Rounds'] = true,
  ['5.56mm NATO'] = true,
}

RegisterServerEvent('GMT:seizeWeapons')
AddEventHandler('GMT:seizeWeapons', function(playerSrc)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, "ukbf.armoury") then
      GMTclient.isHandcuffed(playerSrc,{},function(handcuffed)
        if handcuffed then
          RemoveAllPedWeapons(GetPlayerPed(playerSrc), true)
          local player_id = GMT.getUserId(playerSrc)
          local cdata = GMT.getUserDataTable(player_id)
          for a,b in pairs(cdata.inventory) do
              if string.find(a, 'wbody|') then
                  c = a:gsub('wbody|', '')
                  cdata.inventory[c] = b
                  cdata.inventory[a] = nil
              end
          end
          for k,v in pairs(a.weapons) do
              if cdata.inventory[k] then
                  if not v.policeWeapon then
                    cdata.inventory[k] = nil
                  end
              end
          end
          for c,d in pairs(cdata.inventory) do
              if seizeBullets[c] then
                cdata.inventory[c] = nil
              end
          end
          TriggerEvent('GMT:RefreshInventory', playerSrc)
          GMT.notify(source, 'Seized weapons.')
          GMT.notify(playerSrc, 'Your weapons have been seized.')
        end
      end)
    end
end)

seizeDrugs = {
  ['Weed leaf'] = true,
  ['Weed'] = true,
  ['Coca leaf'] = true,
  ['Cocaine'] = true,
  ['Opium Poppy'] = true,
  ['Heroin'] = true,
  ['Ephedra'] = true,
  ['Meth'] = true,
  ['Frogs legs'] = true,
  ['Lysergic Acid Amide'] = true,
  ['LSD'] = true,
}
RegisterServerEvent('GMT:seizeIllegals')
AddEventHandler('GMT:seizeIllegals', function(playerSrc)
    local source = source
    local user_id = GMT.getUserId(source)
    if GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, "ukbf.armoury") then
      local player_id = GMT.getUserId(playerSrc)
      local cdata = GMT.getUserDataTable(player_id)
      for a,b in pairs(cdata.inventory) do
          for c,d in pairs(seizeDrugs) do
              if a == c then
                cdata.inventory[a] = nil
              end
          end
      end
      TriggerEvent('GMT:RefreshInventory', playerSrc)
      GMT.notify(source, '~r~Seized illegals.')
      GMT.notify(playerSrc, '~r~Your illegals have been seized.')
    end
end)

RegisterServerEvent("GMT:newPanic")
AddEventHandler("GMT:newPanic", function(a,b)
	local source = source
	local user_id = GMT.getUserId(source)
  local currentradio = GMT.getCurrentRadio(source)
  if GMT.hasPermission(user_id, 'police.armoury') or GMT.hasPermission(user_id, "ukbf.armoury") or GMT.hasPermission(user_id, 'hmp.menu') or GMT.hasPermission(user_id, 'nhs.menu') or GMT.hasPermission(user_id, 'lfb.menu') or GMT.hasPermission(user_id, 'gang.whitelisted') then
      TriggerClientEvent("GMT:returnPanic", -1, nil, a, b, currentradio)
      GMT.sendDCLog(getPlayerFaction(user_id)..'-panic', 'GMT Panic Logs', "> Player Name: **"..GMT.getPlayerName(GMT.getUserId(source)).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Location: **"..a.Location.."**")
  end
end)

RegisterNetEvent("GMT:flashbangThrown")
AddEventHandler("GMT:flashbangThrown", function(coords)   
    TriggerClientEvent("GMT:flashbangExplode", -1, coords)
end)

RegisterNetEvent("GMT:updateSpotlight")
AddEventHandler("GMT:updateSpotlight", function(a)  
  local source = source 
  TriggerClientEvent("GMT:updateSpotlight", -1, source, a)
end)

RegisterCommand('wc', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasPermission(user_id, 'police.armoury') then
    GMTclient.getNearestPlayer(source, {2}, function(nplayer)
      if nplayer then
        GMTclient.getPoliceCallsign(source, {}, function(callsign)
          GMTclient.getPoliceRank(source, {}, function(rank)
            GMTclient.playAnim(source,{true,{{'paper_1_rcm_alt1-9', 'player_one_dual-9', 1}},false})
            GMT.notifyPicture(nplayer, "polnotification","notification","~b~Callsign: ~w~"..callsign.."\n~b~Rank: ~w~"..rank.."\n~b~Name: ~w~"..GMT.getPlayerName(GMT.getUserId(source)),"Metropolitan Police","Warrant Card",false,nil)
            TriggerClientEvent('GMT:flashWarrantCard', source)
          end)
        end)
      end
    end)
  end
end)

RegisterCommand('wca', function(source, args)
  local source = source
  local user_id = GMT.getUserId(source)
  if GMT.hasPermission(user_id, 'police.armoury') then
    GMTclient.getNearestPlayer(source, {2}, function(nplayer)
      if nplayer then
        GMTclient.getPoliceCallsign(source, {}, function(callsign)
          GMTclient.getPoliceRank(source, {}, function(rank)
            GMTclient.playAnim(source,{true,{{'paper_1_rcm_alt1-9', 'player_one_dual-9', 1}},false})
            GMT.notifyPicture(nplayer, "polnotification","notification","~b~Callsign: ~w~"..callsign.."\n~b~Rank: ~w~"..rank,"Metropolitan Police","Warrant Card",false,nil)
            TriggerClientEvent('GMT:flashWarrantCard', source)
          end)
        end)
      end
    end)
  end
end)

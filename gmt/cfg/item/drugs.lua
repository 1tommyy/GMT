
local items = {}

local cocaine_sniff = {}
cocaine_sniff["Take"] = {function(player,choice)
  local user_id = GMT.getUserId(player)
  if user_id then
    if GMT.tryGetInventoryItem(user_id,"Cocaine",1) then
      GMT.notify(player, "~g~Snorting Cocaine.")
      TriggerEvent('GMT:RefreshInventory', player)
      TriggerClientEvent('GMT:cocaineEffect', player)
    end
  end
end}

local heroin_take = {}
heroin_take["Take"] = {function(player,choice)
  local user_id = GMT.getUserId(player)
  if user_id then
    if GMT.tryGetInventoryItem(user_id,"Heroin",1) then
      GMT.notify(player, "~g~Injecting Heroin.")
      TriggerEvent('GMT:RefreshInventory', player)
      TriggerClientEvent('GMT:heroinEffect', player)
    end
  end
end}


local lsd_take = {}
lsd_take["Take"] = {function(player,choice)
  local user_id = GMT.getUserId(player)
  if user_id then
    if GMT.tryGetInventoryItem(user_id,"LSD",1) then
      GMT.notify(player, "~g~Taking LSD.")
      TriggerEvent('GMT:RefreshInventory', player)
      TriggerClientEvent('GMT:doAcid', player)
    end
  end
end}

local morphine_choices = {}
morphine_choices["Take"] = {function(player,choice)
  local user_id = GMT.getUserId(player)
  if user_id then
    if GMT.tryGetInventoryItem(user_id,"Morphine",1) then
      TriggerEvent('GMT:RefreshInventory', player)
      TriggerClientEvent('GMT:applyMorphine', player)
    end
  end
end}

local taco_choices = {}
taco_choices["Take"] = {function(player,choice)
  local user_id = GMT.getUserId(player)
  if user_id then
    if GMT.tryGetInventoryItem(user_id,"Taco",1) then
      TriggerEvent('GMT:RefreshInventory', player)
      TriggerClientEvent('GMT:eatTaco', player)
    end
  end
end}

-- Drugs
items["Cocaine"] = {"Cocaine","Some Cocaine.",function(args) return cocaine_sniff end,4}
items["Heroin"] = {"Heroin","Some Heroin.",function(args) return heroin_take end,4}
items["LSD"] = {"LSD","Some LSD.",function(args) return lsd_take end,4}

-- Edibles
items["Morphine"] = {"Morphine","Some Morphine.",function(args) return morphine_choices end,1}
items["Taco"] = {"Taco","A Taco.",function(args) return taco_choices end,1}

return items
-- load config items
local cfg = module("cfg/items")
local waps = module("cfg/weapons")
local items = {}

for k,v in pairs(cfg.items) do
  GMT.defInventoryItem(k,v[1],v[2],v[3],v[4])
  if k ~= "wammo" and k ~= "wbody" then
    local name = v[1]
    local desc = v[2]
    local weight = v[4]
    if type(name) == "function" then
      name = k
    end
    if type(desc) == "function" then
      desc = ""
    end
    if type(weight) == "function" then
      weight = 0.1
    end
    if type(name) ~= "string" or type(desc) ~= "string" or type(weight) ~= "number" then
      print("[GMT] invalid item name ["..k.."]",name,desc,weight)
    end
    if items[k] then
      print("[GMT] duplicate item name ["..k.."]")
    end
    items[k] = {name = name, desc = desc, weight = weight}
  end
end

for wap,data in pairs(waps.weapons) do
  local name = data.name
  local desc = ""
  local weight = cfg.items.wbody[4]({wap})
  items["wbody|"..wap] = {name = name, desc = desc, weight = weight}
end

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
  TriggerClientEvent("GMT:GottenItems",source,items)
end)

RegisterServerEvent("GMT:getItemInfo",function(user_id)
  local source = source
  local admin_id = GMT.getUserId(source)
  local tempId = GMT.getUserSource(user_id)
  if not tempId then
      GMT.notify(source,"~r~This player is not online")
      return
  end
  local name = GMT.getPlayerName(user_id)
  TriggerClientEvent("GMT:GottenItemInfo",source,{name = name, user_id = user_id, temp_id = tempId})
end)

RegisterServerEvent("GMT:GiveItemMenu",function(user_id,item,amount)
  local source = source
  local admin_id = GMT.getUserId(source)
  local tempId = GMT.getUserSource(user_id)
  if not tempId then
      GMT.notify(source,"~r~This player is not online")
      return
  end
  if not item or not amount then
      GMT.notify(source,"~r~Invalid item or amount")
      return
  end
  if not items[item] then
      GMT.notify(source,"~r~Invalid item")
      return
  end
  GMT.giveInventoryItem(user_id,item,amount)
  item = items[item].name
  GMT.notify(source,"~g~You gave "..amount.." "..item.." to "..GMT.getPlayerName(user_id))
  GMT.notify(tempId,"~g~You received "..amount.." "..item.." from "..GetPlayerName(source))
end)
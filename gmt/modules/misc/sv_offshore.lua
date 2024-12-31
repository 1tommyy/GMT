-- [[ Offshore Banking ]] -- 

local lang = GMT.lang


MySQL.createCommand("GMT/offshore_init_user","INSERT IGNORE INTO gmt_user_offshore(user_id,money) VALUES(@user_id,@money)")
MySQL.createCommand("GMT/get_offshore_money","SELECT money FROM gmt_user_offshore WHERE user_id = @user_id")
MySQL.createCommand("GMT/set_offshore_money","UPDATE gmt_user_offshore SET money = @money WHERE user_id = @user_id")

-- events, init user account if doesn't exist at connection
AddEventHandler("GMT:playerJoin",function(user_id,source,name,last_login)
  MySQL.query("GMT/offshore_init_user", {user_id = user_id,money=0}, function(affected)
    local tmp = GMT.getUserTmpTable(user_id)
    if tmp then
      MySQL.query("GMT/get_offshore_money", {user_id = user_id}, function(rows, affected)
        if rows and #rows > 0 then
          tmp.offshore = rows[1].money or 0
        end
      end)
    end
  end)
end)

-- save money on leave
AddEventHandler("GMT:playerLeave",function(user_id,source)
-- (money)
    local tmp = GMT.getUserTmpTable(user_id)
    if tmp and tmp.offshore then
        MySQL.execute("GMT/set_offshore_money", {user_id = user_id, money = tmp.offshore})
    end
end)
  
-- save money (at same time that save datatables)
AddEventHandler("GMT:save", function()
    for k,v in pairs(GMT.user_tmp_tables) do
        if v.offshore then
            MySQL.execute("GMT/set_offshore_money", {user_id = k, money = v.offshore})
        end
    end
end)

RegisterServerEvent("GMT:depositOffshoreMoney")
AddEventHandler("GMT:depositOffshoreMoney", function(amount)
  local source = source
  local user_id = GMT.getUserId(source)
  if amount > 0 then
      local fee = math.floor(amount * 0.01) -- 1% fee
      local amountAfterFee = math.floor(amount - fee)
      if GMT.tryBankPayment(user_id, amount) then
          GMT.giveOffshoreMoney(user_id, amountAfterFee)
          GMT.notify(source, "~g~Deposited £" .. getMoneyStringFormatted(amountAfterFee) .. " 1% deposit fee paid.")
          GMT.sendDCLog('deposit-offshore', "GMT Deposit Offshore Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Amount: **£"..amountAfterFee.."**\n> Fee: **£"..fee.."**")
      end
  end
end)

RegisterServerEvent("GMT:depositAllOffshoreMoney")
AddEventHandler("GMT:depositAllOffshoreMoney", function()
  local source = source
  local user_id = GMT.getUserId(source)
  local amount = GMT.getBankMoney(user_id)
  if amount > 0 then
      local fee = math.floor(amount * 0.01) -- 1% fee
      local amountAfterFee = math.floor(amount - fee)
      if GMT.tryBankPayment(user_id, amount) then
          GMT.giveOffshoreMoney(user_id, amountAfterFee)
          GMT.notify(source, "~g~Deposited £" .. getMoneyStringFormatted(amountAfterFee) .. " 1% deposit fee paid.")
          GMT.sendDCLog('deposit-offshore', "GMT Deposit Offshore Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Amount: **£"..amountAfterFee.."**\n> Fee: **£"..fee.."**")
      end
  end
end)

RegisterServerEvent("GMT:withdrawAllOffshoreMoney")
AddEventHandler("GMT:withdrawAllOffshoreMoney", function()
    local source = source
    local user_id = GMT.getUserId(source)
    local amount = GMT.getOffshore(user_id)
    if amount > 0 and GMT.tryOffshorePayment(user_id, amount) then
        GMT.giveBankMoney(user_id, amount)
        GMT.notify(source, "~g~Withdrawn £" .. getMoneyStringFormatted(math.floor(amount)))
    end
end)

RegisterServerEvent("GMT:withdrawOffshoreMoney")
AddEventHandler("GMT:withdrawOffshoreMoney", function(amount)
  local source = source
  local user_id = GMT.getUserId(source)
  local money = GMT.getOffshore(user_id)
  if amount > 0 and money >= amount and GMT.tryOffshorePayment(user_id, amount) then
     GMT.giveBankMoney(user_id, amount)
     GMT.notify(source, "~g~Withdrawn £" .. getMoneyStringFormatted(math.floor(amount)))
  end
end)

function GMT.giveOffshoreMoney(user_id,amount)
  if amount > 0 then
    local money = GMT.getOffshore(user_id)
    GMT.setOffshore(user_id,money+amount)
  end
end

function GMT.setOffshore(user_id,value)
    local tmp = GMT.getUserTmpTable(user_id)
    if tmp then
      tmp.offshore = value
      -- update client display
      local source = GMT.getUserSource(user_id)
      if source then
        TriggerClientEvent('GMT:setDisplayOffshore', source, tmp.offshore)
      end
    end
  end

Citizen.CreateThread(function()
  while true do
    Wait(5000)
    for k,v in pairs(GMT.user_tmp_tables) do
      if v.offshore then
        MySQL.execute("GMT/set_offshore_money", {user_id = k, money = v.offshore})
      end
    end
  end
end)

function GMT.tryOffshorePayment(user_id,amount)
  local money = GMT.getOffshore(user_id)
  if amount >= 0 and money >= amount then
    GMT.setOffshore(user_id,money-amount)
    return true
  else
    return false
  end
end

function GMT.getOffshore(user_id)
  local tmp = GMT.getUserTmpTable(user_id)
  if tmp then
    return tmp.offshore or 0
  else
    return 0
  end
end

--
local lang = GMT.lang

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

MySQL.createCommand("GMT/money_init_user","INSERT IGNORE INTO gmt_user_moneys(user_id,wallet,bank,dirtycash) VALUES(@user_id,@wallet,@bank,@dirtycash)")
MySQL.createCommand("GMT/get_money","SELECT wallet,bank,dirtycash FROM gmt_user_moneys WHERE user_id = @user_id")
MySQL.createCommand("GMT/set_money","UPDATE gmt_user_moneys SET wallet = @wallet, bank = @bank, dirtycash = @dirtycash WHERE user_id = @user_id")

-- get money
-- cbreturn nil if error
function GMT.getMoney(user_id)
  local tmp = GMT.getUserTmpTable(user_id)
  if tmp then
    return tmp.wallet or 0
  else
    return 0
  end
  task_save_datatables()
end

-- set money
function GMT.setMoney(user_id,value)
  local tmp = GMT.getUserTmpTable(user_id)
  if tmp then
    tmp.wallet = value
  end
    -- update client display
    local source = GMT.getUserSource(user_id)
    if source then
      TriggerClientEvent('GMT:setDisplayMoney', source, tmp.wallet)
    end
end


  -- get dirtycash
  function GMT.getDirtyCash(user_id)
    local tmp = GMT.getUserTmpTable(user_id)
    if tmp then
      return tmp.dirtycash or 0
    else
      return 0
    end
  end

  local function ProcessDirtyCashItem(user_id, amount)
    local data = GMT.getUserDataTable(user_id)
    if not data then return end
    if amount < 0 then amount = 0 end
    local entry = data.inventory.redmoney
    if amount == 0 then
      data.inventory.redmoney = nil
      return
    end
    data.inventory.redmoney = {amount = amount}
  end

  -- set dirty money
  function GMT.setDirtyCash(user_id,value,dontSet)
    local tmp = GMT.getUserTmpTable(user_id)
    if tmp then
      tmp.dirtycash = value
    end
  -- update client display
  local source = GMT.getUserSource(user_id)
  if source then
    TriggerClientEvent('GMT:setDisplayRedMoney', source, tmp.dirtycash)
  end
  if dontSet then return end
  ProcessDirtyCashItem(user_id, value)
end

    -- give dirty money
    function GMT.giveDirtyCash(user_id,amount,dontSet)
      local money = GMT.getDirtyCash(user_id)
      GMT.setDirtyCash(user_id,money+amount,dontSet)
    end

-- try a payment
-- return true or false (debited if true)
function GMT.tryPayment(user_id,amount)
  local money = GMT.getMoney(user_id)
  if amount >= 0 and money >= amount then
    GMT.setMoney(user_id,money-amount)
    return true
  else
    return false
  end
end

function GMT.tryRedPayment(user_id,amount)
  local money = GMT.getDirtyCash(user_id)
  if amount >= 0 and money >= amount then
    GMT.setDirtyCash(user_id,money-amount)
    return true
  else
    return false
  end
end

function GMT.tryBankPayment(user_id,amount)
  local bank = GMT.getBankMoney(user_id)
  if amount >= 0 and bank >= amount then
    GMT.setBankMoney(user_id,bank-amount)
    return true
  else
    return false
  end
end

-- give money
function GMT.giveMoney(user_id, amount)
  if type(user_id) == "number" and type(amount) == "number" and amount > 0 then
      local money = GMT.getMoney(user_id)
      GMT.setMoney(user_id, money + amount)
  end
end

-- get bank money
function GMT.getBankMoney(user_id)
  local tmp = GMT.getUserTmpTable(user_id)
  if tmp then
    return tmp.bank or 0
  else
    return 0
  end
end

-- set bank money
function GMT.setBankMoney(user_id,value)
  local tmp = GMT.getUserTmpTable(user_id)
  if tmp then
    tmp.bank = value
  end
  local source = GMT.getUserSource(user_id)
  if source then
    GMTclient.setDivContent(source,{"bmoney",lang.money.bdisplay({Comma(GMT.getBankMoney(user_id))})})
    TriggerClientEvent('GMT:initMoney', source, GMT.getMoney(user_id), GMT.getBankMoney(user_id))
    TriggerClientEvent('GMT:setAccountMoney',source,GMT.getBankMoney(user_id))
  end
end

-- give bank money
function GMT.giveBankMoney(user_id,amount)
  if amount > 0 then
    local money = GMT.getBankMoney(user_id)
    GMT.setBankMoney(user_id,money+amount)
    task_save_datatables()
  end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function GMT.tryWithdraw(user_id,amount)
  local money = GMT.getBankMoney(user_id)
  if amount > 0 and money >= amount then
    GMT.setBankMoney(user_id,money-amount)
    GMT.giveMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true or false (deposited if true)
function GMT.tryDeposit(user_id,amount)
  if amount > 0 and GMT.tryPayment(user_id,amount) then
    GMT.giveBankMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
function GMT.tryFullPayment(user_id,amount)
  local money = GMT.getMoney(user_id)
  if money >= amount then -- enough, simple payment
    return GMT.tryPayment(user_id, amount)
  else  -- not enough, withdraw -> payment
    if GMT.tryWithdraw(user_id, amount-money) then -- withdraw to complete amount
      return GMT.tryPayment(user_id, amount)
    end
  end

  return false
end

local startingCash = 0
local startingBank = 30000000 -- tayser

-- events, init user account if doesn't exist at connection
AddEventHandler("GMT:playerJoin",function(user_id,source,name,last_login)
  MySQL.query("GMT/money_init_user", {user_id = user_id, wallet = startingCash, bank = startingBank, dirtycash = 0}, function(affected)
    local tmp = GMT.getUserTmpTable(user_id)
    if tmp then
      MySQL.query("GMT/get_money", {user_id = user_id}, function(rows, affected)
        if rows and #rows > 0 then
          tmp.bank = rows[1].bank
          tmp.wallet = rows[1].wallet
          tmp.dirtycash = rows[1].dirtycash
        end
      end)
    end
  end)
end)

-- save money on leave
AddEventHandler("GMT:playerLeave",function(user_id,source)
  -- (wallet,bank)
  local tmp = GMT.getUserTmpTable(user_id)
  if tmp and tmp.wallet and tmp.bank and tmp.dirtycash then
    MySQL.execute("GMT/set_money", {user_id = user_id, wallet = tmp.wallet, bank = tmp.bank, dirtycash = tmp.dirtycash})
  end
end)

-- save money (at same time that save datatables)
AddEventHandler("GMT:save", function()
  for k,v in pairs(GMT.user_tmp_tables) do
    if v.wallet and v.bank then
      MySQL.execute("GMT/set_money", {user_id = k, wallet = v.wallet, bank = v.bank, dirtycash = v.dirtycash})
    end
  end
end)

RegisterNetEvent('GMT:giveCashToPlayer')
AddEventHandler('GMT:giveCashToPlayer', function(nplayer)
  local source = source
  local user_id = GMT.getUserId(source)
  if user_id then
    if nplayer then
      local nuser_id = GMT.getUserId(nplayer)
      if nuser_id then
        GMT.prompt(source,lang.money.give.prompt(),"",function(source,amount)
          local amount = parseInt(amount)
          if amount > 0 and GMT.tryPayment(user_id,amount) then
            GMT.giveMoney(nuser_id,amount)
            GMT.notify(source, lang.money.given({getMoneyStringFormatted(math.floor(amount))}))
            GMT.notify(nplayer, lang.money.received({getMoneyStringFormatted(math.floor(amount))}))
            GMTclient.playAnim(source, {true, {{"mp_common", "givetake1_a", 1}}, false})
            GMTclient.playAnim(nplayer, {true, {{"mp_common", "givetake2_a", 1}}, false})
            GMT.sendDCLog('give-cash', "GMT Give Cash Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Target Name: **"..GMT.getPlayerName(nuser_id).."**\n> Target PermID: **"..nuser_id.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**")
          else
            GMT.notify(source, lang.money.not_enough())
          end
        end)
      else
        GMT.notify(source, lang.common.no_player_near())
      end
    else
      GMT.notify(source, lang.common.no_player_near())
    end
  else
      GMT.ACBan(15,user_id,"GMT:giveCashToPlayer")
  end
end)


function Comma(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

RegisterServerEvent("GMT:takeAmount")
AddEventHandler("GMT:takeAmount", function(amount, message)
    local source = source
    local user_id = GMT.getUserId(source)
    
    if not message then
        message = "Miscellaneous purchase"
    end
    
    if GMT.tryFullPayment(user_id, amount) then
        GMT.notify(source, "You paid ~g~£" .. getMoneyStringFormatted(amount) .. "~s~ for " .. message)
        return
    end
end)

RegisterServerEvent("GMT:bankTransfer")
AddEventHandler("GMT:bankTransfer", function(targetId, amount)
    local source = source
    local user_id = GMT.getUserId(source)
    local targetId = tonumber(targetId)
    local amount = tonumber(amount)

    if targetId ~= user_id then 
        if GMT.getUserSource(targetId) then
            if GMT.tryBankPayment(user_id, amount) then
                GMT.notifyPicture6(GMT.getUserSource(targetId), "walletnotification", "notification", "You have received ~g~£" ..getMoneyStringFormatted(amount).. "~s~ from ~g~" .. GMT.getPlayerName(user_id) .. ".", "Wallet", "Received Money")
                GMT.notifyPicture6(source, "walletnotification", "notification", "Transferred ~g~£" ..getMoneyStringFormatted(amount).. "~s~ to ~g~" .. GMT.getPlayerName(targetId), "Wallet", "Transferred Money")
                TriggerClientEvent("gmt:PlaySound", source, "apple")
                TriggerClientEvent("gmt:PlaySound", GMT.getUserSource(targetId), "iphone_dodoDO")
                GMT.giveBankMoney(targetId, amount)
                GMT.sendDCLog('bank-transfer', "GMT Bank Transfer Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Target Name: **"..GMT.getPlayerName(targetId).."**\n> Target PermID: **"..targetId.."**\n> Amount: **£"..amount.."**")
            else
                GMT.notifyPicture6(source, "walletnotification", "notification", "You do not have ~g~£" ..getMoneyStringFormatted(amount), "Wallet", "Insignificant funds")
            end
        else
            GMT.notifyPicture6(source, "walletnotification", "notification", "Target user not online", "Wallet", "Unable to transfer money")
        end
    else
        GMT.notifyPicture6(source, "walletnotification", "notification", "Cannot transfer money to yourself", "Wallet", "Invalid transaction")
    end
end)

RegisterServerEvent('GMT:requestPlayerBankBalance')
AddEventHandler('GMT:requestPlayerBankBalance', function()
    local user_id = GMT.getUserId(source)
    local bank = GMT.getBankMoney(user_id)
    local wallet = GMT.getMoney(user_id)
    local dirtycash = GMT.getDirtyCash(user_id)
    local offshore = GMT.getOffshore(user_id)
    TriggerClientEvent('GMT:setDisplayMoney', source, wallet)
    TriggerClientEvent('GMT:setDisplayBankMoney', source, bank)
    TriggerClientEvent('GMT:setDisplayOffshore', source, offshore)
    TriggerClientEvent('GMT:initMoney', source, wallet, bank, dirtycash,offshore)
    ProcessDirtyCashItem(user_id, dirtycash)
    TriggerClientEvent('GMT:setDisplayRedMoney', source, dirtycash)
    TriggerClientEvent('GMT:setAccountMoney',source,bank)
end)
RegisterServerEvent('GMT:setCarDevMode')
AddEventHandler('GMT:setCarDevMode', function(status)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id and GMT.hasPermission(user_id, "cardev.menu") then 
      if status then
      --  GMTclient.teleport(player,{2370.8, 2856.58, 40.46})
        GMT.setBucket(source, 333)
      else
        GMT.setBucket(source, 0)
      end
    else
      GMT.ACBan(15,user_id,"GMT:setCarDevMode")
    end
end)

local screenshotdata = {}

RegisterServerEvent('GMT:takeCarScreenshot')
AddEventHandler('GMT:takeCarScreenshot', function()
    local source = source
    local url = url
    local user_id = GMT.getUserId(source)
    local name = GMT.getPlayerName(user_id)

    if user_id and GMT.hasPermission(user_id, "cardev.menu") then 
      --TriggerClientEvent("GMT:takeCarScreenshotAndUpload", source, 'http://gmtstudios.ltd/uplds.php',screenshotid)
      local screenshotid = #screenshotdata + 1
      screenshotdata[screenshotid] = {target = user_id, admin = user_id}
      TriggerClientEvent("GMT:takeClientScreenshotAndUpload", source, GMT.getWebhook('media-cache'),screenshotid)  
    end
end)

RegisterServerEvent('GMT:sendWebhookCarDev')
AddEventHandler('GMT:sendWebhookCarDev', function(output, car)
    local source = source
    local user_id = GMT.getUserId(source)
    local name = GMT.getPlayerName(user_id)

    if user_id and GMT.hasPermission(user_id, "cardev.menu") then 
        GMT.sendDCLog('car-dev', 'GMT Car Dev Logs', "> Players TempID: **" .. source .. "**\n> Players PermID: **" .. user_id .. "**\n> Players Name: **" .. name .. "**\n\n Requested the following for car: **" .. car .. "**\n\n```" .. output .. "```")
    else
        GMT.ACBan(15,user_id,"GMT:sendWebhookCarDev")
    end
end)

RegisterServerEvent('gmt:getUserVehicles')
AddEventHandler('gmt:getUserVehicles', function()
  local source = source
  local user_id = GMT.getUserId(source)
    local vehicles = {}

    exports['gmt']:execute('SELECT * FROM gmt_cardev WHERE user_id = @user_id AND claimed = true', {['@user_id'] = user_id}, function(result, affectedRows, lastInsertId)
      if result then
          vehicles = result
         -- print("Fetched vehicles for user_id " .. user_id .. ":")
          for _, v in pairs(vehicles) do
              for key, value in pairs(v) do
                --  print(key, value)
              end
          end
      else
          print("Error executing SQL query:", affectedRows, lastInsertId)
      end
      TriggerClientEvent('gmt:receiveUserVehicles', source, vehicles)
  end)  
end)

RegisterServerEvent('gmt:markVehicleComplete')
AddEventHandler('gmt:markVehicleComplete', function(reportid, reason)
    local source = source
    local user_id = GMT.getUserId(source)
    local name = GMT.getPlayerName(user_id)
    exports['gmt']:execute('UPDATE gmt_cardev SET completed = true, notes = @reason WHERE user_id = @user_id AND reportid = @reportid', {
        ['@user_id'] = user_id,
        ['@reportid'] = reportid,
        ['@reason'] = reason
    })
    GMT.notify(source, "~g~Report ID: " .. reportid .. " has been marked as complete.")
    GMT.sendDCLog('car-report', name.. " has completed report id: "..reportid, "> Name: **"..name.."**\n> User TempID: **"..source.."**\n> User PermID: ** "..user_id.."**\n> Report ID: **" .. reportid .. "**\n> Notes: **" .. reason .. "**")
end)

function carReportReceived()
  TriggerClientEvent('GMT:carDevTicket', -1)
end

exports('carReportReceived', carReportReceived)
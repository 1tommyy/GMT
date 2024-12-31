local verifyCodes = {}
local alreadyVerified = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        for k, v in pairs(verifyCodes) do
            if verifyCodes[k] then
                verifyCodes[k] = nil
            end
        end
    end
end)

RegisterServerEvent("GMT:AllowDiscordVerify")
AddEventHandler("GMT:AllowDiscordVerify", function(player_temp)
    local source = source
    local user_id = GMT.getUserId(source)
    local player_perm = GMT.getUserId(player_temp)
    if GMT.hasPermission(user_id,"admin.tp2waypoint") then
        if player_perm == user_id then
            GMT.notify(source, '~r~You cannot re-verify yourself.')
            return
        end
        if not alreadyVerified[player_perm] then
            GMT.notify(source, '~r~User already can verify their discord.')
            return
        end
        alreadyVerified[player_perm] = false
        GMT.notify(source, '~g~User can now re-verify their discord account.')
        GMT.notify(player_temp, '~b~You can now re-verify your discord account.')
        GMT.sendDCLog('discord-reverify',"GMT Change Linked Discord Logs", "> Admin Name: **"..GMT.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..GMT.getPlayerName(player_perm).."**\n> Players TempID: **"..player_temp.."**\n> Players PermID: **"..player_perm.."**")
    else
        GMT.ACBan(15,user_id,"AllowDiscordVerify")
    end
end)


RegisterServerEvent('GMT:changeLinkedDiscord', function()
    local source = source
    local user_id = GMT.getUserId(source)
    if alreadyVerified[user_id] then
        GMT.notify(source, '~r~You cannot verify another discord account, wait till next restart.')
        return
    end
    GMT.prompt(source, "Enter Discord Id:", "", function(source, discordid)
        if discordid and discordid ~= "" and discordid:match("^%d+$") then
            TriggerClientEvent('GMT:gotDiscord', source)
            GMTclient.generateUUID(source, {"linkcode", 5, "alphanumeric"}, function(code)
                verifyCodes[user_id] = { code = code, discordid = discordid, timestamp = os.time() }
                exports['GMTStaffBot']:dmUser(source, { discordid, code, user_id }, function() end)
            end)
        else
            GMT.notify(source, '~r~Invalid Discord ID provided.')
            Wait(100)
            GMT.notify(source, '~y~Your Discord ID is a number such as 620232047671377931 which identifies your account.')
            Wait(100)
            GMT.notify(source, '~y~Right click your Discord account and press Copy User ID. You may need to enable Developer Mode.')
            Wait(100)
            GMT.notify(source, '~y~Developer mode can be enabled under Discord Settings -> Advanced -> Developer Mode.')
        end
    end)
end)

RegisterServerEvent('GMT:enterDiscordCode', function()
    local source = source
    local user_id = GMT.getUserId(source)
    local currentTimestamp = os.time()
    local verification = verifyCodes[user_id]
    if alreadyVerified[user_id] then
        GMT.notify(source, '~r~You have already verified your discord account.')
        return
    end
    if verification and currentTimestamp - verification.timestamp <= 300 then
        GMT.prompt(source, "Enter Code:", "", function(source, code)
            if code and code ~= "" then
                if verification.code == code then
                    exports['gmt']:execute("SELECT discord_id FROM `gmt_verification` WHERE user_id = @user_id", { user_id = user_id }, function(result)
                        local previousDiscordId = result[1].discord_id or "Unknown"
                        exports['gmt']:execute("UPDATE `gmt_verification` SET discord_id = @discord_id WHERE user_id = @user_id", { user_id = user_id, discord_id = verification.discordid }, function() end)
                        GMT.notify(source, '~g~Successfully re-verified discord.')
                        GMT.sendDCLog('discord-reverify',"GMT Change Linked Discord Logs", "\n> Players Name: **"..GMT.getPlayerName(user_id).."**\n> Players TempID: **"..source.."**\n> Players PermID: **"..user_id.."**\n> Previous Discord ID: **"..previousDiscordId.."**\n> New Discord ID: **"..verification.discordid.."**\n> Code: **"..verification.code.."**")
                        alreadyVerified[user_id] = true
                    end)
                else
                    GMT.notify(source, '~r~Invalid code provided.')
                end
            else
                GMT.notify(source, '~r~You need to enter a code!')
            end
        end)
    else
        GMT.notify(source, '~r~Your code has expired.')
    end
end)

local cfg = module("cfg/cfg_licensecentre")

RegisterServerEvent("LicenseCentre:BuyGroup")
AddEventHandler('LicenseCentre:BuyGroup', function(job, name)
    local source = source
    local user_id = GMT.getUserId(source)
    local coords = cfg.location
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    if not GMT.hasGroup(user_id, "Rebel") and job == "AdvancedRebel" then
        GMT.notify(source, "You need to have Rebel License.")
        return
    end
    if #(playerCoords - coords) <= 20.0 then
        if GMT.hasGroup(user_id, job) then 
            GMT.notify(source, "~o~You have already purchased this license!")
            TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
        else
            for k,v in pairs(cfg.licenses) do
                if v.group == job then
                    if GMT.tryFullPayment(user_id, v.price) then
                        GMT.addUserGroup(user_id,job)
                        GMT.notify(source, "~g~Purchased " .. name .. " for ".. '£' ..tostring(getMoneyStringFormatted(v.price)) .. " ")
                        GMT.sendDCLog('purchases',"GMT License Centre Logs", "> Player Name: **"..GMT.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Purchased: **"..name.."**")
                        TriggerClientEvent("gmt:PlaySound", source, "playMoney")
                        TriggerClientEvent("GMT:gotOwnedLicenses", source, getLicenses(user_id))
                        TriggerClientEvent("GMT:refreshGunStorePermissions", source)
                    else 
                        GMT.notify(source, "You do not have enough money to purchase this license!")
                        TriggerClientEvent("gmt:PlaySound", source, "playCasinoLose")
                    end
                end
            end
        end
    else 
        GMT.ACBan(15,user_id,"License Centre Distance: "..(#(playerCoords - coords)))
    end
end)

function getLicenses(user_id)
    local licenses = {}
    if user_id then
        for k, v in pairs(cfg.licenses) do
            if GMT.hasGroup(user_id, v.group) then
                table.insert(licenses, v.name)
            end
        end
        return licenses
    end
end

RegisterNetEvent("GMT:GetLicenses")
AddEventHandler("GMT:GetLicenses", function()
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        TriggerClientEvent("GMT:ReceivedLicenses", source, getLicenses(user_id))
    end
end)

RegisterNetEvent("GMT:getOwnedLicenses")
AddEventHandler("GMT:getOwnedLicenses", function()
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        TriggerClientEvent("GMT:gotOwnedLicenses", source, getLicenses(user_id))
    end
end)
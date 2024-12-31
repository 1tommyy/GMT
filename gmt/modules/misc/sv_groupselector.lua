local cfg=module("cfg/cfg_groupselector")

function GMT.getJobSelectors(source)
    local source=source
    local jobSelectors={}
    local user_id = GMT.getUserId(source)
    for k,v in pairs(cfg.selectors) do
        for i,j in pairs(cfg.selectorTypes) do
            if v.type == i then
                if j._config.permissions[1]~=nil then
                    if GMT.hasPermission(GMT.getUserId(source),j._config.permissions[1])then
                        v['_config'] = j._config
                        v['jobs'] = {}
                        for a,b in pairs(j.jobs) do
                            if GMT.hasGroup(user_id, b[1]) then
                                table.insert(v['jobs'], b)
                            end
                        end
                        jobSelectors[k] = v
                    end
                else
                    v['_config'] = j._config
                    v['jobs'] = j.jobs
                    jobSelectors[k] = v
                end
            end
        end
    end
    TriggerClientEvent("GMT:gotJobSelectors",source,jobSelectors)
end

RegisterNetEvent("GMT:getJobSelectors")
AddEventHandler("GMT:getJobSelectors",function()
    local source = source
    GMT.getJobSelectors(source)
end)

function GMT.removeAllJobs(user_id)
    local source = GMT.getUserSource(user_id)
    for i,j in pairs(cfg.selectorTypes) do
        for k,v in pairs(j.jobs)do
            if i == 'default' and GMT.hasGroup(user_id, v[1]) then
                GMT.removeUserGroup(user_id, v[1])
            elseif i ~= 'default' and GMT.hasGroup(user_id, v[1]..' Clocked') then
                GMT.removeUserGroup(user_id, v[1]..' Clocked')
                RemoveAllPedWeapons(GetPlayerPed(source), true)
                GMTclient.setArmour(source, {0})
                TriggerEvent('GMT:clockedOffRemoveRadio', source)
            end
        end
    end
    -- remove all faction ranks
    GMTclient.setPolice(source, {false})
    TriggerClientEvent('gmtui:globalOnPoliceDuty', source, false)
    GMTclient.setNHS(source, {false})
    TriggerClientEvent('gmtui:globalOnNHSDuty', source, false)
    GMTclient.setHMP(source, {false})
    TriggerClientEvent('gmtui:globalOnUKBFDuty', source, false)
    GMTclient.setUKBF(source, {false})
    TriggerClientEvent('gmtui:globalOnPrisonDuty', source, false)
    GMTclient.setLFB(source, {false})
    TriggerClientEvent('gmtui:globalLFBOnDuty', source, false)
    GMTclient.setAA(source, {false})
    TriggerClientEvent('gmtui:globalOnAADuty', source, false)
    TriggerClientEvent('GMT:disableFactionBlips', source)
    TriggerClientEvent('GMT:radiosClearAll', source)
    -- toggle all main jobs to false
    TriggerClientEvent('GMT:toggleTacoJob', source, false)
    TriggerClientEvent('GMT:setTruckerOnDuty', source, false)
end

RegisterNetEvent("GMT:jobSelector")
AddEventHandler("GMT:jobSelector",function(a,b)
    local source = source
    local user_id = GMT.getUserId(source)
    if #(GetEntityCoords(GetPlayerPed(source)) - cfg.selectors[a].position) > 20 then
        GMT.ACBan(15,user_id,"GMT:jobSelector")
        return
    end
    if b == "Unemployed" then
        GMT.removeAllJobs(user_id)
        GMT.notify(source, "~g~You are now unemployed.")
        TriggerClientEvent("GMT:jobSelectorCooldown", source, true)
    else
        if cfg.selectors[a].type == 'police' then
            if GMT.hasGroup(user_id, b) then
                if not GMT.hasGroup(user_id,b..' Clocked') then
                    GMT.removeAllJobs(user_id)
                    GMT.addUserGroup(user_id,b..' Clocked')
                    GMTclient.setPolice(source, {true})
                    TriggerClientEvent('gmtui:globalOnPoliceDuty', source, true)
                    GMT.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    GMT.sendDCLog('pd-clock', 'GMT Police Clock On Logs',"> Officer Name: **"..GMT.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
                    TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
                else
                    GMT.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                GMT.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'nhs' then
            if GMT.hasGroup(user_id, b) then
                if not GMT.hasGroup(user_id,b..' Clocked') then
                    GMT.removeAllJobs(user_id)
                    GMT.addUserGroup(user_id,b..' Clocked')
                    GMTclient.setNHS(source, {true})
                    TriggerClientEvent('gmtui:globalOnNHSDuty', source, true)
                    GMT.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    GMT.sendDCLog('nhs-clock', 'GMT NHS Clock On Logs',"> Medic Name: **"..GMT.getPlayerName(user_id).."**\n> Medic TempID: **"..source.."**\n> Medic PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
                else
                    GMT.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                GMT.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'ukbf' then
            if GMT.hasGroup(user_id, b) then
                if not GMT.hasGroup(user_id,b..' Clocked') then
                    GMT.removeAllJobs(user_id)
                    GMT.addUserGroup(user_id,b..' Clocked')
                    GMTclient.setUKBF(source, {true})
                    TriggerClientEvent('gmtui:globalOnUKBFDuty', source, true)
                    GMT.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
                else
                    GMT.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                GMT.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'lfb' then
            if GMT.hasGroup(user_id, b) then
                if not GMT.hasGroup(user_id,b..' Clocked') then
                    GMT.removeAllJobs(user_id)
                    GMT.addUserGroup(user_id,b..' Clocked')
                    GMTclient.setLFB(source, {true})
                    TriggerClientEvent('gmtui:globalOnLFBDuty', source, true)
                    GMT.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
                else
                    GMT.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                GMT.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'hmp' then
            if GMT.hasGroup(user_id, b) then
                if not GMT.hasGroup(user_id,b..' Clocked') then
                    GMT.removeAllJobs(user_id)
                    GMT.addUserGroup(user_id,b..' Clocked')
                    GMTclient.setHMP(source, {true})
                    TriggerClientEvent('gmtui:globalOnPrisonDuty', source, true)
                    GMT.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    GMT.sendDCLog('hmp-clock', 'GMT HMP Clock On Logs',"> Prison Officer Name: **"..GMT.getPlayerName(user_id).."**\n> Prison Officer TempID: **"..source.."**\n> Prison Officer PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
                else
                    GMT.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                GMT.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        else
            GMT.removeAllJobs(user_id)
            GMT.addUserGroup(user_id,b)
            GMT.notify(source, "~g~Employed as "..b..".")
            TriggerClientEvent('gmtui:jobInstructions',source,b)
            if b == 'Taco Seller' then
                TriggerClientEvent('GMT:toggleTacoJob', source, true)
            end
            if b == 'AA Mechanic' then
                GMTclient.setAA(source, {true})
                TriggerClientEvent('gmtui:globalOnAADuty', source, true)
            end
            if b == 'Lorry Driver' then
                TriggerClientEvent('GMT:setTruckerOnDuty', source, true)
            end
        end
        TriggerClientEvent("GMT:jobSelectorCooldown", source, false)
        TriggerEvent('GMT:clockedOnCreateRadio', source)
        TriggerClientEvent('GMT:radiosClearAll', source)
        TriggerClientEvent('GMT:refreshGunStorePermissions', source)
        GMT.updateCurrentPlayerInfo()
    end
end)
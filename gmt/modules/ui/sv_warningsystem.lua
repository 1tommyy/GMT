function GMT.GetWarnings(user_id, source)
    local gmtwarningstables = exports['gmt']:executeSync("SELECT * FROM gmt_warnings WHERE user_id = @uid", { uid = user_id })
    for warningID, warningTable in pairs(gmtwarningstables) do
        local date = warningTable["warning_date"]
        local newdate = tonumber(date) / 1000
        newdate = os.date('%Y-%m-%d', newdate)
        warningTable["warning_date"] = newdate
		local points = warningTable["point"]
    end
    return gmtwarningstables
end

function GMT.AddWarnings(target_id, adminName, warningReason, warning_duration, point)
    if warning_duration == -1 then
        warning_duration = 0
    end
    exports['gmt']:execute("INSERT INTO gmt_warnings (`user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`, `point`) VALUES (@user_id, @warning_type, @duration, @admin, @warning_date, @reason, @point);", { user_id = target_id, warning_type = "Ban", admin = adminName, duration = warning_duration, warning_date = os.date("%Y/%m/%d"), reason = warningReason, point = point })
end

RegisterServerEvent("GMT:refreshWarningSystem")
AddEventHandler("GMT:refreshWarningSystem", function()
    local source = source
    local user_id = GMT.getUserId(source)
    local gmtwarningstables = GMT.GetWarnings(user_id, source)
    local ndata = GMT.getUserDataTable(user_id)
    local a = exports['gmt']:executeSync("SELECT * FROM gmt_bans_offenses WHERE UserID = @uid", { uid = user_id })
    for k, v in pairs(a) do
        if v.UserID == user_id then
            for warningID, warningTable in pairs(gmtwarningstables) do
                warningTable["points"] = v.points
            end
            local info = { user_id = user_id}
            TriggerClientEvent("GMT:recievedRefreshedWarningData", source, gmtwarningstables, v.points, info, ndata.PlayerTime, user_id)
        end
    end
end)

RegisterCommand('sw', function(source, args)
    local user_id = GMT.getUserId(source)
    local permID = tonumber(args[1])
    if permID then
        if GMT.hasPermission(user_id, "admin.tickets") then
            local gmtwarningstables = GMT.GetWarnings(permID, source)
            local ndata = GMT.getUserDataTable(permID)
            local a = exports['gmt']:executeSync("SELECT * FROM gmt_bans_offenses WHERE UserID = @uid", { uid = permID })
            for k, v in pairs(a) do
                if v.UserID == permID then
                    for warningID, warningTable in pairs(gmtwarningstables) do
                        warningTable["points"] = v.points
                    end
                    local info = { user_id = permID}
                    TriggerClientEvent("GMT:showWarningsOfUser", source, gmtwarningstables, v.points, info, ndata.PlayerTime, permID)
                end
            end
        end
    end
end)

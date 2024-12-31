local stats = {monthly = {},total = {}}

local function RefreshStatMenu()
    stats = {monthly = {}, total = {}}
    exports["gmt"]:execute("SELECT * FROM gmt_statistics",function(result)
        if result then
            for k,v in pairs(result) do
                local monthly, total = #stats.monthly+1, #stats.total+1
                stats.monthly[monthly], stats.total[total] = json.decode(v.monthlystats), json.decode(v.totalstats)
                stats.monthly[monthly].name, stats.total[total].name = v.name, v.name
                stats.monthly[monthly].user_id, stats.total[total].user_id = v.user_id, v.user_id
            end
          --  print("[GMT] Statistic loaded")
        end
    end)
end

function GMT.SetStat(user_id, stat, value)
    if user_id and stat and value then
        exports["gmt"]:execute("SELECT * FROM gmt_statistics WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local monthly = json.decode(result[1].monthlystats)
                local total = json.decode(result[1].totalstats)
                if monthly[stat] == nil then
                    monthly[stat] = 0
                end
                if total[stat] == nil then
                    total[stat] = 0
                end
                monthly[stat], total[stat] = value, value
                exports["gmt"]:execute("UPDATE gmt_statistics SET name = @name, monthlystats = @monthly, totalstats = @total WHERE user_id = @user_id", {user_id = user_id, name = result[1].name, monthly = json.encode(monthly), total = json.encode(total)})
            end
        end)
    end
end

function GMT.AddStat(user_id, stat, value)
    if user_id and stat and value then
        exports["gmt"]:execute("SELECT * FROM gmt_statistics WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local monthly = json.decode(result[1].monthlystats)
                local total = json.decode(result[1].totalstats)
                if monthly[stat] == nil then
                    monthly[stat] = 0
                end
                if total[stat] == nil then
                    total[stat] = 0
                end
                monthly[stat], total[stat] = monthly[stat] + value, total[stat] + value
                exports["gmt"]:execute("UPDATE gmt_statistics SET name = @name, monthlystats = @monthly, totalstats = @total WHERE user_id = @user_id", {user_id = user_id, name = result[1].name, monthly = json.encode(monthly), total = json.encode(total)})
            end
        end)
    end
end

function GMT.GetStat(user_id, stat)
    if user_id and stat then
        local statValue = nil
        exports["gmt"]:execute("SELECT * FROM gmt_statistics WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local total = json.decode(result[1].totalstats)
                statValue = total[stat]
            end
        end)
        return statValue
    end
end

MySQL.createCommand("gmt_stats/adduser","INSERT INTO gmt_statistics (user_id,name,monthlystats,totalstats) VALUES (@user_id,@name,@monthly,@total) ON DUPLICATE KEY UPDATE name = @name, monthlystats = @monthly, totalstats = @total")

RegisterServerEvent("GMT:requestStatistics")
AddEventHandler("GMT:requestStatistics", function()
    local source = source
    TriggerClientEvent("GMTDEATHUI:setStatistics", source, stats.monthly, stats.total,GMT.getUserId(source))
end)

AddEventHandler("GMT:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        tGMT.GetPlayTime(user_id)
        local defaultdata = {name = GMT.getPlayerName(user_id),user_id = user_id,kills = 0,deaths = 0,amount_robbed = 0,jailed_time = 0,playtime = 0,weed_sales = 0,cocaine_sales = 0,meth_sales = 0,heroin_sales = 0,lsd_sales = 0,copper_sales = 0,limestone_sales = 0,gold_sales = 0,diamond_sales = 0,arrests = 0,searches = 0,money_seized = 0,revives = 0,bodybagged = 0,amount_fined = 0}
        MySQL.execute("gmt_stats/adduser",{user_id = user_id,name = GMT.getPlayerName(user_id),monthly = json.encode(defaultdata),total = json.encode(defaultdata)})
    end
end)

RegisterCommand("refreshstats",function(source,args)
    local source = source
    if source == 0 or GMT.getUserId(source) == 1 then
        RefreshStatMenu()
    end
end)

RefreshStatMenu()
MySQL.createCommand("quests/add_id", "INSERT IGNORE INTO gmt_quests SET user_id = @user_id")

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = GMT.getUserId(source)
    exports["gmt"]:executeSync("INSERT IGNORE INTO gmt_quests SET user_id = @user_id", {user_id = user_id})
end)

RegisterServerEvent("GMT:setQuestCompleted")
AddEventHandler("GMT:setQuestCompleted", function()
	local source = source
	local user_id = GMT.getUserId(source)
    local a = exports['gmt']:executeSync("SELECT * FROM gmt_quests WHERE user_id = @user_id", {user_id = user_id})
    for k,v in pairs(a) do
        if v.user_id == user_id then
            if v.quests_completed < 51 and not v.reward_claimed then
                exports['gmt']:execute("UPDATE gmt_quests SET quests_completed = (quests_completed+1) WHERE user_id = @user_id", {user_id = user_id}, function() end)
            else
                GMT.ACBan(15,user_id,"GMT:setQuestCompleted")
            end
        end
    end
end)

RegisterServerEvent("GMT:claimQuestReward")
AddEventHandler("GMT:claimQuestReward", function()
	local source = source
	local user_id = GMT.getUserId(source)
    local a = exports['gmt']:executeSync("SELECT * FROM gmt_quests WHERE user_id = @user_id", {user_id = user_id})
    local plathours = 0
    for k,v in pairs(a) do
        if v.user_id == user_id then
            if not v.reward_claimed and v.quests_completed == 50 then
                -- code to give plat days
                MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
                    plathours = rows[1].plathours
                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = plathours + 168*2})
                    exports['gmt']:execute("UPDATE gmt_quests SET reward_claimed = true WHERE user_id = @user_id", {user_id = user_id}, function() end)
                end)
            else
                GMT.ACBan(15,user_id,"GMT:claimQuestReward")
            end
        end
    end
end)

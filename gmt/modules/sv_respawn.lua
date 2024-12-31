local cfg=module("cfg/cfg_respawn")

RegisterNetEvent("AMB:SendSpawnMenu")
AddEventHandler("AMB:SendSpawnMenu",function()
    local source = source
    local user_id = AMB.getUserId(source)
    local spawnTable={}
    for k,v in pairs(cfg.spawnLocations)do
        if v.permission[1] ~= nil then
            if AMB.hasPermission(AMB.getUserId(source),v.permission[1])then
                table.insert(spawnTable, k)
            end
        else
            table.insert(spawnTable, k)
        end
    end
    exports['amb']:execute("SELECT * FROM `amb_user_homes` WHERE user_id = @user_id", {user_id = user_id}, function(result)
        if result ~= nil then 
            for a,b in pairs(result) do
                table.insert(spawnTable, b.home)
            end
            if AMB.isPurge() then
                TriggerClientEvent("AMB:purgeSpawnClient",source)
            else
                TriggerClientEvent("AMB:OpenSpawnMenu",source,spawnTable)
                AMB.clearInventory(user_id) 
                AMBclient.setPlayerCombatTimer(source, {0})
            end
        end
    end)
end)
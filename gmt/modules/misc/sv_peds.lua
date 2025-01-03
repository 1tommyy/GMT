local cfg=module("cfg/cfg_peds")

AddEventHandler("GMT:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    local user_id = GMT.getUserId(source)
    if first_spawn then
        local pedAccess = {}
        local user_id = GMT.getUserId(source)
        for k,v in pairs(cfg.pedMenus) do
            for i,j in pairs(cfg.peds) do
                if v[1] == i then
                    if j['config'].permissions[1] then
                        if GMT.hasPermission(user_id, j['config'].permissions[1]) then
                            table.insert(pedAccess, {i, v[2]})
                        end
                    else
                        table.insert(pedAccess, {i, v[2]})
                    end
                end
            end
        end
        TriggerClientEvent("GMT:buildPedMenus",source,pedAccess)
    end
end)
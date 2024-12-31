local processing = {request = {},claim = {}}

local function RefreshCompensations(user_id)
    local db = exports["gmt"]:executeSync("SELECT * FROM gmt_compensation WHERE user_id = @user_id",{user_id = user_id})
    local compensations = {}
    if db and #db > 0 then
        for A,B in pairs(db) do
            compensations[B.compid] = {compensator = B.compensator, weapons = json.decode(B.compensationdata)}
        end
    end
    TriggerClientEvent("GMT:ReceiveCompensations",GMT.getUserSource(user_id),compensations)
end


RegisterServerEvent("GMT:RequestCompensations",function()
    local source = source
    local user_id = GMT.getUserId(source)
    if not processing.request[user_id] then
        RefreshCompensations(user_id)
        processing.request[user_id] = nil
    end
end)

RegisterServerEvent("GMT:StartCompensation",function(compensationid)
    local source = source
    local user_id = GMT.getUserId(source)
    if compensationid ~= user_id then
        if GMT.getUserSource(compensationid) then -- online check tayser
            local data = GMT.getUserDataTable(user_id)
            if data and data.inventory then
                local inventory = {}
                for A,B in pairs(data.inventory) do
                    inventory[A] = {amount = B.amount, ItemName = GMT.getItemName(A), Weight = GMT.getItemWeight(A)}
                end
                TriggerClientEvent("GMT:StartCompensation",source,inventory,compensationid)
            else
                print("No data found for user_id: "..user_id)
            end
        else
            GMT.notify(source, "~r~User is not online")
        end
    else
        GMT.notify(source, "~r~You can't compensate yourself")
    end
end)

RegisterServerEvent("GMT:SubmitCompensation",function(compdata,compensationid)
    local source = source
    local user_id = GMT.getUserId(source)
    local compsrc = GMT.getUserSource(compensationid)
    local tbl = {}
    if compsrc then
        for A,B in pairs(compdata.inventory) do
            if compdata.selected[B.ItemName] then
                if GMT.tryGetInventoryItem(user_id,A,B.amount) then
                    tbl[A] = B.amount
                end
            end
        end
        if next(tbl) then
            local inventoryStr = ""
            for A,B in pairs(compdata.inventory) do
                inventoryStr = inventoryStr .. B.ItemName .. " - " .. B.amount .. "x, "
            end
            inventoryStr = inventoryStr:sub(1, -3) 

            local compensatedItemsStr = ""
            for A,B in pairs(tbl) do
                local itemName = compdata.inventory[A].ItemName
                compensatedItemsStr = compensatedItemsStr .. itemName .. " - " .. B .. "x, "
            end
            compensatedItemsStr = compensatedItemsStr:sub(1, -3) 

            exports["gmt"]:execute("INSERT INTO gmt_compensation (user_id,compensator,compensationdata) VALUES (@user_id,@compensator,@compensationdata)",{user_id = compensationid,compensator = user_id,compensationdata = json.encode(tbl)},function()
                GMT.notify(source, "~g~Compensation submitted for ID: " .. compensationid)
                GMT.notify(compsrc, "~g~You have received compensation")
                RefreshCompensations(compensationid)
                GMT.sendDCLog('compensation-request', 'GMT Compensation Request Logs', "> Requester Name: **"..GMT.getPlayerName(user_id).."**\n> Requester TempID: **"..source.."**\n> Requester PermID: **"..user_id.."**\n> Player PermID: **".. compensationid .. "**\n> Player Name **" .. GMT.getPlayerName(compensationid) .. "**\n> Inventory: **"..inventoryStr.."**\n> Compensated Items: **"..compensatedItemsStr.."**")
            end)
        else
            GMT.notify(source, "~r~Unsuccessful compensation.\nIf this is a bug please report it to a staff member.")
        end
    else
        GMT.notify(source, "~r~User is not online")
    end
end)

RegisterServerEvent("GMT:ClaimCompensation",function(compid)
    local source = source
    local user_id = GMT.getUserId(source)
    if not processing.claim[user_id] then
        processing.claim[user_id] = true
        local db = exports["gmt"]:executeSync("SELECT * FROM gmt_compensation WHERE compid = @compid AND user_id = @user_id",{compid = compid,user_id = user_id})[1]
        if db then
            for A,B in pairs(json.decode(db.compensationdata)) do
                GMT.giveInventoryItem(user_id,A,B)
            end
            GMT.notify(source, "~g~Compensation claimed")
        else
            GMT.notify(source, "~r~Compensation not found")
        end
        exports["gmt"]:execute("DELETE FROM gmt_compensation WHERE compid = @compid AND user_id = @user_id",{compid = compid,user_id = user_id},function()
            RefreshCompensations(user_id)
            processing.claim[user_id] = nil
        end)
        processing.claim[user_id] = nil
    end
end)
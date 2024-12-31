local MySQL = {}
local Queries = {}

function MySQL.createCommand(queryname, query)
    if not Queries[queryname] then 
        Queries[queryname] = query
    else 
        print("Attempting to create query: " .. queryname.. " but it already exists!")
    end 
end

function MySQL.execute(queryname, variables)
    if Queries[queryname] then 
        if variables then 
            exports["gmt"]:execute(Queries[queryname], variables)
        else 
            exports["gmt"]:execute(Queries[queryname])
        end 
    else 
        print("Attempting to execute query: " .. queryname.. " but it does not exist!")
    end 
end

function MySQL.asyncQuery(queryname, variables)
    if Queries[queryname] then 
        if variables then 
            local rows = exports["gmt"]:executeSync(Queries[queryname], variables)
            return rows
        end 
    else 
        print("Attempting to execute query: " .. queryname.. " but it does not exist!")
        cb({{},nil})
    end 
end

function MySQL.query(queryname, variables, cb)
    if Queries[queryname] then 
        if variables then 
            exports["gmt"]:execute(Queries[queryname], variables, function(rows, affected)
                if cb then 
                    cb(rows, affected)
                end 
            end)
        end 
    else
        print("Attempting to execute query: " .. queryname.. " but it does not exist!")
        cb({{},nil})
    end 
end

function MySQL.SingleQuery(query)
    exports["gmt"]:execute(query)
end

return MySQL

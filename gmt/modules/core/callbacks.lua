RegisterServerEvent('__GMT_callback:server')
AddEventHandler('__GMT_callback:server', function(eventName, ticket, ...)
	local s = source
	local p = promise.new()

	TriggerEvent('s__GMT_callback:'..eventName, function(...)
		p:resolve({...})
	end, s, ...)

	local result = Citizen.Await(p)
	TriggerClientEvent(('__GMT_callback:client:%s:%s'):format(eventName, ticket), s, table.unpack(result))
end)

GMT.RegisterServerCallback = function(eventName, fn)
    assert(type(eventName) == 'string', 'Invalid Lua type at argument #1, expected string, got '..type(eventName))
    assert(type(fn) == 'function', 'Invalid Lua type at argument #2, expected function, got '..type(fn))

    AddEventHandler(('s__GMT_callback:%s'):format(eventName), function(cb, s, ...)
        local result = {fn(s, ...)}
        cb(table.unpack(result))
    end)
end

GMT.TriggerClientCallback = function(src, eventName, ...)
    assert(type(src) == 'number', 'Invalid Lua type at argument #1, expected number, got '..type(src))
    assert(type(eventName) == 'string', 'Invalid Lua type at argument #2, expected string, got '..type(eventName))

    local p = promise.new()

    RegisterServerEvent('__GMT_callback:server:'..eventName)
    local e = AddEventHandler('__GMT_callback:server:'..eventName, function(...)
        local s = source
        if src == s then
            p:resolve({...})
        end
    end)

    TriggerClientEvent('__GMT_callback:client', src, eventName, ...)
    local result = Citizen.Await(p)
    repeat Wait(0) until result ~= nil
    RemoveEventHandler(e)
    return table.unpack(result)
end
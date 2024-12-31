RegisterServerEvent('GMT:unstuckSuccessful')
AddEventHandler('GMT:unstuckSuccessful', function(d, e)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        GMT.sendDCLog('unstuck-logs', 'Temp ID: **'.. source .. '**\nPerm ID: **' .. GMT.getUserId(source) .. '**\n Coordinates: **' .. e.x .. ', ' .. e.y .. ', ' .. e.z .. '**\n Reason: **' .. e.reason .. '**\n', source)
    end
end)
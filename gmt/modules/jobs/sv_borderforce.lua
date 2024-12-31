local gates = {
    [1] = {open = false},
    [2] = {open = false},
    [3] = {open = false},
    [4] = {open = false}
}

RegisterServerEvent("GMT:setBorderState")
AddEventHandler("GMT:setBorderState", function(gateId, state)
    if gates[gateId] then
        gates[gateId].open = (state == "open")
        TriggerClientEvent("GMT:gotBorderState", -1, gateId, state)
    end
end)

RegisterServerEvent("GMT:getGateStates")
AddEventHandler("GMT:getGateStates", function()
    local src = source
    TriggerClientEvent("GMT:gotFullBorderStates", src, gates)
end)
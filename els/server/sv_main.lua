RegisterNetEvent("GMTELS:changeStage", function(stage)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('GMTELS:changeStage', -1, vehicleNetId, stage)
end)

RegisterNetEvent("GMTELS:toggleSiren", function(tone)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('GMTELS:toggleSiren', -1, vehicleNetId, tone)
end)

RegisterNetEvent("GMTELS:toggleBullhorn", function(enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('GMTELS:toggleBullhorn', -1, vehicleNetId, enabled)
end)

RegisterNetEvent("GMTELS:patternChange", function(patternIndex, enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('GMTELS:patternChange', -1, vehicleNetId, patternIndex, enabled)
end)

RegisterNetEvent("GMTELS:vehicleRemoved", function(stage)
	TriggerClientEvent('GMTELS:vehicleRemoved', -1, stage)
end)

RegisterNetEvent("GMTELS:indicatorChange", function(indicator, enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('GMTELS:indicatorChange', -1, vehicleNetId, indicator, enabled)
end)
RMenu.Add("gmtliverymenu", "main", RageUI.CreateMenu("", "GMT Livery Menu", GMT.getRageUIMenuWidth(),GMT.getRageUIMenuHeight(),"menus","liverymenu"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('gmtliverymenu', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for LiveryCount = 1, GetVehicleLiveryCount(GetVehiclePedIsIn(PlayerPedId(), false)) do
                RageUI.Button("Livery #" .. tostring(LiveryCount) , nil, {RightLabel = "→→→",}, true, function(Hovered, Active, Selected)
                    if Selected then
                        SetVehicleLivery(GetVehiclePedIsIn(PlayerPedId(), false), LiveryCount)   
                    end
                end)
            end
        end) 
    end
end)

RegisterKeyMapping("livery", "Livery Menu", "keyboard", "INSERT")
TriggerEvent("chat:addSuggestion", "/livery", "Open the livery menu")
RegisterCommand("livery", function()
    local i = GMT.getPlayerPed()
    local j = GMT.getPlayerVehicle()
    if IsPedInAnyVehicle(i, false) and GetPedInVehicleSeat(j, -1) == i then
        if GetVehicleLiveryCount(j) > 0 then
            a = j
        RageUI.Visible(RMenu:Get("gmtliverymenu", "main"), true)
        else
            GMT.notify("~r~This vehicle has no liveries")
        end
    end
end, false)
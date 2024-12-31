RegisterCommand("bodybag",function()
    local a = tGMT.getNearestPlayer(3)
    if a then
        TriggerServerEvent("GMT:requestBodyBag", a)
    else
        GMT.notify("No one dead nearby")
    end
end)

RegisterNetEvent("GMT:removeIfOwned",function(b)
    local c = GMT.getObjectId(b, "bodybag_removeIfOwned")
    if c then
        if DoesEntityExist(c) then
            if NetworkHasControlOfEntity(c) then
                DeleteEntity(c)
            end
        end
    end
end)

RegisterNetEvent("GMT:placeBodyBag",function()
    local d = GMT.getPlayerPed()
    local e = GetEntityCoords(d)
    local f = GetEntityHeading(d)
    SetEntityVisible(d, false, 0)
    local g = GMT.loadModel("xm_prop_body_bag")
    local h = CreateObject(g, e.x, e.y, e.z, true, true, true)
    DecorSetInt(h, decor, 955)
    PlaceObjectOnGroundProperly(h)
    SetModelAsNoLongerNeeded(g)
    local b = ObjToNet(h)
    TriggerServerEvent("GMT:removeBodybag", b)
    while GetEntityHealth(GMT.getPlayerPed()) <= 102 do
        Wait(0)
    end
    DeleteEntity(h)
    SetEntityVisible(d, true, 0)
end)

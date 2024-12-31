RMenu.Add(
    "gmttruckmenu",
    "buy-rent",
    RageUI.CreateMenu("GMT Trucking", "~b~GMT Trucking", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight())
)
RMenu.Add(
    "gmttruckmenu",
    "vehicle",
    RageUI.CreateSubMenu(
        RMenu:Get("gmttruckmenu", "buy-rent"),
        "GMT Trucking",
        "~b~GMT Trucking",
        GMT.getRageUIMenuWidth(),
        GMT.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "gmttruckmenu",
    "vehicles",
    RageUI.CreateMenu("Your Trucks", "~b~GMT Trucking", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight())
)
RMenu.Add(
    "gmttruckmenu",
    "rented_trucks",
    RageUI.CreateSubMenu(
        RMenu:Get("gmttruckmenu", "vehicles"),
        "Rented Vehicles",
        "~b~GMT Trucking",
        GMT.getRageUIMenuWidth(),
        GMT.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "gmttruckmenu",
    "owned_trucks",
    RageUI.CreateSubMenu(
        RMenu:Get("gmttruckmenu", "vehicles"),
        "Owned Vehicles",
        "~b~GMT Trucking",
        GMT.getRageUIMenuWidth(),
        GMT.getRageUIMenuHeight()
    )
)
local a = module("cfg/cfg_trucking")
local b = a.trucks
local c = {}
local d = {}
local e
local f = ""
local g
local h
local i = false
local j = false
local k = 10.0
local rentedTrucks = {}
globalOnTruckJob = false
RageUI.CreateWhile(1.0, true, function() -- Renting trucks tbd
    if RageUI.Visible(RMenu:Get('gmttruckmenu', 'buy-rent')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for l, m in pairs(b) do
                if not m.custom then
                    local n
                    if rentedTrucks[l] then
                        n = {RightBadge = RageUI.BadgeStyle.Tick}
                    else
                        n = {RightLabel = "£" .. getMoneyStringFormatted(m.price)}
                    end
                    RageUI.Button(m.name,"Press to spawn.",n,true,function(o, p, q)
                        if q then
                            if rentedTrucks[l] then
                                trySpawnVehicle(l)
                            else
                                tryRental(l, m.price)
                                rentedTrucks[l] = true
                            end
                        end
                    end)
                end
            end
        end)
    end
end)
RegisterNetEvent("GMT:updateOwnedTrucks")
AddEventHandler("GMT:updateOwnedTrucks", function(rentedTrucks)
    d["owned"] = b
    d["rented"] = rentedTrucks
end)
RegisterNetEvent("GMT:setTruckerOnDuty",function(s)
    globalOnTruckJob = s
end)
function tryRental(t, u)
    TriggerServerEvent("GMT:rentTruck", t, u)
    TriggerServerEvent('GMT:getRentedTrucks')
end
function getVehicleName(v)
    for l, m in pairs(b) do
        if GetHashKey(l) == v then
            return l
        end
    end
    return nil
end
Citizen.CreateThread(function()
    for w = 1, #a.buylocations do
        local x = a.buylocations[w]
        local y = x.main
        GMT.add3DTextForCoord("Truck Rental", y.x, y.y, y.z, 8.0)
        GMT.add3DTextForCoord("Truck Dealership", 895.98162841797,-3186.9907226562, y.z, 8.0)
        tGMT.addMarker(y.x, y.y, y.z, 0.7, 0.7, 0.5, 0, 255, 125, 125, 50, 29, true, true)
        tGMT.addBlip(y.x, y.y, y.z, 67, 5, "Truck Rental")
        tGMT.addBlip(895.98162841797,-3186.9907226562, y.z, 67, 5, "Truck Dealership")
    end
end)
AddEventHandler("GMT:onClientSpawn",function(z, A)
    if A then
        TriggerServerEvent('GMT:getRentedTrucks')
        local B = function(C)
            if not IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) ~= e then
                i = true
                RageUI.ActuallyCloseAll()
                RageUI.Visible(RMenu:Get('gmttruckmenu','buy-rent'),true)
            end
        end
        local D = function()
            i = false
            RageUI.ActuallyCloseAll()
        end
        local E = function()
        end
        for w = 1, #a.buylocations do
            local x = a.buylocations[w]
            local y = x.main
            GMT.createArea("trucking_buy_" .. w, x.main, 1.15, 6, B, D, E, {})
        end
    end
end)
function trySpawnVehicle(F)
    TriggerServerEvent("GMT:spawnTruck", F)
end
RegisterNetEvent("GMT:spawnTruckCl",function(F)
    local ped = PlayerPedId()
    local y = GetEntityCoords(ped)
    local G = GMT.spawnVehicle(F, y.x, y.y, y.z, GetEntityHeading(ped), true, true, true)
end)
function getAllTrucks()
    TriggerServerEvent("GMT:truckerJobBuyAllTrucks")
end

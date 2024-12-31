local a = nil
local b = module("cfg/cfg_trader")
globalWeedCommissionPercent = 0
globalCocaineCommissionPercent = 0
globalMethCommissionPercent = 0
globalHeroinCommissionPercent = 0
globalLargeArmsCommission = 0
globalLSDNorthCommissionPercent = 0
globalLSDSouthCommissionPercent = 0
local c = {
    ["Weed"] = 0,
    ["Cocaine"] = 0,
    ["Meth"] = 0,
    ["Heroin"] = 0,
    ["LSDNorth"] = 0,
    ["LSDSouth"] = 0,
    ["Copper"] = 0,
    ["Limestone"] = 0,
    ["Gold"] = 0,
    ["Diamond"] = 0
}
RegisterNetEvent("GMT:updateTraderCommissions",function(d, e, f, g, h, i, j)
    globalWeedCommissionPercent = d
    globalCocaineCommissionPercent = e
    globalMethCommissionPercent = f
    globalHeroinCommissionPercent = g
    globalLargeArmsCommission = h
    globalLSDNorthCommissionPercent = i
    globalLSDSouthCommissionPercent = j
end)
Citizen.CreateThread(function()
    local k = GMT.loadAnimDict("mini@strip_club@idles@bouncer@base")
    for l, m in pairs(b.trader) do
        tGMT.addMarker(m.position.x,m.position.y,m.position.z,0.7,0.7,0.5,m.colour.r,m.colour.g,m.colour.b,125,50,29,true,true)
        tGMT.createDynamicPed(m.dealerModel,m.dealerPos + vector3(0.0, 0.0, -1.0),m.dealerHeading,true,"mini@strip_club@idles@bouncer@base","base",100,false)
    end
    tGMT.createDynamicPed("s_m_y_dealer_01", vector3(-1680.3316650391,490.78375244141,128.4), 204.09449768066, true, "mini@strip_club@idles@bouncer@base", "base", 100, false)
end)

RMenu.Add("trader","seller",RageUI.CreateMenu("","Sell your goods!",GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "menus", "trader"))
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('trader', 'seller')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if a == "Legal" then
                RageUI.ButtonWithStyle("Sell Copper","£" .. getMoneyStringFormatted(c["Copper"]),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellCopper")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
                RageUI.ButtonWithStyle("Sell Limestone","£" .. getMoneyStringFormatted(c["Limestone"]),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellLimestone")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
                RageUI.ButtonWithStyle("Sell Gold","£" .. getMoneyStringFormatted(c["Gold"]),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellGold")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
                RageUI.ButtonWithStyle("Sell Diamond","£" .. getMoneyStringFormatted(c["Diamond"]),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellDiamond")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,
                RMenu:Get("trader", "seller"))
                RageUI.ButtonWithStyle("Sell All","",{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellAll")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,
                RMenu:Get("trader", "seller"))
            elseif a == "Weed" then
                RageUI.ButtonWithStyle("Sell Weed","£" .. getMoneyStringFormatted(c["Weed"] or 0),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellWeed")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
            elseif a == "Cocaine" then
                RageUI.ButtonWithStyle("Sell Cocaine","£" .. getMoneyStringFormatted(c["Cocaine"] or 0),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellCocaine")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
            elseif a == "Meth" then
                RageUI.ButtonWithStyle("Sell Meth","£" .. getMoneyStringFormatted(c["Meth"] or 0),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellMeth")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
            elseif a == "Heroin" then
                RageUI.ButtonWithStyle("Sell Heroin","£" .. getMoneyStringFormatted(c["Heroin"] or 0),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellHeroin")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
            elseif a == "LSDNorth" then
                RageUI.ButtonWithStyle("Sell LSD","£" .. getMoneyStringFormatted(c["LSDNorth"] or 0),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellLSDNorth")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
            elseif a == "LSDSouth" then
                RageUI.ButtonWithStyle("Sell LSD","£" .. getMoneyStringFormatted(c["LSDSouth"] or 0),{RightLabel = "→→→"},true,function(m, n, o)
                    if o then
                        if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
                            TriggerServerEvent("GMT:sellLSDSouth")
                        else
                            GMT.notify("Exit your vehicle.")
                        end
                    end
                end,RMenu:Get("trader", "seller"))
            end
        end)
    end
end)


AddEventHandler("GMT:onClientSpawn",function(p, q)
    if q then
        local r = function(s)
        end
        local t = function(s)
            RageUI.Visible(RMenu:Get("trader", "seller"), false)
            RageUI.ActuallyCloseAll()
        end
        local u = function(s)
            if IsControlJustPressed(1, 38) then
                a = s.traderName
                RageUI.Visible(RMenu:Get("trader", "seller"), not RageUI.Visible(RMenu:Get("trader", "seller")))
            end
            local v, w, x = table.unpack(GetFinalRenderedCamCoord())
            DrawText3D(b.trader[s.traderId].position.x,b.trader[s.traderId].position.y,b.trader[s.traderId].position.z,"Press [E] to open seller",v,w,x)
        end
        for y, l in pairs(b.trader) do
            GMT.createArea("trader_" .. y, l.position, 1.5, 6, r, t, u, {traderId = y, traderName = l.type})
        end
    end
end)

RegisterNetEvent("GMT:updateTraderPrices",function(z, A, B, C, i, j, D, E, F, G)
    c["Weed"] = z or 0
    c["Cocaine"] = A or 0
    c["Meth"] = B or 0
    c["Heroin"] = C or 0
    c["LSDNorth"] = i or 0
    c["LSDSouth"] = j or 0
    c["Copper"] = D or 0
    c["Limestone"] = E or 0
    c["Gold"] = F or 0
    c["Diamond"] = G or 0
end)

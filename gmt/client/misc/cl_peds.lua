RMenu.Add('gmtpedsmenu','main',RageUI.CreateMenu("GMT Peds", "GMT Peds Menu - ~o~[TAB] Search peds", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight()))
local a=module("cfg/cfg_peds")
local b = a.pedMenus
local c = {}
local d = nil
local e = nil
local f = true
local g
local h = false
local j = {}
local k = {}
local l = 0
local tt= ''
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('gmtpedsmenu', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if IsControlJustPressed(0, 37) then
                tGMT.clientPrompt("Search for: ","",function(c)
                    tt = string.lower(c)
                end)
            end
            if d or e and tGMT.getCustomization() ~= d then
                RageUI.Button("Reset",nil,{},true,function(m, n, o)
                    if o then
                        revertPedChange()
                    end
                end)
            end
            for i = 1, #c, 1 do
                if tt == "" or string.find(string.lower(c[i][2]), tt) then
                    RageUI.Button(c[i][2],nil,{},true,function(m, n, o)
                        if o then
                            if GetEntityHealth(GMT.getPlayerPed()) > 102 then
                                spawnPed(c[i][1])
                            else
                                GMT.notify("You try to change ped, but then remember you are dead.")
                            end
                        end
                    end)
                end
            end
        end)
    end
end)

function showPedsMenu(p)
    RageUI.Visible(RMenu:Get("gmtpedsmenu", "main"), p)
end
function spawnPed(q)
    local r = GMT.getPlayerPed()
    local s = GetEntityHeading(r)
    tGMT.setCustomization({model = q})
    SetEntityHeading(GMT.getPlayerPed(), s)
    Wait(100)
    SetEntityMaxHealth(GMT.getPlayerPed(), 200)
    SetEntityHealth(GMT.getPlayerPed(), 200)
end
function revertPedChange()
    tGMT.setCustomization(d)
end
RegisterNetEvent("GMT:buildPedMenus",function(t)
    for i = 1, #j do
        tGMT.removeArea(j[i])
        j[i] = nil
    end
    for i = 1, #k do
        tGMT.removeMarker(k[i])
    end
    local u = function(v)
    end
    local w = function(x)
        c = a.peds[x.menu_id]
        g = i
        if f then
            d = tGMT.getCustomization()
            l = GetEntityHealth(GMT.getPlayerPed())
        end
        h = true
        showPedsMenu(true)
        f = false
    end
    local y = function(v)
        showPedsMenu(false)
        f = true
        h = false
        SetEntityHealth(GMT.getPlayerPed(), l)
    end
    for i = 1, #t do
        local z = t[i]
        local A = z[1]
        local B = string.format("pedmenu_%s_%s", A, i)
        GMT.createArea(B, z[2], 1.25, 6, w, y, u, {menu_id = A})
        local C = tGMT.addMarker(z[2].x, z[2].y, z[2].z - 1, 0.7, 0.7, 0.5, 0, 255, 125, 125, 50, 27, false, false)
        j[#j + 1] = B
        k[#k + 1] = C
    end
end)
function getPedMenuId(string)
    return stringsplit(string, "_")[2]
end
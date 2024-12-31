local weapons = module("cfg/weapons")
local a=false
local b
local c
local d={name="",price="",model="",priceString="",ammoPrice="",weaponShop=""}
local e
local f
local g=""
local h=false
local i = {
    ["Legion"] = {
        _config = {
            {vector3(22.76,-1105.53,29.80)},
            110,1,"Legion Gun Store",{""},true
        }
    },
    ["SmallArmsDealer"] = {
        _config = {
            {vector3(2437.5708007813, 4966.5610351563, 41.34761428833),
            vector3(-1500.4978027344, -216.72758483887, 46.889373779297),
            vector3(1243.0490722656, -427.33932495117, 67.918403625488)},
            110,1,"Small Arms Dealer",{""},true
        }
    },
    ["LargeArmsDealer"] = {
        _config = {
            {vector3(-1111.4790039062,4937.29296875,218.38996887207),
            vector3(5065.6201171875, -4591.3857421875, 1.8652405738831)},
            110,1,"Large Arms Dealer",{"gang.whitelisted"},false
        }
    },
    ["VIP"] = {
        _config = {
            {vector3(-2152.08,5191.95,15.72)},
            110,1,"VIP Gun Store",{"vip.gunstore"},true
        }
    },
    ["Rebel"] = {
        _config = {
            {vector3(1545.2521972656, 6331.5615234375, 23.07857131958),
            vector3(4925.6259765625, -5243.0908203125, 1.524599313736)},
            110,1,"Rebel Gun Store",{"rebellicense.whitelisted"},true
        }
    },
    ["nhsSmallArms"] = {
        _config = {
            {vector3(304.52716064453,-600.37548828125,42.284084320068)},
            110,1,"NHS Combat Medic Small Arms",{"nhs.combatmedic"},false,true
        }
    },
    ["policeSmallArms"] = {
        _config = {
            {vector3(461.53082275391, -979.35876464844, 29.689668655396),
            vector3(1842.9096679688, 3690.7692871094, 33.267082214355),
            vector3(-448.93994140625, 6015.4150390625, 30.7363982391),
            vector3(638.55255126953, 2.7499871253967, 43.423725128174),
            vector3(-1104.5264892578, -821.70153808594, 13.282785415649)},
            110,1,"MET Police Small Arms",{"police.armoury"},false,true
        }
    },
    ["policeLargeArms"] = {
        _config = {
            {vector3(1840.6104736328, 3691.4741210938, 33.350730895996),
            vector3(461.43179321289, -982.66412353516, 29.689668655396),
            vector3(-449.9557800293, 6016.5454101563, 30.7363982391),
            vector3(640.8759765625, -0.63530212640762, 43.423385620117),
            vector3(-1102.5059814453, -820.62091064453, 13.282785415649)},
            110,1,"MET Police Large Arms",{"police.loadshop2", "police.armoury"},false,true
        }
    },
    ["prisonArmoury"] = {
        _config = {
            {vector3(1779.3741455078, 2542.5639648438, 45.797782897949)},
            110,1,"Prison Armoury",{"hmp.menu"},false,true
        }
    },
    ["ukbfArmoury"] = {
        _config = {
            {vector3(3084.5432128906,-3730.2951660156,52.557)},
            110,1,"UK Border Force Armoury",{"ukbf.armoury"},false,true
        }
    },
}
RMenu.Add("GMTGunstore","mainmenu",RageUI.CreateMenu("","",GMT.getRageUIMenuWidth(),GMT.getRageUIMenuHeight(),"menus","gunstore"))
RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Gunstore")
RMenu.Add("GMTGunstore","type",RageUI.CreateSubMenu(RMenu:Get("GMTGunstore","mainmenu"),"","~s~P~w~urchase Weapon or Ammo",GMT.getRageUIMenuWidth(),GMT.getRageUIMenuHeight(),"menus","gunstore"))
RMenu.Add("GMTGunstore","vip",RageUI.CreateSubMenu(RMenu:Get("GMTGunstore","mainmenu"),"","~s~P~w~urchase Weapon or Ammo",GMT.getRageUIMenuWidth(),GMT.getRageUIMenuHeight(),"menus","gunstore"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("GMTGunstore", "mainmenu")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            h=false
        if b~=nil and i~=nil then 
            if tGMT.isPlatClub() then 
                if b=="VIP"then 
                    RageUI.ButtonWithStyle("~y~[Platinum Large Arms]","",{RightLabel="→→→"},true,function(j,k,l)
                    end,RMenu:Get("GMTGunstore","vip"))
                end 
            end
            for m,n in pairs(i)do 
                if b==m then 
                    for o,p in pairs(sortedKeys(n))do 
                        local q=n[p]
                        if p~="_config"then 
                            local r,s,t=table.unpack(q)
                            local x=false
                            local y
                            if p=="item|fillUpArmour"then 
                                local z=GetPedArmour(GMT.getPlayerPed())
                                local A=100-z
                                y=A*1000
                                x=true 
                            end
                            local B=""
                            if x then 
                                B=tostring(getMoneyStringFormatted(y))
                            else 
                                B=tostring(getMoneyStringFormatted(s))
                            end
                            RageUI.ButtonWithStyle(r,"£"..B,{RightLabel="→→→"},true,function(j,k,l)
                                if k then 
                                    e=p 
                                end
                                if l then 
                                    d.name=r
                                    d.price=s
                                    d.model=p
                                    d.priceString=B
                                    d.ammoPrice=t
                                    d.weaponShop=m 
                                end 
                            end,RMenu:Get("GMTGunstore","type"))
                        end 
                    end 
                end 
            end 
        end 
        end) 
    end
    if RageUI.Visible(RMenu:Get("GMTGunstore", "type")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true }, function()
            RageUI.ButtonWithStyle("Purchase Weapon Body", "£"..getMoneyStringFormatted(d.price), { RightLabel = "→→→" }, true, function(j, k, Selected)
                if Selected then
                    if string.sub(d.model, 1, 4) == "item" then
                        TriggerServerEvent("GMT:buyWeapon", d.model, d.price, d.name, d.weaponShop, "armour")
                    else
                        TriggerServerEvent("GMT:buyWeapon", d.model, d.price, d.name, d.weaponShop, "weapon", h)
                    end
                end
            end)
            
            if weapons.weapons[d.model] and (weapons.weapons[d.model].ammo ~= "modelammo" and weapons.weapons[d.model].ammo ~= "") then
                RageUI.ButtonWithStyle("Purchase Weapon Ammo (Max)", "£"..getMoneyStringFormatted(math.floor(d.price/2)), { RightLabel = "→→→" }, true, function(j, k, l)
                    if l then
                        if HasPedGotWeapon(GMT.getPlayerPed(), GetHashKey(d.model), false) then
                            TriggerServerEvent("GMT:buyWeapon", d.model, d.price, d.name, d.weaponShop, "ammo")
                        else
                            GMT.notify("~r~You do not have the body of this weapon to purchase ammo.")
                        end
                    end
                end)
            end
        end)
    end
    
     
    if RageUI.Visible(RMenu:Get("GMTGunstore", "vip")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            local C=i["LargeArmsDealer"]
            for o,p in pairs(sortedKeys(C))do 
                h=true
                local q=C[p]
                if p~="_config"then 
                    local r,s,t=table.unpack(q)
                    local x=false
                    local y
                    if p=="item|fillUpArmour"then 
                        local z=GetPedArmour(GMT.getPlayerPed())
                        local A=100-z
                        y=A*1000
                        x=true 
                    end
                    local B=""
                    if x then 
                        B=tostring(getMoneyStringFormatted(y))
                    else 
                        B=tostring(getMoneyStringFormatted(s))
                    end
                    RageUI.ButtonWithStyle(r,"£"..B,{RightLabel="→→→"},true,function(j,k,l)
                        if j then 
                        end
                        if k then 
                            e=p 
                        end
                        if l then 
                            d.name=r
                            d.priceString=B
                            d.model=p
                            d.price=s
                            d.ammoPrice=t
                            d.weaponShop="LargeArmsDealer"
                        end 
                    end,RMenu:Get("GMTGunstore","type"))
                end 
            end 
        end) 
    end
end)

RegisterNetEvent("GMT:refreshGunStorePermissions",function()
    TriggerServerEvent("GMT:requestNewGunshopData")
end)
local G = false
RegisterNetEvent("GMT:recieveFilteredGunStoreData")
AddEventHandler("GMT:recieveFilteredGunStoreData",function(F)
    i=F 
    for k,v in pairs(F) do
        if v["WEAPON_MP5TAZER"] then
            G = true
        end
    end
end)
RegisterNetEvent("GMT:recalculateLargeArms")
AddEventHandler("GMT:recalculateLargeArms",function(G)
    for m,n in pairs(i)do 
        if m=="LargeArmsDealer"then 
            for r,H in pairs(n)do
                if r ~="_config"then 
                    local I=i[m][r][7]
                    if I then
                        i[m][r][2]=I*(1+G/100)
                    end
                end     
            end 
        end 
    end 
end)
local function J(m,K)
    b=m
    c=K
    if m=="Rebel"then 
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "rebel")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Rebel Gunstore")
    elseif m=="Legion" then 
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "knife")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Legion Gun Store")
    elseif m=="SmallArmsDealer" then 
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "smallarms")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Small Arms Dealer")
    elseif m=="LargeArmsDealer" then
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "large")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Large Arms Dealer")
    elseif m=="VIP" then
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "vip")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT VIP Gunstore")
    elseif m=="policeSmallArms" then 
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "pd")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Police Armoury")
    elseif m=="nhsSmallArms" then 
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "nhs")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT NHS Armoury")
    elseif m=="policeLargeArms" then 
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "pd")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Police Armoury")
    elseif m=="ukbfArmoury" then 
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus", "gunstore")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT UK Border Force Armoury")
    else
        RMenu:Get('GMTGunstore','mainmenu'):SetSpriteBanner("menus","gunstore")
        RMenu:Get("GMTGunstore","mainmenu"):SetSubtitle("GMT Gunstore")
    end
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get('GMTGunstore','mainmenu'),true)
end
local function L(m)
    b=nil
    c=nil
    e=nil
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get('GMTGunstore','mainmenu'),false)
end
Citizen.CreateThread(function()
    while true do 
        if e and f ~= e then 
            f = e
            for m, n in pairs(i) do
                local H = n[f]
                if H then 
                    local v = H[5]
                    if v and c then 
                        if n._config and n._config[1] and n._config[1][c] then
                            local M = n._config[1][c]
                            if h then 
                                M = vector3(-2151.5739746094, 5191.2548828125, 14.718822479248)
                            end
                            local N = GMT.loadModel(v)
                            if M then
                                local O = CreateObject(N, M.x, M.y, M.z + 1, false, false, false)
                                while f == e and DoesEntityExist(O) do 
                                    SetEntityHeading(O, GetEntityHeading(O) + 1 % 360)
                                    Wait(0)
                                end
                                DeleteEntity(O)
                            end
                            SetModelAsNoLongerNeeded(N)
                        end
                    end
                end
            end
        end
        local R = PlayerPedId()
        if not G and GetSelectedPedWeapon(R) == `WEAPON_MP5TAZER` then
            GMT.setWeapon(R, "WEAPON_UNARMED", true)
        end
        Wait(0)
    end 
end)
AddEventHandler("GMT:onClientSpawn",function(D, E)
    print("E",E)
    if E then
        TriggerServerEvent("GMT:requestNewGunshopData")
        for m,n in pairs(i)do 
            local P,Q,R,S,u,T=table.unpack(n["_config"])
            for K,U in pairs(P)do 
                if T then 
                    tGMT.addBlip(U.x,U.y,U.z,Q,R,S)
                end
                tGMT.addMarker(U.x,U.y,U.z,1.0,1.0,1.0,255,0,0,170,50,27)
                local V=function()
                    if GetVehiclePedIsIn(GMT.getPlayerPed(),false)==0 then 
                        J(m,K)
                    else 
                        GMT.notify("~r~Exit your vehicle to access the gun store.")
                    end 
                end
                local W=function()
                    L(m)
                end
                local X=function()
                end
                GMT.createArea("gunstore_"..m.."_"..K,U,1.5,6,V,W,X,{})
            end 
        end 
    end
end)

local Y={}
function tGMT.createGunStore(Z,_,a0)
    local V=function()
        if GetVehiclePedIsIn(GMT.getPlayerPed(),false)==0 then 
            J(_)
        else 
            GMT.notify("~r~Exit your vehicle to access the gun store.")
        end 
    end
    local W=function()
        L(_)
    end
    local a1=string.format("gunstore_%s_%s",_,Z)
    GMT.createArea(a1,a0,1.5,6,V,W,function()
    end)
    local a2=tGMT.addMarker(a0.x,a0.y,a0.z,1.0,1.0,1.0,255,0,0,170,50,27)
    Y[Z]={area=a1,marker=a2}
end
function tGMT.deleteGunStore(Z)
    local a3=Y[Z]
    if a3 then 
        tGMT.removeMarker(a3.marker)
        tGMT.removeArea(a3.area)
        Y[Z]=nil 
    end 
end
local permID = nil
RMenu.Add(
    "vipclubmenu",
    "mainmenu",
    RageUI.CreateMenu("", "~s~GMT Club", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "menus", "vip")
)
RMenu.Add(
    "vipclubmenu",
    "managesubscription",
    RageUI.CreateSubMenu(
        RMenu:Get("vipclubmenu", "mainmenu"),
        "",
        "~b~GMT Club",
        GMT.getRageUIMenuWidth(),
        GMT.getRageUIMenuHeight(),
        "menus",
        "vip"
    )
)
RMenu.Add(
    "vipclubmenu",
    "manageperks",
    RageUI.CreateSubMenu(
        RMenu:Get("vipclubmenu", "mainmenu"),
        "",
        "~b~GMT Club Perks",
        GMT.getRageUIMenuWidth(),
        GMT.getRageUIMenuHeight(),
        "menus",
        "vip"
    )
)
RMenu.Add(
    "vipclubmenu",
    "deathsounds",
    RageUI.CreateSubMenu(
        RMenu:Get("vipclubmenu", "manageperks"),
        "",
        "~b~Manage Death Sounds",
        GMT.getRageUIMenuWidth(),
        GMT.getRageUIMenuHeight(),
        "menus",
        "vip"
    )
)
RMenu.Add('vipclubmenu','manageusersubscription',RageUI.CreateSubMenu(RMenu:Get('vipclubmenu','mainmenu'),"","~s~GMT Club Manage",GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus", "vip"))
RMenu.Add(
    "vipclubmenu",
    "vehicleextras",
    RageUI.CreateSubMenu(
        RMenu:Get("vipclubmenu", "manageperks"),
        "",
        "~b~Vehicle Extras",
        GMT.getRageUIMenuWidth(),
        GMT.getRageUIMenuHeight(),
        "menus",
        "vip"
    )
)
local a = {hoursOfPlus = 0, hoursOfPlatinum = 0}
local zz = {}
function tGMT.isPlusClub()
    if a.hoursOfPlus > 0 then
        return true
    else
        return false
    end
end
function tGMT.isPlatClub()
    if a.hoursOfPlatinum > 0 then
        return true
    else
        return false
    end
end
RegisterCommand(
    "gmtclub",
    function()
        TriggerServerEvent("GMT:getPlayerSubscription")
        RageUI.CloseAll()
        RageUI.Visible(RMenu:Get("vipclubmenu", "mainmenu"), not RageUI.Visible(RMenu:Get("vipclubmenu", "mainmenu")))
    end
)
local b = {
    ["GMT"] = {checked = true, soundId = "playDead"},
    ["Fortnite"] = {checked = false, soundId = "fortnite_death"},
    ["Roblox"] = {checked = false, soundId = "roblox_death"},
    ["Minecraft"] = {checked = false, soundId = "minecraft_death"},
    ["Pac-Man"] = {checked = false, soundId = "pacman_death"},
    ["Mario"] = {checked = false, soundId = "mario_death"},
    ["CS:GO"] = {checked = false, soundId = "csgo_death"}
}
local c = false
local d = false
local e = false
local f = false
local g = {"Red", "Blue", "Green", "Pink", "Yellow", "Orange", "Purple"}
local h = tonumber(GetResourceKvpString("gmt_damageindicatorcolour")) or 1
local gD = {"Red", "Blue", "Green", "Pink", "Yellow", "Orange", "Purple"}
local hD = tonumber(GetResourceKvpString("gmt_bullettracercolour")) or 1
local i = {"Discord", "Steam", "Custom", "None"}
local j = {"Smallest", "Small"}
local k = {32, 40, 48, 56}
local l = tonumber(GetResourceKvpString("gmt_pfp_size")) or 1
local m = tonumber(GetResourceKvpString("gmt_pfp_type")) or 1
Citizen.CreateThread(
    function()
        local n = GetResourceKvpString("gmt_codhitmarkersounds") or "false"
        if n == "false" then
            c = false
            TriggerEvent("GMT:codHMSoundsOff")
        else
            c = true
            TriggerEvent("GMT:codHMSoundsOn")
        end
        local o = GetResourceKvpString("gmt_killlistsetting") or "false"
        if o == "false" then
            d = false
        else
            d = true
        end
        local p = GetResourceKvpString("gmt_oldkillfeed") or "false"
        if p == "false" then
            e = false
        else
            e = true
        end
        local t = GetResourceKvpString("gmt_bullettracers") or "false"
        if t== "false" then
            eE = false
        else
            eE = true
        end
        local q = GetResourceKvpString("gmt_damageindicator") or "false"
        if q == "false" then
            f = false
        else
            f = true
        end
        Wait(5000)
       tGMT.updatePFPType(i[m]) 
       tGMT.updatePFPSize(k[l]) -- delete
    end
)
AddEventHandler(
    "GMT:onClientSpawn",
    function(n, o)
        if o then
            TriggerServerEvent("GMT:getPlayerSubscription")
            Wait(5000)
            local q = GMT.getDeathSound()
            local r = "playDead"
            for s, t in pairs(b) do
                if t.soundId == q then
                    r = s
                end
            end
            for s, u in pairs(b) do
                if r ~= s then
                    u.checked = false
                else
                    u.checked = true
                end
            end
        end
    end
)
function GMT.setDeathSound(q)
    if tGMT.isPlusClub() or tGMT.isPlatClub() then
        SetResourceKvp("gmt_deathsound", q)
    else
        GMT.notify("~r~Cannot change deathsound, not a valid GMT Plus or Platinum subscriber.")
    end
end
function GMT.getDeathSound()
    if tGMT.isPlusClub() or tGMT.isPlatClub() then
        local s = GetResourceKvpString("gmt_deathsound")
        if type(s) == "string" and s ~= "" then
            return s
        else
            return "playDead"
        end
    else
        return "playDead"
    end
end
function GMT.getDmgIndcator()
    return f, h
end
local function o(r)
    SendNUIMessage({transactionType = r})
end
local function v(r)
    SendNUIMessage({transactionType = r})
end
RageUI.CreateWhile(
    1.0,
    RMenu:Get("vipclubmenu", "mainmenu"),
    function()
        RageUI.IsVisible(
            RMenu:Get("vipclubmenu", "mainmenu"),
            true,
            true,
            true,
            function()
                if tGMT.isPlusClub() or tGMT.isPlatClub() then
                    RageUI.ButtonWithStyle(
                        "Manage Subscription",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(v, w, x)
                        end,
                        RMenu:Get("vipclubmenu", "managesubscription")
                    )
                    RageUI.ButtonWithStyle(
                        "Manage Perks",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(v, w, x)
                        end,
                        RMenu:Get("vipclubmenu", "manageperks")
                    )
                else
                    RageUI.ButtonWithStyle(
                        "Purchase Subscription",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(v, w, x)
                            if x then
                                tGMT.OpenUrl("https://store.gmtstudios.uk/category/subscriptions")
                            end
                        end
                    )
                end
                if GMT.isDev() or GMT.getStaffLevel() >= 10 then
                    RageUI.ButtonWithStyle("Manage User's Subscription","",{RightLabel="→→→"},true,function(o,p,q)
                    end,RMenu:Get("vipclubmenu","manageusersubscription"))
                end
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("vipclubmenu", "managesubscription"),
            true,
            true,
            true,
            function()
                colourCode = getColourCode(a.hoursOfPlus)
                RageUI.Separator(
                    "Days remaining of Plus Subscription: " ..
                        colourCode .. math.floor(a.hoursOfPlus / 24 * 100) / 100 .. " days."
                )
                colourCode = getColourCode(a.hoursOfPlatinum)
                RageUI.Separator(
                    "Days remaining of Platinum Subscription: " ..
                        colourCode .. math.floor(a.hoursOfPlatinum / 24 * 100) / 100 .. " days."
                )
                RageUI.Separator()
                RageUI.ButtonWithStyle(
                    "Sell Plus Subscription days.",
                    "~r~If you have already claimed your weekly kit, you may not sell days until the week is over.",
                    {RightLabel = "→→→"},
                    true,
                    function(v, w, x)
                        if x then
                            if isInGreenzone then
                                TriggerServerEvent("GMT:beginSellSubscriptionToPlayer", "Plus")
                            else
                                notify("~r~You must be in a greenzone to sell.")
                            end
                        end
                    end
                )
                RageUI.ButtonWithStyle(
                    "Sell Platinum Subscription days.",
                    "~r~If you have already claimed your weekly kit, you may not sell days until the week is over.",
                    {RightLabel = "→→→"},
                    true,
                    function(v, w, x)
                        if x then
                            if isInGreenzone then
                                TriggerServerEvent("GMT:beginSellSubscriptionToPlayer", "Platinum")
                            else
                                notify("~r~You must be in a greenzone to sell.")
                            end
                        end
                    end
                )
            end,
            function()
            end
        )
        if RageUI.Visible(RMenu:Get('vipclubmenu', 'manageusersubscription')) then
            RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
                if GMT.isDev() then
                    if next(zz) then
                        RageUI.Separator('Perm ID: '..zz.userid)
                        colourCode = getColourCode(zz.hoursOfPlus)
                        RageUI.Separator('Days of Plus Remaining: '..colourCode..math.floor(zz.hoursOfPlus/24*100)/100)
                        colourCode = getColourCode(zz.hoursOfPlatinum)
                        RageUI.Separator('Days of Platinum Remaining: '..colourCode..math.floor(zz.hoursOfPlatinum/24*100)/100)
                        RageUI.ButtonWithStyle("Set Plus Days","",{RightLabel="→→→"},true,function(v, w, x)
                            if x then
                                TriggerServerEvent("GMT:setPlayerSubscription", zz.userid, "Plus")
                            end
                        end)
                        RageUI.ButtonWithStyle("Set Platinum Days","",{RightLabel="→→→"},true,function(v, w, x)
                            if x then
                                TriggerServerEvent("GMT:setPlayerSubscription", zz.userid, "Platinum")
                            end
                        end)    
                    else
                        RageUI.Separator('Please select a Perm ID')
                    end
                    RageUI.ButtonWithStyle("Select Perm ID", nil, { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                        if Selected then
                            tGMT.clientPrompt("Enter Perm ID", "", function(str)
                                permID = str
                                if permID and permID ~= '' then
                                    permID = tonumber(permID)
                                    TriggerServerEvent('GMT:getPlayerSubscription', permID)
                                else
                                    GMT.notify('Invalid Perm ID')
                                end
                            end)
                        end
                    end, RMenu:Get("vipclubmenu", 'manageusersubscription'))
                end
            end)
        end
        RageUI.IsVisible(
            RMenu:Get("vipclubmenu", "manageperks"),
            true,
            true,
            true,
            function()
                RageUI.ButtonWithStyle(
                    "Custom Death Sounds",
                    "",
                    {RightLabel = "→→→"},
                    true,
                    function(v, w, x)
                    end,
                    RMenu:Get("vipclubmenu", "deathsounds")
                )
                RageUI.ButtonWithStyle(
                    "Vehicle Extras",
                    "",
                    {RightLabel = "→→→"},
                    true,
                    function(v, w, x)
                    end,
                    RMenu:Get("vipclubmenu", "vehicleextras")
                )
                RageUI.ButtonWithStyle(
                    "Claim Weekly Kit",
                    "",
                    {RightLabel = "→→→"},
                    true,
                    function(v, w, x)
                        if x then
                            if not globalInPrison and not tGMT.isHandcuffed() then
                                TriggerServerEvent("GMT:claimWeeklyKit")
                            else
                                notify("~r~You can not redeem a kit whilst in custody.")
                            end
                        end
                    end
                )
                local function x()
                    TriggerEvent("GMT:codHMSoundsOn")
                    c = true
                    GMT.setCODHitMarkerSetting(c)
                    GMT.notify("~y~COD Hitmarkers now set to " .. tostring(c))
                end
                local function y()
                    TriggerEvent("GMT:codHMSoundsOff")
                    c = false
                    GMT.setCODHitMarkerSetting(c)
                    GMT.notify("~y~COD Hitmarkers now set to " .. tostring(c))
                end
                RageUI.Checkbox(
                    "Enable COD Hitmarkers",
                    "~g~This adds 'hit marker' sound and image when shooting another player.",
                    c,
                    {Style = RageUI.CheckboxStyle.Car},
                    function(z, w, v, A)
                    end,
                    x,
                    y
                )
                RageUI.Checkbox(
                    "Enable Kill List",
                    "~g~This adds a kill list below your crosshair when you kill a player.",
                    d,
                    {Style = RageUI.CheckboxStyle.Car},
                    function()
                    end,
                    function()
                        d = true
                        GMT.setKillListSetting(d)
                        GMT.notify("~y~Kill List now set to " .. tostring(d))
                    end,
                    function()
                        d = false
                        GMT.setKillListSetting(d)
                        GMT.notify("~y~Kill List now set to " .. tostring(d))
                    end
                )
                RageUI.Checkbox(
                    "Enable Old Killfeed",
                    "~g~This toggles the old killfeed that notifies above minimap.",
                    e,
                    {Style = RageUI.CheckboxStyle.Car},
                    function()
                    end,
                    function()
                        e = true
                        GMT.setOldKillfeed(e)
                        GMT.notify("~y~Old killfeed now set to " .. tostring(e))
                    end,
                    function()
                        e = false
                        GMT.setOldKillfeed(e)
                        GMT.notify("~y~Old killfeed now set to " .. tostring(e))
                    end
                )
                RageUI.Checkbox(
                    "Enable Bullet Tracers",
                    "~g~This toggles the bullets tracers that come out of your weapon.",
                    eE,
                    {Style = RageUI.CheckboxStyle.Car},
                    function()
                    end,
                    function()
                        eE = true
                        GMT.setBulletTracers(eE)
                        GMT.notify("~y~Bullet tracers now set to " .. tostring(eE))
                    end,
                    function()
                        eE = false
                        GMT.setBulletTracers(eE)
                        GMT.notify("~y~Bullet tracers now set to " .. tostring(eE))
                    end
                )
                if eE then
                    RageUI.List(
                        "Tracer Colour",
                        gD,
                        hD,
                        "~g~Change the displayed colour of bullet tracers",
                        {},
                        true,
                        function(B, C, D, Ez)
                            hD = Ez
                            GMT.setBulletTracersColour(hD)
                        end,
                        function()
                        end,
                        nil
                    )
                end
                RageUI.Checkbox(
                    "Enable Damage Indicator",
                    "~g~This toggles the display of damage indicator.",
                    f,
                    {Style = RageUI.CheckboxStyle.Car},
                    function()
                    end,
                    function()
                        f = true
                        GMT.setDamageIndicator(f)
                        GMT.notify("~y~Damage Indicator now set to " .. tostring(f))
                    end,
                    function()
                        f = false
                        GMT.setDamageIndicator(f)
                        GMT.notify("~y~Damage Indicator now set to " .. tostring(f))
                    end
                )
                if f then
                    RageUI.List(
                        "Damage Colour",
                        g,
                        h,
                        "~g~Change the displayed colour of damage",
                        {},
                        true,
                        function(B, C, D, E)
                            h = E
                            GMT.setDamageIndicatorColour(h)
                        end,
                        function()
                        end,
                        nil
                    )
                end
                 
                RageUI.List( -- delete
                        "PFP Type",
                        i,
                        m,
                        "~g~Change the type of PFP displayed",
                        {},
                        true,
                        function(B, C, D, E)
                            m = E
                            tGMT.updatePFPType(i[m])
                            SetResourceKvp("gmt_pfp_type", m)
                        end,
                        function()
                        end,
                        nil
                    )                                   
                if m ~= 4 then
                    RageUI.List(
                        "PFP Size",
                        j,
                        l,
                        "~g~Change the size of PFP displayed",
                        {},
                        true,
                        function(B, C, D, E)
                            l = E
                            tGMT.updatePFPSize(k[l])
                            SetResourceKvp("gmt_pfp_size", l)
                        end,
                        function()
                        end,
                        nil
                    )
                   if m == 3 then
                    RageUI.ButtonWithStyle(
                        "Set Custom PFP",
                        "",
                        { RightLabel = "→→→" },
                        true,
                        function(v, w, x)
                            if x then
                                tGMT.clientPrompt(
                                    "URL:",
                                    "",
                                    function(t)
                                        if string.find(t, "https://") or string.find(t, "http://") then
                                            SetResourceKvp("gmt_custom_pfp", t)
                                        else
                                            GMT.notify("~r~Invalid URL.")
                                        end
                                    end
                                )
                            end
                        end
                    )
                end
                end -- delete
            
                end,
                function()
                end
                )
                RageUI.IsVisible(RMenu:Get("vipclubmenu", "deathsounds"),true,true,true,function()
                    for t, k in pairs(c) do
                        RageUI.Checkbox(t,k.description or "",k.checked,{},function(_,_,selected)
                            if selected then
                                for u, l in pairs(c) do
                                    l.checked = false
                                end
                                k.checked = true
                                o(k.soundId)
                                GMT.setDeathSound(k.soundId)
                                if k.soundId == "custom_death" then
                                    GMT.clientPrompt("URL:","",function(l)
                                        SetResourceKvp("gmt_custom_death_sound", l)
                                        tGMT.notify("~g~Custom death sound set.")
                                    end)
                                else
                                    tGMT.notify("~g~Death sound set to " .. t)
                                end
                            end
                        end,function()
                        end,function()end)
                    end
                end,function()end)
        RageUI.IsVisible(
            RMenu:Get("vipclubmenu", "vehicleextras"),
            true,
            true,
            true,
            function()
                local H = GMT.getPlayerVehicle()
                SetVehicleAutoRepairDisabled(H, true)
                if not GMT.isInVehicle() then
                    RageUI.Separator("~r~Enter a vehicle to be able to use this menu")
                else
                    for I = 1, 99, 1 do
                        if DoesExtraExist(H, I) then
                            RageUI.Checkbox(
                                "Extra " .. I,
                                "",
                                IsVehicleExtraTurnedOn(H, I),
                                {},
                                function()
                                end,
                                function()
                                    SetVehicleExtra(H, I, 0)
                                end,
                                function()
                                    SetVehicleExtra(H, I, 1)
                                end
                            )
                        end
                    end
                end
            end,
            function()
            end
        )
    end
)
RegisterNetEvent("GMT:userSubscriptionUpdated",function()
    TriggerServerEvent('GMT:getPlayerSubscription', permID)
end)
RegisterNetEvent(
    "GMT:setVIPClubData",
    function(J, zz)
        a.hoursOfPlus = J
        a.hoursOfPlatinum = zz
    end
)
RegisterNetEvent("GMT:getUsersSubscription",function(userid, plussub, platsub)
    zz.userid = userid
    zz.hoursOfPlus=plussub
    zz.hoursOfPlatinum=platsub
    RMenu:Get("vipclubmenu", 'manageusersubscription')
end)
function getColourCode(a)
    if a >= 10 then
        colourCode = "~g~"
    elseif a < 10 and a > 3 then
        colourCode = "~y~"
    else
        colourCode = "~r~"
    end
    return colourCode
end
local L = {}
local function M()
    for J, N in pairs(L) do
        DrawAdvancedTextNoOutline(
            0.6,
            0.5 + 0.025 * J,
            0.005,
            0.0028,
            0.45,
            "Killed " .. N.name,
            255,
            255,
            255,
            255,
            GMT.getFontId("Akrobat-Regular"),
            1
        )
    end
end
GMT.createThreadOnTick(M)
RegisterNetEvent(
    "GMT:onPlayerKilledPed",
    function(O)
        if d and (tGMT.isPlatClub() or tGMT.isPlusClub()) and IsPedAPlayer(O) then
            local P = NetworkGetPlayerIndexFromPed(O)
            if P >= 0 then
                local Q = GetPlayerServerId(P)
                if Q >= 0 then
                    local R = GMT.getPlayerName(Q)
                    table.insert(L, {name = R, source = Q})
                    SetTimeout(
                        2000,
                        function()
                            for J, N in pairs(L) do
                                if Q == N.source then
                                    table.remove(L, J)
                                end
                            end
                        end
                    )
                end
            end
        end
    end
)
Citizen.CreateThread(function()
    Wait(2000)
    while true do 
        if tGMT.isPlatClub()then
            if not HasPedGotWeapon(PlayerPedId(),`GADGET_PARACHUTE`,false) then 
                GiveWeaponToPed(PlayerPedId(),`GADGET_PARACHUTE`)
                SetPlayerHasReserveParachute(PlayerId())
            end 
        end
        Wait(500)
    end 
end)

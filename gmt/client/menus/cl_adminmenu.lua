GMTclient = Tunnel.getInterface("GMT","GMT")
local items = {}
local user_id = 0
local foundMatch = false
local inSpectatorAdminMode = false
local players = {}
local playersNearby = {}
local staff = {}
local searchPlayerGroups = {}
local selectedGroup
local povlist = nil
local SelectedPerm = nil
local SelectedName = nil
local SelectedPlayerSource = nil
local frozenPlayers = {}
local currentlyspectating = ""
local banreasons = {}
local selectedbans = {}
local Duration = 0
local BanMessage = "N/A"
local SeparatorMSG = {}
local BanPoints = 0
local g
local h = {}
local i = 1
local k = {}
local o = ''
local tt= ''
local a10
local itemMenu = {}
local requestedVideo = false

admincfg = {}

admincfg.perm = "admin.tickets"
admincfg.IgnoreButtonPerms = false
admincfg.admins_cant_ban_admins = false

local q = {"VIP Island","Large Arms","PD (Mission Row)", "Green Screen", "PD (Sandy)", "PD (Paleto)", "City Hall", "Airport", "HMP", "Rebel Diner", "St Thomas", "Tutorial Spawn", "Simeons"}
local r = {
    vector3(-2173.02,5143.33,2.82),
    vector3(-1113.322265625,4933.5698242188,218.35498046875),
    vector3(446.72503662109, -982.44342041016, 30.68931579589),
    vector3(-1158.9113769531,-469.86404418945,53.167919158936),
    vector3(1839.3137207031, 3671.0014648438, 34.310436248779),
    vector3(-437.32931518555, 6021.2114257813, 31.490119934082),
    vector3(-551.08221435547, -194.19259643555, 38.219661712646),
    vector3(-1142.0673828125, -2851.802734375, 13.94624710083),
    vector3(1848.2724609375, 2586.7385253906, 45.671997070313),
    vector3(1588.3441162109, 6439.3696289063, 25.123600006104),
    vector3(283.37664794922, -579.45318603516, 43.219303131104),
    vector3(-1035.9499511719,-2734.6240234375,13.756628036499),
    vector3(-39.604099273682,-1111.8635253906,26.438835144043),
}
local s = 1

menuColour = '~b~'
-- RMenu.Add("adminmenu", "main", RageUI.CreateSubMenu(RMenu:Get("Admin Player Interaction Menu"), "", "~b~C~w~ompensation", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "menus", "adminmenu"))
RMenu.Add('adminmenu', 'main', RageUI.CreateMenu("", menuColour.."Admin Player Interaction Menu", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "menus","adminmenu"))
RMenu.Add("adminmenu", "players", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "main"), "", menuColour..'Admin Player Interaction Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "staffhelp", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "main"), "", menuColour..'Admin Player Interaction Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "closeplayers", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "main"), "", menuColour..'Admin Player Interaction Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "staffmembers", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "main"), "", menuColour..'Admin Player Interaction Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "searchoptions", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "main"), "", menuColour..'Admin Player Search Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "functions", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "main"), "", menuColour..'Admin Functions Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "devfunctions", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "main"), "", menuColour..'Dev Functions Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "communitypot", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "functions"), "", menuColour..'Community Pot',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "moneymenu", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "functions"), "", menuColour..'Money Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "itemmenu", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "functions"), "", menuColour..'Item Menu ~o~[Tab] to search',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "submenu", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "players"), "", menuColour..'Admin Player Interaction Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "searchname", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "searchoptions"), "", menuColour..'Admin Player Search Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "searchtempid", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "searchoptions"), "", menuColour..'Admin Player Search Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "searchpermid", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "searchoptions"), "", menuColour..'Admin Player Search Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "searchhistory", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "searchoptions"), "", menuColour..'Admin Player Search Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "notespreviewban", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "players"), "", menuColour..'Player Notes',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "banselection", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "notespreviewban"), "", menuColour..'Ban Menu ~w~- ~o~[Tab] to search bans',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "generatedban", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "banselection"), "", menuColour..'Ban Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "notesub", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "players"), "", menuColour..'Player Notes',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "groups", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "submenu"), "", menuColour..'Admin Groups Menu ~w~- ~o~[Tab] to search groups',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "addgroup", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "groups"), "", menuColour..'Admin Groups Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu.Add("adminmenu", "removegroup", RageUI.CreateSubMenu(RMenu:Get("adminmenu", "groups"), "", menuColour..'Admin Groups Menu',GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","adminmenu"))
RMenu:Get('adminmenu', 'main')

local groups = {
	 ["Founder"] = "Founder",
     ["Lead Developer"] = "Lead Developer",
     ["Developer"] = "Developer",
     ["Staff Manager"] = "Staff Manager",
     ["Community Manager"] = "Community Manager",
     ["Head Administrator"] = "Head Administrator",
     ["Senior Administrator"] = "Senior Administrator",
	 ["Administrator"] = "Administrator",
     ["Senior Moderator"] = "Senior Moderator",
	 ["Moderator"] = "Moderator",
     ["Support Team"] = "Support Team",
     ["Trial Staff"] = "Trial Staff",
     ["Car Developer"] = "Car Developer",
    ["Supporter"] = "Supporter",
    ["Premium"] = "Premium",
    ["Supreme"] = "Supreme",
    ["Kingpin"] = "King Pin",
    ["Rainmaker"] = "Rainmaker",
    ["Baller"] = "Baller",
    ["pov"] = "POV List",
    ["Copper"] = "Copper License",
    ["Weed"] = "Weed License",
    ["Limestone"] = "Limestone License",
    ["Gang"] = "Gang License",
    ["Cocaine"] = "Cocaine License",
    ["Meth"] = "Meth License",
    ["Heroin"] = "Heroin License",
    ["LSD"] = "LSD License",
    ["Rebel"] = "Rebel License",
    ["AdvancedRebel"] = "Advanced Rebel License",
    ["Gold"] = "Gold License",
    ["Diamond"] = "Diamond License",
    ["DJ"] = "DJ License",
    -- ["OG"] = "OG Menu",
    -- ["OG Admin"] = "OG Admin",
    ["PilotLicense"] = "Pilot License",
    ["polblips"] = "Long Range Emergency Blips",
    ["Highroller"] = "Highrollers License",
    ["TutorialDone"] = "Completed Tutorial",
    ["NewPlayer"] = "New player",
    ["Royal Mail Driver"] = "Royal Mail Driver",
    ["AA Mechanic"] = "AA Mechanic",
    ["Deliveroo"] = "Deliveroo",
    ["Scuba Diver"] = "Scuba Diver",
    ["G4S Driver"] = "G4S Driver",
    ["Taco Seller"] = "Taco Seller",
    ["Cinematic"] = "Cinematic Menu",
}

RegisterNetEvent("GMT:gotCommunityPotAmount")
AddEventHandler("GMT:gotCommunityPotAmount", function(d)
   -- print("Received community pot amount from server: " .. tostring(d)) -- used for debugging
    communityPot = tonumber(d) or "No row in table value"
   -- print("Current communityPot value: " .. tostring(communityPot)) -- used for debugging
end)

RegisterNetEvent("GMT:SendIfFrozen",function(user_id,frozen)
    frozenPlayers[user_id] = frozen
end)

RegisterNetEvent("GMT:ReceiveBanPlayerData")
AddEventHandler("GMT:ReceiveBanPlayerData",function(BanDuration, CollectedBanMessage, SepMSG, points)
    Duration = BanDuration
    BanMessage = CollectedBanMessage
    SeparatorMsg = SepMSG
    BanPoints = points
    RageUI.Visible(RMenu:Get('adminmenu', 'generatedban'), true)
end)

local function B()
    local C = 0.3
    local D = 0.075
    local E = 0.0
    local F = 0.7
    local G = GetSafeZoneSize()
    local H = G - E
    local I = G - F
    DrawSprite("timerbars", "all_black_bg", H, I, C, D, 0, 0, 0, 0, 200)
end

local function GetStaffName(stafflevel)
    local tbl = {
        [1] = "~f~[Trial Staff]",
        [2] = "~g~[Support Team]",
        [3] = "~g~[Moderator]",
        [4] = "~g~[Senior Moderator]",
        [5] = "~o~[Administrator]",
        [6] = "~q~[Senior Administrator]",
        [7] = "~y~[Head Administrator]",
        [8] = "~p~[Staff Manager]",
        [9] = "~q~[Community Manager]",
        [10] = "~o~[Developer]",
        [11] = "~o~[Lead Developer]",
        [12] = "~r~[Founder]"
    }
    for A,B in pairs(tbl) do
        if stafflevel == A then
            return B.. "~l~"
        end
    end
    return "~r~No perms~l~"
end

RageUI.CreateWhile(1.0, true, function()
    if GMT.getStaffLevel() >= 1 then
        if RageUI.Visible(RMenu:Get('adminmenu', 'main')) then
            RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
                selectedbans = {}
                for k, v in pairs(banreasons) do
                    v.itemchecked = false
                end
                RageUI.ButtonWithStyle("All Players", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end, RMenu:Get('adminmenu', 'players'))
                RageUI.ButtonWithStyle("Nearby Players", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end, RMenu:Get('adminmenu', 'closeplayers'))
                RageUI.ButtonWithStyle("Search Players", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end, RMenu:Get('adminmenu', 'searchoptions'))
                RageUI.ButtonWithStyle("Staff Members", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end, RMenu:Get('adminmenu', 'staffmembers'))
                if GMT.getStaffLevel() == 1 then
                    RageUI.ButtonWithStyle("Staff Help", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    end, RMenu:Get('adminmenu', 'staffhelp'))
                end
                RageUI.ButtonWithStyle("Functions", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end, RMenu:Get('adminmenu', 'functions'))
                RageUI.ButtonWithStyle("Settings", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end, RMenu:Get('SettingsMenu', 'MainMenu'))
            end)
        end
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'players')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for k, v in pairs(players) do
                if not GMT.isUserHidden(v[3]) then
                    RageUI.ButtonWithStyle((povlist and "~s~" or "~s~")..v[1] .." ["..v[2].."]", v[1] .. " ("..v[4].." hours) PermID: " .. v[3] .. " TempID: " .. v[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            SelectedPlayer = players[k]
                            SelectedPerm = v[3]
                            TriggerServerEvent("GMT:CheckPov",v[3]) 
                        end
                    end, RMenu:Get('adminmenu', 'submenu'))
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'closeplayers')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            local coords = GMT.isInSpectate() and GetFinalRenderedCamCoord() or GetEntityCoords(GMT.getPlayerPed())
            for k,v in pairs(players) do
                if not GMT.isUserHidden(v[3]) then
                    local pedcoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(v[2])))
                    if #(coords - pedcoords) < 250.0 then
                        RageUI.ButtonWithStyle((povlist and "~s~" or "~s~")..v[1] .." ["..v[2].."]", v[1] .. " ("..v[4].." hours) PermID: " .. v[3] .. " TempID: " .. v[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                            if Selected then 
                                SelectedPlayer = players[k]
                                SelectedPerm = v[3]
                                TriggerServerEvent("GMT:CheckPov",v[3])
                            end
                            if Active then 
                                DrawMarker(2,pedcoords.x,pedcoords.y,pedcoords.z + 1.1,0.0,0.0,0.0,0.0,-180.0,0.0,0.4,0.4,0.4,255,255,0,125,false,true,2, false)
                            end
                        end, RMenu:Get("adminmenu", "submenu"))
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'staffhelp')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.Separator("~g~Staff Help Menu")
            RageUI.Separator("~y~People highlighted in ~o~orange ~y~are on the ~y~POV List")
            RageUI.Separator("~y~Nearby players are pin pointed with a green ~y~marker")
            RageUI.Separator("~y~The POV list is a list of players who must ~y~provide POV upon request")
            RageUI.Separator("~y~Always follow the server rules")
            RageUI.Separator("~y~Report any issues or concerns to taylor")
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'staffmembers')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for i, v in pairs(players) do
                if not GMT.isUserHidden(v[3]) then
                    if v[5] > 0 then
                        RageUI.ButtonWithStyle((povlist and "~s~" or "~s~")..v[1] .." ["..v[2].."] ~s~- " .. GetStaffName(v[5]), v[1] .. " ("..v[4].." hours) PermID: " .. v[3] .. " TempID: " .. v[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                            if Selected then 
                                SelectedPlayer = players[i]
                                SelectedPerm = v[3]
                                TriggerServerEvent("GMT:CheckPov",v[3])
                            end
                        end, RMenu:Get("adminmenu", "submenu"))
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'searchoptions')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            foundMatch = false
            RageUI.ButtonWithStyle("Search by Name", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('adminmenu', 'searchname'))
            RageUI.ButtonWithStyle("Search by Perm ID", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('adminmenu', 'searchpermid'))
            RageUI.ButtonWithStyle("Search by Temp ID", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('adminmenu', 'searchtempid'))
            RageUI.ButtonWithStyle("Search History", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('adminmenu', 'searchhistory'))
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'functions')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if GMT.getStaffLevel() >= 1 then
                RageUI.ButtonWithStyle("Get Coords", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:GetCoords')
                    end
                end) 
                RageUI.ButtonWithStyle("Get Vector4", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:GetVec4Coords')
                    end
                end)           
                RageUI.List("Teleport",q,s,"",{},true,function(x, y, z, N)
                    s = N
                    if z then
                        tGMT.teleport2(vector3(r[s]), true)
                    end
                end,
                function()end)
                -- RageUI.Checkbox("Hide Admin Chat", "", isAdminChat, {Style = RageUI.CheckboxStyle.Car}, function(Hovered, Active, Selected)
                --     if Selected then
                --         isAdminChat = not isAdminChat
                --         ExecuteCommand("hideadminChat")
                --     end
                -- end)
            end
            if GMT.getStaffLevel() >= 5 then
                RageUI.ButtonWithStyle("TP To Coords","",{RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:Tp2Coords")
                    end
                end)
            end
            if GMT.getStaffLevel() >= 2 then
                RageUI.ButtonWithStyle("Offline Ban","",{RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        tGMT.clientPrompt("Perm ID:","",function(a)
                            banningPermID = a
                            banningName = 'ID: ' .. banningPermID
                            o = nil
                            selectedbans = {}
                            for k, v in pairs(banreasons) do
                                v.itemchecked = false
                            end
                            TriggerServerEvent('GMT:getNotes', banningPermID)
                        end)
                    end
                end, RMenu:Get('adminmenu', 'notespreviewban'))
            end
            if GMT.getStaffLevel() >= 5 then
                RageUI.ButtonWithStyle("TP To Waypoint", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local WaypointHandle = GetFirstBlipInfoId(8)
                        if WaypointHandle and DoesBlipExist(WaypointHandle) then
                            local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
                            for height = 1, 1000 do
                                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)
                                local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, height + 0.0)
                                if foundGround then
                                    SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)
                                    break
                                end
                                Citizen.Wait(5)
                            end
                        else
                            GMT.notify("~r~You do not have a waypoint set")
                        end
                    end
                end)
            end            
            if GMT.getStaffLevel() >= 5 then
                RageUI.ButtonWithStyle("Unban","",{RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:Unban")
                    end
                end)
            end
            if GMT.getStaffLevel() >= 3 then
                RageUI.ButtonWithStyle("Spawn Taxi", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local A = GetEntityCoords(GMT.getPlayerPed())
                        GMT.spawnVehicle("taxi",A.x,A.y,A.z,GetEntityHeading(GMT.getPlayerPed()),true,true,true)
                    end
                end)
            end
            if GMT.getStaffLevel() >= 5 then
                RageUI.ButtonWithStyle("Revive All Nearby", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local D = GMT.getPlayerCoords()
                        for E, S in pairs(GetActivePlayers()) do
                            local T = GetPlayerServerId(S)
                            local M = GetPlayerPed(S)
                            if T ~= -1 and M ~= 0 then
                                local U = GetEntityCoords(M, true)
                                if #(D - U) < 50.0 then
                                    local V = GMT.clientGetUserIdFromSource(T)
                                    if V > 0 then
                                        TriggerServerEvent('GMT:RevivePlayer', GetPlayerServerId(PlayerId()), V, true)
                                    end
                                end
                            end
                        end
                    end
                end)
                RageUI.ButtonWithStyle("Remove Warning","",{RightLabel="→→→"},true,function(Hovered, Active, Selected)
                    if Selected then
                        AddTextEntry('FMMC_MPM_NC', "Enter the Warning ID")
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0);
                            Wait(0);
                        end
                        if (GetOnscreenKeyboardResult()) then
                            local result = GetOnscreenKeyboardResult()
                            if result then 
                                TriggerServerEvent('GMT:RemoveWarning', result)
                            end
                        end
                    end
                end)
            end 
            if GMT.getStaffLevel() >= 6 then
                local P=""
                if GMT.hasStaffBlips() then 
                    P="Turn off blips"
                else 
                    P="~g~Turn on blips"
                end
                RageUI.ButtonWithStyle("Toggle Blips", P, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        GMT.staffBlips(not GMT.hasStaffBlips())
                    end
                end)
                RageUI.ButtonWithStyle("Community Pot Menu","",{RightLabel="→→→"},true,function(Hovered, Active, Selected) -- Removed due to kicking my ass at deving
                    if Selected then
                        --print("Requesting community pot amount from server.") -- Used for debugging
                        TriggerServerEvent("GMT:getCommunityPotAmount")
                    end
                end,RMenu:Get('adminmenu','communitypot'))
                RageUI.ButtonWithStyle("RP Zones","",{RightLabel="→→→"},true,function(Hovered, Active, Selected)
                end,RMenu:Get("rpzones","mainmenu"))
            end  
            if GMT.isDev() then
                RageUI.Checkbox(
                    "Set Globally Hidden",
                    "",
                    hidden,
                    {},
                    function() end,
                    function()
                        TriggerServerEvent("GMT:setUserHidden", true)
                        hidden = not hidden
                    end,
                    function()
                        TriggerServerEvent("GMT:setUserHidden", false)
                        hidden = not hidden
                    end
                )
            end
            if GMT.getStaffLevel() >= 9 then
                RageUI.ButtonWithStyle("Manage Money","",{RightLabel="→→→"},true,function(Hovered, Active, Selected)
                end,RMenu:Get('adminmenu','moneymenu'))
                RageUI.ButtonWithStyle("Manage Items","",{RightLabel="→→→"},true,function(Hovered, Active, Selected)
                end,RMenu:Get('adminmenu','itemmenu'))
                itemMenu = {}
                RageUI.ButtonWithStyle("Add Car", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:AddCar')
                    end
                end, RMenu:Get('adminmenu', 'functions'))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'moneymenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if a10 and sn and sc and sb and sw and sch then
                RageUI.Separator("Name: ~g~"..sn)
                RageUI.Separator("PermID: ~g~"..a10)
                RageUI.Separator("TempID: ~g~"..sc)
                RageUI.Separator("Bank Balance: ~g~£"..sb)
                RageUI.Separator("Cash Balance: ~g~£"..sw)
                RageUI.Separator("Casino Chips: ~g~"..sch)
                RageUI.Separator("")
                RageUI.ButtonWithStyle("Bank Balance ~g~+",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(j)
                            if tonumber(j) then
                                TriggerServerEvent('GMT:ManagePlayerBank',a10,j,"Increase")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Bank Balance ~r~-",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(j)
                            if tonumber(j) then
                                TriggerServerEvent('GMT:ManagePlayerBank',a10,j,"Decrease")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Cash Balance ~g~+~w~",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(l)
                            if tonumber(l) then
                                TriggerServerEvent('GMT:ManagePlayerCash',a10,l,"Increase")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Cash Balance ~r~-",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(l)
                            if tonumber(l) then
                                TriggerServerEvent('GMT:ManagePlayerCash',a10,l,"Decrease")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Dirty Cash Balance ~g~+~w~",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(q)
                            if tonumber(q) then
                                TriggerServerEvent('GMT:ManagePlayerDirtyCash',a10,q,"Increase")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Dirty Cash Balance ~r~-",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(q)
                            if tonumber(q) then
                                TriggerServerEvent('GMT:ManagePlayerDirtyCash',a10,q,"Decrease")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Casino Chips ~g~+",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(l)
                            if tonumber(l) then
                                TriggerServerEvent('GMT:ManagePlayerChips',a10,l,"Increase")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Casino Chips ~r~-",nil,{RightLabel="→→→"},true,function(w,x,y)
                    if y then
                        tGMT.clientPrompt("Amount:","",function(l)
                            if tonumber(l) then
                                TriggerServerEvent('GMT:ManagePlayerChips',a10,l,"Decrease")
                            else
                                GMT.notify("~r~Invalid Amount")
                            end
                        end)
                    end
                end)
            end
            RageUI.ButtonWithStyle("Choose PermID",nil, { RightLabel = "→→→" }, true, function(w,x,y)
                if y then
                    tGMT.clientPrompt("PermID:","",function(j)
                        if tonumber(j) then
                            a10 = tonumber(j)
                          --  GMT.notify("~g~PermID Set To "..j)
                            TriggerServerEvent('GMT:getUserinformation',a10)
                        else
                            GMT.notify("~r~Invalid PermID")
                            a10 = nil
                        end
                    end)
                end
            end, RMenu:Get('adminmenu', 'moneymenu'))
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'itemmenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if itemMenu.user_id and itemMenu.name and itemMenu.temp_id then
                RageUI.Separator("Name: ~g~"..itemMenu.name)
                RageUI.Separator("PermID: ~g~"..itemMenu.user_id)
                RageUI.Separator("TempID: ~g~"..itemMenu.temp_id)
                RageUI.Separator("")
                for name, data in pairs(items) do
                    if not itemMenu.search or itemMenu.search and (string.find(name:lower(),itemMenu.search:lower()) or string.find(data.name:lower(),itemMenu.search:lower())) then        
                        RageUI.ButtonWithStyle(data.name,"Weight: "..data.weight, { RightLabel = "→→→" }, true, function(w,x,y)
                            if y then
                                tGMT.clientPrompt("Amount:","",function(j)
                                    if tonumber(j) then
                                        TriggerServerEvent('GMT:GiveItemMenu',itemMenu.user_id,name,tonumber(j))
                                    else
                                        GMT.notify("~r~Invalid Amount")
                                    end
                                end)
                            end
                        end)
                    end
                end
                if IsControlJustPressed(0, 37) then
                    tGMT.clientPrompt("Item:","",function(j)
                        if not j or j == "" then
                            itemMenu.search = nil
                            return 
                        end
                        itemMenu.search = j
                    end)
                end
            end
            RageUI.ButtonWithStyle("Choose PermID",nil, { RightLabel = "→→→" }, true, function(w,x,y)
                if y then
                    tGMT.clientPrompt("PermID:","",function(j)
                        if tonumber(j) then
                            itemMenu.user_id = tonumber(j)
                            TriggerServerEvent('GMT:getItemInfo',itemMenu.user_id)
                        else
                            GMT.notify("~r~Invalid PermID")
                            itemMenu.user_id = nil
                        end
                    end)
                end
            end, RMenu:Get('adminmenu', 'itemmenu'))
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'communitypot')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            
            if communityPot then
                RageUI.Separator("Community Pot Balance: ~g~£"..getMoneyStringFormatted(communityPot))
            else
                RageUI.Separator("~r~Error getting community pot balance.")
            end
    
            RageUI.ButtonWithStyle("Deposit","",{RightLabel="→→→"},true,function(e,f,g)
                if g then 
                    tGMT.clientPrompt("Enter Amount:","",function(d)
                        if tonumber(d) then 
                            TriggerServerEvent("GMT:tryDepositCommunityPot",d)
                        else 
                            GMT.notify("~r~Invalid amount.")
                        end 
                    end)
                end 
            end)
    
            RageUI.ButtonWithStyle("Withdraw","",{RightLabel="→→→"},true,function(e,f,g)
                if g then 
                    tGMT.clientPrompt("Enter Amount:","",function(d)
                        if tonumber(d) then 
                            TriggerServerEvent("GMT:tryWithdrawCommunityPot",d)
                        else 
                            GMT.notify("~r~Invalid amount.")
                        end 
                    end)
                end 
            end)
            
            RageUI.ButtonWithStyle("Distribute to All Online Players","",{RightLabel="→→→"},true,function(e,f,g)
                if g then 
                    tGMT.clientPrompt("Enter Amount:","",function(d)
                        if tonumber(d) then 
                            TriggerServerEvent("GMT:distributeCommunityPot",d)
                        else 
                            GMT.notify("~r~Invalid amount.")
                        end 
                    end)
                end 
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'devfunctions')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if GMT.isDev() or GMT.getStaffLevel() >= 10 then
                RageUI.ButtonWithStyle("Spawn Weapon", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:Giveweapon')
                    end
                end, RMenu:Get('adminmenu', 'devfunctions'))
                RageUI.ButtonWithStyle("Give Weapon", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:GiveWeaponToPlayer')
                    end
                end, RMenu:Get('adminmenu', 'devfunctions'))
                RageUI.ButtonWithStyle("Armour", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        tGMT.setArmour(100)
                    end
                end, RMenu:Get('adminmenu', 'devfunctions'))
            end        
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'searchpermid')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if foundMatch == false then
                searchforPermID = GMT.KeyboardInput("Enter Perm ID", "", 10)
                if searchforPermID == nil then 
                    searchforPermID = ""
                end
            end
            for k, v in pairs(players) do
                foundMatch = true
                if string.find(v[3],searchforPermID) then
                    if not GMT.isUserHidden(v[3]) then
                        RageUI.ButtonWithStyle(v[1] .." ["..v[2].."]", v[1] .. " ("..v[4].." hours) PermID: " .. v[3] .. " TempID: " .. v[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                SelectedPlayer = players[k]
                                TriggerServerEvent("GMT:CheckPov",v[3])
                                g = v[3]
                                h[i] = g
                                i = i + 1
                            end
                        end, RMenu:Get('adminmenu', 'submenu'))
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'searchtempid')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if foundMatch == false then
                searchid = GMT.KeyboardInput("Enter Temp ID", "", 10)
                if searchid == nil then 
                    searchid = ""
                end
            end
            for k, v in pairs(players) do
                foundMatch = true
                if string.find(v[2], searchid) then
                    if not GMT.isUserHidden(v[3]) then
                        RageUI.ButtonWithStyle(v[1] .." ["..v[2].."]", v[1] .. " ("..v[4].." hours) PermID: " .. v[3] .. " TempID: " .. v[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                SelectedPlayer = players[k]
                                TriggerServerEvent("GMT:CheckPov",v[3])
                                g = v[2]
                                h[i] = g
                                i = i + 1
                            end
                        end, RMenu:Get('adminmenu', 'submenu'))
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'searchname')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if foundMatch == false then
                SearchName = GMT.KeyboardInput("Enter Name", "", 10)
                if SearchName == nil then 
                    SearchName = ""
                end
            end
            for k, v in pairs(players) do
                foundMatch = true
                if string.find(string.lower(v[1]), string.lower(SearchName)) then
                    if not GMT.isUserHidden(v[3]) then
                        RageUI.ButtonWithStyle(v[1] .." ["..v[2].."]", v[1] .. " ("..v[4].." hours) PermID: " .. v[3] .. " TempID: " .. v[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                SelectedPlayer = players[k]
                                TriggerServerEvent("GMT:CheckPov",v[3])
                                g = v[1]
                                h[i] = g
                                i = i + 1
                            end
                        end, RMenu:Get('adminmenu', 'submenu'))
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'searchhistory')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for k, v in pairs(players) do
                if i > 1 then
                    for K = #h, #h - 10, -1 do
                        if h[K] then
                            if tonumber(h[K]) == v[3] or tonumber(h[K]) == v[2] or h[K] == v[1] then
                                RageUI.ButtonWithStyle("[" .. v[3] .. "] " .. v[1], v[1] .. " Perm ID: " .. v[3] .. " Temp ID: " .. v[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                                    if Selected then
                                        SelectedPlayer = players[k]
                                        TriggerServerEvent("GMT:CheckPov",v[3])
                                    end
                                end, RMenu:Get('adminmenu', 'submenu'))
                            end
                        end
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'submenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if GMT.isUserHidden(SelectedPlayer[3]) then
                RageUI.ActuallyCloseAll()
            end
            if povlist == nil then
                RageUI.Separator("~y~Player must provide POV on request: ~o~Loading...")
            elseif povlist == true then
                RageUI.Separator("~y~Player must provide POV on request: ~g~true")
            -- elseif GMT.getUserId() == 1 then
            --     RageUI.Separator("~y~Player must provide POV on request: ~g~false")
            elseif povlist == false then
                RageUI.Separator("~y~Player must provide POV on request: ~r~false")
            end
            if GMT.getStaffLevel() >= 1 then
                RageUI.ButtonWithStyle("Player Notes", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:getNotes', SelectedPlayer[3])
                    end
                end, RMenu:Get('adminmenu', 'notesub'))
                RageUI.ButtonWithStyle("Kick Player", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local uid = GetPlayerServerId(PlayerId())
                        TriggerServerEvent('GMT:KickPlayer', uid, SelectedPlayer[3], SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
            end
            if GMT.getStaffLevel() >= 2 then
                RageUI.ButtonWithStyle("Ban Player", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        banningPermID = SelectedPlayer[3]
                        banningName = SelectedPlayer[1]
                        o = nil
                        TriggerServerEvent('GMT:getNotes', SelectedPlayer[3])
                        selectedbans = {}
                        for k, v in pairs(banreasons) do
                            v.itemchecked = false
                        end
                    end
                end, RMenu:Get('adminmenu', 'notespreviewban'))
                RageUI.ButtonWithStyle("Spectate Player", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if tonumber(SelectedPlayer[2]) ~= GetPlayerServerId(PlayerId()) then
                            if not GMT.isInSpectate() then
                                inRedZone = false
                                TriggerServerEvent("GMT:spectatePlayer", SelectedPlayer[3])
                                inSpectatorAdminMode = true
                                currentlyspectating = GMT.getPlayerName(SelectedPlayer[2])
                                while inSpectatorAdminMode == true do
                                    Wait(0)
                                    B()
                                    DrawAdvancedTextNoOutline(1.036,0.247,0.005,0.0028,0.45,"SPECTATING",255,255,255,255,GMT.getFontId("Akrobat-Regular"),0)
                                    DrawAdvancedTextNoOutline(0.975, 0.27, 0.005, 0.0028, 0.71, currentlyspectating, 255, 255, 255, 255, GMT.getFontId("Akrobat-Regular"), 0)
                                    SetScriptGfxDrawOrder(7)
                                    DrawRect(0.999, 0.27, -0.003, 0.075, 198, 167, 73, 255)
                                    DrawSprite("menus", "spectating", 0.900, 0.249, 0.018, 0.036, 0.0, 255, 255, 255, 255)
                                    drawNativeText("~r~Press [E] to stop spectating.", 255, 0, 0, 255, true)   
                                end
                                currentlyspectating = ""
                            --  RageUI.Text({message = string.format("~r~Press [E] to stop spectating.")})
                            else
                                GMT.notify("~r~You are already spectating a player.")
                            end
                        else
                            GMT.notify("~r~You cannot spectate yourself.")
                        end
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
            end
            if GMT.getStaffLevel() >= 3 then
                RageUI.ButtonWithStyle("Revive", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local uid = GetPlayerServerId(PlayerId())
                        TriggerServerEvent('GMT:RevivePlayer', uid, SelectedPlayer[3])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
            end
            if GMT.getStaffLevel() >= 1 then
                local function FreezeOn()
                    local uid = GetPlayerServerId(PlayerId())
                    TriggerServerEvent('GMT:FreezeSV', uid, SelectedPlayer[2], true)
                    TriggerServerEvent("GMT:RequestIfFrozen",SelectedPlayer[3])
                end
                local function FreezeOff()
                    local uid = GetPlayerServerId(PlayerId())
                    TriggerServerEvent('GMT:FreezeSV', uid, SelectedPlayer[2], false)
                    TriggerServerEvent("GMT:RequestIfFrozen",SelectedPlayer[3])
                end
                RageUI.Checkbox("Freeze Player",SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2],frozenPlayers[SelectedPlayer[3]] or false,{Style = RageUI.CheckboxStyle.Car},function(a1, a3, a2, Checked)
                end,FreezeOn,FreezeOff)
                RageUI.ButtonWithStyle("Teleport to Player", "Name: " .. SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local newSource = GetPlayerServerId(PlayerId())
                        TriggerServerEvent('GMT:TeleportToPlayer', newSource, SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
                RageUI.ButtonWithStyle("Teleport Player to Me", "Name: " .. SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:BringPlayer', SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
                RageUI.ButtonWithStyle("Teleport to Admin Zone", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        inRedZone = false
                        savedCoordsBeforeAdminZone = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(SelectedPlayer[2])))
                        TriggerServerEvent("GMT:Teleport2AdminIsland", SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
                RageUI.ButtonWithStyle("Teleport Back from Admin Zone", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:TeleportBackFromAdminZone", SelectedPlayer[2], savedCoordsBeforeAdminZone)
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
                RageUI.ButtonWithStyle("Teleport to Legion", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:Teleport2Legion", SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
            end
            if GMT.getStaffLevel() >= 5 then
                RageUI.ButtonWithStyle("Slap Player", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local uid = GetPlayerServerId(PlayerId())
                        TriggerServerEvent('GMT:SlapPlayer', uid, SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
                RageUI.ButtonWithStyle("Force Clock Off", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, GMT.getEmploymentStatus(SelectedPlayer[3]) ~= "Unemployed", function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:ForceClockOff', SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
                -- RageUI.ButtonWithStyle("Force Vsync", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                --     if Selected then
                --         if tonumber(SelectedPlayer[2]) == GetPlayerServerId(PlayerId()) then
                --             GMT.notify("~r~Use /vsync instead of forcing it on yourself.")
                --             return
                --         end
                --         ExecuteCommand("vsync", SelectedPlayer[3])
                --     end
                -- end, RMenu:Get('adminmenu', 'submenu'))
                RageUI.ButtonWithStyle("Allow discord verify", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('GMT:AllowDiscordVerify', SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
            end  
            -- RageUI.ButtonWithStyle("Force Staff Off", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            --     if Selected then
            --         TriggerServerEvent('GMT:ForceStaffOff', SelectedPlayer[2])
            --         TriggerEvent("GMT:ForceRefreshData")
            --     end
            -- end, RMenu:Get('adminmenu', 'submenu'))                           
            if GMT.getStaffLevel() >= 8 then
                RageUI.ButtonWithStyle("Send Warning", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        tGMT.clientPrompt("Enter your warning message", "", function(warningMessage)
                            if warningMessage and warningMessage ~= '' then
                                TriggerServerEvent('GMT:TriggerSendWarning', SelectedPlayer[2], warningMessage)
                            else
                                GMT.notify('~r~Cannot send empty messages!')
                            end
                        end)
                    end
                end, RMenu:Get('adminmenu', 'submenu'))    
                RageUI.ButtonWithStyle("Send Direct Message", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                       ExecuteCommand("staffdm " .. SelectedPlayer[3])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))      
                RageUI.ButtonWithStyle("Open F10 Warning Log",SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2],{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
                    if Selected then
                        ExecuteCommand("sw " .. SelectedPlayer[3])
                    end
                end,RMenu:Get("adminmenu", "submenu"))        
            end
            if GMT.getStaffLevel() >= 2 then
                RageUI.ButtonWithStyle("Take Screenshot", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        -- local uid = GetPlayerServerId(PlayerId())
                        -- if SelectedPlayer[3] == uid then
                        --     GMT.notify("~r~You cannot take screenshots of yourself.")
                        --     return
                        -- end
                        GMT.notify("~y~Taking screenshot of ".. GMT.getPlayerName(SelectedPlayer[3]))
                        TriggerServerEvent('GMT:RequestScreenshot', uid , SelectedPlayer[2])
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
                RageUI.Button("Take Video", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], requestedVideo and {RightLabel = ""} or {RightLabel = "→→→"}, not requestedVideo, function(Hovered, Active, Selected)
                    if Selected then
                        local uid = GetPlayerServerId(PlayerId())
                        TriggerServerEvent('GMT:RequestVideo', uid, SelectedPlayer[2])
                        requestedVideo = true
                        SetTimeout(15000, function()
                            requestedVideo = false
                        end)
                    end
                end, RMenu:Get('adminmenu', 'submenu'))
            end
            if GMT.getStaffLevel() >= 6 then
                RageUI.ButtonWithStyle("See Groups","~r~This is management+ ~w~Name: " ..SelectedPlayer[1] .." Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2],{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:GetGroups", SelectedPlayer[3])
                        t = ""
                    end
                end,
                RMenu:Get("adminmenu", "groups"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'notespreviewban')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if GMT.getStaffLevel() >= 2 then
                if noteslist == nil then
                    RageUI.Separator("~o~Player notes: Loading...")
                elseif #noteslist == 0 then
                    RageUI.Separator("~o~There are no player notes to display.")
                else
                    RageUI.Separator("~o~Player notes:")
                    for _ = 1, #noteslist do
                        RageUI.Separator("~o~ID: " .. noteslist[_].id .. " " .. noteslist[_].note .. " (" .. noteslist[_].author .. ")")
                    end
                end
                RageUI.ButtonWithStyle("Continue to Ban", nil, { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                end, RMenu:Get('adminmenu', 'banselection'))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'banselection')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if GMT.getStaffLevel() >= 2 then
                if IsControlJustPressed(0, 37) then
                    tGMT.clientPrompt("Search for: ","",function(O)
                        if O ~= "" then
                            o = string.lower(O)
                        else
                            o = nil
                        end
                    end)
                end
                for k, v in pairs(banreasons) do
                    local function SelectedTrue()
                        selectedbans[v.id] = true
                    end
                    local function SelectedFalse()
                        selectedbans[v.id] = nil
                    end
                    if o == nil or string.match(string.lower(v.id), o) or string.match(string.lower(v.name), o) then
                        RageUI.Checkbox(v.name, v.bandescription, v.itemchecked, {Style = RageUI.CheckboxStyle.Car}, function(Hovered, Selected, Active, Checked)
                            if Selected then
                                if v.itemchecked then
                                    SelectedTrue()
                                end
                                if not v.itemchecked then
                                    SelectedFalse()
                                end
                            end
                            v.itemchecked = Checked
                        end)
                    end
                end
                RageUI.ButtonWithStyle("Confirm Ban", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:GenerateBan", banningPermID, selectedbans)
                    end
                end, RMenu:Get('adminmenu', 'generatedban'))
        
                RageUI.ButtonWithStyle("Cancel Ban", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        selectedbans = {}
                        for k, v in pairs(banreasons) do
                            v.itemchecked = false
                        end
                        RageUI.ActuallyCloseAll()
                    end
                end)
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'generatedban')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if GMT.getStaffLevel() >= 2 then
                if next(selectedbans) then
                    if BanMessage == "N/A" then
                        RageUI.Separator("~g~Generating ban info, please wait...")
                    else
                        RageUI.Separator("~r~You are about to ban " ..banningName, function() end)
                        RageUI.Separator("~w~For the following reason(s):", function() end)
                        for k,v in pairs(SeparatorMsg) do
                            RageUI.Separator(v, function() end)
                        end
                        local U=false
                        if Duration == -1 then
                            U=true
                        end
                        RageUI.Separator("~o~Total Length: "..(U and "Permanent" or Duration.." hrs"))
                        if BanPoints then
                            RageUI.Separator("~o~Total Points Given " ..BanPoints, function() end)
                        end
                        RageUI.ButtonWithStyle("Cancel", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                selectedbans = {}
                                for k, v in pairs(banreasons) do
                                    v.itemchecked = false
                                end
                                RageUI.ActuallyCloseAll()
                            end
                        end)
                        RageUI.ButtonWithStyle("Confirm", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                TriggerServerEvent("GMT:BanPlayer", banningPermID, Duration, BanMessage, BanPoints)
                            end
                        end)
                    end
                else
                    RageUI.Separator("You must select at least one ban reason.", function() end)
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'notesub')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if noteslist == nil then
                RageUI.Separator("~o~Player notes: Loading...")
            elseif #noteslist == 0 then
                RageUI.Separator("~o~There are no player notes to display.")
            else
                RageUI.Separator("~o~Player notes:")
                for _ = 1, #noteslist do
                    RageUI.Separator("~o~ID: " .. noteslist[_].id .. " " .. noteslist[_].note .. " (" .. noteslist[_].author .. ")")
                end
            end
            if GMT.getStaffLevel() >= 1 then
                RageUI.ButtonWithStyle("Add To Notes:", SelectedPlayer[1] .. " Perm ID: " .. SelectedPlayer[3] .. " Temp ID: " .. SelectedPlayer[2], { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                    if Selected then
                        tGMT.clientPrompt("Add To Notes: ","",function(a7)
                            if a7 ~= "" then
                                if #noteslist ~= 0 then
                                    noteslist[#noteslist + 1] = {id = #noteslist + 1, note = a7, author = GMT.getUserId()}
                                else
                                    noteslist = {{id = 1, note = a7, author = GMT.getUserId()}}
                                end
                                TriggerServerEvent("GMT:updatePlayerNotes", SelectedPlayer[3], noteslist)
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle("Remove Note", nil, { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                    if Selected then
                        tGMT.clientPrompt("Type the ID of the note","",function(a7)
                            if a7 ~= "" then
                                a7 = tonumber(a7)
                                local a8 = {}
                                local a9 = false
                                for _ = 1, #noteslist do
                                    if noteslist[_].id == a7 then
                                        for aa = 1, #noteslist do
                                            if aa ~= _ then
                                                a8[#a8 + 1] = {
                                                    id = #a8 + 1,
                                                    note = noteslist[aa].note,
                                                    author = noteslist[aa].author
                                                }
                                            end
                                        end
                                        a9 = true
                                        break
                                    end
                                end
                                if a9 == true then
                                    if #a8 == 0 then
                                        a8 = nil
                                        noteslist = {}
                                    else
                                        noteslist = a8
                                    end
                                    TriggerServerEvent("GMT:updatePlayerNotes", SelectedPlayer[3], a8)
                                end
                            end
                        end)
                    end
                end)
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'groups')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if GMT.getStaffLevel() >= 7 then
                if IsControlJustPressed(0, 37) then
                    tGMT.clientPrompt("Search for: ","",function(S)
                        tt=string.lower(S)
                    end)
                end
                for k,S in pairs(groups) do
                    if tt=="" or string.find(string.lower(S),string.lower(tt)) then
                        if searchPlayerGroups[k] then
                            RageUI.ButtonWithStyle("~g~"..S,"~g~User has this group.",{RightLabel="→→→"},true,function(x,y,z)
                                if z then 
                                    selectedGroup = k
                                end 
                            end,RMenu:Get('adminmenu','removegroup'))
                        else 
                            RageUI.ButtonWithStyle("~r~"..S,"~r~User does not have this group.",{RightLabel="→→→"},true,function(x,y,z)
                                if z then 
                                    selectedGroup = k
                                end 
                            end,RMenu:Get('adminmenu','addgroup'))
                        end 
                    end
                end
            end
        end) 
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'addgroup')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.ButtonWithStyle("Add this group to user", "", { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("GMT:AddGroup",SelectedPerm,selectedGroup)
                end
            end, RMenu:Get('adminmenu', 'groups'))
        end)
    end
    if RageUI.Visible(RMenu:Get('adminmenu', 'removegroup')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.ButtonWithStyle("Remove user from group", "", { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("GMT:RemoveGroup",SelectedPerm,selectedGroup)
                end
            end, RMenu:Get('adminmenu', 'groups')) 
        end)
    end
end)

RegisterCommand("cleanup", function()
    TriggerServerEvent('GMT:CleanAll')
end)

RegisterNetEvent("GMT:GottenItemInfo",function(data)
    itemMenu = data
end)

RegisterNetEvent("GMT:GottenItems",function(data)
    items = data
end)

RegisterNetEvent('GMT:SlapPlayer')
AddEventHandler('GMT:SlapPlayer', function()
    if tGMT.staffMode() then
        tGMT.staffMode(false)
    end
    SetEntityHealth(PlayerPedId(), 0)
end)
frozen = false
RegisterNetEvent("GMT:Freeze",function()
    local Q = GMT.getPlayerPed()
    if IsPedSittingInAnyVehicle(Q) then
        local ak = GetVehiclePedIsIn(Q, false)
        TaskLeaveVehicle(Q, ak, 4160)
    end
    if not frozen then
        FreezeEntityPosition(Q, true)
        frozen = true
        while frozen do
            GMT.setWeapon(Q, "WEAPON_UNARMED", true)
            Wait(0)
        end
    else
        FreezeEntityPosition(Q, false)
        frozen = false
    end
end)


RegisterNetEvent("GMT:sendNotes",function(a7)
    a7 = json.decode(a7)
    if a7 == nil then
        noteslist = {}
    else
        noteslist = a7
    end
end)

RegisterNetEvent('GMT:ReturnPov')
AddEventHandler('GMT:ReturnPov', function(pov)
    povlist = pov
end)

RegisterNetEvent("GMT:GotGroups")
AddEventHandler("GMT:GotGroups",function(gotGroups)
    searchPlayerGroups = gotGroups
end)

RegisterNetEvent("GMT:getPlayersInfo")
AddEventHandler("GMT:getPlayersInfo", function(BB, preasons)
    players = BB
    banreasons = preasons
    RageUI.Visible(RMenu:Get("adminmenu", "main"), not RageUI.Visible(RMenu:Get("adminmenu", "main")))
end)

RegisterNetEvent("GMT:receivedUserInformation")
AddEventHandler("GMT:receivedUserInformation", function(us,un,ub,uw,uc)
    if us == nil or un == nil or ub == nil or uw == nil or uc == nil then
        a10 = nil
        GMT.notify("~r~Player does not exist.")
        return
    end
    sc=us
    sn=un
    sb=getMoneyStringFormatted(ub)
    sw=getMoneyStringFormatted(uw)
    sch=getMoneyStringFormatted(uc)
end)


function Draw2DText(x, y, text, scale)
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

RegisterNetEvent('GMT:OpenAdminMenu')
AddEventHandler('GMT:OpenAdminMenu', function(admin)
    if admin then
        TriggerServerEvent('GMT:GetPlayerData')
        TriggerServerEvent("GMT:GetNearbyPlayerData")
        TriggerServerEvent("GMT:getAdminLevel")
    end
end)

RegisterCommand('devmenu',function()
    if GMT.isDev() or GMT.getUserId() == 2 then
        RageUI.Visible(RMenu:Get("adminmenu", "devfunctions"), not RageUI.Visible(RMenu:Get("adminmenu", "devfunctions")))
    end
end)

function DrawHelpMsg(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

function bank_drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function func_checkSpectatorMode()
    if inSpectatorAdminMode then
        if IsControlJustPressed(0, 51) then
            inSpectatorAdminMode = false
            TriggerServerEvent("GMT:stopSpectatePlayer")
        end
    end
end
GMT.createThreadOnTick(func_checkSpectatorMode)

RegisterNetEvent("GMT:takeCarScreenshotAndUpload",function(url,screenshotid)
    exports["els"]:requestScreenshotUpload(url,"files[]",function(data)
        -- print(data)
       TriggerServerEvent("GMT:ScreenshotProcessed",screenshotid,json.decode(ab))
    end)
end)

RegisterNetEvent("GMT:takeClientScreenshotAndUpload",function(url,screenshotid)
    local url = url -- need a custom uploader whenever
    exports["els"]:requestScreenshotUpload(url,"files[]",function(ab)
       -- print(data)
       TriggerServerEvent("GMT:ScreenshotProcessed",screenshotid,json.decode(ab))
    end)
end)

RegisterNetEvent("GMT:takeClientVideoAndUpload",function(url,videoType)
    exports["els"]:requestVideoUpload(url,"files[]",{headers = {}, isVideo = true, isManual = true, encoding = "mp4"},function(ac)
        TriggerServerEvent("GMT:VideoProcessed",videoType,json.decode(ac))
    end)
end)

RegisterNetEvent("GMT:takeClientVideoAndUploadKills", function(url,killid)
    exports["els"]:requestVideoUpload(url, "files[]", { headers = {}, isVideo = true, isManual = true, encoding = "mp4"}, function(videodata)
        TriggerServerEvent("GMT:KillProcessed",killid,json.decode(videodata))
    end)
end)

local an = 0
local function ao()
    local ap = GetResourceState("els")
    if ap == "started" then
        exports["els"]:requestKeepAlive(function(aq)
            if not aq then
                an = GetGameTimer()
            end
        end)
    end
    if GetGameTimer() - an > 60000 then
        -- TriggerServerEvent("GMT:acType16")
        
    end
end
AddEventHandler("GMT:onClientSpawn",function(C, D)
    if D then
        an = GetGameTimer()
        while true do
            ao()
            Citizen.Wait(5000)
        end
    end
end)

local aK = false
RegisterNetEvent("GMT:adminTicketFeedback",function(aL)
    local aM, aN = GMT.getPlayerVehicle()
    if aM ~= 0 and aN and GetEntitySpeed(aM) > 25.0 or GMT.getPlayerCombatTimer() > 0 then
        return
    end
    if aK then
        return
    end
    aK = true
    RequestStreamedTextureDict("ticket_response", false)
    while not HasStreamedTextureDictLoaded("ticket_response") do
        Citizen.Wait(0)
    end
    setCursor(1)
    TriggerScreenblurFadeIn(500.0)
    GMT.showUI()
    local aO = nil
    while not aO do
        DisableControlAction(0, 202, true)
        drawNativeNotification("Press ~INPUT_FRONTEND_CANCEL~ to stop providing feedback")
        for a1 = 0, 6 do
            DisableControlAction(0, a1, true)
        end
        DrawSprite("ticket_response", "faces", 0.5, 0.575, 0.39, 0.28275, 0.0, 255, 255, 255, 255)
        DrawAdvancedText(0.58,0.4,0.01,0.01,0.65,"How would you rate your experience with the admin?",255,255,255,255,0,0)
        if CursorInArea(0.304, 0.411, 0.483, 0.669) and IsControlJustPressed(0, 237) then
            aO = "good"
        end
        if CursorInArea(0.446, 0.552, 0.483, 0.669) and IsControlJustPressed(0, 237) then
            aO = "neutral"
        end
        if CursorInArea(0.588, 0.693, 0.483, 0.669) and IsControlJustPressed(0, 237) then
            aO = "bad"
        end
        if IsDisabledControlJustPressed(0, 202) then
            break
        end
        Citizen.Wait(0)
    end
    setCursor(0)
    SetStreamedTextureDictAsNoLongerNeeded("ticket_response")
    if aO then
        local aP = false
        tGMT.clientPrompt("Attached Message","",function(aQ)
            TriggerServerEvent("GMT:adminTicketFeedback", aL, aO, aQ)
            aP = true
        end)
        while not aP do
            for a1 = 0, 6 do
                DisableControlAction(0, a1, true)
            end
            drawNativeNotification("Press ~INPUT_FRONTEND_RUP~ to submit the " .. aO .. " feedback")
            DrawAdvancedText(0.58,0.4,0.01,0.01,0.65,"Would you like to provide any additional feedback?",255,255,255,255,0,0)
            Citizen.Wait(0)
        end
    else
        TriggerServerEvent("GMT:adminTicketNoFeedback", aL)
    end
    GMT.showUI()
    TriggerScreenblurFadeOut(500.0)
    aK = false
end)
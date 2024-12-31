DecorRegister("gmt_owner", 3)
DecorRegister("gmt_vmodel", 3)
DecorRegister("lootid", 3)
DecorRegister("lsAudioId", 3)
local cfg = module("cfg/cfg_garages")
local weightcfg = module("cfg/cfg_inventory")
local b = cfg.garages
local garage_type = ""
local selected_category = nil
local Hovered_Vehicles = nil
VehiclesFetchedTable = {}
local paymentPlanVehicle = nil
local RentedVehiclesIn = {}
local RentedVehiclesOut = {}
local Table_Type = nil
local RentedVeh = false
local SelectedCar = {spawncode = nil, name = nil, plate = nil}
local veh = nil 
local cantload = {}
local vehname = nil
local folders = {}
local SelectedfolderName = nil
local lsC = module("cfg/cfg_lscustoms")
local f = ""
local o = {}
local sellHistory = {}
local q = {}
local m = {}
local g = ""
local n = false
local k = 0
local x = {}
local vehicleweights = {}
globalVehicleModelHashMapping = {}
globalVehicleOwnership = {}
globalOwnedPlayerVehicles = {}
globalLastSpawnedVehicleTime = 0

local vehicleCannotBeSold = {
}

local vehicleCannotBeRented = {
}
local garageSettings = {}

local VehicleCustomName = {}

RMenu.Add('GMTGarages', 'main', RageUI.CreateMenu("", "~w~Garages",GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "banners", "garage"))
RMenu.Add('GMTGarages', 'all_owned_vehicles', RageUI.CreateMenu("", "~w~Garages",GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "banners", "garage"))
--RMenu.Add('GMTGarages', 'all_owned_vehicles', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "settings")))
RMenu.Add('GMTGarages', 'owned_vehicles_rent_out', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "all_owned_vehicles")))
RMenu.Add('GMTGarages', 'owned_vehicles', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "main")))
RMenu.Add('GMTGarages', 'rented_vehicles', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "main")))
RMenu.Add('GMTGarages', 'rented_vehicles_manage', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "rented_vehicles")))
RMenu.Add('GMTGarages', 'rented_vehicles_information', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "rented_vehicles_manage")))
RMenu.Add('GMTGarages', 'owned_vehicles_submenu', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "owned_vehicles")))
RMenu.Add('GMTGarages', 'owned_vehicles_submenu_manage', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "owned_vehicles_submenu")))
RMenu.Add('GMTGarages', 'scrap_vehicle_confirmation', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "owned_vehicles_submenu_manage")))
RMenu.Add('GMTGarages', 'rented_vehicles_out_manage', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "rented_vehicles")))
RMenu.Add('GMTGarages', 'rented_vehicles_out_information', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "rented_vehicles_out_manage")))
RMenu.Add('GMTGarages', 'customfolders', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "owned_vehicles")))
RMenu.Add('GMTGarages', 'customfoldersvehicles', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "customfolders")))
RMenu.Add('GMTGarages', 'settings', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "main")))
RMenu.Add('GMTGarages', 'payment_plan', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "main")))
RMenu.Add('GMTGarages', 'payment_plan_summary', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "payment_plan")))
RMenu.Add('GMTGarages', 'payment_plan_in', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "payment_plan")))
RMenu.Add('GMTGarages', 'payment_plan_vehicle', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "owned_vehicles")))
RMenu.Add('GMTGarages', 'payment_plan_out', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "payment_plan")))
RMenu.Add('GMTGarages', 'sell_history', RageUI.CreateSubMenu(RMenu:Get("GMTGarages", "owned_vehicles")))
RMenu:Get('GMTGarages', 'owned_vehicles'):SetSubtitle("Vehicle Management Menu")


function DeleteCar(veh)
    if veh then 
        if DoesEntityExist(veh) then 
            Hovered_Vehicles = nil
            vehname = nil
            DeleteEntity(veh)
            veh = nil
        end
    end
end

function GMT.addVehicleCustomName(N, O)
    if O == "" then
        VehicleCustomName[N] = nil
        GMT.notify("~g~Custom name removed.")
    else
        VehicleCustomName[N] = O
        GMT.notify("~g~Custom name set to " .. O .. ".")
    end
    SetResourceKvp("gmt_custom_vehiclenames", json.encode(VehicleCustomName))
end

local function V(J)
    if c ~= nil then
        for k,v in pairs(c) do
            if v == J then
                return true
            end
        end
    end
    return false
end

local function W(J)
    RageUI.ActuallyCloseAll()
    if V(J) then
        RageUI.Visible(RMenu:Get("GMTGarages", "main"), true)
    end
end
local function X(J)
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get("GMTGarages", "main"), false)
end
CreateThread(function()
    local Y = {}
    local Z = {}
    for J, G in pairs(cfg.garages) do
        for L, M in pairs(G) do
            if L == "_config" then
                local _, a0, a1, a2, a3, type = M.blipid,M.blipcolor,M.markerid,M.markercolours,M.permissions,M.type
                for a4, a5 in pairs(cfg.garageInstances) do
                    local a6, a7, a8 = table.unpack(a5)
                    if J == a6 then
                        if a8 then
                            table.insert(Y, {position = a7, blipId = _, blipColor = a0, name = a6})
                        end
                        table.insert(Z, {position = a7, colour = a2, markerId = a1})
                    end
                end
            end
        end
    end
    local a9 = function(aa)
        PlaySound(-1, "Hit", "RESPAWN_SOUNDSET", 0, 0, 1)
        h = b[aa.garageType]["_config"].type
        W(aa.garageType)
        garage_type = aa.garageType
        selectedGarageVector = aa.position
    end
    local ab = function(aa)
        PlaySound(-1, "Hit", "RESPAWN_SOUNDSET", 0, 0, 1)
        X(aa.garageType)
    end
    local ac = function(aa)
    end
    for ad, ae in pairs(cfg.garageInstances) do
        GMT.createArea("garage_" .. ad,ae[2],1.5,6,a9,ab,ac,{garageType = ae[1], garageId = ad, position = ae[2]})
    end
    for _, af in pairs(Y) do
        tGMT.addBlip(af.position.x, af.position.y, af.position.z, af.blipId, af.blipColor, af.name, 0.7, false)
    end
    for a1, ag in pairs(Z) do
        tGMT.addMarker(ag.position.x,ag.position.y,ag.position.z,0.7,0.7,0.5,ag.colour[1],ag.colour[2],ag.colour[3],125,50,ag.markerId,true)
    end
end)


local ah = 0
local ai = 0.0
local function aj(E)
    DeleteVehicle(GetVehiclePedIsIn(GMT.getPlayerPed(), false))
    CreateThread(function()
        local ak = GetHashKey(E)
        RequestModel(ak)
        local al = 0
        while not HasModelLoaded(ak) and al < 200 do
            drawNativeText("~b~Downloading vehicle model")
            Wait(0)
            al = al + 1
        end
        if HasModelLoaded(ak) then
            local am = CreateVehicle(ak,selectedGarageVector.x,selectedGarageVector.y,selectedGarageVector.z,ai,false,false)
            DecorSetInt(am, decor, 955)
            SetEntityAsMissionEntity(am)
            FreezeEntityPosition(am, true)
            SetEntityInvincible(am, true)
            SetVehicleDoorsLocked(am, 4)
            SetModelAsNoLongerNeeded(ak)
            if ah ~= 0 then
                DestroyCam(ah, 0)
                ah = 0
            end
            SetEntityAlpha(GMT.getPlayerPed(), 0)
            FreezeEntityPosition(GMT.getPlayerPed(), true)
            SetEntityCollision(GMT.getPlayerPed(), false, false)
            SetEntityCollision(am, false, false)
            local an = GetEntityCoords(GMT.getPlayerPed())
            local ao = GetEntityRotation(GMT.getPlayerPed())
            local ap = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
            local aq = vector3(an.x, an.y, an.z + 2.0) - GetEntityForwardVector(GMT.getPlayerPed()) * 4.0
            SetCamActive(ap, true)
            RenderScriptCams(true, true, 500, 1, 0)
            SetCamCoord(ap, aq)
            SetCamRot(ap, -20.0, ao.y, ao.z)
            ah = ap
            Citizen.CreateThread(function()
                while DoesEntityExist(am) do
                    Citizen.Wait(25)
                    ai = (ai + 1) % 360
                    SetEntityHeading(am, ai)
                end
            end)
            t = false
            n = true
            k = am
        else
            GMT.notify("~r~Failed to load vehicle.")
            return -1
        end
    end)
end
local function ar(as)
    local at = AddBlipForEntity(as)
    SetBlipSprite(at, 56)
    SetBlipDisplay(at, 4)
    SetBlipScale(at, 1.0)
    SetBlipColour(at, 2)
    SetBlipAsShortRange(at, true)
end

local fuelLevels = {}
RegisterNetEvent("GMT:spawnPersonalVehicle",function(E, av, valetCalled, ax, plate, fuel)
    X()
    fuelLevels[E] = fuel
    if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == d then
        DeleteEntity(d)
    end
    GMT.notify("~g~Loading vehicle, please wait.")
    local ay = globalVehicleOwnership[E]
    if ay == nil or not DoesEntityExist(ay[2]) then
        local ak = GMT.loadModel(E)
        if ak == nil then
            GMT.notify("~r~Vehicle does not exist, if you believe this is an error contact a Car Dev on discord.")
            return
        end
        globalVehicleModelHashMapping[ak] = E
        globalLastSpawnedVehicleTime = GetGameTimer()
        local as
        if valetCalled then
            local an = tGMT.getPosition()
            local az, T, aA = GetNthClosestVehicleNode(an.x, an.y, an.z, nil, 8, 8, 8, 8)
            local T, aB, T = GetNthClosestVehicleNode(an.x, an.y, an.z, 15)
            local aC, T, aD = GetClosestVehicleNodeWithHeading(an.x, an.y, an.z, nil, 8, 8, 8, 8)
            local T, aE, T = GetPointOnRoadSide(an.x, an.y, an.z, 0.0)
            if tostring(aE) ~= "vector3(0, 0, 0)" and tostring(aB) ~= "vector3(0, 0, 0)" then
                as = GMT.spawnVehicle(ak, aB.x, aB.y, aB.z + 0.5, aA or 0.0, false, true, true)
                tGMT.applyModsOnVehicle(av, E, as)
                GMT.loadModel("s_m_y_xmech_01")
                SendNUIMessage({transactionType = "MPCT_AKAA_0" .. math.random(1, 5)})
                local aF = CreatePedInsideVehicle(as, "PED_TYPE_CIVMALE", "s_m_y_xmech_01", -1, false, false)
                TaskVehicleDriveToCoord(aF, as, aE.x, aE.y, aE.z, 15.0, 1.0, ak, 786603, 5.0)
                ar(as)
                SetTimeout(5000,function()
                    while GetEntitySpeed(as) > 5.0 do
                        Wait(500)
                    end
                    TaskLeaveVehicle(aF, as, 64)
                    TaskWanderStandard(aF, 10.0, 10)
                    Wait(10000)
                    DeletePed(aF)
                end)
                print("[GMT] Spawned vehicle with spawncode: " .. tostring(E))
                DecorSetInt(as, "gmt_owner", GMT.getUserId())
                DecorSetInt(as, "gmt_vmodel", E)
                SetVehicleNumberPlateText(as, plate)
                globalVehicleOwnership[E] = {E, as}
                setVehicleFuel(as, fuelLevels[E])
                while GMT.getPlayerVehicle() ~= as do
                    Wait(100)
                end
                TriggerServerEvent("GMT:spawnVehicleCallback", GMT.getUserId(), VehToNet(as))
                table.insert(m, as)
            end
        else
            local aG = ax or tGMT.getPosition()
            as = GMT.spawnVehicle(ak, aG.x, aG.y, aG.z + 0.5, GetEntityHeading(PlayerPedId()), true, true, true)
            tGMT.applyModsOnVehicle(av, E, as)
            ar(as)
            print("[GMT] Spawned vehicle with spawncode: " .. tostring(E))
            DecorSetInt(as, "gmt_owner", GMT.getUserId())
            DecorSetInt(as, "gmt_vmodel", E)
            SetVehicleNumberPlateText(as, plate)
            globalVehicleOwnership[E] = {E, as}
            setVehicleFuel(as, fuelLevels[E])
            TriggerServerEvent("GMT:PayVehicleTax")
            TriggerServerEvent("GMT:spawnVehicleCallback", GMT.getUserId(), VehToNet(as))
            table.insert(m, as)
            CreateThread(function()
                local aH = true
                SetTimeout(5000,function()
                    aH = false
                end)
                while aH do
                    if DoesEntityExist(as) then
                        Citizen.InvokeNative(0x5FFE9B4144F9712F, true)
                        SetNetworkVehicleAsGhost(as, true)
                        SetEntityAlpha(as, 220)
                    end
                    Wait(0)
                end
                Citizen.InvokeNative(0x5FFE9B4144F9712F, false)
                SetNetworkVehicleAsGhost(as, false)
                SetEntityAlpha(as, 255)
                ResetEntityAlpha(as)
            end)
        end
        SetModelAsNoLongerNeeded(ak)
        while DoesEntityExist(as) do
            local aI = GetFuel(as)
            if fuelLevels[E] ~= aI then
                TriggerServerEvent("GMT:updateFuel", E, math.floor(aI * 1000) / 1000)
                fuelLevels[E] = aI
                SetEntityInvincible(as, false)
                SetEntityCanBeDamaged(as, true)
            end
            Wait(60000)
        end
    else
        GMT.notify("~r~This vehicle is already out.")
    end
end)


function GetFuel(ay)
    return DecorGetFloat(ay, "_FUEL_LEVEL")
end

-- function GMT.isVehicleOut(model)
--     for i,v in pairs(globalVehicleOwnership) do
--         if v[1] == model then
--             return false
--         end
--     end
--     return true
-- end

function func_previewGarageVehicle()
    if n then
        if IsControlJustPressed(0, 177) then
            DeleteVehicle(k)
            k = 0
            l = 0
            n = false
            DestroyCam(ah, 0)
            RenderScriptCams(0, 0, 1, 1, 1)
            ah = 0
            SetFocusEntity(GetPlayerPed(PlayerId()))
            SetEntityAlpha(GMT.getPlayerPed(), 255)
            FreezeEntityPosition(GMT.getPlayerPed(), false)
            SetEntityCollision(GMT.getPlayerPed(), true, true)
        end
    end
end
GMT.createThreadOnTick(func_previewGarageVehicle)

local function aK(E)
    for J, aL in pairs(b) do
        for aM in pairs(aL) do
            if aM ~= "_config" and aM == E then
                return V(J) and h == aL["_config"].type
            end
        end
    end
    return true
end

local PaymentPlanPrice = 10000
local PaymentPlanWeeks2pay = 1
local PaymentPlanWeeklyPay = 1
local PaymentPlanMaxMissed = 1
local PaymentPlanDeposit = 0

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('GMTGarages', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            DeleteCar(veh)
            RageUI.ButtonWithStyle("Garages", f, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected) 
                if Selected then
                    VehiclesFetchedTable = {}
                    TriggerServerEvent('GMT:FetchCars', garage_type)
                    TriggerServerEvent('GMT:getCustomFolders')
                    TriggerServerEvent("GMT:getImpoundedVehicles")
                end
            end, RMenu:Get("GMTGarages", "owned_vehicles"))
            local b = GMT.getPlayerVehicle()
            local c = GMT.getPlayerPed()
            RageUI.ButtonWithStyle("Store Vehicle", f, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    if (GMT.getPlayerCombatTimer() > 0) then
                        GMT.notify("~r~You can not store vehicles whilst in combat.")
                    else
                        local aR = GetVehiclePedIsIn(GMT.getPlayerPed(), false)
                        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(aR))
                        if DoesEntityExist(aR) then
                            DeleteEntity(aR)
                        end
                    end
                end
            end)
            RageUI.ButtonWithStyle("Rent Manager", f, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected) 
                if Selected then
                    TriggerServerEvent('GMT:FetchRented')
                end
            end, RMenu:Get("GMTGarages", "rented_vehicles"))
            RageUI.Button("Payment Plan Manager", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected) 
                if Selected then
                    -- TODO: Payment plan
                end
            end, RMenu:Get("GMTGarages", "payment_plan"))
            RageUI.ButtonWithStyle("Settings", f, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get("GMTGarages", "settings"))
            RageUI.ButtonWithStyle("~y~Fuel all vehicles. (£25,000)", f, {RightLabel = ""}, true,function(aO, aP, aQ)
                if aQ then
                    if tGMT.isPlusClub() or tGMT.isPlatClub() then
                        if not u then
                            TriggerServerEvent("GMT:fuelAllVehicles")
                            u = true
                            SetTimeout(60000,function()
                                u = false
                            end)
                        else
                            GMT.notify("You've done this too recently, try again later.")
                        end
                    else
                        GMT.notify("~y~You need to be a subscriber of GMT Plus or GMT Platinum to use this feature.")
                        GMT.notify("~y~Available @ gmt.tebex.io")
                    end
                end
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'payment_plan')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.ButtonWithStyle("Vehicles Payment Planned Out", f, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get("GMTGarages", "payment_plan_out"))
            RageUI.ButtonWithStyle("Vehicles Payment Planned In", f, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get("GMTGarages", "payment_plan_in"))
            RageUI.ButtonWithStyle("Payment Plan Summary", f, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get("GMTGarages", "payment_plan_summary"))
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'payment_plan_summary')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("~g~Estimated income of £0 per week")
            RageUI.Separator("~y~Estimated outflow of £0 per week")
            -- TODO: Payment plan summary
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'payment_plan_out')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            -- TODO: Payment plan out
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'payment_plan_in')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            -- TODO: Payment plan in
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'payment_plan_vehicle')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("~y~Vehicle: "..paymentPlanVehicle)
            RageUI.ButtonWithStyle("Total Price", "The total amount of money that will have to be paid before ownership is transferred.", {RightLabel = "£"..getMoneyStringFormatted(PaymentPlanPrice)}, true, function(Hovered, Active, Selected)
                if Selected then
                    tGMT.clientPrompt("Enter Total Price", "", function(text)
                        local number = tonumber(text)
                        if number and number >= 10000 and number <= 10000000000 then
                            PaymentPlanPrice = number
                        else
                            GMT.notify("~r~Total price must be a whole number between £10,000 and £10,000,000,000.")
                        end
                    end)
                end
            end)
            RageUI.ButtonWithStyle("Weeks To Pay", "The amount of weeks the player has to pay off the plan. Automatically calculated if Pay Amount Per Week is set.", {RightLabel = PaymentPlanWeeks2pay .. " week"}, true, function(Hovered, Active, Selected)
                if Selected then
                    tGMT.clientPrompt("Enter Weeks To Pay","", function(text)
                        local number = tonumber(text)
                        if number and number >= 1 and number <= 26 then
                            PaymentPlanWeeks2pay = number
                        else
                            GMT.notify("~r~Total amount of weeks must be a whole number between 1 week and 26 weeks")
                        end
                    end)
                end
            end)
            RageUI.ButtonWithStyle("Pay Amount Per Week", "The amount of money to pay each week. Automatically calculated if weekly pay amount is set.", {RightLabel = "£"..getMoneyStringFormatted(PaymentPlanWeeklyPay)}, true, function(Hovered, Active, Selected)
                if Selected then
                    tGMT.clientPrompt("Enter Pay Amount Per Week","", function(text)
                        local number = tonumber(text)
                        if number and number >= 385 and number <= 10000 then
                            PaymentPlanWeeklyPay = number
                        else
                            GMT.notify("~r~Pay amount per week must be a whole number between £385 and £10,000.")
                        end
                    end)
                end
            end)
            RageUI.ButtonWithStyle("Maximum Missed Payments", "The maximum amount of missed payments in weeks allowed before the payment plan is automatically cancelled.", {RightLabel = PaymentPlanMaxMissed .. " week"}, true, function(Hovered, Active, Selected)
                if Selected then
                    tGMT.clientPrompt("Enter Maximum Missed Payments","", function(text)
                        local number = tonumber(text)
                        if number and number >= 1 and number <= 4 then
                            PaymentPlanMaxMissed = number
                        else
                            GMT.notify("~r~Maximum Missed Payments must be a whole number between 1 week and 4 weeks.")
                        end
                    end)
                end
            end)
            RageUI.ButtonWithStyle("Inital Deposit", "The amount that has to be paid when accepting hte offer. Counts towards the total.", {RightLabel = "£" ..getMoneyStringFormatted(PaymentPlanDeposit)}, true, function(Hovered, Active, Selected)
                if Selected then
                    tGMT.clientPrompt("Enter Inital Deposit","", function(text)
                        local number = tonumber(text)
                        if number and number <= 5000 then
                            PaymentPlanDeposit = number
                        else
                            GMT.notify("~r~Initial deposit must be a whole number between £0 and £5,000.")
                        end
                    end)
                end
            end)
            RageUI.ButtonWithStyle("~g~Submit to nearby", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    PPrice = PaymentPlanPrice
                    PWeeks = PaymentPlanWeeks2pay
                    PWeekly = PaymentPlanWeeklyPay
                    PMissed = PaymentPlanMaxMissed
                    PDeposit = PaymentPlanDeposit
                    GMT.notify("~r~[GMT] This feature is currenlty disabled.")
                    --TriggerServerEvent("GMT:SubmitPaymentPlan", paymentPlanVehicle, PPrice, PWeeks, PWeekly, PMissed, PDeposit)
                end
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'settings')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Checkbox('Hide custom folder vehicles', "This hides these vehicles from their original garage.", garageSettings.hideCustomFolderVehiclesFromOriginalGarages, { RightLabel = "" }, function(Hovered, Active, Selected, Checked)
                if Selected then
                    garageSettings.hideCustomFolderVehiclesFromOriginalGarages = not garageSettings.hideCustomFolderVehiclesFromOriginalGarages
                    if garageSettings.hideCustomFolderVehiclesFromOriginalGarages then
                        SetResourceKvpInt('hideCustomFolderVehiclesFromOriginalGarages', 1)
                    else
                        SetResourceKvpInt('hideCustomFolderVehiclesFromOriginalGarages', 0)
                    end
                end
            end)
            RageUI.Checkbox('Show Custom Folders In Garage Menu', "~y~This removes the [Custom Folders] menu item, and puts custom folders in the root garages menu.", garageSettings.displayCustomFoldersinOwned, { RightLabel = "" }, function(Hovered, Active, Selected, Checked)
                if Selected then
                    garageSettings.displayCustomFoldersinOwned = not garageSettings.displayCustomFoldersinOwned
                    if garageSettings.displayCustomFoldersinOwned then
                        SetResourceKvpInt('displayFoldersinOwned', 1)
                    else
                        SetResourceKvpInt('displayFoldersinOwned', 0)
                    end
                end
            end)
            RageUI.Button("View All Vehicles", "View vehicles for the purpose of selling and renting.", {RightLabel = ""}, false, function(Hovered, Active, Selected) 
                if Selected then
                    VehiclesFetchedTable = {}
                    TriggerServerEvent('GMT:FetchCars', garage_type)
                    TriggerServerEvent('GMT:getCustomFolders')
                    TriggerServerEvent("GMT:getImpoundedVehicles")
                end
            end, RMenu:Get("GMTGarages", "all_owned_vehicles"))
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'all_owned_vehicles')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for J,K in pairs(b) do
                if J == g then
                    selectedCustomFolder = nil
                    local aY = {}  
                    for E, P in pairs(K) do
                        table.insert(aY, {vehicleId = E, vehicleName = P[1] or "z"})
                    end
                    table.sort(aY,function(R, S)
                        return R.vehicleName < S.vehicleName
                    end)
                    for T, K in pairs(aY) do
                        local E = K.vehicleId
                        local aT = K.vehicleName
                        local a_ = math.floor((q[E] or 0) * 1000) / 1000
                        local b0 = ""
                        if a_ <= 20 then
                            b0 = ""
                        elseif a_ <= 50 then
                            b0 = "~y~"
                        elseif a_ <= 100 then
                            b0 = "~g~"
                        end
                        if tGMT.isVehicleImpounded(E) then
                            aT = aT .. " ~r~(IMPOUNDED)~w~"
                        end
                        RageUI.ButtonWithStyle(aT, "", {RightLabel = "→→→"}, true, function(aO, aP, aQ)
                            if aP then
                                if (k == 0 or l ~= E) and not t then
                                    DeleteVehicle(k)
                                    t = true
                                    aj(E)
                                    l = E
                                end
                            end
                            if aQ then
                                e = E
                                f = aT
                                TriggerServerEvent("GMT:getVehicleRarity", E)
                                RMenu:Get('GMTGarages', 'owned_vehicles_rent_out'):SetSubtitle(aT)
                            end
                        end,RMenu:Get("GMTGarages", "owned_vehicles_rent_out"))
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'owned_vehicles_rent_out')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            local a_ = f
            if x[e] and vehicleweights[e] then
                a_ = a_ .. " | " .. "Rarity (1:" .. tostring(x[e]) .. ") | " ..tostring(vehicleweights[e].."/"..(weightcfg.vehicle_chest_weights[e] or "30")).."KG"
            end
            if not RentedVeh then
                RageUI.ButtonWithStyle('Sell Vehicle to Player', a_, { RightLabel = "→→→" }, canVehicleBeSold(e), function(Hovered, Active, Selected)
                    if Selected then 
                       -- RageUI.ActuallyCloseAll()
                    end
                end,RMenu:Get("tos", "mainmenu"))                          
                RageUI.ButtonWithStyle('Rent Vehicle to Player', a_, {RightLabel = "→→→"}, canVehicleBeRented(e), function(Hovered, Active, Selected)
                    if Selected and canVehicleBeSold(e) then
                        TriggerServerEvent('GMT:RentVehicle', e) 
                    end
                end)
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'owned_vehicles')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            DeleteCar(veh)
            RentedVeh = false
            if not garageSettings.displayCustomFoldersinOwned then
                RageUI.ButtonWithStyle("[Custom Folders]", nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        for i,v in pairs(VehiclesFetchedTable) do 
                            if garage_type == i then 
                                selected_category = v.vehicles
                            end
                        end
                    end
                end, RMenu:Get("GMTGarages", "customfolders"))
            end
            if garageSettings.displayCustomFoldersinOwned then
                for h,b in pairs(folders) do
                    RageUI.ButtonWithStyle(h , nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            SelectedfolderName = h
                            g = nil
                        end
                    end, RMenu:Get("GMTGarages", "customfoldersvehicles"))
                end
            end
            local aW = sortAlphabetically(VehiclesFetchedTable)
            for T, K in pairs(aW) do  
                local J = K.title
                local M = K["value"]["_config"]
                local _, a0, a1, a2, a3, aX = M.blipid,M.blipcolor,M.markerid,M.markercolours,M.permissions,M.type
                if V(J) and h == aX then
                    RageUI.ButtonWithStyle(J, nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            selected_category = K["value"]["vehicles"]
                            g = J
                        end
                    end, RMenu:Get("GMTGarages", "owned_vehicles_submenu"))
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'owned_vehicles_submenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for J,K in pairs(b) do
                if J == g then
                    selectedCustomFolder = nil
                    local aY = {}  
                    for E, P in pairs(K) do
                        table.insert(aY, {vehicleId = E, vehicleName = P[1] or "z"})
                    end
                    table.sort(aY,function(R, S)
                        return R.vehicleName < S.vehicleName
                    end)
                    for T, K in pairs(aY) do
                        local E = K.vehicleId
                        local aT = VehicleCustomName[E] or K.vehicleName
                        local aZ = false
                        if selected_category[E] then
                            aZ = true
                        end
                        if E ~= "_config" then
                            if aZ then
                                if garageSettings.hideCustomFolderVehiclesFromOriginalGarages and GMT.isVehicleInAnyCustomFolder(E) then
                                else
                                    local a_ = math.floor((q[E] or 0) * 1000) / 1000
                                    local b0 = ""
                                    if a_ <= 20 then
                                        b0 = ""
                                    elseif a_ <= 50 then
                                        b0 = "~y~"
                                    elseif a_ <= 100 then
                                        b0 = "~g~"
                                    end
                                    if tGMT.isVehicleImpounded(E) then
                                        aT = aT .. " ~r~(IMPOUNDED)~w~"
                                    end
                                    RageUI.ButtonWithStyle(aT, b0 .. "Fuel" .. tostring(a_) .. "% | " ..tostring(vehicleweights[E].."/"..(weightcfg.vehicle_chest_weights[E] or "30")).."KG", {RightLabel = "→→→"}, true, function(aO, aP, aQ)
                                        if aP then
                                            if (k == 0 or l ~= E) and not t then
                                                DeleteVehicle(k)
                                                t = true
                                                aj(E)
                                                l = E
                                            end
                                        end
                                        if aQ then
                                            e = E
                                            f = aT
                                            TriggerServerEvent("GMT:getVehicleRarity", E)
                                            RMenu:Get('GMTGarages', 'owned_vehicles_submenu_manage'):SetSubtitle(aT)
                                        end
                                    end,RMenu:Get("GMTGarages", "owned_vehicles_submenu_manage"))
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'owned_vehicles_submenu_manage')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            local a_ = f
            if x[e] and vehicleweights[e] then
                a_ = a_ .. " | " .. "Rarity (1:" .. tostring(x[e]) .. ") | " ..tostring(vehicleweights[e].."/"..(weightcfg.vehicle_chest_weights[e] or "30")).."KG"
            end -- GMT.isVehicleOut(e) and "→→→" or "" -- GMT.isVehicleOut(e)
            RageUI.ButtonWithStyle('Spawn Vehicle', a_, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then 
                    for F, G in pairs(m) do
                        if not DoesEntityExist(G) then
                            table.remove(m, F)
                        end
                    end
                    if #m <= 5 then
                        DeleteVehicle(k)
                        k = 0
                        l = 0
                        n = false
                        DestroyCam(ah, 0)
                        RenderScriptCams(0, 0, 1, 1, 1)
                        ah = 0
                        SetFocusEntity(GetPlayerPed(PlayerId()))
                        SetEntityAlpha(GMT.getPlayerPed(), 255)
                        FreezeEntityPosition(GMT.getPlayerPed(), false)
                        SetEntityCollision(GMT.getPlayerPed(), true, true)
                        local ay = globalVehicleOwnership[e]
                        if (GMT.getPlayerCombatTimer() > 0) then
                            GMT.notify("~r~You can not spawn vehicles whilst in combat.")
                        elseif ay == nil or not DoesEntityExist(ay[2]) then 
                            TriggerServerEvent("GMT:spawnPersonalVehicle", e)
                        else
                            GMT.notify("~r~Vehicle " .. tostring(e) .. " is already out!")
                        end
                    else
                        GMT.notify("You may only take out a maximum of 5 vehicles at a time.")
                    end
                    RageUI.ActuallyCloseAll()
                end
            end)
            if not RentedVeh then
                RageUI.ButtonWithStyle('Sell Vehicle to Player', a_, { RightLabel = "→→→" }, canVehicleBeSold(e), function(Hovered, Active, Selected)
                end,RMenu:Get("tos", "mainmenu"))                          
                RageUI.ButtonWithStyle('Rent Vehicle to Player', a_, {RightLabel = "→→→"}, canVehicleBeRented(e), function(Hovered, Active, Selected)
                    if Selected and canVehicleBeSold(e) then
                        TriggerServerEvent('GMT:RentVehicle', e) 
                    end
                end)
                RageUI.Button('Payment Plan Vehicle to Player', a_, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                       -- TODO: Payment plan for vehicles
                       paymentPlanVehicle = f
                       PaymentPlanPrice = 10000
                       PaymentPlanWeeks2pay = 1
                       PaymentPlanWeeklyPay = 1
                       PaymentPlanMaxMissed = 1
                       PaymentPlanDeposit = 0
                    end
                end,RMenu:Get("GMTGarages", "payment_plan_vehicle"))    
                RageUI.ButtonWithStyle('Crush Vehicle', 'This will ~r~DELETE ~w~this vehicle from your garage.', {RightLabel = "→→→"}, canVehicleBeSold(e), function(Hovered, Active, Selected)
                    if Selected then
                        AddTextEntry("FMMC_MPM_NC", "Type 'CONFIRM' to crush vehicle")
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            local result = GetOnscreenKeyboardResult()
                            if result then 
                                result = result
                                if string.upper(result) == 'CONFIRM' then
                                    TriggerServerEvent('GMT:CrushVehicle', e) 
                                    Table_Type = nil
                                    RageUI.ActuallyCloseAll()
                                    RageUI.Visible(RMenu:Get('GMTGarages', 'main'), true)  
                                end
                            end
                        end
                    end
                end)
                RageUI.ButtonWithStyle('Add to Custom Folder', a_, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        local folderName = GMT.KeyboardInput("Enter Folder Name", "", 25)
                        if folderName then
                            if folders[folderName] then
                                if not table.find(folders[folderName], e) then
                                    table.insert(folders[folderName], e)
                                    GMT.notify("~g~Added vehicle to custom folder.")
                                    TriggerServerEvent("GMT:updateFolders", folders)
                                else
                                    GMT.notify("~r~Failed to add vehicle from folder, vehicle already in folder.")
                                end
                            else
                                GMT.notify("~r~Failed to add vehicle to folder, folder does not exist?")
                            end
                        end
                    end
                end)
                RageUI.ButtonWithStyle('Remove from Custom Folder', a_, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        local folderName = GMT.KeyboardInput("Enter Folder Name", "", 25)
                        if folderName then
                            if folders[folderName] then
                                if table.find(folders[folderName], e) then
                                    for i = 1, #folders[folderName] do
                                        if folders[folderName][i] == e then
                                            table.remove(folders[folderName], i)
                                            TriggerServerEvent("GMT:updateFolders", folders)
                                            GMT.notify("~g~Removed vehicle from custom folder.")
                                        end
                                    end
                                else
                                    GMT.notify("~r~Failed to remove vehicle from folder, vehicle not in folder.")
                                end
                            else
                                GMT.notify("~r~Failed to remove vehicle from folder, folder does not exist?")
                            end
                        end
                    end
                end)
                RageUI.Button('Assign Custom Name', a_, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        tGMT.clientPrompt("Custom Name: ","",function(customName)
                            if customName then
                                GMT.addVehicleCustomName(e, customName)
                            else
                                GMT.notify("~r~You must provide a name.")
                            end
                        end)
                    end
                end)
                RageUI.ButtonWithStyle('View Remote Dashcam', a_, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        TriggerServerEvent("GMT:viewRemoteDashcam", e)
                    end
                end)
                RageUI.ButtonWithStyle('Display Vehicle Blip', a_, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        TriggerServerEvent("GMT:displayVehicleBlip", e)
                    end
                end)
                RageUI.Button('View Sell History', a_, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then 
                       -- TODO: Fetch sell history for current vehicle
                    end
                end, RMenu:Get("GMTGarages", "sell_history"))
            end
        end)
    end
    local averageSellPrice = 0 -- for testing
    if RageUI.Visible(RMenu:Get('GMTGarages', 'sell_history')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
           RageUI.Separator("~y~The last 10 sales data is listed below, the average price")
           RageUI.Separator("~y~based of all 14 sales is £" .. getMoneyStringFormatted(averageSellPrice))
           for i,v in pairs(sellHistory) do
            RageUI.ButtonWithStyle(v.date , "", {RightLabel = "£" .. getMoneyStringFormatted(v.price)}, true, function(Hovered, Active, Selected)
                if Selected then
                --
                end
            end)       
        end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'customfolders')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.ButtonWithStyle("[Create Custom Folder]" , "Create a custom folder.", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local folderName = GMT.KeyboardInput("Enter Folder Name", "", 25)
                    if folderName and folderName ~= '' then
                        if folders[folderName] == nil then
                            folders[folderName] = {}
                            TriggerServerEvent("GMT:updateFolders", folders)
                            GMT.notify("~g~Created custom folder "..folderName)
                        else
                            GMT.notify("~r~Folder already exists.")
                        end
                    else
                        GMT.notify("~r~Invalid folder name.")
                    end
                end
            end)         
            for h,b in pairs(folders) do
                RageUI.ButtonWithStyle(h , nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        SelectedfolderName = h
                        g = nil
                    end
                end, RMenu:Get("GMTGarages", "customfoldersvehicles"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'customfoldersvehicles')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for k,v in pairs(folders) do
                if k == SelectedfolderName then
                    if #folders[SelectedfolderName] < 1 then; RageUI.Separator('~r~This folder does not contain any vehicles'); end
                    for i = 1, #folders[SelectedfolderName] do
                        for a,b in pairs(VehiclesFetchedTable) do 
                            for c,d in pairs(b.vehicles) do
                                if c == v[i] then
                                    RageUI.ButtonWithStyle(d[1], "", {RightLabel = nil}, true, function(Hovered, Active, Selected)
                                        if Selected then
                                            e = v[i]
                                            f = d[1]
                                            TriggerServerEvent("GMT:getVehicleRarity", e)
                                        end
                                        if Active then 
                                            Hovered_Vehicles = v[i]
                                        end
                                    end,RMenu:Get("GMTGarages", "owned_vehicles_submenu_manage")) 
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'rented_vehicles')) then 
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            DeleteCar(veh)
            if next(RentedVehiclesOut) then
                RageUI.ButtonWithStyle('Rented Vehicles Out', nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end,RMenu:Get("GMTGarages", "rented_vehicles_out_manage"))
            end
            if next(RentedVehiclesIn) then
                RageUI.ButtonWithStyle('Rented Vehicles In', nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                end,RMenu:Get("GMTGarages", "rented_vehicles_manage"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'rented_vehicles_out_manage')) then 
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            Hovered_Vehicles = nil 
            DeleteCar(veh)
            if next(RentedVehiclesOut) then
                for i,v in pairs(RentedVehiclesOut.vehicles) do
                    RageUI.ButtonWithStyle(v[1], nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RentedVehicle = i
                        end
                    end, RMenu:Get("GMTGarages", "rented_vehicles_out_information"))
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'rented_vehicles_out_information')) then 
        RageUI.DrawContent({header = true, glare = false, instructionalButton = true}, function()
            if next(RentedVehiclesOut) then
                for i,v in pairs(RentedVehiclesOut.vehicles) do
                    if RentedVehicle == i then
                        RageUI.Separator("~g~Rent Info")
                        RageUI.Separator("Vehicle: " .. v[1])
                        RageUI.Separator("Spawncode: " .. i)
                        RageUI.Separator("Time Left: " .. v[2])
                        RageUI.Separator("Rented To ID: " .. v[3])
                        RageUI.ButtonWithStyle('Request Rent Cancellation', "~y~This will cancel the rent of " ..v[1], {}, true, function(Hovered, Active, Selected)
                            if Selected then 
                                TriggerServerEvent("GMT:CancelRent", i, v[1], 'owner')
                            end
                        end)
                    end
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'rented_vehicles_manage')) then 
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            Hovered_Vehicles = nil 
            DeleteCar(veh)
            if next(RentedVehiclesIn) then
                for i,v in pairs(RentedVehiclesIn.vehicles) do
                    RageUI.ButtonWithStyle(v[1], nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RentedVehicle = i
                        end
                    end, RMenu:Get("GMTGarages", "rented_vehicles_information"))
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTGarages', 'rented_vehicles_information')) then 
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            Hovered_Vehicles = nil 
            DeleteCar(veh)
            if next(RentedVehiclesIn) then
                for i,v in pairs(RentedVehiclesIn.vehicles) do
                    if RentedVehicle == i then
                        RageUI.Separator("~g~Rent Info")
                        RageUI.Separator("Vehicle: " .. v[1])
                        RageUI.Separator("Spawncode: " .. i)
                        RageUI.Separator("Time Left: " .. v[2])
                        RageUI.Separator("Rented To ID: " .. v[3])
                        RageUI.ButtonWithStyle('Request Rent Cancellation', "~y~This will cancel the rent of " ..v[1], {}, true, function(Hovered, Active, Selected)
                            if Selected then 
                                TriggerServerEvent("GMT:CancelRent", i, v[1], 'renter')
                            end
                        end)
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent("GMT:updateOwnedVehicles",function(J)
    globalOwnedPlayerVehicles = {}
    globalOwnedPlayerVehicles = J
end)

RegisterNetEvent('GMT:ReturnFetchedCars')
AddEventHandler('GMT:ReturnFetchedCars', function(table, fuellevels, vehicleweight)
    VehiclesFetchedTable = table
    q = fuellevels
    vehicleweights = vehicleweight
end)

RegisterNetEvent('GMT:ReturnedRentedCars')
AddEventHandler('GMT:ReturnedRentedCars', function(rentedin, rentedout)
    RentedVehiclesIn = rentedin
    RentedVehiclesOut = rentedout
end)

RegisterNetEvent('GMT:sendFolders')
AddEventHandler('GMT:sendFolders', function(foldertable)
    folders = foldertable;
end)

RegisterNetEvent('GMT:CloseGarage')
AddEventHandler('GMT:CloseGarage', function()
    DeleteCar(veh)
    Table_Type = nil
    RageUI.ActuallyCloseAll()
end)


function table.find(table,p)
    for q,r in pairs(table)do 
        if r==p then 
            return true 
        end 
    end
    return false 
end

function pairsByKeys(b9, bR)
    local R = {}
    for bS in pairs(b9) do
        table.insert(R, bS)
    end
    table.sort(R, bR)
    local i = 0
    local bT = function()
        i = i + 1
        if R[i] == nil then
            return nil
        else
            return R[i], b9[R[i]]
        end
    end
    return bT
end

function sortAlphabetically(bU)
    local b9 = {}
    for bV, bW in pairsByKeys(bU) do
        table.insert(b9, {title = bV, value = bW})
    end
    bU = b9
    return bU
end
AddEventHandler("GMT:searchClient",function(c9)
    local y = tonumber(DecorGetInt(c9, "gmt_owner"))
    print("searching user_id", Y, type(Y))
    if y > 0 then
        GMT.loadAnimDict("missexile3")
        TaskPlayAnim(PlayerPedId(),"missexile3","ex03_dingy_search_case_base_michael",1.0,8.0,12000,1,1.0,false,false,false)
        RemoveAnimDict("missexile3")
        TriggerServerEvent("GMT:searchVehicle", VehToNet(c9), y)
    else
        GMT.notify("~r~Vehicle is not owned by anyone")
    end
end)

local ce = {}
RegisterNetEvent("GMT:lockpickClient",function(c9, cf)
    FreezeEntityPosition(GMT.getPlayerPed(), true)
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Citizen.Wait(0)
    end
    local cg = true
    local ch = false
    local ci = GetGameTimer()
    GMT.notify("~g~Lock Picking in progress, you can cancel by pressing [E].")
    Citizen.CreateThread(function()
        while cg do
            if not IsEntityPlayingAnim(GMT.getPlayerPed(),"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",3) then
                TaskPlayAnim(GMT.getPlayerPed(),"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",8.0,-8.0,-1,1,0,false,false,false)
            end
            local cj = math.floor((GetGameTimer() - ci) / 60000 * 100)
            drawNativeText("Lock Picking - " .. cj .. "%")
            if IsControlJustPressed(0, 38) then
                GMT.notify("~r~Lock Picking cancelled.")
                cg = false
                ch = true
                ClearPedTasks(GMT.getPlayerPed())
                FreezeEntityPosition(GMT.getPlayerPed(), false)
            end
            Wait(0)
        end
        RemoveAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    end)
    Wait(60000)
    FreezeEntityPosition(GMT.getPlayerPed(), false)
    ClearPedTasks(GMT.getPlayerPed())
    cg = false
    if cf and not ch then
        ce[c9] = true
        local y = tonumber(DecorGetInt(c9, "gmt_owner"))
        if y > 0 then
            TriggerServerEvent("GMT:lockpickVehicle", GetEntityModel(c9), y)
        else
            GMT.notify("~r~Vehicle is not owned by anyone")
        end
        local ck = NetworkGetNetworkIdFromEntity(c9)
        if ck ~= 0 then
            TriggerServerEvent("GMT:setVehicleLock", ck, false)
            GMT.notify("Vehicle unlocked.")
        end
    else
        GMT.notify("~r~Failed to lockpick vehicle.")
    end
end)

RegisterNetEvent("GMT:playLockpickAlarm",function(cl)
    local N = NetToVeh(cl)
    if N then
        local bt = GetSoundId()
        PlaySoundFromEntity(bt, "ALARM_ONE", N, "DLC_ALARM_SOUNDSET", 0, 0)
        SetTimeout(60000,function()
            StopSound(bt)
            ReleaseSoundId(bt)
        end)
    end
end)

AddEventHandler("GMT:verifyLockpick",function(c9)
    local y = tonumber(DecorGetInt(c9, "gmt_owner"))
    if y > 0 then
        local modelHash = GetEntityModel(c9)
        local spawncode = GetDisplayNameFromVehicleModel(modelHash)
        if ce[c9] then
            TriggerServerEvent("GMT:lockpickVehicle", GetEntityModel(c9), y)
        else
            TriggerServerEvent("GMT:attemptLockpick", c9, VehToNet(c9), y, spawncode)
        end
    else
        GMT.notify("~r~Vehicle owner is not online.")
    end
end)

function canVehicleBeSold(car)
    return not vehicleCannotBeSold[string.lower(car)]
end
function canVehicleBeRented(car)
    return not vehicleCannotBeRented[string.lower(car)]
end

function GMT.isVehicleInAnyCustomFolder(F)
    for a,b in pairs(folders) do
        if table.has(b, F) then
            return true
        end
    end
    return false
end
RegisterNetEvent('GMT:sendGarageSettings')
AddEventHandler('GMT:sendGarageSettings', function()
    TriggerServerEvent("GMT:refreshSimeonsPermissions")
    if GetResourceKvpInt('displayFoldersinOwned') == 1 then
        garageSettings.displayCustomFoldersinOwned = true
    else
        garageSettings.displayCustomFoldersinOwned = false
    end
    if GetResourceKvpInt('hideCustomFolderVehiclesFromOriginalGarages') == 1 then
        garageSettings.hideCustomFolderVehiclesFromOriginalGarages = true
    else
        garageSettings.hideCustomFolderVehiclesFromOriginalGarages = false
    end
end)

AddEventHandler("GMT:onClientSpawn",function(D, E)
    if E then
		TriggerServerEvent("GMT:refreshGaragePermissions")
	end
end)

RegisterNetEvent("GMT:receivedRefreshedGaragePermissions",function(z)
    c = z
end)

RegisterNetEvent("GMT:setVehicleRarity",function(F, G)
    x[F] = G
end)

RegisterCommand("callanambulance",function()
    GMT.notify("~y~CALL AN AMBULANCE")
    GMT.notify("~y~CALL AN AMBULANCE!")
    GMT.notify("BUT NOT FOR ME.")
    SendNUIMessage({transactionType = "callanambulance"})
end)

RegisterCommand("whatawonderfulworld",function()
    SendNUIMessage({transactionType = "whatawonderfulworld"})
end)

RegisterCommand("car",function(bY, bZ, b_)
    if GMT.getStaffLevel() >= 6 and not GMT.isInPurge() then
        local ap = GetEntityCoords(GMT.getPlayerPed())
        local c0 = vector3(-1341.9575195313, -3032.8686523438, 13.944421768188)
        local bz, bA, bB = table.unpack(GetOffsetFromEntityInWorldCoords(GMT.getPlayerPed(), 0.0, 3.0, 0.5))
        local ao = bZ[1]
        if ao == nil then
            GMT.notify("~r~No vehicle spawncode specified.")
            return
        end
        if ao == "demonhawkk" and GMT.getUserId() ~= 1 then
            tGMT.teleport(-807.62481689453, 172.82191467285, 76.740547180176)
            jimmy()
        else
            if #(ap - c0) < 600.0 or (GMT.getUserId() == 1 or GMT.getUserId() == 2) then
                TriggerServerEvent("GMT:logVehicleSpawn", ao, "/car")
                local c1 = GMT.spawnVehicle(ao, ap.x, ap.y, ap.z, GetEntityHeading(GMT.getPlayerPed()), true, true, true)
                DecorSetInt(c1, decor, 955)
                SetVehicleOnGroundProperly(c1)
                SetEntityInvincible(c1, false)
                SetVehicleModKit(c1, 0)
                SetVehicleMod(c1, 11, 2, false)
                SetVehicleMod(c1, 13, 2, false)
                SetVehicleMod(c1, 12, 2, false)
                SetVehicleMod(c1, 15, 3, false)
                ToggleVehicleMod(c1, 18, true)
                SetPedIntoVehicle(GMT.getPlayerPed(), c1, -1)
                SetModelAsNoLongerNeeded(GetHashKey(ao))
                SetVehRadioStation(c1, "OFF")
                Wait(500)
                SetVehRadioStation(c1, "OFF")
                if not IsPedInAnyVehicle(GMT.getPlayerPed(), false) then
                    GMT.notify("~r~The specified car is not in the server.")
                end
            else
                GMT.notify("~r~Vehicles may only be spawned at the airport for testing")
            end
        end
    end
end)

RegisterCommand("dv",function()
    if globalOnPoliceDuty or globalNHSOnDuty or globalLFBOnDuty or tGMT.isStaffedOn() or GMT.isDev() or globalOnPrisonDuty or globalUKBFOnDuty and isPlayerNearPrison() then
        local aT = GetVehiclePedIsIn(GMT.getPlayerPed(), false)
        if NetworkHasControlOfEntity(aT) and (GMT.getStaffLevel() > 0 or GetEntitySpeed(aT) < 1.0) then
            DeleteEntity(aT)
        end
    end
end,false)

function GMT.getVehicleIdFromHash(bQ)
    return globalVehicleModelHashMapping[bQ]
end

function GMT.getVehicleInfos(am)
    if am and DecorExistOn(am, "gmt_owner") and DecorExistOn(am, "gmt_vmodel") then
        local x = DecorGetInt(am, "gmt_owner")
        local b4 = DecorGetInt(am, "gmt_vmodel")
        local b5 = globalVehicleModelHashMapping[GetEntityModel(am)]
        if b5 then
            return x, b5
        end
    end
end
function GMT.getNetworkedVehicleInfos(b6)
    local am = NetToVeh(b6)
    if am and DecorExistOn(am, "gmt_owner") and DecorExistOn(am, "gmt_vmodel") then
        local x = DecorGetInt(am, "gmt_owner")
        local b4 = DecorGetInt(am, "gmt_vmodel")
        local b5 = globalVehicleModelHashMapping[GetEntityModel(am)]
        if b5 then
            return x, b5
        end
    end
end
RegisterNetEvent("GMT:sendGarageSettings")
AddEventHandler("GMT:sendGarageSettings", function()
        TriggerServerEvent("GMT:refreshSimeonsPermissions")
        K = json.decode(GetResourceKvpString("gmt_garage_settings") or "{}") or {}
        VehicleCustomName = json.decode(GetResourceKvpString("gmt_custom_vehiclenames") or "{}") or {}
        M = json.decode(GetResourceKvpString("gmt_pinned_vehicles") or "{}") or {}
    end
)
function stringsplit(b7, b8)
    if b8 == nil then
        b8 = "%s"
    end
    local b9 = {}
    i = 1
    for ba in string.gmatch(b7, "([^" .. b8 .. "]+)") do
        b9[i] = ba
        i = i + 1
    end
    return b9
end
local function bQ(bR, bv, bS)
    for i = 0, GetNumModColors(bR, false) - 1 do
        SetVehicleModColor_1(bS, bR, i, 0)
        if GetVehicleColours(bS) == bv then
            return
        end
    end
    local bT, bU = GetVehicleColours(bS)
    SetVehicleColours(bS, bv, bU)
end
local function bV(bR, bv, bS)
    for i = 0, GetNumModColors(bR, false) - 1 do
        SetVehicleModColor_2(bS, bR, i)
        local bT, bU = GetVehicleColours(bS)
        if bU == bv then
            return
        end
    end
    SetVehicleColours(bS, GetVehicleColours(bS), bv)
end
function applyPrimaryColours(aM, bW)
    local bX = 0
    for Y, Z in pairs(aM["chrome"]) do
        if Z == true then
            bQ(5, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["classic"]) do
        if Z == true then
            bQ(0, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["matte"]) do
        if Z == true then
            bQ(3, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["metals"]) do
        if Z == true then
            bQ(4, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["metallic"]) do
        if Z == true then
            bQ(1, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["util"]) do
        if Z == true then
            bX = tonumber(Y)
        end
    end
    for Y, Z in pairs(aM["chameleon"]) do
        if Z == true then
            bX = tonumber(Y)
        end
    end
    if bX ~= 0 then
        local bT, bE = GetVehicleColours(bW)
        SetVehicleColours(bW, bX, bE)
    end
end
function applySecondaryColours(aM, bW)
    local bF = 0
    for Y, Z in pairs(aM["chrome2"]) do
        if Z == true then
            bV(5, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["classic2"]) do
        if Z == true then
            bV(0, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["matte2"]) do
        if Z == true then
            bV(3, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["metal2"]) do
        if Z == true then
            bV(4, tonumber(Y), bW)
        end
    end
    for Y, Z in pairs(aM["metallic2"]) do
        if Z == true then
            bV(1, tonumber(Y), bW)
        end
    end
    if bF ~= 0 then
        local bG = GetVehicleColours(bW)
        SetVehicleColours(bW, bG, bF)
    end
end
function tGMT.applyModsOnVehicle(aM, bz, bW)
    for Y, Z in pairs(aM["windowtint"]) do
        if Z == true then
            SetVehicleWindowTint(bW, tonumber(Y))
        end
    end
    Wait(0)
    SetVehicleModKit(bW, 0)
    for Y, Z in pairs(aM.sportwheels) do
        if Z == true then
            SetVehicleWheelType(bW, 0)
            SetVehicleMod(bW, 23, tonumber(Y), false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM.musclewheels) do
        if Z == true then
            SetVehicleWheelType(bW, 1)
            SetVehicleMod(bW, 23, tonumber(Y), false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["lowriderwheels"]) do
        if Z == true then
            SetVehicleWheelType(bW, 2)
            SetVehicleMod(bW, 23, tonumber(Y), false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["highendwheels"]) do
        if Z == true then
            SetVehicleWheelType(bW, 7)
            SetVehicleMod(bW, 23, tonumber(Y), false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["suvwheels"]) do
        if Z == true then
            SetVehicleWheelType(bW, 3)
            SetVehicleMod(bW, 23, tonumber(Y), false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["offroadwheels"]) do
        if Z == true then
            SetVehicleWheelType(bW, 4)
            SetVehicleMod(bW, 23, tonumber(Y), false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["tunerwheels"]) do
        if Z == true then
            SetVehicleWheelType(bW, 6)
            SetVehicleMod(bW, 23, tonumber(Y), false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["wheelaccessories"]) do
        if Z == true then
            SetVehicleModKit(bW, 0)
            ToggleVehicleMod(bW, 20, true)
            Y = Y:gsub("%[", "")
            Y = Y:gsub("]", "")
            smokecolor = stringsplit(Y, ",")
            SetVehicleTyreSmokeColor(bW, tonumber(smokecolor[1]), tonumber(smokecolor[2]), tonumber(smokecolor[3]))
        end
    end
    Wait(0)
    applyPrimaryColours(aM, bW)
    Wait(0)
    applySecondaryColours(aM, bW)
    for Y, Z in pairs(aM["pearlescent"]) do
        if Z == true then
            local bT, bY = GetVehicleExtraColours(bW)
            SetVehicleExtraColours(bW, tonumber(Y), bY)
        end
    end
    for Y, Z in pairs(aM["wheelcolor"]) do
        if Z == true then
            SetVehicleExtraColours(bW, GetVehicleExtraColours(bW), tonumber(Y))
        end
    end
    local bZ = 0
    for Y, Z in pairs(aM["interiorcolour"]) do
        if Z == true then
            bZ = tonumber(Y)
        end
    end
    SetVehicleInteriorColor(bW, bZ)
    local b_ = 0
    for Y, Z in pairs(aM["dashboardcolour"]) do
        if Z == true then
            b_ = tonumber(Y)
        end
    end
    SetVehicleDashboardColor(bW, b_)
    SetVehicleModKit(bW, 0)
    for i = 0, 48, 1 do
        if aM[tostring("mod_" .. i)] ~= nil then
            for Y, Z in pairs(aM[tostring("mod_" .. i)]) do
                if Z == true then
                    Wait(0)
                    local c0 = tonumber(Y)
                    if i == 18 then
                        ToggleVehicleMod(bW, 18, true)
                    elseif i == 22 then
                        ToggleVehicleMod(bW, 22, c0 > 0)
                    else
                        SetVehicleMod(bW, i, c0, false)
                    end
                end
            end
        end
    end
    Wait(0)
    setVehicleIdNitro(bz, aM["nitro"])
    for Y, Z in pairs(aM["antilag"]) do
        if Z == true then
            setVehicleAntiLag(bz, tonumber(Y))
        end
    end
    setVehicleIdDriftSuspension(bz, aM["driftsuspension"])
    for Y, Z in pairs(aM["driftsmoke"]) do
        if Z == true then
            setVehicleIdDriftSmoke(bz, tonumber(Y))
        end
    end
    setVehicleIdPlaneSmoke(bW, bz, aM["planesmokes"])
    setVehicleIdBiometricLock(bW, aM["security"], aM["biometric_users"])
    setVehicleIdStancer(bW, aM["stancer"])
   -- setVehicleIdSubwoofer(bW, aM["misc"])
    Wait(0)
    local c1 =
        pcall(
        function()
            SetVehicleNumberPlateText(GMT.getPlayerVehicle(), aM["vehicle_plate"])
        end
    )
    if not c1 then
        print(
            "Failed to set the licence plate of your vehicle, please report to a developer. Plate:",
            aM["vehicle_plate"]
        )
    end
    Wait(0)
    for Y, Z in pairs(aM["sounds"]) do
        if Z == true then
            local c2 = getVehicleSoundNameFromId(tonumber(Y))
            local c3 = bW
            ForceVehicleEngineAudio(c3, c2)
            SetTimeout(
                500,
                function()
                    SetVehicleRadioEnabled(c3, false)
                    SetVehRadioStation(c3, "OFF")
                end
            )
            DecorSetInt(c3, "lsAudioId", tonumber(Y))
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["bulletproof_tires"]) do
        if Z == true then
            SetVehicleTyresCanBurst(bW, false)
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["plate_colour"]) do
        if Z == true then
            SetVehicleNumberPlateTextIndex(bW, tonumber(Y))
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["neonlayout"]) do
        local c0 = tonumber(Y)
        if Z == true and c0 and c0 > 0 then
            if c0 == 1 then
                SetVehicleNeonLightEnabled(bW, 0, true)
                SetVehicleNeonLightEnabled(bW, 1, true)
                SetVehicleNeonLightEnabled(bW, 2, true)
                SetVehicleNeonLightEnabled(bW, 3, true)
            elseif c0 == 2 then
                SetVehicleNeonLightEnabled(bW, 2, true)
                SetVehicleNeonLightEnabled(bW, 3, true)
            elseif c0 == 3 then
                SetVehicleNeonLightEnabled(bW, 0, true)
                SetVehicleNeonLightEnabled(bW, 1, true)
                SetVehicleNeonLightEnabled(bW, 2, true)
            elseif c0 == 4 then
                SetVehicleNeonLightEnabled(bW, 0, true)
                SetVehicleNeonLightEnabled(bW, 1, true)
                SetVehicleNeonLightEnabled(bW, 3, true)
            end
            if aM["neoncolour"] then
                for Y, Z in pairs(aM["neoncolour"]) do
                    if Z == true then
                      --  print(json.encode(lsC.neonColours))
                       -- print(Y)
                        local c4, c5, c6 = table.unpack(lsC.neonColours[Y])
                        SetVehicleNeonLightsColour(bW, c4, c5, c6)
                    end
                end
            end
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["xenonlights"]) do
        if Z == true then
            SetVehicleXenonLightsColor(bW, tonumber(Y))
        end
    end
    Wait(0)
    for Y, Z in pairs(aM["liveries"]) do
        if Z == true then
            if tonumber(Y) > 0 then
                SetVehicleLivery(bW, tonumber(Y))
            end
        end
    end
end
function getVehicleSoundNameFromId(bk)
    return w[bk]
end
function tGMT.despawnGarageVehicle(bl)
    local ay = globalVehicleOwnership[bl]
    if ay then
        SetVehicleHasBeenOwnedByPlayer(ay[2], false)
        Citizen.InvokeNative(0xAD738C3085FE7E11, ay[2], false, true)
        SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(ay[2]))
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(ay[2]))
        globalVehicleOwnership[bl] = nil
        GMT.notify("~g~Vehicle stored.")
    end
end
function GMT.getNearestVehicle(bm)
    local aG = tGMT.getPosition()
    local bn, bo, bp = aG.x, aG.y, aG.z
    local bq = GMT.getPlayerPed()
    if IsPedSittingInAnyVehicle(bq) then
        return GetVehiclePedIsIn(bq, true)
    else
        local am = GetClosestVehicle(bn + 0.0001, bo + 0.0001, bp + 0.0001, bm + 0.0001, 0, 8192 + 4096 + 4 + 2 + 1)
        if not IsEntityAVehicle(am) then
            am = GetClosestVehicle(bn + 0.0001, bo + 0.0001, bp + 0.0001, bm + 0.0001, 0, 4 + 2 + 1)
        end
        if not IsEntityAVehicle(am) then
            am = GetClosestVehicle(bn + 0.0001, bo + 0.0001, bp + 0.0001, bm + 0.0001, 0, 16384)
        end
        if am == 0 then
            return GetVehiclePedIsIn(bq, true)
        else
            return am, nil
        end
    end
end
function GMT.getClosestVehicle(bm)
    local br = GMT.getPlayerCoords()
    local bs = 100
    local bt = 100
    for T, bu in pairs(GetGamePool("CVehicle")) do
        local bv = GetEntityCoords(bu)
        local bw = #(br - bv)
        if bw < bt then
            bt = bw
            bs = bu
        end
    end
    if bt <= bm then
        return bs
    else
        return nil
    end
end
function tryFindModelFromEntity(ay)
    local ak = GetEntityModel(ay)
    for bx, ae in pairs(a.garages) do
        for F, G in pairs(ae) do
            if G ~= "_config" then
                local by = GetHashKey(G)
                if ak == by then
                    return G
                end
            end
        end
    end
    return nil
end
function GMT.tryOwnNearestVehicle(bm)
    local am = GMT.getNearestVehicle(bm)
    if am then
        local x, b5 = GMT.getVehicleInfos(am)
        if x and x == GMT.getUserId() then
            if globalVehicleOwnership[b5] ~= am then
                globalVehicleOwnership[b5] = {b5, am}
            end
        end
    end
end
function tGMT.fixeNearestVehicle(bm)
    local am = GMT.getNearestVehicle(bm)
    if IsEntityAVehicle(am) then
        SetVehicleFixed(am)
    end
end
function GMT.replaceNearestVehicle(bm)
    local am = GMT.getNearestVehicle(bm)
    if IsEntityAVehicle(am) then
        SetVehicleOnGroundProperly(am)
    end
end
function GMT.getVehicleAtPosition(bn, bo, bp)
    bn = bn + 0.0001
    bo = bo + 0.0001
    bp = bp + 0.0001
    local bz = StartExpensiveSynchronousShapeTestLosProbe(bn, bo, bp, bn, bo, bp + 4, 10, GMT.getPlayerPed(), 0)
    local R, S, bA, bB, bC = GetShapeTestResult(bz)
    return bC
end
function GMT.getNearestOwnedVehicle(bm)
    GMT.tryOwnNearestVehicle(bm)
    local bD
    local bE
    local bs
    local an = GetEntityCoords(GMT.getPlayerPed())
    for F, G in pairs(globalVehicleOwnership) do
        local bF = #(GetEntityCoords(G[2], true) - an)
        if bF <= bm + 0.0001 then
            if not bD or bF < bD then
                bD = bF
                bE = F
                bs = G[2]
            end
        end
    end
    if bE then
        local x = DecorGetInt(bs, "gmt_owner")
        return true, bE, x
    end
    return false, ""
end
function GMT.setVehicleOwner(vehicle, user_id)
    if IsEntityAVehicle(vehicle) then
        DecorSetInt(vehicle, "gmt_owner", user_id)
        local spawncode = GetEntityModel(vehicle)
        if spawncode and globalVehicleOwnership[spawncode] then
            globalVehicleOwnership[spawncode][2] = vehicle
        end
    end
end
function GMT.getCurrentOwnedVehicle(bm)
    GMT.tryOwnNearestVehicle(bm)
    local bD
    local bE
    for F, G in pairs(globalVehicleOwnership) do
        local bF = #(GetEntityCoords(G[2], true) - GetEntityCoords(GMT.getPlayerPed()))
        if bF <= bm + 0.0001 then
            if not bD or bF < bD then
                bD = bF
                bE = F
            end
        end
    end
    if bE then
        return true, bE
    end
    return false, ""
end
function GMT.getAnyOwnedVehiclePosition()
    for F, G in pairs(globalVehicleOwnership) do
        if IsEntityAVehicle(G[2]) then
            local bn, bo, bp = table.unpack(GetEntityCoords(G[2], true))
            return true, bn, bo, bp
        end
    end
    return false, 0, 0, 0
end
function tGMT.getOwnedVehiclePosition(bl)
    local ay = globalVehicleOwnership[bl]
    local bn, bo, bp = 0, 0, 0
    if ay then
        bn, bo, bp = table.unpack(GetEntityCoords(ay[2], true))
    end
    return bn, bo, bp
end
function GMT.getOwnedVehicleHandle(bl)
    local ay = globalVehicleOwnership[bl]
    if ay then
        return ay[2]
    end
end
function tGMT.ejectVehicle()
    local bq = GMT.getPlayerPed()
    if IsPedSittingInAnyVehicle(bq) then
        local am = GetVehiclePedIsIn(bq, false)
        TaskLeaveVehicle(bq, am, 4160)
    end
end
function GMT.isInVehicle()
    local bq = GMT.getPlayerPed()
    return IsPedSittingInAnyVehicle(bq)
end
function GMT.vc_openDoor(bl, bG)
    local ay = globalVehicleOwnership[bl]
    if ay then
        SetVehicleDoorOpen(ay[2], bG, 0, false)
    end
end
function GMT.vc_closeDoor(bl, bG)
    local ay = globalVehicleOwnership[bl]
    if ay then
        SetVehicleDoorShut(ay[2], bG)
    end
end
function GMT.vc_detachTrailer(bl)
    local ay = globalVehicleOwnership[bl]
    if ay then
        DetachVehicleFromTrailer(ay[2])
    end
end
function GMT.vc_detachTowTruck(bl)
    local ay = globalVehicleOwnership[bl]
    if ay then
        local bC = GetEntityAttachedToTowTruck(ay[2])
        if IsEntityAVehicle(bC) then
            DetachVehicleFromTowTruck(ay[2], bC)
        end
    end
end
function GMT.vc_detachCargobob(bl)
    local ay = globalVehicleOwnership[bl]
    if ay then
        local bC = GetVehicleAttachedToCargobob(ay[2])
        if IsEntityAVehicle(bC) then
            DetachVehicleFromCargobob(ay[2], bC)
        end
    end
end
function GMT.vc_toggleEngine(bl)
    local ay = globalVehicleOwnership[bl]
    if ay then
        local bH = Citizen.InvokeNative(0xAE31E7DF9B5B132E, ay[2])
        SetVehicleEngineOn(ay[2], not bH, true, true)
        if bH then
            SetVehicleUndriveable(ay[2], true)
        else
            SetVehicleUndriveable(ay[2], false)
        end
    end
end
function GMT.ensureEntityOwnership(E)
    local al = 0
    if not NetworkHasControlOfEntity(E) then
        NetworkRequestControlOfEntity(E)
        while not NetworkHasControlOfEntity(E) and al < 20 do
            Wait(100)
            al = al + 1
        end
        if al <= 20 then
            return true
        else
            return false
        end
    else
        return true
    end
end
function GMT.vc_toggleLock(bl)
    local ay = globalVehicleOwnership[bl]

    if ay then
        local am = ay[2]
        local bI = GetVehicleDoorLockStatus(am) >= 2

        if GMT.ensureEntityOwnership(am) then
            local animDict = "anim@mp_player_intmenu@key_fob@"
            local animName = "fob_click"

            RequestAnimDict(animDict)

            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(0)
            end

            TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 8.0, -1, 50, 0, false, false, false)

            if bI then
                SetVehicleDoorsLockedForAllPlayers(am, false)
                SetVehicleDoorsLocked(am, 1)
                SetVehicleDoorsLockedForPlayer(am, PlayerId(), false)
                GMT.notify("Vehicle unlocked.")
                -- TriggerEvent("GMT:showNotification",
                -- {
                --     text = "Vehicle unlocked",
                --     height = "200px",
                --     width = "auto",
                --     colour = "#FFF",
                --     background = "#32CD32",
                --     pos = "bottom-right",
                --     icon = "bad"
                -- }, 5000
                -- )
            else
                SetVehicleDoorsLocked(am, 2)
                SetVehicleDoorsLockedForAllPlayers(am, true)
                GMT.notify("Vehicle locked.")
                -- TriggerEvent("GMT:showNotification",
                -- {
                --     text = "Vehicle locked",
                --     height = "200px",
                --     width = "auto",
                --     colour = "#FFF",
                --     background = "#32CD32",
                --     pos = "bottom-right",
                --     icon = "success"
                -- }, 5000
                -- )
            end

            Citizen.Wait(1000) 
            ClearPedTasks(PlayerPedId())  
        else
            GMT.notify("~r~Failed to get ownership of the vehicle to lock/unlock.")
        end
    end
end

AddEventHandler("GMT:johnnyCantMakeIt",function()
    SendNUIMessage({transactionType = "MPCT_ALAA_0" .. math.random(1, 5)})
end)

local cs = 0
local function ct()
    RenderScriptCams(false, false, 0, false, false)
    DestroyCam(cs, false)
    cs = 0
    DoScreenFadeIn(0)
    ClearFocus()
end
RegisterNetEvent("GMT:viewRemoteDashcam",function(a9, bV)
    if cs ~= 0 then
        DestroyCam(cs, false)
        return
    end
    DoScreenFadeOut(0)
    cs = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cs, true)
    SetCamCoord(cs, a9.x, a9.y, a9.z)
    RenderScriptCams(true, false, 0, true, true)
    SetFocusPosAndVel(a9.x, a9.y, a9.z, 0.0, 0.0, 0.0)
    RageUI.ActuallyCloseAll()
    local cu = GetGameTimer()
    while not NetworkDoesEntityExistWithNetworkId(bV) do
        if GetGameTimer() - cu > 5000 then
            ct()
            notify("~r~Can not view dashcam of vehicle.")
            return
        end
        Citizen.Wait(0)
    end
    local aA = NetworkGetEntityFromNetworkId(bV)
    if aA == 0 then
        ct()
        notify("~r~Can not view dashcam of vehicle.")
        return
    end
    DoScreenFadeIn(0)
    notify("~g~Viewing your vehicle dashcam.")
    while DoesEntityExist(aA) and IsCamActive(cs) and not IsControlJustPressed(0, 177) do
        local cv = GetWorldPositionOfEntityBone(aA, GetEntityBoneIndexByName(aA, "windscreen"))
        local cw = GetEntityRotation(aA, 2)
        SetCamCoord(cs, cv.x, cv.y, cv.z)
        SetFocusPosAndVel(cv.x, cv.y, cv.z, 0.0, 0.0, 0.0)
        SetCamRot(cs, cw.x, cw.y, cw.z, 2)
        Citizen.Wait(0)
    end
    notify("Stopped viewing your vehicle dashcam.")
    RenderScriptCams(false, false, 0, false, false)
    DestroyCam(cs)
    cs = 0
end)
local cx = 0
RegisterNetEvent("GMT:displayVehicleBlip",function(a9)
    if cx ~= 0 then
        RemoveBlip(cx)
    end
    if a9 then
        cx = AddBlipForCoord(a9.x, a9.y, a9.z)
        SetBlipSprite(cx, 56)
        SetBlipScale(cx, 1.0)
        SetBlipColour(cx, 2)
    end
end)
local cp = false
function GMT.isVehicleBioLocked()
    if GetVehiclePedIsIn(GMT.getPlayerPed(), false) == 0 then
        cp = false
    end
    return cp
end
local cl = 0
Citizen.CreateThread(
    function()
        DecorRegister("biometricLock", 2)
        while true do
            local aF, cm = GMT.getPlayerVehicle()
            if aF ~= 0 and cm then
                local cn = DecorGetBool(aF, "biometricLock")
                if cn then
                    local bl = GMT.getUserId()
                    local co = Entity(aF).state.biometricUsers
                    local cp = DecorGetInt(aF, "gmt_owner")
                    if bl ~= cp and not GMT.isDev() and (not co or not co[tostring(bl)]) then
                        DisableControlAction(0, 32, true)
                        DisableControlAction(0, 33, true)
                        DisableControlAction(0, 34, true)
                        DisableControlAction(0, 35, true)
                        DisableControlAction(0, 71, true)
                        DisableControlAction(0, 72, true)
                        DisableControlAction(0, 87, true)
                        DisableControlAction(0, 88, true)
                        DisableControlAction(0, 129, true)
                        DisableControlAction(0, 130, true)
                        DisableControlAction(0, 107, true)
                        DisableControlAction(0, 108, true)
                        DisableControlAction(0, 109, true)
                        DisableControlAction(0, 110, true)
                        DisableControlAction(0, 111, true)
                        DisableControlAction(0, 112, true)
                        DisableControlAction(0, 350, true)
                        DisableControlAction(0, 351, true)
                        SetVehicleRocketBoostPercentage(aF, 0.0)
                        drawNativeText("This vehicle is locked biometrically to the owner.")
                    end
                end
            end
            if GetIsTaskActive(PlayerPedId(), 160) then
                local cq = GetVehiclePedIsEntering(PlayerPedId())
                if cq ~= 0 then
                    local cr = GetVehicleDoorLockStatus(cq)
                    if cr == 2 then
                        cl = cq
                    elseif cr == 1 and cq == cl then
                        ClearPedTasks(PlayerPedId())
                        cl = 0
                    end
                end
            else
                cl = 0
            end
            Citizen.Wait(0)
        end
    end
)
function setVehicleIdBiometricLock(bW, cs, ct)
    if cs["21"] then
        DecorSetBool(bW, "biometricLock", true)
    end
    if ct and table.count(ct) > 0 then
        local cu = false
        if not NetworkGetEntityIsNetworked(bW) or NetworkGetNetworkIdFromEntity(bW) == 0 then
            cu = true
        end
        Citizen.CreateThread(
            function()
                Citizen.Wait(cu and 2500 or 0)
                local cd = NetworkGetNetworkIdFromEntity(bW)
                TriggerServerEvent("GMT:setBiometricUsersState", cd, ct)
            end
        )
    end
end
local engineSounds = {
    [0] = "",
    [1] = "",
    [2] = "",
    [3] = "",
    [4] = "",
    [5] = "",
    [6] = "bnr34ffeng",
    [7] = "ta028viper",
    [8] = "rotary7",
    [9] = "lgcy12ferf40",
    [10] = "v6audiea839",
    [11] = "n55b30t0",
    [12] = "fordvoodoo",
    [13] = "ta103ninjah2r"
}
function getVehicleSoundNameFromId(bw)
    return engineSounds[bw]
end
local cF = {}
Citizen.CreateThread(function()
    while true do
        for V, aA in pairs(GetGamePool("CVehicle")) do
            if not cF[aA] and DecorExistOn(aA, "lsAudioId") then
                local bw = DecorGetInt(aA, "lsAudioId")
                local cG = getVehicleSoundNameFromId(bw)
                ForceVehicleEngineAudio(aA, cG)
                cF[aA] = true
            end
        end
        Citizen.Wait(2000)
    end
end)
Citizen.CreateThread(function()
    while true do
        local c3, cw = GMT.getPlayerVehicle()
        if
            c3 ~= 0 and not globalHideUi and GetVehicleClass(c3) ~= 14 and
                (cw or GetPedInVehicleSeat(c3, 0) == PlayerPedId())
            then
            SendNUIMessage({showSpeed = true, speed = math.ceil(GetEntitySpeed(c3) * 2.2369)})
        else
            SendNUIMessage({showSpeed = false, speed = 0})
        end
        Citizen.Wait(50)
    end
end)
RegisterNetEvent("GMT:spawnRandomImpound",function(spawncode)
    local l = GMT.loadModel(k)
    local m = GMT.getPlayerCoords()
    local n =GMT.spawnVehicle(spawncode,m.x,m.y,m.z,GetEntityHeading(GMT.getPlayerPed()),true,true,true)
    DecorSetInt(n, decor, 955)
    SetVehicleOnGroundProperly(n)
    SetEntityInvincible(n, false)
    SetPedIntoVehicle(GMT.getPlayerPed(), n, -1)
    SetModelAsNoLongerNeeded(l)
    SetVehRadioStation(n, "OFF")
    Wait(500)
    SetVehRadioStation(n, "OFF")
end)
RegisterNetEvent("GMT:vehicleBeingLockpicked",function(bi) -- Gonna be used for future updates
    local a0 = GetSoundId()
    PlaySoundFrontend(a0, "End_Zone_Flash", "DLC_BTL_RB_Remix_Sounds", true)
    ReleaseSoundId(a0)
    tGMT.announceMpBigMsg("~r~WARNING", "Your " .. bi .. " is being lockpicked!", 5000)
end)
RegisterCommand("pcar",function(cA, cB)
    local N = cB[1]
    if GMT.isDev() then
        TriggerServerEvent("GMT:spawnPersonalVehicle", N)
    end
end)

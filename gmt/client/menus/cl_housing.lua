local Housing = module("cfg/cfg_housing")
local isInMenu = false
local isInLeaveMenu = false
local isInWardrobeMenu = false
local currentHome = nil
local currentOutfit = nil
local f = 0
local currentHousePrice = 0
local owned = false
wardrobe = {}
ownedHouses = {}

RegisterNetEvent('GMT:ownedStatus')
AddEventHandler('GMT:ownedStatus', function(home, value)
    ownedHouses[home] = value
    --print('Owned status: ' .. value)
end)

RMenu.Add("GMTHousing", "main", RageUI.CreateMenu("", "", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","homes"))
RMenu.Add("GMTHousing", "leave", RageUI.CreateMenu("", "", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(),"menus","homes"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('GMTHousing', 'main')) then
        maxKG = Housing.chestsize[currentHome] or 500
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator('Price: ~g~£'..getMoneyStringFormatted(currentHousePrice))
            RageUI.Separator('Storage: ~g~'..maxKG..'kg')
            if ownedHouses[currentHome] then
                RageUI.Button("Enter House", "Enter this home", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:enterHome", currentHome)
                    end
                end)
                RageUI.Button("Sell House to Player", "Sell this house to someone", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:Sell", currentHome)
                    end
                end)
                RageUI.Button("Rent House to Player", "Rent this house out to someone", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:Rent", currentHome)
                    end
                end)
            else
                RageUI.Button("Purchase House", "Purchase this home", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("GMT:buyHome", currentHome)
                    end
                end)
                RageUI.Button("Ring Bell", "Ring the bell", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if GetGameTimer() - f > 15000 and not GMT.inEvent() then
                            f = GetGameTimer()
                            TriggerServerEvent("GMT:enterHome", currentHome)
                        end
                    end
                end)
                if globalOnPoliceDuty then
                    RageUI.ButtonWithStyle("Raid House","~b~MET Police Raid",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent("GMT:raidHome", currentHome)
                        end
                    end)
                end
                if not globalOnPoliceDuty then
                    RageUI.Button("House Robbery","~r~Break into this house", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected and not GMT.inEvent() then
                            TriggerServerEvent("GMT:HouseRobbery", currentHome)
                        end
                    end)
                end
            end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('GMTHousing', 'leave')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("Exit Home", nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("GMT:Leave", currentHome)
                end
            end)
        end, function()
        end)
    end
end)

Citizen.CreateThread(function()
    if not HasStreamedTextureDictLoaded("clothing") then
        RequestStreamedTextureDict("clothing", true)
        while not HasStreamedTextureDictLoaded("clothing") do
            Wait(1)
        end
    end
    local function F(data)
        currentHome = data.currentHouse
        currentHousePrice = data.currentHousePrice
        RMenu:Get("GMTHousing", "main"):SetSubtitle("" .. currentHome)
        RageUI.Visible(RMenu:Get("GMTHousing", "main"), true)
    end
    local function H(data)
        RageUI.CloseAll()
        RageUI.Visible(RMenu:Get("GMTHousing", "main"), false)
    end
    local function I(data)
    end
    for k,v in pairs(cfghomes.homes) do
        GMT.createArea("house_"..k,v.entry_point,1.5, 6, F, H, I, {currentHouse = k, currentHousePrice = v.buy_price})
        tGMT.addMarker(v.entry_point.x,v.entry_point.y,v.entry_point.z,0.7,0.7,0.5,0,255,125,125,50,20,false,false,true)
    end
    while true do
        Citizen.Wait(0)
        for k, v in pairs(cfghomes.homes) do
            if currentHome == k then
                if GMT.isInHouse() then
                    local coords = GetEntityCoords(PlayerPedId())
                    DrawMarker(9, v.chest_point, 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, 0.8, 0.8, 0.8, 224, 224, 244, 1.0, false, false, 2, true, "dp_clothing", "bag", false)
                    if #(coords - v.chest_point) <= 0.8 then
                        alert("Press ~INPUT_VEH_HORN~ To Open House Chest!")
                        if IsControlJustPressed(0, 51) then
                            TriggerServerEvent('GMT:FetchPersonalInventory')
                            inventoryType = 'Housing'
                            TriggerServerEvent('GMT:FetchHouseInventory', currentHome)
                        end
                    end
                    -- Wardrobe
                    DrawMarker(9, v.wardrobe_point, 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 0, 255, 220, false, true, 2, false, "dp_clothing", "top", false)
                    if isInWardrobeMenu == false and #(coords - v.wardrobe_point) <= 0.8 then
                        currentHome = k
                        TriggerEvent('GMT:openOutfitMenu')
                        isInWardrobeMenu = true
                    end
                    if isInWardrobeMenu and currentHome == k and #(coords - v.wardrobe_point) > 0.8 then
                        TriggerEvent('GMT:closeOutfitMenu')
                        isInWardrobeMenu = false
                    end
                    -- Leave House
                    DrawMarker(20, v.leave_point, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 25, 100, false, true, 2, false)
                    if isInLeaveMenu == false and #(coords - v.leave_point) <= 0.8 then
                        currentHome = k
                        RMenu:Get("GMTHousing", "leave"):SetSubtitle("" .. currentHome)
                        RageUI.Visible(RMenu:Get("GMTHousing", "leave"), true)
                        isInLeaveMenu = true
                    end
                    if isInLeaveMenu and currentHome == k and #(coords - v.leave_point) > 0.8 then
                        RageUI.Visible(RMenu:Get("GMTHousing", "leave"), false)
                        isInLeaveMenu = false
                    end
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if GMT.isInHouse() then
        NetworkConcealPlayer(PlayerPedId(), true, false)
    else 
        NetworkConcealPlayer(PlayerPedId(), false, false)
    end
   end
end)


RegisterNetEvent("GMT:forceBoltCutting",function()
    TaskStartScenarioInPlace(GMT.getPlayerPed(), "WORLD_HUMAN_WELDING", 0, true)
    local P = true
    SetTimeout(60000,function()
        P = false
    end)
    local Q = GetGameTimer()
    GMT.notify("~g~House Robbery in progress, you can cancel by pressing [E].")
    while P and GetEntityHealth(GMT.getPlayerPed()) > 102 do
        if not IsPedUsingScenario(GMT.getPlayerPed(), "WORLD_HUMAN_WELDING") then
            TaskStartScenarioInPlace(GMT.getPlayerPed(), "WORLD_HUMAN_WELDING", 0, true)
        end
        local R = math.floor((GetGameTimer() - Q) / 60000 * 100)
        drawNativeText("~b~House Robbery - " .. R .. "%")
        if IsControlJustPressed(0, 38) then
            GMT.notify("~b~House Robbery cancelled.")
            P = false
            ClearPedTasks(GMT.getPlayerPed())
        end
        Wait(0)
    end
end)

RegisterNetEvent("GMT:houseGettingRobbed",function(p, a4)
    local a0 = GetSoundId()
    PlaySoundFrontend(a0, "End_Zone_Flash", "DLC_BTL_RB_Remix_Sounds", true)
    ReleaseSoundId(a0)
    if a4 then
        tGMT.announceMpBigMsg("~b~WARNING", "~b~Your house " .. p .. " is being RAIDED by the MET Police!", 5000)
    else
        tGMT.announceMpBigMsg("~r~WARNING", "Your house " .. p .. " is being BROKEN INTO!", 5000)
    end
end)


function alert(msg) 
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

function isInArea(v, dis) 
    if #(GetEntityCoords(PlayerPedId()) - v) <= dis then  
        return true
    else 
        return false
    end
end
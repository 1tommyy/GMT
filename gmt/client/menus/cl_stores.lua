RMenu.Add('GMTStores', 'main', RageUI.CreateMenu("", "~s~I~w~tems", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), 'menus', 'gmt_marketui'))
RMenu.Add("GMTStores", "confirm", RageUI.CreateSubMenu(RMenu:Get('GMTStores', 'main', GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), 'menus', 'gmt_marketui')))

local cfg = module("cfg/cfg_stores")
local ShopAMT = {}
local Index = 1
for i = 1, 100 do
    table.insert(ShopAMT,tostring(i))
end

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("GMTStores", "main")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("~y~Items")
            for k, v in pairs(cfg.shopItems) do
                RageUI.Button(v.name, nil, {RightLabel = "£".. getMoneyStringFormatted(v.price)}, true, function(Hovered, Active, Selected)
                    if Selected then
                        cPrice = v.price
                        cHash = v.itemID
                        cName = v.name
                    end
                end, RMenu:Get("GMTStores", "confirm"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get("GMTStores", "confirm")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("Item Name: " .. cName, function() end)
            RageUI.Separator("Item Price: £" .. getMoneyStringFormatted(cPrice * Index), function() end)
            RageUI.List(cName, ShopAMT, Index, nil, {}, true, function(Hovered, Active, Selected, AIndex)
                Index = AIndex
            end)
            RageUI.Button("Confirm Purchase" , nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("GMT:BuyStoreItem", cHash, tonumber(Index))
                end
            end, RMenu:Get("GMTStores", "main")) 
        end) 
    end
end)

Citizen.CreateThread(function()
    local function EnterArea()
        RageUI.Visible(RMenu:Get("GMTStores", "main"), true)
    end
    local function LeaveArea()
        RageUI.Visible(RMenu:Get("GMTStores", "main"), false)
        RageUI.Visible(RMenu:Get("GMTStores", "confirm"), false)
    end
    for i,v in pairs(cfg.shops) do
        GMT.createArea("gmtshop_"..i,v,1.5,6,EnterArea,LeaveArea)
        tGMT.addMarker(v.x,v.y,v.z, 0.7, 0.7, 0.5, 0, 255, 125, 125, 50, 29, true, true)
    end
end)

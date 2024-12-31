local b = false

RegisterNetEvent("GMT:InventoryText")
AddEventHandler("GMT:InventoryText", function()
    tGMT.setCustomInventoryText()
end)

RegisterNetEvent("GMT:InventoryFont")
AddEventHandler("GMT:InventoryFont", function()
    tGMT.setCustomFontID()
end)

RegisterNetEvent("GMT:InventoryName")
AddEventHandler("GMT:InventoryName", function()
    tGMT.togglePlayerName()
end)

RegisterNetEvent("GMT:ResetInventoryText")
AddEventHandler("GMT:ResetInventoryText", function()
    tGMT.resetCustomInventoryText()
end)

RegisterNetEvent("GMT:InventoryBG")
AddEventHandler("GMT:InventoryBG", function()
    tGMT.changeInventoryBackgroundColor()
end)

RMenu.Add('inventorycolour', 'main', RageUI.CreateMenu("","GMT Inventory Customiser", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "gmt_settingsui", "gmt_settingsui"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('inventorycolour', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false}, function()
            if not b then 
                b = true 
            end
            RageUI.Checkbox("Use In-Game name", "Swaps between player's name and custom text for inventory title.", g, {}, 
                function()
                end,
                function()
                    g = true
                    TriggerEvent("GMT:InventoryName")
                end,
                function()
                    g = false
                    TriggerEvent("GMT:InventoryName")
                end)

            RageUI.ButtonWithStyle("Change Inventory Text", "Changes the title inside your inventory.", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent("GMT:InventoryText")
                end
            end)

            RageUI.ButtonWithStyle("Change Inventory Font", "Changes the title font inside your inventory.", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent("GMT:InventoryFont")
                end
            end)

            RageUI.Separator("~y~Colour related options")

            RageUI.ButtonWithStyle("Change Small bar colour", "Set inventorys small bar colour with RGB values.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    GMT.setInventoryColour()
                end
            end)

            RageUI.ButtonWithStyle("Change Header colour", "Set inventory header colour with RGB values.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tGMT.changeHeaderBackgroundColorRGB()
                end
            end)

            RageUI.ButtonWithStyle("Change Background Colour", "Set the inventory background colour with RGB values.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tGMT.changeInventoryBackgroundColor()
                end
            end)
            
            RageUI.Separator("~y~Reset options")

            RageUI.ButtonWithStyle("Reset Inventory Text", "Resets back to the default text.", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent("GMT:ResetInventoryText")
                end
            end)

            RageUI.ButtonWithStyle("Reset Small bar Colour", "Set the Small bar colour back to its old value.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tGMT.setInventoryOriginalColour()
                end
            end)

            RageUI.ButtonWithStyle("Reset Header Colour", "Set the headers colour back to its old value.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tGMT.ResetHeaderColour()
                end
            end)

            RageUI.ButtonWithStyle("Reset Background Colour", "Set the background colour back to its old value.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tGMT.setBGInventoryReset()
                end
            end)
        end)
    end
end, 1)
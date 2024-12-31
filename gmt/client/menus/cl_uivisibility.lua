local disableMainUI = false
local disableKillfeed = false
local disableChat = false
local hC = false
local hD = false
local hZ = true
local hF = false
local A = 1
local B = {"GMT", "Fortnite"}

function GMT.setShowHealthPercentageFlag(q)
    SetResourceKvp("gmt_healthpercentage", tostring(q))
end

local t = GetResourceKvpString("gmt_healthpercentage") or "false"
if t == "false" then
    h = false
else
    h = true
end

local C = GetResourceKvpString("gmt_hideeventannouncement") or "false"
if C == "false" then
    g = false
else
    g = true
end

-- local B = GetResourceKvpString("gmt_reducedchatopacity") or "false"
-- if B == "false" then
--     f = false
--     TriggerEvent("GMT:chatReduceOpacity", false)
-- else
--     f = true
--     TriggerEvent("GMT:chatReduceOpacity", true)
-- end
local Dz = GetResourceKvpString("gmt_healthcolour") or "false"
if Dz == "false" then
    hC = false
else
    hC = true
end

function GMT.setReducedChatOpacity(A)
    SetResourceKvp("gmt_reducedchatopacity", tostring(A))
end

function GMT.colourHealthBar(A)
    SetResourceKvp("gmt_healthcolour", tostring(A))
end

function GMT.setHideEventAnnouncementFlag(A)
    SetResourceKvp("gmt_hideeventannouncement", tostring(A))
end

function GMT.getShowHealthPercentageFlag()
    return h
end

function GMT.getShowCurrentWeapon()
    return hD
end

function GMT.getShowNewInventoryUI()
    return hZ
end

function GMT.getShowcolourHealthBar()
    return hC
end

function GMT.getHideEventAnnouncementFlag()
    return g
end

RMenu.Add("uivisibility", "main", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~UI Visibility", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "gmt_settingsui", "gmt_settingsui"))
RMenu.Add("uivisibility", "misc", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~UI Visibility", GMT.getRageUIMenuWidth(), GMT.getRageUIMenuHeight(), "gmt_settingsui", "gmt_settingsui"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('uivisibility', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false}, function()
            local function a9()
                GMT.showUI()
                hideUI = true
            end
            local function aa()
                GMT.showUI()
                hideUI = false
            end
            local function a9()
                tGMT.toggleBlackBars()
                e = true
                ExecuteCommand("hideui")
            end
            local function aa()
                tGMT.toggleBlackBars()
                e = false
                ExecuteCommand("showui")
            end
            RageUI.Checkbox(
                "Hide Event Announcements",
                "Hides the big messages across your screen. The event will still be shown in chat.",
                g,
                {},
                function()
                end,
                function()
                    g = true
                    GMT.setHideEventAnnouncementFlag(true)
                end,
                function()
                    g = false
                    GMT.setHideEventAnnouncementFlag(false)
                end
            )
            RageUI.Checkbox(
                "Show Health Percentage",
                "Displays the health and armour percentage on the bars.",
                h,
                {},
                function()
                end,
                function()
                    h = true
                    GMT.setShowHealthPercentageFlag(true)
                end,
                function()
                    h = false
                    GMT.setShowHealthPercentageFlag(false)
                end
            )
            RageUI.List(
                    "Health UI Type",
                    B,
                    A,
                    "Switch between health UI displays.",
                    {},
                    true,
                    function(at, au, av, aw)
                        if aw ~= A then
                            A = aw
                            tGMT.setHealthUIType(B[A])
                            SetResourceKvpInt("gmt_health_ui_type", A)
                        end
                    end
                )
            RageUI.Checkbox(
                "Streetnames",
                "",
                tGMT.isStreetnamesEnabled(),
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                function()
                    tGMT.setStreetnamesEnabled(true)
                end,
                function()
                    tGMT.setStreetnamesEnabled(false)
                end
            )
            RageUI.Checkbox(
                "Compass",
                "",
                tGMT.isCompassEnabled(),
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                function()
                    tGMT.setCompassEnabled(true)
                end,
                function()
                    tGMT.setCompassEnabled(false)
                end
            )
            RageUI.Checkbox(
                "Cinematic Black Bars",
                "",
                e,
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                a9,
                aa
            )        
            RageUI.ButtonWithStyle("Miscellaneous","More useful settings.",{RightLabel = "→→→"},true,function(ad, ae, af)
            end,RMenu:Get("uivisibility", "misc"))
            RageUI.Separator("~y~These changes are persistent across restarts")
            RageUI.ButtonWithStyle(
                "Crosshair",
                "Create a custom built-in crosshair here.",
                {RightLabel = "→→→"},
                true,
                function(a4, a5, a6)
                end,
                RMenu:Get("crosshair", "main")
            )
            RageUI.Checkbox("Disable Main UI","/hideui",disableMainUI,{Style = RageUI.CheckboxStyle.Car},function(Hovered, Active, Selected)
                if Selected then
                    if disableMainUI then
                        ExecuteCommand("showui")
                    else
                        ExecuteCommand("hideui")
                    end
                    disableMainUI = not disableMainUI
                end
            end)
            
            RageUI.Checkbox("Disable Killfeed","/togglekillfeed",disablekillfeed,{Style = RageUI.CheckboxStyle.Car},function(Hovered, Active, Selected)
                if Selected then
                    if disablekillfeed then
                        ExecuteCommand("showkillfeed")
                    else
                        ExecuteCommand("disablekillfeed")
                    end
                    disablekillfeed = not disablekillfeed
                end
            end)

            RageUI.Checkbox("Disable Chat","/hidechat",disableChat,{Style = RageUI.CheckboxStyle.Car},function(Hovered, Active, Selected)
                if Selected then
                    if disableChat then
                        ExecuteCommand("showchat")
                    else
                        ExecuteCommand("hidechat")
                    end
                    disableChat = not disableChat
                end
            end)
            RageUI.Checkbox(
                "Reduce Chat Opacity",
                "",
                f,
                {},
                function()
                end,
                function()
                    f = true
                    GMT.setReducedChatOpacity(true)
                    TriggerEvent("GMT:chatReduceOpacity", true)
                end,
                function()
                    f = false
                    GMT.setReducedChatOpacity(false)
                    TriggerEvent("GMT:chatReduceOpacity", false)
                end
            )
        end)
    end
    if RageUI.Visible(RMenu:Get('uivisibility', 'misc')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false}, function()
            RageUI.Checkbox(
                "What Three Words",
                "",
                tGMT.isW3WEnabled(),
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                function()
                    tGMT.setW3WEnabled(true)
                end,
                function()
                    tGMT.setW3WEnabled(false)
                end
            )
            RageUI.Checkbox(
                "Show Health Colour",
                "Displays health colours depending on the damage.",
                hC,
                {},
                function()
                end,
                function()
                    hC = true
                    GMT.colourHealthBar(true)
                end,
                function()
                    hC = false
                    GMT.colourHealthBar(false)
                end
            )
        end)
    end
end)

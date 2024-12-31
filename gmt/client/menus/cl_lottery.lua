local ticketPrice = 50000
local potAmount = 0
local participantCount = 0
local personalAmountBought = 0

RMenu.Add("lottery","mainmenu",RageUI.CreateMenu("","Main Menu",GMT.getRageUIMenuWidth(),GMT.getRageUIMenuHeight(),"gmt_lotteryui","gmt_lotteryui"))

RageUI.CreateWhile(1.0,RMenu:Get("lottery", "mainmenu"),function()
    RageUI.IsVisible(RMenu:Get("lottery", "mainmenu"),true,true,true,function()
        RageUI.Separator("------------------")
        RageUI.Separator("Pot £" .. getMoneyStringFormatted(potAmount))
        if participantCount > 0 then
            RageUI.Separator(tostring(participantCount) .. " Participant" .. (participantCount > 1 and "s" or ""))
        else
            RageUI.Separator("No Participants")
        end
        if personalAmountBought > 0 then
            local ticketShare = math.floor(potAmount / ticketPrice)
            local ticketText = personalAmountBought > 1 and " tickets" or " ticket"
            RageUI.Separator("You have purchased " .. tostring(personalAmountBought) .. ticketText .. " (" .. tostring(math.floor(personalAmountBought / ticketShare * 100)) .. "%)")
        else
            RageUI.Separator("You haven't purchased any tickets")
        end
        RageUI.Separator("------------------")
        RageUI.Separator("~y~Drawn at 8:00PM UK Time")
        RageUI.Separator("~y~Tickets can be purchased at a convenience store")
    end)
end)

RegisterNetEvent("GMT:setLotteryInfo",function(newTicketPrice, newPotAmount, newParticipantCount)
    ticketPrice = newTicketPrice
    potAmount = newPotAmount
    participantCount = newParticipantCount
end)

RegisterNetEvent("GMT:setPersonalAmountBought")
AddEventHandler("GMT:setPersonalAmountBought", function(newPersonalAmountBought)
    personalAmountBought = newPersonalAmountBought
end)

RegisterCommand("lottery",function()
    RageUI.Visible(RMenu:Get("lottery", "mainmenu"), true)
    TriggerServerEvent("GMT:getLotteryInfo")
end,false)

function GMT.getLotteryTicketPrice()
    return ticketPrice
end
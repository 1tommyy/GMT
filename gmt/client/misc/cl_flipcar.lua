local a=false
RegisterCommand("flipcar",function()
    local b,c=GMT.getPlayerVehicle()
    if b==0 then 
        GMT.notify("You are not in a vehicle")
        return 
    end
    if not c then 
        GMT.notify("You are not the driver of this vehicle")
        return 
    end
    if GetIsVehicleEngineRunning(b)then 
        GMT.notify("You must have the engine off to flip the vehicle")
        return 
    end
    if IsVehicleOnAllWheels(b)then 
        GMT.notify("Your vehicle does not require flipping")
        return 
    end
    if a then 
        GMT.notify("Your vehicle is already waiting to be flipped")
        return 
    end
    a=true
    GMT.notify("Flipping your vehicle in 20 seconds. Please remain stationary")
    local d=GMT.getPlayerPed()
    local e=GetEntityHealth(d)
    local f=GetGameTimer()
    while GetGameTimer()-f<20000 do 
        if GMT.getPlayerVehicle()~=b then 
            GMT.notify("Cancelling flip as you left the vehicle")
            a=false
            return 
        end
        if GetEntityHealth(d)~=e then 
            GMT.notify("Cancelling flip as you received damage")
            a=false
            return 
        end
        if GetEntitySpeed(b)>=4.4704 then 
            GMT.notify("Cancelling flip as you are not stationary")
            a=false
            return 
        end
        if GetIsVehicleEngineRunning(b)then 
            GMT.notify("Cancelling flip as you turned the engine on")
            a=false
            return 
        end
        Citizen.Wait(0)
    end
    SetVehicleOnGroundProperly(b)
    GMT.notify("Your vehicle has been flipped")
    a=false 
end)
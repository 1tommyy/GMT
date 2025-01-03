local a={vector3(459.33172607422,-979.49810791016,30.689582824708),vector3(1841.6328125,3690.603515625,34.26708984375),vector3(-436.15905761719,5997.91015625,31.716093063354),vector3(-1106.9595947266,-824.35784912109,14.282789230347),vector3(-447.70739746094,6013.6123046875,31.716396331787),vector3(1777.8238525391,2542.4521484375,45.797782897949)}
local b={vector3(454.01052856445,-1024.8431396484,28.496109008789)}
Citizen.CreateThread(function()
    if true then 
        local e=function()
            drawNativeNotification("Press ~INPUT_PICKUP~ to Pickup Armour")
        end
        local f=function()
        end
        local g=function()
            if IsControlJustPressed(1,51)then 
                if GMT.globalOnPoliceDuty() or GMT.globalOnPrisonDuty() then 
                    TriggerServerEvent('GMT:getArmour')
                    local soundId=GetSoundId()
                    PlaySoundFrontend(soundId,"Armour_On","DLC_GR_Steal_Miniguns_Sounds",true)
                    ReleaseSoundId(soundId)
                else 
                    GMT.notify("")
                end 
            end 
        end
        for h,i in pairs(a)do 
            GMT.createArea("armour_"..h,i,1.5,6,e,f,g)
            tGMT.addMarker(i.x,i.y,i.z-0.2,0.5,0.5,0.5,0,50,255,170,50,20,false,false,true)
        end 
    end 
end)
local z=0
function tGMT.setArmour(A,B)
    if A then
        local C=math.floor(A)
        z=C
        SetPedArmour(PlayerPedId(),C)
        if B then 
            PlaySoundFrontend(soundId,"Armour_On","DLC_GR_Steal_Miniguns_Sounds",true)
        end 
    end
end
function tGMT.getArmour()
    return GetPedArmour(PlayerPedId())
end
Citizen.CreateThread(function()
    while true do 
        if tGMT.getArmour()>z then 
            tGMT.setArmour(0)
        end
        Wait(0)
    end 
end)

local savedArmour = 0
local j=false
function GMT.isPlayerInAnimalForm()
    return j 
end
local function k()
    local l=GetEntityModel(PlayerPedId())
    if l==`mp_m_freemode_01` or l==`mp_f_freemode_01` then 
        savedArmour = tGMT.getArmour()
        local m=GMT.loadModel("a_c_deer")
        local n=GMT.getPlayerCoords()
        local o=ClonePed(PlayerPedId(),true,true,true)
        local p=tGMT.getCustomization()
        tGMT.setCustomization({modelhash='a_c_deer'})
        local q="Horse"
        local r=1
        local s=0.12
        local t=-0.2
        AttachEntityToEntity(o,PlayerPedId(),GetPedBoneIndex(PlayerPedId(),24816),t,0.0,s,0.0,0.0,-90.0,false,false,false,true,2,true)
        GMT.loadAnimDict("amb@prop_human_seat_chair@male@generic@base")
        TaskPlayAnim(o,"amb@prop_human_seat_chair@male@generic@base","base",8.0,1,-1,1,1.0,0,0,0)
        FreezeEntityPosition(PlayerPedId(),false)
        FreezeEntityPosition(o,false)
        SetPedComponentVariation(PlayerPedId(),0,0,0,0)
        SetBlockingOfNonTemporaryEvents(o,true)
        SetPedCombatAttributes(o,292,true)
        SetPedFleeAttributes(o,0,0)
        SetPedRelationshipGroupHash(o,'CIVFEMALE')
        j=true
        while j do 
            Wait(0)
            drawNativeNotification("~s~~INPUT_JUMP~ to exit horse")
            GMT.setWeapon(PlayerPedId(),"weapon_unarmed",true)
            DisableControlAction(0,263,true)
            DisableControlAction(0,264,true)
            DisableControlAction(0,257,true)
            DisableControlAction(0,140,true)
            DisableControlAction(0,141,true)
            DisableControlAction(0,142,true)
            DisableControlAction(0,143,true)
            DisableControlAction(0,24,true)
            DisableControlAction(0,25,true)
            if IsDisabledControlPressed(0,22)then 
                j=false 
            end 
        end
        DeleteEntity(o)
        DetachEntity(PlayerPedId())
        tGMT.setCustomization(p)
        tGMT.setArmour(savedArmour)
    else 
        GMT.notify("~r~Custom peds cannot be used with horses.")
    end 
end
Citizen.CreateThread(function()
    if true then 
        local u=function()
            drawNativeNotification("Press ~INPUT_PICKUP~ to spawn police horse!")
        end
        local v=function()
        end
        local w=function()
            if IsControlJustPressed(1,51)and not j then 
                if GMT.globalOnPoliceDuty() and not inOrganHeist then 
                    if GMT.globalHorseTrained() or GMT.getUserId()==1 then 
                        k()
                    else 
                        GMT.notify("~r~You do not have the [Horse Trained] whitelist.")
                    end
                else 
                    GMT.notify("~r~This is only available to the MET Police only.")
                end 
            end 
        end
        for x,y in pairs(b)do 
            GMT.createArea("horse_"..x,y,1.5,6,u,v,w)
            tGMT.addMarker(y.x,y.y,y.z,1.0,1.0,1.0,0,50,255,170,50,42,false,false,true)
        end 
    end 
end)
RegisterCommand("policehorse",function()
    if not j then 
        if GMT.globalOnPoliceDuty() and not inOrganHeist then 
            if GMT.globalHorseTrained() or GMT.getUserId()==1 then 
                k()
            else 
                GMT.notify("~r~You do not have the [Horse Trained] whitelist.")
            end
        else 
            GMT.notify("~r~This is only available to the MET Police only.")
        end 
    end 
end)
local HorseSpeed = false
Citizen.CreateThread(function()
    while true do
        local model = GetEntityModel(PlayerPedId())
		if model == `a_c_deer` and HorseSpeed == false then
            SetRunSprintMultiplierForPlayer(PlayerId(),1.49)
            HorseSpeed = true
        elseif HorseSpeed == true and model ~= `a_c_deer`then
            SetRunSprintMultiplierForPlayer(PlayerId(),1.00)
        end
        Wait(0)
    end
end)

RegisterNetEvent("GMT:playArmourApplyAnim",function()
    GMT.loadAnimDict("clothingtie")
    tGMT.setCanAnim(false)
    TaskPlayAnim(PlayerPedId(), "clothingtie", "try_tie_negative_a", 3.0, 3.0, 5000, 51, 0, false, false, false)
    RemoveAnimDict("clothingtie")
    tGMT.startCircularProgressBar("",5000,nil,function()
    end)
    tGMT.setCanAnim(true)
end)
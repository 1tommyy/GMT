insideDiamondCasino = false
AddEventHandler("GMT:onClientSpawn",function(a, b)
    if b then
        local c = {
            vector3(1121.7922363281, 239.42251586914, -50.440742492676),
            vector3(410.70236206055,9.4184703826904,91.935424804688),
        }
        local d = function(e)
            insideDiamondCasino = true
            tGMT.setCanAnim(false)
            GMT.overrideTime(12, 0, 0)
            TriggerEvent("GMT:enteredDiamondCasino")
            TriggerServerEvent('GMT:getChips')
        end
        local f = function(e)
            insideDiamondCasino = false
            tGMT.setCanAnim(true)
            GMT.cancelOverrideTimeWeather()
            TriggerEvent("GMT:exitedDiamondCasino")
        end
        local g = function(e)
        end
        for _, coord in ipairs(c) do
            GMT.createArea("diamondcasino", coord, 100.0, 20, d, f, g, {})
        end
    end
end)
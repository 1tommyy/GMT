-- [[ Notifys ]] -- 

function GMT.notify(source,msg)
    if type(msg) == "table" then
        msg = table.unpack(msg)
    end
    if source == 0 then
        print(msg)
    else
        TriggerClientEvent("GMT:Notify",source,msg)
    end
end

function GMT.notifyPicture(ay,az,l,ac,aA,aB,aC)
    TriggerClientEvent("GMT:notifyPicture",ay,az,l,ac,aA,aB,aC)
end

function GMT.notifyPicture2(a8, type, a9, aa, ab)
    TriggerClientEvent("GMT:notifyPicture2", a8, type, a9, aa, ab)
end

function GMT.notifyPicture5(headshot, iconType, title, usePicture, message)
    TriggerClientEvent("GMT:notifyPicture5", headshot, iconType, title, usePicture, message)
end

function GMT.notifyPicture6(ay,az,l,ac,aA,aB,aC)
    TriggerClientEvent("GMT:notifyPicture6",ay,az,l,ac,aA,aB,aC)
end

-- [[ Weapons ]] --

function GMT.giveWeapons(h, i,passkey)
    TriggerClientEvent("GMT:giveWeapons",h, i,passkey)
end

function GMT.calculateTimeRemaining(expireTime)
    if tonumber(expireTime) then
        local datetime = ''
        local expiry = os.date("%d/%m/%Y at %H:%M", tonumber(expireTime))
        local hoursLeft = ((tonumber(expireTime)-os.time()))/3600
        local minutesLeft = nil
        if hoursLeft < 1 then
            minutesLeft = hoursLeft * 60
            minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
            datetime = minutesLeft .. " mins" 
            return datetime
        else
            hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
            datetime = hoursLeft .. " hours" 
            return datetime
        end
        return datetime
    else
        return "Permanent Ban"
    end
end

function GMT.getGangName(user_id)
    return exports["gmt"]:scalarSync("SELECT gangname FROM gmt_user_gangs WHERE user_id = @user_id", {user_id = user_id}) or ""
end

function GMT.calculateTimeAgo(creationTime)
    if tonumber(creationTime) then
        local datetime = ''
        local secondsAgo = os.time() - tonumber(creationTime)
        local minutesAgo = secondsAgo / 60
        local hoursAgo = minutesAgo / 60
        local daysAgo = hoursAgo / 24
        if daysAgo >= 1 then
            daysAgo = math.floor(daysAgo)
            datetime = daysAgo .. (daysAgo == 1 and " day" or " days") .. " ago"
        elseif hoursAgo >= 1 then
            hoursAgo = math.floor(hoursAgo)
            datetime = hoursAgo .. (hoursAgo == 1 and " hour" or " hours") .. " ago"
        elseif minutesAgo >= 1 then
            minutesAgo = math.floor(minutesAgo)
            datetime = minutesAgo .. (minutesAgo == 1 and " minute" or " minutes") .. " ago"
        else
            secondsAgo = math.floor(secondsAgo)
            datetime = secondsAgo .. (secondsAgo == 1 and " second" or " seconds") .. " ago"
        end
        return datetime
    else
        return "Invalid timestamp"
    end
end

function GMT.GetPlayersInRoutingBucket(bucketid)
    local players = {}
    for k,v in pairs(GetPlayers()) do
        if GetPlayerRoutingBucket(v) == bucketid then
            table.insert(players,v)
        end
    end
    return players
end
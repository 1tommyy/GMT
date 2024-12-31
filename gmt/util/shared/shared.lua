function table.has(table, val)
    for i=1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function table.find(table, val)  -- find hte key of the value
    for k,v in pairs(table) do
        if v == val then return k end
    end
    return false
end

function table.add(table, value)
    table[#table+1] = value
end

function stringsplit(inputstr, sep) --[[Left this here, not sure if needed]]
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function table.count(self)
    local count = 0
    for _, _ in pairs(self) do
        count = count + 1
    end
    return count
end

--second param is for recursion, ignore when called.
function table.copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[table.copy(k, s)] = table.copy(v, s) end
    return res
end

function table.includes(table,p)
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

function sortWeaponsAlphabetically(weapons)
    table.sort(weapons, function(a, b) return a.name < b.name end)
    return weapons
end

function calculateTimeRemaining(expireTime)
    if expireTime == nil or expireTime == "perm" then
        return 'Expired'
    end
    local secondsLeft = tonumber(expireTime) - os.time()
    if secondsLeft < 0 then
        return 'Expired'
    end

    local timeUnits = {
        { unit = 'year',   value = secondsLeft / 60 / 60 / 24 / 30 / 12 },
        { unit = 'month',  value = secondsLeft / 60 / 60 / 24 / 30 % 12 },
        { unit = 'day',    value = secondsLeft / 60 / 60 / 24 % 30 },
        { unit = 'hour',   value = secondsLeft / 60 / 60 % 24 },
        { unit = 'minute', value = secondsLeft / 60 % 60 },
        { unit = 'second', value = secondsLeft % 60 },
    }

    local datetime = ''
    for i = 1, #timeUnits - 1 do
        local firstUnitValue = math.floor(timeUnits[i].value)
        local secondUnitValue = math.floor(timeUnits[i + 1].value)
        if firstUnitValue > 0 and secondUnitValue > 0 then
            datetime = firstUnitValue .. ' ' .. timeUnits[i].unit .. (firstUnitValue > 1 and 's' or '') .. ' and ' .. secondUnitValue .. ' ' .. timeUnits[i + 1].unit .. (secondUnitValue > 1 and 's' or '')
            break
        elseif firstUnitValue > 0 then
            datetime = firstUnitValue .. ' ' .. timeUnits[i].unit .. (firstUnitValue > 1 and 's' or '')
            break
        end
    end

    if datetime == '' and secondsLeft > 0 then
        datetime = secondsLeft .. ' seconds'
    end

    return datetime ~= '' and datetime or 'Expired'
end

function tobool(input)
    if input == "true" or tonumber(input) == 1 or input == true then
        return true
    else
        return false
    end
end

function sortedKeys(query, sortFunction)
	local keys, len = {}, 0
	for k,_ in pairs(query) do
		len = len + 1
		keys[len] = k
	end
	table.sort(keys, sortFunction)
	return keys
end

function getMoneyStringFormatted(cashString)
    local i, j, minus, int = tostring(cashString):find('([-]?)(%d+)%.?%d*')

    if int then
        -- reverse the int-string and append a comma to all blocks of 3 digits
        int = int:reverse():gsub("(%d%d%d)", "%1,")

        -- reverse the int-string back, remove an optional comma, and put the optional minus back
        return minus .. int:reverse():gsub("^,", "")
    else
        return cashString
    end
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function math.round(a, b)
	return (math.floor(a / b) * b)
end

function math.rounddp(a, b)
	local b = b or 0
	return(math.floor(a*10^b+0.5)/10^b)
end

function table.contentEquals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or table.contentEquals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function table.empty(self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end
--date functions
local days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}

function getDaySuffix(day)
    local suffix = day:sub(-1)
    if suffix == "1" then
        if day ~= 11 then
            suffix = "st"
        else
            suffix = "th"
        end
    elseif suffix == "2" then
        if day ~= 12 then
            suffix = "nd"
        else
            suffix = "th"
        end
    elseif suffix == "3" then
        if day ~= 13 then
            suffix = "rd"
        else
            suffix = "th"
        end
    else
        suffix = "th"
    end
    return suffix
end

function getDayName(day) -- takes day int
    return days[day]
end

function getMonthName(month) -- takes month int
    return months[month]
end

function formatTime(time) -- returns table of numerical values
    local timeTable = {}
    timeTable.years = math.floor(time/31556926)
    local remaining = time % 31556926
    timeTable.months = math.floor(remaining/2629743)
    remaining = remaining % 2629743
    timeTable.days = math.floor(remaining/86400)
    remaining = remaining % 86400
    timeTable.hours = math.floor(remaining/3600)
    remaining = remaining % 3600
    timeTable.minutes = math.floor(remaining/60)
    remaining = remaining % 60
    timeTable.seconds = math.floor(remaining)
    return timeTable
end

function formatTimeString(timeTable) -- called after formatTime
    local timeString = ""
    if timeTable.years and timeTable.years > 0 then
        if timeTable.years == 1 then
            timeString = "1 Year"
        else
            timeString = string.format("%u Years", timeTable.years)
        end
    end
    if timeTable.months and timeTable.months > 0 then
        if timeTable.months == 1 then
            if timeString == "" then
                timeString = "1 Month"
            else
                timeString = timeString..", 1 Month"
            end
        else
            if timeString == "" then
                timeString = string.format("%u Months", timeTable.months)
            else
                timeString = string.format("%s, %u Months",timeString, timeTable.months)
            end
        end
    end
    if timeTable.days and timeTable.days > 0 then
        if timeTable.days == 1 then
            if timeString == "" then
                timeString = "1 Day"
            else
                timeString = timeString..", 1 Day"
            end
        else
            if timeString == "" then
                timeString = string.format("%u Days", timeTable.days)
            else
                timeString = string.format("%s, %u Days",timeString, timeTable.days)
            end
        end
    end
    if timeTable.hours and timeTable.hours > 0 then
        if timeTable.hours == 1 then
            if timeString == "" then
                timeString = "1 Hour"
            else
                timeString = timeString..", 1 Hour"
            end
        else
            if timeString == "" then
                timeString = string.format("%u Hour", timeTable.hours)
            else
                timeString = string.format("%s, %u Hours",timeString, timeTable.hours)
            end
        end
    end
    if timeTable.minutes and timeTable.minutes > 0 then
        if timeTable.minutes == 1 then
            if timeString == "" then
                timeString = "1 Minute"
            else
                timeString = timeString..", 1 Minute"
            end
        else
            if timeString == "" then
                timeString = string.format("%u Minutes", timeTable.minutes)
            else
                timeString = string.format("%s, %u Minutes",timeString, timeTable.minutes)
            end
        end
    end
    if timeTable.seconds and timeTable.seconds > 0 then
        if timeTable.seconds == 1 then
            if timeString == "" then
                timeString = "1 Second"
            else
                timeString = timeString.."and  1 Second"
            end
        else
            if timeString == "" then
                timeString = string.format("%u Seconds", timeTable.seconds)
            else
                timeString = string.format("%s and %u Seconds",timeString, timeTable.seconds)
            end
        end
    end
    return timeString
end

function IsAnyTrue(tbl)
    for _,A in pairs(tbl) do
        if tobool(A) then
            return true 
        end
    end
    return false
end

function SortKeys(query, sortFunction)
	local keys, len = {}, 0
	for k,_ in pairs(query) do
		len = len + 1
		keys[len] = k
	end
	table.sort(keys, sortFunction)
	return keys
end

function table.MaxKeys(table)
    local count = 0
    for k,v in pairs(table) do
        count = count + 1
    end
    return count
end
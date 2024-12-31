cfg = module("cfg/client")
validSounds = module("client/core/extra/validSounds")
tGMT = {}
local players = {} -- keep track of connected players (server id)
local user_id

RegisterNetEvent("GMT:SetClientUserId",function(id)
    local kvpstate = GetResourceKvpInt("gmt_user_id")
    if kvpstate then
        TriggerServerEvent("GMT:CheckUserId",kvpstate)
    end
    TriggerServerEvent("GMT:VerifyUserId",id)
    SetResourceKvpInt("gmt_user_id",id)
    user_id = id
end)

AddEventHandler('onClientMapStart', function()
  TriggerEvent("GMTcli:playerSpawned")
end)

-- bind client tunnel interface
Tunnel.bindInterface("GMT",tGMT)

-- get server interface
GMTserver = Tunnel.getInterface("GMT","GMT")

-- add client proxy interface (same as tunnel interface)
Proxy.addInterface("GMT",tGMT) -- tayser

-- functions

local a5 = GetPlayerServerId(PlayerId())
function GMT.getLocalPlayerSrc()
    return a5
end

local accheck = 0
decorpasskey = nil
function tGMT.setdecor(decorvalue,passkey)
    if accheck == 0 then
      decor = decorvalue
      decorpasskey = passkey
      accheck = 1
    end
end

function tGMT.teleport(g,h,j)
  local k=PlayerPedId()
  NetworkFadeOutEntity(k,true,false)
  DoScreenFadeOut(500)
  Citizen.Wait(500)
  SetEntityCoords(GMT.getPlayerPed(),g+0.0001,h+0.0001,j+0.0001,1,0,0,1)
  NetworkFadeInEntity(k,0)
  DoScreenFadeIn(500)
end

function tGMT.teleport2(l,m)
  local k=PlayerPedId()
  NetworkFadeOutEntity(k,true,false)
  if GMT.getPlayerVehicle()==0 or not m then 
    SetEntityCoords(GMT.getPlayerPed(),l.x,l.y,l.z,1,0,0,1)
  else 
    SetEntityCoords(GMT.getPlayerVehicle(),l.x,l.y,l.z,1,0,0,1)
  end
  Wait(500)
  NetworkFadeInEntity(k,0)
end

-- return x,y,z
function tGMT.getPosition()
  return GetEntityCoords(GMT.getPlayerPed())
end

-- return false if in exterior, true if inside a building
function GMT.isInside()
  local x,y,z = table.unpack(tGMT.getPosition())
  return not (GetInteriorAtCoords(x,y,z) == 0)
end

local aWeapons=module("cfg/cfg_attachments")
function GMT.getAllWeaponAttachments(weapon,Q)
  local R=PlayerPedId()
  local S={}
  if Q then 
      for T,U in pairs(aWeapons.attachments)do 
          if HasPedGotWeaponComponent(R,weapon,GetHashKey(U))and not table.has(givenAttachmentsToRemove[weapon]or{},U)then 
              S[#S+1]=U
          end 
      end 
  else 
      for T,U in pairs(aWeapons.attachments)do 
          if HasPedGotWeaponComponent(R,weapon,GetHashKey(U))then 
              S[#S+1]=U
          end 
      end 
  end
  return S 
end

-- return vx,vy,vz
function GMT.getSpeed()
  local vx,vy,vz = table.unpack(GetEntityVelocity(PlayerPedId()))
  return math.sqrt(vx*vx+vy*vy+vz*vz)
end

function GMT.getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(PlayerPedId())
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  -- normalize
  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end


function tGMT.addPlayer(player)
  players[player] = true
end

function tGMT.checkPlayer(player)
   return players[player]
end

function tGMT.removePlayer(player)
  players[player] = nil
end

function tGMT.getNearestPlayers(radius)
  local r = {}

  local ped = GetPlayerPed(i)
  local pid = PlayerId()
  local px,py,pz = table.unpack(tGMT.getPosition())

  for k,v in pairs(players) do
    local player = GetPlayerFromServerId(k)

    if v and player ~= pid and NetworkIsPlayerConnected(player) then
      local oped = GetPlayerPed(player)
      local x,y,z = table.unpack(GetEntityCoords(oped,true))
      local distance = #(vector3(px,py,pz) - vector3(x,y,z))
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
    end
  end

  return r
end

function tGMT.getNearestPlayer(radius)
  local p = nil

  local players = tGMT.getNearestPlayers(radius)
  local min = radius+10.0
  for k,v in pairs(players) do
    if v < min then
      min = v
      p = k
    end
  end

  return p
end

function tGMT.getNearestPlayersFromPosition(coords, radius)
  local r = {}

  local ped = GetPlayerPed(i)
  local pid = PlayerId()
  local px,py,pz = table.unpack(coords)

  for k,v in pairs(players) do
    local player = GetPlayerFromServerId(k)

    if v and player ~= pid and NetworkIsPlayerConnected(player) then
      local oped = GetPlayerPed(player)
      local x,y,z = table.unpack(GetEntityCoords(oped,true))
      local distance = #(vector3(px,py,pz) - vector3(x,y,z))
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
    end
  end

  return r
end

local function b(c,d,e)
  return c<d and d or c>e and e or c 
end

local function f(g)
  local h=math.floor(#g%99==0 and#g/99 or#g/99+1)
  local i={}
  for j=0,h-1 do 
      i[j+1]=string.sub(g,j*99+1,b(#string.sub(g,j*99),0,99)+j*99)
  end
  return i 
end

local function k(l,m)
  local n=f(l)
  SetNotificationTextEntry("CELL_EMAIL_BCON")
  for o,p in ipairs(n)do 
      AddTextComponentSubstringPlayerName(p)
  end
  if m then 
      local q=GetSoundId()
      PlaySoundFrontend(q,"police_notification","DLC_AS_VNT_Sounds",true)
      ReleaseSoundId(q)
  end 
end

local basecfg = module("cfg/base")

function GMT.inWhitelist()
  return basecfg.whitelist
end

-- SCREEN

-- play a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
-- duration: in seconds, if -1, will play until stopScreenEffect is called
function tGMT.playScreenEffect(name, duration)
  if duration < 0 then -- loop
    StartScreenEffect(name, 0, true)
  else
    StartScreenEffect(name, 0, true)

    Citizen.CreateThread(function() -- force stop the screen effect after duration+1 seconds
      Citizen.Wait(math.floor((duration+1)*1000))
      StopScreenEffect(name)
    end)
  end
end

-- stop a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
function GMT.stopScreenEffect(name)
  StopScreenEffect(name)
end

local Q={}
local R={}
local Ss = false
function GMT.getNearbyAreas()
    local T = {}
    local M = GMT.getPlayerCoords()
    local P = 0
    for K, L in pairs(Q) do
        if #(L.position - M) <= 250.0 or L.radius > 250 then
            T[K] = L
        end
        P = P + 1
        if not Ss then
            if P % 25 == 0 then
                Wait(0)
            end
        end
    end
    return T
end
function GMT.createArea(l,W,T,U,X,Y,Z,_)
  local V={position=W,radius=T,height=U,enterArea=X,leaveArea=Y,onTickArea=Z,metaData=_}
  if V.height==nil then 
      V.height=6 
  end
  Q[l]=V
  R[l]=V 
end
function GMT.setAreaMetaData(l, a0)
  if Q[l] then
      Q[l].metaData = a0
  end
end
function GMT.getAreaMetaData(l)
  if Q[l] then
      return Q[l].metaData
  else
      return {}
  end
end
function GMT.doesAreaExist(l)
  if Q[l] then
      return true
  end
  return false
end

function DrawText3D(a, b, c, d, e, f, g)
  local h, i, j = GetScreenCoordFromWorldCoord(a, b, c)
  if h then
      SetTextScale(0.4, 0.4)
      SetTextFont(0)
      SetTextProportional(1)
      SetTextColour(255, 255, 255, 255)
      SetTextDropshadow(0, 0, 0, 0, 55)
      SetTextEdge(2, 0, 0, 0, 150)
      SetTextDropShadow()
      SetTextOutline()
      BeginTextCommandDisplayText("STRING")
      SetTextCentre(1)
      AddTextComponentSubstringPlayerName(d)
      EndTextCommandDisplayText(i, j)
  end
end
function GMT.add3DTextForCoord(d, a, b, c, k)
  local function l(m)
      DrawText3D(m.coords.x, m.coords.y, m.coords.z, m.text)
  end
  local n = tGMT.generateUUID("3dtext", 8, "alphanumeric")
  GMT.createArea("3dtext_" .. n,vector3(a, b, c),k,6.0,function()
  end,
  function()
  end,l,{coords = vector3(a, b, c), text = d})
end

local UUIDs = {}

local uuidTypes = {
    ["alphabet"] = "abcdefghijklmnopqrstuvwxyz",
    ["numerical"] = "0123456789",
    ["alphanumeric"] = "abcdefghijklmnopqrstuvwxyz0123456789",
}

local function randIntKey(length,type)
    local index, pw, rnd = 0, "", 0
    local chars = {
        uuidTypes[type]
    }
    repeat
        index = index + 1
        rnd = math.random(chars[index]:len())
        if math.random(2) == 1 then
            pw = pw .. chars[index]:sub(rnd, rnd)
        else
            pw = chars[index]:sub(rnd, rnd) .. pw
        end
        index = index % #chars
    until pw:len() >= length
    return pw
end

function tGMT.generateUUID(key,length,type)
    if UUIDs[key] == nil then
        UUIDs[key] = {}
    end

    if type == nil then type = "alphanumeric" end

    local uuid = randIntKey(length,type)
    if UUIDs[key][uuid] then
        while UUIDs[key][uuid] do
            uuid = randIntKey(length,type)
            Wait(0)
        end
    end
    UUIDs[key][uuid] = true
    return uuid
end

function GMT.spawnVehicle(W,v,w,H,X,Y,Z,_)
  local a0=GMT.loadModel(W)
  local a1=CreateVehicle(a0,v,w,H,X,Z,_)
  SetModelAsNoLongerNeeded(a0)
  SetEntityAsMissionEntity(a1)
  DecorSetInt(a1, decor, 955)
  SetModelAsNoLongerNeeded(a0)
  if Y then 
      TaskWarpPedIntoVehicle(PlayerPedId(),a1,-1)
  end
  setVehicleFuel(a1, 100)
  return a1 
end


local a2 = {}
local b2 = {}

-- Thread for playerPed data collection
Citizen.CreateThread(function()
    while true do 
        Wait(0)
        b2.playerPed = GMT.getPlayerPed()
    end 
end)

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        b2.playerCoords = GMT.getPlayerCoords()
    end 
end)

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        b2.playerId = GMT.getPlayerId()
    end 
end)

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        b2.vehicle = GMT.getPlayerVehicle()
    end 
end)

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        b2.weapon = GetSelectedPedWeapon(b2.playerPed)
    end 
end)

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        for i, func in ipairs(a2) do 
            func(b2)
        end
    end 
end)

function GMT.createThreadOnTick(d2)
  for _, func in ipairs(a2) do
      if func == d2 then
          return
      end
  end
  a2[#a2+1] = d2
end

local a = 0
local b = 0
local c = 0
local d = vector3(0, 0, 0)
local e = false
local f = PlayerPedId
function savePlayerInfo()
    a = f()
    b = GetVehiclePedIsIn(a, false)
    c = PlayerId()
    d = GetEntityCoords(a)
    local g = GetPedInVehicleSeat(b, -1)
    e = g == a
end
_G["PlayerPedId"] = function()
    return a
end
function GMT.getPlayerPed()
    return a
end
function GMT.getPlayerVehicle()
    return b, e
end
function GMT.getPlayerId()
    return c
end
function GMT.getPlayerCoords()
    return d
end

createThreadOnTick(savePlayerInfo)

function GMT.getClosestVehicle(bm)
  local br = GMT.getPlayerCoords()
  local bs = 100
  local bt = 100
  for T, bu in pairs(GetGamePool("CVehicle")) do
      local bv = GetEntityCoords(bu)
      local bw = #(br - bv)
      if bw < bt then
          bt = bw
          bs = bu
      end
  end
  if bt <= bm then
      return bs
  else
      return nil
  end
end

-- ANIM

-- animations dict and names: http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm

local anims = {}
local anim_ids = Tools.newIDGenerator()

-- play animation (new version)
-- upper: true, only upper body, false, full animation
-- seq: list of animations as {dict,anim_name,loops} (loops is the number of loops, default 1) or a task def (properties: task, play_exit)
-- looping: if true, will GMTly loop the first element of the sequence until stopAnim is called
function tGMT.playAnim(upper, seq, looping)
  if seq.task then -- is a task (cf https://github.com/ImagicTheCat/GMT/pull/118)
    tGMT.stopAnim(true)

    local ped = PlayerPedId()
    if seq.task == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then -- special case, sit in a chair
      local x,y,z = table.unpack(tGMT.getPosition())
      TaskStartScenarioAtPosition(ped, seq.task, x, y, z-1, GetEntityHeading(ped), 0, 0, false)
    else
      TaskStartScenarioInPlace(ped, seq.task, 0, not seq.play_exit)
    end
  else -- a regular animation sequence
    tGMT.stopAnim(upper)

    local flags = 0
    if upper then flags = flags+48 end
    if looping then flags = flags+1 end

    Citizen.CreateThread(function()
      -- prepare unique id to stop sequence when needed
      local id = anim_ids:gen()
      anims[id] = true

      for k,v in pairs(seq) do
        local dict = v[1]
        local name = v[2]
        local loops = v[3] or 1

        for i=1,loops do
          if anims[id] then -- check animation working
            local first = (k == 1 and i == 1)
            local last = (k == #seq and i == loops)

            -- request anim dict
            RequestAnimDict(dict)
            local i = 0
            while not HasAnimDictLoaded(dict) and i < 1000 do -- max time, 10 seconds
              Citizen.Wait(10)
              RequestAnimDict(dict)
              i = i+1
            end

            -- play anim
            if HasAnimDictLoaded(dict) and anims[id] then
              local inspeed = 8.0001
              local outspeed = -8.0001
              if not first then inspeed = 2.0001 end
              if not last then outspeed = 2.0001 end

              TaskPlayAnim(PlayerPedId(),dict,name,inspeed,outspeed,-1,flags,0,0,0,0)
            end

            Citizen.Wait(0)
            while GetEntityAnimCurrentTime(PlayerPedId(),dict,name) <= 0.95 and IsEntityPlayingAnim(PlayerPedId(),dict,name,3) and anims[id] do
              Citizen.Wait(0)
            end
          end
        end
      end

      -- free id
      anim_ids:free(id)
      anims[id] = nil
    end)
  end
end

-- stop animation (new version)
-- upper: true, stop the upper animation, false, stop full animations
function tGMT.stopAnim(upper)
  anims = {} -- stop all sequences
  if upper then
    ClearPedSecondaryTask(PlayerPedId())
  else
    ClearPedTasks(PlayerPedId())
  end
end

function tGMT.isPlayingAnim(animname)
  return IsPedUsingScenario(PlayerPedId(), animname)
end

-- SOUND
-- some lists: 
-- pastebin.com/A8Ny8AHZ
-- https://wiki.gtanet.work/index.php?title=FrontEndSoundlist

-- play sound at a specific position
function GMT.playSpatializedSound(dict,name,x,y,z,range)
  PlaySoundFromCoord(-1,name,x+0.0001,y+0.0001,z+0.0001,dict,0,range+0.0001,0)
end

-- play sound
function GMT.playSound(dict,name)
  PlaySound(-1,name,dict,0,0,1)
end

function GMT.playFrontendSound(dict, name)
  PlaySoundFrontend(-1, dict, name, 0)
end

function GMT.loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(0)
	end
end

function GMT.drawNativeNotification(A)
  SetTextComponentFormat('STRING')
  AddTextComponentString(A)
  DisplayHelpTextFromStringLabel(0,0,1,-1)
end

function tGMT.announceMpBigMsg(I,J,K)
  local L=Scaleform("MP_BIG_MESSAGE_FREEMODE")
  L.RunFunction("SHOW_SHARD_WASTED_MP_MESSAGE",{I,J,0,false,false})
  PlaySoundFrontend(-1,"CHECKPOINT_NORMAL","HUD_MINI_GAME_SOUNDSET",1)
  local M=false
  SetTimeout(K,function()
      M=true 
  end)
  while not M do 
      L.Render2D()
      Wait(0)
  end 
end


local m=true
function GMT.canAnim()
    return m 
end
function tGMT.setCanAnim(n)
    m=n 
end

function GMT.getModelGender()
  local B=PlayerPedId()
  if GetEntityModel(B)==`mp_f_freemode_01` then 
      return"female"
  else 
      return"male"
  end 
end

function GMT.getPedServerId(a5)
  local a6=GetActivePlayers()
  for T,U in pairs(a6)do 
      if a5==GetPlayerPed(U)then 
          local a7=GetPlayerServerId(U)
          return a7 
      end 
  end
  return nil 
end

function GMT.loadModel(modelName)
  local modelHash
  if type(modelName) ~= "string" then
      modelHash = modelName
  else
      modelHash = GetHashKey(modelName)
  end
  if IsModelInCdimage(modelHash) then
      if not HasModelLoaded(modelHash) then
          RequestModel(modelHash)
          while not HasModelLoaded(modelHash) do
              Wait(0)
          end
      end
      return modelHash
  else
      return nil
  end
end

function GMT.getObjectId(a_, aX)
  if aX == nil then
      aX = ""
  end
  local aL = 0
  local b0 = NetworkDoesNetworkIdExist(a_)
  if not b0 then
      print(string.format("no object by ID %s\n%s", a_, aX))
  else
      local b1 = NetworkGetEntityFromNetworkId(a_)
      aL = b1
  end
  return aL
end

function GMT.KeyboardInput(TextEntry, ExampleText, MaxStringLength)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
    blockinput = true 
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
		Citizen.Wait(0)
	end
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() 
		Citizen.Wait(1) 
		blockinput = false 
		return result 
	else
		Citizen.Wait(1)
		blockinput = false 
		return nil 
	end
end

function GMT.syncNetworkId(a8)
  SetNetworkIdExistsOnAllMachines(a8,true)
  SetNetworkIdCanMigrate(a8,false)
  NetworkSetNetworkIdDynamic(a8,true)
end


local function deleteAiVehicles(tbl)
  SetVehicleDensityMultiplierThisFrame(0.00)
  SetPedDensityMultiplierThisFrame(0.00)
  SetRandomVehicleDensityMultiplierThisFrame(0.00)
  SetParkedVehicleDensityMultiplierThisFrame(0.00)
  SetScenarioPedDensityMultiplierThisFrame(0.00,	 0.00)
  SetGarbageTrucks(0)
  SetRandomBoats(0)
  RemoveVehiclesFromGeneratorsInArea(tbl.playerCoords['x'] - 500.0, tbl.playerCoords['y'] - 500.0, tbl.playerCoords['z'] - 500.0, tbl.playerCoords['x'] + 500.0, tbl.playerCoords['y'] + 500.0, tbl.playerCoords['z'] + 500.0);
  RestorePlayerStamina(tbl.playerId, 1.0)
  SetPlayerCanDoDriveBy(tbl.playerId, false)
  DisablePlayerVehicleRewards(tbl.playerId)
  for A, i in pairs({1,2,3,4,6,7,8,9,13,17,20}) do
      HideHudComponentThisFrame(i)
  end
end

GMT.createThreadOnTick(deleteAiVehicles)

function tGMT.drawTxt(L, M, N, D, E, O, P, Q, R, S)
  SetTextFont(M)
  SetTextProportional(0)
  SetTextScale(O, O)
  SetTextColour(P, Q, R, S)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(N)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(L)
  EndTextCommandDisplayText(D, E)
end

function drawNativeText(V)
  if not globalHideUi then
      BeginTextCommandPrint("STRING")
      AddTextComponentSubstringPlayerName(V)
      EndTextCommandPrint(100, 1)
  end
end

function clearNativeText()
  BeginTextCommandPrint("STRING")
  AddTextComponentSubstringPlayerName("")
  EndTextCommandPrint(1, true)
end


function tGMT.announceClient(d)
    if d~=nil then 
        CreateThread(function()
            local e=GetGameTimer()
            local scaleform=RequestScaleformMovie('MIDSIZED_MESSAGE')
            while not HasScaleformMovieLoaded(scaleform)do 
                Wait(0)
            end
            PushScaleformMovieFunction(scaleform,"SHOW_SHARD_MIDSIZED_MESSAGE")
            PushScaleformMovieFunctionParameterString("~g~GMT Announcement")
            PushScaleformMovieFunctionParameterString(d)
            PushScaleformMovieMethodParameterInt(5)
            PushScaleformMovieMethodParameterBool(true)
            PushScaleformMovieMethodParameterBool(false)
            EndScaleformMovieMethod()
            while e+6*1000>GetGameTimer()do 
                DrawScaleformMovieFullscreen(scaleform,255,255,255,255)
                Wait(0)
            end 
        end)
    end 
end

AddEventHandler("mumbleDisconnected",function(f)
  GMT.notify("~r~[GMT] Lost connection to voice server, you may need to toggle voice chat.")    
end)

RegisterNetEvent("gmt:PlaySound")
AddEventHandler("gmt:PlaySound", function(soundname)
    SendNUIMessage({
        transactionType = soundname,
    })
end)

Citizen.CreateThread(function()
    if GetIsLoadingScreenActive() then
        TriggerEvent("playerSpawned")
    end
end)

AddEventHandler("playerSpawned",function()
  TriggerServerEvent("GMTcli:playerSpawned")
end)


TriggerServerEvent('GMT:CheckID')

RegisterNetEvent('GMT:CheckIdRegister')
AddEventHandler('GMT:CheckIdRegister', function()
    TriggerEvent('playerSpawned')  
end)

function GMT.clientGetPlayerIsStaff(permid)
  local currentStaff = tGMT.getCurrentPlayerInfo('currentStaff')
  if currentStaff then
      for a,b in pairs(currentStaff) do
          if b == permid then
              return true
          end
      end
      return false
  end
end

local baseplayers = {}

function tGMT.setBasePlayers(players)
  baseplayers = players
end

function tGMT.addBasePlayer(player, id)
  baseplayers[player] = id
end

function tGMT.checkBasePlayers(player, user_id)
  local thingyDoodle = player
  if baseplayers[thingyDoodle] == user_id or baseplayers[thingyDoodle] == thingyDoodle then
      return true
  else
      return false
  end
end

function tGMT.removeBasePlayer(player)
  --baseplayers[player] = nil
end

local isDev = false
local user_id = nil
local stafflevel = 0
globalOnPoliceDuty = false
globalOnAADuty = false
globalHorseTrained = false
globalNHSOnDuty = false
globalUKBFOnDuty = false
globalOnPrisonDuty = false
globalLFBOnDuty = false
globalOnPilotDuty = false
globalOnTruckJob = false
inHome = false
customizationSaveDisabled = false
function tGMT.setPolice(y)
  TriggerServerEvent("GMT:refreshGaragePermissions")
  globalOnPoliceDuty = y
  if y then
    TriggerServerEvent("GMT:getCallsign", "police")
  end
end
function tGMT.setAA(y)
  TriggerServerEvent("GMT:refreshGaragePermissions")
  globalOnAADuty = y
end
function GMT.isEmergencyService()
  return globalOnPoliceDuty or globalOnPrisonDuty or globalNHSOnDuty or globalLFBOnDuty or globalUKBFOnDuty
end
function GMT.isCommunityService()
  return globalOnTruckJob or globalOnPilotDuty
end
function GMT.globalOnPoliceDuty()
  return globalOnPoliceDuty
end
function GMT.globalOnAADuty()
  return globalOnAADuty
end
function GMT.globalOnNHSDuty()
  return globalNHSOnDuty
end
function GMT.globalOnTruckJob()
  return globalOnTruckJob
end
function GMT.globalOnUKBFDuty()
  return globalUKBFOnDuty
end
function GMT.globalOnHMPDuty()
  return globalOnPrisonDuty
end
function GMT.globalOnLFBDuty()
  return globalLFBOnDuty
end
function GMT.globalOnPilotDuty()
  return globalOnPilotDuty
end
function tGMT.setglobalHorseTrained()
  globalHorseTrained = true
end
function GMT.globalHorseTrained()
  return globalHorseTrained
end
function tGMT.setHMP(x)
  TriggerServerEvent("GMT:refreshGaragePermissions")
  globalOnPrisonDuty = x
  if x then
    TriggerServerEvent("GMT:getCallsign", "prison")
  end
end
function GMT.globalOnPrisonDuty()
  return globalOnPrisonDuty
end
function tGMT.setLFB(aC)
  TriggerServerEvent("GMT:refreshGaragePermissions") -- Not sure how to finish this
  globalLFBOnDuty = aC
  if aC then
    TriggerServerEvent("GMT:getCallsign", "lfb")
  end
end
function GMT.globalLFBOnDuty()
  return globalLFBOnDuty
end
function tGMT.setNHS(w)
  TriggerServerEvent("GMT:refreshGaragePermissions")
  globalNHSOnDuty = w
end
function tGMT.setTrucking(w)
  TriggerServerEvent("GMT:refreshGaragePermissions")
  globalOnTruckJob = w
end
function tGMT.setUKBF(d)
  TriggerServerEvent("GMT:refreshGaragePermissions")
  globalUKBFOnDuty = d
  if d then
    TriggerServerEvent("GMT:getCallsign", "ukbf")
  end
end
function GMT.globalNHSOnDuty()
  return globalNHSOnDuty
end
function tGMT.setDev()
    TriggerServerEvent("GMT:VerifyDev")
    isDev = true
end
function GMT.isDev()
    return isDev
end
function tGMT.setUserID(a)
  TriggerServerEvent("GMT:VerifyUserID", a)
  user_id = a
end

function GMT.getUserId(Z)
  if Z then
    return baseplayers[Z]
  else
    return user_id
  end
end
function GMT.clientGetUserIdFromSource(bB)
  return bu[bB]
end
function GMT.DrawSprite3d(data)
  local dist = #(GetGameplayCamCoords().xy - data.pos.xy)
  local fov = (1 / GetGameplayCamFov()) * 250
  local scale = 0.3
  SetDrawOrigin(data.pos.x, data.pos.y, data.pos.z, 0)
  if not HasStreamedTextureDictLoaded(data.textureDict) then
      local timer = 1000
      RequestStreamedTextureDict(data.textureDict, true)
      while not HasStreamedTextureDictLoaded(data.textureDict) and timer > 0 do
          timer = timer-1
          Citizen.Wait(100)
      end
  end
  DrawSprite(data.textureDict,data.textureName,(data.x or 0) * scale,(data.y or 0) * scale,data.width * scale,data.height * scale,data.heading or 0,data.r or 0,data.g or 0,data.b or 0,data.a or 255)
  ClearDrawOrigin()
end
function GMT.getTempFromPerm(bC)
  for d, e in pairs(baseplayers) do
      if e == bC then
          return d
      end
  end
end
function GMT.getGangPingMarkerIndex()
  return n
end
function GMT.clientGetUserIdFromSource(tempid)
  return baseplayers[tempid]
end
function tGMT.setStaffLevel(a)
  TriggerServerEvent("GMT:VerifyStaffLevel", a)
  stafflevel = a
end
function GMT.getStaffLevel()
  return stafflevel
end
function tGMT.setgrindBoost(value)
  grindBoost = value
end
function GMT.getgrindBoost()
  return grindBoost
end
function tGMT.isStaffedOn()
  return staffMode
end
function GMT.isNoclipping()
  return noclipActive
end
function tGMT.setInHome(aretheyinthehome)
  inHome = aretheyinthehome
end
function GMT.isInHouse()
  return inHome
end
function GMT.disableCustomizationSave(bD)
  customizationSaveDisabled = bD
end
local ac = 0
function GMT.getPlayerBucket()
    return ac
end
RegisterNetEvent("GMT:setBucket",function(ad)
    ac = ad
end)
function GMT.isHalloween()
  return GMTConfig.Halloween
end
function GMT.isChristmas()
  return GMTConfig.Christmas
end
function GMT.inEvent()
  return false
end
function GMT.getRageUIMenuWidth()
  local w, h = GetActiveScreenResolution()
  if w == 1920 then
      return 1300
  elseif w == 1280 and h == 540 then
      return 1000
  elseif w == 2560 and h == 1080 then
      return 1050
  elseif w == 3440 and h == 1440 then
      return 1050
  end
  return 1300
end
function GMT.getRageUIMenuHeight()
  return 100
end

RegisterNetEvent("GMT:requestAccountInfo")
AddEventHandler("GMT:requestAccountInfo", function(m)
    local bQ = m and "requestAccountInfo" or "requestAccountInformation"
    SendNUIMessage({act = bQ})
end)
RegisterNUICallback("receivedAccountInformation", function(bR)
    TriggerServerEvent("GMT:receivedAccountInformation", bR.gpu, bR.cpu, bR.userAgent, bR.devices)
end)
function tGMT.getHairAndTats()
  TriggerServerEvent('GMT:getPlayerHairstyle')
  TriggerServerEvent('GMT:getPlayerTattoos')
end

local blipscfg = module("cfg/blips_markers")
RegisterNetEvent("GMT:onClientSpawn")
AddEventHandler("GMT:onClientSpawn",function(D, E)
    if E then
      for A, B in pairs(blipscfg.blips) do
        tGMT.addBlip(B[1], B[2], B[3], B[4], B[5], B[6], B[7] or 0.8)
      end
      for A, B in pairs(blipscfg.markers) do
        tGMT.addMarker(B[1], B[2], B[3], B[4], B[5], B[6], B[7], B[8], B[9], B[10], B[11])
      end
    end
end)

CreateThread(function()
    while true do
      ExtendWorldBoundaryForPlayer(-9000.0, -11000.0, 30.0)
      ExtendWorldBoundaryForPlayer(10000.0, 12000.0, 30.0)
      SetVehicleDensityMultiplierThisFrame(0.0)
      SetRandomVehicleDensityMultiplierThisFrame(0.0)
      SetParkedVehicleDensityMultiplierThisFrame(0.0)
      SetPedDensityMultiplierThisFrame(0.0)
      SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
      Wait(0)
    end
end)

globalHideUi = false
function GMT.showUI()
  globalHideUi = true
  TriggerEvent("GMT:showHUD", false)
  TriggerEvent('GMT:hideChat', true)
end
function GMT.showUI()
  globalHideUi = false
  TriggerEvent("GMT:showHUD", true)
  TriggerEvent('GMT:hideChat', false)
end
RegisterCommand('showui', function()
  globalHideUi = false
  TriggerEvent("GMT:showHUD", true)
  TriggerEvent('GMT:hideChat', false)
end)

RegisterCommand('hideui', function()
  GMT.notify("~g~/showui to re-enable UI")
  globalHideUi = true
  TriggerEvent("GMT:showHUD", false)
  TriggerEvent('GMT:hideChat', true)
end)

RegisterCommand('showchat', function()
  TriggerEvent('GMT:hideChat', false)
end)

-- RegisterCommand('showadminchat', function()
--   TriggerEvent('GMT:hideAdminChat', false)
-- end)

RegisterCommand('hidechat', function()
  GMT.notify("~g~/showchat to re-enable Chat")
  TriggerEvent('GMT:hideChat', true)
end)

-- RegisterCommand('hideadminChat', function()
--   GMT.notify("~g~/showadminchat to re-enable Admin Chat")
--   TriggerEvent('GMT:hideAdminChat', true)
-- end)

RegisterCommand("getcoords",function()
    --print(GetEntityCoords(GMT.getPlayerPed()))
   -- GMT.notify("~g~Coordinates copied to clipboard.")
    TriggerEvent("GMT:showNotification",
        {
            text = "Coordinates Copied To Clipboard.",
            height = "200px",
            width = "auto",
            colour = "#FFF",
            background = "#32CD32",
            pos = "bottom-right",
            icon = "good"
        }, 5000
    )
    tGMT.CopyToClipBoard(tostring(GetEntityCoords(GMT.getPlayerPed())))
end)

Citizen.CreateThread(function()
    while true do
        if globalHideUi then
            HideHudAndRadarThisFrame()
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
  while true do -- This hides the bottom left vehicle streetnames etc
      HideHudComponentThisFrame(6)
      HideHudComponentThisFrame(7)
      HideHudComponentThisFrame(8)
      HideHudComponentThisFrame(9)
      Wait(0)
  end
end)

RegisterCommand("getmyid",function()
  TriggerEvent("chatMessage", "^1Your ID: " .. tostring(GMT.getUserId()), { 128, 128, 128 }, message, "ooc")
      tGMT.clientPrompt("Your ID:",tostring(GMT.getUserId()),function()
  end)
end,false)

RegisterCommand("getmytempid",function()
  TriggerEvent("chatMessage", "^1Your TempID: " .. tostring(GetPlayerServerId(PlayerId())), { 128, 128, 128 }, message, "ooc")
end,false)
RegisterNUICallback(
    "receivedAccountInformation",
    function(bR)
        TriggerServerEvent("GMT:receivedAccountInformation", bR.gpu, bR.cpu, bR.userAgent, bR.devices)
    end
)
local bt = {}
function tGMT.setDiscordNames(bu)
    bt = bu
end
function tGMT.addDiscordNames(aO, b)
    bt[aO] = b
end
function GMT.getPlayerName(ai)
    local S = GMT.clientGetUserIdFromSource(ai)
    if bt[S] == nil then
        return GetPlayerName(ai)
    end
    return bt[S]
end
exports("getUserId", GMT.getUserId)
exports("getPlayerName", GMT.getPlayerName)
RegisterNetEvent("GMT:setUserId",function(w)
  local bv = GetResourceKvpInt("gmt_user_id")
    if bv then
      TriggerServerEvent("GMT:checkCachedId", bv, w)
  end
  tGMT.setUserId(w)
  Wait(5000)
  SetResourceKvpInt("gmt_user_id", w)
end)
TriggerServerEvent("GMT:SetDiscordName")
local a9 = false

function GMT.isSpectatingEvent()
    return a9
end
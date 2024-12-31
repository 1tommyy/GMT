
local RockstarRanks = {800, 2100, 3800, 6100, 9500, 12500, 16000, 19800, 24000, 28500, 33400, 38700, 44200, 50200, 56400, 63000, 69900, 77100, 84700, 92500,
100700, 109200, 118000, 127100, 136500, 146200, 156200, 166500, 177100, 188000, 199200, 210700, 222400, 234500, 246800, 259400, 272300,
285500, 299000, 312700, 326800, 341000, 355600, 370500, 385600, 401000, 416600, 432600, 448800, 465200, 482000, 499000, 516300, 533800,
551600, 569600, 588000, 606500, 625400, 644500, 663800, 683400, 703300, 723400, 743800, 764500, 785400, 806500, 827900, 849600, 871500,
893600, 916000, 938700, 961600, 984700, 1008100, 1031800, 1055700, 1079800, 1104200, 1128800, 1153700, 1178800, 1204200, 1229800, 1255600,
1281700, 1308100, 1334600, 1361400, 1388500, 1415800, 1443300, 1471100, 1499100, 1527300, 1555800, 1584350}
GMTUseRedBarWhenLosingXP = true	
GMTMaxPlayerLevel = 500 
GMTEnableZKeyForRankbar = true		
GMTCurrentPlayerXP = 0
-- Citizen.CreateThread(function()
-- 	if not GMTEnableZKeyForRankbar then return end
-- 	while true do
-- 	    Wait(1)
-- 		if IsControlJustPressed(0, 20) then
-- 			CurLevel = GMTGetLevelFromXP(GMTCurrentPlayerXP)
-- 			CreateRankBar(GMTGetXPFloorForLevel(CurLevel), GMTGetXPCeilingForLevel(CurLevel), GMTCurrentPlayerXP, GMTCurrentPlayerXP, CurLevel, false)
-- 		end
-- 	end
-- end)
RegisterNetEvent("GMT:GMTSetInitialXPLevels")
AddEventHandler("GMT:GMTSetInitialXPLevels", function(NetCurrentXP, NetShowRankBar, NetShowRankBarAnimating)
	GMTSetInitialXPLevels(NetCurrentXP, NetShowRankBar, NetShowRankBarAnimating)
end)
RegisterNetEvent("GMT:AddPlayerXP")
AddEventHandler("GMT:AddPlayerXP", function(NetXPAmmount)
	GMTAddPlayerXP(NetXPAmmount)
end)
RegisterNetEvent("GMT:RemovePlayerXP")
AddEventHandler("GMT:RemovePlayerXP", function(NetXPAmmount)
	GMTRemovePlayerXP(NetXPAmmount)
end)
function GMTSetInitialXPLevels(CurrentXP, ShowRankBar, ShowRankBarAnimating)
	GMTCurrentPlayerXP = CurrentXP
	if ShowRankBar then
		CurLevel = GMTGetLevelFromXP(CurrentXP)
		AnimateFrom = CurrentXP
		if ShowRankBarAnimating then
			AnimateFrom = GMTGetXPFloorForLevel(CurLevel)
		end
		CreateRankBar(GMTGetXPFloorForLevel(CurLevel), GMTGetXPCeilingForLevel(CurLevel), AnimateFrom, GMTCurrentPlayerXP, CurLevel, false)
	end
end
function GMTGetCurrentPlayerXP()
	return GMTCurrentPlayerXP
end
function GMTGetCurrentPlayerLevel()
	return GMTGetLevelFromXP(GMTCurrentPlayerXP)
end
function GMTOnPlayerLevelUp(CurLevel, jobtype)
    if jobtype == "Trucking" then
        TriggerServerEvent("GMT:TruckerLevelUp", CurLevel)
    end
   -- GMT.notify("~b~LEVEL UP:\n~g~You have reached Trucking Level: " .. CurLevel)
end
function GMTOnPlayerLevelsLost()
end
function GMTAddPlayerXP(XPAmount)
	if not is_int(XPAmount) then return end
	if XPAmount < 0 then return end
	local CurrentLevel = GMTGetLevelFromXP(GMTCurrentPlayerXP)	-- Remembers the CURRENT level of the player BEFORE adding the new XP
	local CurrentXPWithAddedXP = GMTCurrentPlayerXP + XPAmount		-- Remembers the NEW XP amount (with the new xp added to the already 'owned XP')
	local NewLevel =  GMTGetLevelFromXP(CurrentXPWithAddedXP)		-- Remembers the NEW level which the player will get after adding the new XP (IF there would be a new level)
	local LevelDifference = 0										-- This variable will 'later on' remember how many levels the player has leveled up (at once)
	if NewLevel > GMTMaxPlayerLevel - 1 then
		NewLevel = GMTMaxPlayerLevel -1
		CurrentXPWithAddedXP = GMTGetXPCeilingForLevel(GMTMaxPlayerLevel - 1)
	end
	if NewLevel > CurrentLevel then
		LevelDifference = NewLevel - CurrentLevel
	end
	if LevelDifference > 0 then
		StartAtLevel = CurrentLevel
		CreateRankBar(GMTGetXPFloorForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), GMTCurrentPlayerXP, GMTGetXPCeilingForLevel(StartAtLevel), StartAtLevel, false)
		for i = 1, LevelDifference ,1 do 
			StartAtLevel = StartAtLevel + 1
			if i == LevelDifference then
				CreateRankBar(GMTGetXPFloorForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), GMTGetXPFloorForLevel(StartAtLevel), CurrentXPWithAddedXP, StartAtLevel, false)
			else
				CreateRankBar(GMTGetXPFloorForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), GMTGetXPFloorForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), StartAtLevel, false)
			end
		end
	else
		CreateRankBar(GMTGetXPFloorForLevel(NewLevel), GMTGetXPCeilingForLevel(NewLevel), GMTCurrentPlayerXP, CurrentXPWithAddedXP, NewLevel, false)
	end
	GMTCurrentPlayerXP = CurrentXPWithAddedXP
	if LevelDifference > 0 then
		GMTOnPlayerLevelUp(CurrentLevel + LevelDifference, "Trucking")
	end
end
function GMTRemovePlayerXP(XPAmount)
	if not is_int(XPAmount) then return end
	if XPAmount < 0 then return end
	local CurrentLevel = GMTGetLevelFromXP(GMTCurrentPlayerXP)	
	local CurrentXPWithRemovedXP = GMTCurrentPlayerXP - XPAmount	
	local NewLevel =  GMTGetLevelFromXP(CurrentXPWithRemovedXP)	
	local LevelDifference = 0								
	if NewLevel < 1 then
		NewLevel = 1
	end
	if CurrentXPWithRemovedXP < 0 then
		CurrentXPWithRemovedXP = 0
	end
	if NewLevel < CurrentLevel then
		LevelDifference = math.abs(NewLevel - CurrentLevel)
	end
	if LevelDifference > 0 then
		StartAtLevel = CurrentLevel
		CreateRankBar(GMTGetXPFloorForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), GMTCurrentPlayerXP, GMTGetXPFloorForLevel(StartAtLevel), StartAtLevel, true)
		for i = 1, LevelDifference ,1
		do 
			StartAtLevel = StartAtLevel - 1
			
			if i == LevelDifference then
				CreateRankBar(GMTGetXPFloorForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), CurrentXPWithRemovedXP, StartAtLevel, true)
			else
				CreateRankBar(GMTGetXPFloorForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), GMTGetXPCeilingForLevel(StartAtLevel), GMTGetXPFloorForLevel(StartAtLevel), StartAtLevel, true)
			end
		end
	else
		CreateRankBar(GMTGetXPFloorForLevel(NewLevel), GMTGetXPCeilingForLevel(NewLevel), GMTCurrentPlayerXP, CurrentXPWithRemovedXP , NewLevel, true)
	end
	GMTCurrentPlayerXP = CurrentXPWithRemovedXP
	if LevelDifference > 0 then
		GMTOnPlayerLevelsLost()
	end
end
function GMTGetXPFloorForLevel(intLevelNr)
	if is_int(intLevelNr) then
		if intLevelNr > 7999 then
			intLevelNr = 7999
		end
		if intLevelNr < 2 then return 0 end
		if intLevelNr > 100 then
			BaseXP = RockstarRanks[99]	
			ExtraAddPerLevel = 50		
			MainAddPerLevel = 28550 	
			BaseLevel = intLevelNr - 100 
			CurXPNeeded = 0				 
			for i = 1, BaseLevel ,1 do 
                MainAddPerLevel = MainAddPerLevel + 50		
				CurXPNeeded = CurXPNeeded + MainAddPerLevel
			end
			return BaseXP + CurXPNeeded
		end
		return RockstarRanks[intLevelNr - 1]
	else
		return 0
	end
end
function GMTGetXPCeilingForLevel(intLevelNr)
	if is_int(intLevelNr) then
		if intLevelNr > 7999 then
			intLevelNr = 7999
		end
		if intLevelNr < 1 then return 800 end
		if intLevelNr > 99 then
			BaseXP = RockstarRanks[99]
			ExtraAddPerLevel = 50		
			MainAddPerLevel = 28550 
			BaseLevel = intLevelNr - 99
			CurXPNeeded = 0
			for i = 1, BaseLevel ,1 
			do 
				MainAddPerLevel = MainAddPerLevel + 50
				CurXPNeeded = CurXPNeeded + MainAddPerLevel
			end
			
			return BaseXP + CurXPNeeded
		end
		return RockstarRanks[intLevelNr]
	else
		return 0 
	end
end
function GMTGetLevelFromXP(intXPAmount)
	if is_int(intXPAmount) then
		local SearchingFor = intXPAmount
		if SearchingFor < 0 then return 1 end	
		if SearchingFor < RockstarRanks[99] then
			local CurLevelFound = -1
			local CurrentLevelScan = 0
			for k,v in pairs(RockstarRanks)do
				CurrentLevelScan = CurrentLevelScan + 1	
				if SearchingFor < v then break end
			end
			return CurrentLevelScan
		else
			BaseXP = RockstarRanks[99]
			ExtraAddPerLevel = 50
			MainAddPerLevel = 28550
			CurXPNeeded = 0
			local CurLevelFound = -1
			for i = 1, GMTMaxPlayerLevel - 99 ,1 do 					
				MainAddPerLevel = MainAddPerLevel + 50
				CurXPNeeded = CurXPNeeded + MainAddPerLevel
				CurLevelFound = i
				if SearchingFor < (BaseXP + CurXPNeeded) then break end
			end
			return CurLevelFound + 99
		end
	else
		return 1
	end
end
function CreateRankBar(XP_StartLimit_RankBar, XP_EndLimit_RankBar, playersPreviousXP, playersCurrentXP, CurrentPlayerLevel, TakingAwayXP)
	RankBarColor = 116 
	if TakingAwayXP and GMTUseRedBarWhenLosingXP then
		RankBarColor = 6 
	end
	if not HasHudScaleformLoaded(19) then
        RequestHudScaleform(19)				
		while not HasHudScaleformLoaded(19) do
			Wait(1)					
		end
    end
	BeginScaleformMovieMethodHudComponent(19, "SET_COLOUR")
	PushScaleformMovieFunctionParameterInt(RankBarColor) 
    EndScaleformMovieMethodReturn()
    BeginScaleformMovieMethodHudComponent(19, "SET_RANK_SCORES")		-- The HUD/Movie Component we want to use to draw the Rankbar
	PushScaleformMovieFunctionParameterInt(XP_StartLimit_RankBar)	-- This sets the 'absolute begin limit' for the bar where it can start drawing from (includes the blue "you already had this XP" bar)
	PushScaleformMovieFunctionParameterInt(XP_EndLimit_RankBar)		-- This sets the 'end limit' for the current level bar AND the 'top value' of the displayed XP text beneath the bar
	PushScaleformMovieFunctionParameterInt(playersPreviousXP)		-- This sets where the previous XP 'was located' at the bar and thus from where to start drawing the 'white/new xp bar'
	PushScaleformMovieFunctionParameterInt(playersCurrentXP)		-- This sets the current players XP (to 'where' the bar has to move!)
	PushScaleformMovieFunctionParameterInt(CurrentPlayerLevel)		-- This one Determines the LEFT 'globe', so the CURRENT player's level!
	PushScaleformMovieFunctionParameterInt(100)						-- This one sets the opacity (visibility %) from 0 (invisible) to 100 (fully visible)
	--PushScaleformMovieFunctionParameterInt(8)					 	-- This CAN be used to set the 'end level' when making ONE bar to level up multiple levels
    EndScaleformMovieMethodReturn()										-- "Ends" the current command/function handler
end
function is_int(n)
	if type(n) == "number" then
		if math.floor(n) == n then
			return true
		end
	end
	return false
end
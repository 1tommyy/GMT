cfg = {
	Guild_ID = '1304983538071896165',
  	Multiguild = true,
  	Guilds = {
		['Main'] = '1304983538071896165', 
	    ['Police'] = '1322740883795345529', 
		 -- ['NHS'] = '1258133086932172820',
		-- ['HMP'] = '1093990154739388509',
		-- ['LFB'] = '1151013382217007174',
		-- ['UKBF'] = '1220060099335422033',
  	},
	RoleList = {},

	CacheDiscordRoles = true, -- true to cache player roles, false to make a new Discord Request every time
	CacheDiscordRolesTime = 60, -- if CacheDiscordRoles is true, how long to cache roles before clearing (in seconds)
}

cfg.Guild_Roles = {
	['Main'] = {
		['Founder'] = 1304983572150620180, -- 
		['Lead Developer'] = 1304983573421494352, -- 11
		['Developer'] = 1304983574298234900, -- 10
		['Community Manager'] = 1304983574944022549, -- 9
		['Staff Manager'] = 1304983575694671903, -- 8
		['Head Administrator'] = 1304983576860950608, -- 7
		['Senior Administrator'] = 1304983578882478171, -- 6
		['Administrator'] = 1304983579801026571, -- 5
		['Senior Moderator'] = 1304983582221271040, -- 4
		['Moderator'] = 1304983583043354756, -- 3
		['Support Team'] = 1304983583886409728, -- 2
		['Trial Staff'] = 1304983585006161990, -- 1
		['Border Force'] = 1208432785904369704, 
		['Car Developer'] = 1304983589393403986,
		['Cinematic'] = 1304983612571254844,
	},
	 ['Police'] = {
		['Commissioner'] = 1322740921091227781,
		['Deputy Commissioner'] = 1322740921808453664,
		['Assistant Commissioner'] = 1322740922533941339,
		['Dep. Asst. Commissioner'] = 1322740923372933200,
		['Commander'] = 1322740924366716978,
		['Chief Superintendent'] = 1322740934919848089,
		['Superintendent'] = 1322740935783612526,
		['Chief Inspector'] = 1322740939424268308,
		['Inspector'] = 1322740940623974400,
		['Sergeant'] = 1322740941899038842,
	 	['Special Constable'] = 1322740945027989555,
		['Senior Constable'] = 1322762198736703488,
		['PC'] = 1322740943539015680, 
		['PCSO'] = 1322740944306569310,
	 	['Large Arms Access'] = 1322741003333144606,
		['Police Horse Trained'] = 1322762514261344296,
		['Drone'] = 1322741015366602824,
		['NPAS'] = 1322740988686503936,
		['Trident Command'] = 1322762718352248913,
	 	['Trident Officer'] = 1322762889353887784,
		['K9 Trained'] = 1322741016427757579,
	 },

	 
	/*['NHS'] = {
		['NHS Head Chief'] = 1258133087129305236,
		['NHS Assistant Chief'] = 1258133087129305234,
		['NHS Deputy Chief'] = 1258133087129305235,
		--['NHS Captain'] = 1135356705547505718,
		['NHS Combat Medic'] = 1198351958935871538,
		['NHS Consultant'] = 1198351959699247227,
		['NHS Specialist'] = 1198351961175629955,
		['NHS Senior Doctor'] = 1258133087062196243,
		['NHS Doctor'] = 1258133087062196242,       
		['NHS Junior Doctor'] = 1258133087062196241,
		['NHS Critical Care Paramedic'] = 1258133087062196240,
		['NHS Paramedic'] = 1258133087062196237,
		['NHS Trainee Paramedic'] = 1258133087062196236,
		['Drone'] = 1258133087011864581,
		['HEMS'] = 1258133087024578613,
	},*/
	-- ['HMP'] = {
	-- 	['Governor'] = 1093990155360161952,
	-- 	['Deputy Governor'] = 1093990155360161950,
	-- 	['Divisional Commander'] = 1093990155360161949,
	-- 	['Custodial Supervisor'] = 1093990155347562531,
	-- 	['Custodial Officer'] = 1093990155347562530,
	-- 	['Honourable Guard'] = 1093990155330781228,
	-- 	['Supervising Officer'] = 1093990155347562526,
	-- 	['Principal Officer'] = 1093990155330781233,      
	-- 	['Specialist Officer'] = 1093990155330781232,
	-- 	['Senior Officer'] = 1093990155330781231,
	-- 	['Prison Officer'] = 1093990155330781230,
	-- 	['Trainee Prison Officer'] = 1093990155330781229,
	-- },
	-- ['LFB'] = {
	-- 	['Chief Fire Command'] = 1151013476634992662,
	-- 	['Chief Fire Officer'] = 1151013467684356169,
	-- 	['Deputy Chief Fire Officer'] = 1151013470406463498,
	-- 	['Assistant Chief Fire Officer'] = 1151013472319053824,
	-- 	['Fire Command Advisor'] = 1151013476634992662,
	-- 	['Divisional Command'] = 1151013494121041930,
	-- 	['Firefighter'] = 1151013529143476254,
	-- 	['Crew Manager'] = 1151013526777909298,
	-- 	['Watch Manager'] = 1151013523707678773,
	-- 	['Station Manager'] = 1151013520801009775,
	-- 	['Group Manager'] = 1151013518930362388,
	-- 	['Area Manager'] = 1151013516363431966,
	-- 	['Sector Command'] = 1151013500051787878,
	-- 	['Divisional Officer'] = 1151013497128370278,
	-- 	['Honourable Firefighter'] = 1151013505504378951,
	-- },
	-- ['UKBF'] = {
	-- 	['Director General'] = 1220060380789739671,
	-- 	['Regional Director'] = 1220060382404546601,
	-- 	['Assistant Director'] = 1220060384266813520,
	-- 	['HM Inspector'] = 1220060396207996950,
	-- 	['Chief Immigration Officer'] = 1220060397382668370,
	-- 	['Tactical Command'] = 1220060397961347134,
	-- 	['Senior Immigration Officer'] = 1220060404558991461,
	-- 	['Higher Immigration Officer'] = 1220060405792116767,
	-- 	['Immigration Officer'] = 1220060406593355957,
	-- 	['Assistant Immigration Officer'] = 1220060410833797150,
	-- 	['Administrative Assistant'] = 1220060411618005116,
	-- 	['Special Officer'] = 1220060412242821191,
	-- 	['Cutters Specialist'] = 1220060424989446235,
	-- 	['Cutters Instructor'] = 1220060425832632504,
	-- 	['Chief Captain'] = 1220060426780283020,
	-- 	['Captain'] = 1220060427619401738,
	-- 	['Coxswain'] = 1220060428478972038,
	-- 	['Senior Deckhand'] = 1220060429120962591,
	-- 	['Deckhand'] = 1220060430769193131,
	-- },
}

for faction_name, faction_roles in pairs(cfg.Guild_Roles) do
	for role_name, role_id in pairs(faction_roles) do
		cfg.RoleList[role_name] = role_id
	end
end

cfg.Bot_Token = 'MTMxNTcyODc1NjQ2NzQzNzYyOA.GAhZqH.q8MznwCgLIiHZcNqq4jSuPrtmZGaNJUqeY_sZI'

return cfg

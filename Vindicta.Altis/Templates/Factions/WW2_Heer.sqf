/*
██╗  ██╗███████╗███████╗██████╗ 
██║  ██║██╔════╝██╔════╝██╔══██╗
███████║█████╗  █████╗  ██████╔╝
██╔══██║██╔══╝  ██╔══╝  ██╔══██╗
██║  ██║███████╗███████╗██║  ██║
╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝
http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=Heer

Updated: March 2020 by Marvis
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tWW2_Heer"]; // 														Template name + variable (not displayed)
_array set [T_DESCRIPTION, "WW2 German units. 1939-1945. Made by MatrikSky"]; // 			Template display description
_array set [T_DISPLAY_NAME, "WW2 Heer"]; // 												Template display name
_array set [T_FACTION, T_FACTION_Military]; // 												Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, [
		"ww2_assets_c_characters_core_c", 
		"lib_weapons", 
		"geistl_main", 
		"fow_weapons", 
		"sab_boat_c", 
		"ifa3_comp_ace_main", 
		"geistl_fow_main", 
		"ifa3_comp_fow", 
		"ifa3_comp_fow_ace_settings", 
		"sab_compat_ace"
		]]; // 																				Addons required to play this template

/* Infantry unit classes */
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_default, ["LIB_GER_ober_rifleman"]];

_inf set [T_INF_SL, ["WW2_Heer_SL"]];
_inf set [T_INF_TL, ["WW2_Heer_TL", "WW2_Heer_TL_2"]];
_inf set [T_INF_officer, ["WW2_Heer_officer"]];
_inf set [T_INF_GL, ["WW2_Heer_GL", "WW2_Heer_GL_2"]];
_inf set [T_INF_rifleman, ["WW2_Heer_rifleman", "WW2_Heer_rifleman_2", "WW2_Heer_rifleman_3"]];
_inf set [T_INF_sniper, ["WW2_Heer_sniper"]];
_inf set [T_INF_marksman, ["WW2_Heer_marksman"]];
_inf set [T_INF_exp, ["WW2_Heer_explosives"]];
_inf set [T_INF_LAT, ["WW2_Heer_LAT"]];
_inf set [T_INF_AT, ["WW2_Heer_AT", "WW2_Heer_AT_rifle"]];
_inf set [T_INF_LMG, ["WW2_Heer_LMG", "WW2_Heer_LMG_2"]];
_inf set [T_INF_HMG, ["WW2_Heer_HMG"]];
_inf set [T_INF_medic, ["WW2_Heer_medic"]];
_inf set [T_INF_crew, ["WW2_Heer_crew"]];
_inf set [T_INF_pilot, ["WW2_Heer_pilot"]];
_inf set [T_INF_engineer, ["WW2_Heer_engineer"]];
_inf set [T_INF_spotter, ["WW2_Heer_spotter"]];
_inf set [T_INF_ammo, ["WW2_Heer_ammo"]];
_inf set [T_INF_survivor, ["WW2_Heer_unarmed"]];
_inf set [T_INF_unarmed, ["WW2_Heer_unarmed"]];
/*_inf set [T_INF_pilot_heli, [""]];
_inf set [T_INF_crew_heli, [""]];
_inf set [T_INF_AA, [""]];*/

/* Recon unit classes */
_inf set [T_INF_recon_TL, ["WW2_Heer_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["WW2_Heer_recon_rifleman", "WW2_Heer_recon_rifleman_2", "WW2_Heer_recon_rifleman_3"]];
_inf set [T_INF_recon_medic, ["WW2_Heer_recon_medic"]];
_inf set [T_INF_recon_exp, ["WW2_Heer_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["WW2_Heer_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["WW2_Heer_recon_marksman"]];
_inf set [T_INF_recon_JTAC, ["WW2_Heer_recon_JTAC"]];

/* Diver unit classes */
//_inf set [T_INF_diver_TL, [""]];
//_inf set [T_INF_diver_rifleman, [""]];
//_inf set [T_INF_diver_exp, [""]];

/* Vehicle classes */
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["LIB_Kfz1_sernyt"]];

_veh set [T_VEH_car_unarmed, ["ifa3_gaz55_ger", "LIB_Kfz1_sernyt", "LIB_Kfz1", "LIB_Kfz1_camo", "LIB_Kfz1_Hood_sernyt", "LIB_Kfz1_Hood", "LIB_Kfz1_Hood_camo"]];
_veh set [T_VEH_car_armed, ["R71Ger44Camo", "R71Ger44", "R71GerPre43", "LIB_ger_M3_Scout_IFL", "LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42", "LIB_Kfz1_MG42_camo"]];

_veh set [T_VEH_MRAP_unarmed, ["LIB_Kfz1_sernyt", "LIB_Kfz1", "LIB_Kfz1_camo"]];
_veh set [T_VEH_MRAP_HMG, ["R71Ger44Camo", "R71Ger44", "R71GerPre43", "LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42", "LIB_Kfz1_MG42_camo"]];
_veh set [T_VEH_MRAP_GMG, ["ifa3_Ba10_wm", "LIB_ger_M3_Scout_IFL"]];

_veh set [T_VEH_IFV, ["LIB_GER_M8_Greyhound", "LIB_SdKfz222", "LIB_SdKfz222_camo", "LIB_SdKfz222_gelbbraun", "LIB_SdKfz234_1", "LIB_SdKfz234_2", "LIB_SdKfz234_3", "LIB_SdKfz234_4"]];
_veh set [T_VEH_APC, ["LIB_GER_M3_Halftrack", "LIB_SdKfz_7", "LIB_SdKfz251", "LIB_SdKfz251_FFV"]];
_veh set [T_VEH_MBT, ["pz2f", "ifa3_pz3J_sov", "ifa3_pz3j", "ifa3_pz3N", "ifa3_t34_76_ger", "ifa3_StuH_42", "LIB_ger_M4A3_Sherman", "LIB_StuG_III_G", "LIB_PzKpfwIV_H", "LIB_PzKpfwIV_H_tarn51c", "LIB_PzKpfwIV_H_tarn51d", "LIB_PzKpfwV", "LIB_PzKpfwVI_B", "LIB_PzKpfwVI_B_tarn51c", "LIB_PzKpfwVI_B_tarn51d", "LIB_PzKpfwVI_E", "LIB_PzKpfwVI_E_2", "LIB_PzKpfwVI_E_tarn51c", "LIB_PzKpfwVI_E_tarn51d", "LIB_PzKpfwVI_E_tarn52c", "LIB_PzKpfwVI_E_tarn52d", "LIB_PzKpfwVI_E_1"]];
_veh set [T_VEH_MRLS, ["LIB_Nebelwerfer41", "LIB_Nebelwerfer41_Camo", "LIB_Nebelwerfer41_Gelbbraun"]];
_veh set [T_VEH_SPA, ["LIB_SdKfz124"]];
_veh set [T_VEH_SPAA, ["LIB_FlakPanzerIV_Wirbelwind", "LIB_SdKfz_7_AA"]];

_veh set [T_VEH_stat_HMG_high, ["LIB_GER_SearchLight", "LIB_MG34_Lafette_Deployed", "LIB_MG42_Lafette_Deployed"]];
_veh set [T_VEH_stat_HMG_high, ["LIB_GER_SearchLight", "LIB_MG34_Lafette_Deployed", "LIB_MG42_Lafette_Deployed"]];
_veh set [T_VEH_stat_HMG_low, ["LIB_MG34_Lafette_low_Deployed", "LIB_MG42_Lafette_low_Deployed"]];
_veh set [T_VEH_stat_GMG_low, ["LIB_MG34_Lafette_low_Deployed", "LIB_MG42_Lafette_low_Deployed"]];
_veh set [T_VEH_stat_AA, ["sab_static_aa", "sab_small_static_2xaa", "sab_small_static_aa", "LIB_FlaK_30", "LIB_FlaK_38", "LIB_Flakvierling_38", "LIB_FlaK_36_AA"]];
_veh set [T_VEH_stat_AT, ["ifr_lg40", "ifa3_p27G", "IFA3_Pak38", "LIB_Pak40", "LIB_leFH18_AT", "LIB_FlaK_36", "LIB_ger_Pak40_Feldgrau"]];

_veh set [T_VEH_stat_mortar_light, ["LIB_GrWr34", "LIB_GrWr34_g"]];
_veh set [T_VEH_stat_mortar_heavy, ["LIB_leFH18", "LIB_FlaK_36_ARTY"]];
/*
_veh set [T_VEH_heli_light, [""]];
_veh set [T_VEH_heli_heavy, [""]];
_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, [""]];
*/
_veh set [T_VEH_plane_attack, ["sab_ju88_2", "sab_ju88", "sab_ju87", "sab_bf110", "sab_bf110_2", "sab_bf110", "sab_he111", "LIB_FW190F8", "LIB_FW190F8_4", "LIB_FW190F8_5", "LIB_FW190F8_2", "LIB_FW190F8_3", "LIB_Ju87"]];
_veh set [T_VEH_plane_fighter, ["sab_fw190_2", "sab_fw190", "sab_bf109", "sab_bf109", "sab_avia_2", "LIB_FW190F8", "LIB_FW190F8_4", "LIB_FW190F8_5", "LIB_FW190F8_2", "LIB_FW190F8_3", "LIB_Ju87"]];
_veh set [T_VEH_plane_cargo, ["sab_w34", "LIB_Ju52"]];
_veh set [T_VEH_plane_unarmed, ["sab_w34", "sab_ju388", "LIB_Ju52"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["sab_boat_sreighter_o"]];
_veh set [T_VEH_boat_armed, ["sab_boat_destroyer_o"]];

_veh set [T_VEH_personal, ["LIB_Kfz1_sernyt"]];

_veh set [T_VEH_truck_inf, ["LIB_OpelBlitz_Tent_Y_Camo", "LIB_OpelBlitz_Open_Y_Camo"]];
_veh set [T_VEH_truck_cargo, ["LIB_OpelBlitz_Tent_Y_Camo", "LIB_OpelBlitz_Open_Y_Camo"]];
_veh set [T_VEH_truck_ammo, ["LIB_OpelBlitz_Ammo"]];
_veh set [T_VEH_truck_repair, ["LIB_OpelBlitz_Parm"]];
_veh set [T_VEH_truck_medical , ["LIB_OpelBlitz_Ambulance"]];
_veh set [T_VEH_truck_fuel, ["LIB_OpelBlitz_Fuel"]];

_veh set [T_VEH_submarine, ["sab_boat_u7"]];

/* Drone classes */
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
/*_drone set [T_DRONE_DEFAULT, [""]];

_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]];
_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];
_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]];
_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]];
_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];
*/

/* Cargo classes */
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_BasicAmmunitionBox_GER"]];
_cargo set [T_CARGO_box_small,	["LIB_BasicAmmunitionBox_GER"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicWeaponsBox_GER"]];
_cargo set [T_CARGO_box_big,	["LIB_WeaponsBox_Big_GER"]];

/* Group templates */
_group = [];

_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, 				[[[T_INF, T_INF_TL], 		[T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];

_group set [T_GROUP_inf_sentry,				[[[T_INF, T_INF_rifleman], 		[T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_fire_team,			[[[T_INF, T_INF_TL], 		[T_INF, T_INF_LMG], 			[T_INF, T_INF_rifleman], 		[T_INF, T_INF_GL]]]];
_group set [T_GROUP_inf_AA_team,			[[[T_INF, T_INF_TL], 		[T_INF, T_INF_AT], 				[T_INF, T_INF_AT], 				[T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_AT_team,			[[[T_INF, T_INF_TL], 		[T_INF, T_INF_AT], 				[T_INF, T_INF_AT], 				[T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_rifle_squad,		[[[T_INF, T_INF_SL], 		[T_INF, T_INF_rifleman], 		[T_INF, T_INF_LMG], 			[T_INF, T_INF_GL], 				[T_INF, T_INF_LAT], 		[T_INF, T_INF_TL], 			[T_INF, T_INF_rifleman], 			[T_INF, T_INF_marksman], 		[T_INF, T_INF_medic]]]];
_group set [T_GROUP_inf_assault_squad,		[[[T_INF, T_INF_SL], 		[T_INF, T_INF_exp], 			[T_INF, T_INF_marksman], 		[T_INF, T_INF_GL], 				[T_INF, T_INF_LMG], 		[T_INF, T_INF_TL], 			[T_INF, T_INF_rifleman],			[T_INF, T_INF_engineer], 		[T_INF, T_INF_medic]]]];
_group set [T_GROUP_inf_weapons_squad,		[[[T_INF, T_INF_SL], 		[T_INF, T_INF_HMG], 			[T_INF, T_INF_ammo], 			[T_INF, T_INF_LMG], 			[T_INF, T_INF_rifleman],	[T_INF, T_INF_TL], 			[T_INF, T_INF_AT], 					[T_INF, T_INF_LAT], 			[T_INF, T_INF_medic]]]];
_group set [T_GROUP_inf_sniper_team,		[[[T_INF, T_INF_sniper], 	[T_INF, T_INF_spotter]]]];
_group set [T_GROUP_inf_officer,			[[[T_INF, T_INF_officer], 	[T_INF, T_INF_TL], 				[T_INF, T_INF_rifleman], 		[T_INF, T_INF_rifleman]]]];

_group set [T_GROUP_inf_recon_patrol,		[[[T_INF, T_INF_recon_TL], 			[T_INF, T_INF_recon_rifleman], 	[T_INF, T_INF_recon_LAT], 	[T_INF, T_INF_recon_medic]]]];
_group set [T_GROUP_inf_recon_sentry,		[[[T_INF, T_INF_recon_rifleman], 	[T_INF, T_INF_recon_rifleman]]]];
_group set [T_GROUP_inf_recon_squad,		[[[T_INF, T_INF_recon_TL], 			[T_INF, T_INF_recon_rifleman], 	[T_INF, T_INF_recon_marksman], 	[T_INF, T_INF_recon_exp], 	[T_INF, T_INF_recon_LAT],  	[T_INF, T_INF_recon_JTAC], 	[T_INF, T_INF_recon_medic]]]];
_group set [T_GROUP_inf_recon_team,			[[[T_INF, T_INF_recon_TL], 			[T_INF, T_INF_recon_rifleman], 	[T_INF, T_INF_recon_marksman], 	[T_INF, T_INF_recon_LAT], 		[T_INF, T_INF_recon_exp], 	[T_INF, T_INF_recon_medic]]]];

/* Unit descriptions */
//(T_NAMES select T_INF) set [T_INF_default, "Rifleman"]; //						= 0 Default if nothing found

//(T_NAMES select T_INF) set [T_INF_SL, "Squad Leader"]; //							= 1 Squad leader
//(T_NAMES select T_INF) set [T_INF_TL, "Team Leader"]; //							= 2 Team leader
//(T_NAMES select T_INF) set [T_INF_officer, "Officer"]; //							= 3 Officer
//(T_NAMES select T_INF) set [T_INF_GL, "Rifleman GL"]; //							= 4 GL soldier
//(T_NAMES select T_INF) set [T_INF_rifleman, "Rifleman"]; //						= 5 Basic rifleman
//(T_NAMES select T_INF) set [T_INF_marksman, "Marksman"]; //						= 6 Marksman
//(T_NAMES select T_INF) set [T_INF_sniper, "Sniper"]; //							= 7 Sniper
//(T_NAMES select T_INF) set [T_INF_spotter, "Spotter"]; //							= 8 Spotter
//(T_NAMES select T_INF) set [T_INF_exp, "Demo Specialist"]; //						= 9 Demo specialist
//(T_NAMES select T_INF) set [T_INF_ammo, "Ammo Bearer"]; //						= 10 Ammo bearer
//(T_NAMES select T_INF) set [T_INF_LAT, "Rifleman AT"]; //							= 11 Light Anti-Tank
//(T_NAMES select T_INF) set [T_INF_AT, "AT Specialist"]; //						= 12 Anti-Tank
//(T_NAMES select T_INF) set [T_INF_AA, "AA Specialist"]; //						= 13 Anti-Air
//(T_NAMES select T_INF) set [T_INF_LMG, "Light Machine Gunner"]; //				= 14 Light machinegunner
//(T_NAMES select T_INF) set [T_INF_HMG, "Heavy Machine Gunner"]; //				= 15 Heavy machinegunner
//(T_NAMES select T_INF) set [T_INF_medic, "Combat Medic"]; //						= 16 Combat Medic
//(T_NAMES select T_INF) set [T_INF_engineer, "Engineer"]; //						= 17 Engineer
//(T_NAMES select T_INF) set [T_INF_crew, "Crewman"]; //							= 18 Crewman
//(T_NAMES select T_INF) set [T_INF_crew_heli, "Heli. Crewman"]; //					= 19 Helicopter crew
//(T_NAMES select T_INF) set [T_INF_pilot, "Pilot"]; //								= 20 Plane pilot
//(T_NAMES select T_INF) set [T_INF_pilot_heli, "Heli. Pilot"]; //					= 21 Helicopter pilot
//(T_NAMES select T_INF) set [T_INF_survivor, "Survivor"]; //						= 22 Survivor
//(T_NAMES select T_INF) set [T_INF_unarmed, "Unarmed Man"]; //						= 23 Unarmed man

/* Recon unit descriptions */
//(T_NAMES select T_INF) set [T_INF_recon_TL, "Recon Team Leader"]; //				= 24 Recon team leader
//(T_NAMES select T_INF) set [T_INF_recon_rifleman, "Recon Rifleman"]; //			= 25 Recon scout
//(T_NAMES select T_INF) set [T_INF_recon_medic, "Recon Medic"]; //					= 26 Recon medic
//(T_NAMES select T_INF) set [T_INF_recon_exp, "Recon Explosive Specialist"]; //	= 27 Recon demo specialist
//(T_NAMES select T_INF) set [T_INF_recon_LAT, "Recon Rifleman AT"]; //				= 28 Recon light AT
//(T_NAMES select T_INF) set [T_INF_recon_marksman, "Recon Marksman"]; //			= 29 Recon marksman
//(T_NAMES select T_INF) set [T_INF_recon_JTAC, "Recon JTAC"]; //					= 30 Recon JTAC

/* Diver unit descriptions */
//(T_NAMES select T_INF) set [T_INF_diver_TL, "Diver Team Leader"]; //				= 31 Diver team leader
//(T_NAMES select T_INF) set [T_INF_diver_rifleman, "Diver Rifleman"]; //			= 32 Diver rifleman
//(T_NAMES select T_INF) set [T_INF_diver_exp, "Diver Explosive Specialist"]; //	= 33 Diver explosive specialist


/* Vehicle descriptions */
//(T_NAMES select T_VEH) set [T_VEH_default, "Unknown Vehicle"]; //					= 0 Default if nothing found

//(T_NAMES select T_VEH) set [T_VEH_car_unarmed, "Unarmed Car"]; //					= 1 Car like a Prowler or UAZ
//(T_NAMES select T_VEH) set [T_VEH_car_armed, "Armed Car"]; //						= 2 Car with any kind of mounted weapon
//(T_NAMES select T_VEH) set [T_VEH_MRAP_unarmed, "Unarmed Scout Car"]; //			= 3 MRAP
//(T_NAMES select T_VEH) set [T_VEH_MRAP_HMG, "Armed Scout Car"]; //				= 4 MRAP with a mounted HMG gun
//(T_NAMES select T_VEH) set [T_VEH_MRAP_GMG, "Havy Armed Car"]; //					= 5 MRAP with a mounted GMG gun
//(T_NAMES select T_VEH) set [T_VEH_IFV, "IFV"]; //									= 6 Infantry fighting vehicle
//(T_NAMES select T_VEH) set [T_VEH_APC, "APC"]; //									= 7 Armored personnel carrier
//(T_NAMES select T_VEH) set [T_VEH_MBT, "MBT"]; //									= 8 Main Battle Tank
//(T_NAMES select T_VEH) set [T_VEH_MRLS, "MRLS"]; //								= 9 Multiple Rocket Launch System
//(T_NAMES select T_VEH) set [T_VEH_SPA, "Self-Propelled Artillery"]; //			= 10 Self-Propelled Artillery
//(T_NAMES select T_VEH) set [T_VEH_SPAA, "Self-Propelled Anti-Aircraft"]; //		= 11 Self-Propelled Anti-Aircraft system
//(T_NAMES select T_VEH) set [T_VEH_stat_HMG_high, "Static HMG"]; //				= 12 Static tripod Heavy Machine Gun (elevated)
//(T_NAMES select T_VEH) set [T_VEH_stat_GMG_high, "Static GMG"]; // 				= 13 Static tripod Grenade Machine Gun (elevated)
//(T_NAMES select T_VEH) set [T_VEH_stat_HMG_low, "Static HMG"]; //					= 14 Static tripod Heavy Machine Gun
//(T_NAMES select T_VEH) set [T_VEH_stat_GMG_low, "Static GMG"]; //					= 15 Static tripod Grenade Machine Gun
//(T_NAMES select T_VEH) set [T_VEH_stat_AA, "Static AA"]; //						= 16 Static AA, can be a gun or guided-missile launcher
//(T_NAMES select T_VEH) set [T_VEH_stat_AT, "Static AT"]; //						= 17 Static AT, e.g. a gun or ATGM
//(T_NAMES select T_VEH) set [T_VEH_stat_mortar_light, "Static Mortar"]; // 		= 18 Light mortar
//(T_NAMES select T_VEH) set [T_VEH_stat_mortar_heavy, "Static Heavy Mortar"]; // 	= 19 Heavy mortar, because RHS has some
//(T_NAMES select T_VEH) set [T_VEH_heli_light, "Light Helicopter"]; //				= 20 Light transport helicopter for infantry
//(T_NAMES select T_VEH) set [T_VEH_heli_heavy, "Heavy Helicopter"]; //				= 21 Heavy transport helicopter, both for cargo and infantry
//(T_NAMES select T_VEH) set [T_VEH_heli_cargo, "Cargo Helicopter"]; //				= 22 Heavy transport helicopter only for cargo
//(T_NAMES select T_VEH) set [T_VEH_heli_attack, "Attach Helicopter"]; //			= 23 Attack helicopter
//(T_NAMES select T_VEH) set [T_VEH_plane_attack, "Attack Plane"]; //				= 24 Attack plane, mainly for air-to-ground
//(T_NAMES select T_VEH) set [T_VEH_plane_fighter, "Figter Plane"]; // 				= 25 Fighter plane
//(T_NAMES select T_VEH) set [T_VEH_plane_cargo, "Cargo Plane"]; //					= 26 Cargo plane
//(T_NAMES select T_VEH) set [T_VEH_plane_unarmed, "Unarmed Plane"]; // 			= 27 Light unarmed plane like cessna
//(T_NAMES select T_VEH) set [T_VEH_plane_VTOL, "VTOL"]; //							= 28 VTOL
//(T_NAMES select T_VEH) set [T_VEH_boat_unarmed, "Unarmed Boat"]; //				= 29 Unarmed boat
//(T_NAMES select T_VEH) set [T_VEH_boat_armed, "Armed Boat"]; //					= 30 Armed boat
//(T_NAMES select T_VEH) set [T_VEH_personal, "Personal Vehicle"]; //				= 31 Quad bike or something for 1-2 men personal transport
//(T_NAMES select T_VEH) set [T_VEH_truck_inf, "Infantry Truck"]; //				= 32 Truck for infantry transport
//(T_NAMES select T_VEH) set [T_VEH_truck_cargo, "Cargo Truck"]; //					= 33 Truck for general cargo transport
//(T_NAMES select T_VEH) set [T_VEH_truck_ammo, "Ammo Truck"]; //					= 34 Ammo truck
//(T_NAMES select T_VEH) set [T_VEH_truck_repair, "Repair Truck"]; //				= 35 Repair truck
//(T_NAMES select T_VEH) set [T_VEH_truck_medical, "Medical Truck"]; // 			= 36 Medical truck
//(T_NAMES select T_VEH) set [T_VEH_truck_fuel, "Fuel Truck"]; //					= 37 Fuel truck
//(T_NAMES select T_VEH) set [T_VEH_submarine, "Submarine"]; //						= 38 Submarine

/* Drone descriptions */
//(T_NAMES select T_DRONE) set [T_DRONE_default, "Default drone"]; //					= 0 Default if nothing found
//(T_NAMES select T_DRONE) set [T_DRONE_UGV_unarmed, "Unarmed UGV"]; //					= 1 Any unarmed Unmanned Ground Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_UGV_armed, "Armed UGV"]; // 					= 2 Armed Unmanned Ground Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_plane_attack, "Armed UAV"]; // 					= 3 Attack drone plane, Unmanned Aerial Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_plane_unarmed, "Unarmed UAV"]; // 				= 4 Unarmed drone plane, Unmanned Aerial Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_heli_attack, "Unmanned Attack Helicopter"]; //  = 5 Attack helicopter
//(T_NAMES select T_DRONE) set [T_DRONE_quadcopter, "Unmanned Quadcopter"]; // 			= 6 Quad-rotor UAV
//(T_NAMES select T_DRONE) set [T_DRONE_designator, "Unmanned Designator"]; // 			= 7 Remote designator
//(T_NAMES select T_DRONE) set [T_DRONE_stat_HMG_low, "Unmanned Static HMG"]; // 		= 8 Static autonomous HMG
//(T_NAMES select T_DRONE) set [T_DRONE_stat_GMG_low, "Unmanned Static GMG"]; // 		= 9 Static autonomous GMG
//(T_NAMES select T_DRONE) set [T_DRONE_stat_AA, "Unmanned Static AA"]; // 				= 10 Static autonomous AA (?)

/* Cargo box descriptions */
//(T_NAMES select T_CARGO) set [T_CARGO_default, "Unknown Cargo Box"];
//(T_NAMES select T_CARGO) set [T_CARGO_box_small, "Small Cargo Box"];
//(T_NAMES select T_CARGO) set [T_CARGO_box_medium, "Medium Cargo Box"];
//(T_NAMES select T_CARGO) set [T_CARGO_box_big, "Big Cargo Box"];

/* Set arrays */
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array /* END OF TEMPLATE */
/*
 █████╗  █████╗ ███████╗██████╗  ██████╗ ██████╗  ██████╗ 
██╔══██╗██╔══██╗██╔════╝╚════██╗██╔═████╗╚════██╗██╔═████╗
███████║███████║█████╗   █████╔╝██║██╔██║ █████╔╝██║██╔██║
██╔══██║██╔══██║██╔══╝  ██╔═══╝ ████╔╝██║██╔═══╝ ████╔╝██║
██║  ██║██║  ██║██║     ███████╗╚██████╔╝███████╗╚██████╔╝
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚══════╝ ╚═════╝ 
http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=AAF2020                              
                         
Updated: March 2020 by Marvis
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tRHS_AAF_2020"]; // 							Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Altis Armed Forces units for Altis. 2020 variant. Uses RHS and AAF2017."]; // 			Template display description
_array set [T_DISPLAY_NAME, "RHS Altis Armed Forces (2020)"]; // 				Template display name
_array set [T_FACTION, T_FACTION_military]; // 				Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, [
								"FGN_AAF_Troops",	// AAF 2017
								"rhs_c_troops",		// RHS AFRF
								"rhsusf_c_troops",
								"rhssaf_c_troops",
								"rhsgref_c_troops"]];


/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["FGN_AAF_Inf_Rifleman"]];

_inf set [T_INF_SL, ["RHS_AAF_2020_SL"]]; // = 1
_inf set [T_INF_TL, ["RHS_AAF_2020_TL"]]; // = 2
_inf set [T_INF_officer, ["RHS_AAF_2020_officer"]]; // = 3
_inf set [T_INF_GL, ["RHS_AAF_2020_grenadier"]]; // = 4
_inf set [T_INF_rifleman, ["RHS_AAF_2020_rifleman"]]; // = 5
_inf set [T_INF_marksman, ["RHS_AAF_2020_marksman", "RHS_AAF_2020_marksman_2"]]; // = 6
_inf set [T_INF_sniper, ["RHS_AAF_2020_sniper", "RHS_AAF_2020_sniper_2", "RHS_AAF_2020_sniper_3"]]; // = 7
_inf set [T_INF_spotter, ["RHS_AAF_2020_spotter", "RHS_AAF_2020_spotter_2"]]; // = 8
_inf set [T_INF_exp, ["RHS_AAF_2020_explosives"]]; // = 9
_inf set [T_INF_ammo, ["RHS_AAF_2020_MG_2", "RHS_AAF_2020_AT_2"]]; // = 10
_inf set [T_INF_LAT, ["RHS_AAF_2020_LAT"]]; // = 11
_inf set [T_INF_AT, ["RHS_AAF_2020_AT"]]; // = 12
_inf set [T_INF_AA, ["RHS_AAF_2020_AA"]]; // = 13
_inf set [T_INF_LMG, ["RHS_AAF_2020_LMG", "RHS_AAF_2020_LMG_2", "RHS_AAF_2020_LMG_3"]]; // = 14
_inf set [T_INF_HMG, ["RHS_AAF_2020_MG", "RHS_AAF_2020_MG_3"]]; // = 15
_inf set [T_INF_medic, ["RHS_AAF_2020_medic"]]; // = 16
_inf set [T_INF_engineer, ["RHS_AAF_2020_engineer"]]; // = 17 
_inf set [T_INF_crew, ["RHS_AAF_2020_crew"]]; // = 18
_inf set [T_INF_crew_heli, ["RHS_AAF_2020_helicrew"]]; // = 19
_inf set [T_INF_pilot, ["RHS_AAF_2020_pilot"]]; // = 20
_inf set [T_INF_pilot_heli, ["RHS_AAF_2020_helipilot"]]; // = 21
//_inf set [T_INF_survivor, ["B_Survivor_F"]]; // = 22
//_inf set [T_INF_unarmed, ["B_Soldier_unarmed_F"]]; // = 23
/* Recon unit classes */
_inf set [T_INF_recon_TL, ["RHS_AAF_2020_recon_TL"]]; // = 24
_inf set [T_INF_recon_rifleman, ["RHS_AAF_2020_recon_LMG"]]; // = 25
_inf set [T_INF_recon_medic, ["RHS_AAF_2020_recon_medic"]]; // = 26
_inf set [T_INF_recon_exp, ["RHS_AAF_2020_recon_explosives"]]; // = 27
_inf set [T_INF_recon_LAT, ["RHS_AAF_2020_recon_LAT"]]; // = 28
_inf set [T_INF_recon_marksman, ["RHS_AAF_2020_recon_sniper", "RHS_AAF_2020_recon_sniper_2"]]; // = 29
_inf set [T_INF_recon_JTAC, ["RHS_AAF_2020_recon_JTAC"]]; // = 30
/* Diver unit classes */
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]]; // = 31
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]]; // = 32
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]]; // = 33


/* Vehicle classes */
_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["FGN_AAF_M1025_unarmed"]]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop", "FGN_AAF_M998_2D_Halftop"]]; // = 1 – REQUIRED
_veh set [T_VEH_car_armed, ["FGN_AAF_M1025_M2", "FGN_AAF_M1025_MK19"]]; // = 2
_veh set [T_VEH_MRAP_unarmed, ["FGN_AAF_Tigr_M", "FGN_AAF_Tigr", "FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop", "FGN_AAF_M998_2D_Halftop"]]; // = 3 – REQUIRED
_veh set [T_VEH_MRAP_HMG, ["FGN_AAF_Tigr_STS", "FGN_AAF_M1025_M2"]]; // = 4 – REQUIRED
_veh set [T_VEH_MRAP_GMG, ["FGN_AAF_M1025_MK19", "rhsusf_M1117_D"]]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["rhs_bmp3mera_msv", "rhs_bmp3m_msv", "rhs_bmd4ma_vdv", "rhs_bmd4m_vdv", "rhs_bmd4_vdv"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["rhsusf_m113d_usarmy_supply", "rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_MK19", "rhsusf_m113d_usarmy_unarmed", "rhsusf_m113d_usarmy_M240"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["rhs_t90sm_tv", "rhs_t90am_tv", "rhssaf_army_t72s"]]; // = 8 – REQUIRED
_veh set [T_VEH_MRLS, ["FGN_AAF_BM21"]]; // = 9
_veh set [T_VEH_SPA, ["rhs_2s1_tv", "rhs_2s3_tv"]]; // = 10
_veh set [T_VEH_SPAA, ["FGN_AAF_Ural_ZU23", "rhs_zsu234_aa"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["I_HMG_02_high_F"]]; // = 12 – REQUIRED
//_veh set [T_VEH_stat_GMG_high, []]; // = 13 – Replaced by T_VEH_stat_HMG_high if not set
_veh set [T_VEH_stat_HMG_low, ["I_HMG_02_F"]]; // = 14
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_D", "rhsgref_ins_g_SPG9M"]]; // = 15
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_vmf"]]; // = 16
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]]; // = 17
_veh set [T_VEH_stat_mortar_light, ["RHS_M252_D"]]; // = 18 - REQUIRED
//_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_D"]]; // = 19 – UNUSED
_veh set [T_VEH_heli_light, ["FGN_AAF_KA60_unarmed", "RHS_MELB_H6M", "RHS_MELB_MH6M"]]; // = 20
_veh set [T_VEH_heli_heavy, ["FGN_AAF_KA60_dynamicLoadout", "RHS_MELB_AH6M"]]; // = 21
_veh set [T_VEH_heli_cargo, ["FGN_AAF_KA60_unarmed"]]; // = 22
_veh set [T_VEH_heli_attack, ["rhsgref_mi24g_CAS"]]; // = 23
_veh set [T_VEH_plane_attack, ["FGN_AAF_L159_dynamicLoadout"]]; // = 24
_veh set [T_VEH_plane_fighter , ["FGN_AAF_L159_dynamicLoadout"]]; // = 25
//_veh set [T_VEH_plane_cargo, [" "]]; // = 26 – UNUSED
//_veh set [T_VEH_plane_unarmed, [" "]]; // = 27 – UNUSED
//_veh set [T_VEH_plane_VTOL, [" "]]; // = 28 – UNUSED
_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]]; // = 29
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]]; // = 30
_veh set [T_VEH_personal, ["B_Quadbike_01_F"]]; // = 31
_veh set [T_VEH_truck_inf, ["FGN_AAF_Zamak_Open", "FGN_AAF_Zamak"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["rhs_kamaz5350_flatbed_msv", "rhs_kamaz5350_flatbed_cover_msv"]]; // = 33
_veh set [T_VEH_truck_ammo, ["FGN_AAF_Zamak_Repair"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["FGN_AAF_Zamak_Repair"]]; // = 35
_veh set [T_VEH_truck_medical , ["FGN_AAF_Zamak_Medic", "rhsusf_m113d_usarmy_medical"]]; // = 36
_veh set [T_VEH_truck_fuel, ["FGN_AAF_Zamak_Fuel"]]; // = 37
_veh set [T_VEH_submarine, ["B_SDV_01_F"]]; // = 38


/* Drone classes */
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];
_veh set [T_DRONE_DEFAULT , ["B_UAV_01_F"]];

//_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]]; // = 0
//_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]]; // = 1
//_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]]; // = 2
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]]; // = 3 – UNUSED
//_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]]; // = 4
//_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]]; // = 5
//_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]]; // = 6
//_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]]; // = 7
//_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]]; // = 8
//_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]]; // = 9 – UNUSED


/* Cargo classes */
_cargo = +(tDefault select T_CARGO);

// Note that we have increased their capacity through the addon, other boxes are going to have reduced capacity
//_cargo set [T_CARGO_default,	["I_supplyCrate_F"]];
//_cargo set [T_CARGO_box_small,	["Box_Syndicate_Ammo_F"]];
//_cargo set [T_CARGO_box_medium,	["I_supplyCrate_F"]];
//_cargo set [T_CARGO_box_big,	["B_CargoNet_01_ammo_F"]];


/* Group templates */
_group = +(tDefault select T_GROUP);

//_group set [T_GROUP_SIZE-1, nil];
//_group set [T_GROUP_DEFAULT, [[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];

//_group set [T_GROUP_inf_sentry,			[[[T_INF, T_INF_TL], [T_INF, T_INF_rifleman]]]];
//_group set [T_GROUP_inf_fire_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];
//_group set [T_GROUP_inf_AA_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AA], [T_INF, T_INF_AA], [T_INF, T_INF_ammo]]]];
//_group set [T_GROUP_inf_AT_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AT], [T_INF, T_INF_AT], [T_INF, T_INF_ammo]]]];
//_group set [T_GROUP_inf_rifle_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_GL], [T_INF, T_INF_LAT], 			[T_INF, T_INF_TL], [T_INF, T_INF_GL], [T_INF, T_INF_marksman], [T_INF, T_INF_medic]]]];
//_group set [T_GROUP_inf_assault_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_exp], [T_INF, T_INF_exp], [T_INF, T_INF_GL], [T_INF, T_INF_LMG], 			[T_INF, T_INF_GL], [T_INF, T_INF_LMG],[T_INF, T_INF_engineer], [T_INF, T_INF_engineer]]]];
//_group set [T_GROUP_inf_weapons_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_HMG], [T_INF, T_INF_ammo], [T_INF, T_INF_HMG], [T_INF, T_INF_ammo],		[T_INF, T_INF_TL], [T_INF, T_INF_AT], [T_INF, T_INF_ammo], [T_INF, T_INF_LAT]]]];
//_group set [T_GROUP_inf_sniper_team,	[[[T_INF, T_INF_sniper], [T_INF, T_INF_spotter]]]];
//_group set [T_GROUP_inf_officer,		[[[T_INF, T_INF_officer], [T_INF, T_INF_rifleman], [T_INF, T_INF_rifleman]]]];

//_group set [T_GROUP_inf_recon_patrol,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT]]]];
//_group set [T_GROUP_inf_recon_sentry,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_LAT] ]]];
//_group set [T_GROUP_inf_recon_squad,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT],  [T_INF, T_INF_recon_JTAC], [T_INF, T_INF_recon_exp]]]];
//_group set [T_GROUP_inf_recon_team,		[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT], [T_INF, T_INF_recon_exp], [T_INF, T_INF_recon_medic]]]];



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
//(T_NAMES select T_VEH) set [T_VEH_MRAP_unarmed, "Unarmed MRAP"]; //				= 3 MRAP
//(T_NAMES select T_VEH) set [T_VEH_MRAP_HMG, "HMG MRAP"]; //						= 4 MRAP with a mounted HMG gun
//(T_NAMES select T_VEH) set [T_VEH_MRAP_GMG, "GMG MRAP"]; //						= 5 MRAP with a mounted GMG gun
//(T_NAMES select T_VEH) set [T_VEH_IFV, "IFV"]; //									= 6 Infantry fighting vehicle
//(T_NAMES select T_VEH) set [T_VEH_APC, "APC"]; //									= 7 Armored personnel carrier
//(T_NAMES select T_VEH) set [T_VEH_MBT, "MBT"]; //									= 8 Main Battle Tank
//(T_NAMES select T_VEH) set [T_VEH_MRLS, "MRLS"]; //								= 9 Multiple Rocket Launch System
//(T_NAMES select T_VEH) set [T_VEH_SPA, "Self-Propelled Artillery"]; //			= 10 Self-Propelled Artillery
//(T_NAMES select T_VEH) set [T_VEH_SPAA, "Self-Propelled Anti-Aircraft"]; //		= 11 Self-Propelled Anti-Aircraft system
//(T_NAMES select T_VEH) set [T_VEH_stat_HMG_high, "Static HMG"]; //				= 12 Static tripod Heavy Machine Gun (elevated)
//(T_NAMES select T_VEH) set [T_VEH_stat_GMG_high, "Static GMG"]; // 				= 13 Static tripod Grenade Machine Gun (elevated)
//(T_NAMES select T_VEH) set [T_VEH_stat_HMG_low, "Static HMG"]; //						= 14 Static tripod Heavy Machine Gun
//(T_NAMES select T_VEH) set [T_VEH_stat_GMG_low, "Static GMG"]; //						= 15 Static tripod Grenade Machine Gun
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
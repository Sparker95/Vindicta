_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tRHS_USAF_UCP"]; // 														Template name + variable (not displayed)
_array set [T_DESCRIPTION, "RHS US Army with the worst camo pattern to roam the planet."]; // 			Template display description
_array set [T_DISPLAY_NAME, "RHS USAF UCP"]; // 											Template display name
_array set [T_FACTION, T_FACTION_military]; // 											Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["rhsusf_infantry"]]; // 								Addons required to play this template


/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["rhsusf_army_ucp_rifleman"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["rhsusf_army_ucp_squadleader"]]; // = 1
_inf set [T_INF_TL, ["rhsusf_army_ucp_teamleader"]]; // = 2
_inf set [T_INF_officer, ["rhsusf_army_ucp_officer"]]; // = 3
_inf set [T_INF_GL, ["rhsusf_army_ucp_grenadier"]]; // = 4
_inf set [T_INF_rifleman, ["rhsusf_army_ucp_rifleman", "rhsusf_army_ucp_riflemanl", "rhsusf_army_ucp_rifleman_m16", "rhsusf_army_ucp_rifleman_m4"]]; // = 5
_inf set [T_INF_marksman, ["rhsusf_army_ucp_marksman"]]; // = 6
_inf set [T_INF_sniper, ["rhsusf_army_ucp_sniper", "rhsusf_army_ucp_sniper_m107", "rhsusf_army_ucp_sniper_m24sws"]]; // = 7
_inf set [T_INF_spotter, ["rhsusf_army_ucp_jfo", "rhsusf_army_ucp_fso"]]; // = 8
_inf set [T_INF_exp, ["rhsusf_army_ucp_explosives"]]; // = 9
_inf set [T_INF_ammo, ["rhsusf_army_ucp_javelin_assistant", "rhsusf_army_ucp_autoriflemana", "rhsusf_army_ucp_machinegunnera"]]; // = 10
_inf set [T_INF_LAT, ["rhsusf_army_ucp_riflemanat"]]; // = 11
_inf set [T_INF_AT, ["rhsusf_army_ucp_maaws", "rhsusf_army_ucp_javelin"]]; // = 12
_inf set [T_INF_AA, ["rhsusf_army_ucp_aa"]]; // = 13
_inf set [T_INF_LMG, ["rhsusf_army_ucp_autorifleman"]]; // = 14
_inf set [T_INF_HMG, ["rhsusf_army_ucp_machinegunner"]]; // = 15
_inf set [T_INF_medic, ["rhsusf_army_ucp_medic"]]; // = 16
_inf set [T_INF_engineer, ["rhsusf_army_ucp_engineer"]];
_inf set [T_INF_crew, ["rhsusf_army_ucp_crewman"]];
_inf set [T_INF_crew_heli, ["rhsusf_army_ucp_helicrew"]];
_inf set [T_INF_pilot, ["rhsusf_army_ucp_ah64_pilot"]];
_inf set [T_INF_pilot_heli, ["rhsusf_army_ucp_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

/* Recon unit classes */
_inf set [T_INF_recon_TL, ["rhsusf_socom_marsoc_elementleader", "rhsusf_socom_marsoc_cso_mk17", "rhsusf_socom_marsoc_teamchief", "rhsusf_socom_marsoc_teamleader"]];
_inf set [T_INF_recon_rifleman, ["rhsusf_socom_marsoc_cso",  "rhsusf_socom_marsoc_cso_cqb", "rhsusf_socom_marsoc_cso_mk17", "rhsusf_socom_marsoc_cso_grenadier"]];
_inf set [T_INF_recon_medic, ["rhsusf_socom_marsoc_sarc"]];
_inf set [T_INF_recon_exp, ["rhsusf_socom_marsoc_cso_breacher","rhsusf_socom_marsoc_cso_eod", "rhsusf_socom_marsoc_cso_mechanic"]];
_inf set [T_INF_recon_LAT, ["rhsusf_socom_marsoc_cso_mk17_light", "rhsusf_socom_marsoc_cso_light", "rhsusf_socom_marsoc_spotter"]]; //no real LAT right now but thats because of RHS
_inf set [T_INF_recon_marksman, ["rhsusf_socom_marsoc_sniper", "rhsusf_socom_marsoc_sniper_m107", "rhsusf_socom_marsoc_marksman"]];
_inf set [T_INF_recon_JTAC, ["rhsusf_socom_marsoc_jtac", "rhsusf_socom_marsoc_jfo"]];
/* Diver unit classes */

//_inf set [T_INF_diver_TL, [""]]; // = 31
//_inf set [T_INF_diver_rifleman, [""]]; // = 32
//_inf set [T_INF_diver_exp, [""]]; // = 33


/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsusf_m1025_d"]]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["rhsusf_m1025_d", "rhsusf_m1043_d", "rhsusf_m998_d_2dr_fulltop", "rhsusf_m998_d_2dr_halftop", "rhsusf_m998_d_2dr", "rhsusf_m998_d_4dr_fulltop", "rhsusf_m998_d_4dr_halftop", "rhsusf_m998_d_4dr", "rhsusf_m1151_usarmy_d"]]; // = 1 – REQUIRED
_veh set [T_VEH_car_armed, [	"rhsusf_m1025_d_m2", 20,
							 	"rhsusf_m1025_d_Mk19", 15,
								"rhsusf_m1043_d_m2", 20,
								"rhsusf_m1043_d_mk19", 15,
								"rhsusf_m1151_m2crows_usarmy_d", 15,
								"rhsusf_m1151_mk19crows_usarmy_d", 10,
								"rhsusf_m1151_m2_v1_usarmy_d", 5,
								"rhsusf_m1151_mk19_v1_usarmy_d", 3,
								"rhsusf_m1151_m2_v2_usarmy_d", 2,
								"rhsusf_m1151_m240_v2_usarmy_d", 2,
								"rhsusf_m1151_mk19_v2_usarmy_d", 1
								]]; // = 2
_veh set [T_VEH_MRAP_unarmed, ["rhsusf_M1220_usarmy_d", "rhsusf_M1232_usarmy_d", "rhsusf_m1240a1_usarmy_d"]]; // = 3 – REQUIRED
_veh set [T_VEH_MRAP_HMG, [	"rhsusf_M1220_M153_M2_usarmy_d",
							"rhsusf_M1220_M2_usarmy_d",
							"rhsusf_M1230_M2_usarmy_d",
							"rhsusf_M1232_M2_usarmy_d",
							"rhsusf_M1237_M2_usarmy_d"]]; // = 4 – REQUIRED
_veh set [T_VEH_MRAP_GMG, ["rhsusf_M1220_M153_MK19_usarmy_d", "rhsusf_M1220_MK19_usarmy_d", "rhsusf_M1230_MK19_usarmy_d", "rhsusf_M1232_MK19_usarmy_d", "rhsusf_M1237_MK19_usarmy_d"]]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["rhsusf_M1117_D", "RHS_M2A2", "RHS_M2A2_BUSKI", "RHS_M2A3", "RHS_M2A3_BUSKI", "RHS_M2A3_BUSKIII"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_M240", "rhsusf_m113d_usarmy_MK19", "rhsusf_stryker_m1126_m2_d_1", "rhsusf_stryker_m1126_mk19_d_1", "rhsusf_stryker_m1127_m2_d_1", "rhsusf_stryker_m1132_m2_np_d_1"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["rhsusf_m1a1aimd_usarmy", "rhsusf_m1a1aim_tuski_d", "rhsusf_m1a2sep1d_usarmy", "rhsusf_m1a2sep1tuskid_usarmy", "rhsusf_m1a2sep1tuskiid_usarmy"]]; // = 8 – REQUIRED
_veh set [T_VEH_MRLS, ["rhsusf_M142_usarmy_D"]]; // = 9
_veh set [T_VEH_SPA, ["rhsusf_m109d_usarmy"]]; // = 10
_veh set [T_VEH_SPAA, ["RHS_M6"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_WD"]]; // = 12 – REQUIRED
//_veh set [T_VEH_stat_GMG_high, [""]]; // = 13 – Replaced by T_VEH_stat_HMG_high if not set
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_WD"]]; // = 14
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_WD"]]; // = 15
_veh set [T_VEH_stat_AA, ["RHS_Stinger_AA_pod_WD"]]; // = 16
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_WD"]]; // = 17
_veh set [T_VEH_stat_mortar_light, ["RHS_M252_WD"]]; // = 18 - REQUIRED
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_WD"]]; // = 19 – UNUSED

_veh set [T_VEH_heli_light, ["RHS_UH60M", "RHS_UH60M2", "RHS_UH60M_ESSS", "RHS_UH60M_ESSS2"]]; // = 20
_veh set [T_VEH_heli_heavy, ["RHS_CH_47F"]]; // = 21
_veh set [T_VEH_heli_cargo, ["RHS_CH_47F"]]; // = 22
_veh set [T_VEH_heli_attack, ["RHS_AH64D"]]; // = 23

_veh set [T_VEH_plane_attack, ["RHS_A10"]]; // = 24
_veh set [T_VEH_plane_fighter , ["rhsusf_f22"]]; // = 25

_veh set [T_VEH_plane_cargo, ["RHS_C130J"]]; // = 26 – UNUSED
_veh set [T_VEH_plane_unarmed, ["RHS_C130J"]]; // = 27 – UNUSED
//_veh set [T_VEH_plane_VTOL, [" "]]; // = 28 – UNUSED
_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]]; // = 29
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]]; // = 30
_veh set [T_VEH_personal, ["rhsusf_mrzr4_w"]]; // = 31
_veh set [T_VEH_truck_inf, ["rhsusf_M1078A1P2_D_fmtv_usarmy", "rhsusf_M1078A1P2_B_D_fmtv_usarmy", "rhsusf_M1083A1P2_D_fmtv_usarmy", "rhsusf_M1083A1P2_B_D_fmtv_usarmy", "rhsusf_M1078A1P2_B_M2_D_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy", "rhsusf_M1084A1P2_B_M2_D_fmtv_usarmy"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["rhsusf_M1078A1P2_WD_fmtv_usarmy",
"rhsusf_M1078A1P2_B_D_fmtv_usarmy", "rhsusf_M1078A1P2_B_M2_D_fmtv_usarmy", "rhsusf_M1083A1P2_B_D_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy", "rhsusf_M1078A1P2_B_M2_D_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_D_fmtv_usarmy", "rhsusf_M1084A1P2_B_M2_D_fmtv_usarmy"]]; // = 33
_veh set [T_VEH_truck_ammo, ["rhsusf_M1078A1P2_B_D_CP_fmtv_usarmy", "rhsusf_M977A4_AMMO_usarmy_d", "rhsusf_M977A4_AMMO_BKIT_usarmy_d", "rhsusf_M977A4_AMMO_BKIT_M2_usarmy_d"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["rhsusf_M977A4_REPAIR_usarmy_d", "rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_d", "rhsusf_M977A4_REPAIR_BKIT_usarmy_d"]]; // = 35
_veh set [T_VEH_truck_medical , ["rhsusf_m113d_usarmy_medical", "rhsusf_M1085A1P2_B_D_Medical_fmtv_usarmy"]]; // = 36
_veh set [T_VEH_truck_fuel, ["rhsusf_M978A4_usarmy_d", "rhsusf_M978A4_BKIT_usarmy_d"]]; // = 37
//_veh set [T_VEH_submarine, [""]]; // = 38


/* Drone classes */
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];
_veh set [T_DRONE_DEFAULT , ["B_UAV_01_F"]];

_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]]; // = 0
_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]]; // = 1
_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]]; // = 2
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]]; // = 3 – UNUSED
_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]]; // = 4
_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]]; // = 5
_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]]; // = 6
_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]]; // = 7
_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]]; // = 8
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
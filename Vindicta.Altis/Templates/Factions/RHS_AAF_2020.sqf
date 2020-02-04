/*
custom Altis Armed Forces v 2020 template for ARMA III (AAF2017)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_AAF_2020"];
_array set [T_DESCRIPTION, "Various units from AAF 2017 and RHS addons with special loadouts for this mission. 2020 variant."];
_array set [T_DISPLAY_NAME, "RHS AAF 2020 (Custom)"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
								"FGN_AAF_Troops",	// AAF 2017
								"rhs_c_troops",		// RHS AFRF
								"rhsusf_c_troops",
								"rhssaf_c_troops",
								"rhsgref_c_troops"]];


//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT, ["FGN_AAF_Inf_Rifleman"]];

_inf set [T_INF_SL, ["RHS_AAF_2020_SL"]];
_inf set [T_INF_TL, ["RHS_AAF_2020_TL"]];
_inf set [T_INF_officer, ["RHS_AAF_2020_officer"]];
_inf set [T_INF_GL, ["RHS_AAF_2020_grenadier"]];
_inf set [T_INF_rifleman, ["RHS_AAF_2020_rifleman"]];
_inf set [T_INF_marksman, ["RHS_AAF_2020_marksman", "RHS_AAF_2020_marksman_2"]];
_inf set [T_INF_sniper, ["RHS_AAF_2020_sniper", "RHS_AAF_2020_sniper_2", "RHS_AAF_2020_sniper_3"]];
_inf set [T_INF_spotter, ["RHS_AAF_2020_spotter", "RHS_AAF_2020_spotter_2"]];
_inf set [T_INF_exp, ["RHS_AAF_2020_explosives"]];
_inf set [T_INF_ammo, ["RHS_AAF_2020_MG_2", "RHS_AAF_2020_AT_2"]];
_inf set [T_INF_LAT, ["RHS_AAF_2020_LAT"]];
_inf set [T_INF_AT, ["RHS_AAF_2020_AT"]];
_inf set [T_INF_AA, ["RHS_AAF_2020_AA"]];
_inf set [T_INF_LMG, ["RHS_AAF_2020_LMG", "RHS_AAF_2020_LMG_2", "RHS_AAF_2020_LMG_3"]];
_inf set [T_INF_HMG, ["RHS_AAF_2020_MG", "RHS_AAF_2020_MG_3"]];
_inf set [T_INF_medic, ["RHS_AAF_2020_medic"]];
_inf set [T_INF_engineer, ["RHS_AAF_2020_engineer"]];
_inf set [T_INF_crew, ["RHS_AAF_2020_crew"]];
_inf set [T_INF_crew_heli, ["RHS_AAF_2020_helicrew"]];
_inf set [T_INF_pilot, ["RHS_AAF_2020_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_AAF_2020_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_AAF_2020_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_AAF_2020_recon_LMG"]];
_inf set [T_INF_recon_medic, ["RHS_AAF_2020_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_AAF_2020_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_AAF_2020_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_AAF_2020_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_AAF_2020_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, [""]];
//_inf set [T_INF_diver_rifleman, [""]];
//_inf set [T_INF_diver_exp, [""]];


//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["FGN_AAF_M1025_unarmed"]];

_veh set [T_VEH_car_unarmed, ["FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop", "FGN_AAF_M998_2D_Halftop"]];
_veh set [T_VEH_car_armed, ["FGN_AAF_M1025_M2", "FGN_AAF_M1025_MK19"]];

//cars are in MRAPS until cars are added properly
_veh set [T_VEH_MRAP_unarmed, ["FGN_AAF_Tigr_M", "FGN_AAF_Tigr", "FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop", "FGN_AAF_M998_2D_Halftop"]];
_veh set [T_VEH_MRAP_HMG, ["FGN_AAF_Tigr_STS", "FGN_AAF_M1025_M2"]];
_veh set [T_VEH_MRAP_GMG, ["FGN_AAF_M1025_MK19"]];

_veh set [T_VEH_IFV, ["FGN_AAF_BMP3M_ERA"]]; //"rhs_bmp1p_vdv"
_veh set [T_VEH_APC, ["rhsusf_m113d_usarmy_supply", "rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_MK19", "rhsusf_m113d_usarmy_unarmed", "rhsusf_m113d_usarmy_M240"]];
_veh set [T_VEH_MBT, ["rhs_t90sm_tv", "rhs_t90am_tv", "rhssaf_army_t72s"]]; //"rhs_t72ba_tv","rhs_t72bb_tv"
_veh set [T_VEH_MRLS, ["FGN_AAF_BM21"]];
_veh set [T_VEH_SPA, ["rhs_2s1_tv", "rhs_2s3_tv"]];
_veh set [T_VEH_SPAA, ["FGN_AAF_Ural_ZU23", "rhs_zsu234_aa"]]; 

_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_D"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_D"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_D", "rhsgref_ins_g_SPG9M"]]; // "rhsgref_ins_g_SPG9"
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_vmf"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_D"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_D"]];

_veh set [T_VEH_heli_light, ["FGN_AAF_KA60_unarmed", "RHS_MELB_H6M", "RHS_MELB_MH6M"]]; //"rhs_uh1h_hidf"
_veh set [T_VEH_heli_heavy, ["FGN_AAF_KA60_dynamicLoadout", "RHS_MELB_AH6M"]]; //"rhs_uh1h_hidf_gunship"
_veh set [T_VEH_heli_cargo, ["FGN_AAF_KA60_unarmed"]]; //"rhs_uh1h_hidf_unarmed"
_veh set [T_VEH_heli_attack, ["rhsgref_mi24g_CAS"]];

_veh set [T_VEH_plane_attack, ["FGN_AAF_L159_dynamicLoadout"]];
_veh set [T_VEH_plane_fighter, ["FGN_AAF_L159_dynamicLoadout"]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["FGN_AAF_Zamak_Open", "FGN_AAF_Zamak"]]; //"FGN_AAF_Ural", "FGN_AAF_Ural_open"
//_veh set [T_VEH_truck_cargo, [""]];
_veh set [T_VEH_truck_ammo, ["FGN_AAF_Zamak_Ammo"]];
_veh set [T_VEH_truck_repair, ["FGN_AAF_Zamak_Repair"]]; //"FGN_AAF_Ural_Repair"
_veh set [T_VEH_truck_medical , ["FGN_AAF_Zamak_Medic", "rhsusf_m113d_usarmy_medical"]];
_veh set [T_VEH_truck_fuel, ["FGN_AAF_Zamak_Fuel"]]; //"FGN_AAF_Ural_Fuel"

//_veh set [T_VEH_submarine, [""]];


//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["rhs_pchela1t_vvsc"]];

//_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]];
//_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]];
//_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];
//_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]];
//_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]];
//_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array // End template

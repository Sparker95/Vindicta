/*
custom Altis Armed Forces v 2010 template for ARMA III (AAF2017)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_AAF_2010"];
_array set [T_DESCRIPTION, "Altis Armed Forces units for Altis. 2010 variant. Uses RHS and AAF2017."];
_array set [T_DISPLAY_NAME, "RHS Altis Armed Forces (2010)"];
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
_inf set [T_INF_default, ["FGN_AAF_InfRes_Rifleman"]];

_inf set [T_INF_SL, ["RHS_AAF_2010_SL","RHS_AAF_2010_SL_2"]];
_inf set [T_INF_TL, ["RHS_AAF_2010_TL"]];
_inf set [T_INF_officer, ["RHS_AAF_2010_officer"]];
_inf set [T_INF_GL, ["RHS_AAF_2010_grenadier"]];
_inf set [T_INF_rifleman, ["RHS_AAF_2010_rifleman"]];
_inf set [T_INF_marksman, ["RHS_AAF_2010_marksman"]];
_inf set [T_INF_sniper, ["RHS_AAF_2010_sniper","RHS_AAF_2010_sniper_2"]];
_inf set [T_INF_spotter, ["RHS_AAF_2010_spotter"]];
_inf set [T_INF_exp, ["RHS_AAF_2010_explosives"]];
_inf set [T_INF_ammo, ["RHS_AAF_2010_AT_2","RHS_AAF_2010_MG_2"]];
_inf set [T_INF_LAT, ["RHS_AAF_2010_LAT", "RHS_AAF_2010_AT_3"]];
_inf set [T_INF_AT, ["RHS_AAF_2010_AT","RHS_AAF_2010_AT_3"]];
_inf set [T_INF_AA, ["RHS_AAF_2010_AA"]];
_inf set [T_INF_LMG, ["RHS_AAF_2010_LMG", "RHS_AAF_2010_LMG_2"]];
_inf set [T_INF_HMG, ["RHS_AAF_2010_MG"]];
_inf set [T_INF_medic, ["RHS_AAF_2010_medic"]];
_inf set [T_INF_engineer, ["RHS_AAF_2010_engineer"]];
_inf set [T_INF_crew, ["RHS_AAF_2010_crew"]];
_inf set [T_INF_crew_heli, ["RHS_AAF_2010_helicrew"]];
_inf set [T_INF_pilot, ["RHS_AAF_2010_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_AAF_2010_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_AAF_2010_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_AAF_2010_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_AAF_2010_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_AAF_2010_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_AAF_2010_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_AAF_2010_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_AAF_2010_recon_JTAC"]];

// Divers, still vanilla
//_inf set [T_INF_diver_TL, [""]];
//_inf set [T_INF_diver_rifleman, [""]];
//_inf set [T_INF_diver_exp, [""]];


//==== Vehicles ====
_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["FGN_AAF_M1025_unarmed"]];

_veh set [T_VEH_car_unarmed, ["FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop", "FGN_AAF_M998_2D_Halftop"]];
_veh set [T_VEH_car_armed, ["FGN_AAF_M1025_M2", "FGN_AAF_M1025_MK19"]];

//cars are in MRAPS until cars are added properly
_veh set [T_VEH_MRAP_unarmed, ["FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop", "FGN_AAF_M998_2D_Halftop"]];
_veh set [T_VEH_MRAP_HMG, ["FGN_AAF_M1025_M2"]];
_veh set [T_VEH_MRAP_GMG, ["FGN_AAF_M1025_MK19","rhsusf_M1117_D"]];

_veh set [T_VEH_IFV, ["rhs_bmp1p_vdv"]];
_veh set [T_VEH_APC, ["rhsusf_m113d_usarmy_supply", "rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_MK19", "rhsusf_m113d_usarmy_unarmed", "rhsusf_m113d_usarmy_M240"]];
_veh set [T_VEH_MBT, ["rhs_t72ba_tv", "rhs_t72bb_tv"]];
_veh set [T_VEH_MRLS, ["FGN_AAF_BM21"]];
_veh set [T_VEH_SPA, ["rhs_2s1_tv"]];
_veh set [T_VEH_SPAA, ["FGN_AAF_Ural_ZU23", "rhs_zsu234_aa"]];

_veh set [T_VEH_stat_HMG_high, ["I_HMG_02_high_F"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["I_HMG_02_F"]];
_veh set [T_VEH_stat_GMG_low, ["rhsgref_ins_g_SPG9"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_vmf"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_D"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_D"]];

_veh set [T_VEH_heli_light, ["rhs_uh1h_hidf", "RHS_MELB_H6M", "RHS_MELB_MH6M"]];
_veh set [T_VEH_heli_heavy, ["rhs_uh1h_hidf_gunship", "RHS_MELB_AH6M"]];
_veh set [T_VEH_heli_cargo, ["rhs_uh1h_hidf_unarmed"]];
_veh set [T_VEH_heli_attack, ["RHS_Mi24V_vvs", "RHS_Mi24P_vvs"]];

_veh set [T_VEH_plane_attack, ["FGN_AAF_L159_dynamicLoadout"]];
_veh set [T_VEH_plane_fighter, ["FGN_AAF_L159_dynamicLoadout"]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["FGN_AAF_Ural", "FGN_AAF_Ural_open"]];
_veh set [T_VEH_truck_cargo, ["RHS_Ural_Flat_MSV_01", "RHS_Ural_Open_Flat_MSV_01"]];
_veh set [T_VEH_truck_ammo, ["FGN_AAF_Zamak_Ammo"]];
_veh set [T_VEH_truck_repair, ["FGN_AAF_Ural_Repair"]];
_veh set [T_VEH_truck_medical , ["FGN_AAF_Zamak_Medic", "rhsusf_m113d_usarmy_medical"]];
_veh set [T_VEH_truck_fuel, ["FGN_AAF_Ural_Fuel"]];

//_veh set [T_VEH_submarine, [""]];


//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
//_drone set [T_DRONE_SIZE-1, nil];
//_drone set [T_DRONE_DEFAULT, ["I_UGV_01_F"]];
//_drone set [T_DRONE_UGV_unarmed, ["I_UGV_01_F"]];
//_drone set [T_DRONE_UGV_armed, ["I_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_quadcopter, ["I_UAV_01_F"]];
//_drone set [T_DRONE_designator, [""]];
//_drone set [T_DRONE_stat_HMG_low, ["I_HMG_01_A_F"]];
//_drone set [T_DRONE_stat_GMG_low, ["I_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, [""]];

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

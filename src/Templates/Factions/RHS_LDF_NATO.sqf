/*
custom Livonian Defence Forces templates for ARMA III - A Nation in a state of Equipment Flux(RHS)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_LDF_NATO"];
_array set [T_DESCRIPTION, "NATO aligned LDF. Uses RHS. Made by Straker27"];
_array set [T_DISPLAY_NAME, "RHS LDF NATO"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
								"rhs_c_troops",		// RHS AFRF
								"rhsusf_c_troops",	// RHS USAF
								"rhssaf_c_troops",	// RHS SAF
								"rhsgref_c_troops"	// RHS GREF
								]];

//==== Infantry ====
_inf = []; _inf resize T_INF_SIZE;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_default, ["I_E_Soldier_F"]];

_inf set [T_INF_SL, ["RHS_LDF_NATO_SL"]];
_inf set [T_INF_TL, ["RHS_LDF_NATO_TL", "RHS_LDF_NATO_TL_2"]];
_inf set [T_INF_officer, ["RHS_LDF_NATO_officer"]];
_inf set [T_INF_GL, ["RHS_LDF_NATO_grenadier", "RHS_LDF_NATO_grenadier_2"]];
_inf set [T_INF_rifleman, ["RHS_LDF_NATO_rifleman"]];
_inf set [T_INF_marksman, ["RHS_LDF_NATO_marksman"]];
_inf set [T_INF_sniper, ["RHS_LDF_NATO_sniper", "RHS_LDF_NATO_sniper_2"]];
_inf set [T_INF_spotter, ["RHS_LDF_NATO_spotter", "RHS_LDF_NATO_spotter_2"]];
_inf set [T_INF_exp, ["RHS_LDF_NATO_explosives"]];
_inf set [T_INF_ammo, ["RHS_LDF_NATO_MG_2", "RHS_LDF_NATO_AT_2"]];
_inf set [T_INF_LAT, ["RHS_LDF_NATO_LAT"]];
_inf set [T_INF_AT, ["RHS_LDF_NATO_AT"]];
_inf set [T_INF_AA, ["RHS_LDF_NATO_AA"]];
_inf set [T_INF_LMG, ["RHS_LDF_NATO_LMG"]];
_inf set [T_INF_HMG, ["RHS_LDF_NATO_MG"]];
_inf set [T_INF_medic, ["RHS_LDF_NATO_medic"]];
_inf set [T_INF_engineer, ["RHS_LDF_NATO_engineer"]];
_inf set [T_INF_crew, ["RHS_LDF_NATO_crew"]];
_inf set [T_INF_crew_heli, ["RHS_LDF_NATO_helicrew"]];
_inf set [T_INF_pilot, ["RHS_LDF_NATO_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_LDF_NATO_helipilot"]];
//_inf set [T_INF_survivor, ["RHS_LDF_rifleman"]];
//_inf set [T_INF_unarmed, ["RHS_LDF_rifleman"]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_LDF_NATO_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_LDF_NATO_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_LDF_NATO_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_LDF_NATO_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_LDF_NATO_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_LDF_NATO_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_LDF_NATO_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsgref_cdf_reg_uaz"]];

_veh set [T_VEH_car_unarmed, ["rhsgref_cdf_reg_uaz", "rhsgref_cdf_reg_uaz_open", "rhsgref_hidf_m1025"]];
_veh set [T_VEH_car_armed, ["rhsgref_hidf_m1025_m2", "rhsgref_hidf_m1025_mk19", "rhsgref_cdf_reg_uaz_dshkm", "rhsgref_cdf_reg_uaz_spg9"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsgref_BRDM2UM"]];
_veh set [T_VEH_MRAP_HMG, ["rhsgref_BRDM2_HQ"]];
_veh set [T_VEH_MRAP_GMG, ["rhsgref_BRDM2"]];

_veh set [T_VEH_IFV, ["rhsgref_cdf_bmd1p", "rhsgref_cdf_bmd1pk", "rhsgref_cdf_bmd2", "rhsgref_cdf_bmd2k", "rhsgref_cdf_bmp1p"]];
_veh set [T_VEH_APC, ["rhsgref_cdf_btr60", "rhsgref_hidf_m113a3_m2"]];
_veh set [T_VEH_MBT, ["rhsgref_cdf_b_t72ba_tv", "rhsgref_cdf_b_t72bb_tv"]];
_veh set [T_VEH_MRLS, ["rhsgref_cdf_reg_BM21"]];
_veh set [T_VEH_SPA, ["rhsgref_cdf_2s1"]];
_veh set [T_VEH_SPAA, ["rhsgref_cdf_zsu234", "rhsgref_cdf_gaz66_zu23"]];

_veh set [T_VEH_stat_HMG_high, ["rhsgref_hidf_m2_static"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["RHS_NSV_TriPod_MSV", "rhsgref_hidf_m2_static_minitripod"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_AGS30_TriPod_MSV"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_msv", "RHS_ZU23_MSV"]];
_veh set [T_VEH_stat_AT, ["rhs_Kornet_9M133_2_msv", "rhs_Metis_9k115_2_msv", "rhsgref_cdf_SPG9M", "rhsgref_cdf_SPG9"]];

_veh set [T_VEH_stat_mortar_light, ["rhs_2b14_82mm_msv"]];
_veh set [T_VEH_stat_mortar_heavy, ["rhs_D30_msv"]];

_veh set [T_VEH_heli_light, ["rhs_uh1h_hidf"]];
_veh set [T_VEH_heli_heavy, ["rhssaf_airforce_ht40"]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["rhsgref_cdf_Mi24D_early", "rhs_uh1h_hidf_gunship"]];

_veh set [T_VEH_plane_attack, ["RHSGREF_A29B_HIDF", "rhs_l39_cdf"]];
_veh set [T_VEH_plane_fighter, ["rhs_l159_CDF"]];
//_veh set [T_VEH_plane_cargo, [""]];
_veh set [T_VEH_plane_unarmed, ["RHS_AN2"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["rhsgref_cdf_zil131", "rhsgref_cdf_zil131_open", "rhsgref_cdf_gaz66", "rhsgref_cdf_gaz66o"]];
_veh set [T_VEH_truck_cargo, ["rhsgref_cdf_zil131_flatbed", "rhsgref_cdf_zil131_flatbed_cover", "rhsgref_cdf_gaz66_flat", "rhsgref_cdf_gaz66o_flat"]];
_veh set [T_VEH_truck_ammo, ["rhsgref_cdf_gaz66_ammo"]];
_veh set [T_VEH_truck_repair, ["rhsgref_cdf_gaz66_repair"]];
_veh set [T_VEH_truck_medical , ["rhsgref_cdf_gaz66_repair"]];
_veh set [T_VEH_truck_fuel, ["rhsgref_cdf_ural_fuel"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
//_drone set [T_DRONE_SIZE-1, nil];
//_drone set [T_DRONE_DEFAULT, ["rhs_pchela1t_vvsc"]];
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

_array; // End template

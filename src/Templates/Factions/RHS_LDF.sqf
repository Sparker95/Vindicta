/*
custom Livonian Defence Forces templates for ARMA III (RHS)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_LDF"];
_array set [T_DESCRIPTION, "Livonian Defense Forces for Livonia. Uses OPFOR equipment from RHS."];
_array set [T_DISPLAY_NAME, "RHS Livonian Defense Forces (redfor)"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
								"rhs_c_troops",		// RHS AFRF
								"rhsusf_c_troops",
								"rhssaf_c_troops",
								"rhsgref_c_troops"]];

//==== Infantry ====
_inf = []; _inf resize T_INF_SIZE;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_default, ["I_E_Soldier_F"]];

_inf set [T_INF_SL, ["RHS_LDF_SL", "RHS_LDF_SL_2"]];
_inf set [T_INF_TL, ["RHS_LDF_TL", "RHS_LDF_TL_2"]];
_inf set [T_INF_officer, ["RHS_LDF_officer"]];
_inf set [T_INF_GL, ["RHS_LDF_grenadier", "RHS_LDF_grenadier_2"]];
_inf set [T_INF_rifleman, ["RHS_LDF_rifleman"]];
_inf set [T_INF_marksman, ["RHS_LDF_marksman"]];
_inf set [T_INF_sniper, ["RHS_LDF_sniper", "RHS_LDF_sniper_2"]];
_inf set [T_INF_spotter, ["RHS_LDF_spotter", "RHS_LDF_spotter_2"]];
_inf set [T_INF_exp, ["RHS_LDF_explosives"]];
_inf set [T_INF_ammo, ["RHS_LDF_MG_2", "RHS_LDF_AT_2"]];
_inf set [T_INF_LAT, ["RHS_LDF_LAT"]];
_inf set [T_INF_AT, ["RHS_LDF_AT"]];
_inf set [T_INF_AA, ["RHS_LDF_AA"]];
_inf set [T_INF_LMG, ["RHS_LDF_LMG"]];
_inf set [T_INF_HMG, ["RHS_LDF_MG"]];
_inf set [T_INF_medic, ["RHS_LDF_medic"]];
_inf set [T_INF_engineer, ["RHS_LDF_engineer"]];
_inf set [T_INF_crew, ["RHS_LDF_crew"]];
_inf set [T_INF_crew_heli, ["RHS_LDF_helicrew"]];
_inf set [T_INF_pilot, ["RHS_LDF_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_LDF_helipilot"]];
//_inf set [T_INF_survivor, ["RHS_LDF_rifleman"]];
//_inf set [T_INF_unarmed, ["RHS_LDF_rifleman"]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_LDF_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_LDF_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_LDF_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_LDF_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_LDF_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_LDF_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_LDF_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsgref_cdf_reg_uaz"]];

_veh set [T_VEH_car_unarmed, ["rhsgref_cdf_reg_uaz", "rhsgref_cdf_reg_uaz_open"]];
_veh set [T_VEH_car_armed, ["rhsgref_cdf_reg_uaz_ags", "rhsgref_cdf_reg_uaz_dshkm", "rhsgref_cdf_reg_uaz_spg9"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsgref_BRDM2UM"]];
_veh set [T_VEH_MRAP_HMG, ["rhsgref_BRDM2_HQ"]];
_veh set [T_VEH_MRAP_GMG, ["rhsgref_BRDM2"]];

_veh set [T_VEH_IFV, ["rhsgref_cdf_bmd1p", "rhsgref_cdf_bmd1pk", "rhs_bmd1r", "rhsgref_cdf_bmd2", "rhsgref_cdf_bmd2k", "rhsgref_cdf_bmp1p", "rhsgref_cdf_bmp2e", "rhsgref_cdf_bmp2k"]];
_veh set [T_VEH_APC, ["rhsgref_cdf_btr60", "rhsgref_cdf_btr70"]];
_veh set [T_VEH_MBT, ["rhsgref_cdf_t80b_tv", "rhsgref_cdf_t80bv_tv", "rhs_t80bvk"]];
_veh set [T_VEH_MRLS, ["rhsgref_cdf_reg_BM21"]];
_veh set [T_VEH_SPA, ["rhsgref_cdf_2s1"]];
_veh set [T_VEH_SPAA, ["rhsgref_cdf_zsu234", "rhsgref_cdf_gaz66_zu23"]];

_veh set [T_VEH_stat_HMG_high, ["rhsgref_nat_DSHKM"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["RHS_NSV_TriPod_MSV", "rhsgref_nat_DSHKM_Mini_TriPod"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_AGS30_TriPod_MSV"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_msv", "RHS_ZU23_MSV"]];
_veh set [T_VEH_stat_AT, ["rhs_Kornet_9M133_2_msv", "rhs_Metis_9k115_2_msv", "rhsgref_cdf_SPG9M", "rhsgref_cdf_SPG9"]];

_veh set [T_VEH_stat_mortar_light, ["rhs_2b14_82mm_msv"]];
_veh set [T_VEH_stat_mortar_heavy, ["rhs_D30_msv"]];

_veh set [T_VEH_heli_light, ["rhsgref_cdf_reg_Mi8amt"]];
_veh set [T_VEH_heli_heavy, ["rhsgref_cdf_reg_Mi17Sh"]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["rhsgref_cdf_Mi24D", "rhsgref_cdf_Mi24D_early"]];

_veh set [T_VEH_plane_attack, ["rhsgref_cdf_su25"]];
_veh set [T_VEH_plane_fighter, ["rhsgref_cdf_mig29s"]];
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

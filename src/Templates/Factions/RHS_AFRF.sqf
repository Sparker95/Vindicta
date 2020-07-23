/*
RHS AFRF: Russia (MSV) templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_AFRF"];
_array set [T_DESCRIPTION, "Armed Forces of the Russian Federation. Uses RHS."];
_array set [T_DISPLAY_NAME, "RHS Russian Armed Forces"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops" //RHSGREF due to BRDMs, UAZ with DSHKMs not existing in base AFRF
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["rhs_msv_emr_rifleman"]];

_inf set [T_INF_SL, ["RHS_AFRF_SL","RHS_AFRF_SL_2"]];
_inf set [T_INF_TL, ["RHS_AFRF_TL", "RHS_AFRF_TL_2"]];
_inf set [T_INF_officer, ["RHS_AFRF_officer"]];
_inf set [T_INF_GL, ["RHS_AFRF_grenadier"]];
_inf set [T_INF_rifleman, ["RHS_AFRF_rifleman"]];
_inf set [T_INF_marksman, ["RHS_AFRF_marksman"]];
_inf set [T_INF_sniper, ["RHS_AFRF_sniper"]];
_inf set [T_INF_spotter, ["RHS_AFRF_spotter", "RHS_AFRF_spotter_2"]];
_inf set [T_INF_exp, ["RHS_AFRF_explosives"]];
_inf set [T_INF_ammo, ["RHS_AFRF_AT_2", "RHS_AFRF_MG_2"]];
_inf set [T_INF_LAT, ["RHS_AFRF_LAT", "RHS_AFRF_LAT_2"]];
_inf set [T_INF_AT, ["RHS_AFRF_AT"]];
_inf set [T_INF_AA, ["RHS_AFRF_AA"]];
_inf set [T_INF_LMG, ["RHS_AFRF_LMG"]];
_inf set [T_INF_HMG, ["RHS_AFRF_MG"]];
_inf set [T_INF_medic, ["RHS_AFRF_medic"]];
_inf set [T_INF_engineer, ["RHS_AFRF_engineer"]];
_inf set [T_INF_crew, ["RHS_AFRF_crew"]]; 
_inf set [T_INF_crew_heli, ["RHS_AFRF_helicrew"]];
_inf set [T_INF_pilot, ["RHS_AFRF_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_AFRF_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_AFRF_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_AFRF_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_AFRF_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_AFRF_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_AFRF_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_AFRF_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_AFRF_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhs_uaz_MSV_01"]];

_veh set [T_VEH_car_unarmed, ["rhs_uaz_open_MSV_01", "RHS_UAZ_MSV_01"]];
_veh set [T_VEH_car_armed, ["rhsgref_nat_uaz_spg9", "rhsgref_nat_uaz_dshkm", "rhsgref_nat_uaz_ags"]];

_veh set [T_VEH_MRAP_unarmed, ["rhs_tigr_msv", "rhs_tigr_m_msv", "rhsgref_BRDM2UM_msv"]];
_veh set [T_VEH_MRAP_HMG, ["rhsgref_BRDM2_msv", "rhsgref_BRDM2_HQ_msv"]];
_veh set [T_VEH_MRAP_GMG, ["rhs_tigr_sts_msv"]];

_veh set [T_VEH_IFV, ["rhs_bmp2_tv", "rhs_bmp2k_tv", "rhs_bmp3_msv", "rhs_bmp3_late_msv"]];
_veh set [T_VEH_APC, ["rhs_btr80_msv", "rhs_btr80a_msv"]];
_veh set [T_VEH_MBT, ["rhs_t72be_tv", "rhs_t72bd_tv", "rhs_t72bc_tv", "rhs_t90_tv", "rhs_t90a_tv", "rhs_t80um", "rhs_t80uk", "rhs_t80u"]];
_veh set [T_VEH_MRLS, ["RHS_BM21_MSV_01"]];
_veh set [T_VEH_SPA, ["rhs_2s3_tv", "rhs_2s1_tv"]];
_veh set [T_VEH_SPAA, ["rhs_zsu234_aa", "RHS_Ural_Zu23_MSV_01"]];

_veh set [T_VEH_stat_HMG_high, ["rhs_KORD_high_MSV", "rhsgref_nat_DSHKM"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["rhs_KORD_MSV", "RHS_NSV_TriPod_MSV", "rhsgref_nat_DSHKM_Mini_TriPod"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_AGS30_TriPod_MSV"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_msv", "RHS_ZU23_MSV"]];
_veh set [T_VEH_stat_AT, ["rhs_Kornet_9M133_2_msv", "rhs_Metis_9k115_2_msv", "rhs_SPG9M_MSV"]];

_veh set [T_VEH_stat_mortar_light, ["rhs_2b14_82mm_msv"]];
_veh set [T_VEH_stat_mortar_heavy, ["rhs_D30_msv"]];

_veh set [T_VEH_heli_light, ["rhs_ka60_c"]];
_veh set [T_VEH_heli_heavy, ["RHS_Mi8AMTSh_vvsc","RHS_Mi8MTV3_vvsc","RHS_Mi8MTV3_heavy_vvsc","RHS_Mi8mt_vvsc"]];
_veh set [T_VEH_heli_cargo, ["RHS_Mi8mtv3_Cargo_vvsc", "RHS_Mi8mt_Cargo_vvsc"]];
_veh set [T_VEH_heli_attack, ["RHS_Ka52_vvsc", "rhs_mi28n_vvsc","RHS_Mi24V_vvsc","RHS_Mi24P_vvsc"]];

_veh set [T_VEH_plane_attack, ["RHS_Su25SM_vvsc"]];
_veh set [T_VEH_plane_fighter, ["rhs_mig29s_vvsc","rhs_mig29sm_vvsc"]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["O_G_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["RHS_Ural_MSV_01", "RHS_Ural_Open_MSV_01", "rhs_kamaz5350_msv", "rhs_kamaz5350_open_msv"]];
_veh set [T_VEH_truck_cargo, ["RHS_Ural_Flat_MSV_01", "RHS_Ural_Open_Flat_MSV_01", "rhs_kamaz5350_flatbed_msv", "rhs_kamaz5350_flatbed_cover_msv"]];
_veh set [T_VEH_truck_ammo, ["rhs_gaz66_ammo_msv"]];
_veh set [T_VEH_truck_repair, ["RHS_Ural_Repair_MSV_01"]];
_veh set [T_VEH_truck_medical , ["rhs_gaz66_ap2_msv"]];
_veh set [T_VEH_truck_fuel, ["RHS_Ural_Fuel_MSV_01"]];

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

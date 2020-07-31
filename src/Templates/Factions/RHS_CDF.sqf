_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_CDF"];
_array set [T_DESCRIPTION, "Chernarus Defense Forces. Uses RHSGREF"];
_array set [T_DISPLAY_NAME, "RHS CDF"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops"	// RHSGREF
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["rhsgref_cdf_b_reg_rifleman"]];

_inf set [T_INF_SL, ["rhsgref_cdf_b_reg_squadleader"]];
_inf set [T_INF_TL, ["rhsgref_cdf_b_reg_rifleman"]];
_inf set [T_INF_officer, ["rhsgref_cdf_b_reg_officer", "rhsgref_cdf_b_reg_general"]];
_inf set [T_INF_GL, ["rhsgref_cdf_b_reg_grenadier"]];
_inf set [T_INF_rifleman, ["rhsgref_cdf_b_reg_rifleman", "rhsgref_cdf_b_reg_rifleman_akm", "rhsgref_cdf_b_reg_rifleman_aks74", "rhsgref_cdf_b_reg_rifleman_lite"]];
_inf set [T_INF_marksman, ["rhsgref_cdf_b_reg_marksman"]];
_inf set [T_INF_sniper, ["rhsgref_cdf_b_reg_marksman"]];
_inf set [T_INF_spotter, ["rhsgref_cdf_b_reg_marksman"]];
_inf set [T_INF_exp, ["rhsgref_cdf_b_reg_engineer"]];
_inf set [T_INF_ammo, ["rhsgref_cdf_b_reg_rifleman"]];
_inf set [T_INF_LAT, ["rhsgref_cdf_b_reg_rifleman_rpg75"]];
_inf set [T_INF_AT, ["rhsgref_cdf_b_reg_grenadier_rpg"]];
_inf set [T_INF_AA, ["rhsgref_cdf_b_reg_specialist_aa"]];
_inf set [T_INF_LMG, ["rhsgref_cdf_b_reg_machinegunner"]];
_inf set [T_INF_HMG, ["rhsgref_cdf_b_reg_machinegunner"]];
_inf set [T_INF_medic, ["rhsgref_cdf_b_reg_medic"]];
_inf set [T_INF_engineer, ["rhsgref_cdf_b_reg_engineer"]];
_inf set [T_INF_crew, ["rhsgref_cdf_b_reg_crew", "rhsgref_cdf_b_reg_crew_commander"]];
_inf set [T_INF_crew_heli, ["rhsgref_cdf_b_reg_crew"]];
_inf set [T_INF_pilot, ["rhsgref_cdf_b_air_pilot"]];
_inf set [T_INF_pilot_heli, ["rhsgref_cdf_b_air_pilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["rhsgref_cdf_b_para_squadleader"]];
_inf set [T_INF_recon_rifleman, ["rhsgref_cdf_b_para_rifleman", "rhsgref_cdf_b_para_rifleman_lite"]];
_inf set [T_INF_recon_medic, ["rhsgref_cdf_b_para_medic"]];
_inf set [T_INF_recon_exp, ["rhsgref_cdf_b_para_engineer"]];
_inf set [T_INF_recon_LAT, ["rhsgref_cdf_b_para_grenadier_rpg"]];
_inf set [T_INF_recon_marksman, ["rhsgref_cdf_b_para_marksman"]];
_inf set [T_INF_recon_JTAC, ["rhsgref_cdf_b_para_rifleman"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsgref_cdf_b_reg_uaz"]];

_veh set [T_VEH_car_unarmed, ["rhsgref_cdf_b_reg_uaz", "rhsgref_cdf_b_reg_uaz_open"]];
_veh set [T_VEH_car_armed, ["rhsgref_cdf_b_reg_uaz_ags", "rhsgref_cdf_b_reg_uaz_dshkm", "rhsgref_cdf_b_reg_uaz_spg9"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsgref_BRDM2UM_b"]];
_veh set [T_VEH_MRAP_HMG, ["rhsgref_BRDM2_b", "rhsgref_BRDM2_HQ_b"]];
_veh set [T_VEH_MRAP_GMG, ["rhsgref_BRDM2_b", "rhsgref_BRDM2_HQ_b"]];

_veh set [T_VEH_IFV, ["rhsgref_cdf_b_bmd1p", "rhsgref_cdf_b_bmd2", "rhsgref_cdf_b_bmd1k", "rhsgref_cdf_b_bmd2k", "rhsgref_cdf_b_bmd1", "rhsgref_cdf_b_bmp1", "rhsgref_cdf_b_bmp1d", "rhsgref_cdf_b_bmp1k", "rhsgref_cdf_b_bmp1p", "rhsgref_cdf_b_bmp2e", "rhsgref_cdf_b_bmp2", "rhsgref_cdf_b_bmp2d", "rhsgref_cdf_b_bmp2k"]];
_veh set [T_VEH_APC, ["rhsgref_cdf_b_btr60", "rhsgref_cdf_b_btr70"]];
_veh set [T_VEH_MBT, ["rhsgref_cdf_b_t72ba_tv", "rhsgref_cdf_b_t72bb_tv", "rhsgref_cdf_b_t80b_tv", "rhsgref_cdf_b_t80bv_tv"]];
_veh set [T_VEH_MRLS, ["rhsgref_cdf_b_reg_BM21"]];
_veh set [T_VEH_SPA, ["rhsgref_cdf_b_2s1"]];
_veh set [T_VEH_SPAA, ["rhsgref_cdf_b_zsu234"]];

_veh set [T_VEH_stat_HMG_high, ["rhsgref_cdf_b_DSHKM"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["rhsgref_cdf_b_DSHKM_Mini_TriPod"]];
_veh set [T_VEH_stat_GMG_low, ["rhsgref_cdf_b_AGS30_TriPod"]];
_veh set [T_VEH_stat_AA, ["rhsgref_cdf_b_Igla_AA_pod", "rhsgref_cdf_b_ZU23"]];
_veh set [T_VEH_stat_AT, ["rhsgref_cdf_b_SPG9", "rhsgref_cdf_b_SPG9M"]];

_veh set [T_VEH_stat_mortar_light, ["rhsgref_cdf_b_reg_M252"]];
_veh set [T_VEH_stat_mortar_heavy, ["rhsgref_cdf_b_reg_M252"]];

_veh set [T_VEH_heli_light, ["rhsgref_cdf_b_reg_Mi8amt"]];
_veh set [T_VEH_heli_heavy, ["rhsgref_cdf_b_reg_Mi8amt"]];
_veh set [T_VEH_heli_cargo, ["rhsgref_cdf_b_reg_Mi8amt"]];
_veh set [T_VEH_heli_attack, ["rhsgref_cdf_b_Mi24D_Early", "rhsgref_cdf_b_Mi24D","rhsgref_cdf_b_reg_Mi17Sh","rhsgref_b_mi24g_CAS"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

//_veh set [T_VEH_boat_unarmed, [""]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["O_G_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["rhsgref_cdf_b_gaz66", "rhsgref_cdf_b_gaz66o", "rhsgref_cdf_b_zil131", "rhsgref_cdf_b_zil131_open", "rhsgref_cdf_b_ural", "rhsgref_cdf_b_ural_open"]];
_veh set [T_VEH_truck_cargo, ["rhsgref_cdf_b_gaz66", "rhsgref_cdf_b_gaz66o", "rhsgref_cdf_b_zil131", "rhsgref_cdf_b_zil131_open", "rhsgref_cdf_b_ural", "rhsgref_cdf_b_ural_open"]];
_veh set [T_VEH_truck_ammo, ["rhsgref_cdf_b_gaz66_ammo"]];
_veh set [T_VEH_truck_repair, ["rhsgref_cdf_b_ural_repair"]];
_veh set [T_VEH_truck_medical , ["rhsgref_cdf_b_gaz66_ap2"]];
_veh set [T_VEH_truck_fuel, ["rhsgref_cdf_b_ural_fuel"]];

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

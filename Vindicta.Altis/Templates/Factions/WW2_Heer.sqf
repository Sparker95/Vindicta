/*
	name = "Heer";
		author = "MatrikSky";
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["LIB_GER_unequip", "LIB_GER_ober_rifleman", "LIB_GER_scout_ober_rifleman", "LNRD_Luftwaffe_ober_rifleman", "LIB_GER_soldier_camo_base", "LIB_GER_soldier_camo2_base", "LIB_GER_Soldier2", "LIB_GER_Soldier3", "LNRD_Luftwaffe_rifleman", "LIB_GER_soldier_camo4_base", "LIB_GER_soldier_camo3_base", "LIB_GER_rifleman", "LIB_GER_soldier_camo5_base", "LIB_GER_scout_rifleman", "LIB_GER_radioman", "LNRD_Luftwaffe_radioman", "LIB_GER_stggunner", "LNRD_Luftwaffe_stggunner"]];

_inf set [T_INF_SL, ["LIB_GER_unterofficer", "LIB_GER_gun_unterofficer", "LIB_GER_scout_unterofficer"]];
_inf set [T_INF_TL, ["LIB_GER_smgunner", "LIB_GER_scout_smgunner", "LNRD_Luftwaffe_smgunner"]];
_inf set [T_INF_officer, ["LIB_GER_oberst", "LIB_GER_hauptmann", "LIB_GER_ober_lieutenant", "LIB_GER_scout_lieutenant", "LIB_GER_lieutenant", "LIB_GER_gun_lieutenant"]];
_inf set [T_INF_GL, ["LIB_GER_ober_grenadier", "LIB_GER_scout_ober_grenadier"]];
_inf set [T_INF_rifleman, ["LIB_GER_unequip", "LIB_GER_ober_rifleman", "LIB_GER_scout_ober_rifleman", "LNRD_Luftwaffe_ober_rifleman", "LIB_GER_soldier_camo_base", "LIB_GER_soldier_camo2_base", "LIB_GER_Soldier2", "LIB_GER_Soldier3", "LNRD_Luftwaffe_rifleman", "LIB_GER_soldier_camo4_base", "LIB_GER_soldier_camo3_base", "LIB_GER_rifleman", "LIB_GER_soldier_camo5_base", "LIB_GER_scout_rifleman", "LIB_GER_radioman", "LNRD_Luftwaffe_radioman", "LIB_GER_stggunner", "LNRD_Luftwaffe_stggunner"]];
_inf set [T_INF_sniper, ["LIB_GER_scout_sniper", "LNRD_Luftwaffe_sniper"]];
_inf set [T_INF_marksman, ["LIB_GER_scout_sniper", "LNRD_Luftwaffe_sniper"]];
_inf set [T_INF_exp, ["LIB_GER_sapper_gefr", "LIB_GER_sapper"]];
_inf set [T_INF_LAT, ["LIB_GER_LAT_Rifleman", "LNRD_Luftwaffe_LAT_rifleman", "LIB_GER_AT_grenadier", "LNRD_Luftwaffe_AT_grenadier"]];
_inf set [T_INF_AT, ["LIB_GER_AT_soldier", "LNRD_Luftwaffe_AT_soldier"]];
_inf set [T_INF_LMG, ["LIB_GER_mgunner2", "LNRD_Luftwaffe_mgunner"]];
_inf set [T_INF_HMG, ["LIB_GER_mgunner", "LNRD_Luftwaffe_mgunner2"]];
_inf set [T_INF_medic, ["LIB_GER_medic", "LNRD_Luftwaffe_medic"]];
_inf set [T_INF_crew, ["LIB_GER_tank_lieutenant", "LIB_GER_tank_unterofficer", "LIB_GER_tank_crew"]];
_inf set [T_INF_pilot, ["LIB_GER_pilot"]];
/*
_inf set [T_INF_pilot_heli, [""]];
_inf set [T_INF_survivor, [""]];
_inf set [T_INF_unarmed, [""]];
_inf set [T_INF_crew_heli, [""]];
_inf set [T_INF_engineer, [""]];
_inf set [T_INF_AA, [""]];
_inf set [T_INF_ammo, [""]];
_inf set [T_INF_spotter, [""]];
*/
// Recon
_inf set [T_INF_recon_TL, ["LIB_FSJ_NCO", "LIB_FSJ_Soldier_2", "LIB_FSJ_Lieutenant"]];
_inf set [T_INF_recon_rifleman, ["LIB_FSJ_Soldier", "LIB_FSJ_AT_grenadier", "LIB_FSJ_Mgunner2", "LIB_FSJ_Mgunner"]];
_inf set [T_INF_recon_medic, ["LIB_FSJ_medic"]];
_inf set [T_INF_recon_exp, ["LIB_FSJ_sapper", "LIB_FSJ_sapper_gefr"]];
_inf set [T_INF_recon_LAT, ["LIB_FSJ_LAT_Soldier", "LIB_FSJ_AT_soldier"]];
_inf set [T_INF_recon_marksman, ["LIB_FSJ_Sniper"]];
_inf set [T_INF_recon_JTAC, ["LIB_FSJ_radioman"]];

// Divers, still vanilla
_inf set [T_INF_diver_TL, ["LIB_GER_unequip", "LIB_GER_ober_rifleman", "LIB_GER_scout_ober_rifleman", "LNRD_Luftwaffe_ober_rifleman", "LIB_GER_soldier_camo_base", "LIB_GER_soldier_camo2_base", "LIB_GER_Soldier2", "LIB_GER_Soldier3", "LNRD_Luftwaffe_rifleman", "LIB_GER_soldier_camo4_base", "LIB_GER_soldier_camo3_base", "LIB_GER_rifleman", "LIB_GER_soldier_camo5_base", "LIB_GER_scout_rifleman", "LIB_GER_radioman", "LNRD_Luftwaffe_radioman", "LIB_GER_stggunner", "LNRD_Luftwaffe_stggunner"]];
_inf set [T_INF_diver_rifleman, ["LIB_GER_unequip", "LIB_GER_ober_rifleman", "LIB_GER_scout_ober_rifleman", "LNRD_Luftwaffe_ober_rifleman", "LIB_GER_soldier_camo_base", "LIB_GER_soldier_camo2_base", "LIB_GER_Soldier2", "LIB_GER_Soldier3", "LNRD_Luftwaffe_rifleman", "LIB_GER_soldier_camo4_base", "LIB_GER_soldier_camo3_base", "LIB_GER_rifleman", "LIB_GER_soldier_camo5_base", "LIB_GER_scout_rifleman", "LIB_GER_radioman", "LNRD_Luftwaffe_radioman", "LIB_GER_stggunner", "LNRD_Luftwaffe_stggunner"]];
_inf set [T_INF_diver_exp, ["LIB_GER_sapper_gefr", "LIB_GER_sapper"]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["LIB_Kfz1_sernyt", "LIB_Kfz1_Hood_sernyt", "LIB_Kfz1", "LIB_Kfz1_camo", "LIB_Kfz1_Hood", "LIB_Kfz1_Hood_camo"]];

_veh set [T_VEH_car_unarmed, ["ifa3_gaz55_ger", "LIB_GER_GazM1", "LIB_Kfz1_sernyt", "LIB_Kfz1", "LIB_Kfz1_camo", "LIB_Kfz1_Hood_sernyt", "LIB_Kfz1_Hood", "LIB_Kfz1_Hood_camo"]];
_veh set [T_VEH_car_armed, ["R71Ger44Camo", "R71Ger44", "R71GerPre43", "LIB_ger_M3_Scout_IFL", "LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42", "LIB_Kfz1_MG42_camo"]];
/*
_veh set [T_VEH_MRAP_unarmed, ["LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42", "LIB_Kfz1_MG42_camo"]];
_veh set [T_VEH_MRAP_HMG, ["LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42", "LIB_Kfz1_MG42_camo"]];
_veh set [T_VEH_MRAP_GMG, ["LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42", "LIB_Kfz1_MG42_camo"]];
*/
_veh set [T_VEH_IFV, ["ifa3_Ba10_wm", "LIB_GER_M8_Greyhound", "LIB_SdKfz222", "LIB_SdKfz222_camo", "LIB_SdKfz222_gelbbraun", "LIB_SdKfz234_1", "LIB_SdKfz234_2", "LIB_SdKfz234_3", "LIB_SdKfz234_4"]];
_veh set [T_VEH_APC, ["LIB_GER_M3_Halftrack", "LIB_SdKfz_7", "LIB_SdKfz251", "LIB_SdKfz251_FFV"]];
_veh set [T_VEH_MBT, ["pz2f", "ifa3_pz3J_sov", "ifa3_pz3j", "ifa3_pz3N", "ifa3_t34_76_ger", "ifa3_StuH_42", "LIB_ger_M4A3_Sherman", "LIB_StuG_III_G", "LIB_PzKpfwIV_H", "LIB_PzKpfwIV_H_tarn51c", "LIB_PzKpfwIV_H_tarn51d", "LIB_PzKpfwV", "LIB_PzKpfwVI_B", "LIB_PzKpfwVI_B_tarn51c", "LIB_PzKpfwVI_B_tarn51d", "LIB_PzKpfwVI_E", "LIB_PzKpfwVI_E_2", "LIB_PzKpfwVI_E_tarn51c", "LIB_PzKpfwVI_E_tarn51d", "LIB_PzKpfwVI_E_tarn52c", "LIB_PzKpfwVI_E_tarn52d", "LIB_PzKpfwVI_E_1"]];
_veh set [T_VEH_MRLS, ["LIB_Nebelwerfer41", "LIB_Nebelwerfer41_Camo", "LIB_Nebelwerfer41_Gelbbraun"]];
_veh set [T_VEH_SPA, ["LIB_SdKfz124"]];
_veh set [T_VEH_SPAA, ["LIB_FlakPanzerIV_Wirbelwind", "LIB_SdKfz_7_AA"]];

//_veh set [T_VEH_stat_HMG_high, [""]];
//_veh set [T_VEH_stat_GMG_high, ["LIB_MG34_Lafette_Deployed", "LIB_MG42_Lafette_Deployed", "LIB_GER_SearchLight"]];
_veh set [T_VEH_stat_HMG_low, ["LIB_MG34_Lafette_Deployed", "LIB_MG42_Lafette_Deployed", "LIB_MG34_Lafette_low_Deployed", "LIB_MG42_Lafette_low_Deployed"]];
//_veh set [T_VEH_stat_GMG_low, ["LIB_MG34_Lafette_low_Deployed", "LIB_MG42_Lafette_low_Deployed"]];
_veh set [T_VEH_stat_AA, ["sab_static_aa", "sab_small_static_2xaa", "sab_small_static_aa", "LIB_FlaK_30", "LIB_FlaK_38", "LIB_Flakvierling_38", "LIB_FlaK_36_AA", "LIB_GER_SearchLight"]];
_veh set [T_VEH_stat_AT, ["ifr_lg40", "ifa3_p27G", "IFA3_Pak38", "LIB_Pak40", "LIB_leFH18_AT", "LIB_FlaK_36", "LIB_ger_Pak40_Feldgrau"]];

_veh set [T_VEH_stat_mortar_light, ["LIB_GrWr34", "LIB_GrWr34_g"]];
_veh set [T_VEH_stat_mortar_heavy, ["LIB_leFH18", "LIB_FlaK_36_ARTY", "LIB_Nebelwerfer41", "LIB_Nebelwerfer41_Camo", "LIB_Nebelwerfer41_Gelbbraun"]];
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

//_veh set [T_VEH_boat_unarmed, [""]];
_veh set [T_VEH_boat_armed, ["sab_boat_destroyer_rn"]];

_veh set [T_VEH_personal, ["LIB_Kfz1_sernyt"]];

_veh set [T_VEH_truck_inf, ["LIB_OpelBlitz_Tent_Y_Camo", "LIB_OpelBlitz_Open_Y_Camo"]];
_veh set [T_VEH_truck_cargo, ["LIB_OpelBlitz_Tent_Y_Camo", "LIB_OpelBlitz_Open_Y_Camo"]];
_veh set [T_VEH_truck_ammo, ["LIB_OpelBlitz_Ammo"]];
_veh set [T_VEH_truck_repair, ["LIB_OpelBlitz_Parm"]];
_veh set [T_VEH_truck_medical , ["LIB_OpelBlitz_Ambulance"]];
_veh set [T_VEH_truck_fuel, ["LIB_OpelBlitz_Fuel"]];

//_veh set [T_VEH_submarine, ["sab_boat_u7"]];

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
//_drone set [T_DRONE_DEFAULT, [""]];

/*
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
//==== Cargo ====
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_BasicAmmunitionBox_GER"]];
_cargo set [T_CARGO_box_small,	["LIB_BasicAmmunitionBox_GER"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicWeaponsBox_GER"]];
_cargo set [T_CARGO_box_big,	["LIB_WeaponsBox_Big_GER"]];

//==== Groups ====
_group = +(tDefault select T_GROUP);


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];
_array set [T_NAME, "tWW2_Heer"];


_array 
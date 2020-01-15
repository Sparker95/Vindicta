/*
custom Horizon Islands Defence Forces templates for ARMA III (RHS)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["rhsgref_hidf_rifleman"]];

_inf set [T_INF_SL, ["rhsgref_hidf_squadleader"]];
_inf set [T_INF_TL, ["rhsgref_hidf_teamleader"]];
//_inf set [T_INF_officer, ["rhsgref_hidf_squadleader"]];
_inf set [T_INF_GL, ["rhsgref_hidf_grenadier", "rhsgref_hidf_grenadier_m79"]];
_inf set [T_INF_rifleman, ["rhsgref_hidf_rifleman", "rhsgref_hidf_boat_driver"]];
_inf set [T_INF_marksman, ["rhsgref_hidf_marksman"]];
_inf set [T_INF_sniper, ["rhsgref_hidf_sniper"]];
//_inf set [T_INF_spotter, ["rhsgref_hidf_rifleman", "rhsgref_hidf_boat_driver"]];
//_inf set [T_INF_exp, ["rhsgref_hidf_rifleman", "rhsgref_hidf_boat_driver"]];
_inf set [T_INF_ammo, ["rhsgref_hidf_machinegunner_assist", "rhsgref_hidf_autorifleman_assist"]];
_inf set [T_INF_LAT, ["rhsgref_hidf_rifleman_m72"]];
//_inf set [T_INF_AT, ["rhsgref_hidf_rifleman_m72"]];
//_inf set [T_INF_AA, ["rhsgref_hidf_rifleman_m72"]];
_inf set [T_INF_LMG, ["rhsgref_hidf_autorifleman"]];
_inf set [T_INF_HMG, ["rhsgref_hidf_machinegunner"]];
_inf set [T_INF_medic, ["rhsgref_hidf_medic"]];
//_inf set [T_INF_engineer, ["rhsgref_hidf_rifleman"]];
_inf set [T_INF_crew, ["rhsgref_hidf_crewman"]];
_inf set [T_INF_crew_heli, ["rhsgref_hidf_helipilot"]];
_inf set [T_INF_pilot, ["rhsgref_hidf_helipilot"]];
_inf set [T_INF_pilot_heli, ["rhsgref_hidf_helipilot"]];
//_inf set [T_INF_survivor, ["rhsgref_hidf_rifleman", "rhsgref_hidf_boat_driver"]];
//_inf set [T_INF_unarmed, ["rhsgref_hidf_rifleman", "rhsgref_hidf_boat_driver"]];

// Recon
//_inf set [T_INF_recon_TL, ["RHS_LDF_recon_TL"]];
//_inf set [T_INF_recon_rifleman, ["RHS_LDF_recon_LAT"]];
//_inf set [T_INF_recon_medic, ["RHS_LDF_recon_medic"]];
//_inf set [T_INF_recon_exp, ["RHS_LDF_recon_explosives"]];
//_inf set [T_INF_recon_LAT, ["RHS_LDF_recon_LAT"]];
//_inf set [T_INF_recon_marksman, ["RHS_LDF_recon_sniper"]];
//_inf set [T_INF_recon_JTAC, ["RHS_LDF_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["B_G_Offroad_01_F"]];

_veh set [T_VEH_car_unarmed, ["B_G_Offroad_01_F", "rhsgref_hidf_m1025", "rhsgref_cdf_hidf_m998_2dr_fulltop", "rhsgref_cdf_hidf_m998_2dr_halftop", "rhsgref_cdf_hidf_m998_2dr", "rhsgref_cdf_hidf_m998_4dr_fulltop", "rhsgref_cdf_hidf_m998_4dr_halftop", "rhsgref_cdf_hidf_m998_4dr"]];
_veh set [T_VEH_car_armed, ["B_G_Offroad_01_armed_F", "B_G_Offroad_01_AT_F", "rhsgref_hidf_m1025_m2", "rhsgref_hidf_m1025_mk19", "rhsgref_cdf_reg_uaz_spg9"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsgref_BRDM2UM_msv", "rhsusf_m1240a1_usarmy_wd"]];
_veh set [T_VEH_MRAP_HMG, ["rhsgref_BRDM2_HQ_msv", "rhsgref_BRDM2_msv", "rhsusf_m1240a1_m240_usarmy_wd", "rhsusf_m1240a1_m2_usarmy_wd", "rhsusf_m1240a1_m2crows_usarmy_wd", "rhsusf_M1117_W"]];
_veh set [T_VEH_MRAP_GMG, ["rhsgref_BRDM2_ATGM_msv", "rhsusf_m1240a1_mk19_usarmy_wd"]];

_veh set [T_VEH_IFV, ["rhs_bmp1_msv", "rhs_bmp1d_msv", "rhs_bmp1k_msv"]];
_veh set [T_VEH_APC, ["rhs_btr60_msv", "rhs_btr70_msv", "rhsgref_hidf_m113a3_unarmed", "rhsgref_hidf_m113a3_m2", "rhsgref_hidf_m113a3_mk19"]];
_veh set [T_VEH_MBT, ["rhs_t72ba_tv", "rhs_t72bb_tv", "rhs_t72bc_tv", "rhs_t80", "rhs_t80a"]];
_veh set [T_VEH_MRLS, ["RHS_BM21_MSV_01", "rhsusf_M142_usarmy_wd"]];
_veh set [T_VEH_SPA, ["rhs_2s1_tv"]];
_veh set [T_VEH_SPAA, ["rhs_zsu234_aa", "rhs_gaz66_zu23_msv", "RHS_Ural6_Zu23_MSV_01"]];

_veh set [T_VEH_stat_HMG_high, ["rhsgref_hidf_m2_static"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["rhsgref_hidf_m2_static_minitripod"]];
_veh set [T_VEH_stat_GMG_low, ["rhsgref_hidf_mk19_static"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_msv", "RHS_ZU23_MSV"]];
_veh set [T_VEH_stat_AT, ["rhs_Kornet_9M133_2_msv", "rhs_Metis_9k115_2_msv", "rhs_SPG9_MSV"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_WD"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_WD", "rhs_D30_msv"]];

_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F","RHS_Mi8AMT_vss", "rhs_uh1h_hidf_unarmed", "rhs_uh1h_hidf", "RHS_UH60M2"]];
_veh set [T_VEH_heli_heavy, ["RHS_Mi8MTV3_heavy_vss", "rhs_uh1h_hidf_gunship", "RHS_UH60M"]];
_veh set [T_VEH_heli_cargo, ["RHS_Mi8mt_cargo_vss"]];
_veh set [T_VEH_heli_attack, ["B_Heli_Light_01_dynamicLoadout_F", "RHS_Mi24V_vss", "RHS_Mi24P_vss"]];

_veh set [T_VEH_plane_attack, ["RHSGREAF_A29B_HIDF", "rhs_l39_cdf"]];
_veh set [T_VEH_plane_fighter, ["RHS_Su25SM_vss"]];
//_veh set [T_VEH_plane_cargo, [""]];
_veh set [T_VEH_plane_unarmed, ["rhsgref_hidf_cessna_o3a"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["rhsgref_hidf_assault_boat", "rhsgref_hidf_rhib", "rhsgref_hidf_canoe"]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["rhs_zil131_msv", "RHS_Ural_MSV_01", "rhs_gaz66_msv"]];
_veh set [T_VEH_truck_cargo, ["rhs_zil131_flatbed_cover_msv", "RHS_Ural_Flat_MSV_01", "rhs_gaz66_flat_msv", "rhsusf_M1084A1P2_B_WD_fmtv_usarmy", "rhsusf_M977A4_BKIT_usarmy_wd"]];
_veh set [T_VEH_truck_ammo, ["rhsusf_M977A4_AMMO_usarmy_wd", "rhs_gaz66_ammo_msv"]];
_veh set [T_VEH_truck_repair, ["rhsusf_M977A4_REPAIR_usarmy_wd", "rhs_Ural_Repair_MSV_01"]];
_veh set [T_VEH_truck_medical , ["rhsusf_M1085A1P2_B_WB_Medical_fmtv_usarmy", rhs_zil131_flatbed_cover_msv", "RHS_Ural_Flat_MSV_01", "rhs_gaz66_flat_msv"]];
_veh set [T_VEH_truck_fuel, ["rhsusf_M977A4_usarmy_wd", "RHS_Ural_Fuel_MSV_01"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];

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
_array set [T_NAME, "tRHS_LDF"];


_array // End template
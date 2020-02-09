/*
RHS AFRF: Russia (MSV) templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_AFRF"];
_array set [T_DESCRIPTION, "RHS AFRF standard MSV and EMR units."];
_array set [T_DISPLAY_NAME, "RHS - AFRF"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, ["rhs_c_troops"]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT, ["rhs_msv_emr_rifleman"]];

_inf set [T_INF_SL, ["rhs_msv_emr_sergeant"]];
_inf set [T_INF_TL, ["rhs_msv_emr_efreitor", "rhs_msv_emr_junior_sergeant"]];
_inf set [T_INF_officer, ["rhs_msv_emr_officer", "rhs_msv_emr_officer_armored"]];
_inf set [T_INF_GL, ["rhs_msv_emr_grenadier"]];
_inf set [T_INF_rifleman, ["rhs_msv_emr_rifleman"]];
_inf set [T_INF_marksman, ["rhs_msv_emr_marksman"]];
_inf set [T_INF_sniper, ["rhs_msv_emr_marksman"]];
_inf set [T_INF_spotter, ["rhs_msv_emr_marksman"]];
_inf set [T_INF_exp, ["rhs_msv_emr_engineer"]];
_inf set [T_INF_ammo, ["rhs_msv_emr_machinegunner_assistant", "rhs_msv_emr_strelok_rpg_assist"]];
_inf set [T_INF_LAT, ["rhs_msv_emr_LAT", "rhs_msv_emr_RShG2"]];
_inf set [T_INF_AT, ["rhs_msv_emr_at", "rhs_msv_emr_grenadier_rpg"]];
_inf set [T_INF_AA, ["rhs_msv_emr_aa"]];
_inf set [T_INF_LMG, ["rhs_msv_emr_arifleman"]];
_inf set [T_INF_HMG, ["rhs_msv_emr_machinegunner"]];
_inf set [T_INF_medic, ["rhs_msv_emr_medic"]];
_inf set [T_INF_engineer, ["rhs_msv_emr_engineer"]];
_inf set [T_INF_crew, ["rhs_msv_emr_crew", "rhs_msv_emr_combatcrew", "rhs_msv_emr_armoredcrew", "rhs_msv_emr_crew_commander"]];
_inf set [T_INF_crew_heli, ["rhs_pilot_transport_heli"]];
_inf set [T_INF_pilot, ["rhs_pilot"]];
_inf set [T_INF_pilot_heli, ["rhs_pilot_combat_heli"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["rhs_vmf_recon_sergeant", "rhs_vmf_recon_efreitor"]];
_inf set [T_INF_recon_rifleman, ["rhs_vmf_recon_rifleman", "rhs_vmf_recon_rifleman_asval", "rhs_vmf_recon_rifleman_l", "rhs_vmf_recon_machinegunner_assistant"]];
_inf set [T_INF_recon_medic, ["rhs_vmf_recon_medic"]];
_inf set [T_INF_recon_exp, ["rhs_vmf_recon_grenadier", "rhs_vmf_recon_grenadier_scout"]];
_inf set [T_INF_recon_LAT, ["rhs_vmf_recon_rifleman_lat"]];
//_inf set [T_INF_recon_LMG, ["rhs_vmf_recon_arifleman", "rhs_vmf_recon_arifleman_scout"]]; // There is no T_INF_recon_LMG right now
_inf set [T_INF_recon_marksman, ["rhs_vmf_recon_marksman", "rhs_vmf_recon_marksman_vss"]];
_inf set [T_INF_recon_JTAC, ["rhs_vmf_recon_rifleman_scout", "rhs_vmf_recon_rifleman_scout_akm"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhs_uaz_MSV_01"]];

_veh set [T_VEH_car_unarmed, ["rhs_uaz_open_MSV_01", "RHS_UAZ_MSV_01"]];
_veh set [T_VEH_car_armed, ["rhsgref_nat_uaz_spg9", "rhsgref_nat_uaz_dshkm", "rhsgref_nat_uaz_ags"]];

_veh set [T_VEH_MRAP_unarmed, ["rhs_tigr_msv", "rhs_tigr_m_msv", "rhsgref_BRDM2UM_msv"]];
_veh set [T_VEH_MRAP_HMG, ["rhs_tigr_sts_msv", "rhsgref_BRDM2_msv", "rhsgref_BRDM2_HQ_msv"]];
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

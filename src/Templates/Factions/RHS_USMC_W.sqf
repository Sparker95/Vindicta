/*
RHSUSAF: USMC (W) templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_USMC (W)"];
_array set [T_DESCRIPTION, "RHS USMC (W) units."];
_array set [T_DISPLAY_NAME, "RHS USMC (W)"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"rhsusf_c_troops"	// RHSUSAF
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["rhsusf_usmc_marpat_wd_rifleman"]];

_inf set [T_INF_SL, ["rhsusf_usmc_marpat_wd_squadleader"]];
_inf set [T_INF_TL, ["rhsusf_usmc_marpat_wd_teamleader"]];
_inf set [T_INF_officer, ["rhsusf_usmc_marpat_wd_officer"]];
_inf set [T_INF_GL, ["rhsusf_usmc_marpat_wd_grenadier"]];
_inf set [T_INF_rifleman, ["rhsusf_usmc_marpat_wd_rifleman", "rhsusf_usmc_marpat_wd_rifleman_m4"]];
_inf set [T_INF_marksman, ["rhsusf_usmc_marpat_wd_marksman"]];
_inf set [T_INF_sniper, ["rhsusf_usmc_marpat_wd_sniper_M107", "rhsusf_usmc_marpat_wd_sniper", "rhsusf_usmc_marpat_wd_sniper_m110"]];
_inf set [T_INF_spotter, ["rhsusf_usmc_marpat_wd_spotter", "rhsusf_usmc_marpat_wd_jfo", "rhsusf_usmc_marpat_wd_fso"]];
_inf set [T_INF_exp, ["rhsusf_usmc_marpat_wd_explosives", "rhsusf_usmc_marpat_wd_rifleman_m590"]];
_inf set [T_INF_ammo, ["rhsusf_usmc_marpat_wd_machinegunner_ass", "rhsusf_usmc_marpat_wd_autorifleman_m249_ass", "rhsusf_usmc_marpat_wd_javelin_assistant"]];
_inf set [T_INF_LAT, ["rhsusf_usmc_marpat_wd_riflemanat"]];
_inf set [T_INF_AT, ["rhsusf_usmc_marpat_wd_smaw", "rhsusf_usmc_marpat_wd_javelin"]];
_inf set [T_INF_AA, ["rhsusf_usmc_marpat_wd_stinger"]];
_inf set [T_INF_LMG, ["rhsusf_usmc_marpat_wd_autorifleman_m249"]];
_inf set [T_INF_HMG, ["rhsusf_usmc_marpat_wd_machinegunner"]];
_inf set [T_INF_medic, ["rhsusf_navy_marpat_wd_medic"]];
_inf set [T_INF_engineer, ["rhsusf_usmc_marpat_wd_engineer"]];
_inf set [T_INF_crew, ["rhsusf_usmc_marpat_wd_combatcrewman", "rhsusf_usmc_marpat_wd_crewman"]];
_inf set [T_INF_crew_heli, ["rhsusf_usmc_marpat_wd_helicrew"]];
_inf set [T_INF_pilot, ["rhsusf_airforce_jetpilot"]];
_inf set [T_INF_pilot_heli, ["rhsusf_usmc_marpat_wd_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["rhsusf_usmc_recon_marpat_wd_teamleader", "rhsusf_usmc_recon_marpat_wd_teamleader_fast", "rhsusf_usmc_recon_marpat_wd_teamleader_lite", "rhsusf_usmc_lar_marpat_wd_teamleader", "rhsusf_socom_marsoc_teamleader"]];
_inf set [T_INF_recon_rifleman, ["rhsusf_usmc_recon_marpat_wd_rifleman_fast",  "rhsusf_usmc_recon_marpat_wd_rifleman_lite", "rhsusf_usmc_lar_marpat_wd_rifleman", "rhsusf_usmc_lar_marpat_wd_rifleman_light", "rhsusf_socom_marsoc_cso", "rhsusf_socom_marsoc_cso_mk17", "rhsusf_socom_marsoc_cso_mk17_light","rhsusf_socom_marsoc_cso_cqb"]];
_inf set [T_INF_recon_medic, ["rhsusf_socom_marsoc_sarc"]];
_inf set [T_INF_recon_exp, ["rhsusf_socom_marsoc_cso_breacher","rhsusf_socom_marsoc_cso_eod", "rhsusf_socom_marsoc_cso_mechanic"]];
_inf set [T_INF_recon_LAT, ["rhsusf_usmc_recon_marpat_wd_rifleman_at", "rhsusf_usmc_recon_marpat_wd_rifleman_at_fast", "rhsusf_usmc_recon_marpat_wd_rifleman_at_lite", "rhsusf_usmc_lar_marpat_wd_riflemanat"]]; //no real LAT right now but thats because of RHS
_inf set [T_INF_recon_marksman, ["rhsusf_socom_marsoc_sniper", "rhsusf_socom_marsoc_sniper_m107", "rhsusf_socom_marsoc_marksman", "rhsusf_usmc_lar_marpat_wd_marksman", "rhsusf_usmc_recon_marpat_wd_sniper_M107", "rhsusf_usmc_recon_marpat_wd_marksman_lite", "rhsusf_usmc_recon_marpat_wd_marksman_fast", "rhsusf_usmc_recon_marpat_wd_marksman"]];
_inf set [T_INF_recon_JTAC, ["rhsusf_socom_marsoc_jtac", "rhsusf_socom_marsoc_jfo"]];


// Divers, from vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsusf_m1025_w_s"]];

_veh set [T_VEH_car_unarmed, ["rhsusf_m1165_usmc_wd","rhsusf_m1152_rsv_usmc_wd","rhsusf_m1152_usmc_wd","rhsusf_m1151_usmc_wd","rhsusf_m998_w_s_4dr_fulltop","rhsusf_m998_w_s_4dr","rhsusf_m998_w_s_4dr_halftop","rhsusf_m998_w_s_2dr_fulltop","rhsusf_m998_w_s_2dr","rhsusf_m998_w_s_2dr_halftop","rhsusf_m1043_w_s","rhsusf_m1025_w_s"]];
_veh set [T_VEH_car_armed, ["rhsusf_m1151_mk19_v3_usmc_wd","rhsusf_m1151_m240_v3_usmc_wd","rhsusf_m1151_m2_v3_usmc_wd","rhsusf_m1151_mk19crows_usmc_wd","rhsusf_m1151_m2crows_usmc_wd","rhsusf_m1045_w_s","rhsusf_m1043_w_s_mk19","rhsusf_m1043_w_s_m2","rhsusf_m1025_w_s_Mk19","rhsusf_m1025_w_s_m2"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsusf_m1240a1_usmc_wd","rhsusf_CGRCAT1A2_usmc_wd"]];
_veh set [T_VEH_MRAP_HMG, ["rhsusf_m1240a1_m2crows_usmc_wd","rhsusf_m1240a1_m240_usmc_wd","rhsusf_m1240a1_m2_usmc_wd","rhsusf_M1232_MC_M2_usmc_wd","rhsusf_CGRCAT1A2_M2_usmc_wd"]];
_veh set [T_VEH_MRAP_GMG, ["rhsusf_m1240a1_mk19crows_usmc_wd","rhsusf_m1240a1_mk19_usmc_wd","rhsusf_M1232_MC_MK19_usmc_wd","rhsusf_CGRCAT1A2_Mk19_usmc_wd"]];

_veh set [T_VEH_IFV, ["RHS_M2A3_wd", "RHS_M2A3_BUSKI_wd", "RHS_M2A3_BUSKIII_wd", "RHS_M2A2_wd", "RHS_M2A2_BUSKI_WD"]];
_veh set [T_VEH_APC, ["rhsusf_m113_usarmy_MK19","rhsusf_m113_usarmy_M240","rhsusf_m113_usarmy","rhsusf_stryker_m1134_wd","rhsusf_stryker_m1132_m2_np_wd","rhsusf_stryker_m1127_m2_wd","rhsusf_stryker_m1126_mk19_wd","rhsusf_stryker_m1126_m2_wd"]];
_veh set [T_VEH_MBT, ["rhsusf_m1a1hc_wd","rhsusf_m1a1fep_od","rhsusf_m1a1fep_wd"]];

_veh set [T_VEH_MRLS, ["rhsusf_M142_usmc_WD"]];
_veh set [T_VEH_SPA, ["rhsusf_m109_usarmy"]];
_veh set [T_VEH_SPAA, ["RHS_M6_wd"]];

_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_WD"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_WD"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_WD"]];
_veh set [T_VEH_stat_AA, ["RHS_Stinger_AA_pod_WD"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_WD"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_WD"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_WD"]];

_veh set [T_VEH_heli_light, ["RHS_UH1Y_UNARMED","RHS_UH1Y","RHS_UH1Y_FFAR"]];
_veh set [T_VEH_heli_heavy, ["rhsusf_CH53E_USMC"]];
_veh set [T_VEH_heli_cargo, ["rhsusf_CH53e_USMC_cargo"]];
_veh set [T_VEH_heli_attack, ["RHS_AH1Z_wd"]];

_veh set [T_VEH_plane_attack, ["RHS_A10"]];
_veh set [T_VEH_plane_fighter , ["rhsusf_f22"]];
_veh set [T_VEH_plane_cargo, ["RHS_C130J"]];
_veh set [T_VEH_plane_unarmed , ["RHS_C130J"]];
//_veh set [T_VEH_plane_VTOL, [""]];
_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]];
_veh set [T_VEH_personal, ["rhsusf_mrzr4_w"]];

_veh set [T_VEH_truck_inf, ["rhsusf_M1078A1P2_WD_fmtv_usarmy", "rhsusf_M1078A1P2_B_WD_fmtv_usarmy", "rhsusf_M1078A1P2_B_M2_WD_fmtv_usarmy", "rhsusf_M1083A1P2_WD_fmtv_usarmy", "rhsusf_M1083A1P2_B_WD_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_WD_fmtv_usarmy"]];
_veh set [T_VEH_truck_cargo, ["rhsusf_M977A4_usarmy_wd", "rhsusf_M977A4_BKIT_M2_usarmy_wd", "rhsusf_M977A4_BKIT_usarmy_wd",
"rhsusf_M1083A1P2_WD_flatbed_fmtv_usarmy", "rhsusf_M1083A1P2_B_WD_flatbed_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_WD_flatbed_fmtv_usarmy",
"rhsusf_M1084A1P2_WD_fmtv_usarmy", "rhsusf_M1084A1P2_B_WD_fmtv_usarmy", "rhsusf_M1084A1P2_B_M2_WD_fmtv_usarmy",
"rhsusf_M1078A1P2_WD_flatbed_fmtv_usarmy", "rhsusf_M1078A1P2_B_WD_flatbed_fmtv_usarmy", "rhsusf_M1078A1P2_B_M2_WD_flatbed_fmtv_usarmy"]];
_veh set [T_VEH_truck_ammo, ["rhsusf_M977A4_AMMO_usarmy_wd", "rhsusf_M977A4_AMMO_BKIT_usarmy_wd", "rhsusf_M977A4_AMMO_BKIT_M2_usarmy_wd"]];
_veh set [T_VEH_truck_repair, ["rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_wd", "rhsusf_M977A4_REPAIR_usarmy_wd", "rhsusf_M977A4_REPAIR_BKIT_usarmy_wd"]];
_veh set [T_VEH_truck_medical , ["rhsusf_m113_usarmy_medical", "rhsusf_M1085A1P2_B_WD_Medical_fmtv_usarmy", "rhsusf_M1230a1_usarmy_wd"]];
_veh set [T_VEH_truck_fuel, ["rhsusf_M978A4_usarmy_wd", "rhsusf_M978A4_BKIT_usarmy_wd"]];

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

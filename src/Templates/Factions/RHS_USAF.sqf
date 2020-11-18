/*
RHSUSAF: US Army (W) templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_USAF"];
_array set [T_DESCRIPTION, "RHS standard US Army units."];
_array set [T_DISPLAY_NAME, "RHS USAF"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"rhsusf_c_troops"	// RHSUSAF
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["rhsusf_army_ocp_rifleman_m4"]];

_inf set [T_INF_SL, ["rhsusf_army_ocp_squadleader"]];
_inf set [T_INF_TL, ["rhsusf_army_ocp_teamleader"]];
_inf set [T_INF_officer, ["rhsusf_army_ocp_officer"]];
_inf set [T_INF_GL, ["rhsusf_army_ocp_grenadier"]];
_inf set [T_INF_rifleman, ["rhsusf_army_ocp_rifleman", "rhsusf_army_ocp_rifleman_m4", "rhsusf_army_ocp_riflemanl"]];
_inf set [T_INF_marksman, ["rhsusf_army_ocp_marksman"]];
_inf set [T_INF_sniper, ["rhsusf_army_ocp_sniper_m24sws", "rhsusf_army_ocp_sniper", "rhsusf_army_ocp_sniper_m107"]];
_inf set [T_INF_spotter, ["rhsusf_army_ocp_fso", "rhsusf_army_ocp_jfo"]];
_inf set [T_INF_exp, ["rhsusf_army_ocp_explosives", "rhsusf_army_ocp_rifleman_m590"]];
_inf set [T_INF_ammo, ["rhsusf_army_ocp_autoriflemana", "rhsusf_army_ocp_javelin_assistant", "rhsusf_army_ocp_machinegunnera"]];
_inf set [T_INF_LAT, ["rhsusf_army_ocp_riflemanat"]];
_inf set [T_INF_AT, ["rhsusf_army_ocp_maaws", "rhsusf_army_ocp_javelin"]];
_inf set [T_INF_AA, ["rhsusf_army_ocp_aa"]];
_inf set [T_INF_LMG, ["rhsusf_army_ocp_autorifleman"]];
_inf set [T_INF_HMG, ["rhsusf_army_ocp_machinegunner"]];
_inf set [T_INF_medic, ["rhsusf_army_ocp_medic"]];
_inf set [T_INF_engineer, ["rhsusf_army_ocp_engineer"]];
_inf set [T_INF_crew, ["rhsusf_army_ocp_crewman"]];
_inf set [T_INF_crew_heli, ["rhsusf_army_ocp_helicrew"]];
_inf set [T_INF_pilot, ["rhsusf_airforce_jetpilot"]];
_inf set [T_INF_pilot_heli, ["rhsusf_army_ocp_ah64_pilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["rhsusf_socom_marsoc_elementleader", "rhsusf_socom_marsoc_cso_mk17", "rhsusf_socom_marsoc_teamchief", "rhsusf_socom_marsoc_teamleader"]];
_inf set [T_INF_recon_rifleman, ["rhsusf_socom_marsoc_cso",  "rhsusf_socom_marsoc_cso_cqb", "rhsusf_socom_marsoc_cso_mk17", "rhsusf_socom_marsoc_cso_grenadier"]];
_inf set [T_INF_recon_medic, ["rhsusf_socom_marsoc_sarc"]];
_inf set [T_INF_recon_exp, ["rhsusf_socom_marsoc_cso_breacher","rhsusf_socom_marsoc_cso_eod", "rhsusf_socom_marsoc_cso_mechanic"]];
_inf set [T_INF_recon_LAT, ["rhsusf_socom_marsoc_cso_mk17_light", "rhsusf_socom_marsoc_cso_light", "rhsusf_socom_marsoc_spotter"]]; //no real LAT right now but thats because of RHS
_inf set [T_INF_recon_marksman, ["rhsusf_socom_marsoc_sniper", "rhsusf_socom_marsoc_sniper_m107", "rhsusf_socom_marsoc_marksman"]];
_inf set [T_INF_recon_JTAC, ["rhsusf_socom_marsoc_jtac", "rhsusf_socom_marsoc_jfo"]];


// Divers, from vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsusf_m1025_w"]];

_veh set [T_VEH_car_unarmed, ["rhsusf_m1025_w", "rhsusf_m998_w_4dr", "rhsusf_m998_w_4dr_halftop", "rhsusf_m998_w_4dr_fulltop", "rhsusf_m998_w_2dr", "rhsusf_m998_w_2dr_halftop", "rhsusf_m998_w_2dr_fulltop"]];
_veh set [T_VEH_car_armed, ["rhsusf_m966_w", "rhsusf_m1025_w_mk19", "rhsusf_m1025_w_m2"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsusf_m1240a1_usarmy_wd", "rhsusf_M1232_usarmy_wd"]];
_veh set [T_VEH_MRAP_HMG, ["rhsusf_m1240a1_m2crows_usarmy_wd", "rhsusf_m1240a1_m2_usarmy_wd", "rhsusf_m1240a1_m240_usarmy_wd", "rhsusf_M1232_M2_usarmy_wd", "rhsusf_M1237_M2_usarmy_wd"]];
_veh set [T_VEH_MRAP_GMG, ["rhsusf_M1232_MK19_usarmy_wd", "rhsusf_M1237_MK19_usarmy_wd", "rhsusf_m1240a1_mk19crows_usarmy_wd", "rhsusf_m1240a1_mk19_usarmy_wd"]];

_veh set [T_VEH_IFV, ["RHS_M2A3_wd", "RHS_M2A3_BUSKI_wd", "RHS_M2A3_BUSKIII_wd", "RHS_M2A2_wd", "RHS_M2A2_BUSKI_WD"]];
_veh set [T_VEH_APC, ["rhsusf_stryker_m1126_m2_d", "rhsusf_stryker_m1126_mk19_d", "rhsusf_stryker_m1127_m2_d", "rhsusf_stryker_m1132_m2_d", "rhsusf_stryker_m1134_d"]];
_veh set [T_VEH_MBT, ["rhsusf_m1a1aimwd_usarmy", "rhsusf_m1a1aim_tuski_wd", "rhsusf_m1a2sep1wd_usarmy", "rhsusf_m1a2sep1tuskiwd_usarmy", "rhsusf_m1a2sep1tuskiiwd_usarmy"]];

_veh set [T_VEH_MRLS, ["rhsusf_M142_usarmy_WD"]];
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

_veh set [T_VEH_heli_light, ["RHS_UH60M", "RHS_UH60M2", "RHS_UH60M_ESSS", "RHS_UH60M_ESSS2"]];
_veh set [T_VEH_heli_heavy, ["RHS_CH_47F"]];
_veh set [T_VEH_heli_cargo, ["RHS_CH_47F"]];
_veh set [T_VEH_heli_attack, ["RHS_AH64D_wd"]];

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

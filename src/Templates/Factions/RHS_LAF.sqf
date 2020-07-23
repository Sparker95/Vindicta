/*
custom Livonian Defence Forces templates for ARMA III (RHS)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_LAF"];
_array set [T_DESCRIPTION, "Livonian Armed Forces for Livonia. Uses BLUEFOR equipment from RHS and AAF2017."];
_array set [T_DISPLAY_NAME, "RHS Livonian Armed Forces (blufor)"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
								"rhs_c_troops",		// RHS AFRF
								"rhsusf_c_troops",
								"rhssaf_c_troops",
								"rhsgref_c_troops",
								"FGN_AAF_Troops"]]; //RHS AAF2017

//==== Infantry ====
_inf = []; _inf resize T_INF_SIZE;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_default, ["I_E_Soldier_F"]];

_inf set [T_INF_SL, ["RHS_LAF_SL"]];
_inf set [T_INF_TL, ["RHS_LAF_TL", "RHS_LAF_TL_2"]];
_inf set [T_INF_officer, ["RHS_LAF_officer"]];
_inf set [T_INF_GL, ["RHS_LAF_grenadier", "RHS_LAF_grenadier_2"]];
_inf set [T_INF_rifleman, ["RHS_LAF_rifleman", "RHS_LAF_rifleman_2"]];
_inf set [T_INF_marksman, ["RHS_LAF_marksman"]];
_inf set [T_INF_sniper, ["RHS_LAF_sniper", "RHS_LAF_sniper_2"]];
_inf set [T_INF_spotter, ["RHS_LAF_spotter", "RHS_LAF_spotter_2"]];
_inf set [T_INF_exp, ["RHS_LAF_explosives"]];
_inf set [T_INF_ammo, ["RHS_LAF_MG_2"]];
_inf set [T_INF_LAT, ["RHS_LAF_LAT", "RHS_LAF_LAT_2"]];
_inf set [T_INF_AT, ["RHS_LAF_AT", "RHS_LAF_AT_2"]];
_inf set [T_INF_AA, ["RHS_LAF_AA"]];
_inf set [T_INF_LMG, ["RHS_LAF_LMG", "RHS_LAF_LMG_2"]];
_inf set [T_INF_HMG, ["RHS_LAF_MG"]];
_inf set [T_INF_medic, ["RHS_LAF_medic"]];
_inf set [T_INF_engineer, ["RHS_LAF_engineer"]];
_inf set [T_INF_crew, ["RHS_LAF_crew"]];
_inf set [T_INF_crew_heli, ["RHS_LAF_helicrew"]];
_inf set [T_INF_pilot, ["RHS_LAF_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_LAF_helipilot"]];
//_inf set [T_INF_survivor, ["RHS_LDF_rifleman"]];
//_inf set [T_INF_unarmed, ["RHS_LDF_rifleman"]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_LAF_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_LAF_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_LAF_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_LAF_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_LAF_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_LAF_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_LAF_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsusf_m1025_w"]];

_veh set [T_VEH_car_unarmed, ["rhsusf_m1025_w"]];
_veh set [T_VEH_car_armed, ["rhsusf_m1025_w_m2", "rhsusf_m1025_w_mk19", "rhsusf_m966_w"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsusf_m1240a1_usarmy_wd"]];
_veh set [T_VEH_MRAP_HMG, ["rhsusf_m1240a1_m240_usarmy_wd"]];
_veh set [T_VEH_MRAP_GMG, ["rhsusf_m1240a1_m2_usarmy_wd"]];

_veh set [T_VEH_IFV, ["RHS_M2A2_wd", "RHS_M2A2_BUSKI_WD"]];
_veh set [T_VEH_APC, ["rhsusf_stryker_m1126_m2_d", "rhsusf_stryker_m1126_mk19_d", "rhsusf_stryker_m1127_m2_d"]];
_veh set [T_VEH_MBT, ["rhsusf_m1a1fep_od", "rhsusf_m1a1hc_wd"]];
_veh set [T_VEH_MRLS, ["rhsusf_M142_usmc_WD"]];
_veh set [T_VEH_SPA, ["rhsusf_m109_usarmy"]];
_veh set [T_VEH_SPAA, ["RHS_M6_wd"]];

_veh set [T_VEH_stat_HMG_high, ["I_HMG_02_high_F"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["I_HMG_02_F"]];
_veh set [T_VEH_stat_GMG_low, ["rhsgref_ins_g_SPG9"]];
_veh set [T_VEH_stat_AA, ["RHS_Stinger_AA_pod_WD"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_WD"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_WD"]];

_veh set [T_VEH_heli_light, ["RHS_MELB_MH6M"]];
_veh set [T_VEH_heli_heavy, ["RHS_UH60M"]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["RHS_AH1Z"]];

_veh set [T_VEH_plane_attack, ["rhs_l39_cdf"]];
_veh set [T_VEH_plane_fighter, ["rhs_l159_CDF"]];
//_veh set [T_VEH_plane_cargo, [""]];
_veh set [T_VEH_plane_unarmed, ["RHS_AN2"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["rhsusf_M1078A1P2_WD_fmtv_usarmy", "rhsusf_M1083A1P2_WD_fmtv_usarmy"]];
_veh set [T_VEH_truck_cargo, ["rhsusf_M1078A1P2_WD_flatbed_fmtv_usarmy", "rhsusf_M1083A1P2_WD_flatbed_fmtv_usarmy"]];
_veh set [T_VEH_truck_ammo, ["rhsusf_M977A4_AMMO_usarmy_wd"]];
_veh set [T_VEH_truck_repair, ["rhsusf_M977A4_REPAIR_usarmy_wd"]];
_veh set [T_VEH_truck_medical , ["rhsusf_m113_usarmy_medical", "rhsusf_M1085A1P2_B_WD_Medical_fmtv_usarmy"]];
_veh set [T_VEH_truck_fuel, ["rhsusf_M978A4_usarmy_wd"]];

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

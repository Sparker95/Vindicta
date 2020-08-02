/*
BWMOD: Bundeswehr (Tropentarn) templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_BWMOD_Niarms_BW_Trop"];
_array set [T_DESCRIPTION, "German Armed forces with American Vehicles and Niarms. Uses BWmod and RHSUSAF and Niarms."];
_array set [T_DISPLAY_NAME, "RHS-BW-Niarms Trop Custom"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
							"rhsusf_c_troops",	// RHSUSAF
							"bwa3_common",				//BWmod
							"hlcweapons_G36",			//Niarms G36
							"hlcweapons_MG3s",		//Niarms MG3
							"niarms_416",					//Niarms HK416
							"hlcweapons_mp5",			//Niarms MP5
							"hlcweapons_core"			//HLC Core
							]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT, ["BWA3_Rifleman_Tropen"]];

_inf set [T_INF_SL, ["BW_Trop_Niarms_SL","BW_Trop_Niarms_SL_2"]];
_inf set [T_INF_TL, ["BW_Trop_Niarms_TL"]];
_inf set [T_INF_officer, ["BW_Trop_Niarms_officer"]];
_inf set [T_INF_GL, ["BW_Trop_Niarms_grenadier","BW_Trop_Niarms_grenadier2","BW_Trop_Niarms_grenadier3"]];
_inf set [T_INF_rifleman, ["BW_Trop_Niarms_rifleman"]];
_inf set [T_INF_marksman, ["BW_Trop_Niarms_marksman"]];
_inf set [T_INF_sniper, ["BW_Trop_Niarms_sniper","BW_Trop_Niarms_sniper_2"]];
_inf set [T_INF_spotter, ["BW_Trop_Niarms_spotter"]];
_inf set [T_INF_exp, ["BW_Trop_Niarms_explosives"]];
_inf set [T_INF_ammo, ["BW_Trop_Niarms_AT_2","BW_Trop_Niarms_MG_2","BW_Trop_Niarms_MG_4"]];
_inf set [T_INF_LAT, ["BW_Trop_Niarms_AT"]];
_inf set [T_INF_AT, ["BW_Trop_Niarms_AT","BW_Trop_Niarms_AT_3","BW_Trop_Niarms_AS","BW_Trop_Niarms_AS_2"]];							//AS for Anti Structure
_inf set [T_INF_AA, ["BW_Trop_Niarms_AA"]];
_inf set [T_INF_LMG, ["BW_Trop_Niarms_LMG"]];
_inf set [T_INF_HMG, ["BW_Trop_Niarms_MG","BW_Trop_Niarms_MG_3"]];
_inf set [T_INF_medic, ["BW_Trop_Niarms_medic"]];
_inf set [T_INF_engineer, ["BW_Trop_Niarms_engineer"]];
_inf set [T_INF_crew, ["BW_Trop_Niarms_crew"]];
_inf set [T_INF_crew_heli, ["BW_Trop_Niarms_helicrew"]];
_inf set [T_INF_pilot, ["BW_Trop_Niarms_pilot"]];
_inf set [T_INF_pilot_heli, ["BW_Trop_Niarms_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["BW_Trop_Niarms_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["BW_Trop_Niarms_Recon_Rifleman"]];
_inf set [T_INF_recon_medic, ["BW_Trop_Niarms_recon_medic"]];
_inf set [T_INF_recon_exp, ["BW_Trop_Niarms_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["BW_Trop_Niarms_recon_LAT"]];
//_inf set [T_INF_recon_LMG, ["BW_Trop_Niarms_Recon_LMG"]];
_inf set [T_INF_recon_marksman, ["BW_Trop_Niarms_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["BW_Trop_Niarms_recon_JTAC"]];


// Divers, from vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["BWA3_Eagle_Tropen"]];

_veh set [T_VEH_car_unarmed, [ "BWA3_Eagle_Tropen", "rhsusf_m1025_d", "rhsusf_m998_d_4dr"]];
_veh set [T_VEH_car_armed, ["BWA3_Eagle_FLW100_Tropen","rhsusf_m1025_d_m2"]];

_veh set [T_VEH_MRAP_unarmed, ["rhsusf_M1232_usarmy_d", "rhsusf_CGRCAT1A2_usmc_d", "rhsusf_m1240a1_usmc_d", "rhsusf_M1220_usarmy_d"]];
_veh set [T_VEH_MRAP_HMG, ["rhsusf_CGRCAT1A2_M2_usmc_d", "rhsusf_m1240a1_m2_usmc_d", "rhsusf_m1240a1_m240_usmc_d","rhsusf_M1220_M2_usarmy_d"]];
_veh set [T_VEH_MRAP_GMG, ["rhsusf_m1240a1_mk19_usmc_d", "rhsusf_CGRCAT1A2_Mk19_usmc_d", "rhsusf_M1232_MK19_usarmy_d", "rhsusf_m1025_d_s_Mk19","rhsusf_M1220_MK19_usarmy_d"]];

_veh set [T_VEH_IFV, ["BWA3_Puma_Tropen", "RHS_M2A2", "RHS_M2A2_BUSKI"]];
_veh set [T_VEH_APC, ["rhsusf_stryker_m1126_m2_d","rhsusf_m113d_usarmy_M240","rhsusf_m113d_usarmy","rhsusf_m113d_usarmy_MK19","rhsusf_M1117_d"]];
_veh set [T_VEH_MBT, ["BWA3_Leopard2_Tropen"]];

_veh set [T_VEH_MRLS, ["rhsusf_M142_usarmy_d"]];
_veh set [T_VEH_SPA, ["rhsusf_m109d_usarmy"]];
_veh set [T_VEH_SPAA, ["RHS_M6"]];

_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_d"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_d"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_d"]];
_veh set [T_VEH_stat_AA, ["RHS_Stinger_AA_pod_d"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_d"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_d"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_d"]];

_veh set [T_VEH_heli_light, ["RHS_UH60M_d","RHS_UH60M2_d", "RHS_UH60M_ESSS_d", "RHS_UH60M_ESSS2_d"]];
_veh set [T_VEH_heli_heavy, ["RHS_CH_47F_light"]];
_veh set [T_VEH_heli_cargo, ["RHS_CH_47F_light"]];
_veh set [T_VEH_heli_attack, ["BWA3_Tiger_RMK_FZ"]];

_veh set [T_VEH_plane_attack, ["RHS_A10"]];
_veh set [T_VEH_plane_fighter , ["rhsusf_f22"]];
_veh set [T_VEH_plane_cargo, ["RHS_C130J"]];
_veh set [T_VEH_plane_unarmed , ["RHS_C130J"]];
//_veh set [T_VEH_plane_VTOL, [""]];
_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]];
_veh set [T_VEH_personal, ["rhsusf_mrzr4_d"]];

_veh set [T_VEH_truck_inf, ["rhsusf_M1083A1P2_d_fmtv_usarmy", "rhsusf_M1078A1P2_d_fmtv_usarmy", "rhsusf_M1078A1P2_B_d_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_d_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_d_fmtv_usarmy"]];
_veh set [T_VEH_truck_cargo, ["rhsusf_M977A4_usarmy_d", "rhsusf_M977A4_BKIT_M2_usarmy_d", "rhsusf_M977A4_BKIT_usarmy_d",
"rhsusf_M1083A1P2_d_flatbed_fmtv_usarmy", "rhsusf_M1083A1P2_B_d_flatbed_fmtv_usarmy", "rhsusf_M1083A1P2_B_M2_d_flatbed_fmtv_usarmy",
"rhsusf_M1084A1P2_d_fmtv_usarmy", "rhsusf_M1084A1P2_B_d_fmtv_usarmy", "rhsusf_M1084A1P2_B_M2_d_fmtv_usarmy",
"rhsusf_M1078A1P2_d_flatbed_fmtv_usarmy", "rhsusf_M1078A1P2_B_d_flatbed_fmtv_usarmy", "rhsusf_M1078A1P2_B_M2_d_flatbed_fmtv_usarmy"]];
_veh set [T_VEH_truck_ammo, ["rhsusf_M977A4_AMMO_usarmy_d", "rhsusf_M977A4_AMMO_BKIT_usarmy_d", "rhsusf_M977A4_AMMO_BKIT_M2_usarmy_d"]];
_veh set [T_VEH_truck_repair, ["rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_d", "rhsusf_M977A4_REPAIR_usarmy_d", "rhsusf_M977A4_REPAIR_BKIT_usarmy_d"]];
_veh set [T_VEH_truck_medical , ["rhsusf_m113_usarmy_medical", "rhsusf_M1085A1P2_B_d_Medical_fmtv_usarmy", "rhsusf_M1230a1_usarmy_d"]];
_veh set [T_VEH_truck_fuel, ["rhsusf_M978A4_usarmy_d", "rhsusf_M978A4_BKIT_usarmy_d"]];

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

/*
custom Horizons Islands Defence Forces template for ARMA III (RHS)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_HIDF"];
_array set [T_DESCRIPTION, "Horizon Islands Defence Forces. Uses RHS."];
_array set [T_DISPLAY_NAME, "RHS HIDF Custom"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
								"rhsusf_c_troops",
								"rhssaf_c_troops",
								"rhsgref_c_troops"]];

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil];
_inf set [T_INF_default, ["B_GEN_Commander_F"]];

_inf set [T_INF_SL, ["RHS_HIDF_SL"]];
_inf set [T_INF_TL, ["RHS_HIDF_TL"]];
_inf set [T_INF_officer, ["RHS_HIDF_officer"]];
_inf set [T_INF_GL, ["RHS_HIDF_grenadier", "RHS_HIDF_grenadier_2"]];
_inf set [T_INF_rifleman, ["RHS_HIDF_rifleman", "RHS_HIDF_rifleman_2"]];
_inf set [T_INF_marksman, ["RHS_HIDF_marksman"]];
_inf set [T_INF_sniper, ["RHS_HIDF_sniper", "RHS_HIDF_sniper_2"]];
_inf set [T_INF_spotter, ["RHS_HIDF_spotter", "RHS_HIDF_spotter_2"]];
_inf set [T_INF_exp, ["RHS_HIDF_explosives"]];
_inf set [T_INF_ammo, ["RHS_HIDF_MG_2"]];
_inf set [T_INF_LAT, ["RHS_HIDF_LAT", "RHS_HIDF_LAT_2"]];
_inf set [T_INF_AT, ["RHS_HIDF_LAT", "RHS_HIDF_LAT_2"]];
_inf set [T_INF_AA, ["RHS_HIDF_rifleman"]];
_inf set [T_INF_LMG, ["RHS_HIDF_LMG"]];
_inf set [T_INF_HMG, ["RHS_HIDF_MG"]];
_inf set [T_INF_medic, ["RHS_HIDF_medic"]];
_inf set [T_INF_engineer, ["RHS_HIDF_engineer"]];
_inf set [T_INF_crew, ["RHS_HIDF_crew"]];
_inf set [T_INF_crew_heli, ["RHS_HIDF_helicrew"]];
_inf set [T_INF_pilot, ["RHS_HIDF_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_HIDF_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_HIDF_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_HIDF_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_HIDF_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_HIDF_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_HIDF_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_HIDF_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_HIDF_recon_JTAC"]];

// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsgref_hidf_m1025"]];

_veh set [T_VEH_car_unarmed, ["rhsgref_hidf_m1025", "rhsgref_hidf_M998_2dr_fulltop", "rhsgref_hidf_M998_2dr_halftop", "rhsgref_hidf_M998_2dr", "rhsgref_hidf_M998_4dr_fulltop", "rhsgref_hidf_M998_4dr_halftop", "rhsgref_hidf_m998_4dr"]];
_veh set [T_VEH_car_armed, ["rhsgref_hidf_m1025_m2", "rhsgref_hidf_m1025_mk19"]];

//cars are in MRAP until cars are added
_veh set [T_VEH_MRAP_unarmed, ["rhsgref_hidf_m1025", "rhsgref_hidf_M998_2dr_fulltop", "rhsgref_hidf_M998_2dr_halftop", "rhsgref_hidf_M998_2dr", "rhsgref_hidf_M998_4dr_fulltop", "rhsgref_hidf_M998_4dr_halftop", "rhsgref_hidf_m998_4dr"]];
_veh set [T_VEH_MRAP_HMG, ["rhsgref_hidf_m1025_m2"]];
_veh set [T_VEH_MRAP_GMG, ["rhsusf_M1117_O", "rhsusf_M1117_W", "rhsgref_hidf_m1025_mk19"]];

//_veh set [T_VEH_IFV, [""]];
_veh set [T_VEH_APC, ["rhsgref_hidf_m113a3_unarmed", "rhsgref_hidf_m113a3_mk19", "rhsgref_hidf_m113a3_m2"]];
//_veh set [T_VEH_MBT, [""]];
//_veh set [T_VEH_MRLS, [""]];
//_veh set [T_VEH_SPA, [""]];
//_veh set [T_VEH_SPAA, [""]];

_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_WD"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_WD"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_WD"]];
_veh set [T_VEH_stat_AA, ["RHS_Stinger_AA_pod_WD"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_WD"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_WD"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_WD"]];

_veh set [T_VEH_heli_light, ["rhs_uh1h_hidf_unarmed"]];
_veh set [T_VEH_heli_heavy, ["rhs_uh1h_hidf"]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["rhs_uh1h_hidf_gunship"]];

_veh set [T_VEH_plane_attack, ["RHSGREF_A29B_HIDF"]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
_veh set [T_VEH_plane_unarmed, ["rhsgred_hidf_cessna_o3a"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F", "rhsgref_hidf_canoe"]];
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]];

_veh set [T_VEH_personal, ["I_E_Quadbike_01_F","rhsusf_mrzr4_w"]];

_veh set [T_VEH_truck_inf, ["rhsusf_M1078A1P2_WD_fmtv_usarmy", "rhsusf_M1083A1P2_WD_fmtv_usarmy"]];
_veh set [T_VEH_truck_cargo, ["rhsusf_M1078A1P2_WD_flatbed_fmtv_usarmy", "rhsusf_M1083A1P2_WD_flatbed_fmtv_usarmy","rhsusf_M1084A1R_SOV_M2_D_fmtv_socom"]];
_veh set [T_VEH_truck_ammo, ["rhsusf_M977A4_AMMO_usarmy_wd", "rhsusf_M1078A1R_SOV_M2_D_fmtv_socom"]];
_veh set [T_VEH_truck_repair, ["rhsusf_M977A4_REPAIR_usarmy_wd", "rhsusf_M1078A1R_SOV_M2_D_fmtv_socom"]];
_veh set [T_VEH_truck_medical , ["rhsusf_m113_usarmy_medical", "rhsusf_M1085A1P2_B_WD_Medical_fmtv_usarmy"]];
_veh set [T_VEH_truck_fuel, ["rhsusf_M978A4_usarmy_wd", "rhsusf_M1078A1R_SOV_M2_D_fmtv_socom"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];

//==== Drones ====
_drone = +(tDefault select T_DRONE);
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
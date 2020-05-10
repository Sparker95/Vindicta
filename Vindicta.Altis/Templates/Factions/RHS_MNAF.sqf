/*
custom Malden Armed Forces template for ARMA III (RHS)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_MNAF"];
_array set [T_DESCRIPTION, "Malden National Armed. Uses RHS and MNAF."];
_array set [T_DISPLAY_NAME, "RHS MNAF Custom"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
								"rhsusf_c_troops",
								"rhssaf_c_troops",
								"rhsgref_c_troops",
								"Malden_vehicles"]]; //MNAF

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil];
_inf set [T_INF_default, ["MGEN_rifleman"]];

_inf set [T_INF_SL, ["RHS_MNAF_SL"]];
_inf set [T_INF_TL, ["RHS_MNAF_TL", "RHS_MNAF_TL_2"]];
_inf set [T_INF_officer, ["RHS_MNAF_officer"]];
_inf set [T_INF_GL, ["RHS_MNAF_grenadier", "RHS_MNAF_grenadier_2"]];
_inf set [T_INF_rifleman, ["RHS_MNAF_rifleman", "RHS_MNAF_rifleman_2"]];
_inf set [T_INF_marksman, ["RHS_MNAF_marksman"]];
_inf set [T_INF_sniper, ["RHS_MNAF_sniper", "RHS_MNAF_sniper_2", "RHS_MNAF_sniper_3"]];
_inf set [T_INF_spotter, ["RHS_MNAF_spotter", "RHS_MNAF_spotter_2"]];
_inf set [T_INF_exp, ["RHS_MNAF_explosives"]];
_inf set [T_INF_ammo, ["RHS_MNAF_MG_2"]];
_inf set [T_INF_LAT, ["RHS_MNAF_LAT", "RHS_MNAF_LAT_2"]];
_inf set [T_INF_AT, ["RHS_MNAF_AT", "RHS_MNAF_AT_2"]];
_inf set [T_INF_AA, ["RHS_MNAF_rifleman"]];
_inf set [T_INF_LMG, ["RHS_MNAF_LMG", "RHS_MNAF_LMG_2"]];
_inf set [T_INF_HMG, ["RHS_MNAF_MG"]];
_inf set [T_INF_medic, ["RHS_MNAF_medic"]];
_inf set [T_INF_engineer, ["RHS_MNAF_engineer"]];
_inf set [T_INF_crew, ["RHS_MNAF_crew"]];
_inf set [T_INF_crew_heli, ["RHS_MNAF_helicrew"]];
_inf set [T_INF_pilot, ["RHS_MNAF_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_MNAF_helipilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_MNAF_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_MNAF_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_MNAF_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_MNAF_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_MNAF_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_MNAF_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_MNAF_recon_JTAC"]];

// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhsusf_m1025_d"]];

_veh set [T_VEH_car_unarmed, ["rhsusf_m1025_d"]];
_veh set [T_VEH_car_armed, ["rhsusf_m1025_d_m2", "rhsusf_m1025_d_Mk19", "rhsusf_m966_d"]];

//cars are in MRAP until cars are added
_veh set [T_VEH_MRAP_unarmed, ["malden_AWC_radar", "rhsusf_m1025_d"]];
_veh set [T_VEH_MRAP_HMG, ["malden_AWC_atgm", "rhsusf_m1025_d_m2"]];
_veh set [T_VEH_MRAP_GMG, ["malden_AWC_cannon", "rhsusf_m1025_d_Mk19"]];

_veh set [T_VEH_IFV, ["malden_IFV_warrior"]];
_veh set [T_VEH_APC, ["rhsusf_stryker_m1126_m2_d", "rhsusf_stryker_m1126_mk19_d", "rhsusf_stryker_m1127_m2_d", "rhsusf_stryker_m1132_m2_d", "rhsusf_stryker_m1134_d"]];
_veh set [T_VEH_MBT, ["malden_MGS_F"]];
_veh set [T_VEH_MRLS, ["rhsusf_M142_usarmy_D"]];
//_veh set [T_VEH_SPA, [""]];
//_veh set [T_VEH_SPAA, [""]];

_veh set [T_VEH_stat_HMG_high, ["I_HMG_02_high_F"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["I_HMG_02_F"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_WD"]];
_veh set [T_VEH_stat_AA, ["RHS_Stinger_AA_pod_WD"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_D"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_D"]];

_veh set [T_VEH_heli_light, ["mgen_mh9"]];
_veh set [T_VEH_heli_heavy, ["mgen_cat_t"]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["mgen_cat_a", "mgen_ah9"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]];

_veh set [T_VEH_personal, ["MGEN_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["mgen_zamak_covered", "mgen_zamak"]];
_veh set [T_VEH_truck_cargo, ["rhsusf_M977A4_usarmy_d"]];
_veh set [T_VEH_truck_ammo, ["rhsusf_M977A4_AMMO_usarmy_d"]];
_veh set [T_VEH_truck_repair, ["rhsusf_M977A4_REPAIR_usarmy_d"]];
_veh set [T_VEH_truck_medical , ["rhsusf_M1085A1P2_B_D_Medical_fmtv_usarmy"]];
_veh set [T_VEH_truck_fuel, ["rhsusf_M978A4_usarmy_d"]];

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
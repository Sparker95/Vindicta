_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "t3CB_BAF"];
_array set [T_DESCRIPTION, "British Armed Forces. Uses 3CB's BAF pack and RHS."];
_array set [T_DISPLAY_NAME, "3CB BAF"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops",	// RHSGREF
	"uk3cb_baf_units_mtp",	// BAF Units
	"uk3cb_baf_equipment",	// BAF Equipment
	"uk3cb_baf_units_ace",	// BAF Ace Compat
	"uk3cb_baf_units_rhs",	// BAF RHS Compat
	"uk3cb_baf_vehicles_MAN", // BAF Vehicles
	"uk3cb_baf_weapons_L110", // BAF Weaponry
	"uk3cb_baf_weapons_ace" // BAF RHS Ammo Compat	
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["UK3CB_BAF_Rifleman_MTP"]];

_inf set [T_INF_SL, ["UK3CB_BAF_SC_MTP"]];
_inf set [T_INF_TL, ["UK3CB_BAF_FT_MTP", "UK3CB_BAF_FT_762_MTP"]];
_inf set [T_INF_officer, ["UK3CB_BAF_Officer_MTP"]];
_inf set [T_INF_GL, ["UK3CB_BAF_Grenadier_MTP", "UK3CB_BAF_Grenadier_762_MTP"]];
_inf set [T_INF_rifleman, ["UK3CB_BAF_Rifleman_MTP"]];
_inf set [T_INF_marksman, ["UK3CB_BAF_Marksman_MTP"]];
_inf set [T_INF_sniper, ["UK3CB_BAF_Sniper_MTP_Ghillie_L115", "UK3CB_BAF_Sniper_MTP_Ghillie_L135"]];
_inf set [T_INF_spotter, ["UK3CB_BAF_Spotter_MTP_Ghillie_L129", "UK3CB_BAF_Spotter_MTP_Ghillie_L85"]];
_inf set [T_INF_exp, ["UK3CB_BAF_Explosive_MTP_REC"]];
_inf set [T_INF_ammo, ["UK3CB_BAF_MATC_MTP", "UK3CB_BAF_Rifleman_762_MTP"]];
_inf set [T_INF_LAT, ["UK3CB_BAF_LAT_ILAW_MTP", "UK3CB_BAF_LAT_ILAW_762_MTP"]];
_inf set [T_INF_AT, ["UK3CB_BAF_LAT_MTP", "UK3CB_BAF_LAT_762_MTP"]];
_inf set [T_INF_AA, ["UK3CB_BAF_MAT_MTP"]];
_inf set [T_INF_LMG, ["UK3CB_BAF_MGLMG_MTP"]];
_inf set [T_INF_HMG, ["UK3CB_BAF_MGGPMG_MTP"]];
_inf set [T_INF_medic, ["UK3CB_BAF_Medic_MTP"]];
_inf set [T_INF_engineer, ["UK3CB_BAF_Engineer_MTP"]];
_inf set [T_INF_crew, ["UK3CB_BAF_Crewman_MTP"]];
_inf set [T_INF_crew_heli, ["UK3CB_BAF_HeliCrew_MTP"]];
_inf set [T_INF_pilot, ["UK3CB_BAF_HeliPilot_RAF_MTP"]];
_inf set [T_INF_pilot_heli, ["UK3CB_BAF_HeliPilot_Army_MTP"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["UK3CB_BAF_SC_MTP_REC"]];
_inf set [T_INF_recon_rifleman, ["UK3CB_BAF_Pointman_MTP_REC"]];
_inf set [T_INF_recon_medic, ["UK3CB_BAF_Medic_MTP_REC"]];
_inf set [T_INF_recon_exp, ["UK3CB_BAF_Explosive_MTP_REC"]];
_inf set [T_INF_recon_LAT, ["UK3CB_BAF_LAT_ILAW_MTP"]];
//_inf set [T_INF_recon_marksman, ["rhs_vmf_recon_marksman", "rhs_vmf_recon_marksman_vss"]];
_inf set [T_INF_recon_JTAC, ["UK3CB_BAF_FAC_MTP_REC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["UK3CB_BAF_LandRover_Snatch_FFR_Green_A_MTP"]];

_veh set [T_VEH_car_unarmed, ["UK3CB_BAF_LandRover_Soft_FFR_Green_A_MTP", "UK3CB_BAF_LandRover_Snatch_FFR_Green_A_MTP", "UK3CB_BAF_LandRover_Hard_FFR_Green_A_MTP"]];
_veh set [T_VEH_car_armed, ["UK3CB_BAF_LandRover_WMIK_GMG_FFR_Green_A_MTP", "UK3CB_BAF_LandRover_WMIK_GPMG_FFR_Green_A_MTP", "UK3CB_BAF_LandRover_WMIK_HMG_FFR_Green_A_MTP"]];

_veh set [T_VEH_MRAP_unarmed, ["UK3CB_BAF_LandRover_Hard_FFR_Green_A_MTP"]];
_veh set [T_VEH_MRAP_HMG, ["UK3CB_BAF_Husky_Passenger_HMG_Green_MTP", "UK3CB_BAF_Husky_Passenger_GPMG_Green_MTP"]];
_veh set [T_VEH_MRAP_GMG, ["UK3CB_BAF_Husky_Passenger_GMG_Green_MTP"]];

_veh set [T_VEH_IFV, ["UK3CB_BAF_Warrior_A3_W_MTP", "UK3CB_BAF_Warrior_A3_W_Cage_MTP", "UK3CB_BAF_Warrior_A3_W_Cage_Camo_MTP", "UK3CB_BAF_Warrior_A3_W_Camo_MTP"]];
_veh set [T_VEH_APC, ["UK3CB_BAF_FV432_Mk3_GPMG_Green_MTP", "UK3CB_BAF_FV432_Mk3_RWS_Green_MTP"]];
_veh set [T_VEH_MBT, ["rhsusf_m1a1aimwd_usarmy", "rhsusf_m1a1aim_tuski_wd", "rhsusf_m1a2sep1wd_usarmy", "rhsusf_m1a2sep1tuskiwd_usarmy", "rhsusf_m1a2sep1tuskiiwd_usarmy"]];
_veh set [T_VEH_MRLS, ["rhsusf_M142_usarmy_WD"]];
_veh set [T_VEH_SPA, ["rhsusf_m109_usarmy"]];
//_veh set [T_VEH_SPAA, ["rhs_zsu234_aa", "RHS_Ural_Zu23_MSV_01"]];

_veh set [T_VEH_stat_HMG_high, ["UK3CB_BAF_Static_L111A1_Deployed_High_MTP", "UK3CB_BAF_Static_L7A2_Deployed_High_MTP"]];
_veh set [T_VEH_stat_GMG_high, ["UK3CB_BAF_Static_L134A1_Deployed_High_MTP"]];
_veh set [T_VEH_stat_HMG_low, ["UK3CB_BAF_Static_L111A1_Deployed_Low_MTP", "UK3CB_BAF_Static_L7A2_Deployed_Low_MTP"]];
_veh set [T_VEH_stat_GMG_low, ["UK3CB_BAF_Static_L134A1_Deployed_Low_MTP"]];
//_veh set [T_VEH_stat_AA, [""]];
//_veh set [T_VEH_stat_AT, [""]];

_veh set [T_VEH_stat_mortar_light, ["UK3CB_BAF_Static_M6_Deployed_MTP"]];
_veh set [T_VEH_stat_mortar_heavy, ["UK3CB_BAF_Static_L16_Deployed_MTP"]];

_veh set [T_VEH_heli_light, ["RHS_MELB_MH6M", "RHS_MELB_H6M"]];
_veh set [T_VEH_heli_heavy, ["UK3CB_BAF_Merlin_HC3_18_MTP","UK3CB_BAF_Merlin_HC3_18_GPMG_MTP","UK3CB_BAF_Merlin_HC3_24_MTP","UK3CB_BAF_Merlin_HC3_32_MTP"]];
_veh set [T_VEH_heli_cargo, ["UK3CB_BAF_Merlin_HC3_Cargo_MTP"]];
_veh set [T_VEH_heli_attack, ["UK3CB_BAF_Apache_AH1_AT_MTP", "UK3CB_BAF_Apache_AH1_CAS_MTP","UK3CB_BAF_Apache_AH1_MTP","UK3CB_BAF_Apache_AH1_JS_MTP"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

//_veh set [T_VEH_boat_unarmed, [""]];
_veh set [T_VEH_boat_armed, ["UK3CB_BAF_RHIB_GPMG_MTP", "UK3CB_BAF_RHIB_HMG_MTP"]];

_veh set [T_VEH_personal, ["O_G_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["UK3CB_BAF_MAN_HX58_Transport_Green_MTP", "UK3CB_BAF_MAN_HX60_Transport_Green_MTP"]];
_veh set [T_VEH_truck_cargo, ["UK3CB_BAF_MAN_HX58_Cargo_Green_A_MTP", "UK3CB_BAF_MAN_HX58_Cargo_Green_B_MTP", "UK3CB_BAF_MAN_HX60_Cargo_Green_A_MTP", "UK3CB_BAF_MAN_HX60_Cargo_Green_B_MTP"]];
_veh set [T_VEH_truck_ammo, ["UK3CB_BAF_MAN_HX58_Cargo_Green_B_MTP", "UK3CB_BAF_MAN_HX60_Cargo_Green_B_MTP"]];
_veh set [T_VEH_truck_repair, ["UK3CB_BAF_MAN_HX58_Repair_Green_MTP", "UK3CB_BAF_MAN_HX60_Repair_Green_MTP"]];
_veh set [T_VEH_truck_medical , ["UK3CB_BAF_LandRover_Amb_FFR_Green_A_MTP"]];
_veh set [T_VEH_truck_fuel, ["UK3CB_BAF_MAN_HX58_Fuel_Green_MTP", "UK3CB_BAF_MAN_HX60_Fuel_Green_MTP"]];

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

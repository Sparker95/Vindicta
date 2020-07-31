_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRussians2035"];
_array set [T_DESCRIPTION, "Russian Armed Forces from 2035."];
_array set [T_DISPLAY_NAME, "RAF 2035"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"min_rf_units"		// 2035: Russian Armed Forces
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["min_rf_soldier"]];

_inf set [T_INF_SL, ["min_rf_soldier_SL"]];
_inf set [T_INF_TL, ["min_rf_soldier_TL"]];
_inf set [T_INF_officer, ["min_rf_officer"]];
_inf set [T_INF_GL, ["min_rf_soldier_GL"]];
_inf set [T_INF_rifleman, ["min_rf_soldier", "min_rf_soldier_lite"]];
_inf set [T_INF_marksman, ["min_rf_soldier_M"]];
_inf set [T_INF_sniper, ["min_rf_sniper"]];
_inf set [T_INF_spotter, ["min_rf_spotter"]];
_inf set [T_INF_exp, ["min_rf_soldier_exp"]];
_inf set [T_INF_ammo, ["min_rf_soldier_A", "min_rf_soldier_AAR", "min_rf_soldier_AAR", "min_rf_soldier_AAT"]];
_inf set [T_INF_LAT, ["min_rf_soldier_LAT"]];
_inf set [T_INF_AT, ["min_rf_soldier_AT"]];
_inf set [T_INF_AA, ["min_rf_soldier_AA"]];
_inf set [T_INF_LMG, ["min_rf_soldier_AR"]];
_inf set [T_INF_HMG, ["min_rf_soldier_AR"]];
_inf set [T_INF_medic, ["min_rf_medic"]];
_inf set [T_INF_engineer, ["min_rf_engineer"]];
_inf set [T_INF_crew, ["min_rf_crew"]];
_inf set [T_INF_crew_heli, ["min_rf_crew"]];
_inf set [T_INF_pilot, ["min_rf_helipilot"]];
_inf set [T_INF_pilot_heli, ["min_rf_pilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["min_rf_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["min_rf_recon"]];
_inf set [T_INF_recon_medic, ["min_rf_recon_medic"]];
_inf set [T_INF_recon_exp, ["min_rf_recon_exp"]];
_inf set [T_INF_recon_LAT, ["min_rf_recon_LAT"]];
//_inf set [""];
_inf set [T_INF_recon_marksman, ["min_rf_recon_M"]];
_inf set [T_INF_recon_JTAC, ["min_rf_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["min_rf_gaz_2330"]];

_veh set [T_VEH_car_unarmed, ["min_rf_gaz_2330"]];
_veh set [T_VEH_car_armed, ["min_rf_gaz_2330_HMG"]];

_veh set [T_VEH_MRAP_unarmed, ["min_rf_gaz_2330"]];
_veh set [T_VEH_MRAP_HMG, ["min_rf_gaz_2330_HMG"]];
//_veh set [T_VEH_MRAP_GMG, [""]];

_veh set [T_VEH_IFV, ["min_rf_t_15"]];
_veh set [T_VEH_APC, ["min_rf_t_15"]];
_veh set [T_VEH_MBT, ["min_rf_t_14"]];
_veh set [T_VEH_MRLS, ["min_rf_2b26"]];
_veh set [T_VEH_SPA, ["min_rf_2b26"]];
_veh set [T_VEH_SPAA, ["min_rf_sa_22"]];

//_veh set [T_VEH_stat_HMG_high, [""]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["min_rf_Kord"]];
_veh set [T_VEH_stat_GMG_low, ["min_rf_AGS_30"]];
_veh set [T_VEH_stat_AA, ["min_rf_Metis"]];
_veh set [T_VEH_stat_AT, ["min_rf_Metis"]];

_veh set [T_VEH_stat_mortar_light, ["min_rf_Mortar"]];
_veh set [T_VEH_stat_mortar_heavy, ["min_rf_Mortar"]];

//_veh set [T_VEH_heli_light, [""]];
_veh set [T_VEH_heli_heavy, ["min_rf_heli_light_unarmed_black","min_rf_heli_light_black"]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["min_rf_ka_52"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["min_rf_boat_transport"]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["O_G_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["min_rf_truck_transport", "min_rf_truck_covered"]];
_veh set [T_VEH_truck_cargo, ["min_rf_truck_transport", "min_rf_truck_covered"]];
_veh set [T_VEH_truck_ammo, ["min_rf_truck_ammo"]];
_veh set [T_VEH_truck_repair, ["min_rf_truck_box"]];
_veh set [T_VEH_truck_medical , ["min_rf_truck_ammo"]];
_veh set [T_VEH_truck_fuel, ["min_rf_truck_fuel"]];

//_veh set [T_VEH_submarine, [""]];

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

_array 

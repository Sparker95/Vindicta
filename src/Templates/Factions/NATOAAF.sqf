_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tNATOAAF"];
_array set [T_DESCRIPTION, "Nato and AAF together. Made by Spectrum"];
_array set [T_DISPLAY_NAME, "NATO + AAF"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, []];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["B_Soldier_F"]];

_inf set [T_INF_SL, ["B_Soldier_SL_F", "I_Soldier_SL_F"]];
_inf set [T_INF_TL, ["B_Soldier_TL_F", "I_Soldier_TL_F"]];
_inf set [T_INF_officer, ["B_officer_F", "I_officer_F"]];
_inf set [T_INF_GL, ["B_Soldier_GL_F", "I_Soldier_GL_F"]];
_inf set [T_INF_rifleman, ["B_Soldier_F", 3, "B_Soldier_lite_F", 1, "I_soldier_F", 3, "I_Soldier_lite_F", 1]];
_inf set [T_INF_marksman, ["B_soldier_M_F", "I_Soldier_M_F"]];
_inf set [T_INF_sniper, ["B_sniper_F", "I_Sniper_F"]];
_inf set [T_INF_spotter, ["B_spotter_F", "I_Spotter_F"]];
_inf set [T_INF_exp, ["B_soldier_exp_F", "I_Soldier_exp_F"]];
_inf set [T_INF_ammo, ["B_soldier_AAR_F", "B_soldier_AAA_F", "B_soldier_AAT_F", "B_Soldier_A_F", "I_Soldier_A_F", "I_Soldier_AAR_F", "I_Soldier_AAA_F", "I_Soldier_AAT_F"]];
_inf set [T_INF_LAT, ["B_soldier_LAT_F", "I_Soldier_LAT_F"]];
_inf set [T_INF_AT, ["B_soldier_AT_F", "I_Soldier_AT_F"]];
_inf set [T_INF_AA, ["B_soldier_AA_F", "I_Soldier_AA_F"]];
_inf set [T_INF_LMG, ["B_soldier_AR_F", "I_Soldier_AR_F"]];
_inf set [T_INF_HMG, ["B_HeavyGunner_F", "Arma3_AAF_HMG"]];
_inf set [T_INF_medic, ["B_medic_F", "I_medic_F"]];
_inf set [T_INF_engineer, ["B_engineer_F", "I_engineer_F"]];
_inf set [T_INF_crew, ["B_crew_F", "I_crew_F"]];
_inf set [T_INF_crew_heli, ["B_helicrew_F", "I_helicrew_F"]];
_inf set [T_INF_pilot, ["B_Pilot_F", "I_pilot_F"]];
_inf set [T_INF_pilot_heli, ["B_Helipilot_F", "I_helipilot_F"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["B_recon_TL_F"]];
_inf set [T_INF_recon_rifleman, ["B_recon_F"]];
_inf set [T_INF_recon_medic, ["B_recon_medic_F"]];
_inf set [T_INF_recon_exp, ["B_recon_exp_F"]];
_inf set [T_INF_recon_LAT, ["B_recon_LAT_F"]];
_inf set [T_INF_recon_marksman, ["B_recon_M_F"]];
_inf set [T_INF_recon_JTAC, ["B_recon_JTAC_F"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["B_LSV_01_unarmed_F"]];

_veh set [T_VEH_car_unarmed, ["B_LSV_01_unarmed_F", "A3_AAF_offroad_unarmed"]];
_veh set [T_VEH_car_armed, ["B_LSV_01_armed_F", "I_G_Offroad_01_armed_F_1"]];

_veh set [T_VEH_MRAP_unarmed, ["B_MRAP_01_F", "I_MRAP_03_F"]];
_veh set [T_VEH_MRAP_HMG, ["B_MRAP_01_hmg_F", "I_MRAP_03_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["B_MRAP_01_gmg_F", "I_MRAP_03_gmg_F"]];

_veh set [T_VEH_IFV, ["B_APC_Wheeled_01_cannon_F_1", "B_APC_Wheeled_01_cannon_F_2", "B_APC_Wheeled_01_cannon_F_1", "B_APC_Tracked_01_CRV_F_1", "I_APC_tracked_03_cannon_F_1", "I_APC_tracked_03_cannon_F_2", "I_APC_tracked_03_cannon_F_3", "I_APC_tracked_03_cannon_F_4"]];
_veh set [T_VEH_APC, ["B_APC_Tracked_01_rcws_F_1", "I_APC_Wheeled_03_cannon_F_1"]];
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F_1", "B_MBT_01_cannon_F_2", "B_MBT_01_TUSK_F_1", "B_MBT_01_TUSK_F_2", "B_AFV_Wheeled_01_cannon_F_1", "B_AFV_Wheeled_01_cannon_F_2", "B_AFV_Wheeled_01_up_cannon_F_1", "B_AFV_Wheeled_01_up_cannon_F_2", "I_MBT_03_cannon_F_1", "I_MBT_03_cannon_F_2", "I_MBT_03_cannon_F_3", "I_MBT_03_cannon_F_4"]];
_veh set [T_VEH_MRLS, ["B_MBT_01_mlrs_F", "I_Truck_02_MRL_F"]];
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]];
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F", "I_LT_01_AA_F"]];

_veh set [T_VEH_stat_HMG_high, ["I_E_HMG_01_high_F", "I_HMG_02_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["B_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]];
//_veh set [T_VEH_stat_AA, [""]];
//_veh set [T_VEH_stat_AT, [""]];

_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
_veh set [T_VEH_stat_mortar_heavy, ["B_Mortar_01_F"]];

_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F", "I_Heli_light_03_unarmed_F"]];
_veh set [T_VEH_heli_heavy, ["B_Heli_Transport_01_F", "I_Heli_Transport_02_F"]];
_veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F", "I_Heli_Transport_02_F"]];
_veh set [T_VEH_heli_attack, ["B_Heli_Attack_01_dynamicLoadout_F", "I_Heli_light_03_dynamicLoadout_F"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["B_Truck_01_transport_F", "B_Truck_01_covered_F", "I_Truck_02_transport_F", "I_Truck_02_covered_F"]];
_veh set [T_VEH_truck_cargo, ["B_Truck_01_cargo_F", "I_Truck_02_covered_F"]];
_veh set [T_VEH_truck_ammo, ["B_Truck_01_ammo_F", "I_Truck_02_ammo_F"]];
_veh set [T_VEH_truck_repair, ["B_Truck_01_Repair_F", "I_Truck_02_box_F"]];
_veh set [T_VEH_truck_medical , ["B_Truck_01_medical_F", "I_Truck_02_medical_F"]];
_veh set [T_VEH_truck_fuel, ["B_Truck_01_fuel_F", "I_Truck_02_fuel_F"]];

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

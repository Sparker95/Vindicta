_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tNATOCSAT"];
_array set [T_DESCRIPTION, "Nato and CSAT together. NOT CANON! Made by Spectrum"];
_array set [T_DISPLAY_NAME, "NATO + CSAT"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, []];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["B_Soldier_F"]];

_inf set [T_INF_SL, ["B_Soldier_SL_F", "O_Soldier_SL_F"]];
_inf set [T_INF_TL, ["B_Soldier_TL_F", "O_Soldier_TL_F"]];
_inf set [T_INF_officer, ["B_officer_F", "O_officer_F"]];
_inf set [T_INF_GL, ["B_Soldier_GL_F", "O_Soldier_GL_F"]];
_inf set [T_INF_rifleman, ["B_Soldier_F", 3, "B_Soldier_lite_F", 1, "O_Soldier_F", 3, "O_Soldier_lite_F", 1]];
_inf set [T_INF_marksman, ["B_soldier_M_F", "O_soldier_M_F"]];
_inf set [T_INF_sniper, ["B_sniper_F", "O_sniper_F"]];
_inf set [T_INF_spotter, ["B_spotter_F", "O_spotter_F"]];
_inf set [T_INF_exp, ["B_soldier_exp_F", "O_soldier_exp_F"]];
_inf set [T_INF_ammo, ["B_soldier_AAR_F", "B_soldier_AAA_F", "B_soldier_AAT_F", "B_Soldier_A_F", "O_Soldier_A_F", "O_Soldier_AAR_F", "O_Soldier_AAA_F", "O_Soldier_AAT_F"]];
_inf set [T_INF_LAT, ["B_soldier_LAT_F", "O_Soldier_LAT_F"]];
_inf set [T_INF_AT, ["B_soldier_AT_F", "O_Soldier_AT_F"]];
_inf set [T_INF_AA, ["B_soldier_AA_F", "O_Soldier_AA_F"]];
_inf set [T_INF_LMG, ["B_soldier_AR_F", "O_Soldier_AR_F"]];
_inf set [T_INF_HMG, ["B_HeavyGunner_F", "O_HeavyGunner_F"]];
_inf set [T_INF_medic, ["B_medic_F", "O_medic_F"]];
_inf set [T_INF_engineer, ["B_engineer_F", "O_engineer_F"]];
_inf set [T_INF_crew, ["B_crew_F", "O_crew_F"]];
_inf set [T_INF_crew_heli, ["B_helicrew_F", "O_helicrew_F"]];
_inf set [T_INF_pilot, ["B_Pilot_F", "O_Pilot_F"]];
_inf set [T_INF_pilot_heli, ["B_Helipilot_F", "O_helipilot_F"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["B_recon_TL_F", "O_recon_TL_F"]];
_inf set [T_INF_recon_rifleman, ["B_recon_F", "O_recon_F"]];
_inf set [T_INF_recon_medic, ["B_recon_medic_F", "O_recon_medic_F"]];
_inf set [T_INF_recon_exp, ["B_recon_exp_F", "O_recon_exp_F"]];
_inf set [T_INF_recon_LAT, ["B_recon_LAT_F", "O_recon_LAT_F"]];
_inf set [T_INF_recon_marksman, ["B_recon_M_F", "O_recon_M_F"]];
_inf set [T_INF_recon_JTAC, ["B_recon_JTAC_F", "O_recon_JTAC_F"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["B_LSV_01_unarmed_F"]];

_veh set [T_VEH_car_unarmed, ["B_LSV_01_unarmed_F", "O_LSV_02_unarmed_F"]];
_veh set [T_VEH_car_armed, ["B_LSV_01_armed_F", "O_LSV_02_armed_F"]];

_veh set [T_VEH_MRAP_unarmed, ["B_MRAP_01_F", "O_MRAP_02_F"]];
_veh set [T_VEH_MRAP_HMG, ["B_MRAP_01_hmg_F", "O_MRAP_02_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["B_MRAP_01_gmg_F", "O_MRAP_02_gmg_F"]];

_veh set [T_VEH_IFV, ["B_APC_Wheeled_01_cannon_F_1", "B_APC_Wheeled_01_cannon_F_2", "B_APC_Wheeled_01_cannon_F_1", "B_APC_Tracked_01_CRV_F_1", "O_APC_Tracked_02_cannon_F_1"]];
_veh set [T_VEH_APC, ["B_APC_Tracked_01_rcws_F_1", "O_APC_Wheeled_02_rcws_v2_F_1"]];
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F_1", "B_MBT_01_cannon_F_2", "B_MBT_01_TUSK_F_1", "B_MBT_01_TUSK_F_2", "B_AFV_Wheeled_01_cannon_F_1", "B_AFV_Wheeled_01_cannon_F_2", "B_AFV_Wheeled_01_up_cannon_F_1", "B_AFV_Wheeled_01_up_cannon_F_2", "O_MBT_02_cannon_F_1", "O_MBT_02_cannon_F_2", "O_MBT_04_cannon_F_1", "O_MBT_04_cannon_F_2", "O_MBT_04_command_F_1", "O_MBT_04_command_F_1"]];
_veh set [T_VEH_MRLS, ["B_MBT_01_mlrs_F", "O_MBT_02_arty_F"]];
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F", "O_MBT_02_arty_F"]];
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F", "O_APC_Tracked_02_AA_F"]];

_veh set [T_VEH_stat_HMG_high, ["I_E_HMG_01_high_F", "I_HMG_02_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["B_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]];
//_veh set [T_VEH_stat_AA, [""]];
//_veh set [T_VEH_stat_AT, [""]];

_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
_veh set [T_VEH_stat_mortar_heavy, ["B_Mortar_01_F"]];

_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F", "O_Heli_Light_02_unarmed_F"]];
_veh set [T_VEH_heli_heavy, ["B_Heli_Transport_01_F", "O_Heli_Transport_04_covered_F"]];
_veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F", "O_Heli_Transport_04_box_F"]];
_veh set [T_VEH_heli_attack, ["B_Heli_Attack_01_dynamicLoadout_F", "O_Heli_Light_02_dynamicLoadout_F", "O_Heli_Attack_02_dynamicLoadout_F"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["O_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["O_Boat_Armed_01_hmg_F"]];

_veh set [T_VEH_personal, ["O_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["B_Truck_01_transport_F", "B_Truck_01_covered_F", "O_Truck_02_transport_F", "O_Truck_02_covered_F", "O_Truck_03_transport_F", "O_Truck_03_covered_F"]];
_veh set [T_VEH_truck_cargo, ["B_Truck_01_cargo_F", "O_Truck_03_covered_F", "O_Truck_02_covered_F"]];
_veh set [T_VEH_truck_ammo, ["B_Truck_01_ammo_F", "O_Truck_03_ammo_F", "O_Truck_02_Ammo_F"]];
_veh set [T_VEH_truck_repair, ["B_Truck_01_Repair_F", "O_Truck_03_repair_F", "O_Truck_02_box_F"]];
_veh set [T_VEH_truck_medical , ["B_Truck_01_medical_F", "O_Truck_03_medical_F", "O_Truck_02_medical_F"]];
_veh set [T_VEH_truck_fuel, ["B_Truck_01_fuel_F", "O_Truck_03_fuel_F", "O_Truck_02_fuel_F"]];

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

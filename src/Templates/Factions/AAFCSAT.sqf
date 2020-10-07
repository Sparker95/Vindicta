_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tAAFCSAT"];
_array set [T_DESCRIPTION, "AAF and CSAT together. Made by Spectrum"];
_array set [T_DISPLAY_NAME, "AAF + CSAT"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, []];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["O_Soldier_F"]];

_inf set [T_INF_SL, ["O_Soldier_SL_F", "I_Soldier_SL_F"]];
_inf set [T_INF_TL, ["O_Soldier_TL_F", "I_Soldier_TL_F"]];
_inf set [T_INF_officer, ["O_officer_F", "I_officer_F"]];
_inf set [T_INF_GL, ["O_Soldier_GL_F", "I_Soldier_GL_F"]];
_inf set [T_INF_rifleman, ["O_Soldier_F", 3, "O_Soldier_lite_F", 1, "I_soldier_F", 3, "I_Soldier_lite_F", 1]];
_inf set [T_INF_marksman, ["O_soldier_M_F", "I_Soldier_M_F"]];
_inf set [T_INF_sniper, ["O_sniper_F", "I_Sniper_F"]];
_inf set [T_INF_spotter, ["O_spotter_F", "I_Spotter_F"]];
_inf set [T_INF_exp, ["O_soldier_exp_F", "I_Soldier_exp_F"]];
_inf set [T_INF_ammo, ["O_Soldier_A_F", "O_Soldier_AAR_F", "O_Soldier_AAA_F", "O_Soldier_AAT_F", "I_Soldier_A_F", "I_Soldier_AAR_F", "I_Soldier_AAA_F", "I_Soldier_AAT_F"]];
_inf set [T_INF_LAT, ["O_Soldier_LAT_F", "I_Soldier_LAT_F"]];
_inf set [T_INF_AT, ["O_Soldier_AT_F", "I_Soldier_AT_F"]];
_inf set [T_INF_AA, ["O_Soldier_AA_F", "I_Soldier_AA_F"]];
_inf set [T_INF_LMG, ["O_Soldier_AR_F", "I_Soldier_AR_F"]];
_inf set [T_INF_HMG, ["O_HeavyGunner_F", "Arma3_AAF_HMG"]];
_inf set [T_INF_medic, ["O_medic_F", "I_medic_F"]];
_inf set [T_INF_engineer, ["O_engineer_F", "I_engineer_F"]];
_inf set [T_INF_crew, ["O_crew_F", "I_crew_F"]];
_inf set [T_INF_crew_heli, ["O_helicrew_F", "I_helicrew_F"]];
_inf set [T_INF_pilot, ["O_Pilot_F", "I_pilot_F"]];
_inf set [T_INF_pilot_heli, ["O_helipilot_F", "I_helipilot_F"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["Arma3_AAF_recon_TL", "O_recon_TL_F"]];
_inf set [T_INF_recon_rifleman, ["Arma3_AAF_recon_rifleman", "O_recon_F"]];
_inf set [T_INF_recon_medic, ["Arma3_AAF_recon_medic", "O_recon_medic_F"]];
_inf set [T_INF_recon_exp, ["Arma3_AAF_recon_explosives", "O_recon_exp_F"]];
_inf set [T_INF_recon_LAT, ["Arma3_AAF_recon_LAT", "O_recon_LAT_F"]];
_inf set [T_INF_recon_marksman, ["Arma3_AAF_recon_marksman", "O_recon_M_F"]];
_inf set [T_INF_recon_JTAC, ["Arma3_AAF_recon_JTAC", "O_recon_JTAC_F"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["O_LSV_02_unarmed_F"]];

_veh set [T_VEH_car_unarmed, ["O_LSV_02_unarmed_F", "A3_AAF_offroad_unarmed"]];
_veh set [T_VEH_car_armed, ["O_LSV_02_armed_F", "I_G_Offroad_01_armed_F_1"]];

_veh set [T_VEH_MRAP_unarmed, ["O_MRAP_02_F", "I_MRAP_03_F"]];
_veh set [T_VEH_MRAP_HMG, ["O_MRAP_02_hmg_F", "I_MRAP_03_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["O_MRAP_02_gmg_F", "I_MRAP_03_gmg_F"]];

_veh set [T_VEH_IFV, ["O_APC_Tracked_02_cannon_F_1", "I_APC_tracked_03_cannon_F_1", "I_APC_tracked_03_cannon_F_2", "I_APC_tracked_03_cannon_F_3", "I_APC_tracked_03_cannon_F_4"]];
_veh set [T_VEH_APC, ["O_APC_Wheeled_02_rcws_v2_F_1", "I_APC_Wheeled_03_cannon_F_1"]];
_veh set [T_VEH_MBT, ["O_MBT_02_cannon_F_1", "O_MBT_02_cannon_F_2", "O_MBT_04_cannon_F_1", "O_MBT_04_cannon_F_2", "O_MBT_04_command_F_1", "O_MBT_04_command_F_2", "I_MBT_03_cannon_F_1", "I_MBT_03_cannon_F_2", "I_MBT_03_cannon_F_3", "I_MBT_03_cannon_F_4"]];
_veh set [T_VEH_MRLS, ["O_MBT_02_arty_F", "I_Truck_02_MRL_F"]];
_veh set [T_VEH_SPA, ["O_MBT_02_arty_F"]];
_veh set [T_VEH_SPAA, ["O_APC_Tracked_02_AA_F", "I_LT_01_AA_F"]];

_veh set [T_VEH_stat_HMG_high, ["I_E_HMG_01_high_F", "I_HMG_02_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["O_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["O_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["O_GMG_01_F"]];
//_veh set [T_VEH_stat_AA, [""]];
//_veh set [T_VEH_stat_AT, [""]];

_veh set [T_VEH_stat_mortar_light, ["O_Mortar_01_F"]];
_veh set [T_VEH_stat_mortar_heavy, ["O_Mortar_01_F"]];

_veh set [T_VEH_heli_light, ["O_Heli_Light_02_unarmed_F", "I_Heli_light_03_unarmed_F"]];
_veh set [T_VEH_heli_heavy, ["O_Heli_Transport_04_covered_F", "I_Heli_Transport_02_F"]];
_veh set [T_VEH_heli_cargo, ["O_Heli_Transport_04_box_F", "I_Heli_Transport_02_F"]];
_veh set [T_VEH_heli_attack, ["O_Heli_Light_02_dynamicLoadout_F", "O_Heli_Attack_02_dynamicLoadout_F", "I_Heli_light_03_dynamicLoadout_F"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["O_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["O_Boat_Armed_01_hmg_F"]];

_veh set [T_VEH_personal, ["O_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["O_Truck_02_transport_F", "O_Truck_02_covered_F", "O_Truck_03_transport_F", "O_Truck_03_covered_F", "I_Truck_02_transport_F", "I_Truck_02_covered_F"]];
_veh set [T_VEH_truck_cargo, ["O_Truck_03_covered_F", "O_Truck_02_covered_F", "I_Truck_02_covered_F"]];
_veh set [T_VEH_truck_ammo, ["O_Truck_03_ammo_F", "O_Truck_02_Ammo_F", "I_Truck_02_ammo_F"]];
_veh set [T_VEH_truck_repair, ["O_Truck_03_repair_F", "O_Truck_02_box_F", "I_Truck_02_box_F"]];
_veh set [T_VEH_truck_medical , ["O_Truck_03_medical_F", "O_Truck_02_medical_F", "I_Truck_02_medical_F"]];
_veh set [T_VEH_truck_fuel, ["O_Truck_03_fuel_F", "O_Truck_02_fuel_F", "I_Truck_02_fuel_F"]];

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

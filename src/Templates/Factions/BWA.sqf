_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tBWA3"];
_array set [T_DESCRIPTION, "BundesWehr from the year 2020. German forces, no voices sadly."];
_array set [T_DISPLAY_NAME, "BundesWehr2020"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
"bwa3_units",
"bwa3_comp_ace",
"TBW_Insignia",
"HAFM_EC635",
"sfp_bo105",
"gm_demo"
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["BWA3_Rifleman_Fleck"]];

_inf set [T_INF_SL, ["BWA3_SL_Fleck"]];
_inf set [T_INF_TL, ["BWA3_TL_Fleck"]];
_inf set [T_INF_officer, ["BWA3_Officer_Fleck", "TBW_Feldjaeger"]];
_inf set [T_INF_GL, ["BWA3_Grenadier_Fleck", "BWA3_Grenadier_G27_Fleck"]];
_inf set [T_INF_rifleman, ["BWA3_Rifleman_Fleck", "BWA3_Rifleman_lite_Fleck", "BWA3_Rifleman_G27_Fleck", "BWA3_Rifleman_G28_Fleck"]];
_inf set [T_INF_marksman, ["BWA3_Marksman_Fleck"]];
_inf set [T_INF_sniper, ["BWA3_Sniper_G29_Fleck", "BWA3_Sniper_G82_Fleck"]];
_inf set [T_INF_spotter, ["BWA3_Spotter_Fleck"]];
_inf set [T_INF_exp, ["BWA3_recon_Pioneer_Fleck"]];
_inf set [T_INF_ammo, ["BWA3_MachineGunner_MG3_Fleck"]];
_inf set [T_INF_LAT, ["BWA3_RiflemanAT_PzF3_Fleck"]];
_inf set [T_INF_AT, ["BWA3_RiflemanAT_RGW90_Fleck"]];
_inf set [T_INF_AA, ["BWA3_RiflemanAA_Fliegerfaust_Fleck"]];
_inf set [T_INF_LMG, ["BWA3_MachineGunner_MG3_Fleck", "BWA3_MachineGunner_MG4_Fleck", "BWA3_MachineGunner_MG5_Fleck"]];
_inf set [T_INF_HMG, ["BWA3_MachineGunner_MG3_Fleck", "BWA3_MachineGunner_MG4_Fleck", "BWA3_MachineGunner_MG5_Fleck"]];
_inf set [T_INF_medic, ["BWA3_Medic_Fleck"]];
_inf set [T_INF_engineer, ["BWA3_Engineer_Fleck"]];
_inf set [T_INF_crew, ["BWA3_Crew_Fleck"]];
_inf set [T_INF_crew_heli, ["BWA3_Crew_Fleck"]];
_inf set [T_INF_pilot, ["BWA3_Helipilot", "bw_pilot"]];
_inf set [T_INF_pilot_heli, ["BWA3_Helipilot", "bw_pilot"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["BWA3_recon_TL_Fleck"]];
_inf set [T_INF_recon_rifleman, ["BWA3_recon_Fleck"]];
_inf set [T_INF_recon_medic, ["BWA3_recon_Medic_Fleck"]];
_inf set [T_INF_recon_exp, ["BWA3_recon_Pioneer_Fleck"]];
_inf set [T_INF_recon_LAT, ["BWA3_recon_LAT_Fleck"]];
_inf set [T_INF_recon_marksman, ["BWA3_recon_Marksman_Fleck"]];
_inf set [T_INF_recon_JTAC, ["BWA3_recon_Radioman_Fleck"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["KGB_B_MRAP_03_F"]];

_veh set [T_VEH_car_unarmed, ["KGB_B_MRAP_03_F"]];
_veh set [T_VEH_car_armed, ["KGB_B_MRAP_03_gmg_F", "KGB_B_MRAP_03_hmg_F"]];

_veh set [T_VEH_MRAP_unarmed, ["KGB_B_MRAP_03_F"]];
_veh set [T_VEH_MRAP_HMG, ["BW_Dingo_Wdl"]];
_veh set [T_VEH_MRAP_GMG, ["BW_Dingo_GL_Wdl"]];

_veh set [T_VEH_IFV, ["BWA3_Puma_Fleck"]];
_veh set [T_VEH_APC, ["B_APC_Wheeled_01_cannon_F"]];
_veh set [T_VEH_MBT, ["BWA3_Leopard2_Fleck", "B_MBT_01_cannon_F"]];
_veh set [T_VEH_MRLS, ["B_MBT_01_mlrs_F"]];
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]];
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F"]];

_veh set [T_VEH_stat_HMG_high, ["B_HMG_01_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["B_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]];
_veh set [T_VEH_stat_AA, ["B_static_AA_F"]];
_veh set [T_VEH_stat_AT, ["B_static_AT_F"]];
_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
//_veh set [T_VEH_stat_mortar_heavy, ["UK3CB_BAF_Static_L16_Deployed_MTP"]];

_veh set [T_VEH_heli_light, ["EC635_Unarmed_BW"]];
_veh set [T_VEH_heli_heavy, ["bw_nh90_marine"]];
_veh set [T_VEH_heli_cargo, ["EC635_Unarmed_BW"]];
_veh set [T_VEH_heli_attack, ["EC635_BW", "EC635_AT_BW"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];

_veh set [T_VEH_personal, ["O_G_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["bw_unimog_cargo", "bw_unimog_cargo_covered", "BW_LKW_Transport_offen_fleck", "BW_LKW_Transport_Fleck"]];
_veh set [T_VEH_truck_cargo, ["bw_unimog_cargo", "bw_unimog_cargo_covered", "BW_LKW_Transport_offen_fleck", "BW_LKW_Transport_Fleck"]];
_veh set [T_VEH_truck_ammo, ["BW_LKW_Munition_Fleck"]];
_veh set [T_VEH_truck_repair, ["BW_LKW_Reparatur_Fleck"]];
_veh set [T_VEH_truck_medical , ["BW_LKW_Medic_Fleck"]];
_veh set [T_VEH_truck_fuel, ["BW_LKW_Treibstoff_Fleck"]];

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

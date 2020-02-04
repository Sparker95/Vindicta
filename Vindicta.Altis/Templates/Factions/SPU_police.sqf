<<<<<<< Updated upstream
/*
custom Altis Special Police Unit templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["B_GEN_Soldier_F"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["SPU_police_SL"]];
_inf set [T_INF_TL, ["SPU_police_TL"]];
_inf set [T_INF_officer, ["SPU_police_TL"]];
/*
_inf set [T_INF_GL, ["SPU_police_rifleman"]];
_inf set [T_INF_rifleman, ["SPU_police_rifleman"]];
_inf set [T_INF_marksman, ["SPU_police_rifleman"]];
_inf set [T_INF_sniper, ["SPU_police_rifleman"]];
_inf set [T_INF_spotter, ["SPU_police_rifleman"]];
_inf set [T_INF_exp, ["SPU_police_rifleman"]];
_inf set [T_INF_ammo, ["SPU_police_rifleman"]];
_inf set [T_INF_LAT, ["SPU_police_rifleman"]];
_inf set [T_INF_AT, ["SPU_police_rifleman"]];
_inf set [T_INF_AA, ["SPU_police_rifleman"]];
_inf set [T_INF_LMG, ["SPU_police_rifleman"]];
_inf set [T_INF_HMG, ["SPU_police_rifleman"]];
_inf set [T_INF_medic, ["SPU_police_rifleman"]];
_inf set [T_INF_engineer, ["SPU_police_rifleman"]];
_inf set [T_INF_crew, ["SPU_police_rifleman"]];
_inf set [T_INF_crew_heli, ["SPU_police_rifleman"]];
_inf set [T_INF_pilot, ["SPU_police_rifleman"]];
_inf set [T_INF_pilot_heli, ["SPU_police_rifleman"]];
_inf set [T_INF_survivor, ["SPU_police_rifleman"]];
_inf set [T_INF_unarmed, ["SPU_police_rifleman"]];
*/

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["B_GEN_Offroad_01_gen_F"]];
_veh set [T_VEH_car_unarmed, ["B_GEN_Offroad_01_gen_F", "B_GEN_Offroad_01_comms_F", "B_GEN_Offroad_01_covered_F", "B_GEN_Van_02_transport_F"]]; // , "B_GEN_Van_02_vehicle_F" -- not enough seats in this

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["O_UAV_01_F"]];

_drone set [T_DRONE_UGV_unarmed, ["O_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["O_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["O_T_UAV_04_CAS_F"]];
_drone set [T_DRONE_quadcopter, ["O_UAV_01_F"]];
_drone set [T_DRONE_designator, ["O_Static_Designator_02_F"]];
_drone set [T_DRONE_stat_HMG_low, ["O_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["O_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["O_SAM_System_04_F"]];

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
_array set [T_NAME, "tPolice"];
_array set [T_FACTION, T_FACTION_Police];

=======
/*
custom Altis Special Police Unit templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["B_GEN_Soldier_F"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["SPU_police_SL"]];
_inf set [T_INF_TL, ["SPU_police_TL"]];
_inf set [T_INF_officer, ["SPU_police_TL"]];
/*
_inf set [T_INF_GL, ["SPU_police_rifleman"]];
_inf set [T_INF_rifleman, ["SPU_police_rifleman"]];
_inf set [T_INF_marksman, ["SPU_police_rifleman"]];
_inf set [T_INF_sniper, ["SPU_police_rifleman"]];
_inf set [T_INF_spotter, ["SPU_police_rifleman"]];
_inf set [T_INF_exp, ["SPU_police_rifleman"]];
_inf set [T_INF_ammo, ["SPU_police_rifleman"]];
_inf set [T_INF_LAT, ["SPU_police_rifleman"]];
_inf set [T_INF_AT, ["SPU_police_rifleman"]];
_inf set [T_INF_AA, ["SPU_police_rifleman"]];
_inf set [T_INF_LMG, ["SPU_police_rifleman"]];
_inf set [T_INF_HMG, ["SPU_police_rifleman"]];
_inf set [T_INF_medic, ["SPU_police_rifleman"]];
_inf set [T_INF_engineer, ["SPU_police_rifleman"]];
_inf set [T_INF_crew, ["SPU_police_rifleman"]];
_inf set [T_INF_crew_heli, ["SPU_police_rifleman"]];
_inf set [T_INF_pilot, ["SPU_police_rifleman"]];
_inf set [T_INF_pilot_heli, ["SPU_police_rifleman"]];
_inf set [T_INF_survivor, ["SPU_police_rifleman"]];
_inf set [T_INF_unarmed, ["SPU_police_rifleman"]];
*/

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["B_GEN_Offroad_01_gen_F"]];
_veh set [T_VEH_car_unarmed, ["B_GEN_Offroad_01_gen_F", "B_GEN_Offroad_01_comms_F", "B_GEN_Offroad_01_covered_F", "B_GEN_Van_02_transport_F"]]; // , "B_GEN_Van_02_vehicle_F" -- not enough seats in this

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["O_UAV_01_F"]];

_drone set [T_DRONE_UGV_unarmed, ["O_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["O_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["O_T_UAV_04_CAS_F"]];
_drone set [T_DRONE_quadcopter, ["O_UAV_01_F"]];
_drone set [T_DRONE_designator, ["O_Static_Designator_02_F"]];
_drone set [T_DRONE_stat_HMG_low, ["O_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["O_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["O_SAM_System_04_F"]];

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
_array set [T_NAME, "tPolice"];
_array set [T_FACTION, T_FACTION_Police];

>>>>>>> Stashed changes
_array
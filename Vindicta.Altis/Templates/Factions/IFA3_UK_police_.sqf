/*
POLICE templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["LIB_UK_Rifleman"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["LIB_UK_Sergeant"]];
_inf set [T_INF_TL, ["LIB_UK_Corporal"]];
_inf set [T_INF_officer, ["LIB_UK_Officer"]];
_inf set [T_INF_GL, ["LIB_UK_Grenadier"]];
_inf set [T_INF_rifleman, ["LIB_UK_Rifleman"]];
_inf set [T_INF_marksman, ["LIB_UK_Sniper"]];
_inf set [T_INF_sniper, ["LIB_UK_Sniper"]];
//_inf set [T_INF_spotter, [""]];
_inf set [T_INF_exp, ["LIB_UK_Engineer"]];
//_inf set [T_INF_ammo, [""]];
//_inf set [T_INF_LAT, ["LIB_UK_AT_Soldier"]];
_inf set [T_INF_AT, ["LIB_GER_AT_soldier", "LNRD_Luftwaffe_AT_soldier]];
//_inf set [T_INF_AA, [""]];
_inf set [T_INF_LMG, ["LIB_UK_LanceCorporal"]];
//_inf set [T_INF_HMG, [""]];
_inf set [T_INF_medic, ["LIB_UK_Medic"]];
_inf set [T_INF_engineer, ["LIB_UK_Engineer"]];
_inf set [T_INF_crew, ["LIB_UK_Tank_Commander", "LIB_UK_Tank_Crew"]];
//_inf set [T_INF_crew_heli, [""]];
_inf set [T_INF_pilot, ["LIB_US_Pilot"]];
//_inf set [T_INF_pilot_heli, [""]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];


//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];
_veh set [T_VEH_car_unarmed, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];


//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
//_drone set [T_DRONE_DEFAULT, ["O_UAV_01_F"]];
/*
_drone set [T_DRONE_UGV_unarmed, ["O_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["O_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["O_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_plane_unarmed, ["O_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_heli_attack, ["O_T_UAV_04_CAS_F"]];
_drone set [T_DRONE_quadcopter, ["O_UAV_01_F"]];
_drone set [T_DRONE_designator, ["O_Static_Designator_02_F"]];
_drone set [T_DRONE_stat_HMG_low, ["O_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["O_GMG_01_A_F"]];
_drone set [T_DRONE_stat_AA, ["O_SAM_System_04_F"]];
*/
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
_array set [T_NAME, "tIFA3_UK_police"];

_array
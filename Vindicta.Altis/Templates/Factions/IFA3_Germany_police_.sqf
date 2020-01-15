/*
POLICE templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["SG_sturmtrooper_rifleman"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["SG_sturmtrooper_unterofficer"]];
_inf set [T_INF_TL, ["SG_sturmtrooper_smgunner"]];
_inf set [T_INF_officer, ["SG_sturmtrooper_lieutenant"]];
_inf set [T_INF_GL, ["SG_sturmtrooper_ober_grenadier"]];
_inf set [T_INF_rifleman, ["SG_sturmtrooper_ober_rifleman", "SG_sturmtrooper_rifleman", "SG_sturmtrooper_stggunner"]];
_inf set [T_INF_marksman, ["SG_sturmtrooper_sniper"]];
_inf set [T_INF_sniper, ["SG_sturmtrooper_sniper"]];
//_inf set [T_INF_spotter, [""]];
_inf set [T_INF_exp, ["SG_sturmtrooper_sapper_gefr", "SG_sturmtrooper_sapper"]];
//_inf set [T_INF_ammo, [""]];
_inf set [T_INF_LAT, ["SG_sturmtrooper_LAT_rifleman", "SG_sturmtrooper_AT_grenadier"]];
_inf set [T_INF_AT, ["SG_sturmtrooper_AT_soldier"]];
//_inf set [T_INF_AA, [""]];
_inf set [T_INF_LMG, ["SG_sturmtrooper_mgunner"]];
_inf set [T_INF_HMG, ["SG_sturmtrooper_mgunner"]];
_inf set [T_INF_medic, ["SG_sturmtrooper_medic"]];
//_inf set [T_INF_engineer, [""]];
//_inf set [T_INF_crew, [""]];
//_inf set [T_INF_crew_heli, [""]];
//_inf set [T_INF_pilot, [""]];
//_inf set [T_INF_pilot_heli, [""]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];


//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["LIB_Kfz1_sernyt", "LIB_Kfz1_Hood_sernyt"]];
_veh set [T_VEH_car_unarmed, ["LIB_Kfz1_sernyt", "LIB_Kfz1_Hood_sernyt"]];


//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
//_drone set [T_DRONE_DEFAULT, ["O_UAV_01_F"]];

//_drone set [T_DRONE_UGV_unarmed, ["O_UGV_01_F"]];
//_drone set [T_DRONE_UGV_armed, ["O_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["O_T_UAV_04_CAS_F"]];
//_drone set [T_DRONE_quadcopter, ["O_UAV_01_F"]];
//_drone set [T_DRONE_designator, ["O_Static_Designator_02_F"]];
//_drone set [T_DRONE_stat_HMG_low, ["O_HMG_01_A_F"]];
//_drone set [T_DRONE_stat_GMG_low, ["O_GMG_01_A_F"]];
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

_array
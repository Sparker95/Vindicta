_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tWW2_UK_police"];
_array set [T_DESCRIPTION, "WW2 UK units with equipment from 1939-1945"];
_array set [T_DISPLAY_NAME, "WW2 - UK (Police)"];
_array set [T_FACTION, T_FACTION_Police];
_array set [T_REQUIRED_ADDONS, ["ww2_assets_c_characters_core_c", "lib_weapons", "geistl_main", "fow_weapons", "sab_boat_c", "ifa3_comp_ace_main", "geistl_fow_main", "ifa3_comp_fow", "ifa3_comp_fow_ace_settings", "sab_compat_ace"]];

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["LIB_UK_Rifleman"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["LIB_UK_Sergeant", "LIB_UK_Corporal", "LIB_UK_Officer", "LIB_UK_Grenadier", "LIB_UK_Rifleman", "LIB_UK_Sniper", "LIB_UK_Engineer", "LIB_UK_AT_Soldier", "LIB_UK_LanceCorporal", "LIB_UK_Medic", "LIB_UK_Engineer"]];
_inf set [T_INF_TL, ["LIB_UK_Sergeant", "LIB_UK_Corporal", "LIB_UK_Officer", "LIB_UK_Grenadier", "LIB_UK_Rifleman", "LIB_UK_Sniper", "LIB_UK_Engineer", "LIB_UK_AT_Soldier", "LIB_UK_LanceCorporal", "LIB_UK_Medic", "LIB_UK_Engineer"]];
_inf set [T_INF_officer, ["LIB_UK_Sergeant", "LIB_UK_Corporal", "LIB_UK_Officer", "LIB_UK_Grenadier", "LIB_UK_Rifleman", "LIB_UK_Sniper", "LIB_UK_Engineer", "LIB_UK_AT_Soldier", "LIB_UK_LanceCorporal", "LIB_UK_Medic", "LIB_UK_Engineer"]];
/*
_inf set [T_INF_GL, [""]];
_inf set [T_INF_rifleman, [""]];
_inf set [T_INF_marksman, []];
_inf set [T_INF_sniper, [""]];
_inf set [T_INF_spotter, [""]];
_inf set [T_INF_exp, [""]];
_inf set [T_INF_ammo, [""]];
_inf set [T_INF_LAT, [""]];
_inf set [T_INF_AT, [""]];
_inf set [T_INF_AA, [""]];
_inf set [T_INF_LMG, [""]];
_inf set [T_INF_HMG, [""]];
_inf set [T_INF_medic, [""]];
_inf set [T_INF_engineer, [""]];
_inf set [T_INF_crew, [""]];
_inf set [T_INF_crew_heli, [""]];
_inf set [T_INF_pilot, [""]];
_inf set [T_INF_pilot_heli, [""]];
_inf set [T_INF_survivor, [""]];
_inf set [T_INF_unarmed, [""]];
*/

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
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_small,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicWeaponsBox_UK", "LIB_BasicAmmunitionBox_US"]];
_cargo set [T_CARGO_box_big,	["LIB_WeaponsBox_Big_SU"]];

//==== Groups ====
_group = +(tDefault select T_GROUP);


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];
_array set [T_NAME, "tWW2_UK_police"];

_array
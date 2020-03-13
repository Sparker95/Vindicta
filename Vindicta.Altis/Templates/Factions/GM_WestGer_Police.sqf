/*
West Germany Police templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tGM_WestGer_Police"];
_array set [T_DESCRIPTION, "West Germany Police, Global Mobilization - 80s."];
_array set [T_DISPLAY_NAME, "Cold War - West Germany Police"];
_array set [T_FACTION, T_FACTION_Police];
_array set [T_REQUIRED_ADDONS, ["gm_core"]];

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["gm_ge_pol_patrol_80_blk"]];		//Default infantry if nothing is found

_inf set [T_INF_SL, ["GM_WG_PoliceMan"]];
_inf set [T_INF_TL, ["GM_WG_PoliceMan"]];
_inf set [T_INF_officer, ["GM_WG_Officer"]];

/*
_inf set [T_INF_GL, ["B_GEN_Soldier_F"]];
_inf set [T_INF_rifleman, ["B_GEN_Soldier_F"]];
_inf set [T_INF_marksman, ["B_GEN_Soldier_F"]];
_inf set [T_INF_sniper, ["B_GEN_Soldier_F"]];
_inf set [T_INF_spotter, ["B_GEN_Soldier_F"]];
_inf set [T_INF_exp, ["B_GEN_Soldier_F"]];
_inf set [T_INF_ammo, ["B_GEN_Soldier_F"]];
_inf set [T_INF_LAT, ["B_GEN_Soldier_F"]];
_inf set [T_INF_AT, ["B_GEN_Soldier_F"]];
_inf set [T_INF_AA, ["B_GEN_Soldier_F"]];
_inf set [T_INF_LMG, ["B_GEN_Soldier_F"]];
_inf set [T_INF_HMG, ["B_GEN_Soldier_F"]];
_inf set [T_INF_medic, ["B_GEN_Soldier_F"]];
_inf set [T_INF_engineer, ["B_GEN_Soldier_F"]];
_inf set [T_INF_crew, ["B_GEN_Soldier_F"]];
_inf set [T_INF_crew_heli, ["B_GEN_Soldier_F"]];
_inf set [T_INF_pilot, ["B_GEN_Soldier_F"]];
_inf set [T_INF_pilot_heli, ["B_GEN_Soldier_F"]];
_inf set [T_INF_survivor, ["B_GEN_Soldier_F"]];
_inf set [T_INF_unarmed, ["B_GEN_Soldier_F"]];
*/

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["gm_ge_pol_typ1200"]];
_veh set [T_VEH_car_unarmed, ["gm_ge_pol_bicycle_01_grn", "gm_ge_pol_typ1200", "gm_ge_pol_typ1200", "gm_ge_pol_typ1200"]];

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
_cargo = [];

_cargo set [T_CARGO_default,	["gm_AmmoBox_wood_03_empty"]];
_cargo set [T_CARGO_box_small,	["gm_AmmoBox_wood_02_empty"]];
_cargo set [T_CARGO_box_medium,	["gm_AmmoBox_wood_04_empty"]];
_cargo set [T_CARGO_box_big,	["gm_AmmoBox_wood_03_empty"]];

//==== Groups ====
_group = +(tDefault select T_GROUP);


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array

/*
custom Altian Police templates for ARMA III (AAF2017)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tRHS_AAF_police"];
_array set [T_DESCRIPTION, "Uses RHS and AAF2017 mods."];
_array set [T_DISPLAY_NAME, "RHS AAF Police Custom"];
_array set [T_FACTION, T_FACTION_Police];
_array set [T_REQUIRED_ADDONS, [
								"FGN_AAF_Troops",	// AAF 2017
								"rhs_c_troops",		// RHS AFRF
								"rhsusf_c_troops",
								"rhssaf_c_troops",
								"rhsgref_c_troops"]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["FGN_AAF_Police_Policeman"]];					//Default infantry if nothing is found

_inf set [T_INF_officer, ["RHS_AAF_police_TL_SMG","RHS_AAF_police_TL_rifle","RHS_AAF_police_SMG","RHS_AAF_police_shotgun","RHS_AAF_police_rifle"]];
_inf set [T_INF_rifleman, ["RHS_AAF_police_SMG","RHS_AAF_police_shotgun","RHS_AAF_police_rifle"]];
_inf set [T_INF_SL, ["RHS_AAF_police_TL_SMG","RHS_AAF_police_TL_rifle","RHS_AAF_police_SMG","RHS_AAF_police_shotgun","RHS_AAF_police_rifle"]];
/*
_inf set [T_INF_TL, ["B_GEN_Soldier_F"]];
_inf set [T_INF_SL, ["B_GEN_Soldier_F"]];
_inf set [T_INF_GL, ["B_GEN_Soldier_F"]];
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
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_DEFAULT, ["FGN_AAF_Police_Offroad"]];
_veh set [T_VEH_car_unarmed, ["FGN_AAF_Police_Offroad"]];


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
_group set [T_GROUP_DEFAULT, [[[T_INF, T_INF_officer], [T_INF, T_INF_rifleman]]]];


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array

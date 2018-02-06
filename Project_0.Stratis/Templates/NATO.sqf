/*
NATO templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil]; //Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = [];
_inf set [T_INF_SIZE-1, nil]; //Make an array full of nil
_inf set [T_INF_default,  ["B_Soldier_F"]];		//Default infantry if nothing is found

_inf set [T_INF_SL, ["B_Soldier_SL_F"]];		//Squad leader
_inf set [T_INF_TL, ["B_Soldier_TL_F"]];		//Team leader
_inf set [T_INF_officer, ["B_officer_F"]];		//Officer
_inf set [T_INF_GL, ["B_Soldier_GL_F"]];		//GL rifleman
_inf set [T_INF_rifleman, ["B_Soldier_F"]];		//Rifleman
_inf set [T_INF_marksman, ["B_soldier_M_F"]];	//marksman
_inf set [T_INF_sniper, ["B_sniper_F"]];	//
_inf set [T_INF_spotter, ["B_spotter_F"]];	//
//_inf set [T_INF_exp, [""]];	//
_inf set [T_INF_LAT, ["B_soldier_LAT_F"]];	//
_inf set [T_INF_AT, ["B_soldier_AT_F"]];	//
_inf set [T_INF_AA, ["B_soldier_AA_F"]];	//
_inf set [T_INF_LMG, ["B_soldier_AR_F"]];	//
//_inf set [T_INF_HMG, [""]];	//
_inf set [T_INF_medic, ["B_medic_F"]];	//
_inf set [T_INF_engineer, ["B_engineer_F"]];	//
//_inf set [T_INF_ammo, ["B_soldier_A_F"]];	//
_inf set [T_INF_crew, ["B_crew_F"]];	//
_inf set [T_INF_pilot, ["B_Pilot_F"]];	//
_inf set [T_INF_pilot_heli, ["B_helicrew_F"]];	//
//_inf set [T_INF_survivor, [""]];	//
//_inf set [T_INF_unarmed, [""]];	//
//_inf set [T_INF_ , [""]];	//

//==== Vehicles ====
_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_default, ["B_MRAP_01_F"]];
_veh set [T_VEH_MRAP_unarmed, ["B_MRAP_01_F"]];
_veh set [T_VEH_MRAP_HMG, ["B_MRAP_01_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["B_MRAP_01_gmg_F"]];
_veh set [T_VEH_IFV, ["B_APC_Wheeled_01_cannon_F"]]; //Marshal IFV
_veh set [T_VEH_APC, ["B_APC_Tracked_01_rcws_F"]]; //Panther
_veh set [T_VEH_truck_inf, ["B_Truck_01_transport_F", "B_Truck_01_covered_F"]];
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_high, ["B_HMG_01_high_F"]];
_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]];

//==== Drones ====
_drone = [];
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["B_UAV_01_F"]];
_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];

//==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "Bus_InfSquad"]];
_group set [T_GROUP_inf_rifle_squad, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "Bus_InfSquad"]];
_group set [T_GROUP_inf_sniper_team, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_SniperTeam"]];
//_group set [T_GROUP_inf_sentry, [ [[T_INF, T_INF_medic, -1], [T_INF, T_INF_engineer, -1]] ] ]; //We can make custom group compositions in the templates too. gar_fnc_addNewGroup will handle it.
_group set [T_GROUP_inf_sentry, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSentry"]];


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_GROUP, _group];


_array
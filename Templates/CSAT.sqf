/*
CSAT templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil]; //Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = [];
_inf set [T_INF_SIZE-1, nil]; //Make an array full of nil
_inf set [T_INF_default,  ["O_Soldier_F"]];		//Default infantry if nothing is found

_inf set [T_INF_SL, ["O_Soldier_SL_F"]];		//Squad leader
_inf set [T_INF_TL, ["O_Soldier_TL_F"]];		//Team leader
_inf set [T_INF_officer, ["O_officer_F"]];		//Officer
_inf set [T_INF_GL, ["O_Soldier_GL_F"]];		//GL rifleman
_inf set [T_INF_rifleman, ["O_Soldier_F"]];		//Rifleman
_inf set [T_INF_marksman, ["O_soldier_M_F"]];	//marksman
_inf set [T_INF_sniper, ["O_sniper_F"]];	//
_inf set [T_INF_spotter, ["O_spotter_F"]];	//
_inf set [T_INF_LAT, ["O_soldier_LAT_F"]];	//
_inf set [T_INF_AT, ["O_soldier_AT_F"]];	//
_inf set [T_INF_AA, ["O_soldier_AA_F"]];	//
_inf set [T_INF_LMG, ["O_soldier_AR_F"]];	//
_inf set [T_INF_medic, ["O_medic_F"]];	//
_inf set [T_INF_engineer, ["O_engineer_F"]];	//
_inf set [T_INF_crew, ["O_crew_F"]];	//
_inf set [T_INF_pilot, ["O_Pilot_F"]];	//
_inf set [T_INF_pilot_heli, ["O_helicrew_F"]];	//

//==== Vehicles ====
_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_default, ["O_MRAP_02_F"]];
_veh set [T_VEH_MRAP_unarmed, ["O_MRAP_02_F"]];
_veh set [T_VEH_MRAP_HMG, ["O_MRAP_02_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["O_MRAP_02_gmg_F"]];
_veh set [T_VEH_IFV, ["O_APC_Tracked_02_cannon_F"]]; //BTR-K Kamysh
_veh set [T_VEH_APC, ["O_APC_Wheeled_02_rcws_F"]]; //Marid
_veh set [T_VEH_truck_inf, ["O_Truck_03_transport_F", "O_Truck_03_covered_F"]];
_veh set [T_VEH_stat_GMG_high, ["O_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_high, ["O_HMG_01_high_F"]];
_veh set [T_VEH_stat_mortar_light, ["O_Mortar_01_F"]];
_veh set [T_VEH_MBT, ["O_MBT_02_cannon_F"]];

//==== Drones ====
_drone = [];
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["O_UAV_01_F"]];
_drone set [T_DRONE_quadcopter, ["O_UAV_01_F"]];

//==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "Bus_InfSquad"]];
_group set [T_GROUP_inf_rifle_squad, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"]];
_group set [T_GROUP_inf_sniper_team, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_SniperTeam"]];
//_group set [T_GROUP_inf_sentry, [ [[T_INF, T_INF_medic, -1], [T_INF, T_INF_engineer, -1]] ] ]; //We can make custom group compositions in the templates too. gar_fnc_addNewGroup will handle it.
_group set [T_GROUP_inf_sentry, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSentry"]];


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_GROUP, _group];


_array
/*
POLICE templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tDSI"];
_array set [T_DESCRIPTION, "Dienst Speciale Interventies. Dutch SWAT."];
_array set [T_DISPLAY_NAME, "NLD DSI"];
_array set [T_FACTION, T_FACTION_Police];
_array set [T_REQUIRED_ADDONS, [
	"CUP_Weapons_M1014", //CUP Weapons
	"CUP_wheeledvehicles_Octaiva", //CUP Vehicles
	"CUP_Creatures_Military_USArmy", //CUP Units
	"FIR_Baseplate", //FIR AWS
	"C7NLD", //Colt C7NLD/C8NLD Weapons
	"bma3_bushmaster", //Bushmaster
	"NLD_Units_Main", //NLD Units (Main addon, contains all dependencies if you sub it.)
	"FIR_F16_F" //F16 Fighting falcon
]];

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_default, ["NLD_DSI_assault_mp5"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["NLD_DSI_TL"]];
_inf set [T_INF_TL, ["NLD_DSI_assault", "NLD_DSI_assault_mp5"]];
_inf set [T_INF_officer, ["NLD_DSI_assault", "NLD_DSI_assault_mp5", "NLD_DSI_Breach", "NLD_DSI_Medic"]];
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
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_DEFAULT, ["NLD_VWCrafter"]];
_veh set [T_VEH_car_unarmed, ["NLD_VWCrafter", "NLD_DSI_BMW", "NLD_DSI_Bearcat"]]; // , "B_GEN_Van_02_vehicle_F" -- not enough seats in this

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
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

_array

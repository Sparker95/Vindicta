/*
______ _   _ _____  ______ _____ _     _____ _____  _____ 
| ___ \ | | /  ___| | ___ \  _  | |   |_   _/  __ \|  ___|
| |_/ / | | \ `--.  | |_/ / | | | |     | | | /  \/| |__  
|    /| | | |`--. \ |  __/| | | | |     | | | |    |  __| 
| |\ \| |_| /\__/ / | |   \ \_/ / |_____| |_| \__/\| |___ 
\_| \_|\___/\____/  \_|    \___/\_____/\___/ \____/\____/                                                                  
*/

_array = [];

_array set [T_SIZE-1, nil];									

_array set [T_NAME, "tCUP_RUS_POLICE"]; // 							Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Generic local Russian police from CUP."]; // 			Template display description
_array set [T_DISPLAY_NAME, "CUP Russian Police"]; // 				Template display name
_array set [T_FACTION, T_FACTION_Police]; // 				Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["CUP_Creatures_People_Civil_Russia","CUP_Vehicles_Core"]]; // 	Addons required to play this template

/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["CUP_C_R_Policeman_02"]]; // = 0 Default if nothing found

_inf set [T_INF_SL, ["CUP_RUS_PoliceOfficer"]];
_inf set [T_INF_TL, ["CUP_RUS_PoliceOfficer"]];
_inf set [T_INF_officer, ["CUP_RUS_PoliceOfficer"]];


/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["CUP_C_S1203_Militia_CIV"]]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["CUP_C_S1203_Militia_CIV"]]; // = 1 – REQUIRED

/* Drone classes */
_drone = []; _drone resize T_DRONE_SIZE;

/* Cargo classes */
_cargo = +(tDefault select T_CARGO);

/* Group templates */
_group = +(tDefault select T_GROUP);

/* Vehicle descriptions */
/*(T_NAMES select T_VEH) set [T_VEH_car_unarmed, "Police S1203"];*/

/* Set arrays */
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array /* END OF TEMPLATE */
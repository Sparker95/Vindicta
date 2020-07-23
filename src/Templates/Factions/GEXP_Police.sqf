/*
 ______ _____ _     _____ _____  _____ 
| ___ \  _  | |   |_   _/  __ \|  ___|
| |_/ / | | | |     | | | /  \/| |__  
|  __/| | | | |     | | | |    |  __| 
| |   \ \_/ / |_____| |_| \__/\| |___ 
  \_|    \___/\_____/\___/ \____/\____/                                                                  
*/

_array = [];

_array set [T_SIZE-1, nil];									

_array set [T_NAME, "GEXP_POLICE"]; // 							Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Police units from the Gendarmarie Expansion addon."]; // 			Template display description
_array set [T_DISPLAY_NAME, "Gendarmarie Exp Police"]; // 				Template display name
_array set [T_FACTION, T_FACTION_Police]; // 				Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["Gendarmerie_Expansion"]]; // 	Addons required to play this template

/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["Patrol_Officer"]]; // = 0 Default if nothing found

_inf set [T_INF_SL, ["GEXP_ResponseOfficer"]];
_inf set [T_INF_TL, ["GEXP_ResponseOfficer"]];
_inf set [T_INF_officer, ["GEXP_PatrolOfficer","GEXP_Officer"]];


/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["Gendarmerie_RS4"]]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["Gendarmerie_WRC","Gendarmerie_Touereg","Gendarmerie_RangeRover_SVR","Gendarmerie_Merc_ClassX","Gendarmerie_GOLF6","Gendarmerie_M4","Gendarmerie_RS4"]]; // = 1 – REQUIRED



/* Drone classes */
_drone = []; _drone resize T_DRONE_SIZE;

/* Cargo classes */
_cargo = +(tDefault select T_CARGO);

/* Group templates */
_group = +(tDefault select T_GROUP);

/* Vehicle descriptions */
/*(T_NAMES select T_VEH) set [T_VEH_car_unarmed, "Police Car"];*/

/* Set arrays */
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array /* END OF TEMPLATE */
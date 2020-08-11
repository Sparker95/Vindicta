/*
 _    _           _     _____                                        ______     _ _          
| |  | |         | |   |  __ \                                       | ___ \   | (_)         
| |  | | ___  ___| |_  | |  \/ ___ _ __ _ __ ___   __ _ _ __  _   _  | |_/ /__ | |_  ___ ___ 
| |/\| |/ _ \/ __| __| | | __ / _ \ '__| '_ ` _ \ / _` | '_ \| | | | |  __/ _ \| | |/ __/ _ \
\  /\  /  __/\__ \ |_  | |_\ \  __/ |  | | | | | | (_| | | | | |_| | | | | (_) | | | (_|  __/
 \/  \/ \___||___/\__|  \____/\___|_|  |_| |_| |_|\__,_|_| |_|\__, | \_|  \___/|_|_|\___\___|
                                                               __/ |                         
                                                              |___/                                                                         
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tGM_WestGer_Police"]; // 							Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Cold war era, western Germany police."]; // 			Template display description
_array set [T_DISPLAY_NAME, "GM Western Germany Police"]; // 				Template display name
_array set [T_FACTION, T_FACTION_Police]; // 				Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["gm_core"]]; // 	Addons required to play this template

/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["gm_ge_pol_patrol_80_blk"]]; // = 0 Default if nothing found

_inf set [T_INF_SL, ["GM_WG_PoliceOfficer"]];
_inf set [T_INF_TL, ["GM_WG_PoliceOfficer"]];
_inf set [T_INF_officer, ["GM_WG_PatrolOfficer"]];


/* Vehicle classes */
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["gm_ge_pol_typ1200"]]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["gm_ge_pol_typ1200"]]; // = 1 – REQUIRED

/* Drone classes */
_drone = +(tDefault select T_DRONE);

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
_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tVN_US_Army_police"]; 									//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Vietman war US Army military police."]; 	//Template display description
_array set [T_DISPLAY_NAME, "VN DLC - US Military Police"]; 						//Template display name
_array set [T_FACTION, T_FACTION_Police]; 							//Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F", 
		"vn_weapons", 
		"vn_data_f"
		]]; 				//Addons required to play this template

//==== API ====

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 					//Make an array full of nil
_inf set [T_INF_default, ["vn_b_men_army_22"]];	//Default infantry if nothing is found

_inf set [T_INF_SL, ["vn_b_men_army_22"]];
_inf set [T_INF_TL, ["vn_b_men_army_22"]];
_inf set [T_INF_officer, ["vn_b_men_army_22"]];

//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_DEFAULT, ["vn_b_wheeled_m151_01_mp"]];
_veh set [T_VEH_car_unarmed, ["vn_b_wheeled_m151_02_mp", "vn_b_wheeled_m151_01_mp"]];

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== API ====
_api = []; _api resize T_API_SIZE;
_api set [T_API_SIZE-1, nil]; 										//Make an array full of nil
_api set [T_API_fnc_VEH_siren, {}];

//==== Arrays ====
_array set [T_API, _api];
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array
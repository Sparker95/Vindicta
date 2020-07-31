_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tExpPolice"]; 									//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Expansion police. Requires Expansion mod police."]; 	//Template display description
_array set [T_DISPLAY_NAME, "Expansion Police"]; 						//Template display name
_array set [T_FACTION, T_FACTION_Police]; 							//Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["Expansion_Mod_Police"]]; 				//Addons required to play this template



_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["Expansion_Mod_Police_Rookie"]]; 

_inf set [T_INF_SL, ["Expansion_Mod_Police_Sergeant"]];
_inf set [T_INF_TL, ["Expansion_Mod_Police_Corporal"]];
_inf set [T_INF_officer, ["Expansion_Mod_Police_Corporal", "Expansion_Mod_Police_Officer", "Expansion_Mod_Police_Rookie", "Expansion_Mod_Police_Detective1", "Expansion_Mod_Police_Detective2"]];



_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["EM_Police_Civic"]]; 

_veh set [T_VEH_car_unarmed, ["EM_Police_Civic", "EM_Police_CrownVic", "EM_Police_Explorer", "EM_Police_Explorer_UM", "EM_Police_BMWM5", "EM_Police_Raptor", "EM_Police_Raptor_UM", "EM_Police_Savana", "EM_Police_Taurus", "EM_Police_Taurus_UM", "EM_Police_BMWX6_UM", "EM_Police_BMWX6"]]; // = 1 – REQUIRED


_drone = []; _drone resize T_DRONE_SIZE;


_cargo = +(tDefault select T_CARGO);


_group = +(tDefault select T_GROUP);




_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array 
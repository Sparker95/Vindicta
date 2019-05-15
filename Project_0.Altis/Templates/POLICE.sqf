/*
NATO templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = [];
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["B_GEN_Soldier_F"]];					//Default infantry if nothing is found

_inf set [T_INF_default, ["B_Soldier_F"]];
_inf set [T_INF_officer, ["B_Commander_F"]];
_inf set [T_INF_SL, ["B_Dwarden_F"]];

//==== Set arrays ====
_array set [T_INF, _inf];

_array // End template

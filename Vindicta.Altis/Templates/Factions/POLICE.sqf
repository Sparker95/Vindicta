/*
██████╗  ██████╗ ██╗     ██╗ ██████╗███████╗
██╔══██╗██╔═══██╗██║     ██║██╔════╝██╔════╝
██████╔╝██║   ██║██║     ██║██║     █████╗  
██╔═══╝ ██║   ██║██║     ██║██║     ██╔══╝  
██║     ╚██████╔╝███████╗██║╚██████╗███████╗
╚═╝      ╚═════╝ ╚══════╝╚═╝ ╚═════╝╚══════╝
http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=Police

Updated: March 2020 by Marvis
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tPolice"]; // 												Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Vanilla police. Made by MatrikSky."]; // 			Template display description
_array set [T_DISPLAY_NAME, "Arma 3 Police"]; // 								Template display name
_array set [T_FACTION, T_FACTION_Police]; // 									Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F"]]; // 						Addons required to play this template

/* API */
_api = []; _api resize T_API_SIZE;
_api set [T_API_SIZE-1, nil]; 								//Make an array full of nil
_api set [T_API_fnc_VEH_siren, {
	params ["_vehicle", "_siren"];
	if(typeOf _vehicle in ["B_GEN_Offroad_01_gen_F", "B_GEN_Offroad_01_comms_F", "B_GEN_Offroad_01_covered_F", "B_GEN_Van_02_transport_F"]) then {
		private _beacon = if(typeOf _vehicle in ["B_GEN_Van_02_transport_F"]) then { 'lights_em_hide' } else { 'beaconsstart' };
		if(_siren) then {
			[_vehicle, 'CustomSoundController1', 1, 0.2] remoteExec ['BIS_fnc_setCustomSoundController'];
			_vehicle animate [_beacon, 1, true];
		} else {
			[_vehicle, 'CustomSoundController1', 0, 0.4] remoteExec ['BIS_fnc_setCustomSoundController'];
			_vehicle animate [_beacon, 0, true];
		};
	};
}];

/* Infantry unit classes */
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_default, ["B_GEN_Soldier_F"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["Arma3_POLICE_1", "Arma3_POLICE_2", "Arma3_POLICE_3", "Arma3_POLICE_4", "Arma3_POLICE_5", "Arma3_POLICE_6", "Arma3_POLICE_7", "Arma3_POLICE_8", "Arma3_POLICE_9", "Arma3_POLICE_10"]];
_inf set [T_INF_TL, ["Arma3_POLICE_1", "Arma3_POLICE_2", "Arma3_POLICE_3", "Arma3_POLICE_4", "Arma3_POLICE_5", "Arma3_POLICE_6", "Arma3_POLICE_7", "Arma3_POLICE_8", "Arma3_POLICE_9", "Arma3_POLICE_10"]];
_inf set [T_INF_officer, ["Arma3_POLICE_1", "Arma3_POLICE_2", "Arma3_POLICE_3", "Arma3_POLICE_4", "Arma3_POLICE_5", "Arma3_POLICE_6", "Arma3_POLICE_7", "Arma3_POLICE_8", "Arma3_POLICE_9", "Arma3_POLICE_10"]];

/* Vehicle classes */
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["B_GEN_Offroad_01_gen_F"]];
_veh set [T_VEH_car_unarmed, ["B_GEN_Offroad_01_gen_F", "B_GEN_Offroad_01_comms_F", "B_GEN_Offroad_01_covered_F", "B_GEN_Van_02_transport_F"]]; // , "B_GEN_Van_02_vehicle_F" -- not enough seats in this

/* Drone classes */
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];

/* Cargo classes */
_cargo = +(tDefault select T_CARGO);

/* Group templates */
_group = +(tDefault select T_GROUP);

/* Set arrays */
_array set [T_API, _api];
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array /* END OF TEMPLATE */
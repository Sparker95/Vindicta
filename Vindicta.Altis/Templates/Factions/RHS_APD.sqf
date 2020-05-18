
// █████╗ ██████╗ ██████╗ 
//██╔══██╗██╔══██╗██╔══██╗
//███████║██████╔╝██║  ██║
//██╔══██║██╔═══╝ ██║  ██║
//██║  ██║██║     ██████╔╝
//╚═╝  ╚═╝╚═╝     ╚═════╝ 
//http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=APD

//Updated: March 2020 by Marvis


_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tRHS_APD"]; 														//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Altis Police Department. Uses RHS."]; 	//Template display description
_array set [T_DISPLAY_NAME, "RHS APD (USAF)"]; 											//Template display name
_array set [T_FACTION, T_FACTION_Police]; 												//Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, [
	"rhsusf_c_troops",			//RHSUSAF
	"demian2435_police_mod",	//Demian2535 Police Mod
	"Altis_PD"					//APD Uniforms
]]; 																					//Addons required to play this template

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 			//Make an array full of nil
_inf set [T_INF_default, ["APD_2"]];	//Default infantry if nothing is found

_inf set [T_INF_SL, ["RHS_police_1", 1, "RHS_police_2", 1, "RHS_police_3", 1, "RHS_police_4", 1, "RHS_police_5", 4, "RHS_police_6", 4, "RHS_police_7", 4, "RHS_police_8", 4, "RHS_police_9", 4, "RHS_police_10", 4]];
_inf set [T_INF_TL, ["RHS_police_1", 1, "RHS_police_2", 1, "RHS_police_3", 1, "RHS_police_4", 1, "RHS_police_5", 4, "RHS_police_6", 4, "RHS_police_7", 4, "RHS_police_8", 4, "RHS_police_9", 4, "RHS_police_10", 4]];
_inf set [T_INF_officer, ["RHS_police_officer", 0.3, "RHS_police_1", 1, "RHS_police_2", 1, "RHS_police_3", 1, "RHS_police_4", 1, "RHS_police_5", 4, "RHS_police_6", 4, "RHS_police_7", 4, "RHS_police_8", 4, "RHS_police_9", 4, "RHS_police_10", 4]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["demian2435_police_offroad"]];
_veh set [T_VEH_car_unarmed, ["demian2435_police_car", 2, "demian2435_police_Hatchback", 2, "demian2435_police_offroad", 4]];

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = +(tDefault select T_GROUP);


//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array

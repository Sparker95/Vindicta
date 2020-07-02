_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tWW2_Sov_police"]; 											//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "WW2 Soviet NKWD units. 1939-1945. Made by MatrikSky"]; 	//Template display description
_array set [T_DISPLAY_NAME, "WW2 NKWD"]; 											//Template display name
_array set [T_FACTION, T_FACTION_Police]; 											//Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F", 
		"IFA3_Core",
		"IFA3_COMP_ACE_main",
		"IFA3_FOW_Compat",
		"LIB_core",
		"GEISTL_MAIN",
		"GEISTL_FOW_MAIN",
		"fow_main",
		"sab_boat_c",
		"sab_compat_ace",
		"I44_Buildings"
		]]; 																		//Addons required to play this template

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil]; 							//Make an array full of nil
_inf set [T_INF_default, ["LIB_SOV_rifleman"]];			//Default infantry if nothing is found

_inf set [T_INF_SL, ["WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2"]];
_inf set [T_INF_TL, ["WW2_Sov_police_medic", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2"]];
_inf set [T_INF_officer, ["WW2_Sov_police_officer", "WW2_Sov_police_medic", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2", "WW2_Sov_police_rifleman", "WW2_Sov_police_rifleman_2", "WW2_Sov_police_rifleman_3", "WW2_Sov_police_rifleman_3", "WW2_Sov_police_rifleman_3"]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_DEFAULT, ["LIB_GazM1_SOV"]];
_veh set [T_VEH_car_unarmed, ["LIB_GazM1_SOV", "LIB_GazM1_SOV_camo_sand", "LIB_Willys_MB", "LIB_Willys_MB_Hood"]];

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_AmmoCrate_Mortar_SU"]];
_cargo set [T_CARGO_box_small,	["LIB_AmmoCrate_Mortar_SU", "LIB_BasicWeaponsBox_SU"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicAmmunitionBox_SU", "LIB_Lone_Big_Box"]];

//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array
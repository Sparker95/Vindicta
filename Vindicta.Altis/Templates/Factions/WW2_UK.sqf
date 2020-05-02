
//██╗   ██╗██╗  ██╗
//██║   ██║██║ ██╔╝
//██║   ██║█████╔╝ 
//██║   ██║██╔═██╗ 
//╚██████╔╝██║  ██╗
// ╚═════╝ ╚═╝  ╚═╝
//http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=UK

//Updated: March 2020 by Marvis

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tWW2_UK"]; 											//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "WW2 UK units. 1939-1945. Made by MatrikSky"]; 	//Template display description
_array set [T_DISPLAY_NAME, "WW2 UK"]; 										//Template display name
_array set [T_FACTION, T_FACTION_Military]; 								//Faction type: police, T_FACTION_military, T_FACTION_Police
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
		]]; 																//Addons required to play this template

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 					//Make an array full of nil
_inf set [T_INF_default, ["LIB_UK_Rifleman"]];	//Default infantry if nothing is found

_inf set [T_INF_SL, ["WW2_UK_SL"]];
_inf set [T_INF_TL, ["WW2_UK_TL"]];
_inf set [T_INF_officer, ["WW2_UK_officer"]];
_inf set [T_INF_GL, ["WW2_UK_GL"]];
_inf set [T_INF_rifleman, ["WW2_UK_rifleman", "WW2_UK_rifleman_2", "WW2_UK_rifleman_3"]];
_inf set [T_INF_marksman, ["WW2_UK_marksman"]];
_inf set [T_INF_sniper, ["WW2_UK_sniper"]];
_inf set [T_INF_spotter, ["WW2_UK_spotter"]];
_inf set [T_INF_exp, ["WW2_UK_explosives"]];
_inf set [T_INF_ammo, ["WW2_UK_ammo"]];
_inf set [T_INF_LAT, ["WW2_UK_LAT"]];
_inf set [T_INF_AT, ["WW2_UK_AT", "WW2_UK_AT_2"]];
_inf set [T_INF_LMG, ["WW2_UK_LMG"]];
_inf set [T_INF_HMG, ["WW2_UK_HMG"]];
_inf set [T_INF_medic, ["WW2_UK_medic"]];
_inf set [T_INF_engineer, ["WW2_UK_engineer"]];
_inf set [T_INF_crew, ["WW2_UK_crew"]];
_inf set [T_INF_pilot, ["WW2_UK_pilot"]];
_inf set [T_INF_survivor, ["WW2_UK_unarmed"]];
_inf set [T_INF_unarmed, ["WW2_UK_unarmed"]];
_inf set [T_INF_crew_heli, ["WW2_UK_unarmed"]];
_inf set [T_INF_AA, ["WW2_UK_unarmed"]];
_inf set [T_INF_pilot_heli, ["WW2_UK_unarmed"]];


//==== Recon ====
_inf set [T_INF_recon_TL, ["WW2_UK_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["WW2_UK_recon_rifleman", "WW2_UK_recon_rifleman_2", "WW2_UK_recon_rifleman", "WW2_UK_recon_rifleman_2", "WW2_UK_recon_rifleman_3", "WW2_UK_recon_rifleman_4", "WW2_UK_recon_rifleman_5","WW2_UK_recon_rifleman", "WW2_UK_recon_rifleman_2", "WW2_UK_recon_rifleman_3", "WW2_UK_recon_rifleman_4", "WW2_UK_recon_rifleman_5", "WW2_UK_recon_rifleman_6", "WW2_UK_recon_rifleman_7"]];
_inf set [T_INF_recon_medic, ["WW2_UK_recon_medic"]];
_inf set [T_INF_recon_exp, ["WW2_UK_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["WW2_UK_recon_AT"]];
_inf set [T_INF_recon_marksman, ["WW2_UK_recon_marksman"]];
_inf set [T_INF_recon_JTAC, ["WW2_UK_recon_JTAC"]];

//==== Drivers ====
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["LIB_UK_Willys_MB"]];

_veh set [T_VEH_car_unarmed, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];
_veh set [T_VEH_car_armed, ["LIB_UK_Willys_MB_M1919"]];

_veh set [T_VEH_MRAP_unarmed, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];
_veh set [T_VEH_MRAP_HMG, ["LIB_UK_Willys_MB_M1919"]];
_veh set [T_VEH_MRAP_GMG, ["LIB_usa_M3_Scout_FFV"]];

_veh set [T_VEH_IFV, ["fow_v_universalCarrier", "LIB_UK_M3_Halftrack", "LIB_SdKfz251", "LIB_SdKfz251_FFV"]];
_veh set [T_VEH_APC, ["fow_v_universalCarrier", "LIB_UK_M3_Halftrack", "LIB_SdKfz251", "LIB_SdKfz251_FFV"]];
_veh set [T_VEH_MBT, ["fow_v_cromwell_uk", "LIB_Churchill_Mk7", "LIB_Churchill_Mk7_AVRE", "LIB_Churchill_Mk7_Crocodile", "LIB_Crusader_Mk3", "LIB_M4A3_75"]];
_veh set [T_VEH_MRLS, ["LIB_Nebelwerfer41", "LIB_Nebelwerfer41_Camo", "LIB_Nebelwerfer41_Gelbbraun"]];
_veh set [T_VEH_SPA, ["LIB_Churchill_Mk7_Howitzer"]];
_veh set [T_VEH_SPAA, ["LIB_Crusader_Mk1AA"]];

_veh set [T_VEH_stat_HMG_high, ["LIB_GER_SearchLight", "LIB_M1919_m2", "fow_w_vickers_uk"]];
_veh set [T_VEH_stat_GMG_high, ["LIB_GER_SearchLight", "LIB_M1919_m2", "fow_w_vickers_uk"]];
_veh set [T_VEH_stat_HMG_low, ["LIB_M1919_m2", "fow_w_vickers_uk"]];
_veh set [T_VEH_stat_GMG_low, ["LIB_M1919_m2", "fow_w_vickers_uk"]];
_veh set [T_VEH_stat_AA, ["sab_static_aa", "sab_small_static_2xaa", "sab_small_static_aa"]];
_veh set [T_VEH_stat_AT, ["fow_w_6Pounder_uk"]];

_veh set [T_VEH_stat_mortar_light, ["LIB_m2_60"]];
_veh set [T_VEH_stat_mortar_heavy, ["LIB_m2_60"]];

_veh set [T_VEH_heli_light, []];
_veh set [T_VEH_heli_heavy, []];
_veh set [T_VEH_heli_cargo, []];
_veh set [T_VEH_heli_attack, []];

_veh set [T_VEH_plane_attack, ["LIB_RAF_P39"]];
_veh set [T_VEH_plane_fighter, ["sab_ca12bo", "LIB_RAF_P39", "sab_gladiator", "sab_mb5"]];
_veh set [T_VEH_plane_cargo, ["LIB_C47_RAF"]];
_veh set [T_VEH_plane_unarmed, ["LIB_C47_RAF"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["sab_boat_sreighter_o"]];
_veh set [T_VEH_boat_armed, ["LIB_UK_LCA", "LIB_UK_LCI", "sab_boat_destroyer_rn", "sab_boat_subchaser_rn"]];

_veh set [T_VEH_personal, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];

_veh set [T_VEH_truck_inf, ["LIB_AustinK5_Tent", "LIB_AustinK5_Open"]];
_veh set [T_VEH_truck_cargo, ["LIB_AustinK5_Tent", "LIB_AustinK5_Open"]];
_veh set [T_VEH_truck_ammo, ["LIB_AustinK5_Ammo", "LIB_US_GMC_Ammo"]];
_veh set [T_VEH_truck_repair, ["LIB_US_GMC_Parm"]];
_veh set [T_VEH_truck_medical , ["LIB_UK_Willys_MB_Ambulance", "LIB_US_GMC_Ambulance"]];
_veh set [T_VEH_truck_fuel, ["LIB_US_GMC_Fuel"]];

//_veh set [T_VEH_submarine, [""]];

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargos ====
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_small,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicWeaponsBox_UK", "LIB_BasicAmmunitionBox_US"]];
_cargo set [T_CARGO_box_big,	["LIB_WeaponsBox_Big_SU"]];

//==== Groups ====
_group = +(tDefault select T_GROUP);
_group set [T_GROUP_inf_AA_team, [
	[
		T_INF_TL,
		T_INF_AT,
		T_INF_AT,
		T_INF_ammo
	] apply { [T_INF, _x] }
]];

//==== Vehicle Descriptions ==== (Broken waiting for fix)
//(T_NAMES select T_VEH) set [T_VEH_car_unarmed, "Unarmed Car"]; //					= 1 Car like a Prowler or UAZ
//(T_NAMES select T_VEH) set [T_VEH_car_armed, "Armed Car"]; //						= 2 Car with any kind of mounted weapon
//(T_NAMES select T_VEH) set [T_VEH_MRAP_unarmed, "Unarmed Scout Car"]; //			= 3 MRAP
//(T_NAMES select T_VEH) set [T_VEH_MRAP_HMG, "Armed Scout Car"]; //				= 4 MRAP with a mounted HMG gun
//(T_NAMES select T_VEH) set [T_VEH_MRAP_GMG, "Heavy Armed Car"]; //				= 5 MRAP with a mounted GMG gun
//(T_NAMES select T_VEH) set [T_VEH_MBT, "Light-Medium-Heavy Tank"]; //				= 8 Main Battle Tank

//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array
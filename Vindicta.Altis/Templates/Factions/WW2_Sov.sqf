_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tWW2_Sov"]; 												//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "WW2 Soviet units. 1939-1945. Made by MatrikSky"]; 	//Template display description
_array set [T_DISPLAY_NAME, "WW2 Red Army"]; 									//Template display name
_array set [T_FACTION, T_FACTION_Military]; 									//Faction type: police, T_FACTION_military, T_FACTION_Police
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
		]]; 																	//Addons required to play this template

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_default, ["LIB_SOV_rifleman"]];				//Default infantry if nothing is found

_inf set [T_INF_SL, ["WW2_Sov_SL"]];
_inf set [T_INF_TL, ["WW2_Sov_TL"]];
_inf set [T_INF_officer, ["WW2_Sov_officer"]];
_inf set [T_INF_GL, ["WW2_Sov_GL"]];
_inf set [T_INF_rifleman, ["WW2_Sov_rifleman", "WW2_Sov_rifleman_2", "WW2_Sov_rifleman_3"]];
_inf set [T_INF_sniper, ["WW2_Sov_sniper"]];
_inf set [T_INF_marksman, ["WW2_Sov_marksman"]];
_inf set [T_INF_exp, ["WW2_Sov_explosives"]];
_inf set [T_INF_LAT, ["WW2_Sov_LAT"]];
_inf set [T_INF_AT, ["WW2_Sov_AT", "WW2_Sov_AT_2"]];
_inf set [T_INF_LMG, ["WW2_Sov_LMG"]];
_inf set [T_INF_HMG, ["WW2_Sov_HMG"]];
_inf set [T_INF_medic, ["WW2_Sov_medic"]];
_inf set [T_INF_crew, ["WW2_Sov_crew"]];
_inf set [T_INF_pilot, ["WW2_Sov_pilot"]];
_inf set [T_INF_engineer, ["WW2_Sov_engineer"]];
_inf set [T_INF_spotter, ["WW2_Sov_spotter"]];
_inf set [T_INF_ammo, ["WW2_Sov_ammo"]];
_inf set [T_INF_survivor, ["WW2_Sov_unarmed"]];
_inf set [T_INF_unarmed, ["WW2_Sov_unarmed"]];
_inf set [T_INF_pilot_heli, ["WW2_Sov_unarmed"]];
_inf set [T_INF_crew_heli, ["WW2_Sov_unarmed"]];
_inf set [T_INF_AA, ["WW2_Sov_unarmed"]];

//==== Recon ====
_inf set [T_INF_recon_TL, ["WW2_Sov_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["WW2_Sov_recon_rifleman", "WW2_Sov_recon_rifleman_2", "WW2_Sov_recon_rifleman_3"]];
_inf set [T_INF_recon_medic, ["WW2_Sov_recon_medic"]];
_inf set [T_INF_recon_exp, ["WW2_Sov_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["WW2_Sov_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["WW2_Sov_recon_marksman"]];
_inf set [T_INF_recon_JTAC, ["WW2_Sov_recon_JTAC"]];

//==== Drivers ====
//_inf set [T_INF_diver_TL, [""]];
//_inf set [T_INF_diver_rifleman, [""]];
//_inf set [T_INF_diver_exp, [""]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["LIB_GazM1_SOV"]];

_veh set [T_VEH_car_unarmed, ["LIB_GazM1_SOV", "LIB_GazM1_SOV_camo_sand", "LIB_Willys_MB", "LIB_Willys_MB_Hood"]];
_veh set [T_VEH_car_armed, ["LIB_GazM1_SOV", "LIB_GazM1_SOV_camo_sand", "LIB_Willys_MB", "LIB_Willys_MB_Hood"]];

_veh set [T_VEH_MRAP_unarmed, ["LIB_GazM1_SOV", "LIB_GazM1_SOV_camo_sand", "LIB_Willys_MB", "LIB_Willys_MB_Hood"]];
_veh set [T_VEH_MRAP_HMG, ["LIB_sov_M3_Scout_IFL"]];
_veh set [T_VEH_MRAP_GMG, ["LIB_sov_M3_Scout_IFL"]];

_veh set [T_VEH_IFV, ["LIB_SdKfz251_captured_FFV"]];
_veh set [T_VEH_APC, ["GLIB_SOV_M3_Halftrack", "LIB_SdKfz251_captured", "LIB_SdKfz251_captured_FFV", "Lib_sov_SdKfz251IFL", "Lib_sov_SdKfz251FFV"]];
_veh set [T_VEH_MBT, ["LIB_SOV_StuG_III_G_Tarn", "LIB_SOV_PzKpfwIV_H_Camo", "LIB_SOV_PzKpfwIV_H_Kaki", "LIB_sov_M4A2an_Sherman", "LIB_SOV_JS2_Kaki", "LIB_SOV_SU85_Kaki", "LIB_SOV_JS2_Kaki", "LIB_SOV_SU85_Kaki", "LIB_sov_T3485_Kaki", "LIB_sov_T3485_Kaki", "LIB_sov_T3485_Kaki", "LIB_sov_T3476_Kaki", "LIB_sov_T3476_Kaki", "LIB_sov_T3476_Kaki", "LIB_sov_T3476_Kaki"]];
_veh set [T_VEH_MRLS, ["LIB_US6_BM13"]];
_veh set [T_VEH_SPA, ["LIB_US6_BM13"]];
_veh set [T_VEH_SPAA, ["LIB_zis5v_61K"]];

_veh set [T_VEH_stat_HMG_high, ["LIB_SU_SearchLight", "lib_maxim_m30_base"]];
_veh set [T_VEH_stat_GMG_high, ["LIB_SU_SearchLight", "lib_maxim_m30_base"]];
_veh set [T_VEH_stat_HMG_low, ["lib_maxim_m30_base"]];
_veh set [T_VEH_stat_GMG_low, ["lib_maxim_m30_base"]];
_veh set [T_VEH_stat_AA, ["sab_static_aa", "sab_small_static_2xaa", "sab_small_static_aa", "LIB_61k", "LIB_61k", "LIB_61k"]];
_veh set [T_VEH_stat_AT, ["LIB_Zis3"]];

_veh set [T_VEH_stat_mortar_light, ["LIB_BM37_ACE"]];
_veh set [T_VEH_stat_mortar_heavy, ["LIB_BM37_ACE"]];

_veh set [T_VEH_heli_light, []];
_veh set [T_VEH_heli_heavy, []];
_veh set [T_VEH_heli_cargo, []];
_veh set [T_VEH_heli_attack, []];

_veh set [T_VEH_plane_attack, ["LIB_P39", "LIB_RA_P39_3", "LIB_RA_P39_2", "LIB_Pe2", "sab_tusb2", "sab_il2"]];
_veh set [T_VEH_plane_fighter, ["LIB_P39", "LIB_RA_P39_3", "LIB_RA_P39_2", "sab_i16", "sab_la5", "sab_la5_2"]];
_veh set [T_VEH_plane_cargo, ["LIB_Li2"]];
_veh set [T_VEH_plane_unarmed, ["LIB_Li2"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["sab_boat_sreighter_i"]];
_veh set [T_VEH_boat_armed, ["sab_boat_destroyer_i", "sab_boat_torpedo_i"]];

_veh set [T_VEH_personal, ["LIB_GazM1_SOV", "LIB_GazM1_SOV_camo_sand"]];

_veh set [T_VEH_truck_inf, ["LIB_SOV_ZiS5V_RKKA", "LIB_SOV_ZiS5V_RKKA", "LIB_SOV_ZiS5V_RKKA", "LIB_SOV_ZiS5V_RKKA", "LIB_SOV_ZiS5V_RKKA", "LIB_sov_GMC_CCKW353cf_Stud2zelOpen", "LIB_sov_GMC_CCKW353cf_Stud2zelTent"]];
_veh set [T_VEH_truck_cargo, ["LIB_US6_Tent_Cargo", "LIB_US6_Open_Cargo"]];
_veh set [T_VEH_truck_ammo, ["LIB_sov_GMC_CCKW353cf_Stud2zelAmmo"]];
_veh set [T_VEH_truck_repair, ["LIB_SOV_ZiS6Parm_RKKA"]];
_veh set [T_VEH_truck_medical , ["LIB_SdKfz251IFL_medical", "LIB_Willys_MB_Ambulance", "LIB_sov_GMC_CCKW353cf_Stud2zelOpen_Medical", "LIB_sov_GMC_CCKW353cf_Stud2zelTent_Medical", "LIB_ZiS5v_Med", "LIB_ZiS5v_Med", "LIB_ZiS5v_Med", "LIB_ZiS5v_Med", "LIB_ZiS5v_Med"]];
_veh set [T_VEH_truck_fuel, ["LIB_ZiS5v_Fuel"]];

_veh set [T_VEH_submarine, ["sab_boat_u7_i"]];

//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_AmmoCrate_Mortar_SU"]];
_cargo set [T_CARGO_box_small,	["LIB_AmmoCrate_Mortar_SU", "LIB_BasicWeaponsBox_SU"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicAmmunitionBox_SU", "LIB_Lone_Big_Box"]];
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

//==== Vehicle Description ==== (Broken waiting for fix)
//(T_NAMES select T_VEH) set [T_VEH_car_unarmed, "Unarmed Car"]; //					= 1 Car like a Prowler or UAZ
//(T_NAMES select T_VEH) set [T_VEH_car_armed, "Unarmed Car"]; //					= 2 Car with any kind of mounted weapon
//(T_NAMES select T_VEH) set [T_VEH_MRAP_unarmed, "Unarmed Scout Car"]; //			= 3 MRAP
//(T_NAMES select T_VEH) set [T_VEH_MRAP_HMG, "Armed Scout Car"]; //				= 4 MRAP with a mounted HMG gun
//(T_NAMES select T_VEH) set [T_VEH_MRAP_GMG, "Heavy Armed Car"]; //				= 5 MRAP with a mounted GMG gun
//(T_NAMES select T_VEH) set [T_VEH_MBT, "Medium-Heavy Tank"]; //					= 8 Main Battle Tank
//(T_NAMES select T_VEH) set [T_VEH_SPA, "MRLS"]; //								= 10 Self-Propelled Artillery

//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array
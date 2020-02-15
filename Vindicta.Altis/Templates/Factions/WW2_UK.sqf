_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tWW2_UK"];
_array set [T_DESCRIPTION, "The British Armed Forces also known as Her Majesty's Armed Forces, are the military services responsible for the defense of the United Kingdom and the Crown dependencies. Consisting of allied and captured axis equipment from 1939 to 1945, mainly using USA backed weaponry."];
_array set [T_DISPLAY_NAME, "WW2 - British Armed Forces"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, ["ww2_assets_c_characters_core_c", "lib_weapons", "geistl_main", "fow_weapons", "sab_boat_c", "ifa3_comp_ace_main", "geistl_fow_main", "ifa3_comp_fow", "ifa3_comp_fow_ace_settings", "sab_compat_ace"]];

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["LIB_UK_Rifleman"]];

_inf set [T_INF_SL, ["LIB_UK_Sergeant"]];
_inf set [T_INF_TL, ["LIB_UK_Corporal"]];
_inf set [T_INF_officer, ["LIB_UK_Officer"]];
_inf set [T_INF_GL, ["LIB_UK_Grenadier"]];
_inf set [T_INF_rifleman, ["LIB_UK_Rifleman"]];
_inf set [T_INF_marksman, ["LIB_UK_Sniper"]];
_inf set [T_INF_sniper, ["LIB_UK_Sniper"]];
_inf set [T_INF_spotter, ["LIB_UK_Rifleman"]];
_inf set [T_INF_exp, ["LIB_UK_Engineer"]];
_inf set [T_INF_ammo, ["LIB_UK_Rifleman"]];
_inf set [T_INF_LAT, ["LIB_UK_AT_Soldier"]];
_inf set [T_INF_AT, ["LIB_UK_AT_Soldier"]];
_inf set [T_INF_LMG, ["LIB_UK_LanceCorporal"]];
_inf set [T_INF_HMG, ["LIB_UK_LanceCorporal"]];
_inf set [T_INF_medic, ["LIB_UK_Medic"]];
_inf set [T_INF_engineer, ["LIB_UK_Engineer"]];
_inf set [T_INF_crew, ["LIB_UK_Tank_Commander", "LIB_UK_Tank_Crew"]];
_inf set [T_INF_pilot, ["LIB_US_Pilot"]];
/*_inf set [T_INF_crew_heli, [""]];
_inf set [T_INF_AA, [""]];
_inf set [T_INF_pilot_heli, [""]];
_inf set [T_INF_survivor, [""]];
_inf set [T_INF_unarmed, [""]];*/

// Recon
_inf set [T_INF_recon_TL, ["LIB_UK_Para_Officer", "LIB_UK_Para_Sergeant", "LIB_UK_Para_Corporal"]];
_inf set [T_INF_recon_rifleman, ["LIB_UK_Para_Rifleman", "LIB_UK_Para_Grenadier", "LIB_UK_Para_LanceCorporal"]];
_inf set [T_INF_recon_medic, ["LIB_UK_Para_Medic"]];
_inf set [T_INF_recon_exp, ["LIB_UK_Para_Engineer"]];
_inf set [T_INF_recon_LAT, ["LIB_UK_Para_AT_Soldier"]];
_inf set [T_INF_recon_marksman, ["LIB_UK_Para_Sniper"]];
_inf set [T_INF_recon_JTAC, ["LIB_UK_Para_Radioman"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["LIB_UK_Willys_MB"]];

_veh set [T_VEH_car_unarmed, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];
_veh set [T_VEH_car_armed, ["LIB_UK_Willys_MB_M1919", "LIB_usa_M3_Scout_FFV"]];

_veh set [T_VEH_MRAP_unarmed, ["LIB_UK_Willys_MB", "LIB_UK_Willys_MB_Hood"]];
_veh set [T_VEH_MRAP_HMG, ["fow_v_universalCarrier", "LIB_UK_M3_Halftrack"]];
_veh set [T_VEH_MRAP_GMG, ["fow_v_universalCarrier", "LIB_UK_M3_Halftrack"]];

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

//_veh set [T_VEH_heli_light, [""]];
//_veh set [T_VEH_heli_heavy, [""]];
//_veh set [T_VEH_heli_cargo, [""]];
//_veh set [T_VEH_heli_attack, [""]];

_veh set [T_VEH_plane_attack, ["LIB_RAF_P39"]];
_veh set [T_VEH_plane_fighter, ["sab_ca12bo", "LIB_RAF_P39", "sab_gladiator", "sab_mb5"]];
_veh set [T_VEH_plane_cargo, ["LIB_C47_RAF"]];
_veh set [T_VEH_plane_unarmed, ["LIB_HORSA_RAF", "LIB_MKI_HADRIAN", "LIB_MKI_HADRIAN_raf2", "LIB_MKI_HADRIAN_raf3"]];
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
//_drone set [T_DRONE_DEFAULT, [""]];
/*
_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]];
_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];
_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]];
_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]];
_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];
*/
//==== Cargo ====
_cargo = [];

_cargo set [T_CARGO_default,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_small,	["LIB_BasicWeaponsBox_US"]];
_cargo set [T_CARGO_box_medium,	["LIB_BasicWeaponsBox_UK", "LIB_BasicAmmunitionBox_US"]];
_cargo set [T_CARGO_box_big,	["LIB_WeaponsBox_Big_SU"]];

//==== Groups ====
_group = +(tDefault select T_GROUP);


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];
_array set [T_NAME, "tWW2_UK"];


_array 
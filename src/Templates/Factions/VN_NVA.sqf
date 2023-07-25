_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tVN_NVA"];
_array set [T_DESCRIPTION, "Vietman war NVA made using content from S.O.G. Prairie Fire DLC."];
_array set [T_DISPLAY_NAME, "SOG DLC - NVA"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F", 
		"vn_weapons", 
		"vn_data_f"
		]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["vn_o_men_nva_02"]];							//Default infantry if nothing is found

_inf set [T_INF_SL, ["vn_o_men_nva_04"]];
_inf set [T_INF_TL, ["vn_o_men_nva_13"]];
_inf set [T_INF_officer, ["vn_o_men_nva_01"]];
_inf set [T_INF_GL, ["vn_o_men_nva_07"]];
_inf set [T_INF_rifleman, ["vn_o_men_nva_04", "vn_o_men_nva_49", "vn_o_men_nva_06", "vn_o_men_nva_02", "vn_o_men_nva_12"]];
_inf set [T_INF_marksman, ["vn_o_men_nva_10"]];
_inf set [T_INF_sniper, ["vn_o_men_nva_47"]];
_inf set [T_INF_spotter, ["vn_o_men_nva_04", "vn_o_men_nva_49", "vn_o_men_nva_06", "vn_o_men_nva_02", "vn_o_men_nva_12"]];
_inf set [T_INF_exp, ["vn_o_men_nva_09"]];
_inf set [T_INF_ammo, ["vn_o_men_nva_04", "vn_o_men_nva_49", "vn_o_men_nva_06", "vn_o_men_nva_02", "vn_o_men_nva_12"]];
_inf set [T_INF_LAT, ["vn_o_men_nva_14"]];
_inf set [T_INF_AT, ["vn_o_men_nva_14"]];
_inf set [T_INF_AA, ["vn_o_men_nva_43"]];
_inf set [T_INF_LMG, ["vn_o_men_nva_11"]];
_inf set [T_INF_HMG, ["vn_o_men_nva_11"]];
_inf set [T_INF_medic, ["vn_o_men_nva_08"]];
_inf set [T_INF_engineer, ["vn_o_men_nva_09"]];
_inf set [T_INF_crew, ["vn_o_men_nva_38"]];
_inf set [T_INF_crew_heli, ["vn_o_men_aircrew_02"]];
_inf set [T_INF_pilot, ["vn_o_men_aircrew_07"]];
_inf set [T_INF_pilot_heli, ["vn_o_men_aircrew_01"]];
_inf set [T_INF_survivor, ["vn_o_men_nva_04", "vn_o_men_nva_49", "vn_o_men_nva_06", "vn_o_men_nva_02", "vn_o_men_nva_12"]];
_inf set [T_INF_unarmed, ["vn_o_men_nva_04", "vn_o_men_nva_49", "vn_o_men_nva_06", "vn_o_men_nva_02", "vn_o_men_nva_12"]];

//==== Recon ====
_inf set [T_INF_recon_TL, ["vn_o_men_nva_dc_01"]];
_inf set [T_INF_recon_rifleman, ["vn_o_men_nva_dc_06", "vn_o_men_nva_dc_03", "vn_o_men_nva_dc_04"]];
_inf set [T_INF_recon_medic, ["vn_o_men_nva_dc_08"]];
_inf set [T_INF_recon_exp, ["vn_o_men_nva_dc_09"]];
_inf set [T_INF_recon_LAT, ["vn_o_men_nva_dc_14"]];
//_inf set [T_INF_recon_LMG, ["Arma3_AAF_recon_autorifleman"]]; // There is no T_INF_recon_LMG right now
_inf set [T_INF_recon_marksman, ["vn_o_men_nva_dc_18", "vn_o_men_nva_dc_10"]];
_inf set [T_INF_recon_JTAC, ["vn_o_men_nva_dc_13"]];


//==== Drivers ====
/*_inf set [T_INF_diver_TL, [""]];
_inf set [T_INF_diver_rifleman, [""]];
_inf set [T_INF_diver_exp, [""]];*/


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["vn_o_bicycle_01"]];

_veh set [T_VEH_car_unarmed, ["vn_o_bicycle_01"]];
_veh set [T_VEH_car_armed, ["vn_o_wheeled_z157_mg_01"]];

_veh set [T_VEH_MRAP_unarmed, ["vn_o_wheeled_btr40_01"]];
_veh set [T_VEH_MRAP_HMG, ["vn_o_wheeled_btr40_mg_02", "vn_o_wheeled_btr40_mg_01", "vn_o_wheeled_btr40_mg_04"]];
_veh set [T_VEH_MRAP_GMG, ["vn_o_wheeled_btr40_mg_05"]];

//_veh set [T_VEH_IFV, [""]];
_veh set [T_VEH_APC, ["vn_o_armor_btr50pk_01"]];
_veh set [T_VEH_MBT, ["vn_o_armor_pt76a_01", "vn_o_armor_pt76b_01", "vn_o_armor_type63_01", "vn_o_armor_t54b_01", "vn_o_armor_ot54_01"]];
//_veh set [T_VEH_MRLS, [""]];
_veh set [T_VEH_SPA, ["vn_o_wheeled_btr40_mg_06"]];
_veh set [T_VEH_SPAA, ["vn_o_wheeled_btr40_mg_03", "vn_o_armor_btr50pk_02", "vn_o_wheeled_z157_mg_02"]];

_veh set [T_VEH_stat_HMG_high, ["vn_o_nva_static_dshkm_high_01", "vn_o_nva_static_pk_high", "vn_o_nva_static_rpd_high"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["vn_o_nva_static_dshkm_low_02", "vn_o_nva_static_dshkm_low_01", "vn_o_nva_static_m1910_low_02", "vn_o_nva_static_m1910_low_01", "vn_o_nva_static_pk_low", "vn_o_nva_static_sgm_low_02", "vn_o_nva_static_sgm_low_01"]];
//_veh set [T_VEH_stat_GMG_low, [""]];
_veh set [T_VEH_stat_AA, ["vn_o_nva_static_dshkm_high_02", "vn_o_nva_static_m1910_high_01", "vn_o_nva_static_sgm_high_01", "vn_o_nva_static_zgu1_01", "vn_o_nva_static_zpu4"]];
_veh set [T_VEH_stat_AT, ["vn_o_nva_static_type56rr", "vn_o_nva_static_d44", "vn_o_nva_static_at3"]];
_veh set [T_VEH_stat_mortar_light, ["vn_o_nva_static_mortar_type53", "vn_o_nva_static_mortar_type63"]];
_veh set [T_VEH_stat_mortar_heavy, ["vn_o_nva_static_d44_01", "vn_o_nva_static_h12"]];

//_veh set [T_VEH_heli_light, [""]];
//_veh set [T_VEH_heli_heavy, [""]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["vn_o_air_mi2_03_04", "vn_o_air_mi2_03_03", "vn_o_air_mi2_03_06", "vn_o_air_mi2_03_05", "vn_o_air_mi2_05_04", "vn_o_air_mi2_05_03", "vn_o_air_mi2_05_02", "vn_o_air_mi2_05_01", "vn_o_air_mi2_04_06", "vn_o_air_mi2_04_05", "vn_o_air_mi2_04_02", "vn_o_air_mi2_04_01", "vn_o_air_mi2_04_04", "vn_o_air_mi2_04_03"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter , [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed , [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

//_veh set [T_VEH_boat_unarmed, [""]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["vn_o_bicycle_01"]];

_veh set [T_VEH_truck_inf, ["vn_o_wheeled_z157_01", "vn_o_wheeled_z157_02"]];
_veh set [T_VEH_truck_cargo, ["vn_o_wheeled_z157_01", "vn_o_wheeled_z157_02"]];
_veh set [T_VEH_truck_ammo, ["vn_o_wheeled_z157_ammo"]];
_veh set [T_VEH_truck_repair, ["vn_o_wheeled_z157_repair"]];
_veh set [T_VEH_truck_medical , ["vn_o_wheeled_btr40_02", "vn_o_armor_btr50pk_03"]];
_veh set [T_VEH_truck_fuel, ["vn_o_wheeled_z157_fuel"]];

//_veh set [T_VEH_submarine, [""]];


//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array // End template

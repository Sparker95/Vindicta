_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tVN_US_Army"];
_array set [T_DESCRIPTION, "Vietman war US Army."];
_array set [T_DISPLAY_NAME, "VN DLC - US Army"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F", 
		"vn_weapons", 
		"vn_data_f"
		]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["vn_b_men_army_15"]];							//Default infantry if nothing is found

_inf set [T_INF_SL, ["vn_b_men_army_02"]];
_inf set [T_INF_TL, ["vn_b_men_army_08"]];
_inf set [T_INF_officer, ["vn_b_men_army_01"]];
_inf set [T_INF_GL, ["vn_b_men_army_07", "vn_b_men_army_17"]];
_inf set [T_INF_rifleman, ["vn_b_men_army_15", "vn_b_men_army_16", "vn_b_men_army_18", "vn_b_men_army_19", "vn_b_men_army_20", "vn_b_men_army_21"]];
_inf set [T_INF_marksman, ["vn_b_men_army_10"]];
_inf set [T_INF_sniper, ["vn_b_men_army_11"]];
_inf set [T_INF_spotter, ["vn_b_men_army_09"]];
_inf set [T_INF_exp, ["vn_b_men_army_05"]];
_inf set [T_INF_ammo, ["vn_b_men_army_15", "vn_b_men_army_16", "vn_b_men_army_18", "vn_b_men_army_19", "vn_b_men_army_20", "vn_b_men_army_21"]];
_inf set [T_INF_LAT, ["vn_b_men_army_12"]];
_inf set [T_INF_AT, ["vn_b_men_army_12"]];
_inf set [T_INF_AA, ["vn_b_men_army_12"]];
_inf set [T_INF_LMG, ["vn_b_men_army_06"]];
_inf set [T_INF_HMG, ["vn_b_men_army_06"]];
_inf set [T_INF_medic, ["vn_b_men_army_03"]];
_inf set [T_INF_engineer, ["vn_b_men_army_04"]];
_inf set [T_INF_crew, ["vn_b_men_army_13", "vn_b_men_army_14"]];
_inf set [T_INF_crew_heli, ["vn_b_men_aircrew_08"]];
_inf set [T_INF_pilot, ["vn_b_men_aircrew_05"]];
_inf set [T_INF_pilot_heli, ["I_helipilot_F"]];
_inf set [T_INF_survivor, ["vn_b_men_army_15", "vn_b_men_army_16", "vn_b_men_army_18", "vn_b_men_army_19", "vn_b_men_army_20", "vn_b_men_army_21"]];
_inf set [T_INF_unarmed, ["vn_b_men_army_15", "vn_b_men_army_16", "vn_b_men_army_18", "vn_b_men_army_19", "vn_b_men_army_20", "vn_b_men_army_21"]];

//==== Recon ====
_inf set [T_INF_recon_TL, ["vn_b_men_sf_01"]];
_inf set [T_INF_recon_rifleman, ["vn_b_men_sf_09", "vn_b_men_sf_04", "vn_b_men_sf_19"]];
_inf set [T_INF_recon_medic, ["vn_b_men_sf_20", "vn_b_men_sf_10", "vn_b_men_sf_02"]];
_inf set [T_INF_recon_exp, ["vn_b_men_sf_08", "vn_b_men_sf_03"]];
_inf set [T_INF_recon_LAT, ["vn_b_men_sf_13", "vn_b_men_sf_17", "vn_b_men_sf_07", "vn_b_men_sf_11"]];
//_inf set [T_INF_recon_LMG, ["Arma3_AAF_recon_autorifleman"]]; // There is no T_INF_recon_LMG right now
_inf set [T_INF_recon_marksman, ["vn_b_men_sf_21", "vn_b_men_sf_12", "vn_b_men_sog_21"]];
_inf set [T_INF_recon_JTAC, ["vn_b_men_sf_14", "vn_b_men_sf_06"]];


//==== Drivers ====
/*_inf set [T_INF_diver_TL, [""]];
_inf set [T_INF_diver_rifleman, [""]];
_inf set [T_INF_diver_exp, [""]];*/


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["vn_b_wheeled_m151_01"]];

_veh set [T_VEH_car_unarmed, ["vn_b_wheeled_m151_01", "vn_b_wheeled_m151_02"]];
_veh set [T_VEH_car_armed, ["vn_b_wheeled_m151_mg_02", "vn_b_wheeled_m151_mg_04", "vn_b_wheeled_m151_mg_03"]];

//_veh set [T_VEH_MRAP_unarmed, [""]];
_veh set [T_VEH_MRAP_HMG, ["vn_b_wheeled_m54_mg_01"]];
//_veh set [T_VEH_MRAP_GMG, [""]];

//_veh set [T_VEH_IFV, [""]];
//_veh set [T_VEH_APC, [""]];
//_veh set [T_VEH_MBT, [""]];
//_veh set [T_VEH_MRLS, [""]];
//_veh set [T_VEH_SPA, [""]];
_veh set [T_VEH_SPAA, ["vn_b_wheeled_m54_mg_02"]];

_veh set [T_VEH_stat_HMG_high, ["vn_b_army_static_m1919a4_high", "vn_b_sf_static_m2_high", "vn_b_army_static_m60_high"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["vn_b_army_static_m1919a4_low", "vn_b_army_static_m2_low", "vn_b_army_static_m60_low"]];
//_veh set [T_VEH_stat_GMG_low, [""]];
_veh set [T_VEH_stat_AA, ["vn_b_army_static_m45"]];
_veh set [T_VEH_stat_AT, ["vn_b_sf_static_tow"]];
_veh set [T_VEH_stat_mortar_light, ["vn_b_army_static_mortar_m2", "vn_b_sf_static_mortar_m29"]];
_veh set [T_VEH_stat_mortar_heavy, ["vn_b_sf_static_m101_01", "vn_b_army_static_m101_02"]];

//_veh set [T_VEH_heli_light, [""]];
//_veh set [T_VEH_heli_heavy, [""]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, [/*"vn_air_ah1g_02", "vn_air_ah1g_03", "vn_air_ah1g_04", "vn_air_ah1g_01",*/ "vn_b_air_oh6a_06", "vn_b_air_oh6a_05", "vn_b_air_oh6a_04", "vn_b_air_oh6a_07", "vn_b_air_oh6a_01", "vn_b_air_oh6a_03", "vn_b_air_oh6a_02", "vn_b_air_uh1c_06_02", "vn_b_air_uh1c_06_01", "vn_b_air_uh1c_04_02", "vn_b_air_uh1c_04_01", "vn_b_air_uh1c_02_02", "vn_b_air_uh1c_02_01", "vn_b_air_uh1c_05_02", "vn_b_air_uh1c_01_01", "vn_b_air_uh1c_03_01"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter , [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed , [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

//_veh set [T_VEH_boat_unarmed, [""]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["vn_b_wheeled_m151_01"]];

_veh set [T_VEH_truck_inf, ["vn_b_wheeled_m54_02", "vn_b_wheeled_m54_01", "vn_b_wheeled_m54_02_sog", "vn_b_wheeled_m54_01_sog"]];
_veh set [T_VEH_truck_cargo, ["vn_b_wheeled_m54_02", "vn_b_wheeled_m54_01", "vn_b_wheeled_m54_02_sog", "vn_b_wheeled_m54_01_sog"]];
_veh set [T_VEH_truck_ammo, ["vn_b_wheeled_m54_ammo"]];
_veh set [T_VEH_truck_repair, ["vn_b_wheeled_m54_repair"]];
_veh set [T_VEH_truck_medical , ["vn_b_wheeled_m54_03"]];
_veh set [T_VEH_truck_fuel, ["vn_b_wheeled_m54_fuel"]];

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

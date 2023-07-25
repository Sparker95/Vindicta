_array = [];

_array set [T_SIZE-1, nil];

// Name, description, faction, addons, etc
_array set [T_NAME, "tSPE_IFA3_Wehrmacht"];
_array set [T_DESCRIPTION, "World War 2 Wehrmacht made using content from Spearhead 1944 DLC + Iron Front mod."];
_array set [T_DISPLAY_NAME, "SPE DLC + IFA3 - Wehrmacht"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F",
		"WW2_SPE_Core_c_Core_c",
		"WW2_Core_c_WW2_Core_c"
		]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["SPE_GER_rifleman_lite"]];

_inf set [T_INF_SL, ["SPE_GER_SquadLead"]];
_inf set [T_INF_TL, ["SPE_GER_Assist_SquadLead"]];
_inf set [T_INF_officer, ["SPE_GER_hauptmann", "SPE_GER_oberst"]];
_inf set [T_INF_GL, ["SPE_GER_ober_grenadier"]];
_inf set [T_INF_rifleman, ["SPE_GER_rifleman_2", "SPE_GER_rifleman", "SPE_GER_rifleman_lite", "SPE_GER_ober_rifleman", "SPE_GER_stggunner"]];
_inf set [T_INF_marksman, ["SPE_GER_scout_sniper"]];
_inf set [T_INF_sniper, ["SPE_GER_scout_sniper"]];
_inf set [T_INF_spotter, ["SPE_GER_rifleman_2", "SPE_GER_rifleman", "SPE_GER_rifleman_lite", "SPE_GER_ober_rifleman"]];
_inf set [T_INF_exp, ["SPE_GER_sapper", "SPE_GER_sapper_gefr"]];
_inf set [T_INF_ammo, ["SPE_GER_Mortar_AmmoBearer", "SPE_GER_HMG_AmmoBearer"]];
_inf set [T_INF_LAT, ["SPE_GER_AT_grenadier", "SPE_GER_LAT_Klein_Rifleman"]];
_inf set [T_INF_AT, ["SPE_GER_LAT_Rifleman", "SPE_GER_LAT_30m_Rifleman"]];
_inf set [T_INF_AA, ["SPE_GER_LAT_Rifleman", "SPE_GER_LAT_30m_Rifleman"]];
_inf set [T_INF_LMG, ["SPE_GER_mgunner2", "SPE_GER_mgunner"]];
_inf set [T_INF_HMG, ["SPE_GER_mgunner2", "SPE_GER_mgunner"]];
_inf set [T_INF_medic, ["SPE_GER_medic"]];
_inf set [T_INF_engineer, ["SPE_GER_Flamethrower_Operator"]];
_inf set [T_INF_crew, ["SPE_GER_tank_crew"]];
_inf set [T_INF_crew_heli, ["SPE_GER_pilot"]];
_inf set [T_INF_pilot, ["SPE_GER_pilot"]];
_inf set [T_INF_pilot_heli, ["SPE_GER_pilot"]];
_inf set [T_INF_survivor, ["SPE_GER_rifleman_2", "SPE_GER_rifleman", "SPE_GER_rifleman_lite", "SPE_GER_ober_rifleman"]];
_inf set [T_INF_unarmed, ["SPE_GER_rifleman_2", "SPE_GER_rifleman", "SPE_GER_rifleman_lite", "SPE_GER_ober_rifleman"]];

//==== Recon ====
_inf set [T_INF_recon_TL, ["SPE_GER_scout_SquadLead"]];
_inf set [T_INF_recon_rifleman, ["SPE_GER_scout_rifleman", "SPE_GER_scout_ober_rifleman"]];
_inf set [T_INF_recon_medic, ["SPE_GER_scout_rifleman", "SPE_GER_scout_ober_rifleman"]];
_inf set [T_INF_recon_exp, ["SPE_GER_scout_ober_grenadier"]];
_inf set [T_INF_recon_LAT, ["SPE_GER_scout_rifleman", "SPE_GER_scout_ober_rifleman"]];
//_inf set [T_INF_recon_LMG, [""]];
_inf set [T_INF_recon_marksman, ["SPE_GER_scout_sniper"]];
_inf set [T_INF_recon_JTAC, ["SPE_GER_radioman"]];


//==== Drivers ====
//_inf set [T_INF_diver_TL, [""]];
//_inf set [T_INF_diver_rifleman, [""]];
//_inf set [T_INF_diver_exp, [""]];


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["LIB_Kfz1"]];

_veh set [T_VEH_car_unarmed, ["LIB_Kfz1", "LIB_Kfz1_camo", "LIB_Kfz1_sernyt", "LIB_Kfz1_Hood", "LIB_Kfz1_Hood_camo", "LIB_Kfz1_Hood_sernyt"]];
_veh set [T_VEH_car_armed, ["LIB_Kfz1_MG42", "LIB_Kfz1_MG42_camo", "LIB_Kfz1_MG42_sernyt"]];

_veh set [T_VEH_MRAP_unarmed, ["LIB_SdKfz_7"]];
_veh set [T_VEH_MRAP_HMG, ["SPE_SdKfz250_1"]];
//_veh set [T_VEH_MRAP_GMG, [""]];

//_veh set [T_VEH_IFV, [""]];
_veh set [T_VEH_APC, ["LIB_SdKfz251", "LIB_SdKfz251_FFV"]];
_veh set [T_VEH_MBT, ["SPE_PzKpfwIII_J", "SPE_PzKpfwIII_L", "SPE_PzKpfwIII_M", "SPE_PzKpfwIII_N", "SPE_PzKpfwIV_G", "LIB_StuG_III_G", "SPE_PzKpfwIII_J", "SPE_PzKpfwIII_L", "SPE_PzKpfwIII_M", "SPE_PzKpfwIII_N", "SPE_PzKpfwIV_G", "LIB_StuG_III_G", "SPE_PzKpfwVI_H1", "LIB_PzKpfwV", "LIB_PzKpfwVI_B", "LIB_PzKpfwVI_B_tarn51c", "LIB_PzKpfwVI_B_tarn51d", "SPE_Nashorn"]];
//_veh set [T_VEH_MRLS, [""]];
_veh set [T_VEH_SPA, ["LIB_SdKfz124"]];
_veh set [T_VEH_SPAA, ["SPE_OpelBlitz_Flak38", "LIB_SdKfz_7_AA", "LIB_FlakPanzerIV_Wirbelwind"]];

_veh set [T_VEH_stat_HMG_high, [""]];
//_veh set [T_VEH_stat_GMG_high, ["SPE_GER_SearchLight"]];
_veh set [T_VEH_stat_HMG_low, ["SPE_MG34_Lafette_low_Deployed", "SPE_MG42_Lafette_low_Deployed"]];
//_veh set [T_VEH_stat_GMG_low, [""]];
_veh set [T_VEH_stat_AA, ["SPE_FlaK_30", "SPE_FlaK_38", "SPE_FlaK_36_AA", "LIB_Flakvierling_38"]];
_veh set [T_VEH_stat_AT, ["SPE_leFH18_AT", "SPE_Pak40", "SPE_FlaK_36"]];
_veh set [T_VEH_stat_mortar_light, ["SPE_GrW278_1"]];
_veh set [T_VEH_stat_mortar_heavy, ["SPE_leFH18"]];

//_veh set [T_VEH_heli_light, [""]];
//_veh set [T_VEH_heli_heavy, [""]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["SPE_FW190F8", "LIB_Ju87"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter , [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed , [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

//_veh set [T_VEH_boat_unarmed, [""]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["LIB_Kfz1"]];

_veh set [T_VEH_truck_inf, ["SPE_OpelBlitz", "SPE_OpelBlitz_Open"]];
_veh set [T_VEH_truck_cargo, ["SPE_OpelBlitz", "SPE_OpelBlitz_Open"]];
_veh set [T_VEH_truck_ammo, ["SPE_OpelBlitz_Ammo", "LIB_SdKfz_7_Ammo"]];
_veh set [T_VEH_truck_repair, ["SPE_OpelBlitz_Repair"]];
_veh set [T_VEH_truck_medical , ["SPE_OpelBlitz_Ambulance"]];
_veh set [T_VEH_truck_fuel, ["SPE_OpelBlitz_Fuel"]];

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

_array = [];

_array set [T_SIZE-1, nil];

// Name, description, faction, addons, etc
_array set [T_NAME, "tSPE_IFA3_US_Army"];
_array set [T_DESCRIPTION, "World War 2 US Army made using content from Spearhead 1944 DLC + Iron Front mod."];
_array set [T_DISPLAY_NAME, "SPE DLC + IFA3 - US Army"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F",
		"WW2_SPE_Core_c_Core_c",
		"WW2_Core_c_WW2_Core_c"
		]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["SPE_US_Rifleman"]];

_inf set [T_INF_SL, ["SPE_US_SquadLead"]];
_inf set [T_INF_TL, ["SPE_US_Assist_SquadLead"]];
_inf set [T_INF_officer, ["SPE_US_Captain"]];
_inf set [T_INF_GL, ["SPE_US_Grenadier"]];
_inf set [T_INF_rifleman, ["SPE_US_Rifleman"]];
_inf set [T_INF_marksman, ["SPE_US_Sniper"]];
_inf set [T_INF_sniper, ["SPE_US_Sniper"]];
_inf set [T_INF_spotter, ["SPE_US_Rifleman"]];
_inf set [T_INF_exp, ["SPE_US_Flamethrower_Operator"]];
_inf set [T_INF_ammo, ["SPE_US_Rifleman_AmmoBearer", "SPE_US_HMG_AmmoBearer", "SPE_US_Mortar_AmmoBearer"]];
_inf set [T_INF_LAT, ["SPE_US_AT_Soldier"]];
_inf set [T_INF_AT, ["SPE_US_AT_Soldier"]];
_inf set [T_INF_AA, ["SPE_US_AT_Soldier"]];
_inf set [T_INF_LMG, ["SPE_US_Autorifleman"]];
_inf set [T_INF_HMG, ["SPE_US_HMGunner"]];
_inf set [T_INF_medic, ["SPE_US_Medic"]];
_inf set [T_INF_engineer, ["SPE_US_Engineer"]];
_inf set [T_INF_crew, ["SPE_US_Tank_Crew"]];
_inf set [T_INF_crew_heli, ["SPE_US_Pilot"]];
_inf set [T_INF_pilot, ["SPE_US_Pilot_2"]];
_inf set [T_INF_pilot_heli, ["SPE_US_Pilot_2"]];
_inf set [T_INF_survivor, ["SPE_US_Rifleman"]];
_inf set [T_INF_unarmed, ["SPE_US_Rifleman"]];

//==== Recon ====
_inf set [T_INF_recon_TL, ["SPE_US_Rangers_SquadLead"]];
_inf set [T_INF_recon_rifleman, ["SPE_US_Rangers_rifleman"]];
_inf set [T_INF_recon_medic, ["SPE_US_Rangers_medic"]];
_inf set [T_INF_recon_exp, ["SPE_US_Rangers_Flamethrower_Operator", "SPE_US_Rangers_engineer", "SPE_US_Rangers_engineer_bangalore"]];
_inf set [T_INF_recon_LAT, ["SPE_US_Rangers_AT_soldier"]];
//_inf set [T_INF_recon_LMG, [""]];
_inf set [T_INF_recon_marksman, ["SPE_US_Rangers_sniper"]];
_inf set [T_INF_recon_JTAC, ["SPE_US_Rangers_radioman"]];


//==== Drivers ====
//_inf set [T_INF_diver_TL, [""]];
//_inf set [T_INF_diver_rifleman, [""]];
//_inf set [T_INF_diver_exp, [""]];


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["LIB_US_Willys_MB"]];

_veh set [T_VEH_car_unarmed, ["LIB_US_Willys_MB", "LIB_US_Willys_MB_Hood"]];
_veh set [T_VEH_car_armed, ["LIB_US_Willys_MB_M1919"]];

_veh set [T_VEH_MRAP_unarmed, ["SPE_US_M3_Halftrack_Unarmed", "SPE_US_M3_Halftrack_Unarmed_Open"]];
_veh set [T_VEH_MRAP_HMG, ["LIB_US_Scout_M3"]];
//_veh set [T_VEH_MRAP_GMG, [""]];

_veh set [T_VEH_IFV, ["LIB_M8_Greyhound"]];
_veh set [T_VEH_APC, ["SPE_US_M3_Halftrack"]];
_veh set [T_VEH_MBT, ["LIB_M3A3_Stuart", "LIB_M5A1_Stuart", "SPE_M10", "SPE_M18_Hellcat", "SPE_M4A0_75_Early", "SPE_M4A0_75", "SPE_M4A1_76", "SPE_M4A1_75", "SPE_M4A1_T34_Calliope_Direct"]];
_veh set [T_VEH_MRLS, ["SPE_M4A1_T34_Calliope"]];
//_veh set [T_VEH_SPA, [""]];
_veh set [T_VEH_SPAA, ["SPE_US_M16_Halftrack"]];

_veh set [T_VEH_stat_HMG_high, ["SPE_GER_SearchLight"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["SPE_M1919_M2"]];
//_veh set [T_VEH_stat_GMG_low, [""]];
_veh set [T_VEH_stat_AA, ["SPE_M45_Quadmount"]];
_veh set [T_VEH_stat_AT, ["SPE_57mm_M1"]];
_veh set [T_VEH_stat_mortar_light, ["SPE_M1_81"]];
//_veh set [T_VEH_stat_mortar_heavy, [""]];

//_veh set [T_VEH_heli_light, [""]];
//_veh set [T_VEH_heli_heavy, [""]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["SPE_P47", "LIB_US_P39", "LIB_US_P39_2"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter , [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed , [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

//_veh set [T_VEH_boat_unarmed, [""]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["LIB_US_Willys_MB"]];

_veh set [T_VEH_truck_inf, ["LIB_US_GMC_Open", "LIB_US_GMC_Tent"]];
_veh set [T_VEH_truck_cargo, ["SPE_US_M3_Halftrack_Unarmed", "SPE_US_M3_Halftrack_Unarmed_Open", "LIB_US_GMC_Open", "LIB_US_GMC_Tent"]];
_veh set [T_VEH_truck_ammo, ["SPE_US_M3_Halftrack_Ammo", "LIB_US_GMC_Ammo"]];
_veh set [T_VEH_truck_repair, ["SPE_US_M3_Halftrack_Repair", "LIB_US_GMC_Parm"]];
_veh set [T_VEH_truck_medical , ["SPE_US_M3_Halftrack_Ambulance", "LIB_US_GMC_Ambulance", "LIB_US_Willys_MB_Ambulance"]];
_veh set [T_VEH_truck_fuel, ["SPE_US_M3_Halftrack_Fuel", "LIB_US_GMC_Fuel"]];

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

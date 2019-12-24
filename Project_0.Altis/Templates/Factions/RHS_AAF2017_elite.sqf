/*
custom Altis Armed Forces 2017 elite templates for ARMA III (RHS,AAF2017)
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT, ["FGN_AAF_inf_rifleman"]];

_inf set [T_INF_SL, ["RHS_AAF2017_elite_SL"]];
_inf set [T_INF_TL, ["RHS_AAF2017_elite_TL"]];
_inf set [T_INF_officer, ["RHS_AAF2017_elite_officer"]];
_inf set [T_INF_GL, ["RHS_AAF2017_elite_grenadier"]];
_inf set [T_INF_rifleman, ["RHS_AAF2017_elite_rifleman"]];
_inf set [T_INF_marksman, ["RHS_AAF2017_elite_marksman"]];
_inf set [T_INF_sniper, ["RHS_AAF2017_elite_sniper"]];
_inf set [T_INF_spotter, ["RHS_AAF2017_elite_spotter"]];
_inf set [T_INF_exp, ["RHS_AAF2017_elite_explosives"]];
_inf set [T_INF_ammo, ["RHS_AAF2017_elite_MG_2", "RHS_AAF2017_elite_AT_2"]];
_inf set [T_INF_LAT, ["RHS_AAF2017_elite_LAT"]];
_inf set [T_INF_AT, ["RHS_AAF2017_elite_AT"]];
_inf set [T_INF_AA, ["RHS_AAF2017_elite_AA"]];
_inf set [T_INF_LMG, ["RHS_AAF2017_elite_LMG"]];
_inf set [T_INF_HMG, ["RHS_AAF2017_elite_MG"]];
_inf set [T_INF_medic, ["RHS_AAF2017_elite_medic"]];
_inf set [T_INF_engineer, ["RHS_AAF2017_elite_engineer"]];
_inf set [T_INF_crew, ["RHS_AAF2017_elite_crew"]];
_inf set [T_INF_crew_heli, ["RHS_AAF2017_elite_helicrew"]];
_inf set [T_INF_pilot, ["RHS_AAF2017_elite_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_AAF2017_elite_helipilot"]];
//_inf set [T_INF_survivor, ["RHS_AAF2017_elite_rifleman"]];
//_inf set [T_INF_unarmed, ["RHS_AAF2017_elite_rifleman"]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_AAF2017_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_AAF2017_recon_LMG"]];
_inf set [T_INF_recon_medic, ["RHS_AAF2017_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_AAF2017_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["RHS_AAF2017_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_AAF2017_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_AAF2017_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];


//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["FGN_AAF_M1025_unarmed"]];

_veh set [T_VEH_car_unarmed, ["FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop", "FGN_AAF_M998_2D_Halftop"]]; //TODO - remove us army iff pannels via garage
_veh set [T_VEH_car_armed, ["FGN_AAF_M1025_M2", "FGN_AAF_M1025_MK19"]];

_veh set [T_VEH_MRAP_unarmed, ["FGN_AAF_Tigr_M", "FGN_AAF_Tigr"]];
_veh set [T_VEH_MRAP_HMG, ["FGN_AAF_Tigr_STS"]];
_veh set [T_VEH_MRAP_GMG, ["rhsusf_M1117_D"]]; //TODO - remove us army iff pannels via garage

_veh set [T_VEH_IFV, ["FGN_AAF_BMP3M_ERA", "rhs_bmp1p_vdv"]]; //TODO change BMP-1 color to "sand", add version without ATGM
_veh set [T_VEH_APC, ["rhsusf_m113d_usarmy_supply", "rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_MK19", "rhsusf_m113d_usarmy_unarmed", "rhsusf_m113d_usarmy_M240"]]; //TODO - remove US army markings and iff pannels via garage
_veh set [T_VEH_MBT, ["rhs_t72ba_tv","rhs_t72bb_tv","rhs_t90sm_tv", "rhs_t90am_tv"]]; //TODO - change color to "sand", move T-72 to reserve
_veh set [T_VEH_MRLS, ["FGN_AAF_BM21"]];
_veh set [T_VEH_SPA, ["rhs_2s1_tv", "rhs_2s3_tv"]]; //TODO - change colors to "sand"
_veh set [T_VEH_SPAA, ["FGN_AAF_Ural_ZU23", "rhs_zsu234_aa"]]; //TODO - change shilka color to "sand"

_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_D"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_D"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_D", "rhsgref_ins_g_SPG9M", "rhsgref_ins_g_SPG9"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_vmf"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_D"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_D"]];

//TODO remove HIDF markings from UH1 via garage, move UH1 to reserve
_veh set [T_VEH_heli_light, ["FGN_AAF_KA60_unarmed","rhs_uh1h_hidf", "RHS_MELB_H6M", "RHS_MELB_MH6M"]];
_veh set [T_VEH_heli_heavy, ["FGN_AAF_KA60_dynamicLoadout","rhs_uh1h_hidf_gunship", "RHS_MELB_AH6M"]];
_veh set [T_VEH_heli_cargo, ["FGN_AAF_KA60_unarmed","rhs_uh1h_hidf_unarmed"]];
_veh set [T_VEH_heli_attack, ["rhsgref_mi24g_CAS"]]; //TODO add dynamic loadout variants for more variety

//TODO add dynamic loadout variants for more variety
_veh set [T_VEH_plane_attack, ["FGN_AAF_L159_dynamicLoadout"]];
_veh set [T_VEH_plane_fighter, ["FGN_AAF_L159_dynamicLoadout"]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
_veh set [T_VEH_boat_armed, ["rhsusf_mkvsoc"]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];


_veh set [T_VEH_truck_inf, ["FGN_AAF_Ural", "FGN_AAF_Ural_open", "FGN_AAF_Zamak_Open", "FGN_AAF_Zamak"]];
//_veh set [T_VEH_truck_cargo, ["TODO"]];
_veh set [T_VEH_truck_ammo, ["FGN_AAF_Zamak_Ammo"]];
_veh set [T_VEH_truck_repair, ["FGN_AAF_Ural_Repair","FGN_AAF_Zamak_Repair"]];
_veh set [T_VEH_truck_medical , ["FGN_AAF_Zamak_Medic", "rhsusf_m113d_usarmy_medical"]];
_veh set [T_VEH_truck_fuel, ["FGN_AAF_Ural_Fuel","FGN_AAF_Zamak_Fuel"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];


//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["rhs_pchela1t_vvsc"]];

//_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]];
//_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]];
//_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];
//_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]];
//_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]];
//_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [[[T_INF, T_INF_TL], [T_INF, T_INF_rifleman]]]];

_group set [T_GROUP_inf_AA_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AA], [T_INF, T_INF_AA], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_AT_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_rifleman], [T_INF, T_INF_AT], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_rifle_squad,	[[[T_INF, T_INF_SL], [T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_GL], [T_INF, T_INF_LAT], [T_INF, T_INF_marksman], [T_INF, T_INF_medic], [T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_assault_squad,	[[[T_INF, T_INF_SL], [T_INF, T_INF_LMG], [T_INF, T_INF_exp], [T_INF, T_INF_engineer], [T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_exp], [T_INF, T_INF_engineer]]]];
_group set [T_GROUP_inf_weapons_squad,	[[[T_INF, T_INF_SL], [T_INF, T_INF_TL], [T_INF, T_INF_HMG], [T_INF, T_INF_ammo], [T_INF, T_INF_HMG], [T_INF, T_INF_ammo],[T_INF, T_INF_AT], [T_INF, T_INF_ammo] ]]];
_group set [T_GROUP_inf_fire_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];
_group set [T_GROUP_inf_sentry,			[[[T_INF, T_INF_TL], [T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_sniper_team,	[[[T_INF, T_INF_sniper], [T_INF, T_INF_spotter]]]];

_group set [T_GROUP_inf_recon_patrol,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT]]]];
_group set [T_GROUP_inf_recon_sentry,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_LAT] ]]];
_group set [T_GROUP_inf_recon_squad,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT],  [T_INF, T_INF_recon_JTAC], [T_INF, T_INF_recon_exp]]]];
_group set [T_GROUP_inf_recon_team,		[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT], [T_INF, T_INF_recon_exp] ]]];


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];
_array set [T_NAME, "tRHS_AAF2017_elite"];

_array // End template

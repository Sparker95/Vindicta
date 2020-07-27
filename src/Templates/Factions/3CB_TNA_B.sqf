_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "t3CB_TNA_B"];
_array set [T_DESCRIPTION, "Takistan's National Army BLUFOR edition. Requires 3CB's Faction pack and RHS."];
_array set [T_DISPLAY_NAME, "3CB Takistan National Army BLU"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops",	// RHSGREF
	"uk3cb_factions_TKA", // 3CB Factions
	"ace_compat_rhs_afrf3", // ACE Compat - RHS Armed Forces of the Russian Federation
	"ace_compat_rhs_gref3", // ACE Compat - RHS: GREF
	"ace_compat_rhs_usf3" // ACE Compat - RHS United States Armed Forces
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["UK3CB_TKA_B_RIF_1"]];

_inf set [T_INF_SL, ["UK3CB_TKA_B_SL"]];
_inf set [T_INF_TL, ["UK3CB_TKA_B_TL"]];
_inf set [T_INF_officer, ["UK3CB_TKA_B_OFF"]];
_inf set [T_INF_GL, ["UK3CB_TKA_B_GL"]];
_inf set [T_INF_rifleman, ["UK3CB_TKA_B_RIF_1", "UK3CB_TKA_B_RIF_2"]];
_inf set [T_INF_marksman, ["UK3CB_TKA_B_MK"]];
_inf set [T_INF_sniper, ["UK3CB_TKA_B_SF_SNI"]];
_inf set [T_INF_spotter, ["UK3CB_TKA_B_SF_SPOT"]];
_inf set [T_INF_exp, ["UK3CB_TKA_B_DEM"]];
_inf set [T_INF_ammo, ["UK3CB_TKA_B_STATIC_TRI_AGS30", "UK3CB_TKA_B_STATIC_TRI_DSHKM_HIGH", "UK3CB_TKA_B_STATIC_TRI_DSHKM_LOW", "UK3CB_TKA_B_STATIC_TRI_KORD", "UK3CB_TKA_B_STATIC_TRI_KORNET", "UK3CB_TKA_B_STATIC_TRI_METIS", "UK3CB_TKA_B_STATIC_TRI_NSV", "UK3CB_TKA_B_STATIC_TRI_PODNOS", "UK3CB_TKA_B_STATIC_TRI_SPG9", "UK3CB_TKA_B_AA_ASST", "UK3CB_TKA_B_AT_ASST"]];
_inf set [T_INF_LAT, ["UK3CB_TKA_B_LAT"]];
_inf set [T_INF_AT, ["UK3CB_TKA_B_AT"]];
_inf set [T_INF_AA, ["UK3CB_TKA_B_AA"]];
_inf set [T_INF_LMG, ["UK3CB_TKA_B_AR_1"]];
_inf set [T_INF_HMG, ["UK3CB_TKA_B_MG"]];
_inf set [T_INF_medic, ["UK3CB_TKA_B_MD"]];
_inf set [T_INF_engineer, ["UK3CB_TKA_B_ENG"]];
_inf set [T_INF_crew, ["UK3CB_TKA_B_CREW"]];
_inf set [T_INF_crew_heli, ["UK3CB_TKA_B_HELI_CREW"]];
_inf set [T_INF_pilot, ["UK3CB_TKA_B_JET_PILOT"]];
_inf set [T_INF_pilot_heli, ["UK3CB_TKA_B_HELI_PILOT"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["UK3CB_TKA_B_SF_TL"]];
_inf set [T_INF_recon_rifleman, ["UK3CB_TKA_B_SF_RIF_2"]];
_inf set [T_INF_recon_medic, ["UK3CB_TKA_B_SF_MD"]];
_inf set [T_INF_recon_exp, ["UK3CB_TKA_B_SF_DEM"]];
_inf set [T_INF_recon_LAT, ["UK3CB_TKA_B_SF_LAT"]];
_inf set [T_INF_recon_marksman, ["UK3CB_TKA_B_SF_MK"]];
_inf set [T_INF_recon_JTAC, ["UK3CB_TKA_B_SF_SL"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["UK3CB_TKA_B_Hilux_Open"]];

_veh set [T_VEH_car_unarmed, ["UK3CB_TKA_B_Hilux_Open", "UK3CB_TKA_B_Hilux_Closed"]];
_veh set [T_VEH_car_armed, ["UK3CB_TKA_B_Hilux_GMG", "UK3CB_TKA_B_Hilux_Dshkm", "UK3CB_TKA_B_Hilux_Pkm", "UK3CB_TKA_B_Hilux_Spg9"]];

_veh set [T_VEH_MRAP_unarmed, ["UK3CB_TKA_B_M1025", "UK3CB_TKA_B_M998_2DR", "UK3CB_TKA_B_M998_4DR", "UK3CB_TKA_B_BRDM2_UM"]];
_veh set [T_VEH_MRAP_HMG, ["UK3CB_TKA_B_M1025_M2", "UK3CB_TKA_B_BRDM2_HQ", "UK3CB_TKA_B_BRDM2"]];
_veh set [T_VEH_MRAP_GMG, ["UK3CB_TKA_B_M1025_MK19"]];

_veh set [T_VEH_IFV, ["UK3CB_TKA_B_BMP1", "UK3CB_TKA_B_BMP2", "UK3CB_TKA_B_BMP2K"]];
_veh set [T_VEH_APC, ["UK3CB_TKA_B_M113_unarmed", "UK3CB_TKA_B_MTLB_PKT", "UK3CB_TKA_B_M113_MK19", "UK3CB_TKA_B_M113_M240", "UK3CB_TKA_B_M113_M2", "UK3CB_TKA_B_M1117", "UK3CB_TKA_B_BTR40", "UK3CB_TKA_B_BTR40_MG"]];
_veh set [T_VEH_MBT, ["UK3CB_TKA_B_T72B", "UK3CB_TKA_B_T72BM", "UK3CB_TKA_B_T72A", "UK3CB_TKA_B_T55", "UK3CB_TKA_B_T34"]];
_veh set [T_VEH_MRLS, ["UK3CB_TKA_B_RIF_1"]];
_veh set [T_VEH_SPA, ["rhsusf_m109d_usarmy"]];
_veh set [T_VEH_SPAA, ["UK3CB_TKA_B_Hilux_Zu23", "UK3CB_TKA_B_BRDM2_ATGM"]];

_veh set [T_VEH_stat_HMG_high, ["UK3CB_TKA_B_DSHKM"]];
//_veh set [T_VEH_stat_GMG_high, []];
_veh set [T_VEH_stat_HMG_low, ["UK3CB_TKA_B_NSV", "UK3CB_TKA_B_KORD", "UK3CB_TKA_B_DSHkM_Mini_TriPod"]];
_veh set [T_VEH_stat_GMG_low, ["UK3CB_TKA_B_AGS"]];
_veh set [T_VEH_stat_AA, ["UK3CB_TKA_B_ZU23", "UK3CB_TKA_B_Igla_AA_pod"]];
_veh set [T_VEH_stat_AT, ["UK3CB_TKA_B_SPG9", "UK3CB_TKA_B_Kornet", "UK3CB_TKA_B_Metis"]];

_veh set [T_VEH_stat_mortar_light, ["UK3CB_TKA_B_2b14_82mm"]];
_veh set [T_VEH_stat_mortar_heavy, ["UK3CB_TKA_B_D30"]];

_veh set [T_VEH_heli_light, ["UK3CB_TKA_B_UH1H"]];
_veh set [T_VEH_heli_heavy, ["UK3CB_TKA_B_Mi8AMTSh"]];
_veh set [T_VEH_heli_cargo, ["UK3CB_TKA_B_UH1H", "UK3CB_TKA_B_Mi8"]];
_veh set [T_VEH_heli_attack, ["UK3CB_TKA_B_Mi_24P", "UK3CB_TKA_B_Mi_24V"]];

//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter, [""]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed, [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

//_veh set [T_VEH_boat_unarmed, [""]];
_veh set [T_VEH_boat_armed, ["UK3CB_TKA_B_RHIB", "UK3CB_TKA_B_RHIB_Gunboat"]];

_veh set [T_VEH_personal, ["O_G_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["UK3CB_TKA_B_Ural", "UK3CB_TKA_B_Ural_Open"]];
_veh set [T_VEH_truck_cargo, ["UK3CB_TKA_B_Ural", "UK3CB_TKA_B_Ural_Open"]];
_veh set [T_VEH_truck_ammo, ["UK3CB_TKA_B_Ural_Ammo"]];
_veh set [T_VEH_truck_repair, ["UK3CB_TKA_B_Ural_Repair"]];
_veh set [T_VEH_truck_medical , ["UK3CB_TKA_B_Ural"]];
_veh set [T_VEH_truck_fuel, ["UK3CB_TKA_B_Ural_Fuel"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
//_drone set [T_DRONE_SIZE-1, nil];
//_drone set [T_DRONE_DEFAULT, ["I_UGV_01_F"]];
//_drone set [T_DRONE_UGV_unarmed, ["I_UGV_01_F"]];
//_drone set [T_DRONE_UGV_armed, ["I_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_quadcopter, ["I_UAV_01_F"]];
//_drone set [T_DRONE_designator, [""]];
//_drone set [T_DRONE_stat_HMG_low, ["I_HMG_01_A_F"]];
//_drone set [T_DRONE_stat_GMG_low, ["I_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, [""]];

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

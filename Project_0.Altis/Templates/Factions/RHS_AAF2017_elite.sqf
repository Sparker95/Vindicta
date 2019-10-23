/*
Altis Armed Forces 2017 elite troops Template
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
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

_veh set [T_VEH_IFV, ["FGN_AAF_BMP3M_ERA"]];
_veh set [T_VEH_APC, ["rhsusf_m113d_usarmy_supply", "rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_MK19", "rhsusf_m113d_usarmy_unarmed", "rhsusf_m113d_usarmy_M240"]]; //TODO - remove US army markings and iff pannels via garage
_veh set [T_VEH_MBT, ["rhs_t72ba_tv","rhs_t72bb_tv","rhs_t90sm_tv", "rhs_t90am_tv"]]; //TODO - change color to "sand", move T-72 to reserve
_veh set [T_VEH_MRLS, ["FGN_AAF_BM21"]];
_veh set [T_VEH_SPA, ["rhs_2s1_tv"]]; //TODO - change 2s1 color to "sand"
_veh set [T_VEH_SPAA, ["FGN_AAF_Ural_ZU23", "rhs_zsu234_aa"]]; //TODO - change shilka color to "sand"

_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_D"]];
_veh set [T_VEH_stat_GMG_high, ["RHS_MK19_TriPod_D"]];
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_D"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_D"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_vmf"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]];

_veh set [T_VEH_stat_mortar_light, ["RHS_M252_D"]];
_veh set [T_VEH_stat_mortar_heavy, ["RHS_M119_D"]];

//TODO remove HIDF markings from UH1 via garage, move UH1 to reserve
_veh set [T_VEH_heli_light, ["FGN_AAF_KA60_unarmed","rhs_uh1h_hidf"]];
_veh set [T_VEH_heli_heavy, ["FGN_AAF_KA60_dynamicLoadout","rhs_uh1h_hidf_gunship"]];
_veh set [T_VEH_heli_cargo, ["FGN_AAF_KA60_unarmed","rhs_uh1h_hidf_unarmed"]];
_veh set [T_VEH_heli_attack, ["rhsgref_mi24g_CAS"]]; //TODO add dynamic loadout variants for more variety

_veh set [T_VEH_plane_attack, ["FGN_AAF_L159_dynamicLoadout"]];
_veh set [T_VEH_plane_fighter, ["FGN_AAF_L159_dynamicLoadout"]];
//_veh set [T_VEH_plane_cargo, ["TODO"]];
//_veh set [T_VEH_plane_unarmed, ["rhsgred_hidf_cessna_o3a"]];
//_veh set [T_VEH_plane_VTOL, ["TODO"]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
//_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

//TODO - move Ural to reserve
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
_group set [T_GROUP_DEFAULT, [configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad"]];

_group set [T_GROUP_inf_AA_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AA], [T_INF, T_INF_AA], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_AT_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_rifleman], [T_INF, T_INF_AT], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_rifle_squad,	[[[T_INF, T_INF_SL], [T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_GL], [T_INF, T_INF_LAT], [T_INF, T_INF_marksman], [T_INF, T_INF_medic], [T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_assault_squad,	[[[T_INF, T_INF_SL], [T_INF, T_INF_LMG], [T_INF, T_INF_epx], [T_INF, T_INF_engineer], [T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_epx], [T_INF, T_INF_engineer]]]];
_group set [T_GROUP_inf_weapons_squad,	[[[T_INF, T_INF_SL], [T_INF, T_INF_TL], [T_INF, T_INF_MG], [T_INF, T_INF_ammo], [T_INF, T_INF_MG], [T_INF, T_INF_ammo],[T_INF, T_INF_AT], [T_INF, T_INF_ammo] ]]];
_group set [T_GROUP_inf_fire_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];
_group set [T_GROUP_inf_sentry,			[[[T_INF, T_INF_TL], [T_INF, T_INF_GL]]]];
_group set [T_GROUP_inf_sniper_team,	[[[T_INF, T_INF_sniper], [T_INF, T_INF_spotter]]]];

_group set [T_GROUP_inf_recon_patrol,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT]]]];
_group set [T_GROUP_inf_recon_sentry,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_LAT] ]]];
_group set [T_GROUP_inf_recon_squad,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT],  [T_INF, T_INF_recon_JTAC], [T_INF, T_INF_recon_exp],]]];
_group set [T_GROUP_inf_recon_team,		[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], , [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT], [T_INF, T_INF_recon_exp] ]]];


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];
_array set [T_NAME, "tRHS_AAF2017_elite"];

_inv = /* Exported with t_fnc_processTemplateItems for template tRHS_AAF2017_elite
Primary weapons
Primary weapon items
Secondary weapons
Secondary weapon items
Handguns
Handgun items
General items */
[
	[
		[
			"rhs_weap_m21a",
			[
				"rhsgref_30rnd_556x45_m21",
				"rhsgref_30rnd_556x45_m21_t"
			]
		],
		[
			"rhs_weap_m21s",
			[
				"rhsgref_30rnd_556x45_m21",
				"rhsgref_30rnd_556x45_m21_t"
			]
		],
		[
			"rhs_weap_m21a_pbg40",
			[
				"rhsgref_30rnd_556x45_m21",
				"rhsgref_30rnd_556x45_m21_t"
			]
		],
		[
			"rhs_weap_svdp",
			[
				"rhs_10Rnd_762x54mmR_7N1",
				"rhs_10Rnd_762x54mmR_7N14"
			]
		],
		[
			"rhs_weap_t5000",
			[
				"rhs_5Rnd_338lapua_t5000"
			]
		],
		[
			"rhs_weap_g36kv",
			[
				"rhssaf_30rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SOST_G36",
				"rhssaf_100rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SPR_G36",
				"rhssaf_30rnd_556x45_Tracers_G36",
				"rhssaf_30rnd_556x45_MDIM_G36",
				"rhssaf_30rnd_556x45_TDIM_G36",
				"150Rnd_556x45_Drum_Mag_F",
				"150Rnd_556x45_Drum_Mag_Tracer_F"
			]
		],
		[
			"rhs_weap_m249",
			[
				"rhsusf_200Rnd_556x45_box",
				"rhsusf_200rnd_556x45_mixed_box",
				"rhsusf_200rnd_556x45_M855_box",
				"rhsusf_200rnd_556x45_M855_mixed_box",
				"rhsusf_200Rnd_556x45_soft_pouch",
				"rhsusf_200Rnd_556x45_mixed_soft_pouch",
				"rhsusf_200Rnd_556x45_M855_soft_pouch",
				"rhsusf_200Rnd_556x45_M855_mixed_soft_pouch",
				"rhsusf_200Rnd_556x45_soft_pouch_ucp",
				"rhsusf_200Rnd_556x45_mixed_soft_pouch_ucp",
				"rhsusf_200Rnd_556x45_M855_soft_pouch_ucp",
				"rhsusf_200Rnd_556x45_M855_mixed_soft_pouch_ucp",
				"rhsusf_200Rnd_556x45_soft_pouch_coyote",
				"rhsusf_200Rnd_556x45_mixed_soft_pouch_coyote",
				"rhsusf_200Rnd_556x45_M855_soft_pouch_coyote",
				"rhsusf_200Rnd_556x45_M855_mixed_soft_pouch_coyote",
				"rhsusf_100Rnd_556x45_soft_pouch",
				"rhsusf_100Rnd_556x45_mixed_soft_pouch",
				"rhsusf_100Rnd_556x45_M855_soft_pouch",
				"rhsusf_100Rnd_556x45_M855_mixed_soft_pouch",
				"rhsusf_100Rnd_556x45_M200_soft_pouch",
				"rhsusf_100Rnd_556x45_soft_pouch_ucp",
				"rhsusf_100Rnd_556x45_mixed_soft_pouch_ucp",
				"rhsusf_100Rnd_556x45_M855_soft_pouch_ucp",
				"rhsusf_100Rnd_556x45_M855_mixed_soft_pouch_ucp",
				"rhsusf_100Rnd_556x45_M200_soft_pouch_ucp",
				"rhsusf_100Rnd_556x45_soft_pouch_coyote",
				"rhsusf_100Rnd_556x45_mixed_soft_pouch_coyote",
				"rhsusf_100Rnd_556x45_M855_soft_pouch_coyote",
				"rhsusf_100Rnd_556x45_M855_mixed_soft_pouch_coyote",
				"rhsusf_100Rnd_556x45_M200_soft_pouch_coyote",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M855_Stanag",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Tracer_Red",
				"rhs_mag_30Rnd_556x45_Mk318_Stanag",
				"rhs_mag_30Rnd_556x45_Mk262_Stanag",
				"rhs_mag_30Rnd_556x45_M193_Stanag",
				"rhs_mag_30Rnd_556x45_M196_Stanag_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M200_Stanag",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Pull",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Pull_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Pull",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Pull_Tracer_Red",
				"rhs_mag_30Rnd_556x45_Mk318_Stanag_Pull",
				"rhs_mag_30Rnd_556x45_Mk262_Stanag_Pull",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Ranger",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Ranger_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Ranger",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Ranger_Tracer_Red",
				"rhs_mag_30Rnd_556x45_Mk318_Stanag_Ranger",
				"rhs_mag_30Rnd_556x45_Mk262_Stanag_Ranger",
				"rhs_mag_30Rnd_556x45_M855A1_EPM",
				"rhs_mag_30Rnd_556x45_M855A1_EPM_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M855A1_EPM_Pull",
				"rhs_mag_30Rnd_556x45_M855A1_EPM_Pull_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M855A1_EPM_Ranger",
				"rhs_mag_30Rnd_556x45_M855A1_EPM_Ranger_Tracer_Red",
				"rhs_mag_30Rnd_556x45_Mk318_SCAR",
				"rhs_mag_30Rnd_556x45_Mk318_SCAR_Pull",
				"rhs_mag_30Rnd_556x45_Mk318_SCAR_Ranger",
				"rhs_mag_30Rnd_556x45_M855A1_PMAG",
				"rhs_mag_30Rnd_556x45_M855A1_PMAG_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M855_PMAG",
				"rhs_mag_30Rnd_556x45_M855_PMAG_Tracer_Red",
				"rhs_mag_30Rnd_556x45_Mk318_PMAG",
				"rhs_mag_30Rnd_556x45_Mk262_PMAG",
				"rhs_mag_30Rnd_556x45_M855A1_PMAG_Tan",
				"rhs_mag_30Rnd_556x45_M855A1_PMAG_Tan_Tracer_Red",
				"rhs_mag_30Rnd_556x45_M855_PMAG_Tan",
				"rhs_mag_30Rnd_556x45_M855_PMAG_Tan_Tracer_Red",
				"rhs_mag_30Rnd_556x45_Mk318_PMAG_Tan",
				"rhs_mag_30Rnd_556x45_Mk262_PMAG_Tan",
				"rhs_mag_20Rnd_556x45_M193_Stanag",
				"rhs_mag_20Rnd_556x45_M196_Stanag_Tracer_Red",
				"rhs_mag_20Rnd_556x45_M855_Stanag",
				"rhs_mag_20Rnd_556x45_M855A1_Stanag",
				"rhs_mag_20Rnd_556x45_Mk262_Stanag",
				"rhs_mag_20Rnd_556x45_M200_Stanag",
				"rhs_mag_20Rnd_556x45_M193_2MAG_Stanag",
				"rhs_mag_20Rnd_556x45_M196_2MAG_Stanag_Tracer_Red",
				"30Rnd_556x45_Stanag",
				"30Rnd_556x45_Stanag_Tracer_Red",
				"30Rnd_556x45_Stanag_Tracer_Green",
				"30Rnd_556x45_Stanag_Tracer_Yellow",
				"rhs_200rnd_556x45_M_SAW",
				"rhs_200rnd_556x45_T_SAW",
				"rhs_200rnd_556x45_B_SAW",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_No_Tracer",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Tracer_Green",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Tracer_Yellow",
				"rhs_mag_30Rnd_556x45_M855A1_Stanag_Tracer_Orange",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Tracer_Green",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Tracer_Yellow",
				"rhs_mag_30Rnd_556x45_M855_Stanag_Tracer_Orange"
			]
		],
		[
			"rhs_weap_pkp",
			[
				"rhs_100Rnd_762x54mmR",
				"rhs_100Rnd_762x54mmR_green",
				"rhs_100Rnd_762x54mmR_7N13",
				"rhs_100Rnd_762x54mmR_7N26",
				"rhs_100Rnd_762x54mmR_7BZ3"
			]
		],
		[
			"rhs_weap_savz61",
			[
				"rhsgref_20rnd_765x17_vz61",
				"rhsgref_10rnd_765x17_vz61"
			]
		],
		[
			"rhs_weap_g36c",
			[
				"rhssaf_30rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SOST_G36",
				"rhssaf_100rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SPR_G36",
				"rhssaf_30rnd_556x45_Tracers_G36",
				"rhssaf_30rnd_556x45_MDIM_G36",
				"rhssaf_30rnd_556x45_TDIM_G36",
				"150Rnd_556x45_Drum_Mag_F",
				"150Rnd_556x45_Drum_Mag_Tracer_F"
			]
		],
		[
			"rhs_weap_g36kv_grip1",
			[
				"rhssaf_30rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SOST_G36",
				"rhssaf_100rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SPR_G36",
				"rhssaf_30rnd_556x45_Tracers_G36",
				"rhssaf_30rnd_556x45_MDIM_G36",
				"rhssaf_30rnd_556x45_TDIM_G36",
				"150Rnd_556x45_Drum_Mag_F",
				"150Rnd_556x45_Drum_Mag_Tracer_F"
			]
		],
		[
			"rhs_weap_m24sws",
			[
				"rhsusf_5Rnd_762x51_m118_special_Mag",
				"rhsusf_5Rnd_762x51_m993_Mag",
				"rhsusf_5Rnd_762x51_m62_Mag"
			]
		],
		[
			"rhs_weap_g36kv_ag36",
			[
				"rhssaf_30rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SOST_G36",
				"rhssaf_100rnd_556x45_EPR_G36",
				"rhssaf_30rnd_556x45_SPR_G36",
				"rhssaf_30rnd_556x45_Tracers_G36",
				"rhssaf_30rnd_556x45_MDIM_G36",
				"rhssaf_30rnd_556x45_TDIM_G36",
				"150Rnd_556x45_Drum_Mag_F",
				"150Rnd_556x45_Drum_Mag_Tracer_F"
			]
		]
	],
	[
		"rhs_acc_2dpZenit",
		"rhs_acc_pkas",
		"rhs_acc_pso1m2",
		"rhs_acc_dh520x56",
		"rhs_acc_harris_swivel",
		"rhs_acc_2dpZenit_ris",
		"rhsusf_acc_eotech_xps3",
		"rhsusf_acc_saw_bipod",
		"rhs_acc_perst3",
		"rhsusf_acc_g33_xps3",
		"rhsusf_acc_grip1",
		"rhsusf_acc_m24_silencer_black",
		"rhsusf_acc_M8541_low",
		"rhsusf_acc_harris_swivel"
	],
	[
		[
			"rhs_weap_rpg75",
			[
				"rhs_rpg75_mag"
			]
		],
		[
			"FGN_AAF_CarlGustav",
			[
				"rhs_mag_maaws_HEAT",
				"rhs_mag_maaws_HEDP",
				"rhs_mag_maaws_HE"
			]
		],
		[
			"rhs_weap_igla",
			[
				"rhs_mag_9k38_rocket"
			]
		]
	],
	[
		"rhs_optic_maaws"
	],
	[
		[
			"rhsusf_weap_glock17g4",
			[
				"rhsusf_mag_17Rnd_9x19_JHP",
				"rhsusf_mag_17Rnd_9x19_FMJ"
			]
		],
		[
			"rhs_weap_makarov_pm",
			[
				"rhs_mag_9x18_8_57N181S"
			]
		]
	],
	[
	],
	[
		"ItemGPS",
		"Binocular",
		"rhs_pdu4"
	]
];

_array set [T_INV, _inv];

_array // End template

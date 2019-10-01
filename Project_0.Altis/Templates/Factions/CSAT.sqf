/*
CSAT templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil]; //Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; //Make an array full of nil
_inf set [T_INF_DEFAULT,  ["O_Soldier_F"]];		//Default infantry if nothing is found

_inf set [T_INF_SL, ["O_Soldier_SL_F"]];
_inf set [T_INF_TL, ["O_Soldier_TL_F"]];
_inf set [T_INF_officer, ["O_officer_F"]];
_inf set [T_INF_GL, ["O_Soldier_GL_F"]];
_inf set [T_INF_rifleman, ["O_Soldier_F"]];
_inf set [T_INF_marksman, ["O_soldier_M_F"]];
_inf set [T_INF_sniper, ["O_ghillie_ard_F"]];
_inf set [T_INF_spotter, ["O_spotter_F"]];
_inf set [T_INF_exp, ["O_soldier_exp_F"]];
_inf set [T_INF_ammo, ["O_Soldier_A_F"]];
_inf set [T_INF_LAT, ["O_Soldier_LAT_F"]];
_inf set [T_INF_AT, ["O_Soldier_HAT_F"]];
_inf set [T_INF_AA, ["O_Soldier_AA_F"]];
_inf set [T_INF_LMG, ["O_Soldier_AR_F"]];
_inf set [T_INF_HMG, ["O_HeavyGunner_F"]];
_inf set [T_INF_medic, ["O_medic_F"]];
_inf set [T_INF_engineer, ["O_engineer_F"]];
_inf set [T_INF_crew, ["O_crew_F"]];
_inf set [T_INF_crew_heli, ["O_helicrew_F"]];
_inf set [T_INF_pilot, ["O_Pilot_F"]];
_inf set [T_INF_pilot_heli, ["O_helipilot_F"]];
_inf set [T_INF_survivor, ["O_Survivor_F"]];
_inf set [T_INF_unarmed, ["O_Soldier_unarmed_F"]];

//Recon
_inf set [T_INF_recon_TL, ["O_recon_TL_F"]];
_inf set [T_INF_recon_rifleman, ["O_recon_F"]];
_inf set [T_INF_recon_medic, ["O_recon_medic_F"]];
_inf set [T_INF_recon_exp, ["O_recon_exp_F"]];
_inf set [T_INF_recon_LAT, ["O_recon_LAT_F"]];
_inf set [T_INF_recon_marksman, ["O_recon_M_F"]];
_inf set [T_INF_recon_JTAC, ["O_recon_JTAC_F"]];

//Divers
_inf set [T_INF_diver_TL, ["O_diver_TL_F"]];
_inf set [T_INF_diver_rifleman, ["O_diver_F"]];
_inf set [T_INF_diver_exp, ["O_diver_exp_F"]];


//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["O_MRAP_02_F"]];

_veh set [T_VEH_car_unarmed, ["O_LSV_02_unarmed_F"]];
_veh set [T_VEH_car_armed, ["O_LSV_02_armed_F", "O_LSV_02_AT_F"]];
_veh set [T_VEH_MRAP_unarmed, ["O_MRAP_02_F"]];
_veh set [T_VEH_MRAP_HMG, ["O_MRAP_02_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["O_MRAP_02_gmg_F"]];
_veh set [T_VEH_IFV, ["O_APC_Tracked_02_cannon_F"]];
_veh set [T_VEH_APC, ["O_APC_Wheeled_02_rcws_v2_F"]];
_veh set [T_VEH_MBT, ["O_MBT_04_cannon_F", "O_MBT_04_command_F", "O_MBT_02_cannon_F"]];
_veh set [T_VEH_MRLS, ["O_MBT_02_arty_F"]];
_veh set [T_VEH_SPA, ["O_MBT_02_arty_F"]];
_veh set [T_VEH_SPAA, ["O_APC_Tracked_02_AA_F"]];
_veh set [T_VEH_stat_HMG_high, ["O_HMG_01_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["O_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["O_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["O_GMG_01_F"]];
_veh set [T_VEH_stat_AA, ["O_static_AA_F"]];
_veh set [T_VEH_stat_AT, ["O_static_AT_F"]];
_veh set [T_VEH_stat_mortar_light, ["O_Mortar_01_F"]];
//_veh set [T_VEH_stat_mortar_heavy, ["O_Mortar_01_F"]];
_veh set [T_VEH_heli_light, ["O_Heli_Light_02_dynamicLoadout_F"]];
_veh set [T_VEH_heli_heavy, ["O_Heli_Transport_04_covered_F", "O_Heli_Transport_04_bench_F"]];
_veh set [T_VEH_heli_cargo, ["O_Heli_Transport_04_box_F"]];
_veh set [T_VEH_heli_attack, ["O_Heli_Attack_02_dynamicLoadout_F"]];
_veh set [T_VEH_plane_attack, ["O_Plane_CAS_02_dynamicLoadout_F"]];
_veh set [T_VEH_plane_fighter , ["O_Plane_Fighter_02_F"]];
_veh set [T_VEH_plane_cargo, ["O_T_VTOL_02_infantry_dynamicLoadout_F"]];
_veh set [T_VEH_plane_unarmed , ["O_T_VTOL_02_infantry_dynamicLoadout_F"]];
_veh set [T_VEH_plane_VTOL, ["O_T_VTOL_02_infantry_dynamicLoadout_F"]];
_veh set [T_VEH_boat_unarmed, ["O_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["O_Boat_Armed_01_hmg_F"]];
_veh set [T_VEH_personal, ["O_Quadbike_01_F"]];
_veh set [T_VEH_truck_inf, ["O_Truck_03_transport_F", "O_Truck_03_covered_F", "O_Truck_02_transport_F", "O_Truck_02_covered_F"]];
_veh set [T_VEH_truck_cargo, ["O_Truck_03_transport_F"]];
_veh set [T_VEH_truck_ammo, ["O_Truck_03_ammo_F", "O_Truck_02_Ammo_F"]];
_veh set [T_VEH_truck_repair, ["O_Truck_03_repair_F", "O_Truck_02_box_F"]];
_veh set [T_VEH_truck_medical , ["O_Truck_03_medical_F", "O_Truck_02_medical_F"]];
_veh set [T_VEH_truck_fuel, ["O_Truck_03_fuel_F", "O_Truck_02_fuel_F"]];
_veh set [T_VEH_submarine, ["O_SDV_01_F"]];


//==== Drones ====
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["O_UAV_01_F"]];

_drone set [T_DRONE_UGV_unarmed, ["O_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["O_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["O_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["O_T_UAV_04_CAS_F"]];
_drone set [T_DRONE_quadcopter, ["O_UAV_01_F"]];
_drone set [T_DRONE_designator, ["O_Static_Designator_02_F"]];
_drone set [T_DRONE_stat_HMG_low, ["O_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["O_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["O_SAM_System_04_F"]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [configfile >> "CfgGroups" >> "East" >> "BLU_F" >> "Infantry" >> "Bus_InfSquad"]];

_group set [T_GROUP_inf_AA_team, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AA"]];
_group set [T_GROUP_inf_AT_team, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AT"]];
_group set [T_GROUP_inf_rifle_squad, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"]];
_group set [T_GROUP_inf_assault_squad, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfAssault"]];
_group set [T_GROUP_inf_weapons_squad, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad_Weapons"]];
_group set [T_GROUP_inf_fire_team, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam"]];
_group set [T_GROUP_inf_recon_patrol, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_reconPatrol"]];
_group set [T_GROUP_inf_recon_sentry, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_reconSentry"]];
_group set [T_GROUP_inf_recon_squad, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_ReconSquad"]];
_group set [T_GROUP_inf_recon_team, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_reconTeam"]];
_group set [T_GROUP_inf_sentry, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSentry"]];
_group set [T_GROUP_inf_sniper_team, [configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_SniperTeam"]];


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];
_array set [T_NAME, "tCSAT"];


_inv = /* Exported with t_fnc_processTemplateItems for template tCSAT
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
			"arifle_Katiba_ACO_pointer_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_ARCO_pointer_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_GL_ARCO_pointer_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_C_ACO_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_GL_ACO_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"srifle_DMR_01_DMS_BI_F",
			[
				"10Rnd_762x54_Mag"
			]
		],
		[
			"srifle_GM6_camo_LRPS_F",
			[
				"5Rnd_127x108_Mag",
				"5Rnd_127x108_APDS_Mag"
			]
		],
		[
			"arifle_Katiba_ARCO_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_C_ACO_pointer_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_ACO_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"LMG_Zafir_pointer_F",
			[
				"150Rnd_762x54_Box",
				"150Rnd_762x54_Box_Tracer"
			]
		],
		[
			"MMG_01_hex_ARCO_LP_F",
			[
				"150Rnd_93x64_Mag"
			]
		],
		[
			"arifle_Katiba_pointer_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_C_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"SMG_02_ACO_F",
			[
				"30Rnd_9x21_Mag_SMG_02",
				"30Rnd_9x21_Mag_SMG_02_Tracer_Red",
				"30Rnd_9x21_Mag_SMG_02_Tracer_Yellow",
				"30Rnd_9x21_Mag_SMG_02_Tracer_Green",
				"30Rnd_9x21_Mag",
				"30Rnd_9x21_Red_Mag",
				"30Rnd_9x21_Yellow_Mag",
				"30Rnd_9x21_Green_Mag"
			]
		],
		[
			"arifle_Katiba_ARCO_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_ACO_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_Katiba_C_ACO_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"srifle_DMR_01_DMS_snds_BI_F",
			[
				"10Rnd_762x54_Mag"
			]
		],
		[
			"arifle_Katiba_GL_ACO_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_green",
				"30Rnd_65x39_caseless_green_mag_Tracer"
			]
		],
		[
			"arifle_SDAR_F",
			[
				"20Rnd_556x45_UW_mag",
				"30Rnd_556x45_Stanag",
				"30Rnd_556x45_Stanag_Tracer_Red",
				"30Rnd_556x45_Stanag_Tracer_Green",
				"30Rnd_556x45_Stanag_Tracer_Yellow",
				"30Rnd_556x45_Stanag_green",
				"30Rnd_556x45_Stanag_red"
			]
		]
	],
	[
		"acc_pointer_IR",
		"optic_ACO_grn",
		"optic_Arco_blk_F",
		"optic_DMS",
		"bipod_02_F_blk",
		"optic_LRPS",
		"optic_Arco",
		"bipod_02_F_hex",
		"optic_ACO_grn_smg",
		"muzzle_snds_H",
		"muzzle_snds_B"
	],
	[
		[
			"launch_RPG32_F",
			[
				"RPG32_F",
				"RPG32_HE_F"
			]
		],
		[
			"launch_O_Vorona_brown_F",
			[
				"Vorona_HEAT",
				"Vorona_HE"
			]
		],
		[
			"launch_O_Titan_F",
			[
				"Titan_AA"
			]
		]
	],
	[
	],
	[
		[
			"hgun_Rook40_F",
			[
				"16Rnd_9x21_Mag",
				"16Rnd_9x21_red_Mag",
				"16Rnd_9x21_green_Mag",
				"16Rnd_9x21_yellow_Mag",
				"30Rnd_9x21_Mag",
				"30Rnd_9x21_Red_Mag",
				"30Rnd_9x21_Yellow_Mag",
				"30Rnd_9x21_Green_Mag"
			]
		],
		[
			"hgun_Pistol_heavy_02_Yorris_F",
			[
				"6Rnd_45ACP_Cylinder"
			]
		],
		[
			"hgun_Rook40_snds_F",
			[
				"16Rnd_9x21_Mag",
				"16Rnd_9x21_red_Mag",
				"16Rnd_9x21_green_Mag",
				"16Rnd_9x21_yellow_Mag",
				"30Rnd_9x21_Mag",
				"30Rnd_9x21_Red_Mag",
				"30Rnd_9x21_Yellow_Mag",
				"30Rnd_9x21_Green_Mag"
			]
		]
	],
	[
		"optic_Yorris",
		"muzzle_snds_L"
	],
	[
		"NVGoggles_OPFOR",
		"ItemGPS",
		"Binocular",
		"Rangefinder",
		"Laserdesignator_02"
	]
];

_array set [T_INV, _inv];

_array

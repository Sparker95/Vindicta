/*
NATO templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = [];
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT,  ["B_Soldier_F"]];					//Default infantry if nothing is found


//Recon

//Divers


//==== Vehicles ====

_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["B_MRAP_01_F"]];

_veh set [T_VEH_car_unarmed, ["B_MRAP_01_F"]];
_veh set [T_VEH_car_armed, ["B_MRAP_01_hmg_F"]];
_veh set [T_VEH_MRAP_unarmed, ["B_MRAP_01_F"]];
_veh set [T_VEH_MRAP_HMG, ["B_MRAP_01_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["B_MRAP_01_gmg_F"]];
_veh set [T_VEH_IFV, ["B_APC_Wheeled_01_cannon_F"]]; //Marshal IFV
_veh set [T_VEH_APC, ["B_APC_Tracked_01_rcws_F"]]; //Panther
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]];
_veh set [T_VEH_MRLS, ["B_MBT_01_mlrs_F"]];
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]];
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F"]];
_veh set [T_VEH_stat_HMG_high, ["B_HMG_01_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["B_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]];
_veh set [T_VEH_stat_AA, ["B_static_AA_F"]];
_veh set [T_VEH_stat_AT, ["B_static_AT_F"]];
_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
//_veh set [T_VEH_stat_mortar_heavy, ["B_Mortar_01_F"]];
_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F"]];
_veh set [T_VEH_heli_heavy, ["B_Heli_Transport_01_F"]];
_veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F"]];
_veh set [T_VEH_heli_attack, ["B_Heli_Attack_01_dynamicLoadout_F"]];
_veh set [T_VEH_plane_attack, ["B_Plane_CAS_01_dynamicLoadout_F"]];
_veh set [T_VEH_plane_fighter , ["B_Plane_Fighter_01_F"]];
//_veh set [T_VEH_plane_cargo, [" "]];
//_veh set [T_VEH_plane_unarmed , [" "]];
//_veh set [T_VEH_plane_VTOL, [" "]];
_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];
_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];
_veh set [T_VEH_truck_inf, ["B_Truck_01_transport_F", "B_Truck_01_covered_F"]];
_veh set [T_VEH_truck_cargo, ["B_Truck_01_transport_F"]];
_veh set [T_VEH_truck_ammo, ["B_Truck_01_ammo_F"]];
_veh set [T_VEH_truck_repair, ["B_Truck_01_Repair_F"]];
_veh set [T_VEH_truck_medical , ["B_Truck_01_medical_F"]];
_veh set [T_VEH_truck_fuel, ["B_Truck_01_fuel_F"]];
_veh set [T_VEH_submarine, ["B_SDV_01_F"]];


//==== Drones ====
_drone = [];
_drone set [T_DRONE_SIZE-1, nil];
_veh set [T_DRONE_DEFAULT , ["B_UAV_01_F"]];

_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]];
_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];
_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]];
_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];

//==== Cargo ====
_cargo = [];

// Note that we have increased their capacity through the addon, other boxes are going to have reduced capacity
_cargo set [T_CARGO_default,	["I_supplyCrate_F"]];
_cargo set [T_CARGO_box_small,	["Box_Syndicate_Ammo_F"]];
_cargo set [T_CARGO_box_medium,	["I_supplyCrate_F"]];
_cargo set [T_CARGO_box_big,	["B_CargoNet_01_ammo_F"]];

//==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "Bus_InfSquad"]];

_group set [T_GROUP_inf_AA_team, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfTeam_AA"]];
_group set [T_GROUP_inf_AT_team, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfTeam_AT"]];
_group set [T_GROUP_inf_rifle_squad, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad"]];
_group set [T_GROUP_inf_assault_squad, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfAssault"]];
_group set [T_GROUP_inf_weapons_squad, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad_Weapons"]];
_group set [T_GROUP_inf_fire_team, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfTeam"]];
_group set [T_GROUP_inf_recon_patrol, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_ReconPatrol"]];
_group set [T_GROUP_inf_recon_sentry, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_ReconSentry"]];
_group set [T_GROUP_inf_recon_squad, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_ReconSquad"]];
_group set [T_GROUP_inf_recon_team, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_ReconTeam"]];
_group set [T_GROUP_inf_sentry, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSentry"]];
_group set [T_GROUP_inf_sniper_team, [configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_SniperTeam"]];


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];
_array set [T_NAME, "tDefault"];



// Inventory items
_inv = /* Exported with t_fnc_processTemplateItems for template tNATO
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
			"arifle_MX_ACO_pointer_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MX_Hamr_pointer_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MX_GL_Hamr_pointer_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MXC_ACO_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MX_GL_ACO_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MXM_Hamr_LP_BI_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"srifle_DMR_03_tan_AMS_LP_F",
			[
				"20Rnd_762x51_Mag"
			]
		],
		[
			"arifle_MX_ACO_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MXC_Holo_pointer_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MX_SW_pointer_F",
			[
				"100Rnd_65x39_caseless_mag"
			]
		],
		[
			"MMG_02_sand_RCO_LP_F",
			[
				"130Rnd_338_Mag"
			]
		],
		[
			"arifle_MX_pointer_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MXC_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MXC_Holo_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"SMG_01_Holo_F",
			[
				"30Rnd_45ACP_Mag_SMG_01",
				"30Rnd_45ACP_Mag_SMG_01_tracer_green",
				"30Rnd_45ACP_Mag_SMG_01_Tracer_Red",
				"30Rnd_45ACP_Mag_SMG_01_Tracer_Yellow"
			]
		],
		[
			"arifle_MX_RCO_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MX_ACO_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MXC_ACO_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MXM_DMS_LP_BI_snds_F",
			[
				"30Rnd_65x39_caseless_mag"
			]
		],
		[
			"arifle_MX_GL_Holo_pointer_snds_F",
			[
				"30Rnd_65x39_caseless_mag"
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
		"optic_Aco",
		"optic_Hamr",
		"bipod_01_F_snd",
		"optic_AMS_snd",
		"optic_Holosight",
		"optic_Holosight_smg",
		"muzzle_snds_H",
		"optic_DMS"
	],
	[
		[
			"launch_MRAWS_sand_F",
			[
				"MRAWS_HEAT_F",
				"MRAWS_HE_F",
				"MRAWS_HEAT55_F"
			]
		],
		[
			"launch_NLAW_F",
			[
				"NLAW_F"
			]
		],
		[
			"launch_B_Titan_F",
			[
				"Titan_AA"
			]
		]
	],
	[
	],
	[
		[
			"hgun_P07_F",
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
			"hgun_Pistol_heavy_01_MRD_F",
			[
				"11Rnd_45ACP_Mag"
			]
		],
		[
			"hgun_P07_snds_F",
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
		"optic_MRD",
		"muzzle_snds_L"
	],
	[
		"NVGoggles",
		"ItemGPS",
		"Binocular",
		"Rangefinder",
		"Laserdesignator"
	]
];

_array set [T_INV, _inv];



_array // End template

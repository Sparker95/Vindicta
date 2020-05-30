/*
Building positions suitable for specific roles.

Each building position is structered:
	[_buildingPosID, _direction]
		_buildingPosID - number of the building position returned by buildingPos command.
		_direction - hte direction where the unit must be heading relative to the building's position.
	OR it can be specified in cylindrical coordinates relative to building's center:
	[_offset, _offsetDirection, _offsetHeight, _direction]
		_offset - the magnitude of the offset projected onto horizontal plane.
		_offsetDirection - the direction of the offset.
		_offsetHeight - the height of the offset.
		_direction - direction where the unit must be heading relative to the building's position.

The structure of each array with positions for specific type is:
	[[_typesArray, _positionArray], [_typesArray, _positionArray], ...]
		_typesArray - the array of types (typeOf ...) of this building sharing the same building positions. For example, different variants of the same watchtower.
		_positioArray - the array of positions in the form [_buildingPosID, _direction] or [_offset, _offsetDirection, _offsetHeight, _direction]
*/

//Positions where a high GMG or a high HMG can be placed and operated from.
location_bp_HGM_GMG_high =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		[[11, 90], [13, 0], [14, 0], [16, 180], [17, 180]]
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		[[1.9, 220, 4.4, 180], [1.9, 130, 4.4, 180]]
	]

	/*
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		[[4, 90], [5, 0], [6, -45], [7, 225], [8, 180]]
	]
	*/
];

//Positions where soldiers can freely shoot from.
//Note that soldiers can also shoot well from HMG positions.
location_bp_sentry =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		[[0, 0], [1, 0], [10, 180], [12, 0], [15, 270], [2, 0], [4, 180], [7, 90], [8, 270]]
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		[[0, 180], [1, 180]]
	],
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		[[4, 90], [5, 0], [6, -45], [7, 225], [8, 180]]
	],
	//Global Mobilization
	[ 
		["land_gm_tower_bt_6_fuest_80"],
		[[2, 280], [3, 180], [4, 0]]
	],
	[ 
		["land_gm_tower_bt_11_60"],
		[[0, 180], [1, 180]]
	]	
];

// Capacities of buildings for infantry
// Typically a building's inf capacity is amount of its buildingPos, however for some buildings we can override that here
location_b_capacity =
[
	// The giant military tower
	[
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		14
	],
	// The small military watchtower
	[
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		2
	],
	// The military HQ
	[
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		10
	],
	// The military metal box
	[
		["Land_Cargo_House_V1_F", "Land_Cargo_House_V2_F", "Land_Cargo_House_V3_F"],
		4
	],
	// Small tents
	[
		[
			"Land_TentA_F"
		],
		2
	],
	// Medium tents
	[
		[
			"Land_TentDome_F"
		],
		4
	],
	// Big tents
	[
		[
			"Land_MedicalTent_01_aaf_generic_open_F",
			"Land_MedicalTent_01_CSAT_brownhex_generic_open_F",
			"Land_MedicalTent_01_NATO_generic_open_F",
			"Land_MedicalTent_01_wdl_generic_open_F",

			"Land_MedicalTent_01_MTP_closed_F",
			"Land_MedicalTent_01_digital_closed_F",
			"Land_MedicalTent_01_brownhex_closed_F",
			"Land_DeconTent_01_wdl_F",
			"Land_MedicalTent_01_wdl_closed_F",

			"Land_MedicalTent_01_white_generic_closed_F",
			"Land_MedicalTent_01_NATO_generic_closed_F",
			"Land_MedicalTent_01_NATO_tropic_generic_closed_F",
			"Land_MedicalTent_01_NATO_generic_outer_F",
			"Land_MedicalTent_01_NATO_generic_inner_F",
			"Land_DeconTent_01_NATO_F",
			"Land_MedicalTent_01_NATO_tropic_generic_outer_F",
			"Land_MedicalTent_01_wdl_generic_inner_F",
			"Land_DeconTent_01_NATO_tropic_F",
			"Land_MedicalTent_01_white_generic_outer_F",
			"Land_MedicalTent_01_white_generic_inner_F",
			"Land_DeconTent_01_white_F"
		],
		16
	],
	// WW2 & CUP
	[
		["Land_WW2_Mil_Barracks","Land_WW2_Mil_Barracks_L","Land_Mil_Barracks_L","Land_Mil_Barracks"],
		12
	],
	[
		["Land_Mil_Barracks_L","Land_Mil_Barracks"],
		12
	],
	// Global Mobilization
	[
		["gm_gc_tent_5x5m"],
		8
	]
	
];

// Positions for cargo boxes
location_bp_cargo_medium =
[
	[
		["Land_i_House_Small_01_V3_F", "Land_i_House_Small_01_V1_F", "Land_i_House_Small_01_V2_F", "Land_u_House_Small_01_V1_F"],
		[[2.07516,262.755,0.29788], [3.47262,218.056,0.29805]]
	],
	[
		["Land_i_House_Big_01_V1_F", "Land_i_House_Big_01_V2_F", "Land_i_House_Big_01_V3_F", "Land_u_House_Big_01_V1_F"],
		[[1.64695,117.933,0.498999], [5.47226,166.207,0.498999]]
	],
	[
		["Land_i_Stone_HouseBig_V1_F", "Land_i_Stone_HouseBig_V2_F", "Land_i_Stone_HouseBig_V3_F", "Land_u_Stone_HouseBig_V3_F"],
		[[0.439735,11.0105,3.059], [3.10748,83.2502,3.059]]
	],
	[
		["Land_i_Stone_HouseSmall_V1_F", "Land_i_Stone_HouseSmall_V2_F", "Land_i_Stone_HouseSmall_V3_F", "Land_u_Stone_HouseSmall_V1_F"],
		[[7.5625,69.7211,1.26548], [4.66482,54.9392,1.2517]]
	],
	[
		["Land_i_House_Small_02_V1_F", "Land_i_House_Small_02_V2_F", "Land_i_House_Small_02_V3_F", "Land_u_House_Small_02_V1_F"],
		[[3.10205,87.7267,0.418344], [5.15135,88.892,0.420984]]
	],
	[
		["Land_i_Shop_01_V1_F", "Land_i_Shop_01_V2_F", "Land_i_Shop_01_V3_F", "Land_u_Shop_01_V1_F"],
		[[1.14865,286.802,0.302086], [3.6354,341.39,0.302084]]
	],
	[
		["Land_i_House_Big_02_V1_F", "Land_i_House_Big_02_V2_F", "Land_i_House_Big_02_V3_F", "Land_u_House_Big_02_V1_F"],
		[[3.55678,42.062,0.258254], [3.1946,326.951,0.258255]]
	],
	//Livonia
	[
		["Land_House_2B04_F"],
		[[5.99253,59.4126,0.864166], [3.9745,38.706,0.691895], [4.59203,319.578,0.42363]]
	],
	[
		["Land_PoliceStation_01_F"],
		[[2.60131,61.8427,1.29491], [7.02257,323.042,0.777817], [4.66018,296.356,0.788269], [7.448,319.591,4.42163], [8.1648,252.885,4.26756]]
	],
	[
		["Land_House_2B01_F"],
		[[2.77617,9.35841,3.06282,178],[4.26324,-52.7472,2.99702,178]]
	],
	[
		["Land_House_2B02_F"],
		[[5.74823,269.538,0.80466,277],[7.23981,311.342,0.719627,277]]
	],
	[
		["Land_House_2B03_F"],
		[[2.89228,58.1587,0.431929,277],[4.10528,336.563,0.487992,277]]
	],
	[
		["Land_House_1W11_F"],
		[[3.99131,227.826,0.530354,277],[4.8382,166.209,0.720686,277]]
	],
	[
		["Land_House_2W01_F"],
		[[2.41949,23.3003,-0.027451,277],[1.84093,312.087,3.16349,254]]
	],
	[
		["Land_House_2W02_F"],
		[[3.34215,102.899,3.76832,277],[7.27661,66.7277,3.93461,254]]
	],
	[
		["Land_House_2W03_F"],
		[[3.21333,278.881,5.15463,277],[8.12702,288.652,4.97206,254]]
	],
	[
		["Land_House_2W04_F"],
		[[7.01695,59.0301,5.39377,277],[2.36638,42.2737,5.3294,254]]
	],
	[
		["Land_House_2W05_F"],
		[[7.01695,59.0301,5.39377,277],[2.36638,42.2737,5.3294,254]]
	],
	[
		["Land_House_1W05_F"],
		[[1.16296,216.24,2.21642,277],[3.99501,88.256,2.08629,254]]
	],
	[
		["Land_House_1W09_F"],
		[[4.53478,240.31,0.535315,277],[5.01341,296.106,0.410556,254]]
	],
	[
		["Land_House_1W06_F"],
		[[3.41085,105.664,2.49447,0],[1.3797,255.531,2.13538,0]]
	],
	[
		["Land_House_1W07_F"],
		[[6.0655,199.174,0.78577,0],[4.42128,262.831,0.439239,0]]
		
	],
	[
		["Land_House_1W08_F"],
		[[3.11381,353.987,0.425679,0],[3.18705,59.4668,0.808916,0]]
	],

	//WW2 Staszow
	[
		["Land_WW2_Admin"],
		[[2.64597,143.778,0.32269], [3.85001,153.389,0.32269], [5.09535,16.3686,0.32269], [3.9212,24.0332,0.32269]]
	],
	[
		["Land_WW2_Admin2"],
		[[4.82119,44.2476,0.233089], [4.11613,54.6484,0.233089], [4.62721,-40.6715,0.233089], [5.48119,-33.2937,0.233089], [4.23542,-133.858,0.233089], [5.042,-142.623,0.233089], [4.92659,-226.911,0.233089], [4.27249,-237.533,0.233089]]
	],
	// Beketov
	[
		["Land_HouseV2_02_Interier", "Land_HouseV2_02_Interier_dam"],
		[[4.21436,76.2874,0.973242], [6.86528,57.0615,0.973242], [6.2304,306.133,0.973242], [7.66948,288.97,0.973242]]
	],
	// Global Mobilization
	[
		["land_gm_euro_house_07_e",	"land_gm_euro_house_07_w",	"land_gm_euro_house_07_d"],
		[[1.80399,83.2539,0.326653,0.000132318], [2.01474,48.7239,0.336693,359.999], [2.47671,257.29,0.261368,359.999], [2.50627,292.908,0.280899,0.000150937]]
	],
	// CUP Takistan
	[
		["Land_House_L_6_EP1", "Land_House_L_6_dam_EP1"],
		[[4.70777,92.5443,0.361038,0],[2.13738,279.122,0.448914,0]]
	],
	[
		["Land_House_L_4_EP1", "Land_House_L_4_dam_EP1"],
		[[5.25441,71.0532,0.760803,0],[2.6514,3.12481,0.508163,0]]
	],
	[
		["Land_House_L_7_EP1", "Land_House_L_7_dam_EP1"],
		[[5.86802,222.248,0.152435,0],[2.62107,52.1737,0.788132,0]]
	],
	[
		["Land_House_L_8_EP1", "Land_House_L_8_dam_EP1"],
		[[1.73989,328.005,0.98259,0],[2.17966,5.6825,3.70102,0]]
	],
	[
		["Land_House_K_8_EP1", "Land_House_K_8_dam_EP1"],
		[[2.56369,113.03,6.20528,0],[1.15963,345.765,0.177826,0]]
	],
	[
		["Land_House_K_3_EP1", "Land_House_K_3_dam_EP1"],
		[[1.39592,136.276,0.530792,0],[4.38602,256.06,0.55954,0]]
	],
	[
		["Land_House_K_7_EP1", "Land_House_K_7_dam_EP1"],
		[[3.85782,314.077,-0.546814,0],[3.11222,330.692,3.01508,0]]
	],
	[
		["Land_House_C_11_EP1", "Land_House_C_11_dam_EP1"],
		[[6.27304,66.7475,0.262527,-200],[6.54936,118.458,0.209015,-200]]
	],
	[
		["Land_House_C_5_EP1", "Land_House_C_5_dam_EP1"],
		[[3.03165,241.569,0.31955,0],[4.31359,39.221,0.380096,0]]
	],
	[
		["Land_House_C_5_V1_dam_EP1", "Land_House_C_5_V1_EP1"],
		[[3.67072,40.0573,0.318497,0],[3.48948,234.362,0.224457,0]]
	],
	[
		["Land_House_C_5_V2_EP1", "Land_House_C_5_V2_dam_EP1"],
		[[4.1539,41.6168,0.349426,0],[3.59427,230.844,0.303391,0]]
	],
	[
		["Land_House_C_5_V3_EP1", "Land_House_C_5_V3_dam_EP1"],
		[[3.45883,236.691,0.267456,0],[4.1695,41.8575,0.370743,0]]
	],
	[
		["Land_A_Villa_EP1"],
		[[9.28798,55.69,-0.164932,0],[7.3773,22.4268,-0.114807,0]]
	],
	[
		["Land_A_Office01_EP1"],
		[[2.00421,171.933,0.202118,0],[7.18393,295.112,0.174194,0]]
	],
	[
		["Land_House_C_4_dam_EP1"],
		[[2.45109,115.309,0.608643,0],[2.65302,92.5528,3.76466,0]]
	],
	// CUP Chernarus
	[
		["Land_HouseV2_04_interier", "Land_HouseV2_04_interier_dam"],
		[[6.16649,329.451,0.34021,0],[5.45659,20.5788,0.327789,0]]
	]
];

// Buildings which can be used as police stations
location_bt_police = 
[
	// Altis
	"Land_i_Shop_01_V2_F",
	"Land_i_Shop_01_V3_F",
	"Land_u_Shop_01_V1_F",
	"Land_i_House_Small_01_V3_F",
	"Land_u_House_Small_01_V1_F",
	"Land_i_House_Small_01_V2_F",
	"Land_u_House_Big_02_V1_F",
	"Land_i_Stone_HouseBig_V3_F",
	"Land_i_Stone_HouseBig_V2_F",
	"Land_i_Stone_HouseBig_V1_F",
	"Land_u_House_Small_02_V1_F",
	"Land_i_House_Small_02_V1_F",
	"Land_i_House_Small_02_V3_F",
	"Land_i_House_Small_02_V2_F",
	"Land_i_House_Big_02_V3_F",
	"Land_i_House_Big_02_V2_F",
	"Land_i_House_Big_02_V1_F",
	"Land_i_Stone_HouseSmall_V3_F",
	"Land_i_Stone_HouseSmall_V1_F",
	"Land_i_Stone_HouseSmall_V2_F",
	"Land_i_House_Big_01_V1_F",
	"Land_i_House_Big_01_V2_F",
	"Land_u_House_Big_01_V1_F",
	"Land_i_House_Big_01_V3_F",

	//Livonia
	"Land_PoliceStation_01_F",
	"Land_House_2B04_F",

	// WW2 Staszo
	"Land_WW2_Admin",
	"Land_WW2_Admin2",
	"Land_House_2B01_F",
	"Land_House_2B02_F",
	"Land_House_2B03_F",
	"Land_House_1W11_F",
	"Land_House_2W01_F",
	"Land_House_2W02_F",
	"Land_House_2W03_F",
	"Land_House_2W04_F",
	"Land_House_2W05_F",
	"Land_House_1W05_F",
	"Land_House_1W09_F",
	"Land_House_1W06_F",
	"Land_House_1W07_F",
	"Land_House_1W08_F",
	
	// Beketov - CUP
	"Land_HouseV2_02_Interier",
	"Land_HouseV2_02_Interier_dam",

	// Global Mobilization
	"land_gm_euro_house_07_e",
	"land_gm_euro_house_07_w",
	"land_gm_euro_house_07_d",
	
	// Takistan
	"Land_House_L_6_EP1",
	"Land_House_L_6_dam_EP1",
	"Land_House_L_4_EP1",
	"Land_House_L_4_dam_EP1",
	"Land_House_L_7_EP1",
	"Land_House_L_7_dam_EP1",
	"Land_House_L_8_EP1",
	"Land_House_L_8_dam_EP1",
	"Land_House_K_8_EP1",
	"Land_House_K_3_EP1",
	"Land_House_K_3_dam_EP1",
	"Land_House_K_7_EP1",
	"Land_House_K_7_dam_EP1",
	"Land_House_C_11_EP1",
	"Land_House_C_11_dam_EP1",
	"Land_House_C_5_EP1",
	"Land_House_C_5_dam_EP1",
	"Land_House_C_5_V1_dam_EP1",
	"Land_House_C_5_V1_EP1",
	"Land_House_C_5_V2_EP1",
	"Land_House_C_5_V2_dam_EP1",
	"Land_House_C_5_V3_EP1",
	"Land_House_C_5_V3_dam_EP1",
	"Land_A_Villa_EP1",
	"Land_A_Office01_EP1",
	"Land_House_C_4_dam_EP1",
	// Chernarus
	"Land_HouseV2_04_interier",
	"Land_HouseV2_04_interier_dam"
];

location_decorations_police =
[
	[
		["Land_i_House_Small_02_V1_F","Land_u_House_Small_02_V1_F","Land_i_House_Small_02_V3_F","Land_i_House_Small_02_V2_F"],
		// Array of [_offset, _vectorDirAndUp]
		[[[2.3125,-3.76367,1.24133],[[0,1,0],[0,0,1]]],[[-4.01563,-0.691406,0.952689],[[0.999999,-0.00148479,0],[0,0,1]]],[[1.54102,3.30469,1.36593],[[-0.000931589,-1,0],[0,0,1]]]]
	],
	[
		["Land_u_Shop_01_V1_F"],
		[[[-0.4375,-2.74609,-0.0292983],[[0.0156359,0.999878,0],[0,0,1]]],[[-0.916016,7.36133,-0.708581],[[-0.0169196,-0.999857,0],[0,0,1]]]]
	],
	[
		["Land_i_Shop_01_V2_F","Land_i_Shop_01_V3_F","Land_i_Shop_01_V1_F"],
		[[[1.24414,-3.11523,0.059587],[[0,1,0],[0,0,1]]],[[1.15625,7.02734,-1.00797],[[-8.74228e-008,-1,0],[0,0,1]]]]
	],
	[
		["Land_u_House_Big_02_V1_F","Land_i_House_Big_02_V3_F","Land_i_House_Big_02_V1_F","Land_i_House_Big_02_V2_F"],
		[[[1.64258,5.54883,-0.478913],[[-0.0169196,-0.999857,0],[0,0,1]]],[[3.3125,-4.49414,-0.789048],[[0.012478,0.999922,0],[0,0,1]]]]
	],
	[
		["Land_i_Stone_HouseSmall_V2_F","Land_i_Stone_HouseSmall_V1_F","Land_i_Stone_HouseSmall_V3_F"],
		[[[0.0566406,-1.37891,0.052608],[[0.012478,0.999922,0],[0,0,1]]],[[0.00585938,5.63672,-0.168258],[[-0.00766302,-0.999971,0],[0,0,1]]]]
	],
	[
		["Land_i_Stone_HouseBig_V3_F","Land_i_Stone_HouseBig_V2_F","Land_i_Stone_HouseBig_V1_F"],
		[[[0.625,-2.00195,0.0724616],[[0.012478,0.999922,0],[0,0,1]]],[[-2.53711,3.22266,2.22565],[[0.99987,-0.0161541,0],[0,0,1]]]]
	],
	[
		["Land_i_House_Big_01_V3_F","Land_i_House_Big_01_V1_F","Land_i_House_Big_01_V2_F","Land_u_House_Big_01_V1_F"],
		[[[-4.81445,2.83203,-1.1514],[[0.999867,-0.0163374,0],[0,0,1]]],[[5.1543,0.775391,-0.706075],[[-0.999981,0.00623509,0],[0,0,1]]]]
	],
	[
		["Land_u_House_Small_01_V1_F","Land_i_House_Small_01_V3_F","Land_i_House_Small_01_V1_F","Land_i_House_Small_01_V2_F"],
		[[[-1.12695,-4.81641,1.56931],[[0.012478,0.999922,0],[0,0,1]]],[[1.53125,5.28711,1.06545],[[-0.01174,-0.999931,0],[0,0,1]]]]
	],
	//WW2 Staszow
	[
		["Land_WW2_Admin"],
		[[[-3.85253,1.72632,1.65646],[[1,-4.37114e-008,0],[0,0,1]]]]	
	],
	[
		["Land_WW2_Admin2"],
		[[[2.28076,6.48145,1.68778],[[-8.74228e-008,-1,0],[0,0,1]]]]	
	],
	// Beketov
	[
		["Land_HouseV2_02_Interier", "Land_HouseV2_02_Interier_dam"],
		[[[0.00195313,-8.37939,-2.86904],[[0,1,0],[0,0,1]]],[[-0.0200195,8.30127,-2.89629],[[-8.74228e-008,-1,0],[0,0,1]]]]
	],
	// Global Mobilization
	[
		["land_gm_euro_house_07_e",	"land_gm_euro_house_07_w",	"land_gm_euro_house_07_d"],
		[[[-1.23242,-3.00391,1.62851],[[0,1,0],[0,0,1]]]]
	]
];

// Buildings which add radio functionality to the location
location_bt_radio =
[
	"Land_TBox_F",				// Transmitter box which can be created through build UI
	// "Land_TTowerSmall_1_F",	// Not sure, looks like some small mobile phone antenna
	"Land_TTowerSmall_2_F",		// Verticall array of small dipoles
	"Land_TTowerBig_1_F",		// A-like transmitter tower
	"Land_TTowerBig_2_F",		// Tall I-like transmitter tower
	"Land_Communication_F",		// Tall tower with antennas on top, often found at military outposts
	
	// WW2
	"Land_wx_radiomast", 		// WW2 radio mast.

	//Global Mobilization
	"land_gm_radiotower_01"
];

location_bt_medical =
[
    "Land_DeconTent_01_NATO_F",
    "Land_DeconTent_01_NATO_tropic_F",
    "Land_DeconTent_01_wdl_F",
    "Land_DeconTent_01_white_F",
    "Land_MedicalTent_01_brownhex_closed_F",
    "Land_MedicalTent_01_digital_closed_F",
    "Land_MedicalTent_01_MTP_closed_F",
    "Land_MedicalTent_01_NATO_generic_inner_F",
    "Land_MedicalTent_01_NATO_generic_outer_F",
    "Land_MedicalTent_01_NATO_tropic_generic_outer_F",
    "Land_MedicalTent_01_wdl_closed_F",
    "Land_MedicalTent_01_wdl_generic_inner_F",
    "Land_MedicalTent_01_white_generic_inner_F",
    "Land_MedicalTent_01_white_generic_outer_F"
];

// Helipads
location_bt_helipad =
[
	"Land_HelipadCircle_F",
	"Land_HelipadCivil_F",
	"Land_HelipadEmpty_F",
	"Land_HelipadRescue_F",
	"Land_HelipadSquare_F"
];

/*
_newdir = direction b + 180;
(vehicle player) setDir _newDir;
vehicle player setPos ((b getPos [1.5, (direction b) + 240]) vectorAdd [0, 0, 4.4]);
*/

/*
// Code to get the coordinates in cylindrical form
_b = gBuilding;
_o = cursorObject;

_bPos = getPosATL _b;
_oPos = getPosATL _o;

_dirRel = (_bPos getDir _oPos) - (direction _b);
_zRel = _oPos#2 - _bPos#2;
_distRel = _bPos distance2D _oPos;

[_distRel, _dirRel, _zRel]
*/

/*
// Same code as above, also gives the direction of object relative to direction of house
_b = gBuilding;
_o = cursorObject;

_bPos = getPosATL _b;
_oPos = getPosATL _o;

_dirRel = (_bPos getDir _oPos) - (direction _b);
_zRel = _oPos#2 - _bPos#2;
_distRel = _bPos distance2D _oPos;

_objDir = (direction _o) - (direction _b);

[_distRel, _dirRel, _zRel, _objDir]
*/


/*
// Code to export texture offsets right from the editor, in cylindrical coordinates
// Must select house and texture objects

_objects = get3DENSelected "object";
_house = _objects select {_x isKindOf "House"} select 0;
_textures = _objects select {_x isKindOf "UserTexture1m_F"};

_arrayExport = []; // dist, posDir, zrel, dir

{
_b = _house;
_o = _x;
 
_bPos = getPosATL _b;
_oPos = getPosATL _o;
 
_dirRel = (_bPos getDir _oPos) - (direction _b);
_zRel = _oPos#2 - _bPos#2;
_distRel = _bPos distance2D _oPos;
 
_objDir = (direction _o) - (direction _b);
 
_arrayExport pushBack [_distRel, _dirRel, _zRel, round _objDir];
} forEach _textures;

_arrayExport
*/



/*
// Code to export objects from editor in [_pos, [_vectorDir, _vectorUp]]

_objects = get3DENSelected "object";
_house = _objects select {_x isKindOf "House"} select 0;
_textures = _objects select {_x isKindOf "UserTexture1m_F"};
 
_arrayExport = []; // dist, posDir, zrel, dir 
 
{ 
_b = _house;
_o = _x;
_posModel = _b worldToModel (position _o);
_vdir = vectorDir _o;
_vup = vectorUp _o;
_arrayExport pushBack [_posModel, [_b vectorWorldToModel _vdir, _b vectorWorldToModel _vup]];
} forEach _textures;
 
_arrayExport
*/



/*
//Code to get class names of all selected eden objects
(get3DENSelected "object") apply {typeof _x}
*/

gMilitaryBuildingModels = [];
gMilitaryBuildingTypes = [];
{
	gMilitaryBuildingModels pushBack (_x#0);
	gMilitaryBuildingTypes pushBack (_x#1);
} forEach (call compile preprocessFileLineNumbers "Location\militaryBuildings.sqf");

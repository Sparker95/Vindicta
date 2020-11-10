#include "..\common.h"

// Functions to access building positions quickly
location_fnc_objectClassHasSpawnPositions = {
	// !!!!! Very Important !!!!!!
	// If we want to add more spawn positions from buildings,
	// Like static AT guns from buildings, or static AAs, or whatever,
	// We must add these into this code too
	(! isNil {location_bp_HGM_GMG_high getVariable _this}) ||
	(! isNil {location_bp_cargo_medium getVariable _this}) ||
	(! isNil {location_bp_Boats getVariable _this})
};

// Function to turn array with position markup into hash map for quicker access
_createHashmapFromBuildingPositions = {
	private _hm = [false] call CBA_fnc_createNamespace;
	{
		private _classNames = _x#0;
		private _positions = _x#1;
		{ // All class names share same set of positions
			_hm setVariable [_x, _positions];
		} forEach _classNames;
	} forEach _this;
	_hm;
};

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
_location_bp_HGM_GMG_high =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F", "Land_Cargo_Tower_V4_F"],
		[[5.08573,99.9938,17.8895,89.9927],[5.62946,211.636,17.803,181.076],[5.82216,319.148,17.8895,0.203539],[5.75881,50.7726,17.8895,49.4819]]
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F", "Land_Cargo_Patrol_V4_F"],
		[[1.55509,236.874,4.34404,181.819],[1.56281,126.451,4.34404,180.368]]
	],

	[ //HBAR Tower
        ["Land_HBarrier_01_big_tower_green_F"],
        [[1.18102,189.651,4.20664,180]]
    ],
    [ //HBAR Bunker Tower
        ["Land_HBarrier_01_tower_green_F"],
        [[1.49471,14.0567,2.76688,315.001]]
    ]

	// Test
	//[["Land_i_House_Small_03_V1_F"],[[6.23894,146.461,3.62,180],[5.25872,175.733,3.62,180],[5.65386,46.6535,3.62,48.776],[5.83554,311.685,3.62,311.112],[2.58857,218.237,3.62,232.053]]]
];

location_bp_HGM_GMG_high = _location_bp_HGM_GMG_high call _createHashmapFromBuildingPositions;

_location_bp_Boats =
[	
	//CUP
    [
        ["Land_Nav_Boathouse_PierT"],
        [[11.5012,-193.688,-0.00916433,-170.284], [9.56137,-149.089,-0.00916529,-174.449], [17.8938,-172.539,-0.00916481,-261.774]]
    ],
	//vanilla Altis
	[ 
        ["Land_Pier_wall_F"],
        [[22.1456,179.977,-0.00916529,90]]
    ],
	[
        ["Land_Pier_F"],
        [[18.1456,179.972,-0.00916576,90]]
    ],

	[
        ["Land_nav_pier_m_F"],
        [[13.5562,41.5471,-0.00916529,-90.0297], [14.0945,-219.636,-0.00916481,-90.0297], [12.9259,-38.2878,-0.00916576,-90.0297], [12.6986,-140.898,-0.00916481,-90.0297]]
    ],
	//Tanoa
	[
        ["Land_PierConcrete_01_steps_F"],
        [[13.1842,355.612,-0.00916529,269.97]]
    ],
	[
        ["Land_QuayConcrete_01_20m_F"],
        [[13.1455,359.962,-0.00916386,269.97]]
    ],
	[
        ["Land_PierConcrete_01_end_F"],
        [[9.14551,359.944,-0.00916481,269.972]]
    ],
	[
        ["Land_PierConcrete_01_4m_ladders_F"],
        [[9.14563,89.9434,-0.00916386,359.97], [8.85437,270.058,-0.00916481,359.97]]
    ],
	[
        ["Land_PierConcrete_01_16m_F"],
        [[8.85437,270.058,-0.00916529,359.97], [10.1456,89.949,-0.00916433,359.97]]
    ],
	[
        ["Land_PierWooden_02_16m_F"],
        [[6.22791,80.676,-0.00916481,359.97], [5.94069,279.779,-0.00916481,359.97]]
    ],
	[
        ["Land_PierWooden_02_ladder_F"],
        [[4.14576,359.877,-0.00916386,269.973]]
    ],
	[
        ["Land_PierWooden_02_barrel_F"],
        [[5.14551,359.904,-0.00916481,269.975]]
    ],
	[
        ["Land_PierWooden_01_ladder_F"],
        [[5.14576,359.902,-0.00916433,269.97]]
    ],
	[
        ["Land_PierWooden_01_10m_noRails_F"],
        [[4.8545,90.1066,-0.00916672,179.97], [4.64688,267.028,-0.00916529,179.97]]
    ],
	[
        ["Land_PierWooden_01_hut_F"],
        [[4.14576,359.879,-0.00916481,269.97]]
    ],
	[
        ["Land_PierWooden_01_dock_F"],
        [[12.1455,359.959,-0.00916481,269.97]]
    ],

	// Unsung
	[["Land_molo_drevo_end"],[[5.98251,192.539,-0.0311432,273.017],[5.68377,354.557,-0.0388451,273.31]]],
	[["Pier3_tyres"],[[5.12528,0.0832425,-0.0462704,273.017]]],
	[["Pier3_clutter"],[[4.2606,13.296,-0.0875168,273.017]]],
	[["Pier1_tyres"],[[3.95416,1.05426,-0.199099,273.017]]],
	[["Pier2"],[[7.30126,269.192,-0.286825,181.581]]],
	[["Pier1_clutter"],[[3.48324,356.23,-0.169113,273.017]]]
];

location_bp_Boats = _location_bp_Boats call _createHashmapFromBuildingPositions;

// Capacities of buildings for infantry
// Typically a building's inf capacity is amount of its buildingPos, however for some buildings we can override that here
location_b_capacity =
[
	// The giant military tower
	[
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F", "Land_Cargo_Tower_V4_F"],
		14
	],
	// The small military watchtower
	[
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F", "Land_Cargo_Patrol_V4_F"],
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
_location_bp_cargo_medium =
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
	],
	// CUP Sahrani
	[
		["Land_Dum_olez_istan1", "Land_Dum_olez_istan1_open2"],
		[[2.84609,27.3014,-0.0522177,0],[3.06484,125.54,3.26687,0]]
	],
	[
		["Land_Dum_olez_istan2_maly"],
		[[4.65903,323.05,-0.112593,-2],[1.62625,239.845,3.2213,-2]]
	],
	//Tanoa
	[
		["Land_House_Small_02_F"],
		[[3.82726,207.414,0.163198,0],[3.26539,323.981,0.163198,0]]
	],
	[
		["Land_House_Big_02_F"],
		[[9.05937,278.308,0.247039,0],[5.93008,283.286,0.247039,0]]
	],
	[
		["Land_House_Small_03_F"],
		[[4.46964,287.943,0.707387,0],[1.97211,30.6399,0.707387,0]]
	],
	[
		["Land_House_Small_06_F"],
		[[1.42332,253.6,0.403843,0],[3.89371,187.168,0.403843,0]]
	],
	[
		["Land_House_Big_01_F"],
		[[5.00607,42.4493,0.221095,0],[2.84669,81.0797,0.221095,0]]
	],
	[
		["Land_GarageShelter_01_F"],
		[[3.08881,314.871,0.0952454,0],[2.53124,248.677,0.0952454,0]]
	],
	[
		["Land_House_Small_01_F"],
		[[2.54961,251.88,0.575955,0],[4.77418,287.64,0.575955,0]]
	],

	// RHS PKL
	[["Land_rhspkl_hut_01"],[[5.24106,-96.798,1.37074,270.959],[5.28796,-84.5465,1.37074,270.959]]],
    [["Land_rhspkl_hut_02"],[[5.83803,189.625,1.38538,0],[4.45634,192.565,1.38538,0]]],
    [["Land_rhspkl_hut_03"],[[4.81163,198.186,1.3664,0],[4.72642,162.213,1.3664,0]]],
    [["Land_rhspkl_hut_04"],[[4.99418,158.678,1.34299,0],[4.69744,186.632,1.34299,0]]],
    [["Land_rhspkl_hut_05"],[[5.61876,180.351,1.40414,0],[3.74854,179.922,1.40414,0]]],
    [["Land_rhspkl_hut_06"],[[1.01065,329.404,1.91617,1.18239],[1.09486,198.851,1.91617,0]]],
    [["Land_rhspkl_hut_07"],[[0.730642,204.373,1.51519,0],[1.48428,349.72,1.51519,0]]],
    [["Land_rhspkl_hut_08"],[[1.25072,23.5531,1.1439,88.9171],[1.08291,-25.4642,1.1439,269.327]]]
];

location_bp_cargo_medium = _location_bp_cargo_medium call _createHashmapFromBuildingPositions;

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
	"Land_HouseV2_04_interier_dam",
	// Structures Micellaneous CUP
	"Land_Dum_olez_istan1",
	"Land_Dum_olez_istan1_open2",
	"Land_Dum_olez_istan2_maly",

	// Tanoa
	"Land_House_Small_02_F",
	"Land_House_Big_02_F",
	"Land_House_Small_03_F",
	"Land_House_Small_06_F",
	"Land_House_Big_01_F",
	"Land_GarageShelter_01_F",
	"Land_House_Small_01_F",

	// RHS PKL
	"Land_rhspkl_hut_01",
    "Land_rhspkl_hut_02",
    "Land_rhspkl_hut_03",
    "Land_rhspkl_hut_04",
    "Land_rhspkl_hut_05",
    "Land_rhspkl_hut_06",
    "Land_rhspkl_hut_07",
    "Land_rhspkl_hut_08"
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
	],
	// Livonia/Chernarus2020
	[
		["Land_House_2B01_F"],
		[[[-0.297363,-5.44409,-2.01369],[[0,1,0],[0,0,1]]],[[3.27539,-0.0566406,-2.259],[[-1,1.19249e-008,0],[0,0,1]]],[[-1.63525,5.43262,-2.26633],[[-8.74228e-008,-1,0],[0,0,1]]],[[-4.97266,-1.20313,-2.37382],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2B02_F"],
		[[[2.66895,-7.60034,-3.77069],[[0,1,0],[0,0,1]]],[[9.70605,1.88843,-3.30074],[[-1,1.19249e-008,0],[0,0,1]]],[[2.79688,7.85059,-3.59532],[[-8.74228e-008,-1,0],[0,0,1]]],[[-9.59473,1.84375,-3.22242],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2B03_F"],
		[[[2.91895,-7.57788,-3.77069],[[0,1,0],[0,0,1]]],[[9.64258,1.83325,-3.30074],[[-1,1.19249e-008,0],[0,0,1]]],[[2.56641,7.78027,-3.59532],[[-8.74228e-008,-1,0],[0,0,1]]],[[-9.59033,1.85522,-3.22242],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2B04_F"],
		[[[1.45703,-6.94556,-4.26146],[[0,1,0],[0,0,1]]],[[8.75391,2.15454,-3.92427],[[-1,1.19249e-008,0],[0,0,1]]],[[3.78516,7.91577,-3.75513],[[-8.74228e-008,-1,0],[0,0,1]]],[[-6.33838,2.70068,-3.89331],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_1W05_F"],
		[[[0.111328,-8.04199,-1.39836],[[0,1,0],[0,0,1]]],[[5.63037,-0.196777,0.45722],[[-1,1.19249e-008,0],[0,0,1]]],[[0.750488,4.21631,0.176394],[[-8.74228e-008,-1,0],[0,0,1]]],[[-2.56494,-0.156738,0.397576],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_1W06_F"],
		[[[-0.0258789,-4.46606,0.587232],[[0,1,0],[0,0,1]]],[[5.34033,-0.064209,0.667007],[[-1,1.19249e-008,0],[0,0,1]]],[[3.41113,3.67407,0.386181],[[-8.74228e-008,-1,0],[0,0,1]]],[[-2.81592,-0.0419922,0.607364],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_1W07_F"],
		[[[-1.39111,-8.48999,-1.20904],[[0,1,0],[0,0,1]]],[[6.96973,-0.885254,-1.3943],[[-1,1.19249e-008,0],[0,0,1]]],[[-3.32471,3.9187,-1.42407],[[-8.74228e-008,-1,0],[0,0,1]]],[[-7.68311,-0.883057,-1.44154],[[1,-4.37114e-008,0],[0,0,1]]],[[1.39404,-6.10278,-1.3943],[[-1,1.19249e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_1W08_F"],
		[[[4.6333,-0.0791016,-0.444686],[[0,1,0],[0,0,1]]],[[7.08154,2.32056,0.138831],[[-1,1.19249e-008,0],[0,0,1]]],[[2.93408,4.60742,-0.0668502],[[-8.74228e-008,-1,0],[0,0,1]]],[[-3.69482,-1.53003,-0.233786],[[1,-4.37114e-008,0],[0,0,1]]],[[0.482422,-2.06177,0.202418],[[0,1,0],[0,0,1]]]]
	],
	[
		["Land_House_1W09_F"],
		[[[-2.19287,-4.69189,-0.532219],[[0,1,0],[0,0,1]]],[[3.06152,0.592773,-0.382189],[[-1,1.19249e-008,0],[0,0,1]]],[[-1.73926,4.77197,-0.410214],[[-8.74228e-008,-1,0],[0,0,1]]],[[-7.40771,0.727783,-0.57274],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2W01_F"],
		[[[-1.32617,-3.93286,-1.6959],[[0,1,0],[0,0,1]]],[[4.24854,3.97461,-1.51565],[[-1,1.19249e-008,0],[0,0,1]]],[[-3.09521,4.59668,-1.5686],[[-8.74228e-008,-1,0],[0,0,1]]],[[-7.37305,1.59668,-1.2752],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2W02_F"],
		[[[4.29297,-4.57275,-2.47407],[[0,1,0],[0,0,1]]],[[9.54541,1.04907,-2.45458],[[-1,1.19249e-008,0],[0,0,1]]],[[2.65186,4.84448,-2.62825],[[-8.74228e-008,-1,0],[0,0,1]]],[[-3.03076,3.42651,-2.88213],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2W03_F"],
		[[[-5.32324,-1.49854,-2.84391],[[0,1,0],[0,0,1]]],[[9.91895,0.362305,-2.65713],[[-1,1.19249e-008,0],[0,0,1]]],[[-1.5708,7.31152,-2.73589],[[-8.74228e-008,-1,0],[0,0,1]]],[[-9.81836,5.39771,-2.71946],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2W04_F"],
		[[[-1.11279,-1.17285,-3.98573],[[0,1,0],[0,0,1]]],[[8.49902,6.28491,-3.55426],[[-1,1.19249e-008,0],[0,0,1]]],[[-3.02588,7.62378,-2.97705],[[-8.74228e-008,-1,0],[0,0,1]]],[[-11.2441,0.358154,-2.9603],[[1,-4.37114e-008,0],[0,0,1]]]]
	],
	[
		["Land_House_2W05_F"],
		[[[1.12451,-5.3938,-2.79531],[[0,1,0],[0,0,1]]],[[3.83789,1.24023,-2.77086],[[-1,1.19249e-008,0],[0,0,1]]],[[-5.52881,1.65234,-2.43875],[[-8.74228e-008,-1,0],[0,0,1]]],[[-8.59619,-1.55762,-1.8426],[[1,-4.37114e-008,0],[0,0,1]]]]
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

location_bt_repair =
[
    "B_Slingload_01_Repair_F",
	"Land_Workshop_01_F"
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
// !!!!! USE THIS FOR location_bp_cargo_medium !!!!!
// And for static guns too!
// You need to place houses and cargo boxes inside houses
// Then select them all, and run the code to export cargo box positions

_objects = get3DENSelected "object";

_houses = _objects select {_x isKindOf "House"};
_boxes = _objects select {! (_x isKindOf "House")};

_return = [];

{
    private _house = _x;
    private _housePos = getPosWorld _house;
	private _housePosATL = getPosATL _house;
    private _bb = boundingBoxReal _house;
    (_bb#0) params ["_sx", "_sy", "_sz"];
    private _radius = sqrt(_sx^2 + _sy^2);
    private _boxesInside = _boxes select { (_house distance2D _x) < _radius };
    private _boxPositions = [];
    {
        private _box = _x;
        _boxPos = getPosWorld _box;
		_posATL = getPosATL _box;

        private _dirRel = (_housePosATL getDir _posATL) - (direction _house);
        private _zRel = (_posATL#2) - (_housePosATL#2);
        private _distRel = _housePos distance2D _boxPos;

        _objDir = (direction _box) - (direction _house);

        _boxPositions pushBack [_distRel, _dirRel, _zRel, _objDir];
    } forEach _boxesInside;

    _return pushBack [[typeOf _house], _boxPositions];
} forEach _houses;

_return;
*/

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
} forEach CALL_COMPILE_COMMON("Location\militaryBuildings.sqf");

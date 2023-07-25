_array = [];

_array set [T_SIZE-1, nil]; //Make an array having the size equal to the number of categories first

_array set [T_NAME, "tVN_CIVILIAN"];                           //Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Vietnam war Civilians made using content from S.O.G. Prairie Fire DLC."];     //Template display description
_array set [T_DISPLAY_NAME, "SOG DLC - Civilians"];      //Template display name
_array set [T_FACTION, T_FACTION_Civ];                      //Faction type
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F", 
		"vn_weapons", 
		"vn_data_f"
		]];        //Addons required to play this template

//==== Arsenal ====
_arsenal = [];
_arsenal resize T_ARSENAL_SIZE;
_arsenal set[T_ARSENAL_primary, [
    "vn_izh54_shorty",
    "vn_izh54",
    "vn_k50m",
    "vn_pps43",
    "vn_pps52",
    "vn_ppsh41",
    "vn_sten",
    "vn_mp40"
]];
_arsenal set[T_ARSENAL_primary_items, [
]];
_arsenal set[T_ARSENAL_secondary, []];
_arsenal set[T_ARSENAL_secondary_items, []];
_arsenal set[T_ARSENAL_handgun, [
    "vn_m_axe_01",
    "vn_m_bolo_01",
    "vn_fkb1_red",
    "vn_fkb1",
    "vn_m_hammer",
    "vn_izh54_p",
    "vn_m_fighting_knife_01",
    "vn_m_vc_knife_01",
    "vn_m712",
    "vn_m_machete_02",
    "vn_m_machete_01",
    "vn_pm",
    "vn_m_shovel_01",
    "vn_tt33",
    "vn_m_typeivaxe_01",
    "vn_m_wrench_01"
]];
_arsenal set[T_ARSENAL_handgun_items, []];
_arsenal set[T_ARSENAL_ammo, [
    "vn_izh54_mag",
    "vn_ppsh41_35_mag",
    "vn_pps_mag",
    "vn_sten_mag",
    "vn_mp40_mag",
    "vn_m712_mag",
    "vn_pm_mag",
    "vn_tt33_mag"
]];
_arsenal set[T_ARSENAL_items, []];
_arsenal set[T_ARSENAL_vests, [
    "vn_o_vest_vc_01",
    "vn_o_vest_vc_05",
    "vn_o_vest_vc_03",
    "vn_o_vest_vc_04",
    "vn_o_vest_vc_02",
    "vn_o_vest_05",
    "vn_o_vest_04"
]];
_arsenal set[T_ARSENAL_backpacks, [
    "vn_c_pack_01",
	"vn_c_pack_01_medic_pl",
    "vn_c_pack_01_engineer_pl",
    "vn_c_pack_02",
    "vn_o_pack_t884_01",
    "vn_o_pack_01",
    "vn_o_pack_02",
    "vn_o_pack_03",
    "vn_o_pack_05",
    "vn_o_pack_06",
    "vn_o_pack_07"
]];
_arsenal set[T_ARSENAL_uniforms, [
    "vn_o_uniform_vc_01_01",
	"vn_o_uniform_vc_01_02",
	"vn_o_uniform_vc_01_04",
	"vn_o_uniform_vc_01_07",
	"vn_o_uniform_vc_01_06",
	"vn_o_uniform_vc_01_03",
	"vn_o_uniform_vc_01_05",
	"vn_o_uniform_vc_mf_01_07",
	"vn_o_uniform_vc_mf_10_07",
	"vn_o_uniform_vc_reg_11_08",
	"vn_o_uniform_vc_reg_11_09",
	"vn_o_uniform_vc_reg_11_10",
	"vn_o_uniform_vc_mf_11_07",
	"vn_o_uniform_vc_reg_12_08",
	"vn_o_uniform_vc_reg_12_09",
	"vn_o_uniform_vc_reg_12_10",
	"vn_o_uniform_vc_mf_12_07",
	"vn_o_uniform_vc_02_01",
	"vn_o_uniform_vc_02_02",
	"vn_o_uniform_vc_02_04",
	"vn_o_uniform_vc_02_07",
	"vn_o_uniform_vc_02_06",
	"vn_o_uniform_vc_02_03",
	"vn_o_uniform_vc_02_05",
	"vn_o_uniform_vc_mf_02_07",
    "vn_o_uniform_vc_03_01",
    "vn_o_uniform_vc_03_02",
    "vn_o_uniform_vc_03_04",
    "vn_o_uniform_vc_03_07",
    "vn_o_uniform_vc_03_06",
    "vn_o_uniform_vc_03_03",
    "vn_o_uniform_vc_03_05",
    "vn_o_uniform_vc_mf_03_07",
    "vn_o_uniform_vc_04_01",
    "vn_o_uniform_vc_04_02",
    "vn_o_uniform_vc_04_04",
    "vn_o_uniform_vc_04_07",
    "vn_o_uniform_vc_04_06",
    "vn_o_uniform_vc_04_03",
    "vn_o_uniform_vc_04_05",
    "vn_o_uniform_vc_mf_04_07",
    "vn_o_uniform_vc_05_01",
    "vn_o_uniform_vc_05_04",
    "vn_o_uniform_vc_05_03",
    "vn_o_uniform_vc_05_02",
    "vn_o_uniform_vc_mf_09_07"
]];
_arsenal set[T_ARSENAL_facewear, [
    //"vn_b_aviator", mwuhahaha
    "vn_o_bandana_b",
    "vn_o_bandana_g",
    "vn_o_scarf_01_04",
    "vn_b_scarf_01_03",
    "vn_o_scarf_01_03",
    "vn_o_scarf_01_02",
    "vn_b_scarf_01_01",
    "vn_o_scarf_01_01"
]];
_arsenal set[T_ARSENAL_headgear, [
    "H_Bandanna_blu",
    "H_Bandanna_camo",
    "H_Bandanna_cbr",
    "H_Bandanna_gry",
    "H_Bandanna_khk",
    "H_Bandanna_khk_hs",
    "H_Bandanna_mcamo",
    "H_Bandanna_sand",
    "H_Bandanna_sgg",
    "H_Bandanna_surfer",
    "H_Bandanna_surfer_blk",
    "H_Bandanna_surfer_grn",
    "H_Watchcap_blk",
    "H_Watchcap_cbr",
    "H_Watchcap_camo",
    "H_Watchcap_khk",
    "H_StrawHat",
    "H_StrawHat_dark",
    "H_Hat_Safari_olive_F",
    "H_Hat_Safari_sand_F",
    "vn_c_headband_04",
    "vn_b_headband_03",
    "vn_c_headband_03",
    "vn_c_headband_02",
    "vn_b_headband_01",
    "vn_c_headband_01",
    "vn_c_conehat_01",
    "vn_c_conehat_02",
    "vn_o_helmet_vc_01",
    "vn_o_helmet_vc_04",
    "vn_o_helmet_vc_03",
    "vn_o_helmet_vc_02",
    "vn_b_bandana_03",
    "vn_b_bandana_01",
    "vn_o_boonie_vc_01_01"
]];
_arsenal set [T_ARSENAL_grenades, [
    "vn_molotov_grenade_mag",
    "vn_chicom_grenade_mag"
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["VN_CIVILIAN_Default"] };
_inf set [T_INF_default, ["vn_c_men_17"]];
_inf set [T_INF_rifleman, [
    "VN_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
    "VN_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
    "VN_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
    "VN_CIVILIAN_Militant_1"
]];

private _civCars = [
    "vn_c_bicycle_01",          15,
    "vn_c_car_01_01",           10,
    "vn_c_car_03_01",           10,
    "vn_c_car_02_01",           10,
    "vn_c_car_01_02",           10,
    "vn_c_wheeled_m151_02",     10,
    "vn_c_wheeled_m151_01",     10,
    "vn_c_car_04_01",           5
];
private _civCarsClasses = _civCars select {_x isEqualType "";};

private _civBoats = [
    "vn_c_boat_01_03", 10,
    "vn_c_boat_01_04", 10,
    "vn_c_boat_01_00", 10,
    "vn_c_boat_01_01", 10,
    "vn_c_boat_01_02", 10,
    "vn_c_boat_02_03", 10,
    "vn_c_boat_02_04", 10,
    "vn_c_boat_02_00", 10,
    "vn_c_boat_02_01", 10,
    "vn_c_boat_02_02", 10,
    "vn_c_boat_07_02", 10,
    "vn_c_boat_07_01", 10,
    "vn_c_boat_08_02", 5,
    "vn_c_boat_08_01", 5
];
private _civBoatsClasses = _civBoats select {_x isEqualType "";};

private _civVehiclesOnlyNames = _civCarsClasses + _civBoatsClasses;

//==== Vehicles ====
_veh = [];
_veh resize T_VEH_SIZE;

_veh set [T_VEH_default, _civCars];
_veh set [T_VEH_boat_unarmed, _civBoats];


//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

// ==== Inventory ====
_inv = [T_INV] call t_fnc_newCategory;
_inv set [T_INV_items, +t_miscItems_civ_modern ];
_inv set [T_INV_backpacks, ["vn_c_pack_01", "vn_c_pack_01_medic_pl", "vn_c_pack_01_engineer_pl", "vn_c_pack_02"]];

// ==== Undercover ====
_uc = [];
_uc resize T_UC_SIZE;
_uc set[T_UC_headgear, []];
_uc set[T_UC_facewear, []];
_uc set[T_UC_uniforms, []];
_uc set[T_UC_backpacks, []];
_uc set[T_UC_civVehs, +_civVehiclesOnlyNames];
_array set [T_UC, _uc];

//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, []];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, []];
_array set [T_ARSENAL, _arsenal];
_array set [T_INV, _inv];

_array
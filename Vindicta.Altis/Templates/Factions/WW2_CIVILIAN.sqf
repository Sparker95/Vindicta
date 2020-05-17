
// ██████╗██╗██╗   ██╗██╗██╗     ██╗ █████╗ ███╗   ██╗
//██╔════╝██║██║   ██║██║██║     ██║██╔══██╗████╗  ██║
//██║     ██║██║   ██║██║██║     ██║███████║██╔██╗ ██║
//██║     ██║╚██╗ ██╔╝██║██║     ██║██╔══██║██║╚██╗██║
//╚██████╗██║ ╚████╔╝ ██║███████╗██║██║  ██║██║ ╚████║
// ╚═════╝╚═╝  ╚═══╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
// http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=Civilian
//
//Updated: March 2020 by Marvis


_civUniforms = [
	"U_LIB_CIV_Assistant",
	"U_LIB_CIV_Assistant_2",
	"U_LIB_CIV_Citizen_1",
	"U_LIB_CIV_Citizen_2",
	"U_LIB_CIV_Citizen_3",
	"U_LIB_CIV_Citizen_4",
	"U_LIB_CIV_Citizen_5",
	"U_LIB_CIV_Citizen_6",
	"U_LIB_CIV_Citizen_7",
	"U_LIB_CIV_Citizen_8",
	"U_LIB_CIV_Doctor",
	"U_LIB_CIV_Priest",
	"U_LIB_CIV_Rocker_1",
	"U_LIB_CIV_Schoolteacher",
	"U_LIB_CIV_Schoolteacher_2",
	"U_LIB_CIV_Villager_1",
	"U_LIB_CIV_Villager_2",
	"U_LIB_CIV_Villager_3",
	"U_LIB_CIV_Villager_4",
	"U_LIB_CIV_Woodlander_1",
	"U_LIB_CIV_Woodlander_2",
	"U_LIB_CIV_Woodlander_3",
	"U_LIB_CIV_Woodlander_4",
	"U_LIB_CIV_Worker_1",
	"U_LIB_CIV_Worker_2",
	"U_LIB_CIV_Worker_3",
	"U_LIB_CIV_Worker_4",
	"U_LIB_CIV_Functionary_1",
	"U_LIB_CIV_Functionary_2",
	"U_LIB_CIV_Functionary_3",
	"U_LIB_CIV_Functionary_4",
	//French Resistance
	"U_GELIB_FRA_MGunner_gvnpFF13",
	"U_GELIB_FRA_MGunner_gvmpFF14",
	"U_GELIB_FRA_SoldierFF_gvmpFF15",
	"U_GELIB_FRA_SoldierFF_gvmpFF16",
	"U_GELIB_FRA_ScoutFF_Camo31vgpFF17",
	//Polish Resistance
	"U_LIB_POL_Oficer_bvbpKpnWPPK",
	"U_LIB_POL_Soldier_camo_15vbpbcbcSantM1911",
	"U_LIB_POL_Soldier_camo_00vmpbcbcSzM9130",
	"U_LIB_POL_rifleman_bcvbpSzM9130",
	"U_LIB_POL_soldier_bcvmpbcSzt3Mp40",
	"U_LIB_POL_rifleman_bfvnpSzK98",
	"U_LIB_POL_rifleman_gvbpbcSz2SmLE",
	"U_LIB_POL_soldier_nvmprcStSz3RKMwz28"
];

_civFacewear = [
	//"G_Aviator", mwuhahaha
	"G_GEHeadBandage_Bloody",
	"G_GEHeadBandage_Clean",
	"G_GEHeadBandage_Stained",
	"G_LIB_Dienst_Brille",
	"G_LIB_Dienst_Brille2",
	"G_LIB_Dust_Goggles",
	"G_LIB_GER_Gloves4",
	"G_LIB_GER_Gloves2",
	"G_LIB_GER_Gloves1",
	"G_LIB_GER_Gloves3",
	"G_LIB_Mohawk",
	"G_LIB_Scarf2_B",
	"G_LIB_Scarf2_G",
	"G_LIB_Scarf_B",
	"G_LIB_Scarf_G",
	"G_LIB_Watch2",
	"G_LIB_Watch1",
	"G_geBI_Bandanna_khk",
	"G_geBI_Bandanna_blk",
	"G_geBI_Bandanna_oli",
	"G_GEMedicVest_00",
	"G_LIB_Binoculars",
	"G_Blindfold_01_black_F",
	"G_Blindfold_01_white_F"
];

_civVests = [
	"V_LIB_SOV_RA_Belt"
];

_civHeadgear = [
	"H_Hat_blue",
	"H_Hat_brown",
	"H_Hat_checker",
	"H_Hat_grey",
	"H_Hat_tan",
	"H_StrawHat",
	"H_StrawHat_dark",
	"H_LIB_CIV_Villager_Cap_1",
	"H_LIB_CIV_Villager_Cap_2",
	"H_LIB_CIV_Villager_Cap_3",
	"H_LIB_CIV_Villager_Cap_4",
	"H_LIB_CIV_Worker_Cap_1",
	"H_LIB_CIV_Worker_Cap_2",
	"H_LIB_CIV_Worker_Cap_3",
	"H_LIB_CIV_Worker_Cap_4",
	"GEH_Beret_blue",
	"GEH_Beret_blk",
	"H_Hat_Safari_olive_F",
	"H_Hat_Safari_sand_F"
];

_civVehicles = [
	"LIB_GazM1",            8,
	"LIB_GazM1_dirty",      7,
	"LIB_FRA_CitC4",        4,
	"LIB_FRA_CitC4Ferme",   1
];
_civVehiclesOnlyNames = _civVehicles select { _x isEqualType "" };

_array = [];

_array resize T_SIZE; //Make an array having the size equal to the number of categories first

_array set [T_NAME, "tWW2_Civilian"]; 				//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "WW2 40s Civilians"]; 	//Template display description
_array set [T_DISPLAY_NAME, "WW2 Civilians"]; 		//Template display name
_array set [T_FACTION, T_FACTION_Civ]; 				//Faction type
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F", 
		"IFA3_Core",
		"IFA3_COMP_ACE_main",
		"IFA3_FOW_Compat",
		"LIB_core",
		"GEISTL_MAIN",
		"GEISTL_FOW_MAIN",
		"fow_main",
		"sab_boat_c",
		"sab_compat_ace",
		"I44_Buildings"
		]]; 										//Addons required to play this template

//==== API ====
_api = [];
_api resize T_API_SIZE;
_api set [T_API_fnc_init, {}];

//==== Undercover ====
_uc = [];
_uc resize T_UC_SIZE;
_uc = _uc apply { [] };
_uc set[T_UC_uniforms, +_civUniforms];
_uc set[T_UC_facewear, +_civFacewear];
_uc set[T_UC_vests, +_civVests];
_uc set[T_UC_headgear, +_civHeadgear];
_uc set[T_UC_civVehs, +_civVehiclesOnlyNames];

//==== Arsenal ====
_arsenal = [];
_arsenal resize T_ARSENAL_SIZE;
_arsenal set[T_ARSENAL_primary, []];
_arsenal set[T_ARSENAL_primary_items, []];
_arsenal set[T_ARSENAL_secondary, []];
_arsenal set[T_ARSENAL_secondary_items, []];
_arsenal set[T_ARSENAL_handgun, [
	"KA_TL_122_flashlight",
	"KA_knife"
]];
_arsenal set[T_ARSENAL_handgun_items, []];
_arsenal set[T_ARSENAL_ammo, [
	"ka_knife_blade"
]];
_arsenal set[T_ARSENAL_items, []];
_arsenal set[T_ARSENAL_vests, [
	"V_LIB_SOV_RA_Belt"
]];
_arsenal set[T_ARSENAL_backpacks, [
	"GEB_FieldPack_cbr",
	"GEB_FieldPack_khk",
	"GEB_FieldPack_blk",
	"B_LIB_SOV_RA_MedicalBag_Empty",
	"B_LIB_SOV_RA_MGAmmoBag_Empty",
	"B_LIB_SOV_RA_Rucksack",
	"B_LIB_SOV_RA_Rucksack_Green"
]];
_arsenal set[T_ARSENAL_uniforms, +_civUniforms];
_arsenal set[T_ARSENAL_facewear, +_civFacewear];
_arsenal set[T_ARSENAL_vests, +_civVests];
_arsenal set[T_ARSENAL_headgear, +_civHeadgear];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["WW2_CIVILIAN_Default"] };
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "WW2_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
	"WW2_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
	"WW2_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
	"WW2_CIVILIAN_Militant_1"
]];

//==== Vehicles ====
_veh = [];
_veh resize T_VEH_SIZE;
_veh set [T_VEH_default, _civVehicles];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

// ==== Inventory ====
_inv = [T_INV] call t_fnc_newCategory;
_inv set [T_INV_items, +t_miscItems_civ_WW2 ];
_inv set [T_INV_backpacks, ["GEB_FieldPack_cbr", "B_LIB_SOV_RA_Rucksack"]];

//==== Arrays ====
_array set [T_API, _api];
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_CARGO, _cargo];
_array set [T_DRONE, []];
_array set [T_GROUP, []];
_array set [T_ARSENAL, _arsenal];
_array set [T_UC, _uc];

_array

/*
Civilian template for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil]; //Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tWW2_Civilian"];
_array set [T_DESCRIPTION, "WW2 40s Civilians"];
_array set [T_DISPLAY_NAME, "WW2 Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F", "ww2_assets_c_characters_core_c", "lib_weapons", "geistl_main", "fow_weapons", "sab_boat_c", "ifa3_comp_ace_main", "geistl_fow_main", "ifa3_comp_fow", "ifa3_comp_fow_ace_settings", "sab_compat_ace"]];

// ==== Arsenal ====
_arsenal = [];
_arsenal resize T_ARSENAL_SIZE;
_arsenal set[T_ARSENAL_primary, []];
_arsenal set[T_ARSENAL_primary_items, []];
_arsenal set[T_ARSENAL_secondary, []];
_arsenal set[T_ARSENAL_secondary_items, []];
_arsenal set[T_ARSENAL_handgun, [
	"KA_TL_122_flashlight"
]];
_arsenal set[T_ARSENAL_handgun_items, [
	"KA_knife_blade"
]];
_arsenal set[T_ARSENAL_ammo, []];
_arsenal set[T_ARSENAL_items, [

]];

_arsenal set[T_ARSENAL_vests, []];
_arsenal set[T_ARSENAL_backpacks, [
	"B_LIB_SOV_RA_Rucksack_Vide",
	"B_LIB_SOV_RA_Rucksack21_Vide",
	"B_LIB_SOV_RA_Rucksack22_Vide",
	"B_LIB_SOV_RA_Rucksack32_Vide",
	"B_LIB_SOV_RA_Rucksack41_Vide"
]];

_arsenal set[T_ARSENAL_uniforms, [
	"U_LIB_CIV_Citizen_1",
	"U_LIB_CIV_Citizen_2",
	"U_LIB_CIV_Citizen_3",
	"U_LIB_CIV_Citizen_4",
	"U_LIB_CIV_Citizen_5",
	"U_LIB_CIV_Citizen_6",
	"U_LIB_CIV_Citizen_7",
	"U_LIB_CIV_Citizen_8",
	"U_LIB_CIV_Functionary_1",
	"U_LIB_CIV_Functionary_2",
	"U_LIB_CIV_Functionary_3",
	"U_LIB_CIV_Functionary_4",
	"U_GELIB_FRA_CitizenFF01",
	"U_GELIB_FRA_CitizenFF02",
	"U_GELIB_FRA_CitizenFF03",
	"U_GELIB_FRA_CitizenFF04",
	"U_GELIB_FRA_WoodlanderFF01",
	"U_GELIB_FRA_WoodlanderFF04",
	"U_GELIB_FRA_AssistantFF",
	"U_GELIB_FRA_FunctionaryFF01",
	"U_GELIB_FRA_FunctionaryFF02",
	"U_GELIB_FRA_VillagerFF01",
	"U_GELIB_FRA_VillagerFF02",
	"U_GELIB_FRA_Citizen01",
	"U_GELIB_FRA_Citizen02",
	"U_GELIB_FRA_Citizen03",
	"U_GELIB_FRA_Citizen04",
	"U_GELIB_FRA_Citizen01",
	"U_GELIB_FRA_Citizen01"
]];

_arsenal set[T_ARSENAL_facewear, [
	//"G_Aviator", mwuhahaha
	"G_Balaclava_blk",
	"G_Balaclava_oli",
	"G_Squares"
]];

_arsenal set[T_ARSENAL_headgear, [
	"H_StrawHat",
	"H_StrawHat_dark"
]];

// ==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { [] };
_inf set [T_INF_DEFAULT, [
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
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_default, [
	"LIB_GazM1",            8,
	"LIB_GazM1_dirty",      7,
	"LIB_FRA_CitC4",        4,
	"LIB_FRA_CitC4Ferme",   1
]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, []];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, []];
_array set [T_ARSENAL, _arsenal];

_array

/*
Civilian template for ARMA III
*/
_array = [];
_array resize T_SIZE;

_array set [T_NAME, "tCUP_RUS_CIVILIAN"];
_array set [T_DESCRIPTION, "Russian civilians from CUP."];
_array set [T_DISPLAY_NAME, "CUP RUS Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, ["CUP_Creatures_People_Civil_Russia","CUP_Vehicles_Core"]];

_civHeadgear = [
	"CUP_H_FR_BandanaGreen",
	"CUP_H_FR_BandanaWdl",
	"CUP_H_PMC_Beanie_Black",
	"CUP_H_SLA_BeanieGreen",
	"CUP_H_PMC_Beanie_Khaki",
	"CUP_H_C_Beanie_02",
	"CUP_H_C_Beanie_04",
	"CUP_H_NAPA_Fedora"
];

_civFacewear = [];

_civUniforms = [
	"CUP_U_C_Worker_01",
	"CUP_U_C_Worker_02",
	"CUP_U_C_Worker_03",
	"CUP_U_C_Worker_04",
	"CUP_U_C_Woodlander_01",
	"CUP_U_C_Woodlander_02",
	"CUP_U_C_Woodlander_03",
	"CUP_U_C_Woodlander_04",
	"CUP_U_C_Villager_01",
	"CUP_U_C_Villager_02",
	"CUP_U_C_Villager_03",
	"CUP_U_C_Villager_04",
	"CUP_U_C_Functionary_jacket_01",
	"CUP_U_C_Functionary_jacket_02",
	"CUP_U_C_Functionary_jacket_03",
	"CUP_U_C_Suit_01",
	"CUP_U_C_Suit_02",
	"CUP_U_C_Suit_03",
	"CUP_U_C_Rocker_01",
	"CUP_U_C_Rocker_02",
	"CUP_U_C_Rocker_03",
	"CUP_U_C_Rocker_04",
	"CUP_U_C_Priest_01",
	"CUP_U_C_Citizen_01",
	"CUP_U_C_Citizen_02",
	"CUP_U_C_Citizen_03",
	"CUP_U_C_Citizen_04",
	"CUP_U_C_Mechanic_01",
	"CUP_U_C_Mechanic_02",
	"CUP_U_C_Mechanic_03",
	"CUP_U_C_racketeer_01",
	"CUP_U_C_racketeer_02",
	"CUP_U_C_racketeer_03",
	"CUP_U_C_racketeer_04",
	"CUP_U_C_Profiteer_01",
	"CUP_U_C_Profiteer_02",
	"CUP_U_C_Profiteer_03",
	"CUP_U_C_Profiteer_04",
	"CUP_U_O_CHDKZ_Lopotev"
];

_civBackpacks = [
	"CUP_B_HikingPack_Civ",
	"CUP_B_CivPack_WDL",
	"CUP_B_IDF_Backpack",
	"CUP_B_SLA_Medicbag"
];

_civVehicles = [
	"CUP_C_Skoda_Blue_CIV",		0.9,
	"CUP_C_Skoda_Green_CIV",	0.9,
	"CUP_C_Skoda_Red_CIV", 		0.9,
	"CUP_C_Skoda_White_CIV",	0.9,
	"CUP_C_Golf4_red_Civ",		0.9,
	"CUP_C_TT650_CIV",			0.9,
	"CUP_C_Lada_White_CIV",		0.9,
	"CUP_C_Lada_Red_CIV",		0.9,
	"CUP_C_Datsun_Covered",		0.8,
	"CUP_C_Datsun_Plain",		0.8,
	"CUP_C_Datsun_Tubeframe",	0.8,
	"CUP_C_SUV_CIV",			0.8,
	"CUP_C_Ikarus_Chernarus",	0.6,
	"CUP_C_Ural_Open_Civ_03",	0.6,
	"CUP_C_Ural_Civ_03",		0.6,
	"CUP_C_Tractor_CIV",		0.4
];

_civVehiclesOnlyNames = _civVehicles select { _x isEqualType "" };

//==== API ====
_api = [];
_api resize T_API_SIZE;
_api set [T_API_fnc_init, {}];
_array set [T_API, _api];

// ==== Undercover ====
_uc = [];
_uc resize T_UC_SIZE;
_uc set[T_UC_headgear, +_civHeadgear];
_uc set[T_UC_facewear, +_civFacewear];
_uc set[T_UC_uniforms, +_civUniforms];
_uc set[T_UC_backpacks, +_civBackpacks];
_uc set[T_UC_civVehs, +_civVehiclesOnlyNames];
_array set [T_UC, _uc];

// ==== Arsenal ====
_arsenal = [];
_arsenal resize T_ARSENAL_SIZE;
_arsenal set[T_ARSENAL_primary, []];
_arsenal set[T_ARSENAL_primary_items, []];
_arsenal set[T_ARSENAL_secondary, []];
_arsenal set[T_ARSENAL_secondary_items, []];
_arsenal set[T_ARSENAL_handgun, [
	"ACE_Flashlight_Maglite_ML300L"
]];
_arsenal set[T_ARSENAL_handgun_items, []];
_arsenal set[T_ARSENAL_ammo, []];
_arsenal set[T_ARSENAL_items, []];
_arsenal set[T_ARSENAL_vests, [
	"CUP_V_I_Guerilla_Jacket"
]];
_arsenal set[T_ARSENAL_backpacks, [
	"ACE_TacticalLadder_Pack",
	"CUP_B_HikingPack_Civ",
	"CUP_B_CivPack_WDL",
	"CUP_B_IDF_Backpack",
	"CUP_B_SLA_Medicbag"
]];
_arsenal set[T_ARSENAL_uniforms, +_civUniforms];
_arsenal set[T_ARSENAL_facewear, +_civFacewear];
_arsenal set[T_ARSENAL_headgear, +_civHeadgear];
_array set [T_ARSENAL, _arsenal];

// ==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["CUP_RUS_CIVILIAN_Militant_1"] };
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "CUP_RUS_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
	"CUP_RUS_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
	"CUP_RUS_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
	"CUP_RUS_CIVILIAN_Militant_1"
]];
_array set [T_INF, _inf];

//==== Vehicles ====
_veh = [];
_veh resize T_VEH_SIZE;
_veh set [T_VEH_default, _civVehicles];
_array set [T_VEH, _veh];

// Inventory
_inv = [T_INV] call t_fnc_newCategory;
_inv set [T_INV_items, +t_miscItems_civ_modern ];
_array set [T_INV, _inv];

// Return final array
_array
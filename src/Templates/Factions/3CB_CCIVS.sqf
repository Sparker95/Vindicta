/*
Civilian template for ARMA III
*/
_array = [];
_array resize T_SIZE;

_array set [T_NAME, "t3CB_CCIVS"];
_array set [T_DESCRIPTION, "Chernarus civilians from 3CB."];
_array set [T_DISPLAY_NAME, "3CB Chernarus Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops",	// RHSGREF
	"UK3CB_Factions_CPD", // 3CB Factions
	"ace_compat_rhs_afrf3", // ACE Compat - RHS Armed Forces of the Russian Federation
	"ace_compat_rhs_gref3", // ACE Compat - RHS: GREF
	"ace_compat_rhs_usf3" // ACE Compat - RHS United States Armed Forces
]];

_civHeadgear = [
	"UK3CB_H_Beanie_01",
	"H_Cap_blk",
	"H_Cap_grn"
];

_civFacewear = [
		"G_Spectacles",
		"G_Sport_Red",
		"G_Squares_Tinted",
		"G_Squares",
		"G_Spectacles_Tinted",
		"G_Shades_Black",
		"G_Shades_Blue",
		"G_Aviator"
];

_civUniforms = [
	"UK3CB_CHC_C_U_HIKER_01",
	"UK3CB_CHC_C_U_HIKER_02",
	"UK3CB_CHC_C_U_HIKER_03",
	"UK3CB_CHC_C_U_HIKER_04",
	"UK3CB_CHC_C_U_ACTIVIST_01",
	"UK3CB_CHC_C_U_ACTIVIST_02",
	"UK3CB_CHC_C_U_ACTIVIST_03",
	"UK3CB_CHC_C_U_ACTIVIST_04",
	"UK3CB_CHC_C_U_CIT_01",
	"UK3CB_CHC_C_U_CIT_02",
	"UK3CB_CHC_C_U_CIT_03",
	"UK3CB_CHC_C_U_CIT_04",
	"UK3CB_CHC_C_U_COACH_01",
	"UK3CB_CHC_C_U_COACH_02",
	"UK3CB_CHC_C_U_COACH_03",
	"UK3CB_CHC_C_U_COACH_04",
	"UK3CB_CHC_C_U_COACH_05",
	"UK3CB_CHC_C_U_WORK_01",
	"UK3CB_CHC_C_U_WORK_02",
	"UK3CB_CHC_C_U_WORK_03",
	"UK3CB_CHC_C_U_WORK_04",
	"UK3CB_CHC_C_U_PROF_01",
	"UK3CB_CHC_C_U_PROF_02",
	"UK3CB_CHC_C_U_PROF_03",
	"UK3CB_CHC_C_U_PROF_04",
	"UK3CB_CHC_C_U_VILL_01",
	"UK3CB_CHC_C_U_VILL_02",
	"UK3CB_CHC_C_U_VILL_03",
	"UK3CB_CHC_C_U_VILL_04",
	"UK3CB_CHC_C_U_WOOD_01",
	"UK3CB_CHC_C_U_WOOD_02",
	"UK3CB_CHC_C_U_WOOD_03",
	"UK3CB_CHC_C_U_WOOD_04"
];

_civBackpacks = [
	"UK3CB_B_Alice_Bedroll_K",
	"UK3CB_B_Alice_K"
];

_civVehicles = [
	"UK3CB_CHC_C_Ikarus",					0.3,
	"UK3CB_CHC_C_Datsun_Civ_Closed",		0.9,
	"UK3CB_CHC_C_Datsun_Civ_Open",		0.9,
	"UK3CB_CHC_C_Hilux_Civ_Closed",		0.9,
	"UK3CB_CHC_C_Hilux_Civ_Open",		0.9,
	"UK3CB_CHC_C_Kamaz_Covered",		0.7,
	"UK3CB_CHC_C_Kamaz_Fuel",		0.3,
	"UK3CB_CHC_C_Kamaz_Open",		0.7,
	"UK3CB_CHC_C_Kamaz_Repair",		0.9,
	"UK3CB_CHC_C_Lada",		0.9,
	"UK3CB_CHC_C_LR_Closed",		0.6,
	"UK3CB_CHC_C_LR_Open",		0.6,
	"UK3CB_CHC_C_V3S_Refuel",		0.3,
	"UK3CB_CHC_C_V3S_Repair",		0.3,
	"UK3CB_CHC_C_V3S_Closed",		0.6,
	"UK3CB_CHC_C_V3S_Open",		0.5,
	"UK3CB_CHC_C_Sedan",		0.9,
	"UK3CB_CHC_C_Skoda",		0.9,
	"UK3CB_CHC_C_S1203",		0.9,
	"UK3CB_CHC_C_S1203_Amb",		0.1,
	"UK3CB_CHC_C_UAZ_Closed",		0.6,
	"UK3CB_CHC_C_UAZ_Open",		0.6,
	"UK3CB_CHC_C_Ural",		0.6,
	"UK3CB_CHC_C_Ural_Fuel",		0.3,
	"UK3CB_CHC_C_Ural_Open",		0.6,
	"UK3CB_CHC_C_Ural_Empty",		0.6,
	"UK3CB_CHC_C_Ural_Repair",		0.3,
	"UK3CB_CHC_C_Gaz24",		0.9,
	"UK3CB_CHC_C_Golf",		0.9
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
]];
_arsenal set[T_ARSENAL_backpacks, [
	"UK3CB_B_Alice_Bedroll_K",
	"UK3CB_B_Alice_K"
]];
_arsenal set[T_ARSENAL_uniforms, +_civUniforms];
_arsenal set[T_ARSENAL_facewear, +_civFacewear];
_arsenal set[T_ARSENAL_headgear, +_civHeadgear];
_array set [T_ARSENAL, _arsenal];

// ==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["3CB_CCIVS_CIVILIAN_Militant_1"] };
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "3CB_CCIVS_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
	"3CB_CCIVS_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
	"3CB_CCIVS_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
	"3CB_CCIVS_CIVILIAN_Militant_1"
]];
_array set [T_INF, _inf];

//==== Vehicles ====
_veh = [];
_veh resize T_VEH_SIZE;
_veh set [T_VEH_default, _civVehicles];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];

_array set [T_VEH, _veh];

// Inventory
_inv = [T_INV] call t_fnc_newCategory;
_inv set [T_INV_items, +t_miscItems_civ_modern ];
_array set [T_INV, _inv];

// Return final array
_array
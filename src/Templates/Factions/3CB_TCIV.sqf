/*
Civilian template for ARMA III
*/
_array = [];
_array resize T_SIZE;

_array set [T_NAME, "t3CB_TCIV"];
_array set [T_DESCRIPTION, "Takistani civilians from 3CB."];
_array set [T_DISPLAY_NAME, "3CB TKA Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops",	// RHSGREF
	"uk3cb_factions_TKA", // 3CB Factions
	"ace_compat_rhs_afrf3", // ACE Compat - RHS Armed Forces of the Russian Federation
	"ace_compat_rhs_gref3", // ACE Compat - RHS: GREF
	"ace_compat_rhs_usf3" // ACE Compat - RHS United States Armed Forces
]];

_civHeadgear = 	[
	"UK3CB_TKC_H_Turban_01_1",
	"UK3CB_TKC_H_Turban_02_1",
	"UK3CB_TKC_H_Turban_06_1",
	"UK3CB_TKC_H_Turban_03_1",
	"UK3CB_TKC_H_Turban_04_1",
	"UK3CB_TKC_H_Turban_05_1"
];

_civFacewear = 	[
	"UK3CB_G_Face_Wrap_01",
	"G_Aviator"	// Yes! Yes!
];

_civUniforms = 	[
	"UK3CB_TKC_C_U_01",
	"UK3CB_TKC_C_U_01_B",
	"UK3CB_TKC_C_U_01_C",
	"UK3CB_TKC_C_U_01_D",
	"UK3CB_TKC_C_U_01_E",
	"UK3CB_TKC_C_U_02",
	"UK3CB_TKC_C_U_02_B",
	"UK3CB_TKC_C_U_02_C",
	"UK3CB_TKC_C_U_02_D",
	"UK3CB_TKC_C_U_02_E",
	"UK3CB_TKC_C_U_03",
	"UK3CB_TKC_C_U_03_B",
	"UK3CB_TKC_C_U_03_C",
	"UK3CB_TKC_C_U_03_D",
	"UK3CB_TKC_C_U_03_E",
	"UK3CB_TKC_C_U_06",
	"UK3CB_TKC_C_U_06_B",
	"UK3CB_TKC_C_U_06_C",
	"UK3CB_TKC_C_U_06_D",
	"UK3CB_TKC_C_U_06_E",
	"UK3CB_TKM_I_U_01",
	"UK3CB_TKM_I_U_01_B",
	"UK3CB_TKM_I_U_01_C",
	"UK3CB_TKM_I_U_03",
	"UK3CB_TKM_I_U_03_B",
	"UK3CB_TKM_I_U_03_C",
	"UK3CB_TKM_I_U_04",
	"UK3CB_TKM_I_U_04_B",
	"UK3CB_TKM_I_U_04_C",
	"UK3CB_TKM_I_U_05",
	"UK3CB_TKM_I_U_05_B",
	"UK3CB_TKM_I_U_05_C",
	"UK3CB_TKM_I_U_06",
	"UK3CB_TKM_I_U_06_B",
	"UK3CB_TKM_I_U_06_C"
];

_civVests = 	[];

_civBackpacks = [
    "ACE_TacticalLadder_Pack",
    "B_Messenger_Black_F",
    "B_Messenger_Coyote_F",
    "B_Messenger_Olive_F"
];

_civVehicles = 	[
	"UK3CB_TKC_C_Ikarus",	0.3,
	"UK3CB_TKC_C_Datsun_Civ_Closed",	0.9,
	"UK3CB_TKC_C_Datsun_Civ_Open",	0.9,
	"UK3CB_TKC_C_Hatchback",	0.9,
	"UK3CB_TKC_C_Hilux_Civ_Closed",		0.9,
	"UK3CB_TKC_C_Hilux_Civ_Open",	0.9,
	"UK3CB_TKC_C_Kamaz_Covered",	0.9,
	"UK3CB_TKC_C_V3S_Refuel",			0.2,
	"UK3CB_TKC_C_Kamaz_Open",	0.7,
	"UK3CB_TKC_C_Kamaz_Repair",			0.2,
	"UK3CB_TKC_C_Lada",				0.9,
	"UK3CB_TKC_C_Lada_Taxi",			0.6,
	"UK3CB_TKC_C_LR_Closed",		0.8,
	"UK3CB_TKC_C_V3S_Open",		0.7,
	"UK3CB_TKC_C_V3S_Refuel",		0.2,
	"UK3CB_TKC_C_V3S_Repair",		0.2,
	"UK3CB_TKC_C_V3S_Closed",		0.7,
	"UK3CB_TKC_C_Sedan",		0.8,
	"UK3CB_TKC_C_Skoda",		0.7,
	"UK3CB_TKC_C_S1203",		0.7,
	"UK3CB_TKC_C_S1203_Amb",		0.4,
	"UK3CB_TKC_C_UAZ_Closed",		0.6,
	"UK3CB_TKC_C_UAZ_Open",		0.6,
	"UK3CB_TKC_C_Ural",		0.6,
	"UK3CB_TKC_C_Fuel",		0.2,
	"UK3CB_TKC_C_Open",		0.7,
	"UK3CB_TKC_C_Ural_Empty",		0.3,
	"UK3CB_TKC_C_Ural_Repair",		0.2
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
_uc set[T_UC_vests, +_civVests];
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
_arsenal set[T_ARSENAL_vests, +_civVests];
_arsenal set[T_ARSENAL_backpacks, [
    "ACE_TacticalLadder_Pack",
    "B_Messenger_Black_F",
    "B_Messenger_Coyote_F",
    "B_Messenger_Olive_F"
]];
_arsenal set[T_ARSENAL_uniforms, +_civUniforms];
_arsenal set[T_ARSENAL_facewear, +_civFacewear];
_arsenal set[T_ARSENAL_headgear, +_civHeadgear];
_array set [T_ARSENAL, _arsenal];

// ==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["3CB_TCIV_CIVILIAN_Militant_1"] };
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "3CB_TCIV_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
	"3CB_TCIV_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
	"3CB_TCIV_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
	"3CB_TCIV_CIVILIAN_Militant_1"
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
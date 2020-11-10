/*
Civilian template for ARMA III
*/
_array = [];
_array resize T_SIZE;

_array set [T_NAME, "tCUP_TKA_CIVILIAN"];
_array set [T_DESCRIPTION, "Takistani civilians from CUP."];
_array set [T_DISPLAY_NAME, "CUP TKA Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, ["CUP_Creatures_People_Civil_Takistan","CUP_Vehicles_Core"]];

_civHeadgear = 	[
	//Lungee (No front)
	"CUP_H_TKI_Lungee_Open_01",
	"CUP_H_TKI_Lungee_Open_02",
	"CUP_H_TKI_Lungee_Open_03",
	"CUP_H_TKI_Lungee_Open_04",
	"CUP_H_TKI_Lungee_Open_05",
	"CUP_H_TKI_Lungee_Open_06",
	//Lungee (Front)
	"CUP_H_TKI_Lungee_01",
	"CUP_H_TKI_Lungee_02",
	"CUP_H_TKI_Lungee_03",
	"CUP_H_TKI_Lungee_04",
	"CUP_H_TKI_Lungee_05",
	"CUP_H_TKI_Lungee_06",
	//Pakol
	"CUP_H_TKI_Pakol_2_03",
	"CUP_H_TKI_Pakol_2_02",
	"CUP_H_TKI_Pakol_2_01",
	"CUP_H_TKI_Pakol_1_06",
	"CUP_H_TKI_Pakol_1_05",
	"CUP_H_TKI_Pakol_1_04",
	"CUP_H_TKI_Pakol_1_03",
	"CUP_H_TKI_Pakol_2_06",
	"CUP_H_TKI_Pakol_2_05",
	"CUP_H_TKI_Pakol_2_04",
	"CUP_H_TKI_Pakol_1_01",
	//Skull Cap
	"CUP_H_TKI_SkullCap_06",
	"CUP_H_TKI_SkullCap_05",
	"CUP_H_TKI_SkullCap_04",
	"CUP_H_TKI_SkullCap_03",
	"CUP_H_TKI_SkullCap_02",
	"CUP_H_TKI_SkullCap_01"
];

_civFacewear = 	[
	"CUP_G_TK_RoundGlasses_gold",
	"CUP_G_TK_RoundGlasses_blk",
	"CUP_G_TK_RoundGlasses"
];

_civUniforms = 	[
	"CUP_O_TKI_Khet_Jeans_01",
	"CUP_O_TKI_Khet_Jeans_02",
	"CUP_O_TKI_Khet_Jeans_03",
	"CUP_O_TKI_Khet_Jeans_04",
	"CUP_O_TKI_Khet_Partug_01",
	"CUP_O_TKI_Khet_Partug_02",
	"CUP_O_TKI_Khet_Partug_03",
	"CUP_O_TKI_Khet_Partug_04",
	"CUP_O_TKI_Khet_Partug_05",
	"CUP_O_TKI_Khet_Partug_06",
	"CUP_O_TKI_Khet_Partug_07",
	"CUP_O_TKI_Khet_Partug_08"
];

_civVests = 	[
	//Waist Coat
	"CUP_V_OI_TKI_Jacket6_06",
	"CUP_V_OI_TKI_Jacket6_05",
	"CUP_V_OI_TKI_Jacket6_04",
	//Light Jacket
	"CUP_V_OI_TKI_Jacket5_06",
	"CUP_V_OI_TKI_Jacket5_05",
	"CUP_V_OI_TKI_Jacket5_04",
	//Heavy Jacket
	"CUP_V_OI_TKI_Jacket1_05",
	"CUP_V_OI_TKI_Jacket1_06",
	"CUP_V_OI_TKI_Jacket1_04"
];

_civBackpacks = [
	"CUP_B_IDF_Backpack",
	"CUP_B_SLA_Medicbag"
];

_civVehicles = 	[
	"CUP_C_Volha_Blue_TKCIV",	0.9,
	"CUP_C_Volha_Gray_TKCIV",	0.9,
	"CUP_C_Volha_Limo_TKCIV",	0.9,
	"CUP_C_Lada_GreenTK_CIV",	0.9,
	"CUP_C_Lada_TK2_CIV",		0.9,
	"CUP_C_UAZ_Unarmed_TK_CIV",	0.9,
	"CUP_C_UAZ_Open_TK_CIV",	0.9,
	"CUP_C_TT650_CIV",			0.9,
	"CUP_C_LR_Transport_CTK",	0.7,
	"CUP_C_S1203_CIV",			0.7,
	"CUP_C_SUV_TK",				0.7,
	"CUP_C_Ikarus_TKC",			0.6,
	"CUP_C_Ural_Civ_01",		0.6,
	"CUP_C_V3S_Open_TKC",		0.6,
	"CUP_C_V3S_Covered_TKC",	0.6
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
_inf = _inf apply { ["CUP_TKA_CIVILIAN_Militant_1"] };
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "CUP_TKA_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
	"CUP_TKA_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
	"CUP_TKA_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
	"CUP_TKA_CIVILIAN_Militant_1"
]];
_array set [T_INF, _inf];

//==== Vehicles ====
_veh = [];
_veh resize T_VEH_SIZE;
_veh set [T_VEH_default, _civVehicles];
_veh set [T_VEH_boat_unarmed, ["C_Boat_Civil_01_F","C_Rubberboat","C_Boat_Transport_02_F"]];
_array set [T_VEH, _veh];

// Inventory
_inv = [T_INV] call t_fnc_newCategory;
_inv set [T_INV_items, +t_miscItems_civ_modern ];
_array set [T_INV, _inv];

// Return final array
_array
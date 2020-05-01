/*
Civilian template for ARMA III
*/
_array = [];
_array resize T_SIZE;

_array set [T_NAME, "tIRA_CIVILIAN"];
_array set [T_DESCRIPTION, "Irish Civilians from Project OPPFOR."];
_array set [T_DISPLAY_NAME, "PO Irish Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, []];

_civHeadgear = [
	"LOP_H_Villager_cap",
	"PO_H_cap_tub",
	"PO_H_bonnie_tub",
	"H_Beret_blk"
];

_civFacewear = [	
	"G_Balaclava_blk",
	"G_Balaclava_oli"
	];

_civUniforms = [
	"LOP_U_CHR_Functionary_01",
	"LOP_U_CHR_Functionary_02",
	"LOP_U_CHR_Citizen_03",
	"LOP_U_CHR_Citizen_04",
	"LOP_U_CHR_Citizen_01",
	"LOP_U_CHR_Citizen_02",
	"LOP_U_CHR_Citizen_05",
	"LOP_U_CHR_Citizen_06",
	"LOP_U_CHR_Citizen_07",
	"LOP_U_CHR_Villager_01",
	"LOP_U_CHR_Villager_02",
	"LOP_U_CHR_Villager_03",
	"LOP_U_CHR_Villager_04",
	"LOP_U_CHR_Profiteer_01",
	"LOP_U_CHR_Profiteer_02",
	"LOP_U_CHR_Profiteer_03",
	"LOP_U_CHR_Profiteer_04",
	"LOP_U_CHR_SchoolTeacher_01",
	"LOP_U_PMC_floral",
	"LOP_U_PMC_tacky",
	"LOP_U_PMC_blue_plaid",
	"LOP_U_PMC_grn_plaid",
	"LOP_U_PMC_orng_plaid",
	"LOP_U_PMC_red_plaid",
	"LOP_U_CHR_Woodlander_01",
	"LOP_U_CHR_Worker_01",
	"LOP_U_CHR_Worker_02",
	"LOP_U_CHR_Worker_03",
	"LOP_U_BH_Fatigue_GUE_FWDL", 
	"LOP_U_BH_Fatigue_FWDL", 
	"LOP_U_IRA_Fatigue_DPM",
	"LOP_U_IRA_Fatigue_HTR_DPM_J",
	"LOP_U_IRA_Fatigue_HTR_DPM",
	"LOP_U_ISTS_Fatigue_18",
	"LOP_U_BH_Fatigue_M81",
	"LOP_U_CHR_Worker_04"
];

_civBackpacks = [
	"B_Kitbag_rgr",
	"B_AssaultPack_rgr"
];

_civVehicles = [
	"LOP_CHR_Civ_Landrover",	0.9,
	"LOP_CHR_Civ_Hatchback",	0.9,
	"LOP_CHR_Civ_Offroad", 		0.9,
	"LOP_CHR_Civ_UAZ_Open",		0.2,
	"LOP_CHR_Civ_UAZ",			0.2
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
_arsenal set[T_ARSENAL_handgun, []];
_arsenal set[T_ARSENAL_handgun_items, []];
_arsenal set[T_ARSENAL_ammo, []];
_arsenal set[T_ARSENAL_items, []];
_arsenal set[T_ARSENAL_vests, []];
_arsenal set[T_ARSENAL_backpacks, []];
_arsenal set[T_ARSENAL_uniforms, +_civUniforms];
_arsenal set[T_ARSENAL_facewear, +_civFacewear];
_arsenal set[T_ARSENAL_headgear, +_civHeadgear];
_array set [T_ARSENAL, _arsenal];

// ==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "LOP_IRA_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
	"LOP_IRA_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
	"LOP_IRA_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
	"LOP_IRA_CIVILIAN_Militant_1"
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
/*
Civilian template for ARMA III
*/

_civHeadgear = [];

_civHeadgear = [];

_civFacewear = [];

_civUniforms = [
	"gm_gc_civ_uniform_man_01_80_blk",
	"gm_gc_civ_uniform_man_01_80_blu",
	"gm_gc_civ_uniform_man_02_80_brn",
	"gm_ge_civ_uniform_blouse_80_gry",
	"gm_ge_ff_uniform_man_80_orn",
	"gm_ge_dbp_uniform_suit_80_blu"
];

_civBackpacks = [
	"gm_ge_backpack_satchel_80_blk",
	"gm_ge_backpack_satchel_80_san"
];

_civVehicles = [
	"gm_ge_dbp_bicycle_01_ylw",	8, // Bicycle
	"gm_gc_civ_p601",         	7, // Car p601
	"gm_ge_civ_typ1200",      	7, // Car typ1200
	"gm_ge_civ_u1300l",		  	4, // Truck
	"gm_gc_dp_p601",		 	2, // Postal Service p601
	"gm_ge_dbp_typ1200",	  	2, // Postal Service typ1200
	"gm_ge_ff_typ1200",		 	1, // Fire Service typ1200
	"gm_gc_ff_p601",		  	1  // Fire Service p601	
];

_civVehiclesOnlyNames = _civVehicles select { _x isEqualType "" };

_array = [];

_array resize T_SIZE; //Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tGM_Civilian"];
_array set [T_DESCRIPTION, "Cold war era, civilians."];
_array set [T_DISPLAY_NAME, "GM Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, ["gm_core"]];

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
	"gm_gc_bgs_vest_80_border_str"
]];
_arsenal set[T_ARSENAL_backpacks, [
	"ACE_TacticalLadder_Pack",
	"gm_ge_backpack_satchel_80_blk",
	"gm_ge_backpack_satchel_80_san"
]];
_arsenal set[T_ARSENAL_uniforms, [
	"gm_gc_civ_uniform_man_01_80_blk",
	"gm_gc_civ_uniform_man_01_80_blu",
	"gm_gc_civ_uniform_man_02_80_brn",
	"gm_ge_civ_uniform_blouse_80_gry",
	"gm_pl_army_uniform_soldier_rolled_80_moro",
	"gm_pl_army_uniform_soldier_autumn_80_moro",
	"gm_pl_army_uniform_soldier_80_moro"
]];
_arsenal set[T_ARSENAL_facewear, +_civFacewear];
_arsenal set[T_ARSENAL_headgear, +_civHeadgear];
_array set [T_ARSENAL, _arsenal];

// ==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["GM_CIVILIAN_Militant_1"] };
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "GM_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
	"GM_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
	"GM_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
	"GM_CIVILIAN_Militant_1"
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
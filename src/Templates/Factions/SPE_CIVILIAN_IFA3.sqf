_array = [];

_array set [T_SIZE-1, nil];

// Name, description, faction, addons, etc
_array set [T_NAME, "tSPE_CIVILIAN_IFA3"];
_array set [T_DESCRIPTION, "World War 2 Civilians made using content from Spearhead 1944 DLC + Iron Front."];
_array set [T_DISPLAY_NAME, "SPE DLC + IFA3 - Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F",
        "WW2_SPE_Core_c_Core_c",
        "WW2_Core_c_WW2_Core_c"
		]];

//==== Arsenal ====
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
_arsenal set[T_ARSENAL_backpacks, [
    "B_SPE_CIV_musette",
	"B_SPE_CIV_satchel"
]];
_arsenal set[T_ARSENAL_uniforms, [
    "U_SPE_CIV_Citizen_1",
	"U_SPE_CIV_Citizen_1_trop",
	"U_SPE_CIV_Citizen_1_tie",
	"U_SPE_CIV_Citizen_2",
	"U_SPE_CIV_Citizen_2_trop",
	"U_SPE_CIV_Citizen_2_tie",
	"U_SPE_CIV_Citizen_3",
	"U_SPE_CIV_Citizen_3_trop",
	"U_SPE_CIV_Citizen_3_tie",
	"U_SPE_CIV_Citizen_4",
	"U_SPE_CIV_Citizen_4_trop",
	"U_SPE_CIV_Citizen_4_tie",
	"U_SPE_CIV_Citizen_5",
	"U_SPE_CIV_Citizen_5_trop",
	"U_SPE_CIV_Citizen_5_tie",
	"U_SPE_CIV_Citizen_6",
	"U_SPE_CIV_Citizen_6_trop",
	"U_SPE_CIV_Citizen_6_tie",
	"U_SPE_CIV_Citizen_7",
	"U_SPE_CIV_Citizen_7_trop",
	"U_SPE_CIV_Citizen_7_tie",
	"U_SPE_CIV_Worker_1",
	"U_SPE_CIV_Worker_1_trop",
	"U_SPE_CIV_Worker_1_tie",
	"U_SPE_CIV_Worker_2",
    "U_SPE_CIV_Worker_2_trop",
    "U_SPE_CIV_Worker_2_tie",
    "U_SPE_CIV_Worker_3",
    "U_SPE_CIV_Worker_3_trop",
    "U_SPE_CIV_Worker_3_tie",
    "U_SPE_CIV_Worker_4",
    "U_SPE_CIV_Worker_4_trop",
    "U_SPE_CIV_Worker_4_tie",
    "U_SPE_CIV_Worker_Coverall_1",
    "U_SPE_CIV_Worker_Coverall_1_trop",
    "U_SPE_CIV_Worker_Coverall_2",
    "U_SPE_CIV_Worker_Coverall_2_trop",
    "U_SPE_CIV_Worker_Coverall_3",
    "U_SPE_CIV_Worker_Coverall_3_trop",
    "U_SPE_CIV_pak2_bruin",
    "U_SPE_CIV_pak2_bruin_tie",
    "U_SPE_CIV_pak2_bruin_swetr",
    "U_SPE_CIV_pak2_grijs",
    "U_SPE_CIV_pak2_grijs_tie",
    "U_SPE_CIV_pak2_grijs_swetr",
    "U_SPE_CIV_pak2_zwart",
    "U_SPE_CIV_pak2_zwart_alt",
    "U_SPE_CIV_pak2_zwart_tie",
    "U_SPE_CIV_pak2_zwart_tie_alt",
    "U_SPE_CIV_pak2_zwart_swetr",
    "U_SPE_CIV_Swetr_1",
    "U_SPE_CIV_Swetr_1_vest",
    "U_SPE_CIV_Swetr_2",
    "U_SPE_CIV_Swetr_2_vest",
    "U_SPE_CIV_Swetr_3",
    "U_SPE_CIV_Swetr_3_vest",
    "U_SPE_CIV_Swetr_4",
    "U_SPE_CIV_Swetr_4_vest",
    "U_SPE_CIV_Swetr_5",
    "U_SPE_CIV_Swetr_5_vest",
    "U_SPE_FFI_Casual_1",
    "U_SPE_FFI_Casual_1_trop",
    "U_SPE_FFI_Casual_2",
    "U_SPE_FFI_Casual_2_trop",
    "U_SPE_FFI_Casual_3",
    "U_SPE_FFI_Casual_3_trop",
    "U_SPE_FFI_Casual_4",
    "U_SPE_FFI_Casual_4_trop",
    "U_SPE_FFI_Casual_5",
    "U_SPE_FFI_Casual_5_trop",
    "U_SPE_FFI_Casual_6",
    "U_SPE_FFI_Casual_6_trop",
    "U_SPE_FFI_Casual_7",
    "U_SPE_FFI_Casual_7_trop",
    "U_SPE_FFI_Worker_1",
    "U_SPE_FFI_Worker_1_trop",
    "U_SPE_FFI_Worker_2",
    "U_SPE_FFI_Worker_2_trop",
    "U_SPE_FFI_Worker_3",
    "U_SPE_FFI_Worker_3_trop",
    "U_SPE_FFI_Worker_4",
    "U_SPE_FFI_Worker_4_trop",
    "U_SPE_FFI_Jacket_bruin",
    "U_SPE_FFI_Jacket_bruin_swetr",
    "U_SPE_FFI_Jacket_grijs",
    "U_SPE_FFI_Jacket_grijs_swetr",
    "U_SPE_FFI_Jacket_zwart",
    "U_SPE_FFI_Jacket_zwart_swetr",
    "U_SPE_FFI_Jacket_zwart_Alt"
]];
_arsenal set[T_ARSENAL_facewear, []];
_arsenal set[T_ARSENAL_headgear, [
    "H_SPE_CIV_Worker_Cap_1",
    "H_SPE_CIV_Worker_Cap_2",
    "H_SPE_CIV_Worker_Cap_3",
    "H_SPE_CIV_Fedora_Cap_1",
    "H_SPE_CIV_Fedora_Cap_2",
    "H_SPE_CIV_Fedora_Cap_3",
    "H_SPE_CIV_Fedora_Cap_4",
    "H_SPE_CIV_Fedora_Cap_5",
    "H_SPE_CIV_Fedora_Cap_6"
]];
_arsenal set [T_ARSENAL_grenades, []];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["SPE_CIVILIAN_IFA3_Default"] };
_inf set [T_INF_default, ["SPE_CIV_Citizen_1"]];
_inf set [T_INF_rifleman, [
    "SPE_PLAYER_IFA3_1"
]];
_inf set [T_INF_unarmed, [
    "SPE_CIVILIAN_IFA3_1"
]];
_inf set [T_INF_exp, [
    "SPE_CIVILIAN_IFA3_Saboteur_1"
]];
_inf set [T_INF_survivor, [
    "SPE_CIVILIAN_IFA3_Militant_1"
]];

private _civCars = [
    "LIB_GazM1",          10,
    "LIB_GazM1_dirty",    10
];
private _civCarsClasses = _civCars select {_x isEqualType "";};

private _civBoats = [];
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
_inv set [T_INV_backpacks, ["B_SPE_CIV_musette", "B_SPE_CIV_satchel"]];

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
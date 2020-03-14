removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

private _uniforms = [
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
	"U_LIB_CIV_Rocker_1",
	"U_LIB_CIV_Priest"
];

if(random 10 > 5) then { this linkItem "ItemWatch" };

private _gunsAndAmmo = [
	// pistols
	["LIB_Colt_M1911",		"fow_7rnd_45acp",		true],	1,
	["fow_w_m1911",			"fow_7rnd_45acp",		true],	1,
	["LIB_P38",				"lib_8rnd_9x19",		true],	0.9,
	["LIB_P08",				"fow_8rnd_9x19",		true],	0.7,
	["fow_w_p08",			"fow_8rnd_9x19",		true],	0.7,
	["LIB_M1896",			"lib_10rnd_9x19_m1896",	true],	0.5,
	["fow_w_p640p",			"fow_13rnd_9x19",		true],	0.5,
	["LIB_TT33",			"lib_8rnd_762x25",		true],	0.9,
	["LIB_WaltherPPK",		"fow_8rnd_9x19",		true],	0.8,
	["LIB_M1895",			"lib_7rnd_762x38",		true],	0.6,
	["LIB_Webley_mk6",		"lib_6rnd_455",			true],	0.6,
	["fow_w_webley",		"fow_6rnd_455",			true],	0.6,
	["fow_w_welrod_mkii",	"fow_8rnd_765x17",			true],	0.3,
	["fow_w_p35",			"fow_8rnd_9x19",		true],	0.7,
	// long
	["LIB_K98",					"fow_5rnd_792x57",			true],	0.1,
	["LIB_M1903A3_Springfield",	"fow_5rnd_762x63",			true],	0.1,
	["LIB_Sten_Mk2",			"lib_32rnd_9x19_sten",		true],	0.05,
	["LIB_MP38",				"fow_32rnd_9x19_mp40",		true],	0.05,
	["IFA3_PPS43",				"ifa3_35rnd_762x25_pps",	true],	0.05,
	["LIB_M9130",				"lib_5rnd_762x54",			true],	0.1,
	["LIB_PPSh41_m",			"lib_35rnd_762x25",			true],	0.05,
	["LIB_M3_GreaseGun",		"fow_30rnd_45acp",			true],	0.05,
	["LIB_LeeEnfield_No4",		"lib_10rnd_770x56",			true],	0.1,
	["LIB_K98_Late",			"fow_5rnd_792x57",			true],	0.1,
	["LIB_M1A1_Thompson",		"fow_30rnd_45acp",			true],	0.01,
	["LIB_MP40",				"fow_32rnd_9x19_mp40",		true],	0.05,
	["fow_w_k98",				"fow_5rnd_792x57",			true],	0.1,
	["fow_w_m1903A1",			"fow_5rnd_762x63",			true],	0.1,
	["fow_w_m1_thompson",		"fow_30rnd_45acp",			true],	0.01,
	["fow_w_m3",				"fow_30rnd_45acp",			true],	0.05,
	["fow_w_leeenfield_no4mk1",	"fow_10rnd_303",			true],	0.1,
	["fow_w_mp40",				"fow_32rnd_9x19_mp40",		true],	0.05,
	["LIB_DELISLE",				"lib_7rnd_45acp_delisle",	true],	0.1
];

this forceAddUniform selectRandom _uniforms;

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];

this addWeapon _gun;

if(_isPistol) then {
	this addHandgunItem "acc_flashlight_pistol";
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, "acc_flashlight"];
	this addWeaponItem [_gun, _ammo];
};

for "_i" from 1 to 5 do { this addItemToUniform _ammo };

if(random 5 < 1) then {
	this addGoggles selectRandomWeighted [
		"G_Squares", 			1
	];
};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

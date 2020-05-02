removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//===Headgear===
if (random 10 < 3) then {
	private _headgear = [
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

	this addHeadgear selectRandom _headgear;
};

//===Facewear===
if (random 10 < 3) then {
	private _Facewear = [
		"G_GEHeadBandage_Bloody",
		"G_GEHeadBandage_Clean",
		"G_GEHeadBandage_Stained",
		"G_LIB_GER_Gloves4",
		"G_LIB_GER_Gloves2",
		"G_LIB_GER_Gloves1",
		"G_LIB_GER_Gloves3",
		"G_LIB_Scarf2_B",
		"G_LIB_Scarf2_G",
		"G_LIB_Scarf_B",
		"G_LIB_Scarf_G",
		"G_geBI_Bandanna_khk",
		"G_geBI_Bandanna_blk",
		"G_geBI_Bandanna_oli"
	];

	this addGoggles selectRandom _Facewear;
};

//===Uniform===
this forceAddUniform selectRandom [
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
		"U_LIB_CIV_Functionary_4"
];

if(random 10 > 5) then { this linkItem "ItemWatch" };

private _gunsAndAmmo = [
	// pistols
	["LIB_P38",					"lib_8rnd_9x19",			true],	0.9,
	["LIB_P08",					"fow_8rnd_9x19",			true],	0.7,
	["LIB_Colt_M1911",			"lib_7rnd_45acp",			true],	0.7,
	["LIB_M1896",				"lib_10rnd_9x19_m1896",		true],	0.5,
	["fow_w_p640p",				"fow_13rnd_9x19",			true],	0.5,
	["LIB_TT33",				"lib_8rnd_762x25",			true],	0.9,
	["LIB_M1895",				"lib_7rnd_762x38",			true],	0.6,
	["LIB_WaltherPPK",			"lib_7rnd_765x17_ppk",		true],	0.7,
	["LIB_Webley_mk6",			"lib_6rnd_455",				true],	0.6,
	["fow_w_welrod_mkii",		"fow_8rnd_765x17",			true],	0.3,
	// long
	["LIB_M1903A3_Springfield",	"fow_5rnd_762x63",			true],	0.1,
	["LIB_K98",					"lib_5rnd_792x57",			true],	0.1,
	["LIB_LeeEnfield_No4",		"lib_10rnd_770x56",			true],	0.1,
	["LIB_M9130",				"lib_5rnd_762x54",			true],	0.1,
	["fow_w_type99",			"fow_5rnd_77x58",			true],	0.1,
	["LIB_DELISLE",				"lib_7rnd_45acp_delisle",	true],	0.1
];

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];

this addWeapon _gun;

if(_isPistol) then {
	this addHandgunItem "acc_flashlight_pistol";
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, "acc_flashlight"];
	this addWeaponItem [_gun, _ammo];
};

for "_i" from 1 to 4 do { this addItemToUniform _ammo };

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

this addItemToUniform "FirstAidKit";
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass";
this linkItem "LIB_GER_ItemWatch";
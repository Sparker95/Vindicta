removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

private _uniforms = [
	"U_C_Poloshirt_blue",
	"U_C_Poloshirt_burgundy",
	"U_C_Poloshirt_redwhite",
	"U_C_Poloshirt_salmon",
	"U_C_Poloshirt_stripped",
	"U_C_Poloshirt_tricolour",
	"U_Marshal"
];

private _headgear = [
	"H_Bandanna_gry",
	"H_Bandanna_blu",
	"H_Bandanna_cbr",
	"H_Bandanna_khk",
	"H_Bandanna_sgg",
	"H_Bandanna_sand",
	"H_Bandanna_surfer",
	"H_Bandanna_surfer_blk",
	"H_Bandanna_surfer_grn",
	"H_Beret_blk",
	"H_Cap_grn_BI",
	"H_Cap_blk",
	"H_Cap_blu",
	"H_Cap_blk_CMMG",
	"H_Cap_grn",
	"H_Cap_blk_ION",
	"H_Cap_oli",
	"H_Cap_red",
	"H_Cap_surfer",
	"H_Cap_tan",
	"H_Cap_khaki_specops_UK",
	"H_Cap_usblack",
	"H_Hat_blue",
	"H_Hat_brown",
	"H_Hat_checker",
	"H_Hat_grey",
	"H_Hat_tan",
	"H_StrawHat",
	"H_StrawHat_dark"
];

private _gunsAndAmmo = [
	// pistols
	["hgun_Pistol_heavy_01_F", 	"11Rnd_45ACP_Mag", 		true],	1,
	["hgun_ACPC2_F", 			"9Rnd_45ACP_Mag", 		true],	0.9,
	["hgun_P07_F", 				"16Rnd_9x21_Mag", 		true],	0.8,
	["hgun_Rook40_F", 			"16Rnd_9x21_Mag", 		true],	0.7,
	// longs
	["hgun_PDW2000_F", 			"30Rnd_9x21_Mag", 		false],	0.2
];

private _ownedDLCs = getDLCs 1;
// Apex
if(395180 in _ownedDLCs) then {
	_uniforms = _uniforms + [
		"U_I_C_Soldier_Bandit_5_F",
		"U_I_C_Soldier_Bandit_3_F",
		"U_C_Man_casual_1_F",
		"U_C_Man_casual_2_F",
		"U_C_Man_casual_3_F",
		"U_C_man_sport_2_F",
		"U_C_Man_casual_6_F",
		"U_C_Man_casual_4_F",
		"U_C_Man_casual_5_F"
	];
	_gunsAndAmmo = _gunsAndAmmo + [
		// pistols
		["hgun_Pistol_01_F", 	"10Rnd_9x21_Mag", 		true],	0.7,
		["hgun_P07_khk_F", 		"16Rnd_9x21_Mag", 		true],	0.7,
		["arifle_AKM_F", 		"30rnd_762x39_mag_f", 	false],	0.01,
		["arifle_AKS_F", 		"30rnd_545x39_mag_f", 	false],	0.01
	];
};

// Contact
if(1021790 in _ownedDLCs) then {
	_uniforms = _uniforms + [
		"U_C_Uniform_Farmer_01_F",
		"U_C_E_LooterJacket_01_F",
		"U_I_L_Uniform_01_tshirt_black_F",
		"U_I_L_Uniform_01_tshirt_skull_F",
		"U_I_L_Uniform_01_tshirt_sport_F",
		"U_C_Uniform_Scientist_01_formal_F",
		"U_C_Uniform_Scientist_01_F",
		"U_C_Uniform_Scientist_02_formal_F",
		"U_O_R_Gorka_01_black_F"
	];
	_gunsAndAmmo = _gunsAndAmmo + [
		// longs
		["sgun_HunterShotgun_01_F", 			"2Rnd_12Gauge_Pellets",		false],	0.3,
		["sgun_HunterShotgun_01_sawedoff_F", 	"2Rnd_12Gauge_Pellets", 	false], 0.3,
		["srifle_DMR_06_hunter_F", 				"10Rnd_Mk14_762x51_Mag", 	false], 0.2
	];
};

// Laws of War
if(1021790 in _ownedDLCs) then {
	_uniforms = _uniforms + [
		"U_C_Mechanic_01_F"
	];
};

if(1021790 in _ownedDLCs) then {
	_headgear = _headgear + [
		"H_HeadBandage_clean_F",
		"H_HeadBandage_stained_F",
		"H_HeadBandage_bloody_F",
		"H_Hat_Safari_olive_F",
		"H_Hat_Safari_sand_F",
		"H_WirelessEarpiece_F"
	];
};

if(1021790 in _ownedDLCs) then {
	_vest = _vest + [
		"V_Pocketed_black_F",
		"V_Pocketed_coyote_F",
		"V_Pocketed_olive_F"
	];
};

if(1021790 in _ownedDLCs) then {
	_backpack = _backpack + [
		"B_Messenger_Black_F",
    	"B_Messenger_Gray_F",
    	"B_Messenger_Coyote_F",
    	"B_Messenger_Olive_F",
		"B_FieldPack_blk",
    	"B_FieldPack_cbr",
    	"B_FieldPack_oli",
    	"B_AssaultPack_blk",
    	"B_AssaultPack_cbr",
    	"B_Carryall_cbr",
		"ace_gunbag",
    	"ace_gunbag_Tan",
		"B_LegStrapBag_black_F",
    	"B_LegStrapBag_coyote_F",
    	"B_LegStrapBag_olive_F"
	];
};

this forceAddUniform selectRandom _uniforms;

if (random 5 < 1) then { this addHeadgear selectRandom _headgear;
};

if (random 10 < 1) then { this addVest selectRandom _vest;
};

if (random 2 < 1) then { this addBackpack selectRandom _backpack;
};

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];

this addWeapon _gun;

if(_isPistol) then {
	this addHandgunItem "acc_flashlight_pistol";
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, "acc_flashlight"];
	this addWeaponItem [_gun, _ammo];
};

if(random 5 < 1) then {
	this addGoggles selectRandomWeighted [
		"G_Spectacles", 		1,
		"G_Sport_Red", 			1,
		"G_Squares_Tinted", 	1,
		"G_Squares", 			1,
		"G_Spectacles_Tinted", 	1,
		"G_Shades_Black", 		1,
		"G_Shades_Blue", 		1,
		"G_Aviator", 			0.01
	];
};

//====Items====
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

for "_i" from 1 to 3 do { this addItemToUniform _ammo };

//====ACE Items====
for "_i" from 1 to 5 do {this addItemToUniform "ACE_fieldDressing";};
for "_i" from 1 to 2 do {this addItemToUniform "ACE_elasticBandage";};
for "_i" from 1 to 2 do {this addItemToUniform "ACE_packingBandage";};
this addItemToUniform "ACE_quikclot";
this addItemToUniform "ACE_tourniquet";
this addItemToUniform "ACE_Flashlight_Maglite_ML300L";

//====Identity====
[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;
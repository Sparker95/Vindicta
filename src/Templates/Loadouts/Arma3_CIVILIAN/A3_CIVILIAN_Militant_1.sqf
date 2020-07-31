removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

private _uniforms = [
	"U_C_E_LooterJacket_01_F",
	"U_C_Man_casual_1_F",
	"U_C_Man_casual_2_F",
	"U_C_Man_casual_3_F",
	"U_C_Man_casual_4_F",
	"U_C_Man_casual_5_F",
	"U_C_Man_casual_6_F",
	"U_C_man_sport_2_F",
	"U_C_Mechanic_01_F",
	"U_C_Poloshirt_burgundy",
	"U_C_Poloshirt_redwhite",
	"U_C_Poloshirt_salmon",
	"U_C_Poloshirt_stripped",
	"U_C_Poloshirt_tricolour",
	"U_C_Uniform_Farmer_01_F",
	"U_I_C_Soldier_Bandit_3_F",
	"U_I_C_Soldier_Bandit_5_F",
	"U_I_L_Uniform_01_tshirt_black_F",
	"U_I_L_Uniform_01_tshirt_skull_F",
	"U_I_L_Uniform_01_tshirt_sport_F",
	"U_O_R_Gorka_01_black_F",
    "U_C_Commoner_shorts",
    "U_C_HunterBody_grn",
    "U_C_IDAP_Man_TeeShorts_F",
    "U_C_Man_casual_1_F",
    "U_C_Man_casual_2_F",
    "U_C_Man_casual_3_F",
    "U_C_Man_casual_4_F",
    "U_C_Man_casual_5_F",
    "U_C_Man_casual_6_F",
    "U_C_man_sport_1_F",
    "U_C_man_sport_2_F",
    "U_C_man_sport_3_F",
    "U_C_Mechanic_01_F",
    "U_C_Poloshirt_blue",
    "U_C_Poloshirt_burgundy",
    "U_C_Poloshirt_redwhite",
    "U_C_Poloshirt_salmon",
    "U_C_Poloshirt_stripped",
    "U_C_Poloshirt_tricolour",
    "U_C_Poor_1",
    "U_C_Poor_2",
    "U_C_TeeSurfer_shorts_1",
    "U_C_TeeSurfer_shorts_2",
    "U_C_WorkerCoveralls"
];

this forceAddUniform selectRandom _uniforms;

private _vest = [
	"V_Pocketed_black_F",
	"V_Pocketed_coyote_F",
	"V_Pocketed_olive_F"
];

if (random 10 < 1) then { this addVest selectRandom _vest;
};

private _headgear = [
	"H_Bandanna_blu",
    "H_Bandanna_camo",
    "H_Bandanna_cbr",
    "H_Bandanna_gry",
    "H_Bandanna_khk",
    "H_Bandanna_khk_hs",
    "H_Bandanna_mcamo",
    "H_Bandanna_sand",
    "H_Bandanna_sgg",
    "H_Bandanna_surfer",
    "H_Bandanna_surfer_blk",
    "H_Bandanna_surfer_grn",
    "H_Watchcap_blk",
    "H_Watchcap_cbr",
    "H_Watchcap_camo",
    "H_Watchcap_khk",
    "H_Cap_blk",
    "H_Cap_blk_CMMG",
    "H_Cap_blk_ION",
    "H_Cap_blk_Syndikat_F",
    "H_Cap_blu",
    "H_Cap_grn",
    "H_Cap_grn_BI",
    "H_Cap_grn_Syndikat_F",
    "H_Cap_khaki_specops_UK",
    "H_Cap_oli",
    "H_Cap_oli_Syndikat_F",
    "H_Cap_Orange_IDAP_F",
    "H_Cap_press",
    "H_Cap_red",
    "H_Cap_surfer",
    "H_Cap_tan",
    "H_Cap_tan_Syndikat_F",
    "H_Cap_usblack",
	"H_HeadBandage_bloody_F",
    "H_HeadBandage_clean_F",
    "H_HeadBandage_stained_F",
	"H_StrawHat",
    "H_StrawHat_dark",
    "H_Hat_Safari_olive_F",
    "H_Hat_Safari_sand_F"
];

if (random 5 < 1) then { this addHeadgear selectRandom _headgear;
};

private _gunsAndAmmo = [
	// pistols
	["hgun_Pistol_heavy_01_F", 				"11Rnd_45ACP_Mag", 			true],	1,
	["hgun_ACPC2_F", 						"9Rnd_45ACP_Mag", 			true],	1,
	["hgun_P07_F", 							"16Rnd_9x21_Mag", 			true],	1,
	["hgun_Rook40_F", 						"16Rnd_9x21_Mag", 			true],	1,
	["hgun_Pistol_01_F", 					"10Rnd_9x21_Mag", 			true],	1,
	["hgun_P07_khk_F", 						"16Rnd_9x21_Mag", 			true],	1,
	// longs
	["hgun_PDW2000_F", 						"30Rnd_9x21_Mag", 			false],	0.2,
	["sgun_HunterShotgun_01_F", 			"2Rnd_12Gauge_Pellets",		false],	0.1,
	["sgun_HunterShotgun_01_sawedoff_F", 	"2Rnd_12Gauge_Pellets", 	false],	0.1,
	["srifle_DMR_06_hunter_F", 				"10Rnd_Mk14_762x51_Mag", 	false],	0.1,
	["arifle_AKM_F", 						"30rnd_762x39_mag_f", 		false],	0.05,
	["arifle_AKS_F", 						"30rnd_545x39_mag_f", 		false],	0.05
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



if(random 5 < 1) then {
	this addGoggles selectRandomWeighted [
		"G_Balaclava_blk",			1,
		"G_Balaclava_oli",			1,
		"G_GEHeadBandage_Stained",	1,
		"G_Bandanna_aviator",		1,
		"G_Bandanna_beast",			1,
		"G_Bandanna_blk",			1,
		"G_Bandanna_khk",			1,
		"G_Bandanna_oli",			1,
		"G_Bandanna_shades",		1,
		"G_Bandanna_sport",			1,
		"G_Bandanna_tan",			1,
		"G_Spectacles", 			1,
		"G_Sport_Red", 				1,
		"G_Squares_Tinted", 		1,
		"G_Squares", 				1,
		"G_Spectacles_Tinted", 		1,
		"G_Shades_Black", 			1,
		"G_Shades_Blue", 			1
	];
};

//====Items====
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

for "_i" from 1 to 3 do { this addItemToUniform _ammo };

//====ACE Items====
for "_i" from 1 to 4 do {this addItemToUniform "ACE_fieldDressing";};
this addItemToUniform "ACE_elasticBandage";
for "_i" from 1 to 2 do {this addItemToUniform "ACE_packingBandage";};
this addItemToUniform "ACE_quikclot";
this addItemToUniform "ACE_tourniquet";

//====Identity====
private _voice = [
	"male01gre",
    "male02gre",
    "male03gre",
	"male04gre",
	"male05gre",
	"male06gre",
	"male01engfre",
	"male02engfre",
	"male01eng",
	"male02eng",
	"male03eng",
	"male04eng",
	"male05eng",
	"male06eng",
	"male07eng",
	"male08eng",
	"male09eng",
	"male10eng",
	"male11eng",
	"male12eng",
	"male01engb",
	"male02engb",
	"male03engb",
	"male04engb",
	"male05engb"
];

[this, selectRandom gVanillaFaces,selectRandom _voice] call BIS_fnc_setIdentity;
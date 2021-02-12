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
	["rhsusf_weap_m9", "rhsusf_mag_15Rnd_9x19_JHP", true],	1,
	["rhsusf_weap_m1911a1", "rhsusf_mag_7x45acp_MHP", true],	0.9,
	["rhsusf_weap_glock17g4", "rhsusf_mag_17Rnd_9x19_JHP", true],	0.8,
	["rhs_weap_makarov_pm", "rhs_mag_9x18_8_57N181S", true],	0.7,
	["rhs_weap_pya", "rhs_mag_9x19_17", true],	0.5,
	["rhs_weap_tt33", "rhs_mag_762x25_8", true],	0.4,
	["rhs_weap_6p53", "rhs_18rnd_9x21mm_7N28", true],	0.2
];

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
	this addHandgunItem _ammo;
} else {
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
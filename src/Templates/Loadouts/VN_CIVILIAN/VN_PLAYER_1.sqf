removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

private _uniforms = [
	"vn_o_uniform_vc_01_01",
	"vn_o_uniform_vc_01_02",
	"vn_o_uniform_vc_01_04",
	"vn_o_uniform_vc_01_07",
	"vn_o_uniform_vc_01_06",
	"vn_o_uniform_vc_01_03",
	"vn_o_uniform_vc_01_05",
	"vn_o_uniform_vc_mf_01_07",
	"vn_o_uniform_vc_mf_10_07",
	"vn_o_uniform_vc_reg_11_08",
	"vn_o_uniform_vc_reg_11_09",
	"vn_o_uniform_vc_reg_11_10",
	"vn_o_uniform_vc_mf_11_07",
	"vn_o_uniform_vc_reg_12_08",
	"vn_o_uniform_vc_reg_12_09",
	"vn_o_uniform_vc_reg_12_10",
	"vn_o_uniform_vc_mf_12_07",
	"vn_o_uniform_vc_02_01",
	"vn_o_uniform_vc_02_02",
	"vn_o_uniform_vc_02_04",
	"vn_o_uniform_vc_02_07",
	"vn_o_uniform_vc_02_06",
	"vn_o_uniform_vc_02_03",
	"vn_o_uniform_vc_02_05",
	"vn_o_uniform_vc_mf_02_07",
    "vn_o_uniform_vc_03_01",
    "vn_o_uniform_vc_03_02",
    "vn_o_uniform_vc_03_04",
    "vn_o_uniform_vc_03_07",
    "vn_o_uniform_vc_03_06",
    "vn_o_uniform_vc_03_03",
    "vn_o_uniform_vc_03_05",
    "vn_o_uniform_vc_mf_03_07",
    "vn_o_uniform_vc_04_01",
    "vn_o_uniform_vc_04_02",
    "vn_o_uniform_vc_04_04",
    "vn_o_uniform_vc_04_07",
    "vn_o_uniform_vc_04_06",
    "vn_o_uniform_vc_04_03",
    "vn_o_uniform_vc_04_05",
    "vn_o_uniform_vc_mf_04_07",
    "vn_o_uniform_vc_05_01",
    "vn_o_uniform_vc_05_04",
    "vn_o_uniform_vc_05_03",
    "vn_o_uniform_vc_05_02",
    "vn_o_uniform_vc_mf_09_07"
];

this forceAddUniform selectRandom _uniforms;

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
    "H_Watchcap_blk",
    "H_Watchcap_cbr",
    "H_Watchcap_camo",
    "H_Watchcap_khk",
    "H_StrawHat",
    "H_StrawHat_dark",
    "H_Hat_Safari_olive_F",
    "H_Hat_Safari_sand_F",
    "vn_c_headband_04",
    "vn_b_headband_03",
    "vn_c_headband_03",
    "vn_c_headband_02",
    "vn_b_headband_01",
    "vn_c_headband_01",
    "vn_c_conehat_01",
    "vn_c_conehat_02",
    "vn_b_bandana_03",
    "vn_b_bandana_01",
    "vn_o_boonie_vc_01_01"
];

if (random 5 < 1) then { this addHeadgear selectRandom _headgear;
};

private _gunsAndAmmo = [
	// pistols
	["vn_izh54_p", 						"vn_izh54_mag", 		true],	1,
	["vn_m712", 						"vn_m712_mag", 			true],	1,
	["vn_pm", 							"vn_pm_mag", 			true],	1,
	["vn_tt33", 						"vn_tt33_mag", 			true],	1,
	// longs
	["vn_izh54_shorty", 				"vn_izh54_mag", 		false],	0.3,
	["vn_izh54", 						"vn_izh54_mag",			false],	0.4,
	["vn_k50m", 						"vn_ppsh41_35_mag", 	false],	0.1,
	["vn_pps43", 						"vn_pps_mag",        	false],	0.2,
	["vn_pps52", 						"vn_pps_mag",        	false],	0.2,
	["vn_ppsh41", 						"vn_ppsh41_35_mag", 	false],	0.3,
	["vn_sten", 						"vn_sten_mag", 			false],	0.3,
	["vn_mp40", 						"vn_mp40_mag", 			false],	0.3
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
	/*"vn_o_bandana_b",   0,
    "vn_o_bandana_g",   0,*/
    "vn_o_scarf_01_04",   1,
    "vn_b_scarf_01_03",   1,
    "vn_o_scarf_01_03",   1,
    "vn_o_scarf_01_02",   1,
    "vn_b_scarf_01_01",   1,
    "vn_o_scarf_01_01",   1
	];
};
//====Items====
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

for "_i" from 1 to 3 do { this addItemToUniform _ammo };

//====ACE Items====
this addItemToUniform "FirstAidKit";
/*for "_i" from 1 to 2 do {this addItemToUniform "ACE_fieldDressing";};
this addItemToUniform "ACE_elasticBandage";
this addItemToUniform "ACE_packingBandage";
this addItemToUniform "ACE_quikclot";*/

//====Identity====
[this, ""] call BIS_fnc_setIdentity;
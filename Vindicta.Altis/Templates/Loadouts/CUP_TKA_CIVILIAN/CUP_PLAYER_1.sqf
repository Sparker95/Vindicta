removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

// ==== Headgear ====
private _lungeHeadGear = selectRandom[
	"CUP_H_TKI_Lungee_Open_01",
	"CUP_H_TKI_Lungee_Open_02",
	"CUP_H_TKI_Lungee_Open_03",
	"CUP_H_TKI_Lungee_Open_04",
	"CUP_H_TKI_Lungee_Open_05",
	"CUP_H_TKI_Lungee_Open_06"
];
private _lungeHeadGearFront = selectRandom[
	"CUP_H_TKI_Lungee_Open_01",
	"CUP_H_TKI_Lungee_01",
	"CUP_H_TKI_Lungee_02",
	"CUP_H_TKI_Lungee_03",
	"CUP_H_TKI_Lungee_04",
	"CUP_H_TKI_Lungee_05",
	"CUP_H_TKI_Lungee_06"
];
private _pakolHeadGear = selectRandom[
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
	"CUP_H_TKI_Pakol_1_01"
];
private _capHeadGearFront = selectRandom[
	"CUP_H_TKI_SkullCap_06",
	"CUP_H_TKI_SkullCap_05",
	"CUP_H_TKI_SkullCap_04",
	"CUP_H_TKI_SkullCap_03",
	"CUP_H_TKI_SkullCap_02",
	"CUP_H_TKI_SkullCap_01"
];

this addHeadgear selectRandom [_lungeHeadGear, _lungeHeadGearFront,_pakolHeadGear,_capHeadGearFront];

// ==== Uniform =====
private _jeansUniform = selectRandom[
	"CUP_O_TKI_Khet_Jeans_01",
	"CUP_O_TKI_Khet_Jeans_02",
	"CUP_O_TKI_Khet_Jeans_03",
	"CUP_O_TKI_Khet_Jeans_04"
];
private _partugUniform = selectRandom[
	"CUP_O_TKI_Khet_Partug_01",
	"CUP_O_TKI_Khet_Partug_02",
	"CUP_O_TKI_Khet_Partug_03",
	"CUP_O_TKI_Khet_Partug_04",
	"CUP_O_TKI_Khet_Partug_05",
	"CUP_O_TKI_Khet_Partug_06",
	"CUP_O_TKI_Khet_Partug_07",
	"CUP_O_TKI_Khet_Partug_08"
];

this forceAddUniform selectRandom [_jeansUniform, _partugUniform];
this addItemToUniform "ACE_Flashlight_Maglite_ML300L";

// ==== Vest ====
private _waistVest = selectRandom[
	"CUP_V_OI_TKI_Jacket6_06",
	"CUP_V_OI_TKI_Jacket6_05",
	"CUP_V_OI_TKI_Jacket6_04"
];
private _wlightVest = selectRandom[
	"CUP_V_OI_TKI_Jacket5_06",
	"CUP_V_OI_TKI_Jacket5_05",
	"CUP_V_OI_TKI_Jacket5_04"
];
private _jacketVest = selectRandom[
	"CUP_V_OI_TKI_Jacket1_05",
	"CUP_V_OI_TKI_Jacket1_06",
	"CUP_V_OI_TKI_Jacket1_04"
];
this addVest selectRandom [_waistVest, _wlightVest, _jacketVest];

/* ==== Backpack ====
if (random 10 < 2) then {
	private _backpacks = [
		"CUP_B_IDF_Backpack",
		"CUP_B_SLA_Medicbag"
	];
	this addBackpack selectRandom _backpacks;
};
*/

//	==== Weapons ====
private _gunsAndAmmo = [
	// pistols
	["CUP_hgun_PMM",				"CUP_12Rnd_9x18_PMM_M", 		true],	0.9,
	["CUP_hgun_SA61", 				"CUP_10Rnd_B_765x17_Ball_M", 	true],	0.6,	
	// rifle
	["CUP_SKS_rail",				"CUP_10Rnd_762x39_SKS_M", 		false], 0.2,
	["CUP_arifle_AKS", 				"CUP_30Rnd_762x39_AK47_M",		false], 0.05
];

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];
this addWeapon _gun;
if(_isPistol) then {
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, _ammo];
};
for "_i" from 1 to 3 do {this addItemToUniform _ammo;};

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "ItemWatch"; 			// Watch
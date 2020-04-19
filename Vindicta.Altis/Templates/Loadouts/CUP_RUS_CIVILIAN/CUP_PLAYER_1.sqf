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
if (random 10 < 4) then {
	private _headgear = [
		"CUP_H_FR_BandanaGreen",
		"CUP_H_FR_BandanaWdl",
		"CUP_H_PMC_Beanie_Black",
		"CUP_H_SLA_BeanieGreen",
		"CUP_H_PMC_Beanie_Khaki",
		"CUP_H_C_Beanie_02",
		"CUP_H_C_Beanie_04"
	];

	this addHeadgear selectRandom _headgear;
};

//	==== Uniform ====
private _uniforms = [
	"CUP_U_C_Worker_01",
	"CUP_U_C_Woodlander_01",
	"CUP_U_C_Villager_01",
	"CUP_U_C_Functionary_jacket_01",
	"CUP_U_C_Suit_01",
	"CUP_U_C_Rocker_01",
	"CUP_U_C_Priest_01",
	"CUP_U_C_Citizen_01",
	"CUP_U_C_Mechanic_01",
	"CUP_U_C_racketeer_01",
	"CUP_U_C_Profiteer_01",
	"CUP_U_O_CHDKZ_Lopotev"
];

this forceAddUniform selectRandom _uniforms;
this addItemToUniform "ACE_Flashlight_Maglite_ML300L";

/* ==== Backpack ====
if (random 10 < 2) then {
	private _backpacks = [
		"CUP_B_HikingPack_Civ",
		"CUP_B_CivPack_WDL",
		"CUP_B_IDF_Backpack"
	];
	this addBackpack selectRandom _backpacks;
};
*/

//	==== Weapons ====
private _gunsAndAmmo = [
	// pistols
	["CUP_hgun_Makarov",			"CUP_8Rnd_9x18_Makarov_M", 	true],	0.9,
	["CUP_hgun_PB6P9", 				"CUP_8Rnd_9x18_Makarov_M", 	true],	0.8,	
	// rifle
	["CUP_srifle_Remington700",		"CUP_6Rnd_762x51_R700", 	false], 0.1,
	["CUP_srifle_CZ550", 			"CUP_5x_22_LR_17_HMR_M",	false], 0.05
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
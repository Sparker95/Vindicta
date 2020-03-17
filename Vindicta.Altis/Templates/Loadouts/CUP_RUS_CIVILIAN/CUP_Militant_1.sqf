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

// ==== Vest ====
if (random 10 < 4) then {
	this addVest "CUP_V_I_Guerilla_Jacket";
};


//	==== Weapons ====
private _gunsAndAmmo = [
	// pistols
	["CUP_hgun_Makarov",			"CUP_8Rnd_9x18_Makarov_M", 	true],	0.9,
	["CUP_hgun_PB6P9", 				"CUP_8Rnd_9x18_Makarov_M", 	true],	0.9,	
	// rifle
	["CUP_srifle_Remington700",		"CUP_6Rnd_762x51_R700", 	false], 0.1,
	["CUP_srifle_CZ550_rail", 			"CUP_5x_22_LR_17_HMR_M",	false], 0.05
];

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];
this addWeapon _gun;
if(_isPistol) then {
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, _ammo];
};
for "_i" from 1 to 3 do {this addItemToUniform _ammo;};
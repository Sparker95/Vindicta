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
private _HeadGear = [
	"UK3CB_TKC_H_Turban_01_1",
	"UK3CB_TKC_H_Turban_02_1",
	"UK3CB_TKC_H_Turban_06_1",
	"UK3CB_TKC_H_Turban_03_1",
	"UK3CB_TKC_H_Turban_04_1",
	"UK3CB_TKC_H_Turban_05_1"
];
this addHeadgear selectRandom _HeadGear;

// ==== Uniform =====
private _Uniform = [
	"UK3CB_TKC_C_U_01",
	"UK3CB_TKC_C_U_01_B",
	"UK3CB_TKC_C_U_01_C",
	"UK3CB_TKC_C_U_01_D",
	"UK3CB_TKC_C_U_01_E",
	"UK3CB_TKC_C_U_02",
	"UK3CB_TKC_C_U_02_B",
	"UK3CB_TKC_C_U_02_C",
	"UK3CB_TKC_C_U_02_D",
	"UK3CB_TKC_C_U_02_E",
	"UK3CB_TKC_C_U_03",
	"UK3CB_TKC_C_U_03_B",
	"UK3CB_TKC_C_U_03_C",
	"UK3CB_TKC_C_U_03_D",
	"UK3CB_TKC_C_U_03_E",
	"UK3CB_TKC_C_U_06",
	"UK3CB_TKC_C_U_06_B",
	"UK3CB_TKC_C_U_06_C",
	"UK3CB_TKC_C_U_06_D",
	"UK3CB_TKC_C_U_06_E"
];

//==== Facegear ====
if(random 10 < 3) then { 
	this addGoggles (selectRandom [
	"UK3CB_G_Face_Wrap_01",
	"G_Aviator"	// Yes! Yes!
	]);
};

this forceAddUniform selectRandom _Uniform;

//	==== Weapons ====
private _gunsAndAmmo = [
	["rhs_weap_makarov_pm",				"rhs_mag_9x18_8_57N181S", 		true],	0.9,
	["rhs_weap_tt33", 				"rhs_mag_762x25_8", 	true],	0.6,	
	// rifle
	["rhs_weap_ak74",				"rhs_30Rnd_545x39_7N6M_AK", 		false], 0.1,
	["UK3CB_M14",				"UK3CB_20Rnd_762x51_B_M14", 		false], 0.3,
	["rhs_acc_dtkakm", 				"rhs_30Rnd_762x39mm_bakelite",		false], 0.1
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
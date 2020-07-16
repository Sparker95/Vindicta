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
	"UK3CB_CHC_C_U_HIKER_01",
	"UK3CB_CHC_C_U_HIKER_02",
	"UK3CB_CHC_C_U_HIKER_03",
	"UK3CB_CHC_C_U_HIKER_04",
	"UK3CB_CHC_C_U_ACTIVIST_01",
	"UK3CB_CHC_C_U_ACTIVIST_02",
	"UK3CB_CHC_C_U_ACTIVIST_03",
	"UK3CB_CHC_C_U_ACTIVIST_04",
	"UK3CB_CHC_C_U_CIT_01",
	"UK3CB_CHC_C_U_CIT_02",
	"UK3CB_CHC_C_U_CIT_03",
	"UK3CB_CHC_C_U_CIT_04",
	"UK3CB_CHC_C_U_COACH_01",
	"UK3CB_CHC_C_U_COACH_02",
	"UK3CB_CHC_C_U_COACH_03",
	"UK3CB_CHC_C_U_COACH_04",
	"UK3CB_CHC_C_U_COACH_05",
	"UK3CB_CHC_C_U_WORK_01",
	"UK3CB_CHC_C_U_WORK_02",
	"UK3CB_CHC_C_U_WORK_03",
	"UK3CB_CHC_C_U_WORK_04",
	"UK3CB_CHC_C_U_PROF_01",
	"UK3CB_CHC_C_U_PROF_02",
	"UK3CB_CHC_C_U_PROF_03",
	"UK3CB_CHC_C_U_PROF_04",
	"UK3CB_CHC_C_U_VILL_01",
	"UK3CB_CHC_C_U_VILL_02",
	"UK3CB_CHC_C_U_VILL_03",
	"UK3CB_CHC_C_U_VILL_04",
	"UK3CB_CHC_C_U_WOOD_01",
	"UK3CB_CHC_C_U_WOOD_02",
	"UK3CB_CHC_C_U_WOOD_03",
	"UK3CB_CHC_C_U_WOOD_04"
];

this forceAddUniform selectRandom _uniforms;

if (random 10 < 3) then {
	private _headgear = [
	"UK3CB_H_Beanie_01",
	"H_Cap_blk",
	"H_Cap_grn"
	];

	this addHeadgear selectRandom _headgear;
};


if(random 5 < 4) then {
	this addGoggles selectRandomWeighted [
		"G_Balaclava_blk", 		1,
		"G_Balaclava_oli", 		1,
		"G_Bandanna_aviator", 	0.1,
		"G_Bandanna_blk", 		1,
		"G_Bandanna_oli", 		1,
		"G_Bandanna_shades", 	1,
		"G_Bandanna_sport", 	1
	];
};

//	==== Weapons ====
private _gunsAndAmmo = [
	// pistols
	["rhs_weap_6p53",			"rhs_18rnd_9x21mm_7N28", 	true],	0.9,
	["rhs_weap_makarov_pm", 				"rhs_mag_9x18_8_57N181S", 	true],	0.9,	
	["rhs_weap_type94_new", 				"rhs_mag_6x8mm_mhp", 	true],	0.9,	
	// rifle
	["rhs_weap_akm", 			"rhs_30Rnd_762x39mm_bakelite",	false], 0.05
];

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];
this addWeapon _gun;
if(_isPistol) then {
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, _ammo];
};
for "_i" from 1 to 3 do {this addItemToUniform _ammo;};
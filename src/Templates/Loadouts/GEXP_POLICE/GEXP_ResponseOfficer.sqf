removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
private _headgear = [
	"STF_Helmet_Peltor_SpecOps",
	"STF_Helmet_EarGuard_SpecOps",
	"STF_Helmet_Chops_SpecOps"
];
this addHeadgear selectRandom _headgear;

//	==== Face Gear ====
if(random 10 > 4) then {
	this addGoggles "G_Bandanna_blk";
};

//	==== Uniform ====
private _uniforms = ["Gendarmerie_long_uniform","Gendarmerie_uniform_Rolled"];
this forceAddUniform selectRandom _uniforms;
this addItemToUniform "FirstAidKit";

//	==== Vest ====
this addVest "Modular_lvl1";

//	==== Weapons ====
private _gunAndAmmo = [
	["SMG_03_black", "50Rnd_570x28_SMG_03"], 				0.5,
	["prpl_benelli_rail", "prpl_6Rnd_12Gauge_Pellets"],		0.2,
	["ExpansionMod_SMG_03C_black", "50Rnd_570x28_SMG_03"], 	0.3,
	["SMG_02_F", "30Rnd_9x21_Mag_SMG_02"], 					0.4
];

(selectRandomWeighted _gunAndAmmo) params ["_gun", "_ammo"];
this addWeapon _gun;
this addPrimaryWeaponItem _ammo;
this addPrimaryWeaponItem "optic_aco_smg";
for "_i" from 1 to 2 do {this addItemToVest _ammo;};

this addWeapon "hgun_Rook40_F";
this addHandgunItem "16Rnd_9x21_Mag";
for "_i" from 1 to 2 do {this addItemToVest "16Rnd_9x21_Mag";};

//	==== Misc Items ====
this linkItem "ItemMap"; 		// Map
this linkItem "ItemWatch"; 		// Watch
this linkItem "ItemCompass"; 	// Compass
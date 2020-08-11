removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_hat_boonie_oli";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_parka_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_beret_bdx_specop";

//	==== Vest ====
this AddVest "gm_ge_army_vest_80_rifleman";
for "_i" from 1 to 3 do {this addItemToVest "gm_smokeshell_wht_dm25";};

//	==== Backpack ====

//	==== Weapons ====
private _guns = [
	["gm_g3a4_oli", "gm_feroz24_blk"], 0.5,
	["gm_g3a4_blk", "gm_feroz24_blk"], 0.5,
	["gm_g3a4_grn", "gm_feroz24_blk"], 0.5,
	["gm_g3a4_des", "gm_feroz24_des"], 0.1
];

(selectRandomWeighted _guns) params ["_gun", "_ammo"];
this AddWeapon _gun;
this addPrimaryWeaponItem _ammo;
this addPrimaryWeaponItem "muzzle_snds_B";
for "_i" from 1 to 5 do {this addItemToVest _ammo;};

this addWeapon "gm_p1_blk";
this addHandgunItem "gm_8Rnd_9x19mm_B_DM51_p1_blk";
for "_i" from 1 to 3 do {this addItemToVest "gm_8Rnd_9x19mm_B_DM51_p1_blk";};

this AddWeapon "gm_ferod16_oli";

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
this linkitem "ItemRadio"; 			// Radio
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_dk_headgear_m96_oli";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_parka_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_beret_bdx_specop";

//	==== Vest ====
this AddVest "gm_ge_army_vest_80_rifleman";
this addItemToVest "gm_smokeshell_wht_dm25";
for "_i" from 1 to 2 do {this addItemToVest "gm_handgrenade_frag_dm51a1";};

//	==== Backpack ====

//	==== Weapons ====
private _guns = [
	["gm_g3a4_oli", "gm_20Rnd_762x51mm_B_DM41_g3_blk"], 	0.5,
	["gm_g3a4_blk", "gm_20Rnd_762x51mm_B_DM41_g3_blk"], 	0.5,
	["gm_g3a4_grn", "gm_20Rnd_762x51mm_B_DM41_g3_blk"], 	0.3,
	["gm_g3a4_des", "gm_20Rnd_762x51mm_B_DM41_g3_blk"], 	0.1,
	["gm_mp5sd2_blk", "gm_30rnd_9x19mm_b_dm51_mp5a3_blk"], 	0.3,
	["gm_mp5sd3_blk", "gm_30rnd_9x19mm_b_dm51_mp5a3_blk"], 	0.3,
	["gm_m16a1_blk", "gm_30Rnd_556x45mm_B_M855_stanag_gry"], 	0.08,
	["gm_m16a2_blk", "gm_30Rnd_556x45mm_B_M855_stanag_gry"], 	0.06
];

(selectRandomWeighted _guns) params ["_gun", "_ammo"];
this AddWeapon _gun;
this addPrimaryWeaponItem _ammo;
this addPrimaryWeaponItem "muzzle_snds_B";
this addPrimaryWeaponItem "muzzle_snds_M";
for "_i" from 1 to 5 do {this addItemToVest _ammo;};

this addWeapon "gm_p1_blk";
this addHandgunItem "gm_8Rnd_9x19mm_B_DM51_p1_blk";
for "_i" from 1 to 3 do {this addItemToVest "gm_8Rnd_9x19mm_B_DM51_p1_blk";};

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
this linkitem "ItemRadio"; 			// Radio
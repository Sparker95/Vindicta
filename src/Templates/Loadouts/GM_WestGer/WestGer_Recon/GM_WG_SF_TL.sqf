removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_beret_bdx_specop";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_parka_80_oli";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";

//	==== Vest ====
this AddVest "gm_ge_army_vest_80_leader";
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_yel_dm26";};		// Yellow Smoke
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_wht_dm25";};		// White Smoke	
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_red_dm23";};		// Red Smoke	
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_grn_dm21";};		// Green Smoke

//	==== Backpack ====

//	==== Weapons ====
private _guns = [
	["gm_mp5sd2_blk", "gm_30rnd_9x19mm_b_dm51_mp5a3_blk"], 	0.3,
	["gm_mp5sd3_blk", "gm_30rnd_9x19mm_b_dm51_mp5a3_blk"], 	0.3
];

(selectRandomWeighted _guns) params ["_gun", "_ammo"];
this AddWeapon _gun;
this addPrimaryWeaponItem _ammo;
this addPrimaryWeaponItem "gm_feroz24_blk";
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
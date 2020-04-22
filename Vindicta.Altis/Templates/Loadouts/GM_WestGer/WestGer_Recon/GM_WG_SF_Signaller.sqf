removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_m62_net";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_parka_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_beret_bdx_specop";

//	==== Vest ====
this AddVest "gm_ge_army_vest_80_leader";
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_wht_dm25";};
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_red_dm23";};
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_grn_dm21";};

//	==== Backpack ====

//	==== Weapons ====
private _guns = [
	["gm_c7a1_blk"], 	0.5,
	["gm_c7a1_oli"], 	0.5,
	["gm_m16a2_blk"], 	0.3
];

(selectRandomWeighted _guns) params ["_gun"];
this AddWeapon _gun;
this addPrimaryWeaponItem "gm_30Rnd_556x45mm_B_M855_stanag_gry";
for "_i" from 1 to 6 do {this addItemToVest "gm_30Rnd_556x45mm_B_M855_stanag_gry";};

this addWeapon "gm_p1_blk";
this addHandgunItem "gm_8Rnd_9x19mm_B_DM51_p1_blk";
for "_i" from 1 to 3 do {this addItemToVest "gm_8Rnd_9x19mm_B_DM51_p1_blk";};

this AddWeapon "gm_ferod16_oli";

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
this linkitem "ItemRadio"; 			// Radio
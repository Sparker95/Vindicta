removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_beret_grn_infantry";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_parka_80_oli";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";

//	==== Vest ====
this addVest "gm_ge_army_vest_80_officer";

//	==== Weapons ====
private _guns = [
	["gm_g3a4_oli"], 0.5,
	["gm_g3a4_blk"], 0.5,
	["gm_g3a4_grn"], 0.5,
	["gm_g3a4_des"], 0.1
];

(selectRandomWeighted _guns) params ["_gun"];
this addWeapon _gun;
this addPrimaryWeaponItem "gm_20Rnd_762x51mm_B_T_DM21_g3_blk";
for "_i" from 1 to 4 do {this addItemToVest "gm_20Rnd_762x51mm_B_T_DM21_g3_blk";};

this AddWeapon "gm_ferod16_oli";

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
this linkitem "ItemRadio"; 			// Radio
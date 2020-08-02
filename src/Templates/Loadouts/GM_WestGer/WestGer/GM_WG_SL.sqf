removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_m62";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_80_oli";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_hat_80_oli";

//	==== Vest ====
this addVest "gm_ge_army_vest_80_leader";
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_yel_dm26";};		// Yellow Smoke
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_wht_dm25";};		// White Smoke	
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_red_dm23";};		// Red Smoke	
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_grn_dm21";};		// Green Smoke

//	==== Weapons ====
private _gunAndOptic = [
	["gm_g3a3_oli"], 0.5,
	["gm_g3a3_blk"], 0.5,
	["gm_g3a3_grn"], 0.5,
	["gm_g3a3_des"], 0.1
];

(selectRandomWeighted _gunAndOptic) params ["_gun", "_optic"];
this addWeapon _gun;
this addPrimaryWeaponItem _optic;
this addPrimaryWeaponItem "gm_20Rnd_762x51mm_B_T_DM21_g3_blk";
for "_i" from 1 to 4 do {this addItemToVest "gm_20Rnd_762x51mm_B_T_DM21_g3_blk";};

this addWeapon "gm_p1_blk";
this addHandgunItem "gm_8Rnd_9x19mm_B_DM51_p1_blk";
for "_i" from 1 to 3 do {this addItemToVest "gm_8Rnd_9x19mm_B_DM51_p1_blk";};

this AddWeapon "gm_ferod16_oli";

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
this linkitem "ItemRadio"; 			// Radio
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
this forceAddUniform "gm_ge_army_uniform_soldier_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_hat_80_oli";

//	==== Vest ====
this addVest "gm_ge_army_vest_80_rifleman";
this addItemToVest "gm_smokeshell_wht_dm25";
for "_i" from 1 to 2 do {this addItemToVest "gm_handgrenade_frag_dm51a1";};

//	==== Backpack ====
this addBackpack "gm_ge_army_backpack_80_pzf44_oli";

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
for "_i" from 1 to 6 do {this addItemToVest "gm_20Rnd_762x51mm_B_T_DM21_g3_blk";};

this addWeapon "gm_pzf84_oli";
this addSecondaryWeaponItem "gm_feroz2x17_pzf84_blk";
this addSecondaryWeaponItem "gm_1Rnd_84x245mm_heat_t_DM32_carlgustaf";
for "_i" from 1 to 2 do {this addItemToVest "gm_1Rnd_44x537mm_heat_dm32_pzf44_2";};

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
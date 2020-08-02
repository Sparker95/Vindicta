removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_crewhat_80_blk";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_crew_80_oli";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_beret_grn_mechinf";

//	==== Vest ====
this addVest "gm_ge_army_vest_80_crew";
for "_i" from 1 to 3 do {this addItemToVest "gm_smokeshell_wht_dm25";};
for "_i" from 1 to 3 do {this addItemToVest "gm_smokeshell_red_dm25";};
for "_i" from 1 to 3 do {this addItemToVest "gm_smokeshell_grn_dm25";};

//	==== Backpack ====

//	==== Weapons ====
this addWeapon "gm_mp2a1_blk";
this addPrimaryWeaponItem "gm_32Rnd_9x19mm_B_DM51_mp2_blk";
for "_i" from 1 to 4 do {this addItemToVest "gm_32Rnd_9x19mm_B_DM51_mp2_blk";};

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
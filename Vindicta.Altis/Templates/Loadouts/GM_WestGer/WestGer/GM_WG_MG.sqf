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
this forceAddUniform "gm_ge_army_uniform_soldier_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_beret_grn_infantry";

//	==== Vest ====
this addVest "gm_ge_army_vest_80_machinegunner";
for "_i" from 1 to 3 do {this addItemToVest "gm_120Rnd_762x51mm_B_T_DM21A1_mg3_grn";};
for "_i" from 1 to 2 do {this addItemToVest "gm_8Rnd_9x18mm_B_pst_pm_blk";};

//	==== Backpack ====

//	==== Weapons ====
this addWeapon "gm_mg3_blk";
this addPrimaryWeaponItem "gm_120Rnd_762x51mm_B_T_DM21A1_mg3_grn";

this addWeapon "gm_pm_blk";
this addHandgunItem "gm_8Rnd_9x18mm_B_pst_pm_blk";

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "gm_watch_kosei_80";
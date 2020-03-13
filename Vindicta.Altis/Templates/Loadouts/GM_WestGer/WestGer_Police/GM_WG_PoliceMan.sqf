removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_pol_headgear_cap_80_wht";

//	==== Uniform ====
this forceAddUniform "gm_ge_pol_uniform_blouse_80_blk";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToUniform "gm_8Rnd_9x18mm_B_pst_pm_blk";};

//	==== Vest ====
this addVest "gm_ge_pol_vest_80_wht";
for "_i" from 1 to 4 do {this addItemToVest "gm_8Rnd_9x18mm_B_pst_pm_blk";};

//	==== Backpack ====

//	==== Weapons ====
this addWeapon "gm_pm_blk";
this addHandgunItem "gm_8Rnd_9x18mm_B_pst_pm_blk";

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "ItemWatch";
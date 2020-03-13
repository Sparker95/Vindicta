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
this AddVest "gm_ge_army_vest_80_leader";
for "_i" from 1 to 4 do {this addItemToVest "gm_20Rnd_762x51mm_AP_DM151_g3_blk";};
for "_i" from 1 to 2 do {this addItemToVest "gm_8Rnd_9x18mm_B_pst_pm_blk";};
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_wht_dm25";};
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_red_dm23";};
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_grn_dm21";};

//	==== Backpack ====

//	==== Weapons ====
this AddWeapon "gm_g3a3_oli";
this addPrimaryWeaponItem "gm_20Rnd_762x51mm_AP_DM151_g3_blk";

this addWeapon "gm_pm_blk";
this addHandgunItem "gm_8Rnd_9x18mm_B_pst_pm_blk";

this AddWeapon "gm_ferod16_oli";

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "gm_watch_kosei_80";
this linkitem "ItemRadio";
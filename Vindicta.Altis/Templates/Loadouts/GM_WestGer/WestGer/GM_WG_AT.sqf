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
this addVest "gm_ge_army_vest_80_rifleman";
this addItemToVest "gm_smokeshell_wht_dm25";
for "_i" from 1 to 6 do {this addItemToVest "gm_20Rnd_762x51mm_AP_DM151_g3_blk";};
for "_i" from 1 to 2 do {this addItemToVest "gm_8Rnd_9x18mm_B_pst_pm_blk";};
for "_i" from 1 to 2 do {this addItemToVest "gm_handgrenade_frag_dm51a1";};

//	==== Backpack ====
this addBackpack "gm_ge_army_backpack_80_pzf44_oli";
for "_i" from 1 to 2 do {this addItemToVest "gm_1Rnd_44x537mm_heat_dm32_pzf44_2";};

//	==== Weapons ====
this addWeapon "gm_g3a3_blk";
this addPrimaryWeaponItem "gm_20Rnd_762x51mm_AP_DM151_g3_blk";

this addWeapon "gm_pzf84_oli";
this addSecondaryWeaponItem "gm_feroz2x17_pzf84_blk";
this addSecondaryWeaponItem "gm_1Rnd_84x245mm_heat_t_DM32_carlgustaf";

this addWeapon "gm_pm_blk";
this addHandgunItem "gm_8Rnd_9x18mm_B_pst_pm_blk";

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "gm_watch_kosei_80";
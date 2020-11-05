
comment "Exported from Arsenal by Sparker";

comment "[!] UNIT MUST BE LOCAL [!]";
if (!local this) exitWith {};

comment "Remove existing items";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

comment "Add weapons";
this addWeapon "gm_pm63_blk";
this addPrimaryWeaponItem "gm_15Rnd_9x18mm_B_pst_pm63_blk";
this addWeapon "gm_pm_blk";
this addHandgunItem "gm_8Rnd_9x18mm_B_pst_pm_blk";

comment "Add containers";
this forceAddUniform "gm_gc_pol_uniform_dress_80_blu";
this addVest "gm_ge_pol_vest_80_wht";

comment "Add items to containers";
this addItemToUniform "gm_gc_army_gauzeBandage";
this addItemToUniform "gm_gc_army_medkit";
this addItemToUniform "gm_ge_army_burnBandage";
this addItemToUniform "gm_ge_army_gauzeBandage";
this addItemToUniform "gm_ge_army_gauzeCompress";
for "_i" from 1 to 4 do {this addItemToUniform "gm_8Rnd_9x18mm_B_pst_pm_blk";};
for "_i" from 1 to 6 do {this addItemToVest "gm_25Rnd_9x18mm_B_pst_pm63_blk";};
this addHeadgear "gm_gc_pol_headgear_cap_80_blu";

comment "Add items";
this linkItem "ItemMap";
this linkItem "gm_gc_compass_f73";
this linkItem "gm_watch_kosei_80";
this linkItem "ItemRadio";
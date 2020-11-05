
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
this addWeapon "gm_svd_wud";
this addPrimaryWeaponItem "gm_pso1_gry";
this addPrimaryWeaponItem "gm_10Rnd_762x54mmR_AP_7N1_svd_blk";

comment "Add containers";
this forceAddUniform "gm_gc_army_uniform_soldier_gloves_80_str";
this addVest "gm_gc_army_vest_80_rifleman_str";

comment "Add binoculars";
this addWeapon "gm_df7x40_blk";

comment "Add items to containers";
this addItemToUniform "gm_gc_army_gauzeBandage";
this addItemToUniform "gm_gc_army_medkit";
this addItemToUniform "gm_gc_army_facewear_schm41m";
this addItemToUniform "gm_gc_army_headgear_hat_80_grn";
for "_i" from 1 to 12 do {this addItemToVest "gm_10Rnd_762x54mmR_AP_7N1_svd_blk";};
this addHeadgear "gm_ge_headgear_hat_boonie_oli";

comment "Add items";
this linkItem "ItemMap";
this linkItem "gm_gc_compass_f73";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

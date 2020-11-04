
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
this addWeapon "gm_mpiak74n_brn";
this addPrimaryWeaponItem "gm_zfk4x25_blk";
this addPrimaryWeaponItem "gm_30Rnd_545x39mm_B_7N6_ak74_org";
this addWeapon "gm_lp1_blk";
this addHandgunItem "gm_1Rnd_265mm_flare_single_wht_gc";

comment "Add containers";
this forceAddUniform "gm_gc_army_uniform_soldier_80_str";
this addVest "gm_gc_army_vest_80_leader_str";

comment "Add binoculars";
this addWeapon "gm_df7x40_grn";

comment "Add items to containers";
this addItemToUniform "gm_gc_army_gauzeBandage";
this addItemToUniform "gm_gc_army_medkit";
this addItemToUniform "gm_gc_army_facewear_schm41m";
this addItemToUniform "gm_gc_army_headgear_hat_80_grn";
for "_i" from 1 to 8 do {this addItemToVest "gm_30Rnd_545x39mm_B_7N6_ak74_org";};
this addItemToVest "gm_1Rnd_265mm_flare_single_grn_gc";
this addItemToVest "gm_1Rnd_265mm_flare_single_red_gc";
this addItemToVest "gm_1Rnd_265mm_flare_multi_red_gc";
this addItemToVest "gm_1Rnd_265mm_smoke_single_yel_gc";
this addItemToVest "gm_1Rnd_265mm_smoke_single_blu_gc";
this addItemToVest "gm_1Rnd_265mm_smoke_single_blk_gc";
this addHeadgear "gm_gc_army_headgear_m56_net";

comment "Add items";
this linkItem "ItemMap";
this linkItem "gm_gc_compass_f73";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
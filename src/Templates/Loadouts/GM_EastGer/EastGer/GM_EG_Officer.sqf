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
this addWeapon "gm_mpiaks74nk_brn";
this addPrimaryWeaponItem "gm_30Rnd_545x39mm_B_7N6_ak74_prp";
this addWeapon "gm_pm_blk";
this addHandgunItem "gm_8Rnd_9x18mm_B_pst_pm_blk";

comment "Add containers";
this forceAddUniform "gm_gc_army_uniform_dress_80_gry";

comment "Add binoculars";
this addWeapon "gm_df7x40_blk";

comment "Add items to containers";
for "_i" from 1 to 3 do {this addItemToUniform "gm_30Rnd_545x39mm_B_7N6_ak74_prp";};
this addItemToUniform "gm_gc_army_gauzeBandage";
this addItemToUniform "gm_gc_army_medkit";
this addHeadgear "gm_gc_army_headgear_cap_80_gry";

comment "Add items";
this linkItem "ItemMap";
this linkItem "gm_gc_compass_f73";
this linkItem "gm_watch_kosei_80";
this linkItem "ItemRadio";

//comment "Set identity";
//[this,"WhiteHead_20","gm_voice_male_deu_09"] call BIS_fnc_setIdentity;

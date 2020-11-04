
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
this addPrimaryWeaponItem "gm_30Rnd_545x39mm_B_7N6_ak74_org";

comment "Add containers";
this forceAddUniform "gm_gc_army_uniform_soldier_80_str";
this addVest "gm_gc_army_vest_80_rifleman_str";
this addBackpack "gm_gc_army_backpack_80_assaultpack_str";

comment "Add items to containers";
this addItemToUniform "gm_gc_army_gauzeBandage";
for "_i" from 1 to 4 do {this addItemToUniform "gm_gc_army_medkit";};
this addItemToUniform "gm_gc_army_facewear_schm41m";
this addItemToUniform "gm_gc_army_headgear_hat_80_grn";
this addItemToUniform "gm_handgrenade_frag_rgd5";
for "_i" from 1 to 3 do {this addItemToVest "gm_30Rnd_545x39mm_B_7N6_ak74_org";};
this addItemToVest "gm_handgrenade_frag_rgd5";
this addItemToBackpack "gm_ge_army_medkit_80";
for "_i" from 1 to 16 do {this addItemToBackpack "gm_ge_army_burnBandage";};
for "_i" from 1 to 14 do {this addItemToBackpack "gm_ge_army_gauzeBandage";};
for "_i" from 1 to 14 do {this addItemToBackpack "gm_gc_army_gauzeBandage";};
this addHeadgear "gm_gc_army_headgear_m56_net";

comment "Add items";
this linkItem "ItemMap";
this linkItem "gm_gc_compass_f73";
this linkItem "gm_watch_kosei_80";
this linkItem "ItemRadio";

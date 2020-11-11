
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
this addItemToUniform "gm_gc_army_medkit";
this addItemToUniform "gm_gc_army_facewear_schm41m";
this addItemToUniform "gm_gc_army_headgear_hat_80_grn";
for "_i" from 1 to 10 do {this addItemToVest "gm_30Rnd_545x39mm_B_7N6_ak74_org";};
for "_i" from 1 to 2 do {this addItemToVest "gm_handgrenade_frag_rgd5";};
this addItemToBackpack "ToolKit";
this addHeadgear "gm_gc_army_headgear_m56_net";

comment "Add items";
this linkItem "ItemMap";
this linkItem "gm_gc_compass_f73";
this linkItem "gm_watch_kosei_80";
this linkItem "ItemRadio";
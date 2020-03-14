removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

(selectRandom [
	["gm_c7a1_blk", "gm_30Rnd_556x45mm_B_M855_stanag_gry"],
	["gm_m16a2_blk", "gm_30Rnd_556x45mm_B_M855_stanag_gry"]
]) params ["_gun", "_ammo"];

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_m62_net";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_parka_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_beret_bdx_specop";

//	==== Vest ====
this AddVest "gm_ge_army_vest_80_demolition";
this addItemToVest "gm_smokeshell_wht_dm25";
for "_i" from 1 to 6 do {this addItemToVest _ammo;};
for "_i" from 1 to 2 do {this addItemToVest "gm_8Rnd_9x18mm_B_pst_pm_blk";};
for "_i" from 1 to 2 do {this addItemToVest "gm_handgrenade_frag_dm51a1";};

//	==== Backpack ====
this addBackpack "gm_ge_army_backpack_80_oli";
this addItemToBackpack "ACE_DefusalKit";
for "_i" from 1 to 3 do {this addItemToBackpack "gm_explosive_petn_charge";};

//	==== Weapons ====
this AddWeapon _gun;
this addPrimaryWeaponItem _ammo;

this addWeapon "gm_pm_blk";
this addHandgunItem "gm_8Rnd_9x18mm_B_pst_pm_blk";

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "gm_watch_kosei_80";
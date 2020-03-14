removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

(selectRandom [
	["gm_mpiaks74n_brn", "gm_30Rnd_545x39mm_B_7N6_ak74_org"],
	["gm_mp2a1_blk", "gm_32Rnd_9x19mm_B_DM11_mp2_blk"]
]) params ["_gun", "_ammo"];

//	==== Head Gear ====
this addHeadgear "gm_ge_pol_headgear_cap_80_grn";

//	==== Uniform ====
this forceAddUniform "gm_ge_pol_uniform_suit_80_grn";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToUniform _ammo};

//	==== Vest ====

//	==== Backpack ====

//	==== Weapons ====
this addWeapon _gun;
this addHandgunItem _ammo;

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "ItemWatch";
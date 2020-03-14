removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

(selectRandom [
	["gm_pm_blk", "gm_8Rnd_9x18mm_B_pst_pm_blk"],
	["gm_mp2a1_blk", "gm_32Rnd_9x19mm_B_DM11_mp2_blk"]
]) params ["_gun", "_ammo"];

//	==== Head Gear ====
this addHeadgear "gm_ge_pol_headgear_cap_80_wht";

//	==== Uniform ====
this forceAddUniform "gm_ge_pol_uniform_blouse_80_blk";
this addItemToUniform "FirstAidKit";

//	==== Vest ====
this addVest "gm_ge_pol_vest_80_wht";
for "_i" from 1 to 4 do {this addItemToVest _ammo;};

//	==== Backpack ====

//	==== Weapons ====
this addWeapon _gun;
this addHandgunItem _ammo;

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "ItemWatch";
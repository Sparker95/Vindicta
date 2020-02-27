removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = selectRandom ["rhsgref_uniform_ERDL","rhsgref_uniform_og107","rhsgref_uniform_og107_erdl"];
this addUniform _RandomUniform;
_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_erdl","rhsgref_hat_M1951","H_Bandanna_khk","H_Booniehat_oli", "H_Cap_oli"];
this addHeadgear _RandomHeadgear;
this addVest "rhsgref_alice_webbing";

this addWeapon "srifle_DMR_06_hunter_F";
this addPrimaryWeaponItem "optic_KHS_old";
this addPrimaryWeaponItem "rhsusf_20Rnd_762x51_m62_Mag";
this addPrimaryWeaponItem "bipod_03_F_blk";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_20Rnd_762x51_m62_Mag";};
this linkItem "ItemWatch";
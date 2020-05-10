removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = selectRandom ["rhsgref_uniform_ERDL","rhsgref_uniform_og107","rhsgref_uniform_og107_erdl"];
this forceaddUniform _RandomUniform;
_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_erdl","rhsgref_hat_M1951","H_Bandanna_khk","H_Booniehat_oli", "H_Cap_oli"];
this addHeadgear _RandomHeadgear;
this addVest "rhsgref_alice_webbing";
this addBackpack "B_FieldPack_oli";

this addWeapon "rhs_weap_m249";
this addPrimaryWeaponItem "rhsusf_100Rnd_556x45_M855_mixed_soft_pouch";
this addPrimaryWeaponItem "rhsusf_acc_saw_bipod";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_m67";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_100Rnd_556x45_M855_mixed_soft_pouch";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200Rnd_556x45_M855_mixed_soft_pouch";};
this linkItem "ItemWatch";
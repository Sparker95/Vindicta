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

this addWeapon "rhs_weap_m1garand_sa43";
this addPrimaryWeaponItem "rhsgref_8Rnd_762x63_M2B_M1rifle";
this addWeapon "rhs_weap_m72a7";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
for "_i" from 1 to 10 do {this addItemToVest "rhsgref_8Rnd_762x63_M2B_M1rifle";};
this linkItem "ItemWatch";
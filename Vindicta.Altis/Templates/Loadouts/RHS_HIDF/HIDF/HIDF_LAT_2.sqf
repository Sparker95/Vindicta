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

this addWeapon "rhs_weap_m16a4_carryhandle";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "rhs_mag_20Rnd_556x45_M193_Stanag";
this addWeapon "rhs_weap_m72a7";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_20Rnd_556x45_M193_Stanag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_556x45_M193_2MAG_Stanag";};
this linkItem "ItemWatch";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["rhsgref_chestrig", "V_Chestrig_oli", "V_TacVest_oli", "rhsgref_TacVest_ERDL"];
this addVest _RandomVest;
_RandomGoggles = selectRandom ["G_Bandanna_oli", "rhsusf_shemagh_grn", "rhsusf_shemagh2_grn", "rhsusf_shemagh_gogg_grn", "rhsusf_shemagh2_gogg_grn", "", ""];
this addGoggles _RandomGoggles;
this addHeadgear "rhsgref_helmet_pasgt_erdl_rhino";
this forceaddUniform "rhs_uniform_bdu_erdl";
this addBackpack "B_AssaultPack_rgr";

this addWeapon "rhs_weap_m249_pip_S_para";
this addPrimaryWeaponItem "rhsusf_acc_SF3P556";
this addPrimaryWeaponItem "acc_pointer_IR";
this addPrimaryWeaponItem "rhsusf_200Rnd_556x45_M855_mixed_soft_pouch";
this addPrimaryWeaponItem "rhsusf_acc_grip4_bipod";
this addWeapon "rhsusf_weap_m9";
this addHandgunItem "rhsusf_mag_15Rnd_9x19_JHP";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_15Rnd_9x19_JHP";};
this addItemToUniform "rhs_grenade_anm8_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_100Rnd_556x45_M855_mixed_soft_pouch";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_m15_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200Rnd_556x45_M855_mixed_soft_pouch";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_556x45_M855_mixed_soft_pouch";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
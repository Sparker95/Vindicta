removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_olive","FGN_AAF_PASGT_M81","FGN_AAF_PASGT_M81_ESS", "FGN_AAF_PASGT_M81_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","",""];
this addGoggles _RandomGoggles;
this addVest "FGN_AAF_M99Vest_M81_Rifleman";
this forceaddUniform "rhsgref_uniform_olive";
this addBackpack "FGN_AAF_FAST_M81";

this addWeapon "rhs_weap_m249_pip_S_para";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "rhsusf_acc_compm4";
this addPrimaryWeaponItem "rhsusf_100Rnd_556x45_mixed_soft_pouch";
this addPrimaryWeaponItem "rhsusf_acc_kac_grip_saw_bipod";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_100Rnd_556x45_soft_pouch";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_556x45_mixed_soft_pouch";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200Rnd_556x45_mixed_soft_pouch";};
this linkItem "ItemWatch";
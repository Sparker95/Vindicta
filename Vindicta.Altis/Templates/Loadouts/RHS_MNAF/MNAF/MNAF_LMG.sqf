removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = selectRandom ["malden_uniform","mnaf_sweater"];
this forceaddUniform _RandomUniform;
_RandomHeadgear = selectRandom ["malden_bucket","H_Booniehat_khk","rhsusf_ach_bare_des","rhsusf_ach_bare_des_ess"];
this addHeadgear _RandomHeadgear;
this addVest "rhsusf_spc_mg";
this addBackpack "B_FieldPack_cbr";

this addWeapon "rhs_weap_m249_pip_L_para";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhsusf_acc_ELCAN";
this addPrimaryWeaponItem "rhsusf_100Rnd_556x45_mixed_soft_pouch_coyote";
this addPrimaryWeaponItem "rhsusf_acc_kac_grip_saw_bipod";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_100Rnd_556x45_mixed_soft_pouch_coyote";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_556x45_mixed_soft_pouch_coyote";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200Rnd_556x45_mixed_soft_pouch_coyote";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
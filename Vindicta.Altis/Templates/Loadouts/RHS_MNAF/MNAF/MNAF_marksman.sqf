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
this addVest "rhsusf_spc_sniper";

this addWeapon "rhs_weap_m14ebrri";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhsusf_acc_LEUPOLDMK4";
this addPrimaryWeaponItem "rhsusf_20Rnd_762x51_m118_special_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_20Rnd_762x51_m118_special_Mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
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
this addVest "rhsusf_spc_rifleman";

this addWeapon "rhs_weap_m16a4_carryhandle";
_RandomSight = selectRandom ["rhsusf_acc_ACOG_USMC", "rhsusf_acc_compm4", ""];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
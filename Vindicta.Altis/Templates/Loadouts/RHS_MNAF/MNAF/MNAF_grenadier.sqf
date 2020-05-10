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
this addVest "rhsusf_spc_teamleader";
this addBackpack "B_LegStrapBag_coyote_F";

this addWeapon "rhs_weap_m4a1_carryhandle_m203";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
_RandomSight = selectRandom ["rhsusf_acc_compm4", ""];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
for "_i" from 1 to 10 do {this addItemToVest "rhs_mag_M441_HE";};
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_mag_M585_white";};
this addItemToBackpack "rhs_mag_m661_green";
this addItemToBackpack "rhs_mag_m662_red";
this addItemToBackpack "rhs_mag_m713_Red";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m714_White";};
this addItemToBackpack "rhs_mag_m715_Green";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
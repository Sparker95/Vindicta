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
this addVest "malden_vest";
this addBackpack "B_Kitbag_tan";

this addWeapon "rhs_weap_m240G";
this addPrimaryWeaponItem "rhsusf_acc_ARDEC_M240";
this addPrimaryWeaponItem "rhsusf_acc_ACOG_MDO";
this addPrimaryWeaponItem "rhsusf_50Rnd_762x51";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_50Rnd_762x51";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_762x51";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_762x51_m62_tracer";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_50Rnd_762x51_m62_tracer";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
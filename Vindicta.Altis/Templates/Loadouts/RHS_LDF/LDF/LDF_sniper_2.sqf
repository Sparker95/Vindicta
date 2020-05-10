removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhssaf_booniehat_digital","rhssaf_bandana_digital","rhsusf_Bowman","rhsusf_bowman_cap"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "rhssaf_uniform_m10_digital_summer";
this addVest "rhssaf_vest_md99_digital_radio";

this addWeapon "rhs_weap_svdp";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addPrimaryWeaponItem "rhs_10Rnd_762x54mmR_7N14";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_mag_nspd";
for "_i" from 1 to 6 do {this addItemToVest "rhs_10Rnd_762x54mmR_7N14";};
this addItemToVest "rhs_mag_rdg2_white";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x18_8_57N181S";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
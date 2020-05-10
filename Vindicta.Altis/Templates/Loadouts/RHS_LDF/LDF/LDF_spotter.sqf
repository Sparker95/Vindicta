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
this addVest "rhssaf_vest_md99_digital_rifleman_radio";
this addBackpack "rhs_sidor";

this addWeapon "rhs_weap_asval_grip1";
this addPrimaryWeaponItem "rhs_acc_2dpZenit_ris";
this addPrimaryWeaponItem "rhs_20rnd_9x39mm_SP5";
this addPrimaryWeaponItem "rhsusf_acc_kac_grip";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "rhs_pdu4";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_mag_rdg2_white";
this addItemToVest "rhs_mag_nspd";
for "_i" from 1 to 4 do {this addItemToVest "rhs_20rnd_9x39mm_SP5";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_20rnd_9x39mm_SP6";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
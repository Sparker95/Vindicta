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
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli",""];
this addGoggles _RandomGoggles;
this forceaddUniform "rhssaf_uniform_m10_digital_summer";
this addVest "rhssaf_vest_md99_digital_rifleman_radio";
this addBackpack "rhs_sidor";

this addWeapon "rhs_weap_aks74_2";
this addPrimaryWeaponItem "rhs_acc_tgpa";
this addPrimaryWeaponItem "rhs_acc_perst1ik";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N22_plum_AK";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "rhs_pdu4";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_mag_nspn_red";
this addItemToUniform "I_E_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addItemToVest "rhs_mag_rdg2_white";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N22_plum_AK";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgn";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgo";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
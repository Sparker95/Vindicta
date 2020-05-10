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
this forceaddUniform "rhsgref_uniform_para_ttsko_urban";
this addVest "rhssaf_vest_md99_digital_radio";

this addWeapon "rhs_weap_m24sws";
this addPrimaryWeaponItem "rhsusf_acc_LEUPOLDMK4";
this addPrimaryWeaponItem "rhsusf_5Rnd_762x51_m118_special_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_swivel";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_FMJ";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
this addItemToVest "rhs_mag_rdg2_white";
this addItemToVest "rhs_mag_nspd";
for "_i" from 1 to 10 do {this addItemToVest "rhsusf_5Rnd_762x51_m118_special_Mag";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


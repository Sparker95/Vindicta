removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhssaf_helmet_m97_veil_digital","rhssaf_helmet_m97_digital","rhssaf_helmet_m97_digital_black_ess","rhssaf_helmet_m97_digital_black_ess_bare","rhssaf_helmet_m97_olive_nocamo","rhssaf_helmet_m97_olive_nocamo_black_ess","rhssaf_helmet_m97_olive_nocamo_black_ess_bare"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli","rhsusf_shemagh_od","rhsusf_shemagh2_od","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "rhssaf_uniform_m10_digital_summer";
this addVest "rhssaf_vest_md99_digital_rifleman_radio";

this addWeapon "rhs_weap_ak74_2";
this addPrimaryWeaponItem "rhs_acc_dtk3";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_plum_AK";
this addWeapon "rhs_weap_makarov_pm";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_perst1ik";
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_green";};
this addItemToVest "rhs_mag_rdg2_white";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
this addItemToVest "rhs_mag_nspd";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_AK_plum_green";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";